#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

SRCDIR=${SRCDIR:-$PWD}

# Make sure any Error() immediately exits GAP with exit code 1.
GAP="bin/gap.sh --quitonbreak"

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

# create dir for coverage results
COVDIR=coverage
mkdir -p $COVDIR


# Compile edim, if present, to test gac (but not on HPC-GAP and not on Cygwin,
# where gac is known to be broken)
if [[ -d $SRCDIR/pkg/edim && $HPCGAP != yes && $OSTYPE = Cygwin* ]]
then
  pushd $SRCDIR/pkg/edim
  ./configure $BUILDDIR
  make
  popd
fi


for TEST_SUITE in $TEST_SUITES
do
  case $TEST_SUITE in
  testspecial)
    cd $SRCDIR/tst/test-error
    GAPDIR=$BUILDDIR ./run_error_tests.sh
    cd ../test-compile
    GAPDIR=$BUILDDIR ./run_all.sh
    exit 0
    ;;

  testpackages)
    cd $SRCDIR/pkg

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
    ;;

  docomp)
    # run gap compiler to verify the src/c_*.c files are up to date,
    # and also get coverage on the compiler
    make docomp

    # detect if there are any diffs
    git diff --exit-code -- src hpcgap/src
    ;;

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

    # if there were any failures, abort now.
    [[ $TESTMANUALSPASS = yes ]] || exit 1

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

    if [[ -n ${NO_COVERAGE} ]]
    then
        $GAP $SRCDIR/tst/${TEST_SUITE}.g
    else
        $GAP --cover $COVDIR/${TEST_SUITE}.coverage \
            <(echo 'SetUserPreference("ReproducibleBehaviour", true);') \
            $SRCDIR/tst/${TEST_SUITE}.g
    fi
    ;;
  esac
done
