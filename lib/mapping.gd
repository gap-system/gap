#############################################################################
##
#W  mapping.gd                  GAP library                     Thomas Breuer
#W                                                         & Martin Schoenert
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for general mappings.
##

#1
##  A *general mapping* $F$ in {\GAP} is described by
##  its source $S$, its range $R$, and a subset $Rel$ of the direct product
##  $S \times R$, which is called the underlying relation of $F$.
##  $S$, $R$, and $Rel$ are generalized domains (see Chapter~"Domains").
##  The corresponding attributes for general mappings are `Source', `Range',
##  and `UnderlyingRelation'.
#T what about the family predicates if the source/range is not a
#T collection?
##
##  Note that general mappings themselves are *not* domains.
##  One reason for this is that two general mappings with same underlying
##  relation are regarded as equal only if also the sources are equal and
##  the ranges are equal.
##  Other, more technical, reasons are that general mappings and domains
##  have different basic operations, and that general mappings are
##  arithmetic objects (see~"Arithmetic Operations for General Mappings");
##  both should not apply to domains.
##
##  Each element of an underlying relation of a general mapping lies in the
##  category of tuples (see~"IsTuple").
##
##  For each $s \in S$, the set $\{ r \in R | (s,r) \in Rel \}$
##  is called the set of *images* of $s$.
##  Analogously, for $r \in R$, the set $\{ s \in S | (s,r) \in Rel \}$
##  is called the set of *preimages* of $r$.
##
##  The *ordering* of general mappings via `\<' is defined by the ordering
##  of source, range, and underlying relation. Specifically, if the Source
##  and Range domains of <map1> and <map2> are the same, then one considers 
##  the union of the preimages of <map1> and <map2> as a strictly ordered set.
##  The smaller of <map1> and <map2> is the one whose image is smaller on the 
##  first point of this sequence where they differ.
##

#2
##  `Source' and `Range' are basic operations for general mappings.
##  `UnderlyingRelation' is secondary, its default method sets up a
##  domain that delegates tasks to the general mapping.
##  (Note that this allows one to handle also infinite relations by generic
##  methods if source or range of the general mapping is finite.)
##
##  The distinction between basic operations and secondary operations for
##  general mappings may be a little bit complicated.
##  Namely, each general mapping must be in one of the two categories
##  `IsNonSPGeneralMapping', `IsSPGeneralMapping'.
##  (The category `IsGeneralMapping' is defined as the disjoint union
##  of these two.)
##
##  For general mappings of the first category, `ImagesElm' and
##  `PreImagesElm' are basic operations.
##  (Note that in principle it is possible to delegate from `PreImagesElm'
##  to `ImagesElm'.)
##  Methods for the secondary operations `(Pre)ImageElm', `(Pre)ImagesSet',
##  and `(Pre)ImagesRepresentative' may use `(Pre)ImagesElm',
##  and methods for `(Pre)ImagesElm' must not call the secondary operations.
##  In particular, there are no generic methods for `(Pre)ImagesElm'.
##
##  Methods for `(Pre)ImagesSet' must *not* use `PreImagesRange' and
##  `ImagesSource', e.g., compute the intersection of the set in question
##  with the preimage of the range resp. the image of the source.
##
##  For general mappings of the second category (which means structure
##  preserving general mappings), the situation is different.
##  The set of preimages under a group homomorphism, for example, is either
##  empty or can be described as a coset of the (multiplicative) kernel.
##  So it is reasonable to have `(Pre)ImagesRepresentative' and
##  `Multplicative(Co)Kernel' as basic operations here,
##  and to make `(Pre)ImagesElm' secondary operations
##  that may delegate to these.
##  
##  In order to avoid infinite recursions,
##  we must distinguish between the two different types of mappings.
##
##  (Note that the basic domain operations such as `AsList' for the
##  underlying relation of a general mapping may use either `ImagesElm'
##  or `ImagesRepresentative' and the appropriate cokernel.
##  Conversely, if `AsList' for the underlying relation is known then
##  `ImagesElm' resp. `ImagesRepresentative' may delegate to it, the general
##  mapping gets the property `IsConstantTimeAccessGeneralMapping' for this;
##  note that this is not allowed if only an enumerator of the underlying
##  relation is known.)
##
##  Secondary operations are
##  `IsInjective', `IsSingleValued', `IsSurjective', `IsTotal';
##  they may use the basic operations, and must not be used by them.
##

