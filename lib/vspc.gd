#############################################################################
##
#W  vspc.gd                     GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for vector spaces.
##
##  The operations for bases of free left modules can be found in the file
##  `basis.g'.
##
Revision.vspc_gd :=
    "@(#)$Id$";

#1
##  Vector spaces are free left modules over a field.

#############################################################################
##
#C  IsLeftOperatorRing(<R>)
##
DeclareSynonym( "IsLeftOperatorRing",
    IsLeftOperatorAdditiveGroup and IsRing and IsAssociativeLOpDProd );
#T really?


#############################################################################
##
#C  IsLeftOperatorRingWithOne(<R>)
##
DeclareSynonym( "IsLeftOperatorRingWithOne",
    IsLeftOperatorAdditiveGroup and IsRingWithOne
    and IsAssociativeLOpDProd );
#T really?


#############################################################################
##
#C  IsLeftVectorSpace( <D> )
#C  IsVectorSpace( <D> )
##
##  A (left) vector space in {\GAP} is an additive group that is acted on by
##  a division ring from the left such that this action and the addition are
##  left and right distributive.
##
##  (Vector spaces in {\GAP} are always left vector spaces.)
##
DeclareSynonym( "IsLeftVectorSpace",
    IsLeftModule and IsLeftActedOnByDivisionRing );

DeclareSynonym( "IsVectorSpace", IsLeftVectorSpace );

InstallTrueMethod( IsFreeLeftModule,
    IsLeftModule and IsLeftActedOnByDivisionRing );


#############################################################################
##
#F  IsGaussianSpace( <V> )
##
##  The filter `IsGaussianSpace' for the row space (see~"IsRowSpace") or
##  matrix space (see~"IsMatrixSpace") <V> over the field $F$, say,
##  indicates that the entries of all row vectors or matrices in <V>,
##  respectively, are all contained in $F$.
##  In this case, <V> is called a *Gaussian* vector space.
##  Bases for Gaussian spaces can be computed using Gaussian elimination for
##  a given list of vector space generators.
##
DeclareFilter( "IsGaussianSpace", IsVectorSpace );

InstallTrueMethod( IsGaussianSpace,
    IsVectorSpace and IsFullMatrixModule );

InstallTrueMethod( IsGaussianSpace,
    IsVectorSpace and IsFullRowModule );


#############################################################################
##
#C  IsDivisionRing( <D> )
##
##  A *division ring* in {\GAP} is a nontrivial associative algebra <D>
##  with a multiplicative inverse for each nonzero element.
##  In {\GAP} every division ring is a vector space over a division ring
##  (possibly over itself).
##  Note that being a division ring is thus not a property that a ring can
##  get, because a ring is usually not represented as a vector space.
##
##  The field of coefficients is stored as `LeftActingDomain( <D> )'.
##
DeclareSynonymAttr( "IsDivisionRing",
        IsMagmaWithInversesIfNonzero
    and IsLeftOperatorRing
    and IsLeftVectorSpace
    and IsNonTrivial
    and IsAssociative );


#############################################################################
##
#A  GeneratorsOfLeftVectorSpace( <V> )
#A  GeneratorsOfVectorSpace( <V> )
##
##  returns a set of elements of <V> that spans <V>.
##
DeclareSynonymAttr( "GeneratorsOfLeftVectorSpace",
    GeneratorsOfLeftOperatorAdditiveGroup );

DeclareSynonymAttr( "GeneratorsOfVectorSpace",
    GeneratorsOfLeftOperatorAdditiveGroup );


#############################################################################
##
#A  CanonicalBasis( <V> )
##
##  If the vector space <V> supports a canonical basis then `CanonicalBasis'
##  returns this basis, otherwise `fail' is returned.
##
##  The defining property of a canonical basis is that its vectors are
##  uniquely determined by the vector space.
##  If canonical bases exist for two vector spaces over the same left acting
##  domain (see~"LeftActingDomain") then the equality of these vector spaces
##  can be decided by comparing the canonical bases.
##
##  The exact meaning of a canonical basis depends on the type of <V>.
##  A canonical basis is defined for example for Gaussian row and matrix
##  spaces (see~"Row and Matrix Spaces").
##
DeclareAttribute( "CanonicalBasis", IsFreeLeftModule );


#############################################################################
##
#F  IsRowSpace( <V> )
##
DeclareSynonym( "IsRowSpace", IsRowModule and IsVectorSpace );


#############################################################################
##
#F  IsGaussianRowSpace( <V> )
##
##  A row space is *Gaussian* if the left acting domain contains all
##  scalars that occur in the vectors.
##  Thus one can use Gaussian elimination in the calculations.
##
##  (Otherwise the space is non-Gaussian.
##  We will need a flag for this to write down methods that delegate from
##  non-Gaussian spaces to Gaussian ones.)
##
DeclareSynonym( "IsGaussianRowSpace", IsGaussianSpace and IsRowSpace );


