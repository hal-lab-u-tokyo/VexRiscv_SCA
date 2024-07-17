/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/include/iodef.h
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 08:51:43
*    Last Modified: 17-07-2024 21:53:26
*/

#define LED_BASE_ADDR		0xA0000000
#define GPIO_BASE_ADDR		0xA1000000
#define BUFFER_BASE_ADDR	0xA2000000
#define LFSR_BASE_ADDR		0xA3000000

// 10bit LED
typedef union
{
	struct {
		unsigned int led0:	1;
		unsigned int led1:	1;
		unsigned int led2:	1;
		unsigned int led3:	1;
		unsigned int led4:	1;
		unsigned int led5:	1;
		unsigned int led6:	1;
		unsigned int led7:	1;
		unsigned int led8:	1;
		unsigned int led9:	1;
	} __attribute__((__packed__)) bits;
	unsigned int data;
} led_ctrl_t;



#define LED ((volatile led_ctrl_t*)LED_BASE_ADDR)

// Xilinx AXI GPIO IP
typedef struct {
	// unsigned int gpio_data;		// output only (k_header)
	union {
		struct {
			unsigned int out0:	1;
			unsigned int out1:	1;
			unsigned int out2:	1;
			unsigned int out3:	1;
			unsigned int out4:	1;
			unsigned int out5:	1;
			unsigned int out6:	1;
			unsigned int out7:	1;
			unsigned int out8:	1;
			unsigned int out9:	1;
		} __attribute__((__packed__)) bits;
		unsigned int data;
	} gpio_out_data;
	unsigned int gpio_tri;		// not used in this design
	// input only (k_dipsw)
	union {
		struct {
			unsigned int in0:	1;
			unsigned int in1:	1;
			unsigned int in2:	1;
			unsigned int in3:	1;
			unsigned int in4:	1;
			unsigned int in5:	1;
			unsigned int in6:	1;
			unsigned int in7:	1;
		} __attribute__((__packed__)) bits;
		unsigned int data;
	} gpio_in_data;
	unsigned int gpio2_tri;		// not used in this design
} __attribute__((__packed__)) gpio_ctrl_t;

#define GPIO ((volatile gpio_ctrl_t*)GPIO_BASE_ADDR)

// dual channel buffer for serial-like communication b/w VexRiscv and Spartan6()

typedef struct {
	unsigned char empty;
	unsigned char full;
	unsigned short count;
} __attribute__((__packed__)) buf_status_t;

typedef struct {
	unsigned int tx_data;
	buf_status_t tx_status;
	unsigned int rx_data;
	buf_status_t rx_status;
} __attribute__((__packed__)) buffer_t;


#define BUFFER ((volatile buffer_t*)0xA2000000)

// LFSR
typedef struct {
	unsigned int lfsr_seed;
	unsigned int lfsr_data;
} __attribute__((__packed__)) lfsr_ctrl_t;

#define LFSR ((volatile lfsr_ctrl_t*)LFSR_BASE_ADDR)


