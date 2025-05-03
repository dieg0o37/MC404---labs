/*
    - Input:
     format:
        - "sig1 a\n sig2 b\n sig3 c\n start end\n"
        - a, b, c (a, b, c are exponests) -> positive from 1-999
        - start, end (start, end are the limits of integration)
        - sig = - ou +
     integral:
        - interate [start, finish] sig1 xˆ(a) + sig2 xˆ(b) + sig3 xˆ(c)
    output:
        - all results should be trucated to integers always (no rounding)
     Primitive function:
        - sig1/(a+1) xˆ(a+1) + sig2/(b+1) xˆ(b+1) + sig3/(c+1) xˆ(c+1)
        - [start, end]
        - sig1/(a+1) (endˆ(a+1) - startˆ(a+1)) + sig2/(b+1) (endˆ(b+1) - startˆ(b+1)) + sig3/(c+1) (endˆ(c+1) - startˆ(c+1))

*/


.text
.global _start
_start:
    j main

exit:
    li a7, 93
    li a0, 0
    ecall

main:
    jal read_input

    jal parse_input

    jal calculate_integral

    jal int_to_ascii

    jal write

    j exit



# a1 = adress of buffer
# a2 = size of buffer
read:
    li a0, 0
    li a7, 63
    ecall
    ret



read_input:
    addi sp, sp, -4
    sw ra, 0(sp)

    la a1, LINHA1
    li a2, 6
    jal read

    la a1, LINHA2
    li a2, 6
    jal read

    la a1, LINHA3
    li a2, 6
    jal read

    la a1, LINHA4
    li a2, 8
    jal read

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

parse_input:
    addi sp, sp, -4
    sw ra, 0(sp)

    la a0, LINHA1
    la a1, N1
    la a2, S1
    jal parse_exponents

    la a0, LINHA2
    la a1, N1
    la a2, S2
    jal parse_exponents

    la a0, LINHA3
    la a1, N3
    la a2, S2
    jal parse_exponents

    la a0, LINHA4
    la a1, START
    la a2, END
    jal parse_limits

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


# a0 = LINHA
# a1 = Numero
# a2 = Sinal
parse_exponents:
    lb t0, 0(a0)
    sb t0, 0(a2)
    addi a0, a0, 2


    li t0, 0x0A
    li t5, 10
    li s0, 0
    loop_exp:
        lb t1, 0(a0) # loads current digit
        addi t4, t1, -48  # transform to int
        lb t2, 1(a0) # loads next digit
        beq t2, t0, break # if next digit is \n
        mul t4, t4, t5 # multiply current digit by 10
        mul s0, s0, t5 # multiply current total by 10
        add s0, s0, t4 # add current digit to total
        addi a0, a0, 1 # increment pointer
        j loop_exp
    break:
        add s0, s0, t4 # add current digit to total
        sw s0, 0(a1)
        ret

# a0 = LINHA
parse_limits:
    la a1, START
    li t0, ' '

    li t3, 0x0A
    li t5, 10
    li s0, 0
    loop_lim:
        lb t1, 0(a0)
        addi t6, t1, -48


        lb t2, 1(a0)
        beq t2, t0, fim1
        beq t2, t3, fim
        mul t6, t6, t5 # multiply current digit by 10
        mul s0, s0, t5 # multiply current total by 10
        add s0, s0, t6 # add current digit to total
        addi a0, a0, 1
        j loop_lim
    fim1:
        add s0, s0, t6 # add current digit to total
        addi a0, a0, 2
        sw s0, 0(a1)
        la a1, END
        li s0, 0
        j loop_lim
    fim:
        add s0, s0, t6 # add current digit to total
        sw s0, 0(a1)
        ret
