#!/usr/bin/env bash

# Continous integration testing script

# It can also be run manually, to simulate locally what happens in the
# CI environment (say, for debugging purposes).

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

  echo "Running test suite $TEST_SUITE"
  case $TEST_SUITE in
  testspecial | test-compile)
    cd $SRCDIR/tst/$TEST_SUITE
    GAPDIR=$BUILDDIR ./run_all.sh
    ;;

  testpackages)
    cd $SRCDIR/pkg

    # skip PolymakeInterface: no polynmake installed (TODO: is there a polymake package we can use)
    rm -rf PolymakeInterface*
    # skip xgap: no X11 headers, and no means to test it
    rm -rf xgap*
    # skip itc because it requires xgap
    rm -rf itc*

    # HACK to work out timestamp issues with anupq
    touch anupq*/configure* anupq*/Makefile* anupq*/aclocal.m4

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
        echo "All packages were built successfully"

        cd ..
        # Load GAP (without packages) and save workspace to speed up test.
        # Also, save names of all packages into a file to be able to iterate over them
        $GAP -b <<GAPInput
        SaveWorkspace("testpackagesload.wsp");
        PrintTo("packagenames", JoinStringsWithSeparator( SortedList(RecNames( GAPInfo.PackagesInfo )),"\n") );
        QuitGap(0);
GAPInput
        for pkg in $(cat packagenames)
        do
            $GAP -q -L testpackagesload.wsp <<GAPInput
            Print("-----------------------------------------------------\n");
            Print("Loading $pkg ... \n");
            if LoadPackage("$pkg",false) = true then
              Print(TextAttr.2, "PASS: $pkg\n\n", TextAttr.reset);
            else
              Print(TextAttr.1, "FAIL: $pkg\n\n", TextAttr.reset);
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

  testbuildsys)
    # use parallel make if possible to speed up things a bit
    export MAKEFLAGS="${MAKEFLAGS:--j3}"

    # in case we change file locations again...
    bool_d=build/deps/src/bool.c.d
    bool_lo=build/obj/src/bool.c.lo

    # this test assumes we are doing an out-of-tree build
    test $BUILDDIR != $SRCDIR

    # test: create garbage *.d and *.lo files in the source dir; these should not
    # affect the out of tree build, nor should they be removed by `make clean`
    mkdir -p $SRCDIR/build/deps/src
    mkdir -p $SRCDIR/build/obj/src
    echo "garbage content 1" > $SRCDIR/${bool_d}
    echo "garbage content 2" > $SRCDIR/${bool_lo}
    echo "garbage content 3" > $SRCDIR/build/version.c

    # test: `make clean` works and afterwards we can still `make`; in particular
    # build/config.h must be regenerated before any actual compilation
    make clean
    make > /dev/null 2>&1

    # verify that deps file has a target for the .lo file but not for the .d file
    fgrep "bool.c.lo:" ${bool_d} > /dev/null
    ! fgrep "bool.c.d:" ${bool_d} > /dev/null
    ! fgrep "garbage content" ${bool_lo} > /dev/null

    # verify our "garbage" files are still there
    test -f $SRCDIR/${bool_d}
    test -f $SRCDIR/${bool_lo}

    # test: `make` should regenerate removed *.lo files
    rm ${bool_lo}
    make > /dev/null 2>&1
    test -f ${bool_lo}

    # verify that deps file has a target for the .lo file but not for the .d file
    fgrep "bool.c.lo:" ${bool_d} > /dev/null
    ! fgrep "bool.c.d:" ${bool_d} > /dev/null
    ! fgrep "garbage content" ${bool_lo} > /dev/null

    # test: `make` should regenerate removed *.d files (and then also regenerate the
    # corresponding *.lo file, which we verify by overwriting it with garbage)
    # NOTE: This check was disabled and the corresponding code removed from the
    # build system, as sadly it caused all kinds of issues which were far more
    # annoying than the fringe problem they fixed. If we ever come up with a better
    # implementation for this, the test below can be re-enabled
    #rm ${bool_d}
    #echo "garbage content 3" > ${bool_lo}
    #make > /dev/null 2>&1
    #test -f ${bool_d}

    # verify that deps file has a target for the .lo file but not for the .d file
    fgrep "bool.c.lo:" ${bool_d} > /dev/null
    ! fgrep "bool.c.d:" ${bool_d} > /dev/null
    ! fgrep "garbage content" ${bool_lo} > /dev/null

    # test: running `make` a second time should produce no output
    test -z "$(make)"

    # audit config.h
    pushd $SRCDIR
    dev/audit-config-h.sh
    popd

    # test: touching all source files does *not* trigger a rebuild if we make
    # a target that doesn't depend on sources. We verify this by replacing the source
    # code with garbage
    mv $SRCDIR/src/bool.h book.h.bak
    echo "garbage content 4" > $SRCDIR/src/bool.h
    make print-OBJS  # should print something but not error out
    mv book.h.bak $SRCDIR/src/bool.h

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
        QuitGap(0);
GAPInput

    TESTMANUALSPASS=yes
    for ch in $SRCDIR/tst/testmanuals/*.tst
    do
        $GAP -b -L testmanuals.wsp --cover $COVDIR/$(basename $ch).coverage <<GAPInput || TESTMANUALSPASS=no
        TestManualChapter("$ch");
        QuitGap(0);
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
        QuitGap(0);
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
