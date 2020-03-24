#!/usr/bin/env bash

set -ex

SRCDIR=${SRCDIR:-$PWD}

# print some data useful for debugging issues with the build
gcov --version
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
  CONFIGFLAGS="--enable-hpcgap $CONFIGFLAGS"
fi


if [[ $JULIA = yes ]]
then
  pushd extern
  wget https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz
  tar xvf julia-*.tar.gz
  rm julia-*.tar.gz
  cd julia-*
  JULIA_PATH=$(pwd)
  popd
  CONFIGFLAGS="--with-gc=julia --with-julia=${JULIA_PATH}/bin/julia $CONFIGFLAGS"
fi


# configure and make GAP
time "$SRCDIR/configure" --enable-Werror $CONFIGFLAGS
time make V=1 -j4

# download packages; instruct curl to retry several times if the
# connection is refused, to work around intermittent failures
DOWNLOAD="curl -L --retry 5 --retry-delay 5 -O"
if [[ $(uname) == Darwin ]]
then
    # Travis OSX builders seem to have very small download bandwidth,
    # so as a workaround, we only test the minimal set of packages there.
    # On the upside, it's good to test that, too!
    make bootstrap-pkg-minimal DOWNLOAD="$DOWNLOAD"
    git clone https://github.com/gap-packages/io "$SRCDIR/pkg/io"
    git clone https://github.com/gap-packages/profiling "$SRCDIR/pkg/profiling"
else
    make bootstrap-pkg-full DOWNLOAD="$DOWNLOAD"
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

  # We need to compile the profiling package in order to generate coverage
  # reports; and also the IO package, as the profiling package depends on it.
  pushd "$SRCDIR/pkg"

  # Compile io and profiling packages
  # we deliberately reset CFLAGS, CXXFLAGS, LDFLAGS to prevent them from being
  # compiled with coverage gathering, because otherwise gcov may confuse
  # IO's src/io.c with GAP's.
  CFLAGS= CXXFLAGS= LDFLAGS= "$SRCDIR/bin/BuildPackages.sh" --strict --with-gaproot="$BUILDDIR" io* profiling*

  popd

fi
