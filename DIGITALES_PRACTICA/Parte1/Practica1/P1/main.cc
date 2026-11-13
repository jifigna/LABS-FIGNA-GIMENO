/*
 * Empty C++ Application
 */
#include <complex>
//#include "Flexfft.h"
#include "DataIn.h"
#include "DataOut_OK.h"
#include "xtime_l.h"
#include <stdio.h>
#include "xil_printf.h"

#define FFT_LENGTH 512

std::complex<float> error[FFT_LENGTH];
int i=0,errorT=0;
float cota=0.69;

int main()

{
	XTime tStart, tEnd;


	sampleOutX_t dataout[FFT_LENGTH];


	XTime_GetTime(&tStart);
	FlexFFT(DataIn, dataout);
	XTime_GetTime(&tEnd);

	//float tiempo_segundos=1.0*(tEnd-tStart)/ COUNTS_PER_SECOND;
	//float tiempo_microsegundos=1000000.0*(tEnd-tStart)/ COUNTS_PER_SECOND;


	printf("FFT run: %llu clock cycles.\n", 2*(tEnd-tStart));
	printf("FFT run:%.4f us.\n", 1.0*(tEnd-tStart)/(COUNTS_PER_SECOND/1000000));
	//xil_printf("Tiempo de ejecucion: %f segundos \n", tiempo_segundos);
	//xil_printf("Tiempo de ejecucion: %f microsegundos \n", tiempo_microsegundos);

	for(i=0;i<FFT_LENGTH;i++)
	{
		error[i]=dataout[i]-DataOut_OK[i];

		if(abs(error[i]) > cota)
		{
			errorT++;
			printf("ERROR\n");
		}
		else
		{
			printf("NO_ERROR\n");
		}
	}
	printf("Errores totales: %d", errorT);


	return 0;
}
