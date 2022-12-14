#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Martin Schönert, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for general mappings.
##

#############################################################################
##
##  <#GAPDoc Label="[1]{mapping}">
##  A <E>general mapping</E> <M>F</M> in &GAP; is described by
##  its source <M>S</M>, its range <M>R</M>, and a subset <M>Rel</M> of the
##  direct product <M>S \times R</M>,
##  which is called the underlying relation of <M>F</M>.
##  <M>S</M>, <M>R</M>, and <M>Rel</M> are generalized domains
##  (see <Ref Chap="Domains"/>).
##  The corresponding attributes for general mappings are
##  <Ref Attr="Source"/>, <Ref Attr="Range" Label="of a general mapping"/>,
##  and <Ref Attr="UnderlyingRelation"/>.
##  <!-- what about the family predicates if the source/range is not a -->
##  <!-- collection? -->
##  <P/>
##  Note that general mappings themselves are <E>not</E> domains.
##  One reason for this is that two general mappings with same underlying
##  relation are regarded as equal only if also the sources are equal and
##  the ranges are equal.
##  Other, more technical, reasons are that general mappings and domains
##  have different basic operations, and that general mappings are
##  arithmetic objects
##  (see&nbsp;<Ref Sect="Arithmetic Operations for General Mappings"/>);
##  both should not apply to domains.
##  <P/>
##  Each element of an underlying relation of a general mapping lies in the
##  category of direct product elements
##  (see&nbsp;<Ref Filt="IsDirectProductElement"/>).
##  <P/>
##  For each <M>s \in S</M>, the set <M>\{ r \in R | (s,r) \in Rel \}</M>
##  is called the set of <E>images</E> of <M>s</M>.
##  Analogously, for <M>r \in R</M>,
##  the set <M>\{ s \in S | (s,r) \in Rel \}</M>
##  is called the set of <E>preimages</E> of <M>r</M>.
##  <P/>
##  The <E>ordering</E> of general mappings via <C>&lt;</C> is defined
##  by the ordering of source, range, and underlying relation.
##  Specifically, if the source and range domains of <A>map1</A> and
##  <A>map2</A> are the same, then one considers  the union of the preimages
##  of <A>map1</A> and <A>map2</A> as a strictly ordered set.
##  The smaller of <A>map1</A> and <A>map2</A> is the one whose image is
##  smaller on the  first point of this sequence where they differ.
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[2]{mapping}">
##  <Ref Attr="Source"/> and <Ref Attr="Range" Label="of a general mapping"/>
##  are basic operations for general mappings.
##  <Ref Attr="UnderlyingRelation"/> is secondary, its default method sets up
##  a domain that delegates tasks to the general mapping.
##  (Note that this allows one to handle also infinite relations by generic
##  methods if source or range of the general mapping is finite.)
##  <P/>
##  The distinction between basic operations and secondary operations for
##  general mappings may be a little bit complicated.
##  Namely, each general mapping must be in one of the two categories
##  <Ref Filt="IsNonSPGeneralMapping"/>, <Ref Filt="IsSPGeneralMapping"/>.
##  (The category <Ref Filt="IsGeneralMapping"/> is defined as the disjoint
##  union of these two.)
##  <P/>
##  For general mappings of the first category, <Ref Oper="ImagesElm"/> and
##  <Ref Oper="PreImagesElm"/> are basic operations.
##  (Note that in principle it is possible to delegate
##  from <Ref Oper="PreImagesElm"/> to <Ref Oper="ImagesElm"/>.)
##  Methods for the secondary operations <Ref Oper="ImageElm"/>,
##  <Ref Oper="PreImageElm"/>, <Ref Oper="ImagesSet"/>,
##  <Ref Oper="PreImagesSet"/>, <Ref Oper="ImagesRepresentative"/>,
##  and <Ref Oper="PreImagesRepresentative"/> may use
##  <Ref Oper="ImagesElm"/> and <Ref Oper="PreImagesElm"/>, respectively,
##  and methods for <Ref Oper="ImagesElm"/>, <Ref Oper="PreImagesElm"/>
##  must <E>not</E> call the secondary operations.
##  In particular, there are no generic methods for
##  <Ref Oper="ImagesElm"/> and <Ref Oper="PreImagesElm"/>.
##  <P/>
##  Methods for <Ref Oper="ImagesSet"/> and <Ref Oper="PreImagesSet"/> must
##  <E>not</E> use <Ref Attr="PreImagesRange"/> and
##  <Ref Attr="ImagesSource"/>, e.g.,
##  compute the intersection of the set in question with the preimage of the
##  range resp. the image of the source.
##  <P/>
##  For general mappings of the second category (which means structure
##  preserving general mappings), the situation is different.
##  The set of preimages under a group homomorphism, for example, is either
##  empty or can be described as a coset of the (multiplicative) kernel.
##  So it is reasonable to have <Ref Oper="ImagesRepresentative"/>,
##  <Ref Oper="PreImagesRepresentative"/>,
##  <Ref Attr="KernelOfMultiplicativeGeneralMapping"/>, and
##  <Ref Attr="CoKernelOfMultiplicativeGeneralMapping"/> as basic operations
##  here, and to make <Ref Oper="ImagesElm"/> and <Ref Oper="PreImagesElm"/>
##  secondary operations that may delegate to these.
##  <P/>
##  In order to avoid infinite recursions,
##  we must distinguish between the two different types of mappings.
##  <P/>
##  (Note that the basic domain operations such as <Ref Attr="AsList"/>
##  for the underlying relation of a general mapping may use either
##  <Ref Oper="ImagesElm"/> or <Ref Oper="ImagesRepresentative"/> and the
##  appropriate cokernel.
##  Conversely, if <Ref Attr="AsList"/> for the underlying relation is known
##  then <Ref Oper="ImagesElm"/> resp. <Ref Oper="ImagesRepresentative"/>
##  may delegate to it,
##  the general mapping gets the property
##  <Ref Prop="IsConstantTimeAccessGeneralMapping"/> for this;
##  note that this is not allowed if only an enumerator of the underlying
##  relation is known.)
##  <P/>
##  Secondary operations are
##  <Ref Prop="IsInjective"/>, <Ref Prop="IsSingleValued"/>,
##  <Ref Prop="IsSurjective"/>, <Ref Prop="IsTotal"/>;
##  they may use the basic operations, and must not be used by them.
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[3]{mapping}">
##  General mappings are arithmetic objects.
##  One can form groups and vector spaces of general mappings provided
##  that they are invertible or can be added and admit scalar multiplication,
##  respectively.
##  <P/>
##  For two general mappings with same source, range, preimage, and image,
##  the <E>sum</E> is defined pointwise, i.e.,
##  the images of a point under the sum is the set of all sums with
##  first summand in the images of the first general mapping and
##  second summand in the images of the second general mapping.
##  <P/>
##  <E>Scalar multiplication</E> of general mappings is defined likewise.
##  <P/>
##  The <E>product</E> of two general mappings is defined as the composition.
##  This multiplication is always associative.
##  In addition to the composition via <C>*</C>,
##  general mappings can be composed &ndash;in reversed order&ndash;
##  via <Ref Func="CompositionMapping"/>.
##  <P/>
##  General mappings are in the category of multiplicative elements with
##  inverses.
##  Similar to matrices, not every general mapping has an inverse or an
##  identity, and we define the behaviour of <Ref Attr="One"/> and
##  <Ref Attr="Inverse"/> for general mappings as follows.
##  <Ref Attr="One"/> returns <K>fail</K> when called for a general mapping
##  whose source and range differ,
##  otherwise <Ref Attr="One"/> returns the identity mapping of the source.
##  (Note that the source may differ from the preimage).
##  <Ref Attr="Inverse"/> returns <K>fail</K> when called for a non-bijective
##  general mapping or for a general mapping whose source and range differ;
##  otherwise <Ref Attr="Inverse"/> returns the inverse mapping.
##  <P/>
##  Besides the usual inverse of multiplicative elements, which means that
##  <C>Inverse( <A>g</A> ) * <A>g</A> = <A>g</A> * Inverse( <A>g</A> )
##  = One( <A>g</A> )</C>,
##  for general mappings we have the attribute
##  <Ref Attr="InverseGeneralMapping"/>.
##  If <A>F</A> is a general mapping with source <M>S</M>, range <M>R</M>,
##  and underlying relation <M>Rel</M> then
##  <C>InverseGeneralMapping( <A>F</A> )</C> has source <M>R</M>,
##  range <M>S</M>,
##  and underlying relation <M>\{ (r,s) \mid (s,r) \in Rel \}</M>.
##  For a general mapping that has an inverse in the usual sense,
##  i.e., for a bijection of the source, of course both concepts coincide.
##  <P/>
##  <Ref Attr="Inverse"/> may delegate to
##  <Ref Attr="InverseGeneralMapping"/>.
##  <Ref Attr="InverseGeneralMapping"/> must not delegate to
##  <Ref Attr="Inverse"/>,
##  but a known value of <Ref Attr="Inverse"/> may be fetched.
##  So methods to compute the inverse of a general mapping should be
##  installed for <Ref Attr="InverseGeneralMapping"/>.
##  <P/>
##  (Note that in many respects, general mappings behave similar to matrices,
##  for example one can define left and right identities and inverses, which
##  do not fit into the current concepts of &GAP;.)
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[4]{mapping}">
##  Methods for the operations <Ref Oper="ImagesElm"/>,
##  <Ref Oper="ImagesRepresentative"/>,
##  <Ref Oper="ImagesSet"/>, <Ref Oper="ImageElm"/>,
##  <Ref Oper="PreImagesElm"/>,
##  <Ref Oper="PreImagesRepresentative"/>, <Ref Oper="PreImagesSet"/>,
##  and <Ref Oper="PreImageElm"/> take two arguments, a general mapping
##  <A>map</A> and an element or collection of elements <A>elm</A>.
##  These methods must <E>not</E> check whether <A>elm</A> lies in the source
##  or the range of <A>map</A>.
##  In the case that <A>elm</A> does not, <K>fail</K> may be returned as well
##  as any other &GAP; object, and even an error message is allowed.
##  Checks of the arguments are done only by the functions
##  <Ref Func="Image" Label="set of images of the source of a general mapping"/>,
##  <Ref Func="Images" Label="set of images of the source of a general mapping"/>,
##  <Ref Func="PreImage" Label="set of preimages of the range of a general mapping"/>,
##  and <Ref Func="PreImages" Label="set of preimages of the range of a general mapping"/>,
##  which then delegate to the operations listed above.
##  <#/GAPDoc>
##

