#############################################################################
##
#W  algfp.gd                   GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the decalarations for finitely presented algebras
##
Revision.algfp_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsElementOfFpAlgebra
##
IsElementOfFpAlgebra := NewCategory( "IsElementOfFpAlgebra",
    IsRingElement );


#############################################################################
##
#C  IsElementOfFpAlgebraCollection
##
IsElementOfFpAlgebraCollection := CategoryCollections(
    IsElementOfFpAlgebra );


#############################################################################
##
#C  IsSubalgebraFpAlgebra
##
IsSubalgebraFpAlgebra := NewCategory ("IsSubalgebraFpAlgebra", IsAlgebra);


#############################################################################
##
#M  IsSubalgebraFpAlgebra( <D> )  . for alg. that is coll. of f.p. alg. elms.
##
InstallTrueMethod( IsSubalgebraFpAlgebra,
    IsAlgebra and IsElementOfFpAlgebraCollection );


#############################################################################
##
#C  IsFamilyOfFpAlgebraElements
##
IsFamilyOfFpAlgebraElements := CategoryFamily( IsElementOfFpAlgebra );


#############################################################################
##
#O  ElementOfFpAlgebra( <Fam>, <elm> )
##
ElementOfFpAlgebra := NewOperation("ElementOfFpAlgebra",
    [IsFamilyOfFpAlgebraElements,IsRingElement]);


############################################################################
##
#O  MappedExpression( <expr>, <gens1>, <gens2> )
##
##  For an arithmetic expression <expr> in terms of the generators <gens1>,
##  `MappedExpression' returns the corresponding expression in terms of
##  <gens2>.
##
##  Note that it is expected that one can raise elements in <gens2> to the
##  zero-th power.
##
MappedExpression := NewOperation( "MappedExpression",
    [ IsElementOfFpAlgebra, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  FactorFreeAlgebraByRelators(<F>,<rels>) . . . . .  factor of free algebra
##
FactorFreeAlgebraByRelators := NewOperationArgs(
  "FactorFreeAlgebraByRelators");


#############################################################################
##
#P  IsNormalForm( <elm> )
##
IsNormalForm := NewProperty( "IsNormalForm", IsObject );
SetIsNormalForm := Setter( IsNormalForm );
HasIsNormalForm := Tester( IsNormalForm );


#############################################################################
##
#A  NiceNormalFormByExtRepFunction( <Fam> )
##
##  Applied to the family <Fam> and the external representation of an element
##  $e$ of the family <Fam>,
##  'NiceNormalFormByExtRepFunction( <Fam> )' returns the element of <Fam>
##  that is equal to $e$ and in normal form.
##
##  If the family <Fam> knows a nice normal form for its elements then the
##  elements can be always constructed as normalized elements by
##  'NormalizedObjByExtRep'.
##
##  (Perhaps a normal form that is expensive to compute will not be regarded
##  as a nice normal form.)
##
NiceNormalFormByExtRepFunction := NewAttribute(
    "NiceNormalFormByExtRepFunction",
    IsFamily );
SetNiceNormalFormByExtRepFunction := Setter(
    NiceNormalFormByExtRepFunction );
HasNiceNormalFormByExtRepFunction := Tester(
    NiceNormalFormByExtRepFunction );


#############################################################################
##
#A  BasisInfoFpAlgebra( <A> )
##
##  The value of `BasisInfoFpAlgebra' for a f.p. algebra <A> is a record with
##  the following components.
##
##  `generators'
##      a list of the generators of the full f.p. algebra containing <A>,
##
##  `genimages'
##      a list of ring elements corresponding to `generators',
##
##  `basiselms'
##      a list of elements in <A> that forms a basis of <A>,
##
##  `basisimages'
##      a basis of an algebra whose vectors are in bijection with
##      `basiselms', such that the bijection defines an algebra isomorphism
##      that is compatible with the map that maps the algebra generators to
##      `genimages'.
##      
##  If a f.p. algebra knows the value of `BasisInfoFpAlgebra' then it can be
##  handled via the mechanism of nice bases.
##  Namely, the nice vector of an element can be computed from the image
##  under `MappedExpression', using `genimages'.
##  The ugly vector is given by the linear combination of `basiselms',
##  with coefficients of the decomposition into `basisimages'.
#T Is it reasonable to use this attribute also to construct a
#T ``nice normal form''?
##
BasisInfoFpAlgebra := NewAttribute( "BasisInfoFpAlgebra",
    IsSubalgebraFpAlgebra );
SetBasisInfoFpAlgebra := Setter( BasisInfoFpAlgebra );
HasBasisInfoFpAlgebra := Tester( BasisInfoFpAlgebra );


#############################################################################
##
#M  IsHandledByNiceBasis( <A> ) . . .  for f.p. algebra with known basis info
##
InstallTrueMethod( IsHandledByNiceBasis,
    IsSubalgebraFpAlgebra and HasBasisInfoFpAlgebra );


#############################################################################
##
#F  IsGeneralizedCartanMatrix( <A> )
##
##  The square matrix <A> is a generalized Cartan Matrix if and only if
##  1. `A[i][i] = 2' for all $i$,
##  2. `A[i][j]' are nonpositive integers for $i \not= j$,
##  3. `A[i][j] = 0' implies `A[j][i] = 0'.
##
IsGeneralizedCartanMatrix := NewAttribute( "IsGeneralizedCartanMatrix",
    IsMatrix );


#############################################################################
##
#F  FpAlgebraByGeneralizedCartanMatrix( <F>, <A> )
##
##  is a finitely presented associative algebra over the field <F>,
##  defined by the generalized Cartan matrix <A>.
##
FpAlgebraByGeneralizedCartanMatrix := NewOperationArgs(
    "FpAlgebraByGeneralizedCartanMatrix" );


#############################################################################
##
#E  algfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


