#include <stdint.h>
#include <stdlib.h>
#include <math.h>

#define LEDS        *((volatile uint32_t *) 0x00010000)
#define UART_BAUD   *((volatile uint32_t *) 0x00020000)
#define UART_STATUS *((volatile uint32_t *) 0x00020004)
#define UART_DATA   *((volatile  int32_t *) 0x00020008)
#define MTIME       *((volatile uint64_t *) 0x00030000)
#define MTIMECMP    *((volatile uint64_t *) 0x00030008)

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

//#define BAUD_RATE 9600
#define BAUD_RATE 115200

static void uart_putc(char c) {
    while (!(UART_STATUS & UART_STATUS_TX_READY));
    UART_DATA = c;
}

static void uart_puts(const char *str) {
    char c;
    while ((c = *str++)) {
        uart_putc(c);
    }
}

static inline uint32_t rdcycle(void) {
    uint32_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

static inline uint32_t rdinstret(void) {
    uint32_t instret;
    asm volatile ("rdinstret %0" : "=r"(instret));
    return instret;
}

int main() {
    UART_BAUD = FREQ / BAUD_RATE;
    LEDS = 0xAA;

    uart_puts("Hello, world!\r\n");

    int count = 0;
    for (;;) {
	char s[20];

        uart_puts("Stack: ");
	itoa((int)s, s, 16);
        uart_puts(s);
        uart_puts(" Main: ");
	itoa((int)main, s, 16);
        uart_puts(s);
        uart_puts("\r\n");

        uint32_t start = rdcycle();
        uint32_t starti = rdinstret();

        double f = 0;
        double g = 0;
        while ((rdcycle() - start) <= FREQ / 4) {
		f += 0.001;
		g += sqrt(3);
	}

        uint32_t ncycle = rdcycle() - start;
        uint32_t ninstret = rdinstret() - starti;

	itoa(ncycle, s, 10);
	uart_puts(s);
	uart_puts(" cycles for ");
	itoa(ninstret, s, 10);
	uart_puts(s);
	uart_puts(" instructions\r\n");

	itoa((int)f, s, 10);
	uart_puts(s);
	uart_puts("\r\n");

	itoa((int)g + count, s, 10);
	uart_puts(s);
	uart_puts("\r\n");

	itoa((int)(1000000 * sqrt(2)), s, 10);
	uart_puts(s);
	uart_puts("\r\n");

#if 0
	char *p = malloc(10);
	uart_puts("malloc\r\n");
	free(p);
	uart_puts("free\r\n");
	sprintf(s, "Hi sprintf\r\n");
	uart_puts(s);

	//sprintf(s, "%lf\r\n", 1.0 / sum);
	//gcvt(1.0 / sum, 15, s);
	//uart_puts(s);
	//uart_puts("\r\n");
#endif

        LEDS = ~ ++count;

        starti = rdinstret();
        while ((rdcycle() - start) <= FREQ / 4);
    }
}
