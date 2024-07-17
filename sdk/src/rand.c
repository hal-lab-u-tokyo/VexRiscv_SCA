/*
*    Copyright (C) 2024 The University of Tokyo
*    
*    File:          /sdk/src/rand.c
*    Project:       sakura-x-vexriscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  17-07-2024 21:36:59
*    Last Modified: 17-07-2024 22:06:36
*/


#include <minilib.h>
#include <iodef.h>

int rand(void)
{
	return LFSR->lfsr_data;
}

void srand(unsigned int seed)
{
	LFSR->lfsr_seed = seed;
}