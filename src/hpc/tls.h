#ifndef GAP_TLS_H
#define GAP_TLS_H

#ifdef HPCGAP

#include <src/system.h>
#include <src/hpc/tlsconfig.h>

typedef struct ThreadLocalStorage
{
  int threadID;
  void *threadLock;
  void *threadSignal;
  void *acquiredMonitor;
  unsigned multiplexRandomSeed;
  void *currentRegion;
  void *threadRegion;
  void *traversalState;
  Obj threadObject;
  Obj tlRecords;
  Obj lockStack;
  int lockStackPointer;
  Obj copiedObjs;
  Obj interruptHandlers;
  void *CurrentHashLock;
  int DisableGuards;

  /* From intrprtr.c */
  UInt PeriodicCheckCount;

  /* From read.c */
  syJmp_buf threadExit;

  /* From scanner.c */
  Obj		  DefaultOutput;
  Obj		  DefaultInput;

  /* Profiling */
  UInt CountActive;
  UInt LocksAcquired;
  UInt LocksContended;
} ThreadLocalStorage;

#ifdef HAVE_NATIVE_TLS
extern __thread ThreadLocalStorage *TLSInstance;
#endif

#if defined(VERBOSE_GUARDS)
static inline ThreadLocalStorage *GetTLS(void)
#else
static ALWAYS_INLINE ThreadLocalStorage *GetTLS(void)
#endif
{
#ifdef HAVE_NATIVE_TLS
    return TLSInstance;
#else
    void *stack;
  #ifdef __GNUC__
    stack = __builtin_frame_address(0);
  #else
    int dummy[1];
    stack = dummy;
  #endif
    return (ThreadLocalStorage *) (((uintptr_t) stack) & TLS_MASK);
#endif
}

// Convenience helper for accessing TLS members
#define TLS(x) GetTLS()->x

void InitializeTLS(void);

#endif // HPCGAP

#endif // GAP_TLS_H
