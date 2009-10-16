#############################################################################
##
#W  configure.ac                                            Laurent Bartholdi
##
#H   @(#)$Id: configure.ac,v 1.15 2009/10/13 09:37:06 gap Exp $
##
#Y Copyright (C) 2009, Laurent Bartholdi
##
#############################################################################

AC_PREREQ(2.00)
AC_INIT(fr,,laurent.bartholdi@gmail.com)
AC_CONFIG_SRCDIR([src/fr_dll.c])

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
    [AC_WARN([The GSL library could not be found. It is needed for IMG calculations.])],[-lgslcblas])

AC_CHECK_LIB([gslcblas],[cblas_ctrmv],,
    [AC_WARN([The GSL CBlas library could not be found. It is needed for IMG calculations.])])

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
    for dir in /home/laurent/.../src/4.0 /usr/local/src/4.0 ../..; do
	if test -f $dir/sysinfo.gap; then
	    GAPDIR=$dir
	    break
	fi
    done
fi

if ! test -f $GAPDIR/sysinfo.gap; then
    AC_ERROR([Could not locate sysinfo.gap;
        specify its location with --with-gap=DIR])
fi

. $GAPDIR/sysinfo.gap
TARGET="`./config.guess`-$CC"
if test "$TARGET" != "$GAParch"; then
   AC_WARN([The current target $TARGET is not the gap target $GAParch. Cross your fingers])
fi
AC_SUBST(TARGET)

echo checking GAP directory... $GAPDIR

AC_CHECK_PROGS(GAPPROG,[gapdev gap gap4 gap-4.4 $GAPDIR/bin/gap.sh])

if test -z "$GAPPROG"; then
    AC_WARN([Could not find any GAP executable... you won't be able to compile the help files])
fi

AC_PATH_PROGS(DOT,[dot /usr/local/graphviz/bin/dot])

if test -z "$DOT"; then
    AC_WARN([Could not find 'dot' (in package graphviz)... you won't be able to draw automata])
fi

AC_PATH_PROG(DISP,[display])

if test -z "$DISP"; then
    AC_WARN([Could not find 'display' (in package imagemagick)... you won't be able to draw automata])
fi

AC_PATH_PROG(APPLETVIEWER,[appletviewer])

if test -z "$APPLETVIEWER"; then
    AC_WARN([Could not find 'appletviewer' (in package java-6-sdk)... you won't be able to draw spiders])
fi

AC_CHECK_PROGS(FORTRAN,[gfortran g77 f77])

OBJ="\$(LOCALBIN)/fr_dll.o \$(LOCALBIN)/cpoly.o"

if test -z "$FORTRAN"; then
    AC_WARN([Could not find fortran compiler... you won't be able to compute with spiders])
    CFLAGS="$CFLAGS -DNOFORTRAN"
    FORTRAN=false
else
    OBJ="$OBJ \$(LOCALBIN)/stripack.o \$(LOCALBIN)/grafpack.o"
fi

if test "$FORTRAN" = gfortran; then # need extra library
    AC_CHECK_LIB([gfortran],[sincos])
fi

# Check for java compiler
AC_CHECK_PROGS(JAVAC,[javac])

if test -z "$JAVAC"; then
    AC_WARN([Could not find java compiler... you won't be able to draw spiders])
else
    JAVABUILD="java/javaplot.class java/javaview.jar"
fi
AC_SUBST(JAVABUILD)

# Check for shared libraries linking option
if test "`uname -s`" = "darwin"; then
    SHARED="-dynamiclib -undefined dynamic_lookup -single_module"
else
    SHARED="-shared"
fi
AC_SUBST(SHARED)

AC_SUBST(GAPDIR)
AC_SUBST(LIBS)
AC_SUBST(LIBGSL)
AC_SUBST(OBJ)

AC_CONFIG_FILES([Makefile])

AC_OUTPUT
