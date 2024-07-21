/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/include/serial.h
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:16:02
*    Last Modified: 21-07-2024 19:56:50
*/

void serial_send(unsigned int data);
unsigned int serial_recv(void);
unsigned int serial_available();