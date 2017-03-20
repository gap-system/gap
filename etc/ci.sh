#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

GAPROOT=${GAPROOT:-$PWD}
BUILDDIR=${BUILDDIR:-.}

cd $BUILDDIR

# Load gap-init.g when starting GAP to ensure that any Error() immediately exits
# GAP with exit code 1.
echo 'OnBreak:=function() Print("FATAL ERROR\n"); FORCE_QUIT_GAP(1); end;;' > gap-init.g

# If we don't care about code coverage, just run the test directly
if [[ -n ${NO_COVERAGE} ]]
then
    bin/gap.sh gap-init.g $GAPROOT/tst/${TEST_SUITE}.g
    exit 0
fi

if [[ "${TEST_SUITE}" == makemanuals ]]
then
    make manuals
    cat  $GAPROOT/doc/*/make_manuals.out
    if [[ $(cat  $GAPROOT/doc/*/make_manuals.out | grep -c "manual.lab written") != '3' ]]
    then
        echo "Build failed"
        exit 1
    fi
    exit 0
fi

if [[ "${TEST_SUITE}" == testerror ]]
then
    cd $GAPROOT/tst/test-error
    ./run_error_tests.sh
    exit 0
fi

if [[ x"$ABI" == "x32" ]]
then
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi

if [[ $HPCGAP = yes ]]
then
  # Add flags so that Boehm GC and libatomic headers are found, as well as HPC-GAP headers
  CPPFLAGS="-I$PWD/extern/install/gc/include -I$PWD/extern/install/libatomic_ops/include $CPPFLAGS"
  CPPFLAGS="-I$GAPROOT/hpcgap -I$GAPROOT $CPPFLAGS"
  export CPPFLAGS
fi

# We need to compile the profiling package in order to generate coverage
# reports; and also the IO package, as the profiling package depends on it.
pushd $GAPROOT/pkg

cd io*
./configure $CONFIGFLAGS --with-gaproot=$GAPROOT/$BUILDDIR
make V=1
cd ..

# HACK: profiling 1.1.0 (shipped with GAP 4.8.6) is broken on 32 bit
# systems, so we simply grab the latest profiling version
rm -rf profiling*
git clone https://github.com/gap-packages/profiling
cd profiling
./autogen.sh
./configure $CONFIGFLAGS --with-gaproot=$GAPROOT/$BUILDDIR
make V=1

# return to base directory
popd

# create dir for coverage results
COVDIR=coverage
mkdir -p $COVDIR

case ${TEST_SUITE} in
testmanuals)
    bin/gap.sh -q gap-init.g $GAPROOT/tst/extractmanuals.g

    bin/gap.sh -q gap-init.g <<GAPInput
        SetUserPreference("ReproducibleBehaviour", true);
        Read("$GAPROOT/tst/testmanuals.g");
        SaveWorkspace("testmanuals.wsp");
        QUIT_GAP(0);
GAPInput

    TESTMANUALSPASS=yes
    for ch in $GAPROOT/tst/testmanuals/*.tst
    do
        bin/gap.sh -q -L testmanuals.wsp --cover $COVDIR/$(basename $ch).coverage <<GAPInput || TESTMANUALSPASS=no
        TestManualChapter("$ch");
        QUIT_GAP(0);
GAPInput
    done
    
    if [[ $TESTMANUALSPASS = no ]]
    then
        exit 1
    fi

    # while we are at it, also test the workspace code
    bin/gap.sh -q --cover $COVDIR/workspace.coverage gap-init.g <<GAPInput
        SetUserPreference("ReproducibleBehaviour", true);
        SaveWorkspace("test.wsp");
        QUIT_GAP(0);
GAPInput

    # run gap compiler to verify the src/c_*.c files are up-todate,
    # and also get coverage on the compiler
    make docomp

    # detect if there are any diffs
    git diff --exit-code

    ;;
*)
    if [[ ! -f  $GAPROOT/tst/${TEST_SUITE}.g ]]
    then
        echo "Could not read test suite $GAPROOT/tst/${TEST_SUITE}.g"
        exit 1
    fi

    bin/gap.sh --cover $COVDIR/${TEST_SUITE}.coverage gap-init.g \
               <(echo 'SetUserPreference("ReproducibleBehaviour", true);') \
               $GAPROOT/tst/${TEST_SUITE}.g
esac;

# generate library coverage reports
bin/gap.sh -a 500M -q gap-init.g <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;
d := Directory("$COVDIR");;
covs := [];;
for f in DirectoryContents(d) do
    if f in [".", ".."] then continue; fi;
    Add(covs, Filename(d, f));
od;
Print("Merging coverage results\n");
r := MergeLineByLineProfiles(covs);;
Print("Outputting JSON\n");
OutputJsonCoverage(r, "gap-coverage.json");;
QUIT_GAP(0);
GAPInput

# generate kernel coverage reports by running gcov
. sysinfo.gap
cd bin/${GAParch}
gcov -o . ../../src/*
cd ../..
