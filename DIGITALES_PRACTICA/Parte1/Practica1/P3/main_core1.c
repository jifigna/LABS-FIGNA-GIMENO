#include "platform.h"
#include "xil_mmu.h"
//#include "xtime_l.h"
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
    int sample;

    int i=0;
//    XTime tStart, tEnd; // AGR: Cambiado a variables locales

    init_platform();
//    printf("Hola mundo");
    /* Configurar la memoria compartida */
    Xil_SetTlbAttributes(0x03000000, SECTION(SHAREABLE|NON_CACHED));
    /*
     * Esperar a que Core 0 indique el comienzo.
     * No se modifica datos_listos mientras esperamos.
     */
    while (datos_listos != 1)
    {
        /* Espera activa */
    }

    /*
     * Adquirir y liberar el mutex para sincronizar
     * el acceso con Core 0 antes de usar los datos.
     */
//    lock_mutex((void *)&ctrl_mutex);
//    unlock_mutex((void *)&ctrl_mutex);

    /* Core 1 calcula los otros 50 datos */
//    for (sample = 0; sample < TEST_SAMPLES; sample++)
//    {
        for (i = DATA_LEN / 2; i < DATA_LEN; i++)
        {
            result[i] = data[i] * 5;
        }
//    }

    /* Indicar a Core 0 que el trabajo ha terminado */
    lock_mutex((void *)&ctrl_mutex);

    datos_listos = 2;

    unlock_mutex((void *)&ctrl_mutex);

    /* Mantener Core 1 activo */
    while (1)
    {
        /* Espera */
    }

    return 0;
}



