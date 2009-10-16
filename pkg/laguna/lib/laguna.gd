#############################################################################
##  
#W  laguna.gd                The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  @(#)$Id: laguna.gd,v 1.21 2009/09/08 14:24:48 alexk Exp $
##
#############################################################################



#############################################################################
##
##  LAGInfo
##  
##  We declare new Info class for LAGUNA algorithms. 
##  It has 4 levels - 0, 1 (default), 2 and 3
##  To change Info level to k, use command SetInfoLevel(LAGInfo, k)
DeclareInfoClass("LAGInfo");



#############################################################################
##
##  SOME CLASSES OF GROUP RINGS AND THEIR GENERAL ATTRIBUTES
##
#############################################################################


#############################################################################
##
#P  IsGroupAlgebra( <R> )
##  
##  A group ring over the field is called group algebra. This property
##  will be determined automatically for every group ring, created by
##  the function `GroupRing'
DeclareProperty("IsGroupAlgebra", IsGroupRing);


#############################################################################
##
#P  IsFModularGroupAlgebra( <R> )
##  
##  A group algebra $FG$ over the field $F$ of characteristic $p$ is called
##  modular, if $p$ devides the order of some element of $G$. This property
##  will be determined automatically for every group ring, created by
##  the function `GroupRing'
DeclareProperty("IsFModularGroupAlgebra", IsGroupAlgebra);


#############################################################################
##
#P  IsPModularGroupAlgebra( <R> )
##  
##  We define separate property for modular group algebras of finite p-groups.
##  This property will be determined automatically for every group ring, 
##  created by the function `GroupRing'
DeclareProperty("IsPModularGroupAlgebra", IsFModularGroupAlgebra);


#############################################################################
##
#A  UnderlyingGroup( <R> )
##  
##  This attribute returns the result of the function `UnderlyingMagma' and
##  for convenience was defined for group rings mainly for teaching purposes
DeclareAttribute("UnderlyingGroup", IsGroupRing);


#############################################################################
##
#A  UnderlyingRing( <R> )
##  
##  This attribute returns the result of the function `LeftActingDomain' and
##  for convenience was defined for group rings mainly for teaching purposes
DeclareAttribute("UnderlyingRing",  IsGroupRing);


#############################################################################
##
#A  UnderlyingField( <R> )
##  
##  This attribute returns the result of the function `LeftActingDomain' and
##  for convenience was defined for group algebras mainly for teaching purposes
DeclareAttribute("UnderlyingField", IsGroupAlgebra);



#############################################################################
##
##  GENERAL PROPERTIES AND ATTRIBUTES OF GROUP RING ELEMENTS
##
#############################################################################


