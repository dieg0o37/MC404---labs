
# ==============================================================================
# FUNCOES RECURSIVAS PRINCIPAIS
# ==============================================================================
# ------------------------------------------------------------------------------
# int fatorial_recursive(int num) -> a0 = num
# Retorna num!
# ------------------------------------------------------------------------------
.globl fatorial_recursive
fatorial_recursive:
    addi sp, sp, -8     # Aloca espaco para ra e s0 (num)
    sw ra, 4(sp)        # Salva endereco de retorno
    sw s0, 0(sp)        # Salva s0 (usaremos para num)

    mv s0, a0           # s0 = num

    # Caso base: num == 0 ou num == 1, retorna 1
    # Como num <= 1 tambem inclui num == 0 para fatorial (0! = 1)
    # E se num for negativo (nao esperado pelo problema, mas para robustez)
    # O comportamento para num < 0 nao esta definido, vamos tratar num <= 1 -> 1
    li t0, 1
    ble s0, t0, fatorial_base_case # Se num <= 1, vai para o caso base

    # Passo recursivo: num * fatorial_recursive(num - 1)
    addi a0, s0, -1     # a0 = num - 1 (argumento para a chamada recursiva)
    call fatorial_recursive # Chamada recursiva, resultado em a0

    # resultado_recursivo (em a0) * num (em s0)
    mul a0, a0, s0      # a0 = resultado_final

    j fatorial_end

fatorial_base_case:
    li a0, 1            # Retorna 1

fatorial_end:
    lw s0, 0(sp)        # Restaura s0
    lw ra, 4(sp)        # Restaura ra
    addi sp, sp, 8      # Desaloca espaco da pilha
    ret

# ------------------------------------------------------------------------------
# int fibonacci_recursive(int num) -> a0 = num
# Retorna o N-esimo numero de Fibonacci.
# ------------------------------------------------------------------------------
.globl fibonacci_recursive
fibonacci_recursive:
    addi sp, sp, -12    # Aloca para ra, s0 (num), s1 (fib(n-1))
    sw ra, 8(sp)        # Salva ra
    sw s0, 4(sp)        # Salva s0 (para num)
    sw s1, 0(sp)        # Salva s1 (para guardar fib(n-1))

    mv s0, a0           # s0 = num

    # Caso base 1: num == 0, retorna 0
    beqz s0, fib_base_case_0

    # Caso base 2: num == 1, retorna 1
    li t0, 1
    beq s0, t0, fib_base_case_1

    # Passo recursivo: fib(num - 1) + fib(num - 2)

    # Calcula fib(num - 1)
    addi a0, s0, -1     # a0 = num - 1 
    jal fibonacci_recursive # fib(n-1) retorna em a0
    mv s1, a0           # Salva fib(n-1) em s1

    # Calcula fib(num - 2)
    addi a0, s0, -2     # a0 = num - 2
    jal fibonacci_recursive # fib(n-2) retorna em a0
                            # s1 (fib(n-1)) ainda esta salvo

    # Soma os resultados: fib(n-1) (em s1) + fib(n-2) (em a0)
    add a0, s1, a0      # a0 = resultado_final

    j fib_end

fib_base_case_0:
    li a0, 0            # Retorna 0
    j fib_end

fib_base_case_1:
    li a0, 1            # Retorna 1
    # Nao precisa pular para fib_end, pois a restauracao da pilha ocorre la

fib_end:
    lw s1, 0(sp)        # Restaura s1
    lw s0, 4(sp)        # Restaura s0
    lw ra, 8(sp)        # Restaura ra
    addi sp, sp, 12     # Desaloca pilha
    ret

