/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This header provides GAP-owned wrappers for precise-GC static analysis
**  annotations. Runtime rooting macros live in "precise_gc_julia.h", so that
**  low-level headers can use the annotations without pulling in julia.h.
*/

#ifndef GAP_PRECISE_GC_H
#define GAP_PRECISE_GC_H

/*
 * These annotation spellings match Julia's GC static analyzer plugin.
 * We define GAP-local wrapper macros instead of depending on Julia's
 * internal analyzer header so that GAP can control how these are exposed.
 */
#if defined(__clang_gcanalyzer__)

// Return value keeps the root relationship of a rooted argument.
#define GAP_GC_PROPAGATES_ROOT \
    __attribute__((annotate("julia_propagates_root")))
// Function does not hit GC safepoints.
#define GAP_GC_NOTSAFEPOINT \
    __attribute__((annotate("julia_not_safepoint")))
// Argument may be passed even if not rooted.
#define GAP_GC_MAYBE_UNROOTED \
    __attribute__((annotate("julia_maybe_unrooted")))
// Callee keeps argument live across its internal safepoints.
#define GAP_GC_ROOTS_TEMPORARILY \
    __attribute__((annotate("julia_temporarily_roots")))
// Rooted argument that protects another argument.
#define GAP_GC_ROOTING_ARGUMENT \
    __attribute__((annotate("julia_rooting_argument")))
// Argument protected by a corresponding rooting argument.
#define GAP_GC_ROOTED_ARGUMENT \
    __attribute__((annotate("julia_rooted_argument")))
// Value is globally rooted for analyzer purposes.
#define GAP_GC_GLOBALLY_ROOTED \
    __attribute__((annotate("julia_globally_rooted")))

void JL_GC_PROMISE_ROOTED(void * v) GAP_GC_NOTSAFEPOINT;
#define GAP_GC_PROMISE_ROOTED(v) JL_GC_PROMISE_ROOTED(v)

#else

// No analyzer: annotations compile away.
#define GAP_GC_PROPAGATES_ROOT
#define GAP_GC_NOTSAFEPOINT
#define GAP_GC_MAYBE_UNROOTED
#define GAP_GC_ROOTS_TEMPORARILY
#define GAP_GC_ROOTING_ARGUMENT
#define GAP_GC_ROOTED_ARGUMENT
#define GAP_GC_GLOBALLY_ROOTED
#define GAP_GC_PROMISE_ROOTED(v) ((void)(v))

#endif

#endif
