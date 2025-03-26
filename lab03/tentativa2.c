#define STDIN_FD 0
#define STDOUT_FD 1
#define INPUT_SIZE 33

int read(int __fd, const void *__buf, int __n) {
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1    # file descriptor\n"
        "mv a1, %2    # buffer \n"
        "mv a2, %3    # size \n"
        "li a7, 63    # syscall read (63) \n"
        "ecall        # invoke syscall \n"
        "mv %0, a0    # move return value to ret_val\n"
        : "=r"(ret_val) // Output list
        : "r"(__fd), "r"(__buf), "r"(__n) // Input list
        : "a0", "a1", "a2", "a7"
    );
    return ret_val;
}

void write(int __fd, const void *__buf, int __n) {
    __asm__ __volatile__(
        "mv a0, %0    # file descriptor\n"
        "mv a1, %1    # buffer \n"
        "mv a2, %2    # size \n"
        "li a7, 64    # syscall write (64) \n"
        "ecall"
        : // Output list
        : "r"(__fd), "r"(__buf), "r"(__n)   // Input list
        : "a0", "a1", "a2", "a7"
    ); 
}

void exit(int code) {
    __asm__ __volatile__(
        "mv a0, %0    # return code\n"
        "li a7, 93    # syscall exit (93) \n"
        "ecall"
        : // Output list
        : "r"(code)    // Input list
        : "a0", "a7"
    );
}


void bin_to_dec(char *num, char *num_dec) {
    int decimal_num = 0;
    int base = 1;
    int i;
    for (i = INPUT_SIZE - 2; i >= 0; i--) {
        if (num[i] == '1') {
            decimal_num += base;
        }
        base = base * 2;
    }
    i = 0;
    while (decimal_num != 0) {
        num_dec[i++] = (decimal_num % 10) + '0';
        decimal_num = decimal_num / 10;
    }
    num_dec[i] = '\n';
    for (int j = 0; j < i / 2; j++) {
        char temp = num_dec[j];
        num_dec[j] = num_dec[i - j - 1];
        num_dec[i - j - 1] = temp;
    }
}

void swap_endian(char *num_bin, char *swapped_num) {
    int i;
    for (i = 0; i < 4; i++) {
        for (int j = 0; j < 8; j++) {
            swapped_num[i * 8 + j] = num_bin[(3 - i) * 8 + j];
        }
    }
    swapped_num[INPUT_SIZE - 1] = '\n';
}

void add_one(char *num){
    int carry = 1;
    int i;
    for (i = INPUT_SIZE - 2; i >= 0; i--) {
        if (num[i] == '1' && carry == 1) {
            num[i] = '0';
        } else if (num[i] == '0' && carry == 1) {
            num[i] = '1';
            carry = 0;
        }
    }
}

void invert_bits(char *num) {
    int i;
    for (i = 0; i < INPUT_SIZE - 1; i++) num[i] = num[i] == '0' ? '1' : '0';
    add_one(num);
}

void bin_to_oct (char *num, char *num_oct) {
    int octal_num = 0;
    int base = 1;
    int i;
    int len = ((INPUT_SIZE - 2) / 3) + 1;

    for (i = INPUT_SIZE - 2; i >= 0; i--) {
        if (num[i] == '1') {
            octal_num += base;
        }
        base = base * 2;
        if ((INPUT_SIZE - 2 - i) % 3 == 2 || i == 0) {
            num_oct[(INPUT_SIZE - 2 - i) / 3] = octal_num + '0';
            octal_num = 0;
            base = 1;
        }
    }
    char temp;
    for (i = 0; i < len / 2; i++) {
        temp = num_oct[i];
        num_oct[i] = num_oct[len - i - 1];
        num_oct[len - i - 1] = temp;
    }
    num_oct[len] = '\n';
}

void bin_to_hex (char *num, char *num_hex) {
    int i, j;
    int hex_digit;
    int len = 0;

    for (i = INPUT_SIZE - 2; i >= 0; i -= 4) {
        hex_digit = 0;
        for (j = 0; j < 4; j++) {
            if (i - j >= 0 && num[i - j] == '1') {
                hex_digit += (1 << j);
            }
        }
        if (hex_digit < 10) {
            num_hex[len++] = hex_digit + '0';
        } else {
            num_hex[len++] = hex_digit - 10 + 'a';
        }
    }

    char temp;
    for (i = 0; i < len / 2; i++) {
        temp = num_hex[i];
        num_hex[i] = num_hex[len - i - 1];
        num_hex[len - i - 1] = temp;
    }
    num_hex[len] = '\n';
}

void write_number(char *num, char *prefix, int base, int complemento_dois) {
    char output_buffer[INPUT_SIZE];
    int i;
    for (i = 0; i < INPUT_SIZE; i++) {
        output_buffer[i] = num[i];
    }
    if (complemento_dois && output_buffer[0] == '1' && base == 10) {
        invert_bits(output_buffer);
        write(STDOUT_FD, "-", 1);
    }
    if (base != 2) {
        char num_temp[INPUT_SIZE];
        if (base == 16) {
            bin_to_hex(output_buffer, num_temp); 
        } else if (base == 8) {
            bin_to_oct(output_buffer, num_temp);
        } else if (base == 10) {
            bin_to_dec(output_buffer, num_temp);
        }
        i = 0;
        while (num_temp[i] != '\n') {
            output_buffer[i] = num_temp[i];
            i++;
        }
        output_buffer[i] = '\n';
    }    
    write(STDOUT_FD, (void *) prefix, 2);
    for (i = 0; output_buffer[i] != '\n'; i++) {
        write(STDOUT_FD, (void *) &output_buffer[i], 1);
    }
    write(STDOUT_FD, "\n", 1);
}

int main() {
    char unsigned_val_bin[33], swapped_val_bin[33]; // num[32] = '\n'
    read(STDIN_FD, unsigned_val_bin, 33);
    int i;

    swap_endian(unsigned_val_bin, swapped_val_bin);
    // 1. Decimal complemento de dois
    write_number(unsigned_val_bin, "", 10, 1);
    
    // 2. Decimal não assinado com endianness trocado
    write_number(swapped_val_bin, "", 10, 0);    
    
    // 3. Hexadecimal complemento de dois
    write_number(unsigned_val_bin, "0x", 16, 1);
    
    // 4. Octal complemento de dois
    write_number(unsigned_val_bin, "0o", 8, 1);
    
    // 5. Binário com endianness trocado
    write_number(swapped_val_bin, "0b", 2, 0);
    
    // 6. Decimal (complemento de dois) com endianness trocado
    write_number(swapped_val_bin, "", 10, 1);
    
    // 7. Hexadecimal com endianness trocado
    write_number(swapped_val_bin, "0x", 16, 1);
    
    // 8. Octal com endianness trocado
    write_number(swapped_val_bin, "0o", 8, 1);
    
    return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}