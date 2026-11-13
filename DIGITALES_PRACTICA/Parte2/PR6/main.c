#include <stdint.h>
#include <string.h>
#include "platform.h"
#include "xil_printf.h"
#include "xtime_l.h"



// Tamano de la zona de memoria que vamos a utilizar
#define N_BYTES 4096

// Direccion inicial de nuestra zona de pruebas DDR
#define DDR_TEST_BASE 0x40000000


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
    XTime_GetTime(&inicio);
    // Escribimos datos de 8 bits en toda la zona DDR.
    for (i = 0; i < N_BYTES; i++)
    {
        p8[i] = (uint8_t)i;
    }

    XTime_GetTime(&fin);
    xil_printf("Tiempo de escritura 8 bits: %d us\r\n", (int)(fin - inicio)/(COUNTS_PER_SECOND/1000000));

    // Leemos los datos y comprobamos que coinciden.
    error = 0;
    XTime_GetTime(&inicio);
    for (i = 0; i < N_BYTES; i++)
    {
        if (p8[i] != (uint8_t)i)
        {
            error = 1;
        }
    }
    XTime_GetTime(&fin);
    xil_printf("Tiempo de lectura 8 bits: %d us\r\n", (int)(fin - inicio)/(COUNTS_PER_SECOND/1000000));

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
    XTime_GetTime(&inicio);
    // Escribimos datos de 16 bits en la misma zona DDR.
    for (i = 0; i < N_BYTES / 2; i++)
    {
        p16[i] = (uint16_t)i;
    }
    XTime_GetTime(&fin);
    xil_printf("Tiempo de escritura 16 bits: %d us\r\n", (int)(fin - inicio)/(COUNTS_PER_SECOND/1000000));

    // Leemos y comprobamos los datos almacenados.
    error = 0;
    XTime_GetTime(&inicio);
    for (i = 0; i < N_BYTES / 2; i++)
    {
        if (p16[i] != (uint16_t)i)
        {
            error = 1;
        }
    }
    XTime_GetTime(&fin);
    xil_printf("Tiempo de lectura 16 bits: %d us\r\n", (int)(fin - inicio)/(COUNTS_PER_SECOND/1000000));

    if (error == 0)
    {
        xil_printf("Validacion 16 bits: CORRECTA\r\n");
    }
    else
    {
        xil_printf("Validacion 16 bits: ERROR\r\n");
    }


    // VALIDACION DE ACCESOS DE 32 BITS

    XTime_GetTime(&inicio);
    // Escribimos datos de 32 bits en la misma zona DDR.
    for (i = 0; i < N_BYTES / 4; i++)
    {
        p32[i] = (uint32_t)i;
    }
    XTime_GetTime(&fin);
    xil_printf("Tiempo de escritura 32 bits: %d us\r\n", (int)(fin - inicio)/(COUNTS_PER_SECOND/1000000));

    // Leemos y comprobamos los datos almacenados.
    error = 0;
    XTime_GetTime(&inicio);
    for (i = 0; i < N_BYTES / 4; i++)
    {
        if (p32[i] != (uint32_t)i)
        {
            error = 1;
        }
    }
    XTime_GetTime(&fin);
    xil_printf("Tiempo de lectura 32 bits: %d us\r\n", (int)(fin - inicio)/(COUNTS_PER_SECOND/1000000));

    if (error == 0)
    {
        xil_printf("Validacion 32 bits: CORRECTA\r\n");
    }
    else
    {
        xil_printf("Validacion 32 bits: ERROR\r\n");
    }

    cleanup_platform();

    return 0;
}
