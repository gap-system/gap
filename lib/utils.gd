#############################################################################
##
#W  utils.gd			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This is a temporary file containing utilities for group chains.
##

#############################################################################
#############################################################################
##
##  General 
##
#############################################################################
#############################################################################

#############################################################################
##
#F  UseSubsetRelationNC( <super>, <sub> )
##
##  This would be a useful GAP fnc.  For UseSubsetRelation,
##    GAP currently requires:  FAMILY PREDICATE:  IS_IDENTICAL_OBJ
##
DeclareGlobalFunction( "UseSubsetRelationNC", [ IsCollection, IsCollection ] );

#############################################################################
##
#O  ImageUnderWord( <basicIm>, <word>, <orbitGenerators>, <homFromFree> )
##
DeclareOperation( "ImageUnderWord", [ IsList, IsWordWithInverse, IsList, IsGroupHomomorphism ] );

#############################################################################
##
#O  ImageUnderWord( <basicIm>, <word>, <orbitGenerators>, <homFromFree> )
##
##  The image of <basicIm> under <word> evaluated in the orbit generators.
##
DeclareOperation( "ImageUnderWord", [ IsInt, IsWordWithInverse, IsList, IsGroupHomomorphism ] );

#############################################################################
#############################################################################
##
##  Matrices and vectors
##
#############################################################################
#############################################################################

#############################################################################
##
#A  UnderlyingVectorSpace( <A> )
##
##  Underlying vector space of an algebra.
##
DeclareAttribute( "UnderlyingVectorSpace", IsAlgebra );

#############################################################################
##
#A  UnderlyingVectorSpace( <G> )
##
##  Underlying vector space of a matrix group.
##
DeclareAttribute( "UnderlyingVectorSpace", IsFFEMatrixGroup );

#############################################################################
##
#A  UnderlyingVectorSpace( <M> )
##
##  Underlying vector space of a matrix???
##
DeclareAttribute( "UnderlyingVectorSpace", IsMatrix );

#############################################################################
##
#O  FixedPointSpace( <matrix> )
##
##  The fixed point space of a matrix.
##
DeclareOperation( "FixedPointSpace", [ IsMatrix ] );

#############################################################################
##
#O  PermMatrixGroup( <G> )
##
##  Convert a permutation group to a group of permutation matrices over GF(2).
##
DeclareOperation( "PermMatrixGroup", [ IsPermGroup ] );

#############################################################################
##
#O  EnvelopingAlgebra( <G> )
##
##  The enveloping algebra of a matrix group.
##
DeclareOperation( "EnvelopingAlgebra", [ IsFFEMatrixGroup ] );

#############################################################################
##
#O  SpanOfMatrixGroup( <G> )
##
##  The vector space span of a matrix group.
##
DeclareOperation( "SpanOfMatrixGroup", [ IsFFEMatrixGroup ] );

#############################################################################
##
#P  IsUniformMatrixGroup( <G> )
##
##  Matrix group is uniform if fixed point space of every element
##  is either the trivial space or the entire space.
##
DeclareProperty( "IsUniformMatrixGroup", IsFFEMatrixGroup );

#############################################################################
##
#A  PreBasis( <H> )
##
##  Basis for the source of <H>, such that the images of the elements
##  are in the basis for the range.
##
DeclareAttribute( "PreBasis", IsVectorSpaceHomomorphism );

#############################################################################
##
#F Pullback( <H>, <v> )
##
##  Image(H, PullBack( H, v )) = v; # => true;
##
DeclareGlobalFunction( "PullBack", [ IsVectorSpaceHomomorphism, IsVector ] );

#############################################################################
##
#F  ImageMat( <H>, <A> )
##
##  v  := Random(Source(H));  A := Random(G);
##  Image(H, v)^ImageMat( H, A ) = Image(H, v^A); #  => true
##
DeclareGlobalFunction( "ImageMat", [ IsVectorSpaceHomomorphism, IsMatrix ] );

