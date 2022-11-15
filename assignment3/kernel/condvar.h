#ifndef CONDVAR_H
#define CONDVAR_H

#include "sleeplock.h"

struct cond_t {
    struct sleeplock lk;
};

#endif