.section .text
    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost

make_node:
    addi    sp, sp, -32        # create stack frame
    sd      ra, 16(sp)         # save return address
    sd      s0, 0(sp)          # save s0

    mv      s0, a0             # store input value (val) in s0

    li      a0, 24             # size of struct Node = 24 bytes
    call    malloc             # allocate memory

    beqz a0, make_end          # if malloc failed, return NULL

    sw      s0, 0(a0)          # node->val = val
    sd      zero, 8(a0)        # node->left = NULL
    sd      zero, 16(a0)       # node->right = NULL

make_end:
    ld      ra, 16(sp)         # restore return address
    ld      s0, 0(sp)          # restore s0
    addi    sp, sp, 32         # restore stack
    ret                        # return node pointer in a0

insert:
    addi    sp, sp, -64        # create stack frame
    sd      ra, 48(sp)         # save return address
    sd      s0, 32(sp)         # save root
    sd      s1, 16(sp)         # save val

    mv      s0, a0             # s0 = root
    mv      s1, a1             # s1 = val

    bnez    s0, .insert_nonempty   # if root != NULL → go to logic

    # if root == NULL → create new node
    mv      a0, s1
    call    make_node
    j       .insert_done

.insert_nonempty:
    lw      t0, 0(s0)          # t0 = root->val
    sext.w  t1, s1             # sign-extend val
    sext.w  t0, t0             # sign-extend root->val

    blt     t1, t0, .insert_left   # if val < root->val → go left
    bgt     t1, t0, .insert_right  # if val > root->val → go right

    # if equal → do nothing
    mv      a0, s0             # return root
    j       .insert_done

.insert_left:
    ld      a0, 8(s0)          # load root->left
    mv      a1, s1             # pass val
    call    insert             # recursive call

    sd      a0, 8(s0)          # update root->left with returned subtree
    mv      a0, s0             # return root
    j       .insert_done

.insert_right:
    ld      a0, 16(s0)         # load root->right
    mv      a1, s1             # pass val
    call    insert             # recursive call

    sd      a0, 16(s0)         # update root->right
    mv      a0, s0             # return root

.insert_done:
    ld      ra, 48(sp)         # restore return address
    ld      s0, 32(sp)         # restore root
    ld      s1, 16(sp)         # restore val
    addi    sp, sp, 64         # restore stack
    ret

get:
    sext.w  a1, a1             # ensure val is 32-bit signed

.get_loop:
    beqz    a0, .get_null      # if root == NULL → not found

    lw      t0, 0(a0)          # t0 = root->val
    sext.w  t0, t0

    beq     a1, t0, .get_found # if equal → found node
    blt     a1, t0, .get_left  # if val < root->val → go left

    # otherwise go right
    ld      a0, 16(a0)         # move to root->right
    j       .get_loop

.get_left:
    ld      a0, 8(a0)          # move to root->left
    j       .get_loop

.get_found:
    ret                        # return pointer to node

.get_null:
    li      a0, 0              # return NULL
    ret

getAtMost:
    sext.w  a0, a0             # ensure val is signed
    li      t2, -1             # best answer = -1 initially
    mv      t3, a1             # t3 = current node (root)

.gam_loop:
    beqz    t3, .gam_done      # if node == NULL → stop

    lw      t0, 0(t3)          # t0 = node->val
    sext.w  t0, t0

    bgt     t0, a0, .gam_left  # if node->val > val → go left

    # valid candidate (<= val)
    mv      t2, t0             # update best answer
    ld      t3, 16(t3)         # move right (try bigger values)
    j       .gam_loop

.gam_left:
    ld      t3, 8(t3)          # move left (smaller values)
    j       .gam_loop

.gam_done:
    mv      a0, t2             # return best found value
    ret