## Shared region for storing results of FamiliesOfGeneralMappingsAndRanges
## This has to have higher precedence than TRANSREGION, because
## while doing TransitiveIdentification we hold a lock on TRANSREGION
## and want a lock for GENERAL_MAPPING_REGION
#if IsHPCGAP then
BindGlobal("GENERAL_MAPPING_REGION",
        NewInternalRegion("FamiliesOfGeneralMappingsAndRanges region"));
#fi;

#############################################################################
##
#C  IsGeneralMapping( <map> )
##
##  <#GAPDoc Label="IsGeneralMapping">
##  <ManSection>
##  <Filt Name="IsGeneralMapping" Arg='map' Type='Category'/>
##
##  <Description>
##  Each general mapping lies in the category <Ref Filt="IsGeneralMapping"/>.
##  It implies the categories
##  <Ref Filt="IsMultiplicativeElementWithInverse"/>
##  and <Ref Filt="IsAssociativeElement"/>;
##  for a discussion of these implications,
##  see&nbsp;<Ref Sect="Arithmetic Operations for General Mappings"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsGeneralMapping",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );


#############################################################################
##
#C  IsSPGeneralMapping( <map> )
#C  IsNonSPGeneralMapping( <map> )
##
##  <#GAPDoc Label="IsSPGeneralMapping">
##  <ManSection>
##  <Filt Name="IsSPGeneralMapping" Arg='map' Type='Category'/>
##  <Filt Name="IsNonSPGeneralMapping" Arg='map' Type='Category'/>
##
##  <Description>
##  <!--  What we want to express is that <C>IsGeneralMapping</C> is the disjoint union-->
##  <!--  of <C>IsSPGeneralMapping</C> and <C>IsNonSPGeneralMapping</C>.-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsSPGeneralMapping", IsGeneralMapping );
DeclareCategory( "IsNonSPGeneralMapping", IsGeneralMapping );


#############################################################################
##
#C  IsGeneralMappingCollection( <obj> )
##
##  <ManSection>
##  <Filt Name="IsGeneralMappingCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryCollections( "IsGeneralMapping" );


#############################################################################
##
#C  IsGeneralMappingFamily( <obj> )
##
##  <#GAPDoc Label="IsGeneralMappingFamily">
##  <ManSection>
##  <Filt Name="IsGeneralMappingFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  The family category of the category of general mappings.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryFamily( "IsGeneralMapping" );


#############################################################################
##
#A  FamilyRange( <Fam> )
##
##  <#GAPDoc Label="FamilyRange">
##  <ManSection>
##  <Attr Name="FamilyRange" Arg='Fam'/>
##
##  <Description>
##  is the elements family of the family of the range of each general
##  mapping in the family <A>Fam</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FamilyRange", IsGeneralMappingFamily );


#############################################################################
##
#A  FamilySource( <Fam> )
##
##  <#GAPDoc Label="FamilySource">
##  <ManSection>
##  <Attr Name="FamilySource" Arg='Fam'/>
##
##  <Description>
##  is the elements family of the family of the source of each general
##  mapping in the family <A>Fam</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FamilySource", IsGeneralMappingFamily );


