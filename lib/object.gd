#############################################################################
##
#W  object.gd                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for all objects.
##
Revision.object_gd :=
    "@(#)$Id$";


#T Shall we add a check that no  object ever lies in both
#T `IsComponentObjectRep' and `IsPositionalObjectRep'?
#T (A typical pitfall is that one decides to use `IsAttributeStoringRep'
#T for storing attribute values, *and* `IsPositionalObjectRep' for
#T convenience.)
#T Could we use `IsImpossible' and an immediate method that signals an error?


#############################################################################
##
#C  IsObject( <obj> ) . . . . . . . . . . . .  test if an object is an object
##
##  `IsObject' returns `true' if the object <obj> is an object.  Obviously it
##  can never return `false'.
##
##  It can be used as a filter in `InstallMethod'
##  (see~"prg:Method Installation" in ``Programming in GAP'')
##  when one of the arguments can be anything.
##
DeclareCategoryKernel( "IsObject", IS_OBJECT, IS_OBJECT );


#############################################################################
##
#F  IsIdenticalObj( <obj1>, <obj2> )  . . . . . . . are two objects identical
##
##  `IsIdenticalObj( <obj1>, <obj2> )' tests whether the objects
##  <obj1> and <obj2> are identical (that is they are either
##  equal immediate objects or are both stored at the same location in 
##  memory.
##
BIND_GLOBAL( "IsIdenticalObj", IS_IDENTICAL_OBJ );


#############################################################################
##
#F  IsNotIdenticalObj( <obj1>, <obj2> ) . . . . are two objects not identical
##
##  tests whether the objects <obj1> and <objs2> are not identical.
##
BIND_GLOBAL( "IsNotIdenticalObj", function ( obj1, obj2 )
    return not IsIdenticalObj( obj1, obj2 );
end );


#############################################################################
##
#o  <obj1> = <obj2> . . . . . . . . . . . . . . . . . . are two objects equal
##
DeclareOperationKernel( "=", [ IsObject, IsObject ], EQ );


#############################################################################
##
#o  <obj1> < <obj2> . . . . . . . . . . .  is one object smaller than another
##
DeclareOperationKernel( "<", [ IsObject, IsObject ], LT );


#############################################################################
##
#o  <obj1> in <obj2>  . . . . . . . . . . . is one object a member of another
##
DeclareOperationKernel( "in", [ IsObject, IsObject ], IN );


#############################################################################
##
#C  IsCopyable( <obj> ) . . . . . . . . . . . . test if an object is copyable
##
##  If a mutable form of an object <obj> can be made in {\GAP},
##  the object is called *copyable*. Examples of copyable objects are of
##  course lists and records. A new mutable version of the object can
##  always be obtained by the operation `ShallowCopy' (see "Duplication of 
##  Objects").
##
DeclareCategoryKernel( "IsCopyable", IsObject, IS_COPYABLE_OBJ );


#############################################################################
##
#C  IsMutable( <obj> )  . . . . . . . . . . . .  test if an object is mutable
##
##  tests whether <obj> is mutable.
##
##  If an object is mutable then it is also copyable (see~"IsCopyable"),
##  and a `ShallowCopy' (see~"ShallowCopy") method should be supplied for it.
##  Note that `IsMutable' must not be implied by another filter,
##  since otherwise `Immutable' would be able to create paradoxical objects
##  in the sense that `IsMutable' for such an object is `false' but the
##  filter that implies `IsMutable' is `true'.
##
DeclareCategoryKernel( "IsMutable", IsObject, IS_MUTABLE_OBJ );

InstallTrueMethod( IsCopyable, IsMutable);


#############################################################################
##
#O  Immutable( <obj> )
##
##  returns an immutable structural copy (see~"StructuralCopy") of <obj>
##  in which the subobjects are immutable *copies* of the subobjects of
##  <obj>.
##  If <obj> is immutable then `Immutable' returns <obj> itself.
##
##  {\GAP} will complain with an error if one tries to change an
##  immutable object.
##
BIND_GLOBAL( "Immutable", IMMUTABLE_COPY_OBJ );


