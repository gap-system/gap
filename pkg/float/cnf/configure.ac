#############################################################################
##
#W  configure.ac                                            Laurent Bartholdi
##
#H   @(#)$Id: configure.ac,v 1.15 2012/01/17 10:57:03 gap Exp $
##
#Y Copyright (C) 2009, Laurent Bartholdi
##
#############################################################################

AC_PREREQ(2.00)
AC_INIT(float,,laurent.bartholdi@gmail.com)
AC_CONFIG_SRCDIR([src/mp_float.h])
AC_CONFIG_AUX_DIR(cnf)

# Checks for programs.
AC_PROG_CC
AC_PROG_CXX

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

GAPDIR=`cd "$GAPDIR" && pwd` # make path absolute
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
# mpfr configuration

EXTERN="bin/$TARGET/extern"

MPFRDIR="$EXTERN"
MPFRINCLUDE=""
MPFRLIB=""

AC_ARG_WITH(mpfr,
 [  --with-mpfr=<path>|yes|no|extern
    Location at which the MPFR library was installed.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path (/usr, /usr/local,...).  Otherwise
    you must give the <path> to the directory which contains the
    library. The special value "extern", which is the default, asks Float
    to compile a version of mpfr in the subdirectory extern/.
 ],
 [if test "$withval" != extern; then MPFRDIR="$withval"; fi]
)

AC_ARG_WITH(mpfr-include,
 [  --with-mpfr-include=<location>
    Location at which the MPFR include files were installed.],
 [MPFRINCLUDE="$withval"]
)

AC_ARG_WITH(mpfr-lib,
 [  --with-mpfr-lib=<location>
    Location at which the MPFR library files were installed.],
 [MPFRLIB="$withval"]
)

if test "$MPFRDIR" != yes; then
if test "$MPFRINCLUDE" == ""; then MPFRINCLUDE="$MPFRDIR/include"; fi
if test "$MPFRLIB" == ""; then MPFRLIB="$MPFRDIR/lib"; fi
fi

################################################################
# mpfi configuration

if test "MPFRDIR" != no; then

MPFIDIR="$EXTERN"
MPFIINCLUDE=""
MPFILIB=""

AC_ARG_WITH(mpfi,
 [  --with-mpfi=<path>|yes|no|extern
    Location at which the MPFI library was installed.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path (/usr, /usr/local,...).  Otherwise
    you must give the <path> to the directory which contains the
    library. The special value "extern", which is the default, asks Float
    to compile a version of mpfi in the subdirectory extern/.
 ],
 [if test "$withval" != extern; then MPFIDIR="$withval"; fi]
)

AC_ARG_WITH(mpfi-include,
 [  --with-mpfi-include=<location>
    Location at which the MPFI include files were installed.],
 [MPFIINCLUDE="$withval"]
)

AC_ARG_WITH(mpfi-lib,
 [  --with-mpfi-lib=<location>
    Location at which the MPFI library files were installed.],
 [MPFILIB="$withval"]
)

if test "$MPFIDIR" != yes; then
if test "$MPFIINCLUDE" == ""; then MPFIINCLUDE="$MPFIDIR/include"; fi
if test "$MPFILIB" == ""; then MPFILIB="$MPFIDIR/lib"; fi
fi

fi

################################################################
# mpc configuration

if test "$MPFRDIR" != no; then

MPCDIR="$EXTERN"
MPCINCLUDE=""
MPCLIB=""

AC_ARG_WITH(mpc,
 [  --with-mpc=<path>|yes|no|extern
    Location at which the MPC library was installed.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path (/usr, /usr/local,...).  Otherwise
    you must give the <path> to the directory which contains the
    library. The special value "extern", which is the default, asks Float
    to compile a version of mpc in the subdirectory extern/.
 ],
 [if test "$withval" != extern; then MPCDIR="$withval"; fi]
)

AC_ARG_WITH(mpc-include,
 [  --with-mpc-include=<location>
    Location at which the MPC include files were installed.],
 [MPCINCLUDE="$withval"]
)

AC_ARG_WITH(mpc-lib,
 [  --with-mpc-lib=<location>
    Location at which the MPC library files were installed.],
 [MPCLIB="$withval"]
)

