#!/usr/bin/env bash

gap="../../bin/gap.sh"
for gfile in *.g; do
    ./run_gap.sh "${gap}" "${gfile}" > "${gfile}.out"
done
