#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

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

    if [[ x"$ABI" == "x32" ]]
    then
        sh bin/gap.sh tst/${TEST_SUITE}.g
    else
        cd pkg/io*
        ./configure
        make
        cd ../..
        cd pkg/profiling*
        ./configure
        make
        cd ../..

        sh bin/gap.sh --cover coverage tst/${TEST_SUITE}.g

        # generate coverage report
        sh bin/gap.sh -b etc/cover2json.g
        cd bin/x86* ; gcov -o . ../../src/*
        cd ../..
    fi
fi;
