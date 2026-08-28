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
 * These annotation spellings match Julia's static analysis tooling. We define
 * GAP-local wrapper macros instead of depending on Julia's internal analyzer
 * header so that GAP can control how these are exposed.
 *
 * Nothing here affects a normal build: without one of the defines below every
 * macro expands to nothing, so GASMAN and Boehm builds are unchanged. The
 * runtime rooting macros in "precise_gc_julia.h" behave the same way, and
 * expand to `((void)0)` unless the Julia GC is in use.
 *
 *
 *  The two analyses
 *  ----------------
 *
 * Two independent checks are modelled, each selected by its own define:
 *
 *   __clang_gcanalyzer__      Julia's GCChecker plugin. It checks that a value
 *                             the GC manages is reachable from a root whenever
 *                             a collection could happen. Run it with
 *                             dev/run-julia-gc-analyzer.sh.
 *
 *   __clang_safetyanalysis__  Clang Thread Safety Analysis, the counterpart to
 *                             Julia's `make -C src safesrc`. It checks the
 *                             safepoint annotations against each other. Run it
 *                             with dev/run-safepoint-check.sh.
 *
 * The two have opposite defaults, which is the main thing to keep straight:
 *
 *   - To the GCChecker an unannotated function may safepoint. Promising it
 *     does not is opting out, and it verifies the promise.
 *   - To the safety analysis an unannotated function may NOT safepoint. Every
 *     function that can must say so, and it is flagged as soon as it calls one
 *     that does without saying so itself.
 *
 * So a function that allocates needs GAP_GC_CANSAFEPOINT, and one that must
 * never allocate -- a marking function, say -- needs GAP_GC_NOTSAFEPOINT.
 * The two must never appear on the same declaration: if the safety analysis
 * asks for GAP_GC_CANSAFEPOINT somewhere that already promises
 * GAP_GC_NOTSAFEPOINT, one of the two is wrong, and adding the second only
 * hides which. See the panic path in "system.h" for the third option: a
 * function that never returns can promise callers no safepoint while its own
 * body opts out of the analysis with GAP_GC_NO_SAFEPOINT_ANALYSIS.
 *
 *
 *  Where an annotation goes
 *  ------------------------
 *
 * Placement is part of each annotation's meaning, and the two are easy to mix
 * up, so the comments below say which of the two each one takes:
 *
 *   void AddList(Obj list, Obj obj GAP_GC_ROOTED_BY_ARG(0)) GAP_GC_CANSAFEPOINT;
 *                          ^ on the parameter                ^ on the function
 *
 * Argument indices are zero-based positions in the parameter list, counting
 * every parameter and not just the `Obj` ones.
 *
 * Put the annotation on a function's FIRST declaration, normally the one in
 * the header. Clang silently ignores an annotation that appears only on a
 * later declaration, so one written on the definition of a function declared
 * in a header does nothing at all, and the mistake is invisible. The
 * julia-first-decl-annotations clang-tidy check catches this; see
 * dev/julia-gc-handoff.md for how to run it.
 *
 *
 *  Rooting, in one example
 *  -----------------------
 *
 * The GCChecker cares about values held in C locals across a possible
 * collection. A local is not a root by itself, so this is wrong:
 *
 *     Obj list = NEW_PLIST(T_PLIST, 2);
 *     Obj elm  = NEW_STRING(10);      // may collect, and may move `list`
 *     SET_ELM_PLIST(list, 1, elm);
 *
 * Rooting `list` with a frame fixes it. Note that the frame stores the
 * ADDRESS of the local, so every rooted local must be initialised before the
 * frame is pushed -- the collector reads it immediately:
 *
 *     Obj list = 0, elm = 0;
 *     GAP_GC_PUSH2(&list, &elm);
 *     list = NEW_PLIST(T_PLIST, 2);
 *     elm  = NEW_STRING(10);
 *     SET_ELM_PLIST(list, 1, elm);
 *     GAP_GC_POP();
 *
 * Use the fixed-arity GAP_GC_PUSH1 .. GAP_GC_PUSH9 for GAP `Obj` locals.
 * GAP_GC_PUSHARGS stores values rather than addresses and reads them with
 * Julia's low-bit tag semantics, which collide with GAP's tagged immediates,
 * so it is only safe for arrays that can never hold an immediate.
 *
 * The annotations below let a callee describe its rooting to the analyzer, so
 * that callers need no frame of their own. `GAP_GC_ROOTED_BY_ARG(0)` on
 * AddList's second parameter, for instance, says the value is stored into the
 * first argument and is rooted by whatever roots that.
 */
