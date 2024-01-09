#!/usr/bin/env bash

# Continuous integration testing script

# It can also be run manually, to simulate locally what happens in the
# CI environment (say, for debugging purposes). For example:
#
#    dev/ci.sh testinstall
#
# run just the 'testinstall' testsuite

set -E # inherit -e
set -e # exit immediately on errors
set -o pipefail # exit on pipe failure

SRCDIR=${SRCDIR:-$PWD}

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

GAP=${GAP:-$BUILDDIR/gap}

# Make sure any Error() immediately exits GAP with exit code 1.
GAP="$GAP --quitonbreak"

# create dir for coverage results unless coverage is disabled
COVDIR=${COVDIR:-coverage}

######################################################################
#
# Various little helper functions

# is output going to a terminal?
if test -t 1; then

    # does the terminal support color?
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

notice() {
    printf "${green}%s${normal}\n" "$*"
}

warning() {
    printf "${yellow}WARNING: %s${normal}\n" "$*"
}

error() {
    printf "${red}ERROR: %s${normal}\n" "$*" 1>&2
    exit 1
}

echo_and_run () {
    cmd="$1" ; shift
    echo "$cmd" "$@"
    "$cmd" "$@"
}

# helper function to generate `--cover` arguments for GAP invocations
# but only if coverage tracking is enabled (= "not disabled")
gap_cover_arg () {
  if [[ -z ${NO_COVERAGE} ]]
  then
    extra=${extra:+-$extra}
    mkdir -p $COVDIR
    echo "--cover $COVDIR/${TEST_SUITE}${extra}.coverage"
  fi
}

#
testmockpkg () {
    # Try building and loading the mockpkg kernel extension
    gap="$1"
    gaproot="$2"
    mockpkg_dir="$PWD"

    echo_and_run ./configure "$gaproot"
    echo_and_run make V=1
    # trick to make it easy to load the package in GAP
    rm -f pkg && ln -sf . pkg
    # try to load the kernel extension
    cd "$gaproot"
    echo_and_run $gap -A -l "$mockpkg_dir;" "$mockpkg_dir/tst/testall.g"
}


for TEST_SUITE in "$@"
do
  # restore current directory before each test suite
  cd "$BUILDDIR"

  echo "${blue}"
  echo "+-------------------------------------------"
  echo "|"
  echo "| Running test suite $TEST_SUITE"
  echo "|"
  echo "+-------------------------------------------"
  echo "${normal}"
  case $TEST_SUITE in
  testspecial | test-compile)
    cd $SRCDIR/tst/$TEST_SUITE
    GAPDIR=$BUILDDIR ./run_all.sh
    ;;

  testpackages)
    cd $SRCDIR/pkg

    # skip PolymakeInterface: no polymake installed (TODO: is there a polymake package we can use?)
    rm -rf PolymakeInterface*
    # skip xgap: no X11 headers, and no means to test it
    rm -rf xgap*
    # skip itc because it requires xgap
    rm -rf itc*

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
            SetInfoLevel(InfoPackageLoading, PACKAGE_DEBUG);
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

    set -x

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
    fgrep "bool.c.d:" ${bool_d} > /dev/null && exit 1
    fgrep "garbage content" ${bool_lo} > /dev/null && exit 1

    # verify our "garbage" files are still there
    test -f $SRCDIR/${bool_d}
    test -f $SRCDIR/${bool_lo}

    # test: `make` should regenerate removed *.lo files
    rm ${bool_lo}
    make > /dev/null 2>&1
    test -f ${bool_lo}

    # verify that deps file has a target for the .lo file but not for the .d file
    fgrep "bool.c.lo:" ${bool_d} > /dev/null
    fgrep "bool.c.d:" ${bool_d} > /dev/null && exit 1
    fgrep "garbage content" ${bool_lo} > /dev/null && exit 1

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
    fgrep "bool.c.d:" ${bool_d} > /dev/null && exit 1
    fgrep "garbage content" ${bool_lo} > /dev/null && exit 1

    # test: running `make` a second time should produce no output
    test -z "$(make)"

    # audit config.h
    $SRCDIR/dev/audit-config-h.sh

    # test: touching all source files does *not* trigger a rebuild if we make
    # a target that doesn't depend on sources. We verify this by replacing the source
    # code with garbage
    mv $SRCDIR/src/bool.h book.h.bak
    echo "garbage content 4" > $SRCDIR/src/bool.h
    make print-OBJS  # should print something but not error out
    mv book.h.bak $SRCDIR/src/bool.h

    set +x

    ;;

  makemanuals)
    make doc
    make check-manuals
    ;;

  testmakeinstall)
    # get the install prefix from the GAP build system
    eval $(make print-prefix)
    GAPPREFIX=$prefix

    # verify $GAPPREFIX does not yet exist
    test ! -d $GAPPREFIX

    # perform he installation
    make install

    # verify $GAPPREFIX now exists
    test -d $GAPPREFIX

    # verify `make install DESTDIR=...` produces identical content, just
    # in a different directory
    make install DESTDIR=/tmp/DESTDIR
    diff -ru /tmp/DESTDIR/$GAPPREFIX $GAPPREFIX

    # change directory to prevent the installed GAP from accidentally picking
    # up files from the GAP source resp. build directory (wherever we are
    # right now)
    cd /

    # test for the presence of bunch of important files
    test -f $GAPPREFIX/bin/gap
    test -f $GAPPREFIX/bin/gac
    test -f $GAPPREFIX/include/gap/gap_all.h
    test -f $GAPPREFIX/include/gap/version.h
    test -f $GAPPREFIX/lib/gap/sysinfo.gap
    test -f $GAPPREFIX/lib/pkgconfig/libgap.pc
    test -f $GAPPREFIX/share/gap/doc/ref/chap0_mj.html
    test -f $GAPPREFIX/share/gap/grp/basic.gd
    test -f $GAPPREFIX/share/gap/hpcgap/lib/hpc/tasks.g
    test -f $GAPPREFIX/share/gap/lib/init.g

    # verify that there are no references to the build, source or home
    # directories after stripping gap and libgap
    strip $GAPPREFIX/bin/gap > /dev/null
    strip $GAPPREFIX/lib/gap/gap > /dev/null
    strip $GAPPREFIX/lib/libgap.so > /dev/null 2>&1 || :      # for Linux
    strip -S $GAPPREFIX/lib/libgap.dylib > /dev/null 2>&1 || :   # for macOS
    fgrep -r $BUILDDIR $GAPPREFIX && exit 1
    fgrep -r $SRCDIR $GAPPREFIX && exit 1
    fgrep -r $HOME $GAPPREFIX && exit 1

    # HACK: symlink packages so we can start GAP
    ln -s $SRCDIR/pkg $GAPPREFIX/share/gap/pkg

    # test building and loading package kernel extension
    cd "$SRCDIR/tst/mockpkg"
    testmockpkg "$GAPPREFIX/bin/gap" "$GAPPREFIX/lib/gap"

    # run testinstall for the resulting GAP
    $GAPPREFIX/bin/gap --quitonbreak -l ";$SRCDIR" $SRCDIR/tst/testinstall.g

    # test integration with pkg-config
    cd "$SRCDIR"
    # make install # might be actually needed for testpkgconfigbuild
    make testpkgconfigversion
    make testpkgconfigbuild
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
        $GAP -b -L testmanuals.wsp $(gap_cover_arg $(basename $ch)) <<GAPInput || TESTMANUALSPASS=no
        TestManualChapter("$ch");
        QuitGap(0);
