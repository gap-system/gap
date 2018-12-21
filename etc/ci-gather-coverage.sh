#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details.
# This is in a seperate script, because we always want to run it even if
# the test script fails

set -ex

# If we don't care about code coverage, do nothing
if [[ -n ${NO_COVERAGE} ]]
then
    exit 0
fi

SRCDIR=${SRCDIR:-$PWD}

# Make sure any Error() immediately exits GAP with exit code 1.
GAP="bin/gap.sh --quitonbreak --alwaystrace -q"

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

# Get dir for coverage results
COVDIR=coverage

# generate library coverage reports
$GAP -a 500M -m 500M -q <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;
d := Directory("$COVDIR");;
Print("Scanning for coverage data...\n");
covs := [];;
for f in DirectoryContents(d) do
    if f in [".", ".."] then continue; fi;
    f := Filename(d, f);
    Add(covs, f);
    Print("  ", f, "\n");
od;
if Length(covs) > 0 then
    Print("Merging ", Length(covs), " coverage files...\n");
    r := MergeLineByLineProfiles(covs);;

    # now remove "weird" entries, and entries for pkg files
    prefix := Concatenation(GAPInfo.SystemEnvironment.PWD, "/");
    r.line_info := Filtered(r.line_info, file ->
        StartsWith(file[1], prefix) and
        fail = PositionSublist(file[1], "/pkg/") and
        IsReadableFile(file[1]) );

    Print("Outputting JSON for Codecov...\n");
    OutputJsonCoverage(r, "gap-coverage.json");;

    if IsBound(GAPInfo.SystemEnvironment.TRAVIS_JOB_ID) then
        Print("Outputting JSON for Coveralls...\n");
        OutputCoverallsJsonCoverage(r, "gap-coveralls.json",
                GAPInfo.SystemEnvironment.TRAVIS_JOB_ID,
                prefix);
    fi;
else
    # Don't error, because we might want to gather
    # gcov coverage, so just inform that we didn't find
    # GAP coverage data
    Print("No coverage files found...\n");
fi;
GAPInput

# generate kernel coverage reports by running gcov
make coverage

# upload to coveralls.io
if [[ -f gap-coveralls.json ]]
then
  curl -F json_file=@gap-coveralls.json "https://coveralls.io/api/v1/jobs"
fi
