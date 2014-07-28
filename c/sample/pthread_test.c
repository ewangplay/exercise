#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

int retv = 0;

void * thread_func(void * arg);

int main(int argc, char * argv[])
{
    pthread_t  ptid;
    int error;
    void * ret_val;

    error = pthread_create(&ptid, NULL, thread_func, NULL);
    if(error != 0)
    {
        printf("failed to create thread!\n");
        return -1;
    }

    error = pthread_join(ptid, &ret_val);
    if(error != 0)
    {
        printf("failed to wait for thread termination.\n");
        return -2;
    }

    printf("successful to create thread!\n");

    printf("thread reutrn value is: %d\n", *((int *)ret_val));

    return 0;
}

void * thread_func(void * arg)
{
    int i;

    printf("enter new thread.\n");

    i = 0;
    while(i < 10)
    {
        printf("%d\n", i);
        i++;
        sleep(1);
    }
    
    printf("exit new thread.\n");
    retv = i;
    return (void *)&retv;
}

