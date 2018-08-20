/****************************************************************************
**
*W  gapstate.h      GAP source                 Markus Pfeiffer
**
**
**  This file declares a struct that contains variables that are global
**  state in GAP, but in HPC-GAP an instance of it exists for every thread.
**
*/

#ifndef GAP_GAPSTATE_H
#define GAP_GAPSTATE_H

#include "system.h"

#if defined(HPCGAP)
#include "hpc/tls.h"
#endif

enum {
    STATE_SLOTS_SIZE = 32768,

    MAX_VALUE_LEN = 1024,
};

typedef struct GAPState {
#ifdef HPCGAP
    // TLS data -- this *must* come first, so that we can safely
    // cast a GAPState pointer into a ThreadLocalStorage pointer
    ThreadLocalStorage tls;
#endif

    /* From intrprtr.c */
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

    /* From scanner.c */
    Obj    ValueObj;
    Char   Value[MAX_VALUE_LEN];
    UInt   NrError;
    UInt   NrErrLine;
    UInt   Symbol;
    UInt   SymbolStartPos;
    UInt   SymbolStartLine;

    const Char * Prompt;

    Char * In;

    /* From stats.c */
    Stat CurrStat;
    Obj  ReturnObjStat;
    UInt (**CurrExecStatFuncs)(Stat);

    /* From code.c */
    Stat * PtrBody;

    /* From opers.c */
#if defined(HPCGAP)
    Obj   MethodCache;
    Obj * MethodCacheItems;
    UInt  MethodCacheSize;
#endif

    /* From gap.c */
    Obj  ThrownObject;
    UInt UserHasQuit;
    UInt UserHasQUIT;
    Obj  ShellContext;
    Obj  BaseShellContext;
    Obj  ErrorLVars;        // ErrorLVars as modified by DownEnv / UpEnv
    Int  ErrorLLevel;       // record where on the stack ErrorLVars is relative to the top, i.e. BaseShellContext
    void (*JumpToCatchCallback)(); // This callback is called in FuncJUMP_TO_CATCH,
                                   // this is not used by GAP itself but by programs
                                   // that use GAP as a library to handle errors

    /* From objects.c */
    Int PrintObjIndex;
    Int PrintObjDepth;

    UInt1 StateSlots[STATE_SLOTS_SIZE];

/* Allocation */
#if !defined(USE_GASMAN)
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


// Offset into StateSlots
typedef Int ModuleStateOffset;

static inline void * StateSlotsAtOffset(ModuleStateOffset offset)
{
    GAP_ASSERT(0 <= offset && offset < STATE_SLOTS_SIZE);
    return &STATE(StateSlots)[offset];
}

/* Access a module's registered state */
#define MODULE_STATE(module) \
    (*(module ## ModuleState *)StateSlotsAtOffset(module ## StateOffset))

#endif    // GAP_GAPSTATE_H
