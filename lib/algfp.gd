#############################################################################
##
#W  algfp.gd                   GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for finitely presented algebras
##
Revision.algfp_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsElementOfFpAlgebra
##
DeclareCategory( "IsElementOfFpAlgebra", IsRingElement );


#############################################################################
##
#C  IsElementOfFpAlgebraCollection
##
DeclareCategoryCollections( "IsElementOfFpAlgebra" );


#############################################################################
##
#C  IsElementOfFpAlgebraFamily
##
DeclareCategoryFamily( "IsElementOfFpAlgebra" );


#############################################################################
##
#C  IsSubalgebraFpAlgebra
##
DeclareCategory( "IsSubalgebraFpAlgebra", IsAlgebra );


#############################################################################
##
#M  IsSubalgebraFpAlgebra( <D> )  . for alg. that is coll. of f.p. alg. elms.
##
InstallTrueMethod( IsSubalgebraFpAlgebra,
    IsAlgebra and IsElementOfFpAlgebraCollection );


#############################################################################
##
#M  IsHandledByNiceBasis( <C> ) .  for space that is coll. of f.p. alg. elms.
##
InstallTrueMethod( IsHandledByNiceBasis,
    IsFreeLeftModule and IsElementOfFpAlgebraCollection );


#############################################################################
##
#P  IsFullFpAlgebra( <A> )
##
##  A f.~p. algebra is given by generators which are arithmetic expressions
##  in terms of a set of generators $X$ of an f.~p. algebra that was
##  constructed as a quotient of a free algebra.
##
##  A *full f.~p. algebra* is a f.~p. algebra that contains $X$.
##  (So a full f.~p. algebra need *not* contain the whole family of its
##  elements.)
##
DeclareProperty( "IsFullFpAlgebra",
    IsFLMLOR and IsElementOfFpAlgebraCollection );


#############################################################################
##
#O  ElementOfFpAlgebra( <Fam>, <elm> )
##
DeclareOperation( "ElementOfFpAlgebra",
    [ IsElementOfFpAlgebraFamily, IsRingElement ] );


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
DeclareOperation( "MappedExpression",
    [ IsElementOfFpAlgebra, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  FactorFreeAlgebraByRelators(<F>,<rels>) . . . . .  factor of free algebra
##
DeclareGlobalFunction( "FactorFreeAlgebraByRelators" );


#############################################################################
##
#P  IsNormalForm( <elm> )
##
DeclareProperty( "IsNormalForm", IsObject );


#############################################################################
##
#A  NiceNormalFormByExtRepFunction( <Fam> )
##
##  `NiceNormalFormByExtRepFunction( <Fam> )' is a function that can be
##  applied to the family <Fam> and the external representation of an element
##  $e$ of <Fam>;
##  This call returns the element of <Fam> that is equal to $e$ and in normal
##  form.
##
##  If the family <Fam> knows a nice normal form for its elements then the
##  elements can be always constructed as normalized elements by
##  `NormalizedObjByExtRep'.
##
##  (Perhaps a normal form that is expensive to compute will not be regarded
##  as a nice normal form.)
##
DeclareAttribute( "NiceNormalFormByExtRepFunction", IsFamily );


#############################################################################
##
#A  NiceAlgebraMonomorphism( <A> )
##
##  If a f.p. algebra <A> knows the value of `NiceAlgebraMonomorphism'
##  then it can be handled via the mechanism of nice bases.
##  Namely, the nice vector of an element can be computed via
##  `ImagesRepresentative',
##  and the ugly vector is given by `PreImagesRepresentative'.
##
##  `NiceAlgebraMonomorphism' is inherited to subalgebras and subspaces.
##  (If one knows that <A> contains the source then one should set
##  `GeneratorsOfLeftModule' for <A>,
##  and also one can set `NiceFreeLeftModule' for <A>  to the module
##  of the basis `basisimages'.)
##
##  The `NiceAlgebraMonomorphism' value of the algebra stored in
##  the `wholeFamily' component of the family of algebra elements
##  is used to define the `\<' relation of algebra elements.
#T use it also for a ``nice normal form''!
##
DeclareAttribute( "NiceAlgebraMonomorphism", IsSubalgebraFpAlgebra );

InstallSubsetMaintainedMethod( NiceAlgebraMonomorphism,
    IsFreeLeftModule and HasNiceAlgebraMonomorphism, IsFreeLeftModule );


#############################################################################
##
#M  IsHandledByNiceBasis( <A> ) . . . for f.p. algebra with known nice monom.
##
InstallTrueMethod( IsHandledByNiceBasis,
    IsSubalgebraFpAlgebra and HasNiceAlgebraMonomorphism );


#############################################################################
##
#F  FpAlgebraByGeneralizedCartanMatrix( <F>, <A> )
##
##  is a finitely presented associative algebra over the field <F>,
##  defined by the generalized Cartan matrix <A>.
##
DeclareGlobalFunction( "FpAlgebraByGeneralizedCartanMatrix" );


#############################################################################
##
#E  algfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

