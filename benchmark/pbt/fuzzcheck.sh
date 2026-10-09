#!/bin/bash
# Summarizes the output of fuzz.g: invalid results, errors and brute force mismatches.
# fuzzcheck.sh file : report BAD lines, errors, and oracle mismatches
f=$1
echo "$f: $(grep -c '^c ' $f) lines, BAD: $(grep -c ' BAD' $f), errors: $(grep -c -i 'error' $f)"
awk '$5 ~ /^oracle-/ {sub("oracle-","",$5); o[$2" "$3" "$4" "$5]=$6; next}
     $1=="c" {v[$2" "$3" "$4" "$5]=$6}
     END {n=0; for (k in o) { n++; if (v[k] != o[k]) {print "ORACLE MISMATCH", k, "got", v[k], "expected", o[k]; m++} } print "oracle checks:", n, "mismatches:", m+0}' $f
