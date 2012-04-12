#!/bin/sh
#############################################################################  
## 
## The script to test all *.tst files in the current directory 
##
TESTGAP="../../../bin/gap.sh -L ../wsp.g -b -m 100m -o 500m -A -N -x 80 -r -T" 
ls *.tst > list.files
  ed - list.files << \%
    1,$s/^.*\///
    1,$s/\..*$//
    w
%
if test -e diffs; then rm diffs; fi
for i in `cat list.files`
do
  echo $i
  echo $i >> diffs
  echo 'r:=ReadTest( "'$i'" );' | $TESTGAP >> diffs
  echo '============================================================' >> diffs
  echo '============================================================' 
done
echo ''
echo '############################################################'
rm list.files