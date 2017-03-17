JOBS=4
GMP=yes
GC=boehm-par
MPI_GC=boehm
GCBLKSIZE=8192
GCMAXTHREADS=
WARD=../ward
SCONS=bin/run-python bin/scons
CFLAGS=
DEBUG=debugguards=1 cflags=-"DTRACK_CREATOR $(CFLAGS)"
ZMQ=yes
COMPILER=
CPP_COMPILER=
BUILD=$(SCONS) -j $(JOBS) ward=$(WARD) gc=$(GC) gmp=$(GMP) zmq=$(ZMQ) \
	gcblksize=$(GCBLKSIZE) gcmaxthreads=$(GCMAXTHREADS) \
	cflags=$(CFLAGS) compiler=$(COMPILER) cpp_compiler=$(CPP_COMPILER)
MPI_BUILD=$(SCONS) -j $(JOBS) ward=$(WARD) gc=$(MPI_GC) gmp=$(GMP) zmq=$(ZMQ) \
	cflags=$(CFLAGS) compiler=$(COMPILER) cpp_compiler=$(CPP_COMPILER)

all opt: $(WARD)/bin/ward
	$(BUILD) debug=0

mpidebug: $(WARD)/bin/ward
	$(MPI_BUILD) abi=64 mpi=$(MPIHOME) gc=boehm debug=1 $(DEBUG)

gapdebug: $(WARD)/bin/ward
	$(MPI_BUILD) debug=0 $(DEBUG) 

debug: $(WARD)/bin/ward
	$(BUILD) debug=1 $(DEBUG) 

opt32 32: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=32 

gapdebug32: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=32 $(DEBUG) 

debug32: $(WARD)/bin/ward
	$(BUILD) debug=1 abi=32 $(DEBUG) 

opt64 64: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=64 

gapdebug64: $(WARD)/bin/ward
	$(BUILD) debug=0 abi=64 $(DEBUG) 

debug64: $(WARD)/bin/ward
	$(BUILD) debug=1 abi=64 $(DEBUG) 

config:
	$(BUILD) config

config32:
	$(BUILD) abi=32 config

config64:
	$(BUILD) abi=64 config

mpi:
	@$(MPI_BUILD) abi=64 mpi=$(MPIHOME)


clean:
	$(SCONS) -c preprocess=dummy compiler=$(COMPILER)

