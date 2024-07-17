/*
*    Copyright (C) 2024 The University of Tokyo
*    
*    File:          /sdk/src/gpio.c
*    Project:       sakura-x-vexriscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  17-07-2024 21:48:37
*    Last Modified: 17-07-2024 21:56:32
*/

#include <iodef.h>

void pinHeaderWrite(int pos, int val)
{
	switch(pos) {
		case 0: GPIO->gpio_out_data.bits.out0 = val; break;
		case 1: GPIO->gpio_out_data.bits.out1 = val; break;
		case 2: GPIO->gpio_out_data.bits.out2 = val; break;
		case 3: GPIO->gpio_out_data.bits.out3 = val; break;
		case 4: GPIO->gpio_out_data.bits.out4 = val; break;
		case 5: GPIO->gpio_out_data.bits.out5 = val; break;
		case 6: GPIO->gpio_out_data.bits.out6 = val; break;
		case 7: GPIO->gpio_out_data.bits.out7 = val; break;
		case 8: GPIO->gpio_out_data.bits.out8 = val; break;
		case 9: GPIO->gpio_out_data.bits.out9 = val; break;
	}
}

int dipSwitchRead(int pos)
{
	switch(pos) {
		case 0: return GPIO->gpio_in_data.bits.in0;
		case 1: return GPIO->gpio_in_data.bits.in1;
		case 2: return GPIO->gpio_in_data.bits.in2;
		case 3: return GPIO->gpio_in_data.bits.in3;
		case 4: return GPIO->gpio_in_data.bits.in4;
		case 5: return GPIO->gpio_in_data.bits.in5;
		case 6: return GPIO->gpio_in_data.bits.in6;
		case 7: return GPIO->gpio_in_data.bits.in7;
	}
	return 0;
}



