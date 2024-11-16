.global _start
_start:
    li x1, 2
    li x2, 1
    blt x1, x2, true_1

    li x3, 1
    j next

true_1:
    li x3, 2
    j next

next:
    li x4, -1
    li x5, 1
    blt x4, x5, true_2

    li x6, 1
    j end

true_2:
    li x6, 2
    j end

end:
    j 0
