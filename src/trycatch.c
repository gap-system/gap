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

#include "trycatch.h"

#include "gaputils.h"

#include <stdio.h>

static ThrowObserver throwObservers[16];

int RegisterThrowObserver(ThrowObserver func)
{
    for (int i = 0; i < ARRAY_SIZE(throwObservers); ++i) {
        if (throwObservers[i] == func) {
            return 1;
        }
        if (throwObservers[i] == 0) {
            throwObservers[i] = func;
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
    int depth = STATE(TryCatchDepth);
    for (int i = 0; i < ARRAY_SIZE(throwObservers) && throwObservers[i]; ++i)
        (throwObservers[i])(depth);
    _longjmp(STATE(ReadJmpError), 1);
}
