.data
INPUT_BUFFER: .skip 8192        # Buffer para armazenar a string de entrada inteira
TAM_CAMADAS: .skip 40           # Suporta até 10 camadas (10 * 4 bytes/int)
PESOS_MATRIZ: .skip 4096        # Buffer para armazenar os pesos (td em int)
VETOR_ATIVACAO_0: .skip 400     # Buffer para armazenar o vetor de ativação c - 1
VETOR_ATIVACAO_1: .skip 400     # Buffer para armazenar o vetor de ativação c
NUMERO_CAMADAS: .skip 4
VETOR_FINAL: .skip 12           # Buffer para armazenar o vetor final (3 tipos de plantas)
OUTPUT: .skip 4                 # Buffer para armazenar o index da planta escolhida (0, 1 ou 2)

.text
.globl _start
# -- _start --
# a0 = código de saída do programa
_start:
    jal main
    li a7, 93
    ecall

# -- inicialização --
ler_input:
    la a0, 0
    li a7, 63
    la a1, INPUT_BUFFER
    li a2, 8192
    ecall
    ret

# -- main --
main:
    addi sp, sp, -16 # Aloca espaço na pilha
    sw ra, 12(sp)    # Salva o endereço de retorno

    # Lê o imput 
    jal ler_input

    # ---------- Processamento da entrada -----------

    # Parsing da primeira linha
    la a0, input_buffer
    jal parse_arquitetura
    
    # Parsing da segunda linha
    jal parse_pesos

    # Parsing da terceira linha
    jal parse_vetor_inicial

    # ----------- Execução da rede neural --------------

    # Todas as variáveis globais devem estar preenchidas exceto VETOR_ATIVACAO_1
    jal irisnet

    # ----------- Impressão do resultado -------------

    # Acha o índice do maior valor no vetor de ativação final
    jal max

    # Escreve o resultado na saída padrão
    jal escrever_resultado

    # -------------- Finalização -----------------

    lw ra, 12(sp)   # Restaura o endereço de retorno
    addi sp, sp, 16 # Desaloca espaço na pilha
    li a0, 0        # retorna 0
    ret

# ------------------------------------------------------------------------------
# Função: ler_prox_int
# Descrição: Lê um número inteiro (positivo ou negativo) de uma string.
# Argumentos:
#   a0: Ponteiro para a string (será atualizado).
# Retorno:
#   a0: Ponteiro para depois do número lido.
#   a1: O número inteiro lido.
# ------------------------------------------------------------------------------
ler_prox_int:
    li t0, 0          # Inicializa o número lido como 0
    li t1, 1          # Inicializa o sinal como positivo (-1 = negativo)
    li t2, 10         # Inicializa a base decimal
pular_caracteres:
    lb t3, 0(a0)
    li t4, 45                       # Código ASCII para '-'
    beq t3, t4, sinal_negativo      # Se for '-', trata como negativo
    li t4, 48                       # Código ASCII para '0'
    blt t3, t4, prox_char   
    li t4, 57                       # Código ASCII para '9'
    bgt t3, t4, prox_char           # Se não for entre '0' e '9', pula
    j parse_loop
prox_char:
    addi a0, a0, 1          # Avança o ponteiro
    j pular_caracteres
sinal_negativo:
    li t1, -1               # Define o sinal como negativo
    addi a0, a0, 1          # Avança o ponteiro
parse_loop:
    lb t3, 0(a0)            # Lê o byte atual da string

    li t4, 48               # Código ASCII para '0'
    blt t3, t4, parse_end   # Se for menor que '0', termina o parsing
    li t4, 57               # Código ASCII para '9'
    bgt t3, t4, parse_end   # Se for maior que '9', termina o parsing

    addi t3, t3, -48        # Converte de ASCII para inteiro

    mul t0, t0, t2          # Multiplica o número atual por 10
    add t0, t0, t3          # Adiciona o dígito lido

    addi a0, a0, 1          # Avança o ponteiro
    j parse_loop            # Continua lendo o próximo dígito

parse_end:
    mul t0, t0, t1
    mv a1, t0               # Armazena o número lido em a1
    ret
# ------------------------------------------------------------------------------
# Função: parse_architecture
# Descrição: Analisa a primeira linha da entrada para extrair os tamanhos das camadas.
# Argumentos:
#   a0: Ponteiro para a string de entrada.
# Retorno/Efeitos:
#   Atualiza o vetor TAM_CAMADAS com os tamanhos das camadas.
#   Atualiza NUMERO_CAMADAS com o número de camadas.
#   a0: Ponteiro para a próxima linha da entrada.
# ------------------------------------------------------------------------------
parse_arquitetura:
    addi sp, sp, -16  # Aloca espaço na pilha
    sw ra, 12(sp)     # Salva o endereço de retorno
    sw s0, 8(sp)      # Salva o contador de camadas
    sw s1, 4(sp)      # Salva o ponteiro para o Array de camadas

    la s1, TAM_CAMADAS  # Ponteiro para o vetor de tamanhos das camadas
    li s0, 0            # Inicializa o contador de camadas

parse_arq_loop:
    jal ler_prox_int  # Lê o próximo inteiro
    sw a1, 0(s1)      # Armazena o tamanho da camada atual
    addi s1, s1, 4    # Avança para o próximo espaço no vetor
    addi s0, s0, 1    # Incrementa o contador de camadas

    # Verifica se tem mais números na linha
    lb t0, 0(a0)                # Lê o próximo caractere
    li t1, 44                   # Código ASCII para ','
    beq t0, t1, parse_arq_loop  # Se for vírgula, continua lendo

prox_linha:
    li t1, 10                   # Código ASCII para '\n'
    lb t0, 0(a0)                # Lê o próximo caractere
    beq t0, t1, fim_parse_arq   # Se for nova linha, termina o parsing
    addi a0, a0, 1              # Avança o ponteiro
    j prox_linha

fim_parse_arq:
    addi a0, a0, 1          # Avança o ponteiro para pular o '\n'
    la t0, NUMERO_CAMADAS   # Ponteiro para o número de camadas
    sw s0, 0(t0)            # Armazena o número de camadas

    lw ra, 12(sp)       # Restaura o endereço de retorno
    lw s0, 8(sp)        # Restaura o contador de camadas
    lw s1, 4(sp)        # Restaura o ponteiro para o Array de camadas
    addi sp, sp, 16     # Desaloca espaço na pilha
    ret                 # Retorna para o chamador
# ------------------------------------------------------------------------------