#############################################################################
##
#A  FamiliesOfGeneralMappingsAndRanges( <Fam> )
##
##  <#GAPDoc Label="FamiliesOfGeneralMappingsAndRanges">
##  <ManSection>
##  <Attr Name="FamiliesOfGeneralMappingsAndRanges" Arg='Fam'/>
##
##  <Description>
##  is a list that stores at the odd positions the families of general
##  mappings with source in the family <A>Fam</A>, at the even positions the
##  families of ranges of the general mappings.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FamiliesOfGeneralMappingsAndRanges",
    IsFamily, "mutable" );


#############################################################################
##
#P  IsConstantTimeAccessGeneralMapping( <map> )
##
##  <#GAPDoc Label="IsConstantTimeAccessGeneralMapping">
##  <ManSection>
##  <Prop Name="IsConstantTimeAccessGeneralMapping" Arg='map'/>
##
##  <Description>
##  is <K>true</K> if the underlying relation of the general mapping
##  <A>map</A> knows its <Ref Attr="AsList"/> value,
##  and <K>false</K> otherwise.
##  <P/>
##  In the former case, <A>map</A> is allowed to use this list for calls to
##  <Ref Oper="ImagesElm"/> etc.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsConstantTimeAccessGeneralMapping", IsGeneralMapping );
InstallTrueMethod( IsGeneralMapping, IsConstantTimeAccessGeneralMapping );


#############################################################################
##
#P  IsEndoGeneralMapping( <obj> )
##
##  <#GAPDoc Label="IsEndoGeneralMapping">
##  <ManSection>
##  <Prop Name="IsEndoGeneralMapping" Arg='obj'/>
##
##  <Description>
##  If a general mapping has this property then its source and range are
##  equal.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsEndoGeneralMapping", IsGeneralMapping );
InstallTrueMethod( IsGeneralMapping, IsEndoGeneralMapping );


#############################################################################
##
#P  IsTotal( <map> )  . . . . . . . . test whether a general mapping is total
##
##  <#GAPDoc Label="IsTotal">
##  <ManSection>
##  <Prop Name="IsTotal" Arg='map'/>
##
##  <Description>
##  is <K>true</K> if each element in the source <M>S</M>
##  of the general mapping <A>map</A> has images, i.e.,
##  <M>s^{<A>map</A>} \neq \emptyset</M> for all <M>s \in S</M>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsTotal", IsGeneralMapping );


#############################################################################
##
#P  IsSingleValued( <map> ) . test whether a general mapping is single-valued
##
##  <#GAPDoc Label="IsSingleValued">
##  <ManSection>
##  <Prop Name="IsSingleValued" Arg='map'/>
##
##  <Description>
##  is <K>true</K> if each element in the source <M>S</M>
##  of the general mapping <A>map</A> has at most one image, i.e.,
##  <M>|s^{<A>map</A>}| \leq 1</M> for all <M>s \in S</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  Equivalently, <C>IsSingleValued( <A>map</A> )</C> is <K>true</K>
##  if and only if the preimages of different elements in <M>R</M> are
##  disjoint.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSingleValued", IsGeneralMapping );


#############################################################################
##
#P  IsMapping( <map> )
##
##  <#GAPDoc Label="IsMapping">
##  <ManSection>
##  <Filt Name="IsMapping" Arg='map'/>
##
##  <Description>
##  A <E>mapping</E> <A>map</A> is a general mapping that assigns to each
##  element <C>elm</C> of its source a unique element
##  <C>Image( <A>map</A>, elm )</C> of its range.
##  <P/>
##  Equivalently, the general mapping <A>map</A> is a mapping if and only if
##  it is total and single-valued
##  (see&nbsp;<Ref Prop="IsTotal"/>, <Ref Prop="IsSingleValued"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsMapping",
    IsGeneralMapping and IsTotal and IsSingleValued );


#############################################################################
##
#P  IsEndoMapping( <obj> )
##
##  <ManSection>
##  <Prop Name="IsEndoMapping" Arg='obj'/>
##
##  <Description>
##  If a mapping has this property then its source and range are
##  equal and it is single valued.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsEndoMapping", IsMapping and IsEndoGeneralMapping );


#############################################################################
##
#P  IsInjective( <map> )  . . . . . .  test if a general mapping is injective
##
##  <#GAPDoc Label="IsInjective">
##  <ManSection>
##  <Prop Name="IsInjective" Arg='map'/>
##
##  <Description>
##  is <K>true</K> if the images of different elements in the source <M>S</M>
##  of the general mapping <A>map</A> are disjoint, i.e.,
##  <M>x^{<A>map</A>} \cap y^{<A>map</A>} = \emptyset</M>
##  for <M>x \neq y \in S</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  Equivalently, <C>IsInjective( <A>map</A> )</C> is <K>true</K>
##  if and only if each element in the range of <A>map</A> has at most one
##  preimage in <M>S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsInjective", IsGeneralMapping );
DeclareSynonym("IsOneToOne",IsInjective);


#############################################################################
##
#P  IsSurjective( <map> ) . . . . . . test if a general mapping is surjective
##
##  <#GAPDoc Label="IsSurjective">
##  <ManSection>
##  <Prop Name="IsSurjective" Arg='map'/>
##
##  <Description>
##  is <K>true</K> if each element in the range <M>R</M>
##  of the general mapping <A>map</A> has preimages in the source <M>S</M>
##  of <A>map</A>, i.e.,
##  <M>\{ s \in S \mid x \in s^{<A>map</A>} \} \neq \emptyset</M>
##  for all <M>x \in R</M>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSurjective", IsGeneralMapping );
DeclareSynonym("IsOnto",IsSurjective);


#############################################################################
##
#P  IsBijective( <map> )  . . . . . .  test if a general mapping is bijective
##
##  <#GAPDoc Label="IsBijective">
##  <ManSection>
##  <Prop Name="IsBijective" Arg='map'/>
##
##  <Description>
##  A general mapping <A>map</A> is <E>bijective</E> if and only if it is
##  an injective and surjective mapping (see&nbsp;<Ref Filt="IsMapping"/>,
##  <Ref Prop="IsInjective"/>, <Ref Prop="IsSurjective"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsBijective",
    IsSingleValued and IsTotal and IsInjective and IsSurjective );


#############################################################################
##
#A  Range( <map> )  . . . . . . . . . . . . . . .  range of a general mapping
##
##  <#GAPDoc Label="Range">
##  <ManSection>
##  <Attr Name="Range" Arg='map' Label="of a general mapping"/>
##
##  <Description>
##  The range of a general mapping.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Range", IsGeneralMapping );


