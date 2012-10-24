#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT([logToThreadscope], [0.1], [vj32@st-andrews.ac.uk])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.
AC_CHECK_SIZEOF(void*)
AC_CHECK_SIZEOF(long)
AC_CHECK_SIZEOF(long long)

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_INLINE
AC_TYPE_SIZE_T

# Checks for library functions.
AC_FUNC_MALLOC

AM_INIT_AUTOMAKE([logToThreadscope],[0.1])

AC_CONFIG_FILES([Makefile 
	         src/Makefile])
AC_OUTPUT
