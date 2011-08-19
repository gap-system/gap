#ifndef _TLS_H
#define _TLS_H

#include <stdint.h>

#include "tlsconfig.h"


typedef struct ThreadLocalStorage
{
  int threadID;
  void *threadLock;
  void *threadSignal;
  void *acquiredMonitor;
  unsigned multiplexRandomSeed;
  void *currentRegion;
  void *traversalState;
  Obj tlRecords;
  Obj lockStack;
  int lockStackPointer;
  Obj copiedObjs;
  /* From intrprtr.c */
  Obj intrResult;
  UInt intrIgnoring;
  UInt intrReturning;
  UInt intrCoding;
  Obj intrState;
  Obj stackObj;
  Int countObj;
  /* From gvar.c */
  Obj currNamespace;
  /* From vars.c */
  Bag bottomLVars;
  Bag currLVars;
  Obj *ptrLVars;
  /* From read.c */
  syJmp_buf readJmpError;
  Obj stackNams;
  UInt countNams;
  UInt readTop;
  UInt readTilde;
  UInt currLHSGVar;
  UInt currentGlobalForLoopVariables[100];
  UInt currentGlobalForLoopDepth;
  Obj exprGVars;
  Obj errorLVars;
  Obj readEvalResult;
  /* From scanner.c */
  Char value[MAX_VALUE_LEN];
  UInt valueLen;
  UInt nrError;
  UInt nrErrLine;
  UInt            symbol;
  Char *          prompt;
  Obj  printPromptHook;
  Obj  endLineHook;
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
  Char            testLine [256];
  Obj isStringStream;
  TypOutputFile logFile;
  TypOutputFile logStream;
  TypOutputFile inputLogFile;
  TypOutputFile inputLogStream;
  TypOutputFile outputLogFile;
  TypOutputFile outputLogStream;
  Obj printFormattingStatus;
  Obj readLineFunc;
  Int helpSubsOn;
  Int dualSemicolon;
  Obj writeAllFunc;
  Int noSplitLine;
  KOutputStream theStream;
  Char *theBuffer;
  UInt theCount;
  UInt theLimit;
  /* From stats.c */
  Stat currStat;
  Obj returnObjStat;
  /* From code.c */
  Stat *ptrBody;
  Stat offsBody;
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
  /* From permutat.c */
  Obj TmpPerm;
  /* From cyclotom.c */
  Obj ResultCyc;
  Obj  LastECyc;
  UInt LastNCyc;

  /* From gap.c */
  Obj thrownObject;

} ThreadLocalStorage;

extern ThreadLocalStorage *MainThreadTLS;

typedef struct
{
  struct TLSHandler *nextHandler;
  void (*constructor)();
  void (*destructor)();
} TLSHandler;

void InstallTLSHandler(
	TLSHandler *handler,
	void (*constructor)(),
	void (*destructor)()
);

void RunTLSConstructors();
void RunTLSDestructors();

#ifdef HAVE_NATIVE_TLS

extern __thread ThreadLocalStorage TLSInstance;

#define TLS (&TLSInstance)

#else

static inline ThreadLocalStorage *GetTLS()
{
  void *stack;
#ifdef __GNUC__
  stack = __builtin_frame_address(0);
#else
  int dummy[0];
  stack = dummy;
#endif
  return (ThreadLocalStorage *) (((uintptr_t) stack) & TLS_MASK);
}

#define TLS (GetTLS())

#endif /* HAVE_NATIVE_TLS */

#define IS_BAG_REF(bag) (bag && !((Int)(bag)& 0x03))

static inline Bag WriteGuard(Bag bag)
{
  extern void WriteGuardError();
  Region *region;
  if (!IS_BAG_REF(bag))
    return bag;
  region = DS_BAG(bag);
  if (region && region->owner != TLS)
    WriteGuardError(bag);
  return bag;
}

static inline Bag *WriteGuardByRef(Bag *bagref)
{
  extern void WriteGuardError();
  Bag bag = *bagref;
  Region *region;
  if (!IS_BAG_REF(bag))
    return bagref;
  region = DS_BAG(bag);
  if (region && region->owner != TLS)
    WriteGuardError(bag);
  return bagref;
}

#define WRITE_GUARD(bag) (*WriteGuardByRef(&(bag)))

static inline Bag ImpliedWriteGuard(Bag bag)
{
  return bag;
}

static inline int CheckWrite(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = DS_BAG(bag);
  return !(region && region->owner != TLS);
}

static inline Bag ReadGuard(Bag bag)
{
  extern void ReadGuardError();
  Region *region;
  if (!IS_BAG_REF(bag))
    return bag;
  region = DS_BAG(bag);
  if (region && region->owner != TLS &&
      !region->readers[TLS->threadID])
    ReadGuardError(bag);
  return bag;
}

static inline Bag *ReadGuardByRef(Bag *bagref)
{
  extern void ReadGuardError();
  Bag bag = *bagref;
  Region *region;
  if (!IS_BAG_REF(bag))
    return bagref;
  region = DS_BAG(bag);
  if (region && region->owner != TLS &&
      !region->readers[TLS->threadID])
    ReadGuardError(bag);
  return bagref;
}

#define READ_GUARD(bag) (*ReadGuardByRef(&(bag)))

static inline Bag ImpliedReadGuard(Bag bag)
{
  return bag;
}


static inline int CheckRead(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = DS_BAG(bag);
  return !(region && region->owner != TLS &&
    !region->readers[TLS->threadID]);
}

static inline int IsMainThread()
{
  return TLS->threadID == 0;
};

void InitializeTLS();

void InitTLS();
void DestroyTLS();

#endif /* _TLS_H */
