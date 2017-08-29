/****************************************************************************
**
*W  hookintrprtr.h                    GAP source              Chris Jefferson
**
**
*Y  Copyright (C) 2017 The GAP Group
**
**  This file contains functions related to hooking the interpreter.
**
*/

#ifndef GAP_HOOKINTRPRTR_H
#define GAP_HOOKINTRPRTR_H

#include <src/exprs.h>

void InstallEvalBoolFunc(Int, Obj (*)(Expr));
void InstallEvalExprFunc(Int, Obj (*)(Expr));
void InstallExecStatFunc(Int, UInt (*)(Stat));
void InstallPrintStatFunc(Int, void (*)(Stat));
void InstallPrintExprFunc(Int, void (*)(Expr));


/****************************************************************************
**
** Store the true values of each function we wrap for hooking. These always
** store the correct values and are never changed.
**
** These are provided for interpreter hooks to call the original methods.
*/

extern UInt (*OriginalExecStatFuncsForHook[256])(Stat stat);

extern Obj (*OriginalEvalExprFuncsForHook[256])(Expr expr);
extern Obj (*OriginalEvalBoolFuncsForHook[256])(Expr expr);

extern void (*OriginalPrintStatFuncsForHook[256])(Stat stat);
extern void (*OriginalPrintExprFuncsForHook[256])(Expr expr);


/****************************************************************************
**
** A struct to represent the hooks allowed into the interpreter
**
**
** This struct represents a list of functions which will be called by the
** interpreter every time statements are executed. Note that the existence
** of any hooks slows GAP down measurably, so don't leave them in if you
** don't need them, and try to make it clear to users they are activated,
** and how to deactivate them.
**
** There are four functions:
**
** * 'visitStat' is called for every visited Stat (and Expr) from the
**    GAP bytecode.
** * 'enterFunction' and 'leaveFunction' are called whenever a function
**    is entered, or left. This is passed the function which is being
**    entered (or left)
** * 'registerStat' is called whenever a statement is read from a text
**    file. Note that you will only see files which are read while your
**    hooks are running.
** * 'hookName' is a string is used in debugging messages to describe
**    the currently active hooks.
**
** This is a sharp tool -- use with care! Look at 'profiling.c', and
** the 'debugger' package for guidance on usage, in particular look
** at FILENAMEID_STAT, FILENAME_STAT and LINE_STAT to find out which
** statement is running.
**
** Remember if you run GAP code during any of these functions, it will
** reinvoke your hooks!
*/

struct InterpreterHooks {
    void (*visitStat)(Stat stat);
    void (*enterFunction)(Obj func);
    void (*leaveFunction)(Obj func);
    void (*registerStat)(Stat stat);
    const char * hookName;
};


enum { HookCount = 6 };

extern struct InterpreterHooks * activeHooks[HookCount];

Int ActivateHooks(struct InterpreterHooks * hook);
Int DeactivateHooks(struct InterpreterHooks * hook);

/****************************************************************************
**
** A struct to represent the hooks allowed into printing functions
**
**
** This struct represents a list of functions which will be called whenever
** a statement or expression is printed. They can be used to provide
** simple customisation of printing. At the moment they are used by
** profiling.c, to mark statements which have been executed.
** Look at that code to get an idea how to use them.
*/
struct PrintHooks {
    void (*printStatPassthrough)(Stat stat);
    void (*printExprPassthrough)(Expr stat);
};

void ActivatePrintHooks(struct PrintHooks * hook);
void DeactivatePrintHooks(struct PrintHooks * hook);

/****************************************************************************
**
** We can only store a fixed number of files, and files, in statements.
**
** Whenever an overflow occurs we do not mark that statement with its line
** or file, and call these functions to record the fact information is
** missing, so we can inform users later.
*/

void ReportLineNumberOverflowOccured();
void ReportFileNumberOverflowOccured();

/****************************************************************************
**
** We need the functions in the next three functions to be in the header,
** so they can be inlined away. The only functionality here which should
** be publicly used is 'VisitStatIfHooked',
** 'HookedLineIntoFunction' and 'HookedLineOutFunction'.
**
** 'RegisterStatWithHook' is used because some parts of the interpreter
** skip executing some statements by "cleverness", but we still want them
** to be visible to code coverage, so they appear 'executed'.
*/

/* Represents a loop we use frequently. We store 'hook' in a local
** variable to avoid race conditions.
*/

#define GAP_HOOK_LOOP(member, argument)                                      \
    do {                                                                     \
        Int i;                                                               \
        struct InterpreterHooks * hook;                                      \
        for (i = 0; i < HookCount; ++i) {                                    \
            hook = activeHooks[i];                                           \
            if (hook && hook->member) {                                      \
                (hook->member)(argument);                                    \
            }                                                                \
        }                                                                    \
    } while(0)

static inline void VisitStatIfHooked(Stat stat)
{
    GAP_HOOK_LOOP(visitStat, stat);
}

static inline void HookedLineIntoFunction(Obj func)
{
    GAP_HOOK_LOOP(enterFunction, func);
}


static inline void HookedLineOutFunction(Obj func)
{
    GAP_HOOK_LOOP(leaveFunction, func);
}

static inline void RegisterStatWithHook(Stat func)
{
    GAP_HOOK_LOOP(registerStat, func);
}


/****************************************************************************
**
*F  InitInfoHookIntrprtr() . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoHookIntrprtr(void);

#endif    // GAP_HOOKINTRPRTR_H
