#!/usr/bin/env bash

set -ex

SRCDIR=${SRCDIR:-$PWD}

# prepare the build system
cd $SRCDIR
./autogen.sh

# change into BUILDDIR (creating it if necessary), and turn it into an absolute path
if [[ -n "$BUILDDIR" ]]
then
  mkdir -p "$BUILDDIR"
  cd "$BUILDDIR"
fi
BUILDDIR=$PWD

# for HPC-GAP we install ward inside BUILDDIR
if [[ $HPCGAP = yes ]]
then
  git clone https://github.com/gap-system/ward
  cd ward
  CFLAGS= LDFLAGS= ./build.sh
  cd ..
  CONFIGFLAGS="$CONFIGFLAGS --enable-hpcgap"
fi

# configure and make GAP
"$SRCDIR/configure" $CONFIGFLAGS --enable-Werror
make V=1 -j4

# check that GAP is at least able to start
echo 'Print("GAP started successfully\n");QUIT_GAP(0);' | ./gap -q -T

# download packages; instruct wget to retry several times if the
# connection is refused, to work around intermittent failures
WGET="wget -N --no-check-certificate --tries=5 --waitretry=5 --retry-connrefused"
if [[ $(uname) == Darwin ]]
then
    # Travis OSX builders seem to have very small download bandwidth,
    # so as a workaround, we only test the minimal set of packages there.
    # On the upside, it's good to test that, too!
    make bootstrap-pkg-minimal WGET="$WGET"
else
    make bootstrap-pkg-full WGET="$WGET"
fi

# TEMPORARY FIX : factint is not HPC-GAP compatible
if [[ $HPCGAP = yes ]]
then
    rm -rf pkg/factint*
fi

# packages must be placed inside SRCDIR, as only that
# is a GAP root, while BUILDDIR is not.
if [[ ! -d "$SRCDIR/pkg" ]]
then
  mv pkg "$SRCDIR/"
fi

echo "ls $SRCDIR/pkg"
ls $SRCDIR/pkg

# compile IO and profiling package, unless NO_COVERAGE is given
if [[ -z ${NO_COVERAGE} ]]
then
  # TODO: get rid of this hack (packages should set 32bit flags themselves)
  if [[ $ABI == 32 ]]
  then
    CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
  fi

  # TODO: get rid of this hack (packages should get include paths from sysinfo.gap resp. gac)
  if [[ $HPCGAP = yes ]]
  then
    # Add flags so that Boehm GC and libatomic headers are found
    CPPFLAGS="-I$PWD/extern/install/gc/include -I$PWD/extern/install/libatomic_ops/include $CPPFLAGS"
    export CPPFLAGS
  fi

  # We need to compile the profiling package in order to generate coverage
  # reports; and also the IO package, as the profiling package depends on it.
  pushd "$SRCDIR/pkg"

  # HACK: io 4.4.6 (shipped with GAP 4.8.6) directly accesses some GAP internals
  # (for GASMAN), which we will remove in GAP 4.9. To ensure it works,
  # we simply grab the latest version from git.
  # TODO: go back to using the io release on 4.5.0 is out
  rm -rf io*
  git clone https://github.com/gap-packages/io
  cd io
  # invoke autogen if configure does not exist or is not executable
  [[ -x configure ]] || ./autogen.sh
  ./configure $CONFIGFLAGS --with-gaproot=$BUILDDIR
  make V=1
  cd ..

  # HACK: grab the latest profiling version.
  rm -rf profiling*
  git clone https://github.com/gap-packages/profiling
  cd profiling
  # invoke autogen if configure does not exist or is not executable
  [[ -x configure ]] || ./autogen.sh
  ./configure $CONFIGFLAGS --with-gaproot=$BUILDDIR
  make V=1
  cd ..

  popd

fi
