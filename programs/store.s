.global _start
_start:
    li x1, 2048
    li x2, 0x01000000
    sw x2, 0(x1)
    sw zero, 0(x1)