#############################################################################
##
#A  Source( <map> ) . . . . . . . . . . . . . . . source of a general mapping
##
##  <#GAPDoc Label="Source">
##  <ManSection>
##  <Attr Name="Source" Arg='map'/>
##
##  <Description>
##  The source of a general mapping.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Source", IsGeneralMapping );


#############################################################################
##
#A  UnderlyingRelation( <map> ) . .  underlying relation of a general mapping
##
##  <#GAPDoc Label="UnderlyingRelation">
##  <ManSection>
##  <Attr Name="UnderlyingRelation" Arg='map'/>
##
##  <Description>
##  The <E>underlying relation</E> of a general mapping <A>map</A> is the
##  domain of pairs <M>(s,r)</M>, with <M>s</M> in the source and <M>r</M> in
##  the range of <A>map</A> (see&nbsp;<Ref Attr="Source"/>,
##  <Ref Attr="Range" Label="of a general mapping"/>),
##  and <M>r \in</M> <C>ImagesElm( <A>map</A>, </C><M>s</M><C> )</C>.
##  <P/>
##  Each element of the underlying relation is represented by
##  a direct product element (see&nbsp;<Ref Filt="IsDirectProductElement"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingRelation", IsGeneralMapping );


#############################################################################
##
#A  UnderlyingGeneralMapping( <map> )
##
##  <#GAPDoc Label="UnderlyingGeneralMapping">
##  <ManSection>
##  <Attr Name="UnderlyingGeneralMapping" Arg='map'/>
##
##  <Description>
##  attribute for underlying relations of general mappings
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingGeneralMapping", IsCollection );


#############################################################################
##
#F  GeneralMappingsFamily( <sourcefam>, <rangefam> )
##
##  <#GAPDoc Label="GeneralMappingsFamily">
##  <ManSection>
##  <Func Name="GeneralMappingsFamily" Arg='sourcefam, rangefam'/>
##
##  <Description>
##  All general mappings with same source family <A>FS</A> and same range
##  family <A>FR</A> lie in the family
##  <C>GeneralMappingsFamily( <A>FS</A>, <A>FR</A> )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GeneralMappingsFamily" );


#############################################################################
##
#F  TypeOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
##  <#GAPDoc Label="TypeOfDefaultGeneralMapping">
##  <ManSection>
##  <Func Name="TypeOfDefaultGeneralMapping" Arg='source, range, filter'/>
##
##  <Description>
##  is the type of mappings with <C>IsDefaultGeneralMappingRep</C> with
##  source <A>source</A> and range <A>range</A> and additional categories
##  <A>filter</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TypeOfDefaultGeneralMapping" );


#############################################################################
##
#A  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
##  <#GAPDoc Label="IdentityMapping">
##  <ManSection>
##  <Attr Name="IdentityMapping" Arg='D'/>
##
##  <Description>
##  is the bijective mapping with source and range equal to the collection
##  <A>D</A>, which maps each element of <A>D</A> to itself.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IdentityMapping", IsCollection );


#############################################################################
##
#A  InverseGeneralMapping( <map> )
##
##  <#GAPDoc Label="InverseGeneralMapping">
##  <ManSection>
##  <Attr Name="InverseGeneralMapping" Arg='map'/>
##
##  <Description>
##  The <E>inverse general mapping</E> of a general mapping <A>map</A> is
##  the general mapping whose underlying relation
##  (see&nbsp;<Ref Attr="UnderlyingRelation"/>) contains a pair <M>(r,s)</M>
##  if and only if the underlying relation of <A>map</A> contains the pair
##  <M>(s,r)</M>.
##  <P/>
##  See the introduction to Chapter&nbsp;<Ref Chap="Mappings"/>
##  for the subtleties concerning the difference between
##  <Ref Attr="InverseGeneralMapping"/> and <Ref Attr="Inverse"/>.
##  <P/>
##  Note that the inverse general mapping of a mapping <A>map</A> is
##  in general only a general mapping.
##  If <A>map</A> knows to be bijective its inverse general mapping will know
##  to be a mapping.
##  In this case also <C>Inverse( <A>map</A> )</C> works.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InverseGeneralMapping", IsGeneralMapping );

#############################################################################
##
#A  RestrictedInverseGeneralMapping( <map> )
##
##  <#GAPDoc Label="RestrictedInverseGeneralMapping">
##  <ManSection>
##  <Attr Name="RestrictedInverseGeneralMapping" Arg='map'/>
##
##  <Description>
##  The <E>restricted inverse general mapping</E> of a general
##  mapping <A>map</A> is
##  the general mapping whose underlying relation
##  (see&nbsp;<Ref Attr="UnderlyingRelation"/>) contains a pair <M>(r,s)</M>
##  if and only if the underlying relation of <A>map</A> contains the pair
##  <M>(s,r)</M>, and whose domain is restricted to the image of <A>map</A>
##  and whose range is the domain of <A>map</A>.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RestrictedInverseGeneralMapping", IsGeneralMapping );


#############################################################################
##
#A  ImagesSource( <map> )
##
##  <#GAPDoc Label="ImagesSource">
##  <ManSection>
##  <Attr Name="ImagesSource" Arg='map'/>
##
##  <Description>
##  is the set of images of the source of the general mapping <A>map</A>.
##  <P/>
##  <Ref Attr="ImagesSource"/> delegates to <Ref Oper="ImagesSet"/>,
##  it is introduced only to store the image of <A>map</A> as attribute
##  value.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ImagesSource", IsGeneralMapping );


#############################################################################
##
#A  PreImagesRange( <map> )
##
##  <#GAPDoc Label="PreImagesRange">
##  <ManSection>
##  <Attr Name="PreImagesRange" Arg='map'/>
##
##  <Description>
##  is the set of preimages of the range of the general mapping <A>map</A>.
##  <P/>
##  <Ref Attr="PreImagesRange"/> delegates to <Ref Oper="PreImagesSet"/>,
##  it is introduced only to store the preimage of <A>map</A> as attribute
##  value.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PreImagesRange", IsGeneralMapping );


