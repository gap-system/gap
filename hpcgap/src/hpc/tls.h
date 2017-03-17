#ifndef GAP_TLS_H
#define GAP_TLS_H

#if !defined(HPCGAP)

/*
 * HPC-GAP stubs.
 */

#define ReadGuard(bag) NOOP
#define WriteGuard(bag) NOOP

static inline Bag ImpliedWriteGuard(Bag bag)
{
  return bag;
}

#else

#include <stdint.h>

#include "code.h"
#include "tlsconfig.h"
#include "scanner.h"
#include "gasman.h"

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
  char *CurrFuncName;
  int DisableGuards;

  /* From intrprtr.c */
  Obj IntrResult;
  UInt IntrIgnoring;
  UInt IntrReturning;
  UInt IntrCoding;
  Obj IntrState;
  Obj StackObj;
  Int CountObj;
  UInt PeriodicCheckCount;

  /* From gvar.c */
  Obj CurrNamespace;

  /* From vars.c */
  Bag BottomLVars;
  Bag CurrLVars;
  Obj *PtrLVars;
  Bag LVarsPool[16];

  /* From read.c */
  syJmp_buf ReadJmpError;
  syJmp_buf threadExit;
  Obj StackNams;
  UInt CountNams;
  UInt ReadTop;
  UInt ReadTilde;
  UInt CurrLHSGVar;
  UInt CurrentGlobalForLoopVariables[100];
  UInt CurrentGlobalForLoopDepth;
  Obj ExprGVars;
  Obj ErrorLVars;
  Obj ErrorLVars0;
  Obj ReadEvalResult;

  /* From scanner.c */
  Char Value[MAX_VALUE_LEN];
  UInt ValueLen;
  UInt NrError;
  UInt NrErrLine;
  UInt            Symbol;
  Char *          Prompt;
  TypInputFile *  InputFiles[16];
  TypOutputFile* OutputFiles[16];
  int InputFilesSP;
  int OutputFilesSP;
  TypInputFile *  Input;
  Char *          In;
  TypOutputFile * Output;
  TypOutputFile * InputLog;
  TypOutputFile * OutputLog;
  TypInputFile *  TestInput;
  TypOutputFile * TestOutput;
  TypOutputFile * IgnoreStdoutErrout;
  Obj		  DefaultOutput;
  Obj		  DefaultInput;
  Char            TestLine [256];
  TypOutputFile LogFile;
  TypOutputFile LogStream;
  TypOutputFile InputLogFile;
  TypOutputFile InputLogStream;
  TypOutputFile OutputLogFile;
  TypOutputFile OutputLogStream;
  Int HELPSubsOn;
  Int NoSplitLine;
  KOutputStream TheStream;
  Char *TheBuffer;
  UInt TheCount;
  UInt TheLimit;

  /* From exprs.c */
  Obj (**CurrEvalExprFuncs)(Expr);

  /* From stats.c */
  Stat CurrStat;
  Obj ReturnObjStat;
  UInt (**CurrExecStatFuncs)(Stat);

  /* From code.c */
  Stat *PtrBody;
  Stat OffsBody;
  Stat *OffsBodyStack;
  UInt OffsBodyCount;
  UInt LoopNesting;
  UInt *LoopStack;
  UInt LoopStackCount;
  
  Obj CodeResult;
  Bag StackStat;
  Int CountStat;
  Bag StackExpr;
  Int CountExpr;
  Bag CodeLVars;

  /* From funcs.h */
  Int RecursionDepth;
  Obj ExecState;

  /* From opers.c */
  Obj MethodCache;
  Obj *MethodCacheItems;
  UInt MethodCacheSize;
  UInt CacheIndex;

  /* From cyclotom.c */
  Obj ResultCyc;
  Obj  LastECyc;
  UInt LastNCyc;

  /* From permutat.c */
  Obj TmpPerm;

  /* From trans.c */
  Obj TmpTrans;
 
  /* From pperm.c */
  Obj TmpPPerm; 

  /* From gap.c */
  Obj ThrownObject;
  UInt UserHasQuit;
  UInt UserHasQUIT;
  Obj ShellContext;
  Obj BaseShellContext;
  UInt ShellContextDepth;
  Int ErrorLLevel;

  /* From objects.c */

  Obj PrintObjThis;
  Int PrintObjIndex;
  Int PrintObjDepth;
  Int PrintObjFull;
  Obj PrintObjThissObj;
  Obj *PrintObjThiss;
  Obj PrintObjIndicesObj;
  Int *PrintObjIndices;

  /* For serializer.c */
  Obj SerializationObj;
  UInt SerializationIndex;
  void *SerializationDispatcher;
  Obj SerializationRegistry;
  Obj SerializationStack;

  /* For objscoll*, objccoll* */
  Obj SC_NW_STACK;
  Obj SC_LW_STACK;
  Obj SC_PW_STACK;
  Obj SC_EW_STACK;
  Obj SC_GE_STACK;
  Obj SC_CW_VECTOR;
  Obj SC_CW2_VECTOR;
  UInt SC_MAX_STACK_SIZE;

  /* Profiling */
  UInt CountActive;
  UInt LocksAcquired;
  UInt LocksContended;

  /* Allocation */
#ifdef BOEHM_GC
#define MAX_GC_PREFIX_DESC 4
  void **FreeList[MAX_GC_PREFIX_DESC+2];
#endif
  /* Extra storage */
  void *Extra[TLS_NUM_EXTRA];
} ThreadLocalStorage;

