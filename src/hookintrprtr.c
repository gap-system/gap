/****************************************************************************
**
*W  hookintrprtr.c                    GAP source              Chris Jefferson
**
**
*Y  Copyright (C) 2017 The GAP Group
**
**  This file contains functions related to hooking the interpreter.
**
*/

#include <src/hookintrprtr.h>

#include <src/code.h>
#include <src/exprs.h>
#include <src/gap.h>
#include <src/gapstate.h>
#include <src/gaputils.h>
#include <src/stats.h>

#include <src/hpc/thread.h>


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

UInt (*OriginalExecStatFuncsForHook[256])(Stat stat);

Obj (*OriginalEvalExprFuncsForHook[256])(Expr expr);
Obj (*OriginalEvalBoolFuncsForHook[256])(Expr expr);

void (*OriginalPrintStatFuncsForHook[256])(Stat stat);
void (*OriginalPrintExprFuncsForHook[256])(Expr expr);

/****************************************************************************
**
** These functions install implementations of eval/expr functions,
** ensuring they are set up correctly if any hooks are already active.
*/

void InstallEvalBoolFunc(Int pos, Obj (*expr)(Expr))
{
    OriginalEvalBoolFuncsForHook[pos] = expr;
    HashLock(&activeHooks);
    if (!HookActiveCount) {
        EvalBoolFuncs[pos] = expr;
    }
    HashUnlock(&activeHooks);
}

void InstallEvalExprFunc(Int pos, Obj (*expr)(Expr))
{
    OriginalEvalExprFuncsForHook[pos] = expr;
    HashLock(&activeHooks);
    if (!HookActiveCount) {
        EvalExprFuncs[pos] = expr;
    }
    HashUnlock(&activeHooks);
}

void InstallExecStatFunc(Int pos, UInt (*stat)(Stat))
{
    OriginalExecStatFuncsForHook[pos] = stat;
    HashLock(&activeHooks);
    if (!HookActiveCount) {
        ExecStatFuncs[pos] = stat;
    }
    HashUnlock(&activeHooks);
}

void InstallPrintStatFunc(Int pos, void (*stat)(Stat))
{
    OriginalPrintStatFuncsForHook[pos] = stat;
    HashLock(&activeHooks);
    if(!PrintHookActive) {
        PrintStatFuncs[pos] = stat;
    }
    HashUnlock(&activeHooks);
}

void InstallPrintExprFunc(Int pos, void (*expr)(Expr))
{
    OriginalPrintExprFuncsForHook[pos] = expr;
    HashLock(&activeHooks);
    if(!PrintHookActive) {
        PrintExprFuncs[pos] = expr;
    }
    HashUnlock(&activeHooks);
}

UInt ProfileExecStatPassthrough(Stat stat)
{
    GAP_HOOK_LOOP(visitStat, stat);
    return OriginalExecStatFuncsForHook[TNUM_STAT(stat)](stat);
}

Obj ProfileEvalExprPassthrough(Expr stat)
{
    GAP_HOOK_LOOP(visitStat, stat);
    return OriginalEvalExprFuncsForHook[TNUM_STAT(stat)](stat);
}

Obj ProfileEvalBoolPassthrough(Expr stat)
{
    /* There are two cases we must pass through without touching */
    /* From TNUM_EXPR */
    if (IS_REFLVAR(stat)) {
        return OriginalEvalBoolFuncsForHook[T_REFLVAR](stat);
    }
    if (IS_INTEXPR(stat)) {
        return OriginalEvalBoolFuncsForHook[T_INTEXPR](stat);
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
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
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

    /* return success                                                      */
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
