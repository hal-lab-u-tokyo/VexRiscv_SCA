/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/serial.c
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:11:00
*    Last Modified: 17-07-2024 21:32:59
*/



#include <iodef.h>
#include <serial.h>

void serial_send(unsigned int data)
{
	while (BUFFER->tx_status.full);
	BUFFER->tx_data = data;
}

unsigned int serial_recv()
{
	while (BUFFER->rx_status.empty);
	return BUFFER->rx_data;
}

unsigned int available()
{
	return BUFFER->rx_status.count;
}