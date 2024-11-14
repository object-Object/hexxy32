ENTRY(_start)

MEMORY {
    ram (rwx) : ORIGIN = 0, LENGTH = 19*19*19 * 512*4
}

SECTIONS {
    .text : {
        KEEP(*(.text.boot));
        *(.text .text.*);
    } > ram

    .rodata : {
        *(.rodata .rodata.*);
    } > ram

    .data : {
        *(.data .data.*);
    } > ram

    .bss : {
        *(.bss .bss.*);
    } > ram
}
