#############################################################################
##
#W  mapping.gd                  GAP library                     Thomas Breuer
#W                                                         & Martin Schoenert
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for general mappings.
##
##  A *general mapping* $F$ in {\GAP} is a subset of the direct product of
##  the source $S$ of $F$ and the range $R$ of $F$.
##  (Usually this is called a relation by mathematicians.)
##
##  A general mapping is a domain,
##  each of its elements is in the category of tuples.
##
##  For each $s \in S$, the set $\{ r \in R | (s,r) \in F \}$
##  is called the set of *images* of $s$.
##  Analogously, for $r \in R$, the set $\{ s \in S | (s,r) \in F \}$
##  is called the set of *preimages* of $r$.
##
##  The distinction between basic operations and secondary operations for
##  general mappings may be a little bit complicated.
##  Namely, each general mapping must be in one of the two categories
##  'IsNonSPGeneralMapping', 'IsSPGeneralMapping'.
##
##  For general mappings of the first category, 'ImagesElm' and
##  'PreImagesElm' are basic operations.
##  (Note that in principle it is possible to delegate from 'PreImagesElm'
##  to 'ImagesElm'.)
##  Methods for the secondary operations '(Pre)ImageElm', '(Pre)ImagesSet',
##  and '(Pre)ImagesRepresentative' may use '(Pre)ImagesElm',
##  and methods for '(Pre)ImagesElm' must not call the secondary operations.
##  Especially there are no generic methods for '(Pre)ImagesElm'.
##
##  For general mappings of the second category (which means structure
##  preserving general mappings), the situation is different.
##  The set of preimages under a group homomorphism, for example, is either
##  empty or can be described as a coset of the (multiplicative) kernel.
##  For such general mappings, 
##  So it is reasonable to have '(Pre)ImagesRepresentative' and
##  'Multplicative(Co)Kernel' as basic operations here,
##  and to make '(Pre)ImagesElm' secondary operations
##  that may delegate to these.
##  
##  In order to avoid infinite recursions,
##  we must distinguish between the two different types of mappings.
##
##  (Note that the basic domain operation 'AsList' may use 'ImagesElm'
##  resp. 'ImagesRepresentative' and the appropriate cokernel.)
##
##  Besides this, of course 'Source' and 'Range' are basic operations for
##  general mappings.
##
##  Secondary operations are
##  'IsInjective', 'IsSingleValued', 'IsSurjective', 'IsTotal';
##  they may use the basic operations, and must not be used by them.
##
##  General mappings can be composed via '\*' and --in reversed order--
##  'CompositionMapping'.
##  So general mappings are multiplicative elements.
##  If source and range coincide, the 'One' of a general mapping is defined
##  as the identity mapping of the source.
##  (It is not guaranteed that such mappings are in the category
##  'IsMultiplicativeElementWithOne'.)
##
Revision.mapping_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsGeneralMapping( <map> )
#C  IsSPGeneralMapping( <map> )
#C  IsNonSPGeneralMapping( <map> )
##
##  What we want to express is that 'IsGeneralMapping' is the disjoint union
##  of 'IsSPGeneralMapping' and 'IsNonSPGeneralMapping'.
##
IsGeneralMapping := NewCategory( "IsGeneralMapping",
    IsDomain and IsTuplesCollection and IsMultiplicativeElement );

IsSPGeneralMapping := NewCategory( "IsSPGeneralMapping",
    IsDomain and IsTuplesCollection and IsMultiplicativeElement );

IsNonSPGeneralMapping := NewCategory( "IsNonSPGeneralMapping",
    IsDomain and IsTuplesCollection and IsMultiplicativeElement );

InstallTrueMethod( IsGeneralMapping, IsSPGeneralMapping );
InstallTrueMethod( IsGeneralMapping, IsNonSPGeneralMapping );


#############################################################################
##
#C  IsGeneralMappingCollection( <obj> )
##
IsGeneralMappingCollection := CategoryCollections(
    "IsGeneralMappingCollection", IsGeneralMapping );


#############################################################################
##
#P  IsTotal( <map> )  . . . . . . . . test whether a general mapping is total
##
##  is 'true' if each element in the source $S$ of the general mapping <map>
##  has images, i.e.,
##  $s^{<map>} \not= \emptyset$ for all $s\in S$,
##  and 'false' otherwise.
##
IsTotal := NewProperty( "IsTotal", IsGeneralMapping );
SetIsTotal := Setter( IsTotal );
HasIsTotal := Tester( IsTotal );


#############################################################################
##
#P  IsSingleValued( <map> ) . test whether a general mapping is single-valued
##
##  is 'true' if each element in the source $S$ of the general mapping <map>
##  has at most one image, i.e.,
##  $|s^{<map>}| \leq 1$ for all $s\in S$,
##  and 'false' otherwise.
##
##  Equivalently, 'IsSingleValued( <map> )' is 'true' if and only if
##  the preimages of different elements in $R$ are disjoint.
##
IsSingleValued := NewProperty( "IsSingleValued", IsGeneralMapping );
SetIsSingleValued := Setter( IsSingleValued );
HasIsSingleValued := Tester( IsSingleValued );


