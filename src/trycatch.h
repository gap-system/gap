/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This module declares the functions to read  expressions  and  statements.
*/

#ifndef GAP_TRYCATCH_H
#define GAP_TRYCATCH_H

#include "funcs.h"    // for SetRecursionDepth
#include "gapstate.h"
#include "system.h"    // for NORETURN

#include <setjmp.h>
#include <string.h>    // for memcpy


/****************************************************************************
**
*T  TryCatchMode
*T  TryCatchHandler
*F  RegisterTryCatchHandler()
*F  InvokeTryCatchHandler()
**
**  The function RegisterTryCatchHandler() allows the installation of
**  global exception handlers that are being called whenever GAP_TRY or
**  GAP_CATCH code is executed. It returns 1 if installing the
**  handler was successful, 0 otherwise. Installation can only fail if one
**  attempts to install more handlers than the allotted maximum (currently
**  16).
**
**  The mode parameter of the handler function signals whether it has been
**  called at the beginning of the section, at the end of the section
**  without an error being raised, or at the end of a section with an error
**  being raised, respectively. The function InvokeTryCatchHandler() is
**  used to invoke those handlers as needed.
*/
typedef enum { TryEnter = 0, TryLeave = 1, TryCatch = 2 } TryCatchMode;

typedef void (*TryCatchHandler)(TryCatchMode mode);

int  RegisterTryCatchHandler(TryCatchHandler func);
void InvokeTryCatchHandler(TryCatchMode mode);

/****************************************************************************
**
*S  GAP_TRY
*S  GAP_CATCH
**
**  These two macros implement a kind of "poor man's exception handler".
**  See also `read.c` for the two related macros TRY_IF_NO_ERROR and
**  CATCH_ERROR (which have special code for use in the GAP "reader",
**  and should not be used elsewhere).
**
**  To use GAP_TRY and GAP_CATCH, write code like this:
**
**    GAP_TRY
**    {
**       ... code which might trigger a GAP error ...
**    }
**    GAP_CATCH
**    {
**       ... error handler ...
**    }
**
**  WARNING: it is not safe to use `return` inside a GAP_TRY block; doing so
**  would leave STATE(ReadJmpError) in an inconsistent state, which can lead
**  to crashes later on.
**
**  Note that any GAP_TRY must ALWAYS be followed by a GAP_CATCH block.
**  Failure to do so triggers an "unused variable" compiler warning.
**
**  The implementation of these two macros (ab)uses for loops to run code
**  at the start resp. end of the following code block; in order to have
**  the loop executed exactly once, auxiliary variables gap__i resp. gap__j
**  are set to 1 initially; then used as loop condition; then in the post
**  iteration step are set to 0 to prevent further loop iterations.
*/
#define GAP_TRY                                                              \
    int             gap__i, gap__j;                                          \
    GAP_TryCatchEnv gap__env;                                                \
    gap_safe_trycatch(&gap__env);                                            \
    InvokeTryCatchHandler(TryEnter);                                         \
    if (!_setjmp(STATE(ReadJmpError)))                                       \
        for (gap__i = 1; gap__i; gap__i = 0,                                 \
            InvokeTryCatchHandler(TryLeave),                                 \
            gap_restore_trycatch(&gap__env))

#define GAP_CATCH                                                            \
    else for (gap__j = 1, InvokeTryCatchHandler(TryCatch),                   \
              gap_restore_trycatch(&gap__env);                               \
              gap__j; gap__j = 0)

typedef struct {
    volatile int tryCatchDepth;
    volatile Int recursionDepth;
    jmp_buf      jb;
} GAP_TryCatchEnv;

// helper function for use by GAP_TRY and GAP_CATCH
static inline int gap_safe_trycatch(GAP_TryCatchEnv * env)
{
    memcpy(env->jb, STATE(ReadJmpError), sizeof(jmp_buf));
    env->recursionDepth = GetRecursionDepth();
    env->tryCatchDepth = STATE(TryCatchDepth)++;
    return 0;
}

static inline int gap_restore_trycatch(GAP_TryCatchEnv * env)
{
    memcpy(STATE(ReadJmpError), env->jb, sizeof(jmp_buf));
    SetRecursionDepth(env->recursionDepth);
    STATE(TryCatchDepth) = env->tryCatchDepth;
    return 0;
}

/****************************************************************************
**
*F  GAP_THROW
**
**  `GAP_THROW` raises an "exception" by invoking `longjmp` which can be
**  caught via `GAP_TRY` and `GAP_CATCH`.
*/
void GAP_THROW(void) NORETURN;


/****************************************************************************
**
*F  RegisterThrowObserver( <func> )
**
**  Register a function to be called each time GAP_THROW is called.
**  Returns 1 on success, 0 if the table of functions is already full.
**  This function is idempotent -- if a function is passed multiple times
**  it is still only registered once.
*/
typedef void (*ThrowObserver)(int depth);

int RegisterThrowObserver(ThrowObserver func);


#endif
