#!/bin/sh
set -e

# ensure DST is a symlink pointing to SRC
SRC=$1
DST=$2
CUR=$(readlink "$DST" || echo "")
if [ "$CUR" != "$SRC" ]
then
    rm -f "$DST"
    ln -s "$SRC" "$DST"
fi
