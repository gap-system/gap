/***********************************************************************
 **
 *W  gapstate.h      GAP source                 Markus Pfeiffer
 **
 **
 ** This file declares a struct that contains variables that are
 ** global state in GAP, but in HPC-GAP an instance of it exists
 ** for every thread.
 **
 */
#ifndef GAP_GAPSTATE_H
#define GAP_GAPSTATE_H

#include <stdint.h>

#include <src/system.h>
#include <src/gasman.h>
#include <src/io.h> // for TypInputFile and friends
#include <src/scanner.h> // for MAX_VALUE_LEN

#if defined(HPCGAP)
#include <src/hpc/serialize.h>
#include <src/hpc/tls.h>
#endif

enum { STATE_MAX_HANDLERS = 256,
       STATE_SLOTS_SIZE = 32768 };

#define MAXPRINTDEPTH 1024L

typedef struct GAPState {
#ifdef HPCGAP
    // TLS data -- this *must* come first, so that we can safely
    // cast a GAPState pointer into a ThreadLocalStorage pointer
    ThreadLocalStorage tls;
#endif

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
    Bag   LVarsPool[16];

    /* From read.c */
    syJmp_buf ReadJmpError;
    Obj       StackNams;
    UInt      ReadTop;
    UInt      ReadTilde;
    UInt      CurrLHSGVar;
    UInt      CurrentGlobalForLoopVariables[100];
    UInt      CurrentGlobalForLoopDepth;

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
    TypOutputFile   InputLogFileOrStream;
    TypOutputFile   OutputLogFileOrStream;
    Int             HELPSubsOn;
    Int             NoSplitLine;
    Char            Pushback;
    Char *          RealIn;

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
    Obj  ErrorLVars;        // ErrorLVars as modified by DownEnv / UpEnv
    Int  ErrorLLevel;       // record where on the stack ErrorLVars is relative to the top, i.e. BaseShellContext

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

    UInt1 StateSlots[STATE_SLOTS_SIZE];

/* Allocation */
#ifdef BOEHM_GC
#define MAX_GC_PREFIX_DESC 4
    void ** FreeList[MAX_GC_PREFIX_DESC + 2];
#endif
} GAPState;

#if defined(HPCGAP)

static inline GAPState * ActiveGAPState(void)
{
    return (GAPState *)GetTLS();
}

#else

extern GAPState MainGAPState;

static inline GAPState * ActiveGAPState(void)
{
    return &MainGAPState;
}

#endif

#define STATE(x) (ActiveGAPState()->x)

/* Access a module's registered state */
#define MODULE_STATE(module, var) \
    (((module ## ModuleState *)(&STATE(StateSlots)[module ## StateOffset]))->var)


// Offset into StateSlots
typedef Int ModuleStateOffset;
typedef void (*ModuleConstructor)(ModuleStateOffset offset);
typedef void (*ModuleDestructor)();

/*
 * Register global state for a module.
 *
 * size - how much memory (in bytes) the module would like to reserve in
 *        GAPState.StateSlots
 * constructor and destructor - function pointers. These functions are called
 *        whenever a module is instantiated or freed, respectively.
 *        In GAP this only happens once at startup (and exit).
 *        In HPC-GAP every thread creation and destruction triggers
 *        construction, or destruction resp.
 *        Constructor and destructor receive the offset (in bytes) into
 *        StateSlots where they are free to use the memory area of size
 *        "size", which is aligned to a multiple of sizeof(Obj).
 *
 * Normally the module would store the offset that is returned by
 * RegisterModuleState and use the MODULE_STATE macro to access
 * its own state after that.
 */
ModuleStateOffset RegisterModuleState(UInt              size,
                                      ModuleConstructor constructor,
                                      ModuleDestructor  destructor);

void RunModuleConstructors(GAPState * state);
void RunModuleDestructors(GAPState * state);

void InitMainGAPState(void);

void InitGAPState(GAPState * state);
void DestroyGAPState(GAPState * state);

#endif    // GAP_GAPSTATE_H