GAPInput
    done

    # if there were any failures, abort now.
    [[ $TESTMANUALSPASS = yes ]] || error "reference manual tests failed"

    # while we are at it, also test the workspace code
    $GAP -A $(gap_cover_arg workspace) <<GAPInput
        SetUserPreference("ReproducibleBehaviour", true);
        # Also test a package banner
        LoadPackage("polycyclic");
        SaveWorkspace("test.wsp");
        QuitGap(0);
GAPInput

    ;;

  testlibgap)
    make V=1 testlibgap
    ;;

  testkernel)
    make V=1 testkernel
    ;;

  testmockpkg)
    # for debugging it is useful to know what sysinfo.gap contains at this point
    echo "Content of sysinfo.gap:"
    echo "${blue}---- BEGIN sysinfo.gap ----${normal}"
    cat "$BUILDDIR/sysinfo.gap"
    echo "${blue}---- END sysinfo.gap ----${normal}"

    # test building and loading a package kernel extension
    cd "$SRCDIR/tst/mockpkg"
    testmockpkg "$GAP $(gap_cover_arg)" "$BUILDDIR"
    ;;

  testexpect)
    INPUTRC=/tmp/inputrc expect -c "spawn $GAP -A -b $(gap_cover_arg 1)" $SRCDIR/dev/gaptest.expect
    INPUTRC=/tmp/inputrc expect -c "spawn $GAP -A -b $(gap_cover_arg 2) -l missing-dir" $SRCDIR/dev/gaptest2.expect
    ;;

  *)
    if [[ ! -f  $SRCDIR/tst/${TEST_SUITE}.g ]]
    then
        error "Could not read test suite $SRCDIR/tst/${TEST_SUITE}.g"
    fi

    if [[ -n ${NO_COVERAGE} ]]
    then
        $GAP $SRCDIR/tst/${TEST_SUITE}.g
    else
        $GAP $(gap_cover_arg) \
            <(echo 'SetUserPreference("ReproducibleBehaviour", true);') \
            $SRCDIR/tst/${TEST_SUITE}.g
    fi
    ;;
  esac

  notice "Test suite ${TEST_SUITE} passed"
done

exit 0
