#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for all objects.
##


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
##  <#GAPDoc Label="IsObject">
##  <ManSection>
##  <Filt Name="IsObject" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsObject"/> returns <K>true</K> if the object <A>obj</A> is an
##  object.  Obviously it can never return <K>false</K>.
##  <P/>
##  It can be used as a filter in <Ref Func="InstallMethod"/>
##  when one of the arguments can be anything.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsObject", IS_OBJECT, IS_OBJECT );


#############################################################################
##
#F  IsIdenticalObj( <obj1>, <obj2> )  . . . . . . . are two objects identical
##
##  <#GAPDoc Label="IsIdenticalObj">
##  <ManSection>
##  <Func Name="IsIdenticalObj" Arg='obj1, obj2'/>
##
##  <Description>
##  <Ref Func="IsIdenticalObj"/> tests whether the objects
##  <A>obj1</A> and <A>obj2</A> are identical (that is they are either
##  equal immediate objects or are both stored at the same location in
##  memory.
##  <P/>
##  If two copies of a simple constant object
##  (see section <Ref Sect="Mutability and Copyability"/>) are created,
##  it is not defined whether &GAP; will
##  actually store two equal but non-identical objects, or just a single
##  object. For mutable objects, however, it is important to know whether
##  two values refer to identical or non-identical objects, and the
##  documentation of operations that return mutable values should make
##  clear whether the values returned are new, or may be identical to
##  values stored elsewhere.
##  <P/>
##  <Example><![CDATA[
##  gap> IsIdenticalObj( 10^6, 10^6);
##  true
##  gap> IsIdenticalObj( 10^30, 10^30);
##  false
##  gap> IsIdenticalObj( true, true);
##  true
##  ]]></Example>
##  <P/>
##  Generally, one may compute with objects but think of the results in
##  terms of the underlying elements because one is not interested in
##  locations in memory, data formats or information beyond underlying
##  equivalence relations. But there are cases where it is important to
##  distinguish the relations identity and equality.  This is best
##  illustrated with an example.  (The reader who is not familiar with
##  lists in &GAP;, in particular element access and assignment, is
##  referred to Chapter&nbsp;<Ref Chap="Lists"/>.)
##  <Example><![CDATA[
##  gap> l1:= [ 1, 2, 3 ];; l2:= [ 1, 2, 3 ];;
##  gap> l1 = l2;
##  true
##  gap> IsIdenticalObj( l1, l2 );
##  false
##  gap> l1[3]:= 4;; l1; l2;
##  [ 1, 2, 4 ]
##  [ 1, 2, 3 ]
##  gap> l1 = l2;
##  false
##  ]]></Example>
##  The two lists <C>l1</C> and <C>l2</C> are equal but not identical.
##  Thus a change in <C>l1</C> does not affect <C>l2</C>.
##  <Example><![CDATA[
##  gap> l1:= [ 1, 2, 3 ];; l2:= l1;;
##  gap> l1 = l2;
##  true
##  gap> IsIdenticalObj( l1, l2 );
##  true
##  gap> l1[3]:= 4;; l1; l2;
##  [ 1, 2, 4 ]
##  [ 1, 2, 4 ]
##  gap> l1 = l2;
##  true
##  ]]></Example>
##  Here, <C>l1</C> and <C>l2</C> are identical objects,
##  so changing <C>l1</C> means a change to <C>l2</C> as well.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "IsIdenticalObj", IS_IDENTICAL_OBJ );


#############################################################################
##
#F  IsNotIdenticalObj( <obj1>, <obj2> ) . . . . are two objects not identical
##
##  <#GAPDoc Label="IsNotIdenticalObj">
##  <ManSection>
##  <Func Name="IsNotIdenticalObj" Arg='obj1, obj2'/>
##
##  <Description>
##  tests whether the objects <A>obj1</A> and <A>obj2</A> are not identical.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsCopyable">
##  <ManSection>
##  <Filt Name="IsCopyable" Arg='obj' Type='Category'/>
##
##  <Description>
##  If a mutable form of an object <A>obj</A> can be made in &GAP;,
##  the object is called <E>copyable</E>. Examples of copyable objects are of
##  course lists and records. A new mutable version of the object can
##  always be obtained by the operation <Ref Oper="ShallowCopy"/>.
##  <P/>
##  Objects for which only an immutable form exists in &GAP; are called
##  <E>constants</E>.
##  Examples of constants are integers, permutations, and domains.
##  Called with a constant as argument,
##  <Ref Func="Immutable"/> and <Ref Oper="ShallowCopy"/> return this
##  argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsCopyable", IsObject, IS_COPYABLE_OBJ );


