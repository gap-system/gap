#############################################################################
##
#W  ghom.gd                     GAP library                     Thomas Breuer
#W                                                           Alexander Hulpke
#W                                                             Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  1. Functions for creating group general mappings by images
##  2. Functions for creating natural homomorphisms
##  3. Functions for conjugation action
##  4. Functions for ...
##
Revision.ghom_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. Functions for creating group general mappings by images
##


#############################################################################
##
#O  GroupGeneralMappingByImages( <G>, <H>, <gensG>, <gensH> )
##
##  returns a generalized mapping defined by extending the mapping from
##  <gensG> to <gensH> homomorphically.
##  (`GroupHomomorphismByImages' creates a `GroupGeneralMappingByImages' and
##  tests whether it `IsMapping'.)
DeclareOperation( "GroupGeneralMappingByImages",
    [ IsGroup, IsGroup, IsList, IsList ] );


#############################################################################
##
#F  GroupHomomorphismByImages( <G>, <H>, <gens>, <imgs> )
##
##  `GroupHomomorphismByImages' returns the group homomorphism with
##  source <G> and range <H> that is defined by mapping the list <gens> of
##  generators of <G> to the list <imgs> of images in <H>.
##
##  If <gens> does not generate <G> or if the mapping of the generators does
##  not extend to a homomorphism
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then `fail' is returned.
##
##  This test can be quite expensive. If one is certain that the mapping of
##  the generators extends to a homomorphism,
##  one can avoid the checks by calling `GroupHomomorphismByImagesNC'.
##  (There also is the possibility to
##  construct potentially multi-valued mappings with
##  `GroupGeneralMappingByImages' and to test with `IsMapping' that
##  they are indeed homomorphisms.)
##
DeclareGlobalFunction( "GroupHomomorphismByImages" );


#############################################################################
##
#O  GroupHomomorphismByImagesNC( <G>, <H>, <gensG>, <gensH> )
##
##  `GroupHomomorphismByImagesNC' creates a homomorphism as
##  `GroupHomomorphismByImages' does, however it does not test whether
##  <gens> generates <G> and that the mapping of
##  <gens> to <imgs> indeed defines a group homomorphism.
##  Because these tests can be expensive it can be substantially faster than
##  `GroupHomomorphismByImages'.
##  Results are unpredictable if the conditions do not hold.
##
##  (For creating a possibly multi-valued mapping from <G> to <H> that
##  respects multiplication and inverses,
##  `GroupGeneralMappingByImages' can be used.)
##
#T If we could guarantee that it does not matter whether we construct the
#T homomorphism directly or whether we construct first a general mapping
#T and ask it for  being a homomorphism,
#T then this operation would be obsolete,
#T and `GroupHomomorphismByImages' would be allowed to return the general
#T mapping itself after the checks.
#T (See also the declarations of `AlgebraHomomorphismByImagesNC',
#T `AlgebraWithOneHomomorphismByImagesNC',
#T `LeftModuleHomomorphismByImagesNC'.)
##
DeclareOperation( "GroupHomomorphismByImagesNC",
    [ IsGroup, IsGroup, IsList, IsList ] );


#############################################################################
##
#R  IsGroupGeneralMappingByImages(<map>)
##
##  Representation for mappings from one group to another that are defined
##  by extending a mapping of group generators homomorphically.
DeclareRepresentation( "IsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep,
      [ "generators", "genimages" ] );

#############################################################################
##
#R  IsPreimagesByAsGroupGeneralMappingByImages(<map>)
##
##  Representation for mappings that delegate work for preimages to a
##  GroupHomomorphismByImages.
DeclareRepresentation( "IsPreimagesByAsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep,
      [  ] );

#############################################################################
##
#R  IsGroupGeneralMappingByAsGroupGeneralMappingByImages(<map>)
##
##  Representation for mappings that delegate work on a
##  `GroupHomomorphismByImages'.
DeclareRepresentation( "IsGroupGeneralMappingByAsGroupGeneralMappingByImages",
      IsPreimagesByAsGroupGeneralMappingByImages, [  ] );

