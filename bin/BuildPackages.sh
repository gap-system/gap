#!/usr/bin/env bash

set -e

# You need at least 'gzip', GNU 'tar', a C compiler, sed, pdftex to run this.
# Some packages also need a C++ compiler.
# Run this script from the 'pkg' subdirectory of your GAP installation.

# Contact support@gap-system.org for questions and complaints.

# Note, that this isn't and is not intended to be a sophisticated script.
# Even if it doesn't work completely automatically for you, you may get
# an idea what to do for a complete installation of GAP.

if ! [ x`which gmake` = "x" ] ; then
  MAKE=gmake
else
  MAKE=make
fi

# Package-specific info:

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
    exit 1
fi

if (cd $SUBDIR && grep 'ABI_CFLAGS=-m32' $GAPDIR/Makefile > /dev/null) ; then
  echo "Building with 32-bit ABI"
  ABI32=YES
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi;

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
cd carat
tar xzpf carat-2.1b1.tgz
rm -f bin
ln -s carat-2.1b1/bin bin
cd carat-2.1b1/functions
# Install the include Gmp first.
# (If you have already Gmp on your system, you can delete the file
# gmp-*.tar.gz and delete the target 'Gmp' from the target 'ALL' in
# carat-2.1b1/Makefile.)
tar xzpf gmp-*.tar.gz
cd ..
$MAKE TOPDIR=`pwd` Links
# Note that Gmp may use processor specific code, so this step may not be ok
# for a network installation if you want to use the package on older computers
# as well.
$MAKE TOPDIR=`pwd` Gmp
# And now the actual Carat programs.
$MAKE TOPDIR=`pwd` CFLAGS='-O2'
)
}

build_cohomolo() {
(
cd $dir
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
      case $dir in
        atlasrep*)
          (cd $dir && chmod 1777 datagens dataword) || build_fail
        ;;

        carat*)
          build_carat || build_fail
        ;;

        cohomolo*)
          build_cohomolo || build_fail
        ;;

        fplsa*)
          (cd $dir && ./configure $GAPDIR && $MAKE CC="gcc -O2 ") || build_fail
        ;;

        kbmag*)
          (cd $dir && ./configure $GAPDIR && $MAKE COPTS="-O2 -g") || build_fail
        ;;

        pargap*)
          (cd $dir && ./configure $GAPDIR && $MAKE && cp bin/pargap.sh $GAPDIR/bin && rm -f ALLPKG) || build_fail
        ;;

        xgap*)
          (cd $dir && ./configure && $MAKE && rm -f $GAPDIR/bin/xgap.sh && cp bin/xgap.sh $GAPDIR/bin) || build_fail
        ;;

        simpcomp*)
        ;;
        
        *)
          (cd $dir && run_configure_and_make) || build_fail
        ;;
      esac;
    else
      echo "$dir is not a GAP package -- no PackageInfo.g"
    fi;
done;