#############################################################################
##
#C  IsMutable( <obj> )  . . . . . . . . . . . .  test if an object is mutable
##
##  <#GAPDoc Label="IsMutable">
##  <ManSection>
##  <Filt Name="IsMutable" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests whether <A>obj</A> is mutable.
##  <P/>
##  If an object is mutable then it is also copyable
##  (see&nbsp;<Ref Filt="IsCopyable"/>),
##  and a <Ref Oper="ShallowCopy"/> method should be supplied for it.
##  Note that <Ref Filt="IsMutable"/> must not be implied by another filter,
##  since otherwise <Ref Func="Immutable"/> would be able to create
##  paradoxical objects in the sense that <Ref Filt="IsMutable"/> for such an
##  object is <K>false</K> but the filter that implies
##  <Ref Filt="IsMutable"/> is <K>true</K>.
##  <P/>
##  In many situations, however, one wants to ensure that objects are
##  <E>immutable</E>. For example, take the identity of a matrix group.
##  Since this matrix may be referred to as the identity of the group in
##  several places, it would be fatal to modify its entries,
##  or add or unbind rows.
##  We can obtain an immutable copy of an object with
##  <Ref Func="Immutable"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsMutable", IsObject, IS_MUTABLE_OBJ );

#############################################################################
##
#C  IsInternallyMutable( <obj> )  . . . .  test if an object has mutable state
##
##  <#GAPDoc Label="IsInternallyMutable">
##  <ManSection>
##  <Filt Name="IsInternallyMutable" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests whether <A>obj</A> has mutable internal state.
##  <P/>
##  Unlike <Ref Func="IsMutable">, <Ref Func="IsInternallyMutable"> is
##  true if and only if the object's internal representation chan change
##  even though its outwardly visible behavior does not. For example, if
##  a set of integers were represented internally as a T_DATOBJ containing
##  an array of integers, the implementation may choose to sort the array
##  to make membership tests faster. Such an object would be internally
##  mutable even if elements could not be added and thus it were immutable
##  per <Ref Func="IsMutable">.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
if IsHPCGAP then
DeclareCategoryKernel( "IsInternallyMutable",
    IsObject, IS_INTERNALLY_MUTABLE_OBJ );
fi;

InstallTrueMethod( IsCopyable, IsMutable);


#############################################################################
##
#O  Immutable( <obj> )
##
##  <#GAPDoc Label="Immutable">
##  <ManSection>
##  <Func Name="Immutable" Arg='obj'/>
##
##  <Description>
##  returns an immutable structural copy
##  (see&nbsp;<Ref Func="StructuralCopy"/>) of <A>obj</A>
##  in which the subobjects are immutable <E>copies</E> of the subobjects of
##  <A>obj</A>.
##  If <A>obj</A> is immutable then <Ref Func="Immutable"/> returns
##  <A>obj</A> itself.
##  <P/>
##  &GAP; will complain with an error if one tries to change an
##  immutable object.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "Immutable", IMMUTABLE_COPY_OBJ );

