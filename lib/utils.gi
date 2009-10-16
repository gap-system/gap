#############################################################################
##
#W  utils.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: utils.gi,v 4.14 2002/04/15 10:05:26 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This is a temporary file containing utilities for group chains.
##
Revision.utils_gi :=
    "@(#)$Id: utils.gi,v 4.14 2002/04/15 10:05:26 sal Exp $";


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
InstallGlobalFunction( UseSubsetRelationNC, function ( super, sub )
    local  entry;
    for entry  in SUBSET_MAINTAINED_INFO[1]  do
        if entry[1]( super ) and entry[2]( sub ) and not entry[4]( sub )  then
            entry[5]( sub, entry[3]( super ) );
        fi;
    od;
    return true;
end );

#############################################################################
##
#M  ImageUnderWord( <basicIm>, <word>, <orbitGenerators>, <homFromFree> )
##
InstallMethod( ImageUnderWord, "for basic images", true,
    [ IsList, IsWordWithInverse, IsList, IsGroupHomomorphism ], 0,
    function( basicIm, word, orbitGenerators, homFromFree )
	local newIm, i, freeGens, term, oGen;

	newIm := ShallowCopy( basicIm );
	freeGens := GeneratorsOfGroup( Source( homFromFree ) );
	for i in [1..Length( word )] do
	    term := Subword( word, i, i );
	    if term in freeGens then
		oGen := orbitGenerators[ Position( freeGens, term ) ];
	    else
		oGen := orbitGenerators[ Position( freeGens, term^(-1) ) ]^(-1);
	    fi;
	    newIm := List( newIm, b -> b^oGen );
	od;
	return newIm;
    end );

#############################################################################
##
#M  ImageUnderWord( <basicIm>, <word>, <orbitGenerators>, <homFromFree> )
##
InstallMethod( ImageUnderWord, "for integers", true,
    [ IsInt, IsWordWithInverse, IsList, IsGroupHomomorphism ], 0,
    function( pnt, word, orbitGenerators, homFromFree )
	local newIm, i, freeGens, term, oGen;

	freeGens := GeneratorsOfGroup( Source( homFromFree ) );
	for i in [1..Length( word )] do
	    term := Subword( word, i, i );
	    if term in freeGens then
		oGen := orbitGenerators[ Position( freeGens, term ) ];
	    else
		oGen := orbitGenerators[ Position( freeGens, term^(-1) ) ]^(-1);
	    fi;
	    pnt := pnt^oGen;
	od;
	return pnt;
    end );


#############################################################################
#############################################################################
##
##  Matrices and vectors
##
#############################################################################
#############################################################################

#############################################################################
##
#M  UnderlyingField( <V> )
##
InstallMethod( UnderlyingField, "for vector space", true,
    [ IsVectorSpace ], 0,
    V -> LeftActingDomain( V ) );

#############################################################################
##
#M  UnderlyingField( <A> )
##
InstallMethod( UnderlyingField, "for matrix algebra", true,
    [ IsAlgebra ], 0,
    A -> LeftActingDomain( A ) );

#############################################################################
##
#M  UnderlyingField( <G> )
##
InstallMethod( UnderlyingField, "for matrix group", true,
    [ IsFFEMatrixGroup ], 0,
    G -> FieldOfMatrixGroup( G ) );

#############################################################################
##
#M  MatrixDimension( <A> )
##
InstallMethod( MatrixDimension, "for matrix algebra", true,
    [ IsAlgebra ], 0,
    A -> Length( One( A ) ) );

#############################################################################
##
#M  MatrixDimension( <G> )
##
InstallMethod( MatrixDimension, "for matrix group", true,
    [ IsFFEMatrixGroup ], 0, DimensionOfMatrixGroup );

#############################################################################
##
#M  UnderlyingVectorSpace( <A> )
##
InstallMethod( UnderlyingVectorSpace, "for matrix algebra", true,
    [ IsAlgebra ], 0,
    A -> FullRowSpace( UnderlyingField(A), MatrixDimension(A) ) );