#############################################################################
##
#F  IsNonGaussianRowSpace( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsNonGaussianRowSpace' then
##  this expresses that <V> consists of row vectors (see~"IsRowVector") such
##  that not all entries in these row vectors are contained in $F$
##  (so Gaussian elimination cannot be used to compute an $F$-basis from a
##  list of vector space generators),
##  and that <V> is handled via the mechanism of nice bases (see~"...") in
##  the following way.
##  Let $K$ be the field spanned by the entries of all vectors in <V>.
##  Then the `NiceFreeLeftModuleInfo' value of <V> is a basis $B$ of the
##  field extension $K / ( K \cap F )$,
##  and the `NiceVector' value of $v \in <V>$ is defined by replacing each
##  entry of $v$ by the list of its $B$-coefficients, and then forming the
##  concatenation.
##
##  So the associated nice vector space is a Gaussian row space (see~"...").
##
DeclareHandlingByNiceBasis( "IsNonGaussianRowSpace",
    "for non-Gaussian row spaces" );


#############################################################################
##
#F  IsMatrixSpace( <V> )
##
DeclareSynonym( "IsMatrixSpace", IsMatrixModule and IsVectorSpace );


#############################################################################
##
#F  IsGaussianMatrixSpace( <V> )
##
##  A matrix space is Gaussian if the left acting domain contains all
##  scalars that occur in the vectors.
##  Thus one can use Gaussian elimination in the calculations.
##
##  (Otherwise the space is non-Gaussian.
##  We will need a flag for this to write down methods that delegate from
##  non-Gaussian spaces to Gaussian ones.)
##
DeclareSynonym( "IsGaussianMatrixSpace", IsGaussianSpace and IsMatrixSpace );


#############################################################################
##
#F  IsNonGaussianMatrixSpace( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsNonGaussianMatrixSpace'
##  then this expresses that <V> consists of matrices (see~"IsMatrix") such
##  that not all entries in these matrices are contained in $F$
##  (so Gaussian elimination cannot be used to compute an $F$-basis from a
##  list of vector space generators),
##  and that <V> is handled via the mechanism of nice bases (see~"...") in
##  the following way.
##  Let $K$ be the field spanned by the entries of all vectors in <V>.
##  The `NiceFreeLeftModuleInfo' value of <V> is irrelevant,
##  and the `NiceVector' value of $v \in <V>$ is defined as the concatenation
##  of the rows of $v$.
##
##  So the associated nice vector space is a (not necessarily Gaussian)
##  row space (see~"...").
##
DeclareHandlingByNiceBasis( "IsNonGaussianMatrixSpace",
    "for non-Gaussian matrix spaces" );


#############################################################################
##
#A  NormedRowVectors( <V> ) . . .  normed vectors in a Gaussian row space <V>
##
##  For a finite Gaussian row space <V> (see~"IsRowSpace",
##  "IsGaussianSpace"), `NormedRowVectors' returns a list of those nonzero
##  vectors in <V> that have a one in the first nonzero component.
##
##  The result list can be used as action domain for the action of a matrix
##  group via `OnLines' (see~"OnLines"), which yields the natural action on
##  one-dimensional subspaces of <V> (see also~"Subspaces").
##
DeclareAttribute( "NormedRowVectors", IsGaussianSpace );

DeclareSynonymAttr( "NormedVectors", NormedRowVectors );


#############################################################################
##
#A  TrivialSubspace( <V> )
##
##  returns the subspace of <V> generated by the zero vector of <V>
##
DeclareSynonymAttr( "TrivialSubspace", TrivialSubmodule );


#############################################################################
##
#O  AsSubspace( <V>, <U> )  . . . . . . . . . . . view <U> as subspace of <V>
##
##  If the vector space <U> happens to be contained in the vector
##  space <V>, then it can be viewed as subspace of <V>. This function
##  returns that subspace.
##
DeclareOperation( "AsSubspace", [ IsVectorSpace, IsVectorSpace ] );


#############################################################################
##
#O  AsVectorSpace( <F>, <D> ) . . . . . . . . .  view <D> as <F>-vector space
##
##  returns the domain <D> viewed as vector space over <F>.
##
DeclareSynonym( "AsVectorSpace", AsLeftModule );


#############################################################################
##
#F  VectorSpace( <F>, <gens>[, <zero>][, "basis"] )
##
##  For a field <F> and a collection <gens> of vectors, `VectorSpace' returns
##  the <F>-vector space spanned by the elements in <gens>.
##  The optional argument <zero> can be used to specify the zero element of
##  the space.
##  The optional argument `\"basis\"' indicates that <gens> is known to be
##  linearly independent over <F>.
#T crossref. to `FreeLeftModule' as soon as the modules chapter is reliable!
##
DeclareSynonym( "VectorSpace", FreeLeftModule );