#############################################################################
##
#A  Support( <x> )
##  
##  The support of a non-zero element of a group ring $ x = \sum \alpha_g g $ 
##  is a set of elements $g \in G$ for which $\alpha_g$ in not zero.
##  Note that for zero element this function returns an empty list
DeclareAttribute("Support", 
                  IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  CoefficientsBySupport( <x> )
##  
##  List of coefficients for elements of Support(x) 
DeclareAttribute("CoefficientsBySupport", 
                  IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  TraceOfMagmaRingElement( <x> )
##  
##  The trace of an element $ x = \sum \alpha_g g $ is $\alpha_1$, i.e.
##  the coefficient of the identity element of a group $G$. 
##  Note that for zero element this function returns zero
DeclareAttribute("TraceOfMagmaRingElement", 
                  IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  Length( <x> )
##  
##  Length of an element of a group ring is the number of elements in its
##  support
DeclareAttribute("Length", 
                  IsElementOfMagmaRingModuloRelations and
		  IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  Augmentation( <x> )
##  
##  Augmentation of a group ring element $ x = \sum \alpha_g g $ is the sum 
##  of coefficients $ \sum \alpha_g $
DeclareAttribute("Augmentation", 
                  IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep );


#############################################################################
##
#O  PartialAugmentations( <KG>, <x> )
##  
##  Returns a list of two lists, the first being partial augmentations of x
##  and the second - representatives of corresponding conjugacy classes
DeclareOperation("PartialAugmentations", 
                 [IsGroupRing, 
                  IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep ]);


#############################################################################
##
#O  Involution( <x> )
##  
DeclareOperation("Involution", 
                 [IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep, IsMapping, IsMapping ]);


#############################################################################
##
#A  IsSymmetric( <x> )
##  
##  An element of a group ring is called symmetric if it is fixed under the 
##  classical involution
DeclareAttribute("IsSymmetric", 
                  IsElementOfMagmaRingModuloRelations and
		  IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  IsUnitary( <x> )
##  
##  An unit of a group ring is called unitary if x^-1 = Involution(x) * eps,
##  where eps is an invertible element from an underlying ring
DeclareAttribute("IsUnitary", 
                  IsElementOfMagmaRingModuloRelations and
		  IsMagmaRingObjDefaultRep );



#############################################################################
##
##  AUGMENTATION IDEAL AND GROUPS OF UNITS OF GROUP RINGS
##
#############################################################################


#############################################################################
##
#O  LeftIdealBySubgroup(     <KG>, <H> )
#O  RightIdealBySubgroup(    <KG>, <H> )
#O  TwoSidedIdealBySubgroup( <KG>, <H> )
#O  IdealBySubgroup(         <KG>, <H> )
##  
DeclareOperation( "LeftIdealBySubgroup" ,    [ IsGroupRing, IsGroup ] );
DeclareOperation( "RightIdealBySubgroup",    [ IsGroupRing, IsGroup ] );
DeclareOperation( "TwoSidedIdealBySubgroup", [ IsGroupRing, IsGroup ] );
DeclareSynonym(   "IdealBySubgroup",         TwoSidedIdealBySubgroup  );


#############################################################################
##
#A  WeightedBasis( <KG> )
##  
##  KG must be a modular group algebra. The weighted basis is a basis of the 
##  fundamental ideal such that each power of the fundamental ideal is 
##  spanned by a subset of the basis. Note that this function actually 
##  constructs a basis for the *fundamental ideal* and not for KG.
##  Returns a record whose basis entry is the basis and the weights entry
##  is a list of corresponding weights of basis elements with respect to     
##  the fundamental ideal filtration.
##  This function uses the Jennings basis of the underlying group.    
DeclareAttribute("WeightedBasis", IsPModularGroupAlgebra);


#############################################################################
##
#A  AugmentationIdealPowerSeries( <KG> )
##  
##  KG is a modular group algebra.    
##  Returns a list whose elements are the terms of the augmentation ideal    
##  filtration of I. That is AugmentationIdealPowerSeries(KG)[k] = I^k,
##  where I is the augmentation ideal of KG.
DeclareAttribute("AugmentationIdealPowerSeries", IsPModularGroupAlgebra);


#############################################################################
##
#A  AugmentationIdealNilpotencyIndex( <R> )
##  
DeclareAttribute("AugmentationIdealNilpotencyIndex", IsPModularGroupAlgebra);


#############################################################################
##
#A  AugmentationIdealOfDerivedSubgroupNilpotencyIndex( <R> )
##  
DeclareAttribute("AugmentationIdealOfDerivedSubgroupNilpotencyIndex", 
                  IsPModularGroupAlgebra);


#############################################################################
##
#P  IsGroupOfUnitsOfMagmaRing( <U> )
##  
DeclareProperty("IsGroupOfUnitsOfMagmaRing", IsGroup);


#############################################################################
##
#P  IsUnitGroupOfGroupRing( <U> )
##  
DeclareProperty("IsUnitGroupOfGroupRing", IsGroupOfUnitsOfMagmaRing);


#############################################################################
##
#P  IsNormalizedUnitGroupOfGroupRing( <U> )
##  
DeclareProperty("IsNormalizedUnitGroupOfGroupRing", IsGroupOfUnitsOfMagmaRing);


#############################################################################
##
#A  UnderlyingGroupRing( <U> )
##  
DeclareAttribute("UnderlyingGroupRing", IsGroupOfUnitsOfMagmaRing);


#############################################################################
##
#O  NormalizedUnitCF( <KG>, <u> )
##  
DeclareOperation( "NormalizedUnitCF", 
                  [ IsPModularGroupAlgebra, 
                    IsElementOfMagmaRingModuloRelations and 
                    IsMagmaRingObjDefaultRep] );

					  
#############################################################################
##
#O  NormalizedUnitCFmod( <KG>, <u>, <k> )
##  
DeclareOperation( "NormalizedUnitCFmod", 
                  [ IsPModularGroupAlgebra, 
                    IsElementOfMagmaRingModuloRelations and 
                    IsMagmaRingObjDefaultRep,
                    IsPosInt] );


#############################################################################
##
#A  NormalizedUnitGroup( <KG> )
##  
DeclareAttribute("NormalizedUnitGroup", IsPModularGroupAlgebra);


#############################################################################
##
#A  PcNormalizedUnitGroup( <KG> )
##  
DeclareAttribute("PcNormalizedUnitGroup", IsPModularGroupAlgebra);


#############################################################################
##
#O  AugmentationIdealPowerFactorGroup( <KG>, <n> )
##  
##  Calculates the pc-presentation of the factor group of the normalized unit
##  group V(KG) over 1+I^n, where I is the augmentation ideal of KG 
KeyDependentOperation( "AugmentationIdealPowerFactorGroup", 
                        IsPModularGroupAlgebra, IsPosInt, IsPosInt );


#############################################################################
##
#A  PcUnits( <KG> )
##  
DeclareAttribute("PcUnits", IsPModularGroupAlgebra);


#############################################################################
##
#A  NaturalBijectionToPcNormalizedUnitGroup( <KG> )
##  
DeclareAttribute("NaturalBijectionToPcNormalizedUnitGroup", 
                  IsPModularGroupAlgebra);


#############################################################################
##
#A  NaturalBijectionToNormalizedUnitGroup( <KG> )
##  
DeclareAttribute("NaturalBijectionToNormalizedUnitGroup", 
                  IsPModularGroupAlgebra);


#############################################################################
##
#A  GroupBases( <KG> )
##  
DeclareAttribute("GroupBases", IsPModularGroupAlgebra);


#############################################################################
##
#O  BassCyclicUnit( <ZG>, <g>, <k> )
#O  BassCyclicUnit( <g>, <k> )
##  
##  Let g be an element of order n of the group G, and 1 < k < n be such that
##  k and n are coprime, then  k^Phi(n) is congruent to 1 modulo n. The unit 
##  b(g,k) = ( \sum_{j=0}^{k-1} g^j )^Phi(n) + ( (1-k^Phi(n))/n ) * Hat(g),
##  where Hat(g) = g + g^2 + ... + g^n, is called a Bass cyclic unit of 
##  the integral group ring ZG.
##  When G is a finite nilpotent group, the group generated by the
##  Bass cyclic units contain a subgroup of finite index in the centre
##  of U(ZG) [E. Jespers, M.M. Parmenter and S.K. Sehgal, Central Units 
##  Of Integral Group Rings Of Nilpotent Groups.
##  Proc. Amer. Math. Soc. 124 (1996), no. 4, 1007--1012].
##
DeclareOperation( "BassCyclicUnit",
       [ IsGroupRing, IsObject, IsPosInt ] );


#############################################################################
##
#O  BicyclicUnitOfType1( <KG>, <a>, <g> )
#O  BicyclicUnitOfType2( <KG>, <a>, <g> )
##  
## For elements a and g of the underlying group of a group ring KG,
## returns the bicyclic unit u_(a,g) of the appropriate type.
## If ord a = n, then the bicycle unit of the 1st type is defined as
##
##       u_{a,g} = 1 + (a-1) * g * ( 1 + a + a^2 + ... +a^{n-1} )
##
## and the bicycle unit of the 2nd type is defined as
##
##       v_{a,g} = 1 + ( 1 + a + a^2 + ... +a^{n-1} ) * g * (a-1) 
## 
## u_{a,g} and v_{a,g} may coincide for some a and g, but in general
## this does not hold.
##
DeclareOperation( "BicyclicUnitOfType1",
       [ IsGroupRing, IsObject, IsObject ] );

DeclareOperation( "BicyclicUnitOfType2",
       [ IsGroupRing, IsObject, IsObject ] );


#############################################################################
##
#A  BicyclicUnitGroup( <V(KG)> )
##  
##  KG is a modular group algebra and V(KG) is its normalized unit group.
##  Returns the subgroup of V(KG) generated by all bicyclic units u_{g,h}
##  and v_{g,h}, where g and h run over the elements of the underlying
##  p-group, and h do not belongs to the normalizer of <g> in G.
DeclareAttribute("BicyclicUnitGroup", IsNormalizedUnitGroupOfGroupRing);


#############################################################################
##
#A  UnitarySubgroup( <V(KG)> )
##  
DeclareAttribute("UnitarySubgroup", IsNormalizedUnitGroupOfGroupRing);


#############################################################################
##
##  LIE PROPERTIES OF GROUP ALGEBRAS
##
#############################################################################

                   
#############################################################################
##
#C  IsLieAlgebraByAssociativeAlgebra( <L> )
##  
##  This category signifies that the Lie algebra is constructed as an
##  associated Lie algebra of an associative algebra. (That knowledge
##  cannot be obtained later on.)
DeclareCategory( "IsLieAlgebraByAssociativeAlgebra", IsLieAlgebra );


#############################################################################
##
#A  UnderlyingAssociativeAlgebra( <L> )
##  
##  If a Lie algebra is constructed from an associative algebra, it remembers
##  this underlying associative algebra as one of its attributes. 
DeclareAttribute( "UnderlyingAssociativeAlgebra", 
                   IsLieAlgebraByAssociativeAlgebra );


#############################################################################
##
#P  IsLieAlgebraOfGroupRing( <L> )
##  
##  If a Lie algebra is constructed from an associative algebra which happens
##  to be in fact a group ring, it has many nice properties that
##  can be used for faster algorithms, so this information is stored as a
##  property.
DeclareProperty( "IsLieAlgebraOfGroupRing",
                  IsLieAlgebraByAssociativeAlgebra);


#############################################################################
##
#P  IsBasisOfLieAlgebraOfGroupRing( <B> )
##  
##  A basis has this property if the basis vectors are exactly the images
##  of group elements (in sorted oreder).
##  A basis can be told that it has this above property. (This is important
##  for the speed of the calculation of the structure constants table.)
DeclareProperty( "IsBasisOfLieAlgebraOfGroupRing", IsBasis);


#############################################################################
##
#A  UnderlyingGroup( <L> )
##  
##  The underlying group of a Lie algebra <L> which is constructed from a
##  group ring is defined to be the underlying magma of this group ring. 
##  *Remark:* The underlying field may be accessed by the command
##  `LeftActingDomain( <L> )'.
DeclareAttribute( "UnderlyingGroup", IsLieAlgebraOfGroupRing);


#############################################################################
##
#A  NaturalBijectionToLieAlgebra( <A> )
##  
##  The natural linear bijection between the (isomorphic, but not equal,
##  see introduction) underlying vector
##  spaces of an associative algebra $A$ and its associated Lie algebra is
##  stored as an attribute of $A$.
##  (Note that this is a vector space isomorphism between two algebras,
##  but not an algebra homomorphism in general.)
DeclareAttribute( "NaturalBijectionToLieAlgebra",
                   IsAlgebra and IsAssociative);


#############################################################################
##
#A  NaturalBijectionToAssociativeAlgebra( <L> )
##  
##  This is the inverse of the linear bijection mentioned above, stored as
##  an attribute of the Lie algebra. 
DeclareAttribute( "NaturalBijectionToAssociativeAlgebra",
                   IsLieAlgebraByAssociativeAlgebra);


#############################################################################
##
#O  Embedding( <U>, <L> )
##  
##  Let <U> be a submagma of a group $G$, $A := FG$ be the group ring of $G$
##  over some field $F$, and let <L> be the associated Lie algebra of $A$.
##  Then `Embedding( <U>, <L> )' returns the obvious mapping $<U> \to <L>$
##  (as the composition of the mappings `Embedding( <U>, <A> )' and
##  `NaturalBijectionToLieAlgebra( <A> )'~).
##  DeclareOperation( "Embedding", [IsGroup, IsLieAlgebraOfGroupRing]);


#############################################################################
##
#A  AugmentationHomomorphism( <A> )
##  
##  Nomen est omen for this attribute of the group ring $<A> := FG$ of a
##  group $G$ over some field $F$.
DeclareAttribute( "AugmentationHomomorphism",
                             IsAlgebraWithOne and IsGroupRing );


#############################################################################
##
#P  IsLieMetabelian( <L> )
##  
##  A Lie algebra is called (Lie) metabelian, if its (Lie) derived subalgebra
##  is (Lie) abelian, i.e. its second (Lie) derived subalgebra is trivial.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
DeclareProperty( "IsLieMetabelian",
                             IsLieAlgebra);


#############################################################################
##
#P  IsLieCentreByMetabelian( <L> )
##  
##  A Lie algebra is called (Lie) centre-by-metabelian,
##  if its second (Lie) derived
##  subalgebra is contained in the (Lie) centre of the Lie algebra.
##  
##  Note that he prefix `Lie' is consistently used to
##  distinguish properties of Lie algebras from the analogous properties
##  of groups (or of general algebras). Not using this prefix may
##  result in error messages, or even in wrong results without warning.
DeclareProperty( "IsLieCentreByMetabelian",
                             IsLieAlgebra);


#############################################################################
##
#A  LieUpperNilpotencyIndex( <KG> )
##  
DeclareAttribute("LieUpperNilpotencyIndex", IsPModularGroupAlgebra);


#############################################################################
##
#A  LieLowerNilpotencyIndex( <KG> )
##  
DeclareAttribute("LieLowerNilpotencyIndex", IsPModularGroupAlgebra);


#############################################################################
##
#A  LieDerivedLength( <KG> )
##  
DeclareAttribute("LieDerivedLength", IsLieAlgebra);


#############################################################################
##
## SOME GROUP-THEORETICAL ATTRIBUTES
##
#############################################################################


#############################################################################
##
#A  SubgroupsOfIndexTwo( <G> )
##  
##  A list is returned here. (The subgroups of index two in the group <G>
##  are important for the Lie structure of the group algebra $F<G>$, in case
##  that the underlying field $F$ has characteristic 2.)
DeclareAttribute( "SubgroupsOfIndexTwo", IsGroup);


#############################################################################
##
#A  DihedralDepth( <G> )
##  
##  The dihedral depth of a finite 2-group $G$ is equal to $d$, if the maximal
##  size of the dihedral subgroup contained in a group $G$ is $2^(d+1)$
DeclareAttribute( "DihedralDepth", IsGroup);


#############################################################################
##
#A  DimensionBasis( <G> )
##  
DeclareAttribute("DimensionBasis", IsGroup);


#############################################################################
##
#A  LieDimensionSubgroups( <G> )
##  
DeclareAttribute("LieDimensionSubgroups", IsGroup);


#############################################################################
##
#A  LieUpperCodimensionSeries( <KG> )
#A  LieUpperCodimensionSeries( <G> )
##  
DeclareAttribute( "LieUpperCodimensionSeries", IsGroupRing);
DeclareAttribute( "LieUpperCodimensionSeries", IsGroup);


#############################################################################
##
#E
##