#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"


uint64
sys_exit(void)
{
  int status;
  uint64 msgaddr;     
  argint(0, &status);  // first arg: status
  argaddr(1, &msgaddr);// second arg: pointer to msg

  // We'll fetch the string from user space into a kernel buffer.
  char msgbuf[32];
  if(msgaddr != 0){
    if(fetchstr(msgaddr, msgbuf, sizeof(msgbuf)) < 0){
      // invalid pointer or too long => just empty
      msgbuf[0] = '\0';
    }
  } else {
    // if user passed NULL
    msgbuf[0] = '\0';
  }

  exit(status, msgbuf);
  return 0; // not reached
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
  uint64 statusaddr; 
  uint64 msgaddr;   
  argaddr(0, &statusaddr);
  argaddr(1, &msgaddr);

  return wait(statusaddr, (char*) msgaddr);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
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

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
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

  argint(0, &pid);
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

uint64 sys_memsize(void){

  uint64 size;
  size = myproc()->sz;
  
  return size;
}

uint64
sys_forkn(void)
{
  int n;  
  uint64 pids_addr;     
  argint(0, &n);  
  argaddr(1, &pids_addr);

  return forkn(n, (int*)pids_addr);
}

uint64
sys_waitall(void)
{
  uint64 n_addr;
  uint64 statuses_addr;
  argaddr(0, &n_addr);
  argaddr(1, &statuses_addr);
  return waitall((int*)n_addr, (int*)statuses_addr);

}
