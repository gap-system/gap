/***********************************************************************
 **
 *W  gapstate.h      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares all variables that are considered state for the
 ** interpreter
 **
 */
#ifndef GAP_GAPSTATE_H
#define GAP_GAPSTATE_H

#include <stdint.h>

#include <src/code.h>
#include <src/gasman.h>
#include <src/scanner.h>
#include <src/system.h>

#if defined(HPCGAP)
#include <src/hpc/serialize.h>
#endif

#define MAXPRINTDEPTH 1024L

typedef struct GAPState {
    /* From intrprtr.c */
    Obj  IntrResult;
    UInt IntrIgnoring;
    UInt IntrReturning;
    UInt IntrCoding;
    Obj  IntrState;
    Obj  StackObj;
    Obj  Tilde;

    /* From gvar.c */
    Obj CurrNamespace;

    /* From vars.c */
    Bag   BottomLVars;
    Bag   CurrLVars;
    Obj * PtrLVars;

    /* The length of this array must be synced with InitKernel in vars.c */
    Bag   LVarsPool[16];

    /* From read.c */
    syJmp_buf ReadJmpError;
    syJmp_buf threadExit;
    Obj       StackNams;
    UInt      ReadTop;
    UInt      ReadTilde;
    UInt      CurrLHSGVar;
    UInt      CurrentGlobalForLoopVariables[100];
    UInt      CurrentGlobalForLoopDepth;
    Obj       ReadEvalResult;

    /* From scanner.c */
    Char   Value[MAX_VALUE_LEN];
    UInt   ValueLen;
    UInt   NrError;
    UInt   NrErrLine;
    UInt   Symbol;
    const Char * Prompt;
#if defined(HPCGAP)
    TypInputFile *  InputFiles[16];
    TypOutputFile * OutputFiles[16];
    int             InputFilesSP;
    int             OutputFilesSP;
#else
    TypInputFile  InputFiles[16];
    TypOutputFile OutputFiles[16];
#endif
    TypInputFile *  Input;
    Char *          In;
    TypOutputFile * Output;
    TypOutputFile * InputLog;
    TypOutputFile * OutputLog;
    TypOutputFile * IgnoreStdoutErrout;
    TypOutputFile   LogFile;
    TypOutputFile   LogStream;
    TypOutputFile   InputLogFile;
    TypOutputFile   InputLogStream;
    TypOutputFile   OutputLogFile;
    TypOutputFile   OutputLogStream;
    Int             HELPSubsOn;
    Int             NoSplitLine;
    KOutputStream   TheStream;
    Char *          TheBuffer;
    UInt            TheCount;
    UInt            TheLimit;

    /* From exprs.c */
    Obj (**CurrEvalExprFuncs)(Expr);

    /* From stats.c */
    Stat CurrStat;
    Obj  ReturnObjStat;
    UInt (**CurrExecStatFuncs)(Stat);

    /* From code.c */
    Stat * PtrBody;
    Stat   OffsBody;
    Stat * OffsBodyStack;
    UInt   OffsBodyCount;
    UInt   LoopNesting;
    UInt * LoopStack;
    UInt   LoopStackCount;

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
#if defined(HPCGAP)
    Obj   MethodCache;
    Obj * MethodCacheItems;
    UInt  MethodCacheSize;
#endif
    UInt  CacheIndex;

    /* From cyclotom.c */
    Obj  ResultCyc;
    Obj  LastECyc;
    UInt LastNCyc;

    /* From permutat.c */
    Obj TmpPerm;

    /* From trans.c */
    Obj TmpTrans;

    /* From pperm.c */
    Obj TmpPPerm;

    /* From gap.c */
    Obj  ThrownObject;
    UInt UserHasQuit;
    UInt UserHasQUIT;
    Obj  ShellContext;
    Obj  BaseShellContext;
    Obj  ErrorLVars0;       // the initial ErrorLVars value, i.e. for the lvars were the break occurred
    Obj  ErrorLVars;        // ErrorLVars as modified by DownEnv / UpEnv
    Int  ErrorLLevel;       // record where on the stack ErrorLVars is relative to the top, i.e. ErrorLVars0

    /* From objects.c */
    Obj PrintObjThis;
    Int PrintObjIndex;
    Int PrintObjDepth;
    Int PrintObjFull;
#if defined(HPCGAP)
    Obj   PrintObjThissObj;
    Obj * PrintObjThiss;
    Obj   PrintObjIndicesObj;
    Int * PrintObjIndices;
#else
    Obj           PrintObjThiss[MAXPRINTDEPTH];
    Int           PrintObjIndices[MAXPRINTDEPTH];
#endif

#if defined(HPCGAP)
    /* For serializer.c */
    SerializationState Serialization;
#endif

    /* For objscoll*, objccoll* */
    Obj  SC_NW_STACK;
    Obj  SC_LW_STACK;
    Obj  SC_PW_STACK;
    Obj  SC_EW_STACK;
    Obj  SC_GE_STACK;
    Obj  SC_CW_VECTOR;
    Obj  SC_CW2_VECTOR;
    UInt SC_MAX_STACK_SIZE;

/* Allocation */
#ifdef BOEHM_GC
#define MAX_GC_PREFIX_DESC 4
    void ** FreeList[MAX_GC_PREFIX_DESC + 2];
#endif
} GAPState;

#if defined(HPCGAP)

#include <src/hpc/tls.h>

#else

extern GAPState * MainGAPState;
#define STATE(x) (MainGAPState->x)

#endif

void InitMainGAPState(void);

void InitScannerState(GAPState *);
void InitStatState(GAPState *);
void InitExprState(GAPState *);
void InitCoderState(GAPState *);
void InitOpersState(GAPState *);

void DestroyScannerState(GAPState *);
void DestroyStatState(GAPState *);
void DestroyExprState(GAPState *);
void DestroyCoderState(GAPState *);
void DestroyOpersState(GAPState *);

void InitGAPState(GAPState * state);
void DestroyGAPState(GAPState * state);

#endif    // GAP_GAPSTATE_H