#############################################################################
##
#M  UnderlyingVectorSpace( <G )
##
InstallMethod( UnderlyingVectorSpace, "for matrix group", true,
    [ IsFFEMatrixGroup ], 0,
    G -> FullRowSpace( UnderlyingField(G), MatrixDimension(G) ) );

#############################################################################
##
#M  UnderlyingVectorSpace( <M> )
##
InstallMethod( UnderlyingVectorSpace, "for matrix", true,
    [ IsMatrix ], 0,
    M -> FullRowSpace( DefaultFieldOfMatrix(M), Length(M) ) );

#############################################################################
##
#M  FixedPointSpace( <matrix> )
##
InstallMethod( FixedPointSpace, "for matrix", true,
    [ IsMatrix ], 0,matrix ->
    Subspace( UnderlyingVectorSpace(matrix),
              NullspaceMat( matrix - One(matrix) ),
              "basis" ) ); # Tells GAP not to check if it's a basis.

#############################################################################
##
#M  PermMatrixGroup( <G> )
##
InstallMethod( PermMatrixGroup, "for perm group", true,
    [ IsPermGroup ], 0, 
    G -> Group( List( GeneratorsOfGroup( G ),
        elt -> PermutationMat( elt, Maximum( 1, NrMovedPoints(G) ),
                               GF(2) ) ) ) );

#############################################################################
##
#M  EnvelopingAlgebra( <G> )
##
InstallMethod( EnvelopingAlgebra, "for matrix group", true,
    [ IsFFEMatrixGroup ], 0, 
    G ->  Algebra(UnderlyingField(G), GeneratorsOfGroup(G)) );

#############################################################################
##
#M  SpanOfMatrixGroup( <G> )
##
InstallMethod( SpanOfMatrixGroup, "for matrix group", true,
    [ IsFFEMatrixGroup ], 0, 
    G -> AsVectorSpace( UnderlyingField(G), EnvelopingAlgebra(G) ) );

#############################################################################
##
#M  IsUniformMatrixGroup( <> )
##
##  Matrix group is uniform if fixed point space of every element
##    is either the trivial space or the entire space.
##    (used in Luks algorithm in solmxgrp.gi)
##
InstallMethod( IsUniformMatrixGroup, "for cyclic matrix p-group", true,
    [ IsFFEMatrixGroup and IsCyclic and IsPGroup ], 0,
    G -> IsIdenticalObj( G, InvariantSubspaceOrUniformCyclicPGroup(G) ) );

#############################################################################
##
#A  PreBasis( <H> )
##
InstallMethod( PreBasis, "for vector space homomorphisms", true,
    [ IsVectorSpaceHomomorphism ], 0, 
    function( H ) 
    local srcs, ims, subsp, im, newsubsp, b, imsp, B;

    B := Basis(Source(H));
    srcs := []; ims := [];
    imsp := Image(H);
    subsp := TrivialSubspace(imsp);
    for b in AsList(B) do
	im := ImageElm(H, b);
	newsubsp := Subspace( imsp, Concatenation( AsList(Basis(subsp)), [im] ) );
	if newsubsp <> subsp then
	    subsp := newsubsp;
	    Add( srcs, b );  Add(ims, im );
	fi;
    od;

    return [srcs, ims];
    end );

#############################################################################
##
#F Pullback( <H>, <v> )
##
InstallGlobalFunction( PullBack, function( H, v )  # v in image under H
    local preBasis, basis, tmp;
    tmp := PreBasis( H );
    preBasis := BasisNC( Source(H), tmp[1] );
    basis := Basis( Image(H), tmp[2] );
    return LinearCombination( Coefficients( basis, v ), preBasis );
end );

#############################################################################
##
#F  ImageMat( <H>, <A> )
##
InstallGlobalFunction( ImageMat, function( H, A )
local imgBasis, imgOfA;
    imgBasis := CanonicalBasis(Image(H));
    imgOfA := List( BasisVectors(imgBasis), v-> ImageElm( H, PullBack(H,v)^A ) );
    return TransposedMat( imgOfA );
end );

