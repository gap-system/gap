dnl
dnl Setup autoconf
dnl
AC_PREREQ([2.68])
AC_INIT([GAP], [4.dev], [support@gap-system.org], [gap], [https://www.gap-system.org/])

AC_CONFIG_SRCDIR([src/gap.c])
AC_CONFIG_AUX_DIR([cnf])

AC_CONFIG_HEADERS([gen/config.h:src/config.h.in])
AC_CONFIG_COMMANDS([gen/stamp-h], [echo timestamp > gen/stamp-h])

dnl
dnl Get canonical host information
dnl
AC_CANONICAL_HOST


dnl
dnl Check for working C and C++ compiler; insist on C99 support
dnl
AC_PROG_CC_C99
AC_PROG_CXX
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
dnl Setup libtool (for interfacing with GAP kernel extension)
dnl
LT_PREREQ([2.4.2])
LT_INIT([disable-static dlopen win32-dll])


dnl
dnl Check for properties of the host system and compiler
dnl

dnl endianess
AC_C_BIGENDIAN

dnl function attributes
AX_GCC_FUNC_ATTRIBUTE([always_inline])
AX_GCC_FUNC_ATTRIBUTE([format])
AX_GCC_FUNC_ATTRIBUTE([noinline])
AX_GCC_FUNC_ATTRIBUTE([noreturn])

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

CHECK_COMPILER_BUILTIN([__builtin_mul_overflow],[0,0,0]);
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
    AC_DEFINE([HPCGAP], [1], [define if building HPC-GAP])

    # HACK, see https://github.com/fingolfin/gap/issues/9
    AC_DEFINE([MAX_GC_THREADS], [4], [maximum number of GC threads])
    ])

dnl
dnl User setting: garbage collector to use
dnl
AC_ARG_WITH([gc],
    [AS_HELP_STRING([--with-gc@<:@=default|gasman|boehm|julia@:>@],
      [specify which garbage collector to use (default: gasman; for HPC-GAP: boehm)])],
    [],
    [with_gc=default])
AC_MSG_CHECKING([which garbage collector to use])
AS_IF([test "x$with_gc" = xyes], [with_gc=default])
AS_IF([test "x$with_gc" = xdefault],
    [
    AS_IF([test "x$enable_hpcgap" = xyes], [with_gc=boehm], [with_gc=gasman])
    ])
AS_CASE([$with_gc],
    [none|no],  [AC_MSG_ERROR([cannot run GAP without a garbage collector])],
    [boehm],    [AC_SUBST([GC_SOURCES], [src/boehm_gc.c])
                 AC_DEFINE([USE_BOEHM_GC],  [1], [define as 1 if Boehm GC is used])
                ],
    [gasman],   [AS_IF([test "x$enable_hpcgap" = xyes],
                    [AC_MSG_ERROR([GASMAN can not be used with HPC-GAP])])
                 AC_SUBST([GC_SOURCES], [src/gasman.c])
                 AC_DEFINE([USE_GASMAN],    [1], [define as 1 if GASMAN is used])
                ],
    [julia],    [AC_SUBST([GC_SOURCES], [src/julia_gc.c])
                 AC_DEFINE([USE_JULIA_GC],  [1], [define as 1 if the Julia GC is used])
                ],
    [*],        [AC_MSG_ERROR([Invalid gc method '$with_gc', use default|none|gasman|boehm|julia])],
    )
AC_MSG_RESULT([$with_gc])

dnl
dnl User setting: Debug mode (off by default)
dnl
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug], [enable debug mode])],
    [AC_DEFINE([GAP_KERNEL_DEBUG], [1], [define if building in debug mode])
     AC_DEFINE([GAP_PRINT_BACKTRACE], [1], [to enable backtraces upon crashes])],
    [enable_debug=no]
    )
AC_MSG_CHECKING([whether to enable debug mode])
AC_MSG_RESULT([$enable_debug])

AC_ARG_ENABLE([memory-checking],
    [AS_HELP_STRING([--enable-memory-checking], [enable memory checking])],
    [AC_DEFINE([GAP_MEM_CHECK], [1], [define if building with memory checking])],
    [enable_memory_checking=no]
    )
AC_MSG_CHECKING([whether to enable memory checking])
AC_MSG_RESULT([$enable_memory_checking])

