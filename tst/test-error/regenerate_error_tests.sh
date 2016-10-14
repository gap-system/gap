#!/usr/bin/env bash

for gfile in *.g; do
    ./run_gap.sh ../../bin/gap.sh "${gfile}" > "${gfile}.out"
done