# ------------------------------------------------------------------------------
# void torre_de_hanoi(int num, char de, char aux, char ate, char* str_fmt)
# a0=num, a1=de, a2=aux, a3=ate, a4=str_fmt
# str_fmt e "Mover disco _ da torre _ para a torre _\0"
# Indices dos '_': 12 (num disco), 23 (de_torre), 38 (ate_torre)
# Max discos e 9, entao o num do disco e 1 digito.
# ------------------------------------------------------------------------------
.globl torre_de_hanoi
torre_de_hanoi:
    # Pilha: ra, s0(num), s1(de), s2(aux), s3(ate), s4(str_fmt), s5 (num_disco_str_buf)
    # s5 precisa de ~3 bytes para "9\0". Alocamos 4 por alinhamento.
    # Total: 4*7 = 28. Alocamos 32 por alinhamento de 8 bytes.
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)       # num
    sw s1, 20(sp)       # de_char
    sw s2, 16(sp)       # aux_char
    sw s3, 12(sp)       # ate_char
    sw s4, 8(sp)        # str_fmt_ptr
    # s5 sera usado como ponteiro para um buffer na pilha para itoa
    # Buffer para string do numero do disco (ex: "1\0", "9\0") na pilha:
    # sp+0 a sp+3 (4 bytes)

    mv s0, a0           # s0 = num
    mv s1, a1           # s1 = de_char
    mv s2, a2           # s2 = aux_char
    mv s3, a3           # s3 = ate_char
    mv s4, a4           # s4 = str_fmt_ptr

    # Caso base: num == 1
    li t0, 1
    bne s0, t0, hanoi_recursive_step
    # Se num == 1: Imprimir "Mover disco 1 da torre 'de' para a torre 'ate'"

    # Prepara para chamar itoa para o disco 1
    li a0, 1            # value = 1
    mv a1, sp           # a1 = buffer na pilha para string "1"
    li a2, 10           # base = 10
    jal itoa            # itoa converte 1 para "1" no buffer sp+0
                        # a0 (retorno de itoa) aponta para sp+0

    # Carrega o char '1' do buffer (sp+0)
    lb t0, 0(sp)        # t0 = caractere '1'

    # Modifica a string de formato (s4)
    # "Mover disco _ da torre _ para a torre _\0"
    #              ^12        ^23            ^38
    sb t0, 12(s4)       # Coloca '1' no lugar do primeiro '_'
    sb s1, 23(s4)       # Coloca char 'de' no lugar do segundo '_'
    sb s3, 38(s4)       # Coloca char 'ate' no lugar do terceiro '_'

    # Chama puts com a string formatada
    mv a0, s4
    jal puts

    j hanoi_end         # Fim para num == 1

hanoi_recursive_step:
    # torre_de_hanoi(num - 1, de, ate, aux, str_fmt)
    addi a0, s0, -1     # a0 = num - 1
    mv a1, s1           # a1 = de (s1)
    mv a2, s3           # a2 = ate (s3) -> se torna o novo auxiliar
    mv a3, s2           # a3 = aux (s2) -> se torna o novo destino
    mv a4, s4           # a4 = str_fmt (s4)
    jal torre_de_hanoi

    # Imprimir "Mover disco 'num' da torre 'de' para a torre 'ate'"
    # Prepara para chamar itoa para o disco 'num' (s0)
    mv a0, s0           # value = num (s0)
    mv a1, sp           # a1 = buffer na pilha para string do num
    li a2, 10           # base = 10
    jal itoa            # itoa converte num para string no buffer sp+0

    lb t0, 0(sp)        # t0 = primeiro (e unico) digito do numero do disco

    sb t0, 12(s4)       # Coloca digito do disco 'num'
    sb s1, 23(s4)       # Coloca char 'de'
    sb s3, 38(s4)       # Coloca char 'ate'
    mv a0, s4
    jal puts
    
    

    # torre_de_hanoi(num - 1, aux, de, ate, str_fmt)
    addi a0, s0, -1     # a0 = num - 1
    mv a1, s2           # a1 = aux (s2) -> se torna a nova origem
    mv a2, s1           # a2 = de (s1) -> se torna o novo auxiliar
    mv a3, s3           # a3 = ate (s3)
    mv a4, s4           # a4 = str_fmt (s4)
    jal torre_de_hanoi

hanoi_end:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    addi sp, sp, 32
    ret