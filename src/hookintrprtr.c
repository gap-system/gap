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

#include <src/system.h>
#include <src/gapstate.h>
#include <src/sysfiles.h>

#include <src/gasman.h>
#include <src/objects.h>
#include <src/scanner.h>

#include <src/gap.h>

#include <src/gvars.h>

#include <src/calls.h>

#include <src/precord.h>
#include <src/records.h>

#include <src/lists.h>
#include <src/plist.h>
#include <src/stringobj.h>

#include <src/bool.h>

#include <src/code.h>
#include <src/exprs.h>
#include <src/vars.h>

#include <src/intrprtr.h>

#include <src/ariths.h>

#include <src/stats.h>

#include <assert.h>

#include <src/hookintrprtr.h>

#include <src/hpc/thread.h>

#include <src/gaputils.h>

/* List of active hooks */
struct InterpreterHooks * activeHooks[HookCount];

/* Number of active hooks */
static Int HookActiveCount;

/* If a print hook is current active */
static Int PrintHookActive;

/* Forward declaration */
void CheckPrintOverflowWarnings(void);

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

UInt ProfileStatPassthrough(Stat stat)
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

    CheckPrintOverflowWarnings();

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
        ExecStatFuncs[i] = ProfileStatPassthrough;
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
        for (i = 0; i < ARRAY_SIZE(ExecStatFuncs); i++) {
            ExecStatFuncs[i] = OriginalExecStatFuncsForHook[i];
            EvalExprFuncs[i] = OriginalEvalExprFuncsForHook[i];
            EvalBoolFuncs[i] = OriginalEvalBoolFuncsForHook[i];
        }
    }

    HashUnlock(&activeHooks);
    return 1;
}

/****************************************************************************
**
** These variables store if we have overflowed either 2^16 lines, or files.
** In this case GAP will stop marking the line and file of statements.
** We print a warning to tell users that this happens, either immediately
** (if hooking is active) or when hooking is next activated if not.
**/

static Int HaveReportedLineProfileOverflow;
static Int ShouldReportLineProfileOverflow;

static Int HaveReportedFileProfileOverflow;
static Int ShouldReportFileProfileOverflow;

// This function only exists to allow testing of these overflow checks
Obj FuncCLEAR_PROFILE_OVERFLOW_CHECKS(Obj self)
{
    HaveReportedLineProfileOverflow = 0;
    ShouldReportLineProfileOverflow = 0;

    HaveReportedFileProfileOverflow = 0;
    ShouldReportFileProfileOverflow = 0;

    return 0;
}

void CheckPrintOverflowWarnings(void)
{
    if (!HaveReportedLineProfileOverflow && ShouldReportLineProfileOverflow) {
        HaveReportedLineProfileOverflow = 1;
        Pr("#I Interpreter hooking only works on the first 65,535 lines\n"
           "#I of each file (this warning will only appear once).\n"
           "#I This will effect profiling and debugging.\n",
           0L, 0L);
    }

    if (!HaveReportedFileProfileOverflow && ShouldReportFileProfileOverflow) {
        HaveReportedFileProfileOverflow = 1;
        Pr("#I Interpreter hooking only works on the first 65,535 read files\n"
           "#I of each file (this warning will only appear once).\n"
           "#I This will effect profiling and debugging.\n",
           0L, 0L);
    }
}

void ReportLineNumberOverflowOccured(void)
{
    ShouldReportLineProfileOverflow = 1;
    if (HookActiveCount) {
        CheckPrintOverflowWarnings();
    }
}

void ReportFileNumberOverflowOccured(void)
{
    ShouldReportFileProfileOverflow = 1;
    if (HookActiveCount) {
        CheckPrintOverflowWarnings();
    }
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
    Int i;

    if (!PrintHookActive) {
        return;
    }
    PrintHookActive = 0;
    for (i = 0; i < ARRAY_SIZE(ExecStatFuncs); i++) {
        PrintStatFuncs[i] = OriginalPrintStatFuncsForHook[i];
        PrintExprFuncs[i] = OriginalPrintExprFuncsForHook[i];
    }
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
    GVAR_FUNC(CLEAR_PROFILE_OVERFLOW_CHECKS, 0, ""),
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
    MODULE_BUILTIN, /* type                           */
    "hookintrprtr", /* name                           */
    0,              /* revision entry of c file       */
    0,              /* revision entry of h file       */
    0,              /* version                        */
    0,              /* crc                            */
    InitKernel,     /* initKernel                     */
    InitLibrary,    /* initLibrary                    */
    0,              /* checkInit                      */
    0,              /* preSave                        */
    0,              /* postSave                       */
    0               /* postRestore                    */
};

StructInitInfo * InitInfoHookIntrprtr(void)
{
    return &module;
}