#############################################################################
##
#F  ExtendToBasis( <V>, <vects> )
##
InstallGlobalFunction( ExtendToBasis, function( V, vects )
     local subsp, b, newsubsp;

     vects := ShallowCopy( vects );
     subsp := Subspace( V, vects );
     for b in BasisVectors( Basis( V ) ) do
	newsubsp := Subspace( V,
                          Concatenation( BasisVectors(Basis(subsp)), [b] ) );
	if newsubsp <> subsp then
	    subsp := newsubsp;
	    Add( vects, b );
	fi;
    od;
   
    return Basis( V, vects );
end );

#############################################################################
##
#F  ProjectionOntoVectorSubspace( <V>, <W> )
##
##  H := ProjectionOfVectorSpace := function( V, W );
##  v := Random(V);  ImageElm(H, ImageElm(H, v)) = ImageElm(H, v);
##
InstallGlobalFunction( ProjectionOntoVectorSubspace, function( V, W ) # V->W
    local basisW, basisV;

    basisW := BasisVectors(Basis(W));
    basisV := BasisVectors(Basis(V));
    if not IsSubspace(V,W) then
	Print("ProjectionOntoVectorSubspace:  W must be a subspace of V\n");
	return fail;
    fi;
    return LeftModuleHomomorphismByImages(V, W, ExtendToBasis(V,basisW), 
		Concatenation( basisW,
      ListWithIdenticalEntries( Length(basisV) - Length(basisW), Zero(W) ) ) );
end );

#############################################################################
##
#F  IsomorphismToFullRowSpace( <V> )
##
InstallGlobalFunction( IsomorphismToFullRowSpace, function( V )  # V -> standard vector space
    local basisV, imV;

    basisV := BasisVectors(Basis(V));
    imV := FullRowSpace( Field(Flat(basisV)), Length(basisV) );
    return LeftModuleHomomorphismByImages(V, imV,
                                          basisV, BasisVectors(Basis(imV)) );
end );


#############################################################################
##
#F  ProjectionOntoFullRowSpace( <V>, <W> )
##
InstallGlobalFunction( ProjectionOntoFullRowSpace, function( V, W )  # V->W -> standard vector space
    return CompositionMapping( IsomorphismToFullRowSpace(W),
                               ProjectionOntoVectorSubspace(V, W) );
end );


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
##  REFERENCE:  (random subproducts, random normal subproducts,
##               random Schreier subproducts, random commutator subproducts)
##  G.~Cooperman and L.~Finkelstein, ``Combinatorial Tools for Computational
##  Group Theory'', Proceedings of DIMACS Workshop on Groups and Computation,
##  DIMACS-AMS 11, AMS Press, Providence, RI, 1993, pp.~53--86
##
InstallGlobalFunction( RandomSubprod, function(grp)
    local prod, gen;
    prod := One(grp);
    for gen in GeneratorsOfGroup(grp) do
        if Random([true,false]) then prod := prod * gen; fi;
    od;
    return prod;
end );

#############################################################################
##
#F  RandomNormalSubproduct( <grp>, <subgp> )
##
InstallGlobalFunction( RandomNormalSubproduct, function(grp, subgp)
    return RandomSubprod(subgp)^RandomSubprod(grp);
end );

#############################################################################
##
#F  RandomCommutatorSubproduct( <grp>, <subgp> )
##
InstallGlobalFunction( RandomCommutatorSubproduct, function(grp1, grp2)
    return Comm( RandomSubprod(grp1), RandomSubprod(grp2) );
end );

#############################################################################
##
#M  IsCharacteristicMatrixPGroup( <H> )
##
InstallMethod( IsCharacteristicMatrixPGroup, "for matrix p-group", true,
    [ IsFFEMatrixGroup and IsPGroup ], 0,
    H -> Characteristic(FieldOfMatrixGroup(H)) = PrimePGroup(H) );

#############################################################################
##
#M  IsNoncharacteristicMatrixPGroup( <H> )
##
InstallMethod( IsNoncharacteristicMatrixPGroup, "for matrix p-group", true,
    [ IsFFEMatrixGroup and IsPGroup ], 0,
    H -> Characteristic(FieldOfMatrixGroup(H)) <> PrimePGroup(H) );
