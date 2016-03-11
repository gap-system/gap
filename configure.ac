dnl
dnl Setup autoconf
dnl
AC_PREREQ([2.68])
AC_INIT([GAP], [4.dev], [support@gap-system.org], [gap], [http://www.gap-system.org/])

AC_CONFIG_SRCDIR([src/gap.c])
AC_CONFIG_HEADERS([src/config.h])
AC_CONFIG_MACRO_DIR([cnf/m4])
AC_CONFIG_AUX_DIR([cnf])

dnl
dnl Get canonical host information
dnl
AC_CANONICAL_HOST

# HACK
AC_DEFINE_UNQUOTED( SYS_ARCH, "fake-gap-arch", [define the name of the architucture] )
AC_DEFINE_UNQUOTED(CONFIGNAME, "fake-config", [the CONFIGNAME value of the active configuration])



dnl
dnl Setup automake
dnl
AM_INIT_AUTOMAKE([1.11 -Wall foreign subdir-objects])
AM_SILENT_RULES([yes])
AM_PROG_AR

dnl
dnl Set the language
dnl
AM_PROG_AS
AC_PROG_CC
AC_LANG([C])

# TODO: check for C++ in the future??
#AC_PROG_CXX
#AC_LANG([C++])

dnl
dnl Setup libtool (for interfacing with GAP kernel extension)
dnl
LT_PREREQ([2.4.2])
LT_INIT([disable-static dlopen win32-dll])

dnl
dnl Check for compiler features, and properties of the host system
dnl
AC_C_CONST
AC_C_INLINE
AC_C_BIGENDIAN
# pointer sizes to distinguish 32 and 64 bit systems.
AC_CHECK_SIZEOF([void *])


AC_MSG_CHECKING([whether right shifts are arithmetic])
AC_COMPUTE_INT(RIGHTSHIFTMINUSONE, [(-1L >> 1)+1])
if test x"$RIGHTSHIFTMINUSONE" = x0 ; then
    HAVE_ARITHRIGHTSHIFT=1
    AC_MSG_RESULT([yes])
else
    HAVE_ARITHRIGHTSHIFT=0
    AC_MSG_RESULT([no])
fi
AC_DEFINE_UNQUOTED([HAVE_ARITHRIGHTSHIFT],
    [$HAVE_ARITHRIGHTSHIFT],
    [define as 1 if >> for long int behaves like an arithmetic right shift for negative numbers])


# TODO: these symbols used to be defined. Check whether we
# need to keep providing them, and/or whether and how to adapt
# source code using them.
# C_UNDERSCORE_SYMBOLS   # for loading kernel extensions
# C_LONG_ALIGN  # unused?
# HAVE_UNION_WAIT
# SYS_ARCH
# GAPARCH


dnl
dnl Find GMP
dnl
AC_ARG_WITH([gmp],
  [AS_HELP_STRING([--with-gmp=<path>],  
                  [prefix of GMP installation. e.g. /usr/local or /usr])],
  [GMP_PREFIX="$with_gmp"],
  [AC_CHECK_LIB([gmp], [__gmpz_init], ,
    AC_MSG_ERROR([GNU Multiple Precision Arithmetic Library not found.
    Maybe you want to call configure with the --with-gmp=<path> option?
    This tells configure where to find the GMP library and headers.
    e.g. --with-gmp=/usr/local or --with-gmp=/usr]))]
)
if test "x$GMP_PREFIX" != x ; then
  GMP_LIBS=" -L${GMP_PREFIX}/lib"
  GMP_CFLAGS=" -I${GMP_PREFIX}/include"
else
  GMP_LIBS=""
  GMP_CFLAGS=""
fi
GMP_LIBS="${GMP_LIBS} -lgmp"
AC_SUBST(GMP_LIBS)
AC_SUBST(GMP_CFLAGS)
AC_DEFINE([USE_GMP], [1], [for backwards compatibility])

# TODO: still try to build an included GMP ?

dnl
dnl Find readline
dnl
AC_ARG_WITH([readline],
  [AS_HELP_STRING([--with-readline],
    [support fancy command line editing @<:@default=check@:>@])],
  [],
  [with_readline=check])

LIBREADLINE=
AS_IF([test "x$with_readline" != xno],
  [AC_CHECK_LIB([readline], [main],
    [AC_SUBST([LIBREADLINE], ["-lreadline -lncurses"])
     AC_DEFINE([HAVE_LIBREADLINE], [1],
               [Define if you have libreadline])
    ],
    [if test "x$with_readline" != xcheck; then
       AC_MSG_FAILURE(
         [--with-readline was given, but test for readline failed])
     fi
    ], -lncurses)
  ]
)


dnl
dnl some user settings
dnl

AC_ARG_ENABLE([hpcgap], [AS_HELP_STRING([--enable-hpcgap], [enable HPC-GAP])])
AM_CONDITIONAL([HPCGAP], [test x$enable_hpcgap = xyes])

# TODO: --enable-compatibility-mode / --enable-compat-mode



dnl
dnl Detect host specific setting
dnl

GP_C_LONG_ALIGN


case "$host_cpu" in 
  sparc* )
    AC_DEFINE([SPARC], [1], [define as 1 on SPARC architecture to flush register windows])
    ;;
  ia64* ) 
    AC_DEFINE([ITANIUM], [1], [define as 1 on Itanium architecture to flush and mark register stack])
    ITANIUM=yes
    ;;
