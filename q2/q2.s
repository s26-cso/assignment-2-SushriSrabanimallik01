.section .data
fmt_int:   .string "%ld"     # format to print integer
fmt_space: .string " "       # space between outputs
fmt_nl:    .string "\n"      # newline

.section .text
.globl main

main:
    #  Setup stack frame 
    addi    sp, sp, -128
    sd      ra, 112(sp)
    sd      s0, 96(sp)   # arr
    sd      s1, 80(sp)   # n
    sd      s2, 64(sp)   # result[]
    sd      s3, 48(sp)   # stack[]
    sd      s4, 32(sp)   # stack top index
    sd      s5, 16(sp)   # loop variable i
    sd      s6,  0(sp)   # argv

    addi    s1, a0, -1       # n = argc - 1
    mv      s6, a1           # store argv

    #  Edge case: no input 
    bnez    s1, allocate_memory
    la      a0, fmt_nl
    call    printf
    j       program_end

allocate_memory:
    # allocate arr[n]
    slli    a0, s1, 3        # n * 8 bytes
    call    malloc
    mv      s0, a0           # arr pointer

    # allocate result[n]
    slli    a0, s1, 3
    call    malloc
    mv      s2, a0           # result pointer

    # allocate stack[n]
    slli    a0, s1, 3
    call    malloc
    mv      s3, a0           # stack pointer
    li      s5, 0            # i = 0

read_input_loop:
    bge     s5, s1, input_done

    addi    t0, s5, 1        # argv index = i+1 (skip program name)
    slli    t1, t0, 3
    add     t1, s6, t1
    ld      a0, 0(t1)        # load argv[i+1]

    call    atoi             # convert string → int

    slli    t0, s5, 3
    add     t0, s0, t0
    sd      a0, 0(t0)        # arr[i] = value

    addi    s5, s5, 1
    j       read_input_loop

input_done:
    li      s5, 0
    li      t6, -1

initialize_result:
    bge     s5, s1, init_done

    slli    t0, s5, 3
    add     t0, s2, t0
    sd      t6, 0(t0)        # result[i] = -1

    addi    s5, s5, 1
    j       initialize_result

init_done:
    li      s4, -1           # stack is empty → top = -1
    addi    s5, s1, -1       # i = n - 1 (start from right)

process_elements:
    bltz    s5, nge_finished

    # current element = arr[i]
    slli    t0, s5, 3
    add     t0, s0, t0
    ld      t1, 0(t0)

#  Pop smaller elements from stack 
remove_smaller_elements:
    bltz    s4, done_popping   # if stack empty → stop

    slli    t2, s4, 3
    add     t2, s3, t2
    ld      t3, 0(t2)          # index at top of stack

    slli    t4, t3, 3
    add     t4, s0, t4
    ld      t5, 0(t4)          # value at stack.top()

    bgt     t5, t1, done_popping   # stop if greater element found

    addi    s4, s4, -1         # pop stack
    j       remove_smaller_elements

done_popping:

#  Assign result if stack not empty 
    bltz    s4, no_next_greater

    slli    t2, s4, 3
    add     t2, s3, t2
    ld      t3, 0(t2)          # stack.top() index

    slli    t4, s5, 3
    add     t4, s2, t4
    sd      t3, 0(t4)          # result[i] = index

no_next_greater:

#  Push current index onto stack 
    addi    s4, s4, 1
    slli    t2, s4, 3
    add     t2, s3, t2
    sd      s5, 0(t2)

    addi    s5, s5, -1         # i--
    j       process_elements

nge_finished:
    li      s5, 0

print_results:
    bge     s5, s1, printing_done

    # print space before elements except first
    beqz    s5, skip_space
    la      a0, fmt_space
    call    printf

skip_space:
    slli    t0, s5, 3
    add     t0, s2, t0
    ld      a1, 0(t0)

    la      a0, fmt_int
    call    printf

    addi    s5, s5, 1
    j       print_results

printing_done:
    la      a0, fmt_nl
    call    printf

program_end:
    li      a0, 0
    ld      ra, 112(sp)
    ld      s0, 96(sp)
    ld      s1, 80(sp)
    ld      s2, 64(sp)
    ld      s3, 48(sp)
    ld      s4, 32(sp)
    ld      s5, 16(sp)
    ld      s6,  0(sp)
    addi    sp, sp, 128
    ret