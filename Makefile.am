ACLOCAL_AMFLAGS = -I cnf/m4


bin_PROGRAMS = gap

gap_LDFLAGS = $(LIBREADLINE)

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

$(top_srcdir)/cnf/GAP-VERSION-FILE: FORCE
	@$(SHELL) $(top_srcdir)/cnf/GAP-VERSION-GEN
-include $(top_srcdir)/cnf/GAP-VERSION-FILE

#gap_CPPFLAGS += '-DGAP_VERSION="$(GAP_VERSION)"'
#
#$(top_builddir)/src/gap-gap_version.o: $(top_srcdir)/cnf/GAP-VERSION-FILE

BUILT_SOURCES = src/gap_version.h
CLEANFILES = src/gap_version.h
src/gap_version.h: $(top_srcdir)/cnf/GAP-VERSION-FILE
	@echo '#define GAP_VERSION "$(GAP_VERSION)"' >$@

.PHONY: FORCE