InstallImmediateMethod( IsNoncharacteristicMatrixPGroup,
                        IsPGroup and HasIsCharacteristicMatrixPGroup,
                        0, grp -> not IsCharacteristicMatrixPGroup(grp) );

#############################################################################
##
#M  SizeUpperBound( <G> )
##
##  (implemented only what's needed for solmxgrp.gi)
##
InstallMethod( SizeUpperBound, "for groups", true, [ IsGroup ], SUM_FLAGS,
    function(G)
        if HasSize(G) then return Size(G);
        elif HasParent(G) and not IsIdenticalObj(G,Parent(G)) then
            return SizeUpperBound(Parent(G));
        else TryNextMethod(); return;
        fi;
    end );
InstallMethod( SizeUpperBound, "for matrix groups", true, [ IsFFEMatrixGroup ], 0,
    G -> Size(GL(DimensionOfMatrixGroup(G),Size(FieldOfMatrixGroup(G))) )); 
InstallMethod( SizeUpperBound, "for perm groups", true, [ IsPermGroup ], 0,
    G -> Size(SymmetricGroup(NrMovedPoints(G))) );

#############################################################################
##
#F  DecomposeEltIntoPElts( <elt> )
#F  DecomposeEltIntoPElts( <elt>, <ordOfElt> )
##
##  Returns list of lists, each of form:  [p, pElt]
##    such that each p is unique, pElt has order prime power of p,
##    and arg, elt, is product of pElt's.
##  (this format needed for PGroupGeneratorsOfAbelianGroup)
##
InstallGlobalFunction( DecomposeEltIntoPElts, function( arg )
    local elt, ordOfElt, powerElt, ord, elts, i;
    elt := arg[1];
    if Length( arg ) = 2 then ordOfElt := arg[2];
    else ordOfElt := Order( elt );
    fi;
    elts := [];
    ord := PrimePowersInt( ordOfElt );
    for i in 2*[1..Length(ord)/2]-1 do
      powerElt := elt^(ordOfElt/(ord[i]^ord[i+1]));
      elts[ ord[i] ] := [ ord[i], powerElt ];
    od;
    return Compacted(elts);
end );

#############################################################################
##
#M  PGroupGeneratorsOfAbelianGroup( <H> )
##
##  Returns list of lists, each of form:  [p, pgroupGenerators, exponent]
##  (this format needed for solmxgrp.gi)
##
InstallMethod( PGroupGeneratorsOfAbelianGroup, "for abelian groups", true,
[ IsGroup and IsAbelian ], 0,
function( H )
    local gen, ordOfGen, exponent, gens, decomp, pElt, base, exp;
    gens := [];
    exponent := 1;
    for gen in GeneratorsOfGroup( H ) do
        ordOfGen := Order( gen );
        exponent := LcmInt( exponent, ordOfGen );
        decomp := DecomposeEltIntoPElts( gen, ordOfGen );
        for pElt in decomp do
            if IsBound( gens[ pElt[1] ] ) then
                Add( gens[ pElt[1] ][2], pElt[2] );
            else gens[ pElt[1] ] := [ pElt[1], [pElt[2]] ];
            fi;
        od;
    od;
    SetExponent( H, exponent );
    # Set order of each pGroup in array slot 3
    base := 0;
    for exp in PrimePowersInt(exponent) do
        if base = 0 then base := exp;
        else
            gens[ base ][3] := base^(exp);
            base := 0;
        fi;
    od;
    return Compacted(gens);
end );

#############################################################################
##
#M  GeneratorOfCyclicGroup( <G> )
##
##  (implemented only what's needed for solmxgrp.gi)
##
InstallMethod( GeneratorOfCyclicGroup, "for cyclic matrix p-group",true,
        [ IsFFEMatrixGroup and IsCyclic and IsPGroup ], 0,
function( G )
    local gen;
    if IsTrivial(G) then
      return One(G);
    elif Length( GeneratorsOfGroup( G ) ) = 1 then
	return GeneratorsOfGroup( G )[1];
    elif IsUniformMatrixGroup(G) and IsNoncharacteristicMatrixPGroup(G) then
	InvariantSubspaceOrCyclicGroup(G);
	if not HasGeneratorOfCyclicGroup(G) then
	    Error("internal error:  no cyclic generator");
	elif Order(GeneratorOfCyclicGroup(G)) = 1 then
	    Error("internal error:  cyclic generator of order 1");
	else return GeneratorOfCyclicGroup(G);
	fi;
    else TryNextMethod();
	  return;
    fi;
end );


