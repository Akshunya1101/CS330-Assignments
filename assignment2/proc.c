#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "procstat.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

extern int SCHED_POLICY, OLD_POLICY;

int curr_batch = 0, net_batch = 0;

uint wait_sum = 0;

int total_burst = 0;
uint max_burst = 0, mi_burst = 0, sum_burst = 0;
uint est_max = 0, mi_est = 0, sum_est = 0;

uint err_burst = 0, err_sum = 0;

uint min_burst = 0;

int min_prio = 0;

int print = 0;

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  uint xticks;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);

  p->ctime = xticks;
  p->stime = -1;
  p->endtime = -1;
  p->start_ticks = 0;
  p->end_ticks = 0;
  p->batch = 0;
  p->estimate = 0;
  p->cpu_usage = 0;
  p->priority = 0;
  p-> prio = 0;
  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the childa
  np->trapframe->a0 = 0;

  // np->batch = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// forkp system call which takes as input the base priority and assigns it to the child created
// Also, prio is added to the proc structure
int
forkp(int prio)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;

  np->prio = prio;
  np->priority = prio;

  if(min_prio == 0){
    min_prio = prio;
  }
  else if(min_prio > prio){
    min_prio = prio;
  }

  curr_batch ++ ;
  net_batch ++;

  np->batch = 1;

  release(&np->lock);

  return pid;
}

int
forkf(uint64 faddr)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;
  // Make child to jump to function
  np->trapframe->epc = faddr;

  // np->batch = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();
  uint xticks;

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  //


  //

  release(&wait_lock);

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);

  p->endtime = xticks;


  uint yticks;
      if (!holding(&tickslock)) {
        acquire(&tickslock);
        yticks = ticks;
        release(&tickslock);
      }
      else yticks = ticks;

      p->end_ticks = yticks;

      if(p->batch == 1){
        curr_batch -- ;
      }

      if(p->batch ==1 && p->end_ticks > p->start_ticks && SCHED_NPREEMPT_SJF){

      if(max_burst < p->end_ticks - p->start_ticks){
        max_burst = p->end_ticks - p->start_ticks;
      }
      if(mi_burst == 0){
        mi_burst = p->end_ticks - p->start_ticks;
      }
      else if(mi_burst > p->end_ticks - p->start_ticks){
        mi_burst = p->end_ticks - p->start_ticks;
      }
      sum_burst += p->end_ticks - p->start_ticks;
      total_burst ++ ;
      
      if(p->estimate > 0){
        err_burst ++ ;
      }
        if(p->estimate > p->end_ticks - p->start_ticks){
          err_sum += p->estimate - (p->end_ticks - p->start_ticks);
        }
        else{
          err_sum += (p->end_ticks - p->start_ticks) - p->estimate;
        }
    }      

  int flag =0 ;
  int minstart = 0, maxend = 0;
  int sum = 0;
  int tot_exec = 0, maxexec = 0, minexec = 0;
  struct proc* p1;
  for(p1 = proc; p1< &proc[NPROC]; p1++){
    if(p1->batch == 1){

      if(p1->state != ZOMBIE){
        flag = 1;
        break;
      }
    
      if(minstart == 0){
        minstart = p1->stime;
      }
      else if(minstart > p1->stime){
        minstart = p1->stime;
      }
      if(maxend < p1->endtime){
        maxend = p1->endtime;
      }
      sum += p1->endtime - p1->ctime;

      if(minexec == 0){
        minexec = p1->endtime;
      }
      if(minexec > p1->endtime){
        minexec = p1->endtime;
      }

      if(maxexec < p1->endtime){
        maxexec = p1->endtime;
      }

      tot_exec += p1->endtime;
    }
  }

      min_burst = 0;
      min_prio = 0;
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
        if(p1->state == RUNNABLE && p1->batch == 1){
          if(SCHED_POLICY == SCHED_NPREEMPT_SJF){
          if(min_burst == 0){
            min_burst = p1->estimate;
          }
          else{
            if(min_burst > p1->estimate){
              min_burst = p1->estimate;
            }
          }
          }
          if(SCHED_POLICY == SCHED_PREEMPT_UNIX){
          if(min_prio == 0){
            min_prio = p1->priority;
          }
          else if(min_prio > p1->priority){
            min_prio = p1->priority;
          }
          }
        }
      }

  

  


   if(curr_batch == 0 && flag !=1){
    printf("Batch execution time: %d\n", maxend - minstart);
    printf("Average turn-around time: %d\n", sum/net_batch);
    printf("Average waiting time: %d\n", wait_sum/net_batch);
    printf("Completion time: avg: %d, max: %d, min: %d\n", tot_exec/net_batch , maxexec, minexec);
    if(SCHED_POLICY == SCHED_NPREEMPT_SJF){
      printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", total_burst, sum_burst/total_burst, max_burst, mi_burst);
      printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", total_burst, sum_est/total_burst, est_max, mi_est);
      printf("CPU burst estimation error: count: %d, avg: %d\n", err_burst, err_sum/err_burst);
    }

  curr_batch = 0; net_batch = 0;

 wait_sum = 0;

 total_burst = 0;
 max_burst = 0; mi_burst = 0; sum_burst = 0;
 est_max = 0; mi_est = 0; sum_est = 0;

 err_burst = 0; err_sum = 0;

 min_burst = 0;

 min_prio = 0;

  }

  

  

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

