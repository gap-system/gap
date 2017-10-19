#!/usr/bin/env bash

gap="../../bin/gap.sh"
for gfile in *.g; do
    ./run_single_test.sh "${gap}" "${gfile}" > "${gfile}.out"
done
