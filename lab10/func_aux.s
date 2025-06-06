# func_aux.s - Implementacao de funcoes utilitarias

.text
# ------------------------------------------------------------------------------
# exit(int code) -> a0 = code
# Usa a syscall exit (93) para terminar o programa.
# ------------------------------------------------------------------------------
.globl exit
exit:
    li a7, 93       # Carrega o numero da syscall exit (93)
    ecall           # Chama o sistema operacional

# Defines a newline character in the data section
.data
newline: .asciz "\n"

.text
# ------------------------------------------------------------------------------
# puts(const char *str) -> a0 = str
# Writes the string str to stdout followed by a newline using single syscalls.
# THIS VERSION IS MUCH MORE EFFICIENT.
# ------------------------------------------------------------------------------
.globl puts
puts:
    addi sp, sp, -16    # Aloca espaço na pilha
    sw ra, 12(sp)       # Salva o endereço de retorno (ra)
    sw s0, 8(sp)        # Salva s0 (ponteiro da string)
    sw s1, 4(sp)        # Salva s1 (contador de tamanho)

    mv s0, a0           # s0 = ponteiro da string (str)
    li s1, 0            # s1 = contador de tamanho (len)

    # Loop para calcular o tamanho da string (strlen)
    strlen_loop:
        add t0, s0, s1      # t0 = str + len
        lb t1, 0(t0)        # Carrega o caractere atual
        beqz t1, strlen_end # Se for NULL (\0), termina o loop
        addi s1, s1, 1      # len++
        j strlen_loop       # Repete

    strlen_end:
        # Se o tamanho for 0, pula para imprimir a nova linha
        beqz s1, puts_newline

        # Syscall para escrever a string inteira
        li a7, 64           # Syscall write (64)
        li a0, 1            # File descriptor 1 (stdout)
        mv a1, s0           # Endereço da string
        mv a2, s1           # Tamanho da string
        ecall               # Chama a syscall

    puts_newline:
        # Syscall para escrever a nova linha
        li a7, 64           # Syscall write
        li a0, 1            # stdout
        la a1, newline      # Endereço do caractere '\n'
        li a2, 1            # Tamanho (1 byte)
        ecall               # Chama a syscall

    puts_end:
        lw s1, 4(sp)        # Restaura s1
        lw s0, 8(sp)        # Restaura s0
        lw ra, 12(sp)       # Restaura ra
        addi sp, sp, 16     # Desaloca espaço da pilha
        ret  
# ------------------------------------------------------------------------------
# gets(char *str) -> a0 = str
# Le uma linha da entrada padrao (stdin) para a string str.
# Usa a syscall read (63). Retorna o ponteiro str.
# ------------------------------------------------------------------------------
.globl gets
gets:
    addi sp, sp, -16    # Aloca espaco na pilha
    sw ra, 12(sp)       # Salva ra
    sw s0, 8(sp)        # Salva s0 (ponteiro original do buffer)
    sw s1, 4(sp)        # Salva s1 (ponteiro atual do buffer)

    mv s0, a0           # s0 = ponteiro original (para retornar)
    mv s1, a0           # s1 = ponteiro atual (para escrita)
    addi t0, sp, 0      # t0 = buffer temporario de 1 byte na pilha

    gets_loop:
        li a7, 63           # Syscall read (63)
        li a0, 0            # File descriptor 0 (stdin)
        mv a1, t0           # Endereco do buffer temporario
        li a2, 1            # Ler 1 byte
        ecall               # Chama a syscall

        # Se ecall retornar 0 (EOF) ou < 0 (erro), termina.
        # Tambem verifica se leu algo (a0 > 0).
        blez a0, gets_end_null # Se <= 0, termina

        lb t1, 0(t0)        # Carrega o byte lido
        li t2, '\n'         # Caractere de nova linha
        beq t1, t2, gets_end_null # Se for '\n', termina

        sb t1, 0(s1)        # Armazena o caractere no buffer do usuario
        addi s1, s1, 1      # Avanca o ponteiro do buffer do usuario
        j gets_loop         # Repete

    gets_end_null:
        li t1, 0            # Caractere NULL (\0)
        sb t1, 0(s1)        # Armazena o NULL para terminar a string

    gets_end:
        mv a0, s0           # Coloca o ponteiro original em a0 (valor de retorno)
        lw s1, 4(sp)        # Restaura s1
        lw s0, 8(sp)        # Restaura s0
        lw ra, 12(sp)       # Restaura ra
        addi sp, sp, 16     # Desaloca a pilha
        ret                 # Retorna

