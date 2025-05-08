
read_input:
    li a0, 0 // File descriptor 0 (stdin)
    li a7, 63 // Syscall number for read
    la a1, INPUT // Load buffer address
    li a2, 32 // Read up to 32 bytes
    ecall
    ret

/*
    percorre o INPUT, transforma os números em inteiros e os sinais em (-1 ou +1)
*/
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
    lw t1, 8(t0) // Carrega o valor de S2
    lw t2, 12(t0) // Carrega o valor de N2
    addi a1, t2, 1 // a1 = b + 1
    jal raise_to_power // a0 = end, a1 = b + 1, a2 = (end)^(b+1)
    div s3, a2, a1 // s3 = (end)^(b+1)/(b+1)
    mv a0, s0 // Carrega o valor de START
    jal raise_to_power // a0 = start, a1 = b + 1, a2 = (start)^(b+1)
    div s4, a2, a1 // a0 = (start)^(b+1)/(b+1)
    sub s4, s3, s4 // s4 = (end)^(b+1)/(b+1) - (start)^(b+1)/(b+1)
    mul s3, s4, t1 // s3 = (end)^(b+1)/(b+1) - (start)^(b+1)/(b+1) * sinal

    // Terceiro termo da integral
    lw t1, 16(t0) // Carrega o valor de S3
    lw t2, 20(t0) // Carrega o valor de N3
    addi a1, t2, 1 // a1 = c + 1
    jal raise_to_power // a0 = end, a1 = c + 1, a2 = (end)^(c+1)
    div s4, a2, a1 // s4 = (end)^(c+1)/(c+1)
    mv a0, s0 // Carrega o valor de START
    jal raise_to_power // a0 = start, a1 = c + 1, a2 = (start)^(c+1)
    div s5, a2, a1 // a0 = (start)^(c+1)/(c+1)
    sub s5, s4, s5 // s5 = (end)^(c+1)/(c+1) - (start)^(c+1)/(c+1)
    mul s4, s5, t1 // s4 = (end)^(c+1)/(c+1) - (start)^(c+1)/(c+1) * sinal
    
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
    li t1, 1
    mv    t0, a1
    li    a2, 1          # Initialize result = 1
    beq   t0, t1, done    # Early exit if exponent == 1
    loop_pow:
        mul   a2, a2, a0     # result *= base
        addi  t0, t0, -1     # exponent--
        bnez  t0, loop_pow       # Repeat if exponent != 0
    done:
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