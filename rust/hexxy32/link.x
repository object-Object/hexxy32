ENTRY(_start)

MEMORY {
    rom (rx) : ORIGIN = 0,                LENGTH = 19*19*10 * 512*4
    ram (rw) : ORIGIN = 19*19*10 * 512*4, LENGTH = 19*19*9 * 512*4
}

SECTIONS {
    .text : {
        KEEP(*(.text.start));
        *(.text.reset);
        *(.text .text.*);
    } > rom

    .rodata : {
        *(.rodata .rodata.*);
    } > rom

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
