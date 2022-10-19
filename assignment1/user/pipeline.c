#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

int sz = sizeof(int);

void pipeline(int n, int x){
    if(n == 0){
        return;
    }
    int fd1[2], fd2[2], msg, x1;
    if(pipe(fd1) < 0){
        printf("Error in pipe 1\n");
        exit(0);
    }
    if(pipe(fd2) < 0){
        printf("Error in pipe 2\n");
        exit(0);
    }
    int p = fork();
    if(p > 0){
        msg = p;
        write(fd1[1], &msg, sz);
        wait(NULL);
        read(fd2[0], &x1, sz);
        close(fd1[0]);
        close(fd1[1]);
        close(fd2[0]);
        close(fd2[1]);
        pipeline(n-1, x1);

    }
    else if(p == 0){
        read(fd1[0], &msg, sz);
        x1 = msg + x;
        printf("%d: %d\n", msg, x1);
        write(fd2[1], &x1, sz);
        close(fd1[0]);
        close(fd1[1]);
        close(fd2[0]);
        close(fd2[1]);
    }
    
}

int main(int argc, char* argv[]){
    if(argc != 3){
        printf("Number of arguments is not equal to 2. Try again.\n");
        exit(0);
    }
    int n = atoi(argv[1]);
    int x = atoi(argv[2]);
    pipeline(n,x);
    exit(0);
}