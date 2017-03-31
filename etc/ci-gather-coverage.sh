#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details.
# This is in a seperate script, because we always want to run it even if
# the test script fails

set -ex

SRCDIR=${SRCDIR:-$PWD}

GAP="bin/gap.sh --quitonbreak -q"

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

# Load gap-init.g when starting GAP to ensure that any Error() immediately exits
# GAP with exit code 1.
echo 'OnBreak:=function() Print("FATAL ERROR\n"); FORCE_QUIT_GAP(1); end;;' > gap-init.g

# Get dir for coverage results
COVDIR=coverage

# generate library coverage reports
$GAP -a 500M -m 500M -q gap-init.g <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;
d := Directory("$COVDIR");;
covs := [];;
for f in DirectoryContents(d) do
    if f in [".", ".."] then continue; fi;
    Add(covs, Filename(d, f));
od;
Print("Merging coverage results\n");
r := MergeLineByLineProfiles(covs);;
Print("Outputting JSON\n");
OutputJsonCoverage(r, "gap-coverage.json");;
QUIT_GAP(0);
GAPInput

# generate kernel coverage reports by running gcov
. sysinfo.gap
cd bin/${GAParch}
gcov -o . ../../src/*
cd ../..