if test "$MPCDIR" != yes; then
if test "$MPCINCLUDE" == ""; then MPCINCLUDE="$MPCDIR/include"; fi
if test "$MPCLIB" == ""; then MPCLIB="$MPCDIR/lib"; fi
fi

fi

################################################################
# fplll configuration

if test "$MPFRDIR" != no; then

FPLLLDIR="$EXTERN"
FPLLLINCLUDE=""
FPLLLLIB=""

AC_ARG_WITH(fplll,
 [  --with-fplll=<path>|yes|no|extern
    Location at which the FPLLL library was installed.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path (/usr, /usr/local,...).  Otherwise
    you must give the <path> to the directory which contains the
    library. The special value "extern", which is the default, asks Float
    to compile a version of fplll in the subdirectory extern/.
 ],
 [if test "$withval" != extern; then FPLLLDIR="$withval"; fi]
)

AC_ARG_WITH(fplll-include,
 [  --with-fplll-include=<location>
    Location at which the FPLLL include files were installed.],
 [FPLLLINCLUDE="$withval"]
)

AC_ARG_WITH(fplll-lib,
 [  --with-fplll-lib=<location>
    Location at which the FPLLL library files were installed.],
 [FPLLLLIB="$withval"]
)

if test "$FPLLLDIR" != yes; then
if test "$FPLLLINCLUDE" == ""; then FPLLLINCLUDE="$FPLLLDIR/include"; fi
if test "$FPLLLLIB" == ""; then FPLLLLIB="$FPLLLDIR/lib"; fi
fi

fi

################################################################
# cxsc configuration

CXSCDIR="$EXTERN"
CXSCINCLUDE=""
CXSCLIB=""

AC_ARG_WITH(cxsc,
 [  --with-cxsc=<path>|yes|no|extern
    Location at which the CXSC library was installed.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path (/usr, /usr/local,...).  Otherwise
    you must give the <path> to the directory which contains the
    library. The special value "extern", which is the default, asks Float
    to compile a version of cxsc in the subdirectory extern/.
 ],
 [if test "$withval" != extern; then CXSCDIR="$withval"; fi]
)

AC_ARG_WITH(cxsc-include,
 [  --with-cxsc-include=<location>
    Location at which the CXSC include files were installed.],
 [CXSCINCLUDE="$withval"]
)

AC_ARG_WITH(cxsc-lib,
 [  --with-cxsc-lib=<location>
    Location at which the CXSC library files were installed.],
 [CXSCLIB="$withval"]
)

if test "$CXSCDIR" != yes; then
if test "$CXSCINCLUDE" == ""; then CXSCINCLUDE="$CXSCDIR/include"; fi
if test "$CXSCLIB" == ""; then CXSCLIB="$CXSCDIR/lib"; fi
fi

################################################################
# make target mpfr

echo using GMP directory... $GMPDIR
echo using MPFR directory... $MPFRDIR
echo using MPFI directory... $MPFIDIR
echo using MPC directory... $MPCDIR
echo using FPLLL directory... $FPLLLDIR
echo using CXSC directory... $CXSCDIR

GACFLAGS=""
DLL_TARGET="\$(LOCALBIN)"
LIB_TARGET=""

if test "$MPFRDIR" != no; then

MP_FLOAT_LIB=""
MP_FLOAT_O="\$(LOCALBIN)/mp_float.o"
DLL_TARGET="$DLL_TARGET \$(LOCALBIN)/mp_float.so"

# check gmp presence
if test "$GMPINCLUDE" != ""; then
   CPPFLAGS="$CPPFLAGS -I$GMPINCLUDE"
   GACFLAGS="$GACFLAGS -p -I$GMPINCLUDE"
fi
AC_CHECK_HEADER(gmp.h,[],[AC_MSG_ERROR([library gmp not found. Specify its location using --with-gmp])],[])

# buggy darwin doesn't chain the dll requirements to gmp; we include it again
if test "$GMPLIB" != ""; then
   MP_FLOAT_LIB="$MP_FLOAT_LIB -L -L$GMPLIB -L -Wl,-rpath,$GMPLIB"
fi
MP_FLOAT_LIB="$MP_FLOAT_LIB -L -lgmp"

