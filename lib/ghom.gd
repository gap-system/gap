#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Alexander Hulpke, Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  1. Functions for creating group general mappings by images
##  2. Functions for creating natural homomorphisms
##  3. Functions for conjugation action
##  4. Functions for ...
##


#############################################################################
##
##  1. Functions for creating group general mappings by images
##


#############################################################################
##
#O  GroupGeneralMappingByImages( <G>, <H>, <gens>, <imgs> )
##
##  <#GAPDoc Label="GroupGeneralMappingByImages">
##  <ManSection>
##  <Oper Name="GroupGeneralMappingByImages" Arg='G, H, gens, imgs'/>
##  <Oper Name="GroupGeneralMappingByImages" Arg='G, gens, imgs' Label="from group to itself"/>
##  <Oper Name="GroupGeneralMappingByImagesNC" Arg='G, H, gens, imgs'/>
##  <Oper Name="GroupGeneralMappingByImagesNC" Arg='G, gens, imgs' Label="from group to itself"/>
##
##  <Description>
##  returns a general mapping defined by extending the mapping from
##  <A>gens</A> to <A>imgs</A> homomorphically. If the range <A>H</A> is not
##  given the mapping will be made automatically surjective. The NC version
##  does not test whether <A>gens</A> are contained in <A>G</A> or <A>imgs</A>
##  are contained in <A>H</A>.
##  (<Ref Func="GroupHomomorphismByImages"/> creates
##  a group general mapping by images and
##  tests whether it is in <Ref Filt="IsMapping"/>.)
##  <Example><![CDATA[
##  gap> map:=GroupGeneralMappingByImages(g,h,gens,[(1,2,3),(1,2)]);
##  [ (1,2,3,4), (1,2) ] -> [ (1,2,3), (1,2) ]
##  gap> IsMapping(map);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareOperation( "GroupGeneralMappingByImages",
    [ IsGroup, IsGroup, IsList, IsList ] );
DeclareOperation( "GroupGeneralMappingByImages",
    [ IsGroup, IsList, IsList ] );

DeclareOperation( "GroupGeneralMappingByImagesNC",
    [ IsGroup, IsGroup, IsList, IsList ] );
DeclareOperation( "GroupGeneralMappingByImagesNC",
    [ IsGroup, IsList, IsList ] );


#############################################################################
##
#F  GroupHomomorphismByImages( <G>[, <H>][[, <gens>], <imgs>] )
##
##  <#GAPDoc Label="GroupHomomorphismByImages">
##  <ManSection>
##  <Func Name="GroupHomomorphismByImages" Arg='G, H[[, gens], imgs]'/>
##
##  <Description>
##  <Ref Func="GroupHomomorphismByImages"/> returns the group homomorphism
##  with source <A>G</A> and range <A>H</A> that is defined by mapping the
##  list <A>gens</A> of generators of <A>G</A> to the list <A>imgs</A> of
##  images in <A>H</A>.
##  <P/>
##  If omitted, the arguments <A>gens</A> and <A>imgs</A> default to
##  the <Ref Attr="GeneratorsOfGroup"/> value of <A>G</A> and <A>H</A>,
##  respectively. If <A>H</A> is not given the mapping is automatically
##  considered as surjective.
##  <P/>
##  If <A>gens</A> does not generate <A>G</A> or if the mapping of the
##  generators does not extend to a homomorphism
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then <K>fail</K> is returned.
##  <P/>
##  This test can be quite expensive. If one is certain that the mapping of
##  the generators extends to a homomorphism,
##  one can avoid the checks by calling
##  <Ref Oper="GroupHomomorphismByImagesNC"/>.
##  (There also is the possibility to
##  construct potentially multi-valued mappings with
##  <Ref Oper="GroupGeneralMappingByImages"/> and to test with
##  <Ref Filt="IsMapping"/> whether they are indeed homomorphisms.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GroupHomomorphismByImages" );


