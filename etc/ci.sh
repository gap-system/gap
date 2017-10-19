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
    $GAP $SRCDIR/tst/${TEST_SUITE}.g
    exit 0
fi

if [[ "${TEST_SUITE}" == testspecial ]]
then
    cd $SRCDIR/tst/test-error
    ./run_error_tests.sh
    cd ../test-compile
    ./run_compile_tests.sh
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

# HACK: io 4.4.6 (shipped with GAP 4.8.6) directly accesses some GAP internals
# (for GASMAN), which we will remove in GAP 4.9. To ensure it works,
# we simply grab the latest version from git.
rm -rf io*
git clone https://github.com/gap-packages/io
cd io
./autogen.sh
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

if [[ "${TEST_SUITE}" == testpackages ]]
then
    # skip carat because building it leads to too much output which floods the log
    rm -rf carat*
    # skip linboxing because it hasn't compiled for years
    rm -rf linboxing*
    # skip pargap: no MPI present (though we could fix that), and it currently does not
    # build with the GAP master branch
    rm -rf pargap*
    # skip PolymakeInterface: no polynmake installed (TODO: is there a polymake package we can use)
    rm -rf PolymakeInterface*
    # HACK to work out timestamp issues with anupq
    touch anupq*/configure* anupq*/Makefile* anupq*/aclocal.m4
    # HACK to prevent float from complaining about missing C-XSC (not available in Ubuntu)
    # and fplll (float 0.7.5 is not compatible with fplll 4.0)
    perl -pi -e 's;CXSC=yes;CXSC=no;' float*/configure
    perl -pi -e 's;CXSC=extern;CXSC=no;' float*/configure
    perl -pi -e 's;FPLLL=yes;FPLLL=no;' float*/configure
    perl -pi -e 's;FPLLL=extern;FPLLL=no;' float*/configure

    if [[ x"$ABI" == "x32" ]]
    then
      # HACK: disable NormalizInterface in 32bit mode for now. Version
      # 0.9.8 doesn't make it easy to support 32bit. With the next
      # release of the package, this will hopefully change.
      rm -rf NormalizInterface-0.9.8
    fi

    $SRCDIR/bin/BuildPackages.sh --with-gaproot=$BUILDDIR
    if [[ "$(wc -l < log/fail.log)" -ge 3 ]]
    then
        echo "Some packages failed to build:"
        cat "log/fail.log"
        exit 1
    else
        echo "All packages were built succesfully"
    fi

    # TODO: actually run package tests

    exit 0
fi


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
makemanuals)
    make doc
    ;;

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
