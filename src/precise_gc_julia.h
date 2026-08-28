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
#ifdef __cplusplus
extern "C++" {
#endif
#include <julia.h>
#ifdef __cplusplus
}
#endif


#define GAP_GC_PUSH1(arg1) JL_GC_PUSH1(arg1)
#define GAP_GC_PUSH2(arg1, arg2) JL_GC_PUSH2(arg1, arg2)
#define GAP_GC_PUSH3(arg1, arg2, arg3) JL_GC_PUSH3(arg1, arg2, arg3)
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4) JL_GC_PUSH4(arg1, arg2, arg3, arg4)
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5) \
    JL_GC_PUSH5(arg1, arg2, arg3, arg4, arg5)
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6) \
    JL_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6)
#define GAP_GC_PUSH7(arg1, arg2, arg3, arg4, arg5, arg6, arg7) \
    JL_GC_PUSH7(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
#define GAP_GC_PUSH8(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) \
    JL_GC_PUSH8(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
#define GAP_GC_PUSH9(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) \
    JL_GC_PUSH9(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
#define GAP_GC_PUSHARGS(rts, n) JL_GC_PUSHARGS(rts, n)
#define GAP_GC_POP() JL_GC_POP()

#ifdef GAP_KERNEL_DEBUG
/****************************************************************************
**
*F  GAP_IsRootedSlot(<slot>) . . . is a slot registered in a live GC frame?
**
**  For asserting that a state struct on the C stack really was rooted by
**  whoever created it. A precise collector cannot find such structs itself,
**  and neither the compiler nor the GC analyzer will point out a missing
**  root -- the analyzer checks rooting within a function, not whether a
**  struct on the stack holds GAP objects.
**
**  Only frames pushed by GAP_GC_PUSH* are considered: those hold slot
**  addresses, which is what we are looking for. GAP_GC_PUSHARGS frames hold
**  values instead and are skipped.
*/
static inline BOOL GAP_IsRootedSlot(const void * slot) GAP_GC_NOTSAFEPOINT
{
    for (jl_gcframe_t * f = jl_pgcstack; f; f = f->prev) {
        size_t nroots = f->nroots;
        if (!(nroots & 1))
            continue;
        void ** roots = ((void **)f) + 2;
        for (size_t i = 0; i < (nroots >> 2); i++)
            if (roots[i] == slot)
                return TRUE;
    }
    return FALSE;
}
#endif


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
#define GAP_GC_PUSHARGS(rts, n) ((void)0)
#define GAP_GC_POP() ((void)0)

#ifdef GAP_KERNEL_DEBUG
// Conservative collectors find these structs by scanning the C stack, so
// there is nothing to assert; see the Julia branch above.
static inline BOOL GAP_IsRootedSlot(const void * slot) GAP_GC_NOTSAFEPOINT
{
    (void)slot;
    return TRUE;
}
#endif


#endif

/****************************************************************************
**
*F  GAP_GC_PUSH_ROOTS( <n>, (<slots>) ) . . . root a composed list of n slots
**
**  Push <n> slots given as a parenthesised, comma-separated list, so that the
**  per-struct *_ROOTS(p) macros can be fed to the fixed-arity push macros:
**
**      GAP_GC_PUSH_ROOTS(9, (&local, READER_STATE_ROOTS(rs)));
**
**  The extra parentheses defer expansion until the list has been substituted,
**  which is what splits it into separate macro arguments.
**
**  <n> must be a literal 1..9, not an expression: it is pasted onto the macro
**  name. That is deliberate. If a *_ROOTS list gains or loses a slot, every
**  call site stops matching its stated count and fails to compile, rather
**  than silently rooting the wrong number of slots.
*/
#define GAP_GC_PUSH_ROOTS(n, roots)  GAP_GC_PUSH_ROOTS_(n, roots)
#define GAP_GC_PUSH_ROOTS_(n, roots) GAP_GC_PUSH##n roots

#endif
