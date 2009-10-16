#############################################################################
##
#W    read.g                    share package                   Karel Dekimpe
#W                                                               Bettina Eick
##

# read matrix groups 
ReadPkg( "aclib", "gap/matgrp3.gi" );
ReadPkg( "aclib", "gap/matgrp4.gi" );
ReadPkg( "aclib", "gap/matgrp.gi" );

# read corresponding pcp groups - only if polycyclic is installed
if pc = true then 
    ReadPkg( "aclib", "gap/pcpgrp3.gi" );
    ReadPkg( "aclib", "gap/pcpgrp4.gi" );
    ReadPkg( "aclib", "gap/pcpgrp.gi" );

    ReadPkg( "aclib", "gap/betti.gi" );
    ReadPkg( "aclib", "gap/union.gi" );
    ReadPkg( "aclib", "gap/extend.gi" );
else
    Print("#I The polycyclic package is not installed \n");
    Print("#I Cannot load pc group functionality \n");
fi;

# read some help functions to work with crystallographic groups
if cs = true then
    ReadPkg( "aclib", "gap/crystgrp.gi" );
else
    Print("#I The crystcat package is not installed \n");
    Print("#I Cannot load crystallographic groups functionality \n");
fi;

