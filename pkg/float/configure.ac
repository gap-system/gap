AC_INIT(configure)

AC_ARG_WITH(gac,
 [  --with-gac=<path>       Location of the gap compiler],
 [GAC="$withval"],
 [GAC="gacdev"]
)

if test "`which $GAC`" == ""; then
   AC_MSG_ERROR([Cannot find gac under filename $GAC])
fi

AC_ARG_WITH(gap,
 [  --with-gap=<path>       Location of the gap executable],
 [GAP="$withval"],
 [GAP="gapdevL"]
)

if test "`which $GAP`" == ""; then
   AC_MSG_ERROR([Cannot find gap under filename $GAP])
fi

AC_ARG_WITH(mpfr,
 [  --with-mpfr=<path>|no
    Location of the MPFR library.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path "/usr" or "/usr/local".  Otherwise
    you must give the <path> to the directory which contains the
    library.
 ],
 [if test "$withval" != no; then
   MPFR_DIR="$withval"
   WITH_MPFR=-DWITH_MPFR
  fi],
 [WITH_MPFR=-DWITH_MPFR]
)

AC_ARG_WITH(mpfi,
 [  --with-mpfi=<path>|no
    Location of the MPFI library.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path "/usr" or "/usr/local".  Otherwise
    you must give the <path> to the directory which contains the
    library.
 ],
 [if test "$withval" != no; then
   MPFI_DIR="$withval"
   WITH_MPFI=-DWITH_MPFI
  fi],
 [WITH_MPFI=-DWITH_MPFI]
)

AC_ARG_WITH(mpc,
 [  --with-mpc=<path>|no
    Location of the MPC library.
    If the argument is omitted, the library is assumed to be reachable
    under the standard search path "/usr" or "/usr/local".  Otherwise
    you must give the <path> to the directory which contains the
    library.
 ],
 [if test "$withval" != no; then
   MPC_DIR="$withval"
   WITH_MPC=-DWITH_MPC
  fi],
 [WITH_MPC=-DWITH_MPC]
)

AC_ARG_WITH(cxsc,
 [  --with-cxsc=<path>|no
    Location of the C-XSC library.
    The CXSC module contains standard-precision "interval" arithmetic,
    and in particular complex intervals ("polydisks")
 ],
 [if test "$withval" != no; then
   CXSC_DIR="$withval"
   CXSC_INCLUDEDIR="-I$withval/include"
   CXSC_LIBDIR="-L$withval/lib"
   WITH_CXSC=-DWITH_CXSC
  fi],
 [WITH_CXSC=-DWITH_CXSC]
)

AC_PROG_CC
AC_PROG_CXX

FLOAT_TARGET="\$(LOCALBIN)"

MP_FLOAT_LIB="-lgmp -lmpfr"
MP_FLOAT_O="\$(LOCALBIN)/mp_float.o \$(LOCALBIN)/mpfr.o"
MP_INCLUDEDIR=""
MP_LIBDIR=""
MP_GACFLAGS=""

if test "$WITH_MPFR" != ""; then
   if test "$MPFR_DIR" == ""; then
      AC_CHECK_HEADER(mpfr.h,[],[AC_MSG_ERROR(library mpfr is not properly installed)],[])
   else
      if ! test -r $MPFR_DIR/include/mpfr.h; then
         AC_MSG_ERROR(library mpfr is not at $MPFR_DIR)
      fi
      echo checking for mpfr.h ... in $MPFR_DIR/include
      MP_INCLUDEDIR="$MP_INCLUDEDIR -I$MPFR_DIR/include"
      MP_LIBDIR="$MP_LIBDIR -L$MPFR_DIR/lib"
      MP_GACFLAGS="$MP_GACFLAGS -p -I$MPFR_DIR/include"
   fi
   FLOAT_TARGET="$FLOAT_TARGET \$(LOCALBIN)/mp_float.so"
fi

