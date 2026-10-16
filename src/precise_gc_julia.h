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
**  mode (the Julia GC configured with --enable-precise-gc) it maps onto
**  Julia's GC frame macros; in every other configuration it compiles away to
**  no-ops, except that GAP_GC_PUSHARGS still supplies its array.
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

// Precise mode: the Julia GC without the conservative stack scan, selected by
// configure --enable-precise-gc. Only then do the rooting macros push frames.
// With the scan on, the frames would be redundant, and Julia before 1.14
// (JuliaLang/julia#62889) crashes on the immediates they hold. The GC
// analyzer always sees the frames.
#if defined(DISABLE_STACK_SCAN) || defined(__clang_gcanalyzer__)
#define GAP_GC_PRECISE 1
#endif

#ifdef DISABLE_STACK_SCAN
#if JULIA_VERSION_MAJOR == 1 && JULIA_VERSION_MINOR < 14
#error "--enable-precise-gc needs Julia 1.14 or later"
#endif
#endif

// JL_GC_PUSH and JL_GC_POP find the frame stack through jl_get_pgcstack(),
// a chain of out-of-line calls. If Julia's TLS slot is in the static TLS
// block of the executable (julia has it there, and so does gap, see main.c),
// Julia records its offset from the thread pointer in jl_tls_offset, and the
// slot can be read inline, as Julia's own codegen does.
#if defined(GAP_GC_PRECISE) && defined(__ELF__) &&                           \
    (defined(__x86_64__) || defined(__aarch64__)) &&                         \
    !defined(__clang_gcanalyzer__) && !defined(__clang_safetyanalysis__)
#define GAP_GC_INLINE_PGCSTACK 1

// -1 until InitBags has read jl_tls_offset, and if Julia does not know it
extern ssize_t GAP_JuliaTLSOffset;

EXPORT_INLINE jl_gcframe_t ** GAP_GetPgcstack(void) GAP_GC_NOTSAFEPOINT
{
    if (GAP_JuliaTLSOffset == -1)
        return jl_get_pgcstack();

    // The result belongs to the task, so the compiler may reuse it, as it may
    // reuse that of jl_get_pgcstack(), declared JL_CONST_FUNC. The thread
    // pointer does not: after a call the task may run on another thread. One
    // asm statement for both keeps it from reusing the thread pointer alone.
    jl_gcframe_t ** pgcstack;
#if defined(__x86_64__)
    __asm__("movq %%fs:(%1), %0" : "=r"(pgcstack) : "r"(GAP_JuliaTLSOffset));
#else
    __asm__("mrs %0, tpidr_el0\n\tldr %0, [%0, %1]"
            : "=&r"(pgcstack)
            : "r"(GAP_JuliaTLSOffset));
#endif
    return pgcstack;
}

#undef jl_pgcstack
#define jl_pgcstack (*GAP_GetPgcstack())
#endif

#ifdef GAP_MEM_CHECK
// Under memory checking every push is recorded with its source location and
// every pop checked against the record, so a frame pushed and never popped,
// or popped from the wrong place, is reported at the pop that finds the
// mismatch - not at a later collection walking a frame on dead stack.
void GAP_GC_LedgerPush(void * frame, const char * file, int line);
void GAP_GC_LedgerPop(void * frame, const char * file, int line);
void GAP_GC_LedgerUnwind(void * frame);
#endif
#endif


#ifdef GAP_GC_PRECISE


// A root may be the address of a volatile local (one that is modified
// between GAP_TRY and GAP_CATCH); the cast drops the qualifier the frame
// cannot carry.
#define GAP_GC_ROOT_(a) ((void *)(a))

#ifdef GAP_GC_INLINE_PGCSTACK

// JL_GC_PUSH and JL_GC_POP look the frame stack up twice; these do it once.
// The frames are laid out as Julia's.
EXPORT_INLINE void GAP_GC_LinkFrame(void ** frame) GAP_GC_NOTSAFEPOINT
{
    jl_gcframe_t ** pgcstack = GAP_GetPgcstack();
    frame[1] = *pgcstack;
    *pgcstack = (jl_gcframe_t *)frame;
}

EXPORT_INLINE void GAP_GC_UnlinkFrame(void) GAP_GC_NOTSAFEPOINT
{
    jl_gcframe_t ** pgcstack = GAP_GetPgcstack();
    *pgcstack = (*pgcstack)->prev;
}

// A name per line, as frames may nest and -Wshadow is on.
#define GAP_GC_CAT_(a, b) a##b
#define GAP_GC_FRAME_(line) GAP_GC_CAT_(gap_gc_frame_, line)
#define GAP_GC_PUSH_(n, ...)                                                 \
    void * GAP_GC_FRAME_(__LINE__)[] = { (void *)JL_GC_ENCODE_PUSH(n), 0,    \
                                         __VA_ARGS__ };                      \
    GAP_GC_LinkFrame(GAP_GC_FRAME_(__LINE__))

