#include <stdio.h>

#define MEMINFO "cat /proc/meminfo"
#define MAXLINE 512

int main(int argc, char * argv[])
{
    FILE * fpR = NULL;
    char buffer[MAXLINE];

    fpR = popen(MEMINFO, "r");
    if(NULL == fpR)
    {
        printf("failed to read file.\n");
        return -1;
    }

    while(fgets(buffer, MAXLINE, fpR) != NULL)
    {
        printf("%s", buffer);
        if(ferror(fpR))
        {
            printf("error occurs when transfer data.\n");
            return -1;
        }
    }

    pclose(fpR);

    return 0;
}


    
