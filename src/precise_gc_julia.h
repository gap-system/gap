/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This header exposes GAP-owned wrappers for runtime GC rooting. In Julia-GC
**  builds it maps onto Julia's GC frame macros; in other configurations it
**  compiles away to no-ops.
*/

#ifndef GAP_PRECISE_GC_JULIA_H
#define GAP_PRECISE_GC_JULIA_H

#include "precise_gc.h"

#if defined(USE_JULIA_GC)
#include <julia.h>

#define GAP_GC_PUSH1(arg1) JL_GC_PUSH1(arg1)
#define GAP_GC_PUSH2(arg1, arg2) JL_GC_PUSH2(arg1, arg2)
#define GAP_GC_PUSH3(arg1, arg2, arg3) JL_GC_PUSH3(arg1, arg2, arg3)
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4) JL_GC_PUSH4(arg1, arg2, arg3, arg4)
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5) \
    JL_GC_PUSH5(arg1, arg2, arg3, arg4, arg5)
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6) \
    JL_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6)
#define GAP_GC_PUSHARGS(rts, n) JL_GC_PUSHARGS(rts, n)
#define GAP_GC_POP() JL_GC_POP()

#else

#define GAP_GC_PUSH1(arg1) ((void)0)
#define GAP_GC_PUSH2(arg1, arg2) ((void)0)
#define GAP_GC_PUSH3(arg1, arg2, arg3) ((void)0)
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4) ((void)0)
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5) ((void)0)
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6) ((void)0)
#define GAP_GC_PUSHARGS(rts, n) ((void)0)
#define GAP_GC_POP() ((void)0)

#endif

#endif
