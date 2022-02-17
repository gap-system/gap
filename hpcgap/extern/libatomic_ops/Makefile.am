SUBDIRS = src doc tests

ACLOCAL_AMFLAGS = -I m4

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = pkgconfig/atomic_ops.pc
noinst_DATA = pkgconfig/atomic_ops-uninstalled.pc

if ENABLE_DOCS
dist_doc_DATA = COPYING README.md
endif

EXTRA_DIST = autogen.sh

## TODO: After migration to autoconf-1.13+, remove check-nolink definition
## from this Makefile.am and add AM_EXTRA_RECURSIVE_TARGETS([check-nolink])
## back to configure.ac file.
.PHONY: check-nolink check-nolink-local
check-nolink: check-nolink-local
	$(MAKE) --directory tests $(AM_MAKEFLAGS) check-nolink-local

check-nolink-local: all

#distclean-local:
