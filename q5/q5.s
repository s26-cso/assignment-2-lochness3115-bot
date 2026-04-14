.text
    .globl main

main:
    # Setup stack frame and preserve callee-saved registers
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)    # s0: file pointer
    sd s1, 24(sp)    # s1: string length
    sd s2, 16(sp)    # s2: left index
    sd s3, 8(sp)     # s3: right index
    sd s4, 0(sp)     # s4: char buffer

    # Open file for reading
    la a0, filename
    la a1, mode_r
    call fopen
    mv s0, a0

    # Determine file size using fseek/ftell
    mv a0, s0
    li a1, 0
    li a2, 2         # SEEK_END
    call fseek
    mv a0, s0
    call ftell
    mv s1, a0

    # Check for trailing newline and adjust length if found
    mv a0, s0
    addi a1, s1, -1
    li a2, 0         # SEEK_SET
    call fseek
    mv a0, s0
    call fgetc
    li t0, 10        # ASCII '\n'
    bne a0, t0, no_trim
    addi s1, s1, -1

no_trim:
    li s2, 0         # Start at index 0
    addi s3, s1, -1  # End at index length-1

check_loop:
    # Break loop if pointers cross
    bge s2, s3, yes
    
    # Read character at left pointer
    mv a0, s0
    mv a1, s2
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    mv s4, a0

    # Read character at right pointer
    mv a0, s0
    mv a1, s3
    li a2, 0
    call fseek
    mv a0, s0
    call fgetc
    
    # Compare characters; exit loop on mismatch
    bne s4, a0, no
    
    # Advance pointers inward
    addi s2, s2, 1
    addi s3, s3, -1
    j check_loop

yes:
    la a0, yes_str
    call printf
    j done

no:
    la a0, no_str
    call printf

done:
    # return
    li a0, 0
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    ld s4, 0(sp)
    addi sp, sp, 48
    ret

.section .rodata
filename: .string "input.txt"
mode_r:   .string "r"
yes_str:  .string "Yes\n"
no_str:   .string "No\n"