#############################################################################
##
#P  IsMapping( <map> )
##
##  A mapping <map> is a general mapping that assigns to each element 'elm'
##  of its source a unique element 'Image( <map>, <elm> )' of its range.
##
IsMapping := IsGeneralMapping and IsTotal and IsSingleValued;


#############################################################################
##
#P  IsInjective( <map> )  . . . . . .  test if a general mapping is injective
##
##  is 'true' if the images of different elements in the source $S$ of the
##  general mapping <map> are disjoint, i.e.,
##  $x^{<map>} \cap y^{<map>} = \emptyset$ for $x\not= y\in S$,
##  and 'false' otherwise.
##
##  Equivalently, 'IsInjective( <map> )' is 'true' if and only if each
##  element in the range of <map> has at most one preimage in $S$.
##
IsInjective := NewProperty( "IsInjective", IsGeneralMapping );
SetIsInjective := Setter( IsInjective );
HasIsInjective := Tester( IsInjective );


#############################################################################
##
#P  IsSurjective( <map> ) . . . . . . test if a general mapping is surjective
##
##  is 'true' if each element in the range $R$ of the general mapping <map>
##  has preimages in the source $S$ of <map>, i.e.,
##  $\{ s\in S; x\in s^{<map>} \} \not= \emptyset$ for all $x\in R$,
##  and 'false' otherwise.
##
IsSurjective := NewProperty( "IsSurjective", IsGeneralMapping );
SetIsSurjective := Setter( IsSurjective );
HasIsSurjective := Tester( IsSurjective );


#############################################################################
##
#P  IsBijective( <map> )  . . . . . .  test if a general mapping is bijective
##
IsBijective := IsSingleValued and IsTotal and IsInjective and IsSurjective;
SetIsBijective := Setter( IsBijective );
HasIsBijective := Tester( IsBijective );


#############################################################################
##
#A  Range( <map> )  . . . . . . . . . . . . . . .  range of a general mapping
##
Range := NewAttribute( "Range", IsGeneralMapping );
SetRange := Setter( Range );
HasRange := Tester( Range );


#############################################################################
##
#A  Source( <map> ) . . . . . . . . . . . . . . . source of a general mapping
##
Source := NewAttribute( "Source", IsGeneralMapping );
SetSource := Setter( Source );
HasSource := Tester( Source );


#############################################################################
##
#F  GeneralMappingsFamily( <sourcefam>, <rangefam> )
##
##  All general mappings with same source family <FS> and same range family
##  <FR> lie in the family 'GeneralMappingsFamily( <FS>, <FR> )'.
##
##  'GeneralMappingsFamily' is just a shorthand for a call to 'TuplesFamily'.
##
GeneralMappingsFamily := NewOperationArgs( "GeneralMappingsFamily" );


#############################################################################
##
#F  KindOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
##  is the kind of mappings with 'IsDefaultGeneralMappingRep' with source
##  <source> and range <range> and additional categories <filter>.
##
KindOfDefaultGeneralMapping := NewOperationArgs(
    "KindOfDefaultGeneralMapping" );


#############################################################################
##
#A  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
IdentityMapping := NewAttribute( "IdentityMapping", IsCollection );
SetIdentityMapping := Setter( IdentityMapping );
HasIdentityMapping := Tester( IdentityMapping );


#############################################################################
##
#A  InverseGeneralMapping( <map> )
##
##  Note that the inverse of a mapping <map> is in general only a general
##  mapping.
##  Only if <map> is bijective its inverse will be a mapping.
##
InverseGeneralMapping := NewAttribute( "InverseGeneralMapping",
    IsGeneralMapping );
SetInverseGeneralMapping := Setter( InverseGeneralMapping );
HasInverseGeneralMapping := Tester( InverseGeneralMapping );


#############################################################################
##
#A  ImagesSource( <map> )
##
##  'ImagesSource' delegates to 'ImagesSet'.
##
ImagesSource := NewAttribute( "ImagesSource", IsGeneralMapping );
SetImagesSource := Setter( ImagesSource );
HasImagesSource := Tester( ImagesSource );


#############################################################################
##
#A  PreImagesRange( <map> )
##
##  'PreImagesRange' delegates to 'PreImagesSet'.
##
PreImagesRange := NewAttribute( "PreImagesRange", IsGeneralMapping );
SetPreImagesRange := Setter( PreImagesRange );
HasPreImagesRange := Tester( PreImagesRange );


