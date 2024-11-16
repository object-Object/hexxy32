.global _start
_start:
    la x1, word

    li x2, 0x01020304
    sw x2, 0(x1) # 0x04030201
    
    li x2, 0xab
    sb x2, 0(x1) # 0xab030201
    sb x2, 1(x1) # 0xabab0201
    sb x2, 2(x1) # 0xababab01
    sb x2, 3(x1) # 0xabababab

    li x2, 0xcdef
    sh x2, 0(x1) # 0xefcdabab
    sh x2, 2(x1) # 0xefcdefcd

    li x2, 0x12345678
    sw x2, 0(x1) # 0x78563412

    sw x2, 1(x1) # misaligned store exception

.section .data
.org 0x760
.balign 4
word:
    .word 0x01020304
