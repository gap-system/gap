#############################################################################
##
#W init.g                  POLENTA package                     Bjoern Assmann
##
##
#H  @(#)$Id: init.g,v 1.3 2006/03/14 16:45:30 gap Exp $
##
#Y 2003
##


DeclarePackage( "polenta", "1.1", function() return true; end );
#DeclarePackageDocumentation( "polenta", "doc" );
 
#############################################################################
#R  read .gd files
##
ReadPkg( "polenta/lib/finite.gd" );
ReadPkg( "polenta/lib/info.gd" );
ReadPkg( "polenta/lib/basic.gd" );
ReadPkg( "polenta/exam/test.gd" );

ReadPkg( "polenta/lib/cpcs.gd" );
ReadPkg( "polenta/lib/present.gd" );
ReadPkg( "polenta/lib/solvable.gd" );
ReadPkg( "polenta/lib/series.gd" );
ReadPkg( "polenta/lib/subgroups.gd" );
ReadPkg( "polenta/lib/ispolyz.gd" );

############################################################################
#R  read other packages
##
RequirePackage( "polycyclic" );
RequirePackage( "alnuth" );
RequirePackage( "aclib" );

#############################################################################
##
#E


