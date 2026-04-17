.section .data
one_msg:  .asciz "1\n"          # output if palindrome
zero_msg: .asciz "0\n"          # output if not palindrome

.section .bss
buf: .space 10004               # buffer: max 10^4 chars + newline + null

.section .text
.global _start

_start:
    # Read entire input from stdin into buf 
    # read(0, buf, 10004)
    li   a7, 63
    li   a0, 0                  # fd = stdin
    la   a1, buf
    li   a2, 10004
    ecall
    # a0 = number of bytes actually read (n_read)
    blez a0, palindrome         # empty input → palindrome

    #  Strip trailing newline 
    mv   s1, a0                 # s1 = current length
strip_nl:
    beqz s1, palindrome         # length became 0
    la   t0, buf
    add  t1, t0, s1
    addi t1, t1, -1             # t1 → last byte
    lb   t2, 0(t1)
    li   t3, 10                 # '\n'
    beq  t2, t3, do_strip
    li   t3, 13                 # '\r'
    beq  t2, t3, do_strip
    j    done_strip
do_strip:
    addi s1, s1, -1
    j    strip_nl
done_strip:

    # Edge case: 0 or 1 character → always a palindrome 
    li   t0, 2
    blt  s1, t0, palindrome

    #  Two-pointer palindrome check 
    li   t1, 0                  # left  index
    addi t2, s1, -1             # right index
    la   s0, buf                # base address of buffer

check_loop:
    bge  t1, t2, palindrome     # pointers crossed → palindrome

    add  t3, s0, t1             # address of buf[left]
    lb   t4, 0(t3)              # left  character

    add  t5, s0, t2             # address of buf[right]
    lb   t6, 0(t5)              # right character

    bne  t4, t6, not_palindrome # mismatch → not palindrome

    addi t1, t1, 1              # left++
    addi t2, t2, -1             # right--
    j    check_loop

#  Output "1\n" 
palindrome:
    li   a7, 64                 # write syscall
    li   a0, 1                  # stdout
    la   a1, one_msg
    li   a2, 2                  # length of "1\n"
    ecall
    j    exit

# Output "0\n" 
not_palindrome:
    li   a7, 64
    li   a0, 1
    la   a1, zero_msg
    li   a2, 2                  # length of "0\n"
    ecall

# Exit 
exit:
    li   a7, 93
    li   a0, 0
    ecall