#############################################################################
##
#O  ShallowCopy( <obj> )  . . . . . . . . . . . . . shallow copy of an object
##
##  <#GAPDoc Label="ShallowCopy">
##  <ManSection>
##  <Oper Name="ShallowCopy" Arg='obj'/>
##
##  <Description>
##  <Ref Oper="ShallowCopy"/> returns a <E>new mutable</E> object <E>equal</E>
##  to its argument, if this is possible.
##  The subobjects of <C>ShallowCopy( <A>obj</A> )</C> are <E>identical</E>
##  to the subobjects of <A>obj</A>.
##  <P/>
##  If &GAP; does not support a mutable form of the immutable object <A>obj</A>
##  (see&nbsp;<Ref Sect="Mutability and Copyability"/>) then
##  <Ref Oper="ShallowCopy"/> returns <A>obj</A> itself.
##  <P/>
##  Since <Ref Oper="ShallowCopy"/> is an operation, the concrete meaning of
##  <Q>subobject</Q> depends on the type of <A>obj</A>.
##  But for any copyable object <A>obj</A>, the definition should reflect the
##  idea of <Q>first level copying</Q>.
##  <P/>
##  The definition of <Ref Oper="ShallowCopy"/> for lists (in particular for
##  matrices) can be found in&nbsp;<Ref Sect="Duplication of Lists"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "ShallowCopy", [ IsObject ], SHALLOW_COPY_OBJ );


#############################################################################
##
#F  StructuralCopy( <obj> ) . . . . . . . . . .  structural copy of an object
##
##  <#GAPDoc Label="StructuralCopy">
##  <ManSection>
##  <Func Name="StructuralCopy" Arg='obj'/>
##
##  <Description>
##  In a few situations, one wants to make a <E>structural copy</E>
##  <C>scp</C> of an object <A>obj</A>.
##  This is defined as follows.
##  <C>scp</C> and <A>obj</A> are identical if <A>obj</A> is immutable.
##  Otherwise, <C>scp</C> is a mutable copy of <A>obj</A> such that
##  each subobject of <C>scp</C> is a structural copy of the corresponding
##  subobject of <A>obj</A>.
##  Furthermore, if two subobjects of <A>obj</A> are identical then
##  also the corresponding subobjects of <C>scp</C> are identical.
##  <Example><![CDATA[
##  gap> obj:= [ [ 0, 1 ] ];;
##  gap> obj[2]:= obj[1];;
##  gap> obj[3]:= Immutable( obj[1] );;
##  gap> scp:= StructuralCopy( obj );;
##  gap> scp = obj; IsIdenticalObj( scp, obj );
##  true
##  false
##  gap> IsIdenticalObj( scp[1], obj[1] );
##  false
##  gap> IsIdenticalObj( scp[3], obj[3] );
##  true
##  gap> IsIdenticalObj( scp[1], scp[2] );
##  true
##  ]]></Example>
##  <P/>
##  That both <Ref Oper="ShallowCopy"/> and <Ref Func="StructuralCopy"/>
##  return the argument <A>obj</A> itself if it is not copyable
##  is consistent with this definition,
##  since there is no way to change <A>obj</A> by modifying the result of any
##  of the two functions,
##  because in fact there is no way to change this result at all.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "StructuralCopy", DEEP_COPY_OBJ );


#############################################################################
##
#A  Name( <obj> ) . . . . . . . . . . . . . . . . . . . . . name of an object
##
##  <#GAPDoc Label="Name">
##  <ManSection>
##  <Attr Name="Name" Arg='obj'/>
##
##  <Description>
##  returns the name, a string, previously assigned to <A>obj</A> via a call
##  to <Ref Oper="SetName"/>.
##  The name of an object is used <E>only</E> for viewing the object via this
##  name.
##  <P/>
##  There are no methods installed for computing names of objects,
##  but the name may be set for suitable objects,
##  using <Ref Oper="SetName"/>.
##  <Example><![CDATA[
##  gap> R := PolynomialRing(Integers,2);
##  Integers[x_1,x_2]
##  gap> SetName(R,"Z[x,y]");
##  gap> R;
##  Z[x,y]
##  gap> Name(R);
##  "Z[x,y]"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Name", IsObject );

#############################################################################
##
#A  InfoText( <obj> )
##
##  <#GAPDoc Label="InfoText">
##  <ManSection>
##  <Attr Name="InfoText" Arg='obj'/>
##
##  <Description>
##  is a mutable string with information about the object <A>obj</A>.
##  There is no default method to create an info text.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InfoText", IsObject, "mutable" );