distclean:
	-rm -rf bin/current/* build
	$(SCONS) -c preprocess=dummy compiler=$(COMPILER); rm -rf extern/lib/* extern/include/* extern/32bit extern/64bit bin/current/*

$(WARD)/bin/ward:
	@test -z "$(WARD)" || echo "Building Ward."
	@test -z "$(WARD)" || (cd $(WARD); sh build.sh >/dev/null 2>/dev/null)
	@test -z "$(WARD)" || echo "Ward build completed."

.PHONY: all opt gapdebug debug
.PHONY: opt32 32 gapdebug32 debug32
.PHONY: opt64 64 gapdebug64 debug64
.PHONY: clean distclean

# Copied from standard GAP makefile

TESTGAP=bin/gap-hpc.sh
TESTGAPauto=bin/gap-hpc.sh

manuals:
	( cd doc/ref; echo 'Read( "makedocrel.g" );' | \
          ../../$(TESTGAP) > make_manuals.out )
	( cd doc/tut; echo 'Read( "makedocrel.g" );' | \
          ../../$(TESTGAP) > make_manuals.out )
	( cd doc/changes; echo 'Read( "makedocrel.g" );' | \
          ../../$(TESTGAP) > make_manuals.out )          
	( cd doc/ref; echo 'Read( "makedocrel.g" );' | \
          ../../$(TESTGAP) > make_manuals.out )
	( cd doc/tut; echo 'Read( "makedocrel.g" );' | \
          ../../$(TESTGAP) > make_manuals.out )
	( cd doc/changes; echo 'Read( "makedocrel.g" );' | \
          ../../$(TESTGAP) > make_manuals.out )


testinstall:
	mkdir -p dev/log
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
	        ReadGapRoot( "tst/testutil.g" ); \
            ReadGapRoot( "tst/testinstall.g" );' | $(TESTGAP) > \
            `date -u +dev/log/testinstall1_%Y-%m-%d-%H-%M` )
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
	        ReadGapRoot( "tst/testutil.g" ); LoadAllPackages(); \
            ReadGapRoot( "tst/testinstall.g" );' | $(TESTGAP) > \
            `date -u +dev/log/testinstall2_%Y-%m-%d-%H-%M` )

teststandard:
	mkdir -p dev/log
	( echo 'ShowSystemInformation(); RunStandardTests( [' > test.tmp; \
          grep -h "STOP_TEST" tst/*.tst | sed -e 's/^gap> STOP_TEST(/[/;s/);/],/' >> test.tmp; \
          echo '] ); ' >> test.tmp )
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
	        ReadGapRoot( "tst/testutil.g" ); Read( "test.tmp" );' | $(TESTGAP) > \
            `date -u +dev/log/teststandard1_%Y-%m-%d-%H-%M` )
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
	        ReadGapRoot( "tst/testutil.g" ); LoadAllPackages(); Read( "test.tmp" );' | $(TESTGAP) > \
            `date -u +dev/log/teststandard2_%Y-%m-%d-%H-%M` )
	( rm test.tmp )

teststandardrenormalize:
	mkdir -p dev/log
	( echo 'RunStandardTests( [' > test.tmp; \
          grep -h "STOP_TEST" tst/*.tst | \
            sed -e 's/^gap> STOP_TEST(/[/;s/);/],/' >> test.tmp; \
          echo '], true ); ShowSystemInformation();' \
          >> test.tmp; \
          echo 'ReadGapRoot( "tst/testutil.g" ); Read( "test.tmp" ); \
            CreateTestinstallFile(); Runtime();' | $(TESTGAP) > \
            `date -u +dev/log/teststandardrenormalize_%Y-%m-%d-%H-%M` )
	( rm test.tmp )

testinstall.g:
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
            CreateTestinstallFile();' | $(TESTGAP) )            

testpackages:
	mkdir -p dev/log
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            CreatePackageTestsInput( "testpackages.in", \
            "dev/log/testpackages1", \
            "$(TESTGAP)", "false" );'\
            | $(TESTGAP) > /dev/null )
	( chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in )
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            CreatePackageTestsInput( "testpackages.in", \
            "dev/log/testpackagesA", \
            "$(TESTGAPauto)", "auto" );'\
            | $(TESTGAPauto) > /dev/null )
	( chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in )
	( echo 'SetAssertionLevel( 2 ); ReadGapRoot( "tst/testutil.g" ); \
            CreatePackageTestsInput( "testpackages.in", \
            "dev/log/testpackages2", \
            "$(TESTGAP)", "true" );'\
            | $(TESTGAP) > /dev/null )
	( chmod 777 testpackages.in; ./testpackages.in; rm testpackages.in )
	
testpackagesload:
	mkdir -p dev/log
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageLoadTestsInput( "testpackagesload.in", \
            "dev/log/testpackagesload1", \
            "$(TESTGAP)", false, false );'\
            | $(TESTGAP) > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesload1_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageLoadTestsInput( "testpackagesload.in", \
            "dev/log/testpackagesloadN1", \
            "$(TESTGAP)", false, true );'\
            | $(TESTGAP) > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesloadN1_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageLoadTestsInput( "testpackagesload.in", \
            "testpackagesloadA", \
            "$(TESTGAPauto)", true, false );'\
            | $(TESTGAPauto) > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesloadA_%Y-%m-%d-%H-%M`; rm testpackagesload.in )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageLoadTestsInput( "testpackagesload.in", \
            "testpackagesloadNA", \
            "$(TESTGAPauto)", true, true );'\
            | $(TESTGAPauto) > /dev/null )
	( chmod 777 testpackagesload.in; ./testpackagesload.in > \
            `date -u +dev/log/testpackagesloadNA_%Y-%m-%d-%H-%M`; rm testpackagesload.in )

testpackagesvars:
	mkdir -p dev/log
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageVarsTestsInput( "testpackagesvars.in", \
            "dev/log/testpackagesvars", \
            "$(TESTGAP)" );'\
            | $(TESTGAP) > /dev/null )
	( chmod 777 testpackagesvars.in; ./testpackagesvars.in > \
            `date -u +dev/log/testpackagesvars_%Y-%m-%d-%H-%M`; rm testpackagesvars.in )
	
testmanuals1:
	(cd doc/ref; ../../bin/gap.sh -r extractexamples.g runexamples.g)
	(cd doc/tut; ../../bin/gap.sh -r extractexamples.g runexamples.g)

testmanuals:
	mkdir -p dev/log
	((cd doc/tut ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ../../$(TESTGAP);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/tut/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/tut/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN TUTORIAL EXAMPLES (NO PACKAGES)"; fi ; \
	  echo '============================================================';\
	  cd doc/ref ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ../../$(TESTGAP);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/ref/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/ref/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN REFERENCE MANUAL EXAMPLES (NO PACKAGES)"; fi ) \
	  > `date -u +dev/log/testmanuals1_%Y-%m-%d-%H-%M` 2>&1 )
	( rm -rf doc/tut/EXAMPLEDIFFS*; rm -rf doc/ref/EXAMPLEDIFFS* )
	((cd doc/tut ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ../../$(TESTGAPauto);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/tut/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/tut/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN TUTORIAL EXAMPLES (DEFAULT PACKAGES)"; fi ; \
	  echo '============================================================';\
	  cd doc/ref ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ../../$(TESTGAPauto);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/ref/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/ref/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN REFERENCE MANUAL EXAMPLES (DEFAULT PACKAGES)"; fi ) \
	  > `date -u +dev/log/testmanualsA_%Y-%m-%d-%H-%M` 2>&1 )
	( rm -rf doc/tut/EXAMPLEDIFFS*; rm -rf doc/ref/EXAMPLEDIFFS* )
	((cd doc/tut ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  LoadAllPackages() ; \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ../../$(TESTGAP);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/tut/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/tut/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN TUTORIAL EXAMPLES (ALL PACKAGES)"; fi ; \
	  echo '============================================================';\
	  cd doc/ref ; \
	  echo 'SetUserPreference("UseColorsInTerminal",false); SetAssertionLevel( 2 ); \
	  LoadAllPackages() ; \
	  Read("extractexamples.g"); Read("runexamples.g"); ' | ../../$(TESTGAP);\
	  echo '============================================================';\
	  cd ../.. ; ff=`ls doc/ref/EXAMPLEDIFFS* 2> /dev/null | wc -l`; \
	  if [ $$ff != "0" ] ; then cat doc/ref/EXAMPLEDIFFS*; \
	  else echo "NO DIFFERENCES IN REFERENCE MANUAL EXAMPLES (ALL PACKAGES)"; fi ) \
	  > `date -u +dev/log/testmanuals2_%Y-%m-%d-%H-%M` 2>&1 )
	( rm -rf doc/tut/EXAMPLEDIFFS*; rm -rf doc/ref/EXAMPLEDIFFS* )

testupdates:
	mkdir -p dev/log
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
            ReadGapRoot( "tst/testutil.g" ); \
            SetAssertionLevel( 2 ); RunDevUpdateTests();' | $(TESTGAP) > \
            `date -u +dev/log/testupdates1_%Y-%m-%d-%H-%M` )
	( echo 'SetUserPreference("UseColorsInTerminal",false); \
            ReadGapRoot( "tst/testutil.g" ); LoadAllPackages(); \
            SetAssertionLevel( 2 ); RunDevUpdateTests();' | $(TESTGAP) > \
            `date -u +dev/log/testupdates2_%Y-%m-%d-%H-%M` )
            
testobsoletes:
	mkdir -p dev/log
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageLoadTestsInput( "testobsoletes1.in", \
            "dev/log/testobsoletes1", \
            "$(TESTGAP) -O", false, false );'\
            | $(TESTGAP) -O > /dev/null )
	( chmod 777 testobsoletes1.in; ./testobsoletes1.in > \
            `date -u +dev/log/testobsoletes1_%Y-%m-%d-%H-%M`; rm testobsoletes1.in )
	( echo 'ReadGapRoot( "tst/testutil.g" ); \
	    CreatePackageLoadTestsInput( "testobsoletesN1.in", \
            "dev/log/testobsoletesN1", \
            "$(TESTGAP) -O", false, true );'\
            | $(TESTGAP) -O > /dev/null )
	( chmod 777 testobsoletesN1.in; ./testobsoletesN1.in > \
            `date -u +dev/log/testobsoletesN1_%Y-%m-%d-%H-%M`; rm testobsoletesN1.in )
