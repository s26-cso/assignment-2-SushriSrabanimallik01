.section .data
filename: .asciz "input.txt"
yes_msg:  .asciz "Yes\n"
no_msg:   .asciz "No\n"

.section .bss
left_buf:  .space 1
right_buf: .space 1

.section .text
.globl main

main:
    # Open input.txt (read-only)
    li   a7, 56
    li   a0, -100
    la   a1, filename
    li   a2, 0
    ecall
    bltz a0, print_no
    mv   s0, a0

    # Get file length
    li   a7, 62
    mv   a0, s0
    li   a1, 0
    li   a2, 2
    ecall
    mv   s1, a0

strip_loop:
    beqz s1, print_yes

    li   a7, 62
    mv   a0, s0
    addi a1, s1, -1
    li   a2, 0
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, right_buf
    li   a2, 1
    ecall

    la   t0, right_buf
    lb   t1, 0(t0)
    li   t2, 10
    beq  t1, t2, do_strip
    li   t2, 13
    beq  t1, t2, do_strip
    j    done_strip

do_strip:
    addi s1, s1, -1
    j    strip_loop

done_strip:
    li   t0, 2
    blt  s1, t0, print_yes

    li   s2, 0
    addi s3, s1, -1

check_loop:
    bge  s2, s3, print_yes

    # left char
    li   a7, 62
    mv   a0, s0
    mv   a1, s2
    li   a2, 0
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, left_buf
    li   a2, 1
    ecall

    # right char
    li   a7, 62
    mv   a0, s0
    mv   a1, s3
    li   a2, 0
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, right_buf
    li   a2, 1
    ecall

    la   t0, left_buf
    lb   t1, 0(t0)
    la   t2, right_buf
    lb   t3, 0(t2)
    bne  t1, t3, print_no

    addi s2, s2, 1
    addi s3, s3, -1
    j    check_loop

print_yes:
    li   a7, 64
    li   a0, 1
    la   a1, yes_msg
    li   a2, 4
    ecall
    j    exit

print_no:
    li   a7, 64
    li   a0, 1
    la   a1, no_msg
    li   a2, 3
    ecall

exit:
    ret