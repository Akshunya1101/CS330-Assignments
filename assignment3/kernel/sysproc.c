#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "condvar.h"
#include "proc.h"
#include "barrier.h"
#include "bufferelem.h"
#include "semaphore.h"


struct barrier barriers[10];

//global variables for condprodconstest
#define SIZE 20
struct buffer_elem buffer[SIZE];
int tail, head;
struct sleeplock lock_delete, lock_insert, lock_print;

//global variables for semprodconstest
#define N 20
int sem_buffer[N];
int nextp, nextc;
struct sem_t pro, con, empty, full;

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_getppid(void)
{
  if (myproc()->parent) return myproc()->parent->pid;
  else {
     printf("No parent found.\n");
     return 0;
  }
}

uint64
sys_yield(void)
{
  yield();
  return 0;
}

uint64
sys_getpa(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
}

uint64
sys_forkf(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return forkf(x);
}

uint64
sys_waitpid(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if (x == -1) return wait(p);
  if ((x == 0) || (x < -1)) return -1;
  return waitpid(x, p);
}

uint64
sys_ps(void)
{
   return ps();
}

uint64
sys_pinfo(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
  return pinfo(x, p);
}

uint64
sys_forkp(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return forkp(x);
}

uint64
sys_schedpolicy(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return schedpolicy(x);
}

uint64 
sys_barrier(void)
{

  int barrier_instance_no, barrier_id, n;
  if(argint(0, &barrier_instance_no) < 0){
    return -1;
  }

  if(argint(1, &barrier_id) < 0){
    return -1;
  }

  if(argint(2, &n) < 0){
    return -1;
  }

  if(barriers[barrier_id].counter == -1){
    printf("Element with given barrier array id is not allocated\n");
    return -1;
  }

  barriers[barrier_id].counter++ ;

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barrier_instance_no, barrier_id);


  if(barriers[barrier_id].counter != n){
    cond_wait(&barriers[barrier_id].cv, &barriers[barrier_id].lock);
  }
  else{
    barriers[barrier_id].counter = 0;
    cond_broadcast(&barriers[barrier_id].cv);
  }

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barrier_instance_no, barrier_id);
  
  return 0;
}

uint64 
sys_barrier_alloc(void)
{
    for(int i=0; i<10; ++i){
      acquiresleep(&barriers[i].lock);
      if(barriers[i].counter == -1){
        barriers[i].counter = 0;
        releasesleep(&barriers[i].lock);
        return i;
      }
      releasesleep(&barriers[i].lock);
    } 
  return -1;
}

uint64 
sys_barrier_free(void)
{
   int barrier_id;
   if(argint(0, &barrier_id) < 0){
    return -1;
   }
   barriers[barrier_id].counter = -1;
   initsleeplock(&barriers[barrier_id].lock, "barrier_lock");
   cond_init(&barriers[barrier_id].cv);

   return 0;

}

uint64
sys_buffer_cond_init(void)
{
  tail = 0;
  head = 0;
  initsleeplock(&lock_delete, "delete");
  initsleeplock(&lock_insert, "insert");
  initsleeplock(&lock_print, "print");
  for (int i = 0; i < SIZE; i++) {
    buffer[i].x = -1;
    buffer[i].full = 0;
    initsleeplock(&buffer[i].lock, "buffer_lock");
    cond_init(&buffer[i].inserted);
    cond_init(&buffer[i].deleted);
  }
  return 0;
}

uint64
sys_cond_produce(void)
{
  int val;
  if(argint(0, &val) < 0) return -1;
  int index;
  acquiresleep(&lock_insert);
  index = tail;
  tail = (tail + 1) % SIZE;
  releasesleep(&lock_insert);
  acquiresleep(&buffer[index].lock);
  while(buffer[index].full)
    cond_wait(&buffer[index].deleted, &buffer[index].lock);
  buffer[index].x = val;
  buffer[index].full = 1;
  cond_signal(&buffer[index].inserted);
  releasesleep(&buffer[index].lock);
  return 0;
}

uint64
sys_cond_consume(void)
{
  int index, v;
  acquiresleep(&lock_delete);
  index = head;
  head = (head + 1) % SIZE;
  releasesleep(&lock_delete);
  acquiresleep(&buffer[index].lock);
  while (!buffer[index].full)
    cond_wait(&buffer[index].inserted, &buffer[index].lock);
  v = buffer[index].x;
  buffer[index].full = 0;
  cond_signal(&buffer[index].deleted);
  releasesleep(&buffer[index].lock);
  acquiresleep(&lock_print);
  printf("%d ", v);
  releasesleep(&lock_print);
  return v;
}

uint64
sys_buffer_sem_init(void)
{
  nextp = 0;
  nextc = 0;
  sem_init(&pro, 1);
  sem_init(&con, 1);
  sem_init(&empty, N);
  sem_init(&full, 0);
  return 0;
}

uint64
sys_sem_produce(void)
{
  int val;
  if(argint(0, &val) < 0) return -1;
  sem_wait(&empty);
  sem_wait(&pro);
  sem_buffer[nextp] = val;
  nextp = (nextp + 1)%N;
  sem_post (&pro);
  sem_post (&full);
  return 0;
}

uint64
sys_sem_consume(void)
{
  int v;
  sem_wait (&full);
  sem_wait (&con);
  v = sem_buffer[nextc];
  nextc = (nextc+1)%N;
  sem_post (&con);
  sem_post (&empty);
  acquiresleep(&lock_print);
  printf("%d ", v);
  releasesleep(&lock_print);
  return v;
}