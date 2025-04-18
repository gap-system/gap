dnl
dnl Setup autoconf
dnl
AC_PREREQ([2.68])

m4_define([gap_version], [4.15dev])
m4_define([gap_releaseday], [today])
m4_define([gap_releaseyear], [this year])

m4_define([gap_tarname], [gap-gap_version])

dnl
dnl library version
dnl
dnl The version of the libgap shared library as well as the kernel version are
dnl tracked here, and follow more or less semver (semantic versioning).
dnl When making a new GAP release, these values need to be adjusted, based on
dnl the following rules:
dnl
dnl 1. If any interfaces have been removed or changed since the last public
dnl    release, then increment major and set minor to 0.
dnl 2. Otherwise (i.e., if no interfaces have been removed or changed),
dnl    if any interfaces have been added since the last public release, then
dnl    increment minor.
dnl
m4_define([kernel_major_version], [10])
m4_define([kernel_minor_version], [0])

m4_define([GAP_DEFINE], [GAP_DEFINES="$GAP_DEFINES -D$1"])

AC_INIT([GAP],
        gap_version,
        [support@gap-system.org],
        gap_tarname,
        [https://www.gap-system.org/])

AC_CONFIG_SRCDIR([src/gap.c])
AC_CONFIG_AUX_DIR([cnf])

dnl we do not use AC_CONFIG_MACRO_DIR but rather a manually created aclocal.m4;
dnl this is in parts because autoreconf and aclocal are only available via GNU automake,
dnl which we do not use; but also because there is no obvious benefit to using it.

AC_CONFIG_HEADERS([build/config.h:src/config.h.in])
AC_CONFIG_COMMANDS([build/stamp-h], [echo timestamp > build/stamp-h])

AS_IF([test "x$srcdir" = x.],
    [AC_MSG_NOTICE([in-tree build])],
    [AC_MSG_NOTICE([out-of-tree build])])

dnl note that the final version used by the GAP kernel is GAP_BUILD_VERSION
dnl and is computed by cnf/gap-version-gen.sh, which takes git commit hashes into
dnl account to produce a more fine-grained version string for GAP development
dnl versions.
AC_SUBST([GAP_VERSION], "gap_version")
AC_SUBST([GAP_RELEASEDAY], "gap_releaseday")
AC_SUBST([GAP_RELEASEYEAR], "gap_releaseyear")

dnl
dnl Get canonical host information
dnl
AC_CANONICAL_HOST


dnl
dnl Check for working C and C++ compiler; insist on C99 and C++11 support
dnl
dnl In autoconf <= 2.69, we use AC_PROG_CC_C99; in autoconf >= 2.70, this
dnl is deprecated, and AC_PROG_CC subsumes it. We have to use some M4 code
dnl to deal with this in way that retains support for autoconf 2.69 while
dnl avoiding warnings in autoconf >= 2.70
m4_if(m4_version_compare(m4_defn([AC_AUTOCONF_VERSION]), [2.70]), -1,
    [AC_PROG_CC_C99],
    [AC_PROG_CC])
AC_PROG_CXX
AX_CXX_COMPILE_STDCXX(11)

AC_LANG([C])


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

dnl Start using ABI_CFLAGS *now*, so that all configure tests we
dnl run from here on use it.
AS_IF([test -n $ABI_CFLAGS],[
  CC="$CC $ABI_CFLAGS"
  CXX="$CXX $ABI_CFLAGS"

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



dnl
dnl Miscellaneous tools
dnl
AC_PROG_INSTALL
AC_PROG_MKDIR_P


dnl
dnl Check for properties of the host system and compiler
dnl

dnl endianness
AC_C_BIGENDIAN

dnl C/C++ attributes with GNU syntax (i.e., `__attribute__(FOO)`)
AX_GCC_FUNC_ATTRIBUTE([always_inline])
AX_GCC_FUNC_ATTRIBUTE([constructor])
AX_GCC_FUNC_ATTRIBUTE([fallthrough])
AX_GCC_FUNC_ATTRIBUTE([format])
AX_GCC_FUNC_ATTRIBUTE([noinline])
AX_GCC_FUNC_ATTRIBUTE([noreturn])
AX_GCC_FUNC_ATTRIBUTE([pure])

dnl compiler builtins
AC_DEFUN([CHECK_COMPILER_BUILTIN],
[AC_MSG_CHECKING([for $1])
    AC_LINK_IFELSE(
        [AC_LANG_PROGRAM(
            [[]],
            [int x; $1[($2)];
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

CHECK_COMPILER_BUILTIN([__builtin_mul_overflow],[0,0,&x]);
CHECK_COMPILER_BUILTIN([__builtin_clz],[0]);
CHECK_COMPILER_BUILTIN([__builtin_clzl],[0]);
CHECK_COMPILER_BUILTIN([__builtin_clzll],[0]);
CHECK_COMPILER_BUILTIN([__builtin_popcountl],[0]);

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
    [],
    [enable_hpcgap=no])
AC_MSG_CHECKING([whether to enable HPC-GAP])
AC_MSG_RESULT([$enable_hpcgap])

AC_SUBST([HPCGAP], [$enable_hpcgap])
AS_IF([test "x$enable_hpcgap" = xyes],
    [
    GAP_DEFINE([HPCGAP=1])

    # HACK, see https://github.com/fingolfin/gap/issues/9
    GAP_DEFINE([MAX_GC_THREADS=4])
    ])

dnl
dnl User setting: garbage collector to use
dnl
AC_ARG_WITH([gc],
    [AS_HELP_STRING([--with-gc@<:@=default|gasman|boehm|julia@:>@],
      [specify which garbage collector to use (default: gasman; for HPC-GAP: boehm)])],
    [],
    [with_gc=default])

dnl
dnl User setting: whether to link against Julia
dnl
dnl This comes here as it interacts with the garbage collector settings.
dnl The actual handling of with_julia comes at a later point.
dnl
AC_ARG_WITH([julia],
  [AS_HELP_STRING([--with-julia@<:@=PATH@:>@],
    [specify a julia binary or a prefix for a julia binary])],
  [],[
    AS_IF([test "x$with_gc" = xjulia],
    [
      with_julia=yes
    ],
    [
      with_julia=no
    ])
  ])


dnl handle the garbage collector setting
AC_MSG_CHECKING([which garbage collector to use])
AS_IF([test "x$with_gc" = xyes], [with_gc=default])
AS_IF([test "x$with_gc" = xdefault],
    [
    with_gc=gasman
    AS_IF([test "x$enable_hpcgap" = xyes], [with_gc=boehm])
    AS_IF([test "x$with_julia" != xno], [with_gc=julia])
    ])
AS_CASE([$with_gc],
    [none|no],  [AC_MSG_ERROR([cannot run GAP without a garbage collector])],
    [boehm],    [AC_SUBST([GC_SOURCES], [src/boehm_gc.c])
                 GAP_DEFINE([USE_BOEHM_GC=1])
                ],
    [gasman],   [AS_IF([test "x$enable_hpcgap" = xyes],
                    [AC_MSG_ERROR([GASMAN cannot be used with HPC-GAP])])
                 AC_SUBST([GC_SOURCES], ["src/gasman.c src/sysmem.c"])
                 GAP_DEFINE([USE_GASMAN=1])
                ],
    [julia],    [AC_SUBST([GC_SOURCES], [src/julia_gc.c])
                 GAP_DEFINE([USE_JULIA_GC=1])
                ],
    [*],        [AC_MSG_ERROR([Invalid gc method '$with_gc', use default|none|gasman|boehm|julia])],
    )
AC_MSG_RESULT([$with_gc])

dnl
dnl User setting: native thread-local storage (off by default)
dnl See src/hpc/tls.h for more details on thread-local storage options.
dnl

AC_ARG_ENABLE([native-tls],
    [AS_HELP_STRING([--enable-native-tls],
        [use native thread-local storage implementation])],
        [enable_native_tls=$enableval],
        [enable_native_tls=no])
AC_MSG_CHECKING([whether to use native tls])
dnl
dnl Distinguish between cases where we support __thread declarations
dnl and situations where we use a pthread_getspecific() implementation.
dnl Right now, we only do the latter for 64-bit macOS. See src/hpc/tls.h
dnl for details.
dnl
enable_macos_tls_asm=default
AS_IF([[test "x$enable_native_tls" = "xyes"]], [
        case "$host" in
            x86_64-apple-darwin*)
                GAP_DEFINE([USE_PTHREAD_TLS=1])
                dnl
                dnl Test if we can optimize pthread_getspecific() calls via
                dnl inline assembly on macOS.
                dnl
                AC_RUN_IFELSE(
                    [AC_LANG_SOURCE([[
// The following code also occurs in src/hpc/thread.c and both need to be
// kept in sync.
#include <pthread.h>
#include <string.h>

#define OFFS 0x100
#define END (-1)

int cmpOpCode(unsigned char *code, int *with) {
    int result = 0;
    while (*with >= 0) {
        if (*with == OFFS) {
            result = *code;
        } else {
            if (*code != *with)
                return -1;
        }
        code++;
        with++;
    }
    return result;
}

int main() {
    // This is an idea borrowed from Mono. We test if the implementation
    // of pthread_getspecific() uses the assembly code below. If that is
    // true, we can replace calls to pthread_getspecific() with the
    // matching inline assembly, allowing a significant performance boost.
#if defined(__APPLE__) && defined(__x86_64__)
    // There are two possible implementations.
    static int asm_code[] = {
        // movq %gs:[OFFS](,%rdi,8), %rax
        // retq
        0x65, 0x48, 0x8b, 0x04, 0xfd, OFFS, 0x00, 0x00, 0x00, 0xc3, END
    };
    static int asm_code2[] = {
        // pushq  %rbp
        // movq   %rsp, %rbp
        // movq   %gs:[OFFS](,%rdi,8),%rax
        // popq   %rbp
        // retq
        0x55, 0x48, 0x89, 0xe5, 0x65, 0x48, 0x8b, 0x04, 0xfd, OFFS,
        0x00, 0x00, 0x00, 0x5d, 0xc3, END
    };
    if (cmpOpCode((unsigned char *)pthread_getspecific, asm_code) >= 0) {
        return 0;
    }
    if (cmpOpCode((unsigned char *)pthread_getspecific, asm_code2) >= 0) {
        return 0;
    }
    return 1;
#else
#error FAIL
#endif
}
                    ]])],
                    dnl => Test succeeded
                    [GAP_DEFINE([USE_MACOS_PTHREAD_TLS_ASM=1])
                    AC_MSG_RESULT([[yes (macOS assembly)]])
                    enable_macos_tls_asm=yes
                    ],
                    dnl => Test failed
                    [AC_MSG_RESULT([[yes (pthread-based)]])
                    enable_macos_tls_asm=no
                    ],
                    dnl => Cross-compilation, test impossible
                    [AC_MSG_RESULT([[yes (pthread-based)]])
                    enable_macos_tls_asm=no
                    ])
            ;;
            *)
                dnl => Any other OS, --with-native-tls specified
                GAP_DEFINE([USE_NATIVE_TLS=1])
                AC_MSG_RESULT([yes])
            ;;
        esac
    ],
    [
        dnl => --without-native-tls
        AC_MSG_RESULT([no])
    ]
)
dnl
dnl Test if pthread_getspecific() can be overridden as
dnl __attribute__((pure)).
dnl
AS_IF([test "x$enable_hpcgap" = xyes],[
AC_MSG_CHECKING([[whether pthread_getspecific() can be made pure]])
AC_COMPILE_IFELSE(
    [AC_LANG_SOURCE([[
#include <pthread.h>
__attribute__((pure))
void * pthread_getspecific(pthread_key_t key);
]])], [
    AC_MSG_RESULT(yes)
    GAP_DEFINE([ALLOW_PURE_PTHREAD_GETSPECIFIC=1])
], [
    AC_MSG_RESULT(no)
])
])

dnl
dnl User setting: Debug mode (off by default)
dnl
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug], [enable debug mode])],
    [],
    [enable_debug=no]
    )
AC_MSG_CHECKING([whether to enable debug mode])
AC_MSG_RESULT([$enable_debug])

AS_IF([test "x$enable_debug" != "xno"],
    [GAP_DEFINE([GAP_KERNEL_DEBUG=1])
     GAP_DEFINE([GAP_PRINT_BACKTRACE=1])],
)

dnl
dnl Maintainer mode (on by default) controls whether our build system
dnl automatically regenerates `configure` if `configure.ac` or any of its
dnl other sources changes, by running `autoconf`. Similarly, it regenerates
dnl `src/config.h.in` if necessary by running `autoheader`.
dnl
dnl While this is very useful when developing GAP, it can be problematic if
dnl a user wants to compile a release version of GAP but does not have
dnl autoconf installed; or if for some reason the GAP source code is readonly
dnl and they want to run an out-of-tree build. Thus we allow turning this
dnl off.
AC_ARG_ENABLE([maintainer-mode],
    [AS_HELP_STRING([--disable-maintainer-mode], [disable maintainer mode])],
    [],
    [enable_maintainer_mode=yes]
    )
AC_MSG_CHECKING([whether to enable maintainer-mode mode])
AC_MSG_RESULT([$enable_maintainer_mode])
AC_SUBST([MAINTAINER_MODE], [$enable_maintainer_mode])

dnl
AC_ARG_ENABLE([memory-checking],
    [AS_HELP_STRING([--enable-memory-checking], [enable memory checking])],
    [],
    [enable_memory_checking=no]
    )
AC_MSG_CHECKING([whether to enable memory checking])
AC_MSG_RESULT([$enable_memory_checking])

AS_IF([test "x$enable_memory_checking" != "xno"],
  [GAP_DEFINE([GAP_MEM_CHECK=1])]
)

dnl
AC_ARG_ENABLE([valgrind],
    [AS_HELP_STRING([--enable-valgrind], [enable valgrind extensions to GASMAN])],
    [],
    [enable_valgrind=no]
    )
AC_MSG_CHECKING([whether to enable valgrind extensions to GASMAN])
AC_MSG_RESULT([$enable_valgrind])

AS_IF([test "x$enable_valgrind" != "xno"],
  [GAP_DEFINE([GAP_MEMORY_CANARY=1])]
)

if test "x$enable_valgrind" != "xno" -a "x$enable_memory_checking" != "xno"; then
    AC_MSG_ERROR([--enable-valgrind and --enable-memory-checking cannot be used at the same time])
fi

if test "x$with_gc" != "xgasman"; then
    if test "x$enable_valgrind" != "xno" -o "x$enable_memory_checking" != "xno"; then
        AC_MSG_ERROR([--enable-valgrind and --enable-memory-checking are only compatible with GASMAN])
    fi
fi

dnl
dnl User setting: Enable -Werror (off by default)
dnl

AC_ARG_ENABLE([Werror],
    AS_HELP_STRING([--enable-Werror], [treat compiler warnings as errors]),
    [],
    [enable_Werror=no])
AC_MSG_CHECKING([whether to treat C compiler warnings as errors])
AC_MSG_RESULT([$enable_Werror])


AS_IF([test "x$enable_Werror" != "xno"],
  [ax_enable_compile_warnings=error],
  [ax_enable_compile_warnings=yes])

AX_COMPILER_WARNING_FLAGS

dnl
dnl User setting: Enable popcnt (on by default)
dnl

AC_ARG_ENABLE([popcnt],
    AS_HELP_STRING([--enable-popcnt], [use __builtin_popcountl if available]),
    [],
    [enable_popcnt=yes])
AC_MSG_CHECKING([whether to try and use __builtin_popcountl])
AC_MSG_RESULT([$enable_popcnt])

AS_IF([test "x$enable_popcnt" != "xno"],
    [USE_POPCNT=1],
    [USE_POPCNT=0])

AC_DEFINE_UNQUOTED([USE_POPCNT],
    [$USE_POPCNT],
    [define as 1 if we should try and use the __builtin_popcountl function if available])

dnl
dnl External dependencies
dnl

# We support finding dependencies in certain non-standard locations:
#  Homebrew on macOS: $(brew --prefix) (usually /opt/homebrew or /usr/local)
#  Fink on macOS: /sw
#  MacPorts: /opt/local
HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null || :)"
DEFAULT_SEARCH_PATH="$HOMEBREW_PREFIX /opt/local /sw"

dnl Find GMP
AC_ARG_WITH([gmp],
  [AS_HELP_STRING([--with-gmp@<:@=builtin|PREFIX@:>@],
    [prefix of GMP installation. e.g. /usr/local; specify `builtin' to let GAP builds its own version of GMP])],
    [],[with_gmp=yes])

BUILD_GMP=no
GMP_SEARCH_PATH="DEFAULTS ${DEFAULT_SEARCH_PATH}"
GMP_CPPFLAGS=
GMP_LDFLAGS=
GMP_LIBS="-lgmp"
GMP_PREFIX=
AS_CASE([$with_gmp],
  [builtin],[
    # user explicitly requested to use builtin GMP
    GMP_SEARCH_PATH=""
    AC_MSG_NOTICE([Using bundled GMP])
  ],
  [no],[
    AC_MSG_ERROR([Building without GMP is not supported])
  ],
  [system],[
    dnl supported for backwards compatibility with old build system
    with_gmp=yes
  ],
  [yes],[],
  [*],[
    GMP_SEARCH_PATH="$with_gmp"
  ]
)

save_CFLAGS=${CFLAGS}
save_LIBS=${LIBS}

AC_MSG_CHECKING([for GMP])
gmp_found=no
for GMP_PREFIX in ${GMP_SEARCH_PATH} ; do
  AS_IF([test "$GMP_PREFIX" != "DEFAULTS"],[
    GMP_CPPFLAGS="-I${GMP_PREFIX}/include"
    GMP_LDFLAGS="-L${GMP_PREFIX}/lib"
  ],[
    GMP_PREFIX=""
    GMP_CPPFLAGS=""
    GMP_LDFLAGS=""
  ])
  CFLAGS="${GMP_CPPFLAGS} ${save_CFLAGS}"
  LIBS="${GMP_LDFLAGS} ${GMP_LIBS} ${save_LIBS}"
  AC_LINK_IFELSE(
    [AC_LANG_PROGRAM([[#include <gmp.h>]],
              [[mpz_t a; mpz_init (a);]])],
    [gmp_found=yes
     AS_IF([test x"$GMP_PREFIX" != x""],[
       AC_MSG_RESULT([yes, at prefix ${GMP_PREFIX}])
     ],[
       AC_MSG_RESULT([yes, in default search path])
     ])
     break],
  )
done

CFLAGS=${save_CFLAGS}
LIBS=${save_LIBS}

# Fall back to bundled GMP if necessary
AS_IF([test x$gmp_found = xno],[
  AC_MSG_RESULT([build bundled copy])
  BUILD_GMP=yes
  GMP_PREFIX='${abs_builddir}/extern/install/gmp'
  GMP_CPPFLAGS='-I${abs_builddir}/extern/install/gmp/include'
  GMP_LDFLAGS='-L${abs_builddir}/extern/install/gmp/lib'
  GMP_LIBS='-Wl,-rpath,${abs_builddir}/extern/install/gmp/lib -lgmp'
])

AC_SUBST([BUILD_GMP])
AC_SUBST([GMP_CPPFLAGS])
AC_SUBST([GMP_LDFLAGS])
AC_SUBST([GMP_LIBS])
AC_SUBST([GMP_PREFIX])


dnl Find zlib
AC_ARG_WITH([zlib],
  [AS_HELP_STRING([--with-zlib@<:@=builtin|PREFIX@:>@],
    [prefix of zlib installation. e.g. /usr/local; specify `builtin' to let GAP builds its own version of zlib])],
    [],[with_zlib=yes])

BUILD_ZLIB=no
ZLIB_SEARCH_PATH="DEFAULTS ${DEFAULT_SEARCH_PATH}"
ZLIB_CPPFLAGS=
ZLIB_LDFLAGS=
ZLIB_LIBS="-lz"
AS_CASE([$with_zlib],
  [builtin],[
    # user explicitly requested to use builtin zlib
    ZLIB_SEARCH_PATH=""
    AC_MSG_NOTICE([Using bundled zlib])
  ],
  [no],[
    AC_MSG_ERROR([Building without zlib is not supported])
  ],
  [system],[
    dnl supported for backwards compatibility with old build system
    with_zlib=yes
  ],
  [yes],[],
  [*],[
    ZLIB_SEARCH_PATH="$with_gmp"
  ]
)

save_CFLAGS=${CFLAGS}
save_LIBS=${LIBS}

AC_MSG_CHECKING([for zlib])
zlib_found=no
for ZLIB_PREFIX in ${ZLIB_SEARCH_PATH} ; do
  AS_IF([test "$ZLIB_PREFIX" != "DEFAULTS"],[
    ZLIB_CPPFLAGS="-I${ZLIB_PREFIX}/include"
    ZLIB_LDFLAGS="-L${ZLIB_PREFIX}/lib"
  ],[
    ZLIB_PREFIX=""
    ZLIB_CPPFLAGS=""
    ZLIB_LDFLAGS=""
  ])
  CFLAGS="${ZLIB_CPPFLAGS} ${save_CFLAGS}"
  LIBS="${ZLIB_LDFLAGS} ${ZLIB_LIBS} ${save_LIBS}"
  AC_LINK_IFELSE(
    [AC_LANG_PROGRAM([[#include <zlib.h>]],
              [[z_stream a; inflateEnd(&a);]])],
    [zlib_found=yes
     AS_IF([test x"$ZLIB_PREFIX" != x""],[
       AC_MSG_RESULT([yes, at prefix ${ZLIB_PREFIX}])
     ],[
       AC_MSG_RESULT([yes, in default search path])
     ])
     break],
  )
done

CFLAGS=${save_CFLAGS}
LIBS=${save_LIBS}

# Fall back to bundled zlib if necessary
AS_IF([test x$zlib_found = xno],[
  AC_MSG_RESULT([build bundled copy])
  BUILD_ZLIB=yes
  ZLIB_CPPFLAGS='-I${abs_builddir}/extern/install/zlib/include'
  ZLIB_LDFLAGS='-L${abs_builddir}/extern/install/zlib/lib'
  ZLIB_LIBS='-Wl,-rpath,${abs_builddir}/extern/install/zlib/lib -lz'
])

AC_SUBST([BUILD_ZLIB])
AC_SUBST([ZLIB_CPPFLAGS])
AC_SUBST([ZLIB_LDFLAGS])
AC_SUBST([ZLIB_LIBS])


dnl Find GNU readline
AC_ARG_WITH([readline],
  [AS_HELP_STRING([--with-readline@<:@=PREFIX@:>@],
    [support fancy command line editing via GNU readline; optionally
     specify a prefix where it can be found])],
    [],[with_readline=check])

READLINE_SEARCH_PATH="DEFAULTS DEFAULTS_EREADLINE $HOMEBREW_PREFIX/opt/readline ${DEFAULT_SEARCH_PATH}"
READLINE_CPPFLAGS=
READLINE_LDFLAGS=
READLINE_LIBS=

AS_CASE([$with_readline],
  [no],[
    READLINE_SEARCH_PATH=""
  ],
  [check],[],
  [yes],[],
  [*],[
    READLINE_SEARCH_PATH="$with_readline"
  ]
)

dnl Now check if we can find GNU readline. We go to some extra efforts to
dnl ensure it is GNU readline, and not e.g. BSD editline wrappers for
dnl readline, which do not suffice for GAP.
dnl
dnl note that OpenBSD installs modern (v6+) GNU readline into /usr/local under name libereadline
dnl and its headers into /usr/local/include/ereadline.
save_CFLAGS=${CFLAGS}
save_LIBS=${LIBS}

AC_MSG_CHECKING([for GNU readline])
readline_found=no
for READLINE_PREFIX in ${READLINE_SEARCH_PATH} ; do
  AS_CASE([$READLINE_PREFIX],
    [DEFAULTS],[
      READLINE_PREFIX=""
      READLINE_CPPFLAGS=""
      READLINE_LDFLAGS=""
      READLINE_LIBS="-lreadline"
    ],
    [DEFAULTS_EREADLINE],[
      dnl ereadline is the name of GNU readline library on OpenBSD
      READLINE_PREFIX=""
      READLINE_CPPFLAGS="-I/usr/local/include/ereadline"
      READLINE_LDFLAGS=""
      READLINE_LIBS="-lereadline"
    ],
    [*],[
      READLINE_CPPFLAGS="-I${READLINE_PREFIX}/include"
      READLINE_LDFLAGS="-L${READLINE_PREFIX}/lib"
      READLINE_LIBS="-lreadline"
    ]
  )
  CFLAGS="${READLINE_CPPFLAGS} ${save_CFLAGS}"
  LIBS="${READLINE_LDFLAGS} ${READLINE_LIBS} ${save_LIBS}"
  AC_LINK_IFELSE(
    [AC_LANG_PROGRAM([[#include <stdio.h>
                       #include <readline/readline.h>]],
              [[rl_bind_keyseq(0,0);]])],
    [readline_found=yes
     AS_IF([test x"$READLINE_PREFIX" != x""],[
       AC_MSG_RESULT([yes, at prefix ${READLINE_PREFIX}])
     ],[
       AC_MSG_RESULT([yes, in default search path])
     ])
     AC_DEFINE([HAVE_LIBREADLINE], [1], [Define if you have lib(e)readline])
     break],
  )
done

CFLAGS=${save_CFLAGS}
LIBS=${save_LIBS}

AS_IF([test x$readline_found = xno],[
  AC_MSG_RESULT([no])
  AS_IF([test x$with_readline != xcheck && test x$with_readline != xno],[
    AC_MSG_FAILURE([--with-readline was given, but further tests for readline failed])
  ])
  READLINE_CPPFLAGS=
  READLINE_LDFLAGS=
  READLINE_LIBS=
])

AC_SUBST([READLINE_CPPFLAGS])
AC_SUBST([READLINE_LDFLAGS])
AC_SUBST([READLINE_LIBS])


dnl Find julia

AC_DEFUN([FIND_JULIA],
[
  AS_IF([test -x "$with_julia" && test ! -d "$with_julia" ],
  [
    JULIA="${with_julia}"
  ],
  [
    AS_IF([test -d "$with_julia"  ],
    [
      JULIA_PATH="${with_julia}/bin:${with_julia}:${with_julia}/usr/bin"
    ],
    [
      AS_IF([test "x$with_julia" != xyes ],
        [ AC_MSG_ERROR([invalid argument to --with-julia]) ] )
      JULIA_PATH="${PATH}"
    ])
    AC_PATH_PROG([JULIA], [julia], [], [$JULIA_PATH])
  ])
  AS_IF([test "x$JULIA" = x],[ AC_MSG_ERROR([no julia executable found]) ])
  JL_SHARE=$($JULIA --startup-file=no -e 'print(joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia"))')
])

AS_IF([test "x$with_julia" != xno ],[

  AS_IF([test "x$JULIA_VERSION" != x],[],
        [test "x$JULIA_CFLAGS" != x],[],
        [test "x$JULIA_LDFLAGS" != x],[],
        [test "x$JULIA_LIBS" != x],[],
        [FIND_JULIA])

  AC_MSG_CHECKING([for Julia version])
  AS_IF([test "x$JULIA_VERSION" = x],[
    JULIA_VERSION=$(${JULIA} --startup-file=no -e 'print("$(VERSION.major).$(VERSION.minor)")')
    AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain Julia version])])
  ])
  AC_MSG_RESULT([${JULIA_VERSION}])

  AC_MSG_CHECKING([for JULIA_CFLAGS])
  AS_IF([test "x$JULIA_CFLAGS" = x],[
    AS_IF([test -f "${JL_SHARE}/julia-config.jl"], [], [AC_MSG_ERROR([no julia-config.jl found])])
    JULIA_CFLAGS=$(${JULIA} --startup-file=no ${JL_SHARE}/julia-config.jl --cflags 2>/dev/null)
    JULIA_CFLAGS=${JULIA_CFLAGS/-std=gnu99/}  # need to remove -std=gnu99 for our C11 and C++ code
    AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain JULIA_CFLAGS from julia-config.jl])])
  ])
  AC_MSG_RESULT([${JULIA_CFLAGS}])

  AC_MSG_CHECKING([for JULIA_LDFLAGS])
  AS_IF([test "x$JULIA_LDFLAGS" = x],[
    AS_IF([test -f "${JL_SHARE}/julia-config.jl"], [], [AC_MSG_ERROR([no julia-config.jl found])])
    JULIA_LDFLAGS=$(${JULIA} --startup-file=no ${JL_SHARE}/julia-config.jl --ldflags)
    AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain JULIA_LDFLAGS from julia-config.jl])])
    JULIA_LDFLAGS=${JULIA_LDFLAGS//\'/}
  ])
  AC_MSG_RESULT([${JULIA_LDFLAGS}])

  AC_MSG_CHECKING([for JULIA_LIBS])
  AS_IF([test "x$JULIA_LIBS" = x],[
    AS_IF([test -f "${JL_SHARE}/julia-config.jl"], [], [AC_MSG_ERROR([no julia-config.jl found])])
    JULIA_LIBS=$(${JULIA} --startup-file=no ${JL_SHARE}/julia-config.jl --ldlibs)
    AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain JULIA_LIBS from julia-config.jl])])
    # remove apostrophes, they confuse libtool in some cases.
    JULIA_LIBS=${JULIA_LIBS//\'/}
  ])
  AC_MSG_RESULT([${JULIA_LIBS}])
],
[
  AS_IF( [ test "x$with_gc" = xjulia ],
  [
    AC_MSG_ERROR([ julia was selected as GC, but julia support was disabled ])
  ])
])
AC_SUBST([JULIA_VERSION])
AC_SUBST([JULIA_CFLAGS])
AC_SUBST([JULIA_LDFLAGS])
AC_SUBST([JULIA_LIBS])

