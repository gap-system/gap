#############################################################################
##
#W  object.gd                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareCategoryKernel( "IsObject",
    IS_OBJECT,
    IS_OBJECT );


#############################################################################
##
#F  IsIdenticalObj( <obj1>, <obj2> )  . . . . . . . are two objects identical
##
BIND_GLOBAL( "IsIdenticalObj", IS_IDENTICAL_OBJ );


#############################################################################
##
#F  IsNotIdenticalObj( <obj1>, <obj2> ) . . . . are two objects not identical
##
BIND_GLOBAL( "IsNotIdenticalObj", function ( obj1, obj2 )
    return not IsIdenticalObj( obj1, obj2 );
end );


#############################################################################
##

#O  <obj1> = <obj2> . . . . . . . . . . . . . . . . . . are two objects equal
##
DeclareOperationKernel( "=",
    [ IsObject, IsObject ],
    EQ );


#############################################################################
##
#O  <obj1> < <obj2> . . . . . . . . . . .  is one object smaller than another
##
DeclareOperationKernel( "<",
    [ IsObject, IsObject ],
    LT );


#############################################################################
##
#O  <obj1> in <obj2>  . . . . . . . . . . . is one object a member of another
##
DeclareOperationKernel( "in",
    [ IsObject, IsObject ],
    IN );


#############################################################################
##

#C  IsCopyable( <obj> ) . . . . . . . . . . . . test if an object is copyable
##
DeclareCategoryKernel( "IsCopyable",
    IsObject,
    IS_COPYABLE_OBJ );


#############################################################################
##
#C  IsMutable( <obj> )  . . . . . . . . . . . .  test if an object is mutable
##
DeclareCategoryKernel( "IsMutable",
    IsObject,
    IS_MUTABLE_OBJ );


#############################################################################
##
#O  Immutable( <obj> )
##
BIND_GLOBAL( "Immutable", IMMUTABLE_COPY_OBJ );


#############################################################################
##
#O  ShallowCopy( <obj> )  . . . . . . . . . . . . . shallow copy of an object
##
DeclareOperationKernel( "ShallowCopy",
    [ IsObject ],
    SHALLOW_COPY_OBJ );


#############################################################################
##
#O  StructuralCopy( <obj> ) . . . . . . . . . .  structural copy of an object
##
BIND_GLOBAL( "StructuralCopy", DEEP_COPY_OBJ );


#############################################################################
##

#A  Name( <obj> ) . . . . . . . . . . . . . . . . . . . . . name of an object
##
##  The name of an object is used *only* for printing the object via this
##  name.
##
DeclareAttribute( "Name", IsObject );


#############################################################################
##
#A  String( <obj> ) . . . . . . . . . . .  string representation of an object
##
##  returns a string that will print similar as <obj> does.
DeclareAttribute( "String", IsObject );


#############################################################################
##

#O  FormattedString( <obj>, <nr> )  . . formatted string repres. of an object
##
DeclareOperation( "FormattedString",
    [ IsObject, IS_INT ] );


#############################################################################
##
#O  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
##
##  `PrintObj' prints information about the object <obj>.
##  This information is in general more detailed as that obtained from
##  `ViewObj',
##  but still it need not be sufficient to construct <obj> from it,
##  and in general it is not {\GAP} readable.
##
##  If <obj> has a name (see~"Name") then it will be printed via this name,
##  and a domain without name is in many cases printed via its generators.
#T write that many domains (without name) are in fact GAP readable?
##
##  {\GAP} readable data can be produced with `SaveObj'.                 
##
DeclareOperationKernel( "PrintObj",
    [ IsObject ],
    PRINT_OBJ );


#############################################################################
##
#O  Display( <obj> )  . . . . . . . . . . . . . . . . . . . display an object
##
DeclareOperation( "Display",
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
DeclareOperation( "IsInternallyConsistent",
    [ IsObject ] );


#############################################################################
##
#A  IsImpossible( <obj> )
##
##  For debugging purposes, it may be useful to install immediate methods
##  that raise an error if an object lies in a filter which is impossible.
##  For example, if a matrix is in the two fiters `IsOrdinaryMatrix' and
##  `IsLieMatrix' then apparently something went wrong.
##  Since we can install these immediate methods only for attributes
##  (and not for the operation `IsInternallyConsistent'),
##  we need such an attribute.
##
DeclareAttribute( "IsImpossible", IsObject );


#############################################################################
##
#O  ExtRepOfObj( <obj> )  . . . . . . .  external representation of an object
##
DeclareOperation( "ExtRepOfObj",
    [ IsObject ] );


#############################################################################
##
#O  ObjByExtRep( <F>, <descr> ) . object in family <F> and ext. repr. <descr>
##
DeclareOperation( "ObjByExtRep",
    [ IsFamily, IsObject ] );


#############################################################################
##
#O  KnownAttributesOfObject( <object> ) . . . . . list of names of attributes
##
DeclareOperation( "KnownAttributesOfObject",
    [ IsObject ] );


#############################################################################
##
#O  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
##
DeclareOperation( "KnownPropertiesOfObject",
    [ IsObject ] );


#############################################################################
##
#O  KnownTruePropertiesOfObject( <object> )  list of names of true properties
##
DeclareOperation( "KnownTruePropertiesOfObject",
    [ IsObject ]  );


#############################################################################
##
#O  CategoriesOfObject( <object> )  . . . . . . . list of names of categories
##
DeclareOperation( "CategoriesOfObject",
    [ IsObject ] );


#############################################################################
##
#O  RepresentationsOfObject( <object> ) . .  list of names of representations
##
DeclareOperation( "RepresentationsOfObject",
    [ IsObject ] );


#############################################################################
##

#E  object.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
