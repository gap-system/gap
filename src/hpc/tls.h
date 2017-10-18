#ifndef GAP_TLS_H
#define GAP_TLS_H

#ifdef HPCGAP

#include <stdint.h>
#include <src/gapstate.h>
#include <src/code.h>
#include <src/hpc/tlsconfig.h>
#include <src/scanner.h>
#include <src/gasman.h>

#define TLS_NUM_EXTRA 256

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

  GAPState state;

  /* Extra storage */
  void *Extra[TLS_NUM_EXTRA];
} ThreadLocalStorage;

extern ThreadLocalStorage *MainThreadTLS;

typedef struct TLSHandler
{
  void (*constructor)(void);
  void (*destructor)(void);
} TLSHandler;

void InstallTLSHandler(
	void (*constructor)(void),
	void (*destructor)(void)
);

void RunTLSConstructors(void);
void RunTLSDestructors(void);

#ifdef HAVE_NATIVE_TLS

extern __thread ThreadLocalStorage TLSInstance;

#define realTLS (&TLSInstance)

#else

#if defined(VERBOSE_GUARDS)
static inline ThreadLocalStorage *GetTLS(void)
#else
static ALWAYS_INLINE ThreadLocalStorage *GetTLS(void)
#endif
{
  void *stack;
#ifdef __GNUC__
  stack = __builtin_frame_address(0);
#else
  int dummy[1];
  stack = dummy;
#endif
  return (ThreadLocalStorage *) (((uintptr_t) stack) & TLS_MASK);
}

#define realTLS (GetTLS())

#endif /* HAVE_NATIVE_TLS */

#define TLS(x) realTLS->x
#define STATE(x) TLS(state).x

static inline int IsMainThread(void)
{
  return TLS(threadID) == 0;
}

void InitializeTLS(void);

Int AllocateExtraTLSSlot(void);

void InitTLS(void);
void DestroyTLS(void);

#endif // HPCGAP

#endif // GAP_TLS_H
