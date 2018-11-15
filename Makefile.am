# -*- Makefile -*-

ACLOCAL_AMFLAGS = -I cnf/m4
AM_CPPFLAGS = ${BOEHM_GC_CPPFLAGS} ${GMP_CPPFLAGS} ${JULIA_CPPFLAGS} \
	${LIBATOMIC_OPS_CPPFLAGS} ${PTHREAD_CFLAGS} ${READLINE_CPPFLAGS} \
	${ZLIB_CPPFLAGS} -I${abs_builddir}/gen -I${abs_builddir}/src \
	-I${abs_builddir}
AM_CFLAGS = ${WARN_CFLAGS}
AM_CXXFLAGS = ${WARN_CXXFLAGS}
AM_LDFLAGS =

if SYS_IS_CYGWIN32
AM_CPPFLAGS += -DCOMPILECYGWINDLL
# increase stack size, the default is too small (see issue #1522)
AM_LDFLAGS += -Wl,--stack,16777216
endif

BUILT_SOURCES = src/ffdata.c src/ffdata.h gen/gap_version.c
if BUILD_GMP
BUILT_SOURCES += extern/install/gmp/lib/libgmp.la
endif
if BUILD_ZLIB
BUILT_SOURCES += extern/install/zlib/lib/libz.a
endif

CLEANFILES = extern/install/gmp/lib/libgmp.la extern/install/zlib/lib/libz.a
noinst_DATA = sysinfo.gap
noinst_SCRIPTS = bin/gap.sh
bin_PROGRAMS = gap ffgen
bin_SCRIPTS = gac
lib_LTLIBRARIES = libgap.la
pkginclude_HEADERS = src/ariths.h src/blister.h src/bool.h src/calls.h \
	src/code.h src/collectors.h src/compiled.h src/compiler.h \
	src/compstat.h src/costab.h src/cyclotom.h src/debug.h src/dt.h \
	src/dteval.h src/error.h src/exprs.h src/ffdata.h src/fibhash.h \
	src/finfield.h src/funcs.h src/gap.h src/gapstate.h src/gaputils.h \
	src/gasman.h src/gasman_intern.h src/gvars.h src/hookintrprtr.h \
	src/integer.h src/intfuncs.h src/intobj.h src/intrprtr.h src/io.h \
	src/iostream.h src/libgap-api.h src/listfunc.h src/listoper.h \
	src/lists.h src/macfloat.h src/modules.h src/objccoll.h src/objcftl.h \
	src/objects.h src/objfgelm.h src/objpcgel.h src/objset.h src/opers.h \
	src/permutat.h src/plist.h src/pperm.h src/precord.h src/profile.h \
	src/range.h src/rational.h src/read.h src/records.h src/saveload.h \
	src/scanner.h src/sctable.h src/set.h src/sortbase.h src/stats.h \
	src/streams.h src/stringobj.h src/sysfiles.h src/sysmem.h \
	src/sysopt.h src/system.h src/tietze.h src/trans.h src/vars.h \
	src/vec8bit.h src/vecffe.h src/vecgf2.h src/vector.h src/weakptr.h
hpcincludedir = ${pkgincludedir}/hpc
hpcinclude_HEADERS = src/hpc/aobjects.h src/hpc/atomic.h src/hpc/guards.h \
	src/hpc/misc.h src/hpc/region.h src/hpc/serialize.h src/hpc/thread.h \
	src/hpc/threadapi.h src/hpc/tls.h src/hpc/tlsconfig.h \
	src/hpc/traverse.h
gap_SOURCES = src/gapw95.c
gap_LDADD = libgap.la
ffgen_SOURCES = etc/ffgen.c
libgap_la_SOURCES = src/ariths.c src/blister.c src/bool.c src/calls.c \
	src/code.c src/collectors.cc src/compiler.c src/compstat.c \
	src/costab.c src/cyclotom.c src/debug.c src/dt.c src/dteval.c \
	src/error.c src/exprs.c src/ffdata.c src/finfield.c src/funcs.c \
	src/gap.c src/gvars.c src/hookintrprtr.c src/integer.c \
	src/intfuncs.c src/intrprtr.c src/io.c src/iostream.c src/listfunc.c \
	src/listoper.c src/lists.c src/macfloat.c src/modules.c \
	src/modules-builtin.c src/objcftl.c src/objects.c src/objfgelm.cc \
	src/objpcgel.cc src/objset.c src/opers.c src/permutat.cc src/plist.c \
	src/pperm.c src/precord.c src/profile.c src/range.c src/rational.c \
	src/read.c src/records.c src/saveload.c src/scanner.c src/sctable.c \
	src/set.c src/stats.c src/streams.c src/stringobj.c src/sysfiles.c \
	src/sysmem.c src/system.c src/tietze.c src/trans.c src/vars.c \
	src/vec8bit.c src/vecffe.c src/vecgf2.c src/vector.c src/weakptr.c \
	gen/gap_version.c
