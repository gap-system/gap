#!/usr/bin/env bash

# Continous integration testing script

# This is currently only used for Travis CI integration, see .travis.yml
# for details.
# This is in a separate script, because we always want to run it even if
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
ls -l "$COVDIR" # for debugging

# generate library coverage reports
$GAP -a 500M -m 500M -q <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    ForceQuitGap(1);
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
prefix := Concatenation(GAPInfo.SystemEnvironment.PWD, "/");
if Length(covs) > 0 then
    Print("Merging ", Length(covs), " coverage files...\n");
    r := MergeLineByLineProfiles(covs);;

    # now remove "weird" entries, and entries for pkg files
    r.line_info := Filtered(r.line_info, file ->
        StartsWith(file[1], prefix) and
        fail = PositionSublist(file[1], "/pkg/") and
        IsReadableFile(file[1]) );

    Print("Outputting JSON for Codecov...\n");
    OutputJsonCoverage(r, "gap-coverage.json");;
else
    # Don't error, because we might want to gather
    # gcov coverage, so just inform that we didn't find
    # GAP coverage data
    Print("No coverage files found...\n");
    r := rec( line_info := [] );
fi;

# Always output coveralls JSON, as ci-coveralls-merge.py relies
# on it being present and containing all relevant metadata...
Print("Outputting JSON for Coveralls...\n");

env := GAPInfo.SystemEnvironment;;
if IsBound(env.GITHUB_ACTIONS) then
    opt := rec(
        service_name := "github",
        # The build number. Will default to chronological numbering from builds on repo
        service_number := env.GITHUB_RUN_NUMBER,
        # A unique identifier of the job on the service specified by service_name
        # FIXME: there seems to be no unique per-job id; the GITHUB_RUN_ID is
        # shared by all jobs in a single build :-(
        #service_job_id := env.GITHUB_RUN_ID,
        service_branch := env.GITHUB_REF{[Length("refs/heads/")..Length(env.GITHUB_REF)]},
        commit_sha := env.GITHUB_SHA,
#         service_build_url := Concatenation(
#             "https://ci.appveyor.com/project/",
#             env.APPVEYOR_REPO_NAME,
#             "/build/",
#             env.APPVEYOR_BUILD_VERSION),
    );

    # GITHUB_REF has the form refs/pull/12345/merge
    if IsBound(env.GITHUB_REF) and StartsWith(env.GITHUB_REF, "refs/pull/") then
        tmp := SplitString(env.GITHUB_REF, "/");
        if Length(tmp) = 4 and tmp[4] = "merge" and Int(tmp[3]) <> fail then
            # The associated pull request ID of the build. Used for updating the status and/or commenting
            opt.service_pull_request := tmp[3];
        fi;
    fi;

    OutputCoverallsJsonCoverage(r, "gap-coveralls.json", prefix, opt);

else
    OutputCoverallsJsonCoverage(r, "gap-coveralls.json", prefix);
fi;
GAPInput

if [[ -f gap-coveralls.json ]]
then
  # generate kernel coverage reports by running gcov
  python -m gcovr -r . -o c-coveralls.json --json --exclude-directories pkg/ --exclude-directories extern/ -e pkg/ -e extern/

  python etc/ci-coveralls-merge.py
fi

# upload to coveralls.io
# TODO: perhaps fold into python script?
if [[ -f merged-coveralls.json ]]
then
  curl -F json_file=@merged-coveralls.json "https://coveralls.io/api/v1/jobs"
fi

