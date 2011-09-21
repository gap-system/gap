#!/bin/sh
#############################################################################
##
#W  mkxtest.sh      Test the examples in GAP manual files      Volkmar Felsch
##
#H  $Id$
##
#Y  Copyright (C) 2002, Lehrstuhl D für Mathematik, RWTH Aachen, Germany
##
##  mkxtest.sh [-f] [-i] [-o] [-d] [-c] [-p path] [-s suffix] [-r package]
##            [file1 file2 ...]
##
##  For each of the specified manual files, 'mkxtest.sh' runs all examples
##  given in that file and constructs a new version of the file which is
##  up-to-date with respect to the output of the examples. The new file gets
##  the suffix '.tst'.
##
##  If '-f' is specified then a full test (including the 'no test' examples)
##  is done.
##
##  If '-i' is specified then the input file for the examples is saved
##  (suffix '.in').
##
##  If '-o' is specified then the output file of the examples is saved
##  (suffix '.out').
##
##  If '-d' is specified then, in addition to the new manual file itself, a
##  file with suffix '.dif' is provided which lists all differences between
##  the old and the new manual file.
##
##  If '-c' is specified then use the context output format of the 'diff'
##  command. This option has no effect if the option '-d' is not specified.
##
##  If '-p path' is specified then that path is assumed to be the path of the
##  directory which contains the given manual files (the default path is
##  '../').
##
##  If '-s suffix' is specified then that suffix is assumed to be the suffix
##  of the manual files (the default suffix is '.xml').
##
##  If '-r package' is specified then GAP will load the package 'package'
##  before running the examples. The option '-r' may be specified more than
##  once if there are more than one packages to be loaded.
##
##  If '-R' is specified then GAP will call 'LoadAllPackages()' before the
##  tests, which loads all available packages.
##  (The default is to load no package.)
##
##  If '-L wspfile' is specified then GAP will load the workspace in
##  'wspfile'.
##
##  If no file names are specified then all files with the given suffix in
##  the directory with the given suffix are handled.
##
##  This test reported to be not working in the UNIX version of GAP under 
##  MAC OS X.

#############################################################################
##
##  Define the local call of GAP.
##
gap="../../bin/gap.sh -b -m 100m -o 500m -A -N -x 80 -r -T"


#############################################################################
##
##  Initialize the input file.
##
echo ' ' > @.pack


#############################################################################
##
##  Parse the arguments.
##
full_test="no"
save_input="no"
save_output="no"
save_dif="no"
context=""
path="../"
suffix=".xml"
wspfile="-"
option="yes"

while [ $option = "yes" ]; do
  option="no"
  case $1 in

    -f) shift; option="yes"; full_test="yes";;

    -i) shift; option="yes"; save_input="yes";;

    -o) shift; option="yes"; save_output="yes";;

    -d) shift; option="yes"; save_dif="yes";;

    -c) shift; option="yes"; context="-c";;

    -p) shift; option="yes"; path=$1; shift;;

    -s) shift; option="yes"; suffix=$1; shift;;

    -r) shift; option="yes"; echo 'LoadPackage("'$1'");' >> @.pack; shift;;

    -R) shift; option="yes"; echo 'LoadAllPackages();' >> @.pack;;

    -L) shift; option="yes"; wspfile=$1; shift;;

  esac
done

