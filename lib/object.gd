#############################################################################
##
#W  object.gd                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for all objects.
##
Revision.object_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsObject( <obj> ) . . . . . . . . . . . .  test if an object is an object
##
##  'IsObject' returns 'true' if the object <obj> is an object.  Obviously it
##  can never return 'false'.
##
##  It can be used as a filter in  'InstallMethod', when one of the arguments
##  can be anything.
##
IsObject := NewCategoryKernel(
    "IsObject",
    IS_OBJECT,
    IS_OBJECT );


#############################################################################
##
#F  IsIdentical( <obj1>, <obj2> ) . . . . . . . . . are two objects identical
##
IsIdentical := IS_IDENTICAL_OBJ;


#############################################################################
##
#F  IsNotIdentical( <obj1>, <obj2> )  . . . . . are two objects not identical
##
IsNotIdentical := function ( obj1, obj2 )
    return not IsIdentical( obj1, obj2 );
end;


#############################################################################
##

#O  <obj1> = <obj2> . . . . . . . . . . . . . . . . . . are two objects equal
##
\= := NewOperationKernel( "=",
    [ IsObject, IsObject ],
    EQ );


#############################################################################
##
#O  <obj1> < <obj2> . . . . . . . . . . .  is one object smaller than another
##
\< := NewOperationKernel( "<",
    [ IsObject, IsObject ],
    LT );


#############################################################################
##
#O  <obj1> in <obj2>  . . . . . . . . . . . is one object a member of another
##
\in := NewOperationKernel( "in",
    [ IsObject, IsObject ],
    IN );


#############################################################################
##

#C  IsCopyable( <obj> ) . . . . . . . . . . . . test if an object is copyable
##
IsCopyable := NewCategoryKernel(
    "IsCopyable",
    IsObject,
    IS_COPYABLE_OBJ );


#############################################################################
##
#C  IsMutable( <obj> )  . . . . . . . . . . . .  test if an object is mutable
##
IsMutable := NewCategoryKernel( "IsMutable",
    IsObject,
    IS_MUTABLE_OBJ );


#############################################################################
##
#O  Immutable( <obj> )
##
Immutable := IMMUTABLE_COPY_OBJ;


#############################################################################
##
#O  ShallowCopy( <obj> )  . . . . . . . . . . . . . shallow copy of an object
##
ShallowCopy := NewOperationKernel(
    "ShallowCopy",
    [ IsObject ],
    SHALLOW_COPY_OBJ );


#############################################################################
##
#O  DeepCopy( <obj> ) . . . . . . . . . . . . . . . .  deep copy of an object
##
DeepCopy := DEEP_COPY_OBJ;


#############################################################################
##

#A  Name( <obj> ) . . . . . . . . . . . . . . . . . . . . . name of an object
##
Name    := NewAttribute( "Name", IsObject );
SetName := Setter( Name );
HasName := Tester( Name );


#############################################################################
##
#A  String( <obj> ) . . . . . . . . . . .  string representation of an object
##
String    := NewAttribute( "String", IsObject );
SetString := Setter( String );
HasString := Tester( String );


#############################################################################
##

#O  FormattedString( <obj>, <nr> )  . . formatted string repres. of an object
##
FormattedString := NewOperation( "FormattedString",
    [ IsObject, IS_INT ] );


#############################################################################
##
#O  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
##
PrintObj := NewOperationKernel( "PrintObj",
    [ IsObject ],
    PRINT_OBJ );


#############################################################################
##
#O  Display( <obj> )  . . . . . . . . . . . . . . . . . . . display an object
##
Display := NewOperation( "Display",
    [ IsObject ] );


#############################################################################
##
#O  IsInternallyConsistent( <obj> )
##
##  For debugging purposes, it may be useful to check the consistency of
##  an object <obj> that is composed from other (composed) objects.
##
##  There is a default method of 'IsInternallyConsistent', with rank zero,
##  that returns 'true'.
##  So it is possible (and recommended) to check the consistency of
##  subobjects of <obj> recursively by 'IsInternallyConsistent'.
##
##  (Note that 'IsInternallyConsistent' is not an attribute.)
##
IsInternallyConsistent := NewOperation( "IsInternallyConsistent",
    [ IsObject ] );


#############################################################################
##
#O  ExtRepOfObj( <obj> )  . . . . . . .  external representation of an object
##
ExtRepOfObj := NewOperation( "ExtRepOfObj",
    [ IsObject ] );


#############################################################################
##
#O  ObjByExtRep( <F>, <descr> ) . object in family <F> and ext. repr. <descr>
##
ObjByExtRep := NewOperation( "ObjByExtRep",
    [ IsFamily, IsObject ] );


#############################################################################
##

#E  object.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
