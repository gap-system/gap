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

#ifndef GAP_HOOKINTRPRTR_H
#define GAP_HOOKINTRPRTR_H

#include "common.h"

void InstallEvalBoolFunc(Int, EvalBoolFunc);
void InstallEvalExprFunc(Int, EvalExprFunc);
void InstallExecStatFunc(Int, ExecStatFunc);


/****************************************************************************
**
** Store the true values of each function we wrap for hooking. These always
** store the correct values and are never changed.
**
** These are provided for interpreter hooks to call the original methods.
*/

extern ExecStatFunc OriginalExecStatFuncsForHook[256];

extern EvalExprFunc OriginalEvalExprFuncsForHook[256];
extern EvalBoolFunc OriginalEvalBoolFuncsForHook[256];


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
    void (*visitInterpretedStat)(int fileid, int line);
    void (*enterFunction)(Obj func);
    void (*leaveFunction)(Obj func);
    void (*registerStat)(int fileid, int line, int type);
    void (*registerInterpretedStat)(int fileid, int line);
    const char * hookName;
};


enum { MAX_HOOK_COUNT = 6 };

extern struct InterpreterHooks * activeHooks[MAX_HOOK_COUNT];

BOOL ActivateHooks(struct InterpreterHooks * hook);
BOOL DeactivateHooks(struct InterpreterHooks * hook);

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

#define GAP_HOOK_LOOP(member, ...)                                           \
    do {                                                                     \
        struct InterpreterHooks * hook;                                      \
        for (int i = 0; i < MAX_HOOK_COUNT; ++i) {                           \
            hook = activeHooks[i];                                           \
            if (hook && hook->member) {                                      \
                (hook->member)(__VA_ARGS__);                                 \
            }                                                                \
        }                                                                    \
    } while (0)

EXPORT_INLINE void VisitStatIfHooked(Stat stat)
{
    GAP_HOOK_LOOP(visitStat, stat);
}

EXPORT_INLINE void HookedLineIntoFunction(Obj func)
{
    GAP_HOOK_LOOP(enterFunction, func);
}


EXPORT_INLINE void HookedLineOutFunction(Obj func)
{
    GAP_HOOK_LOOP(leaveFunction, func);
}

EXPORT_INLINE void RegisterStatWithHook(int fileid, int line, int type)
{
    GAP_HOOK_LOOP(registerStat, fileid, line, type);
}

EXPORT_INLINE void InterpreterHook(int fileid, int line, Int skipped)
{
    GAP_HOOK_LOOP(registerInterpretedStat, fileid, line);
    if (!skipped) {
        GAP_HOOK_LOOP(visitInterpretedStat, fileid, line);
    }
}


/****************************************************************************
**
*F  InitInfoHookIntrprtr() . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoHookIntrprtr(void);

#endif    // GAP_HOOKINTRPRTR_H
