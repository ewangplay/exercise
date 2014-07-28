#include <unistd.h>
#include <stdio.h>

int main() {
    pid_t pid;
    pid = fork();
    if (pid == 0) {
        printf("child [%d]\n", getpid());
        exit(0);
    }
    printf("parent [%d]\n", getpid());
    exit(0);
}