#############################################################################
##
#O  ImagesElm( <map>, <elm> ) . . . all images of an elm under a gen. mapping
##
##  <#GAPDoc Label="ImagesElm">
##  <ManSection>
##  <Oper Name="ImagesElm" Arg='map, elm'/>
##
##  <Description>
##  If <A>elm</A> is an element of the source of the general mapping
##  <A>map</A> then <Ref Oper="ImagesElm"/> returns the set of all images
##  of <A>elm</A> under <A>map</A>.
##  <P/>
##  Anything may happen if <A>elm</A> is not an element of the source of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImagesElm", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesRepresentative(<map>,<elm>) . one image of elm under a gen. mapping
##
##  <#GAPDoc Label="ImagesRepresentative">
##  <ManSection>
##  <Oper Name="ImagesRepresentative" Arg='map,elm'/>
##
##  <Description>
##  If <A>elm</A> is an element of the source of the general mapping
##  <A>map</A> then <Ref Oper="ImagesRepresentative"/> returns either
##  a representative of the set of images of <A>elm</A> under <A>map</A>
##  or <K>fail</K>, the latter if and only if <A>elm</A> has no images under
##  <A>map</A>.
##  <P/>
##  Anything may happen if <A>elm</A> is not an element of the source of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImagesRepresentative", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesSet( <map>, <elms> )
##
##  <#GAPDoc Label="ImagesSet">
##  <ManSection>
##  <Oper Name="ImagesSet" Arg='map, elms'/>
##
##  <Description>
##  If <A>elms</A> is a subset of the source of the general mapping
##  <A>map</A> then <Ref Oper="ImagesSet"/> returns the set of all images of
##  <A>elms</A> under <A>map</A>.
##  <P/>
##  The result will be either a proper set or a domain.
##  Anything may happen if <A>elms</A> is not a subset of the source of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImagesSet", [ IsGeneralMapping, IsListOrCollection ] );


#############################################################################
##
#O  ImageElm( <map>, <elm> )  . . . .  unique image of an elm under a mapping
##
##  <#GAPDoc Label="ImageElm">
##  <ManSection>
##  <Oper Name="ImageElm" Arg='map, elm'/>
##
##  <Description>
##  If <A>elm</A> is an element of the source of the total and single-valued
##  mapping <A>map</A> then
##  <Ref Oper="ImageElm"/> returns the unique image of <A>elm</A> under
##  <A>map</A>.
##  <P/>
##  Anything may happen if <A>elm</A> is not an element of the source of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImageElm", [ IsMapping, IsObject ] );


#############################################################################
##
#F  Image( <map> )  . . . .  set of images of the source of a general mapping
#F  Image( <map>, <elm> ) . . . .  unique image of an element under a mapping
#F  Image( <map>, <coll> )  . . set of images of a collection under a mapping
##
##  <#GAPDoc Label="Image">
##  <ManSection>
##  <Heading>Image</Heading>
##  <Func Name="Image" Arg='map'
##   Label="set of images of the source of a general mapping"/>
##  <Func Name="Image" Arg='map, elm'
##   Label="unique image of an element under a mapping"/>
##  <Func Name="Image" Arg='map, coll'
##   Label="set of images of a collection under a mapping"/>
##
##  <Description>
##  <C>Image( <A>map</A> )</C> is the <E>image</E> of the general mapping
##  <A>map</A>, i.e.,
##  the subset of elements of the range of <A>map</A>
##  that are actually values of <A>map</A>.
##  <E>Note</E> that in this case the argument may also be multi-valued.
##  <P/>
##  <C>Image( <A>map</A>, <A>elm</A> )</C> is the image of the element
##  <A>elm</A> of the source of the mapping <A>map</A> under <A>map</A>,
##  i.e., the unique element of the range to which <A>map</A> maps
##  <A>elm</A>.
##  This can also be expressed as <A>elm</A><C>^</C><A>map</A> or as
##  <A>map</A><C>( </C><A>elm</A><C> )</C>.
##  <P/>
##  Note that <A>map</A> must be total and single valued,
##  a multi valued general mapping is not allowed
##  (see&nbsp;<Ref Func="Images" Label="set of images of the source of a general mapping"/>).
##  <P/>
##  <C>Image( <A>map</A>, <A>coll</A> )</C> is the image of the subset
##  <A>coll</A> of the source of the mapping <A>map</A> under <A>map</A>,
##  i.e., the subset of the range to which <A>map</A> maps elements of
##  <A>coll</A>. <P/>
##  <A>coll</A> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##  Note that in this case <A>map</A> may also be multi-valued.
##  (If <A>coll</A> and the result are lists then the positions of
##  entries do in general <E>not</E> correspond.)
##  <P/>
##  <C>Image( <A>map</A>, <A>coll</A> )</C> can also be expressed as <C><A>map</A>(<A>coll</A>)</C> and
##  <C>Image( <A>map</A>, <A>elm</A> )</C> as  <C><A>map</A>(<A>elm</A>)</C>.
##  Those using this notation should remember that composition of mappings in &GAP;
##  still follows the conventions appropriate for mapping acting from the right, so that
##  <C>(<A>map1</A>*<A>map2</A>)(<A>x</A>)</C> is equivalent to
##  <C><A>map2</A>(<A>map1</A>(<A>x</A>))</C>    <P/>
##  <Ref Func="Image" Label="set of images of the source of a general mapping"/>
##  delegates to <Ref Attr="ImagesSource"/> when called
##  with one argument, and to <Ref Oper="ImageElm"/> resp.
##  <Ref Oper="ImagesSet"/> when called with two arguments.
##  <P/>
##  If the second argument is not an element or a subset of the source of
##  the first argument, an error is signalled.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Image" );


#############################################################################
##
#F  Images( <map> ) . . . .  set of images of the source of a general mapping
#F  Images( <map>, <elm> )  . . . set of images of an element under a mapping
#F  Images( <map>, <coll> ) . . set of images of a collection under a mapping
##
##  <#GAPDoc Label="Images">
##  <ManSection>
##  <Heading>Images</Heading>
##  <Func Name="Images" Arg='map'
##   Label="set of images of the source of a general mapping"/>
##  <Func Name="Images" Arg='map, elm'
##   Label="set of images of an element under a mapping"/>
##  <Func Name="Images" Arg='map, coll'
##   Label="set of images of a collection under a mapping"/>
##
##  <Description>
##  <C>Images( <A>map</A> )</C> is the <E>image</E> of the general mapping
##  <A>map</A>, i.e., the subset of elements of the range of <A>map</A>
##  that are actually values of <A>map</A>.
##  <P/>
##  <C>Images( <A>map</A>, <A>elm</A> )</C> is the set of images of the
##  element <A>elm</A> of the source of the general mapping <A>map</A> under
##  <A>map</A>, i.e., the set of elements of the range to which <A>map</A>
##  maps <A>elm</A>.
##  <P/>
##  <C>Images( <A>map</A>, <A>coll</A> )</C> is the set of images of the
##  subset <A>coll</A> of the source of the general mapping <A>map</A> under
##  <A>map</A>, i.e., the subset of the range to which <A>map</A> maps
##  elements of <A>coll</A>.
##  <A>coll</A> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##  (If <A>coll</A> and the result are lists then the positions of
##  entries do in general <E>not</E> correspond.)
##  <P/>
##  <Ref Func="Images" Label="set of images of the source of a general mapping"/>
##  delegates to <Ref Attr="ImagesSource"/> when called
##  with one argument, and to <Ref Oper="ImagesElm"/> resp.
##  <Ref Oper="ImagesSet"/> when called with two arguments.
##  <P/>
##  If the second argument is not an element or a subset of the source of
##  the first argument, an error is signalled.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Images" );


