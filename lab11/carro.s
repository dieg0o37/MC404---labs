

.text
.globl _start

_start:
    jal main
    li a7, 93
    ecall

main:
    li s0, 0xFFFF0100           # carrega base adress do carro

    li s1, 18
    sb s1, 0x20(s0)             # Gira o volante para a direita (+18)

    li s1, 1
    sb s1, 0x21(s0)             # Acelera o carro
    while_loop:
        li s1, 1
        sb s1, 0x00(s0)         # Liga o GPS
        lb s1, 0x10(s0)         # carrega a coordenada X do carro
        li s2, 40               
        bge s1, s2, while_loop  # Se Pos_x > 40. Espera
    li s1, 0
    sb s1, 0x21(s0)             # Para o carro
    li s1, 1
    sb s1, 0x22(s0)             # Liga o freio de mão
    li a0, 0
    ret