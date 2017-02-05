dnl #########################################################################
dnl ##
dnl ## check whether CC expects -export-dynamic
dnl ##

AC_DEFUN(GP_PROG_CC_EXPORT_DYNAMIC,
[AC_CACHE_CHECK(whether ${CC-cc} accepts -export-dynamic, gp_cv_prog_cc_export_dynamic,
[echo 'int main(){}' > conftest.c
if test -z "`${CC-cc} -export-dynamic -o conftest conftest.c 2>&1`"; then
  gp_cv_prog_cc_export_dynamic=yes
else
  gp_cv_prog_cc_export_dynamic=no
fi
rm -f conftest*
])])


dnl #########################################################################
dnl ##
dnl ## check what symbols in ".o" start with an underscore
dnl ##

AC_DEFUN(GP_C_UNDERSCORE_SYMBOLS,
[AC_CHECK_PROGS( NM, nm )
AC_CACHE_CHECK(whether symbols begin with an underscore, gp_cv_c_underscore_symbols,
[echo 'int foo() { return 0;}' > conftest.c
${CC-cc} -c conftest.c 2>&1
if test -z "$NM" ;  then
  AC_MSG_ERROR( cannot find "nm" )
else
  if $NM conftest.o | grep _foo > /dev/null 2>&1 ;  then
    gp_cv_c_underscore_symbols=yes
  else
    gp_cv_c_underscore_symbols=no
  fi
fi
rm -f conftest*
] )
if test "$gp_cv_c_underscore_symbols" = yes;  then
AC_DEFINE( C_UNDERSCORE_SYMBOLS, 1, [define as 1 if you symbols in ".o" files begin with `_'])
fi
] )


dnl #########################################################################
dnl ##
dnl ## check what unaligned access is still save
dnl ##

AC_DEFUN(GP_C_LONG_ALIGN,
[AC_CACHE_CHECK(unaligned access, gp_cv_c_long_align,
[
case "$host" in
   alpha* )
        gp_cv_c_long_align=8;;
   mips* | sparc* )
        gp_cv_c_long_align=$ac_cv_sizeof_void_p;;
   i586-* | i686-* )
        gp_cv_c_long_align=2;;
   x86_64-* )
        gp_cv_c_long_align=2;;
        * )

case "$host" in 
   *OSF* | *osf* )
    uac p sigbus;;
esac
 AC_LANG_PUSH([C])
 AC_RUN_IFELSE( [AC_LANG_SOURCE([[char buf[32];main(){long i= *(long*)(buf+1);buf[1]=(char)i;return 0;}]])],
 [gp_cv_c_long_align=1],
 [
  AC_RUN_IFELSE( [AC_LANG_SOURCE([[char buf[32];main(){long i= *(long*)(buf+2);buf[1]=(char)i;return 0;}]])],
  [gp_cv_c_long_align=2],
  [
   AC_RUN_IFELSE( [AC_LANG_SOURCE([[char buf[32];main(){long i= *(long*)(buf+4);buf[1]=(char)i;return 0;}]])],
   [gp_cv_c_long_align=4],
   [
    AC_RUN_IFELSE( [AC_LANG_SOURCE([[char buf[32];main(){long i= *(long*)(buf+8);buf[1]=(char)i;return 0;}]])],
    [gp_cv_c_long_align=8] )
   ] )
  ] )
 ] )
 AC_LANG_POP([C])
 rm -f core core.* *.core
esac
] )
AC_DEFINE_UNQUOTED( C_LONG_ALIGN, $gp_cv_c_long_align, [define as least offset which is still safe for an unaligned access] )
] )


dnl #########################################################################
dnl ##
dnl ## check for old style union wait more carefully
dnl ##

AC_DEFUN(GP_C_UNION_WAIT,
[AC_CACHE_CHECK(union wait, gp_cv_c_union_wait,
 [
  AC_TRY_COMPILE( [#include <sys/wait.h> ], 
                  [int a; int status; waitpid( (pid_t)-1, & status, 0);
                             a = WIFSIGNALED(status); a = WEXITSTATUS(status);],
                  gp_cv_c_union_wait=0,
                  gp_cv_c_union_wait=1 )],
  AC_DEFINE( HAVE_UNION_WAIT, $gp_cv_c_union_wait, [define as 1 if you have "union wait"] )
)])

dnl #########################################################################
dnl ##
dnl ## choose CFLAGS more carefully
dnl ##
dnl ##  For alpha/cc (or some flavours of this at least) -O3 is faster
dnl ##  but seems to reveal a compiler bug applying to stats.c and causing
dnl ##  SyCompileInput to be clobbered while PrintStatFuncs is being
dnl ##  initialized
dnl ##
AC_DEFUN(GP_CFLAGS,
[AC_CACHE_CHECK(C compiler default flags, gp_cv_cflags,
 [ case "$host-$CC" in
    *-gcc* )
        gp_cv_cflags="-Wall -g -O2 ${ABI_CFLAGS}";;
    *-clang* )
        gp_cv_cflags="-Wall -g -O3 ${ABI_CFLAGS} -Wno-unused-value";;
    i686-*-egcs )
        gp_cv_cflags="-Wall -g -O2 -mcpu=i686 ${ABI_CFLAGS}";;
    i586-*-egcs )
        gp_cv_cflags="-Wall -g -O2 -mcpu=i586 ${ABI_CFLAGS}";;
    i486-*-egcs )
        gp_cv_cflags="-Wall -g -O2 -mcpu=i486 ${ABI_CFLAGS}";;
    i386-*-egcs )
        gp_cv_cflags="-Wall -g -O2 -mcpu=i386 ${ABI_CFLAGS}";;
    *-icc* )
        gp_cv_cflags="-Wall -g -O2 ${ABI_CFLAGS}";;
    alphaev6-*-osf4*-cc )
        gp_cv_cflags="-g3 -arch ev6 -O1 ";;
    alphaev56-*-osf4*-cc )
        gp_cv_cflags="-g3 -arch ev56 -O1";;
    alphaev5-*-osf4*-cc )
        gp_cv_cflags="-g3 -arch ev5 -O1";;
    alpha*-*-osf4*-cc )
        gp_cv_cflags="-g3 -O1";;
    *aix*cc )
        gp_cv_cflags="-g -O3";;
    *-solaris*-cc )
        gp_cv_cflags="-fast -erroff=E_STATEMENT_NOT_REACHED";;
    *-irix*-cc )
        gp_cv_cflags="-O3 -woff 1110,1167,1174,1552";;
    * )
        gp_cv_cflags="-O";;
   esac 
 ])
CFLAGS="$gp_cv_cflags $CFLAGS"])

dnl #########################################################################
dnl ##
dnl ## choose LDFLAGS more carefully
dnl ##

AC_DEFUN(GP_LDFLAGS,
[AC_CACHE_CHECK(Linker default flags, gp_cv_ldflags,
 [ case "$host-$CC" in
    *-darwin[[6-9]].* | *-darwin10.* )
        gp_cv_ldflags="-g ${ABI_CFLAGS}";;
    *-darwin* )
        gp_cv_ldflags="-g -Wl,-no_pie ${ABI_CFLAGS}";;
    *-gcc* | *-egcs )
        gp_cv_ldflags="-g ${ABI_CFLAGS}";;
    *-clang* )
        gp_cv_ldflags="-g -rdynamic ${ABI_CFLAGS}";;
    *-icc* )
        gp_cv_ldflags="-g -rdynamic -static-libgcc -static-intel ${ABI_CFLAGS}";;
    alpha*-*-osf4*-cc )
        gp_cv_ldflags="-g3 ";;
    *-solaris*-cc )
        gp_cv_ldflags="";;
    *aix*cc )
        gp_cv_ldflags="-g";;
    *-irix*-cc )
        gp_cv_ldflags="-O3";;
    * )
        gp_cv_ldflags="";;
   esac 
 ])
LDFLAGS="$LDFLAGS $gp_cv_ldflags"])
              
dnl #########################################################################
dnl ##
dnl ## flags for dynamic linking
dnl ##
AC_DEFUN(GP_PROG_CC_DYNFLAGS,
[AC_CACHE_CHECK(dynamic module compile options, gp_cv_prog_cc_cdynoptions,
 [ case "$host-$CC" in
    *cygwin* )
        gp_cv_prog_cc_cdynoptions="${ABI_CFLAGS}";;
    *-apple-darwin* )
        gp_cv_prog_cc_cdynoptions="-fPIC -Wall ${ABI_CFLAGS}";;
    *-hpux-gcc )
        gp_cv_prog_cc_cdynoptions="-fpic -Wall ${ABI_CFLAGS}";;
    *-gcc* | *-egcs )
        gp_cv_prog_cc_cdynoptions="-fPIC -Wall -O2 ${ABI_CFLAGS}";;
    *-clang* )
        gp_cv_prog_cc_cdynoptions="-fPIC -Wall ${ABI_CFLAGS} -Wno-unused-value";;
    *-icc* )
        gp_cv_prog_cc_cdynoptions="-fpic -Wall -O2 ${ABI_CFLAGS}";;
    *-next-nextstep-cc )
        gp_cv_prog_cc_cdynoptions=" -Wall -O2 -arch $hostcpu";;
    *-osf*-cc )
        gp_cv_prog_cc_cdynoptions=" -shared -x -O2";;
    *-irix* )
        gp_cv_prog_cc_cdynoptions=" -O3 -woff 1110,1167,1174,1552";;
   
    * )    dnl ## if we don't recognise this compiler, guess some flags
        gp_cv_prog_cc_cdynoptions="-fPIC -O2 ${ABI_CFLAGS}";;
   esac 
 ])
 AC_CACHE_CHECK(dynamic linker, gp_cv_prog_cc_cdynlinker,
 [ case "$host-$CC" in
    *-gcc* | *-clang* | *-egcs | *-icc* )
        gp_cv_prog_cc_cdynlinker="${CC}";;
    *-irix* )
        gp_cv_prog_cc_cdynlinker="ld";;

    * )    dnl ## if we don't recognise this compiler, assume it can link
        gp_cv_prog_cc_cdynlinker="${CC}";;
   esac 
 ])
 AC_CACHE_CHECK(dynamic module link flags, gp_cv_prog_cc_cdynlinking,
 [ case "$host-$CC" in
    *-apple-darwin* )
        gp_cv_prog_cc_cdynlinking='-g -bundle -bundle_loader ${gap_bin}/gap'" ${ABI_CFLAGS}";;
    *cygwin* )
        gp_cv_prog_cc_cdynlinking='-shared ${gap_bin}/gap.dll';;
    *-gcc )
        gp_cv_prog_cc_cdynlinking="-shared -g ${ABI_CFLAGS}";;
    *-clang )
        gp_cv_prog_cc_cdynlinking="-shared -g ${ABI_CFLAGS}";;
    *-icc )
        gp_cv_prog_cc_cdynlinking="-shared -g ${ABI_CFLAGS}";;
    *-egcs )
        gp_cv_prog_cc_cdynlinking="-shared -g ${ABI_CFLAGS}";;
    *hpux* )
        gp_cv_prog_cc_cdynlinking="-b +e Init__Dynamic";;
    alpha*osf4*-cc )
        gp_cv_prog_cc_cdynlinking="-shared -g3";;
    alpha*osf*cc )
        gp_cv_prog_cc_cdynlinking="-shared";;
    *osf*cc )
        gp_cv_prog_cc_cdynlinking="-shared -r";;
    *-irix* )
       gp_cv_prog_cc_cdynlinking="-shared -O3";;  
    *-nextstep*cc )
        gp_cv_prog_cc_cdynlinking="-arch $hostcpu -Xlinker -r -Xlinker -x -nostdlib";;
    *solaris* )
        gp_cv_prog_cc_cdynlinking="-G -Bdynamic";;
    *sunos* )
        gp_cv_prog_cc_cdynlinking="-assert pure-text -Bdynamic -x";;

    * )   dnl ## if we don't recognise this compiler, guess some flags
        gp_cv_prog_cc_cdynlinking="-shared -g ${ABI_CFLAGS}";;
   esac 
 ])


CDYNOPTIONS=$gp_cv_prog_cc_cdynoptions 
CDYNLINKER=$gp_cv_prog_cc_cdynlinker
CDYNLINKING=$gp_cv_prog_cc_cdynlinking

AC_SUBST(CDYNOPTIONS)
AC_SUBST(CDYNLINKER)
AC_SUBST(CDYNLINKING)
AC_SUBST(GMP_LIBS)
AC_SUBST(GMP_CFLAGS)

])