#############################################################################
##
#O  GroupHomomorphismByImagesNC( <G>, <H>[[, <gens>], <imgs>] )
##
##  <#GAPDoc Label="GroupHomomorphismByImagesNC">
##  <ManSection>
##  <Oper Name="GroupHomomorphismByImagesNC" Arg='G, H[[, gens], imgs]'/>
##
##  <Description>
##  <Ref Oper="GroupHomomorphismByImagesNC"/> creates a homomorphism as
##  <Ref Func="GroupHomomorphismByImages"/> does, however it does not test
##  whether <A>gens</A> generates <A>G</A> and that the mapping of
##  <A>gens</A> to <A>imgs</A> indeed defines a group homomorphism.
##  Because these tests can be expensive it can be substantially faster than
##  <Ref Func="GroupHomomorphismByImages"/>.
##  Results are unpredictable if the conditions do not hold.
##  <P/>
##  If omitted, the arguments <A>gens</A> and <A>imgs</A> default to
##  the <Ref Attr="GeneratorsOfGroup"/> value of <A>G</A> and <A>H</A>,
##  respectively.
##  <P/>
##  (For creating a possibly multi-valued mapping from <A>G</A> to <A>H</A>
##  that respects multiplication and inverses,
##  <Ref Oper="GroupGeneralMappingByImages"/> can be used.)
##  <!-- If we could guarantee that it does not matter whether we construct the-->
##  <!-- homomorphism directly or whether we construct first a general mapping-->
##  <!-- and ask it for  being a homomorphism,-->
##  <!-- then this operation would be obsolete,-->
##  <!-- and <C>GroupHomomorphismByImages</C> would be allowed to return the general-->
##  <!-- mapping itself after the checks.-->
##  <!-- (See also the declarations of <C>AlgebraHomomorphismByImagesNC</C>,-->
##  <!-- <C>AlgebraWithOneHomomorphismByImagesNC</C>,-->
##  <!-- <C>LeftModuleHomomorphismByImagesNC</C>.)-->
##  <P/>
##  <Example><![CDATA[
##  gap> gens:=[(1,2,3,4),(1,2)];
##  [ (1,2,3,4), (1,2) ]
##  gap> g:=Group(gens);
##  Group([ (1,2,3,4), (1,2) ])
##  gap> h:=Group((1,2,3),(1,2));
##  Group([ (1,2,3), (1,2) ])
##  gap> hom:=GroupHomomorphismByImages(g,h,gens,[(1,2),(1,3)]);
##  [ (1,2,3,4), (1,2) ] -> [ (1,2), (1,3) ]
##  gap> Image(hom,(1,4));
##  (2,3)
##  gap> map:=GroupHomomorphismByImages(g,h,gens,[(1,2,3),(1,2)]);
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GroupHomomorphismByImagesNC",
    [ IsGroup, IsGroup, IsList, IsList ] );
DeclareOperation( "GroupHomomorphismByImagesNC",
    [ IsGroup, IsList, IsList ] );


#############################################################################
##
#R  IsGroupGeneralMappingByImages(<map>)
##
##  <#GAPDoc Label="IsGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsGroupGeneralMappingByImages" Arg='map'
##   Type='Representation'/>
##
##  <Description>
##  Representation for mappings from one group to another that are defined
##  by extending a mapping of group generators homomorphically.
##  Instead of record components,
##  the attribute <Ref Attr="MappingGeneratorsImages"/> is
##  used to store generators and their images.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep,
      [] );


#############################################################################
##
#R  IsPreimagesByAsGroupGeneralMappingByImages(<map>)
##
##  <#GAPDoc Label="IsPreimagesByAsGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsPreimagesByAsGroupGeneralMappingByImages" Arg='map'
##   Type='Representation'/>
##
##  <Description>
##  Representation for mappings that delegate work for preimages to a
##  mapping created with <Ref Func="GroupHomomorphismByImages"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsPreimagesByAsGroupGeneralMappingByImages",
      IsGroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep,
      [  ] );


