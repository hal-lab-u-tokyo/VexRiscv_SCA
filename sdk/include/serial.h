/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/include/serial.h
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:16:02
*    Last Modified: 07-12-2023 09:16:06
*/

void serial_send(unsigned int data);
unsigned int serial_recv(void);