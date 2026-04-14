.section .rodata
fmt_int:    .string "%d"
fmt_space:  .string " "
fmt_nl:     .string "\n"

.text
.globl main
main:
    addi sp, sp, -64            # allocate stack frame
    sd ra, 56(sp)
    sd s0, 48(sp)               # s0: element count (argc - 1)
    sd s1, 40(sp)               # s1: input array pointer
    sd s2, 32(sp)               # s2: result array pointer
    sd s3, 24(sp)               # s3: stack array pointer (holds indices)
    sd s4, 16(sp)               # s4: stack top index (-1 = empty)
    sd s5,  8(sp)               # s5: argv pointer
    sd s6,  0(sp)               # s6: loop counter

    addi s0, a0, -1             # number of elements = argc - 1
    mv s5, a1                   # save argv

    slli a0, s0, 2
    call malloc                 # allocate input array (4 bytes per int)
    mv s1, a0

    slli a0, s0, 2
    call malloc                 # allocate result array (4 bytes per int)
    mv s2, a0

    slli a0, s0, 3
    call malloc                 # allocate stack (8 bytes per index, 64-bit)
    mv s3, a0

    li s4, -1                   # stack is empty
    li s6, 0

load_loop:                      # parse argv strings into input array
    bge s6, s0, load_done
    addi t0, s6, 1              # skip argv[0] (program name)
    slli t0, t0, 3              # multiply by 8 (pointer size)
    add t0, t0, s5
    ld a0, 0(t0)                # load argv[i+1] pointer
    call atoi                   # convert to integer
    slli t0, s6, 2
    add t0, t0, s1
    sw a0, 0(t0)                # store in input array
    addi s6, s6, 1
    j load_loop
load_done:

    li s6, 0
init_loop:                      # initialise result array to -1
    bge s6, s0, init_done
    slli t0, s6, 2
    add t0, t0, s2
    li t1, -1
    sw t1, 0(t0)
    addi s6, s6, 1
    j init_loop
init_done:

    addi s6, s0, -1             # start right-to-left scan from last index

algo_loop:
    bltz s6, algo_done

    slli t0, s6, 2
    add t0, t0, s1
    lw t0, 0(t0)                # t0 = arr[i] (current value)

while_loop:                     # pop indices whose values are <= current
    bltz s4, while_done         # stack empty -> no NGE
    slli t1, s4, 3
    add t1, t1, s3
    ld t1, 0(t1)                # t1 = index at stack top
    slli t2, t1, 2
    add t2, t2, s1
    lw t2, 0(t2)                # t2 = arr[stack_top]
    bgt t2, t0, while_done      # arr[stack_top] > arr[i] -> found NGE
    addi s4, s4, -1             # pop
    j while_loop

while_done:
    bltz s4, push               # stack empty -> result stays -1
    slli t1, s4, 3
    add t1, t1, s3
    ld t1, 0(t1)                # t1 = NGE index
    slli t2, s6, 2
    add t2, t2, s2
    sw t1, 0(t2)                # result[i] = NGE index

push:
    addi s4, s4, 1              # push current index onto stack
    slli t1, s4, 3
    add t1, t1, s3
    sd s6, 0(t1)
    addi s6, s6, -1
    j algo_loop

algo_done:

    li s6, 0
    bge s6, s0, print_done      # edge case

    # print result[0] with no leading space
    slli t0, s6, 2
    add t0, t0, s2
    lw a1, 0(t0)
    la a0, fmt_int
    call printf
    addi s6, s6, 1

print_loop:                   
    bge s6, s0, print_done
    la a0, fmt_space
    call printf
    slli t0, s6, 2
    add t0, t0, s2
    lw a1, 0(t0)
    la a0, fmt_int
    call printf
    addi s6, s6, 1
    j print_loop

print_done:
    la a0, fmt_nl
    call printf

    li a0, 0
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5,  8(sp)
    ld s6,  0(sp)
    addi sp, sp, 64
    ret