#############################################################################
##
#R  IsGroupGeneralMappingByAsGroupGeneralMappingByImages(<map>)
##
##  <#GAPDoc Label="IsGroupGeneralMappingByAsGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsGroupGeneralMappingByAsGroupGeneralMappingByImages"
##   Arg='map' Type='Representation'/>
##
##  <Description>
##  Representation for mappings that delegate work on a
##  <Ref Func="GroupHomomorphismByImages"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsGroupGeneralMappingByAsGroupGeneralMappingByImages",
      IsPreimagesByAsGroupGeneralMappingByImages, [  ] );


#############################################################################
##
#A  AsGroupGeneralMappingByImages(<map>)
##
##  <#GAPDoc Label="AsGroupGeneralMappingByImages">
##  <ManSection>
##  <Attr Name="AsGroupGeneralMappingByImages" Arg='map'/>
##
##  <Description>
##  If <A>map</A> is a mapping from one group to another this attribute
##  returns a group general mapping that which implements the same abstract
##  mapping. (Some operations can be performed more effective in this
##  representation, see
##  also&nbsp;<Ref Filt="IsGroupGeneralMappingByAsGroupGeneralMappingByImages"/>.)
##  <Example><![CDATA[
##  gap> AsGroupGeneralMappingByImages(hom);
##  [ (1,2,3,4), (1,2) ] -> [ (1,2), (1,2) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsGroupGeneralMappingByImages", IsGroupGeneralMapping );


#############################################################################
##
#A  MappingOfWhichItIsAsGGMBI(<map>)
##
##  <ManSection>
##  <Attr Name="MappingOfWhichItIsAsGGMBI" Arg='map'/>
##
##  <Description>
##  If <A>map</A> is <C>AsGroupGeneralMappingByImages(<A>map2</A>)</C> then
##  <A>map2</A> is <C>MappingOfWhichItIsAsGGMBI(<A>map</A>)</C>. This attribute is used to
##  transfer attribute values which were set later.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "MappingOfWhichItIsAsGGMBI", IsGroupGeneralMapping );
InstallTrueMethod( IsGroupGeneralMapping, MappingOfWhichItIsAsGGMBI );

InstallAttributeMethodByGroupGeneralMappingByImages :=
  function( attr )
    InstallMethod( attr, "via `AsGroupGeneralMappingByImages'", true,
            [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages ], 0,
            hom -> attr( AsGroupGeneralMappingByImages( hom ) ) );
    InstallMethod( attr, "get delayed set attribute values", true,
            [ IsGroupGeneralMapping and HasMappingOfWhichItIsAsGGMBI ],
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
##  <#GAPDoc Label="NaturalHomomorphismByNormalSubgroup">
##  <ManSection>
##  <Func Name="NaturalHomomorphismByNormalSubgroup" Arg='G, N'/>
##  <Func Name="NaturalHomomorphismByNormalSubgroupNC" Arg='G, N'/>
##
##  <Description>
##  returns a homomorphism from <A>G</A> to another group whose kernel is <A>N</A>.
##  &GAP; will try to select the image group as to make computations in it
##  as efficient as possible. As the factor group <M><A>G</A>/<A>N</A></M> can be identified
##  with the image of <A>G</A> this permits efficient computations in the factor
##  group.
##  The homomorphism returned is not necessarily surjective, so
##  <Ref Attr="ImagesSource"/> should be used instead of
##  <Ref Attr="Range" Label="of a general mapping"/>
##  to get a group isomorphic to the factor group.
##  The <C>NC</C> variant does not check whether <A>N</A> is normal in
##  <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "NaturalHomomorphismByNormalSubgroupNC", IsGroup, IsGroup,
             DeclareAttribute );

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
##  <#GAPDoc Label="ConjugatorIsomorphism">
##  <ManSection>
##  <Oper Name="ConjugatorIsomorphism" Arg='G, g'/>
##
##  <Description>
##  Let <A>G</A> be a group, and <A>g</A> an element in the same family as
##  the elements of <A>G</A>.
##  <Ref Oper="ConjugatorIsomorphism"/> returns the isomorphism from <A>G</A>
##  to <C><A>G</A>^<A>g</A></C> defined by <M>h \mapsto h^{<A>g</A>}</M>
##  for all <M>h \in <A>G</A></M>.
##  <P/>
##  If <A>g</A> normalizes <A>G</A> then <Ref Oper="ConjugatorIsomorphism"/>
##  does the same as <Ref Oper="ConjugatorAutomorphismNC"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ConjugatorIsomorphism",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#F  ConjugatorAutomorphism( <G>, <g> )
#O  ConjugatorAutomorphismNC( <G>, <g> )
##
##  <#GAPDoc Label="ConjugatorAutomorphism">
##  <ManSection>
##  <Func Name="ConjugatorAutomorphism" Arg='G, g'/>
##  <Oper Name="ConjugatorAutomorphismNC" Arg='G, g'/>
##
##  <Description>
##  Let <A>G</A> be a group, and <A>g</A> an element in the same family as
##  the elements of <A>G</A> such that <A>g</A> normalizes <A>G</A>.
##  <Ref Func="ConjugatorAutomorphism"/> returns the automorphism of <A>G</A>
##  defined by <M>h \mapsto h^{<A>g</A>}</M> for all <M>h \in <A>G</A></M>.
##  <P/>
##  If conjugation by <A>g</A> does <E>not</E> leave <A>G</A> invariant,
##  <Ref Func="ConjugatorAutomorphism"/> returns <K>fail</K>;
##  in this case,
##  the isomorphism from <A>G</A> to <C><A>G</A>^<A>g</A></C> induced by
##  conjugation with <A>g</A> can be constructed with
##  <Ref Oper="ConjugatorIsomorphism"/>.
##  <P/>
##  <Ref Oper="ConjugatorAutomorphismNC"/> does the same as
##  <Ref Func="ConjugatorAutomorphism"/>,
##  except that the check is omitted whether <A>g</A> normalizes <A>G</A>
##  and it is assumed that <A>g</A> is chosen to be in <A>G</A> if possible.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConjugatorAutomorphism" );

