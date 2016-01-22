AC_PREREQ([2.66])
AC_INIT([GAP], [4.8.1], [support@gap-system.org])

AC_CANONICAL_TARGET
AM_INIT_AUTOMAKE

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([src/gap.h])
AC_CONFIG_HEADERS([src/config.h])

AC_CONFIG_FILES([
  Makefile
  src/Makefile
])


dnl Find the GNU Multiple Precision Arithmetic Library
AC_ARG_WITH(gmp,
  [AS_HELP_STRING([--with-gmp=<path>],  
                  [prefix of GMP installation. e.g. /usr/local or /usr])],
  [GMP_PREFIX="$with_gmp"],
  [AC_CHECK_LIB([gmp], [__gmpz_init], ,
    AC_MSG_ERROR([GNU Multiple Precision Arithmetic Library not found.
    Maybe you want to call configure with the --with-gmp=<path> option?
    This tells configure where to find the GMP library and headers.
    e.g. --with-gmp=/usr/local or --with-gmp=/usr]))]
)
if test "x$GMP_PREFIX" != x ; then
  GMP_LIBS=" -L${GMP_PREFIX}/lib"
  GMP_CFLAGS=" -I${GMP_PREFIX}/include"
else
  GMP_LIBS=""
  GMP_CFLAGS=""
fi
GMP_LIBS="${GMP_LIBS} -lgmp"
AC_SUBST(GMP_LIBS)
AC_SUBST(GMP_CFLAGS)


dnl SYS_ARCH must match the GAP install for packages 
dnl to find binaries in the right path (see GAParch_system 
dnl in sysinfo.gap)
AC_ARG_WITH(gap-system-arch,
  [AS_HELP_STRING([--with-gap_system_arch=<string>],  
                  [the GAP arch (default: x86_64-unknown-linux-gnu-gcc-default64)])],
  [GAP_SYSTEM_ARCH="$with_gap_system_arch"],
  [GAP_SYSTEM_ARCH="x86_64-unknown-linux-gnu-gcc-default64"])
AC_DEFINE_UNQUOTED([SYS_ARCH], ["$GAP_SYSTEM_ARCH"], [GAP system architecture string])


# weird macros that GAP uses
AC_DEFINE_UNQUOTED([CONFIGNAME], ["default"], [arbitrary name])
AC_DEFINE([HAVE_DOTGAPRC], 1, [define as 1 if the user resource file is .gaprc])
AC_DEFINE([HAVE_SLASH_SEPARATOR], 1, [if your directory separator is forward slash])

# Checks for programs.
AM_PROG_CC_C_O
AM_PROG_AS

AC_C_CONST
AC_C_INLINE
AC_C_BIGENDIAN
AC_CHECK_SIZEOF(void *, 4) # no space between 'void *' and ','
AC_CHECK_ALIGNOF([long])

# Checks for libraries.
LT_INIT([dlopen])

# Checks for header files.
AC_CHECK_HEADERS([math.h assert.h sys/sysmacros.h fcntl.h sys/stat.h mach/mach.h sys/mman.h])
AC_CHECK_HEADERS([sgtty.h stdlib.h string.h sys/ioctl.h sys/param.h sys/time.h sys/resource.h])
AC_CHECK_HEADERS([termio.h termios.h unistd.h signal.h stdio.h libc.h sys/times.h sys/wait.h])
AC_CHECK_HEADERS([vfork.h dirent.h errno.h setjmp.h])

AC_FUNC_VFORK
AC_FUNC_FORK
AC_FUNC_MALLOC
AC_CHECK_FUNCS([getpseudotty _getpty getpt ptsname_r])
AC_CHECK_FUNCS([setpgid setjmp sbrk])
AC_CHECK_FUNCS([rld_load])
AC_CHECK_FUNCS([times getrusage])
AC_CHECK_FUNCS([vm_allocate])
AC_CHECK_FUNCS([fork popen waitpid wait4])
AC_CHECK_FUNCS([dup2 floor memmove mkdir pow rint select])
AC_CHECK_FUNCS([ttyname strerror select])
AC_CHECK_FUNCS([access stat fstat lstat unlink mkdir mkdtemp mkstemp rmdir link rename])
AC_CHECK_FUNCS([symlink readlink chmod fchmod chown fchown lchown dup dup2 mknod mkfifo])
AC_CHECK_FUNCS([socket listen accept connect bind getsockname recv recvfrom recvmsg send])
AC_CHECK_FUNCS([sendto sendmsg getsockopt setsockopt getprotobyname gethostbyname])
AC_CHECK_FUNCS([opendir closedir dirfd readdir rewinddir seekdir telldir])
AC_CHECK_FUNCS([gettimeofday])

AC_SEARCH_LIBS(dlopen, dl, AC_DEFINE(HAVE_DLOPEN, 1, [define as 1 if you have dlopen and dlsym]))

# sigsetjmp is a macro on some platforms, cannot use AC_CHECK_FUNCS
AC_MSG_CHECKING(for sigsetjmp())
AC_TRY_LINK([#include <setjmp.h>], [sigjmp_buf t; sigsetjmp(t, 0)],
  [AC_MSG_RESULT(yes)
   AC_DEFINE([HAVE_SIGSETJMP], 1, [Define to 1 if you have the sigsetjmp function.])],
  [AC_MSG_RESULT(no)]
)

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_HEADER_DIRENT
AC_HEADER_MAJOR
AC_HEADER_STAT
AC_C_INLINE
AC_TYPE_SIZE_T
AC_TYPE_PID_T
AC_TYPE_SIGNAL
AC_CHECK_MEMBERS([struct stat.st_rdev])
 
# weird check for signal handling
AC_CHECK_FUNCS([signal])
AC_TYPE_SIGNAL
if test "$ac_cv_type_signal" = "void"; then
  AC_DEFINE([HAVE_SIGNAL_VOID], [1] ,[void as signal type??])
fi

AC_DEFINE(HAVE_STRERROR, 1, [Everybody has that])
AC_DEFINE(HAVE_SYS_ERRLIST, 1, [Or GAP will define its own])

dnl #########################################################################
dnl ##
dnl ## set features on systems we know for better performance
dnl ##

case "$host" in
  i386-*-* | i486-*-* | i586-*-* | i686-*-*)
    AC_DEFINE([C_STACK_ALIGN], [2], [align stack??])
    ;;
  *)
    AC_DEFINE_UNQUOTED([C_STACK_ALIGN], [$ac_cv_alignof_long], [align stack??])
    ;;
esac

need_itanium_obj=false
case "$host" in 
  sparc-* )
    AC_DEFINE([SPARC], [1], [whether we are running on SPARC architecture])
    ;;
  ia64-* ) 
    AC_DEFINE([ITANIUM], [1], [whether we are runnig on Itanium architecture])
    need_itanium_obj=true
    ;;
  *-darwin* )
    AC_DEFINE([SYS_IS_DARWIN], [1], [whether we are running on OSX])
    ;;
  *)
    AC_DEFINE([SYS_IS_DARWIN], [0], [whether we are running on OSX])
    ;;
esac
# important: AM_CONDITIONAL must not be in case/esac block
AM_CONDITIONAL([NEED_ITANIUMOBJ], [test x$need_itanium_obj = xtrue])

AC_CYGWIN
if test "$CYGWIN" = "yes"; then
  AC_DEFINE([SYS_IS_CYGWIN32], [1], [whether we are running on Windows])
else
  AC_DEFINE([SYS_IS_CYGWIN32], [0], [whether we are running on Windows])
fi


#OUTPUT
AC_OUTPUT
