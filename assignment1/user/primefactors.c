#include "kernel/types.h"
#include "user/user.h"

int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};

void factors(int n, int i) {
    if(n==1)
        return;
    
    int fd1[2], fd2[2], msg, n1;
    if(pipe(fd1) < 0) {
        printf("Error in pipe 1\n");
        exit(0);
    }
    if(pipe(fd2) < 0) {
        printf("Error in pipe 2\n");
        exit(0);
    }
    int p = fork();
    if(p > 0){
        n1 = n;
        while(n1 % primes[i] == 0){
            n1 = n1 / primes[i];
        }
        msg = p;
        write(fd1[1], &n1, sizeof(n1));
        write(fd2[1], &msg, sizeof(msg));
        wait(0);
        close(fd1[0]);
        close(fd1[1]);
        close(fd2[0]);
        close(fd2[1]);
    }
    else if(p == 0){
        int n2=n;
        if(n % primes[i] == 0){
            read(fd1[0], &n1, sizeof(n1));
            read(fd2[0], &msg, sizeof(msg));
            n2 = n1;
            while(n1*primes[i] <= n){
                printf("%d, ",primes[i]);
                n1 = n1*primes[i];
            }
            printf("[%d]\n",msg);
        }
        close(fd1[0]);
        close(fd1[1]);
        close(fd2[0]);
        close(fd2[1]);
        factors(n2,i+1);
    }
}

int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    if(n < 2 || n > 100) {
        printf("Number not in the range [2, 100]. Aborting...\n");
        exit(0);
    }
    factors(n, 0);
    exit(0);
}