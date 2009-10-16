#############################################################################
##
#W    init.g               share package 'grpconst'        Hans Ulrich Besche
##                                                               Bettina Eick

#############################################################################
##
#D Declare the package
##
DeclarePackage( "grpconst", "2.0", 
    function()

    if VERSION{[1,2,3]} <> "4.1" then
        return true;
    else
        Print("The versions of grpconst and GAP4 you are using\n");
        Print("are not compatible. You need at least version 4.2 of\n");
        Print("GAP to work with this version of grpconst.\n");
        return false;
    fi;

    end );
DeclarePackageDocumentation( "grpconst", "doc" );

#############################################################################
##
#D Require other packages
##
RequirePackage( "autpgrp" );

#############################################################################
##
#D Read .gd files
##
ReadPkg( "grpconst/gap/grpconst.gd");