if HPCGAP
libgap_la_SOURCES += src/hpc/aobjects.c src/hpc/misc.c src/hpc/serialize.c src/hpc/thread.c src/hpc/threadapi.c src/hpc/tls.c src/hpc/traverse.c
libgap_la_SOURCES += src/hpc/c_oper1.c src/hpc/c_type1.c
# we don't support a kernel API in HPC-GAP atm
else
libgap_la_SOURCES += src/c_oper1.c src/c_type1.c
libgap_la_SOURCES += src/libgap-api.c
endif
if GAPMPI
libgap_la_SOURCES += src/hpc/gapmpi.c
endif
if USE_BOEHM_GC
libgap_la_SOURCES += src/boehm_gc.c
endif
if USE_GASMAN
libgap_la_SOURCES += src/gasman.c
endif
if USE_JULIA_GC
libgap_la_SOURCES += src/julia_gc.c
endif

libgap_la_LIBADD = ${BOEHM_GC_LIBS} ${GMP_LIBS} ${JULIA_LDFLAGS} ${JULIA_LIBS} \
	${LIBATOMIC_OPS_LIBS} ${READLINE_LIBS} ${ZLIB_LIBS}
if HPCGAP
libgap_la_LIBADD += ${PTHREAD_LIBS}
endif

src/ffgen.c: src/ffgen.h
src/ffgen.h: ffgen
	./ffgen -h >src/ffdata.h
	./ffgen -c >src/ffdata.c

gen/gap_version.c: ${top_builddir}/config.status

.PHONY: etags
etags:
	cd $(abs_srcdir) && etc/tags.sh -e --recurse lib hpcgap/lib src

extern/install/gmp/lib/libgmp.la:
	${MKDIR_P} gmp/doc
	touch "gmp/doc/gmp.info"
	MAKE=${MAKE} ${srcdir}/cnf/build-extern.sh gmp "${abs_top_srcdir}/extern/gmp" ABI=${ABI} --disable-static --enable-shared

extern/install/zlib/lib/libz.a:
if SYS_IS_CYGWIN32
	MAKE=${MAKE} CFLAGS="-fPIC ${CFLAGS} ${ABI_CFLAGS}" ${srcdir}/cnf/build-cygwin-zlib.sh
else
	MAKE=${MAKE} CFLAGS="-fPIC ${CFLAGS} ${ABI_CFLAGS}" ${srcdir}/cnf/build-extern.sh zlib "${abs_top_srcdir}/extern/zlib"
endif

install-exec-local:
	@echo '***'
	@echo '*** `make install` is not supported at this time.'
	@echo '*** gap and its utilities can only be run from the build directory.'
	@echo '*** This is because GAP scripts such as gac have build-time paths encoded in them.'
	@echo '***'
	exit 1

if SYS_IS_CYGWIN32
noinst_DATA += bin/gapicon.bmp bin/gapicon.ico bin/cygwin-version.txt
noinst_SCRIPTS += bin/instcygwinterminfo.sh
endif

bin/gapicon.bmp: cnf/cygwin/gapicon.bmp
	cp $< $@
bin/gapicon.ico: cnf/cygwin/gapicon.ico
	cp $< $@
bin/instcygwinterminfo.sh: cnf/cygwin/instcygwinterminfo.sh
	cp $< $@
	chmod a+x $@
bin/cygwin-version.txt:
	uname -a > $@
bin/gap.sh: config.status