#############################################################################
##
#A  String( <obj>[, <length>] )  formatted string representation of an object
##
##  <#GAPDoc Label="String">
##  <ManSection>
##  <Attr Name="String" Arg='obj[, length]'/>
##
##  <Description>
##  <Ref Attr="String"/> returns a representation of <A>obj</A>,
##  which may be an object of arbitrary type, as a string.
##  This string should approximate as closely as possible the character
##  sequence you see if you print <A>obj</A>.
##  <P/>
##  If <A>length</A> is given it must be an integer.
##  The absolute value gives the minimal length of the result.
##  If the string representation of <A>obj</A> takes less than that many
##  characters it is filled with blanks.
##  If <A>length</A> is positive it is filled on the left,
##  if <A>length</A> is negative it is filled on the right.
##  <P/>
##  In the two argument case, the string returned is a new mutable
##  string (in particular not a part of any other object);
##  it can be modified safely,
##  and <Ref Func="MakeImmutable"/> may be safely applied to it.
##  <Example><![CDATA[
##  gap> String(123);String([1,2,3]);
##  "123"
##  "[ 1, 2, 3 ]"
##  ]]></Example>
##  <Ref Attr="String"/> must not put in additional control
##  characters <C>\&lt;</C> (ASCII 1) and <C>\&gt;</C> (ASCII 2)
##  that allow proper line breaks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "String", IsObject );
DeclareOperation( "String", [ IsObject, IS_INT ] );


#############################################################################
##
#O  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
##
##  <ManSection>
##  <Oper Name="PrintObj" Arg='obj'/>
##
##  <Description>
##  <Ref Func="PrintObj"/> prints information about the object <A>obj</A>.
##  This information is in general more detailed as that obtained from
##  <Ref Func="ViewObj"/>,
##  but still it need not be sufficient to construct <A>obj</A> from it,
##  and in general it is not &GAP; readable.
##  <P/>
##  If <A>obj</A> has a name (see&nbsp;<Ref Func="Name"/>) then it will be
##  printed via this name, and a domain without name is in many cases printed
##  via its generators.
##  <!-- write that many domains (without name) are in fact GAP readable?-->
##  </Description>
##  </ManSection>
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
#O  PrintString( <obj> ) . . . . . . . . . . . string which would be printed
##
##  <#GAPDoc Label="PrintString">
##  <ManSection>
##  <Oper Name="PrintString" Arg='obj[, length]'/>
##
##  <Description>
##  <Ref Oper="PrintString"/> returns a representation of <A>obj</A>,
##  which may be an object of arbitrary type, as a string.
##  This string should approximate as closely as possible the character
##  sequence you see if you print <A>obj</A> using <Ref Oper="PrintObj"/>.
##  <P/>
##  If <A>length</A> is given it must be an integer.
##  The absolute value gives the minimal length of the result.
##  If the string representation of <A>obj</A> takes less than that many
##  characters it is filled with blanks.
##  If <A>length</A> is positive it is filled on the left,
##  if <A>length</A> is negative it is filled on the right.
##  <P/>
##  In the two argument case, the string returned is a new mutable
##  string (in particular not a part of any other object);
##  it can be modified safely,
##  and <Ref Func="MakeImmutable"/> may be safely applied to it.
##  <Example><![CDATA[
##  gap> PrintString(123);PrintString([1,2,3]);
##  "123"
##  "[ 1, 2, 3 ]"
##  ]]></Example>
##  <Ref Oper="PrintString"/> is entitled to put in additional control
##  characters <C>\&lt;</C> (ASCII 1) and <C>\&gt;</C> (ASCII 2)
##  that allow proper line breaks. See <Ref Func="StripLineBreakCharacters"/>
##  for a function to get rid of these control characters.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PrintString", [ IsObject ] );
DeclareOperation( "PrintString", [ IsObject, IS_INT ] );


#############################################################################
##
#F  StripLineBreakCharacters( <string> ) . . . removes \< and \> characters
##
##  <#GAPDoc Label="StripLineBreakCharacters">
##  <ManSection>
##  <Func Name="StripLineBreakCharacters" Arg="st"/>
##
##  <Description>
##  This function takes a string <A>st</A> as an argument and removes all
##  control characters <C>\&lt;</C> (ASCII 1) and <C>\&gt;</C> (ASCII 2)
##  which are used by
##  <Ref Oper="PrintString"/> and <Ref Oper="PrintObj"/> to ensure proper
##  line breaking. A new string with these characters removed is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StripLineBreakCharacters" );