#############################################################################
##
#A   AsGroupGeneralMappingByImages(<map>)
##
##   If <map> is a mapping from one group to another this attribute returns
##   a group general mapping that which implements the same abstract
##   mapping. (Some operations can be performed more effective in this
##   representation, see
##   also~"IsGroupGeneralMappingByAsGroupGeneralMappingByImages".)
DeclareAttribute( "AsGroupGeneralMappingByImages", IsGroupGeneralMapping );

#############################################################################
##
#A  MappingOfWhichItIsAsGGMBI(<map>)
##
##  If <map> is `AsGroupGeneralMappingByImages(<map2>)' then
##  <map2> is `MappingOfWhichItIsAsGGMBI(<map>)'. This attribute is used to
##  transfer attribute values which were set later.
DeclareAttribute( "MappingOfWhichItIsAsGGMBI", IsGroupGeneralMapping );

InstallAttributeMethodByGroupGeneralMappingByImages :=
  function( attr, value_filter )
    InstallMethod( attr, "via `AsGroupGeneralMappingByImages'", true,
            [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages ], 0,
            hom -> attr( AsGroupGeneralMappingByImages( hom ) ) );
    InstallMethod( attr, "get delayed set attribute values", true,
            [ HasMappingOfWhichItIsAsGGMBI ],
	    SUM_FLAGS-1, # we want to do this before doing any calculations
	    function(hom)
              hom:=MappingOfWhichItIsAsGGMBI( hom );
	      if Tester(attr)(hom) then
	        return attr(hom);
	      else
	        TryNextMethod();
	      fi;
	    end);
end;


#############################################################################
##
##  2. Functions for creating natural homomorphisms
##


#############################################################################
##
#F  NaturalHomomorphismByNormalSubgroup( <G>, <N> )
#F  NaturalHomomorphismByNormalSubgroupNC( <G>, <N> )
##
##  returns a homomorphism from <G> to another group whose kernel is <N>.
##  {\GAP} will try to select the image group as to make computations in it
##  as efficient as possible. As the factor group $<G>/<N>$ can be identified
##  with the image of <G> this permits efficient computations in the factor
##  group. The homomorphism returned is not necessarily surjective, so
##  `ImagesSource' should be used instead of `Range' to get a group
##  isomorphic to the factor group.
##  The `NC' variant does not check whether <N> is normal in <G>.
##
InParentFOA( "NaturalHomomorphismByNormalSubgroupNC", IsGroup, IsGroup,
              NewAttribute );

DeclareSynonym( "NaturalHomomorphismByNormalSubgroupInParent",
    NaturalHomomorphismByNormalSubgroupNCInParent );
DeclareSynonym( "NaturalHomomorphismByNormalSubgroupOp",
    NaturalHomomorphismByNormalSubgroupNCOp );
#T Get rid of this hack when the ``in parent'' approach is cleaned!

BindGlobal( "NaturalHomomorphismByNormalSubgroupNCOrig",
    NaturalHomomorphismByNormalSubgroupNC );
#T Get rid of this hack when the ``in parent'' approach is cleaned!

MakeReadWriteGlobal( "NaturalHomomorphismByNormalSubgroupNC" );
UnbindGlobal( "NaturalHomomorphismByNormalSubgroupNC" );
BindGlobal( "NaturalHomomorphismByNormalSubgroupNC",
    function( G, N )
    local hom;
    hom:= NaturalHomomorphismByNormalSubgroupNCOrig( G, N );
    SetIsMapping( hom, true );
    return hom;
    end );
#T Get rid of this hack when the ``in parent'' approach is cleaned!

DeclareGlobalFunction( "NaturalHomomorphismByNormalSubgroup" );


#############################################################################
##
##  3. Functions for conjugation action
##


