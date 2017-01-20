#!/usr/bin/env bash

retvalue=0
for gfile in *.g; do
    if ! diff -b "${gfile}.out" <(./run_gap.sh "../../bin/gap.sh" "${gfile}"); then
        echo "${gfile}" failed
        retvalue=1
    fi;
done;
exit ${retvalue}

