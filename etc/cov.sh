#!/usr/bin/env bash
#
# cov.sh - Test code coverage in a package and show the result using HTML
#
# This script should be called from the root directory of a GAP package.  It
# runs the file 'tst/testall.g' and puts an HTML code coverage report in the
# tmp/ directory, reporting where the output can be found.
#
#   -b option: open output in browser when done.
#

set -e

# Name the directory
COVDIR=$PWD/tmp

# Get a GAP command
if [ "x$GAP" = x ] ; then
    GAP="gap"
fi
command -v $GAP >/dev/null 2>&1 ||
    error "could not find GAP (perhaps set the GAP environment variable?)"

# Get a test file
TEST="tst/testall.g"
if [ ! -f $TEST ]; then
    echo "error: $TEST does not exist in this directory"
    exit
fi

# Set some options
GAP="$GAP -a 500M -m 500M -q"

# Generate coverage data
$GAP -A --cover $COVDIR.json tst/testall.g

# Generate HTML
$GAP <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;
x := ReadLineByLineProfile("$COVDIR.json");;
OutputAnnotatedCodeCoverageFiles(x, "$PWD", "$COVDIR");
QUIT_GAP(0);
GAPInput

# Remove the raw data file
rm $COVDIR.json

# Possibly open the file
if [ "$1" = "-b" ]; then
    xdg-open $COVDIR/index.html
else
    echo "View output at $COVDIR/index.html"
fi
