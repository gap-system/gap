/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  Rooting macros for GAP with the Julia GC in precise mode. With any other
**  memory manager, and with the Julia GC in its default mode, they compile
**  to nothing.
**
**  Precise mode means using the Julia GC for memory management without
**  GAP's traditional conservative scan of the C stack. It is selected by
**  defining GAP_ENABLE_PRECISE_GC and needs Julia 1.14 or later. Without the
**  scan, the collector sees a bag referenced only from a C local only if that
**  local is registered in a GC frame on Julia's frame stack, which is what
**  the macros below do. So this is wrong in precise mode:
**
**      Obj list = NEW_PLIST(T_PLIST, 2);
**      Obj elm  = NEW_STRING(10);      // may collect, and free `list`
**      SET_ELM_PLIST(list, 1, elm);
**
**  and rooting the locals fixes it:
**
**      Obj list = 0, elm = 0;
**      GAP_GC_PUSH2(&list, &elm);
**      list = NEW_PLIST(T_PLIST, 2);
**      elm  = NEW_STRING(10);
**      SET_ELM_PLIST(list, 1, elm);
**      GAP_GC_POP();
**
**  A frame stores the ADDRESS of each local, so every rooted local must be
**  initialised before the push: the collector may read it at once. Every
**  push needs a GAP_GC_POP on each way out of the function.
**
**  GAP_GC_PUSH1 to GAP_GC_PUSH9 root `Obj` locals. GAP_GC_PUSHARGS(rts, n)
**  allocates n zeroed slots on the C stack and points `rts`, typically an
**  `Obj *`, at them; in precise mode they form a frame, so the values stored
**  there are rooted. It supplies the slots in every build, so code using it
**  needs no `#ifdef`. Both kinds of frame may hold GAP's tagged immediates:
**  Julia's root scanner skips those since JuliaLang/julia#62889, which is why
**  precise mode needs Julia 1.14.
**
**  Which locals need rooting is what Julia's GC analyzer checks; see
**  "precise_gc.h" for it, and for the annotations that let a function
**  describe its rooting to it.
*/

#ifndef GAP_PRECISE_GC_JULIA_H
#define GAP_PRECISE_GC_JULIA_H

#include "precise_gc.h"

#if defined(GAP_ENABLE_PRECISE_GC) && !defined(USE_JULIA_GC)
#error "GAP_ENABLE_PRECISE_GC needs the Julia GC"
#endif

#ifdef USE_JULIA_GC

// As in gasman.h: our headers may be included from within `extern "C"`, which
// must not apply to the C++ headers that julia.h includes in C++.
#ifdef __cplusplus
extern "C++" {
#endif
#include <julia.h>
#ifdef __cplusplus
}
#endif

#if defined(GAP_ENABLE_PRECISE_GC) && JULIA_VERSION_MAJOR == 1 &&           \
    JULIA_VERSION_MINOR < 14
#error "GAP_ENABLE_PRECISE_GC needs Julia 1.14 or later"
#endif

// GAP_GC_PRECISE controls whether the macros push frames: namely in precise
// mode, and whenever the GC analyzer runs, so that it sees them also when it
// checks a build with the stack scan. In such a build the frames would only
// cost time, and Julia before 1.14 crashes on the immediates they hold.
#if defined(GAP_ENABLE_PRECISE_GC) || defined(__clang_gcanalyzer__)
#define GAP_GC_PRECISE 1
#endif

// Under memory checking, every push is recorded with its source location and
// every pop checked against the record, so that a frame pushed and never
// popped, or popped from the wrong place, is reported at the pop that finds
// the mismatch, not at a later collection walking a frame on dead stack.
#ifdef GAP_MEM_CHECK
void GAP_GC_LedgerPush(void * frame, const char * file, int line);
void GAP_GC_LedgerPop(void * frame, const char * file, int line);
void GAP_GC_LedgerUnwind(void * frame);
#define GAP_GC_LEDGER_PUSH_() GAP_GC_LedgerPush(jl_pgcstack, __FILE__, __LINE__)
#define GAP_GC_LEDGER_POP_() GAP_GC_LedgerPop(jl_pgcstack, __FILE__, __LINE__)
#else
#define GAP_GC_LEDGER_PUSH_() ((void)0)
#define GAP_GC_LEDGER_POP_() ((void)0)
#endif

#endif    // USE_JULIA_GC


#ifdef GAP_GC_PRECISE

// A local variable modified between GAP_TRY and GAP_CATCH must be
// `volatile`. Julia's frame macros store each root as a `void *`, and
// converting the address of such a variable to that type implicitly drops
// `volatile`, which GCC rejects with -Werror; the explicit cast is allowed.
#define GAP_GC_ROOT_(a) ((void *)(a))