#############################################################################
##
#F  ExtendToBasis( <V>, <vects> )
##
##  Extend <vects> to a basis.
##
DeclareGlobalFunction( "ExtendToBasis", [ IsVectorSpace, IsList ] );

#############################################################################
##
#F  ProjectionOntoVectorSubspace( <V>, <W> )
##
##  Returns the projection of <V> onto <W>
##
DeclareGlobalFunction( "ProjectionOntoVectorSubspace", 
    [ IsVectorSpace, IsVectorSpace ] );

#############################################################################
##
#F  IsomorphismToFullRowSpace( <V> )
##
##  Returns the isomorphism from <V> to the appropriate row space.
##
DeclareGlobalFunction( "IsomorphismToFullRowSpace", [ IsVectorSpace ] );

#############################################################################
##
#F  ProjectionOntoFullRowSpace( <V>, <W> )
##
##  Returns the projection from <V> onto a full row space isomorphic to <W>.
##
DeclareGlobalFunction( "ProjectionOntoFullRowSpace", 
    [ IsVectorSpace, IsVectorSpace ] );


#############################################################################
#############################################################################
##
##  Groups
##
#############################################################################
#############################################################################

#############################################################################
##
#F  RandomSubprod( <grp> )
##
##  Returns a random subproduct of the generators of <grp>.
##
DeclareGlobalFunction( "RandomSubprod", [ IsGroup, IsVectorSpace ] );

#############################################################################
##
#F  RandomNormalSubproduct( <grp>, <subgp> )
##
##  Returns a random normal subproduct.
##
DeclareGlobalFunction( "RandomNormalSubproduct", [ IsGroup, IsGroup ] );

#############################################################################
##
#F  RandomCommutatorSubproduct( <grp1>, <grp2> )
##
##  Returns a random commutator subproduct.
##
DeclareGlobalFunction( "RandomCommutatorSubproduct", [ IsGroup, IsGroup ] );

#############################################################################
##
#P  IsCharacteristicMatrixPGroup( <H> )
#P  IsNoncharacteristicMatrixPGroup( <H> )
##
##  A matrix group is a characteristic $p$-group if it is a $p$-group
##  and $p$ is also the characteristic of the underlying field.
##
##     HasIsCharacteristicMatrixPGroup to true.  Hence, we have three cases:
##     (1) HasIsCharacteristicMatrixPGroup false
##     (2) HasIsCharacteristicMatrixPGroup true, and IsCharacteristicMatrixPGroup true
##     (3) HasIsCharacteristicMatrixPGroup true, and IsCharacteristicMatrixPGroup false
##     The last case should be synonymous with IsNoncharacteristicMatrixPGroup
##     Hence, when an IsCharacteristicMatrixPGroup method is applicable, the
##     IsNoncharacteristicMatrixPGroup method will also be applicable, but
##     the IsCharacteristicMatrixPGroup will be considered more specific, and
##     so will always be preferred over the IsNoncharacteristicMatrixPGroup method.
##  DeclareSynonym( "IsNoncharacteristicMatrixPGroup", HasIsCharacteristicMatrixPGroup );
##  gdc - This is bogus.  We should just have two separate attributes
##        with an immediate method connecting them.
##  InstallImmediateMethod( IsNoncharacteristicMatrixPGroup, HasIsCharacteristicMatrixPGroup,
##                          0, grp -> not IsCharacteristicMatrixPGroup );
DeclareProperty( "IsCharacteristicMatrixPGroup", IsFFEMatrixGroup );
DeclareProperty( "IsNoncharacteristicMatrixPGroup", IsFFEMatrixGroup );

#############################################################################
##
#O  SizeUpperBound( <G> )
##
##  Return an upper bound on the order of the group <G>.
##
DeclareOperation( "SizeUpperBound", [ IsGroup ] );

#############################################################################
##
#F  DecomposeEltIntoPElts( <elt> )
#F  DecomposeEltIntoPElts( <elt>, <ordOfElt> )
##
##  Produces list of elements:  [p, elti], where p prime,
##  elti has order a power of p, and cyclic group generated by elt
##  is same as group generated by union of elements, elti.
##  NO CHECKING:  If you lie about the order, you get a false result.
##    This seems to be similar to GAP's IndependentGeneratorsOfAbelianGroup(),
##    but we need the extra information
##
DeclareGlobalFunction( "DecomposeEltIntoPElts" );

