#!/bin/bash
#
#  (C) Frank Lübeck
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

bin/$arch*/gap -l `pwd`"/local;"`pwd`  -r > /dev/null <<EOF

# load here all packages you want to include in the standard workspace
for nam in [ "atlasrep", "autpgrp", "browse", "cohomolo", "crisp", "cryst", 
      "crystcat", "ctbllib", "edim", "factint", "format", "grape", 
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


