#!/bin/sh
# usage: configure gappath
# this script creates a `Makefile' from `Makefile.in' 
if test -z $1; then 
  GAPPATH=../..; echo "Using ../.. as default GAP path"; 
else 
  GAPPATH=$1; 
fi
if ! test -e $GAPPATH/sysinfo.gap; then
  echo "Please give correct GAP path as argument (and make sure that GAP"
  echo "is already properly installed)."
  exit
fi

. $GAPPATH/sysinfo.gap
sed -e "s|@GAPARCH@|$GAParch|g" Makefile.in > Makefile
echo "Makefile successfully created."
