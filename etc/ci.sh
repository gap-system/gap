#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

if [[ "${TEST_SUITE}" == makemanuals ]]
then
    make manuals
    cat doc/*/make_manuals.out
    if [[ $(cat doc/*/make_manuals.out | grep -c "manual.lab written") != '3' ]]
    then
        echo "Build failed"
        exit 1
    fi
    exit 0
fi

if [[ x"$ABI" == "x32" ]]
then
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi

# We need to compile the profiling package in order to generate coverage
# reports; and also the IO package, as the profiling package depends on it.
pushd pkg

cd io*
./configure $CONFIGFLAGS
make
cd ..

# HACK: profiling 1.1.0 (shipped with GAP 4.8.6) is broken on 32 bit
# systems, so we simply grab the latest profiling version
rm -rf profiling*
git clone https://github.com/gap-packages/profiling
cd profiling
./autogen.sh
./configure $CONFIGFLAGS
make

# return to base directory
popd

# create dir for coverage results
COVDIR=coverage
mkdir -p $COVDIR


case ${TEST_SUITE} in
testmanuals)
    bin/gap.sh -q tst/extractmanuals.g

    bin/gap.sh -q <<GAPInput
        Read("tst/testmanuals.g");
        SaveWorkspace("testmanuals.wsp");
        QUIT_GAP(0);
GAPInput

    for ch in tst/testmanuals/*.tst
    do
        bin/gap.sh -q -L testmanuals.wsp --cover $COVDIR/$(basename $ch).coverage <<GAPInput
        TestManualChapter("$ch");
        QUIT_GAP(0);
GAPInput
    done

    ;;
*)
    if [[ ! -f  tst/${TEST_SUITE}.g ]]
    then
        echo "Could not read test suite tst/${TEST_SUITE}.g"
        exit 1
    fi

    bin/gap.sh --cover $COVDIR/${TEST_SUITE}.coverage tst/${TEST_SUITE}.g
esac;

# generate library coverage reports
bin/gap.sh -a 500M -q <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;
d := Directory("$COVDIR");;
for f in DirectoryContents(d) do
    if f in [".", ".."] then continue; fi;
    Print("Converting ", f, " to JSON\n");
    OutputJsonCoverage(Filename(d, f), Concatenation(f, ".json"));
od;
QUIT_GAP(0);
GAPInput

# generate kernel coverage reports by running gcov
. sysinfo.gap
cd bin/${GAParch}
gcov -o . ../../src/*
cd ../..