#3
##  General mappings are arithmetic objects.
##  One can form groups and vector spaces of general mappings provided
##  that they are invertible or can be added and admit scalar multiplication,
##  respectively.
##
##  For two general mappings with same source, range, preimage, and image,
##  the *sum* is defined pointwise, i.e., the images of a point under the sum
##  is the set of all sums with first summand in the images of the first
##  general mapping and second summand in the images of the second general
##  mapping.
##
##  *Scalar multiplication* of general mappings is defined likewise.
##
##  The *product* of two general mappings is defined as the composition.
##  This multiplication is always associative.
##  In addition to the composition via `\*', general mappings can be composed
##  --in reversed order-- via `CompositionMapping'.
##
##  General mappings are in the category of multiplicative elements with
##  inverses.
##  Similar to matrices, not every general mapping has an inverse or an
##  identity, and we define the behaviour of `One' and `Inverse' for
##  general mappings as follows.
##  `One' returns `fail' when called for a general mapping whose source and
##  range differ, otherwise `One' returns the identity mapping of the source.
##  (Note that the source may differ from the preimage).
##  `Inverse' returns `fail' when called for a non-bijective general mapping
##  or for a general mapping whose source and range differ; otherwise
##  `Inverse' returns the inverse mapping.
##
##  Besides the usual inverse of multiplicative elements, which means that
##  `Inverse( <g> ) \* <g> = <g> \* Inverse( <g> ) = One( <g> )',
##  for general mappings we have the attribute `InverseGeneralMapping'.
##  If <F> is a general mapping with source $S$, range $R$, and underlying
##  relation $Rel$ then `InverseGeneralMapping( <F> )' has source $R$,
##  range $S$, and underlying relation $\{ (r,s) \mid (s,r) \in Rel \}$.
##  For a general mapping that has an inverse in the usual sense,
##  i.e., for a bijection of the source, of course both concepts coincide.
##
##  `Inverse' may delegate to `InverseGeneralMapping'.
##  `InverseGeneralMapping' must not delegate to `Inverse', but a known
##  value of `Inverse' may be fetched.
##  So methods to compute the inverse of a general mapping should be
##  installed for `InverseGeneralMapping'.
##
##  (Note that in many respects, general mappings behave similar to matrices,
##  for example one can define left and right identities and inverses, which
##  do not fit into the current concepts of {\GAP}.)
##

#4
##  Methods for the operations `ImagesElm', `ImagesRepresentative',
##  `ImagesSet', `ImageElm', `PreImagesElm', `PreImagesRepresentative',
##  `PreImagesSet', and `PreImageElm' take two arguments, a general mapping
##  <map> and an element or collection of elements <elm>.
##  These methods must *not* check whether <elm> lies in the source or the
##  range of <map>.
##  In the case that <elm> does not, `fail' may be returned as well as any
##  other {\GAP} object, and even an error message is allowed.
##  Checks of the arguments are done only by the functions `Image', `Images',
##  `PreImage', and `PreImages', which then delegate to the operations listed
##  above.
##
Revision.mapping_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsGeneralMapping( <map> )
##
##  Each general mapping lies in the category `IsGeneralMapping'.
##  It implies the categories `IsMultiplicativeElementWithInverse'
##  (see~"IsMultiplicativeElementWithInverse")
##  and `IsAssociativeElement' (see~"IsAssociativeElement");
##  for a discussion of these implications,
##  see~"Arithmetic Operations for General Mappings".
##
DeclareCategory( "IsGeneralMapping",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );


#############################################################################
##
#C  IsSPGeneralMapping( <map> )
#C  IsNonSPGeneralMapping( <map> )
##
#T  What we want to express is that `IsGeneralMapping' is the disjoint union
#T  of `IsSPGeneralMapping' and `IsNonSPGeneralMapping'.
##
DeclareCategory( "IsSPGeneralMapping", IsGeneralMapping );
DeclareCategory( "IsNonSPGeneralMapping", IsGeneralMapping );


#############################################################################
##
#C  IsGeneralMappingCollection( <obj> )
##
DeclareCategoryCollections( "IsGeneralMapping" );


#############################################################################
##
#C  IsGeneralMappingFamily( <obj> )
##
DeclareCategoryFamily( "IsGeneralMapping" );


#############################################################################
##
#A  FamilyRange( <Fam> )
##
##  is the elements family of the family of the range of each general
##  mapping in the family <Fam>.
##
DeclareAttribute( "FamilyRange", IsGeneralMappingFamily );


#############################################################################
##
#A  FamilySource( <Fam> )
##
##  is the elements family of the family of the source of each general
##  mapping in the family <Fam>.
##
DeclareAttribute( "FamilySource", IsGeneralMappingFamily );


#############################################################################
##
#A  FamiliesOfGeneralMappingsAndRanges( <Fam> )
##
##  is a list that stores at the odd positions the families of general
##  mappings with source in the family <Fam>, at the even positions the
##  families of ranges of the general mappings.
##
DeclareAttribute( "FamiliesOfGeneralMappingsAndRanges",
    IsFamily, "mutable" );


#############################################################################
##
#P  IsConstantTimeAccessGeneralMapping( <map> )
##
##  is `true' if the underlying relation of the general mapping <map>
##  knows its `AsList' value, and `false' otherwise.
##
##  In the former case, <map> is allowed to use this list for calls to
##  `ImagesElm' etc.
##
DeclareProperty( "IsConstantTimeAccessGeneralMapping", IsGeneralMapping );


#############################################################################
##
#P  IsEndoGeneralMapping( <obj> )
##
##  If a general mapping has this property then its source and range are
##  equal.
##
DeclareProperty( "IsEndoGeneralMapping", IsGeneralMapping );

#############################################################################
##
#P  IsTotal( <map> )  . . . . . . . . test whether a general mapping is total
##
##  is `true' if each element in the source $S$ of the general mapping <map>
##  has images, i.e.,
##  $s^{<map>} \not= \emptyset$ for all $s\in S$,
##  and `false' otherwise.
##
DeclareProperty( "IsTotal", IsGeneralMapping );


#############################################################################
##
#P  IsSingleValued( <map> ) . test whether a general mapping is single-valued
##
##  is `true' if each element in the source $S$ of the general mapping <map>
##  has at most one image, i.e.,
##  $|s^{<map>}| \leq 1$ for all $s\in S$,
##  and `false' otherwise.
##
##  Equivalently, `IsSingleValued( <map> )' is `true' if and only if
##  the preimages of different elements in $R$ are disjoint.
##
DeclareProperty( "IsSingleValued", IsGeneralMapping );


#############################################################################
##
#P  IsMapping( <map> )
##
##  A *mapping* <map> is a general mapping that assigns to each element `elm'
##  of its source a unique element `Image( <map>, <elm> )' of its range.
##
##  Equivalently, the general mapping <map> is a mapping if and only if it is
##  total and single-valued (see~"IsTotal", "IsSingleValued").
##
DeclareSynonymAttr( "IsMapping",
    IsGeneralMapping and IsTotal and IsSingleValued );



#############################################################################
##
#P  IsEndoMapping( <obj> )
##
##  If a mapping has this property then its source and range are
##  equal and it is single valued.
##
DeclareSynonymAttr( "IsEndoMapping", IsMapping and IsEndoGeneralMapping );


