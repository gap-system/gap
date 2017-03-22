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

# HACK
pwd
ls -l

# Minimal test to see if the gap binary can at least start
echo 'Print("GAP started successfully\n");QUIT_GAP(0);' | ./gap -q -T

make bootstrap-pkg-full
if [[ $BUILDDIR != . ]] ; then mv pkg $GAPROOT/ ; fi