sysinfo.gap: config.status
	@rm -f sysinfo.gap sysinfo.gap-default${ABI}	# in case this is a symlink created by an older version of the build system
	@echo "# This files has been generated by the GAP build system," >$@
	@echo "# do not edit manually!" >>$@
	@echo "GAParch=${GAPARCH}" >>$@
	@echo "GAP_ABI=${ABI}" >>$@
	@echo "GAP_HPCGAP=${HPCGAP}" >>$@
	@echo "" >>$@
	@echo "GAP_KERNEL_MAJOR_VERSION=${gap_kernel_major_version}" >>$@
	@echo "GAP_KERNEL_MINOR_VERSION=${gap_kernel_minor_version}" >>$@
	@echo "" >> $@
	@echo "GAP_BIN_DIR=\"${abs_builddir}\"" >>$@
	@echo "GAP_LIB_DIR=\"${abs_srcdir}\"" >>$@
	@echo "" >> $@
	@echo "GAP_CC=\"${CC}\"" >>$@
	@echo "GAP_CFLAGS=\"${CFLAGS}\"" >>$@
	@echo "GAP_CXXFLAGS=\"${CXXFLAGS}\"" >>$@
	@echo "GAP_CPPFLAGS=\"${AM_CPPFLAGS} ${CPPFLAGS}\"" >>$@
	@echo "GAP_LDFLAGS=\"${GAP_LDFLAGS}\"" >>$@
	@echo "GAP_LIBS=\"-L${abs_builddir} -L${abs_builddir}/.libs -lgap\"" >>$@
	@echo "" >>$@
	@echo "GAP_OBJS=\"\"" >>$@
	@echo "" >>$@
	@echo "JULIA=\"${JULIA}\"" >>$@
	ln -s $@ sysinfo.gap-default${ABI}
	${MKDIR_P} bin/${GAPARCH}
	rm -f bin/${GAPARCH}/src bin/${GAPARCH}/gac bin/${GAPARCH}/gap
	ln -s ${abs_srcdir}/src bin/${GAPARCH}/src
	ln -s ${abs_builddir}/gac bin/${GAPARCH}/gac
	ln -s ${abs_builddir}/gap bin/${GAPARCH}/gap

.PHONY: docomp
docomp: gap
if HPCGAP
	@${top_srcdir}/cnf/GAP-C-GEN ${top_srcdir}/lib ${top_srcdir}/src/hpc oper1 ./gap${EXEEXT}
	@${top_srcdir}/cnf/GAP-C-GEN ${top_srcdir}/lib ${top_srcdir}/src/hpc type1 ./gap${EXEEXT}
else
	@${top_srcdir}/cnf/GAP-C-GEN ${top_srcdir}/lib ${top_srcdir}/src oper1 ./gap${EXEEXT}
	@${top_srcdir}/cnf/GAP-C-GEN ${top_srcdir}/lib ${top_srcdir}/src type1 ./gap${EXEEXT}
endif

TESTGAP = ${builddir}/bin/gap.sh --quitonbreak -b -m 100m -o 1g -q -x 80 -r -A ${GAPARGS}
TESTGAPauto = ${builddir}/bin/gap.sh --quitonbreak -b -m 100m -o 1g -q -x 80 -r ${GAPARGS}

# Alias for backwards compatibility
manuals: doc

doc: gap$(EXEEXT) doc/make_doc
	doc/make_doc