if test "$WITH_MPFI" != ""; then
   if test "$WITH_MPFR" == ""; then
      AC_MSG_ERROR([Option --with-mpfi is meaninless without --with-mpfr])
   fi
   if test "$MPFI_DIR" == ""; then
      AC_CHECK_HEADER(mpfi.h,[],[AC_MSG_ERROR(library mpfi is not properly installed)],[#include <mpfr.h>])
   else
      if ! test -r $MPFI_DIR/include/mpfi.h; then
         AC_MSG_ERROR(library mpfi is not at $MPFI_DIR)
      fi
      echo checking for mpfi.h ... in $MPFI_DIR/include
      MP_INCLUDEDIR="$MP_INCLUDEDIR -I$MPFI_DIR/include"
      MP_LIBDIR="$MP_LIBDIR -L$MPFI_DIR/lib"
      MP_GACFLAGS="$MP_GACFLAGS -p -I$MPFI_DIR/include"
   fi
   MP_FLOAT_LIB="$MP_FLOAT_LIB -lmpfi"
   MP_FLOAT_O="$MP_FLOAT_O \$(LOCALBIN)/mpfi.o"
fi

if test "$WITH_MPC" != ""; then
   if test "$WITH_MPFR" == ""; then
      AC_MSG_ERROR([Option --with-mpc is meaninless without --with-mpfr])
   fi
   if test "$MPC_DIR" == ""; then
      AC_CHECK_HEADER(mpc.h,[],[AC_MSG_ERROR(library mpc is not properly installed)],[#include <mpfr.h>])
   else
      if ! test -r $MPC_DIR/include/mpc.h; then
         AC_MSG_ERROR(library mpc is not at $MPC_DIR)
      fi
      echo checking for mpc.h ... in $MPC_DIR/include
      MP_INCLUDEDIR="$MP_INCLUDEDIR -I$MPC_DIR/include"
      MP_LIBDIR="$MP_LIBDIR -L$MPC_DIR/lib"
      MP_GACFLAGS="$MP_GACFLAGS -p -I$MPC_DIR/include"
   fi
   MP_FLOAT_LIB="$MP_FLOAT_LIB -lmpc"
   MP_FLOAT_O="$MP_FLOAT_O \$(LOCALBIN)/mpc.o"
fi

if test "$WITH_CXSC" != ""; then
   if test "CXSC_DIR" == ""; then
      AC_CHECK_HEADER(interval.hpp,[],[AC_MSG_ERROR(library cxsc is not properly installed)],[])
   else
      if ! test -r $CXSC_DIR/include/interval.hpp; then
         AC_MSG_ERROR(library cxsc is not at CXSC_DIR)
      fi
      echo checking for interval.hpp ... in $CXSC_DIR/include
   fi
  FLOAT_TARGET="$FLOAT_TARGET \$(LOCALBIN)/cxsc_float.so"
  CXSC_FLOAT_O="\$(LOCALBIN)/cxsc_float.o \$(LOCALBIN)/cpoly.o"
  gacfile=`which $GAC`
  GAP_BIN=`grep '^gap_bin' $gacfile | cut -c 9-`
  CXSC_INCLUDEDIR="$CXSC_INCLUDEDIR -I$GAP_BIN -I$GAP_BIN/../.."
fi

AC_CANONICAL_TARGET
ARCH="$target-$CC"

AC_SUBST(GAC)
AC_SUBST(GAP)
AC_SUBST(CC)
AC_SUBST(CXX)
AC_SUBST(CFLAGS)
AC_SUBST(ARCH)
AC_SUBST(WITH_MPFR)
AC_SUBST(WITH_MPFI)
AC_SUBST(WITH_MPC)
AC_SUBST(WITH_CXSC)
AC_SUBST(FLOAT_TARGET)
AC_SUBST(MP_FLOAT_LIB)
AC_SUBST(MP_FLOAT_O)
AC_SUBST(MP_INCLUDEDIR)
AC_SUBST(MP_LIBDIR)
AC_SUBST(MP_GACFLAGS)
AC_SUBST(CXSC_FLOAT_O)
AC_SUBST(CXSC_INCLUDEDIR)
AC_SUBST(CXSC_LIBDIR)

AC_OUTPUT(Makefile)
