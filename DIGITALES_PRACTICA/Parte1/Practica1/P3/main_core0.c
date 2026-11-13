
#include "platform.h"
#include "xil_mmu.h"
#include "xtime_l.h"
#include "mutex_blk.h"
#include <stdio.h>

// Number of iterations
#define TEST_SAMPLES	1000
//#define SHAREABLE (1 << 16)
#define NON_CACHED (0)
#define WB_WA_CACHE (1) /* write back, write allocate */
#define WT_CACHE (2) /* write thru */
#define WB_CACHE (3) /* write back */
#define INNER_SHIFT (2)
#define OUTER_SHIFT (12)
#define TEX_MSB (1 << 14)
#define AP_FAULT (0) /* no access, a fault */
#define AP_FULL (3 << 10) /* full access */
#define DOMAIN(x) (x << 5)
#define INNER_NON_CACHED (NON_CACHED << INNER_SHIFT)
#define INNER_WB_WA (WB_WA_CACHE<< INNER_SHIFT)
#define INNER_WT (WT_CACHE<< INNER_SHIFT)
#define INNER_WB (WB_CACHE<< INNER_SHIFT)
#define OUTER_NON_CACHED (TEX_MSB | (NON_CACHED << OUTER_SHIFT))
#define OUTER_WB_WA (TEX_MSB | (WB_WA_CACHE<< OUTER_SHIFT))
#define OUTER_WT (TEX_MSB | (WT_CACHE<< OUTER_SHIFT))
#define OUTER_WB (TEX_MSB | (WB_CACHE << OUTER_SHIFT))
#define SECTION(attributes) ((attributes) | 0x2)
#define SUPER_SECTION(attributes) ((attributes) | 0x4002)

// Las optimizaciones del compilador pueden hacer que optimice la localizaci n de estas variables dentro del mapa de memoria. Para que en ambos procesadores est n en la misma regi n, se estable la m nima optimizaci n (o0) en esta parte del programa en ambos cores.
#pragma GCC push_options
#pragma GCC optimize ("O0")

// Mutex en cada core que se aloja en la secci n .mem_mutex del linker script con alineamiento d 32 bits.
volatile unsigned int ctrl_mutex __attribute__ ((section (".mem_mutex"))) __attribute__( ( aligned ( 32 ) ) ) = unlocked;

#define DATA_LEN 100
volatile unsigned int data[DATA_LEN] __attribute__ ((section (".mem_mutex"))) __attribute__( ( aligned ( 32 ) ) );
volatile unsigned int result[DATA_LEN] __attribute__ ((section (".mem_mutex"))) __attribute__( ( aligned ( 32 ) ) );
volatile unsigned int datos_listos __attribute__ ((section(".mem_mutex")))__attribute__((aligned(32))) = 0;

#pragma GCC pop_options


int main(void)
{
    unsigned int estado;
    double tiempo_secuencial;
    double tiempo_paralelo;
    double comparacion;

    int Array[100], i=0, j=0; // AGR: Lo he cambiado a variable local, pero da un poco igual
    XTime tStart, tEnd;

    init_platform();

    /* Configurar la memoria compartida */
    Xil_SetTlbAttributes(0x03000000, SECTION(SHAREABLE|NON_CACHED)); // AGR: Lo he cambiado

    /* Inicializar los datos */
    for (i = 0; i < DATA_LEN; i++)
    {
        Array[i] = i + 1;
        data[i] = i + 1;
        result[i] = 0;
    }

    ///////////////////////////////////////////////////////////////////

    // Comparamos el tiempo de ejecución utilizando únicamente el Core 0 y utilizando ambos cores,
    // realizando las mismas operaciones y accediendo a las mismas variables.
    //
    // Es importante que las condiciones de acceso a memoria sean equivalentes. Por ejemplo,
    // acceder a Array[i], si está en memoria local, puede ser mucho más rápido que
    // acceder a data[i], si está en memoria DDR compartida (acordaos de las comprobaciones de caché).
    //
    // Por tanto, comparar ambos casos no sería justo, ya que la diferencia de tiempo podría
    // deberse a la latencia de acceso a memoria y no a la utilización de uno o dos cores.

    ///////////////////////////////////////////////////////////////////


    // CALCULO CON UN SOLO CORE

    XTime_GetTime(&tStart);

	for (i = 0; i < DATA_LEN; i++)
	{
		result[i] = data[i] * 5; // AGR: Esto a cambiado para que ambas variables sean locales
	}

    XTime_GetTime(&tEnd);

    tiempo_secuencial = 1000000.0 * ((double)(tEnd - tStart) / (double)COUNTS_PER_SECOND); // AGR: Puede que veais alguna diferencia aquí

    printf("Tiempo secuencial medio: %.4f us\r\n", tiempo_secuencial);

    /* Limpiar los resultados antes del calculo paralelo */
    for (i = 0; i < DATA_LEN; i++)
    {
        result[i] = 0;
    }

    sleep(10); //Sin este sleep XTime_GetTime deja de funcionar porque el core1 al inicializarse más tarde que el core0 reinicia el contador


    //CALCULO CON DOS CORES
    printf("Empieza core 0 y core 1\r\n");

    /* Iniciar la medida antes de dar la orden a Core 1 */


    lock_mutex(&ctrl_mutex);

    datos_listos = 1;

    unlock_mutex(&ctrl_mutex);

    printf("Mutex Ejecutado\r\n");

    XTime_GetTime(&tStart);
    /* Core 0 calcula los primeros 50 datos */
//    for (sample = 0; sample < TEST_SAMPLES; sample++)
//    {
        for (i = 0; i < DATA_LEN / 2; i++)
        {
            result[i] = data[i] * 5;
        }
//    }


    /* Esperar a que Core 1 termine */
    do
    {
//        lock_mutex((void *)&ctrl_mutex);
        estado = datos_listos;
//        unlock_mutex((void *)&ctrl_mutex);

    } while (estado != 2);

    XTime_GetTime(&tEnd);

    tiempo_paralelo = 1000000.0 * ((double)(tEnd - tStart) / (double)COUNTS_PER_SECOND);

    printf("Tiempo paralelo medio: %.4f us\r\n", tiempo_paralelo);

    printf("Ticks start: %f\r\n", (double)tStart);
    printf("Ticks end: %f\r\n", (double)tEnd);


    //COMPROBAR LOS RESULTADOS


    for (i = 45; i < 55; i++)
    {
        if (result[i] != data[i] * 5)
        {
            printf("Error en el dato %d\r\n", i);
            break;
        }
    }

    if (i == DATA_LEN)
    {
        printf("Todos los resultados son correctos\r\n");
    }


    //COMPARAR LOS TIEMPOS
    if (tiempo_paralelo > 0.0)
    {
        comparacion = tiempo_secuencial / tiempo_paralelo;

        printf("Comparacion: %.2f veces\r\n", comparacion);
    }

    cleanup_platform();

    return 0;
}
