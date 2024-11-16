.global _start
_start:
    la x1, word
    lw x2, 0(x1) # 16909060 (0x01020304)
    lh x2, 0(x1) # 772 (0x0304)
    lh x2, 2(x1) # 258 (0x0102)
    lb x2, 0(x1) # 4 (0x04)
    lb x2, 1(x1) # 3 (0x03)
    lb x2, 2(x1) # 2 (0x02)
    lb x2, 3(x1) # 1 (0x01)

    la x1, negative
    lb x2, 0(x1)  # 4294967293 (-3)
    lbu x2, 0(x1) # 253 (0b11111101)

    la x1, word
    lw x2, 1(x0)  # misaligned load exception

.section .data
.balign 4
word:
    .word 0x01020304 # LE: 0x04030201

negative:
    .byte -3
