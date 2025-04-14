/* 1 - A, 2 - B, 3 - C
 Formato da string - "(DD DD) (DD DD) (DD DD)\n" 
 Ya = Yb, Xa = Xc
 cateto1 = Xa - Xb
 cateto2 = Yc - Ya
*/ 
.globl _start
_start:
    jal main
    li a0, 0
    li a7, 93       # syscall exit
    ecall

main:
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)

    jal read

    la t0, input_address

    li t3, 10

    # Xa = s0 = Xc
    lbu t1, 1(t0)   #primeiro digito
    lbu t2, 2(t0)   #segundo digito
    addi t1, t1, -'0' #transformar em inteiro
    addi t2, t2, -'0' #transformar em inteiro
    mul t1, t1, t3 
    add s0, t1, t2  #guardar em s0 

    # Ya = s1 = Yb
    lbu t1, 4(t0)   #primeiro digito
    lbu t2, 5(t0)   #segundo digito
    addi t1, t1, -'0' #transformar em inteiro
    addi t2, t2, -'0' #transformar em inteiro
    mul t1, t1, t3
    add s1, t1, t2  #guardar em s1

    # Xb = s2
    lbu t1, 9(t0)   #primeiro digito
    lbu t2, 10(t0)   #segundo digito
    addi t1, t1, -'0' #transformar em inteiro
    addi t2, t2, -'0' #transformar em inteiro
    mul t1, t1, t3
    add s2, t1, t2  #guardar em s2

    # Yc = s3
    lbu t1, 20(t0)  #primeiro digito
    lbu t2, 21(t0)  #segundo digito
    addi t1, t1, -'0' #transformar em inteiro
    addi t2, t2, -'0' #transformar em inteiro
    mul t1, t1, t3
    add s3, t1, t2  #guardar em s3

    sub s4, s2, s0  # dx = Xb - Xa
    sub s5, s3, s1  # dy = Yc - Ya

    mul s6, s4, s4  # dx_squared
    mul s7, s5, s5  # dy_squared

    add s8, s6, s7  # sum = dx_sq + dy_sq

    mv a0, s8

    jal sqrt        # a0 = sqrt(sum)

    jal to_ascii    # convert to ascii
    jal write

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    addi sp, sp, 36
    ret

read:
    li a0, 0            # stdin
    la a1, input_address
    li a2, 24           # read 24 bytes
    li a7, 63           # syscall read
    ecall
    ret

write:
    li a0, 1            # stdout
    la a1, result
    li a2, 4            # write 4 bytes
    li a7, 64           # syscall write
    ecall
    ret

sqrt:
    beqz a0, sqrt_zero  # se y == 0 => sqrt(0) = 0
    srli t0, a0, 1      # k = y / 2 = t0
    li t1, 10           # contador = 10
sqrt_loop:
    beqz t1, sqrt_end
    beqz t0, zero_k     # se k == 0 => k = 1
    mv t2, a0           # t2 = a0 = sum
    divu t3, t2, t0     # t3 = t2 // k [sum // k]
    add t4, t0, t3      # t4 = t2 + t3 [sum + sum // k]
    srli t4, t4, 1      # t4 = t4 / 2  [(sum + sum // k) / 2]
    mv t0, t4           # k = t4
    addi t1, t1, -1     # decrementa o contador
    j sqrt_loop         
zero_k:
    li t0, 1            # muda k para 1
    addi t1, t1, -1     # decrementa o contador
    j sqrt_loop
sqrt_zero:
    li a0, 0
    ret
sqrt_end:
    mv a0, t0           # k = sqrt(y)
    ret


to_ascii:   
    la t0, result       #carregar endereco de result
    li t1, 100          
    divu t5, a0, t1     # t5 = a0 // 100 => (casa centena)
    remu t3, a0, t1     # t3 = a0 % 100
    li t1, 10
    divu t4, t3, t1     # t4 = (a0 % 100) // 10 => (casa decimal)
    remu t2, t3, t1     # t2 = (a0 % 100) % 10 => (casa unidade)

    addi t5, t5, '0'    # transformar em ascii
    addi t4, t4, '0'    # transformar em ascii
    addi t2, t2, '0'    # transformar em ascii

    sb t2, 2(t0)
    sb t4, 1(t0)
    sb t5, 0(t0)
    li t6, 0x0A         # newline
    sb t6, 3(t0)
    ret


.data
input_address: .skip 0x18  # 24 bytes buffer

.bss
result: .skip 0x4          # 4 bytes buffer