/*
    s0 = (sig1)endˆ(a+1)/(a+1), s1 = (sig2)startˆ(a+1)/(a+1)
    s4 = (sig2)endˆ(b+1)/(b+1), s5 = (sig2)start^(b+1)/(b+1)
    s6 = (sig2)end^(c+1)/(c+1), s7 = (sig2)start^(c+1)/(c+1)

*/
calculate_integral:
    addi sp, sp, -4
    sw ra, 0(sp)
    li t1, '-'



    la t0, END
    lw a0, 0(t0)
    la t0, N1
    lw t1, 0(t0)
    addi a1, t1, 1
    jal raise_to_power # a2 = end^(a+1)
    div s2, a2, a1 # a2 = end^(a+1)/(a+1)
    la t0, START
    lw a0, 0(t0)
    jal raise_to_power # a2 = start^(a+1)
    div s3, a2, a1 # a2 = start^(a+1)/(a+1)
    la t0, S1
    lb t2, 0(t0)
    beq t2, t1, 2f
    mv s1, s3
    mv s0, s2
    j 1f
    2:
    li t2, -1
    mul s0, s2, t2
    mul s1, s3, t2
    1:

    la t0, END
    lw a0, 0(t0)
    la t0, N2
    lw t1, 0(t0)
    addi a1, t1, 1
    jal raise_to_power # a2 = end^(b+1)
    div s2, a2, a1 # a2 = end^(b+1)/(b+1)
    la t0, START
    lw a0, 0(t0)
    jal raise_to_power # a2 = start^(b+1)
    div s3, a2, a1 # a2 = start^(b+1)/(b+1)
    la t0, S2
    lb t2, 0(t0)
    beq t2, t1, 2f
    mv s5, s3
    mv s4, s2
    j 1f
    2:
    li t2, -1
    mul s4, s2, t2 # s4 = (sig2)end^(b+1)/(b+1)
    mul s5, s3, t2 # s5 = (sig2)start^(b+1)/(b+1)
    1:

    la t0, END
    lw a0, 0(t0)
    la t0, N3
    lw t1, 0(t0)
    addi a1, t1, 1
    jal raise_to_power # a2 = end^(c+1)
    div s2, a2, a1 # a2 = end^(c+1)/(c+1)
    la t0, START
    lw a0, 0(t0)
    jal raise_to_power # a2 = start^(c+1)
    div s3, a2, a1 # a2 = start^(c+1)/(c+1)
    la t0, S3
    lb t2, 0(t0)
    beq t2, t1, 2f
    mv s7, s3
    mv s6, s2
    j 1f
    2:
    li t2, -1
    mul s6, s2, t2 # s6 = (sig2)end^(c+1)/(c+1)
    mul s7, s3, t2 # s7 = (sig2)start^(c+1)/(c+1)
    1:

    sub s0, s0, s1
    sub s4, s4, s5
    sub s6, s6, s7

    add s0, s0, s4
    add s0, s0, s6

    la t0, result
    sw s0, 0(t0)

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a2 = output = input
invert_sig:
    li t2, -1
    mul a2, a2, t2
    ret
# a0 = base
# a1 = exponent
# a2 = a0^a1
raise_to_power:
    li t1, 1
    mv    t0, a1
    li    a2, 1          # Initialize result = 1
    beq   t0, t1, done    # Early exit if exponent == 1
    loop_pow:
        mul   a2, a2, a0     # result *= base
        addi  t0, t0, -1     # exponent--
        bnez  t0, loop_pow       # Repeat if exponent != 0
    done:
        ret                  # Return (result in a2)


int_to_ascii:
    # Load integer address (a0) and string buffer (a1)
    la   a0, result       # a0 = &integer
    la   a1, output    # a1 = &string_buf

    # Load the integer value
    lw   t0, 0(a0)         # t0 = integer value

    # Handle negative numbers
    li   t1, '-'           # t1 = '-'
    bge t0, zero, positive      # Skip if positive
    sb   t1, 0(a1)         # Store '-'
    addi a1, a1, 1         # Move buffer pointer
    sub t0, zero, t0            # Make t0 positive

    positive:
        # Initialize digit counter and stack pointer
        li   t2, 0            # t2 = digit count
        mv   t3, a1           # t3 = start of digits (for reversal)

    extract_digits:
        # Extract digits (LSB first)
        li   t4, 10           # Divisor = 10
        remu t5, t0, t4       # t5 = t0 % 10 (current digit)
        divu t0, t0, t4       # t0 = t0 / 10
        addi t5, t5, '0'      # Convert digit to ASCII
        sb   t5, 0(a1)        # Store digit
        addi a1, a1, 1        # Increment buffer pointer
        addi t2, t2, 1        # Increment digit count
        bnez t0, extract_digits # Repeat if t0 != 0

        # Reverse digits (since they were extracted LSB first)
        mv   t6, a1           # t6 = end of digits
    reverse_loop:
        addi t6, t6, -1       # Move t6 backward
        lb   t4, 0(t3)        # Load digit from start
        lb   t5, 0(t6)        # Load digit from end
        sb   t5, 0(t3)        # Swap
        sb   t4, 0(t6)
        addi t3, t3, 1        # Move start forward
        blt  t3, t6, reverse_loop # Repeat until pointers cross

        # Add newline and null terminator
        li   t1, '\n'         # t1 = '\n'
        sb   t1, 0(a1)        # Store newline

        ret                   # Return


write:
    li a0, 1            # stdout
    la a1, output
    li a2, 11            # write 11 bytes
    li a7, 64           # syscall write
    ecall
    ret



.bss
S1: .skip 1
N1: .skip 4
S2: .skip 1
N2: .skip 4
S3: .skip 1
N3: .skip 4

START: .skip 4
END: .skip 4

LINHA1: .skip 6
LINHA2: .skip 6
LINHA3: .skip 6
LINHA4: .skip 8

result: .skip 4
output: .skip 11
