#include "types.h"
#include "spinlock.h"
#include "condvar.h"
#include "riscv.h"
#include "defs.h"

void cond_wait (struct cond_t *cv, struct sleeplock *lock) {
    condsleep(cv, lock);
    return;
}
void cond_signal (struct cond_t *cv) {
    wakeupone(cv);
    return;
}
void cond_broadcast (struct cond_t *cv) {
    wakeup(cv);
    return;
}