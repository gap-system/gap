#############################################################################
##
#W  mapping.gd                  GAP library                  Martin Schoenert
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for general mappings.
##
Revision.mapping_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsGeneralMapping( <map> )
##
IsGeneralMapping := NewCategory( "IsGeneralMapping",
    IsMultiplicativeElement );


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
#V  FAMILIES_MAPPINGS
#V  FAMILIES_RANGE
#V  FAMILIES_SOURCE
##
##  Families of general mappings are stored in 'FAMILIES_MAPPINGS',
##  the corresponding families of range elements and source elements in
##  'FAMILIES_RANGE' resp. 'FAMILIES_SOURCE'.
##
FAMILIES_MAPPINGS := [];
FAMILIES_RANGE    := [];
FAMILIES_SOURCE   := [];


#############################################################################
##
#A  FamilyRange( <Fam> )
#A  FamilySource( <Fam> )
##
##  The range family of a general mapping is the elements family of its
##  range.
##  The source family of a general mapping is the elements family of its
##  source.
##
FamilyRange := NewAttribute( "FamilyRange", IsFamily );
SetFamilyRange := Setter( FamilyRange );
HasFamilyRange := Tester( FamilyRange );

FamilySource := NewAttribute( "FamilySource", IsFamily );
SetFamilySource := Setter( FamilySource );
HasFamilySource := Tester( FamilySource );


#############################################################################
##
#O  GeneralMappingsFamily( <sourcefam>, <rangefam> )
##
##  All general mappings with same source family <FS> and same range family
##  <FR> form a family, namely 'GeneralMappingsFamily( <FS>, <FR> )'.
##
GeneralMappingsFamily := NewOperation( "GeneralMappingsFamily",
    [ IsFamily, IsFamily ] );


#############################################################################
##
#O  KindOfDefaultGeneralMapping( <source>, <range>, <filter> )
##
##  is the kind of mappings with 'IsDefaultGeneralMappingRep' with source
##  <source> and range <range> and additional categories <filter>.
##
KindOfDefaultGeneralMapping := NewOperationArgs(
    "KindOfDefaultGeneralMapping" );
#T It is not necessary to notify this function, it will be used only in
#T implementation files, or?
#T (Think of the chosen representation!)


#############################################################################
##
#C  IsGeneralMappingCollection( <obj> )
##
IsGeneralMappingCollection := CategoryCollections(
    "IsGeneralMappingCollection", IsGeneralMapping );


#############################################################################
##
#C  IsInverseMapping( <map> )
##
##  Note that if a mapping knows its inverse mapping then also the inverse
##  mapping knows its inverse mapping.
##  So we need this flag to avoid infinite recursion when a question is
##  delegated to the inverse of a mapping.
##
IsInverseMapping := NewCategory(
    "IsInverseMapping",
    IsGeneralMapping );


#############################################################################
##
#A  IdentityMapping( <D> )  . . . . . . . .  identity mapping of a collection
##
IdentityMapping := NewAttribute( "IdentityMapping", IsCollection );
SetIdentityMapping := Setter( IdentityMapping );
HasIdentityMapping := Tester( IdentityMapping );
#T file 'colls.g'?


#############################################################################
##
#A  InverseGeneralMapping( <map> )
##
##  Note that the inverse mapping 'Inverse( <map> )' of a mapping <map>
##  will be in general only a general mapping.
##  Only if <map> is bijective its inverse will be a mapping.
##
##  'InverseGeneralMapping' avoids the check for bijection, and returns
##  only a general mapping.
##
InverseGeneralMapping := NewAttribute( "InverseGeneralMapping",
    IsGeneralMapping );
SetInverseGeneralMapping := Setter( InverseGeneralMapping );
HasInverseGeneralMapping := Tester( InverseGeneralMapping );


#############################################################################
##
#A  ImagesSource( <map> )
##
ImagesSource := NewAttribute( "ImagesSource", IsGeneralMapping );
SetImagesSource := Setter( ImagesSource );
HasImagesSource := Tester( ImagesSource );


#############################################################################
##
#A  PreImagesRange( <map> )
##
PreImagesRange := NewAttribute( "PreImagesRange", IsGeneralMapping );
SetPreImagesRange := Setter( PreImagesRange );
HasPreImagesRange := Tester( PreImagesRange );


#############################################################################
##
#A  AsMapping( <map> )
##
##  is the general mapping <map> viewed as mapping, if <map> is total and
##  single-valued.
##
AsMapping := NewAttribute( "AsMapping", IsGeneralMapping );


#############################################################################
##
#O  ImagesElm( <map>, <elm> ) . . . . .  all images of an elm under a mapping
#O  ImagesRepresentative(<map>,<elm>) .  one image  of an elm under a mapping
##
##  There are generic methods for the latter two functions that use
##  'ImagesElm'; so one needs to implement a method only for 'ImagesElm' when
##  creating a new type of mappings.
##
ImagesElm := NewOperation( "ImagesElm", [ IsGeneralMapping, IsObject ] );

ImagesRepresentative := NewOperation( "ImagesRepresentative",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  ImagesSet( <map>, <elms> )
##
ImagesSet := NewOperation( "ImagesSet", [ IsGeneralMapping, IsCollection ] );


#############################################################################
##
#O  ImageElm( <map>, <elm> )  . . . .  unique image of an elm under a mapping
##
##  'ImageElm' expects <map> to be a bijection.
##
ImageElm := NewOperation( "ImageElm", [ IsMapping, IsObject ] );


#############################################################################
##
#F  Image( <map>, <elm> ) . . . . . . . . image of an element under a mapping
#F  Image( <map> )
##
Image := NewOperationArgs( "Image" );


#############################################################################
##
#F  Images( <map>, <elm> )  . .  images of an element under a general mapping
##
Images := NewOperationArgs( "Images" );


#############################################################################
##
#O  PreImagesElm( <map>, <elm> )
#O  PreImageElm( <map>, <elm> )
#O  PreImagesRepresentative( <map>, <img> ) . . .  one preimage of an element
#O                                                            under a mapping
##
##  There are generic methods for the latter two functions that use
##  'PreImagesElm';
##  so one needs to implement a method only for 'PreImagesElm' when creating
##  a new type of mappings.
##
##  'PreImageElm' expects (and checks) <map> to be a bijection.
##
PreImagesElm := NewOperation( "PreImagesElm",
    [ IsGeneralMapping, IsObject ] );

PreImageElm := NewOperation( "PreImageElm",
    [ IsGeneralMapping and IsInjective and IsSurjective, IsObject ] );

PreImagesRepresentative := NewOperation( "PreImagesRepresentative",
    [ IsGeneralMapping, IsObject ] );


#############################################################################
##
#O  PreImagesSet( <map>, <elms> )
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
#O  CompositionMapping2(<map1>,<map2>)  . . . composition of general mappings
##
CompositionMapping2 := NewOperation( "CompositionMapping2",
    [ IsGeneralMapping, IsGeneralMapping ] );


#############################################################################
##
#F  CompositionMapping(<map1>,<map2>, ... ) . . . . . composition of mappings
##
CompositionMapping := NewOperationArgs( "CompositionMapping" );


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
#O  NaturalHomomorphism( <D>, <F> )
##
##  (should be natural enough to leave it to <D> and its factor structure <F>
##  what kind of homomorphism it is thought of ...)
##
NaturalHomomorphism := NewOperation( "NaturalHomomorphism",
    [ IsDomain, IsDomain ] );


BijectiveMappingByFunctions := NewOperationArgs( "BijectiveMappingByFunctions" );

#############################################################################
##
#E  mapping.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