extern ThreadLocalStorage *MainThreadTLS;

typedef struct TLSHandler
{
  void (*constructor)();
  void (*destructor)();
} TLSHandler;

void InstallTLSHandler(
	void (*constructor)(),
	void (*destructor)()
);

void RunTLSConstructors();
void RunTLSDestructors();

#if defined(__GNUC__)
#define ALWAYS_INLINE __attribute__((always_inline)) inline
#else
#define ALWAYS_INLINE inline
#endif

#ifdef HAVE_NATIVE_TLS

extern __thread ThreadLocalStorage TLSInstance;

#define realTLS (&TLSInstance)

#else

#if defined(VERBOSE_GUARDS)
static inline ThreadLocalStorage *GetTLS()
#else
static ALWAYS_INLINE ThreadLocalStorage *GetTLS()
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

#define IS_BAG_REF(bag) (bag && !((Int)(bag)& 0x03))

#ifdef VERBOSE_GUARDS

#define ReadGuard(bag) ReadGuardFull(bag, __FILE__, __LINE__, __FUNCTION__, #bag)
#define WriteGuard(bag) WriteGuardFull(bag, __FILE__, __LINE__, __FUNCTION__, #bag)
#define ReadGuardByRef(bag) ReadGuardByRefFull(bag, __FILE__, __LINE__, __FUNCTION__, #bag)
#define WriteGuardByRef(bag) WriteGuardByRefFull(bag, __FILE__, __LINE__, __FUNCTION__, #bag)


#endif

#ifdef VERBOSE_GUARDS
void WriteGuardError(Bag bag,
    const char *file, unsigned line, const char *func, const char *expr);
void ReadGuardError(Bag bag,
    const char *file, unsigned line, const char *func, const char *expr);
#else
void WriteGuardError(Bag bag);
void ReadGuardError(Bag bag);
#endif

#ifdef VERBOSE_GUARDS
static ALWAYS_INLINE Bag WriteGuardFull(Bag bag,
  const char *file, unsigned line, const char *func, const char *expr)
#else
static ALWAYS_INLINE Bag WriteGuard(Bag bag)
#endif
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return bag;
  region = REGION(bag);
  if (region && region->owner != realTLS && region->alt_owner != realTLS)
    WriteGuardError(bag
#ifdef VERBOSE_GUARDS
    , file, line, func, expr
#endif
    );
  return bag;
}

#ifdef VERBOSE_GUARDS
static ALWAYS_INLINE Bag *WriteGuardByRefFull(Bag *bagref,
  const char *file, unsigned line, const char *func, const char *expr)
#else
static ALWAYS_INLINE Bag *WriteGuardByRef(Bag *bagref)
#endif
{
  Bag bag = *bagref;
  Region *region;
  if (!IS_BAG_REF(bag))
    return bagref;
  region = REGION(bag);
  if (region && region->owner != realTLS && region->alt_owner != realTLS)
    WriteGuardError(bag
#ifdef VERBOSE_GUARDS
    , file, line, func, expr
#endif
    );
  return bagref;
}

#define WRITE_GUARD(bag) (*WriteGuardByRef(&(bag)))

static inline Bag ImpliedWriteGuard(Bag bag)
{
  return bag;
}

static inline int CheckWriteAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  return !(region && region->owner != realTLS && region->alt_owner != realTLS)
    || TLS(DisableGuards) >= 2;
}

static inline int CheckExclusiveWriteAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  if (!region)
    return 0;
  return region->owner == realTLS || region->alt_owner == realTLS
    || TLS(DisableGuards) >= 2;
}

#ifdef VERBOSE_GUARDS
static ALWAYS_INLINE Bag ReadGuardFull(Bag bag,
  const char *file, unsigned line, const char *func, const char *expr)
#else
static ALWAYS_INLINE Bag ReadGuard(Bag bag)
#endif
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return bag;
  region = REGION(bag);
  if (region && region->owner != realTLS &&
      !region->readers[TLS(threadID)] && region->alt_owner != realTLS)
    ReadGuardError(bag
#ifdef VERBOSE_GUARDS
    , file, line, func, expr
#endif
    );
  return bag;
}

#ifdef VERBOSE_GUARDS
static ALWAYS_INLINE Bag *ReadGuardByRefFull(Bag *bagref,
  const char *file, unsigned line, const char *func, const char *expr)
#else
static ALWAYS_INLINE Bag *ReadGuardByRef(Bag *bagref)
#endif
{
  Bag bag = *bagref;
  Region *region;
  if (!IS_BAG_REF(bag))
    return bagref;
  region = REGION(bag);
  if (region && region->owner != realTLS &&
      !region->readers[TLS(threadID)] && region->alt_owner != realTLS)
    ReadGuardError(bag
#ifdef VERBOSE_GUARDS
    , file, line, func, expr
#endif
    );
  return bagref;
}

#define READ_GUARD(bag) (*ReadGuardByRef(&(bag)))

static ALWAYS_INLINE Bag ImpliedReadGuard(Bag bag)
{
  return bag;
}


static ALWAYS_INLINE int CheckReadAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  return !(region && region->owner != realTLS &&
    !region->readers[TLS(threadID)] && region->alt_owner != realTLS)
    || TLS(DisableGuards) >= 2;
}

static inline int IsMainThread()
{
  return TLS(threadID) == 0;
};

void InitializeTLS();

Int AllocateExtraTLSSlot();

void InitTLS();
void DestroyTLS();

#endif // HPCGAP

#endif // GAP_TLS_H
