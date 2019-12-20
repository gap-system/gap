#!/usr/bin/env bash

set -ex

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

gap="$GAPDIR/bin/gap.sh"

echo This script should only be run with a 64-bit GAP
for gfile in *.g 64bit/*.g; do
    ./run_gap.sh "${gap}" "${gfile}" > "${gfile}.out"
done
