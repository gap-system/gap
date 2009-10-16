#############################################################################
##
#W    init.g               OpenMath Package            Andrew Solomon
#W                                                     Marco Costantini
##
#H    @(#)$Id: init.g,v 1.29 2009/05/26 16:42:07 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##    init.g file
##

Revision.("openmath/init.g") :=
    "@(#)$Id: init.g,v 1.29 2009/05/26 16:42:07 alexk Exp $";

# If SuppressOpenMathReferences is set to true, then 
# OMPutReference (gap/omput.gi) will put the actual 
# OpenMath code for an object whenever it has id or not.
# This might be needed for compatibility with some systems.
SuppressOpenMathReferences:=false;

# For backward compatibility

if not IsBound( Float )  then
    Float := ReturnFail;
fi;

if not CompareVersionNumbers( VERSION, "4.4" )  then

    # announce the package version and test for the existence of the binary
    DeclarePackage( "openmath", "10.0.4", ReturnTrue );

    # install the documentation
    DeclarePackageDocumentation( "openmath", "doc" );

    ReadPackage := ReadPkg;
    LoadPackage := RequirePackage;

    LoadPackage( "gapdoc" );


  InstallMethod( String,
    "record", true,
    [ IsRecord ], 0,
    function( record )
    local   str,  nam,  com;

    str := "rec( ";
    com := false;
    for nam in RecNames( record ) do
      if com then
        Append( str, ", " );
      else
        com := true;
      fi;
      Append( str, nam );
      Append( str, " := " );
      if IsStringRep( record.( nam ) )
         or ( IsString( record.( nam ) )
              and not IsEmpty( record.( nam ) ) ) then
        Append( str, "\"" );
        Append( str, String( record.(nam) ) );
        Append( str, "\"" );
      else
        Append( str, String( record.(nam) ) );
      fi;
    od;
    Append( str, " )" );
    ConvertToStringRep( str );
    return str;
  end );


 if not CompareVersionNumbers( VERSION, "4.3" )  then

  MakeReadWriteGlobal("ListWithIdenticalEntries");
  ListWithIdenticalEntries := function ( n, obj )
    local  list, i, c;
    if n > 0 and IS_FFE( obj ) and IsZero( obj )  then
        c := Characteristic( obj );
        if c = 2  then
            return ZERO_GF2VEC_2( n );
        elif c <= 256  then
            return ZERO_VEC8BIT_2( c, n );
        fi;
    fi;
    if IsChar( obj )  then
        list := "";
        for i  in [ 1 .. n ]  do
            list[i] := obj;
        od;
    else
        list := [  ];
        for i  in [ n, n - 1 .. 1 ]  do
            list[i] := obj;
        od;
    fi;
    return list;
  end;
  MakeReadOnlyGlobal("ListWithIdenticalEntries");

 fi;

fi;

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
## Module 1.2.a
## This module reads token/values off the stream and builds GAP objects;
## uses the external binary gpipe, 
## requires the function OMsymLookup and provides OMpipeObject
## Directories bin, include, OMCv1.3c, src belongs to this module.

ReadPackage("openmath", "/gap/lex.g");
ReadPackage("openmath", "/gap/parse.gi");

# test for existence of the compiled binary
if Filename(DirectoriesPackagePrograms("openmath"), "gpipe") = fail  then
    Info( InfoWarning, 1,
     "Warning: package openmath, the program `gpipe' is not compiled." );
fi;


#################################################################
## Module 1.2.b
## This module converts the OpenMath XML into a tree and parses it;
## requires the function OMsymLookup (and the function 
## ParseTreeXMLString from package GapDoc) and provides 
## the function OMgetObjectXMLTree

if IsBound( ParseTreeXMLString )  then
    ReadPackage("openmath", "/gap/xmltree.g");
fi;


#################################################################
## Module 1.3
## This module gets exactly one OpenMath object from <input stream>;
## provides the function PipeOpenMathObject


ReadPackage("openmath", "/gap/pipeobj.g");


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
