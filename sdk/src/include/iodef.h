/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/include/iodef.h
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 08:51:43
*    Last Modified: 01-03-2025 17:44:54
*/

#define LED_BASE_ADDR		0xA0000000
#define GPIO_BASE_ADDR		0xA1000000
#define BUFFER_BASE_ADDR	0xA2000000
#define LFSR_BASE_ADDR		0xA3000000

#define BIT_FIELDS_10 \
    X(0)  \
    X(1)  \
    X(2)  \
    X(3)  \
    X(4)  \
    X(5)  \
    X(6)  \
    X(7)  \
    X(8)  \
    X(9)

#define BIT_FIELDS_12 \
    X(0)  \
    X(1)  \
    X(2)  \
    X(3)  \
    X(4)  \
    X(5)  \
    X(6)  \
    X(7)  \
    X(8)  \
    X(9)  \
	X(10) \
	X(11)

#define BIT_FIELDS_8 \
	X(0)  \
	X(1)  \
	X(2)  \
	X(3)  \
	X(4)  \
	X(5)  \
	X(6)  \
	X(7)

#define BIT_FIELDS_4 \
	X(0)  \
	X(1)  \
	X(2)  \
	X(3)

#define BIT_FIELDS_3 \
	X(0)  \
	X(1)  \
	X(2)


#if defined(__SAKURA_X_TARGET__)
#define LED_COUNT 10
#elif defined(__CW305_TARGET__)
#define LED_COUNT 3
#else
#error "Target board is not defined or unknown"
#endif

// 10bit LED or 4bit LED
typedef union
{
	struct {
		#define X(n) unsigned int led##n : 1;
		#if defined(__SAKURA_X_TARGET__)
		BIT_FIELDS_10
		#elif defined(__CW305_TARGET__)
		BIT_FIELDS_3
		#endif
		#undef X
	} __attribute__((__packed__)) bits;
	unsigned int data;
} led_ctrl_t;



#define LED ((volatile led_ctrl_t*)LED_BASE_ADDR)


// Xilinx AXI GPIO IP
typedef struct {
	// output only (header pin)
	union {
		struct {
			#define X(n) unsigned int out##n : 1;
			#if defined(__SAKURA_X_TARGET__)
			BIT_FIELDS_10
			#elif defined(__CW305_TARGET__)
			BIT_FIELDS_12
			#endif
			#undef X
		} __attribute__((__packed__)) bits;
		unsigned int data;
	} gpio_out_data;
	unsigned int gpio_tri;		// not used in this design
	// input only (dip switch)
	union {
		struct {
			#define X(n) unsigned int in##n : 1;
			#if defined(__SAKURA_X_TARGET__)
			BIT_FIELDS_8
			#elif defined(__CW305_TARGET__)
			BIT_FIELDS_4
			#endif
			#undef X
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