#############################################################################
##
#P  IsInjective( <map> )  . . . . . .  test if a general mapping is injective
##
##  is `true' if the images of different elements in the source $S$ of the
##  general mapping <map> are disjoint, i.e.,
##  $x^{<map>} \cap y^{<map>} = \emptyset$ for $x\not= y\in S$,
##  and `false' otherwise.
##
##  Equivalently, `IsInjective( <map> )' is `true' if and only if each
##  element in the range of <map> has at most one preimage in $S$.
##
DeclareProperty( "IsInjective", IsGeneralMapping );


#############################################################################
##
#P  IsSurjective( <map> ) . . . . . . test if a general mapping is surjective
##
##  is `true' if each element in the range $R$ of the general mapping <map>
##  has preimages in the source $S$ of <map>, i.e.,
##  $\{ s\in S \mid x\in s^{<map>} \} \not= \emptyset$ for all $x\in R$,
##  and `false' otherwise.
##
DeclareProperty( "IsSurjective", IsGeneralMapping );


#############################################################################
##
#P  IsBijective( <map> )  . . . . . .  test if a general mapping is bijective
##
##  A general mapping <map> is *bijective* if and only if it is an injective
##  and surjective mapping (see~"IsMapping", "IsInjective", "IsSurjective").
##
DeclareSynonymAttr( "IsBijective",
    IsSingleValued and IsTotal and IsInjective and IsSurjective );


#############################################################################
##
#A  Range( <map> )  . . . . . . . . . . . . . . .  range of a general mapping
##
DeclareAttribute( "Range", IsGeneralMapping );


#############################################################################
##
#A  Source( <map> ) . . . . . . . . . . . . . . . source of a general mapping
##
DeclareAttribute( "Source", IsGeneralMapping );


#############################################################################
##
#A  UnderlyingRelation( <map> ) . .  underlying relation of a general mapping
##
##  The *underlying relation* of a general mapping <map> is the domain
##  of pairs $(s,r)$, with $s$ in the source and $r$ in the range of <map>
##  (see~"Source", "Range"), and $r\in$`ImagesElm( <map>, $s$ )'.
##
##  Each element of the underlying relation is a tuple (see~"IsTuple").
##
DeclareAttribute( "UnderlyingRelation", IsGeneralMapping );


#############################################################################
##
#A  UnderlyingGeneralMapping( <map> )
##
##  attribute for underlying relations of general mappings
##
DeclareAttribute( "UnderlyingGeneralMapping", IsCollection );


#############################################################################
##
#F  GeneralMappingsFamily( <sourcefam>, <rangefam> )
##
##  All general mappings with same source family <FS> and same range family
##  <FR> lie in the family `GeneralMappingsFamily( <FS>, <FR> )'.
##
DeclareGlobalFunction( "GeneralMappingsFamily" );


#############################################################################
##
#F  TypeOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
##  is the type of mappings with `IsDefaultGeneralMappingRep' with source
##  <source> and range <range> and additional categories <filter>.
##
DeclareGlobalFunction( "TypeOfDefaultGeneralMapping" );


#############################################################################
##
#A  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
##  is the bijective mapping with source and range equal to the collection
##  <D>, which maps each element of <D> to itself.
##
DeclareAttribute( "IdentityMapping", IsCollection );


#############################################################################
##
#A  InverseGeneralMapping( <map> )
##
##  The *inverse general mapping* of a general mapping <map> is the general
##  mapping whose underlying relation (see~"UnderlyingRelation") contains a
##  pair $(r,s)$ if and only if the underlying relation of <map> contains
##  the pair $(s,r)$.
##
##  See the introduction to Chapter~"Mappings" for the subtleties concerning
##  the difference between `InverseGeneralMapping' and `Inverse'.
##
##  Note that the inverse general mapping of a mapping <map> is in general
##  only a general mapping.
##  If <map> knows to be bijective its inverse general mapping will know to
##  be a mapping.
##  In this case also `Inverse( <map> )' works.
##
DeclareAttribute( "InverseGeneralMapping", IsGeneralMapping );


