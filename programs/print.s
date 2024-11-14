.global _start
_start:
    la a0, msg

.section .data
.balign 4

msg:
    .ascii "abcd\0"
