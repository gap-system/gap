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

# for HPC-GAP we install ward inside BUILDDIR
if [[ $HPCGAP = yes ]]
then
  git clone https://github.com/gap-system/ward
  cd ward
  CFLAGS= LDFLAGS= ./build.sh
  cd ..
  CONFIGFLAGS="$CONFIGFLAGS --enable-hpcgap"
fi


if [[ $JULIA = yes ]]
then
  # TODO: once Julia 1.1 is released, switch to stable Julia versions here?
  # or maybe use Travis' `language: julia` feature?
  wget https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-rc1-linux-x86_64.tar.gz
  #wget https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz
  tar xvf julia-*.tar.gz
  rm julia-*.tar.gz
  pushd julia-*
  JULIA_PATH=$(pwd)
  popd
  CONFIGFLAGS="--with-gc=julia --with-julia=$JULIA_PATH $CONFIGFLAGS"
fi


# configure and make GAP
time "$SRCDIR/configure" --enable-Werror $CONFIGFLAGS
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

  #
  # Factint is incompatible with HPCGAP and interferes with some tests
  #
  
  if [[ $HPCGAP = yes ]]
  then
     rm -rf $SRCDIR/pkg/FactInt*
  fi
  
  popd

fi
