#include "kernel/types.h"
#include "user/user.h"

int main() {
    printf("%d", uptime());
    return 0;
}