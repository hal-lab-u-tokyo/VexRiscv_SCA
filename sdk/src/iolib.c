// A part of codes in this file were written by Mitaro Namiki on 2010-07-14,15 for Geyser library
/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/iolib.c
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:10:08
*    Last Modified: 07-12-2023 09:49:35
*/

#include <minilib.h>
#include <serial.h>

int getchar()
{
    return serial_recv();
}

int putchar(int ch) {
    serial_send(ch);
    return ch;
}

#define  CTRLC ('c' & 0x1f)
#define  CTRLU ('u' & 0x1f)
#define  CTRLH ('h' & 0x1f)
#define  DEL   0xff

static void BackSpace(void)
{
  putchar(CTRLH) ; putchar(' ') ; putchar(CTRLH) ;
}

char *gets(char *pbuf)
{
  int i = 0 ;
  int c ;
  char *s ;
  s = pbuf ;
  while(1) {
    c = getchar() ;
    switch(c) {
    case '\r':  continue ;
    case CTRLC: pbuf = NULL ; goto Done ;
    case '\n':  *s = '\0' ;   goto Done ;
    case DEL:
    case CTRLH: BackSpace() ; --s ; --i ; continue ;
    case CTRLU:
      for(s -= i ; i > 0 ; --i) BackSpace() ;
      continue ;
    default:
      putchar(c) ; // echo back
      *s++ = c ; ++i ;
    }
  }
 Done:
  putchar('\r') ; putchar('\n') ;
  return pbuf ;
}

//
char *puts(char *s)
{
  int c ;
  while((c = *s++) != '\0') putchar(c) ;
  putchar('\n') ;
  return s;
}