#############################################################################
##
#O  ImagesElm( <map>, <elm> ) . . . all images of an elm under a gen. mapping
##
##  If <elm> is not in the soucre of <map>, 'fail' is returned.
##
ImagesElm := NewOperation( "ImagesElm", [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesRepresentative(<map>,<elm>) . one image of elm under a gen. mapping
##
##  If <elm> is not in the soucre of <map>, or if <elm> has no images under
##  <map>, 'fail' is returned.
##
ImagesRepresentative := NewOperation( "ImagesRepresentative",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesSet( <map>, <elms> )
##
##  is the set of images of the collection <elms>
##  under the general mapping <map>.
##
##  If <elms> is not a subset of the source of <map>, 'fail' is returned.
##
ImagesSet := NewOperation( "ImagesSet", [ IsGeneralMapping, IsCollection ] );


#############################################################################
##
#O  ImageElm( <map>, <elm> )  . . . .  unique image of an elm under a mapping
##
##  'ImageElm' expects <map> to be total and single-valued.
##
ImageElm := NewOperation( "ImageElm", [ IsMapping, IsObject ] );


#############################################################################
##
#F  Image( <map>, <elm> ) . . . . . . . . image of an element under a mapping
#F  Image( <map> )  . . . . . . . . . . . . . . images of the source of <map>
##
#T  allow Image( <map>, <coll> ) ?
##
Image := NewOperationArgs( "Image" );


#############################################################################
##
#F  Images( <map>, <elm> )  . .  images of an element under a general mapping
##
Images := NewOperationArgs( "Images" );


#############################################################################
##
#O  PreImagesElm( <map>, <elm> )  . all preimages of elm under a gen. mapping
##
##  If <elm> is not in the range of <map>, 'fail' is returned.
##
PreImagesElm := NewOperation( "PreImagesElm",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImageElm( <map>, <elm> )
##
PreImageElm := NewOperation( "PreImageElm",
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ] );


#############################################################################
##
#O  PreImagesRepresentative( <map>, <img> ) . . .  one preimage of an element
#O                                                       under a gen. mapping
##
##  If <elm> is not in the range of <map>, or if <elm> has no preimages under
##  <map>, 'fail' is returned.
##
PreImagesRepresentative := NewOperation( "PreImagesRepresentative",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImagesSet( <map>, <elms> )
##
##  is the set of preimages of the collection <elms>
##  under the general mapping <map>.
##
##  If <elms> is not a subset of the range of <map>, 'fail' is returned.
##
PreImagesSet := NewOperation( "PreImagesSet",
    [ IsGeneralMapping, IsCollection ] );


#############################################################################
##
#F  PreImage(<bij>[,<img>]) . . . .  preimage of an element under a bijection
##
PreImage := NewOperationArgs( "PreImage" );


#############################################################################
##
#F  PreImages(<map>,<img>)  . . . . . preimages of an element under a mapping
##
PreImages := NewOperationArgs( "PreImages" );


#############################################################################
##
#O  CompositionMapping2(<map2>,<map1>)  . . . composition of general mappings
##
##  'CompositionMapping2' returns the composition of <map2> and <map1>,
##  this is the general mapping that maps an element first under <map1>,
##  and then maps the images under <map2>.
##
##  (Note the reverse ordering of arguments in the composition via '\*'.
##
CompositionMapping2 := NewOperation( "CompositionMapping2",
    [ IsGeneralMapping, IsGeneralMapping ] );


#############################################################################
##
#F  CompositionMapping(<map1>,<map2>, ... ) . . . . . composition of mappings
##
##  'CompositionMapping' allows to compose arbitrarily many mappings,
##  and delegates each step to 'CompositionMapping2'.
##
CompositionMapping := NewOperationArgs( "CompositionMapping" );


#############################################################################
##
#O  ZeroMapping( <S>, <R> ) . . . . . . . . . .  zero mapping from <S> to <R>
##
##  A zero mapping is a total general mapping that maps each element of its
##  source to the zero element of its range.
##
##  (Each mapping with empty source is a zero mapping.)
##
ZeroMapping := NewOperation( "ZeroMapping", [ IsCollection, IsCollection ] );


#############################################################################
##
#O  Embedding( <S>, <T> ) . . . . . . .  embedding of one domain into another
#O  Embedding( <S>, <T>, <i> )
##
Embedding := NewOperation( "Embedding", [ IsDomain, IsDomain ] );


#############################################################################
##
#O  Projection( <S>, <T> )  . . . . . . projection of one domain onto another
#O  Projection( <S>, <T>, <i> )
##
Projection := NewOperation( "Projection", [ IsDomain, IsDomain ] );


#############################################################################
##
#F  GeneralMappingByElements( <S>, <R>, <elms> )
##
##  is the general mapping with source <S> and range <R>,
##  and with elements in the list <elms> of tuples.
##
GeneralMappingByElements := NewOperationArgs( "GeneralMappingByElements" );


#############################################################################
##
#M  IsBijective . . . . . . . . . . . . . . . . . . . .  for identity mapping
#M  IsMultiplicativeElementWithInverse  . . . . . . . .  for identity mapping
##
InstallTrueMethod( IsBijective, IsGeneralMapping and IsOne );
InstallTrueMethod( IsMultiplicativeElementWithInverse,
    IsGeneralMapping and IsOne );


#############################################################################
##
#M  IsSingleValued  . . . . . . . . . . . . . . . . . . . .  for zero mapping
#M  IsTotal . . . . . . . . . . . . . . . . . . . . . . . .  for zero mapping
##
InstallTrueMethod( IsSingleValued, IsGeneralMapping and IsZero );
InstallTrueMethod( IsTotal, IsGeneralMapping and IsZero );


#############################################################################
##
#E  mapping.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



