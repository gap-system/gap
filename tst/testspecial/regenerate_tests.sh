#!/usr/bin/env bash

set -ex

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

gap="$GAPDIR/bin/gap.sh"

echo This script should only be run with a 64-bit GAP
if command -v parallel >/dev/null 2>&1 ; then
    parallel --bar ./run_gap.sh "${gap}" ::: *.g 64bit/*.g
else
    for gfile in *.g 64bit/*.g; do
        ./run_gap.sh "${gap}" "${gfile}"
    done
fi
