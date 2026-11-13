
#include <stdint.h>
#include <string.h>

#include "platform.h"
#include "xil_printf.h"
#include "xtime_l.h"



// Tamano de la zona de memoria que vamos a utilizar
#define N_BYTES 4096

// Direccion inicial de nuestra zona de pruebas DDR
#define DDR_TEST_BASE 0x3FF00000U

// Arrays auxiliares para las operaciones de copia
// Estos arrays se almacenan en la DDR habitual del programa.
uint32_t origen[N_BYTES / 4];
uint32_t destino[N_BYTES / 4];


int main()
{
    int i;
    int error;

    XTime inicio, fin;

    // Punteros para acceder directamente a la zona DDR reservada.
    // Los tres utilizan la misma direccion inicial, pero permiten acceder con diferentes tamanos de datos.

    uint8_t *p8 = (uint8_t *)DDR_TEST_BASE;
    uint16_t *p16 = (uint16_t *)DDR_TEST_BASE;
    uint32_t *p32 = (uint32_t *)DDR_TEST_BASE;


    init_platform();

    // VALIDACION DE ACCESOS DE 8 BITS

    // Escribimos datos de 8 bits en toda la zona DDR.
    for (i = 0; i < N_BYTES; i++)
    {
        p8[i] = (uint8_t)i;
    }

    // Leemos los datos y comprobamos que coinciden.
    error = 0;

    for (i = 0; i < N_BYTES; i++)
    {
        if (p8[i] != (uint8_t)i)
        {
            error = 1;
        }
    }

    // Mostramos el resultado de la validacion.
    if (error == 0)
    {
        xil_printf("Validacion 8 bits: CORRECTA\r\n");
    }
    else
    {
        xil_printf("Validacion 8 bits: ERROR\r\n");
    }


    //VALIDACION DE ACCESOS DE 16 BITS

    // Escribimos datos de 16 bits en la misma zona DDR.
    for (i = 0; i < N_BYTES / 2; i++)
    {
        p16[i] = (uint16_t)i;
    }

    // Leemos y comprobamos los datos almacenados.
    error = 0;

    for (i = 0; i < N_BYTES / 2; i++)
    {
        if (p16[i] != (uint16_t)i)
        {
            error = 1;
        }
    }

    if (error == 0)
    {
        xil_printf("Validacion 16 bits: CORRECTA\r\n");
    }
    else
    {
        xil_printf("Validacion 16 bits: ERROR\r\n");
    }


    // =====================================================
    // 3. VALIDACION DE ACCESOS DE 32 BITS
    // =====================================================

    // Escribimos datos de 32 bits en la misma zona DDR.
    for (i = 0; i < N_BYTES / 4; i++)
    {
        p32[i] = (uint32_t)i;
    }

    // Leemos y comprobamos los datos almacenados.
    error = 0;

    for (i = 0; i < N_BYTES / 4; i++)
    {
        if (p32[i] != (uint32_t)i)
        {
            error = 1;
        }
    }

    if (error == 0)
    {
        xil_printf("Validacion 32 bits: CORRECTA\r\n");
    }
    else
    {
        xil_printf("Validacion 32 bits: ERROR\r\n");
    }



    // PREPARACION DE DATOS PARA LAS MEDICIONES

    // Rellenamos el array origen con los datos que queremos
    // escribir posteriormente en la zona DDR de pruebas.
    for (i = 0; i < N_BYTES / 4; i++)
    {
        origen[i] = i + 100;
    }


    // MEDICION DE ACCESOS INDIVIDUALES


    // Medimos cuanto tiempo tardamos en escribir los datos individualmente en la memoria DDR.
    XTime_GetTime(&inicio);

    for (i = 0; i < N_BYTES / 4; i++)
    {
        p32[i] = origen[i];
    }

    XTime_GetTime(&fin);

    xil_printf("Escritura individual: %d ticks\r\n",
               (int)(fin - inicio));


    // Medimos cuanto tiempo tardamos en leer los datos individualmente desde la memoria DDR.
    XTime_GetTime(&inicio);

    for (i = 0; i < N_BYTES / 4; i++)
    {
        destino[i] = p32[i];
    }

    XTime_GetTime(&fin);

    xil_printf("Lectura individual: %d ticks\r\n",
               (int)(fin - inicio));


    // MEDICION DE ACCESOS MEDIANTE MEMCPY

    // Copiamos el array origen directamente a la DDR.
    XTime_GetTime(&inicio);

    memcpy((void *)DDR_TEST_BASE, origen, N_BYTES);

    XTime_GetTime(&fin);

    xil_printf("Escritura mediante memcpy: %d ticks\r\n",
               (int)(fin - inicio));


    // Copiamos los datos almacenados en DDR hacia destino.
    XTime_GetTime(&inicio);

    memcpy(destino, (void *)DDR_TEST_BASE, N_BYTES);

    XTime_GetTime(&fin);

    xil_printf("Lectura mediante memcpy: %d ticks\r\n",
               (int)(fin - inicio));


    cleanup_platform();

    return 0;
}
