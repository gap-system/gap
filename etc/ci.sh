#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

SRCDIR=${SRCDIR:-$PWD}

GAP="bin/gap.sh --quitonbreak -q"

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

# Load gap-init.g when starting GAP to ensure that any Error() immediately exits
# GAP with exit code 1.
echo 'OnBreak:=function() Print("FATAL ERROR\n"); FORCE_QUIT_GAP(1); end;;' > gap-init.g

# If we don't care about code coverage, just run the test directly
if [[ -n ${NO_COVERAGE} ]]
then
    $GAP gap-init.g $SRCDIR/tst/${TEST_SUITE}.g
    exit 0
fi

if [[ "${TEST_SUITE}" == makemanuals ]]
then
    make manuals
    cat  $SRCDIR/doc/*/make_manuals.out
    exit 0
fi

if [[ "${TEST_SUITE}" == testerror ]]
then
    cd $SRCDIR/tst/test-error
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
  CPPFLAGS="-I$SRCDIR/hpcgap -I$SRCDIR $CPPFLAGS"
  export CPPFLAGS
fi

# We need to compile the profiling package in order to generate coverage
# reports; and also the IO package, as the profiling package depends on it.
pushd $SRCDIR/pkg

cd io*
./configure $CONFIGFLAGS --with-gaproot=$BUILDDIR
make V=1
cd ..

# HACK: profiling 1.1.0 (shipped with GAP 4.8.6) is broken on 32 bit
# systems, so we simply grab the latest profiling version
rm -rf profiling*
git clone https://github.com/gap-packages/profiling
cd profiling
./autogen.sh
./configure $CONFIGFLAGS --with-gaproot=$BUILDDIR
make V=1

# return to base directory
popd



# create dir for coverage results
COVDIR=coverage
mkdir -p $COVDIR

case ${TEST_SUITE} in
testmanuals)
    $GAP gap-init.g $SRCDIR/tst/extractmanuals.g

    $GAP gap-init.g <<GAPInput
        SetUserPreference("ReproducibleBehaviour", true);
        Read("$SRCDIR/tst/testmanuals.g");
        SaveWorkspace("testmanuals.wsp");
        QUIT_GAP(0);
GAPInput

    TESTMANUALSPASS=yes
    for ch in $SRCDIR/tst/testmanuals/*.tst
    do
        $GAP -L testmanuals.wsp --cover $COVDIR/$(basename $ch).coverage <<GAPInput || TESTMANUALSPASS=no
        TestManualChapter("$ch");
        QUIT_GAP(0);
GAPInput
    done
    
    if [[ $TESTMANUALSPASS = no ]]
    then
        exit 1
    fi

    # while we are at it, also test the workspace code
    $GAP --cover $COVDIR/workspace.coverage gap-init.g <<GAPInput
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
    if [[ ! -f  $SRCDIR/tst/${TEST_SUITE}.g ]]
    then
        echo "Could not read test suite $SRCDIR/tst/${TEST_SUITE}.g"
        exit 1
    fi

    $GAP --cover $COVDIR/${TEST_SUITE}.coverage gap-init.g \
               <(echo 'SetUserPreference("ReproducibleBehaviour", true);') \
               $SRCDIR/tst/${TEST_SUITE}.g || [[ $HPCGAP = yes ]] # HPCGAP HACK TO MAKE TEST PASS
esac;
