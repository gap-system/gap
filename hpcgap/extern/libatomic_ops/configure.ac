# Copyright (c) 2005-2006 Hewlett-Packard Development Company, L.P.
# Copyright (c) 2009-2019 Ivan Maidanski
#
# THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
# OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
#
# Permission is hereby granted to use or copy this program
# for any purpose,  provided the above notices are retained on all copies.
# Permission to modify the code and to distribute modified code is granted,
# provided the above notices are retained, and a notice that the code was
# modified is included with the above copyright notice.

dnl Process this file with autoconf to produce configure.

AC_INIT([libatomic_ops],[7.6.12],https://github.com/ivmai/libatomic_ops/issues)

AC_PREREQ(2.61)
AC_CANONICAL_TARGET([])
AC_CONFIG_SRCDIR(src/atomic_ops.c)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([foreign nostdinc])
AM_MAINTAINER_MODE

AC_CONFIG_HEADERS([src/config.h])

dnl Checks for programs.
AM_PROG_CC_C_O
AM_PROG_AS
LT_INIT([disable-shared])

dnl Checks for functions.
AC_FUNC_MMAP

# Determine PIC flag.
need_asm=false
PICFLAG=
AC_MSG_CHECKING(for PIC compiler flag)
if test "$GCC" = yes; then
  old_CC="$CC"
  if test -n "$CROSS_CC"; then
    CC="$CROSS_CC"
  fi

  case "$host" in
    *-*-cygwin* | *-*-mingw* | *-*-msys*)
      # Cygwin and Mingw[-w32/64] do not need -fPIC.
      AC_MSG_RESULT([not needed])
      ;;
    *)
      AC_MSG_RESULT(-fPIC)
      PICFLAG=-fPIC
      AC_MSG_CHECKING(whether -fPIC compiler option causes __PIC__ definition)
      # Workaround: at least GCC 3.4.6 (Solaris) does not define this macro.
      old_CFLAGS="$CFLAGS"
      CFLAGS="$PICFLAG $CFLAGS"
      AC_TRY_COMPILE([],[
 #ifndef __PIC__
 # error
 #endif
      ], [ac_cv_pic_macro=yes], [ac_cv_pic_macro=no])
      CFLAGS="$old_CFLAGS"
      AC_MSG_RESULT($ac_cv_pic_macro)
      AS_IF([test "$ac_cv_pic_macro" = yes], [],
            [PICFLAG="-D__PIC__=1 $PICFLAG"])
      ;;
  esac

  # Output all warnings.
  AC_MSG_CHECKING([whether compiler supports -Wextra])
  old_CFLAGS="$CFLAGS"
  CFLAGS="-Wextra $CFLAGS"
  AC_TRY_COMPILE([],[], [ac_cv_cc_wextra=yes], [ac_cv_cc_wextra=no])
  CFLAGS="$old_CFLAGS"
  AC_MSG_RESULT($ac_cv_cc_wextra)
  AS_IF([test "$ac_cv_cc_wextra" = yes], [WEXTRA="-Wextra"], [WEXTRA="-W"])
  AC_MSG_CHECKING([whether compiler supports -Wpedantic])
  CFLAGS="-Wpedantic -Wno-long-long $CFLAGS"
  AC_TRY_COMPILE([],[
extern int quiet;
  ], [ac_cv_cc_pedantic=yes], [ac_cv_cc_pedantic=no])
  CFLAGS="$old_CFLAGS"
  AC_MSG_RESULT($ac_cv_cc_pedantic)
  WPEDANTIC=
  AS_IF([test "$ac_cv_cc_pedantic" = yes],
        [WPEDANTIC="-Wpedantic -Wno-long-long"])
  CFLAGS="-Wall $WEXTRA $WPEDANTIC $CFLAGS"

  AC_ARG_ENABLE(werror, [AC_HELP_STRING([--enable-werror],
                            [Pass -Werror to the C compiler])])
  if test "$enable_werror" = yes; then
    CFLAGS="-Werror $CFLAGS"
  fi

  CC="$old_CC"
else
  case "$host" in
    *-*-hpux*)
      AC_MSG_RESULT([+Z])
      PICFLAG="+Z"
      CFLAGS="+O2 -mt $CFLAGS"
      ;;
    *-*-solaris*)
      AC_MSG_RESULT(-Kpic)
      PICFLAG=-Kpic
      CFLAGS="-O $CFLAGS"
      need_asm=true
      ;;
    *-*-linux*)
      AC_MSG_RESULT(-fPIC)
      PICFLAG=-fPIC
      # Any Linux compiler had better be gcc compatible.
      ;;
    *)
      AC_MSG_RESULT([none])
      ;;
  esac
fi

AC_ARG_ENABLE(assertions,
        [AC_HELP_STRING([--enable-assertions], [Assertion checking])])
if test "$enable_assertions" != yes; then
  AC_DEFINE([NDEBUG], 1, [Define to disable assertion checking.])
fi

AC_ARG_ENABLE(atomic-intrinsics,
        [AC_HELP_STRING([--disable-atomic-intrinsics],
                        [Do not use C11 atomic intrinsics])])
if test "$enable_atomic_intrinsics" = no; then
  AC_DEFINE([AO_DISABLE_GCC_ATOMICS], 1,
            [Define to avoid C11 atomic intrinsics even if available.])
fi

AC_ARG_ENABLE(gcov, AC_HELP_STRING([--enable-gcov],
                                   [Turn on code coverage analysis]))
if test "$enable_gcov" = "yes"; then
  CFLAGS="$CFLAGS --coverage"
  # Turn off code optimization to get accurate line numbers.
  CFLAGS=`echo "$CFLAGS" | sed -e 's/-O\(1\|2\|3\|4\|s\|fast\)\?//g'`
