#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

SRCDIR=${SRCDIR:-$PWD}

# Make sure any Error() immediately exits GAP with exit code 1.
GAP="bin/gap.sh --quitonbreak -q"

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

# If we don't care about code coverage, just run the test directly
if [[ -n ${NO_COVERAGE} ]]
then
    if [[ $HPCGAP = yes ]]
    then
        # FIXME/HACK: some tests currently hang for HPC-GAP, so we skip them for now
        echo "Skipping tests for HPC-GAP"
    else
        $GAP $SRCDIR/tst/${TEST_SUITE}.g
    fi
    exit 0
fi

if [[ "${TEST_SUITE}" == makemanuals ]]
then
    make doc
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
  # Add flags so that Boehm GC and libatomic headers are found
  CPPFLAGS="-I$PWD/extern/install/gc/include -I$PWD/extern/install/libatomic_ops/include $CPPFLAGS"
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
cd ..

# Compile edim to test gac (but not on HPC-GAP and not on Cygwin, where gac is known to be broken)
if [[ $HPCGAP != yes && $OSTYPE = Cygwin* ]]
then
    cd edim
    ./configure $BUILDDIR
    make
    cd ..
fi

# return to base directory
popd



# create dir for coverage results
COVDIR=coverage
mkdir -p $COVDIR


# run gap compiler to verify the src/c_*.c files are up to date,
# and also get coverage on the compiler
make docomp

# detect if there are any diffs
git diff --exit-code -- src hpcgap/src


case ${TEST_SUITE} in
testmanuals)
    $GAP $SRCDIR/tst/extractmanuals.g

    $GAP <<GAPInput
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
    $GAP --cover $COVDIR/workspace.coverage <<GAPInput
        SetUserPreference("ReproducibleBehaviour", true);
        SaveWorkspace("test.wsp");
        QUIT_GAP(0);
GAPInput

    ;;
*)
    if [[ ! -f  $SRCDIR/tst/${TEST_SUITE}.g ]]
    then
        echo "Could not read test suite $SRCDIR/tst/${TEST_SUITE}.g"
        exit 1
    fi


    $GAP --cover $COVDIR/${TEST_SUITE}.coverage \
            <(echo 'SetUserPreference("ReproducibleBehaviour", true);') \
            $SRCDIR/tst/${TEST_SUITE}.g
esac;
