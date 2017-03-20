#!/usr/bin/env bash

set -ex

GAPROOT=${GAPROOT:-$PWD}
BUILDDIR=${BUILDDIR:-.}

./autogen.sh
if [[ $HPCGAP = yes ]]
then
  git clone https://github.com/gap-system/ward
  cd ward
  CFLAGS= LDFLAGS= ./build.sh
  cd ..
  CONFIGFLAGS="$CONFIGFLAGS --enable-hpcgap"
fi
mkdir -p $BUILDDIR
cd $BUILDDIR
$GAPROOT/configure $CONFIGFLAGS
make V=1 -j4
make bootstrap-pkg-full
if [[ $BUILDDIR != . ]] ; then mv pkg $GAPROOT/ ; fi
