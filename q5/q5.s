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
    # 1. Open input.txt (read-only)
    # Using openat (syscall 56): a0=AT_FDCWD (-100), a1=path, a2=flags (0)
    li   a7, 56
    li   a0, -100
    la   a1, filename
    li   a2, 0
    ecall
    bltz a0, print_no      # If fd < 0, error opening file
    mv   s0, a0            # s0 = file descriptor

    # 2. Get file length using lseek (syscall 62)
    # a0=fd, a1=offset (0), a2=whence (SEEK_END = 2)
    li   a7, 62
    mv   a0, s0
    li   a1, 0
    li   a2, 2
    ecall
    mv   s1, a0            # s1 = total file length

strip_loop:
    # 3. Strip trailing newlines (\n or \r)
    beqz s1, print_yes     # Empty file is a palindrome

    li   a7, 62
    mv   a0, s0
    addi a1, s1, -1        # Seek to last char
    li   a2, 0             # SEEK_SET
    ecall

    li   a7, 63            # read (syscall 63)
    mv   a0, s0
    la   a1, right_buf
    li   a2, 1
    ecall

    lb   t1, 0(a1)
    li   t2, 10            # '\n'
    beq  t1, t2, do_strip
    li   t2, 13            # '\r'
    beq  t1, t2, do_strip
    j    done_strip

do_strip:
    addi s1, s1, -1
    j    strip_loop

done_strip:
    # 4. Palindrome Check Logic
    li   s2, 0             # s2 = left index (0)
    addi s3, s1, -1        # s3 = right index (length - 1)

check_loop:
    bge  s2, s3, print_yes # If indices cross, it's a palindrome

    # Read left char
    li   a7, 62            # lseek
    mv   a0, s0
    mv   a1, s2
    li   a2, 0
    ecall
    li   a7, 63            # read
    mv   a0, s0
    la   a1, left_buf
    li   a2, 1
    ecall
    lb   t1, 0(a1)

    # Read right char
    li   a7, 62            # lseek
    mv   a0, s0
    mv   a1, s3
    li   a2, 0
    ecall
    li   a7, 63            # read
    mv   a0, s0
    la   a1, right_buf
    li   a2, 1
    ecall
    lb   t3, 0(a1)

    # Compare
    bne  t1, t3, print_no

    addi s2, s2, 1
    addi s3, s3, -1
    j    check_loop

print_yes:
    li   a7, 64            # write (syscall 64)
    li   a0, 1             # stdout
    la   a1, yes_msg
    li   a2, 4             # Length of "Yes\n"
    ecall
    j    terminate

print_no:
    li   a7, 64            # write
    li   a0, 1             # stdout
    la   a1, no_msg
    li   a2, 3             # Length of "No\n"
    ecall

terminate:

    li   a7, 93            # exit (syscall 93)
    li   a0, 0             # exit code 0
    ecall