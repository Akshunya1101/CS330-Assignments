#ifndef BUFFERELEM_H
#define BUFFERELEM_H

#include "condvar.h"
#include "types.h"

struct buffer_elem {
   int x;
   int full;
   struct sleeplock lock;
   struct cond_t inserted;
   struct cond_t deleted;
};

#endif