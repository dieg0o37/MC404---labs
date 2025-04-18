/*
    input: 
        formatted as: int int\n
        - 2 integers (CA1, CO1)
        - 1 integer (CO2)
    output:
        formatted as: int\n
        - 1 integer CA2 = CA1 * CO2 / CO1 
*/

.globl _start
_start:
    jal main
    li a0, 0
    li a7, 93       # syscall exit
    ecall

.bss 
triangulo_maior: .skip 6 // CA1 CO1'\n' (up to 10 bytes including newline)
triangulo_menor: .skip 3 // CO2'\n' (up to 5 bytes including newline)
result: .skip 5          // CA2'\n'
