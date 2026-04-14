.text
.globl main
main:
    addi sp, sp, -64            # allocate stack frame
    sd ra, 56(sp)
    sd s0, 48(sp)               # s0: element count (argc - 1)
    sd s1, 40(sp)               # s1: input array pointer
    sd s2, 32(sp)               # s2: result array pointer
    sd s3, 24(sp)               # s3: stack pointer (indices)
    sd s4, 16(sp)               # s4: stack top index
    sd s5,  8(sp)               # s5: argv pointer
    sd s6,  0(sp)               # s6: loop counter
    addi s0, a0, -1             
    mv s5, a1                   
    
    slli a0, s0, 2       
    call malloc                 # Allocate input array
    mv s1, a0              
    slli a0, s0, 2
    call malloc                 # Allocate result array
    mv s2, a0              
    slli a0, s0, 3           
    call malloc                 # Allocate stack
    mv s3, a0              
    li s4, -1                   # Initialize stack as empty
    li s6, 0     

loop:                           # Convert argv strings to integers
    bge s6, s0, done
    addi t0, s6, 1           
    slli t0, t0, 3           
    add t0, t0, s5          
    ld a0, 0(t0)           
    call atoi                
    slli t0, s6, 2           
    add t0, t0, s1          
    sw a0, 0(t0)           
    addi s6, s6, 1
    j loop

done:
    li s6, 0

init_loop:                      # Set all result indices to -1
    bge s6, s0, init_done
    slli t0, s6, 2
    add t0, t0, s2
    li t1, -1
    sw t1, 0(t0)           
    addi s6, s6, 1
    j init_loop

init_done:
    addi s6, s0, -1             # Begin right-to-left scan

algo_loop:
    bltz s6, algo_done       
    slli t0, s6, 2
    add t0, t0, s1
    lw t0, 0(t0)                # t0: current value

while_loop:                     # Pop elements smaller than current
    bltz s4, while_done      
    slli t1, s4, 3
    add t1, t1, s3
    ld t1, 0(t1)           
    slli t2, t1, 2
    add t2, t2, s1
    lw t2, 0(t2)           
    bgt t2, t0, while_done      # If stack top > current, found NGE
    addi s4, s4, -1          
    j while_loop

while_done:
    bltz s4, push         
    slli t1, s4, 3
    add t1, t1, s3
    ld t1, 0(t1)           
    slli t2, s6, 2
    add t2, t2, s2
    sw t1, 0(t2)                # Store found NGE index

push:
    addi s4, s4, 1              # Push current index to stack
    slli t1, s4, 3
    add t1, t1, s3
    sd s6, 0(t1)           
    addi s6, s6, -1             
    j algo_loop

algo_done:
    li s6, 0

print_loop:                     # Print results
    bge s6, s0, print_done
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
    li a0, 0                    # restore and return
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