#############################################################################
##
##  Get a list of the file names to be handled.
##
if [ $# = 0 ]; then
  ls $path*$suffix > @.files
  ed - @.files << \%
    1,$s/^.*\///
    1,$s/\..*$//
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
##  Loop over the given files.
##
for i in `cat @.files`
do

#############################################################################
##
##  Initialize the new manual file by a copy of the old one.
##
echo "testing "$i$suffix
old=$path$i$suffix
cp $old @.new
chmod 644 @.new

#############################################################################
##
##  Add a dummy example to make sure that there is at least one example to be
##  handled.
##
ed - @.new << \%
  $a
dummy example:
<Example>
<![CDATA[
gap> dummy:=true;;
]]>
</Example>
.
  1,$s/ *<!\[CDATA\[/gap> # &/
  1,$s/^ *]]>/gap> # &/
  w
%

#############################################################################
##
##  If the 'no test' examples are to be checked add a dummy example (to
##  ensure that the following works), change all 'no test' examples to
##  ordinary examples, and remove the dummy again.
##
if [ $full_test = "yes" ]; then
  ed - @.new << \%
    0a
<Log>
</Log>
.
    1,$s/<Log>/<Example>Log/
    1,$s/<\/Log>/<\/Example>Log/
    1,2d
    w
%
fi

#############################################################################
##
##  Construct the input file:
##
##  Get a copy of the file,
##  remove all lines outside of the examples,
##  remove all output lines from the examples,
##  remove the prompts from the input lines,
##  insert approriate calls of the function 'LogTo' to write each example to
##  a separate file,
##
cp @.new @.in

ed - @.in << \%
  $a
dummy
</Example>
.
  1,/^ *<Example>/-1d
  $d
  1,$g/^ *\<\/Example>/+1,/^ *\<Example>/-1d
  1,$s/^/#@ /
  1,$s/^#@ [gap]*> /@&/
  1,$s/^.*<Example>/@&/
  1,$s/^.*<\/Example>/@&/
  1,$v/^@#@/d
  1,$s/@#@ //
  1,$s/[gap]*> //
  1,$s/^.*<Example>.*$/E_1:=last;E_0:=E_0+1;E_2:=E_1;/
  1,$s/;E_2:=E_1;/&LogTo(Concatenation("@tmp",String(E_0)));/
  1,$s/^.*<\/Example>.*/LogTo(   );/
  $a
quit;
.
  0r @.pack
  0a
E_0:=10000;
.
  w
%

#############################################################################
##
##  Run the examples.
##
touch @tmp
rm @tmp*
if [ $wspfile = "-" ]; then
  $gap < @.in > /dev/null
else
  $gap -L $wspfile < @.in > /dev/null
fi
cat @tmp* > @.out

#############################################################################
##
##  Remove the 'LogTo' statements from the output file.
##
ed - @.out << \%
  $a
LogTo(   ); gap> LogTo(   );
.
  1,$s/.gap> LogTo(   );/&@/
  1,$s/LogTo(   );@//
  1,$g/LogTo(   );/d
  w
%

#############################################################################
##
##  Insert the output of the examples into the new manual file.
##
ed - @.new << \%
  1,$s/<Example>/<Example1>/
  1,$s/<\/Example>/<\/Example1>/
  w
%

ls @tmp* > @.ls

for j in `cat @.ls`
do
  cp $j @tmpj

  ed - @tmpj << \%
    $a
.
    w
%

  ed - @.new << \%
    /<Example1>/s/Example1/Example2/
    /<\/Example1>/s/Example1/Example2/
    /<Example2>/+1,/<\/Example2>/-1d
    /<Example2>/r @tmpj
    /<Example2>/s/Example2/Example/
    /<\/Example2>/s/Example2/Example/
    w
%
done

#############################################################################
##
##  Remove the 'LogTo' statements and the dummy example from the new manual
##  file.
##
ed - @.new << \%
  $a
LogTo(   ); gap> LogTo(   );
.
  1,$s/.gap> LogTo(   );/&@/
  1,$s/LogTo(   );@//
  1,$g/LogTo(   );/d
  1,$s/^gap> # *<!\[CDATA\[/@@&/
  1,$s/^gap> # *]]>/@@&/
  1,$s/^@@gap> # //
  $-5,$d
  w
%

#############################################################################
##
##  If 'no test' examples are being checked add a dummy example (to ensure
##  that the following works), change the 'no test' examples back to what
##  they were before, and remove the dummy again.
##
if [ $full_test = "yes" ]; then
  ed - @.new << \%
    0a
<Example>Log
</Example>Log
.
    1,$s/<Example>Log/<Log>/
    1,$s/<\/Example>Log/<\/Log>/
    1,2d
    w
%
fi

#############################################################################
##
##  Save a file which lists the differences between the old and the new file.
##
if [ $save_dif = "yes" ]; then
  diff $context $old @.new > $i.dif
fi

#############################################################################
##
##  Save the new file.
##
mv @.new $i.tst

#############################################################################
##
##  Remove the dummy example from the input file and save it.
##
if [ $save_input = "yes" ]; then
  ed - @.in << \%
    1,$g/^#<!\[CDATA\[$/d
    1,$g/^#]]>$/d
    $-3,$-1d
    w
%
  mv @.in $i.in
else
  rm @.in
fi

#############################################################################
##
##  Remove the dummy example from the output file and save it.
##
if [ $save_output = "yes" ]; then
  ed - @.out << \%
    1,$g/^gap>#<!\[CDATA\[$/d
    1,$g/^gap>#]]>$/d
    $d
    w
%
  mv @.out $i.out
else
  rm @.out
fi

#############################################################################
##
done
rm @.files @.ls @.pack @tmp*