fi

AC_ARG_ENABLE(docs,
        [AC_HELP_STRING([--disable-docs],
                        [Do not build and install documentation])])
AM_CONDITIONAL(ENABLE_DOCS, test x$enable_docs != xno)

AC_SUBST(PICFLAG)
AC_SUBST(DEFS)

dnl Extra user-defined C flags.
AC_SUBST([CFLAGS_EXTRA])

AH_TEMPLATE([_PTHREADS], [Indicates the use of pthreads (NetBSD).])

AH_TEMPLATE([AO_USE_NANOSLEEP],
        [Use nanosleep() instead of select() (only if atomic operations \
         are emulated)])
AH_TEMPLATE([AO_USE_NO_SIGNALS],
        [Do not block signals in compare_and_swap (only if atomic operations \
         are emulated)])
AH_TEMPLATE([AO_USE_WIN32_PTHREADS],
        [Use Win32 Sleep() instead of select() (only if atomic operations \
         are emulated)])
AH_TEMPLATE([AO_TRACE_MALLOC], [Trace AO_malloc/free calls (for debug only)])

dnl These macros are tested in public headers.
AH_TEMPLATE([AO_GENERALIZE_ASM_BOOL_CAS],
        [Force compare_and_swap definition via fetch_compare_and_swap])
AH_TEMPLATE([AO_PREFER_GENERALIZED],
        [Prefer generalized definitions to direct assembly-based ones])
AH_TEMPLATE([AO_USE_PTHREAD_DEFS],
        [Emulate atomic operations via slow and async-signal-unsafe \
         pthread locking])
AH_TEMPLATE([AO_ASM_X64_AVAILABLE],
        [Inline assembly available (only VC/x86_64)])
AH_TEMPLATE([AO_ASSUME_VISTA],
        [Assume Windows Server 2003, Vista or later target (only VC/x86)])
AH_TEMPLATE([AO_CMPXCHG16B_AVAILABLE],
        [Assume target is not old AMD Opteron chip (only x86_64)])
AH_TEMPLATE([AO_FORCE_USE_SWP],
        [Force test_and_set to use SWP instruction instead of LDREX/STREX \
         (only arm v6+)])
AH_TEMPLATE([AO_NO_SPARC_V9], [Assume target is not sparc v9+ (only sparc)])
AH_TEMPLATE([AO_OLD_STYLE_INTERLOCKED_COMPARE_EXCHANGE],
        [Assume ancient MS VS Win32 headers (only VC/arm v6+, VC/x86)])
AH_TEMPLATE([AO_UNIPROCESSOR], [Assume single-core target (only arm v6+)])
AH_TEMPLATE([AO_USE_INTERLOCKED_INTRINSICS],
        [Assume Win32 _Interlocked primitives available as intrinsics \
         (only VC/arm)])
AH_TEMPLATE([AO_USE_PENTIUM4_INSTRS],
        [Use Pentium 4 'mfence' instruction (only x86)])
AH_TEMPLATE([AO_USE_SYNC_CAS_BUILTIN],
        [Prefer GCC built-in CAS intrinsics in favor of inline assembly \
         (only gcc/x86, gcc/x86_64)])
AH_TEMPLATE([AO_WEAK_DOUBLE_CAS_EMULATION],
        [Emulate double-width CAS via pthread locking in case of no hardware \
         support (only gcc/x86_64, the emulation is unsafe)])
AH_TEMPLATE([AO_PREFER_BUILTIN_ATOMICS],
        [Prefer C11 atomic intrinsics over assembly-based implementation \
        even in case of inefficient implementation (do not use assembly for \
        any atomic_ops primitive if C11/GCC atomic intrinsics available)])

AC_DEFINE(_REENTRANT, 1, [Required define if using POSIX threads.])

# Libraries needed to support threads (if any).
have_pthreads=false
AC_CHECK_LIB(pthread, pthread_self, have_pthreads=true)
if test x$have_pthreads = xtrue; then
  THREADDLLIBS=-lpthread
  case "$host" in
    *-*-netbsd*)
      # Indicates the use of pthreads.
      AC_DEFINE(_PTHREADS)
      ;;
    *-*-openbsd* | *-*-kfreebsd*-gnu | *-*-dgux*)
      THREADDLLIBS=-pthread
      ;;
    *-*-cygwin* | *-*-darwin*)
      # Cygwin does not have a real libpthread, so Libtool cannot link
      # against it.
      THREADDLLIBS=
      ;;
    *-*-mingw* | *-*-msys*)
      # Use Win32 threads for tests anyway.
      THREADDLLIBS=
      # Skip test_atomic_pthreads.
      have_pthreads=false
      ;;
  esac
else
  AC_DEFINE([AO_NO_PTHREADS], 1, [No pthreads library available])
  # Assume VxWorks or Win32.
  THREADDLLIBS=
fi
AC_SUBST(THREADDLLIBS)

AM_CONDITIONAL(ENABLE_SHARED, test x$enable_shared = xyes)
AM_CONDITIONAL(HAVE_PTHREAD_H, test x$have_pthreads = xtrue)
AM_CONDITIONAL(NEED_ASM, test x$need_asm = xtrue)

AC_CONFIG_FILES([
        Makefile
        doc/Makefile
        src/Makefile
        tests/Makefile
        pkgconfig/atomic_ops.pc
        pkgconfig/atomic_ops-uninstalled.pc ])

AC_CONFIG_COMMANDS([default],[[]],[[
PICFLAG="${PICFLAG}"
CC="${CC}"
DEFS="${DEFS}"
]])
AC_OUTPUT
