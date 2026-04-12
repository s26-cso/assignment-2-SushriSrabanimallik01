.section .data
filename: .asciz "input.txt"   # file we will check
yes_msg:  .asciz "Yes\n"       # printed if palindrome
no_msg:   .asciz "No\n"        # printed if not palindrome

.section .bss
front_char:  .space 1          # stores character from start
back_char:   .space 1          # stores character from end

.section .text
.global _start

_start:
    # Open file in read-only mode 
    # openat(AT_FDCWD, filename, O_RDONLY)
    li a7, 56
    li a0, -100
    la a1, filename
    li a2, 0
    ecall
    mv s0, a0                  # s0 = file descriptor

    bltz s0, not_palindrome    # if open fails → print No

    # Get file size (n) 
    # lseek(fd, 0, SEEK_END)
    li a7, 62
    mv a0, s0
    li a1, 0
    li a2, 2                   # SEEK_END
    ecall
    mv s1, a0                  # s1 = file length

    # If file has 0 or 1 character → palindrome
    li t0, 2
    blt s1, t0, palindrome

    # Initialize two pointers
    li t1, 0                   # left index = 0
    addi t2, s1, -1            # right index = n - 1

check_loop:
    # Stop when pointers meet or cross
    bge t1, t2, palindrome

    # Read character from left side 
    # Move file pointer to position = left index
    li a7, 62
    mv a0, s0
    mv a1, t1
    li a2, 0                   # SEEK_SET
    ecall

    # Read 1 byte into front_char
    li a7, 63
    mv a0, s0
    la a1, front_char
    li a2, 1
    ecall

    # Read character from right side 
    # Move file pointer to position = right index
    li a7, 62
    mv a0, s0
    mv a1, t2
    li a2, 0
    ecall

    # Read 1 byte into back_char
    li a7, 63
    mv a0, s0
    la a1, back_char
    li a2, 1
    ecall

    # Compare both characters 
    la t3, front_char
    lb t4, 0(t3)

    la t5, back_char
    lb t6, 0(t5)

    bne t4, t6, not_palindrome   # mismatch → not palindrome

    # Move inward
    addi t1, t1, 1               # left++
    addi t2, t2, -1              # right--
    j check_loop

#If palindrome 
palindrome:
    li a7, 64                   # write syscall
    li a0, 1                    # stdout
    la a1, yes_msg
    li a2, 4
    ecall
    j exit

#If not palindrome
not_palindrome:
    li a7, 64
    li a0, 1
    la a1, no_msg
    li a2, 3
    ecall

# Exit program 
exit:
    li a7, 93
    li a0, 0
    ecall