dnl TODO: check if $with_gc = julia; if so, error out if julia is not found

AS_IF([test "x$with_gc" = xboehm],
  [
  # We bundle two libraries we need for HPC-GAP:
  # Boehm garbage collector, see https://www.hboehm.info/gc/
  # libatomic_ops - part of Boehm GC, but see also https://github.com/ivmai/libatomic_ops
  #
  # We bundle them because we need a few patches to Boehm GC which are
  # not upstream (and it is unclear whether they ever will be).
  # And we bundle libatomic_ops because its version must match that
  # of Boehm GC; the easiest way to ensure that is to include that, too.
  #
  # As a side benefit, users do not have to worry about installing dependencies.

  BUILD_LIBATOMIC_OPS=yes
  LIBATOMIC_OPS_CPPFLAGS='-I${abs_builddir}/extern/install/libatomic_ops/include'
  LIBATOMIC_OPS_LDFLAGS='-L${abs_builddir}/extern/install/libatomic_ops/lib'
  LIBATOMIC_OPS_LIBS='-Wl,-rpath,${abs_builddir}/extern/install/libatomic_ops/lib  -latomic_ops'
  AC_SUBST([BUILD_LIBATOMIC_OPS])
  AC_SUBST([LIBATOMIC_OPS_CPPFLAGS])
  AC_SUBST([LIBATOMIC_OPS_LDFLAGS])
  AC_SUBST([LIBATOMIC_OPS_LIBS])

  ATOMIC_OPS_CFLAGS=$LIBATOMIC_OPS_CPPFLAGS
  ATOMIC_OPS_LIBS=$LIBATOMIC_OPS_LDFLAGS


  BUILD_BOEHM_GC=yes
  BOEHM_GC_CPPFLAGS='-I${abs_builddir}/extern/install/gc/include'
  BOEHM_GC_LDFLAGS='-L${abs_builddir}/extern/install/gc/lib'
  BOEHM_GC_LIBS='-Wl,-rpath,${abs_builddir}/extern/install/gc/lib -lgc'
  AC_SUBST([BUILD_BOEHM_GC])
  AC_SUBST([BOEHM_GC_CPPFLAGS])
  AC_SUBST([BOEHM_GC_LDFLAGS])
  AC_SUBST([BOEHM_GC_LIBS])
  ]
)

