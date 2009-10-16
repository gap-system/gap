#!/bin/bash
#
#  $Id: CreateWorkspace.sh,v 1.7 2007/10/04 15:01:50 gap Exp $   Frank Lübeck
#
# Use this script inside the $GAPHOME directory (the top directory
# containing 'bin', 'lib', 'pkg' and so on as subdirectories) to 
# generate a workspace file:
#     bin/wsgap4
#

arch=$1
if [ $arch'X' = 'X' ]; then
  arch=i686
fi
if [ $arch'X' = 'i686X' ]; then
  wsname=wsgap4
else
  wsname=ws64gap4
fi

# the -N option is to really load the code, not completion files
bin/$arch*/gap -l `pwd`"/local;"`pwd` -N -r > /dev/null <<EOF

##  comment this if you don't want colors to be used by default, e.g. when
##  GAPDoc produced manual pages are displayed on screen.
ANSI_COLORS := true;

##  uncomment these two lines, if you want a colored prompt as default
#ReadLib("colorprompt.g");


# load here all packages you want to include in the standard workspace
for nam in [ "atlasrep", "autpgrp", "carat", "cohomolo", "crisp", "cryst", 
      "crystcat", "ctbllib", "edim", "factint", "format", "gapdoc", "grape", 
      "grpconst", "guava", "kbmag", "laguna", "quagroup" ] do
  LoadPackage(nam);
od;
Unbind(nam);

# load help book infos with a dummy help query
??blablfdfhskhks

# a small trick to make everything sensible available to the TAB completion
function() local a; for a in NamesGVars() do if ISB_GVAR(a) then
VAL_GVAR(a); fi;od;end;
last();

# save the workspace
SaveWorkspace("bin/$wsname");

quit;
EOF


