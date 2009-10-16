#############################################################################
##
#W  init.gd                    GAP library                     Volkmar Felsch
##                                                              Franz Gaehler
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

DeclareAutoPackage( "crystcat", "1.1.1", function()
  if TestPackageAvailability( "cryst", "4.1" ) = fail then
    Info( InfoWarning, 3, "package ``crystcat'' requires package ``cryst''" );
     return false;
  else
     return true;
  fi;
end );

DeclarePackageAutoDocumentation( "crystcat", "doc" );

ReadPkg( "crystcat", "lib/crystcat.gd" );

RequirePackage( "cryst" );