dnl
dnl Export library and kernel version
dnl

AC_SUBST([gap_kernel_major_version], kernel_major_version)
AC_SUBST([gap_kernel_minor_version], kernel_minor_version)

dnl
dnl Determine the GAPARCH string, used by package build systems and more
dnl

AC_MSG_CHECKING([the GAPARCH])

dnl The "host" identifier is the start
case "$host_os" in
  *darwin*)
    # On macOS / Darwin, override the config.guess result, which includes
    # the minor versions of macOS, which has no benefit but is painful as
    # every patch update of the OS may result in all packages having to be
    # recompiled. So instead of e.g. `darwin21.2.0` (for macOS 12.2.0) and
    # `darwin21.4.0` (for macOS 12.3.1), use just `darwin21`, and so on.
    GAPARCH="$host_cpu-$host_vendor-${host_os%%.*.*}"
    ;;
  *)
    GAPARCH="$host"
    ;;
esac

dnl Append primary build variant
AS_IF(
  [test "x$enable_hpcgap" = xyes],
     [GAPARCH="$GAPARCH-hpcgap"],
  [test "x$with_julia" != xno],
     [GAPARCH="$GAPARCH-julia${JULIA_VERSION}-"],
  # else
     [GAPARCH="$GAPARCH-default"])

dnl Append ABI (for historical reasons, we don't insert a dash before it)
GAPARCH="${GAPARCH}${ABI}"

dnl Append kernel version
GAPARCH="${GAPARCH}-kv${gap_kernel_major_version}"

dnl Allow user to extend the GAPARCH with some extra key
AS_IF([test "x$ARCHEXT" != "x"], [GAPARCH="$GAPARCH-$ARCHEXT"])

dnl Allow user to completely override the GAPARCH (should be used sparingly!)
AS_IF([test "x$ARCH" != "x"], [GAPARCH="$ARCH"])

AC_MSG_RESULT([${GAPARCH}])
AC_DEFINE_UNQUOTED([GAPARCH], ["$GAPARCH"], [the GAP architecture, for kernel extensions])
AC_SUBST([GAPARCH])


dnl
dnl Detect host specific setting
dnl

GP_C_LONG_ALIGN

case "$host_cpu" in
  sparc* )
    AC_DEFINE([SYS_IS_SPARC], [1], [define as 1 on SPARC architecture to flush register windows])
    ;;
