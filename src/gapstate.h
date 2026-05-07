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

#ifdef HPCGAP
enum {
    STATE_SLOTS_SIZE = 32768 - 1024,
};

#define DECL_GAP_STATE

typedef struct GAPState {
    // TLS data -- this *must* come first, so that we can safely
    // cast a GAPState pointer into a ThreadLocalStorage pointer
    ThreadLocalStorage tls;
#elif !defined(DECL_GAP_STATE)
#define DECL_GAP_STATE extern
#endif

    // for Boehm GC
#if defined(USE_BOEHM_GC)
    #define MAX_GC_PREFIX_DESC 4
    DECL_GAP_STATE void ** FreeList[MAX_GC_PREFIX_DESC + 2];
#endif

    // From intrprtr.c
    DECL_GAP_STATE Obj Tilde;

    // The current assertion level for use in Assert
    DECL_GAP_STATE Int CurrentAssertionLevel;

    // From gvar.c
    DECL_GAP_STATE Obj CurrNamespace;

    // From vars.c

    // 'CurrLVars' is the bag containing the values of the local variables of
    // the currently executing interpreted function.
    //
    // Assignments to the local variables change this bag. We do not call
    // 'CHANGED_BAG' for each of such change. Instead we wait until a garbage
    // collection begins and then call 'CHANGED_BAG' in 'BeginCollectBags'.
    DECL_GAP_STATE Bag CurrLVars;

    // 'PtrLVars' is a pointer to the 'STATE(CurrLVars)' bag. This makes it
    // faster to access local variables.
    //
    // Since a garbage collection may move this bag around, the pointer
    // 'PtrLVars' must be recalculated afterwards in 'VarsAfterCollectBags'.
    DECL_GAP_STATE Obj * PtrLVars;

    DECL_GAP_STATE Bag LVarsPool[16];

    // From read.c
    DECL_GAP_STATE jmp_buf ReadJmpError;

    // 'Prompt' holds the string that is to be printed if a new line is read
    // from the interactive files '*stdin*' or '*errin*'.
    //
    // It is set to 'gap> ' or 'brk> ' in the read-eval-print loops and
    // changed to the partial prompt '> ' in 'Read' after the first symbol is
    // read.
    DECL_GAP_STATE char Prompt[80];

    // From stats.c

    // `ReturnObjStat` is the result of the return-statement that was last
    // executed. It is set in `ExecReturnObj` and used in the handlers that
    // interpret functions.
    DECL_GAP_STATE Obj ReturnObjStat;

    DECL_GAP_STATE ExecStatFunc * CurrExecStatFuncs;

    // From code.c
    DECL_GAP_STATE void * PtrBody;

    // From opers.c
#ifdef HPCGAP
    Obj   MethodCache;
    Obj * MethodCacheItems;
    UInt  MethodCacheSize;
#endif

    // for use by GAP_TRY / GAP_CATCH and related code
    DECL_GAP_STATE int TryCatchDepth;

    // Set by `FuncJUMP_TO_CATCH` to the value of its second argument, and
    // and then later extracted by `CALL_WITH_CATCH`. Not currently used by
    // the GAP kernel itself, as far as I can tell.
    DECL_GAP_STATE Obj ThrownObject;

    // Set to TRUE when a read-eval-loop encounters a `quit` statement.
    DECL_GAP_STATE BOOL UserHasQuit;

    // Set to TRUE when a read-eval-loop encounters a `QUIT` statement.
    DECL_GAP_STATE BOOL UserHasQUIT;

    // Set by the primary read-eval loop in `FuncSHELL`, based on the value of
    // `ErrorLLevel`. Also, `ReadEvalCommand` saves and restores this value
    // before executing code.
    DECL_GAP_STATE Obj ErrorLVars;

    // Records where on the stack `ErrorLVars` is relative to the top; this is
    // modified by `FuncDownEnv` / `FuncUpEnv`, and ultimately used and
    // controlled by the primary read-eval loop in `FuncSHELL`.
    DECL_GAP_STATE Int ErrorLLevel;

    // This callback is called in FuncJUMP_TO_CATCH, this is not used by GAP
    // itself but by programs that use GAP as a library to handle errors
    DECL_GAP_STATE void (*JumpToCatchCallback)(void);

    // From info.c
    DECL_GAP_STATE Int ShowUsedInfoClassesActive;

#ifdef HPCGAP
    UInt1 StateSlots[STATE_SLOTS_SIZE];
} GAPState;

// for performance reasons, we strive to keep the GAPState size small enough
// so that all its members can be access with a 16 bit signed offset
GAP_STATIC_ASSERT(sizeof(GAPState) < 32768, "GAPState is too big");

#define DECL_MODULE_STATE

EXPORT_INLINE GAPState * ActiveGAPState(void)
{
    return (GAPState *)GetTLS();
}

#define STATE(x) (ActiveGAPState()->x)

#else

#define DECL_MODULE_STATE static

#define STATE(x) (x)

#endif


#ifdef HPCGAP

// Offset into StateSlots
typedef Int ModuleStateOffset;

EXPORT_INLINE void * StateSlotsAtOffset(ModuleStateOffset offset)
{
    GAP_ASSERT(0 <= offset && offset < STATE_SLOTS_SIZE);
    return &STATE(StateSlots)[offset];
}

// Access a module's registered state
#define MODULE_STATE(module, ident) \
    (((module ## ModuleState *)StateSlotsAtOffset(module ## StateOffset))->ident)

#endif

#endif    // GAP_GAPSTATE_H
