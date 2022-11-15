#ifndef BARRIER_H
#define BARRIER_H

#include "condvar.h"
#include "types.h"

struct barrier {
    int counter;
    struct sleeplock lock;
    struct cond_t cv;
};

#endif