.global _start
_start:
    la a0, msg     # address
    la a1, msg_len # length
    li a7, 1       # syscall (print)
    ecall

    li a0, 0 # exit code
    li a7, 0 # syscall (halt)
    ecall

.section .data
.balign 2048
msg:
    .ascii "hello world"
    .set msg_len, . - msg