esac


dnl
dnl check for the existence of various header files
dnl

dnl check for functionality related to child process handling,
dnl including pseudo TTY support, signals, etc.
AC_CHECK_HEADERS([termios.h])
AC_CHECK_HEADERS([sys/ioctl.h sys/resource.h])


# openpty() is available on various BSD variants, but also in glibc.
# On BSD systems, one usually needs to add -lutil to LIBS in order
# to use it.
AC_SEARCH_LIBS([openpty], [util],
    AC_DEFINE([HAVE_OPENPTY], [1], [define as 1 if you have `openpty']))

AS_IF([test "x$ac_cv_search_openpty" = xno],[
  # Check for POSIX 98 pty APIs to use instead of openpty()
  AC_CHECK_FUNCS([ptsname grantpt unlockpt posix_openpt])
],[
  # Check for headers declaring openpty()
  AC_CHECK_HEADERS([util.h pty.h libutil.h])
])

dnl check for input/output functions
AC_CHECK_HEADERS([signal.h])
AC_CHECK_FUNCS([select])

dnl various functions to deal with child processes
AC_CHECK_HEADERS([spawn.h])
AC_HEADER_SYS_WAIT
AC_FUNC_FORK
AC_CHECK_FUNCS([popen posix_spawn])
AC_CHECK_FUNCS([posix_spawn_file_actions_addchdir])
AC_CHECK_FUNCS([posix_spawn_file_actions_addchdir_np])

dnl signal handling
AC_CHECK_TYPE([sig_atomic_t], [],
    [AC_DEFINE([HAVE_SIG_ATOMIC_T],[],[Check for sig_atomic_t])],
    [#include <signal.h>]
)
AC_CHECK_FUNCS([signal sigaction setpgid])


dnl
dnl check for dynamic loading of modules
dnl

AC_SEARCH_LIBS([dlopen], [dl],
    [AC_DEFINE([HAVE_DLOPEN], [1], [define as 1 if you have `dlopen' and `dlsym'])]
)