DeclareOperation( "ConjugatorAutomorphismNC",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#F  InnerAutomorphism( <G>, <g> )
#O  InnerAutomorphismNC( <G>, <g> )
##
##  <#GAPDoc Label="InnerAutomorphism">
##  <ManSection>
##  <Func Name="InnerAutomorphism" Arg='G, g'/>
##  <Oper Name="InnerAutomorphismNC" Arg='G, g'/>
##
##  <Description>
##  Let <A>G</A> be a group, and <M><A>g</A> \in <A>G</A></M>.
##  <Ref Func="InnerAutomorphism"/> returns the automorphism of <A>G</A>
##  defined by <M>h \mapsto h^{<A>g</A>}</M> for all <M>h \in <A>G</A></M>.
##  <P/>
##  If <A>g</A> is <E>not</E> an element of <A>G</A>,
##  <Ref Func="InnerAutomorphism"/> returns <K>fail</K>;
##  in this case,
##  the isomorphism from <A>G</A> to <C><A>G</A>^<A>g</A></C> induced by
##  conjugation with <A>g</A> can be constructed
##  with <Ref Oper="ConjugatorIsomorphism"/>
##  or with <Ref Func="ConjugatorAutomorphism"/>.
##  <P/>
##  <Ref Oper="InnerAutomorphismNC"/> does the same as
##  <Ref Func="InnerAutomorphism"/>,
##  except that the check is omitted whether <M><A>g</A> \in <A>G</A></M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsConjugatorIsomorphism">
##  <ManSection>
##  <Prop Name="IsConjugatorIsomorphism" Arg='hom'/>
##  <Prop Name="IsConjugatorAutomorphism" Arg='hom'/>
##  <Prop Name="IsInnerAutomorphism" Arg='hom'/>
##
##  <Description>
##  Let <A>hom</A> be a group general mapping
##  (see&nbsp;<Ref Filt="IsGroupGeneralMapping"/>) with source <M>G</M>.
##  <Ref Prop="IsConjugatorIsomorphism"/> returns <K>true</K> if <A>hom</A>
##  is induced by conjugation of <M>G</M> by an element <M>g</M> that lies in
##  <M>G</M> or in a group into which <M>G</M> is naturally embedded
##  in the sense described below, and <K>false</K> otherwise.
##  <P/>
##  Natural embeddings are dealt with in the case that <M>G</M> is
##  a permutation group (see Chapter&nbsp;<Ref Chap="Permutation Groups"/>),
##  a matrix group (see Chapter&nbsp;<Ref Chap="Matrix Groups"/>),
##  a finitely presented group
##  (see Chapter&nbsp;<Ref Chap="Finitely Presented Groups"/>), or
##  a group given w.r.t.&nbsp;a polycyclic presentation
##  (see Chapter&nbsp;<Ref Chap="Pc Groups"/>).
##  In all other cases, <Ref Prop="IsConjugatorIsomorphism"/> may return
##  <K>false</K> if <A>hom</A> is induced by conjugation
##  but is not an inner automorphism.
##  <P/>
##  If <Ref Prop="IsConjugatorIsomorphism"/> returns <K>true</K> for
##  <A>hom</A> then an element <M>g</M> that induces <A>hom</A> can be
##  accessed as value of the attribute
##  <Ref Attr="ConjugatorOfConjugatorIsomorphism"/>.
##  <P/>
##  <Ref Prop="IsConjugatorAutomorphism"/> returns <K>true</K> if <A>hom</A>
##  is an automorphism (see&nbsp;<Ref Prop="IsEndoGeneralMapping"/>)
##  that is regarded as a conjugator isomorphism
##  by <Ref Prop="IsConjugatorIsomorphism"/>, and <K>false</K> otherwise.
##  <P/>
##  <Ref Prop="IsInnerAutomorphism"/> returns <K>true</K> if <A>hom</A> is a
##  conjugator automorphism such that an element <M>g</M> inducing <A>hom</A>
##  can be chosen in <M>G</M>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="ConjugatorOfConjugatorIsomorphism">
##  <ManSection>
##  <Attr Name="ConjugatorOfConjugatorIsomorphism" Arg='hom'/>
##
##  <Description>
##  For a conjugator isomorphism <A>hom</A>
##  (see&nbsp;<Ref Oper="ConjugatorIsomorphism"/>),
##  <Ref Attr="ConjugatorOfConjugatorIsomorphism"/> returns an element
##  <M>g</M> such that mapping under <A>hom</A> is induced by conjugation
##  with <M>g</M>.
##  <P/>
##  To avoid problems with <Ref Prop="IsInnerAutomorphism"/>,
##  it is guaranteed that the conjugator is taken from the source of
##  <A>hom</A> if possible.
##  <P/>
##  <Example><![CDATA[
##  gap> hgens:=[(1,2,3),(1,2,4)];;h:=Group(hgens);;
##  gap> hom:=GroupHomomorphismByImages(h,h,hgens,[(1,2,3),(2,3,4)]);;
##  gap> IsInnerAutomorphism(hom);
##  true
##  gap> ConjugatorOfConjugatorIsomorphism(hom);
##  (1,2,3)
##  gap> hom:=GroupHomomorphismByImages(h,h,hgens,[(1,3,2),(1,4,2)]);
##  [ (1,2,3), (1,2,4) ] -> [ (1,3,2), (1,4,2) ]
##  gap> IsInnerAutomorphism(hom);
##  false
##  gap> IsConjugatorAutomorphism(hom);
##  true
##  gap> ConjugatorOfConjugatorIsomorphism(hom);
##  (1,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConjugatorOfConjugatorIsomorphism",
    IsConjugatorIsomorphism );