clean-doc:
	rm -f doc/*/chap*.html doc/*/chap*.txt doc/*/*.css doc/*/*.js
	rm -f doc/*/chooser.html doc/*/manual*.pdf
	rm -f doc/*/*.{aux,bbl,blg,brf,idx,ilg,ind,lab,log,out,pnr,six,tex,toc}
	rm -f doc/manualbib.xml.bib

# FIXME: we currently build the manual inside $srcdir; so we don't want "make clean"
# to remove it, as other builds might share the manual.
#clean: clean-doc

# Manual consistency check
check-manuals: all
	${MKDIR_P} dev/log
	((cd doc/ref ; \
	  echo 'Read("testconsistency.g");' | ${TESTGAP} ) \
	  >`date -u +dev/log/check_manuals_%Y-%m-%d-%H-%M` 2>&1 )

.PHONY: doc clean-doc manuals check-manuals

testinstall: all
	${MKDIR_P} dev/log
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
            ReadGapRoot( "tst/testinstall.g" );' | ${TESTGAP} | \
            tee `date -u +dev/log/testinstall1_%Y-%m-%d-%H-%M` )
	( echo 'SetUserPreference("UseColorsInTerminal",false); LoadAllPackages(); \
            ReadGapRoot( "tst/testinstall.g" );' | ${TESTGAP} | \
            tee `date -u +dev/log/testinstall2_%Y-%m-%d-%H-%M` )

# test manual examples three times:
# - without packages
# - with packages loaded by default
# - with all packages loaded
testmanuals: all
	${MKDIR_P} dev/log
	((cd doc/tut ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ${TESTGAP};\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/tut/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/tut/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN TUTORIAL EXAMPLES (NO PACKAGES)"; fi ; \
	  echo '============================================================';\
	  cd doc/ref ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ${TESTGAP};\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/ref/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/ref/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN REFERENCE MANUAL EXAMPLES (NO PACKAGES)"; fi ) \
	  > `date -u +dev/log/testmanuals1_%Y-%m-%d-%H-%M` 2>&1 )
	( rm -rf doc/tut/EXAMPLEDIFFS*; rm -rf doc/ref/EXAMPLEDIFFS* )
	((cd doc/tut ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | $(TESTGAPauto);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/tut/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/tut/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN TUTORIAL EXAMPLES (DEFAULT PACKAGES)"; fi ; \
	  echo '============================================================';\
	  cd doc/ref ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | $(TESTGAPauto);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/ref/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/ref/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN REFERENCE MANUAL EXAMPLES (DEFAULT PACKAGES)"; fi ) \
	  > `date -u +dev/log/testmanualsA_%Y-%m-%d-%H-%M` 2>&1 )
	( rm -rf doc/tut/EXAMPLEDIFFS*; rm -rf doc/ref/EXAMPLEDIFFS* )
	((cd doc/tut ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  LoadAllPackages() ; \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ${TESTGAP};\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/tut/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/tut/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN TUTORIAL EXAMPLES (ALL PACKAGES)"; fi ; \
	  echo '============================================================';\
	  cd doc/ref ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  LoadAllPackages() ; \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ${TESTGAP};\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/ref/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/ref/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN REFERENCE MANUAL EXAMPLES (ALL PACKAGES)"; fi ) \
	  > `date -u +dev/log/testmanuals2_%Y-%m-%d-%H-%M` 2>&1 )
	( rm -rf doc/tut/EXAMPLEDIFFS*; rm -rf doc/ref/EXAMPLEDIFFS* )

# check how packages are loaded when loading obsoletes is disabled
# - when all dependencies are loaded
# - when packages are loaded with `OnlyNeeded` option
testobsoletes: all
	${MKDIR_P} dev/log
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} -O )
	( echo 'CreatePackageLoadTestsInput( "testobsoletes1.in", \
            "dev/log/testobsoletes1", \
            "${TESTGAP} -O -L wsp.g", false, false );'\
            | ${TESTGAP} -O -L wsp.g > /dev/null )
	( chmod 777 testobsoletes1.in; ./testobsoletes1.in > \
            `date -u +dev/log/testobsoletes1_%Y-%m-%d-%H-%M`; rm testobsoletes1.in )
	( rm wsp.g )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} -O )
	( echo 'CreatePackageLoadTestsInput( "testobsoletesN1.in", \
            "dev/log/testobsoletesN1", \
            "${TESTGAP} -O -L wsp.g", false, true );'\
            | ${TESTGAP} -O -L wsp.g > /dev/null )
	( chmod 777 testobsoletesN1.in; ./testobsoletesN1.in > \
            `date -u +dev/log/testobsoletesN1_%Y-%m-%d-%H-%M`; rm testobsoletesN1.in )
	( rm wsp.g )

# For a package with the name given by the PKGNAME variable,
# run its standard tests (i.e. those specified in PackageInfo.g):
# - in GAP started without packages
# - in GAP started with packages loaded by default
# - in GAP started with all packages loaded
testpackage: all
	${MKDIR_P} dev/log
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageTestsInput( "testpackage.in", \
            "dev/log/testpackage1", \
            "${TESTGAP} -L wsp.g", "false", "$(PKGNAME)" );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackage.in; ./testpackage.in; rm testpackage.in )
	( rm wsp.g )
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | $(TESTGAPauto) )
	( echo 'CreatePackageTestsInput( "testpackage.in", \
            "dev/log/testpackageA", \
            "$(TESTGAPauto) -L wsp.g", "auto", "$(PKGNAME)" );'\
            | $(TESTGAPauto) -L wsp.g > /dev/null )
	( chmod 777 testpackage.in; ./testpackage.in; rm testpackage.in )
	( rm wsp.g )
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageTestsInput( "testpackage.in", \
            "dev/log/testpackage2", \
            "${TESTGAP} -L wsp.g", "true", "$(PKGNAME)" );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackage.in; ./testpackage.in; rm testpackage.in )
	( rm wsp.g )

# For each package that specifies its standard tests in PackageInfo.g, run it
# - in GAP started without packages
# - in GAP started with packages loaded by default
# - in GAP started with all packages loaded
testpackages: all
	${MKDIR_P} dev/log
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageTestsInput( "testpackages.in", \
            "dev/log/testpackages1", \
            "${TESTGAP} -L wsp.g", "false" );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in )
	( rm wsp.g )
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | $(TESTGAPauto) )
	( echo 'CreatePackageTestsInput( "testpackages.in", \
            "dev/log/testpackagesA", \
            "$(TESTGAPauto) -L wsp.g", "auto" );'\
            | $(TESTGAPauto) -L wsp.g > /dev/null )
	( chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in )
	( rm wsp.g )
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageTestsInput( "testpackages.in", \
            "dev/log/testpackages2", \
            "${TESTGAP} -L wsp.g", "true" );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in )
	( rm wsp.g )

# check how packages are loaded
# - when all dependencies are loaded
# - when packages are loaded with `OnlyNeeded` option
testpackagesload: all
	${MKDIR_P} dev/log
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageLoadTestsInput( "testpackagesload.in", \
            "dev/log/testpackagesload1", \
            "${TESTGAP} -L wsp.g", false, false );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesload1_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( rm wsp.g )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageLoadTestsInput( "testpackagesload.in", \
            "dev/log/testpackagesloadN1", \
            "${TESTGAP} -L wsp.g", false, true );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesloadN1_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( rm wsp.g )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | $(TESTGAPauto) )
	( echo 'CreatePackageLoadTestsInput( "testpackagesload.in", \
            "testpackagesloadA", \
            "$(TESTGAPauto) -L wsp.g", true, false );'\
            | $(TESTGAPauto) -L wsp.g > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesloadA_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( rm wsp.g )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | $(TESTGAPauto) )
	( echo 'CreatePackageLoadTestsInput( "testpackagesload.in", \
            "testpackagesloadNA", \
            "$(TESTGAPauto) -L wsp.g", true, true );'\
            | $(TESTGAPauto) -L wsp.g > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesloadNA_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( rm wsp.g )

# Produce an overview of new variables defined by each package
testpackagesvars: all
	${MKDIR_P} dev/log
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            SaveWorkspace( "wsp.g" );' | ${TESTGAP} )
	( echo 'CreatePackageVarsTestsInput( "testpackagesvars.in", \
            "dev/log/testpackagesvars", \
            "${TESTGAP} -L wsp.g" );'\
            | ${TESTGAP} -L wsp.g > /dev/null )
	( chmod 777 testpackagesvars.in; ./testpackagesvars.in > \
            `date -u +dev/log/testpackagesvars_%Y-%m-%d-%H-%M`; rm testpackagesvars.in )
	( rm wsp.g )

# run teststandard.g twice:
# - without packages (except needed to run GAP)
# - with all packages loaded
teststandard: all
	${MKDIR_P} dev/log
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
          ReadGapRoot( "tst/teststandard.g" );' | ${TESTGAP} | \
            tee `date -u +dev/log/teststandard1_%Y-%m-%d-%H-%M` )
	( echo 'SetUserPreference("UseColorsInTerminal",false); LoadAllPackages(); \
          ReadGapRoot( "tst/teststandard.g" );' | ${TESTGAP} | \
            tee `date -u +dev/log/teststandard2_%Y-%m-%d-%H-%M` )

# run testbugfix.g twice:
# - without packages (except needed to run GAP)
# - with all packages loaded
testbugfix: all
	${MKDIR_P} dev/log
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
          ReadGapRoot( "tst/testbugfix.g" );' | ${TESTGAP} | \
            tee `date -u +dev/log/testbugfix1_%Y-%m-%d-%H-%M` )
	( echo 'SetUserPreference("UseColorsInTerminal",false); LoadAllPackages(); \
          ReadGapRoot( "tst/testbugfix.g" );' | ${TESTGAP} | \
            tee `date -u +dev/log/testbugfix2_%Y-%m-%d-%H-%M` )

# change PKG_BRANCH to stable-X.Y in the stable branch
PKG_BRANCH = master
PKG_BOOTSTRAP_URL = https://www.gap-system.org/pub/gap/gap4pkgs/
PKG_MINIMAL = packages-required-${PKG_BRANCH}.tar.gz
PKG_FULL = packages-${PKG_BRANCH}.tar.gz
WGET = wget -N

bootstrap-pkg-minimal:
	@if test -e pkg; then \
		echo "The pkg directory already exists. Please move or remove it to proceed."; \
	else \
		${WGET} ${PKG_BOOTSTRAP_URL}${PKG_MINIMAL} && \
		mkdir pkg && \
		cd pkg && \
		tar -xzf ../${PKG_MINIMAL}; \
	fi

bootstrap-pkg-full:
	@if test -e pkg; then \
		echo "The pkg directory already exists. Please move or remove it to proceed" ; \
	else \
		${WGET} ${PKG_BOOTSTRAP_URL}${PKG_FULL} && \
		mkdir pkg && \
		cd pkg && \
		tar -xzf ../${PKG_FULL}; \
	fi

.PHONY: bootstrap-pkg-minimal bootstrap-pkg-full
