#/usr/bin/env bash

# This script should be run as ./run_gap.sh gap gapfile.g
# It provides the following features:
# 1) Stop GAP from attaching to the terminal (which it will
#    use in the break loop)
# 2) Combine stderr and stdout
# 3) Rewrite the root of gap with the string GAPROOT,
#    so the output is usable on other machines
GAPROOT=$(cd ../..; pwd)
echo 'Read("'$2'");\n' | $1 -q -b 2>&1 | sed "s:${GAPROOT//:/\\:}:GAPROOT:g"
