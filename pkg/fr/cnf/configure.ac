#############################################################################
##
#W  configure.ac                                            Laurent Bartholdi
##
#H   @(#)$Id: configure.ac,v 1.9 2012/01/11 10:49:23 gap Exp $
##
#Y Copyright (C) 2009, Laurent Bartholdi
##
#############################################################################

AC_PREREQ(2.00)
AC_INIT(fr,,laurent.bartholdi@gmail.com)
AC_CONFIG_SRCDIR([src/fr_dll.c])
AC_CONFIG_AUX_DIR(cnf)

# Checks for programs.
AC_PROG_CC

# Check for -fno-stack-protector, because we link within GAP
AC_CACHE_CHECK([whether $CC accepts -fno-stack-protector],
    [ns_cv_cc__nostackprotector],
    [save_CFLAGS=$CFLAGS
     CFLAGS="$CFLAGS -fno-stack-protector"
     AC_LINK_IFELSE([AC_LANG_PROGRAM([], [])],
                    [ns_cv_cc__nostackprotector=yes],
                    [ns_cv_cc__nostackprotector=no])
     CFLAGS=$save_CFLAGS])
if test $ns_cv_cc__nostackprotector = yes; then
     CFLAGS="$CFLAGS -fno-stack-protector"
fi

################################################################
# Check for gsl library
GSLDIR=""
GSLINCLUDE=""
GSLLIB=""

AC_ARG_WITH(gsl,
 [  --with-gsl=<location>
    Location at which the GSL library, needed for FR, was installed.
 ],
 [GSLDIR="$withval"]
)

AC_ARG_WITH(gsl-include,
 [  --with-gsl-include=<location>
    Location at which the GSL include files were installed.],
 [GSLINCLUDE="$withval"]
)

AC_ARG_WITH(gsl-lib,
 [  --with-gsl-lib=<location>
    Location at which the GSL library files were installed.],
 [GSLLIB="$withval"]
)

if test "$GSLDIR" != yes; then
if test "$GSLINCLUDE" == ""; then GSLINCLUDE="$GSLDIR/include"; fi
if test "$GSLLIB" == ""; then GSLLIB="$GSLDIR/lib"; fi
fi

if test "$GSLINCLUDE" != ""; then
   CPPFLAGS="$CPPFLAGS -I$GSLINCLUDE"
   CFLAGS="$CFLAGS -I$GSLINCLUDE"
fi

AC_CHECK_HEADER(gsl/gsl_vector.h,[],[AC_MSG_ERROR([library gsl not found. Specify its location using --with-gsl])],[])

if test "$GSLLIB" != ""; then
   LIBS="$LIBS -L$GSLLIB"
   GACFLAGS="$GACFLAGS -L -L$GSLLIB -L -Wl,-rpath,$GSLLIB -L -lgsl -L -lgslcblas"
fi

AC_CHECK_LIB([gsl],[gsl_multiroot_fsolver_set],,
    [AC_ERROR([The GSL library could not be found. It is needed for IMG calculations.])],[-lgslcblas])

AC_CHECK_LIB([gslcblas],[cblas_ctrmv],,
    [AC_ERROR([The GSL CBlas library could not be found. It is needed for IMG calculations.])])

################################################################
# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([float.h stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_C_INLINE

AC_ARG_VAR([GAPDIR], [Location of the GAP root directory, e.g. ../..])

if test -z "$GAPDIR"; then
    for dir in ../.. /Applications/gap4r5; do
	if test -f $dir/sysinfo.gap; then
	    GAPDIR=$dir
	    break
	fi
    done
fi

AC_ARG_VAR([CONFIGNAME],[Name of GAP build configuration])
if test -n "$CONFIGNAME"; then
    SYSINFO="$GAPDIR/sysinfo.gap-$CONFIGNAME"
    MAKEFILE="Makefile-$CONFIGNAME"
    GAPPROG="$GAPDIR/bin/gap-$CONFIGNAME.sh"
else
    SYSINFO="$GAPDIR/sysinfo.gap"
    MAKEFILE="Makefile"
    GAPPROG="$GAPDIR/bin/gap.sh"
fi