#############################################################################
##
#O  Display( <obj> )  . . . . . . . . . . . . . . . . . . . display an object
##
##  <#GAPDoc Label="Display">
##  <ManSection>
##  <Oper Name="Display" Arg='obj'/>
##
##  <Description>
##  Displays the object <A>obj</A> in a nice, formatted way which is easy to
##  read (but might be difficult for machines to understand).
##  The actual format used for this depends on the type of <A>obj</A>.
##  Each method should print a newline character as last character.
##  <Example><![CDATA[
##  gap> Display( [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] * Z(5) );
##   2 4 1
##   3 . 2
##  ]]></Example>
##  <P/>
##  One can assign a string to an object that <Ref Func="Print"/> will use
##  instead of the default used by <Ref Func="Print"/>,
##  via <Ref Oper="SetName"/>.
##  Also, <Ref Attr="Name"/> returns the string previously assigned to
##  the object for printing, via <Ref Oper="SetName"/>.
##  The following is an example in the context of domains.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Group( (1,2,3,4) );
##  Group([ (1,2,3,4) ])
##  gap> SetName( g, "C4" ); g;
##  C4
##  gap> Name( g );
##  "C4"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Display", [ IsObject ] );


#############################################################################
##
#O  DisplayString( <obj> )  . . . . . . . . . . . . . . . . display an object
##
##  <#GAPDoc Label="DisplayString">
##  <ManSection>
##  <Oper Name="DisplayString" Arg='obj'/>
##
##  <Description>
##  Returns a string which could be used to
##  display the object <A>obj</A> in a nice, formatted way which is easy to
##  read (but might be difficult for machines to understand).
##  The actual format used for this depends on the type of <A>obj</A>.
##  Each method should include a newline character as last character.
##  Note that no method for <Ref Oper="DisplayString"/> may delegate
##  to any of the operations <Ref Oper="Display"/>, <Ref Oper="ViewObj"/>
##  or <Ref Oper="PrintObj"/> to avoid circular delegations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DisplayString", [ IsObject ] );


#############################################################################
##
#O  IsInternallyConsistent( <obj> )
##
##  <#GAPDoc Label="IsInternallyConsistent">
##  <ManSection>
##  <Oper Name="IsInternallyConsistent" Arg='obj'/>
##
##  <Description>
##  For debugging purposes, it may be useful to check the consistency of
##  an object <A>obj</A> that is composed from other (composed) objects.
##  <P/>
##  There is a default method of <Ref Oper="IsInternallyConsistent"/>,
##  with rank zero, that returns <K>true</K>.
##  So it is possible (and recommended) to check the consistency of
##  subobjects of <A>obj</A> recursively by
##  <Ref Oper="IsInternallyConsistent"/>.
##  <P/>
##  (Note that <Ref Oper="IsInternallyConsistent"/> is not an attribute.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsInternallyConsistent", [ IsObject ] );


#############################################################################
##
#A  IsImpossible( <obj> )
##
##  <ManSection>
##  <Attr Name="IsImpossible" Arg='obj'/>
##
##  <Description>
##  For debugging purposes, it may be useful to install immediate methods
##  that raise an error if an object lies in a filter which is impossible.
##  For example, if a matrix is in the two filters <C>IsOrdinaryMatrix</C> and
##  <C>IsLieMatrix</C> then apparently something went wrong.
##  Since we can install these immediate methods only for attributes
##  (and not for the operation <Ref Oper="IsInternallyConsistent"/>),
##  we need such an attribute.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "IsImpossible", IsObject );


#############################################################################
##
#O  ExtRepOfObj( <obj> )  . . . . . . .  external representation of an object
##
##  <ManSection>
##  <Oper Name="ExtRepOfObj" Arg='obj'/>
##
##  <Description>
##  returns the external representation of the object <A>obj</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ExtRepOfObj", [ IsObject ] );


#############################################################################
##
#O  ObjByExtRep( <F>, <descr> ) . object in family <F> and ext. repr. <descr>
##
##  <ManSection>
##  <Oper Name="ObjByExtRep" Arg='F, descr'/>
##
##  <Description>
##  creates an object in the family <A>F</A> which has the external
##  representation <A>descr</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ObjByExtRep", [ IsFamily, IsObject ] );


