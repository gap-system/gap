#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

if [[ x"$ABI" == "x32" ]]
then
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi

if [[ $TEST_SUITE = 'makemanuals' && $TRAVIS_OS_NAME = 'linux' ]]
then
    make manuals
    cat doc/*/make_manuals.out
    if [ `cat doc/*/make_manuals.out | grep -c "manual.lab written"` != '3' ]
    then
        echo "Build failed"
        exit 1
    fi
else
    if [ ! -f  tst/${TEST_SUITE}.g ]
    then
        echo "Could not read test suite tst/${TEST_SUITE}.g"
        exit 1
    fi

    if [[ x"$COVERAGE" == "xno" ]]
    then
        sh bin/gap.sh tst/${TEST_SUITE}.g
    else
        cd pkg/io*
        ./configure $CONFIGFLAGS
        make
        cd ../..
        cd pkg/profiling*
        ./configure $CONFIGFLAGS
        make
        cd ../..

        sh bin/gap.sh --cover coverage tst/${TEST_SUITE}.g

        # generate coverage report
        sh bin/gap.sh -q <<GAPInput
            if LoadPackage("profiling") <> true then
                Print("ERROR: could not load profiling package");
                FORCE_QUIT_GAP(1);
            fi;
            OutputJsonCoverage("coverage", "coverage.json");
            QUIT_GAP(0);
GAPInput
    fi
    cd bin/x86* ; gcov -o . ../../src/*
    cd ../..
fi;
