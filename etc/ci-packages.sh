#!/usr/bin/env bash

GAP="bin/gap.sh --quitonbreak -q"

packages=$($GAP -A <<GAPInput
    packages := SortedList(ShallowCopy(RecNames(GAPInfo.PackagesInfo)));;
    Perform(packages,Display);
    QUIT_GAP(0);
GAPInput
)

any_failures=no
log="package-test-failure.log"
echo "" > $log

for pkg in $packages
do
    echo "=== Running tests for $pkg ==="
$GAP -A  -x 80 -r <<GAPInput
    status := TestPackage("$pkg");;
    if status = fail then
        QUIT_GAP(1); # signal failure;
    elif status = false then
        Print("No test file found, skipping\n");
    fi;
    QUIT_GAP(0);
GAPInput

    if [[ $? != 0 ]]
    then
        echo "tests failed"
        any_failures=yes
        echo "$pkg" >> $log
    else
        echo "tests passed"
    fi
    echo
done

if [[ $any_failures == yes ]]
then
    echo "Package tests failed for these packages:"
    cat $log
    exit 1
fi
