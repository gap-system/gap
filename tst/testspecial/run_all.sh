#!/usr/bin/env bash

set -ex

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

retvalue=0
gap="$GAPDIR/bin/gap.sh"
if "${gap}" -A -b -c 'QuitGap(GAPInfo.BytesPerVariable - 8);'; then
    echo "Running 64-bit special tests"
    tocheck="*.g 64bit/*.g"
else
    echo "Running 32-bit special tests"
    tocheck="*.g"
fi;
for gfile in $tocheck; do
    ./run_gap.sh "${gap}" "${gfile}" "${gfile}.bad"
    if ! diff -b "${gfile}.out" "${gfile}.bad"; then
        echo "${gfile}" failed
        retvalue=1
    else
        rm -f "${gfile}.bad"
    fi;
done;
exit ${retvalue}

