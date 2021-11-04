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
  wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.3-linux-x86_64.tar.gz
  tar xvf julia-*.tar.gz
  rm julia-*.tar.gz
  cd julia-*
  JULIA_PATH=$(pwd)
  popd
  CONFIGFLAGS="--with-julia=${JULIA_PATH}/bin/julia $CONFIGFLAGS"
fi


# configure and make GAP
time "$SRCDIR/configure" --enable-Werror $CONFIGFLAGS
