#include <stdint.h>
#include <stdlib.h>

#define LEDS        *((volatile uint32_t *) 0x00010000)
#define UART_BAUD   *((volatile uint32_t *) 0x00020000)
#define UART_STATUS *((volatile uint32_t *) 0x00020004)
#define UART_DATA   *((volatile  int32_t *) 0x00020008)
#define MTIME       *((volatile uint64_t *) 0x00030000)
#define MTIMECMP    *((volatile uint64_t *) 0x00030008)

#define UART_STATUS_TX_READY 0x1
#define UART_STATUS_RX_READY 0x2

#define BAUD_RATE 9600

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

        while ((rdcycle() - start) <= FREQ);

        uint32_t ncycle = rdcycle() - start;
        uint32_t ninstret = rdinstret() - starti;

	itoa(ncycle, s, 10);
	uart_puts(s);
	uart_puts(" cycles for ");
	itoa(ninstret, s, 10);
	uart_puts(s);
	uart_puts(" instructions\r\n");

        LEDS = ~LEDS;

        starti = rdinstret();
        while ((rdcycle() - start) <= FREQ);
    }
}
