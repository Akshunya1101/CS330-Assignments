#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "barrier.h"
#include "condvar.h"
#include "bufferelem.h"

volatile static int started = 0;

extern int sched_policy;

extern struct barrier barr[10];
extern struct buffer_elem buffer[20];
extern int sem_buffer[20];

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
  if(cpuid() == 0){
    consoleinit();
    printfinit();
    printf("\n");
    printf("xv6 kernel is booting\n");
    printf("\n");
    kinit();         // physical page allocator
    kvminit();       // create kernel page table
    kvminithart();   // turn on paging
    procinit();      // process table
    trapinit();      // trap vectors
    trapinithart();  // install kernel trap vector
    plicinit();      // set up interrupt controller
    plicinithart();  // ask PLIC for device interrupts
    binit();         // buffer cache
    iinit();         // inode table
    fileinit();      // file table
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
      ;
    __sync_synchronize();
    printf("hart %d starting\n", cpuid());
    kvminithart();    // turn on paging
    trapinithart();   // install kernel trap vector
    plicinithart();   // ask PLIC for device interrupts
  }

  sched_policy = SCHED_PREEMPT_RR;

  for (int i = 0; i < 10; i++)
  {
    barr[i].counter = -1;
    initsleeplock(&barr[i].lock, "barrier_lock");
    initsleeplock(&barr[i].cv.lk, "barrier_cv_lock");
  }
  

  scheduler();        
}