dnl check for timing functions
AC_CHECK_HEADERS([sys/time.h])
AC_CHECK_FUNCS([getrusage gettimeofday clock_gettime clock_getres])
AC_CHECK_FUNCS([setitimer])

dnl check for functions dealing with virtual memory
AC_CHECK_FUNCS([vm_allocate sbrk madvise sysconf])

dnl check for large-file support (for accessing files whose sizes or inodes require 64bits)
AC_SYS_LARGEFILE

dnl check whether libm / -lm is available and necessary
AC_SEARCH_LIBS([cos], [m], [], [
  AC_MSG_ERROR([unable to find the cos() function])
])

dnl check for non-standard math functions
AC_CHECK_FUNCS([exp10])

dnl pthreads
dnl unconditionally check for pthread flags (and use them), even though we
dnl only use pthreads if HPC-GAP is enabled. The reason is that if a kernel
dnl extension uses pthreads (e.g. that of the Semigroups package does it),
dnl then it may be necessary under certain Linux variants that the
dnl gap executable is linked with flags like `-pthread`. If it is not, then
dnl using the kernel extension leads to a runtime exception.
dnl See also <https://github.com/gap-system/gap/issues/5192>
#AS_IF([test "x$enable_hpcgap" = xyes -o "x$with_julia" != xno ],[
  AX_PTHREAD
#  ])

dnl backtraces via execinfo
AX_EXECINFO

AS_IF([test "x$enable_hpcgap" = xyes],[
  AS_BOX([WARNING: Experimental HPC-GAP mode enabled])
  dnl also enable backtrace, to help debug spurious crashes
  AC_DEFINE([GAP_PRINT_BACKTRACE], [1], [to enable backtraces upon crashes])
  ])

AS_IF([test "x$enable_macos_tls_asm" = xno],[
  AS_BOX([WARNING: macOS fast thread-local storage not available])
])

dnl
dnl Output everything
dnl
AC_SUBST([GAP_DEFINES], [$GAP_DEFINES])

AC_CONFIG_FILES([GNUmakefile])
AC_CONFIG_FILES([CITATION])
AC_CONFIG_FILES([libgap.pc])
AC_CONFIG_FILES([doc/make_doc], [chmod +x doc/make_doc])
AC_CONFIG_FILES([doc/versiondata])
AC_OUTPUT
