.global _start
_start:
    lw x1, 0(x0)
    lw x2, 1(x0)  # should raise a misaligned load exception
