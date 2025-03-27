#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    uint64 ms = memsize();
    printf("start: %d\n",(int)ms);
    
    int* temp = (int*)malloc(20000);
    ms = memsize();
    printf("after adding: %d\n",(int)ms);

    free(temp);
    ms = memsize();
    printf("after freeing: %d\n",(int)ms);


    exit(0);
}
