# FILE THAT FINDS THE MESSAGE AND CYPHER AND PRINTS TO THE TERMINAL
# pgm image format:
# (Total bytes in the header: 13)
# [IMAGE DATA] (4096 bytes)
# Only read first 55 bytes of image.
# byte 0-2: P5\n (3 bytes)
# byte 3-8: 64 64\n (6 bytes)
# byte 9-12: 255\n (4 bytes)
# byte 13-43: ceasers cipher (31 bytes)
# byte 44-67: message to decrypt (24 bytes) 
.data
image_path: .asciz "image.pgm"  # Path to the image file

.bss
image_data: .skip 453
shift_text: .skip 249
message_text: .skip 193

.text
.globl _start

_start: 
    j main

exit:
    li a7, 93
    li a0, 0
    ecall


main:
    jal open_file
    
    // read first 68 bytes = header + cypher shift + message
    jal read_image
    jal extract_cypher
    
    li t0, 10
    sb t0, 0(t1)  # Store a newline character
    jal write_cypher
    
    jal extract_message
    
    li t0, 10
    sb t0, 0(t1)  # Store a newline character
    jal write_message

    j exit

read_image:
    li a7, 63
    la a1, image_data
    li a2, 453        # read 44 bytes (header + cypher shift + message)
    ecall
    ret

/*
    The cypher is coded into the first LSB bit of each of the first 31 bytes of the image.
    The message to decrypt is coded into the first LSB bit of each of the next 24 bytes of the image.
*/
extract_cypher:
    la t0, image_data
    addi t0, t0, 13      # Skip header (13 bytes)
    li t2, 248
    la t1, shift_text
    extract_loop:
        lb t3, 0(t0)          # Load byte from image data
        andi t4, t3, 1        # Extract LSB
        addi t4, t4, 48       # Convert to ASCII ('0' or '1')
        sb t4, 0(t1)          # Store LSB in shift_text
        addi t0, t0, 1        # Move to next byte
        addi t1, t1, 1        # Move to next byte in shift_text
        addi t2, t2, -1       # Decrement counter
        bnez t2, extract_loop # Repeat until 31 bytes processed
    ret

write_cypher:
    li a7, 64               # syscall for write
    li a0, 1                # file descriptor 1 (stdout)
    la a1, shift_text       # buffer to write
    li a2, 249               # write 32 bytes
    ecall
    ret


# RESULT: CYPHER = Length is the key. Allan Turing
open_file:
    // open image file
    li a7, 1024         # syscall for open file
    la a0, image_path   # file path
    li a1, 2            # RDWR
    li a2, 0            # mode
    ecall
    ret

extract_message:
    la t0, image_data
    addi t0, t0, 261      # Skip header + cypher (44 bytes)
    li t2, 192
    la t1, message_text
    message_loop:
        lb t3, 0(t0)          # Load byte from image data
        andi t4, t3, 1        # Extract LSB
        addi t4, t4, 48       # Convert to ASCII ('0' or '1')
        sb t4, 0(t1)          # Store LSB in message_text
        addi t0, t0, 1        # Move to next byte
        addi t1, t1, 1        # Move to next byte in message_text
        addi t2, t2, -1       # Decrement counter
        bnez t2, message_loop # Repeat until 24 bytes processed
    ret

write_message:
    li a7, 64               # syscall for write
    li a0, 1                # file descriptor 1 (stdout)
    la a1, message_text     # buffer to write
    li a2, 193               # write 25 bytes
    ecall
    ret

# RESULT: MESSAGE = Modqpufq zae eqge eaztae


# Key: 12
# decrypted message = "Acredite nos seus sonhos"

# decrypted message in binary = 
# 01000001 01100011 01110010 01100101
# 01100100 01101001 01110100 01100101 
# 00100000 01101110 01101111 01110011 
# 00100000 01110011 01100101 01110101
# 01110011 00100000 01110011 01101111 
# 01101z