#define GAP_GC_PUSH1(arg1) GAP_GC_PUSH_(1, GAP_GC_ROOT_(arg1))
#define GAP_GC_PUSH2(arg1, arg2)                                             \
    GAP_GC_PUSH_(2, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2))
#define GAP_GC_PUSH3(arg1, arg2, arg3)                                       \
    GAP_GC_PUSH_(3, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3))
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4)                                 \
    GAP_GC_PUSH_(4, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3), GAP_GC_ROOT_(arg4))
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5)                           \
    GAP_GC_PUSH_(5, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3), GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5))
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6)                     \
    GAP_GC_PUSH_(6, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3), GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), \
                 GAP_GC_ROOT_(arg6))
#define GAP_GC_PUSH7(arg1, arg2, arg3, arg4, arg5, arg6, arg7)               \
    GAP_GC_PUSH_(7, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3), GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), \
                 GAP_GC_ROOT_(arg6), GAP_GC_ROOT_(arg7))
#define GAP_GC_PUSH8(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)         \
    GAP_GC_PUSH_(8, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3), GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), \
                 GAP_GC_ROOT_(arg6), GAP_GC_ROOT_(arg7), GAP_GC_ROOT_(arg8))
#define GAP_GC_PUSH9(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)   \
    GAP_GC_PUSH_(9, GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2),                  \
                 GAP_GC_ROOT_(arg3), GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), \
                 GAP_GC_ROOT_(arg6), GAP_GC_ROOT_(arg7), GAP_GC_ROOT_(arg8), \
                 GAP_GC_ROOT_(arg9))
#define GAP_GC_POP() GAP_GC_UnlinkFrame()

#else

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
#define GAP_GC_POP() JL_GC_POP()

#endif

#define GAP_GC_PUSHARGS(rts, n) JL_GC_PUSHARGS(rts, n)

#ifdef GAP_MEM_CHECK
#undef GAP_GC_PUSH1
#undef GAP_GC_PUSH2
#undef GAP_GC_PUSH3
#undef GAP_GC_PUSH4
#undef GAP_GC_PUSH5
#undef GAP_GC_PUSH6
#undef GAP_GC_PUSH7
#undef GAP_GC_PUSH8
#undef GAP_GC_PUSH9
#undef GAP_GC_PUSHARGS
#undef GAP_GC_POP
#define GAP_GC_PUSH1(a) JL_GC_PUSH1(GAP_GC_ROOT_(a)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH2(a, b) JL_GC_PUSH2(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH3(a, b, c) JL_GC_PUSH3(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH4(a, b, c, d) JL_GC_PUSH4(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c), GAP_GC_ROOT_(d)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH5(a, b, c, d, e) JL_GC_PUSH5(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c), GAP_GC_ROOT_(d), GAP_GC_ROOT_(e)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH6(a, b, c, d, e, f) JL_GC_PUSH6(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c), GAP_GC_ROOT_(d), GAP_GC_ROOT_(e), GAP_GC_ROOT_(f)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH7(a, b, c, d, e, f, g) JL_GC_PUSH7(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c), GAP_GC_ROOT_(d), GAP_GC_ROOT_(e), GAP_GC_ROOT_(f), GAP_GC_ROOT_(g)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH8(a, b, c, d, e, f, g, h) JL_GC_PUSH8(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c), GAP_GC_ROOT_(d), GAP_GC_ROOT_(e), GAP_GC_ROOT_(f), GAP_GC_ROOT_(g), GAP_GC_ROOT_(h)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSH9(a, b, c, d, e, f, g, h, i) JL_GC_PUSH9(GAP_GC_ROOT_(a), GAP_GC_ROOT_(b), GAP_GC_ROOT_(c), GAP_GC_ROOT_(d), GAP_GC_ROOT_(e), GAP_GC_ROOT_(f), GAP_GC_ROOT_(g), GAP_GC_ROOT_(h), GAP_GC_ROOT_(i)); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_PUSHARGS(rts, n) JL_GC_PUSHARGS(rts, n); GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_POP() (GAP_GC_LedgerPop(jl_pgcstack, __FILE__, __LINE__), JL_GC_POP())
#endif

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
// The array is still provided: it lives on the C stack, which the collectors
// of these configurations scan, so a caller need not know which mode it is in.
// The builtin needs no header; <alloca.h> does not exist on OpenBSD.
#define GAP_GC_PUSHARGS(rts, n) \
    ((rts) = (__typeof__(rts))__builtin_alloca(sizeof(void *) * (n)))
#define GAP_GC_POP() ((void)0)

#ifdef GAP_KERNEL_DEBUG
// Conservative collectors find these structs by scanning the C stack, so
// there is nothing to assert; see the precise branch above.
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
