#!/usr/bin/env bash

set -ex

SRCDIR=${SRCDIR:-$PWD}

# for debugging purposes print the environment and info about the HEAD commit
printenv | sort
git show --pretty=fuller -s

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

if [[ $HPCGAP = yes ]]
then
  CONFIGFLAGS="$CONFIGFLAGS --enable-hpcgap"
fi


if [[ $JULIA = yes ]]
then
  # TODO: once Julia 1.1 is released, switch to stable Julia versions here?
  wget https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz
  tar xvf julia-latest-linux64.tar.gz
  rm julia-latest-linux64.tar.gz
  pushd julia-*
  JULIA_PATH=$(pwd)
  popd
  CONFIGFLAGS="$CONFIGFLAGS --with-gc=julia --with-julia=$JULIA_PATH"
fi


# configure and make GAP
time "$SRCDIR/configure" $CONFIGFLAGS --enable-Werror
time make V=1 -j4

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

# check that GAP is at least able to start
echo 'Print("GAP started successfully\n");QUIT_GAP(0);' | ./gap -T

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

  # We need to compile the profiling package in order to generate coverage
  # reports; and also the IO package, as the profiling package depends on it.
  pushd "$SRCDIR/pkg"

  rm -rf io*
  time git clone https://github.com/gap-packages/io

  rm -rf profiling-*
  time git clone https://github.com/gap-packages/profiling

  # Compile io and profiling packages
  # we deliberately reset CFLAGS and LDFLAGS to prevent them from being
  # compiled with coverage gathering, because otherwise gcov may confuse
  # IO's src/io.c with GAP's.
  CFLAGS= LDFLAGS= "$SRCDIR/bin/BuildPackages.sh" --strict --with-gaproot="$BUILDDIR" io* profiling*

  popd

fi
