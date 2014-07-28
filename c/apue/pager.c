#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>

#define DEFAULT_PAGER "/bin/more"

#define MAXLINE 512

int main(int argc, char * argv[])
{
    int fd[2];
    int error;
    pid_t pid;
    char buffer[MAXLINE] = {0};
    char * pager, *args;
    FILE * fp = NULL;
    int n; 

    if(argc != 2)
    {
        printf("usage: a.out filename\n");
        return -1;
    }

    fp = fopen(argv[1], "r");
    if(NULL == fp)
    {
        printf("failed to read file: %s", argv[1]);
        return -1;
    }
    
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
        while(fgets(buffer, MAXLINE, fp) != NULL)
        {
            n = strlen(buffer);
            if(write(fd[1], buffer, n) != n)
            {
                printf("write erorr to pipe.\n");
                exit(-1);
            }
        }
        /*
        while(!feof(fp))
        {
            n = fread(buffer, 1, MAXLINE, fp);
            if(write(fd[1], buffer, n) != n)
            {
                printf("write erorr to pipe.\n");
                exit(-1);
            }
            memset(buffer, 0, MAXLINE);
        }
        */

        close(fd[1]);
        wait(NULL);
    }
    else    //child process
    {
        close(fd[1]);

        /* duplicate the fd[0] to STDIN_FILENO */
        if(fd[0] != STDIN_FILENO)
        {
            if(dup2(fd[0], STDIN_FILENO) != STDIN_FILENO)
            {
                printf("failed to duplicate file handle.\n");
                _exit(-1);
            }
            close(fd[0]);
        }

        /* get environment pager */
        if((pager = getenv("PAGER")) == NULL)
        {
            pager = DEFAULT_PAGER;
        }

        if((args = strrchr(pager, '/')) != NULL)
        {
            args++;
        }
        else
        {
            args = pager;
        }

        printf("pager = %s, args = %s\n", pager, args);

        if(execl(pager, args, (char *)0) < 0)
        {
            printf("failed to execute the pager parogram.\n");
            _exit(-1);
        }
    }

    fclose(fp);
    return 0;
}


    
