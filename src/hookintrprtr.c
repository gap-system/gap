/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains functions related to hooking the interpreter.
**
*/

#include "hookintrprtr.h"

#include "code.h"
#include "exprs.h"
#include "gaputils.h"
#include "modules.h"
#include "stats.h"

#include "hpc/thread.h"

#include <string.h>


/* List of active hooks */
struct InterpreterHooks * activeHooks[HookCount];

/* Number of active hooks */
static Int HookActiveCount;

/* If a print hook is current active */
static Int PrintHookActive;

/****************************************************************************
**
** Store the true values of each function we wrap for hooking. These always
** store the correct values and are never changed.
*/

ExecStatFunc OriginalExecStatFuncsForHook[256];

EvalExprFunc OriginalEvalExprFuncsForHook[256];
EvalBoolFunc OriginalEvalBoolFuncsForHook[256];

PrintStatFunc OriginalPrintStatFuncsForHook[256];
PrintExprFunc OriginalPrintExprFuncsForHook[256];

/****************************************************************************
**
** These functions install implementations of eval/expr functions,
** ensuring they are set up correctly if any hooks are already active.
*/

void InstallEvalBoolFunc(Int pos, EvalBoolFunc f)
{
    OriginalEvalBoolFuncsForHook[pos] = f;
    HashLock(&activeHooks);
    if (!HookActiveCount) {
        EvalBoolFuncs[pos] = f;
    }
    HashUnlock(&activeHooks);
}

void InstallEvalExprFunc(Int pos, EvalExprFunc f)
{
    OriginalEvalExprFuncsForHook[pos] = f;
    HashLock(&activeHooks);
    if (!HookActiveCount) {
        EvalExprFuncs[pos] = f;
    }
    HashUnlock(&activeHooks);
}

void InstallExecStatFunc(Int pos, ExecStatFunc f)
{
    OriginalExecStatFuncsForHook[pos] = f;
    HashLock(&activeHooks);
    if (!HookActiveCount) {
        ExecStatFuncs[pos] = f;
    }
    HashUnlock(&activeHooks);
}

void InstallPrintStatFunc(Int pos, PrintStatFunc f)
{
    OriginalPrintStatFuncsForHook[pos] = f;
    HashLock(&activeHooks);
    if(!PrintHookActive) {
        PrintStatFuncs[pos] = f;
    }
    HashUnlock(&activeHooks);
}

void InstallPrintExprFunc(Int pos, PrintExprFunc f)
{
    OriginalPrintExprFuncsForHook[pos] = f;
    HashLock(&activeHooks);
    if(!PrintHookActive) {
        PrintExprFuncs[pos] = f;
    }
    HashUnlock(&activeHooks);
}

static ExecStatus ProfileExecStatPassthrough(Stat stat)
{
    GAP_HOOK_LOOP(visitStat, stat);
    return OriginalExecStatFuncsForHook[TNUM_STAT(stat)](stat);
}

static Obj ProfileEvalExprPassthrough(Expr stat)
{
    GAP_HOOK_LOOP(visitStat, stat);
    return OriginalEvalExprFuncsForHook[TNUM_STAT(stat)](stat);
}

static Obj ProfileEvalBoolPassthrough(Expr stat)
{
    /* There are two cases we must pass through without touching */
    /* From TNUM_EXPR */
    if (IS_REF_LVAR(stat)) {
        return OriginalEvalBoolFuncsForHook[EXPR_REF_LVAR](stat);
    }
    if (IS_INTEXPR(stat)) {
        return OriginalEvalBoolFuncsForHook[EXPR_INT](stat);
    }
    GAP_HOOK_LOOP(visitStat, stat);
    return OriginalEvalBoolFuncsForHook[TNUM_STAT(stat)](stat);
}

/****************************************************************************
**
** Activate, or deactivate hooks
**
*/

Int ActivateHooks(struct InterpreterHooks * hook)
{
    Int i;

    if (HookActiveCount == HookCount) {
        return 0;
    }

    HashLock(&activeHooks);
    for (i = 0; i < HookCount; ++i) {
        if (activeHooks[i] == hook) {
            HashUnlock(&activeHooks);
            return 0;
        }
    }

    for (i = 0; i < ARRAY_SIZE(ExecStatFuncs); i++) {
        ExecStatFuncs[i] = ProfileExecStatPassthrough;
        EvalExprFuncs[i] = ProfileEvalExprPassthrough;
        EvalBoolFuncs[i] = ProfileEvalBoolPassthrough;
    }

    for (i = 0; i < HookCount; ++i) {
        if (!activeHooks[i]) {
            activeHooks[i] = hook;
            HookActiveCount++;
            HashUnlock(&activeHooks);
            return 1;
        }
    }
    HashUnlock(&activeHooks);
    return 0;
}

Int DeactivateHooks(struct InterpreterHooks * hook)
{
    Int i;

    HashLock(&activeHooks);
    for (i = 0; i < HookCount; ++i) {
        if (activeHooks[i] == hook) {
            activeHooks[i] = 0;
            HookActiveCount--;
        }
    }

    if (HookActiveCount == 0) {
        memcpy(ExecStatFuncs, OriginalExecStatFuncsForHook, sizeof(ExecStatFuncs));
        memcpy(EvalExprFuncs, OriginalEvalExprFuncsForHook, sizeof(EvalExprFuncs));
        memcpy(EvalBoolFuncs, OriginalEvalBoolFuncsForHook, sizeof(EvalBoolFuncs));
    }

    HashUnlock(&activeHooks);
    return 1;
}

void ActivatePrintHooks(struct PrintHooks * hook)
{
    Int i;

    if (PrintHookActive) {
        return;
    }
    PrintHookActive = 1;
    for (i = 0; i < ARRAY_SIZE(ExecStatFuncs); i++) {
        if (hook->printStatPassthrough) {
            PrintStatFuncs[i] = hook->printStatPassthrough;
        }
        if (hook->printExprPassthrough) {
            PrintExprFuncs[i] = hook->printExprPassthrough;
        }
    }
}

void DeactivatePrintHooks(struct PrintHooks * hook)
{
    if (!PrintHookActive) {
        return;
    }
    PrintHookActive = 0;
    memcpy(PrintStatFuncs, OriginalPrintStatFuncsForHook, sizeof(PrintStatFuncs));
    memcpy(PrintExprFuncs, OriginalPrintExprFuncsForHook, sizeof(PrintExprFuncs));
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {
    { 0, 0, 0, 0, 0 }
};


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);

    return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel(StructInitInfo * module)
{
    InitHdlrFuncsFromTable(GVarFuncs);
    return 0;
}


/****************************************************************************
**
*F  InitInfoHookIntrptr() . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "hookintrprtr",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoHookIntrprtr(void)
{
    return &module;
}
