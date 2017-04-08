/***********************************************************************
 **
 *W  globalstate.h      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */
#ifndef GAP_GLOBAL_STATE_H
#define GAP_GLOBAL_STATE_H

#include <stdint.h>

#include <src/system.h>
#include <src/code.h>
#include <src/scanner.h>
#include <src/gasman.h>

#define MAXPRINTDEPTH 1024L

typedef struct GlobalState
{
#if defined(HPCGAP)
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
#endif

  /* From intrprtr.c */
  Obj IntrResult;
  UInt IntrIgnoring;
  UInt IntrReturning;
  UInt IntrCoding;
  Obj IntrState;
  Obj StackObj;
  Int CountObj;
#if defined(HPCGAP)
  UInt PeriodicCheckCount;
#endif

  /* From gvar.c */
  Obj CurrNamespace;

  /* From vars.c */
  Bag BottomLVars;
  Bag CurrLVars;
  Obj *PtrLVars;
#if defined(HPCGAP)
  Bag LVarsPool[16];
#endif

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
  Obj ReadEvalResult;

  /* From scanner.c */
  Char Value[MAX_VALUE_LEN];
  UInt ValueLen;
  UInt NrError;
  UInt NrErrLine;
  UInt            Symbol;
  Char *          Prompt;
#if defined(HPCGAP)
  TypInputFile * InputFiles[16];
  TypOutputFile * OutputFiles[16];
#else
  TypInputFile InputFiles[16];
  TypOutputFile OutputFiles[16];
#endif
  int InputFilesSP;
  int OutputFilesSP;
  TypInputFile *  Input;
  Char *          In;
  TypOutputFile * Output;
  TypOutputFile * InputLog;
  TypOutputFile * OutputLog;
  TypOutputFile * IgnoreStdoutErrout;
#if defined(HPCGAP)
  Obj		  DefaultOutput;
  Obj		  DefaultInput;
#endif
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
  Int ErrorLLevel;
  Obj ErrorLVars;
  Obj ErrorLVars0;

  /* From objects.c */
  Obj PrintObjThis;
  Int PrintObjIndex;
  Int PrintObjDepth;
  Int PrintObjFull;
#if defined(HPCGAP)
  Obj PrintObjThissObj;
  Obj *PrintObjThiss;
  Obj PrintObjIndicesObj;
  Obj *PrintObjIndices;
#else
  Obj PrintObjThiss[MAXPRINTDEPTH];
  Int PrintObjIndices[MAXPRINTDEPTH];
#endif

#if defined(HPCGAP)
  /* For serializer.c */
  Obj SerializationObj;
  UInt SerializationIndex;
  void *SerializationDispatcher;
  Obj SerializationRegistry;
  Obj SerializationStack;
#endif

  /* For objscoll*, objccoll* */
  Obj SC_NW_STACK;
  Obj SC_LW_STACK;
  Obj SC_PW_STACK;
  Obj SC_EW_STACK;
  Obj SC_GE_STACK;
  Obj SC_CW_VECTOR;
  Obj SC_CW2_VECTOR;
  UInt SC_MAX_STACK_SIZE;

#if defined(HPCGAP)
  /* Profiling */
  UInt CountActive;
  UInt LocksAcquired;
  UInt LocksContended;
#endif

  /* Allocation */
#ifdef BOEHM_GC
#define MAX_GC_PREFIX_DESC 4
  void **FreeList[MAX_GC_PREFIX_DESC+2];
#endif
  /* Extra storage */
#if defined(HPCGAP)
  void *Extra[TLS_NUM_EXTRA];
#endif
} GlobalState;

extern GlobalState *MainGlobalState;

void InitMainGlobalState(void);

void InitScannerState(GlobalState *);
void InitStatState(GlobalState *);
void InitExprState(GlobalState *);
void InitCoderState(GlobalState *);
void InitOpersState(GlobalState *);

void DestroyScannerState(GlobalState *);
void DestroyStatState(GlobalState *);
void DestroyExprState(GlobalState *);
void DestroyCoderState(GlobalState *);
void DestroyOpersState(GlobalState *);

void InitGlobalState(GlobalState *state);
void DestroyGlobalState(GlobalState *state);

#endif // GAP_GLOBAL_STATE_H