#############################################################################
##
#O  ConjugatorIsomorphism( <G>, <g> )
##
##  Let <G> be a group, and <g> an element in the same family as the elements
##  of <G>.
##  `ConjugatorIsomorphism' returns the isomorphism from <G> to `<G>^<g>'
##  defined by $<h> \mapsto <h>^{<g>}$ for all $<h> \in <G>$.
##
##  If <g> normalizes <G> then `ConjugatorIsomorphism' does the same as
##  `ConjugatorAutomorphismNC' (see~"ConjugatorAutomorphism").
##
DeclareOperation( "ConjugatorIsomorphism",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#F  ConjugatorAutomorphism( <G>, <g> )
#O  ConjugatorAutomorphismNC( <G>, <g> )
##
##  Let <G> be a group, and <g> an element in the same family as the elements
##  of <G> such that <g> normalizes <G>.
##  `ConjugatorAutomorphism' returns the automorphism of <G>
##  defined by $<h> \mapsto <h>^{<g>}$ for all $<h> \in <G>$.
##
##  If conjugation by <g> does *not* leave <G> invariant,
##  `ConjugatorAutomorphism' returns `fail';
##  in this case,
##  the isomorphism from <G> to `<G>^<g>' induced by conjugation with <g>
##  can be constructed
##  with `ConjugatorIsomorphism' (see~"ConjugatorIsomorphism").
##
##  `ConjugatorAutomorphismNC' does the same as `ConjugatorAutomorphism',
##  except that the check is omitted whether <g> normalizes <G>.
##
DeclareGlobalFunction( "ConjugatorAutomorphism" );

DeclareOperation( "ConjugatorAutomorphismNC",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#F  InnerAutomorphism( <G>, <g> )
#O  InnerAutomorphismNC( <G>, <g> )
##
##  Let <G> be a group, and $<g> \in <G>$.
##  `InnerAutomorphism' returns the automorphism of <G>
##  defined by $<h> \mapsto <h>^{<g>}$ for all $<h> \in <G>$.
##
##  If <g> is *not* an element of <G>,
##  `InnerAutomorphism' returns `fail';
##  in this case,
##  the isomorphism from <G> to `<G>^<g>' induced by conjugation with <g>
##  can be constructed
##  with `ConjugatorIsomorphism' (see~"ConjugatorIsomorphism")
##  or with `ConjugatorAutomorphism' (see~"ConjugatorAutomorphism").
##
##  `InnerAutomorphismNC' does the same as `InnerAutomorphism',
##  except that the check is omitted whether $<g> \in <G>$.
##
DeclareGlobalFunction( "InnerAutomorphism" );

DeclareOperation( "InnerAutomorphismNC",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#P  IsConjugatorIsomorphism( <hom> )
#P  IsConjugatorAutomorphism( <hom> )
#P  IsInnerAutomorphism( <hom> )
##
##  Let <hom> be a group general mapping (see~"IsGroupGeneralMapping")
##  with source $G$, say.
##  `IsConjugatorIsomorphism' returns `true' if <hom> is induced by
##  conjugation of $G$ by an element $g$ that lies in $G$ or in a group into
##  which $G$ is naturally embedded in the sense described below,
##  and `false' otherwise.
##  Natural embeddings are dealt with in the case that $G$ is
##  a permutation group (see Chapter~"Permutation Groups"),
##  a matrix group (see Chapter~"Matrix Groups"),
##  a finitely presented group (see Chapter~"Finitely Presented Groups"), or
##  a group given w.r.t.~a polycyclic presentation (see Chapter~"Pc Groups").
##  In all other cases, `IsConjugatorIsomorphism' may return `false'
##  if <hom> is induced by conjugation but is not an inner automorphism.
##
##  If `IsConjugatorIsomorphism' returns `true' for <hom> then
##  an element $g$ that induces <hom> can be accessed as value of
##  the attribute `ConjugatorOfConjugatorIsomorphism'
##  (see~"ConjugatorOfConjugatorIsomorphism").
##
##  `IsConjugatorAutomorphism' returns `true' if <hom> is an automorphism
##  (see~"IsEndoGeneralMapping") that is regarded as a conjugator isomorphism
##  by `IsConjugatorIsomorphism', and `false' otherwise.
##
##  `IsInnerAutomorphism' returns `true' if <hom> is a conjugator
##  automorphism such that an element $g$ inducing <hom> can be chosen in
##  $G$, and `false' otherwise.
##
DeclareProperty( "IsConjugatorIsomorphism", IsGroupGeneralMapping );

DeclareSynonymAttr( "IsConjugatorAutomorphism",
    IsEndoGeneralMapping and IsConjugatorIsomorphism );

DeclareProperty( "IsInnerAutomorphism", IsGroupGeneralMapping );

InstallTrueMethod( IsBijective, IsConjugatorIsomorphism );
InstallTrueMethod( IsGroupHomomorphism, IsConjugatorIsomorphism );
InstallTrueMethod( IsConjugatorAutomorphism, IsInnerAutomorphism );


#############################################################################
##
#A  ConjugatorOfConjugatorIsomorphism( <hom> )
##
##  For a conjugator isomorphism <hom> (see~"ConjugatorIsomorphism"),
##  `ConjugatorOfConjugatorIsomorphism' returns an element $g$ such that
##  mapping under <hom> is induced by conjugation with $g$.
##
##  To avoid problems with `IsInnerAutomorphism',
##  it is guaranteed that the conjugator is taken from the source of <hom>
##  if possible.
##
DeclareAttribute( "ConjugatorOfConjugatorIsomorphism",
    IsConjugatorIsomorphism );

##  just for compatibility with {\GAP}~4.1 ...
DeclareSynonymAttr( "ConjugatorInnerAutomorphism",
    ConjugatorOfConjugatorIsomorphism );


#############################################################################
##
##  4. Functions for ...
##


DeclareGlobalFunction( "MakeMapping" );


#############################################################################
##
#F  GroupHomomorphismByFunction( <S>, <R>, <fun> )
#F  GroupHomomorphismByFunction( <S>, <R>, <fun>, <invfun> )
##
##  `GroupHomomorphismByFunction' returns a group homomorphism <hom> with
##  source <S> and range <R>, such that each element <s> of <S> is mapped to
##  the element `<fun>( <s> )', where <fun> is a {\GAP} function.
##
##  If the argument <invfun> is bound then <hom> is a bijection between <S>
##  and <R>, and the preimage of each element <r> of <R> is given by
##  `<invfun>( <r> )', where <invfun> is a {\GAP}  function.
##
##  No test is performed on whether the functions actually give an
##  homomorphism between both groups because this would require testing the
##  full multiplication table.
##
##  `GroupHomomorphismByFunction' creates a mapping which
##  `IsSPGeneralMapping'.
##
DeclareGlobalFunction("GroupHomomorphismByFunction");

#############################################################################
##
#F  ImagesRepresentativeGMBIByElementsList( <hom>, <elm> )
##
##  This is the method for `ImagesRepresentative' which calls `MakeMapping'
##  and uses element lists to evaluate the image. It is used by
##  `Factorization'.
DeclareGlobalFunction("ImagesRepresentativeGMBIByElementsList");

#############################################################################
##
#A   ImagesSmallestGenerators(<map>)
##
##   returns the list of images of `GeneratorsSmallest(Source(<map>))'. This
##   list can be used to compare group homomorphisms.  (The standard
##   comparison is to compare the image lists on the set of elements of the
##   source. If however x and y have the same images under a and b,
##   certainly all their products have. Therefore it is sufficient to test
##   this on the images of the smallest generators.)
DeclareAttribute( "ImagesSmallestGenerators",
    IsGroupGeneralMapping );


#############################################################################
##
#E

