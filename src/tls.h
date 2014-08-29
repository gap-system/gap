#ifndef GAP_TLS_H
#define GAP_TLS_H

#include <stdint.h>

#include "tlsconfig.h"

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
  Obj intrResult;
  UInt intrIgnoring;
  UInt intrReturning;
  UInt intrCoding;
  Obj intrState;
  Obj stackObj;
  Int countObj;
  UInt PeriodicCheckCount;
  /* From gvar.c */
  Obj currNamespace;
  /* From vars.c */
  Bag bottomLVars;
  Bag currLVars;
  Obj *ptrLVars;
  Bag LVarsPool[16];
  /* From read.c */
  syJmp_buf readJmpError;
  syJmp_buf threadExit;
  Obj stackNams;
  UInt countNams;
  UInt readTop;
  UInt readTilde;
  UInt currLHSGVar;
  UInt currentGlobalForLoopVariables[100];
  UInt currentGlobalForLoopDepth;
  Obj exprGVars;
  Obj errorLVars;
  Obj errorLVars0;
  Obj readEvalResult;
  /* From scanner.c */
  Char value[MAX_VALUE_LEN];
  UInt valueLen;
  UInt nrError;
  UInt nrErrLine;
  UInt            symbol;
  Char *          prompt;
  TypInputFile *  inputFiles[16];
  TypOutputFile* outputFiles[16];
  int inputFilesSP;
  int outputFilesSP;
  TypInputFile *  input;
  Char *          in;
  TypOutputFile * output;
  TypOutputFile * inputLog;
  TypOutputFile * outputLog;
  TypInputFile *  testInput;
  TypOutputFile * testOutput;
  TypOutputFile * IgnoreStdoutErrout;
  Obj		  defaultOutput;
  Obj		  defaultInput;
  Char            testLine [256];
  TypOutputFile logFile;
  TypOutputFile logStream;
  TypOutputFile inputLogFile;
  TypOutputFile inputLogStream;
  TypOutputFile outputLogFile;
  TypOutputFile outputLogStream;
  Int helpSubsOn;
  Int dualSemicolon;
  Int noSplitLine;
  KOutputStream theStream;
  Char *theBuffer;
  UInt theCount;
  UInt theLimit;
  /* From exprs.c */
  Obj (**CurrEvalExprFuncs)(Expr);
  /* From stats.c */
  Stat currStat;
  Obj returnObjStat;
  UInt (**CurrExecStatFuncs)(Stat);
  /* From code.c */
  Stat *ptrBody;
  Stat OffsBody;
  Stat *OffsBodyStack;
  UInt OffsBodyCount;
  Obj codeResult;
  Bag stackStat;
  Int countStat;
  Bag stackExpr;
  Int countExpr;
  Bag codeLVars;
  /* From funcs.h */
  Int recursionDepth;
  Obj execState;

  /* From opers.c */
  Obj methodCache;
  Obj *methodCacheItems;
  UInt methodCacheSize;
  UInt CacheIndex;

  /* From permutat.c */
  Obj TmpPerm;
  /* From cyclotom.c */
  Obj ResultCyc;
  Obj  LastECyc;
  UInt LastNCyc;

  /* From trans.c */
  Obj TmpTrans;
 
  /* From pperm.c */
  Obj TmpPPerm; 

  /* From gap.c */
  Obj thrownObject;
  UInt UserHasQuit;
  UInt UserHasQUIT;
  Obj ShellContext;
  Obj BaseShellContext;
  UInt ShellContextDepth;
  Int ErrorLLevel;
  Obj ErrorLVars0;

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

#define TLS (&TLSInstance)

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

#define TLS (GetTLS())

#endif /* HAVE_NATIVE_TLS */

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
  if (region && region->owner != TLS && region->alt_owner != TLS)
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
  if (region && region->owner != TLS && region->alt_owner != TLS)
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
  return !(region && region->owner != TLS && region->alt_owner != TLS)
    || TLS->DisableGuards >= 2;
}

static inline int CheckExclusiveWriteAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  if (!region)
    return 0;
  return region->owner == TLS || region->alt_owner == TLS
    || TLS->DisableGuards >= 2;
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
  if (region && region->owner != TLS &&
      !region->readers[TLS->threadID] && region->alt_owner != TLS)
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
  if (region && region->owner != TLS &&
      !region->readers[TLS->threadID] && region->alt_owner != TLS)
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
  return !(region && region->owner != TLS &&
    !region->readers[TLS->threadID] && region->alt_owner != TLS)
    || TLS->DisableGuards >= 2;
}

static inline int IsMainThread()
{
  return TLS->threadID == 0;
};

void InitializeTLS();

Int AllocateExtraTLSSlot();

void InitTLS();
void DestroyTLS();

#endif // GAP_TLS_H
