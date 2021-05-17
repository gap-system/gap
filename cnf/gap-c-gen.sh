#!/bin/sh -e

# This script regenerates src/c_$1.c from lib/$1.g, but touching
# the C file only when it changed

# usage:  GAP-C_GEN gapfile cfile stem gapbin

GAP_FILE="$1"
C_FILE="$2"
STEM="$3"
GAPBIN="$4"

if ! test -r "$GAP_FILE"
then
    echo "Error, could not find $GAP_FILE"
    exit 1
fi

# invoke GAP in compiler mode
"$GAPBIN" -E -C "$C_FILE.tmp" \
          "$GAP_FILE" \
          "Init_$STEM" \
          GAPROOT/lib/$STEM.g >> "$C_FILE.tmp"

# if the new file differs from the old one, overwrite
if cmp -s "$C_FILE.tmp" "$C_FILE"
then
    rm "$C_FILE.tmp"
else
    echo "   GAC     $GAP_FILE => $C_FILE"
    mv "$C_FILE.tmp" "$C_FILE"
fi
