dnl
dnl Setup autoconf
dnl
AC_PREREQ([2.68])
AC_INIT([GAP], [4.dev], [support@gap-system.org], [gap], [http://www.gap-system.org/])

AC_CONFIG_SRCDIR([src/gap.c])
AC_CONFIG_AUX_DIR([cnf])

AC_CONFIG_HEADERS([gen/config.h:src/config.h.in])
AC_CONFIG_COMMANDS([gen/stamp-h], [echo timestamp > gen/stamp-h])

dnl
dnl Get canonical host information
dnl
AC_CANONICAL_HOST


dnl
dnl Set the language
dnl
AC_PROG_CC_C99
AC_LANG([C])


dnl
dnl Check whether to use _GNU_SOURCE etc. (needed for e.g. exp10).
dnl Must come before anything else using AC_COMPILE_IFELSE
dnl
AC_USE_SYSTEM_EXTENSIONS


dnl
dnl ABI settings
dnl
AC_ARG_VAR(ABI, [Set this equal to 32 or 64 to build GAP (and GMP provided you
     do not deselect it) in 32- or 64-bit mode. The default value
     for this option is determined by testing the behaviour of your
     compiler, so should be 32 on a 32-bit system and 64 on one
     which is 64-bit. If this is unset, the build system will set
     a value of 64 or 32 depending of the pointer size of the host.])

AC_MSG_CHECKING([ABI flags])
if test "x$ABI" = "x" ;  then
  ABI_CFLAGS=""
elif test "$ABI" = "64"; then
  ABI_CFLAGS="-m64"
elif test "$ABI" = "32"; then
  ABI_CFLAGS="-m32"
else
  AC_MSG_ERROR([ $ABI is not a supported value for ABI. The supported values are ABI=64
                 or 32.])
fi
AC_MSG_RESULT([$ABI_CFLAGS])
AC_SUBST([ABI_CFLAGS])

dnl Add ABI_CFLAGS to CFLAGS *now*, so that all config tests we
dnl run from here on use it.
AS_IF([test -n $ABI_CFLAGS],[
  CFLAGS="$CFLAGS $ABI_CFLAGS"
  LDFLAGS="$LDFLAGS $ABI_CFLAGS"

  dnl Verify that the ABI_CFLAGS didn't break anything
    AC_LINK_IFELSE(
        [AC_LANG_PROGRAM([[]],[])],
        [],
        [AC_MSG_ERROR([ABI_CFLAGS="$ABI_CFLAGS" not supported])]
        )
])

dnl determine pointer sizes to distinguish 32 and 64 bit systems.
AC_CHECK_SIZEOF([void *])

dnl ensure that ABI and sizeof(void *) match
AC_MSG_CHECKING([ABI bit size])
if test "x$ABI" = "x" ;  then
  if test $ac_cv_sizeof_void_p = 8; then
    ABI="64"
  else
    ABI="32"
  fi
elif test "$ABI" = "32"; then
  if test $ac_cv_sizeof_void_p != 4; then
    AC_MSG_ERROR([ ABI=32 used by sizeof(void *) != 4.])
  fi
elif test "$ABI" = "64"; then
  if test $ac_cv_sizeof_void_p != 8; then
    AC_MSG_ERROR([ ABI=64 used by sizeof(void *) != 8.])
  fi
fi
AC_MSG_RESULT([$ABI])
AC_SUBST([ABI])


dnl autoconf may set CXX to g++ even if there is no working C++ compiler.
dnl So verify that CXX really is able to compile C++ code.
AC_LANG_PUSH([C++])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
  [[#include <iostream>
    #ifndef __cplusplus
    #error "broken C++"
    #endif]])],,
  [CXX=;])
AC_LANG_POP([C++])


dnl
dnl Miscellaneous tools
dnl
AC_PROG_INSTALL
AC_PROG_MKDIR_P


dnl
dnl Setup libtool (for interfacing with GAP kernel extension)
dnl
LT_PREREQ([2.4.2])
LT_INIT([disable-static dlopen win32-dll])


dnl
dnl Check for properties of the host system and compiler
dnl

dnl endianess
AC_C_BIGENDIAN

dnl shifts
AC_MSG_CHECKING([whether right shifts are arithmetic])
AC_COMPUTE_INT(RIGHTSHIFTMINUSONE, [(-1L >> 1)+1])
AS_IF([test x"$RIGHTSHIFTMINUSONE" = x0],
    [
    HAVE_ARITHRIGHTSHIFT=1
    AC_MSG_RESULT([yes])
    ],[
    HAVE_ARITHRIGHTSHIFT=0
    AC_MSG_RESULT([no])
    ])
AC_DEFINE_UNQUOTED([HAVE_ARITHRIGHTSHIFT],
    [$HAVE_ARITHRIGHTSHIFT],
    [define as 1 if >> for long int behaves like an arithmetic right shift for negative numbers])

dnl compiler builtins
AC_DEFUN([CHECK_COMPILER_BUILTIN],
[AC_MSG_CHECKING([for $1])
    AC_LINK_IFELSE(
        [AC_LANG_PROGRAM(
            [[]],
            [$1[($2)];
            ]
        )],
        [AS_VAR_SET([[have_]$1], [yes])],
        [AS_VAR_SET([[have_]$1], [no])]
        )
    AC_MSG_RESULT(AS_VAR_GET([[have_]$1]))
    AS_IF([test yes = AS_VAR_GET([[have_]$1])],
        [AC_DEFINE_UNQUOTED(AS_TR_CPP([HAVE_]$1), 1,
            [Define to 1 if the system has the `]$1[' built-in function])], []
        )])

CHECK_COMPILER_BUILTIN([__builtin_smul_overflow],[0,0,0]);
CHECK_COMPILER_BUILTIN([__builtin_smull_overflow],[0,0,0]);
CHECK_COMPILER_BUILTIN([__builtin_smulll_overflow],[0,0,0]);
CHECK_COMPILER_BUILTIN([__builtin_clz],[0]);
CHECK_COMPILER_BUILTIN([__builtin_clzl],[0]);
CHECK_COMPILER_BUILTIN([__builtin_clzll],[0]);

dnl determine sizeof of some standard types, so that the GAP headers
dnl can pick the correct builtins among those we just tested
AC_CHECK_SIZEOF([int])
AC_CHECK_SIZEOF([long])
AC_CHECK_SIZEOF([long long])



dnl
dnl User settings
dnl

dnl
dnl User setting: HPC-GAP mode (off by default)
dnl
dnl If on, build an HPCGAP executable instead of standard GAP.
dnl
AC_ARG_ENABLE([hpcgap],
    [AS_HELP_STRING([--enable-hpcgap], [enable HPC-GAP])],
    [AC_DEFINE([HPCGAP], [1], [define if building HPC-GAP])],
    [enable_hpcgap=no]
    )
AC_MSG_CHECKING([whether to enable HPC-GAP])
AC_MSG_RESULT([$enable_hpcgap])

AC_SUBST([HPCGAP], [$enable_hpcgap])
AS_IF([test "x$enable_hpcgap" = xyes],
    [
    # HACK (see issue #9)
    AC_DEFINE([MAX_GC_THREADS], [4], [maximum number of GC threads])
    ])

dnl
dnl User setting: Debug mode (off by default)
dnl
dnl TODO: make this actually do something, e.g. disable or reduce optimizations,
dnl enable/disable C level assertions, etc.
dnl
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug], [enable debug mode])],
    [AC_DEFINE([DEBUG], [1], [define if building in debug mode])],
    [enable_debug=no]
    )
AC_MSG_CHECKING([whether to enable debug mode])
AC_MSG_RESULT([$enable_debug])

dnl
dnl External dependencies
dnl

dnl Find GMP
AC_ARG_WITH([gmp],
  [AS_HELP_STRING([--with-gmp@<:@=builtin|PREFIX@:>@],
    [prefix of GMP installation. e.g. /usr/local; specify `builtin' to let GAP builds its own version of GMP])],
    [],[with_gmp=yes])

BUILD_GMP=no
GMP_CPPFLAGS=
GMP_LDFLAGS=
GMP_LIBS="-lgmp"
AS_CASE([$with_gmp],
  [builtin],[
    # user explicitly requested to use builtin GMP
    BUILD_GMP=yes
    AC_MSG_NOTICE([Using bundled GMP])
  ],
  [no],[
    AC_MSG_ERROR([Building without GMP is not supported])
  ],
  [system],[with_gmp=yes],  dnl supported for backwards compatibility with old build system
  [yes],[],
  [*],[
    GMP_CPPFLAGS="-I${with_gmp}/include"
    GMP_LDFLAGS="-L${with_gmp}/lib"
  ]
)

AS_IF([test $BUILD_GMP = no],
  [
    # try to link against GMP
    AX_CHECK_LIBRARY([GMP], [gmp.h], [gmp], [__gmpz_init])
    AS_IF([test $ax_cv_have_GMP = no],[
        AS_IF([test "x$with_gmp" = "xyes"],[
          BUILD_GMP=yes
          AC_MSG_NOTICE([No usable GMP found, switching to included GMP])
        ],
        [AC_MSG_ERROR([GMP not found at prefix $with_gmp])]
        )
    ])
  ])

# Use bundled GMP if requested
AS_IF([test x$BUILD_GMP = xyes],[
  BUILD_GMP=yes
  GMP_CPPFLAGS='-I${abs_top_builddir}/extern/install/gmp/include'
  GMP_LDFLAGS='${abs_top_builddir}/extern/install/gmp/lib/libgmp.la'
  GMP_LIBS=
])

AC_SUBST([BUILD_GMP])
AC_SUBST([GMP_CPPFLAGS])
AC_SUBST([GMP_LDFLAGS])
AC_SUBST([GMP_LIBS])

dnl Some packages check the USE_GMP flag; retain it for now to
dnl allow these packages to work correctly for now. We should
dnl remove this eventually.
AC_DEFINE([USE_GMP], [1], [for backwards compatibility])


dnl Find GNU readline
AC_ARG_WITH([readline],
  [AS_HELP_STRING([--with-readline@<:@=PREFIX:>@],
    [support fancy command line editing via GNU readline; optionally
     specify a prefix where it can be found])])

dnl Now check if we can find GNU readline. We go to some extra efforts to
dnl ensure it is GNU readline, and not e.g. BSD editline wrappers for
dnl readline, which do not suffice for GAP.
AS_IF([test "x$with_readline" != xno],[
  READLINE_LIBS="-lreadline -lncurses"
  AS_CASE([x"$with_readline"],
    [xyes|x],[
      READLINE_CPPFLAGS=
      READLINE_LDFLAGS=
    ],
    [*],[
      READLINE_CPPFLAGS="-I$with_readline/include"
      READLINE_LDFLAGS="-L$with_readline/lib"
    ]
  )

  dnl We check for the symbol rl_ding to distinguish GNU readline
  dnl from other readline implementation.
  AX_CHECK_LIBRARY([READLINE], [readline/readline.h], [readline], [rl_ding], [], [], [-lncurses])

  AS_IF([test $ax_cv_have_READLINE = yes],[
    AC_DEFINE([HAVE_LIBREADLINE], [1], [Define if you have libreadline])
  ],[
    AS_CASE([x"$with_readline"],
      [x], [READLINE_CPPFLAGS= READLINE_LDFLAGS= READLINE_LIBS=],
      [*], [AC_MSG_FAILURE([--with-readline was given, but test for readline failed])]
    )
  ])
])

AC_SUBST([READLINE_CPPFLAGS])
AC_SUBST([READLINE_LDFLAGS])
AC_SUBST([READLINE_LIBS])

dnl Find ward (if HPC-GAP mode is enabled)
AC_ARG_WITH([ward],
  [AS_HELP_STRING([--with-ward@<:@=PREFIX:>@],
    [prefix to the ward tool (used for building HPC-GAP)])],
  [],
  [with_ward=check])

dnl If HPC-GAP is enabled, check for a usable ward, either in the prefix
dnl specified by the user, or else in $srcdir/hpcgap/ward
AS_IF([test "x$enable_hpcgap" = xyes],
  [
  # If the user specified a prefix, check only there.
  # Otherwise, check in various relative paths, and in $PATH
  AS_IF([test "x$with_ward" != xcheck],
        [WARD_PATH="$with_ward/bin"],
        [WARD_PATH="$srcdir/hpcgap/ward/bin:ward/bin:../ward/bin:$PATH"]
        )
  AC_PATH_PROG([ADDGUARDS2], [addguards2c addguards2], [], [$WARD_PATH])
  AS_IF([test "x$ADDGUARDS2" = x], AC_MSG_ERROR([could not locate addguards2]))


  # We bundle two libraries we need for HPC-GAP:
  # Boehm garbage collector, see http://www.hboehm.info/gc/
  # libatomic_ops - part of Boehm GC, but see also https://github.com/ivmai/libatomic_ops
  #
  # We bundle them because we need a few patches to Boehm GC which are
  # not upstream (and it is unclear whether they ever will be).
  # And we bundle libatomic_ops because its version must match that
  # of Boehm GC; the easiest way to ensure that is to include that, too.
  #
  # As a side benefit, users do not have to worry about installing dependencies.

  BUILD_LIBATOMIC_OPS=yes
  LIBATOMIC_OPS_CPPFLAGS='-I${abs_top_builddir}/extern/install/libatomic_ops/include'
  LIBATOMIC_OPS_LDFLAGS='${abs_top_builddir}/extern/install/libatomic_ops/lib/libatomic_ops.la'
  LIBATOMIC_OPS_LIBS=
  AC_SUBST([BUILD_LIBATOMIC_OPS])
  AC_SUBST([LIBATOMIC_OPS_CPPFLAGS])
  AC_SUBST([LIBATOMIC_OPS_LDFLAGS])
  AC_SUBST([LIBATOMIC_OPS_LIBS])

  ATOMIC_OPS_CFLAGS=$LIBATOMIC_OPS_CPPFLAGS
  ATOMIC_OPS_LIBS=$LIBATOMIC_OPS_LDFLAGS

  AC_DEFINE([BOEHM_GC], [1], [Use Boehm garbage collector])
  BUILD_BOEHM_GC=yes
  BOEHM_GC_CPPFLAGS='-I${abs_top_builddir}/extern/install/gc/include'
  BOEHM_GC_LDFLAGS='${abs_top_builddir}/extern/install/gc/lib/libgc.la'
  BOEHM_GC_LIBS=
  AC_SUBST([BUILD_BOEHM_GC])
  AC_SUBST([BOEHM_GC_CPPFLAGS])
  AC_SUBST([BOEHM_GC_LDFLAGS])
  AC_SUBST([BOEHM_GC_LIBS])
  ]
)


dnl
dnl User setting: Compatibility mode (on by default)
dnl
CONFIGNAME="default${ABI}"
BASECC=`basename ${CC}`
GAPARCH="$host-$BASECC-${CONFIGNAME}"
AC_DEFINE_UNQUOTED([CONFIGNAME], ["$CONFIGNAME"], [for backwards compatibility])
AC_DEFINE_UNQUOTED([SYS_ARCH], ["$GAPARCH"], [for backwards compatibility])
AC_SUBST([GAPARCH])

AC_ARG_ENABLE([compat-mode],
    [AS_HELP_STRING([--disable-compat-mode], [enable compatibility mode])],
    [],
    [enable_compat_mode=yes]
    )
AC_MSG_CHECKING([whether to enable compatibility mode for packages])
AC_MSG_RESULT([$enable_compat_mode])

AC_SUBST([COMPAT_MODE], [$enable_compat_mode])
AS_IF([test "x$enable_compat_mode" = xyes],
    [
    AC_CONFIG_FILES([bin/gap.sh:cnf/compat/gap.sh.in], [chmod +x bin/gap.sh])
    AC_CONFIG_FILES([sysinfo.gap:cnf/compat/sysinfo.gap.in], [ln -s sysinfo.gap sysinfo.gap-$CONFIGNAME], [CONFIGNAME='$CONFIGNAME'])
    AC_CONFIG_LINKS([bin/$GAPARCH/config.h:gen/config.h])
    AS_IF([test x$BUILD_GMP = xyes],[
      AC_CONFIG_FILES([bin/$GAPARCH/extern/gmp/include/gmp.h:cnf/compat/gmp.h.in])
    ])
    AS_IF([test "x$srcdir" = x.],
        [
            AC_MSG_NOTICE([in-tree build])
        ],
        [
            AC_MSG_NOTICE([out-of-tree build])
            # FIXME: the following config command works if invoked
            # explicitly, but for some reason is not added to the list
            # of automatic command
            AC_CONFIG_COMMANDS([src/compiled.h],
                [
                echo "#include \"$ac_abs_top_srcdir/src/compiled.h\"" > src/compiled.h
                ])
        ])
    ])


dnl
dnl Detect host specific setting
dnl

GP_C_LONG_ALIGN


case "$host_cpu" in
  sparc* )
    AC_DEFINE([SPARC], [1], [define as 1 on SPARC architecture to flush register windows])
    SPARC=yes
    ;;
esac

case "$host_os" in
  *cygwin*)
    AC_DEFINE([SYS_IS_CYGWIN32], [1], [define if this is the Cygwin32 port])
    CYGWIN=yes

    AS_IF([test "x$enable_compat_mode" = xyes],[
        wingapdir=$(cygpath -w $(pwd))
        wincygbin=$(cygpath -w /bin)
        gapdir=$(echo /proc/cygdrive/"$(cygpath -am $(pwd))" | sed -e 's/:\//\//g')
        AC_SUBST([wingapdir])
        AC_SUBST([wincygbin])
        AC_SUBST([gapdir])

        AC_CONFIG_FILES([bin/gap.bat:cnf/cygwin/gap.bat.in], [chmod +x bin/gap.bat])
        AC_CONFIG_FILES([bin/gapcmd.bat:cnf/cygwin/gapcmd.bat.in], [chmod +x bin/gapcmd.bat])
        AC_CONFIG_FILES([bin/gaprxvt.bat:cnf/cygwin/gaprxvt.bat.in], [chmod +x bin/gaprxvt.bat])
    ])
    ;;
  *darwin*)
    AC_DEFINE([SYS_IS_DARWIN], [1], [define if this is the Darwin port])
    DARWIN=yes
    ;;
esac

dnl Note: AC_DEFINE defines conditionals to be put in config.h, while
dnl AM_CONDITIONAL defines conditionals for use in in Makefile.am
AC_SUBST([SYS_IS_CYGWIN32], [$CYGWIN])
SYS_IS_DARWIN=$DARWIN
AC_SUBST([SYS_IS_DARWIN])


dnl
dnl check for the existence of various header files
dnl

dnl check for stdint.h and the types int8_t, uint8_t etc. it defines
AC_TYPE_INT8_T
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_UINT8_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T

dnl
dnl check for functionality related to child process handling,
dnl including pseudo TTY support, signals, etc.
dnl
dnl TODO: reduce these checks to the minimum! but make sure
dnl to also adjust the C code simultaneously, and e.g. remove
dnl checks for things like HAVE_SYS_WAIT_H if appropriate.
dnl

AC_CHECK_HEADERS([fcntl.h termios.h termio.h sgtty.h])
AC_CHECK_HEADERS([sys/ioctl.h sys/resource.h sys/stat.h sys/wait.h])

# FIXME: get rid of the following (requires code changes!!!)
AC_CHECK_HEADERS( assert.h errno.h )


# Check for POSIX 98 pty APIs
AC_CHECK_FUNCS([ptsname grantpt unlockpt posix_openpt])

# Check for glibc specific pty APIs
AC_CHECK_FUNCS([getpt ptsname_r])

# Check for some legacy APIs
AC_CHECK_FUNCS([getpseudotty _getpty])

# openpty() is available on various BSD variants, but also in glibc.
# On BSD systems, one usually needs to add -lutil to LIBS in order
# to use it.
AC_CHECK_HEADERS([util.h pty.h libutil.h])
AC_SEARCH_LIBS([openpty], [util],
    AC_DEFINE([HAVE_OPENPTY], [1], [define as 1 if you have `openpty']))


dnl check for input/output functions
AC_CHECK_HEADERS([signal.h])
AC_CHECK_FUNCS([ttyname select])

dnl various functions to deal with child processes
AC_HEADER_SYS_WAIT
AC_TYPE_PID_T
AC_FUNC_FORK
AC_CHECK_FUNCS([popen])

dnl signal handling
AC_CHECK_TYPE([sig_atomic_t], [],
    [AC_DEFINE([HAVE_SIG_ATOMIC_T],[],[Check for sig_atomic_t])],
    [#include <signal.h>]
)
AC_CHECK_FUNCS([signal sigaction setpgid])


dnl
dnl check for dynamic loading of modules
dnl TODO: replace with libtool code?!
dnl

AC_CHECK_FUNCS([rld_load])

AC_SEARCH_LIBS([dlopen], [dl],
    [AC_DEFINE([HAVE_DLOPEN], [1], [define as 1 if you have `dlopen' and `dlsym'])]
)


dnl error handling
AC_CHECK_HEADERS([errno.h])

dnl check for timing functions
AC_CHECK_HEADERS([time.h sys/time.h sys/times.h])
AC_CHECK_FUNCS([times getrusage gettimeofday clock_gettime clock_getres])
AC_CHECK_FUNCS([setitimer getitimer])
AC_CHECK_LIB([rt], [timer_create])
AC_CHECK_FUNCS([timer_settime timer_gettime timer_create])
AC_CHECK_FUNCS([sys_timer_settime sys_timer_gettime sys_timer_create])

dnl check for functions dealing with virtual memory
AC_CHECK_FUNCS([vm_allocate sbrk madvise sysconf])

dnl check for functions dealing with strings and integers
AC_CHECK_FUNCS([atol strlcpy strlcmp strlcat])

dnl check for file access functions
AC_HEADER_STAT
AC_CHECK_FUNCS([access stat fstat lstat unlink mkdir rmdir mkdtemp mkstemp link rename chmod dup dup2 realpath])

dnl check for large-file support (for accessing files whose sizes or inodes require 64bits)
AC_SYS_LARGEFILE

dnl check for socket access functions
AC_CHECK_FUNCS([socket accept connect bind send])

dnl check for directory access functions
AC_HEADER_DIRENT
AC_CHECK_FUNCS([opendir closedir readdir])

dnl check whether libm / -lm is available and necessary
AC_SEARCH_LIBS([cos], [m], [], [
  AC_MSG_ERROR([unable to find the cos() function])
])

dnl check for math functions
AC_CHECK_FUNCS([log2 log10 log1p exp2 expm1 exp10 trunc])

dnl sigsetjmp is a macro on some platforms, cannot use AC_CHECK_FUNCS
AC_MSG_CHECKING([for sigsetjmp])
AC_LINK_IFELSE(
  [AC_LANG_PROGRAM([[#include <setjmp.h>]],
      [[sigjmp_buf t; sigsetjmp(t, 0)]])],
  [AC_MSG_RESULT([yes])
   AC_DEFINE([HAVE_SIGSETJMP], [1], [Define to 1 if you have the `sigsetjmp' function.])],
  [AC_MSG_RESULT([no])])

dnl _setjmp is a macro on some platforms, cannot use AC_CHECK_FUNCS
AC_MSG_CHECKING([for _setjmp])
AC_LINK_IFELSE(
  [AC_LANG_PROGRAM([[#include <setjmp.h>]],
      [[sigjmp_buf t; _setjmp(t, 0)]])],
  [AC_MSG_RESULT([yes])
   AC_DEFINE([HAVE__SETJMP], [1], [Define to 1 if you have the `_setjmp' function.])],
  [AC_MSG_RESULT([no])])

dnl pthreads
AS_IF([test "x$enable_hpcgap" = xyes],[
  AX_PTHREAD
  ])

AS_IF([test "x$enable_hpcgap" = xyes],[
  AS_BOX([WARNING: Experimental HPC-GAP mode enabled])
  ])


dnl
dnl Output everything
dnl
AC_CONFIG_FILES([GNUmakefile])
AC_CONFIG_FILES([doc/make_doc], [chmod +x doc/make_doc])
AC_CONFIG_FILES([gac:cnf/gac.in], [chmod +x gac])
AC_OUTPUT