int
waitpid(int pid, uint64 addr)
{
  struct proc *np;
  struct proc *p = myproc();
  int found=0;

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for child with pid
    for(np = proc; np < &proc[NPROC]; np++){
      if((np->parent == p) && (np->pid == pid)){
	found = 1;
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        if(np->state == ZOMBIE){
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
             release(&np->lock);
             release(&wait_lock);
             return -1;
           }
           freeproc(np);
           release(&np->lock);
           release(&wait_lock);
           return pid;
	}

        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!found || p->killed){
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.

void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  
  c->proc = 0;
  
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) {
      if(SCHED_POLICY != OLD_POLICY){
        OLD_POLICY = SCHED_POLICY;
        break;
      }
    
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        if(p->batch==1){
          if(SCHED_POLICY == SCHED_NPREEMPT_SJF && min_burst < p->estimate && min_burst !=0 ){
          release(&p->lock);
          continue;
        }
        if(SCHED_POLICY == SCHED_PREEMPT_UNIX && min_prio < p->priority && min_prio != 0){
          release(&p->lock);
          continue;
        }
        if(est_max == 0){
            est_max = p->estimate;
          }
          else if(est_max < p->estimate){
            est_max = p->estimate;
          }
          if(mi_est == 0){
            mi_est = p->estimate;
          }
          else if(mi_est > p->estimate){
            mi_est = p->estimate;
          }
          sum_est += p->estimate;
          uint xticks;
        if (!holding(&tickslock)) {
            acquire(&tickslock);
            xticks = ticks;
            release(&tickslock);
        }
        else xticks = ticks;

        p->start_ticks = xticks;

        wait_sum += p->start_ticks - p->end_ticks;
        }
        
        p->state = RUNNING;

        // Beginning of Code Change Area
        // Calling Ticks to get current ticks
        

        // End of code change area

        c->proc = p;
        swtch(&c->context, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
      
      
      
    }
  }
  
}

int 
schedpolicy(int new_sched)
{
  OLD_POLICY = SCHED_POLICY;
  SCHED_POLICY = new_sched;

  return OLD_POLICY;
}


// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;

  // End Ticks of CPU BURST
    uint xticks;
    if (!holding(&tickslock)) {
      acquire(&tickslock);
      xticks = ticks;
      release(&tickslock);
    }
    else xticks = ticks;

    p->end_ticks = xticks;

    p->cpu_usage = p->cpu_usage + SCHED_PARAM_CPU_USAGE;

    if(p->batch == 1 && p->end_ticks > p->start_ticks){
      if(max_burst < p->end_ticks - p->start_ticks){
        max_burst = p->end_ticks - p->start_ticks;
      }
      if(mi_burst == 0){
        mi_burst = p->end_ticks - p->start_ticks;
      }
      else if(mi_burst > p->end_ticks - p->start_ticks){
        mi_burst = p->end_ticks - p->start_ticks;
      }
      sum_burst += p->end_ticks - p->start_ticks;
      total_burst ++ ;

      if(p->estimate){
        err_burst ++ ;
      }
        if(p->estimate > p->end_ticks - p->start_ticks){
          err_sum += p->estimate - (p->end_ticks - p->start_ticks);
        }
        else{
          err_sum += (p->end_ticks - p->start_ticks) - p->estimate;
        }
      

      
      // p->estimate = (p->end_ticks - p->start_ticks) - (SCHED_PARAM_SJF_A_NUMER*(p->end_ticks - p->start_ticks))/SCHED_PARAM_SJF_A_DENOM + (SCHED_PARAM_SJF_A_NUMER*(p->estimate))/SCHED_PARAM_SJF_A_DENOM;
      
      // p->cpu_usage = p->cpu_usage/2;
      // p->priority = p->prio + p->cpu_usage/2;
      // min_burst = 0;
      // min_prio = 0;
      // struct proc* p1;
      // for(p1 = proc; p1 < &proc[NPROC]; ++p1){
      //   if(p1->state == RUNNABLE){
      //     if(min_burst == 0){
      //       min_burst = p1->estimate;
      //     }
      //     else{
      //       if(min_burst > p1->estimate){
      //         mi_burst = p1->estimate;
      //       }
      //     }
      //     if(min_prio == 0){
      //       min_prio = p->priority;
      //     }
      //     else if(min_prio > p->priority){
      //       min_prio = p->priority;
      //     }
      //   }
      // }
        
      }

      p->estimate = (p->end_ticks - p->start_ticks) - (SCHED_PARAM_SJF_A_NUMER*(p->end_ticks - p->start_ticks))/SCHED_PARAM_SJF_A_DENOM + (SCHED_PARAM_SJF_A_NUMER*(p->estimate))/SCHED_PARAM_SJF_A_DENOM;
      
      
      // p->cpu_usage = p->cpu_usage/2;
      // p->priority = p->prio + p->cpu_usage/2;
      

      min_burst = 0;
      min_prio = 0;
      struct proc* p1;
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
        p1->cpu_usage = p1->cpu_usage/2;
        p1->priority = p1->prio + p1->cpu_usage/2;
      }
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
        if(p1->state == RUNNABLE && p1->batch == 1){
          if(min_burst == 0){
            min_burst = p1->estimate;
          }
          else{
            if(min_burst > p1->estimate){
              min_burst = p1->estimate;
            }
          }
          if(min_prio == 0){
            min_prio = p1->priority;
          }
          else if(min_prio > p1->priority){
            min_prio = p1->priority;
          }
        }
        
      }
    
  

  // Scheduling it again
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);

  myproc()->stime = xticks;

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  //
    uint xticks;
    if (!holding(&tickslock)) {
      acquire(&tickslock);
      xticks = ticks;
      release(&tickslock);
    }
    else xticks = ticks;

    p->end_ticks = xticks;

    p->cpu_usage = p->cpu_usage + SCHED_PARAM_CPU_USAGE/2;

    if(p->batch == 1 && p->end_ticks > p->start_ticks){
       if(max_burst < p->end_ticks - p->start_ticks){
        max_burst = p->end_ticks - p->start_ticks;
      }
      if(mi_burst == 0){
        mi_burst = p->end_ticks - p->start_ticks;
      }
      else if(mi_burst > p->end_ticks - p->start_ticks){
        mi_burst = p->end_ticks - p->start_ticks;
      }
      sum_burst += p->end_ticks - p->start_ticks;
      total_burst ++ ;

      if(p->estimate){
        err_burst ++ ;
      }
        if(p->estimate > p->end_ticks - p->start_ticks){
          err_sum += p->estimate - (p->end_ticks - p->start_ticks);
        }
        else{
          err_sum += (p->end_ticks - p->start_ticks) - p->estimate;
        }
      
      
      // p->estimate = (p->end_ticks - p->start_ticks) - (SCHED_PARAM_SJF_A_NUMER*(p->end_ticks - p->start_ticks))/SCHED_PARAM_SJF_A_DENOM + (SCHED_PARAM_SJF_A_NUMER*(p->estimate))/SCHED_PARAM_SJF_A_DENOM;
      
      // p->cpu_usage = p->cpu_usage/2;
      // p->priority = p->prio + p->cpu_usage/2;
      // min_burst = 0;
      // min_prio = 0;
      // struct proc* p1;
      // for(p1 = proc; p1 < &proc[NPROC]; ++p1){
      //   if(p1->state == RUNNABLE){
      //     if(min_burst == 0){
      //       min_burst = p1->estimate;
      //     }
      //     else{
      //       if(min_burst > p1->estimate){
      //         mi_burst = p1->estimate;
      //       }
      //     }
      //     if(min_prio == 0){
      //       min_prio = p->priority;
      //     }
      //     else if(min_prio > p->priority){
      //       min_prio = p->priority;
      //     }
      //   }
      }

      p->estimate = (p->end_ticks - p->start_ticks) - (SCHED_PARAM_SJF_A_NUMER*(p->end_ticks - p->start_ticks))/SCHED_PARAM_SJF_A_DENOM + (SCHED_PARAM_SJF_A_NUMER*(p->estimate))/SCHED_PARAM_SJF_A_DENOM;
      
      // p->cpu_usage = p->cpu_usage/2;
      // p->priority = p->prio + p->cpu_usage/2;
      min_burst = 0;
      min_prio = 0;
      struct proc* p1;
      for(p1 = proc; p1 < &proc[NPROC]; ++p1){
        p1->cpu_usage = p1->cpu_usage/2;
        p1->priority = p1->prio + p1->cpu_usage/2;
      }
      for(p1 = proc; p1 < &proc[NPROC]; p1++){
        if(p1->state == RUNNABLE && p1->batch == 1){
          if(min_burst == 0){
            min_burst = p1->estimate;
          }
          else{
            if(min_burst > p1->estimate){
              min_burst = p1->estimate;
            }
          }
          if(min_prio == 0){
            min_prio = p1->priority;
          }
          else if(min_prio > p1->priority){
            min_prio = p1->priority;
          }
        }

      
      


    }
  

  //

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
   static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep",
  [RUNNABLE]  "runble",
  [RUNNING]   "run",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    release(&wait_lock);

    acquire(&tickslock);
    xticks = ticks;
    release(&tickslock);

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    printf("\n");
  }
  return 0;
}

int
pinfo(int pid, uint64 addr)
{
   struct procstat pstat;

   static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep",
  [RUNNABLE]  "runble",
  [RUNNING]   "run",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
       acquire(&p->lock);
       if((p->state == UNUSED) || (p->pid != pid)) {
         release(&p->lock);
         continue;
       }
       else {
         found=1;
         break;
       }
     }
  }
  if (found) {
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
         state = states[p->state];
     else
         state = "???";

     pstat.pid = p->pid;
     release(&p->lock);
     acquire(&wait_lock);
     if (p->parent) {
        acquire(&p->parent->lock);
        pstat.ppid = p->parent->pid;
        release(&p->parent->lock);
     }
     else pstat.ppid = -1;
     release(&wait_lock);

     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
     pstat.ctime = p->ctime;
     pstat.stime = p->stime;
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
     pstat.size = p->sz;
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
     return 0;
  }
  else return -1;
}
