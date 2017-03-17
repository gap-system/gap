@echo off

rem  gap.cmd                    GAP                             Norbert Dragon
rem 
rem  This is a  command file for OS/2 that starts GAP. Here  you  can make all
rem  the  necessary  customizations.

rem  Then copy this file to a  directory in your  search path,  e.g., '~/bin'.
rem  If you later move GAP to another location you must only change this file.

rem  First change to the drive where GAP is installed by e.g. the command 'd:'
rem  I like to work in a subdirectory \gap4b2\tmp (which one has to mkdir), so
rem  I change into that directory by 'cd \gap4b2\tmp'.

rem  The template for the command starting GAP is

rem  GAP_DIR\bin\GAP_PRG -N -M -m GAP_MEM -l GAP_LIB


rem  'GAP_DIR' is  the  directory  where  you  have  installed  GAP, i.e., the 
rem  directory with the subdirectories  'lib',  'grp', 'doc', etc. For example
rem  '\gap4b2'.

rem  'GAP_PRG' is  the  name  of  the  executable  program of  the GAP kernel.
rem  e.g. 'gapemx.exe'


rem  'GAP_MEM' is  the amount of  memory  GAP shall use as  initial workspace.
rem  The default is 8 MByte, which is the minimal reasonable amount of memory.
rem  You have to change it if you want  GAP to use a larger initial workspace.
rem  If you are not going to run  GAP  in parallel with other programs you may
rem  want to set this value close to the  amount of memory your  computer has.
rem  e.g. '-m 16m' makes GAP start with 16 MBytes workspace.


rem  'GAP_LIB' is the same directory as GAP_DIR written, however, with slashes
rem  rather than with backslashes. This is because OS/2 cmd.exe needs the path 
rem  of an  executable specified  with  backslashes  while  GAP  uses  slashes 
rem  internally and does not allow a colon ':' in a path. This is also why  we
rem  change to the drive (e.g.'d:') where GAP is installed before we start GAP. 

rem  You should now be able to adapt the following lines, which work for me, to
rem  your installation.

d:
cd \gap4b2\tmp
\gap4b2\bin\gapemx.exe -N -M -m 16m -l /gap4b2
