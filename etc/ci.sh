#!/bin/sh

# Continous integration testing script

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
    if [[ x"$ABI" == "x32" ]]
    then
        echo "Read(\"tst/${TEST_SUITE}.g\"); quit;" |\
           sh bin/gap.sh |\
           tee testlog.txt |\
           grep --colour=always -E "########> Diff|$"
    else
        cd pkg/io*
        ./configure
        make
        cd ../.
        cd pkg/profiling*
        ./configure
        make
        cd ../..
        echo "Read(\"tst/${TEST_SUITE}.g\"); quit;" |\
            sh bin/gap.sh --cover cover |\
            tee testlog.txt |\
            grep --colour=always -E "########> Diff|$"
        echo "CoverToJson(\"coverage\", \"coverage.json\"); quit;" |\
            sh bin/gap.sh etc/cover2json.g
        cd bin/x86* ; gcov -o . ../../src/*
        cd ../..
    fi;
    cat testlog.txt | tail -n 2 |\
        grep "total"; ( ! grep "########> Diff" testlog.txt )
fi;