#############################################################################
##
#O  KnownAttributesOfObject( <object> ) . . . . . list of names of attributes
##
##  <#GAPDoc Label="KnownAttributesOfObject">
##  <ManSection>
##  <Oper Name="KnownAttributesOfObject" Arg='object'/>
##
##  <Description>
##  returns a list of the names of the attributes whose values are known for
##  <A>object</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2),(1,2,3));;Size(g);;
##  gap> KnownAttributesOfObject(g);
##  [ "Size", "OneImmutable", "NrMovedPoints", "MovedPoints",
##    "GeneratorsOfMagmaWithInverses", "MultiplicativeNeutralElement",
##    "HomePcgs", "Pcgs", "StabChainMutable", "StabChainOptions" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "KnownAttributesOfObject", [ IsObject ] );


#############################################################################
##
#O  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
##
##  <#GAPDoc Label="KnownPropertiesOfObject">
##  <ManSection>
##  <Oper Name="KnownPropertiesOfObject" Arg='object'/>
##
##  <Description>
##  returns a list of the names of the properties whose values are known for
##  <A>object</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "KnownPropertiesOfObject", [ IsObject ] );


#############################################################################
##
#O  KnownTruePropertiesOfObject( <object> )  list of names of true properties
##
##  <#GAPDoc Label="KnownTruePropertiesOfObject">
##  <ManSection>
##  <Oper Name="KnownTruePropertiesOfObject" Arg='object'/>
##
##  <Description>
##  returns a list of the names of the properties known to be <K>true</K> for
##  <A>object</A>.
##  <Example><![CDATA[
##  gap> g:=Group((1,2),(1,2,3));;
##  gap> KnownPropertiesOfObject(g);
##  [ "IsEmpty", "IsTrivial", "IsNonTrivial", "IsFinite",
##    "CanEasilyCompareElements", "CanEasilySortElements",
##    "IsDuplicateFree", "IsGeneratorsOfMagmaWithInverses",
##    "IsAssociative", "IsFinitelyGeneratedMagma",
##    "IsGeneratorsOfSemigroup", "IsSimpleSemigroup",
##    "IsRegularSemigroup", "IsInverseSemigroup",
##    "IsCompletelyRegularSemigroup", "IsCompletelySimpleSemigroup",
##    "IsGroupAsSemigroup", "IsMonoidAsSemigroup", "IsOrthodoxSemigroup",
##    "IsFinitelyGeneratedMonoid", "IsFinitelyGeneratedGroup",
##    "IsSubsetLocallyFiniteGroup", "KnowsHowToDecompose",
##    "IsInfiniteAbelianizationGroup", "IsNilpotentByFinite",
##    "IsTorsionFree", "IsFreeAbelian" ]
##  gap> Size(g);
##  6
##  gap> KnownPropertiesOfObject(g);
##  [ "IsEmpty", "IsTrivial", "IsNonTrivial", "IsFinite",
##    "CanEasilyCompareElements", "CanEasilySortElements",
##    "IsDuplicateFree", "IsGeneratorsOfMagmaWithInverses",
##    "IsAssociative", "IsFinitelyGeneratedMagma",
##    "IsGeneratorsOfSemigroup", "IsSimpleSemigroup",
##    "IsRegularSemigroup", "IsInverseSemigroup",
##    "IsCompletelyRegularSemigroup", "IsCompletelySimpleSemigroup",
##    "IsGroupAsSemigroup", "IsMonoidAsSemigroup", "IsOrthodoxSemigroup",
##    "IsFinitelyGeneratedMonoid", "IsFinitelyGeneratedGroup",
##    "IsSubsetLocallyFiniteGroup", "KnowsHowToDecompose",
##    "IsPerfectGroup", "IsSolvableGroup", "IsPolycyclicGroup",
##    "IsInfiniteAbelianizationGroup", "IsNilpotentByFinite",
##    "IsTorsionFree", "IsFreeAbelian" ]
##  gap> KnownTruePropertiesOfObject(g);
##  [ "IsNonTrivial", "IsFinite", "CanEasilyCompareElements",
##    "CanEasilySortElements", "IsDuplicateFree",
##    "IsGeneratorsOfMagmaWithInverses", "IsAssociative",
##    "IsFinitelyGeneratedMagma", "IsGeneratorsOfSemigroup",
##    "IsSimpleSemigroup", "IsRegularSemigroup", "IsInverseSemigroup",
##    "IsCompletelyRegularSemigroup", "IsCompletelySimpleSemigroup",
##    "IsGroupAsSemigroup", "IsMonoidAsSemigroup", "IsOrthodoxSemigroup",
##    "IsFinitelyGeneratedMonoid", "IsFinitelyGeneratedGroup",
##    "IsSubsetLocallyFiniteGroup", "KnowsHowToDecompose",
##    "IsSolvableGroup", "IsPolycyclicGroup", "IsNilpotentByFinite" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "KnownTruePropertiesOfObject", [ IsObject ]  );


