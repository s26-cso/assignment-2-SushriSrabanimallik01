# Assignment 2 - Question 5: Palindrome check from input.txt
# O(n) time, O(1) space — two file pointers (lseek), no buffer
# Output: "Yes" if palindrome, "No" otherwise

.section .data
filename: .asciz "input.txt"
yes_msg:  .asciz "Yes\n"
no_msg:   .asciz "No\n"

.section .bss
left_buf:  .space 1            # 1-byte buffer for left  character
right_buf: .space 1            # 1-byte buffer for right character

.section .text
.global _start

_start:
    # ── Open input.txt (read-only) ─────────────────────────────────────
    # openat(AT_FDCWD=-100, filename, O_RDONLY=0)
    li   a7, 56
    li   a0, -100
    la   a1, filename
    li   a2, 0
    ecall
    bltz a0, print_no           # if fd < 0, open failed → No
    mv   s0, a0                 # s0 = file descriptor (saved reg, safe across ecalls)

    # ── Get file length via lseek(fd, 0, SEEK_END=2) ──────────────────
    li   a7, 62
    mv   a0, s0
    li   a1, 0
    li   a2, 2
    ecall
    mv   s1, a0                 # s1 = raw file length (saved reg)

    # ── Strip trailing newline(s) from the length ──────────────────────
    # We check the last byte; if it's '\n' (10) or '\r' (13), shrink s1
strip_loop:
    beqz s1, print_yes          # empty string → palindrome

    # Seek to position (s1 - 1) and read 1 byte
    li   a7, 62
    mv   a0, s0
    addi a1, s1, -1             # position = length - 1
    li   a2, 0                  # SEEK_SET
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, right_buf
    li   a2, 1
    ecall

    la   t0, right_buf
    lb   t1, 0(t0)
    li   t2, 10                 # '\n'
    beq  t1, t2, do_strip
    li   t2, 13                 # '\r'
    beq  t1, t2, do_strip
    j    done_strip

do_strip:
    addi s1, s1, -1             # shrink logical length
    j    strip_loop

done_strip:
    # ── Edge cases: 0 or 1 character → always palindrome ──────────────
    li   t0, 2
    blt  s1, t0, print_yes

    # ── Two-pointer palindrome check ──────────────────────────────────
    # s0 = fd, s1 = length (after strip)
    # s2 = left index, s3 = right index  (saved regs — survive ecalls)
    li   s2, 0                  # left  = 0
    addi s3, s1, -1             # right = length - 1

check_loop:
    bge  s2, s3, print_yes      # pointers met or crossed → palindrome

    # Read character at left index
    li   a7, 62
    mv   a0, s0
    mv   a1, s2                 # seek to left
    li   a2, 0                  # SEEK_SET
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, left_buf
    li   a2, 1
    ecall

    # Read character at right index
    li   a7, 62
    mv   a0, s0
    mv   a1, s3                 # seek to right
    li   a2, 0
    ecall

    li   a7, 63
    mv   a0, s0
    la   a1, right_buf
    li   a2, 1
    ecall

    # Compare the two characters
    la   t0, left_buf
    lb   t1, 0(t0)
    la   t2, right_buf
    lb   t3, 0(t2)
    bne  t1, t3, print_no       # mismatch → not palindrome

    addi s2, s2, 1              # left++
    addi s3, s3, -1             # right--
    j    check_loop

# ── Print "Yes\n" and exit ─────────────────────────────────────────────
print_yes:
    li   a7, 64
    li   a0, 1
    la   a1, yes_msg
    li   a2, 4
    ecall
    j    exit

# ── Print "No\n" and exit ──────────────────────────────────────────────
print_no:
    li   a7, 64
    li   a0, 1
    la   a1, no_msg
    li   a2, 3
    ecall

exit:
    li   a7, 93
    li   a0, 0
    ecall