#############################################################################
##
#O  ShallowCopy( <obj> )  . . . . . . . . . . . . . shallow copy of an object
##
##  If {\GAP} supports a mutable form of the object <obj>
##  (see~"Mutability and Copyability") then this is obtained by
##  `ShallowCopy'.
##  Otherwise `ShallowCopy' returns <obj> itself.
##
##  The subobjects of `ShallowCopy( <obj> )' are *identical* to the
##  subobjects of <obj>.
##  Note that if the object returned by `ShallowCopy' is mutable then it is
##  always a *new* object.
##  In particular, if the return value is mutable, then it is not *identical*
##  with the argument <obj>, no matter whether <obj> is mutable or immutable.
##  But of course the object returned by `ShallowCopy' is *equal* to <obj>
##  w.r.t.~the equality operator `='.
##
##  Since `ShallowCopy' is an operation, the concrete meaning of
##  ``subobject'' depends on the type of <obj>.
##  But for any copyable object <obj>, the definition should reflect the
##  idea of ``first level copying''.
##
##  The definition of `ShallowCopy' for lists (in particular for matrices)
##  can be found in~"Duplication of Lists".
##
DeclareOperationKernel( "ShallowCopy", [ IsObject ], SHALLOW_COPY_OBJ );


#############################################################################
##
#F  StructuralCopy( <obj> ) . . . . . . . . . .  structural copy of an object
##
##  In a few situations,
##  one wants to make a *structural copy* <scp> of an object <obj>.
##  This is defined as follows.
##  <scp> and <obj> are identical if <obj> is immutable.
##  Otherwise, <scp> is a mutable copy of <obj> such that
##  each subobject of <scp> is a structural copy of the corresponding
##  subobject of <obj>.
##  Furthermore, if two subobjects of <obj> are identical then
##  also the corresponding subobjects of <scp> are identical.
##
BIND_GLOBAL( "StructuralCopy", DEEP_COPY_OBJ );


#############################################################################
##
#A  Name( <obj> ) . . . . . . . . . . . . . . . . . . . . . name of an object
##
##  returns the name, a string, previously assigned to <obj> via a call to
##  `SetName' (see~"SetName").
##  The name of an object is used *only* for viewing the object via this
##  name.
##
##  There are no methods installed for computing names of objects,
##  but the name may be set for suitable objects, using `SetName'.
##
DeclareAttribute( "Name", IsObject );


#############################################################################
##
#A  String( <obj> ) . . . . . . . . . . .  string representation of an object
#O  String( <obj>, <length> ) .  formatted string representation of an object
##
##  `String' returns a representation of <obj>,
##  which may be an object of arbitrary type, as a string.
##  This string should approximate as closely as possible the character
##  sequence you see if you print <obj>.
##  
##  If <length> is given it must be an integer.
##  The absolute value gives the minimal length of the result.
##  If the string representation of <obj> takes less than that many
##  characters it is filled with blanks.
##  If <length> is positive it is filled on the left,
##  if <length> is negative it is filled on the right.
##  
##  In the two argument case, the string returned is a new mutable
##  string (in particular not a part of any other object);
##  it can be modified safely,
##  and `MakeImmutable' may be safely applied to it.
##
DeclareAttribute( "String", IsObject );
DeclareOperation( "String", [ IsObject, IS_INT ] );


#############################################################################
##
#O  FormattedString( <obj>, <nr> )  . . formatted string repres. of an object
##
#T  is now obsolete
##
BIND_GLOBAL( "FormattedString", String );


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
DeclareOperationKernel( "PrintObj", [ IsObject ], PRINT_OBJ );

# for technical reasons, this cannot be in `function.g' but must be after
# the declaration.
InstallMethod( PrintObj, "for an operation", true, [IsOperation], 0,
        function ( op )
    Print("<Operation \"",NAME_FUNC(op),"\">");
end);


