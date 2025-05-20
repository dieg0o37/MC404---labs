
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

.text
.globl _start

_start: 
    j main

exit:
    li a7, 93
    li a0, 0
    ecall

# RESULT: CYPHER = Length is the key. Allan Turing
# RESULT: MESSAGE = Modqpufq zae eqge eaztae
# Key: 12
# decrypted message = "Acredite nos seus sonhos"
main:
    // configure the canvas
    jal set_canvas_size
    // read every byte of the image except the header and copy it to the canvas
    jal copy_image
    // write the decrypted message to the last 192 LSB bytes of the canvas
    jal write_decrypted_message

    j exit


# decrypted message in binary = 
# 01000001 01100011 01110010 01100101
# 01100100 01101001 01110100 01100101 
# 00100000 01101110 01101111 01110011 
# 00100000 01110011 01100101 01110101
# 01110011 00100000 01110011 01101111 
# 01101110 01101000 01101111 01110011

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
    li a7, 1024         # syscall for open file
    la a0, image_path   # file path
    li a1, 2            # RDWR
    li a2, 0            # mode
    ecall

    li a7, 63
    li a2, 13
    la a1, header
    ecall

    li t3, 0                # X
    li t4, 0                # Y

        li a7, 63
        li a2, 4096
        la a1, image_part
        ecall

        li t1, 4096
        la t0, image_part       # 8 total parts
        la t5, image_rgba
            copy_loop:
                lb t2, 0(t0)        # ler byte 
                addi t0, t0, 1      # prox byte
                addi t1, t1, -1     # -1 do contador

                sb t2, 0(t5)
                sb t2, 1(t5)
                sb t2, 2(t5)
                li t2, 255
                sb t2, 3(t5)
                
                mv a2, t5

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
                    ret
    
write_decrypted_message:
ret
