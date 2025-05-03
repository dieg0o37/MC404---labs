.data
terms:    .space 24    # 3 termos (sinal, expoente) * 4 bytes cada
a:        .word 0      # Início do intervalo
b:        .word 0      # Fim do intervalo
buffer:   .space 12    # Buffer para conversão do resultado + '\n'

.text
.globl main

main:
    # Ler 8 inteiros (3 termos + a e b)
    la s0, terms       # Endereço dos termos
    li s1, 8           # Contador de leitura
read_loop:
    li a7, 63          # Syscall 63: read_int
    ecall
    sw a0, 0(s0)       # Armazena o inteiro lido
    addi s0, s0, 4
    addi s1, s1, -1
    bnez s1, read_loop

    # Carregar a e b
    la s0, terms
    lw s6, 24(s0)      # a
    lw s7, 28(s0)      # b

    # Processar cada termo
    la s3, terms       # Ponteiro para os termos
    li s4, 3           # Contador de termos
    li s2, 0           # soma = 0

term_loop:
    # Carregar sinal e expoente
    lw s5, 0(s3)       # sinal
    lw s8, 4(s3)       # expoente
    addi s8, s8, 1     # n = expoente + 1

    # Calcular a^n / n
    mv a0, s6          # a
    mv a1, s8
    jal ra, power
    div t1, a0, s8     # a_div = a^n / n (truncado)

    # Calcular b^n / n
    mv a0, s7          # b
    mv a1, s8
    jal ra, power
    div t2, a0, s8     # b_div = b^n / n (truncado)

    # Diferença e acumular
    sub t3, t2, t1     # diferença = b_div - a_div
    mul t4, t3, s5     # term_value = diferença * sinal
    add s2, s2, t4     # soma += term_value

    # Próximo termo
    addi s3, s3, 8
    addi s4, s4, -1
    bnez s4, term_loop

    # Converter resultado (s2) para ASCII em buffer
    jal ra, int_to_str

    # Escrever buffer via syscall 64 (write)
    li a7, 64          # Syscall 64: write
    li a0, 1           # File descriptor (stdout)
    la a1, buffer       # Endereço do buffer
    mv a2, t0          # Tamanho da string (calculado em int_to_str)
    ecall

    # Encerrar
    li a7, 93          # Syscall 93: exit
    ecall

# Função: a0^a1 (potência)
power:
    li t0, 1
    beqz a1, power_end
power_loop:
    mul t0, t0, a0
    addi a1, a1, -1
    bnez a1, power_loop
power_end:
    mv a0, t0
    ret

# Função: Converte s2 para ASCII em buffer (com '\n')
int_to_str:
    la t1, buffer      # Início do buffer
    addi t2, t1, 11    # Fim do buffer (12 bytes)
    li t3, 0           # Contador de dígitos

    # Tratar sinal negativo
    bltz s2, negative
    li t4, 1           # sinal = positivo
    j convert
negative:
    li t4, -1          # sinal = negativo
    neg s2, s2         # Tornar positivo

convert:
    # Extrair dígitos (LSB primeiro)
    li t5, 10
extract:
    rem t6, s2, t5     # t6 = s2 % 10
    div s2, s2, t5     # s2 = s2 / 10
    addi t6, t6, '0'   # Converter para ASCII
    sb t6, 0(t2)       # Armazenar no buffer (do fim para o início)
    addi t2, t2, -1
    addi t3, t3, 1     # Incrementar contador
    bnez s2, extract

    # Adicionar sinal negativo se necessário
    beqz t4, reverse
    li t6, '-'
    sb t6, 0(t2)
    addi t2, t2, -1
    addi t3, t3, 1

reverse:
    addi t2, t2, 1     # Ajustar ponteiro para o primeiro dígito
    la t1, buffer       # Início do buffer
reverse_loop:
    lb t5, 0(t2)        # Carregar dígito
    sb t5, 0(t1)        # Armazenar no início
    addi t1, t1, 1
    addi t2, t2, 1
    addi t3, t3, -1
    bnez t3, reverse_loop

    # Adicionar '\n'
    li t5, '\n'
    sb t5, 0(t1)
    addi t1, t1, 1

    # Calcular tamanho da string (t1 - buffer)
    la t0, buffer
    sub t0, t1, t0
    ret