##  just for compatibility with &GAP; 4.1 ...
DeclareSynonymAttr( "ConjugatorInnerAutomorphism",
    ConjugatorOfConjugatorIsomorphism );


#############################################################################
##
##  4. Functions for ...
##

DeclareGlobalFunction( "MakeMapping" );


#############################################################################
##
#F  GroupHomomorphismByFunction( <S>, <R>, <fun>[, <invfun>] )
#F  GroupHomomorphismByFunction( <S>, <R>, <fun>, `false', <prefun> )
##
##  <#GAPDoc Label="GroupHomomorphismByFunction">
##  <ManSection>
##  <Heading>GroupHomomorphismByFunction</Heading>
##  <Func Name="GroupHomomorphismByFunction" Arg='S, R, fun[, invfun]'
##   Label="by function (and inverse function) between two domains"/>
##  <Func Name="GroupHomomorphismByFunction" Arg='S, R, fun, false, prefun'
##   Label="by function and function that computes one preimage"/>
##
##  <Description>
##  <Ref Func="GroupHomomorphismByFunction" Label="by function (and inverse function) between two domains"/>
##  returns a group homomorphism
##  <C>hom</C> with source <A>S</A> and range <A>R</A>,
##  such that each element <C>s</C> of <A>S</A> is mapped to the element
##  <A>fun</A><C>( s )</C>, where <A>fun</A> is a &GAP; function.
##  <P/>
##  If the argument <A>invfun</A> is bound then <A>hom</A> is a bijection
##  between <A>S</A> and <A>R</A>,
##  and the preimage of each element <C>r</C> of <A>R</A> is given by
##  <A>invfun</A><C>( r )</C>,
##  where <A>invfun</A> is a &GAP; function.
##  <P/>
##  If five arguments are given and the fourth argument is <K>false</K> then
##  the &GAP; function <A>prefun</A> can be used to compute a single preimage
##  also if <C>hom</C> is not bijective.
##  <P/>
##  No test is performed on whether the functions actually give an
##  homomorphism between both groups because this would require testing the
##  full multiplication table.
##  <P/>
##  <Ref Func="GroupHomomorphismByFunction" Label="by function (and inverse function) between two domains"/>
##  creates a mapping which lies in <Ref Filt="IsSPGeneralMapping"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> hom:=GroupHomomorphismByFunction(g,h,
##  > function(x) if SignPerm(x)=-1 then return (1,2); else return ();fi;end);
##  MappingByFunction( Group([ (1,2,3,4), (1,2) ]), Group(
##  [ (1,2,3), (1,2) ]), function( x ) ... end )
##  gap> ImagesSource(hom);
##  Group([ (1,2), (1,2) ])
##  gap> Image(hom,(1,2,3,4));
##  (1,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("GroupHomomorphismByFunction");