esac

case "$host_os" in
  *cygwin*)
    AC_DEFINE([SYS_IS_CYGWIN32], [1], [define if this is the Cygwin32 port])
    CYGWIN=yes
    ;;
  *darwin*)
    AC_DEFINE([SYS_IS_DARWIN], [1], [define if this is the Darwin port])
    DARWIN=yes
    ;;
esac

dnl Note: AC_DEFINE defines conditionals to be put in config.h, while
dnl AM_CONDITIONAL defines conditionals for use in in Makefile.am
AM_CONDITIONAL([ITANIUM], [test x$ITANIUM = xyes])
AM_CONDITIONAL([SYS_IS_CYGWIN32], [test x$CYGWIN = xyes])
AM_CONDITIONAL([SYS_IS_DARWIN], [test x$DARWIN = xyes])


dnl
dnl check for the existence of various header files
dnl

# FIXME: needed?
#AC_HEADER_STDC


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

AC_CHECK_HEADERS([termios.h termio.h sgtty.h])
AC_CHECK_HEADERS([sys/ioctl.h time.h sys/times.h])


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
AC_CHECK_FUNCS([popen waitpid wait4])

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

if test "$ac_cv_search_dlopen" != "no";  then
  #GP_PROG_CC_EXPORT_DYNAMIC
  if test "$gp_cv_prog_cc_export_dynamic" = yes;  then
    LDFLAGS="$LDFLAGS -export-dynamic"
  fi
fi

case "$LIBS" in 
  *-ldl* )
    C_DYNLIBS="-ldl"
    ;;
  *)
    C_DYNLIBS=""
    ;;
esac;

AC_SUBST(C_DYNLIBS)


dnl error handling
AC_CHECK_HEADERS([errno.h])

dnl check for timing functions
AC_CHECK_FUNCS([times getrusage gettimeofday])
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

dnl check for socket access functions
AC_CHECK_FUNCS([socket accept connect bind send])

dnl check for directory access functions
AC_HEADER_DIRENT
AC_CHECK_FUNCS([opendir closedir readdir])

dnl check for math functions
AC_CHECK_FUNCS([log2 log10 log1p exp2 expm1 exp10 trunc])

dnl sigsetjmp is a macro on some platforms, cannot use AC_CHECK_FUNCS
AC_MSG_CHECKING([for sigsetjmp])
AC_TRY_LINK([#include <setjmp.h>], [sigjmp_buf t; sigsetjmp(t, 0)],
  [AC_MSG_RESULT([yes])
   AC_DEFINE([HAVE_SIGSETJMP], [1], [Define to 1 if you have the `sigsetjmp' function.])],
  [AC_MSG_RESULT([no])]
)

dnl _setjmp is a macro on some platforms, cannot use AC_CHECK_FUNCS
AC_MSG_CHECKING([for _setjmp])
AC_TRY_LINK([#include <setjmp.h>], [sigjmp_buf t; _setjmp(t, 0)],
  [AC_MSG_RESULT([yes])
   AC_DEFINE([HAVE__SETJMP], [1], [Define to 1 if you have the `_setjmp' function.])],
  [AC_MSG_RESULT([no])]
)

# for rusage
AC_CHECK_HEADERS([sys/resource.h])
AC_CHECK_FUNCS([getrusage gettimeofday])


dnl
dnl Output everything
dnl
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
