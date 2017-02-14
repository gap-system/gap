#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details. In addition, it can be run manually, to simulate what
# happens in the CI environment locally (say, for debugging purposes).

set -ex

case $TEST_SUITE in
    makemanuals)
        make manuals
        cat doc/*/make_manuals.out
        if [ `cat doc/*/make_manuals.out | grep -c "manual.lab written"` != '3' ]
        then
            echo "Build failed"
            exit 1
        fi
        ;;
    testmanuals)
        cd pkg/io*
        ./configure
        make
        cd ../..
        cd pkg/profiling*
        ./configure
        make
        cd ../..

        sh bin/gap.sh -q tst/extractmanuals.g
        COVDIR=`mktemp -d`

        sh bin/gap.sh -q <<GAPInput
            Read("tst/testmanuals.g");
            SaveWorkspace("testmanuals.wsp");
            QUIT_GAP(0);
GAPInput
       
        for ch in tst/testmanuals/*.tst
        do
            COVNAME="coverage.`basename $ch .tst`"
            sh bin/gap.sh -q -L testmanuals.wsp --cover $COVDIR/$COVNAME <<GAPInput
            TestManualChapter("$ch");
            QUIT_GAP(0);
GAPInput
        done

        sh bin/gap.sh -q <<GAPInput
        if LoadPackage("profiling") <> true then
            Print("ERROR: could not load profiling package");
            FORCE_QUIT_GAP(1);
        fi;

        for f in DirectoryContents("$COVDIR") do
            if not (f in [".", ".."]) then
                OutputJsonCoverage( Filename(Directory("$COVDIR"), f)
                                  , Concatenation(f, ".json"));
            fi;
        od;
        QUIT_GAP(0);
GAPInput
        ;;
    *)
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
            sh bin/gap.sh -a 500M -q <<GAPInput
                if LoadPackage("profiling") <> true then
                    Print("ERROR: could not load profiling package");
                    FORCE_QUIT_GAP(1);
                fi;
                OutputJsonCoverage("coverage", "coverage.json");
                QUIT_GAP(0);
GAPInput
        fi
esac;

# Run gcov
. sysinfo.gap
cd bin/${GAParch}
gcov -o . ../../src/*
cd ../..