#############################################################################
##
#O  PreImagesElm( <map>, <elm> )  . all preimages of elm under a gen. mapping
##
##  <#GAPDoc Label="PreImagesElm">
##  <ManSection>
##  <Oper Name="PreImagesElm" Arg='map, elm'/>
##
##  <Description>
##  If <A>elm</A> is an element of the range of the general mapping
##  <A>map</A> then <Ref Oper="PreImagesElm"/> returns the set of all
##  preimages of <A>elm</A> under <A>map</A>.
##  <P/>
##  Anything may happen if <A>elm</A> is not an element of the range of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PreImagesElm", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImageElm( <map>, <elm> )
##
##  <#GAPDoc Label="PreImageElm">
##  <ManSection>
##  <Oper Name="PreImageElm" Arg='map, elm'/>
##
##  <Description>
##  If <A>elm</A> is an element of the range of the injective and surjective
##  general mapping <A>map</A> then
##  <Ref Oper="PreImageElm"/> returns the unique preimage of <A>elm</A> under
##  <A>map</A>.
##  <P/>
##  Anything may happen if <A>elm</A> is not an element of the range of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PreImageElm",
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ] );


#############################################################################
##
#O  PreImagesRepresentative( <map>, <elm> ) . . .  one preimage of an element
##                                                       under a gen. mapping
##
##  <#GAPDoc Label="PreImagesRepresentative">
##  <ManSection>
##  <Oper Name="PreImagesRepresentative" Arg='map, elm'/>
##
##  <Description>
##  If <A>elm</A> is an element of the range of the general mapping
##  <A>map</A> then <Ref Oper="PreImagesRepresentative"/> returns either a
##  representative of the set of preimages of <A>elm</A> under <A>map</A> or
##  <K>fail</K>, the latter if and only if <A>elm</A>
##  has no preimages under <A>map</A>.
##  <P/>
##  Anything may happen if <A>elm</A> is not an element of the range of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PreImagesRepresentative",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImagesSet( <map>, <elms> )
##
##  <#GAPDoc Label="PreImagesSet">
##  <ManSection>
##  <Oper Name="PreImagesSet" Arg='map, elms'/>
##
##  <Description>
##  If <A>elms</A> is a subset of the range of the general mapping <A>map</A>
##  then <Ref Oper="PreImagesSet"/> returns the set of all preimages of
##  <A>elms</A> under <A>map</A>.
##  <P/>
##  Anything may happen if <A>elms</A> is not a subset of the range of
##  <A>map</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PreImagesSet", [ IsGeneralMapping, IsListOrCollection ] );


#############################################################################
##
#F  PreImage( <map> ) . .  set of preimages of the range of a general mapping
#F  PreImage( <map>, <elm> )  . unique preimage of an elm under a gen.mapping
#F  PreImage(<map>, <coll>)  set of preimages of a coll. under a gen. mapping
##
##  <#GAPDoc Label="PreImage">
##  <ManSection>
##  <Heading>PreImage</Heading>
##  <Func Name="PreImage" Arg='map'
##   Label="set of preimages of the range of a general mapping"/>
##  <Func Name="PreImage" Arg='map, elm'
##   Label="unique preimage of an element under a general mapping"/>
##  <Func Name="PreImage" Arg='map, coll'
##   Label="set of preimages of a collection under a general mapping"/>
##
##  <Description>
##  <C>PreImage( <A>map</A> )</C> is the preimage of the general mapping
##  <A>map</A>, i.e., the subset of elements of the source of <A>map</A>
##  that actually have values under <A>map</A>.
##  Note that in this case the argument may also be non-injective or
##  non-surjective.
##  <P/>
##  <C>PreImage( <A>map</A>, <A>elm</A> )</C> is the preimage of the element
##  <A>elm</A> of the range of the injective and surjective mapping
##  <A>map</A> under <A>map</A>, i.e., the unique element of the source
##  which is mapped under <A>map</A> to <A>elm</A>.
##  Note that <A>map</A> must be injective and surjective
##  (see&nbsp;<Ref Func="PreImages" Label="set of preimages of the range of a general mapping"/>).
##  <P/>
##  <C>PreImage( <A>map</A>, <A>coll</A> )</C> is the preimage of the subset
##  <A>coll</A> of the range of the general mapping <A>map</A> under
##  <A>map</A>, i.e., the subset of the source which is mapped under
##  <A>map</A> to elements of <A>coll</A>. <A>coll</A> may be a proper set
##  or a domain.
##  The result will be either a proper set or a domain.
##  Note that in this case <A>map</A> may also be non-injective or
##  non-surjective.
##  (If <A>coll</A> and the result are lists then the positions of
##  entries do in general <E>not</E> correspond.)
##  <P/>
##  <Ref Func="PreImage" Label="set of preimages of the range of a general mapping"/>
##  delegates to <Ref Attr="PreImagesRange"/> when
##  called with one argument,
##  and to <Ref Oper="PreImageElm"/> resp. <Ref Oper="PreImagesSet"/> when
##  called with two arguments.
##  <P/>
##  If the second argument is not an element or a subset of the range of
##  the first argument, an error is signalled.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PreImage" );


#############################################################################
##
#F  PreImages( <map> )  . . . set of preimages of the range of a gen. mapping
#F  PreImages(<map>,<elm>)  . set of preimages of an elm under a gen. mapping
#F  PreImages(<map>,<coll>)  set of preimages of a coll. under a gen. mapping
##
##  <#GAPDoc Label="PreImages">
##  <ManSection>
##  <Heading>PreImages</Heading>
##  <Func Name="PreImages" Arg='map'
##   Label="set of preimages of the range of a general mapping"/>
##  <Func Name="PreImages" Arg='map, elm'
##   Label="set of preimages of an elm under a general mapping"/>
##  <Func Name="PreImages" Arg='map, coll'
##   Label="set of preimages of a collection under a general mapping"/>
##
##  <Description>
##  <C>PreImages( <A>map</A> )</C> is the preimage of the general mapping
##  <A>map</A>, i.e., the subset of elements of the source of <A>map</A>
##  that have actually values under <A>map</A>.
##  <P/>
##  <C>PreImages( <A>map</A>, <A>elm</A> )</C> is the set of preimages of the
##  element <A>elm</A> of the range of the general mapping <A>map</A> under
##  <A>map</A>, i.e., the set of elements of the source which <A>map</A> maps
##  to <A>elm</A>.
##  <P/>
##  <C>PreImages( <A>map</A>, <A>coll</A> )</C> is the set of images of the
##  subset <A>coll</A> of the range of the general mapping <A>map</A> under
##  <A>map</A>, i.e., the subset of the source which <A>map</A> maps to
##  elements of <A>coll</A>.
##  <A>coll</A> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##  (If <A>coll</A> and the result are lists then the positions of
##  entries do in general <E>not</E> correspond.)
##  <P/>
##  <Ref Func="PreImages" Label="set of preimages of the range of a general mapping"/>
##  delegates to <Ref Attr="PreImagesRange"/> when
##  called with one argument,
##  and to <Ref Oper="PreImagesElm"/> resp. <Ref Oper="PreImagesSet"/> when
##  called with two arguments.
##  <P/>
##  If the second argument is not an element or a subset of the range of
##  the first argument, an error is signalled.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PreImages" );