#############################################################################
##
#O  PGroupGeneratorsOfAbelianGroup( <H> )
##
##  Produces list of p-groups, each elt of form [p, pgroupGenerators, exponent]
##
DeclareOperation( "PGroupGeneratorsOfAbelianGroup", 
    [ IsGroup and IsAbelian ] );

#############################################################################
##
#A  GeneratorOfCyclicGroup( <G> )
##
##  Cyclic groups must have a single generator.  Store it.
##  This is useful for groups given with multiple generators which are 
##  later shown to be cyclic.
##  Note this gives an implicit presentation for the group.
##
DeclareAttribute( "GeneratorOfCyclicGroup", IsGroup and IsCyclic );

#############################################################################
##
#A  IndependentGeneratorsOfAbelianMatrixGroup( <H> )
##
##  Note this gives an implicit presentation for the group.
##  This should replace the current matrix group method for 
##  IndependentGeneratorsOfAbelianGroup.
##
DeclareAttribute( "IndependentGeneratorsOfAbelianMatrixGroup",
                  IsGroup and IsFFEMatrixGroup and IsAbelian );
DeclareAttribute( "IndependentGeneratorsOfAbelianMatrixGroup",
                  IsAdditiveGroup );

#############################################################################
##
#F  IsInCenter( <G>, <g> )
#F  IsInCentre( <G>, <g> )
##
##  Is <g> in the centre of <G>?
##
DeclareGlobalFunction( "IsInCenter", [ IsGroup, IsAssociativeElement ] );

#############################################################################
##
#F  UnipotentSubgroup( <n>, <p> )
##
##  Returns the unipotent subgroup of GL( <n>, <p> ).
##  Currently <p> must be prime.
##
DeclareGlobalFunction( "UnipotentSubgroup", [ IsInt, IsInt ] );


#############################################################################
#############################################################################
##
##  Matrix group recognition
##
#############################################################################
#############################################################################

#############################################################################
##
#O  NaturalHomomorphismByInvariantSubspace( <A>, <W> )
##
##  The natural homomorphism of a matrix algebra <A> given by an invariant 
##  subspace <W> of the underlying vector space.
##
DeclareOperation( "NaturalHomomorphismByInvariantSubspace",
    [ IsAlgebra, IsVectorSpace ] );

#############################################################################
##
#O  NaturalHomomorphismByInvariantSubspace( <G>, <W> )
##
##  The natural homomorphism of a matrix group <G> given by an invariant 
##  subspace <W> of the underlying vector space.
##
DeclareOperation( "NaturalHomomorphismByInvariantSubspace",
    [ IsFFEMatrixGroup, IsVectorSpace ] );

#############################################################################
##
#O  NaturalHomomorphismByFixedPointSubspace( <G>, <W> )
##
##  The natural homomorphism given by a fixed point subspace.
##
DeclareOperation( "NaturalHomomorphismByFixedPointSubspace",
    [ IsFFEMatrixGroup, IsVectorSpace ] );

#############################################################################
##
#O  NaturalHomomorphismByHomVW( <G>, <W> )
##
##  We are in the case of Hom(V,W)
##  Get hom from g to Hom(V,W) by g-> (v -> v*g-v) for v in V,
##  and interpret result as f in Hom(V,W), by images on Basis(V)
##  where Hom(V,W) is viewed as additive group.
##  NOTE: v*(hg)-v=(v*h-v)*g+(v*g-v),\phi(h*g)=\phi(h)\circ\phi(g)
##  This is Hom from mult. grp. to additive grp.
##  Action of G on this is  v*g^(-1)*f*g when W<V is G-invar.
##  This needs a better name.
##
DeclareOperation( "NaturalHomomorphismByHomVW",
    [ IsFFEMatrixGroup, IsVectorSpace ] );


#E
