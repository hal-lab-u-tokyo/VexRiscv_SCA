// A part of codes in this file were written by Mitaro Namiki on 2010-07-14,15 for Geyser library
/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/include/minilib.h
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:03:10
*    Last Modified: 17-07-2024 21:56:29
*/


#ifndef __MYLIB_H_
#define __MYLIB_H_

typedef	unsigned char	uint8;
typedef unsigned short	uint16;
typedef	unsigned int	uint32;

typedef	unsigned int	size_t;

#ifndef NULL
#define NULL ((void*)0)
#endif

extern int printf(char *, ...) ;
extern int scanf(const char *format, ...);

extern char *gets(char *) ;
extern char *puts(char *s);

extern int atoi(char *) ;
extern int xtoi(char *) ;
char *itoa(int, char *, int);

extern int strcmp(const char *, const char *) ;
extern int strlen(const char *) ;
extern char *strcpy(char *, const char *) ;
extern char *strcat(char *, const char *) ;


extern int getchar();
extern int putchar(int ch);

extern int rand(void);
extern void srand(unsigned int seed);

extern void led_on(int pos);
extern void led_off(int pos);
extern void led_all_on();
extern void led_all_off();

extern void pinHeaderWrite(int pos, int val);
extern int dipSwitchRead(int pos);


#endif	/* __MYLIB_H_ */
