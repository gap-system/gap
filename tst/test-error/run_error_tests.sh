#!/usr/bin/env bash

retvalue=0
gap="../../bin/gap.sh"
for gfile in *.g; do
    if ! diff -b "${gfile}.out" <(./run_gap.sh "${gap}" "${gfile}"); then
        echo "${gfile}" failed
        retvalue=1
    fi;
done;
exit ${retvalue}