# ------------------------------------------------------------------------------
# atoi(const char *str) -> a0 = str
# Converte a string str para um inteiro.
# ------------------------------------------------------------------------------
.globl atoi
atoi:
    addi sp, sp, -16    # Aloca pilha
    sw ra, 12(sp)       # Salva ra
    sw s0, 8(sp)        # s0 = ponteiro da string
    sw s1, 4(sp)        # s1 = resultado
    sw s2, 0(sp)        # s2 = sinal (1 ou -1)

    mv s0, a0           # s0 = str
    li s1, 0            # resultado = 0
    li s2, 1            # sinal = 1

    lb t0, 0(s0)        # Carrega o primeiro caractere
    li t1, '-'
    bne t0, t1, atoi_loop_start # Se nao for '-', comeca o loop

    li s2, -1           # Se for '-', sinal = -1
    addi s0, s0, 1      # Avanca para o proximo caractere

    atoi_loop_start:
        lb t0, 0(s0)        # Carrega o caractere atual
        beqz t0, atoi_end   # Se for NULL, termina

        li t1, '0'
        blt t0, t1, atoi_end # Se < '0', nao e digito, termina
        li t1, '9'
        bgt t0, t1, atoi_end # Se > '9', nao e digito, termina

        addi t0, t0, -'0'   # Converte para int

        li t1, 10
        mul s1, s1, t1      # resultado = resultado * 10
        add s1, s1, t0      # resultado = resultado + digito

        addi s0, s0, 1      # Proximo caractere
        j atoi_loop_start   # Repete

    atoi_end:
        mul s1, s1, s2      # Aplica o sinal
        mv a0, s1           # Coloca o resultado em a0 (retorno)

        lw s2, 0(sp)        # Restaura s2
        lw s1, 4(sp)        # Restaura s1
        lw s0, 8(sp)        # Restaura s0
        lw ra, 12(sp)       # Restaura ra
        addi sp, sp, 16     # Desaloca pilha
        ret                 # Retorna

# ------------------------------------------------------------------------------
# itoa(int value, char *str, int base) -> a0 = value, a1 = str, a2 = base
# Converte o inteiro 'value' para uma string 'str' na 'base' dada.
# Retorna o ponteiro str.
# ------------------------------------------------------------------------------

.data
    hex_chars: .asciz "0123456789abcdef" # Caracteres para itoa (base 16)
.text
.globl itoa
itoa:
    addi sp, sp, -48    # Aloca 48 bytes (32 temp_buf + 16 regs)
    sw ra, 44(sp)       # Salva ra
    sw s0, 40(sp)       # s0 = value
    sw s1, 36(sp)       # s1 = str (original)
    sw s2, 32(sp)       # s2 = base
    sw s3, 28(sp)       # s3 = temp_buf_ptr (inicio)
    sw s4, 24(sp)       # s4 = is_negative
    sw s5, 20(sp)       # s5 = temp_buf_ptr (atual)

    mv s0, a0           # s0 = value
    mv s1, a1           # s1 = str
    mv s2, a2           # s2 = base
    addi s3, sp, 0      # s3 = inicio do buffer temporario
    mv s5, s3           # s5 = ponteiro atual do buffer temporario
    li s4, 0            # is_negative = 0

    # Caso especial: value = 0
    bnez s0, itoa_check_neg
    li t1, '0'
    sb t1, 0(s5)        # Armazena '0'
    addi s5, s5, 1      # Avanca ponteiro
    j itoa_reverse      # Vai para a reversao

    itoa_check_neg:
        li t1, 10
        bne s2, t1, itoa_loop # Se base != 10, nao ha negativo
        bgez s0, itoa_loop    # Se >= 0, nao ha negativo

        li s4, 1            # Marca como negativo
        neg s0, s0          # Torna o valor positivo

    itoa_loop:
        rem t1, s0, s2      # t1 = value % base (resto)
        div t2, s0, s2      # t2 = value / base (quociente)

        la t3, hex_chars    # Carrega endereco dos caracteres
        add t3, t3, t1      # Pega o endereco do caractere do resto
        lb t1, 0(t3)        # Carrega o caractere

        sb t1, 0(s5)        # Armazena o caractere no buffer temporario
        addi s5, s5, 1      # Avanca ponteiro temporario
        mv s0, t2           # value = value / base
        bnez s0, itoa_loop  # Se value != 0, repete

        # Adiciona '-' se for negativo
        beqz s4, itoa_reverse
        li t1, '-'
        sb t1, 0(s5)
        addi s5, s5, 1

    itoa_reverse:
        # O buffer temporario (s3 a s5-1) contem a string invertida.
        # Agora, copia (invertendo) para o buffer do usuario (s1).
        mv t0, s1           # t0 = ponteiro do buffer do usuario
        addi s5, s5, -1     # s5 aponta para o ultimo caractere no temp

    itoa_rev_loop:
        blt s5, s3, itoa_end_rev # Se s5 < s3 (inicio), termina a copia
        lb t1, 0(s5)        # Carrega caractere do buffer temporario
        sb t1, 0(t0)        # Armazena no buffer do usuario
        addi s5, s5, -1     # Decrementa ponteiro temporario
        addi t0, t0, 1      # Incrementa ponteiro do usuario
        j itoa_rev_loop

    itoa_end_rev:
        li t1, 0
        sb t1, 0(t0)        # Adiciona NULL ao final da string do usuario

    itoa_end:
        mv a0, s1           # Retorna o ponteiro original da string

        lw s5, 20(sp)       # Restaura registros salvos
        lw s4, 24(sp)
        lw s3, 28(sp)
        lw s2, 32(sp)
        lw s1, 36(sp)
        lw s0, 40(sp)
        lw ra, 44(sp)
        addi sp, sp, 48     # Desaloca pilha
        ret                 # Retorna
