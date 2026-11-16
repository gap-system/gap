/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This header exposes GAP-owned wrappers for runtime GC rooting. In precise
**  mode (the Julia GC built with DISABLE_STACK_SCAN) it maps onto Julia's GC
**  frame macros; in every other configuration it compiles away to no-ops,
**  except that GAP_GC_PUSHARGS still supplies its array.
*/

#ifndef GAP_PRECISE_GC_JULIA_H
#define GAP_PRECISE_GC_JULIA_H

#include "precise_gc.h"

#if defined(USE_JULIA_GC)
#ifdef __cplusplus
extern "C++" {
#endif
#include <julia.h>
#ifdef __cplusplus
}
#endif

// Precise mode: the Julia GC without the conservative stack scan. Only then
// do the rooting macros push frames. With the scan on, the frames would be
// redundant, and Julia before 1.14 (JuliaLang/julia#62889) crashes on the
// immediates they hold. The GC analyzer always sees the frames.
#if defined(DISABLE_STACK_SCAN) || defined(__clang_gcanalyzer__)
#define GAP_GC_PRECISE 1
#endif

#ifdef DISABLE_STACK_SCAN
#if JULIA_VERSION_MAJOR == 1 && JULIA_VERSION_MINOR < 14
#error "precise mode (DISABLE_STACK_SCAN) needs Julia 1.14 or later"
#endif
#endif
#endif


#ifdef GAP_GC_PRECISE

// A root may be the address of a volatile local (one that is modified
// between GAP_TRY and GAP_CATCH); the cast drops the qualifier the frame
// cannot carry.
#define GAP_GC_ROOT_(a) ((void *)(a))

#define GAP_GC_PUSH1(arg1) JL_GC_PUSH1(GAP_GC_ROOT_(arg1))
#define GAP_GC_PUSH2(arg1, arg2) JL_GC_PUSH2(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2))
#define GAP_GC_PUSH3(arg1, arg2, arg3) \
    JL_GC_PUSH3(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3))
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4) \
    JL_GC_PUSH4(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4))
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5) \
    JL_GC_PUSH5(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5))
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6) \
    JL_GC_PUSH6(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6))
#define GAP_GC_PUSH7(arg1, arg2, arg3, arg4, arg5, arg6, arg7) \
    JL_GC_PUSH7(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6), \
                GAP_GC_ROOT_(arg7))
#define GAP_GC_PUSH8(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) \
    JL_GC_PUSH8(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6), \
                GAP_GC_ROOT_(arg7), GAP_GC_ROOT_(arg8))
#define GAP_GC_PUSH9(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) \
    JL_GC_PUSH9(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6), \
                GAP_GC_ROOT_(arg7), GAP_GC_ROOT_(arg8), GAP_GC_ROOT_(arg9))
#define GAP_GC_PUSHARGS(rts, n) JL_GC_PUSHARGS(rts, n)
#define GAP_GC_POP() JL_GC_POP()

#else


#define GAP_GC_PUSH1(arg1) ((void)0)
#define GAP_GC_PUSH2(arg1, arg2) ((void)0)
#define GAP_GC_PUSH3(arg1, arg2, arg3) ((void)0)
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4) ((void)0)
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5) ((void)0)
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6) ((void)0)
#define GAP_GC_PUSH7(arg1, arg2, arg3, arg4, arg5, arg6, arg7) ((void)0)
#define GAP_GC_PUSH8(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) \
    ((void)0)
#define GAP_GC_PUSH9(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) \
    ((void)0)
// The array is still provided: it lives on the C stack, which the collectors
// of these configurations scan, so a caller need not know which mode it is in.
// The builtin needs no header; <alloca.h> does not exist on OpenBSD.
#define GAP_GC_PUSHARGS(rts, n) \
    ((rts) = (__typeof__(rts))__builtin_alloca(sizeof(void *) * (n)))
#define GAP_GC_POP() ((void)0)

#endif

#endif
