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


for TEST_SUITE in $TEST_SUITES
do
  # restore current directory before each test suite
  cd "$BUILDDIR"

  case $TEST_SUITE in
  testspecial | test-compile)
    cd $SRCDIR/tst/$TEST_SUITE
    GAPDIR=$BUILDDIR ./run_all.sh
    ;;

  testpackages)
    cd $SRCDIR/pkg

    # skip linboxing because it hasn't compiled for years
    rm -rf linboxing*
    # skip pargap: no MPI present (though we could fix that), and it currently does not
    # build with the GAP master branch
    rm -rf pargap*
    # skip PolymakeInterface: no polynmake installed (TODO: is there a polymake package we can use)
    rm -rf PolymakeInterface*
    # skip xgap: no X11 headers, and no means to test it
    rm -rf xgap*

    # HACK to work out timestamp issues with anupq
    touch anupq*/configure* anupq*/Makefile* anupq*/aclocal.m4

    # HACK: workaround GMP 5 bug causing "error: '::max_align_t' has not been declared",
    # see <https://gcc.gnu.org/gcc-4.9/porting_to.html>
    printf "%s\n" 1 i "#include <stddef.h>" . w | ed float*/src/mp_poly.C

    # reset CFLAGS, CXXFLAGS, LDFLAGS before compiling packages, to prevent
    # them from being compiled with coverage gathering, because
    # otherwise gcov may confuse IO's src/io.c, or anupq's src/read.c,
    # with GAP kernel files with the same name
    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
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
    ;;

  docomp)
    # run gap compiler to verify the src/c_*.c files are up to date,
    # and also get coverage on the compiler
    make docomp

    # detect if there are any diffs
    git diff --exit-code -- src
    ;;

  testbuildsys)
    # this test assumes we are doing an out-of-tree build
    test $BUILDDIR != $SRCDIR

    # test: create garbage *.d and *.lo files in the source dir; these should not
    # affect the out of tree build, nor should they be removed by `make clean`
    mkdir -p $SRCDIR/build/deps/src
    mkdir -p $SRCDIR/build/obj/src
    echo "garbage content !!!" > $SRCDIR/build/deps/src/bool.c.d
    echo "garbage content !!!" > $SRCDIR/build/obj/src/bool.c.lo

    # test: `make clean` works and afterwards we can still `make`
    make clean
    make

    # verify our "garbage" files are still there
    test -f $SRCDIR/build/deps/src/bool.c.d
    test -f $SRCDIR/build/obj/src/bool.c.lo

    # test: `make` should regenerate removed *.d files (and then also regenerate the
    # corresponding *.lo file, which we verify by overwriting it with garbage)
    rm build/deps/src/bool.c.d
    echo "garbage content !!!" > build/obj/src/bool.c.lo
    make
    test -f build/deps/src/bool.c.d

    # test: running `make` a second time should produce no output
    test -z "$(make)"
    ;;

  makemanuals)
    make doc
    make check-manuals
    ;;

  testmanuals)
    # Start GAP with -O option to disable obsoletes. The test
    # will fail if there will be an error message, but warnings
    # should be checked manually in the test log. Since some
    # packages may still use obsoletes, we use -A option.
    $GAP -O -A $SRCDIR/tst/extractmanuals.g

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

  testlibgap)
    make testlibgap
    ;;

  testkernel)
    make testkernel
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

exit 0