#############################################################################
##
#O  CompositionMapping2(<map2>,<map1>)  . . . composition of general mappings
#F  CompositionMapping2General(<map2>,<map1>)
##
##  <#GAPDoc Label="CompositionMapping2">
##  <ManSection>
##  <Oper Name="CompositionMapping2" Arg='map2, map1'/>
##  <Func Name="CompositionMapping2General" Arg='map2, map1'/>
##
##  <Description>
##  <Ref Oper="CompositionMapping2"/> returns the composition of <A>map2</A>
##  and <A>map1</A>,
##  this is the general mapping that maps an element first under <A>map1</A>,
##  and then maps the images under <A>map2</A>.
##  <P/>
##  (Note the reverse ordering of arguments in the composition via
##  the multiplication <Ref Oper="\*"/>.
##  <P/>
##  <Ref Func="CompositionMapping2General"/> is the method that forms a
##  composite mapping with two constituent mappings.
##  (This is used in some algorithms.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CompositionMapping2",
    [ IsGeneralMapping, IsGeneralMapping ] );

DeclareGlobalFunction("CompositionMapping2General");


#############################################################################
##
#F  CompositionMapping( <map1>, <map2>, ... ) . . . . composition of mappings
##
##  <#GAPDoc Label="CompositionMapping">
##  <ManSection>
##  <Func Name="CompositionMapping" Arg='map1, map2, ...'/>
##
##  <Description>
##  <Ref Func="CompositionMapping"/> allows one to compose arbitrarily many
##  general mappings,
##  and delegates each step to <Ref Oper="CompositionMapping2"/>.
##  The result is a map that maps an element first under the last argument,
##  then under the penultimate argument and so forth.
##  <P/>
##  Additionally, the properties <Ref Prop="IsInjective"/> and
##  <Ref Prop="IsSingleValued"/> are maintained.
##  If the range of the <M>i+1</M>-th argument is identical to
##  the range of the <M>i</M>-th argument,
##  also <Ref Prop="IsTotal"/> and <Ref Prop="IsSurjective"/> are maintained.
##  (So one should not call <Ref Oper="CompositionMapping2"/> directly
##  if one wants to maintain these properties.)
##  <P/>
##  Depending on the types of <A>map1</A> and <A>map2</A>,
##  the returned mapping might be constructed completely new (for example by
##  giving domain generators and their images, this is for example the case
##  if both mappings preserve the same algebraic structures and &GAP; can
##  decompose elements of the source of <A>map2</A> into generators) or as an
##  (iterated) composition
##  (see&nbsp;<Ref Filt="IsCompositionMappingRep"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> f := GroupHomomorphismByImages(CyclicGroup(IsPermGroup, 2),
##  >                                   CyclicGroup(IsPermGroup, 1));
##  [ (1,2) ] -> [ () ]
##  gap> g := GroupHomomorphismByImages(CyclicGroup(IsPermGroup, 6),
##  >                                   CyclicGroup(IsPermGroup, 2));
##  [ (1,2,3,4,5,6) ] -> [ (1,2) ]
##  gap> CompositionMapping(f, g);
##  [ (1,2,3,4,5,6) ] -> [ () ]
##  gap> CompositionMapping(g, f);
##  [ (1,2) ] -> [ () ]
##  ]]></Example>
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CompositionMapping" );


#############################################################################
##
#R  IsCompositionMappingRep( <map> )
##
##  <#GAPDoc Label="IsCompositionMappingRep">
##  <ManSection>
##  <Filt Name="IsCompositionMappingRep" Arg='map' Type='Representation'/>
##
##  <Description>
##  Mappings in this representation are stored as composition of two
##  mappings, (pre)images of elements are computed in a two-step process.
##  The constituent mappings of the composition can be obtained via
##  <Ref Func="ConstituentsCompositionMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsCompositionMappingRep",
    IsGeneralMapping and IsAttributeStoringRep, [ "map1", "map2" ] );


#############################################################################
##
#F  ConstituentsCompositionMapping( <map> )
##
##  <#GAPDoc Label="ConstituentsCompositionMapping">
##  <ManSection>
##  <Func Name="ConstituentsCompositionMapping" Arg='map'/>
##
##  <Description>
##  If <A>map</A> is stored in the representation
##  <Ref Filt="IsCompositionMappingRep"/> as composition of two mappings
##  <A>map1</A> and <A>map2</A>, this function returns the
##  two constituent mappings in a list <C>[ <A>map1</A>, <A>map2</A> ]</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstituentsCompositionMapping" );


#############################################################################
##
#O  ZeroMapping( <S>, <R> ) . . . . . . . . . .  zero mapping from <S> to <R>
##
##  <#GAPDoc Label="ZeroMapping">
##  <ManSection>
##  <Oper Name="ZeroMapping" Arg='S, R'/>
##
##  <Description>
##  A zero mapping is a total general mapping that maps each element of its
##  source to the zero element of its range.
##  <P/>
##  (Each mapping with empty source is a zero mapping.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZeroMapping", [ IsCollection, IsCollection ] );


#############################################################################
##
#O  RestrictedMapping( <map>, <subdom> )
##
##  <#GAPDoc Label="RestrictedMapping">
##  <ManSection>
##  <Oper Name="RestrictedMapping" Arg='map, subdom'/>
##
##  <Description>
##  If <A>subdom</A> is a subdomain of the source of the general mapping
##  <A>map</A>,
##  this operation returns the restriction of <A>map</A> to <A>subdom</A>.
##  <!--  The general concept of restricted general mappings still missing.-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RestrictedMapping", [ IsGeneralMapping, IsDomain ] );


#############################################################################
##
#R  IsGeneralRestrictedMappingRep( <map> )
##
##  Mappings in this representation are stored as wrapper object, containing
##  the original map but new source and range.
##
DeclareRepresentation( "IsGeneralRestrictedMappingRep",
    IsGeneralMapping and IsAttributeStoringRep, [ "map" ] );

#############################################################################
##
#F  GeneralRestrictedMapping( <map>, <source>, <range> )
##
##  <C>GeneralRestrictedMapping</C> allows one to restrict <source> and
##  <range> for an existing mapping, for example enforcing injectivity or
##  surjectivity this way.
##
DeclareGlobalFunction( "GeneralRestrictedMapping" );

