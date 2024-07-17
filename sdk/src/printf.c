// A part of codes in this file were written by Mitaro Namiki on 2010-07-14,15 for Geyser library
/*
*    Copyright (C) 2023 The University of Tokyo
*
*    File:          /sdk/src/printf.c
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:07:34
*    Last Modified: 17-07-2024 21:34:42
*/


#include <stdarg.h>
#include <minilib.h>


static int To2Power(unsigned int w, char *pbuf, int pw, int isbig)
{
	int c, i = 0, mask = ((1 << pw) - 1);
	char *s ;
	do {
		c = w & mask ; w >>= pw ;
		pbuf[i++] = (isbig ? "0123456789ABCDEF" : "0123456789abcdef")[c] ;
	} while(w) ;
	return i ;
}
static int ToDec(int w, char *pbuf, int uflag)
{
	unsigned int ww ;
	unsigned int c, sflag = 0, i = 0 ;
	if(uflag || w >= 0)
		ww = w ;
	else {
		ww = -w ; sflag = 1 ;
	}
	do {
		c = ww % 10;
		ww /= 10 ;
		pbuf[i++] = c + (int)'0' ;
	} while(ww) ;
	return sflag ? -i : i ;
}

int printf(char *fmt, ...)
{
	va_list args ;
	int c, argc, lpos, padding,cwidth, fmtch,padnum, len ;
	int w, big, sflag, uflag, outcnt, flag2, pw ;
	char *s, *p ;
	char wbuf[36] ;

	va_start(args,fmt);

	outcnt = 0 ;
	while ((c = *fmt) != '\0') {
		if(c != '%') {
			putchar(c) ;
			++fmt ; ++outcnt ;
			continue;
		}
		padding = ' ' ; lpos = 0 ; cwidth = 0 ;
		c = *++fmt ;
		if(c == '0') {
			padding = '0' ; lpos = 0 ; c = *++fmt ;
		}
		if(c == '-') {
			lpos = 1 ; c = *++fmt ; padding = ' ' ;
		}
		while('0' <= c && c <= '9') {
			cwidth = 10 * cwidth + (c - '0') ;
			c = *++fmt ;
		}
		if(! c) break ;

		if(c != 'u')
			uflag = 0 ;
		else {
			c = *++fmt ; uflag = 1 ;
		}
		big = len = sflag = flag2 = 0 ;
		switch(fmtch = c) {
		case 'c':
			c = va_arg(args, int) ;
		case '%':
			wbuf[0] = c ; len = 1 ; break ;
		case 'X': big = 1 ;
		case 'x': pw = 4 ; flag2 = 1 ; break ;
		case 'o': pw = 3 ; flag2 = 1 ; break ;
		case 'b': pw = 1 ; flag2 = 1 ; break ;
		case 'd':
			w = va_arg(args, int) ; len = ToDec(w, wbuf, uflag) ;
			if(len < 0) { len = -len ; sflag = 1 ;}
			break ;
		case 's':
			for(s = p = va_arg(args, char *), len = 0 ; *p++ ; ++len) ;
			break ;
		case '\0':
			goto Done ;
		}
		if(flag2) {
			w = va_arg(args, int) ; len = To2Power(w, wbuf, pw, big) ;
		}
		padnum = cwidth - len ;
		if(sflag) {
			putchar('-') ; --padnum ; ++outcnt ;
		}
		if(!lpos) {
			for(; --padnum >= 0; ++outcnt) putchar(padding) ;
		}
		if(fmtch == 's')
			for(; (c = *s++) != '\0' ; ++outcnt) putchar(c) ;
		else
			for(; len-- > 0 ; ++outcnt) putchar(wbuf[len]) ;
		if(lpos)
			for(; --padnum >= 0 ; ++outcnt) putchar(padding) ;
		++fmt ;
	}
 Done:
	va_end(args) ;
	return outcnt ;
}