#define GAP_GC_PUSH1(arg1) \
    JL_GC_PUSH1(GAP_GC_ROOT_(arg1)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH2(arg1, arg2) \
    JL_GC_PUSH2(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH3(arg1, arg2, arg3) \
    JL_GC_PUSH3(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH4(arg1, arg2, arg3, arg4) \
    JL_GC_PUSH4(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH5(arg1, arg2, arg3, arg4, arg5) \
    JL_GC_PUSH5(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH6(arg1, arg2, arg3, arg4, arg5, arg6) \
    JL_GC_PUSH6(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH7(arg1, arg2, arg3, arg4, arg5, arg6, arg7) \
    JL_GC_PUSH7(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6), \
                GAP_GC_ROOT_(arg7)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH8(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) \
    JL_GC_PUSH8(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6), \
                GAP_GC_ROOT_(arg7), GAP_GC_ROOT_(arg8)); \
    GAP_GC_LEDGER_PUSH_()
#define GAP_GC_PUSH9(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) \
    JL_GC_PUSH9(GAP_GC_ROOT_(arg1), GAP_GC_ROOT_(arg2), GAP_GC_ROOT_(arg3), \
                GAP_GC_ROOT_(arg4), GAP_GC_ROOT_(arg5), GAP_GC_ROOT_(arg6), \
                GAP_GC_ROOT_(arg7), GAP_GC_ROOT_(arg8), GAP_GC_ROOT_(arg9)); \
    GAP_GC_LEDGER_PUSH_()

// JL_GC_PUSHARGS(rts, n) assigns a `jl_value_t **` to `rts`, which does not
// compile if `rts` has another type, such as `Obj *`. So let it assign to a
// temporary of type `jl_value_t **` instead, and copy that to `rts` with a
// cast.
#define GAP_GC_PUSHARGS(rts, n) \
    do { \
        jl_value_t ** gap_gc_pushargs_; \
        JL_GC_PUSHARGS(gap_gc_pushargs_, n); \
        GAP_GC_LEDGER_PUSH_(); \
        (rts) = (__typeof__(rts))gap_gc_pushargs_; \
    } while (0)
#define GAP_GC_POP() (GAP_GC_LEDGER_POP_(), JL_GC_POP())

#ifdef GAP_KERNEL_DEBUG
/****************************************************************************
**
*F  GAP_IsRootedSlot(<slot>) . . . is a slot registered in a live GC frame?
**
**  For asserting that a state struct on the C stack was rooted by whoever
**  created it. Neither the compiler nor the GC analyzer points out a missing
**  root there: the analyzer checks rooting within a function, not whether a
**  struct on the stack holds GAP objects.
**
**  Only frames pushed by GAP_GC_PUSH1 to GAP_GC_PUSH9 are considered: those
**  hold slot addresses, which is what we are looking for. GAP_GC_PUSHARGS
**  frames hold values instead and are skipped.
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

#else    // !GAP_GC_PRECISE

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

// Even if precise mode is disabled, GAP_GC_PUSHARGS must still provide the
// slots, since code using it stores into them, and zero them as
// JL_GC_PUSHARGS does. The collector then scans the C stack, so the values
// stay alive. __builtin_alloca needs no header (<alloca.h> does not exist on
// OpenBSD). If your compiler lacks it, try `alloca` instead, and please tell
// the GAP team, so that we can find a more portable solution.
#define GAP_GC_PUSHARGS(rts, n) \
    ((rts) = (__typeof__(rts))__builtin_memset( \
         __builtin_alloca(sizeof(void *) * (n)), 0, sizeof(void *) * (n)))
#define GAP_GC_POP() ((void)0)

#endif    // GAP_GC_PRECISE


/****************************************************************************
**
*F  GAP_GC_PUSH_ROOTS( <n>, (<roots>) ) . . . . . . . . root a list of slots
**
**  A state struct on the C stack, such as CodeState in "code.h", comes with
**  a macro listing the addresses of its `Obj` fields, separated by commas:
**  CODE_STATE_ROOTS(p) for CodeState. To root these together with other
**  locals, pass the whole list in parentheses, and its length <n>:
**
**      GAP_GC_PUSH_ROOTS(6, (&func, &name, CODE_STATE_ROOTS(&cs)));
**
**  This becomes GAP_GC_PUSH6(&func, &name, ...) with all six addresses.
**  Calling GAP_GC_PUSH6 directly fails, because the preprocessor counts its
**  arguments before expanding CODE_STATE_ROOTS, and so sees three.
**
**  <n> must be a literal from 1 to 9, since it is pasted onto the macro
**  name. If a struct's list gains or loses a slot, every call site using it
**  then fails to compile, instead of rooting the wrong number of slots.
*/
#define GAP_GC_PUSH_ROOTS(n, roots) GAP_GC_PUSH_ROOTS_(n, roots)
#define GAP_GC_PUSH_ROOTS_(n, roots) GAP_GC_PUSH##n roots

#endif    // GAP_PRECISE_GC_JULIA_H
