#include "semaphore.h"
#include "riscv.h"
#include "defs.h"

void sem_init (struct sem_t *z, int value) {
    z->value = value;
    cond_init(&z->cv);
    initsleeplock(&z->lock, "semaphore_lock");
}

void sem_wait (struct sem_t *z) {
acquiresleep (&z->lock);
while (z->value <= 0)
    cond_wait (&z->cv, &z->lock);
z->value--;
releasesleep (&z->lock);
}

void sem_post (struct sem_t *z) {
acquiresleep (&z->lock);
z->value++;
cond_signal (&z->cv);
releasesleep (&z->lock);
}
