#!/usr/bin/env bash

set -e

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

gap="$GAPDIR/bin/gap.sh"
gac="$GAPDIR/gac"
for gfile in *.g; do
    echo "Regenerating ${gfile}.out ..."
    ./run_interpreted.sh "${gap}" "${gfile}" > "${gfile}.out"
    "${gac}" -d -C -o "${gfile}.dynamic.c" "${gfile}"
    "${gac}" -C -o "${gfile}.static.c" "${gfile}"
done
