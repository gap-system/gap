DEFAULT_INCLUDES = -I@top_builddir@

bin_PROGRAMS = gap

gap_SOURCES = \
  ariths.c    c_random.c  gmpints.c   objccoll.c  rational.c  system.c  \
  blister.c   c_type1.c   gvars.c     objcftl.c   read.c      tietze.c  \
  bool.c      cyclotom.c  integer.c   objects.c   records.c   vars.c    \
  calls.c     dt.c        intfuncs.c  objfgelm.c  saveload.c  vec8bit.c \
  c_filt1.c   dteval.c    intrprtr.c  objpcgel.c  scanner.c   vecffe.c  \
  c_meths1.c  exprs.c     iostream.c  objscoll.c  sctable.c   vecgf2.c  \
  code.c      finfield.c  opers.c     set.c       vector.c  \
  compiler.c  funcs.c     listfunc.c  permutat.c  stats.c     weakptr.c \
  compstat.c  gap.c       listoper.c  plist.c     streams.c   \
  c_oper1.c   lists.c     precord.c   string.c    \
  costab.c    gasman.c    macfloat.c  range.c     sysfiles.c \
  pperm.c     trans.c \
  profile.c

if NEED_ITANIUMOBJ
  gap_SOURCES += itanium.s
endif

gapincludedir = @includedir@/gap
gapinclude_HEADERS = \
  ariths.h    cyclotom.h  integer.h   objcftl.h   rational.h  sysfiles.h \
  blister.h   dteval.h    intfuncs.h  objects.h   read.h      system.h   \
  bool.h      dt.h        intrprtr.h  objfgelm.h  records.h   tietze.h   \
  calls.h     exprs.h     iostream.h  objpcgel.h  saveload.h  vars.h     \
  code.h      finfield.h  objscoll.h  scanner.h   vec8bit.h              \
  compiled.h  funcs.h     listfunc.h  opers.h     sctable.h   vecffe.h   \
  compiler.h  gap.h       listoper.h  permutat.h  set.h       vecgf2.h   \
  compstat.h  gasman.h    lists.h     plist.h     stats.h     vector.h   \
  config.h    gmpints.h   macfloat.h  precord.h   streams.h   weakptr.h  \
  costab.h    gvars.h     objccoll.h  range.h     string.h               \
  pperm.h     trans.h     objccoll-impl.h objscoll-impl.h \
  profile.h   gap_version.h \
  hpc/aobjects.h  hpc/atomic.h  hpc/ffdata.h  hpc/thread.h  hpc/tls.h



gap_CFLAGS = $(AM_CFLAGS) \
  -DCONFIG_H @GMP_CFLAGS@

# * the no-undefined is necessary for Cygwin
# * export-dynamic is a bit of a hack to allow dynamic loading of gap
#   packages. This would not be needed if the GAP symbols were in a
#   shared library (libgap)
gap_LDFLAGS = -lm @GMP_LIBS@ -no-undefined -export-dynamic


dist-hook:
	@echo '***************************************************'
	@echo '*** /src dist-hook *********************************'
	@echo '***************************************************'
	@echo '****** patch version $(PACKAGE)-$(VERSION)'
	sed -i 's/SyKernelVersion = "4.dev"/SyKernelVersion = "$(VERSION)"/g' $(top_distdir)/src/system.c
	sed -i 's/GAP_BUILD_VERSION  "4.dev"/GAP_BUILD_VERSION  "$(PACKAGE)-$(VERSION)"/g' $(top_distdir)/src/gap_version.h
	@echo '***************************************************'
