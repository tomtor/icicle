// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include <stdarg.h>
#include <stdint.h>

void setStats(int enable)
{

}

#define UART_BASE  ((volatile uint32_t*)(0x70000))
#define MTIME_BASE ((volatile uint32_t*)(0x70010))

static void printf_c(int c)
{
	putchar(c);
}

static void printf_s(char *p)
{
	while (*p)
		putchar(*(p++));
}

static void printf_d(int val)
{
	char buffer[32];
	char *p = buffer;
	if (val < 0) {
		printf_c('-');
		val = -val;
	}
	while (val || p == buffer) {
		*(p++) = '0' + val % 10;
		val = val / 10;
	}
	while (p != buffer)
		printf_c(*(--p));
}

int printf(const char *format, ...)
{
	int i;
	va_list ap;

	va_start(ap, format);

	for (i = 0; format[i]; i++)
		if (format[i] == '%') {
			while (format[++i]) {
				if (format[i] == 'c') {
					printf_c(va_arg(ap,int));
					break;
				}
				if (format[i] == 's') {
					printf_s(va_arg(ap,char*));
					break;
				}
				if (format[i] == 'd') {
					printf_d(va_arg(ap,int));
					break;
				}
			}
		} else
			printf_c(format[i]);

	va_end(ap);
}


int puts(char *s){
  while (*s) {
    putchar(*s);
    s++;
  }
  putchar('\n');
  return 0;
}

#define UART_BAUD   *((volatile uint32_t *) 0x00020000)
#define UART_STATUS *((volatile uint32_t *) 0x00020004)
#define UART_DATA   *((volatile  int32_t *) 0x00020008)

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

#define BAUD_RATE 115200

void putchar(char c){
    static int init;
    if (!init) {
      UART_BAUD = FREQ / BAUD_RATE;
      init = 1;
    }
    while (!(UART_STATUS & UART_STATUS_TX_READY));
    UART_DATA = c;
}

static inline unsigned int rdcycle(void) {
    unsigned int cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

//Time in microsecond
long time(){
  // printf("time\n");
  // return MTIME_BASE[0] & 0xFFFFFF;
  // return rdcycle() * 1000000 / CORE_HZ;
  return rdcycle();
}

//See https://github.com/zephyrproject-rtos/meta-zephyr-sdk/issues/110
//It does not interfere with the benchmark code.
unsigned long long __divdi3 (unsigned long long numerator,unsigned  long long divisor)
{
    unsigned long long result = 0;
    unsigned long long count = 0;
    unsigned long long remainder = numerator;

    while((divisor & 0x8000000000000000ll) == 0) {
        divisor = divisor << 1;
        count++;
    }
    while(remainder != 0) {
        if(remainder >= divisor) {
            remainder = remainder - divisor;
            result = result | (1 << count);
        }
        if(count == 0) {
            break;
        }
        divisor = divisor >> 1;
        count--;
    }
    return result;
}
