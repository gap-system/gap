#!/usr/bin/env bash

set -ex

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

gap="$GAPDIR/bin/gap.sh"
for gfile in *.g; do
    ./run_gap.sh "${gap}" "${gfile}" > "${gfile}.out"
done
