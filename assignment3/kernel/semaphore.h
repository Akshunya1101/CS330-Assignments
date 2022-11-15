#ifndef SEMAPHORE_H
#define SEMAPHORE_H

#include "sleeplock.h"
#include "condvar.h"
struct sem_t {
int value;
struct sleeplock lock; 
struct cond_t cv;
};

#endif