if ! test -f "$SYSINFO"; then
    AC_ERROR([Could not locate the GAP root directory;
        specify its location with './configure GAPDIR=DIR [CONFIGNAME=NAME)]'])
fi

GAPDIR=`cd $GAPDIR && pwd` # make path absolute
AC_SUBST(GAPDIR)

. "$SYSINFO"
TARGET="$GAParch"

echo checking target... "$TARGET"

XTARGET="`cnf/config.guess`-$CC-`echo $TARGET | sed 's/.*-//'`"
if test "$XTARGET" != "$GAParch_system"; then
   AC_WARN([The guessed target $XTARGET is not the gap target $GAParch_system. Cross your fingers])
fi
AC_SUBST(TARGET)

echo checking gap executable ... "$GAPPROG"

if ! test -e "$GAPPROG"; then
    AC_ERROR([Could not find GAP executable $GAPPROG])
fi
AC_SUBST(GAPPROG)

GAC="$GAPDIR/bin/$TARGET/gac"

echo checking gac compiler... $GAC

if ! test -e "$GAC"; then
    AC_ERROR([Could not find GAP compiler $GAC])
fi
AC_SUBST(GAC)

################################################################
# gmp configuration

GMPDIR="$GAPDIR/bin/$TARGET/extern/gmp"
GMPINCLUDE=""
GMPLIB=""

AC_ARG_WITH(gmp,
 [  --with-gmp=<location>|yes|no|gap
    Location at which the GMP library, needed for MPFR, was installed.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path (/usr, /usr/local,...).  Otherwise
    you must give the <path> to the directory which contains the
    library. The special value "gap", which is the default, asks MPFR
    to use the version of gmp included in the GAP distribution.
 ],
 [if test "$withval" != gap; then GMPDIR="$withval"; fi]
)

AC_ARG_WITH(gmp-include,
 [  --with-gmp-include=<location>
    Location at which the GMP include files were installed.],
 [GMPINCLUDE="$withval"]
)

AC_ARG_WITH(gmp-lib,
 [  --with-gmp-lib=<location>
    Location at which the GMP library files were installed.],
 [GMPLIB="$withval"]
)

if test "$GMPDIR" != yes; then
if test "$GMPINCLUDE" == ""; then GMPINCLUDE="$GMPDIR/include"; fi
if test "$GMPLIB" == ""; then GMPLIB="$GMPDIR/lib"; fi
fi

################################################################
# external programs configuration

AC_PATH_PROGS(DOT,[dot],[],[$PATH$PATH_SEPARATOR/usr/local/graphviz/bin])

if test -z "$DOT"; then
    AC_WARN([Could not find 'dot' (debian package graphviz)... you won't be able to draw automata])
fi

AC_PATH_PROG(DISP,[display])

if test -z "$DISP"; then
    AC_WARN([Could not find 'display' (debian package imagemagick)... you won't be able to draw automata])
fi

AC_PATH_PROG(APPLETVIEWER,[appletviewer])

if test -z "$APPLETVIEWER"; then
    AC_WARN([Could not find 'appletviewer' (debian package java-6-sdk)... you won't be able to draw spiders])
fi

# Check for java compiler
AC_CHECK_PROGS(JAVAC,[javac])

if test -z "$JAVAC"; then
    AC_WARN([Could not find java compiler... you won't be able to draw spiders])
else
    JAVABUILD="java/javaplot.class java/javaview.jar"
fi
AC_SUBST(JAVABUILD)
AC_SUBST(GACFLAGS)
AC_SUBST(LIBS)

################################################################
# generate files

echo using GMP directory... $GMPDIR

if test "$GMPINCLUDE" != ""; then
   CPPFLAGS="$CPPFLAGS -I$GMPINCLUDE"
   CFLAGS="$CFLAGS -p -I$GMPINCLUDE"
fi
AC_CHECK_HEADER(gmp.h,[],[AC_MSG_ERROR([library gmp not found. Specify its location using --with-gmp])],[])

mkdir -p bin/$TARGET
CONFIG_STATUS=bin/$TARGET/config.status

AC_CONFIG_FILES([Makefile:cnf/Makefile.in])

if test "$MAKEFILE" != Makefile; then
   ln -sf "$MAKEFILE" Makefile
fi

AC_OUTPUT
