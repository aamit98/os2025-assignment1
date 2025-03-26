#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    uint64 ms = memsize();
    printf("start: %llu\n",(unsigned long long)ms);
    
    int* temp = (int*)malloc(20000);
    ms = memsize();
    printf("after adding: %llu\n",(unsigned long long)ms);

    free(temp);
    ms = memsize();
    printf("after freeing: %llu\n",(unsigned long long)ms);


    exit(0);
}