#############################################################################
##
#A  ImagesSource( <map> )
##
##  is the set of images of the source of the general mapping <map>.
##
##  `ImagesSource' delegates to `ImagesSet',
##  it is introduced only to store the image of <map> as attribute value.
##
DeclareAttribute( "ImagesSource", IsGeneralMapping );


#############################################################################
##
#A  PreImagesRange( <map> )
##
##  is the set of preimages of the range of the general mapping <map>.
##
##  `PreImagesRange' delegates to `PreImagesSet',
##  it is introduced only to store the preimage of <map> as attribute value.
##
DeclareAttribute( "PreImagesRange", IsGeneralMapping );


#############################################################################
##
#O  ImagesElm( <map>, <elm> ) . . . all images of an elm under a gen. mapping
##
##  If <elm> is an element of the source of the general mapping <map> then
##  `ImagesElm' returns the set of all images of <elm> under <map>.
##
##  Anything may happen if <elm> is not an element of the source of <map>.
##
DeclareOperation( "ImagesElm", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesRepresentative(<map>,<elm>) . one image of elm under a gen. mapping
##
##  If <elm> is an element of the source of the general mapping <map> then
##  `ImagesRepresentative' returns either a representative of the set of
##  images of <elm> under <map> or `fail', the latter if and only if <elm>
##  has no images under <map>.
##
##  Anything may happen if <elm> is not an element of the source of <map>.
##
DeclareOperation( "ImagesRepresentative", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesSet( <map>, <elms> )
##
##  If <elms> is a subset of the source of the general mapping <map> then
##  `ImagesSet' returns the set of all images of <elms> under <map>.
##
##  Anything may happen if <elms> is not a subset of the source of <map>.
##
DeclareOperation( "ImagesSet", [ IsGeneralMapping, IsCollection ] );


#############################################################################
##
#O  ImageElm( <map>, <elm> )  . . . .  unique image of an elm under a mapping
##
##  If <elm> is an element of the source of the total and single-valued
##  mapping <map> then
##  `ImageElm' returns the unique image of <elm> under <map>.
##
##  Anything may happen if <elm> is not an element of the source of <map>.
##
DeclareOperation( "ImageElm", [ IsMapping, IsObject ] );


#############################################################################
##
#F  Image( <map> )  . . . .  set of images of the source of a general mapping
#F  Image( <map>, <elm> ) . . . .  unique image of an element under a mapping
#F  Image( <map>, <coll> )  . . set of images of a collection under a mapping
##
##  `Image( <map> )' is the image of the general mapping <map>, i.e.,
##  the subset of elements of the range of <map> that are actually values of
##  <map>.
##  Note that in this case the argument may also be multi-valued.
##
##  `Image( <map>, <elm> )' is the image of the element <elm> of the source
##  of the mapping <map> under <map>, i.e., the unique element of the range
##  to which <map> maps <elm>.
##  This can also be expressed as `<elm> ^ <map>'.
##  Note that <map> must be total and single valued, a multi valued general
##  mapping is not allowed (see~"Images").
##
##  `Image( <map>, <coll> )' is the image of the subset <coll> of the source
##  of the mapping <map> under <map>, i.e., the subset of the range
##  to which <map> maps elements of <coll>.
##  <coll> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##  Note that in this case <map> may also be multi-valued.
##
##  `Image' delegates to `ImagesSource' when called with one argument,
##  and to `ImageElm' resp. `ImagesSet' when called with two arguments.
##
##  If the second argument is not an element or a subset of the source of
##  the first argument, an error is signalled.
##
DeclareGlobalFunction( "Image" );


#############################################################################
##
#F  Images( <map> ) . . . .  set of images of the source of a general mapping
#F  Images( <map>, <elm> )  . . . set of images of an element under a mapping
#F  Images( <map>, <coll> ) . . set of images of a collection under a mapping
##
##  `Images( <map> )' is the image of the general mapping <map>, i.e.,
##  the subset of elements of the range of <map> that are actually values of
##  <map>.
##
##  `Images( <map>, <elm> )' is the set of images of the element <elm> of
##  the source of the general mapping <map> under <map>, i.e., the set of
##  elements of the range to which <map> maps <elm>.
##
##  `Images( <map>, <coll> )' is the set of images of the subset <coll> of
##  the source of the general mapping <map> under <map>, i.e., the subset
##  of the range to which <map> maps elements of <coll>.
##  <coll> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##
##  `Images' delegates to `ImagesSource' when called with one argument,
##  and to `ImagesElm' resp. `ImagesSet' when called with two arguments.
##
##  If the second argument is not an element or a subset of the source of
##  the first argument, an error is signalled.
##
DeclareGlobalFunction( "Images" );


#############################################################################
##
#O  PreImagesElm( <map>, <elm> )  . all preimages of elm under a gen. mapping
##
##  If <elm> is an element of the range of the general mapping <map> then
##  `PreImagesElm' returns the set of all preimages of <elm> under <map>.
##
##  Anything may happen if <elm> is not an element of the range of <map>.
##
DeclareOperation( "PreImagesElm", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImageElm( <map>, <elm> )
##
##  If <elm> is an element of the range of the injective and surjective
##  general mapping <map> then
##  `PreImageElm' returns the unique preimage of <elm> under <map>.
##
##  Anything may happen if <elm> is not an element of the range of <map>.
##
DeclareOperation( "PreImageElm",
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ] );


#############################################################################
##
#O  PreImagesRepresentative( <map>, <elm> ) . . .  one preimage of an element
##                                                       under a gen. mapping
##
##  If <elm> is an element of the range of the general mapping <map> then
##  `PreImagesRepresentative' returns either a representative of the set of
##  preimages of <elm> under <map> or `fail', the latter if and only if <elm>
##  has no preimages under <map>.
##
##  Anything may happen if <elm> is not an element of the range of <map>.
##
DeclareOperation( "PreImagesRepresentative",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImagesSet( <map>, <elms> )
##
##  If <elms> is a subset of the range of the general mapping <map> then
##  `PreImagesSet' returns the set of all preimages of <elms> under <map>.
##
##  Anything may happen if <elms> is not a subset of the range of <map>.
##
DeclareOperation( "PreImagesSet", [ IsGeneralMapping, IsCollection ] );


#############################################################################
##
#F  PreImage( <map> ) . .  set of preimages of the range of a general mapping
#F  PreImage( <map>, <elm> )  . unique preimage of an elm under a gen.mapping
#F  PreImage(<map>,<coll>)   set of preimages of a coll. under a gen. mapping
##
##  `PreImage( <map> )' is the preimage of the general mapping <map>, i.e.,
##  the subset of elements of the source of <map> that actually have values
##  under <map>.
##  Note that in this case the argument may also be non-injective or
##  non-surjective.
##
##  `PreImage( <map>, <elm> )' is the preimage of the element <elm> of the
##  range of the injective and surjective mapping <map> under <map>, i.e.,
##  the unique element of the source which is mapped under <map> to <elm>.
##  Note that <map> must be injective and surjective (see~"PreImages").
##
##  `PreImage( <map>, <coll> )' is the preimage of the subset <coll> of the
##  range of the general mapping <map> under <map>, i.e., the subset of the
##  source which is mapped under <map> to elements of <coll>.
##  <coll> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##  Note that in this case <map> may also be non-injective or
##  non-surjective.
##
##  `PreImage' delegates to `PreImagesRange' when called with one argument,
##  and to `PreImageElm' resp. `PreImagesSet' when called with two arguments.
##
##  If the second argument is not an element or a subset of the range of
##  the first argument, an error is signalled.
##
DeclareGlobalFunction( "PreImage" );


#############################################################################
##
#F  PreImages( <map> )  . . . set of preimages of the range of a gen. mapping
#F  PreImages(<map>,<elm>)  . set of preimages of an elm under a gen. mapping
#F  PreImages(<map>,<coll>)  set of preimages of a coll. under a gen. mapping
##
##  `PreImages( <map> )' is the preimage of the general mapping <map>, i.e.,
##  the subset of elements of the source of <map> that have actually values
##  under <map>.
##
##  `PreImages( <map>, <elm> )' is the set of preimages of the element <elm>
##  of the range of the general mapping <map> under <map>, i.e., the set of
##  elements of the source which <map> maps to <elm>.
##
##  `PreImages( <map>, <coll> )' is the set of images of the subset <coll> of
##  the range of the general mapping <map> under <map>, i.e., the subset
##  of the source which <map> maps to elements of <coll>.
##  <coll> may be a proper set or a domain.
##  The result will be either a proper set or a domain.
##
##  `PreImages' delegates to `PreImagesRange' when called with one argument,
##  and to `PreImagesElm' resp. `PreImagesSet' when called with two
##  arguments.
##
##  If the second argument is not an element or a subset of the range of
##  the first argument, an error is signalled.
##
DeclareGlobalFunction( "PreImages" );


#############################################################################
##
#O  CompositionMapping2(<map2>,<map1>)  . . . composition of general mappings
##
##  `CompositionMapping2' returns the composition of <map2> and <map1>,
##  this is the general mapping that maps an element first under <map1>,
##  and then maps the images under <map2>.
##
##  (Note the reverse ordering of arguments in the composition via `\*'.
##
DeclareOperation( "CompositionMapping2",
    [ IsGeneralMapping, IsGeneralMapping ] );


#############################################################################
##
#F  CompositionMapping( <map1>, <map2>, ... ) . . . . composition of mappings
##
##  `CompositionMapping' allows one to compose arbitrarily many general
##  mappings, and delegates each step to `CompositionMapping2'.
##
##  Additionally, the properties `IsInjective' and `IsSingleValued' are
##  maintained; if the source of the $i+1$-th general mapping is identical to
##  the range of the $i$-th general mapping, also `IsTotal' and
##  `IsSurjective' are maintained.
##  (So one should not call `CompositionMapping2' directly if one wants to
##  maintain these properties.)
##
##  Depending on the types of <map1> and <map2>, the returned mapping might
##  be constructed completely new (for example by giving domain generators
##  and their images, this is for example the case if both mappings preserve
##  the same alagebraic structures and {\GAP} can decompose elements of the
##  source of <map2> into generators) or as an (iterated) composition
##  (see~"IsCompositionMappingRep").
DeclareGlobalFunction( "CompositionMapping" );

#############################################################################
##
#R  IsCompositionMappingRep( <map> )
##
##  Mappings in this representation are stored as composition of two
##  mappings, (pre)images of elements are computed in a two-step process.
##  The constituent mappings of the composition can be obtained via
##  `ConstituentsCompositionMapping'.
DeclareRepresentation( "IsCompositionMappingRep",
    IsGeneralMapping and IsAttributeStoringRep, [ "map1", "map2" ] );

#############################################################################
##
#F  ConstituentsCompositionMapping( <map> )
##
##  If <map> is stored in the representation `IsCompositionMappingRep' as
##  composition of two mappings <map1> and <map2>, this function returns the
##  two constituent mappings in a list [<map1>,<map2>].
DeclareGlobalFunction( "ConstituentsCompositionMapping" );

#############################################################################
##
#O  ZeroMapping( <S>, <R> ) . . . . . . . . . .  zero mapping from <S> to <R>
##
##  A zero mapping is a total general mapping that maps each element of its
##  source to the zero element of its range.
##
##  (Each mapping with empty source is a zero mapping.)
##
DeclareOperation( "ZeroMapping", [ IsCollection, IsCollection ] );


#############################################################################
##
#O  RestrictedMapping( <map>, <subdom> )
##
##  If <subdom> is a subdomain of the source of the general mapping <map>,
##  this operation returns the restriction of <map> to <subdom>.
#T  The general concept of restricted general mappings still missing.
##
DeclareOperation( "RestrictedMapping", [ IsGeneralMapping, IsDomain ] );


#############################################################################
##
#O  Embedding( <S>, <T> ) . . . . . . .  embedding of one domain into another
#O  Embedding( <S>, <i> )
##
##  returns the embedding of the domain <S> in the  domain  <T>,  or  in  the
##  second form, some domain indexed by the positive integer <i>. The precise
##  natures of the various methods are described elsewhere: for Lie algebras,
##  see~`LieFamily' ("LieFamily"); for group  products,  see~"Embeddings  and
##  Projections for  Group  Products"  for  a  general  description,  or  for
##  examples see~"Direct Products" for direct products, "Semidirect Products"
##  for semidirect products, or~"Wreath Products" for wreath products; or for
##  magma rings see~"Natural Embeddings related to Magma Rings".
##
DeclareOperation( "Embedding", [ IsDomain, IsObject ] );


#############################################################################
##
#O  Projection( <S>, <T> )  . . . . . . projection of one domain onto another
#O  Projection( <S>, <i> )
#O  Projection( <S> )
##
##  returns the projection of the domain <S> onto the domain <T>, or  in  the
##  second form, some domain indexed by the positive integer <i>, or  in  the
##  third form some natural subdomain of <S>. Various methods are defined for
##  group products; see~"Embeddings and Projections for Group Products" for a
##  general description, or for examples  see~"Direct  Products"  for  direct
##  products,  "Semidirect  Products"  for  semidirect  products,  "Subdirect
##  Products"  for  subdirect  products,  or~"Wreath  Products"  for   wreath
##  products.
##
DeclareOperation( "Projection", [ IsDomain, IsObject ] );


#############################################################################
##
#F  GeneralMappingByElements( <S>, <R>, <elms> )
##
##  is the general mapping with source <S> and range <R>,
##  and with underlying relation consisting of the tuples collection <elms>.
##
DeclareGlobalFunction( "GeneralMappingByElements" );


#############################################################################
##                                         
#F  MappingByFunction( <S>, <R>, <fun> )  . . . . .  create map from function
#F  MappingByFunction( <S>, <R>, <fun>, <invfun> )
#F  MappingByFunction( <S>, <R>, <fun>, `false',<prefun> )
##
##  `MappingByFunction' returns a mapping <map> with source <S> and range
##  <R>, such that each element <s> of <S> is mapped to the element
##  `<fun>( <s> )', where <fun> is a {\GAP} function.
##
##  If the argument <invfun> is bound then <map> is a bijection between <S>
##  and <R>, and the preimage of each element <r> of <R> is given by
##  `<invfun>( <r> )', where <invfun> is a {\GAP}  function.
##
##  In the third variant, a function <prefun> is given that can be used to
##  compute a single preimage. In this case, the third entry must be
##  `false'.
##
##  `MappingByFunction' creates a mapping which `IsNonSPGeneralMapping'
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
##  Let <from> and <to> be two general mappings which are known to be equal.
##  `CopyMappingAttributes' copies known mapping attributes from <from> to
##  <to>. This is used in operations, such as
##  `AsGroupGeneralMappingByImages', that produce equal mappings in another
##  representation.
##
DeclareGlobalFunction( "CopyMappingAttributes" );

#############################################################################
##
#A  MappingGeneratorsImages(<map>)
##
##  This attribute contains a list of length 2, the first enry being a list
##  of generators of the source of <map> and the second entry a list of
##  their images. This attribute is used (for example) by
##  `GroupHomomorphismByImages' to store generators and images.
#T  `MappingGeneratorsImages' is permitted to call `Source' and
#T  `ImagesRepresentative'.
DeclareAttribute( "MappingGeneratorsImages", IsGeneralMapping );


#############################################################################
##
#E

