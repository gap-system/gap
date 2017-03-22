#!/bin/bash
export SOURCE=/usr/share/terminfo
rm -rf terminfo
mkdir terminfo 
mkdir terminfo/c 
mkdir terminfo/r
mkdir terminfo/x
mkdir terminfo/63
mkdir terminfo/72
mkdir terminfo/78
if test -r $SOURCE/c/cygwin ; then
  cp $SOURCE/c/cygwin terminfo/c
  cp $SOURCE/c/cygwin terminfo/63
elif test -r $SOURCE/63/cygwin ; then
  cp $SOURCE/63/cygwin terminfo/c
  cp $SOURCE/63/cygwin terminfo/63
else
  echo "No terminfo entry for cygwin found!"
  exit 1
fi
if test -r $SOURCE/r/rxvt ; then
  cp $SOURCE/r/rxvt terminfo/r
  cp $SOURCE/r/rxvt terminfo/72
elif test -r $SOURCE/72/rxvt ; then
  cp $SOURCE/72/rxvt terminfo/r
  cp $SOURCE/72/rxvt terminfo/72
else
  echo "No terminfo entry for rxvt found!"
  exit 1
fi
if test -r $SOURCE/x/xterm ; then
  cp $SOURCE/x/xterm terminfo/x
  cp $SOURCE/x/xterm terminfo/78
elif test -r $SOURCE/78/xterm ; then
  cp $SOURCE/78/xterm terminfo/x
  cp $SOURCE/78/xterm terminfo/78
else
  echo "No terminfo entry for xterm found!"
  exit 1
fi
exit 0
