#!/bin/sh
#
#  $Id$   Frank Lübeck
#
# Use this script inside the $GAPHOME directory (the top directory
# containing 'bin', 'lib', 'pkg' and so on as subdirectories) to 
# generate a workspace file:
#     bin/wsgap4
#

# the -N option is to really load the code, not completion files
bin/i686-pc-linux-gnu-gcc/gap -l `pwd` -N -r > /dev/null <<EOF
ANSI_COLORS := true;
# load here all packages you want to include in the standard workspace
for nam in [ "atlasrep", "autpgrp", "carat", "cohomolo", "crisp", "cryst", 
      "crystcat", "ctbllib", "edim", "factint", "format", "gapdoc", "grape", 
      "grpconst", "kbmag", "laguna", "quagroup" ]do
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
SaveWorkspace("bin/wsgap4");

quit;
EOF


