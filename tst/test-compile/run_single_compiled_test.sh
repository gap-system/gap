#!/usr/bin/env bash

# This script should be run as ./compile_gap.sh gap gac gapfile.g
# It compiles gapfile.g using gac, then runs the function 'runtest'

# It provides the following features:
# 1) Stop GAP from attaching to the terminal (which it will
#    use in the break loop)
# 2) Combine stderr and stdout
# 3) Rewrite the root of gap with the string GAPROOT,
#    so the output is usable on other machines
GAPROOT=$(cd ../..; pwd)
# Clean any old files around
rm -rf $3.comp* 
$2 $3 -d -o $3.comp 2>&1 >/dev/null
echo 'LoadDynamicModule("./'$3.comp.so'"); runtest();' | $1 -r -A -q -b -x 200 2>&1 | sed "s:${GAPROOT//:/\\:}:GAPROOT:g"
rm -rf $3.comp*
