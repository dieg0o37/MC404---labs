
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
decrypted_message: .asciz "Acredite nos seus sonhos"

.bss
image_part: .skip 4096
header: .skip 13
image_rgba: .skip 4
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
    
    jal extract_message

    jal set_canvas_size

    jal copy_image

    j exit


open_file:
    // open image file
    li a7, 1024         # syscall for open file
    la a0, image_path   # file path
    li a1, 2            # RDWR
    li a2, 0            # mode
    ecall
    ret

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

# RESULT: CYPHER = Length is the key. Allan Turing

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

# RESULT: MESSAGE = Modqpufq zae eqge eaztae

# Key: 12
# decrypted message = "Acredite nos seus sonhos"

set_canvas_size:
    li a7, 2201
    li a0, 64
    li a1, 64
    ecall
    ret

// reads the image byte by byte until leaving 192 bytes from the end of the image unread
// and copy it to the canvas
// syscall: setPixel 2200
// a0 = pixel x coordinate
// a1 = pixel y coordinate
// a2 = value
copy_image:
    addi sp, sp, -32
    sw ra, 0(sp)

    li a7, 1024         # syscall for open file
    la a0, image_path   # file path
    li a1, 2            # RDWR
    li a2, 0            # mode
    ecall

    sw a0, 4(sp)
    li a7, 63
    li a2, 13
    la a1, header
    ecall

    li t3, 0                # X
    li t4, 0                # Y

    lw a0, 4(sp)
    li a7, 63
    li a2, 4096
    la a1, image_part
    ecall

    li t1, 4096
    la t0, image_part       
    la t5, image_rgba
    copy_loop:
        lbu t2, 0(t0)        # ler byte 
        addi t0, t0, 1      # prox byte
        addi t1, t1, -1     # -1 do contador


        li a0, 255
        mv a1, t1

        sw t0, 4(sp)    # 8
        sw t1, 8(sp)    # 12
        sw t2, 12(sp)    # 16
        sw t3, 16(sp)    # 20
        sw t4, 20(sp)    # 24
        sw t5, 24(sp)    # 28

        li t2, 192
        bgt t1, t2, no_message
        # a0 = current byte
        # a1 = contador (0 - 191)
        jal correct_byte

        no_message:
        lw t5, 24(sp)
        lw t4, 20(sp)
        lw t3, 16(sp)
        lw t2, 12(sp)
        lw t1, 8(sp)
        lw t0, 4(sp)
                
        sb t2, 1(t5)
        sb t2, 2(t5)
        sb t2, 3(t5)
        //li t2, 255
        sb a0, 0(t5)
                
        lw a2, 0(t5)
        li a7, 2200
        mv a0, t3
        mv a1, t4
        ecall

        bge zero, t1, break # se contador <= 0 break

        li t2, 64
        addi t3, t3, 1
        beq t3, t2, 1f 

        j copy_loop
        1:
            li t3, 0
            addi t4, t4, 1
            j copy_loop
        break:
            lw ra, 0(sp) 
            addi sp, sp, 32
            ret
# a0 = current byte
# a1 = contador (0 - 191)
correct_byte:
    la t0, decrypted_message    # carrega msg decriptografada
    li t1, 191                  
    li t6, -1
    mul a1, a1, t6
    add t1, t1, a1              # 191 - contador = index_rel (ex: 191 - 190 = 1)

    li t3, 8                    
    div t2, t1, t3              # index_atual = index_rel//8 (ex: 1//8 = 0)
    rem t1, t1, t3              # index_bit = index_relmod8 (ex: 1mod8 = 1)

    # t2 = index do byte a ser copiado
    add t0, t0, t2              # ajusta a posição de leitura (ex: 0 + 0 = 0)

    li t3, -128                 # bit mask (0b10000000)
    srl t3, t3, t1              # ajusta a posição da mask (0b10000000 >> 1 = 0b01000000)

    lb t4, 0(t0)                # carrega o byte atual da msg (ex: 01000001)
    and t4, t4, t3              # separa o bit atual  (ex: 0b01000001 and 0b01000000 = 0b01000000)

    li t3, 7
    mul t1, t1, t6                    
    add t3, t3, t1              # 7 - index_rel (ex: 7 - 1 = 6)             
    srl t4, t4, t3              # coloca o bit atual na direita (ex: 0b01000000 >> 6 = 0b00000001)

    # Atualizar o byte atual: 0b011111111
    sub a0, a0, t4              # ex: 0b011111111 - 0b00000001 = 0b011111110

    ret
