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
[echo 'int foo() {}' > conftest.c
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
AC_DEFINE( C_UNDERSCORE_SYMBOLS )
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
   alpha-* )
	gp_cv_c_long_align=8;;
   mips-* )
        gp_cv_c_long_align=4;;
   i586-* )
        gp_cv_c_long_align=2;;
        * )

case "$host" in 
   *OSF* | *osf* )
    uac p sigbus;;
esac
 AC_TRY_RUN( [char buf[32];main(){long i= *(long*)(buf+1);buf[1]=(char)i;exit(0);}],
 gp_cv_c_long_align=1,
 [
  AC_TRY_RUN( [char buf[32];main(){long i= *(long*)(buf+2);buf[1]=(char)i;exit(0);}],
  gp_cv_c_long_align=2,
  [
   AC_TRY_RUN( [char buf[32];main(){long i= *(long*)(buf+4);buf[1]=(char)i;exit(0);}],
   gp_cv_c_long_align=4,
   [
    AC_TRY_RUN( [char buf[32];main(){long i= *(long*)(buf+8);buf[1]=(char)i;exit(0);}],
    gp_cv_c_long_align=8 )
   ] )
  ] )
 ] )
 rm -f core core.* *.core
esac
] )
AC_DEFINE_UNQUOTED( C_LONG_ALIGN, $gp_cv_c_long_align )
] )


dnl #########################################################################
dnl ##
dnl ## check for old style union wait more carefully
dnl ##

AC_DEFUN(GP_C_UNION_WAIT,
[AC_CACHE_CHECK(union wait, gp_cv_c_union_wait,
 [
  AC_TRY_COMPILE( [#include sys/wait.h ], 
                  [int a; int status; waitpid( (pid_t)-1, & status, 0);
                             a = WIFSIGNALED(status); a = WEXITSTATUS(status);],
                  gp_cv_c_union_wait=0,
                  gp_cv_c_union_wait=1 )],
  AC_DEFINE( HAVE_UNION_WAIT, $gp_cv_c_union_wait )
)])
              
dnl #########################################################################
dnl ##
dnl ## flags for dynamic linking
dnl ##
AC_DEFUN(GP_PROG_CC_DYNFLAGS,
[AC_CACHE_CHECK(dynamic module compile options, gp_cv_prog_cc_cdynoptions,
 [ case "$host-$CC" in
    *-hpux-gcc )
        gp_cv_prog_cc_cdynoptions="-fpic";;
    *-gcc )
     	gp_cv_prog_cc_cdynoptions="-fpic -ansi -Wall -O2";;
    *-next-nextstep-cc )
        gp_cv_prog_cc_cdynoptions="-ansi -Wall -O2 -arch $hostcpu";;
    * )
        gp_cv_prog_cc_cdynoptions="UNSUPPORTED";;
   esac 
 ])
 AC_CACHE_CHECK(dynamic linker, gp_cv_prog_cc_cdynlinker,
 [ case "$host-$CC" in
    *-gcc )
        gp_cv_prog_cc_cdynlinker="ld";;
    *-next-nextstep-cc )
        gp_cv_prog_cc_cdynlinker="cc";;
    * )
        gp_cv_prog_cc_cdynlinker="echo";;
   esac 
 ])
 AC_CACHE_CHECK(dynamic module link flags, gp_cv_prog_cc_cdynlinking,
 [ case "$host-$CC" in
    *linux* )
        gp_cv_prog_cc_cdynlinking="-Bshareable -x";;
    *freebsd* )
        gp_cv_prog_cc_cdynlinking="-Bshareable -x";;
    *hpux* )
        gp_cv_prog_cc_cdynlinking="-b +e Init__Dynamic";;

    *-nextstep*cc )
        gp_cv_prog_cc_cdynlinking="-arch $hostcpu -Xlinker -r -Xlinker -x -nostdlib";;
    *solaris* )
        gp_cv_prog_cc_cdynlinking="-G -Bdynamic";;
    *sunos* )
        gp_cv_prog_cc_cdynlinking="-assert pure-text -Bdynamic -x";;
    * )
        gp_cv_prog_cc_cdynlinking="UNSUPPORTED";;
   esac 
 ])

CDYNOPTIONS=$gp_cv_prog_cc_cdynoptions 
CDYNLINKER=$gp_cv_prog_cc_cdynlinker
CDYNLINKING=$gp_cv_prog_cc_cdynlinking

AC_SUBST(CDYNOPTIONS)
AC_SUBST(CDYNLINKER)
AC_SUBST(CDYNLINKING)

])
