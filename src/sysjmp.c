/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
*/

#include "sysjmp.h"

#include "trycatch.h"


/****************************************************************************
**
*F  RegisterSyLongjmpObserver( <func> )
**
**  Register a function to be called before longjmp is called.
**  Returns 1 on success, 0 if the table of functions is already full.
**  This function is idempotent -- if a function is passed multiple times
**  it is still only registered once.
*/

enum { signalSyLongjmpFuncsLen = 16 };

static voidfunc signalSyLongjmpFuncs[signalSyLongjmpFuncsLen];

int RegisterSyLongjmpObserver(voidfunc func)
{
    for (int i = 0; i < signalSyLongjmpFuncsLen; ++i) {
        if (signalSyLongjmpFuncs[i] == func) {
            return 1;
        }
        if (signalSyLongjmpFuncs[i] == 0) {
            signalSyLongjmpFuncs[i] = func;
            return 1;
        }
    }
    return 0;
}

enum { tryCatchFuncsLen = 16 };

static TryCatchHandler tryCatchFuncs[tryCatchFuncsLen];

int RegisterTryCatchHandler(TryCatchHandler func)
{
    for (int i = 0; i < tryCatchFuncsLen; ++i) {
        if (tryCatchFuncs[i] == func) {
            return 1;
        }
        if (tryCatchFuncs[i] == 0) {
            tryCatchFuncs[i] = func;
            return 1;
        }
    }
    return 0;
}

void InvokeTryCatchHandler(TryCatchMode mode)
{
    for (int i = 0; i < tryCatchFuncsLen && tryCatchFuncs[i]; ++i)
        (tryCatchFuncs[i])(mode);
}

void GAP_THROW(void)
{
    for (int i = 0; i < signalSyLongjmpFuncsLen && signalSyLongjmpFuncs[i]; ++i)
        (signalSyLongjmpFuncs[i])();
    longjmp(STATE(ReadJmpError), 1);
}
