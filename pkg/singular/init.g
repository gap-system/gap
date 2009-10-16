#############################################################################
##
#W    init.g               Package singular            Willem de Graaf
#W                                                     Marco Costantini
##
#H    @(#)$Id: init.g,v 1.9 2006/07/23 20:05:30 gap Exp $
##
#Y    Copyright (C) 2003 Willem de Graaf and Marco Costantini
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##


# For backward compatibility: announce the package version.

DeclarePackage( "singular", "06.07.23", true );
DeclarePackageDocumentation( "singular", "doc" );

# Read the files...

ReadPkg( "singular", "gap/singular.gd" );
ReadPkg( "singular", "gap/singular.g" );



#############################################################################
#E