#############################################################################
##
#F  Subspace( <V>, <gens>[, "basis"] )  . subspace of <V> generated by <gens>
#F  SubspaceNC( <V>, <gens>[, "basis"] )
##
##  For an $F$-vector space <V> and a list or collection <gens> that is a
##  subset of <V>, `Subspace' returns the $F$-vector space spanned by <gens>;
##  if <gens> is empty then the trivial subspace (see~"TrivialSubspace") of
##  <V> is returned.
##
##  `SubspaceNC' does the same as `Subspace', except that it omits the check
##  whether <gens> is a subset of <V>.
##
##  The optional argument `\"basis\"' indicates that <gens> is known to be
##  linearly independent over $F$.
##  In this case the dimension of the subspace is immediately set,
##  and it is *not* checked (also by `Subspace') whether <gens> really is
##  linearly independent and whether <gens> is a subset of <V>.
#T crossref. to `Submodule' as soon as the modules chapter is reliable!
##
DeclareSynonym( "Subspace", Submodule );

DeclareSynonym( "SubspaceNC", SubmoduleNC );


#############################################################################
##
#F  Intersection2Spaces( <AsStruct>, <Substruct>, <Struct> )
##
##  is a function that takes two arguments <V> and <W> which must be finite
##  dimensional vector spaces, and returns the intersection of <V> and <W>.
##
##  If the left acting domains are different then let $F$ be their
##  intersection.
##  The intersection of <V> and <W> is computed as intersection of
##  `<AsStruct>( <F>, <V> )' and `<AsStruct>( <F>, <V> )'.
##
##  If the left acting domains are equal to $F$ then the intersection of <V>
##  and <W> is returned either as $F$-<Substruct> with the common parent of
##  <V> and <W> or as $F$-<Struct>, in both cases with known basis.
##
##  This function is used to handle the intersections of two vector spaces,
##  two algebras, two algebras-with-one, two left ideals, two right ideals,
##  two two-sided ideals.
##
DeclareGlobalFunction( "Intersection2Spaces" );


#############################################################################
##
#F  FullRowSpace( <F>, <n> )
##
##  For a field <F> and a nonnegative integer <n>, `FullRowSpace' returns the
##  <F>-vector space that consists of all row vectors (see~"IsRowVector") of
##  length <n> with entries in <F>.
##
##  An alternative to construct this vector space is via `<F>^<n>'.
##
DeclareSynonym( "FullRowSpace", FullRowModule );
DeclareSynonym( "RowSpace", FullRowModule );


#############################################################################
##
#F  FullMatrixSpace( <F>, <m>, <n> )
##
##  For a field <F> and two positive integers <m> and <n>, `FullMatrixSpace'
##  returns the <F>-vector space that consists of all <m> by <n> matrices
##  (see~"IsMatrix") with entries in <F>.
##
##  If `<m> = <n>' then the result is in fact an algebra
##  (see~"FullMatrixAlgebra").
##
##  An alternative to construct this vector space is via `<F>^[<m>,<n>]'.
##
DeclareSynonym( "FullMatrixSpace", FullMatrixModule );
DeclareSynonym( "MatrixSpace", FullMatrixModule );
DeclareSynonym( "MatSpace", FullMatrixModule );


#############################################################################
##
#C  IsSubspacesVectorSpace( <D> )
##
##  The domain of all subspaces of a (finite) vector space lies in the
##  category `IsSubspacesVectorSpace'.
##
DeclareCategory( "IsSubspacesVectorSpace", IsDomain );


#############################################################################
##
#M  IsFinite( <D> ) . . . . . . . . . . . . . . . . .  for a subspaces domain
##
##  Returns `true' if <D> is finite.
##  We allow subspaces domains in `IsSubspacesVectorSpace' only for finite
##  vector spaces.
##
InstallTrueMethod( IsFinite, IsSubspacesVectorSpace );


#############################################################################
##
#A  Subspaces( <V> )
#O  Subspaces( <V>, <k> )
##
##  Let <V> be a finite vector space.  In the first form, `Subspaces' returns
##  the domain of all subspaces of <V>.
##  In the second form, <k> must be a nonnegative integer, and `Subspaces'
##  returns the domain of all <k>-dimensional subspaces of <V>.
##
DeclareAttribute( "Subspaces", IsLeftModule );
DeclareOperation( "Subspaces", [ IsLeftModule, IsInt ] );


#############################################################################
##
#F  IsSubspace( <V>, <U> )
##
##  check that <U> is a vector space that is contained in <V>
#T Must also <V> be a vector space?
#T If yes then must <V> and <U> have same left acting domain?
#T (Is this function useful at all?)
##
DeclareGlobalFunction( "IsSubspace" );


#############################################################################
##
#O  OrthogonalSpaceInFullRowSpace( <U> )
##
##  computes the dual space to <U> in the full row space underlying <U>
##  using the standard scalar product.
##
DeclareAttribute( "OrthogonalSpaceInFullRowSpace", IsGaussianSpace );


#############################################################################
##
#P  IsVectorSpaceHomomorphism( <map> )
##
##  A mapping $f$ is a vector space homomorphism (or linear mapping) if
##  the source and range are vector spaces (see~"IsVectorSpace")
##  over the same division ring $D$ (see~"LeftActingDomain"),
##  and if $f( a + b ) = f(a) + f(b)$ and $f( s \* a ) = s \* f(a)$ hold
##  for all elements $a$, $b$ in the source of $f$ and $s \in D$.
##
DeclareProperty( "IsVectorSpaceHomomorphism", IsGeneralMapping );


#############################################################################
##
#E

