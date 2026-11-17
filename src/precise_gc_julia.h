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

// GAP_GC_PRECISE says whether the macros push frames: in precise mode, and
// whenever the GC analyzer runs, so that it sees them also when it checks a
// build with the stack scan. In such a build the frames would only cost time,
// and Julia before 1.14 crashes on the immediates they hold.
#if defined(GAP_ENABLE_PRECISE_GC) || defined(__clang_gcanalyzer__)
#define GAP_GC_PRECISE 1
#endif

#endif    // USE_JULIA_GC


#ifdef GAP_GC_PRECISE

// A local modified between GAP_TRY and GAP_CATCH must be `volatile`. Julia's
// frame macros store each root as a `void *`, and converting the address of
// such a local to that type implicitly drops `volatile`, which GCC rejects
// with -Werror; the explicit cast is allowed.
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

// JL_GC_PUSHARGS takes only a `jl_value_t **`; going through one lets `rts`
// be an `Obj *`.
#define GAP_GC_PUSHARGS(rts, n) \
    do { \
        jl_value_t ** gap_gc_pushargs_; \
        JL_GC_PUSHARGS(gap_gc_pushargs_, n); \
        (rts) = (__typeof__(rts))gap_gc_pushargs_; \
    } while (0)
#define GAP_GC_POP() JL_GC_POP()

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

// GAP_GC_PUSHARGS must still provide the slots, since code using it stores
// into them, and zero them as JL_GC_PUSHARGS does; the collectors of these
// configurations scan the C stack, so the values stay alive. __builtin_alloca
// needs no header (<alloca.h> does not exist on OpenBSD). If your compiler
// lacks it, try `alloca` instead, and please tell the GAP team, so that we
// can find a more portable solution.
#define GAP_GC_PUSHARGS(rts, n) \
    ((rts) = (__typeof__(rts))__builtin_memset( \
         __builtin_alloca(sizeof(void *) * (n)), 0, sizeof(void *) * (n)))
#define GAP_GC_POP() ((void)0)

#endif    // GAP_GC_PRECISE

#endif    // GAP_PRECISE_GC_JULIA_H