#############################################################################
##
#O  CategoriesOfObject( <object> )  . . . . . . . list of names of categories
##
##  <#GAPDoc Label="CategoriesOfObject">
##  <ManSection>
##  <Oper Name="CategoriesOfObject" Arg='object'/>
##
##  <Description>
##  returns a list of the names of the categories in which <A>object</A> lies.
##  <Example><![CDATA[
##  gap> g:=Group((1,2),(1,2,3));;
##  gap> CategoriesOfObject(g);
##  [ "IsListOrCollection", "IsCollection", "IsExtLElement",
##    "CategoryCollections(IsExtLElement)", "IsExtRElement",
##    "CategoryCollections(IsExtRElement)",
##    "CategoryCollections(IsMultiplicativeElement)",
##    "CategoryCollections(IsMultiplicativeElementWithOne)",
##    "CategoryCollections(IsMultiplicativeElementWithInverse)",
##    "CategoryCollections(IsAssociativeElement)",
##    "CategoryCollections(IsFiniteOrderElement)", "IsGeneralizedDomain",
##    "CategoryCollections(IsPerm)", "IsMagma", "IsMagmaWithOne",
##    "IsMagmaWithInversesIfNonzero", "IsMagmaWithInverses" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CategoriesOfObject", [ IsObject ] );


#############################################################################
##
#O  RepresentationsOfObject( <object> ) . .  list of names of representations
##
##  <#GAPDoc Label="RepresentationsOfObject">
##  <ManSection>
##  <Oper Name="RepresentationsOfObject" Arg='object'/>
##
##  <Description>
##  returns a list of the names of the representations <A>object</A> has.
##  <Example><![CDATA[
##  gap> g:=Group((1,2),(1,2,3));;
##  gap> RepresentationsOfObject(g);
##  [ "IsComponentObjectRep", "IsAttributeStoringRep" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RepresentationsOfObject", [ IsObject ] );


#############################################################################
##
#R  IsPackedElementDefaultRep( <obj> )
##
##  <ManSection>
##  <Filt Name="IsPackedElementDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in this representation stores a related object as
##  <A>obj</A><C>![1]</C>.
##  This representation is used for example for elements in f.p.&nbsp;groups
##  or f.p.&nbsp;algebras, where the stored object is an element of a
##  corresponding free group or algebra, respectively;
##  it is also used for Lie objects created from objects with an associative
##  multiplication.
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsPackedElementDefaultRep", IsAtomicPositionalObjectRep );

#############################################################################
##
#O  PostMakeImmutable( <obj> )  clean-up after MakeImmutable
##
##  <ManSection>
##  <Oper Name="PostMakeImmutable" Arg='obj'/>
##
##  <Description>
##  This operation is called by the kernel immediately after making
##  any COM_OBJ or POS_OBJ immutable using MakeImmutable
##  It is intended that objects should have methods for this operation
##  which make any appropriate subobjects immutable (eg list entries)
##  other subobjects (eg MutableAttributes) need not be made immutable.
##  <P/>
##  A default method does nothing.
##  </Description>
##  </ManSection>
##
DeclareOperation( "PostMakeImmutable", [IsObject]);
