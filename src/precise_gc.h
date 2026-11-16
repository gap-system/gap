/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Annotations that describe to Julia's static analyzers how a function
**  interacts with the Julia GC: whether it may trigger a collection, and how
**  the values it takes and returns are rooted. They matter to GAP with the
**  Julia GC in precise mode (see "precise_gc_julia.h"), which can only be
**  trusted with the analyzers' help.
*/

#ifndef GAP_PRECISE_GC_H
#define GAP_PRECISE_GC_H

/*
 *  What the annotations are
 *  ------------------------
 *
 * The annotations change nothing in compiled code: each expands to nothing
 * unless one of the two analyzers below processes the file, and then to an
 * attribute that analyzer reads. The attributes are those behind Julia's own
 * annotations (JL_NOTSAFEPOINT and the others in its analyzer_annotations.h);
 * GAP defines its own names so that it controls what they expand to, and so
 * that every header can use them without including julia.h.
 *
 * There are two kinds:
 *
 *   - Safepoint annotations say whether a function may reach a safepoint, a
 *     point at which a collection can run: GAP_GC_CANSAFEPOINT on one that
 *     may, for instance because it allocates a bag, and GAP_GC_NOTSAFEPOINT
 *     on one that never does, such as a marking function.
 *   - Rooting annotations say how a callee roots its arguments and return
 *     value, so that its callers need no GC frame of their own; for example,
 *     GAP_GC_ROOTED_BY_ARG on a parameter that the function stores into
 *     another argument.
 *
 *
 *  The two analyses
 *  ----------------
 *
 * Each is selected by its own define:
 *
 *   __clang_gcanalyzer__      Julia's GCChecker, a plugin for the Clang
 *                             static analyzer in Julia's src/clangsa. It
 *                             checks that a value the GC manages is rooted
 *                             whenever a collection could happen, and that a
 *                             function promising no safepoint keeps it.
 *
 *   __clang_safetyanalysis__  Clang's Thread Safety Analysis, set up as in
 *                             Julia's `make -C src safesrc`. It checks the
 *                             safepoint annotations against each other.
 *
 * They take opposite views of an unannotated function:
 *
 *   - To the GCChecker it may safepoint. GAP_GC_NOTSAFEPOINT opts out, and
 *     the checker verifies the promise.
 *   - To the safety analysis it may NOT safepoint. Every function that can
 *     must say so with GAP_GC_CANSAFEPOINT, and is flagged as soon as it
 *     calls one that does without saying so itself.
 *
 * The two annotations must never appear on the same declaration: if the
 * safety analysis asks for GAP_GC_CANSAFEPOINT somewhere that already
 * promises GAP_GC_NOTSAFEPOINT, one of the two is wrong, and adding the
 * second only hides which. A third option suits a function that never
 * returns: it can promise callers no safepoint while its own body opts out
 * of the analysis with GAP_GC_NO_SAFEPOINT_ANALYSIS.
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
 * A parameter annotation is about the parameter it is on; an index in it
 * names another parameter, counted from zero over all parameters, not just
 * the `Obj` ones. Here `obj` is stored into argument 0, `list`, so whatever
 * roots `list` roots `obj` too.
 *
 * Put the annotation on a function's FIRST declaration, normally the one in
 * the header. Clang silently ignores an annotation that appears only on a
 * later declaration, so one written on the definition of a function declared
 * in a header does nothing at all, and the mistake is invisible. Julia's
 * julia-first-decl-annotations clang-tidy check catches this.
 */
#if defined(__clang_gcanalyzer__)

// Rooting annotations.

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
// Function may hit a GC safepoint. Julia passes these to the GCChecker too,
// as "julia_can_safepoint" (a call stays a safepoint even where the inlined
// body reaches none) and, for the ENTER/LEAVE forms, as region transitions.
// We do not: Julia's first-declaration check would then demand the annotation
// on every function-pointer type such a function is stored in. So they only
// matter to the thread safety analysis below.
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

// Declared as in Julia's analyzer_annotations.h, which julia.h includes in a
// Julia GC build. Julia before 1.14 takes a `void *`, so the analyzer needs
// Julia 1.14.
#ifdef __cplusplus
extern "C" {
#endif
void JL_GC_PROMISE_ROOTED(const void * v) GAP_GC_NOTSAFEPOINT;
#ifdef __cplusplus
}
#endif
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
