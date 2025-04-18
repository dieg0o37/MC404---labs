/*
    input: 
        formatted as: int int\n
        - 2 integers (CA1, CO1) from (1-99)
        - 1 integer (CO2) from (1-99)
    output:
        formatted as: int\n
        - 1 integer CA2 = CA1 * CO2 / CO1 from (1-99)
*/

.globl _start
_start:
    jal main
exit:
    li a0, 0
    li a7, 93       # syscall exit
    ecall

main:
    jal read_triangulo_maior
    jal read_triangulo_menor

    # extract CA1 and CO1 from triangulo_maior
    jal parse_maior

    jal parse_menor
    
    mul s4, s1, s3  # CA1 * CO2
    div s5, s4, s2  # CA2 = (CA1 * CO2) / CO1

    la t0, result
    sw s5, 0(t0)  # store CA2 in result
    li t1, 0x0A
    sb t1, 2(t0)  # store newline in result
    jal write


read_triangulo_maior:
    li a7, 63       # syscall read
    li a0, 0        # stdin
    la a1, triangulo_maior
    li a2, 6        # max bytes to read
    ecall
    ret

read_triangulo_menor:
    li a7, 63       # syscall read
    li a0, 0        # stdin
    la a1, triangulo_menor
    li a2, 3        # max bytes to read
    ecall
    ret

/*  
    input:
        t0 = &(triangulo_maior)
    output:
        s1 = CA1
        s2 = CO1
*/
parse_maior:
    la t0, triangulo_maior
    //no max 4 numeros
    lb t1, 0(t0)     # garantido ser 1 digito
    lb t2, 1(t0)     # pd ser 1 digito ou 1 espaco
    lb t3, 2(t0)     # pd ser 1 digito ou 1 espaco
    lb t4, 3(t0)     # pd ser 1 digito ou 1 newline
    lb t5, 4(t0)     # pd ser 1 digito ou 1 newline
    # 5(t0) garantdo ser 1 newline

    li t6, 0x0A # newline
    beq t4, t6, caso1
    li t6, 0x20 # espaco
    beq t2, t6, caso2
    beq t3, t6, caso3
    j caso4


    // 4 casos: 
    // 1 digito com 1 digito
    // 1 digito com 2 digitos
    // 2 digitos com 1 digito
    // 2 digitos com 2 digitos
caso1: // if t4 == '\n'
    mv s1, t1 # CA1
    mv s2, t3 # CO1
    ret
caso2: // if t2 == ' '
    mv s1, t1 # CA1
    li t2, 10
    mul  t0, t3, t2
    add s2, t0, t4
    ret
caso3:  // if t3 == ' '
    mv s2, t4 # CO1
    li t3, 10
    mul t0, t3, t1
    add s1, t0, t2
    ret
caso4:  // else
    li t3, 10
    mul t1, t1, t3
    add s1, t1, t2

    mul t1, t5, t3
    add s2, t1, t4
    ret
        
/*
    input:
        t0 = &(triangulo_menor)
    output:
        s3 = CO2
*/
parse_menor:
    la t0, triangulo_menor
    lb t1, 0(t0)     # garantido ser 1 digito (decimal ou unidade)
    lb t2, 1(t0)     # pd ser 1 digito ou 1 newline
    # 2(t0) garantido ser 1 newline

    li t3, 0x0A
    beq t2, t3, caso1_menor
    j caso2_menor
    ret

caso1_menor:
    mv s3, t1 # CO2
    ret

caso2_menor:
    li t3, 10
    mul t1, t1, t3
    add s3, t1, t2 # CO2
    ret
write:
    li a7, 64       # syscall write
    li a0, 1        # stdout
    la a1, result
    li a2, 3        # write 3 bytes (2 or 1 digits + newline)
    ecall
    ret

.bss 
triangulo_maior: .skip 6 // "CA1 CO1\n" (up to 10 bytes including newline)
triangulo_menor: .skip 3 // "CO2\n" (up to 5 bytes including newline)
result: .skip 3          // CA2'\n'
