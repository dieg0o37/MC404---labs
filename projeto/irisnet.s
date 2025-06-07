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
