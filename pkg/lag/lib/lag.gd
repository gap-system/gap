#############################################################################
##  
#W    lag.gd                 The LAG package                     Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
#1
##  The {\LAG} package contains the declaration of attributes, properties,
##  and operations for associated Lie algebras of
##  associative algebras, in particular group algebras.
##
##  If $A$ is an associative algebra, its associated Lie algebra is the
##  Lie Algebra $L$ which has the same underlying vector space as $A$, and
##  which satisfies $[a,b]=ab-ba$ for all $a,b \in A$.
##  
##  In {\GAP}, however, the bracket notation $[a,b]$ is reserved for lists, so
##  the product in $L$ is denoted by the star `*' -- the same
##  symbol which is also used to
##  denote the associative multiplication in $A$.
##  Therefore, {\GAP} needs to distinguish between the elements in $A$ and the
##  elements in $L$, i.e.\ here the underlying vector spaces are not equal,
##  but only (however canonically) isomorphic.
##  {\GAP} stores the Lie algebra $L$ and the natural linear bijection
##  from $A$ onto $L$ as attributes of the associative algebra $A$.
##  
##  The usual commands that apply to algebras, such as `Dimension',
##  `IsFiniteDimensional', `IsFinite', `Size', `Elements', etc.\ also work for
##  the Lie Algebra, if they work for the underlying associative algebra.
##  Additionally, the standard Lie algebra functions (described
##  in the chapter about Lie algebras) of course also apply to Lie
##  algebras that come from associative algebras.
##  This will not be explained in detail for every single command in
##  this chapter.
##  
##  The main objective of this package, however, is to deal with Lie algebras
##  of group algebras. Some new functions are added, and, for other functions
##  that also apply to abstract Lie algebras, much faster methods are
##  implemented (which was possible due to the special structure of such
##  Lie algebras).
##
##  I would like to point out that many properties of Lie algebras of group
##  algebras carry over to the commutator structure of the unit group.
##  E.g., if the Lie algebra of the group algebra is solvable, then so is its
##  unit group (in odd characteristic --- there are counterexamples in
##  characteristic 2).
##  However, no such functions have been included in the {\LAG} package,
##  due to the fact that unit groups were only ``in the making'' at the time
##  when {\LAG} was programmed. See the survey article \cite{Bov98}
##  %[Adalbert Bovdi, The group of units of a group algebra of 
##  %characteristic p, Publ. Math. Debrecen 52/1-2 (1998), 193-244]
##  for a detailed description of the interplay
##  between the unit group and the Lie algebra of a group algebra. It might be
##  useful for future implementations of fast algorithms for the unit group.
##
##  The {\LAG} package arose as a byproduct of the author's dissertation thesis
##  %[Richard Rossmanith, Centre-by-metabelian group algebras,
##  %Friedrich-Schiller-Universitaet Jena, 1997]
##  \cite{Ros97}. It was ported to {\GAP}~4
##  and brought into standard {\GAP} package format during a visit to 
##  St.~Andrews in September 1998, under the supervision of the {\GAP} team. 
##  I want to thank everybody on the team for their support, in particular
##  Steve Linton, Willem de Graaf, Thomas Breuer, and Alexander Hulpke.
##
##  (Richard Rossmanith)
##


#############################################################################
##
##  LAGInfo
##  
##  We declare new Info class for LAG algorithms. 
##  It has 4 levels - 0 (default), 1, 2 and 3
##  To change Info level to k, use command SetInfoLevel(LAGInfo, k)
DeclareInfoClass("LAGInfo");



#############################################################################
##
## SOME CLASSES OF GROUP RINGS AND THEIR GENERAL ATTRIBUTES
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
## GENERAL PROPERTIES AND ATTRIBUTES OF GROUP RING ELEMENTS
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
                  IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  CoefficientsBySupport( <x> )
