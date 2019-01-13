ENTRY(start)

MEMORY {
    spram (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS {
    .text : {
        start.o(.text);
        *(.text);
        *(.text.*);
    } > spram

    .data : {
        *(.data);
        *(.data.*);
    } > spram

    .rodata : {
        *(.rodata);
        *(.rodata.*);
    } > spram

    .bss : ALIGN(4) {
        *(.bss);
        *(.bss.*);

        . = ALIGN(4);
    } > spram

    bss_start = ADDR(.bss);
    bss_end = bss_start + SIZEOF(.bss);

    stack_top = ORIGIN(spram) + LENGTH(spram);
}
