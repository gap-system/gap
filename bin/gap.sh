#!/bin/sh
#############################################################################
##
##  gap.sh                      GAP                          Martin Schoenert
##
##  This is a shell script for the  UNIX  operating system  that starts  GAP.
##  This is the place  where  you  make  all  the  necessary  customizations.
##  Then copy this file to a  directory in your  search path,  e.g., '~/bin'.
##  If you later move GAP to another location you must only change this file.
##


#############################################################################
##
##  GAP_DIR . . . . . . . . . . . . . . . . . . . . directory where GAP lives
##
##  Set 'GAP_DIR' to the name of the directory where you have installed  GAP,
##  i.e., the directory with the subdirectories  'lib',  'grp',  'doc',  etc.
##  The default is '/usr/local/lib/gap3r4p4',  which is a  standard location.
##  You have to change this unless you have installed  GAP in this  location.
##
if [ "x$GAP_DIR" = "x" ];  then
GAP_DIR=/usr/local/lib/gap4beta
fi


#############################################################################
##
##  GAP_MEM . . . . . . . . . . . . . . . . . . . amount of initial workspace
##
##  Set 'GAP_MEM' to the amount of memory GAP shall use as initial workspace.
##  The default is 8 MByte, which is the minimal reasonable amount of memory.
##  You have to change it if you want  GAP to use a larger initial workspace.
##  If you are not going to run  GAP  in parallel with other programs you may
##  want to set this value close to the  amount of memory your  computer has.
##
if [ "x$GAP_MEM" = "x" ];  then
GAP_MEM=8m
fi


#############################################################################
##
##  GAP_PRG . . . . . . . . . . . . . . . . .  name of the executable program
##
##  Set 'GAP_PRG' to the  name of the executable  program of the  GAP kernel.
##  The  default is  '`hostname'/gap'.    You  can   either change this    to
##  '<target>/gap' where <target> is the  target you have selected during the
##  compilation or create  a symbolic link  from <target> to  '`hostname`' in
##  the 'bin' directory.
##
if [ "x$GAP_PRG" = "x" ];  then
GAP_PRG=`hostname`/gap
fi


#############################################################################
##
##  GAP . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . run GAP
##
##  You  probably should  not change  this line,  which  finally starts  GAP.
##
exec $GAP_DIR/bin/$GAP_PRG -m $GAP_MEM -l $GAP_DIR $*
