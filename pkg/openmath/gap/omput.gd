#######################################################################
##
#W  omput.gd                OpenMath Package           Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: omput.gd,v 1.14 2009/05/09 11:07:59 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Writes a GAP object to an output stream, as an OpenMath object
## 

Revision.("openmath/gap/omput.gd") := 
    "@(#)$Id: omput.gd,v 1.14 2009/05/09 11:07:59 alexk Exp $";

DeclareGlobalVariable("OpenMathRealRandomSource");

#######################################################################
##
#F  OMPutObject( <stream>, <obj> )  
#F  OMPutObjectOMPutObjectNoOMOBJtags( <stream>, <obj> )  
## 
##  OMPutObject writes (appends) the XML OpenMath encoding of the GAP
##  object <obj> to output stream <stream> (see "ref: OutputTextFile",
##  "ref: OutputTextUser", "ref: OutputTextString",
##  "ref: InputOutputLocalProcess" ).
##
##  The second version does the same but without <OMOBJ> .. </OMOBJ> 
##  tags in the beginning and end, which maybe useful for combining
##  complex objects.
## 
DeclareGlobalFunction("OMPutObject");

DeclareGlobalFunction("OMPutObjectNoOMOBJtags");


#######################################################################
##
#O  OMPut(<stream>,<obj> ) 
## 
##
DeclareOperation("OMPut", [IsOutputStream, IsObject ]);


#######################################################################
##
#F  OMPrint( <obj> ) .................   Print <obj> as OpenMath object 
##
##  OMPrint writes the XML OpenMath encoding of GAP object <obj> 
##  to the standard output.
##
DeclareGlobalFunction("OMPrint");


########################################################################
## 
## OMString( <obj> ) ....... Return string with <obj> as OpenMath object
##
DeclareGlobalFunction("OMString");


#######################################################################
##
#F  OMWriteLine( <stream>, <list> )
##
##  Auxiliary function for OMPut functions.
##  Takes a list of string arguments and outputs them
##  to a single line with the correct indentation.
##
##  Input : List of arguments to print
##  Output: \t ^ OMIndent, arguments
##
DeclareGlobalFunction("OMWriteLine");


#######################################################################
##
#F  OMPutSymbol( <stream>, <cd>, <name> )
##
##  Input : cd, name as strings
##  Output: <OMS cd="<cd>" name="<name>" />
##
DeclareGlobalFunction("OMPutSymbol");


#######################################################################
##
#F  OMPutVar( <stream>, <name> )
##
##  Input : name as string
##  Output: <OMV name="<name>" />
##
DeclareGlobalFunction("OMPutVar");


#######################################################################
##
#M  OMPutApplication( <stream>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OMA>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<list>[1])
##                OMPut(<list>[2])
##                ...
##        </OMA>
##
DeclareGlobalFunction("OMPutApplication");

DeclareAttribute( "OMReference", IsObject );

DeclareOperation( "OMPutReference", [ IsOutputStream, IsObject ] );


#######################################################################
##
#O  OMPutList(<stream>,<obj> ) 
## 
##  Tries to render this as an OpenMath list
##
DeclareOperation("OMPutList", [IsOutputStream, IsObject ]);


# Determines the indentation of the next line to be printed.
OMIndent := 0;


#############################################################################
#
# Declarations for OMPlainString objects
#
DeclareCategory( "IsOMPlainString", IsObject );
OMPlainStringsFamily := NewFamily( "OMPlainStringsFamily" );
DeclareGlobalFunction ( "OMPlainString" );
DeclareRepresentation( "IsOMPlainStringRep", IsPositionalObjectRep, [ ] );
OMPlainStringDefaultType := NewType( OMPlainStringsFamily, 
                                IsOMPlainStringRep and IsOMPlainString );

#############################################################################
#E
