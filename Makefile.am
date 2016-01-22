
# Hack: GAP uses header names that clash with system headers
# (like string.h). This works as long as "." is not in the include
# path, otherwise the wrong header will be picked up. But for make
# distcheck we need "." in the search path since, during the VPATH
# build, this is where config.h resides. Incidentally, "." is not
# where the GAP headers are during the VPATH build so we are fine.

AM_DISTCHECK_CONFIGURE_FLAGS = 'CFLAGS=-I. -I../src'

ACLOCAL_AMFLAGS = -I m4
SUBDIRS = src
