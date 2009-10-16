#############################################################################
##
#W    init.g               share package 'Cubefree'            Heiko Dietrich
##
#H   @(#)$Id: init.g,v 1.2 2007/05/08 08:00:15 gap Exp $
##                                                             

#############################################################################
##
#D Declare the package
##
DeclarePackage( "Cubefree", "1.0",
    function()

    if VERSION{[1,2,3]} <> "4.1" then
        return true;
    else
        Print("The versions of Cubefree and GAP4 you are using\n");
        Print("are not compatible. You need at least version 4.2 of\n");
        Print("GAP to work with this version of Cubefree.\n");
        return false;
    fi;

    end );
DeclarePackageDocumentation( "Cubefree", "doc" );

############################################################################
##
#I InfoClass
##
DeclareInfoClass( "InfoCF" );

#############################################################################
##
#D Read .gd files
##
ReadPackage("cubefree","gap/allCubeFree.gd");
ReadPackage("cubefree","gap/cubefree.gd");
ReadPackage("cubefree","gap/frattExt.gd");
ReadPackage("cubefree","gap/frattFree.gd");
ReadPackage("cubefree","gap/glasby.gd");
ReadPackage("cubefree","gap/irrGL2.gd");
ReadPackage("cubefree","gap/number.gd");
ReadPackage("cubefree","gap/prelim.gd");
