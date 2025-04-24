/*
    input: 
        - formatted as: "int int\nint\n"
        - \n could be something else idk LOL
    output:
        formatted as: "int\n"
        - 1 integer CA2 = CA1 * CO2 / CO1 from (1-99)
*/
.global _start

_start:
    j main

exit:
    li a0, 0
    li a7, 93
    ecall

.text
main:
    jal read

    # Parse first number
    la a0, buffer       # Load buffer address into a0
    jal parse_number    # Parse first number
    mv s0, a1           # Store CA1 in s0

    # Parse second number
    jal parse_number
    mv s1, a1           # Store CO1 in s1

    # Parse third number
    jal parse_number
    mv s2, a1           # Store CO2 in s2

    mul s3, s0, s2  # CA1 * CO2
    div s5, s3, s1  # CA2 = (CA1 * CO2) / CO1

    jal to_ascii

    jal write

    j exit

# Function to parse number at current buffer position
# Input: a0 = current buffer position
# Output: a1 = parsed number, a0 updated to position after number
parse_number:
    lbu t0, 0(a0)       # Load first character
    addi t0, t0, -48    # Convert to digit
    lbu t1, 1(a0)       # Check next character
    
    # Check if next character is a digit
    li t2, 48
    blt t1, t2, single_digit # if its before '0'
    li t2, 57
    bgt t1, t2, single_digit # if its after '9'
    
    # Handle two-digit number
    addi t1, t1, -48
    li t3, 10
    mul t0, t0, t3
    add a1, t0, t1
    addi a0, a0, 3      # Advance past two digits
    ret
    
    single_digit:
        mv a1, t0       # Single-digit result
        addi a0, a0, 2  # Advance past one digit
        ret


read:
    # Read input using syscall 63
    li a0, 0            # File descriptor 0 (stdin)
    la a1, buffer       # Load buffer address
    li a2, 16           # Read up to 16 bytes
    li a7, 63           # Syscall number for read
    ecall
    ret

# Input: s5 = inteiro
# Output: Output buffer
to_ascii:
    la t0, output
    li t1, 10
    divu t3, s5, t1     # t3 = CA2 // 10 => (casa decimal)
    remu t2, s5, t1     # t2 = CA2 % 10 => (casa unidade)

    li t1, 0
    li t4, 0x0A         # newline
    beq t1, t3, soh_1

    addi t3, t3, '0'    # transform to ascii
    addi t2, t2, '0'    # transform to ascii

    sb t3, 0(t0)
    sb t2, 1(t0)
    sb t4, 2(t0)
    ret

    soh_1:
        addi t2, t2, '0'
        sb t2, 0(t0)
        sb t4, 1(t0)
        ret

write:
    li a7, 64       # syscall write
    li a0, 1        # stdout
    la a1, output
    li a2, 3        # write 3 bytes (2 or 1 digits + newline)
    ecall
    ret

.data
buffer: .skip 16 # more than enough space. I think   
output: .skip 5 # more than enough