#############################################################################
##
#W    init.g               OpenMath Package            Andrew Solomon
#W                                                     Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##    init.g file
##

#############################################################################
#
# Reading configuration file
#
ReadPackage("openmath", "config.g");

#############################################################################
#
# Reading *.gd files
#
ReadPackage("openmath", "/gap/parse.gd");
ReadPackage("openmath", "/gap/xmltree.gd");
ReadPackage("openmath", "/gap/omget.gd");
ReadPackage("openmath", "/gap/omput.gd");
ReadPackage("openmath", "/gap/test.gd");

#############################################################################
##
## Reading *.g files organised into modules
##
#############################################################################
## Module 1: conversion from OpenMath to Gap
#################################################################
## Module 1.1 
## This module contains the semantic mappings from parsed openmath
## symbols to GAP objects and provides the function OMsymLookup

ReadPackage("openmath", "/gap/gap.g");


#################################################################
## Module 1.2.b
## This module converts the OpenMath XML into a tree and parses it;
## requires the function OMsymLookup (and the function 
## ParseTreeXMLString from package GapDoc) and provides 
## the function OMgetObjectXMLTree

if IsBound( ParseTreeXMLString )  then
    ReadPackage("openmath", "/gap/xmltree.g");
fi;

#################################################
# patch for HexStringBlist

if not CompareVersionNumbers( GAPInfo.Version, "4.5.0") then

MakeReadWriteGlobal("HexStringBlist");

HexStringBlist := function ( b )
   local  i, n, s;
   HexBlistSetup(  );
   n := Length( b );
   i := 1;
   s := "";
   while i + 7 <= n  do
       Append( s, HEXBYTES[PositionSorted( BLISTBYTES, b{[ i .. i + 7 ]} )] );
       i := i + 8;
   od;
   b := b{[ i .. n ]};
   if Length( b ) = 0  then
       return s;
   fi;
   while Length( b ) < 8  do
       Add( b, false );
   od;
   Append( s, HEXBYTES[PositionSorted( BLISTBYTES, b )] );
   return s;
end;

MakeReadOnlyGlobal("HexStringBlist");

fi;


#################################################################
## Module 1.3
## This module gets exactly one OpenMath object from <input stream>;
## provides the function PipeOpenMathObject

ReadPackage("openmath", "/gap/pipeobj.g");


#############################################################################
##
## Binary OpenMath --> GAP
##
ReadPackage("openmath", "/gap/const.g");
ReadPackage("openmath", "/gap/binread.g");


#################################################################
## Module 1.4
## This module converts one OpenMath object to a Gap object; requires
## PipeOpenMathObject and one of the functions OMpipeObject or
## OMgetObjectXMLTree and provides OMGetObject

ReadPackage("openmath", "/gap/omget.g");

# file containing updates
ReadPackage("openmath", "/gap/new.g");

#############################################################################
## Module 2: conversion from Gap to OpenMath
## (Modules 1 and 2 are independent)

#################################################################
## Module 2.1 
## This module is concerned with outputting OpenMath; 
## It provides OMPutObject and OMPrint in "/gap/omput.gi"


#################################################################
## Module 2.2
## This module is concerned with viewing Hasse diagrams;
## requires the variables defined in gap/omput.gd

ReadPackage("openmath", "/hasse/config.g");
ReadPackage("openmath", "/hasse/hasse.g");


#############################################################################
## Module 3: test
## Provides the function OMTest for testing OMGetObject.OMPutObject = id
## requires OMGetObject and OMPutObject

ReadPackage("openmath", "/gap/test.g");


#############################################################################
#E
