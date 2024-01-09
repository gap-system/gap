#!/usr/bin/env bash

# Continuous integration testing script

# It can also be run manually, to simulate locally what happens in the
# CI environment (say, for debugging purposes).

set -ex

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

    ./configure "$gaproot"
    make V=1
    # trick to make it easy to load the package in GAP
    rm -f pkg && ln -sf . pkg
    # try to load the kernel extension
    cd "$gaproot"
    $gap -A -l "$mockpkg_dir;" "$mockpkg_dir/tst/testall.g"
}


for TEST_SUITE in "$@"
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

    # HACK/WORKAROUND: excise `-march=native` from some configure
    # scripts by replacing it with `-g0` ; we do it this way to simplify
    # the patching process (we don't want to use an actual patchh file
    # that may need to be updated for every new release of the affected
    # packages'), while ensuring the patched shell scripts keep working;
    # as an added bonus, the `-g0` helps ensure that any existing ccache
    # entries for those files are invalidated.
    perl -pi -e 's;-march=native;-g0;' [Dd]igraphs*/configure [Ss]emigroups*/configure [Ss]emigroups*/libsemigroups/configure

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

    ;;

  makemanuals)
    make doc
    make check-manuals
    ;;

  testmakeinstall)
    # at this point GAPPREFIX should be set
    test -n $GAPPREFIX  || (echo "GAPPREFIX must be set" ; exit 1)

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
    strip $GAPPREFIX/lib/libgap.so > /dev/null
    fgrep -r $BUILDDIR $GAPPREFIX && exit 1
    fgrep -r $SRCDIR $GAPPREFIX && exit 1
    fgrep -r $HOME $GAPPREFIX && exit 1

    # HACK: symlink packages so we can start GAP
    ln -s $SRCDIR/pkg $GAPPREFIX/share/gap/pkg

    # test building and loading package kernel extension
    cd "$SRCDIR/tst/mockpkg"
    testmockpkg "$GAPPREFIX/bin/gap" "$GAPPREFIX/lib/gap"

    # run testsuite for the resulting GAP
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
    [[ $TESTMANUALSPASS = yes ]] || exit 1

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
    make testlibgap
    ;;

  testkernel)
    make testkernel
    ;;

  testmockpkg)
    # for debugging it is useful to know what sysinfo.gap contains at this point
    cat "$BUILDDIR/sysinfo.gap"

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
        echo "Could not read test suite $SRCDIR/tst/${TEST_SUITE}.g"
        exit 1
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
done

exit 0
