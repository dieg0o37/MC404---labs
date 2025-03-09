#include "calculadora.h"
#include "funcoes-risc-v.h"

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

int main () {
    char input_buffer[6];
    read(STDIN_FD, input_buffer, INPUT_SIZE); //read input

    int n1 = (int)(input_buffer[0] - 48);
    int n2 = (int)(input_buffer[4] - 48);
    char operador = input_buffer[2];
    int resultado = operacao(operador, n1, n2);

    write(STDOUT_FD, &resultado, 4);

    return 0;
}

int operacao(char operador, int n1, int n2){
    switch (operador)
    {
    case '+':
        return (n1 + n2);
        break;
    case '-':
        return (n1 - n2);
        break;
    case '*':
        return (n1 * n2);
        break;
    default:
        break;
    }
    return 0;
}