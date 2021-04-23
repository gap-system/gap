#!/usr/bin/env bash
set -ex

SRCDIR=${SRCDIR:-$PWD}

# change into BUILDDIR
[[ -n "$BUILDDIR" ]] && cd "$BUILDDIR"

#
make V=1 -j4
