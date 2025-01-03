.global _start
_start:
    la a0, image # address
    li a7, 2     # syscall (refresh display)
    ecall

    li a0, 0 # exit code
    li a7, 0 # syscall (halt)
    ecall

.section .data
.balign 256
image:
    .skip 256, 0