# check mpfr presence
if test "$MPFRINCLUDE" != ""; then
   CPPFLAGS="$CPPFLAGS -I$MPFRINCLUDE"
   GACFLAGS="$GACFLAGS -p -I$MPFRINCLUDE"
fi
if test "$MPFRDIR" == "$EXTERN"; then
   LIB_TARGET="$LIB_TARGET mpfrlib"
else
   AC_CHECK_HEADER(mpfr.h,[],[AC_MSG_ERROR([library mpfr not found. Specify its location, or disable it using --without-mpfr])],[])
fi
GACFLAGS="$GACFLAGS -p -DWITH_MPFR"
if test "$MPFRLIB" != ""; then MP_FLOAT_LIB="$MP_FLOAT_LIB -L -L$MPFRLIB -L -Wl,-rpath,$MPFRLIB"; fi
MP_FLOAT_LIB="$MP_FLOAT_LIB -L -lmpfr"
MP_FLOAT_O="$MP_FLOAT_O \$(LOCALBIN)/mpfr.o"

# check mpfi presence
if test "$MPFIDIR" != no; then
   if test "$MPFIINCLUDE" != ""; then
      CPPFLAGS="$CPPFLAGS -I$MPFIINCLUDE"
      GACFLAGS="$GACFLAGS -p -I$MPFIINCLUDE"
   fi
   if test "$MPFIDIR" == "$EXTERN"; then
      LIB_TARGET="$LIB_TARGET mpfilib"
   else
      AC_CHECK_HEADER(mpfi.h,[],[AC_MSG_ERROR([library mpfi not found. Specify its location, or disable it using --without-mpfi])],[#include <mpfr.h>])
   fi
   GACFLAGS="$GACFLAGS -p -DWITH_MPFI"
   if test "$MPFILIB" != ""; then MP_FLOAT_LIB="$MP_FLOAT_LIB -L -L$MPFILIB -L -Wl,-rpath,$MPFILIB"; fi
   MP_FLOAT_LIB="$MP_FLOAT_LIB -L -lmpfi"
   MP_FLOAT_O="$MP_FLOAT_O \$(LOCALBIN)/mpfi.o"
fi

# check mpc presence
if test "$MPCDIR" != no; then
   if test "$MPCINCLUDE" != ""; then
      CPPFLAGS="$CPPFLAGS -I$MPCINCLUDE"
      GACFLAGS="$GACFLAGS -p -I$MPCINCLUDE"
   fi
   if test "$MPCDIR" == "$EXTERN"; then
      LIB_TARGET="$LIB_TARGET mpclib"
   else
      AC_CHECK_HEADER(mpc.h,[],[AC_MSG_ERROR([library mpc not found. Specify its location, or disable it using --without-mpc])],[#include <mpfr.h>])
   fi
   GACFLAGS="$GACFLAGS -p -DWITH_MPC"
   if test "$MPCLIB" != ""; then MP_FLOAT_LIB="$MP_FLOAT_LIB -L -L$MPCLIB -L -Wl,-rpath,$MPCLIB"; fi
   MP_FLOAT_LIB="$MP_FLOAT_LIB -L -lmpc"
   MP_FLOAT_O="$MP_FLOAT_O \$(LOCALBIN)/mpc.o \$(LOCALBIN)/mp_poly.o"
fi

# check fplll presence
if test "$FPLLLDIR" != no; then
   if test "$FPLLLINCLUDE" != ""; then
      CPPFLAGS="$CPPFLAGS -I$FPLLLINCLUDE"
      GACFLAGS="$GACFLAGS -p -I$FPLLLINCLUDE"
   fi
   if test "$FPLLLDIR" == "$EXTERN"; then
      LIB_TARGET="$LIB_TARGET fpllllib"
   else
      AC_CHECK_HEADER(fplll.h,[],[AC_MSG_ERROR([library fplll not found. Specify its location, or disable it using --without-fplll])],[#include <mpfr.h>])
   fi
   GACFLAGS="$GACFLAGS -p -DWITH_FPLLL"
   if test "$FPLLLLIB" != ""; then MP_FLOAT_LIB="$MP_FLOAT_LIB -L -L$FPLLLLIB -L -Wl,-rpath,$FPLLLLIB"; fi
   MP_FLOAT_LIB="$MP_FLOAT_LIB -L -lfplll"
   MP_FLOAT_O="$MP_FLOAT_O \$(LOCALBIN)/fplll.o"
fi

fi

################################################################
# make target cxsc

if test "$CXSCDIR" != no; then
   CXSC_FLOAT_LIB=""
   CXSC_FLOAT_O=""

   if test "CXSCINCLUDE" != ""; then
      CPPFLAGS="$CPPFLAGS -I$CXSCINCLUDE"
      GACFLAGS="$GACFLAGS -p -I$CXSCINCLUDE"
   fi
   if test "$CXSCDIR" == "$EXTERN"; then
      LIB_TARGET="$LIB_TARGET cxsclib"
   else
      AC_LANG([C++])
      AC_CHECK_HEADER(interval.hpp,[],[AC_MSG_ERROR([library cxsc not found. Specify its location, or disable using --without-cxsc])],[])
   fi
   GACFLAGS="$GACFLAGS -p -DWITH_CXSC"
   DLL_TARGET="$DLL_TARGET \$(LOCALBIN)/cxsc_float.so"
   CXSC_FLOAT_O="\$(LOCALBIN)/cxsc_float.o \$(LOCALBIN)/cxsc_poly.o"
   if test "$CXSCLIB" != ""; then CXSC_FLOAT_LIB="$CXSC_FLOAT_LIB -L -L$CXSCLIB -L -Wl,-rpath,$CXSCLIB"; fi
   if echo "$TARGET" | grep -qi darwin; then # buggy darwin, can't include dll
      CXSC_FLOAT_LIB="$CXSC_FLOAT_LIB -L $CXSCLIB/libcxsc.a"
   else
      CXSC_FLOAT_LIB="$CXSC_FLOAT_LIB -L -lcxsc"
   fi
fi

################################################################
# generate files

WITHGMP=""
if test "$GMPINCLUDE" != ""; then WITHGMP="$WITHGMP --with-gmp-include=$GMPINCLUDE"; fi
if test "$GMPLIB" != ""; then WITHGMP="$WITHGMP --with-gmp-lib=$GMPLIB"; fi
WITHMPFR=""
if test "$MPFRDIR" == "$EXTERN"; then
   MPFRINCLUDE="\$(CURDIR)/$MPFRINCLUDE"
   MPFRLIB="\$(CURDIR)/$MPFRLIB"
fi
if test "$MPFRINCLUDE" != ""; then
   WITHMPFR="$WITHMPFR --with-mpfr-include=$MPFRINCLUDE"
fi
if test "$MPFRLIB" != ""; then
   WITHMPFR="$WITHMPFR --with-mpfr-lib=$MPFRLIB"
fi

# prevent parallel make on mpfr, mpc, mpfi before mpfr is compiled
if test "$MPFRDIR" == "$EXTERN"; then MPFRDEPEND=mpfrlib; fi

AC_SUBST(GAC)
AC_SUBST(GAP)
AC_SUBST(CC)
AC_SUBST(CXX)
AC_SUBST(CFLAGS)
AC_SUBST(GAPDIR)
AC_SUBST(TARGET)
AC_SUBST(DLL_TARGET)
AC_SUBST(LIB_TARGET)
AC_SUBST(MP_FLOAT_LIB)
AC_SUBST(MP_FLOAT_O)
AC_SUBST(CXSC_FLOAT_LIB)
AC_SUBST(CXSC_FLOAT_O)
AC_SUBST(GACFLAGS)
AC_SUBST(WITHGMP)
AC_SUBST(GMPINCLUDE)
AC_SUBST(GMPLIB)
AC_SUBST(WITHMPFR)
AC_SUBST(MPFRDEPEND)
AC_SUBST(MPFRINCLUDE)
AC_SUBST(MPFRLIB)

mkdir -p bin/$TARGET
CONFIG_STATUS=bin/$TARGET/config.status

AC_CONFIG_FILES([$MAKEFILE:cnf/Makefile.in])

if test "$MAKEFILE" != Makefile; then
   ln -sf "$MAKEFILE" Makefile
fi

AC_OUTPUT
