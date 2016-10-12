ACLOCAL_AMFLAGS = -I cnf/m4


bin_PROGRAMS = gap

# libraries used by GAP
gap_CPPFLAGS = $(GMP_CPPFLAGS)
gap_LDFLAGS = $(GMP_LDFLAGS) $(LIBREADLINE)

# In order to enable kernel extensions to invoke arbitrary
# GAP kernel functions, pass -export-dynamic to libtool
gap_LDFLAGS += -export-dynamic

# GAP itself should not have any unresolved symbols, so tell
# libtool about that.
gap_LDFLAGS += -no-undefined

# HACK: tell GAP where to search for its library
# This is a hack, because (a) it is incorrect when doing "make install", 
# (b) it does not rebuild anything if the source directory is moved.
# The latter could be ignored, but not the former.
gap_CPPFLAGS += '-DSYS_DEFAULT_PATHS="$(abs_top_srcdir)"'


# standard GAP sources
gap_SOURCES = \
    src/ariths.c \
    src/backtrace.c \
    src/blister.c \
    src/bool.c \
    src/c_filt1.c \
    src/c_meths1.c \
    src/c_oper1.c \
    src/c_random.c \
    src/c_type1.c \
    src/calls.c \
    src/code.c \
    src/compiler.c \
    src/compstat.c \
    src/costab.c \
    src/cyclotom.c \
    src/dt.c \
    src/dteval.c \
    src/exprs.c \
    src/ffdata.c \
    src/finfield.c \
    src/funcs.c \
    src/gap.c \
    src/gap_version.c \
    src/gasman.c \
    src/globalstate.c \
    src/gmpints.c \
    src/gvars.c \
    src/intfuncs.c \
    src/intrprtr.c \
    src/iostream.c \
    src/listfunc.c \
    src/listoper.c \
    src/lists.c \
    src/macfloat.c \
    src/objccoll.c \
    src/objcftl.c \
    src/objects.c \
    src/objfgelm.c \
    src/objpcgel.c \
    src/objscoll.c \
    src/objset.c \
    src/opers.c \
    src/permutat.c \
    src/plist.c \
    src/pperm.c \
    src/precord.c \
    src/profile.c \
    src/range.c \
    src/rational.c \
    src/read.c \
    src/records.c \
    src/saveload.c \
    src/scanner.c \
    src/sctable.c \
    src/set.c \
    src/stats.c \
    src/streams.c \
    src/stringobj.c \
    src/sysfiles.c \
    src/system.c \
    src/systimers.c \
    src/tietze.c \
    src/trans.c \
    src/vars.c \
    src/vec8bit.c \
    src/vecffe.c \
    src/vecgf2.c \
    src/vector.c \
    src/weakptr.c

if ITANIUM
gap_SOURCES += src/itanium.s
endif

if HPCGAP
gap_SOURCES += \
    src/hpc/aobjects.c \
    src/hpc/gapmpi.c \
    src/hpc/serialize.c \
    src/hpc/thread.c \
    src/hpc/threadapi.c \
    src/hpc/tls.c \
    src/hpc/traverse.c \
    src/hpc/zmqgap.c
endif

#
# GAP headers
#
gapincludedir = $(includedir)/gap
gapinclude_HEADERS = \
    src/ariths.h \
    src/blister.h \
    src/bool.h \
    src/calls.h \
    src/code.h \
    src/compiled.h \
    src/compiler.h \
    src/compstat.h \
    src/config.h \
    src/costab.h \
    src/cyclotom.h \
    src/dt.h \
    src/dteval.h \
    src/exprs.h \
    src/ffdata.h \
    src/fibhash.h \
    src/finfield.h \
    src/funcs.h \
    src/gap.h \
    src/gasman.h \
    src/globalstate.h \
    src/gmpints.h \
    src/gvars.h \
    src/integer.h \
    src/intfuncs.h \
    src/intrprtr.h \
    src/iostream.h \
    src/listfunc.h \
    src/listoper.h \
    src/lists.h \
    src/macfloat.h \
    src/objccoll.h \
    src/objcftl.h \
    src/objects.h \
    src/objfgelm.h \
    src/objpcgel.h \
    src/objscoll.h \
    src/objset.h \
    src/opers.h \
    src/permutat.h \
    src/plist.h \
    src/pperm.h \
    src/precord.h \
    src/profile.h \
    src/range.h \
    src/rational.h \
    src/read.h \
    src/records.h \
    src/saveload.h \
    src/scanner.h \
    src/sctable.h \
    src/set.h \
    src/stats.h \
    src/streams.h \
    src/stringobj.h \
    src/sysfiles.h \
    src/system.h \
    src/systhread.h \
    src/tietze.h \
    src/trans.h \
    src/vars.h \
    src/vec8bit.h \
    src/vecffe.h \
    src/vecgf2.h \
    src/vector.h \
    src/weakptr.h


# The following headers are deliberately not installed 
noinst_HEADERS = \
    src/objccoll-impl.h \
    src/objscoll-impl.h \
    src/sortbase.h


if HPCGAP
gapinclude_HEADERS += \
    src/hpc/aobjects.h \
    src/hpc/atomic.h \
    src/hpc/boehm_gc.h \
    src/hpc/gapmpi.h \
    src/hpc/serialize.h \
    src/hpc/thread.h \
    src/hpc/threadapi.h \
    src/hpc/tls.h \
    src/hpc/tlsconfig.h \
    src/hpc/traverse.h \
    src/hpc/zmqgap.h
endif

if COMPAT_MODE
# TODO:
# create the following dirs and files in the build tree:
#  sysinfo.gap
#  src/
#    foo.h    # symlink, hardlink or copy to $GAPROOT/foo.h
#    compiled.h    # this one MUST be a copy, because those scripts check for that...
#  bin/
#    fakearch-default32/    # or ...64/
#      config.h             # symlink (?) to ../../src/config.h
#
# Content of sysinfo.gap:
#   GAParch=fake-arch
#   GAParch_system=fake-arch
#   GAParch_abi=64-bit


endif


$(top_srcdir)/cnf/GAP-VERSION-FILE: FORCE
	@cd $(top_srcdir) && $(SHELL) cnf/GAP-VERSION-GEN
-include $(top_srcdir)/cnf/GAP-VERSION-FILE

#gap_CPPFLAGS += '-DGAP_VERSION="$(GAP_VERSION)"'
#
#$(top_builddir)/src/gap-gap_version.o: $(top_srcdir)/cnf/GAP-VERSION-FILE

BUILT_SOURCES = src/gap_version.h
CLEANFILES = src/gap_version.h
src/gap_version.h: $(top_srcdir)/cnf/GAP-VERSION-FILE
	@echo '#define GAP_VERSION "$(GAP_VERSION)"' >$@

.PHONY: FORCE
