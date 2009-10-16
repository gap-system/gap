#!/bin/sh

# This script will make a copy of the GAP distribution in your
# home directory as ~/mygap4beta, while using symbolic links for most files.
# So, it won't require much disk space, and you can still modify
#  private copies of the files.

#Link files from here:
GAP_DIR=/home/gene/gap4b3
#Link files to new directory, here:
DESTDIR=$HOME/mygap4beta

if [ ! -z $1 ]; then
  echo Will use:  GAP_DIR=$1
  GAP_DIR=$1
fi
if [ ! -z $2 ]; then
  echo Will use:  DESTDIR=$2
  DESTDIR=$2
fi

if [ -w $DESTDIR ]; then
  echo $DESTDIR already exists
  echo If you want to start over, try copying your files to a safe place, and:
  echo "    " rm -rf $DESTDIR
  exit
fi

if [ ! -x $GAP_DIR ]; then
  echo \$GAP_DIR, $GAP_DIR, at beginning of this script, does not exist,
  echo     or does not allow search permission.
  echo Looking for GAP_DIR in your default gap script:
  grep GAP_DIR= `which gap`
  exit
fi

echo Copying files into $DESTDIR/
echo If it doesn"'"t work \(due to quota or other random problems\), just
echo "   "  rm -r $DESTDIR/
echo fix the problem, and try again.
echo ""

mkdir $DESTDIR
cd $DESTDIR
ln -s $GAP_DIR/* .

rm bin
mkdir bin
for file in $GAP_DIR/bin/*
do
  if [ -d $file ]; then
    name=`basename $file`
    mkdir bin/$name
    ln -s $file/* bin/$name/
  fi
done
# sed -e s#$GAP_DIR#$DESTDIR#g $GAP_DIR/bin/gap.sh > ./bin/gap.sh
sed -e 's#GAP_DIR=.*$#GAP_DIR='$DESTDIR#g $GAP_DIR/bin/gap.sh > ./bin/gap.sh
chmod a+x ./bin/gap.sh

rm src
mkdir src
ln -s $GAP_DIR/src/* ./src/

cd src
cp -f Makefile tmp
mv -f tmp Makefile
cp -f gap.c tmp
mv -f tmp gap.c
rm -f ../bin/*/gap.o
# Hopefully, streams.c and funcs.c will be fixed in future GAP dist,
#    and this will go away.
cp -f streams.c tmp
mv -f tmp streams.c
rm -f ../bin/*/streams.o
cp -f funcs.c tmp
mv -f tmp funcs.c
rm -f ../bin/*/funcs.o
cd ..

rm lib
mkdir lib
ln -s $GAP_DIR/lib/* ./lib/
cd lib
rm -f slavelist.g masslave.g
cp -f init.g tmp
mv -f tmp init.g
cd ..

rm pkg
mkdir pkg
if [ -d $GAP_DIR/pkg ]; then
  ln -s $GAP_DIR/pkg/* ./pkg/
fi
rm -f $GAP_DIR/pkg/gapmpi

# Use src/Makefile and not Makefile
rm Makefile
for file in ./bin/*$ARCH*/gap; do
  rm -f $file
done
rm -f bin/*/gapmpi.o bin/*/gapmpi_0.o

echo ===========================
echo Now copy $DESTDIR/bin/gap.sh to $HOME/bin/mygap
echo To run it, call:    mygap
echo To re-make: "       " cd $DESTDIR/src \;  make
echo
echo See comment at end of this file about how to make private copies
echo      of files for your own system development.

#Continue to use this procedure to set up private files:
#  cd $DESTDIR/src
#  cp -f read.c tmp
#  mv -f tmp read.c
#  rm -f ../bin/*/read.o
