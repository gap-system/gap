#############################################################################
##
#W  factintaux.g              GAP4 Package `FactInt'              Stefan Kohl
##
##  This file contains auxiliary functions for the FactInt package.
##
#############################################################################

#############################################################################
##
#F  FactIntBuildManual( ) . . . . . . . . . . . . . . . . .  build the manual
##
##  This function builds the manual of the FactInt package in the file
##  formats LaTeX, PDF, HTML and ASCII-text.
##
##  This is done using the GAPDoc package by Frank Lübeck and Max Neunhöffer.
##
BindGlobal( "FactIntBuildManual", 

  function ( )

    local  FactIntDir;

    FactIntDir := GAPInfo.PackagesInfo.("factint")[1].InstallationPath;
    MakeGAPDocDoc( Concatenation( FactIntDir, "/doc/" ), "factint.xml",
                   [ "../gap/factintaux.g", "../gap/factint.gd",
                     "../gap/general.gi", "../gap/pminus1.gi",
                     "../gap/pplus1.gi", "../gap/ecm.gi",
                     "../gap/cfrac.gi", "../gap/mpqs.gi" ],
                     "FactInt", "../../../" );
  end );

#############################################################################
##
#E  factintaux.g . . . . . . . . . . . . . . . . . . . . . . . . .  ends here