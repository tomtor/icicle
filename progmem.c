#include <stdint.h>
#include <stdio.h>

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

int main() {
    UART_BAUD = FREQ / BAUD_RATE;
    LEDS = 0xAA;

    for (;;) {
	char s[80];
        uint32_t cycle = rdcycle();
	sprintf(s, "Cycle: %lu %ld (/19)\r\n", cycle, cycle/19);
        uart_puts(s);

	int retval = exmain();
	sprintf("zlib test: %d\r\r", retval);	

        uint32_t start = rdcycle();
        while ((rdcycle() - start) <= FREQ);
    }
}
