#!/usr/bin/env bash

set -e

# This script should be run as ./run_compiled_dynamic.sh gap gac gapfile.g
# It compiles gapfile.g using gac, then runs the function 'runtest'
gap="$1"
gac="$2"
gfile="$3"

# It provides the following features:
# 1) Stop GAP from attaching to the terminal (which it will
#    use in the break loop)
# 2) Combine stderr and stdout
# 3) Rewrite the root of gap with the string GAPROOT,
#    so the output is usable on other machines
GAPROOT=$(cd ../..; pwd)
# Clean any old files around
rm -rf .libs "$gfile.comp"*

"$gac" "$gfile" -d -C -o "$gfile.dynamic.c" 2>&1 >/dev/null

"$gac" "$gfile" -p "$CFLAGS" -P "$LDFLAGS" -d -o "$gfile.comp" 2>&1 >/dev/null

echo "LoadDynamicModule(\"./$gfile.comp.so\"); runtest();" |
    "$gap" -r -A -q -b -x 200 2>&1 |
    sed "s:${GAPROOT//:/\\:}:GAPROOT:g"

rm -rf .libs "$gfile.comp"*
