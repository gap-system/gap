#!/bin/sh

#CALLING SYNTAX:  ./install-gapmpi-4.x.sh <SOURCE_GAP_ROOT_DIR>
#                ( to make new copy in ~/.mygap4beta )
# OR:  ./install-gapmpi-4.x.sh <SOURCE_GAP_ROOT_DIR> COPYOVER
#  where COPYOVER is copied literally

DESTDIR=$HOME/mygap4beta

if [ ! -z "$1" ]; then
  if [ ! -d $1  -o ! -f $1/src/gap.c ]; then
    echo $1 is not a GAP root directory
    exit
  fi;
  echo Will use:  GAP_DIR=$1
  GAP_DIR=$1
else
  echo Syntax: ./install-gapmpi-4.x.sh '<SOURCE_GAP_ROOT_DIR>'
  echo OR: ./install-gapmpi-4.x.sh '<SOURCE_GAP_ROOT_DIR>' COPYOVER
  echo "  " where COPYOVER is copied literally.
  echo ""
  echo "  " The first form will create a new $HOME/mygap4beta
  echo "    "  with symbolic links to save on disk space.
  echo "  " The second form will modify the existing DEST_GAP_ROOT_DIR
  exit
fi
if [ x$2 = xCOPYOVER ]; then
  echo Will COPYOVER using:  DESTDIR=$1
  DESTDIR=$1
fi
if [ -w "$DESTDIR" ]; then
  if [ x$2 != xCOPYOVER ]; then
    echo $DESTDIR already exists
    echo If you want to start over, try copying your files to a safe place, and:
    echo "    " rm -rf $DESTDIR
    echo If you want to modify $DESTDIR, then call this script as:
    echo "    "  ./install-gapmpi-4.x.sh $1 $DESTDIR
    exit
  fi
fi
if [ ! -f gap4b3-bin-i586-Makefile ]; then
  echo Couldn"'"t find gap4b3-src-gap.c
  echo You must be in the original directory where you found this script
  echo when you execute it.
fi
if ( ! grep 'VERSION := "4.' $DESTDIR/lib/version.g > /dev/null ) ; then
  echo This isn"'"t GAP-4.x.  It"'"s
  grep ^VERSION $DESTDIR/lib/version.g
  exit
fi 
if ( grep 'GAPMPI' $DESTDIR/src/gap.c > /dev/null ) ; then
  echo The destination directory appears to already have a GAPMPI patch.
  echo Make sure that the bin/*/Makefile has been modified for GAPMPI
  echo Then try doing ./configure and make as with the usual GAP installation.
  exit
fi 

if [ x$2 != xCOPYOVER ]; then
  ./install-private-gap.sh $GAP_DIR $DESTDIR
fi
if [ ! -d $DESTDIR/pkg ]; then
  if [ -f $DESTDIR/pkg ]; then
    echo WARNING:  $DESTDIR/pkg is not a directory.
    echo Consider deleting it, and calling this script again.
  fi;
  mkdir $DESTDIR/pkg
  rm -fr $DESTDIR/pkg/gapmpi
fi;
cp -r . $DESTDIR/pkg/gapmpi

cd $DESTDIR
cp pkg/gapmpi/src/* src/
cp pkg/gapmpi/lib/* lib/
cp pkg/gapmpi/procgroup .
# This patch may go away when GAP-4 is modified for GAPMPI conditionals
# To create the patch, start with a fresh GAP:
# For patch to work, on some systems, the dirname, patch/,
#   must be longer than src/ or lib/, and on some, patch must come first.
#    mkdir patch; copy new files into patch/; and
#    diff -c src/gap.c patch/gap.c > gapmpi4.patch
#    diff -c lib/init.g patch/init.g >> gapmpi4.patch
#  -p0: strip 0 components from pathname in patch file
patch -p0 < pkg/gapmpi/gapmpi4.patch
# Will ./configure be required in GAP 4.x?
# ./configure
make
# This patch may go away when GAP-4 is modified for GAPMPI conditionals
for file in bin/i?86-* ; do
  cp pkg/gapmpi/gap4b3-bin-i586-Makefile $file/Makefile
done
if [ ! -f bin/gap.sh ]; then
  echo $DESTDIR/bin/gap.sh missing from distribution.
  echo Can"'"t do make without it.
  exit
fi
if (uname -srm | grep 'Linux 2.*i[3-9]86' > /dev/null ); then
  make
else
  echo Not a Linux 2.x ix86 system
  echo You"'"ll have to modify your 'bin/*/Makefile'
  echo as in ../README.install-gapmpi or as in gap4b3-bin-i586-Makefile
  echo  unless the GAP 4.x autoconf now does that automatically for you.
  echo In a Sparc implementation, I was successful copying the i586 Makefile
  echo   to the 'bin/sparc-*' directory.  I had to remove the -export-dynamic
  echo   flag, since that is defined in GNU ld, and not in SUN ld.
fi
