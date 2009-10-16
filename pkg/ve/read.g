#############################################################################
##
#W  init.g                       VE library                     Thomas Breuer
##
#H  @(#)$Id: read.g,v 1.1 2001/08/29 09:08:41 sal Exp $
##
#Y  Copyright (C) 1998,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##

# announce the package version and test for the existence of the binary
DeclarePackage("ve","0.0",ReturnTrue);

# install the documentation
DeclarePackageDocumentation( "ve", "doc" );


ReadPkg( "ve", "read.g" );
#############################################################################
##

#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

