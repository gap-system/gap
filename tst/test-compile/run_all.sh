#!/usr/bin/env bash

set -e

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir)
GAPDIR=${GAPDIR:-../..}

# Clean up any old compiled files before running tests
rm -rf .libs

retvalue=0
gap="$GAPDIR/bin/gap.sh"
gac="$GAPDIR/gac"
for gfile in *.g; do
    echo "Now testing ${gfile}"

    echo "  now interpreting ${gfile} ..."
    if ! diff -u -b "${gfile}.out" <(./run_interpreted.sh "${gap}" "${gfile}"); then
        echo "ERROR: ${gfile} failed without compiling"
        retvalue=1
    fi;

    echo "  now compiling ${gfile} dynamically ..."
    if ! diff -u  -b "${gfile}.out" <(./run_compiled_dynamic.sh "${gap}" "${gac}" "${gfile}"); then
        echo "ERROR: ${gfile} failed with compiling and dynamic linking"
        retvalue=1
    fi;
    if ! git diff --exit-code -- ${gfile}.dynamic.c; then
        echo "ERROR: ${gfile}.dynamic.c changed unexpectedly"
        retvalue=1
    fi;

    echo "  now compiling ${gfile} statically ..."
    if ! diff -u -b "${gfile}.out" <(./run_compiled_static.sh "${gac}" "${gfile}"); then
        echo "ERROR: ${gfile} failed with compiling and static linking"
        retvalue=1
    fi;
    if ! git diff --exit-code -- ${gfile}.static.c; then
        echo "ERROR: ${gfile}.static.c changed unexpectedly"
        retvalue=1
    fi;
    echo

done;
exit ${retvalue}

