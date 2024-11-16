.global _start
_start:
    j increment

.org 1024
increment:
    addi x1, x1, 1
    j _start
