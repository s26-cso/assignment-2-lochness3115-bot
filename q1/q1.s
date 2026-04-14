.text
.global make_node
.global insert
.global get
.global getAtMost

# make_node(int val) -> Node*
# Creates a new BST node with given value, left=NULL, right=NULL
make_node:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    mv s0, a0               # save val argument
    li a0, 24
    call malloc             # allocate 24 bytes for the node
    sw s0, 0(a0)            # node->val = val (word, 4 bytes)
    sd x0, 8(a0)            # node->left = NULL
    sd x0, 16(a0)           # node->right = NULL
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret                     # return pointer to new node in a0

# insert(Node* root, int val) -> Node*
# Inserts val into BST rooted at root, returns (possibly new) root
insert:
    bnez a0, start_search   # if root != NULL, search for insertion point
    mv a0, a1               # else root is NULL: a0 = val
    tail make_node          # tail call make_node(val), return the new node as root

start_search:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    mv s2, a0               # s2 = current root 
    mv s3, a1               # s3 = val to insert 
    lw t0, 0(s2)            # t0 = root->val
    beq s3, t0, finish_up   # if val == root->val, duplicate — do nothing
    blt s3, t0, go_left     # if val < root->val, insert into left subtree

    # val > root->val: insert into right subtree
    ld a0, 16(s2)           # a0 = root->right
    mv a1, s3               # a1 = val
    call insert             # insert(root->right, val)
    sd a0, 16(s2)           # root->right = returned (possibly new) node
    j finish_up

go_left:
    ld a0, 8(s2)            # a0 = root->left
    mv a1, s3               # a1 = val
    call insert             # insert(root->left, val)
    sd a0, 8(s2)            # root->left = returned (possibly new) node

finish_up:
    mv a0, s2               # return the current root (unchanged)
    ld ra, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    addi sp, sp, 32
    ret

# get(Node* root, int val) -> Node*
# Searches BST for val; returns pointer to node if found, NULL otherwise
get:
    mv t0, a0               # t0 = current node pointer

find_loop:
    beqz t0, not_found      # if current == NULL, val not in tree
    lw t1, 0(t0)            # t1 = current->val
    beq a1, t1, found_it    # if val == current->val, found
    blt a1, t1, move_left   # if val < current->val, go left
    ld t0, 16(t0)           # else val > current->val, go right
    j find_loop

move_left:
    ld t0, 8(t0)            # go left
    j find_loop

found_it:
    mv a0, t0               # return pointer to the found node
    ret

not_found:
    li a0, 0                # return NULL
    ret

# getAtMost(int target, Node* root) -> int
# Returns the largest value in BST that is <= target (BST floor operation)
getAtMost:
    mv t0, a1               # t0 = current node (root), a0 = target (unchanged)
    li t2, -1               # t2 = best candidate so far (-1 = none found yet)

tree_traverse:
    beqz t0, exit_atmost    # if current == NULL, return best found so far
    lw t1, 0(t0)            # t1 = current->val
    beq t1, a0, exact_match # if current->val == target, perfect match
    blt a0, t1, jump_left   # if target < current->val, current is too big — go left

    # target > current->val: current is a valid candidate, but try to find closer
    mv t2, t1               # best = current->val 
    ld t0, 16(t0)           # go right to look for a larger value still <= target
    j tree_traverse

jump_left:
    ld t0, 8(t0)            # go left (current->val too large)
    j tree_traverse

exact_match:
    mv a0, t1               # return the exact matching value
    ret

exit_atmost:
    mv a0, t2               # return best candidate else -1
    ret
