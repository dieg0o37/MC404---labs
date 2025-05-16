
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

# RESULT: CYPHER = Length is the key. Allan Turing
# RESULT: MESSAGE = Modqpufq zae eqge eaztae
# Key: 12
# decrypted message = "Acredite nos seus sonhos"
main:
    jal open_file
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


// write the decrypted message to the canvas
open_file:
    // open image file
    li a7, 1024         # syscall for open file
    la a0, image_path   # file path
    li a1, 2            # RDWR
    li a2, 0            # mode
    ecall
    ret

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
    li a7, 63
    

.bss
header: .skip 13
image_first_half: .skip 2048
image_second_half: .skip 2048

.data
decrypted_message: .asciz "Acredite nos seus sonhos\n"