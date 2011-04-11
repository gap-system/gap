#!/bin/sh
#############################################################################
##
#W  mkxdiff.sh       Differences of GAP manual examples        Volkmar Felsch
##
#H  $Id$
##
#Y  Copyright (C) 2002, Lehrstuhl D für Mathematik, RWTH Aachen, Germany
##
##  mkxdiff.sh [-c] [-p path] [-s suffix] [file1 file2 ...]
##
##  For each of the specified files names, 'mkxdiff.sh' compares the manual
##  file (suffix '.xml') with the test file (suffix '.tst') and writes the
##  differences for all these files to a file 'diffs'.
##
##  If '-c' is specified then use the context output format of the 'diff'
##  command.
##
##  If '-p path' is specified then that path is assumed to be the path of the
##  directory which contains the given manual files (the default path is
##  '../').
##
##  If '-s suffix' is specified then that suffix is assumed to be the suffix
##  of the manual files (the default suffix is '.xml').
##
##  If no file names are specified then all files with suffix '.tst' in the
##  current directory are handled.
##

#############################################################################
##
##  Parse the arguments.
##
context=""
path="../"
suffix=".xml"
option="yes"

while [ $option = "yes" ]; do
  option="no"
  case $1 in

    -c)  shift; option="yes"; context="-c";;

    -p)  shift; option="yes"; path=$1; shift;;

    -s)  shift; option="yes"; suffix=$1; shift;;

  esac
done

#############################################################################
##
##  Get a list of the file names to be handled.
##
if [ $# = 0 ]; then
  ls *.tst > @.files
  ed - @.files << \%
    1,$s/\.tst$//
    w
%
else
  touch @.files
  rm @.files
  touch @.files
  for i
  do
    echo $i >> @.files
  done
fi

#############################################################################
##
##  Initialize the resulting list of differences.
##
echo "$path (`date -u`)" > diffs

#############################################################################
##
##  Loop over the given files.
##
for i in `cat @.files`
do
  echo '=================================  '$i'  ================================' >> diffs
  echo ' ' >> diffs
  diff -b -B $context $path$i$suffix $i.tst >> diffs
  echo ' ' >> diffs
done

#############################################################################
##
##  Close the list.
##
echo '============================================================================' >> diffs
echo ' ' >> diffs
rm @.files

