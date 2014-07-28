#include <stdio.h>

#define PAGER "${PAGER:-more}"

#define MAXLINE 512

int main(int argc, char * argv[])
{
    char buffer[MAXLINE] = {0};
    FILE * fpR = NULL, *fpW = NULL;
    int n; 

    if(argc != 2)
    {
        printf("usage: a.out filename\n");
        return -1;
    }

    fpR = fopen(argv[1], "r");
    if(NULL == fpR)
    {
        printf("failed to read file: %s", argv[1]);
        return -1;
    }
    
    fpW = popen(PAGER, "w");
    if(NULL == fpW)
    {
        printf("failed to open pipe.\n");
        return -1;
    }

    while(fgets(buffer, MAXLINE, fpR) != NULL)
    {
        fputs(buffer, fpW);
        if(ferror(fpR) || ferror(fpW))
        {
            printf("error occurs when transfer data.\n");
            return -1;
        }
    }

    pclose(fpW);

    fclose(fpR);
    return 0;
}


    
