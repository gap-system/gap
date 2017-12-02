#!/usr/bin/env bash

set -ex

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

retvalue=0
gap="$GAPDIR/bin/gap.sh"
for gfile in *.g; do
    if ! diff -b "${gfile}.out" <(./run_gap.sh "${gap}" "${gfile}"); then
        echo "${gfile}" failed
        retvalue=1
    fi;
done;
exit ${retvalue}

