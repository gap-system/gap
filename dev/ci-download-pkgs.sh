#!/usr/bin/env bash
set -ex

SRCDIR=${SRCDIR:-$PWD}

# change into BUILDDIR
[[ -n "$BUILDDIR" ]] && cd "$BUILDDIR"
BUILDDIR=$PWD

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

# reset CFLAGS, CXXFLAGS, LDFLAGS before compiling packages, to prevent
# them from being compiled with coverage gathering, because
# otherwise gcov may confuse IO's src/io.c, or anupq's src/read.c,
# with GAP kernel files with the same name
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

# compile a few packages useful for some tests, e.g. in testbugfix
pushd "$SRCDIR/pkg"
"$SRCDIR/bin/BuildPackages.sh" --strict --with-gaproot="$BUILDDIR" io* cvec*
popd