#############################################################################
##
#O  Embedding( <S>, <T> ) . . . . . . .  embedding of one domain into another
#O  Embedding( <S>, <i> )
##
##  <#GAPDoc Label="Embedding">
##  <ManSection>
##  <Heading>Embedding</Heading>
##  <Oper Name="Embedding" Arg='S, T' Label="for two domains"/>
##  <Oper Name="Embedding" Arg='S, i'
##   Label="for a domain and a positive integer"/>
##
##  <Description>
##  returns the embedding of the domain <A>S</A> in the domain <A>T</A>,
##  or in the second form, some domain indexed by the positive integer
##  <A>i</A>.
##  The precise natures of the various methods are described elsewhere:
##  for Lie algebras, see <Ref Attr="LieFamily"/>; for group  products,
##  see&nbsp;<Ref Sect="Embeddings and Projections for Group Products"/>
##  for a general description, or for examples
##  see&nbsp;<Ref Sect="Direct Products"/> for direct products,
##  <Ref Sect="Semidirect Products"/> for semidirect products,
##  or&nbsp;<Ref Sect="Wreath Products"/> for wreath products; or for
##  magma rings
##  see&nbsp;<Ref Sect="Natural Embeddings related to Magma Rings"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Embedding", [ IsDomain, IsObject ] );


#############################################################################
##
#O  Projection( <S>, <T> )  . . . . . . projection of one domain onto another
#O  Projection( <S>, <i> )
#O  Projection( <S> )
##
##  <#GAPDoc Label="Projection">
##  <ManSection>
##  <Heading>Projection</Heading>
##  <Oper Name="Projection" Arg='S, T' Label="for two domains"/>
##  <Oper Name="Projection" Arg='S, i'
##   Label="for a domain and a positive integer"/>
##  <Oper Name="Projection" Arg='S' Label="for a domain"/>
##
##  <Description>
##  returns the projection of the domain <A>S</A> onto the domain <A>T</A>,
##  or in the second form, some domain indexed by the positive integer
##  <A>i</A>,
##  or in the third form some natural quotient domain of <A>S</A>.
##  Various methods are defined for group products;
##  see&nbsp;<Ref Sect="Embeddings and Projections for Group Products"/> for
##  a general description,
##  or for examples see&nbsp;<Ref Sect="Direct Products"/> for direct
##  products, <Ref Sect="Semidirect Products"/> for semidirect products,
##  <Ref Sect="Subdirect Products"/> for subdirect products,
##  or&nbsp;<Ref Sect="Wreath Products"/> for wreath products.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Projection", [ IsDomain, IsObject ] );


#############################################################################
##
#F  GeneralMappingByElements( <S>, <R>, <elms> )
##
##  <#GAPDoc Label="GeneralMappingByElements">
##  <ManSection>
##  <Func Name="GeneralMappingByElements" Arg='S, R, elms'/>
##
##  <Description>
##  is the general mapping with source <A>S</A> and range <A>R</A>,
##  and with underlying relation consisting of the collection <A>elms</A>
##  of direct product elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GeneralMappingByElements" );


#############################################################################
##
#F  MappingByFunction( <S>, <R>, <fun>[, <invfun>] )
#F  MappingByFunction( <S>, <R>, <fun>, `false', <prefun> )
##
##  <#GAPDoc Label="MappingByFunction">
##  <ManSection>
##  <Heading>MappingByFunction</Heading>
##  <Func Name="MappingByFunction" Arg='S, R, fun[, invfun]'
##   Label="by function (and inverse function) between two domains"/>
##  <Func Name="MappingByFunction" Arg='S, R, fun, false, prefun'
##   Label="by function and function that computes one preimage"/>
##
##  <Description>
##  <Ref Func="MappingByFunction" Label="by function (and inverse function) between two domains"/>
##  returns a mapping <C>map</C> with source
##  <A>S</A> and range <A>R</A>,
##  such that each element <M>s</M> of <A>S</A> is mapped to the element
##  <A>fun</A><M>( s )</M>, where <A>fun</A> is a &GAP; function.
##  <P/>
##  If the argument <A>invfun</A> is bound then <C>map</C> is a bijection
##  between <A>S</A> and <A>R</A>, and the preimage of each element <M>r</M>
##  of <A>R</A> is given by <A>invfun</A><M>( r )</M>,
##  where <A>invfun</A> is a &GAP;  function.
##  <P/>
##  If five arguments are given and the fourth argument is <K>false</K> then
##  the &GAP; function <A>prefun</A> can be used to compute a single preimage
##  also if <C>map</C> is not bijective.
##  <!-- what is <A>prefun</A> expected to return for <A>r</A> outside the image of <A>map</A>-->
##  <!-- if <A>map</A> is not surjective?-->
##  <!-- or must <A>map</A> be surjective in this case?-->
##  <P/>
##  The mapping returned by
##  <Ref Func="MappingByFunction" Label="by function (and inverse function) between two domains"/> lies in the
##  filter <Ref Filt="IsNonSPGeneralMapping"/>,
##  see&nbsp;<Ref Sect="Technical Matters Concerning General Mappings"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MappingByFunction" );


#############################################################################
##
#m  IsBijective . . . . . . . . . . . . . . . . . . . .  for identity mapping
##
InstallTrueMethod( IsBijective, IsGeneralMapping and IsOne );


#############################################################################
##
#m  IsSingleValued  . . . . . . . . . . . . . . . . . . . .  for zero mapping
#m  IsTotal . . . . . . . . . . . . . . . . . . . . . . . .  for zero mapping
##
InstallTrueMethod( IsSingleValued, IsGeneralMapping and IsZero );
InstallTrueMethod( IsTotal, IsGeneralMapping and IsZero );


#############################################################################
##
#F  CopyMappingAttributes( <from>, <to> )
##
##  <ManSection>
##  <Func Name="CopyMappingAttributes" Arg='from, to'/>
##
##  <Description>
##  Let <A>from</A> and <A>to</A> be two general mappings which are known to be equal.
##  <C>CopyMappingAttributes</C> copies known mapping attributes from <A>from</A> to
##  <A>to</A>. This is used in operations, such as
##  <C>AsGroupGeneralMappingByImages</C>, that produce equal mappings in another
##  representation.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CopyMappingAttributes" );

#############################################################################
##
#A  MappingGeneratorsImages(<map>)
##
##  <#GAPDoc Label="MappingGeneratorsImages">
##  <ManSection>
##  <Attr Name="MappingGeneratorsImages" Arg='map'/>
##
##  <Description>
##  This attribute contains a list of length 2, the first entry being a list
##  of generators of the source of <A>map</A> and the second entry a list of
##  their images. This attribute is used, for example, by
##  <Ref Func="GroupHomomorphismByImages"/> to store generators and images.
##  <!--  <C>MappingGeneratorsImages</C> is permitted to call           -->
##  <!--  <C>Source</C> and <C>ImagesRepresentative</C>.                -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MappingGeneratorsImages", IsGeneralMapping );
