ENTRY(start)

MEMORY {
    bram (rwx) : ORIGIN = 0x10000000, LENGTH = 8K
}

SECTIONS {
    .text : {
        start.o(.text);
        *(.text);
        *(.text.*);
    } > bram

    .data : ALIGN(4) {
        *(.data);
        *(.data.*);

	. = ALIGN(4);
    } > bram

    .rodata : {
        *(.rodata);
        *(.rodata.*);
    } > bram

    .bss : ALIGN(4) {
        *(.bss);
        *(.bss.*);

        . = ALIGN(4);
    } > bram

    bss_start = ADDR(.bss);
    bss_end = bss_start + SIZEOF(.bss);

    stack_top = ORIGIN(bram) + LENGTH(bram);
}
