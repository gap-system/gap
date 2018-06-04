# =============================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_compiler_flags_cflags.html
# =============================================================================
#
# SYNOPSIS
#
#   AX_COMPILER_FLAGS_CFLAGS([VARIABLE], [IS-RELEASE], [EXTRA-BASE-FLAGS], [EXTRA-YES-FLAGS])
#
# DESCRIPTION
#
#   Add warning flags for the C compiler to VARIABLE, which defaults to
#   WARN_CFLAGS.  VARIABLE is AC_SUBST-ed by this macro, but must be
#   manually added to the CFLAGS variable for each target in the code base.
#
#   This macro depends on the environment set up by AX_COMPILER_FLAGS.
#   Specifically, it uses the value of $ax_enable_compile_warnings to decide
#   which flags to enable.
#
# LICENSE
#
#   Copyright (c) 2014, 2015 Philip Withnall <philip@tecnocode.co.uk>
#   Copyright (c) 2017, 2018 Reini Urban <rurban@cpan.org>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.

#serial 16

AC_DEFUN([AX_COMPILER_FLAGS_CFLAGS],[
    AC_REQUIRE([AC_PROG_SED])
    AX_REQUIRE_DEFINED([AX_APPEND_COMPILE_FLAGS])
    AX_REQUIRE_DEFINED([AX_APPEND_FLAG])
    AX_REQUIRE_DEFINED([AX_CHECK_COMPILE_FLAG])

    # Variable names
    m4_define([ax_warn_cflags_variable],
              [m4_normalize(ifelse([$1],,[WARN_CFLAGS],[$1]))])

    AC_LANG_PUSH([C])

    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([
      [#ifndef __cplusplus
       #error "no C++"
       #endif]])],
      [ax_compiler_cxx=yes;],
      [ax_compiler_cxx=no;])

    # Always pass -Werror=unknown-warning-option to get Clang to fail on bad
    # flags, otherwise they are always appended to the warn_cflags variable, and
    # Clang warns on them for every compilation unit.
    # If this is passed to GCC, it will explode, so the flag must be enabled
    # conditionally.
    AX_CHECK_COMPILE_FLAG([-Werror=unknown-warning-option],[
        ax_compiler_flags_test="-Werror=unknown-warning-option"
    ],[
        ax_compiler_flags_test=""
    ])

    # Check that -Wno-suggest-attribute=format is supported
    AX_CHECK_COMPILE_FLAG([-Wno-suggest-attribute=format],[
        ax_compiler_no_suggest_attribute_flags="-Wno-suggest-attribute=format"
    ],[
        ax_compiler_no_suggest_attribute_flags=""
    ])

    # Base flags
    AX_APPEND_COMPILE_FLAGS([ dnl
        -fno-strict-aliasing dnl
        $3 dnl
    ],ax_warn_cflags_variable,[$ax_compiler_flags_test])

    AS_IF([test "$ax_enable_compile_warnings" != "no"],[
        # "yes" flags
        AX_APPEND_COMPILE_FLAGS([ dnl
            -Wall dnl
            -Wextra dnl
            -Wundef dnl
            -Wwrite-strings dnl
            -Wpointer-arith dnl
            dnl -Wmissing-declarations dnl
            -Wredundant-decls dnl
            -Wno-unused-parameter dnl
            -Wmissing-field-initializers dnl
            -Wformat=2 dnl
            -Wold-style-definition dnl
            dnl -Wcast-align dnl
            -Wformat-nonliteral dnl
            -Wformat-security dnl
            -Wno-sign-compare dnl
            -Wstrict-aliasing dnl
            -Wshadow dnl
            -Winline dnl
            -Wpacked dnl
            -Wmissing-format-attribute dnl
            dnl -Wmissing-noreturn dnl
            -Winit-self dnl
            -Wredundant-decls dnl
            -Wmissing-include-dirs dnl
            -Wunused-but-set-variable dnl
            -Warray-bounds dnl
            -Wreturn-type dnl
            dnl -Wswitch-enum dnl
            dnl -Wswitch-default dnl
            -Wno-implicit-fallthrough dnl
            -Wno-inline dnl
            -Wduplicated-cond dnl
            -Wduplicated-branches dnl
            -Wlogical-op dnl
            -Wrestrict dnl
            dnl -Wnull-dereference dnl
            -Wdouble-promotion dnl
            $4 dnl
            $5 dnl
            $6 dnl
            $7 dnl
        ],ax_warn_cflags_variable,[$ax_compiler_flags_test])
        if test "$ax_compiler_cxx" = "no" ; then
            # C-only flags. Warn in C++
            AX_APPEND_COMPILE_FLAGS([ dnl
            -Wnested-externs dnl
            dnl -Wmissing-prototypes dnl
            dnl -Wstrict-prototypes dnl
            dnl -Wdeclaration-after-statement dnl
            -Wimplicit-function-declaration dnl
            -Wold-style-definition dnl
            -Wjump-misses-init dnl
            ],ax_warn_cflags_variable,[$ax_compiler_flags_test])
        fi
    ])
    AS_IF([test "$ax_enable_compile_warnings" = "error"],[
        # "error" flags; -Werror has to be appended unconditionally because
        # it's not possible to test for
        #
        # suggest-attribute=format is disabled because it gives too many false
        # positives
        AX_APPEND_FLAG([-Werror],ax_warn_cflags_variable)

        AX_APPEND_COMPILE_FLAGS([ dnl
            [$ax_compiler_no_suggest_attribute_flags] dnl
        ],ax_warn_cflags_variable,[$ax_compiler_flags_test])
    ])

    # In the flags below, when disabling specific flags, always add *both*
    # -Wno-foo and -Wno-error=foo. This fixes the situation where (for example)
    # we enable -Werror, disable a flag, and a build bot passes CFLAGS=-Wall,
    # which effectively turns that flag back on again as an error.
    for flag in $ax_warn_cflags_variable; do
        AS_CASE([$flag],
                [-Wno-*=*],[],
                [-Wno-*],[
                    AX_APPEND_COMPILE_FLAGS([-Wno-error=$(AS_ECHO([$flag]) | $SED 's/^-Wno-//')],
                                            ax_warn_cflags_variable,
                                            [$ax_compiler_flags_test])
                ])
    done

    AC_LANG_POP([C])

    # Substitute the variables
    AC_SUBST(ax_warn_cflags_variable)
])dnl AX_COMPILER_FLAGS