AC_ARG_ENABLE([valgrind],
    [AS_HELP_STRING([--enable-valgrind], [enable valgrind extensions to GASMAN])],
    [AC_DEFINE([GAP_MEMORY_CANARY], [1], [define if building with valgrind extensions])],
    [enable_valgrind=no]
    )
AC_MSG_CHECKING([whether to enable valgrind extensions to GASMAN])
AC_MSG_RESULT([$enable_valgrind])

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
  GMP_CPPFLAGS='-I${abs_builddir}/extern/install/gmp/include'
  GMP_LDFLAGS='${abs_builddir}/extern/install/gmp/lib/libgmp.la'
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


dnl Find zlib
AC_ARG_WITH([zlib],
  [AS_HELP_STRING([--with-zlib@<:@=builtin|PREFIX@:>@],
    [prefix of zlib installation. e.g. /usr/local; specify `builtin' to let GAP builds its own version of zlib])],
    [],[with_zlib=yes])

BUILD_ZLIB=no
ZLIB_CPPFLAGS=
ZLIB_LDFLAGS=
ZLIB_LIBS="-lz"
AS_CASE([$with_zlib],
  [builtin],[
    # user explicitly requested to use builtin zlib
    BUILD_ZLIB=yes
    AC_MSG_NOTICE([Using bundled zlib])
  ],
  [no],[
    AC_MSG_ERROR([Building without zlib is not supported])
  ],
  [system],[with_zlib=yes],  dnl supported for backwards compatibility with old build system
  [yes],[],
  [*],[
    ZLIB_CPPFLAGS="-I${with_zlib}/include"
    ZLIB_LDFLAGS="-L${with_zlib}/lib"
  ]
)


AS_IF([test $BUILD_ZLIB = no],
  [
    # try to link against zlib
    AX_CHECK_LIBRARY([ZLIB], [zlib.h], [z], [inflateEnd])
    AS_IF([test $ax_cv_have_ZLIB = no],[
        AS_IF([test "x$with_zlib" = "xyes"],[
          BUILD_ZLIB=yes
          AC_MSG_NOTICE([No usable zlib found, switching to included zlib])
        ],
        [AC_MSG_ERROR([zlib not found at prefix $with_zlib])]
        )
    ])
  ])

# Use bundled zlib if requested
AS_IF([test x$BUILD_ZLIB = xyes],[
  BUILD_ZLIB=yes
  ZLIB_CPPFLAGS='-I${abs_builddir}/extern/install/zlib/include'
  ZLIB_LDFLAGS='-L${abs_builddir}/extern/install/zlib/lib/ -Wl,-rpath -Wl,${abs_builddir}/extern/install/zlib/lib/ -lz'
  ZLIB_LIBS=
])

AC_SUBST([BUILD_ZLIB])
AC_SUBST([ZLIB_CPPFLAGS])
AC_SUBST([ZLIB_LDFLAGS])
AC_SUBST([ZLIB_LIBS])


dnl Find GNU readline
AC_ARG_WITH([readline],
  [AS_HELP_STRING([--with-readline@<:@=PREFIX@:>@],
    [support fancy command line editing via GNU readline; optionally
     specify a prefix where it can be found])])

dnl Now check if we can find GNU readline. We go to some extra efforts to
dnl ensure it is GNU readline, and not e.g. BSD editline wrappers for
dnl readline, which do not suffice for GAP.
dnl
dnl note that OpenBSD installs modern (v6+) GNU readline into /usr/local under name libereadline
dnl and its headers into /usr/local/include/ereadline.
dnl
AS_IF([test "x$with_readline" != xno],[
 dnl Checking for rl_bind_keyseq rules out very old readline
 dnl ereadline is the name of GNU readline library on OpenBSD
 AS_CASE([x"$with_readline"],dnl set up needed -L flags
    [xyes|x], [READLINE_LDFLAGS=],
    [*], [READLINE_LDFLAGS="-L$with_readline/lib"])
 save_LDFLAGS="$LDFLAGS"
 LDFLAGS="$LDFLAGS $READLINE_LDFLAGS"
 save_LIBS="$LIBS"
 AC_SEARCH_LIBS([rl_bind_keyseq], [readline ereadline], [
   AS_IF([test x$ac_cv_search_rl_bind_keyseq != "xnone required"],
    [READLINE_LIBS=$ac_cv_search_rl_bind_keyseq], [READLINE_LIBS=])
   AS_CASE([x"$with_readline"],dnl libereadline is a special case
    [xyes|x], [
      AS_IF([test x$ac_cv_search_rl_bind_keyseq = "x-lereadline"], [
	READLINE_CPPFLAGS="-I/usr/local/include/ereadline"
	], [
	READLINE_CPPFLAGS=])
    ], [*],[
      AS_IF([test x$ac_cv_search_rl_bind_keyseq = "x-lereadline"], [
	READLINE_CPPFLAGS="-I$with_readline/include/ereadline"
	], [
	READLINE_CPPFLAGS="-I$with_readline/include"])
      ]
   )
  dnl We check that the corresponding header is present
   save_CPPFLAGS="$CPPFLAGS"
   CPPFLAGS="$READLINE_CPPFLAGS $CPPFLAGS"
   AC_CHECK_HEADERS([readline/readline.h], [
        AC_DEFINE([HAVE_LIBREADLINE], [1], [Define if you have lib(e)readline])
	], [
	AS_CASE([x"$with_readline"],
            [x], [READLINE_CPPFLAGS= READLINE_LDFLAGS= READLINE_LIBS=],
            [*], [AC_MSG_FAILURE([--with-readline was given, but further tests for readline failed])])
        ]
   )
   CPPFLAGS="$save_CPPFLAGS"
   break
   ],[
   AS_CASE([x"$with_readline"],
      [x], [READLINE_CPPFLAGS= READLINE_LDFLAGS= READLINE_LIBS=],
      [*], [AC_MSG_FAILURE([--with-readline was given, but test for readline failed])]
   )
 ])dnl AC_SEARCH_LIBS([rl_bind_keyseq] ...) ends here
 LDFLAGS="$save_LDFLAGS"
 LIBS="$save_LIBS"
])

AC_SUBST([READLINE_CPPFLAGS])
AC_SUBST([READLINE_LDFLAGS])
AC_SUBST([READLINE_LIBS])


dnl Find julia
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

AS_IF([test "x$with_julia" != xno ],[
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
  AS_IF([test -f "${JL_SHARE}/julia-config.jl"], [], [AC_MSG_ERROR([no julia-config.jl found])])

  AC_MSG_CHECKING([for JULIA_CPPFLAGS])
  JULIA_CPPFLAGS=$(${JULIA} --startup-file=no ${JL_SHARE}/julia-config.jl --cflags 2>/dev/null)
  AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain JULIA_CPPFLAGS from julia-config.jl])])
  JULIA_CPPFLAGS=${JULIA_CPPFLAGS/-std=gnu99/}  # need to remove -std=gnu99 for our C++ code
  # remove apostrophes, they mess up quoting when used in shell code(although
  # they are fine inside of Makefiles); this could cause problems if any
  # paths involve spaces, but then we likely will haves problem in other
  # places; in any case, if anybody ever cares about this, we can work on
  # finding a better solution.
  JULIA_CPPFLAGS=${JULIA_CPPFLAGS//\'/}
  AC_MSG_RESULT([${JULIA_CPPFLAGS}])

  AC_MSG_CHECKING([for JULIA_LDFLAGS])
  JULIA_LDFLAGS=$(${JULIA} --startup-file=no ${JL_SHARE}/julia-config.jl --ldflags)
  AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain JULIA_LDFLAGS from julia-config.jl])])
  JULIA_LDFLAGS=${JULIA_LDFLAGS//\'/}
  AC_MSG_RESULT([${JULIA_LDFLAGS}])

  AC_MSG_CHECKING([for JULIA_LIBS])
  JULIA_LIBS=$(${JULIA} --startup-file=no ${JL_SHARE}/julia-config.jl --ldlibs)
  AS_IF([ test $? != 0 ], [AC_MSG_ERROR([failed to obtain JULIA_LIBS from julia-config.jl])])
  JULIA_LIBS=${JULIA_LIBS//\'/}
  AC_MSG_RESULT([${JULIA_LIBS}])
],
[
  AS_IF( [ test "x$with_gc" = xjulia ],
  [
    AC_MSG_ERROR([ julia was selected as GC, but julia support was disabled ])
  ])
])
AC_SUBST([JULIA])
AC_SUBST([JULIA_CPPFLAGS])
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
  LIBATOMIC_OPS_LDFLAGS='${abs_builddir}/extern/install/libatomic_ops/lib/libatomic_ops.la'
  LIBATOMIC_OPS_LIBS=
  AC_SUBST([BUILD_LIBATOMIC_OPS])
  AC_SUBST([LIBATOMIC_OPS_CPPFLAGS])
  AC_SUBST([LIBATOMIC_OPS_LDFLAGS])
  AC_SUBST([LIBATOMIC_OPS_LIBS])

  ATOMIC_OPS_CFLAGS=$LIBATOMIC_OPS_CPPFLAGS
  ATOMIC_OPS_LIBS=$LIBATOMIC_OPS_LDFLAGS


  BUILD_BOEHM_GC=yes
  BOEHM_GC_CPPFLAGS='-I${abs_builddir}/extern/install/gc/include'
  BOEHM_GC_LDFLAGS='${abs_builddir}/extern/install/gc/lib/libgc.la'
  BOEHM_GC_LIBS=
  AC_SUBST([BUILD_BOEHM_GC])
  AC_SUBST([BOEHM_GC_CPPFLAGS])
  AC_SUBST([BOEHM_GC_LDFLAGS])
  AC_SUBST([BOEHM_GC_LIBS])
  ]
)

dnl
dnl Define kernel version
dnl


gap_kernel_major_version=7
gap_kernel_minor_version=0
AC_SUBST([gap_kernel_major_version])
AC_SUBST([gap_kernel_minor_version])

AC_DEFINE_UNQUOTED([GAP_KERNEL_MAJOR_VERSION], $gap_kernel_major_version, [The major version of the kernel ABI])
AC_DEFINE_UNQUOTED([GAP_KERNEL_MINOR_VERSION], $gap_kernel_minor_version, [The minor version of the kernel ABI])

dnl
dnl User setting: Compatibility mode (on by default)
dnl
AS_IF(
  [test "x$enable_hpcgap" = xyes],
     [GAPARCH="$host-hpcgap${ABI}-kv${gap_kernel_major_version}"],
  [test "x$with_julia" != xno],
     [GAPARCH="$host-julia${ABI}-kv${gap_kernel_major_version}"],
  # else
     [GAPARCH="$host-default${ABI}-kv${gap_kernel_major_version}"])
AS_IF([test "x$ARCHEXT" != "x"],
  [GAPARCH="$GAPARCH-$ARCHEXT"])
AS_IF([test "x$ARCH" != "x"],
  [GAPARCH="$ARCH"])

AC_DEFINE_UNQUOTED([GAPARCH], ["$GAPARCH"], [for backwards compatibility])
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
    ])
    ;;
  *darwin*)
    AC_DEFINE([SYS_IS_DARWIN], [1], [define if this is the Darwin port])
    DARWIN=yes
    ;;
esac

AC_SUBST([SYS_IS_CYGWIN32], [$CYGWIN])
SYS_IS_DARWIN=$DARWIN
AC_SUBST([SYS_IS_DARWIN])


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

AC_SEARCH_LIBS([dlopen], [dl],
    [AC_DEFINE([HAVE_DLOPEN], [1], [define as 1 if you have `dlopen' and `dlsym'])]
)


dnl check for timing functions
AC_CHECK_HEADERS([sys/time.h])
AC_CHECK_FUNCS([getrusage gettimeofday clock_gettime clock_getres])
AC_CHECK_FUNCS([setitimer])

dnl check for functions dealing with virtual memory
AC_CHECK_FUNCS([vm_allocate sbrk madvise sysconf])

dnl check for functions dealing with strings and integers
AC_CHECK_FUNCS([strlcpy strlcmp strlcat])

dnl check for large-file support (for accessing files whose sizes or inodes require 64bits)
AC_SYS_LARGEFILE

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

dnl backtraces via execinfo
AX_EXECINFO

AS_IF([test "x$enable_hpcgap" = xyes],[
  AS_BOX([WARNING: Experimental HPC-GAP mode enabled])
  dnl also enable backtrace, to help debug spurious crashes
  AC_DEFINE([GAP_PRINT_BACKTRACE], [1], [to enable backtraces upon crashes])
  ])

dnl
dnl Output everything
dnl
AC_CONFIG_FILES([GNUmakefile])
AC_CONFIG_FILES([doc/make_doc], [chmod +x doc/make_doc])
AC_CONFIG_FILES([gac:cnf/gac.in], [chmod +x gac])
AC_OUTPUT
