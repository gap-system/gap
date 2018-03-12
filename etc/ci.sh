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

    # HACK: skip building semigroups-3.x for now -- it requires GCC >= 5, which Travis doesn't have
    rm -rf semigroups-3.*

    if [[ x"$ABI" == "x32" ]]
    then
      # HACK: disable NormalizInterface in 32bit mode for now. Version
      # 0.9.8 doesn't make it easy to support 32bit. With the next
      # release of the package, this will hopefully change.
      rm -rf NormalizInterface-0.9.8
    fi

    if ! "$SRCDIR/bin/BuildPackages.sh" --strict --with-gaproot="$BUILDDIR"
    then
        echo "Some packages failed to build:"
        cat "log/fail.log"
        exit 1
    else
        echo "All packages were built succesfully"

        #
        # Now that we built packages, we try to load them.
        # For this, we need to skip a few additional packages which cannot
        # be loaded in the test environment.
        #
        # skip xgap as it can only be loaded in a GAP session started via
        # special helper script, *and* it requires X Window
        rm -rf xgap*
        # also skip itc because it requires xgap
        rm -rf itc*

        if [[ x"$ABI" != "x32" ]]
        then
          # HACK: disable some packages in 64bit mode for now. Otherwise they
          # builds, but loading fails with an "undefined symbol: atexit" error
          rm -rf digraphs*
          rm -rf float*
        fi

        cd ..
        # Load GAP (without packages) and save workspace to speed up test.
        # Also, save names of all packages into a file to be able to iterate over them
        $GAP -b <<GAPInput
        SaveWorkspace("testpackagesload.wsp");
        PrintTo("packagenames", JoinStringsWithSeparator( SortedList(RecNames( GAPInfo.PackagesInfo )),"\n") );
        QUIT_GAP(0);
GAPInput
        for pkg in $(cat packagenames)
        do
            $GAP -q -L testpackagesload.wsp <<GAPInput
            Print("-----------------------------------------------------\n");
            Print("Loading $pkg ... \n");
            if LoadPackage("$pkg",false) = true then
              Print("PASS: $pkg\n\n");
            else
              Print("FAIL: $pkg\n\n");
              AppendTo("fail.log", "Loading failed : ", "$pkg", "\n");
            fi;
GAPInput

        done

        if [[ -f fail.log ]]
        then
            echo "Some packages failed to load:"
            cat fail.log
            exit 1
        fi

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
        $GAP -b -L testmanuals.wsp --cover $COVDIR/$(basename $ch).coverage <<GAPInput || TESTMANUALSPASS=no
        TestManualChapter("$ch");
        QUIT_GAP(0);
GAPInput
    done

    # if there were any failures, abort now.
    [[ $TESTMANUALSPASS = yes ]] || exit 1

    # while we are at it, also test the workspace code
    $GAP -A --cover $COVDIR/workspace.coverage <<GAPInput
        SetUserPreference("ReproducibleBehaviour", true);
        # Also test a package banner
        LoadPackage("polycyclic");
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
