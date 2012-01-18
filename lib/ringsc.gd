#############################################################################
##
#W  ringsc.gd                   GAP library                 Alexander Hulpke
##
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This file contains declarations for elements of rings, given as Z-modules
##  with structure constants for multiplication. Is is based on algsc.gd
##

#############################################################################
##
#C  IsSCRingObj( <obj> )
#C  IsSCRingObjCollection( <obj> )
#C  IsSCRingObjFamily( <obj> )
##
##  S.~c. ring elements may have inverses, in order to allow `One' and
##  `Inverse' we make them scalars.
##
DeclareCategory( "IsSCRingObj", IsScalar );
DeclareCategoryCollections( "IsSCRingObj" );
DeclareCategoryCollections( "IsSCRingObjCollection" );
DeclareCategoryCollections( "IsSCRingObjCollColl" );
DeclareCategoryFamily( "IsSCRingObj" );

DeclareSynonym("IsSubringSCRing",IsRing and IsSCRingObjCollection);

#############################################################################
##
#F  RingByStructureConstants( <moduli>, <sctable>[, <nameinfo>] )
##
##  <#GAPDoc Label="RingByStructureConstants">
##  <ManSection>
##  <Func Name="RingByStructureConstants" Arg='moduli, sctable[, nameinfo]'/>
##
##  <Description>
##  returns a ring <M>R</M> whose additive group is described by the list
##  <A>moduli</A>,
##  with multiplication defined by the structure constants table
##  <A>sctable</A>.
##  The optional argument <A>nameinfo</A> can be used to prescribe names for
##  the elements of the canonical generators of <M>R</M>;
##  it can be either a string <A>name</A>
##  (then <A>name</A><C>1</C>, <A>name</A><C>2</C> etc. are chosen)
##  or a list of strings which are then chosen.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RingByStructureConstants" );

#############################################################################
##
#F  StandardGeneratorsSubringSCRing( <S> )
##
##  for a subring <S> of an SC ring <R> this command returns a list of length 3.
##  The first entry are generators for <S> as addive group, given with
##  respect to the additive group basis for <R> and being in hermite normal
##  form. The second entries are pivot positions for these generators. The third
##  entry are the generators as actual ring elements.
DeclareAttribute("StandardGeneratorsSubringSCRing",IsSubringSCRing);

#############################################################################
##
#A  Subrings( <R> )
##
##  for a finite ring <R> this function returns a list of all subrings of <R>.
DeclareAttribute("Subrings",IsRing);

#############################################################################
##
#A  Ideals( <R> )
##
##  for a finite ring <R> this function returns a list of all ideals of <R>.
DeclareAttribute("Ideals",IsRing);

#############################################################################
##
#F  NumberSmallRings( <s> )
##
##  returns the number of (nonisomorphic) rings of order <s> stored in the
##  library of small rings.
DeclareGlobalFunction("NumberSmallRings");

#############################################################################
##
#F  SmallRing( <s>,<n> )
##
##  returns the <n>-th ring of order <s> from a library of rings of small
##  order (up to isomorphism).
DeclareGlobalFunction("SmallRing");

#############################################################################
##
#F  DirectSum( <R>{, <S>} )
#O  DirectSumOp( <list>, <expl> )
##
##  <#GAPDoc Label="DirectSum">
##  <ManSection>
##  <Func Name="DirectSum" Arg='R{, S}'/>
##  <Oper Name="DirectSumOp" Arg='list, expl'/>
##
##  <Description>
##  These functions construct the direct sum of the rings given as
##  arguments.
##  <C>DirectSum</C> takes an arbitrary positive number of arguments
##  and calls the operation <C>DirectSumOp</C>, which takes exactly two
##  arguments, namely a nonempty list of rings and one of these rings.
##  (This somewhat strange syntax allows the method selection to choose
##  a reasonable method for special cases.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectSum" );
DeclareOperation( "DirectSumOp", [ IsList, IsRing ] );
DeclareAttribute( "DirectSumInfo", IsGroup, "mutable" );