#############################################################################
##
#M  IndependentGeneratorsOfAbelianMatrixGroup( <> )
##
##  (implemented only what's needed for solmxgrp.gi)
##  (These should be unified with IndependentGeneratorsOfAbelianGroup,
##   which currently has methods for perm group)
##
InstallMethod( IndependentGeneratorsOfAbelianMatrixGroup,
  "for abelian matrix group", true,
  [ IsGroup and IsFFEMatrixGroup and IsAbelian ], 0,
  function(G)
    if IsTrivial(G) then return [];
    elif HasGeneratorOfCyclicGroup(G) then return [GeneratorOfCyclicGroup(G)];
    elif IsQuotientToAdditiveGroup(G) then
        return BasisOfHomCosetAddMatrixGroup(G).basis;
    elif HasChainSubgroup(G) and HasQuotientGroup(G) then
        return Concatenation(
             IndependentGeneratorsOfAbelianMatrixGroup(ChainSubgroup(G)),
             List( IndependentGeneratorsOfAbelianMatrixGroup(
                                                   QuotientGroup(G) ),
                   g -> SourceElt(g) ) );
    elif not  HasChainSubgroup(G) or not HasQuotientGroup(G) then
        MakeHomChain(G);
        return IndependentGeneratorsOfAbelianMatrixGroup(G);
    else return fail;
    fi;
end );
InstallMethod( IndependentGeneratorsOfAbelianMatrixGroup,
  "for additive groups", true,
  [ IsAdditiveGroup ], 0,
  function(G)
    if IsTrivial(G) then return [];
    elif HasGeneratorOfCyclicGroup(G) then return [GeneratorOfCyclicGroup(G)];
    else return BasisOfHomCosetAddMatrixGroup(G).basis;
  fi;
end );

#############################################################################
##
#F  IsInCenter( <G>, <g> )
#F  IsInCentre( <G>, <g> )
##
InstallGlobalFunction( IsInCenter,
    function(G,g)
    	return ForAll(GeneratorsOfGroup(G), h->IsOne(Comm(g,h)));
    end );
DeclareSynonym( "IsInCentre", IsInCenter );

#############################################################################
##
#F  UnipotentSubgroup( <n>, <p> )
##
InstallGlobalFunction( UnipotentSubgroup, function( n, p )
    local G, subgroup, gens, I, i, gen;
    G := GL(n,p);
    I := One( G );
    I := List( I, row -> ShallowCopy(row) ); # to make I mutable
    gens := [];
    for i in [1..n-1] do
	gen := StructuralCopy( I );
	gen[i][i+1] := One( GF(p) );
	Add( gens, gen );
    od;
    subgroup := SubgroupNC( G, gens );
    # The unipotent group is nilpotent
    SetIsNilpotentGroup(subgroup,true);
    return subgroup;
end );

#############################################################################
#############################################################################
##
##  Matrix group recognition
##
##  These are functions for the recursive part of the matrix group
##  recognition project.  They belong in a library file I intend to
##  write in the near future.
##
#############################################################################
#############################################################################

#############################################################################
##
#M  NaturalHomomorphismByInvariantSubspace( <A>, <W> )
##
##  Move to mxgrprec ???
##
InstallMethod( NaturalHomomorphismByInvariantSubspace, "for matrix algebra", true,
    [ IsAlgebra, IsVectorSpace ], 0,
    function( A, W )
    	return OperationAlgebraHomomorphism( A, Basis(W), OnRight );
    end );

