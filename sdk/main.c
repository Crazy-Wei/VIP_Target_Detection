/*
 * main.c
 *
 *  Created on: 2020Äê8ÔÂ1ÈÕ
 *      Author: zzw
 */


#include <stdio.h>
#include "xparameters.h"
#include "sleep.h"

#define	CAM_VALUE_BASEADDR		XPAR_CAMERA_VALUE_0_S00_AXI_BASEADDR

u32 S_cnt, T_cnt;
u32 fps_rate;
u32 threshold;
float f;
void camera()
{
	Xil_Out32(CAM_VALUE_BASEADDR,0x02);
	Xil_Out32(CAM_VALUE_BASEADDR,0x01);
	sleep(1);
	S_cnt = Xil_In32(CAM_VALUE_BASEADDR + 4);
	T_cnt = Xil_In32(CAM_VALUE_BASEADDR + 8);
	fps_rate = Xil_In32(CAM_VALUE_BASEADDR + 12);
	threshold = Xil_In32(CAM_VALUE_BASEADDR + 16);
	f = (float)100 * T_cnt / S_cnt;
	printf("pclk = %.2f MHz   fps_rate = %d fps   threshold = %d\n", f, fps_rate, threshold);
}

int main()
{
    printf("target detection demo!\n\r");
	while(1)
	{
		camera();
	}
    return 0;
}
