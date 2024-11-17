ENTRY(_start)

MEMORY {
    ram (rwx) : ORIGIN = 0, LENGTH = 19*19*19 * 512*4
}

SECTIONS {
    .text : {
        KEEP(*(.text.start));
        *(.text.reset);
        *(.text .text.*);
    } > ram

    .rodata : {
        *(.rodata .rodata.*);
    } > ram

    .data : {
        _sdata = .;
        *(.data .data.*);
        _edata = .;
    } > ram

    .bss : {
        _sbss = .;
        *(.bss .bss.*);
        _ebss = .;
    } > ram

    _sidata = LOADADDR(.data);
    _stack_start = ORIGIN(ram) + LENGTH(ram);
}
