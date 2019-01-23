ENTRY(start)

MEMORY {
    spram (rwx) : ORIGIN = 0x10000000, LENGTH = 128K
    flash (rx) : ORIGIN = 0x01100000, LENGTH = 3M
}

SECTIONS {
    .text : {
        start.o(.text);
        *(.text);
        *(.text.*);
    } > flash

    .data : ALIGN(4) {
        *(.data);
        *(.data.*);

        . = ALIGN(4);
    } > spram AT> flash

    .rodata : {
        *(.rodata);
        *(.rodata.*);
    } > flash

    .bss : ALIGN(4) {
        *(.bss);
        *(.bss.*);

        . = ALIGN(4);
    } > spram

    bss_start = ADDR(.bss);
    bss_end = bss_start + SIZEOF(.bss);

    data_flash_start = LOADADDR(.data);
    data_start = ADDR(.data);
    data_end = data_start + SIZEOF(.data);

    stack_top = ORIGIN(spram) + LENGTH(spram);
}
