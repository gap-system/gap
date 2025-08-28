# GNUmakefile.  Generated from GNUmakefile.in by configure.

# This file is the part of the GAP build system. It is the first file
# processed by GNU make when build GAP. If you want to understand the
# build system, you can begin tracing it from here.
#
# To learn more about the GAP build system, see README.buildsys.md


#
# Set lots of variables to values computed by the configure script
#

# GAP specific
ABI = 64
ABI_CFLAGS = 

# HPC-GAP specific
HPCGAP = no

# garbage collector source files
GC_SOURCES = src/gasman.c src/sysmem.c

# GAP architecture string
GAPARCH = x86_64-pc-linux-gnu-default64-kv10

# maintainer mode
MAINTAINER_MODE = yes

# GAP version and release date
GAP_VERSION = 4.15dev
GAP_RELEASEDAY = today

# GAP kernel version
GAP_KERNEL_MINOR_VERSION = 0
GAP_KERNEL_MAJOR_VERSION = 10

# autoconf host system information (= system *for* which we are compiling)
host = x86_64-pc-linux-gnu
host_alias = 
host_cpu = x86_64
host_os = linux-gnu
host_vendor = pc

# autoconf build system information (= system *on* which we are compiling)
build = x86_64-pc-linux-gnu
build_alias = 
build_cpu = x86_64
build_os = linux-gnu
build_vendor = pc

# compile and linker flags
CFLAGS = -g -O2
CXXFLAGS = -g -O2
CPPFLAGS = 
LDFLAGS = 
LIBS = -lm 
GAP_DEFINES =  -DUSE_GASMAN=1

WARN_CFLAGS = -fno-strict-aliasing -Wall -Wextra -Warray-bounds -Wno-cast-function-type -Wdouble-promotion -Wduplicated-branches -Wduplicated-cond -Wformat-nonliteral -Wformat-security -Wformat=2 -Winit-self -Wno-inline -Wlogical-op -Wmissing-field-initializers -Wmissing-format-attribute -Wmissing-include-dirs -Wno-pragmas -Wpacked -Wpointer-arith -Wredundant-decls -Wrestrict -Wreturn-type -Wshadow -Wno-sign-compare -Wstrict-aliasing -Wundef -Wunused-but-set-variable -Wno-unused-parameter -Wwrite-strings -Wno-implicit-fallthrough -Wimplicit-function-declaration -Wjump-misses-init -Wnested-externs -Wold-style-definition -Wstrict-prototypes -Wno-error=cast-function-type -Wno-error=inline -Wno-error=pragmas -Wno-error=sign-compare -Wno-error=unused-parameter -Wno-error=implicit-fallthrough
WARN_CXXFLAGS = -fno-strict-aliasing -Wall -Wextra -Warray-bounds -Wno-cast-function-type -Wdouble-promotion -Wduplicated-branches -Wduplicated-cond -Wformat-nonliteral -Wformat-security -Wformat=2 -Winit-self -Wno-inline -Wlogical-op -Wmissing-field-initializers -Wmissing-format-attribute -Wmissing-include-dirs -Wno-pragmas -Wpacked -Wpointer-arith -Wredundant-decls -Wrestrict -Wreturn-type -Wshadow -Wno-sign-compare -Wstrict-aliasing -Wundef -Wunused-but-set-variable -Wno-unused-parameter -Wwrite-strings -Wextra-semi

BUILD_GMP = no
GMP_CPPFLAGS = -Ibundled/include
GMP_LDFLAGS = -Lbundled/lib
GMP_LIBS = -lgmp
GMP_PREFIX = bundled

BUILD_ZLIB = no
ZLIB_CPPFLAGS = 
ZLIB_LDFLAGS = 
ZLIB_LIBS = -lz

READLINE_CPPFLAGS = 
READLINE_LDFLAGS = 
READLINE_LIBS = 

JULIA_VERSION = 
JULIA_CFLAGS = 
JULIA_LDFLAGS = 
JULIA_LIBS = 

BUILD_BOEHM_GC = 
BOEHM_GC_CPPFLAGS = 
BOEHM_GC_LDFLAGS = 
BOEHM_GC_LIBS = 

BUILD_LIBATOMIC_OPS = 
LIBATOMIC_OPS_CPPFLAGS = 
LIBATOMIC_OPS_LDFLAGS = 
LIBATOMIC_OPS_LIBS = 

PTHREAD_CFLAGS = -pthread
PTHREAD_LIBS = -lpthread

# build tools
CC = gcc 
CXX = g++ 
INSTALL = /usr/bin/install -c
MKDIR_P = /usr/bin/mkdir -p
SED = /usr/bin/sed
SHELL = /bin/bash

# misc
EXEEXT = 

# build paths
abs_builddir = /home/runner/work/gap/gap/native-build
abs_srcdir = /home/runner/work/gap/gap/native-build/..
builddir = .
srcdir = ..

# for compatibility: top_builddir is used by libtool for LIBTOOL variable;
# keeping the others makes it easier to "git bisect" back and forth
top_builddir = .
top_srcdir = ..
abs_top_builddir = /home/runner/work/gap/gap/native-build
abs_top_srcdir = /home/runner/work/gap/gap/native-build/..

# install paths
bindir = ${exec_prefix}/bin
datadir = ${datarootdir}
datarootdir = ${prefix}/share
docdir = ${datarootdir}/doc/${PACKAGE_TARNAME}
exec_prefix = ${prefix}
htmldir = ${docdir}
includedir = ${prefix}/include
infodir = ${datarootdir}/info
libdir = ${exec_prefix}/lib
libexecdir = ${exec_prefix}/libexec
localedir = ${datarootdir}/locale
localstatedir = ${prefix}/var
mandir = ${datarootdir}/man
pdfdir = ${docdir}
prefix = /usr/local
psdir = ${docdir}
sbindir = ${exec_prefix}/sbin
sharedstatedir = ${prefix}/com
sysconfdir = ${prefix}/etc


#
# Set vpath values to make GNU make read source files from $(srcdir).
#
# The vpath directives below ensure that if we reference src/foo.c, then if it
# is not found in the build dir (e.g. because we are doing an out-of-tree
# build), GNU make automatically looks for $(srcdir)/src/foo.c
# #
# Note that `vpath' is a GNU make extension. Unlike VPATH, it can be
# restricted to certain file extensions. This way, we can mix in-tree and
# out-of-tree builds without accidentally picking up e.g. *.o files from the
# wrong tree. We still have to be careful about build/config.h, though.
#
vpath src/%.h $(srcdir)
vpath src/%.c $(srcdir)
vpath src/%.cc $(srcdir)
vpath src/%.s $(srcdir)

vpath src/hpc/%.h $(srcdir)
vpath src/hpc/%.c $(srcdir)
vpath src/hpc/%.cc $(srcdir)
vpath src/hpc/%.s $(srcdir)

vpath tst/testkernel/%.h $(srcdir)
vpath tst/testkernel/%.c $(srcdir)

vpath tst/testlibgap/%.h $(srcdir)
vpath tst/testlibgap/%.c $(srcdir)


#
# Finally, include the actual make rules.
#
include $(srcdir)/Makefile.rules