#############################################################################
##
#F  ImagesRepresentativeGMBIByElementsList( <hom>, <elm> )
##
##  <ManSection>
##  <Func Name="ImagesRepresentativeGMBIByElementsList" Arg='hom, elm'/>
##
##  <Description>
##  This is the method for <C>ImagesRepresentative</C> which calls <C>MakeMapping</C>
##  and uses element lists to evaluate the image. It is used by
##  <C>Factorization</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ImagesRepresentativeGMBIByElementsList");

#############################################################################
##
#A  ImagesSmallestGenerators(<map>)
##
##  <#GAPDoc Label="ImagesSmallestGenerators">
##  <ManSection>
##  <Attr Name="ImagesSmallestGenerators" Arg='map'/>
##
##  <Description>
##  returns the list of images of <C>GeneratorsSmallest(Source(<A>map</A>))</C>.
##  This list can be used to compare group homomorphisms.  (The standard
##  comparison is to compare the image lists on the set of elements of the
##  source. If however x and y have the same images under a and b,
##  certainly all their products have. Therefore it is sufficient to test
##  this on the images of the smallest generators.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ImagesSmallestGenerators",
    IsGroupGeneralMapping );


#############################################################################
##
#A  RegularActionHomomorphism( <G> )
##
##  <#GAPDoc Label="RegularActionHomomorphism">
##  <ManSection>
##  <Attr Name="RegularActionHomomorphism" Arg='G'/>
##
##  <Description>
##  returns an isomorphism from <A>G</A> onto the regular permutation
##  representation of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RegularActionHomomorphism", IsGroup );

DeclareGlobalFunction("IsomorphismAbelianGroupViaIndependentGenerators");
