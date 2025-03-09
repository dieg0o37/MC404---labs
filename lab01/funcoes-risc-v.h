#ifndef RISC_V
#define RISC_V

#define STDIN_FD  0
#define STDOUT_FD 1


int read(int __fd, const void *__buf, int __n);

void exit(int code);

void write(int __fd, const void *__buf, int __n);

int read(int __fd, const void *__buf, int __n);

#endif