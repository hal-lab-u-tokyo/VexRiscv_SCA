/*
*    Copyright (C) 2025 The University of Tokyo
*    
*    File:          /bootloader/main.c
*    Project:       VexRiscv_SCA
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  01-03-2025 17:51:13
*    Last Modified: 01-03-2025 17:51:14
*/

void main(void)
{
	extern unsigned int _imem;
	__asm__ ("jalr %0" : : "r" (&_imem));
}