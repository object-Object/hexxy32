heap_size = 19;
focus_length = 512 * 4;
layer_length = heap_size * heap_size * focus_length;

ENTRY(_start)

MEMORY {
    ram (rwx) : ORIGIN = 0, LENGTH = heap_size * layer_length
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