##  
##  List of coefficients for elements of Support(x) 
DeclareAttribute("CoefficientsBySupport", 
                  IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  TraceOfMagmaRingElement( <x> )
##  
##  The trace of an element $ x = \sum \alpha_g g $ is $\alpha_1$, i.e.
##  the coefficient of the identity element of a group $G$. 
##  Note that for zero element this function returns zero
DeclareAttribute("TraceOfMagmaRingElement", 
                  IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  Length( <x> )
##  
##  Length of an element of a group ring is the number of elements in its support
DeclareAttribute("Length", 
                  IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  Augmentation( <x> )
##  
##  Augmentation of a group ring element $ x = \sum \alpha_g g $ is the sum 
## of coefficients $ \sum \alpha_g $
DeclareAttribute("Augmentation", 
                  IsElementOfMagmaRingModuloRelations and IsMagmaRingObjDefaultRep );


#############################################################################
##
#A  Involution( <x> )
##  
DeclareOperation("Involution", 
                 [IsElementOfMagmaRingModuloRelations and 
                  IsMagmaRingObjDefaultRep, IsMapping ]);



#############################################################################
##
## AUGMENTATION IDEAL AND GROUPS OF UNITS OF GROUP RINGS
##
#############################################################################


#############################################################################
##
#A  WeightedBasis( <KG> )
##  
## KG must be a modular group algebra. The weighted basis is a basis of the 
## fundamental ideal such that each power of the fundamental ideal is 
## spanned by a subset of the basis. Note that this function actually 
## constructs a basis for the *fundamental ideal* and not for KG.
## Returns a record whose basis entry is the basis and the weights entry
## is a list of corresponding weights of basis elements with respect to     
## the fundamental ideal filtration.
## This function uses the Jennings basis of the underlying group.    
DeclareAttribute("WeightedBasis", IsPModularGroupAlgebra);


#############################################################################
##
#A  AugmentationIdealPowerSeries( <KG> )
##  
## KG is a modular group algebra.    
## Returns a list whose elements are the terms of the augmentation ideal    
## filtration of I. That is AugmentationIdealPowerSeries(KG)[k] = I^k,
## where I is the augmentation ideal of KG.
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
DeclareAttribute("AugmentationIdealOfDerivedSubgroupNilpotencyIndex", IsPModularGroupAlgebra);

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
#A  UnderlyingRing( <U> )
##  
DeclareAttribute("UnderlyingRing", IsGroupOfUnitsOfMagmaRing);

#############################################################################
##
#O  NormalizedUnitCF( <U> )
##  
DeclareOperation( "NormalizedUnitCF", 
                  [ IsPModularGroupAlgebra, 
                    IsElementOfMagmaRingModuloRelations and 
                    IsMagmaRingObjDefaultRep] );

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
#A  PcUnits( <KG> )
##  
DeclareAttribute("PcUnits", IsPModularGroupAlgebra);

#############################################################################
##
#A  NaturalBijectionToPcNormalizedUnitGroup( <KG> )
##  
DeclareAttribute("NaturalBijectionToPcNormalizedUnitGroup", IsPModularGroupAlgebra);

#############################################################################
##
#A  NaturalBijectionToNormalizedUnitGroup( <KG> )
##  
DeclareAttribute("NaturalBijectionToNormalizedUnitGroup", IsPModularGroupAlgebra);


#############################################################################
##
#A  GroupBases( <KG> )
##  
DeclareAttribute("GroupBases", IsPModularGroupAlgebra);



#############################################################################
##
## LIE PROPERTIES OF GROUP ALGEBRAS
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
DeclareProperty( "IsBasisOfLieAlgebraOfGroupRing",
                             IsBasis);


#############################################################################
##
#A  UnderlyingGroup( <L> )
##  
##  The underlying group of a Lie algebra <L> which is constructed from a
##  group ring is defined to be the underlying magma of this group ring. 
##  *Remark:* The underlying field may be accessed by the command
##  `LeftActingDomain( <L> )'.
DeclareAttribute( "UnderlyingGroup",
                             IsLieAlgebraOfGroupRing);


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
##  Let <U> be a submagma of a group $G$, let $A := FG$ be the group ring of $G$
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
#E
##



