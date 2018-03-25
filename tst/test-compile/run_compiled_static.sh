#!/usr/bin/env bash

set -e

# This script should be run as ./run_compiled_static.sh gac gapfile.g
# It compiles gapfile.g using gac, then runs the function 'runtest'
gac="$1"
gfile="$2"

# It provides the following features:
# 1) Stop GAP from attaching to the terminal (which it will
#    use in the break loop)
# 2) Combine stderr and stdout
# 3) Rewrite the root of gap with the string GAPROOT,
#    so the output is usable on other machines
GAPROOT=$(cd ../..; pwd)
# Clean any old files around
rm -rf .libs "$gfile.comp"*

"$gac" "$gfile" -C -o "$gfile.static.c" 2>&1 >/dev/null

"$gac" "$gfile" -p "$CFLAGS" -P "$LDFLAGS" -o "$gfile.comp" 2>&1 >/dev/null

echo "LOAD_STAT(\"$gfile\",false);; runtest();" |
    "./$gfile.comp" -l "$GAPROOT" -r -A -q -b -x 200 2>&1 |
    sed "s:${GAPROOT//:/\\:}:GAPROOT:g"

rm -rf .libs "$gfile.comp"*
