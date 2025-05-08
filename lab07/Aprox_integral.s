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

read_input:
    li a0, 0 // File descriptor 0 (stdin)
    li a7, 63 // Syscall number for read
    la a1, INPUT // Load buffer address
    li a2, 32 // Read up to 32 bytes
    ecall
    ret



# a0 = LINHA
# a1 = Numero
# a2 = Sinal
parse_input:
    la a0, INPUT
    la a1, INPUT_ARRAY
    li t1, 5 //Para após encontrar os 5 números
    li t6, 0 // Contador de números encontrados
    addi a0, a0, -1
    li s0, 0
    li t3, 10
        loop:
            addi a0, a0, 1 // Incrementa o ponteiro do buffer
            beq t6, t1, end_loop // quando t6 == 1 => achou 5 números
            lb t0, 0(a0) // Carrega o caractere atual
            li t2, '-'
            beq t0, t2, negative // Se for negativo
            li t2, '+'
            beq t0, t2, positive // Se for positivo
            li t2, '0'
            blt t0, t2, loop
            li t2, '9'
            bgt t0, t2, loop

            addi t0, t0, -48
            lb t4, 1(a0) // Carrega o próximo caractere
            bgt t4, t2, fim_numero_atual
            li t2, '0'
            blt t4, t2, fim_numero_atual


            mul t0, t0, t3 // Multiplica o número atual por 10
            mul s0, s0, t3 // Multiplica o total por 10
            add s0, s0, t0 // Adiciona o número atual ao total
            j loop

                fim_numero_atual:
                    add s0, s0, t0 // Adiciona o número atual ao total
                    sw s0, 0(a1) // Armazena o número atual no array
                    addi a1, a1, 4 // Avança para o próximo número
                    li s0, 0 // Reseta o total para o próximo número
                    addi t6, t6, 1 // Incrementa o contador de números encontrados
                    j loop
                negative:
                    li t2, -1
                    sw t2, 0(a1) // Armazena o sinal negativo no array
                    addi a1, a1, 4 // Avança para o próximo número
                    j loop
                positive:
                    li t2, 1
                    sw t2, 0(a1) // Armazena o sinal positivo no array
                    addi a1, a1, 4 // Avança para o próximo número
                    j loop
                end_loop:
                    ret


calculate_integral:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, INPUT_ARRAY
    lw s0, 24(t0) // Carrega o valor de START
    lw s1, 28(t0) // Carrega o valor de END

    // Primeiro termo da integral
    mv a0, s0 // Carrega o valor de START
    lw t1, 0(t0)
    lw t2, 4(t0)
    addi a1, t2, 1 // a1 = a + 1
    jal raise_to_power // a0 = start, a1 = a + 1, a2 = (start)^(a+1)
    div s2, a2, a1 // a0 = (start)^(a+1)/(a+1)

    mv a0, s1 // Carrega o valor de END
    jal raise_to_power // a0 = end, a1 = a + 1, a2 = (end)^(a+1)
    div s3, a2, a1 // a0 = (end)^(a+1)/(a+1)

    sub s2, s3, s2 // s2 = (end)^(a+1)/(a+1) - (start)^(a+1)/(a+1)
    mul s2, s2, t1 // s2 = (end)^(a+1)/(a+1) - (start)^(a+1)/(a+1) * sinal



    // Segundo termo da integral
    la t0, INPUT_ARRAY

    mv a0, s1 // Carrega o valor de END
    lw t1, 8(t0) // Carrega o valor de S2
    lw t2, 12(t0) // Carrega o valor de N2
    addi a1, t2, 1 // a1 = b + 1
    jal raise_to_power // a0 = end, a1 = b + 1, a2 = (end)^(b+1)
    div s3, a2, a1 // s3 = (end)^(b+1)/(b+1)

    mv a0, s0 // Carrega o valor de START
    jal raise_to_power // a0 = start, a1 = b + 1, a2 = (start)^(b+1)
    div s4, a2, a1 // s4 = (start)^(b+1)/(b+1)

    sub s4, s3, s4 // s4 = (end)^(b+1)/(b+1) - (start)^(b+1)/(b+1)
    mul s3, s4, t1 // s3 = (end)^(b+1)/(b+1) - (start)^(b+1)/(b+1) * sinal

    // Terceiro termo da integral
    la t0, INPUT_ARRAY

    mv a0, s1 // Carrega o valor de END
    lw t1, 16(t0) // Carrega o valor de S3
    lw t2, 20(t0) // Carrega o valor de N3
    addi a1, t2, 1 // a1 = c + 1
    jal raise_to_power // a0 = end, a1 = c + 1, a2 = (end)^(c+1)
    div s4, a2, a1 // s4 = (end)^(c+1)/(c+1)

    mv a0, s0 // Carrega o valor de START
    jal raise_to_power // a0 = start, a1 = c + 1, a2 = (start)^(c+1)
    div s5, a2, a1 // s5 = (start)^(c+1)/(c+1)

    sub s5, s4, s5 // s5 = (end)^(c+1)/(c+1) - (start)^(c+1)/(c+1)
    mul s4, s5, t1 // s4 = (end)^(c+1)/(c+1) - (start)^(c+1)/(c+1) * sinal

    // Soma os resultados
    add s0, s2, s3
    add s0, s0, s4 // s0 = (end)^(a+1)/(a+1) - (start)^(a+1)/(a+1) * sinal + (end)^(b+1)/(b+1) - (start)^(b+1)/(b+1) * sinal + (end)^(c+1)/(c+1) - (start)^(c+1)/(c+1) * sinal

    // Armazena o resultado final
    la t0, result
    sw s0, 0(t0) // Armazena o resultado no endereço de result

    lw ra, 0(sp)
    addi sp, sp, 4
    ret



# a0 = base
# a1 = exponent
# a2 = a0^a1
raise_to_power:
    li t5, 1
    mv    t0, a1
    li    a2, 1          # Initialize result = 1
    beq   t0, t5, done    # Early exit if exponent == 1
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
    bge t0, zero, positive_int      # Skip if positive
    sb   t1, 0(a1)         # Store '-'
    addi a1, a1, 1         # Move buffer pointer
    sub t0, zero, t0            # Make t0 positive

    positive_int:
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
/*
S1: .skip 1
N1: .skip 4
S2: .skip 1
N2: .skip 4
S3: .skip 1
N3: .skip 4


START: .skip 4
END: .skip 4
*/
// INPUT_ARRAY[0] = S1, INPUT_ARRAY[4] = N1, INPUT_ARRAY[8] = S2, INPUT_ARRAY[12] = N2
// INPUT_ARRAY[16] = S3, INPUT_ARRAY[20] = N3, INPUT_ARRAY[24] = START, INPUT_ARRAY[28] = END
INPUT_ARRAY: .skip 32


/*
LINHA1: .skip 6
LINHA2: .skip 6
LINHA3: .skip 6
LINHA4: .skip 8
*/
INPUT: .skip 32


result: .skip 4
output: .skip 11
# .data
#     INPUT: .string "+ 1 - 2 + 4 32 37"