#############################################################################
##
#M  NaturalHomomorphismByInvariantSubspace( <G>, <W> )
##
InstallMethod( NaturalHomomorphismByInvariantSubspace, "for matrix group", true,
    [ IsFFEMatrixGroup, IsVectorSpace ], 0,
function( G, W )
    local A, algHom, gens, imgs, MyImageElm;
    # GAP ImageElm() checks families, and only one family is HomCoset
    MyImageElm := function( hom, elt )
        return InducedLinearAction( hom!.basis, elt, hom!.operation );
    end;
    A := EnvelopingAlgebra( G );
    algHom := NaturalHomomorphismByInvariantSubspace( A, W );
    return GroupHomomorphismByFunction
        ( G, GL(Dimension(W),Size(UnderlyingField(W))), g->MyImageElm(algHom,g) );
end );

#############################################################################
##
#M  NaturalHomomorphismByFixedPointSubspace( <G>, <W> )
##
InstallMethod( NaturalHomomorphismByFixedPointSubspace, "for matrix group", true,
    [ IsFFEMatrixGroup, IsVectorSpace ], 0,
function( G, W )
    local A, vecHom, gens, imgs, dim, fnc;
    if not ForAll( GeneratorsOfGroup(G),
                   g -> ForAll( BasisVectors(Basis(W)), w->w*g=w ) ) then
        Error("Vector space, W, is not fixed by matrix group, G");
    fi;
    A := EnvelopingAlgebra( G );
    vecHom := NaturalHomomorphismBySubspace
                               ( UnderlyingVectorSpace(G), W );
    dim := DimensionOfVectors( W ) - Dimension(W);
    # preimagesbasisimage are subset of CanonicalBasis(Source(vecHom))
    #    such that their image is CanonicalBasis(Source(vecHom)/W)
    # Also CanonicalBasis(Source(vecHom)/W) are elem. basis vectors
    #    and because Source(vecHom) is FullRowSpace(), same is true for it.
    fnc := g -> List([1..dim],
                     i->ImageElm(vecHom,(vecHom!.preimagesbasisimage[i])*g));
    # THESE DON'T WORK.  WHY??
    # Apparently, GAP calls ImagesSet() instead of ImagesList() (if it existed)
    # So, GAP assumes the non-set as input should be ordered as set on output
    #fnc := g -> ImageElm(vecHom,(vecHom!.preimagesbasisimage)*g);
    #fnc := g->ImageElm(vecHom, List([1..dim],i->(vecHom!.preim...[i])*g));
    return GroupHomomorphismByFunction
                          (G, GL(dim, Size(UnderlyingField(W))), fnc );
end );

#############################################################################
##
#M  NaturalHomomorphismByHomVW( <G>, <W> )
##
InstallMethod( NaturalHomomorphismByHomVW, "for matrix group", true,
    [ IsFFEMatrixGroup, IsVectorSpace ], 0,
function( G, W )
    local V, fnc, hom; # Note that W is not used.
    V := UnderlyingVectorSpace(G);
    fnc := g -> List( BasisVectors(Basis(V)), v -> v*g-v );
    # if fnc(G.1*G.1) <> fnc(G.1)+fnc(G.1) then
    #     Error("inconsistent"); fi;
    #NOTE:  GAP also has IsFullHomModule(), Hom()
    # LeftModuleHomomorphismByImages(), etc.  Prob. not general enough
    #   for us, although GAP would then understand hom space
    #   as a Gaussian matrix space (in which lin. algebra works)..
    # Image of hom. is Hom(V,subspace) as additive group
    # This works because subspace vectors are fixed by G
    #   and Im(G) \le subspace
    hom := GroupHomomorphismByFunction(
	  G,
	  # AdditiveGroupByGenerators(GeneratorsOfGroup(
	  SubadditiveGroupNC(
	      GL(DimensionOfMatrixGroup(G),Size(FieldOfMatrixGroup(G))),
	      GeneratorsOfGroup(
	      GL(DimensionOfMatrixGroup(G),Size(FieldOfMatrixGroup(G)))
	  )),
	  fnc );
    # GAP4r1 Image(hom) needs this patch when range is AdditiveGroup()
    SetImagesSource( hom,
		     AdditiveGroup( List( GeneratorsOfGroup(G), fnc ) ) );
    UseSubsetRelation( Range(hom), Image(hom) );
    return hom;
end );


#E
