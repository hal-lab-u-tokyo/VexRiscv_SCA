/*
*    Copyright (C) 2024 The University of Tokyo
*    
*    File:          /sdk/src/led.c
*    Project:       sakura-x-vexriscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  17-07-2024 21:39:54
*    Last Modified: 17-07-2024 21:47:36
*/


#include <minilib.h>
#include <iodef.h>

void led_on(int pos)
{
	switch(pos) {
		case 0: LED->bits.led0 = 1; break;
		case 1: LED->bits.led1 = 1; break;
		case 2: LED->bits.led2 = 1; break;
		case 3: LED->bits.led3 = 1; break;
		case 4: LED->bits.led4 = 1; break;
		case 5: LED->bits.led5 = 1; break;
		case 6: LED->bits.led6 = 1; break;
		case 7: LED->bits.led7 = 1; break;
		case 8: LED->bits.led8 = 1; break;
		case 9: LED->bits.led9 = 1; break;
	}

}

void led_off(int pos)
{
	switch(pos) {
		case 0: LED->bits.led0 = 0; break;
		case 1: LED->bits.led1 = 0; break;
		case 2: LED->bits.led2 = 0; break;
		case 3: LED->bits.led3 = 0; break;
		case 4: LED->bits.led4 = 0; break;
		case 5: LED->bits.led5 = 0; break;
		case 6: LED->bits.led6 = 0; break;
		case 7: LED->bits.led7 = 0; break;
		case 8: LED->bits.led8 = 0; break;
		case 9: LED->bits.led9 = 0; break;
	}
}

void led_all_on()
{
	LED->data = 0x3FF;
}

void led_all_off()
{
	LED->data = 0x000;
}