#!/usr/bin/env bash

set -e

# This script attempts to build all GAP packages contained in the current
# directory. Normally, you should run this script from the 'pkg'
# subdirectory of your GAP installation.

# You can also run it from other locations, but then you need to tell the
# script where your GAP root directory is, by passing it as first argument
# to the script. By default, the script assumes that the parent of the
# current working directory is the GAP root directory.

# You need at least 'gzip', GNU 'tar', a C compiler, sed, pdftex to run this.
# Some packages also need a C++ compiler.

# Contact support@gap-system.org for questions and complaints.

# Note, that this isn't and is not intended to be a sophisticated script.
# Even if it doesn't work completely automatically for you, you may get
# an idea what to do for a complete installation of GAP.


if [ $# -eq 0 ]
  then
    echo "Assuming default GAP location: ../.."
    GAPDIR=../..
  else
    echo "Using GAP location: $1"
    GAPDIR="$1"
fi

# Is someone trying to run us from inside the 'bin' directory?
if [ -f gapicon.bmp ]
  then
    echo "This script must be run from inside the pkg directory"
    echo "Type: cd ../pkg; ../bin/BuildPackages.sh"
    exit 1
fi

# We need any subdirectory, to test if $GAPDIR is right
SUBDIR=`ls -d */ | head -n 1`
if ! (cd $SUBDIR && [ -f $GAPDIR/sysinfo.gap ])
  then
    echo "$GAPDIR is not the root of a gap installation (no sysinfo.gap)"
    echo "Please provide the absolute path of your GAP root directory as"
    echo "first argument to this script."
    exit 1
fi

if (cd $SUBDIR && grep 'ABI_CFLAGS=-m32' $GAPDIR/Makefile > /dev/null) ; then
  echo "Building with 32-bit ABI"
  ABI32=YES
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi;

# Many package require GNU make. So use gmake if available,
# for improved compatibility with *BSD systems where "make"
# is BSD make, not GNU make.
if ! [ x`which gmake` = "x" ] ; then
  MAKE=gmake
else
  MAKE=make
fi

cat <<EOF
Attempting to build GAP packages.
Note that many GAP packages require extra programs to be installed,
and some are quite difficult to build. Please read the documentation for
packages which fail to build correctly, and only worry about packages
you require!
EOF

build_carat() {
(
# TODO: FIX Carat
# Installation of Carat produces a lot of data, maybe you want to leave
# this out until a user complains.
# It is not possible to move around compiled binaries because these have the
# path to some data files burned in.
zcat carat-2.1b1.tgz | tar pxf -
ln -s carat-2.1b1/bin bin
cd carat-2.1b1
make TOPDIR=`pwd`
chmod -R a+rX .
cd bin
aa=`./config.guess`
for x in "`ls -d1 $GAPDIR/bin/${aa}*`"; do
 ln -s "$aa" "`basename $x`"
done
)
}

build_cohomolo() {
(
./configure $GAPDIR
cd standalone/progs.d
cp makefile.orig makefile
cd ../..
$MAKE
)
}

build_fail() {
  echo "= Failed to build $dir"
}

run_configure_and_make() {
  # We want to know if this is an autoconf configure script
  # or not, without actually executing it!
  if [ -f autogen.sh ] && ! [ -f configure ] ; then
    ./autogen.sh
  fi;
  if [ -f configure ]; then
    if grep Autoconf ./configure > /dev/null; then
      ./configure $CONFIGFLAGS --with-gaproot=$GAPDIR
    else
      ./configure $GAPDIR
    fi;
    $MAKE
  else
    echo "No building required for $dir"
  fi;
}

for dir in `ls -d */`
do
    if [ -e $dir/PackageInfo.g ]; then
      dir="${dir%/}"
      echo "==== Checking $dir"
      (  # start subshell
      set -e
      cd $dir
      case $dir in
        atlasrep*)
          chmod 1777 datagens dataword
        ;;

        carat*)
          build_carat
        ;;

        cohomolo*)
          build_cohomolo
        ;;

        fplsa*)
          ./configure $GAPDIR &&
          $MAKE CC="gcc -O2 "
        ;;

        kbmag*)
          ./configure $GAPDIR &&
          $MAKE COPTS="-O2 -g"
        ;;

        NormalizInterface*)
          ./build-normaliz.sh $GAPDIR &&
          run_configure_and_make
        ;;

        pargap*)
          ./configure $GAPDIR &&
          $MAKE &&
          cp bin/pargap.sh $GAPDIR/bin &&
          rm -f ALLPKG
        ;;

        xgap*)
          ./configure &&
          $MAKE &&
          rm -f $GAPDIR/bin/xgap.sh &&
          cp bin/xgap.sh $GAPDIR/bin
        ;;

        simpcomp*)
        ;;
        
        *)
          run_configure_and_make
        ;;
      esac;
      ) || build_fail
      # end subshell
    else
      echo "$dir is not a GAP package -- no PackageInfo.g"
    fi;
done;