#if defined(__clang_gcanalyzer__)

/*
 * Rooting annotations. Argument indices are zero-based positions in the
 * parameter list. Note that the placement differs per annotation: some belong
 * on a parameter, others on the function itself.
 */

// On a parameter: the root protecting it also protects the return value.
#define GAP_GC_PROPAGATES_ROOT \
    __attribute__((annotate("julia_propagates_root")))
// On the function: the return value is read from the child of argument <root>
// at the position given by argument <index>, so the analyzer can track a later
// overwrite of exactly that child. Non-literal indices degrade to plain
// GAP_GC_PROPAGATES_ROOT.
#define GAP_GC_PROPAGATES_ROOT_INDEXED(root, index) \
    __attribute__((annotate("julia_propagates_root_indexed:" #root ":" #index)))
// On a parameter: it is stored into argument <n>, and inherits its root.
#define GAP_GC_ROOTED_BY_ARG(n) \
    __attribute__((annotate("julia_rooted_by_arg:" #n)))
// On a parameter: like GAP_GC_ROOTED_BY_ARG, but stored into the child of
// argument <root> at the position given by argument <index>.
#define GAP_GC_ROOTED_BY_ARG_INDEXED(root, index) \
    __attribute__((annotate("julia_rooted_by_arg_indexed:" #root ":" #index)))
// On an out-parameter: the value written through it is rooted by argument <n>.
#define GAP_GC_OUT_ROOTED_BY_ARG(n) \
    __attribute__((annotate("julia_out_rooted_by_arg:" #n)))
// On a parameter: it is rooted by the function's return value.
#define GAP_GC_ROOTED_BY_RETURN \
    __attribute__((annotate("julia_rooted_by_return")))
// On a variadic function: its variadic arguments are rooted by the return
// value. Individual variadic arguments cannot be annotated.
#define GAP_GC_ROOTED_VARARGS \
    __attribute__((annotate("julia_rooted_varargs")))
// On a parameter: it may be passed even if not rooted.
#define GAP_GC_MAYBE_UNROOTED \
    __attribute__((annotate("julia_maybe_unrooted")))
// On a parameter: the caller passes a rooted slot, so values assigned through
// it count as rooted.
#define GAP_GC_REQUIRE_ROOTED_SLOT \
    __attribute__((annotate("julia_require_rooted_slot")))
// On a global, or on a function to mean its return value: always rooted.
#define GAP_GC_GLOBALLY_ROOTED \
    __attribute__((annotate("julia_globally_rooted")))

// Function does not hit GC safepoints.
#define GAP_GC_NOTSAFEPOINT \
    __attribute__((annotate("julia_not_safepoint")))
// Function may hit a GC safepoint. The GCChecker assumes this by default, so
// the annotation only matters to the thread safety analysis below.
#define GAP_GC_CANSAFEPOINT
#define GAP_GC_CANSAFEPOINT_ENTER
#define GAP_GC_CANSAFEPOINT_LEAVE
#define GAP_GC_CANSAFEPOINT_ENTER_LEAVE
#define GAP_GC_CANCALLBACK
#define GAP_GC_NO_SAFEPOINT_ANALYSIS \
    __attribute__((annotate("julia_no_safepoint_analysis")))
#define GAP_GC_NOTSAFEPOINT_ENTER \
    __attribute__((annotate("julia_notsafepoint_enter")))
#define GAP_GC_NOTSAFEPOINT_LEAVE \
    __attribute__((annotate("julia_notsafepoint_leave")))
#define GAP_GC_NOTSAFEPOINT_ENTER_CONDITIONAL(success) \
    __attribute__((annotate("julia_notsafepoint_enter_conditional:" #success)))

void JL_GC_PROMISE_ROOTED(const void * v) GAP_GC_NOTSAFEPOINT;
#define GAP_GC_PROMISE_ROOTED(v) JL_GC_PROMISE_ROOTED(v)

#elif defined(__clang_safetyanalysis__)

/*
 * The thread safety analysis models the current thread with two token
 * capabilities, mirroring Julia's model:
 *
 *   jl_notsafepoint     reentrant, held while inside a no-safepoint region,
 *   jl_gcunsaferegion   held while the thread is allowed to safepoint.
 *
 * A safepoint is permissible only while gc-unsafe and holding no no-gc lock.
 * The definitions and the guard name below match Julia's
 * src/support/analyzer_annotations.h so that both agree in translation units
 * which also include julia.h.
 */
#ifndef JL_NOTSAFEPOINT_TOKEN_DEFINED
#define JL_NOTSAFEPOINT_TOKEN_DEFINED
struct __attribute__((capability("notsafepoint"), reentrant_capability))
NOTSAFEPOINT {
    char cpp_compat;
};
struct __attribute__((capability("gcunsaferegion"))) GCUNSAFEREGION {
    char cpp_compat;
};
#ifdef __cplusplus
extern "C" {
#endif
extern struct NOTSAFEPOINT *jl_notsafepoint;
extern struct GCUNSAFEREGION *jl_gcunsaferegion;
#ifdef __cplusplus
}
#endif
#endif

// The rooting annotations say nothing about safepoints.
#define GAP_GC_PROPAGATES_ROOT
#define GAP_GC_PROPAGATES_ROOT_INDEXED(root, index)
#define GAP_GC_ROOTED_BY_ARG(n)
#define GAP_GC_ROOTED_BY_ARG_INDEXED(root, index)
#define GAP_GC_OUT_ROOTED_BY_ARG(n)
#define GAP_GC_ROOTED_BY_RETURN
#define GAP_GC_ROOTED_VARARGS
#define GAP_GC_MAYBE_UNROOTED
#define GAP_GC_REQUIRE_ROOTED_SLOT
#define GAP_GC_GLOBALLY_ROOTED

// A function holding nothing is flagged if it reaches a safepoint.
#define GAP_GC_NOTSAFEPOINT
#define GAP_GC_CANSAFEPOINT \
    __attribute__((requires_capability(jl_gcunsaferegion), \
                   requires_capability(!jl_notsafepoint)))
#define GAP_GC_CANSAFEPOINT_ENTER \
    __attribute__((requires_capability(!jl_gcunsaferegion), \
                   acquire_capability(jl_gcunsaferegion), \
                   requires_capability(!jl_notsafepoint)))
#define GAP_GC_CANSAFEPOINT_LEAVE \
    __attribute__((release_capability(jl_gcunsaferegion), \
                   requires_capability(!jl_notsafepoint)))
// Both enters and leaves the gc-unsafe region in its own body, so the function
// may be used as a callback from an unknown context.
#define GAP_GC_CANSAFEPOINT_ENTER_LEAVE \
    __attribute__((requires_capability(!jl_gcunsaferegion), \
                   requires_capability(!jl_notsafepoint)))
// Can call an arbitrary user or foreign callback.
#define GAP_GC_CANCALLBACK \
    __attribute__((requires_capability(!jl_notsafepoint)))
#define GAP_GC_NO_SAFEPOINT_ANALYSIS __attribute__((no_thread_safety_analysis))
#define GAP_GC_NOTSAFEPOINT_ENTER \
    __attribute__((acquire_capability(jl_notsafepoint)))
#define GAP_GC_NOTSAFEPOINT_LEAVE \
    __attribute__((release_capability(jl_notsafepoint)))
#define GAP_GC_NOTSAFEPOINT_ENTER_CONDITIONAL(success) \
    __attribute__((try_acquire_capability(success, jl_notsafepoint)))

#define GAP_GC_PROMISE_ROOTED(v) ((void)(v))

#else

// No analyzer: annotations compile away.
#define GAP_GC_PROPAGATES_ROOT
#define GAP_GC_PROPAGATES_ROOT_INDEXED(root, index)
#define GAP_GC_ROOTED_BY_ARG(n)
#define GAP_GC_ROOTED_BY_ARG_INDEXED(root, index)
#define GAP_GC_OUT_ROOTED_BY_ARG(n)
#define GAP_GC_ROOTED_BY_RETURN
#define GAP_GC_ROOTED_VARARGS
#define GAP_GC_MAYBE_UNROOTED
#define GAP_GC_REQUIRE_ROOTED_SLOT
#define GAP_GC_GLOBALLY_ROOTED
#define GAP_GC_NOTSAFEPOINT
#define GAP_GC_CANSAFEPOINT
#define GAP_GC_CANSAFEPOINT_ENTER
#define GAP_GC_CANSAFEPOINT_LEAVE
#define GAP_GC_CANSAFEPOINT_ENTER_LEAVE
#define GAP_GC_CANCALLBACK
#define GAP_GC_NO_SAFEPOINT_ANALYSIS
#define GAP_GC_NOTSAFEPOINT_ENTER
#define GAP_GC_NOTSAFEPOINT_LEAVE
#define GAP_GC_NOTSAFEPOINT_ENTER_CONDITIONAL(success)
#define GAP_GC_PROMISE_ROOTED(v) ((void)(v))

#endif

#endif
