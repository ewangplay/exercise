#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

static int a = 3;

void * thread_func(void * arg);

int main(int argc, char * argv[])
{
    pthread_t  ptid;
    int error;
    void * ret_val;

    a = 4;

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
        reutrn -2;
    }

    printf("successful to create thread!\n");
    return 0;
}

void * thread_func(void * arg)
{
    printf("enter new thread.\n");

    printf("a = %d\n", a);

    printf("exit new thread.\n");

    return (void *)0;
}

