
// int read(int __fd, const void *__buf, int __n) {
//     int ret_val;
//     __asm__ __volatile__(
//         "mv a0, %1    # file descriptor\n"
//         "mv a1, %2    # buffer \n"
//         "mv a2, %3    # size \n"
//         "li a7, 63    # syscall read (63) \n"
//         "ecall        # invoke syscall \n"
//         "mv %0, a0    # move return value to ret_val\n"
//         : "=r"(ret_val) // Output list
//         : "r"(__fd), "r"(__buf), "r"(__n) // Input list
//         : "a0", "a1", "a2", "a7"
//     );
//     return ret_val;
// }

// void write(int __fd, const void *__buf, int __n) {
//     __asm__ __volatile__(
//         "mv a0, %0    # file descriptor\n"
//         "mv a1, %1    # buffer \n"
//         "mv a2, %2    # size \n"
//         "li a7, 64    # syscall write (64) \n"
//         "ecall"
//         : // Output list
//         : "r"(__fd), "r"(__buf), "r"(__n)   // Input list
//         : "a0", "a1", "a2", "a7"
//     ); 
// }

// void exit(int code) {
//     __asm__ __volatile__(
//         "mv a0, %0    # return code\n"
//         "li a7, 93    # syscall exit (93) \n"
//         "ecall"
//         : // Output list
//         : "r"(code)    // Input list
//         : "a0", "a7"
//     );
// }
#define STDIN_FD 0
#define STDOUT_FD 1
#define INPUT_SIZE 48
#include <stdio.h>


void bin_to_hex (char *num, char *num_hex) {
    int i, j;
    int hex_digit;
    int len = 0;

    //transforma string binário em hexadecimal
    //opera a string de 4 em 4 bits (1 dígito hexadecimal)
    for (i = 31; i >= 0; i -= 4) {
        hex_digit = 0;
        //cicla pelos 4 bits
        for (j = 0; j < 4; j++) {
            //se o bit for 1, adiciona 2^j ao número hexadecimal
            if (i - j >= 0 && num[i - j] == '1') {
                //hex_digit += pow(2, j);
                hex_digit += (1 << j);
            }
        }
        //adiciona o número hexadecimal ao output
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
    num_hex[len] = '\0';
}


void strdec_to_strbin(char num[5], char num_bin[33]) {
    int sign = num[0] == '-' ? -1 : 1;
    int abs_value = (num[1] - '0') * 1000 + (num[2] - '0') * 100 + (num[3] - '0') * 10 + (num[4] - '0');
    int value = sign * abs_value;
    unsigned int u = (unsigned int)value;
    for (int i = 0; i < 32; i++) {
        unsigned int bit = (u >> (31 - i)) & 1;
        num_bin[i] = bit ? '1' : '0';
    }
    num_bin[32] = '\0';
}

void read_to_bin(char n1_bin[], char n2_bin[], char n3_bin[], char n4_bin[], char n5_bin[], char n6_bin[], char n7_bin[], char n8_bin[]){
    //le os números decimais
    char input[INPUT_SIZE] = "-0001 -0001 -0001 -0001 -0001 -0001 -0001 +0000\n";
    // read(STDIN_FD, input, INPUT_SIZE);
    //8 numbers
    char n1_dec[5], n2_dec[5], n3_dec[5], n4_dec[5], n5_dec[5], n6_dec[5], n7_dec[5], n8_dec[5];
    int i = 0, j = 0;
    for (i = 0; i < 5; i++){
        //le os números decimais
        n1_dec[i] = input[j];
        n2_dec[i] = input[j+6];
        n3_dec[i] = input[j+12];
        n4_dec[i] = input[j+18];
        n5_dec[i] = input[j+24];
        n6_dec[i] = input[j+30];
        n7_dec[i] = input[j+36];
        n8_dec[i] = input[j+42];
        j += 1;
    }
    
    //converte os números decimais para binários
    strdec_to_strbin(n1_dec, n1_bin);
    strdec_to_strbin(n2_dec, n2_bin);
    strdec_to_strbin(n3_dec, n3_bin);
    strdec_to_strbin(n4_dec, n4_bin);
    strdec_to_strbin(n5_dec, n5_bin);
    strdec_to_strbin(n6_dec, n6_bin);
    strdec_to_strbin(n7_dec, n7_bin);
    strdec_to_strbin(n8_dec, n8_bin);
}

void xor(char n1_bin[], char n2_bin[], char result_bin[]){
    for (int i = 0; i < 32; i++){
        if (n1_bin[i] == n2_bin[i]){
            result_bin[i] = '0';
        } else {
            result_bin[i] = '1';
        }
    }
    result_bin[32] = '\0';
}

void and(char n1_bin[], char n2_bin[], char result_bin[]){
    for (int i = 0; i < 32; i++){
        if (n1_bin[i] == '1' && n2_bin[i] == '1'){
            result_bin[i] = '1';
        } else {
            result_bin[i] = '0';
        }
    }
    result_bin[32] = '\0';
}

void nand(char n1_bin[], char n2_bin[], char result_bin[]){
    for (int i = 0; i < 32; i++){
        if (n1_bin[i] == '1' && n2_bin[i] == '1'){
            result_bin[i] = '0';
        } else {
            result_bin[i] = '1';
        }
    }
    result_bin[32] = '\0';
}

void or(char n1_bin[], char n2_bin[], char result_bin[]){
    for (int i = 0; i < 32; i++){
        if (n1_bin[i] == '1' || n2_bin[i] == '1'){
            result_bin[i] = '1';
        } else {
            result_bin[i] = '0';
        }
    }
    result_bin[32] = '\0';
}

int main(){
    char n1_bin[33], n2_bin[33], n3_bin[33], n4_bin[33], n5_bin[33], n6_bin[33], n7_bin[33], n8_bin[33];

    read_to_bin(n1_bin, n2_bin, n3_bin, n4_bin, n5_bin, n6_bin, n7_bin, n8_bin);
    //imprime os números binários
    printf("n1_bin: %s\n", n1_bin);
    printf("n2_bin: %s\n", n2_bin);
    printf("n3_bin: %s\n", n3_bin);
    printf("n4_bin: %s\n", n4_bin);
    printf("n5_bin: %s\n", n5_bin);
    printf("n6_bin: %s\n", n6_bin);
    printf("n7_bin: %s\n", n7_bin);
    printf("n8_bin: %s\n", n8_bin);

    char N1[33], N2[33], N3[33], N4[33];
    and(n1_bin, n2_bin, N1);
    or(n3_bin, n4_bin, N2);
    xor(n5_bin, n6_bin, N3);
    nand(n7_bin, n8_bin, N4);
    
    char val_final_str[33];
    int i = 0;
    for (i = 0; i < 8; i++){
        val_final_str[i] = N3[i];
        val_final_str[i+8] = N4[i];
        val_final_str[i+16] = N2[i + 24];
        val_final_str[i+24] = N1[i + 24];
    }
    val_final_str[32] = '\0';
    char val_final_hex[33];
    bin_to_hex(val_final_str, val_final_hex);
    printf("val_final_str: 0x%s\n", val_final_hex);
    
    return 0;
}

// void _start()
// {
//   int ret_code = main();
//   exit(ret_code);
// }