#############################################################################
##
#O  Display( <obj> )  . . . . . . . . . . . . . . . . . . . display an object
##
##  Displays the object <obj> in a nice, formatted way which is easy to read
##  (but might be difficult for machines to understand). The actual format
##  used for this depends on the type of <obj>. Each method should print a
##  newline character as last character.
##
DeclareOperation( "Display", [ IsObject ] );

#############################################################################
##
#O  DisplayString( <obj> )  . . . . . . . . . . . . . . . . display an object
##
##
##  Returns a string which could be used to 
##  display the object <obj> in a nice, formatted way which is easy to read
##  (but might be difficult for machines to understand). The actual format
##  used for this depends on the type of <obj>. Each method should include a
##  newline character as last character.
##
DeclareOperation( "DisplayString", [ IsObject ] );


#############################################################################
##
#O  IsInternallyConsistent( <obj> )
##
##  For debugging purposes, it may be useful to check the consistency of
##  an object <obj> that is composed from other (composed) objects.
##
##  There is a default method of `IsInternallyConsistent', with rank zero,
##  that returns `true'.
##  So it is possible (and recommended) to check the consistency of
##  subobjects of <obj> recursively by `IsInternallyConsistent'.
##
##  (Note that `IsInternallyConsistent' is not an attribute.)
##
DeclareOperation( "IsInternallyConsistent", [ IsObject ] );


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
##  returns the external representation of the object <obj>.
##
DeclareOperation( "ExtRepOfObj", [ IsObject ] );


#############################################################################
##
#O  ObjByExtRep( <F>, <descr> ) . object in family <F> and ext. repr. <descr>
##
##  creates an object in the family <F> which has the external
##  representation <descr>.
##
DeclareOperation( "ObjByExtRep", [ IsFamily, IsObject ] );


#############################################################################
##
#O  KnownAttributesOfObject( <object> ) . . . . . list of names of attributes
##
##  returns a list of the names of the attributes whose values are known for 
##  <object>.
##
DeclareOperation( "KnownAttributesOfObject", [ IsObject ] );


#############################################################################
##
#O  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
##
##  returns a list of the names of the properties whose values are known for
##  <object>.
##
DeclareOperation( "KnownPropertiesOfObject", [ IsObject ] );


#############################################################################
##
#O  KnownTruePropertiesOfObject( <object> )  list of names of true properties
##
##  returns a list of the names of the properties known to be `true' for
##  <object>.
##
DeclareOperation( "KnownTruePropertiesOfObject", [ IsObject ]  );


#############################################################################
##
#O  CategoriesOfObject( <object> )  . . . . . . . list of names of categories
##
##  returns a list of the names of the categories in which <object> lies.
##
DeclareOperation( "CategoriesOfObject", [ IsObject ] );


#############################################################################
##
#O  RepresentationsOfObject( <object> ) . .  list of names of representations
##
##  returns a list of the names of the representations <object> has.
##
DeclareOperation( "RepresentationsOfObject", [ IsObject ] );


#############################################################################
##
#R  IsPackedElementDefaultRep( <obj> )
##
##  An object <obj> in this representation stores a related object as
##  `<obj>![1]'.
##  This representation is used for example for elements in f.p.~groups
##  or f.p.~algebras, where the stored object is an element of a
##  corresponding free group or algebra, respectively;
##  it is also used for Lie objects created from objects with an associative
##  multiplication.
##
DeclareRepresentation( "IsPackedElementDefaultRep", IsPositionalObjectRep,
    [ 1 ] );

#############################################################################
##
#O  PostMakeImmutable( <obj> )  clean-up after MakeImmutable
##
##  This operation is called by the kernel immediately after making
##  any COM_OBJ or POS_OBJ immutable using MakeImmutable
##  It is intended that objects should have methods for this operation
##  which make any appropriate subobjects immutable (eg list entries)
##  other subobjects (eg MutableAttributes) need not be made immutable.
##
##  A default method does nothing.

DeclareOperation( "PostMakeImmutable", [IsObject]);
  

#############################################################################
##
#E
##
