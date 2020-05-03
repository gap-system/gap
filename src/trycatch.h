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

#include <string.h>    // for memcpy


/****************************************************************************
**
*S  GAP_TRY
*S  GAP_CATCH
**
**  These two macros implement a kind of "poor man's exception handler".
**  See also `read.h` for the two related macros TRY_IF_NO_ERROR and
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
**  Note that GAP_TRY must ALWAYS be used together with GAP_CATCH; otherwise
**  STATE(ReadJmpError) will not be restored properly, which can lead to
**  crashes later on. To help catch violations of this rule, we introduce the
**  variable gap__j which is then exclusively used in GAP_CATCH. Failure to
**  use GAP_CATCH then triggers an "unused variable" compiler warning.
**
**  The implementation of these two macros (ab)uses for loops to run code
**  at the start resp. end of the following code block; in order to have
**  the loop executed exactly once, auxiliary variables gap__i resp. gap__j
**  are set to 1 initially; then used as loop condition; then in the post
**  iteration step are set to 0 to prevent further loop iterations.
*/
#define GAP_TRY                                                              \
    int          gap__i, gap__j;                                             \
    jmp_buf      gap__jmp_buf;                                               \
    volatile Int gap__recursionDepth = GetRecursionDepth();                  \
    memcpy(gap__jmp_buf, STATE(ReadJmpError), sizeof(jmp_buf));              \
    if (!setjmp(STATE(ReadJmpError)))                                        \
        for (gap__i = 1; gap__i; gap__i = 0,                                 \
            gap_restore_trycatch(gap__jmp_buf, gap__recursionDepth))


// TODO: call SetRecursionDepth(recursionDepth); in GAP_CATCH; but for that we
// need perhaps a helper function
#define GAP_CATCH                                                            \
    else for (gap__j = 1,                                                    \
              gap_restore_trycatch(gap__jmp_buf, gap__recursionDepth);       \
              gap__j; gap__j = 0)

// helper function for use by GAP_TRY and GAP_CATCH
static inline int gap_restore_trycatch(jmp_buf jb, int recursionDepth)
{
    memcpy(STATE(ReadJmpError), jb, sizeof(jmp_buf));
    SetRecursionDepth(recursionDepth);
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

#endif
