#############################################################################
##
#W  configure.ac                                            Laurent Bartholdi
##
#H   @(#)$Id: configure.ac,v 1.7 2011/06/20 14:14:30 gap Exp $
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

# Checks for libraries.
AC_CHECK_LIB([gsl],[gsl_multiroot_fsolver_set],,
    [AC_ERROR([The GSL library could not be found. It is needed for IMG calculations.])],[-lgslcblas])

AC_CHECK_LIB([gslcblas],[cblas_ctrmv],,
    [AC_ERROR([The GSL CBlas library could not be found. It is needed for IMG calculations.])])

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([float.h stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_C_INLINE

AC_ARG_WITH(gap,
 [  --with-gap=DIR          Location of the GAP root directory [[GAPDIR]]],
 [GAPDIR=$withval])

if test -z "$GAPDIR"; then
    for dir in ../.. /home/laurent/.../src/4.0 /usr/local/src/4.0 /Applications/gap4r5; do
	if test -f $dir/sysinfo.gap; then
	    GAPDIR=$dir
	    break
	fi
    done
fi

if ! test -f $GAPDIR/sysinfo.gap; then
    AC_ERROR([Could not locate $GAPDIR/sysinfo.gap;
        specify its location with --with-gap=DIR])
fi

GAPDIR=`cd $GAPDIR && pwd` # make path absolute
AC_SUBST(GAPDIR)

. $GAPDIR/sysinfo.gap
TARGET="$GAParch"

AC_ARG_WITH(target,
 [  --with-target=TARGET    Target to compile for [[TARGET]]],
 [TARGET=$withval]) 

echo checking target... $TARGET

XTARGET="`cnf/config.guess`-$CC"
if test "$XTARGET" != "$GAParch_system"; then
   AC_WARN([The current target $XTARGET is not the gap target $GAParch_system. Cross your fingers])
fi
AC_SUBST(TARGET)

echo checking GAP directory... $GAPDIR

GAPPROG="$GAPDIR/bin/gap.sh"
AC_SUBST(GAPPROG)

GAC="$GAPDIR/bin/$TARGET/gac"

echo checking gac compiler... $GAC

if ! test -e "$GAC"; then
    AC_ERROR([Could not find GAP compiler $GAC])
fi
AC_SUBST(GAC)

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

AC_SUBST(LIBS)

mkdir -p bin/$TARGET
CONFIG_STATUS=bin/$TARGET/config.status

AC_CONFIG_FILES([Makefile:cnf/Makefile.in])

AC_OUTPUT
