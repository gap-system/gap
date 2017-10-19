#!/usr/bin/env bash

# Clean up any old compiled files before running tests
rm -rf .libs

retvalue=0
gap="../../bin/gap.sh"
gac="../../gac"
for gfile in *.g; do
    if ! diff -b "${gfile}.out" <(./run_single_test.sh "${gap}" "${gfile}"); then
        echo "${gfile}" failed without compiling
        retvalue=1
    fi;
        if ! diff -b "${gfile}.out" <(./run_single_compiled_test.sh "${gap}" "${gac}" "${gfile}"); then
        echo "${gfile}" failed with compiling
        retvalue=1
    fi;

done;
exit ${retvalue}

