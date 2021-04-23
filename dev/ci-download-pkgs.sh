#!/usr/bin/env bash
set -ex

SRCDIR=${SRCDIR:-$PWD}

# change into BUILDDIR
[[ -n "$BUILDDIR" ]] && cd "$BUILDDIR"

# if requested, bootstrap with minimal set of packages
if [[ $BOOTSTRAP_MINIMAL = yes ]]
then
    make bootstrap-pkg-minimal
    # if coverage is requested, install the io and profiling packages directly
    if [[ -z ${NO_COVERAGE} ]]
    then
      git clone https://github.com/gap-packages/io "$SRCDIR/pkg/io"
      git clone https://github.com/gap-packages/profiling "$SRCDIR/pkg/profiling"
    fi
else
    make bootstrap-pkg-full
fi

# packages must be placed inside SRCDIR, as only that
# is a GAP root, while BUILDDIR is not.
if [[ ! -d "$SRCDIR/pkg" ]]
then
  mv pkg "$SRCDIR/"
fi

echo "ls $SRCDIR/pkg"
ls $SRCDIR/pkg
