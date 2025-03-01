/*
*    Copyright (C) 2024 The University of Tokyo
*    
*    File:          /sdk/src/gpio.c
*    Project:       sakura-x-vexriscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  17-07-2024 21:48:37
*    Last Modified: 01-03-2025 18:22:05
*/

#include <iodef.h>

void pinHeaderWrite(int pos, int val)
{
	switch(pos) {
		#define X(n) case n: GPIO->gpio_out_data.bits.out##n = val; break;
		#if defined(__SAKURA_X_TARGET__)
		BIT_FIELDS_10
		#elif defined(__CW305_TARGET__)
		BIT_FIELDS_12
		#endif
		#undef X
	}
}

int dipSwitchRead(int pos)
{
	switch(pos) {
		#define X(n) case n: return GPIO->gpio_in_data.bits.in##n;
		#if defined(__SAKURA_X_TARGET__)
		BIT_FIELDS_8
		#elif defined(__CW305_TARGET__)
		BIT_FIELDS_4
		#endif
		#undef X
	}
	return 0;
}

