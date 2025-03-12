#define INPUT_SIZE 6

#define STDIN_FD  0
#define STDOUT_FD 1

/* read
 * Parâmetros:
 *  __fd:  file descriptor do arquivo a ser lido.
 *  __buf: buffer para armazenar o dado lido.
 *  __n:   quantidade máxima de bytes a serem lidos.
 * Retorno:
 *  Número de bytes lidos.
 */
int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)                   // Output list
    : "r"(__fd), "r"(__buf), "r"(__n) // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}
/* write
 * Parâmetros:
 *  __fd:  files descriptor para escrita dos dados.
 *  __buf: buffer com dados a serem escritos.
 *  __n:   quantidade de bytes a serem escritos.
 * Retorno:
 *  Número de bytes efetivamente escritos.
 */
void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}
void exit(int code){
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
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

// n1, n2 estão entre 0 e 9
// operador é um dos caracteres '+', '-', '*'
// input = "n1 op n2\n"
// output = "resultado\n"
// resultado é um número entre 0 e 9 (1 dígito)
int main () {
    int n1, n2, resultado;
    char operador;
    char input[INPUT_SIZE], output[2];

    read(STDIN_FD, (void *) input, INPUT_SIZE);
    n1 = input[0] - '0';
    operador = input[2];
    n2 = input[4] - '0';
    resultado = operacao(operador, n1, n2);
    output[0] = resultado + '0';
    output[1] = '\n';
    write(STDOUT_FD, (void *) output, 2);

    
    return 0;
}

void _start() {
  int ret_val = main();
  exit(ret_val);
}