#######################################################################
##
#W  omput.gd                OpenMath Package           Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: omput.gd,v 1.27 2010/09/23 20:44:01 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Writes a GAP object to an output stream, as an OpenMath object
## 

Revision.("openmath/gap/omput.gd") := 
    "@(#)$Id: omput.gd,v 1.27 2010/09/23 20:44:01 alexk Exp $";

DeclareGlobalVariable("OpenMathRealRandomSource");


#############################################################################
#
# Declarations for OpenMathWriter
#
DeclareCategory( "IsOpenMathWriter", IsObject );
DeclareCategory( "IsOpenMathXMLWriter", IsOpenMathWriter );
DeclareCategory( "IsOpenMathBinaryWriter", IsOpenMathWriter );
OpenMathWritersFamily := NewFamily( "OpenMathWritersFamily" );
DeclareGlobalFunction ( "OpenMathBinaryWriter" );
DeclareGlobalFunction ( "OpenMathXMLWriter" );
DeclareRepresentation( "IsOpenMathWriterRep", IsPositionalObjectRep, [ ] );
OpenMathBinaryWriterType := NewType( OpenMathWritersFamily, 
                              IsOpenMathWriterRep and IsOpenMathBinaryWriter );
OpenMathXMLWriterType    := NewType( OpenMathWritersFamily, 
                              IsOpenMathWriterRep and IsOpenMathXMLWriter );                                
                            
                               
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
DeclareOperation("OMPutOMOBJ",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMOBJ", [ IsOpenMathWriter ] );

DeclareGlobalFunction("OMPutObjectNoOMOBJtags");


#######################################################################
##
#O  OMPut(<stream>,<obj> ) 
## 
##
DeclareOperation("OMPut", [IsOpenMathWriter, IsObject ]);


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
DeclareOperation("OMPutSymbol", [ IsOpenMathWriter, IsString, IsString ] );


#######################################################################
##
#F  OMPutForeign( <stream>, <encoding>, <string> )
##
##  Input : encoding and string representing the foreighn object
##
DeclareOperation("OMPutForeign", [ IsOpenMathWriter, IsString, IsString ] );


#######################################################################
##
#F  OMPutVar( <stream>, <name> )
##
##  Input : name as string
##  Output: <OMV name="<name>" />
##
DeclareOperation("OMPutVar", [ IsOpenMathWriter, IsObject ] );


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
DeclareOperation("OMPutOMA",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutOMAWithId", [ IsOpenMathWriter , IsString ] );
DeclareOperation("OMPutEndOMA", [ IsOpenMathWriter ] );


#######################################################################
##
## Tags for attributions and attribution pairs
##
DeclareOperation("OMPutOMATTR",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMATTR",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutOMATP", [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMATP", [ IsOpenMathWriter ] );

#######################################################################
##
#M  OMPutBinding( <stream>, <cd>, <name>, <listbvars>, <object> )
##
##  Input : cd, name, list of bvars, object
##  Output:
##        <OMBIND>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<list>[1])
##                OMPut(<object)
##                ...
##        </OMBIND>
##
#DeclareGlobalFunction("OMPutBinding");
DeclareOperation("OMPutOMBIND",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutOMBINDWithId", [ IsOpenMathWriter , IsString ] );
DeclareOperation("OMPutEndOMBIND", [ IsOpenMathWriter ] );

#######################################################################
##
## Tags for binding vars
##
DeclareOperation("OMPutOMBVAR",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMBVAR",    [ IsOpenMathWriter ] );

#######################################################################
##
#M  OMPutError( <stream>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OME>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<list>[1])
##                OMPut(<list>[2])
##                ...
##        </OME>
##
DeclareGlobalFunction("OMPutError");
DeclareOperation("OMPutOME",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOME", [ IsOpenMathWriter ] );

DeclareAttribute( "OMReference", IsObject );

DeclareOperation( "OMPutReference", [ IsOpenMathWriter, IsObject ] );

#######################################################################
##
#O  OMPutByteArray( <stream>, <bitlist> ) 
## 
##  Put bitlists into byte arrays
##
DeclareGlobalFunction("OMPutByteArray");


#######################################################################
##
#O  OMPutList(<stream>,<obj> ) 
## 
##  Tries to render this as an OpenMath list
##
DeclareOperation("OMPutList", [ IsOpenMathWriter, IsObject ]);


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
