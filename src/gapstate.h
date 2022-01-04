/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares a struct that contains variables that are global
**  state in GAP, but in HPC-GAP an instance of it exists for every thread.
**
*/

#ifndef GAP_GAPSTATE_H
#define GAP_GAPSTATE_H

#include "common.h"

#ifdef HPCGAP
#include "hpc/tls.h"
#endif

#include <setjmp.h>

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
    Obj  Tilde;

    // The current assertion level for use in Assert
    Int CurrentAssertionLevel;

    /* From gvar.c */
    Obj CurrNamespace;

    /* From vars.c */
    Bag   CurrLVars;
    Obj * PtrLVars;
    Bag   LVarsPool[16];

    /* From read.c */
    jmp_buf ReadJmpError;

    char Prompt[80];

    /* From stats.c */

    // `ReturnObjStat` is the result of the return-statement that was last
    // executed. It is set in `ExecReturnObj` and used in the handlers that
    // interpret functions.
    Obj  ReturnObjStat;

    ExecStatFunc * CurrExecStatFuncs;

    /* From code.c */
    void * PtrBody;

    /* From opers.c */
#ifdef HPCGAP
    Obj   MethodCache;
    Obj * MethodCacheItems;
    UInt  MethodCacheSize;
#endif

    // for use by GAP_TRY / GAP_CATCH and related code
    int TryCatchDepth;

    // Set by `FuncJUMP_TO_CATCH` to the value of its second argument, and
    // and then later extracted by `CALL_WITH_CATCH`. Not currently used by
    // the GAP kernel itself, as far as I can tell.
    Obj ThrownObject;

    // Set to TRUE when a read-eval-loop encounters a `quit` statement.
    BOOL UserHasQuit;

    // Set to TRUE when a read-eval-loop encounters a `QUIT` statement.
    BOOL UserHasQUIT;

    // Set by the primary read-eval loop in `FuncSHELL`, based on the value of
    // `ErrorLLevel`. Also, `ReadEvalCommand` saves and restores this value
    // before executing code.
    Obj ErrorLVars;

    // Records where on the stack `ErrorLVars` is relative to the top; this is
    // modified by `FuncDownEnv` / `FuncUpEnv`, and ultimately used and
    // controlled by the primary read-eval loop in `FuncSHELL`.
    Int ErrorLLevel;

    // This callback is called in FuncJUMP_TO_CATCH, this is not used by GAP
    // itself but by programs that use GAP as a library to handle errors
    void (*JumpToCatchCallback)(void);

    /* From info.c */
    Int ShowUsedInfoClassesActive;

    UInt1 StateSlots[STATE_SLOTS_SIZE];

/* Allocation */
#if defined(USE_BOEHM_GC)
#define MAX_GC_PREFIX_DESC 4
    void ** FreeList[MAX_GC_PREFIX_DESC + 2];
#endif
} GAPState;

#ifdef HPCGAP

EXPORT_INLINE GAPState * ActiveGAPState(void)
{
    return (GAPState *)GetTLS();
}

#else

extern GAPState MainGAPState;

EXPORT_INLINE GAPState * ActiveGAPState(void)
{
    return &MainGAPState;
}

#endif

#define STATE(x) (ActiveGAPState()->x)


// Offset into StateSlots
typedef Int ModuleStateOffset;

EXPORT_INLINE void * StateSlotsAtOffset(ModuleStateOffset offset)
{
    GAP_ASSERT(0 <= offset && offset < STATE_SLOTS_SIZE);
    return &STATE(StateSlots)[offset];
}

/* Access a module's registered state */
#define MODULE_STATE(module) \
    (*(module ## ModuleState *)StateSlotsAtOffset(module ## StateOffset))

#endif    // GAP_GAPSTATE_H
