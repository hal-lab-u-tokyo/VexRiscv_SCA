/*
*    Copyright (C) 2024 The University of Tokyo
*    
*    File:          /sdk/src/led.c
*    Project:       sakura-x-vexriscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  17-07-2024 21:39:54
*    Last Modified: 01-03-2025 17:39:27
*/


#include <minilib.h>
#include <iodef.h>

inline void led_set(int pos, int val)
{
	switch(pos) {
		#define X(n) case n: LED->bits.led##n = val; break;
		#if defined(__SAKURA_X_TARGET__)
		BIT_FIELDS_10
		#elif defined(__CW305_TARGET__)
		BIT_FIELDS_3
		#endif
		#undef X
	}
}
void led_on(int pos)
{
	led_set(pos, 1);
}

void led_off(int pos)
{
	led_set(pos, 0);
}

void led_all_on()
{
	LED->data = (1u << LED_COUNT) - 1;
}

void led_all_off()
{
	LED->data = 0x0;
}