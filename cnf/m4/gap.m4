dnl
dnl check what unaligned access is still save
dnl

AC_DEFUN([GP_C_LONG_ALIGN],
[AC_CACHE_CHECK([unaligned access], gp_cv_c_long_align,
[
case "$host" in
   alpha* )
        gp_cv_c_long_align=8;;
   mips-* | sparc-* )
        gp_cv_c_long_align=$ac_cv_sizeof_void_p;;
   i386-*-* | i486-*-* | i586-*-* | i686-*-*)
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
AC_DEFINE_UNQUOTED(C_STACK_ALIGN, $gp_cv_c_long_align, [define as least offset which is still safe for an unaligned access])
] )
