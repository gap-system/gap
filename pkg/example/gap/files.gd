#############################################################################
####
##
#W  files.gd                   Example Package                  Werner Nickel
##
##  Declaration file for functions of the Example package.
##
#H  @(#)$Id: files.gd,v 1.2 2002/02/12 18:08:35 gap Exp $
##
#Y  Copyright (C) 1999,2001 University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##
Revision.("example/gap/files_gd") := 
    "@(#)$Id: files.gd,v 1.2 2002/02/12 18:08:35 gap Exp $";

#############################################################################
##
#F  EgSeparatedString( <str>, <c> ) . . . . . . . .  cut a string into pieces
##
DeclareGlobalFunction( "EgSeparatedString" );

#############################################################################
##
#F  ListDirectory([<dir>])  . . . . . . . . . . list the files in a directory
##
DeclareGlobalFunction( "ListDirectory" );

#############################################################################
##
#F  FindFile( <dir>, <file> ) . . . . . . . . find a file in a directory tree
##
DeclareGlobalFunction( "FindFile" );

#############################################################################
##
#F  LoadedPackages() . . . . . . . . . . . . which share packages are loaded?
##
DeclareGlobalFunction( "LoadedPackages" );

#############################################################################
##
#F  Which( <prg> )  . . . . . . . . . . . . which program would Exec execute?
##
DeclareGlobalFunction( "Which" );

#############################################################################
##
#F  WhereIsPkgProgram( <prg> ) . . . . the paths of any matching pkg programs
##
DeclareGlobalFunction( "WhereIsPkgProgram" );

#############################################################################
##
#F  HelloWorld() . . . . . . . . . . . . . . . . . . . . . . . . . . . guess!
##
DeclareGlobalFunction( "HelloWorld" );

#############################################################################
##
#V  FruitCake . . . . . . . . . . . . . things one needs to make a fruit cake
##
DeclareGlobalVariable( "FruitCake",
   "record with the bits and pieces needed to make a boiled fruit cake");

#############################################################################
##
#O  Recipe( <cake> ) . . . . . . . . . . . . . . . . . . . . display a recipe
##
DeclareOperation( "Recipe", [ IsRecord ] );

#E  files.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
