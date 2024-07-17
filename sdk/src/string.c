// This file is extracted from a source code written by Mitaro Namiki on 2010-07-14,15
/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/string.c
*    Project:       slmlet_sdk
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-03-2023 14:29:00
*    Last Modified: 17-07-2024 21:34:12
*/



#include <minilib.h>

int strcmp(const char *s1, const char *s2)
{
	for(; *s1 && *s1 == *s2; ++s1, ++s2) ;
	return *s1 - *s2 ;
}

int strlen(const char *s)
{
	int len = 0;
	while(*s++) ++len ;
	return len;
}

char *strcpy(char *d, const char *s)
{
	char *p ;
	p = d ;
	while((*d++ = *s++) != '\0') ;
	return p;
}

char *strcat(char *d, const char *s)
{
	char *p ;
	p = d ;
	while(*d) ++d ;
	while((*d++ = *s++) != '\0') ;
	return p;
}

int atoi(char *s)
{
	int c, v = 0, sflag = 0;
	if((c = *s++) == '-') { sflag = 1 ; c = *s++ ; }
	for(; '0' <= c && c <= '9'; c = *s++)
		v = 10 * v + (c - '0') ;
	return sflag ? -v : v ;
}

int xtoi(char *s)
{
	int c, v = 0 ;
	while(1) {
		c = *s++ ;
		if('0' <= c && c <= '9')
			c -= '0' ;
		else if('a' <= c && c <= 'f')
			c -= 'a' - 10 ;
		else if('A' <= c && c <= 'F')
			c -= 'A' - 10 ;
		else
			break ;
		v =  (v << 4) | c ;
	}
	return v ;
}

void strrev(char *str)
{
	int i, len;
	char buf[100];

	len = strlen(str) - 1;

	for ( i = 0; i <= len; i++)
		buf[i] = str[len-i];

	buf[i] = 0;

	strcpy(str, buf);
}

char *itoa(int x, char *buf, int radix)
{
	int i = 0, xx;

	if ( x == 0 ) {
		buf[0] = '0';
		buf[1] = 0;
	} else {
		while ( x > 0 ) {
			xx =  x % radix;
			x /= radix;
			buf[i++] = '0' + xx;
		}
		buf[i] = 0;
		strrev(buf);
	}

	return buf;
}