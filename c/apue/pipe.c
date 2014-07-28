#include <stdio.h>
#include <unistd.h>

#define MAXLINE 128

int main(int argc, char * argv[])
{
    int fd[2];
    int error;
    pid_t pid;
    char buffer[MAXLINE];
    int n;

    error = pipe(fd);
    if(error != 0)
    {
        printf("pipe create failed!\n");
        return -1;
    }

    pid = fork();
    if(pid < 0)
    {
        printf("create child process failed.\n");
        return -1;
    }
    else if(pid > 0)    //parent process
    {

        close(fd[0]);
        write(fd[1], "hello,world.\n", 14);
        close(fd[1]);
        wait(NULL);
    }
    else    //child process
    {
        close(fd[1]);
        n = read(fd[0], buffer, MAXLINE);
        write(STDOUT_FILENO, buffer, n);
        close(fd[0]);
    }

    return 0;
}


    
