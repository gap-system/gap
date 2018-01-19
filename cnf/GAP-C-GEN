#!/bin/sh -e

# This script regenerates src/c_$1.c from lib/$1.g, but touching
# the C file only when it changed

# usage:  GAP-C_GEN srcdir dstdir stem gapbin

srcdir=$(cd "$1"; pwd)
dstdir=$(cd "$2"; pwd)
STEM="$3"
GAPBIN="$4"

GAP_FILE="$srcdir/$STEM.g"
C_FILE="$dstdir/c_$STEM.c"

if ! test -r "$GAP_FILE"
then
    echo "Error, could not find $GAP_FILE"
    exit 1
fi

# invoke GAP in compiler mode
echo "#ifndef AVOID_PRECOMPILED" > "$C_FILE.tmp"
"$GAPBIN" -C "*stdout*" \
          "$GAP_FILE" \
          "Init_$STEM" \
          GAPROOT/lib/$STEM.g >> "$C_FILE.tmp"
echo "#endif" >> "$C_FILE.tmp"

# if the new file differs from the old one, overwrite
if cmp -s "$C_FILE.tmp" "$C_FILE"
then
    rm "$C_FILE.tmp"
else
    echo "Updating $C_FILE"
    mv "$C_FILE.tmp" "$C_FILE"
fi
