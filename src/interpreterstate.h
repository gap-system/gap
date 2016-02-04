/***********************************************************************
 **
 *W  interpreterstate.h      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */
#ifndef GAP_INTERPRETER_STATE_H
#define GAP_INTERPRETER_STATE_H

#include <stdint.h>

#include "system.h"
#include "code.h"
#include "scanner.h"
#include "gasman.h"

typedef struct InterpreterState
{
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
} InterpreterState;

extern InterpreterState *MainInterpreterState;

void InitInterpreter(void);

void InitScannerState(InterpreterState *);
void InitStatState(InterpreterState *);
void InitExprState(InterpreterState *);
void InitCoderState(InterpreterState *);
void InitOpersState(InterpreterState *);

void DestroyScannerState(InterpreterState *);
void DestroyStatState(InterpreterState *);
void DestroyExprState(InterpreterState *);
void DestroyCoderState(InterpreterState *);
void DestroyOpersState(InterpreterState *);

void InitInterpreterState(InterpreterState *state);
void DestroyInterpreterState(InterpreterState *state);

#endif // GAP_TLS_H
