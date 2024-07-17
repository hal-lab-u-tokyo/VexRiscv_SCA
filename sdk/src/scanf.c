/*
*    Copyright (C) 2023 The University of Tokyo
*    
*    File:          /sdk/src/scanf.c
*    Project:       expr-riscv
*    Author:        Takuya Kojima in The University of Tokyo (tkojima@hal.ipc.i.u-tokyo.ac.jp)
*    Created Date:  07-12-2023 09:07:57
*    Last Modified: 07-12-2023 09:07:58
*/



#include <minilib.h>
#include <stdarg.h>

#define STR_MAX_LEN 1024

typedef enum {
	UNKNOWN = 0,
	SINT,
	UINT,
	STRING,
	CHAR,
	PERCENT,
} ConvKind;

typedef enum {
	NoMod = 0,
	ToHarf,
	ToLong
} ModKind;


typedef struct {
	ConvKind conv;
	ModKind mod;
	int radix;
} st_placeholder_t;


const char* decode_format(const char *format, 
				st_placeholder_t *P)
{
	// assumed the head of % is already eliminated
	ModKind mod = NoMod;
	ConvKind conv = UNKNOWN;
	int radix = 10;

	st_placeholder_t ret;

	// decode modifier
	if (*format) {
		if (*format == 'h') {
			format++;
			if (*format == 'h') {
				// extra h
				format++;
			}
			mod = ToHarf;
		} else if (*format == 'l') {
			format++;
			if (*format == 'l') {
				// extra l
				format++;
			}
			mod = ToLong;
		}
	}

	// decode conversion specifier
	switch (*format++) {
		case 'd':
			conv = SINT; break;
		case 'u':
			conv = UINT; break;
		case 'b':
			conv = UINT; radix = 2; break;
		case 'o':
			conv = UINT; radix = 8; break;
		case 'x':
		case 'X':
			conv = UINT; radix = 16; break;
		case 'S':
		case 's':
			conv = STRING; break;
		case 'C':
		case 'c':
			conv = CHAR; break;
		case '%':
			conv = PERCENT; break;
		case 'i': // not supported
		default:
			break;
	}

	P->conv = conv;
	P->mod = mod;
	P->radix = radix;

	return format;

}

static inline int is_start_placeholder(int c)
{
	return c == '%';
}

#ifndef isspace
int isspace(int c)
{
	return (c == '\t' || c == '\n' ||
			c == '\v' || c == '\f' || 
			c == '\r' || c == ' ' ? 1 : 0);
}
#endif

long tinyStrtol(char *pbuf, int radix)
{
	long ret = 0;
	int n;
	int digit = 1;
	int negative = 0;

	char *last = pbuf;

	if (*pbuf == '-') {
		negative = 1;
		last = ++pbuf;
	}

	// go to end
	while (*++pbuf);
	pbuf--;

	while (pbuf >= last) {
		if ((*pbuf >= '0') && (*pbuf <= '9')) {
			n = (int)(*pbuf - '0');
		} else if (radix > 10) {
			if ((*pbuf >= 'a') && (*pbuf <= 'f')) {
				n = (int)(*pbuf - 'a') + 10;
			} else if ((*pbuf >= 'A') && (*pbuf <= 'F')) {
				n = (int)(*pbuf - 'A') + 10;
			} else {
				return 0;
			}
		} else {
			return 0;
		}
		ret += digit * n;
		digit *= radix;
		pbuf--;
	}

	if (negative) {
		ret *= -1;
	}

	return ret;
}

void load_data_str(char* buf, int max_len)
{
	int char_tmp;
	int len = 0;

	char_tmp = getchar();

	// skip loaded byte untile it is not space char
	while (isspace(char_tmp)) {
		char_tmp = getchar();
	}

	while (len < max_len && !isspace(char_tmp)) {
		buf[len++] = char_tmp;
		char_tmp = getchar();
	}
	buf[len] = '\0';

}

int vscanf(const char *format, va_list args)
{
	int char_tmp;
	int num_success = 0;
	st_placeholder_t pstyle;
	char data_str[STR_MAX_LEN];
	long int_tmp;

	while (*format) { // loop until the end of format string

		// skip space of format
		while (isspace((int)*(format))) {
			format++;
		}

		// check if ordinary string in format and 
		// loaded string are the same
		// until reaching either a placeholder, space, of the end of the string
		while (*format && !is_start_placeholder(*format)
				&& !isspace(*format))  {
			char_tmp = getchar();
			if (*format++ != char_tmp) {
				return num_success;
			}
		}

		if (!is_start_placeholder(*format)) {
			continue;
		}

		// get decoded result
		format = decode_format(++format, &pstyle);

		switch (pstyle.conv) {
			case SINT:
				load_data_str(data_str, STR_MAX_LEN - 1);
				int_tmp = tinyStrtol(data_str, pstyle.radix);
				switch (pstyle.mod) {
					case NoMod:
						 *va_arg(args, int*) = (int)int_tmp;
						 break;
					case ToHarf:
						 *va_arg(args, short*) = (short)int_tmp;
						 break;
					case ToLong:
						 *va_arg(args, long*) = (long)int_tmp;
						 break;
					default:
						return num_success;
				}
				break;
			case UINT:
				load_data_str(data_str, STR_MAX_LEN - 1);
				int_tmp = tinyStrtol(data_str, pstyle.radix);
				switch (pstyle.mod) {
					case NoMod:
						 *va_arg(args, unsigned int*) = (unsigned int)int_tmp;
						 break;
					case ToHarf:
						 *va_arg(args, unsigned short*) = (unsigned short)int_tmp;
						 break;
					case ToLong:
						 *va_arg(args, unsigned long*) = (unsigned long)int_tmp;
						 break;
					default:
						return num_success;
				}
				break;
			case STRING:
				load_data_str(va_arg(args, char*), 
								STR_MAX_LEN - 1);
				break;
			case CHAR:
				load_data_str(data_str, 1);
				*va_arg(args, char*) = data_str[0];
				break;
			case PERCENT:
				if ('%' != getchar()) return num_success;
				continue;
			default:
				return num_success;
		}
		num_success++;

	}
	return num_success;
}

int scanf(const char *format, ...)
{
	va_list args;
	int n;

	va_start(args, format);
	n = vscanf(format, args);
	va_end(args);

	return n;
}

