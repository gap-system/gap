#############################################################################
##
#W  grp.gd                      GAP library                     .............
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of operations for groups.
##
#W  @(#)$Id$
##
Revision.grp_gd :=
    "@(#)$Id$";


GroupString := function(arg) return "Group"; end;
#T !!!


#############################################################################
##
#V  InfoGroup
##
InfoGroup := NewInfoClass( "InfoGroup" );


#############################################################################
##
#C  IsGroup( <obj> )
##
##  A group is a magma with inverses and associative multiplication.
##
IsGroup := IsMagmaWithInverses and IsAssociative;


#############################################################################
##
#A  GeneratorsOfGroup( <G> )
##
GeneratorsOfGroup := GeneratorsOfMagmaWithInverses;
SetGeneratorsOfGroup := SetGeneratorsOfMagmaWithInverses;
HasGeneratorsOfGroup := HasGeneratorsOfMagmaWithInverses;


#############################################################################
##
#P  IsCyclic( <G> )
##
IsCyclic := NewProperty( "IsCyclic", IsGroup );
SetIsCyclic := Setter( IsCyclic );
HasIsCyclic := Tester( IsCyclic );

InstallSubsetTrueMethod( IsCyclic, IsGroup and IsCyclic, IsGroup );
InstallFactorTrueMethod( IsCyclic, IsGroup and IsCyclic, IsGroup, IsGroup );

InstallTrueMethod( IsCyclic, IsGroup and IsTrivial );

InstallTrueMethod( IsCommutative, IsGroup and IsCyclic );


#############################################################################
##
#P  IsElementaryAbelian( <G> )
##
##  A group <G> is elementary abelian if it is commutative and if there is a
##  prime $p$ such that the order of each element in <G> is divisible by $p$.
##
IsElementaryAbelian := NewProperty( "IsElementaryAbelian", IsGroup );
SetIsElementaryAbelian := Setter( IsElementaryAbelian );
HasIsElementaryAbelian := Tester( IsElementaryAbelian );

InstallSubsetTrueMethod( IsElementaryAbelian,
    IsGroup and IsElementaryAbelian, IsGroup );
InstallFactorTrueMethod( IsElementaryAbelian,
    IsGroup, IsGroup and IsElementaryAbelian, IsGroup );

InstallTrueMethod( IsElementaryAbelian, IsGroup and IsTrivial );


#############################################################################
##
#P  IsFinitelyGeneratedGroup( <G> )
##
IsFinitelyGeneratedGroup := NewProperty( "IsFinitelyGeneratedGroup",
                                         IsGroup );
SetIsFinitelyGeneratedGroup := Setter( IsFinitelyGeneratedGroup );
HasIsFinitelyGeneratedGroup := Tester( IsFinitelyGeneratedGroup );

InstallFactorTrueMethod( IsFinitelyGeneratedGroup,
    IsGroup and IsFinitelyGeneratedGroup, IsGroup, IsGroup );

InstallTrueMethod( IsFinitelyGeneratedGroup, IsGroup and IsTrivial );


#############################################################################
##
#P  IsNilpotentGroup( <G> )
##
IsNilpotentGroup := NewProperty( "IsNilpotentGroup", IsGroup );
SetIsNilpotentGroup := Setter( IsNilpotentGroup );
HasIsNilpotentGroup := Tester( IsNilpotentGroup );

InstallSubsetTrueMethod( IsNilpotentGroup,
    IsGroup and IsNilpotentGroup, IsGroup );
InstallFactorTrueMethod( IsNilpotentGroup,
    IsGroup and IsNilpotentGroup, IsGroup, IsGroup );

InstallTrueMethod( IsNilpotentGroup, IsGroup and IsCommutative );


#############################################################################
##
#P  IsPerfectGroup( <G> )
##
IsPerfectGroup := NewProperty( "IsPerfectGroup", IsGroup );
SetIsPerfectGroup := Setter( IsPerfectGroup );
HasIsPerfectGroup := Tester( IsPerfectGroup );

InstallFactorTrueMethod( IsPerfectGroup,
    IsGroup and IsPerfectGroup, IsGroup, IsGroup );


#############################################################################
##
#P  IsSimpleGroup( <G> )
##
IsSimpleGroup := NewProperty( "IsSimpleGroup", IsGroup );
SetIsSimpleGroup := Setter( IsSimpleGroup );
HasIsSimpleGroup := Tester( IsSimpleGroup );

InstallIsomorphismTrueMethod( IsSimpleGroup,
    IsGroup and IsSimpleGroup, IsGroup );


#############################################################################
##
#P  IsSupersolvableGroup( <G> )
##
IsSupersolvableGroup := NewProperty( "IsSupersolvableGroup", IsGroup );
SetIsSupersolvableGroup := Setter( IsSupersolvableGroup );
HasIsSupersolvableGroup := Tester( IsSupersolvableGroup );

InstallSubsetTrueMethod( IsSupersolvableGroup,
    IsGroup and IsSupersolvableGroup, IsGroup );
InstallFactorTrueMethod( IsSupersolvableGroup,
    IsGroup and IsSupersolvableGroup, IsGroup, IsGroup );

InstallTrueMethod( IsSupersolvableGroup, IsNilpotentGroup );


#############################################################################
##
#P  IsMonomialGroup( <G> )
##
IsMonomialGroup := NewProperty( "IsMonomialGroup", IsGroup );
SetIsMonomialGroup := Setter( IsMonomialGroup );
HasIsMonomialGroup := Tester( IsMonomialGroup );

InstallFactorTrueMethod( IsMonomialGroup,
    IsGroup and IsMonomialGroup, IsGroup, IsGroup );

InstallTrueMethod( IsMonomialGroup, IsSupersolvableGroup and IsFinite );


#############################################################################
##
#P  IsSolvableGroup( <G> )
##
IsSolvableGroup := NewProperty( "IsSolvableGroup", IsGroup );
SetIsSolvableGroup := Setter( IsSolvableGroup );
HasIsSolvableGroup := Tester( IsSolvableGroup );

InstallSubsetTrueMethod( IsSolvableGroup,
    IsGroup and IsSolvableGroup, IsGroup );
InstallFactorTrueMethod( IsSolvableGroup,
    IsGroup and IsSolvableGroup, IsGroup, IsGroup );

InstallTrueMethod( IsSolvableGroup, IsMonomialGroup );
InstallTrueMethod( IsSolvableGroup, IsSupersolvableGroup );


#############################################################################
##
#A  AbelianInvariants( <G> )
##
AbelianInvariants := NewAttribute( "AbelianInvariants", IsGroup );
SetAbelianInvariants := Setter( AbelianInvariants );
HasAbelianInvariants := Tester( AbelianInvariants );


#############################################################################
##
#A  AsGroup( <D> )  . . . . . . . . . . . . . collection <D>, viewed as group
##
AsGroup := NewAttribute( "AsGroup", IsCollection );
SetAsGroup := Setter( AsGroup );
HasAsGroup := Tester( AsGroup );


#############################################################################
##
#A  CharacterDegrees( <G> )
##
##  is a collected list of the degrees of the irreducible characters of
##  the group <G>.
##
CharacterDegrees := NewAttribute( "CharacterDegrees", IsGroup );
SetCharacterDegrees := Setter( CharacterDegrees );
HasCharacterDegrees := Tester( CharacterDegrees );


#############################################################################
##
#A  CharacterTable( <G> )
##
CharacterTable := NewAttribute( "CharacterTable", IsGroup );
SetCharacterTable := Setter( CharacterTable );
HasCharacterTable := Tester( CharacterTable );


#############################################################################
##
#A  CharacterTableHead( <G> )
##
CharacterTableHead := NewAttribute( "CharacterTableHead", IsGroup );
SetCharacterTableHead := Setter( CharacterTableHead );
HasCharacterTableHead := Tester( CharacterTableHead );


#############################################################################
##
#A  ChiefSeries( <G> )
##
ChiefSeries := NewAttribute( "ChiefSeries", IsGroup );
SetChiefSeries := Setter( ChiefSeries );
HasChiefSeries := Tester( ChiefSeries );


#############################################################################
##
#A  CommutatorFactorGroup( <G> )
##
CommutatorFactorGroup := NewAttribute( "CommutatorFactorGroup", IsGroup );
SetCommutatorFactorGroup := Setter( CommutatorFactorGroup );
HasCommutatorFactorGroup := Tester( CommutatorFactorGroup );


#############################################################################
##
#A  CompositionSeries( <G> )
##
CompositionSeries := NewAttribute( "CompositionSeries", IsGroup );
SetCompositionSeries := Setter( CompositionSeries );
HasCompositionSeries := Tester( CompositionSeries );
#T and for module?


#############################################################################
##
#A  ConjugacyClasses( <G> )
##
ConjugacyClasses := NewAttribute( "ConjugacyClasses", IsGroup );
SetConjugacyClasses := Setter( ConjugacyClasses );
HasConjugacyClasses := Tester( ConjugacyClasses );


#############################################################################
##
#A  ConjugacyClassesMaximalSubgroups( <G> )
##
ConjugacyClassesMaximalSubgroups := NewAttribute(
    "ConjugacyClassesMaximalSubgroups", IsGroup );
SetConjugacyClassesMaximalSubgroups := Setter(
    ConjugacyClassesMaximalSubgroups );
HasConjugacyClassesMaximalSubgroups := Tester(
    ConjugacyClassesMaximalSubgroups );


#############################################################################
##
#A  ConjugacyClassesPerfectSubgroups( <G> )
##
ConjugacyClassesPerfectSubgroups := NewAttribute(
    "ConjugacyClassesPerfectSubgroups", IsGroup );
SetConjugacyClassesPerfectSubgroups := Setter(
    ConjugacyClassesPerfectSubgroups );
HasConjugacyClassesPerfectSubgroups := Tester(
    ConjugacyClassesPerfectSubgroups );


#############################################################################
##
#A  ConjugacyClassesSubgroups( <G> )
##
ConjugacyClassesSubgroups := NewAttribute( "ConjugacyClassesSubgroups",
    IsGroup );
SetConjugacyClassesSubgroups := Setter( ConjugacyClassesSubgroups );
HasConjugacyClassesSubgroups := Tester( ConjugacyClassesSubgroups );


#############################################################################
##
#A  DerivedLength( <G> )
##
DerivedLength := NewAttribute( "DerivedLength", IsGroup );
SetDerivedLength := Setter( DerivedLength );
HasDerivedLength := Tester( DerivedLength );


#############################################################################
##
#A  DerivedSeriesOfGroup( <G> )
##
DerivedSeriesOfGroup := NewAttribute( "DerivedSeriesOfGroup", IsGroup );
SetDerivedSeriesOfGroup := Setter( DerivedSeriesOfGroup );
HasDerivedSeriesOfGroup := Tester( DerivedSeriesOfGroup );


#############################################################################
##
#A  DerivedSubgroup( <G> )
##
DerivedSubgroup := NewAttribute( "DerivedSubgroup", IsGroup );
SetDerivedSubgroup := Setter( DerivedSubgroup );
HasDerivedSubgroup := Tester( DerivedSubgroup );


#############################################################################
##
#A  DimensionsLoewyFactors( <G> )
##
DimensionsLoewyFactors := NewAttribute( "DimensionsLoewyFactors", IsGroup );
SetDimensionsLoewyFactors := Setter( DimensionsLoewyFactors );
HasDimensionsLoewyFactors := Tester( DimensionsLoewyFactors );


#############################################################################
##
#A  ElementaryAbelianSeries( <G> )
##
ElementaryAbelianSeries := NewAttribute( "ElementaryAbelianSeries", IsGroup );
SetElementaryAbelianSeries := Setter( ElementaryAbelianSeries );
HasElementaryAbelianSeries := Tester( ElementaryAbelianSeries );


#############################################################################
##
#A  Exponent( <G> )
##
Exponent := NewAttribute( "Exponent", IsGroup );
SetExponent := Setter( Exponent );
HasExponent := Tester( Exponent );


#############################################################################
##
#A  FittingSubgroup( <G> )
##
FittingSubgroup := NewAttribute( "FittingSubgroup", IsGroup );
SetFittingSubgroup := Setter( FittingSubgroup );
HasFittingSubgroup := Tester( FittingSubgroup );


#############################################################################
##
#A  PrefrattiniSubgroup( <G> )
##
PrefrattiniSubgroup := NewAttribute( "PrefrattiniSubgroup", IsGroup );
SetPrefrattiniSubgroup := Setter( PrefrattiniSubgroup );
HasPrefrattiniSubgroup := Tester( PrefrattiniSubgroup );

#############################################################################
##
#A  FrattiniSubgroup( <G> )
##
FrattiniSubgroup := NewAttribute( "FrattiniSubgroup", IsGroup );
SetFrattiniSubgroup := Setter( FrattiniSubgroup );
HasFrattiniSubgroup := Tester( FrattiniSubgroup );


#############################################################################
##
#A  InvariantForm( <D> )
##
InvariantForm := NewAttribute( "InvariantForm", IsGroup );
SetInvariantForm := Setter( InvariantForm );
HasInvariantForm := Tester( InvariantForm );


#############################################################################
##
#A  ComputedIBrs( <G> )
##
##  is the list where position <p> is reserved for 'IBr( <G>, <p> )'.
##
ComputedIBrs := NewAttribute( "ComputedIBrs", IsGroup, "mutable" );
SetComputedIBrs := Setter( ComputedIBrs );
HasComputedIBrs := Tester( ComputedIBrs );


#############################################################################
##
#A  Irr( <G> )
##
##  is the list of all complex ordinary irreducible characters of the finite
##  group <G>.
##
Irr := NewAttribute( "Irr", IsGroup );
SetIrr := Setter( Irr );
HasIrr := Tester( Irr );


#############################################################################
##
#A  JenningsSeries( <G> )
##
JenningsSeries := NewAttribute( "JenningsSeries", IsGroup );
SetJenningsSeries := Setter( JenningsSeries );
HasJenningsSeries := Tester( JenningsSeries );


#############################################################################
##
#A  LatticeSubgroups( <G> )
##
LatticeSubgroups := NewAttribute( "LatticeSubgroups", IsGroup );
SetLatticeSubgroups := Setter( LatticeSubgroups );
HasLatticeSubgroups := Tester( LatticeSubgroups );


#############################################################################
##
#A  LowerCentralSeriesOfGroup( <G> )
##
LowerCentralSeriesOfGroup := NewAttribute( "LowerCentralSeriesOfGroup",
    IsGroup );
SetLowerCentralSeriesOfGroup := Setter( LowerCentralSeriesOfGroup );
HasLowerCentralSeriesOfGroup := Tester( LowerCentralSeriesOfGroup );


#############################################################################
##
#A  MaximalNormalSubgroups( <G> )
##
MaximalNormalSubgroups := NewAttribute( "MaximalNormalSubgroups", IsGroup );
SetMaximalNormalSubgroups := Setter( MaximalNormalSubgroups );
HasMaximalNormalSubgroups := Tester( MaximalNormalSubgroups );


#############################################################################
##
#A  NormalMaximalSubgroups( <G> )
##
NormalMaximalSubgroups := NewAttribute( "NormalMaximalSubgroups", IsGroup );
SetNormalMaximalSubgroups := Setter( NormalMaximalSubgroups );
HasNormalMaximalSubgroups := Tester( NormalMaximalSubgroups );


#############################################################################
##
#A  MaximalSubgroups( <G> )
##
MaximalSubgroups := NewAttribute( "MaximalSubgroups", IsGroup );
SetMaximalSubgroups := Setter( MaximalSubgroups );
HasMaximalSubgroups := Tester( MaximalSubgroups );


#############################################################################
##
#A  MaximalSubgroupClassReps( <G> )
##
MaximalSubgroupClassReps := NewAttribute("MaximalSubgroupClassReps",IsGroup);
SetMaximalSubgroupClassReps := Setter( MaximalSubgroupClassReps );
HasMaximalSubgroupClassReps := Tester( MaximalSubgroupClassReps );


#############################################################################
##
#A  NormalSubgroups( <G> )
##
NormalSubgroups := NewAttribute( "NormalSubgroups", IsGroup );
SetNormalSubgroups := Setter( NormalSubgroups );
HasNormalSubgroups := Tester( NormalSubgroups );

#############################################################################
##
#F  NormalSubgroupsAbove
##
NormalSubgroupsAbove:=NewOperationArgs("NormalSubgroupsAbove");

############################################################################
##
#A  NrConjugacyClasses( <G> )
##
NrConjugacyClasses := NewAttribute( "NrConjugacyClasses", IsGroup );
SetNrConjugacyClasses := Setter( NrConjugacyClasses );
HasNrConjugacyClasses := Tester( NrConjugacyClasses );


#############################################################################
##
#A  Omega( <G> )
##
Omega := NewAttribute( "Omega", IsGroup );
SetOmega := Setter( Omega );
HasOmega := Tester( Omega );


#############################################################################
##
#A  RadicalGroup( <G> )
##
##  is the radical of <G>, i.e., the largest normal solvable subgroup of <G>.
##
RadicalGroup := NewAttribute( "RadicalGroup", IsGroup );
SetRadicalGroup := Setter( RadicalGroup );
HasRadicalGroup := Tester( RadicalGroup );


#############################################################################
##
#A  OrdersClassRepresentatives( <G> )
##
##  is a list of orders of representatives of conjugacy classes of the group
##  <G>, in the same ordering as the conjugacy classes.
##
OrdersClassRepresentatives := NewAttribute( "OrdersClassRepresentatives",
    IsGroup );
SetOrdersClassRepresentatives := Setter( OrdersClassRepresentatives );
HasOrdersClassRepresentatives := Tester( OrdersClassRepresentatives );


#############################################################################
##
#A  RationalClasses( <G> )
##
RationalClasses := NewAttribute( "RationalClasses", IsGroup );
SetRationalClasses := Setter( RationalClasses );
HasRationalClasses := Tester( RationalClasses );


#############################################################################
##
#A  RepresentativesPerfectSubgroups( <G> )
##
RepresentativesPerfectSubgroups := NewAttribute(
    "RepresentativesPerfectSubgroups", IsGroup );
SetRepresentativesPerfectSubgroups := Setter(
    RepresentativesPerfectSubgroups );
HasRepresentativesPerfectSubgroups := Tester(
    RepresentativesPerfectSubgroups );


#############################################################################
##
#A  SizesCentralizers( <G> )
##
##  is a list that stores at position $i$ the size of the centralizer of any
##  element in the $i$-th conjugacy class of the group $G$.
##
SizesCentralizers := NewAttribute( "SizesCentralizers", IsGroup );
SetSizesCentralizers := Setter( SizesCentralizers );
HasSizesCentralizers := Tester( SizesCentralizers );


#############################################################################
##
#A  SizesConjugacyClasses( <G> )
##
##  is a list that stores at position $i$ the size of the $i$-th conjugacy
##  class of the group $G$.
##
SizesConjugacyClasses := NewAttribute( "SizesConjugacyClasses", IsGroup );
SetSizesConjugacyClasses := Setter( SizesConjugacyClasses );
HasSizesConjugacyClasses := Tester( SizesConjugacyClasses );


#############################################################################
##
#A  GeneratorsSmallest( <G> )
#T or better GeneratorsSmallestGroup?
##
GeneratorsSmallest := NewAttribute( "GeneratorsSmallest", IsGroup );
SetGeneratorsSmallest := Setter( GeneratorsSmallest );
HasGeneratorsSmallest := Tester( GeneratorsSmallest );


#############################################################################
##
#A  MinimalGeneratingSet( <G> )
##
MinimalGeneratingSet := NewAttribute( "MinimalGeneratingSet", IsGroup );
SetMinimalGeneratingSet := Setter( MinimalGeneratingSet );
HasMinimalGeneratingSet := Tester( MinimalGeneratingSet );


#############################################################################
##
#A  SupersolvableResiduum( <G> )
##
SupersolvableResiduum := NewAttribute( "SupersolvableResiduum", IsGroup );
SetSupersolvableResiduum := Setter( SupersolvableResiduum );
HasSupersolvableResiduum := Tester( SupersolvableResiduum );


#############################################################################
##
#A  ComplementSystem( <G> )
##
ComplementSystem := NewAttribute( "ComplementSystem", IsGroup );
SetComplementSystem := Setter( ComplementSystem );
HasComplementSystem := Tester( ComplementSystem );


#############################################################################
##
#A  SylowSystem( <G> )
##
SylowSystem := NewAttribute( "SylowSystem", IsGroup );
SetSylowSystem := Setter( SylowSystem );
HasSylowSystem := Tester( SylowSystem );

#############################################################################
##
#A  HallSystem( <G> )
##
HallSystem := NewAttribute( "HallSystem", IsGroup );
SetHallSystem := Setter( HallSystem );
HasHallSystem := Tester( HallSystem );


#############################################################################
##
#A  TrivialSubgroup( <G> ) . . . . . . . . . .  trivial subgroup of group <G>
##
TrivialSubgroup := NewAttribute( "TrivialSubgroup", IsGroup );
SetTrivialSubgroup := Setter( TrivialSubgroup );
HasTrivialSubgroup := Tester( TrivialSubgroup );


#############################################################################
##
#A  UpperCentralSeriesOfGroup( <G> )
##
UpperCentralSeriesOfGroup := NewAttribute( "UpperCentralSeriesOfGroup",
    IsGroup );
SetUpperCentralSeriesOfGroup := Setter( UpperCentralSeriesOfGroup );
HasUpperCentralSeriesOfGroup := Tester( UpperCentralSeriesOfGroup );


#############################################################################
##
#O  Agemo( <G>, <p> )
##
Agemo := NewOperation( "Agemo", [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#O  EulerianFunction( <G>, <n> )
##
EulerianFunction := NewOperation( "EulerianFunction", 
                    [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#F  AgemoAbove( <G>, <C>, <p> )
##
AgemoAbove := NewOperationArgs( "AgemoAbove" );


#############################################################################
##
#O  AsSubgroup( <G>, <U> )
##
AsSubgroup := NewOperation( "AsSubgroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ClassMultiplicationCoefficient( <G>, <i>, <j>, <k> )
#O  ClassMultiplicationCoefficient( <G>, <C_i>, <C_j>, <C_k> )
##
ClassMultiplicationCoefficient := NewOperation(
    "ClassMultiplicationCoefficient",
    [ IsGroup, IsPosRat and IsInt,
      IsPosRat and IsInt, IsPosRat and IsInt ] );


#############################################################################
##
#F  ClosureGroupDefault( <G>, <elm> ) . . . . . closure of group with element
##
##  This functions returns the closure of the group <G> with the element
##  <elm>.
##  If <G> has the attribute 'AsListSorted' then also the result has this
##  attribute.
##  This is used to implement the default method for 'Enumerator' and
##  'EnumeratorSorted', via the function 'EnumeratorOfGroup'.
##
ClosureGroupDefault := NewOperationArgs( "ClosureGroupDefault" );


#############################################################################
##
#O  ClosureGroup( <G>, <obj> )  . . .  closure of group with element or group
##
ClosureGroup := NewOperation( "ClosureGroup", [ IsGroup, IsObject ] );


#############################################################################
##
#O  CommutatorSubgroup( <G>, <H> )
##
CommutatorSubgroup := NewOperation( "CommutatorSubgroup",
    [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ConjugateSubgroup( <G>, <obj> ) . . . . . conjugate of group <G> by <obj>
##
##  Note that <obj> must lie in the parent of <G>, otherwise the term
##  subgroup would not make sense.
##  To form a conjugate (group) by any object acting via '\^', one can use
##  the operator '\^'.
#T This should not be restricted to objects in the parent, or?
#T (Remember the hacks in the dispatchers of 'Centralizer' and 'Normalizer'
#T in GAP-3!)
##
#T Do we need 'ConjugateSubgroupNC', which does not check containment in
#T the parent?
##
ConjugateSubgroup := NewOperation( "ConjugateSubgroup",
    [ IsGroup, IsObject ] );


#############################################################################
##
#O  ConjugateSubgroups( <G>, <U> )
##
ConjugateSubgroups := NewOperation( "ConjugateSubgroups",
    [ IsGroup, IsGroup ] );


#############################################################################
##
#O  Core( <S>, <U> )
##
Core := NewOperation( "Core", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  CoreInParent( <G> )
##
CoreInParent := NewAttribute( "CoreInParent", IsGroup );
SetCoreInParent := Setter( CoreInParent );
HasCoreInParent := Tester( CoreInParent );


#############################################################################
##
#O  FactorGroup( <G>, <N> )
##
FactorGroup := NewOperation( "FactorGroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  FusionConjugacyClasses( <G>, <N> )
##
FusionConjugacyClasses := NewOperation( "FusionConjugacyClasses",
    [ IsGroup, IsGroup ] );


#############################################################################
##
#O  IBr( <G>, <p> )
##
##  is the list of all complex irreducible Brauer characters in
##  characteristic <p> of the finite group <G>.
##
IBr := NewOperation( "IBr", [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#O  Index( <G>, <U> )
##
Index := NewOperation( "Index", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  IndexInParent( <G> )
##
IndexInParent := NewAttribute( "IndexInParent", IsGroup );
SetIndexInParent := Setter( IndexInParent );
HasIndexInParent := Tester( IndexInParent );


#############################################################################
##
#O  IsConjugate( <G>, <x>, <y> )
##
IsConjugate := NewOperation( "IsConjugate",
    [ IsGroup, IsObject, IsObject ] );


#############################################################################
##
#P  IsNormalInParent( <G> )
##
IsNormalInParent := NewProperty( "IsNormalInParent", IsGroup );
SetIsNormalInParent := Setter( IsNormalInParent );
HasIsNormalInParent := Tester( IsNormalInParent );


#############################################################################
##
#O  IsNormal( <G>, <U> )
##
IsNormal := NewOperation( "IsNormal", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  IsPNilpotent( <G>, <p> )
##
IsPNilpotent := NewOperation( "IsPNilpotent",
    [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#O  IsPSolvable( <G>, <p> )
##
IsPSolvable := NewOperation( "IsPSolvable",
    [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#O  IsSubgroup( <G>, <U> )
##
IsSubgroup := NewOperation( "IsSubgroup", [ IsGroup, IsGroup ] );
#T really needed? (compat3.g?)


#############################################################################
##
#O  IsSubnormal( <G>, <U> )
##
IsSubnormal := NewOperation( "IsSubnormal", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  NiceGroup( <G> )  . . . . . . . . . . . . .  nice group isomorphic to <G>
##
NiceGroup := NewAttribute( "NiceGroup", IsGroup );
SetNiceGroup := Setter( NiceGroup );
HasNiceGroup := Tester( NiceGroup );


#############################################################################
##
#O  NormalClosure( <G>, <U> )
##
NormalClosure := NewOperation( "NormalClosure", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  NormalClosureInParent( <G> )
##
NormalClosureInParent := NewAttribute( "NormalClosureInParent", IsGroup );
SetNormalClosureInParent := Setter( NormalClosureInParent );
HasNormalClosureInParent := Tester( NormalClosureInParent );


#############################################################################
##
#O  NormalIntersection( <G>, <U> )
##
NormalIntersection := NewOperation( "NormalIntersection",
    [ IsGroup, IsGroup ] );

#############################################################################
##
#O  Normalizer( <G>, <g> )
#O  Normalizer( <G>, <U> )
##
Normalizer := NewOperation( "Normalizer", [ IsGroup, IsObject ] );


#############################################################################
##
#A  NormalizerInParent( <G> )
##
NormalizerInParent := NewAttribute( "NormalizerInParent", IsGroup );
SetNormalizerInParent := Setter( NormalizerInParent );
HasNormalizerInParent := Tester( NormalizerInParent );


#############################################################################
##
#F  PCentralSeries( <G>, <p> )
#O  PCentralSeriesOp( <G>, <p> )
#A  ComputedPCentralSeriess( <G> )  . . . . . . . .  known $p$-central series
##
##  'PCentralSeries' returns the <p>-central series of the group <G>.
##
##  The series that were computed already by 'PCentralSeries' are
##  stored as value of the attribute 'ComputedPCentralSeriess'.
##  Methods for the computation of a <p>-central series can be installed for
##  the operation 'PCentralSeriesOp'.
##
PCentralSeries := NewOperationArgs( "PCentralSeries" );

PCentralSeriesOp := NewOperation( "PCentralSeriesOp",
    [ IsGroup, IsPosRat and IsInt ] );

ComputedPCentralSeriess := NewAttribute( "ComputedPCentralSeriess",
    IsGroup, "mutable" );

#############################################################################
##
#F  PRump( <G>, <p> )
#O  PRumpOp( <G>, <p> )
#A  ComputedPRumps( <G> )
##
PRump := NewOperationArgs( "PRump" );

PRumpOp := NewOperation( "PRumpOp",
    [ IsGroup, IsPosRat and IsInt ] );

ComputedPRumps := NewAttribute( "ComputedPRumps",
    IsGroup, "mutable" );


#############################################################################
##
#F  PCore( <G>, <p> )
#O  PCoreOp( <G>, <p> )
#A  ComputedPCores( <G> ) . . . . . . . . . . . . . . . . . . known $p$ cores
##
##  'PCore' returns the <p>-core of the group <G>, where <p> is a prime
##  integer.
##  The <p>-core of <G> is the largest normal subgroup of <G> whose size is a
##  power of <p>.
##
##  The <p>-cores that were computed already by 'PCore' are
##  stored as value of the attribute 'ComputedPCores'.
##  Methods for the computation of a <p>-core can be installed for
##  the operation 'PCoreOp'.
##
PCoreOp := NewOperation( "PCoreOp", [ IsGroup, IsPosRat and IsInt ] );

PCore := NewOperationArgs( "PCore" );

ComputedPCores := NewAttribute( "ComputedPCores", IsGroup, "mutable" );


#############################################################################
##
#O  Stabilizer( <G>, <obj>, <opr> )
#O  Stabilizer( <G>, <obj> )
##
Stabilizer := NewOperation( "Stabilizer",
    [ IsGroup, IsObject, IsFunction ] );


#############################################################################
##
#O  SubnormalSeries( <G>, <U> )
##
SubnormalSeries := NewOperation( "SubnormalSeries", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  SubnormalSeriesInParent( <G> )
##
SubnormalSeriesInParent := NewAttribute( "SubnormalSeriesInParent",
    IsGroup );
SetSubnormalSeriesInParent := Setter( SubnormalSeriesInParent );
HasSubnormalSeriesInParent := Tester( SubnormalSeriesInParent );


#############################################################################
##
#F  SylowSubgroup( <G>, <p> )
#O  SylowSubgroupOp( <G>, <p> )
#A  ComputedSylowSubgroups( <G> ) . . . . . . . . . . . known Sylow subgroups
##
##  'SylowSubgroup' returns a Sylow <p> subgroup of the group <G>.
##
##  The Sylow subgroups that were computed already by 'SylowSubgroup' are
##  stored as value of the attribute 'ComputedSylowSubgroups'.
##  Methods for the computation of a Sylow subgroup can be installed for
##  the operation 'SylowSubgroupOp'.
##
SylowSubgroup := NewOperationArgs( "SylowSubgroup" );

SylowSubgroupOp := NewOperation( "SylowSubgroupOp",
    [ IsGroup, IsPosRat and IsInt ] );

ComputedSylowSubgroups := NewAttribute( "ComputedSylowSubgroups",
    IsGroup, "mutable" );


#############################################################################
##
#F  SylowComplement( <G>, <p> )
#O  SylowComplementOp( <G>, <p> )
#A  ComputedSylowComplements( <G> ) . . . . . . . . . known Sylow complements
##
##  'SylowComplement' returns a Sylow <p> complement of the group <G>.
##
##  The Sylow complements that were computed already by 'SylowComplement' are
##  stored as value of the attribute 'ComputedSylowComplements'.
##  Methods for the computation of a Sylow complement can be installed for
##  the operation 'SylowComplementOp'.
##
SylowComplement := NewOperationArgs( "SylowComplement" );

SylowComplementOp := NewOperation( "SylowComplementOp",
    [ IsGroup, IsPosRat and IsInt ] );

ComputedSylowComplements := NewAttribute( "ComputedSylowComplements", 
    IsGroup, "mutable" );


#############################################################################
##
#F  HallSubgroup( <G>, <pi> )
#O  HallSubgroupOp( <G>, <pi> )
#A  ComputedHallSubgroups( <G> ) . . . . . . . . . . . known Hall subgroups
##
##  'HallSubgroup' returns a Hall <pi> subgroup of the group <G>.
##
##  The Hall subgroups that were computed already by 'HallSubgroup' are
##  stored as value of the attribute 'ComputedHallSubgroups'.
##  Methods for the computation of a Hall subgroup can be installed for
##  the operation 'HallSubgroupOp'.
##
HallSubgroup := NewOperationArgs( "HallSubgroup" );

HallSubgroupOp := NewOperation( "HallSubgroupOp",
    [ IsGroup, IsObject ] );

ComputedHallSubgroups := NewAttribute( "ComputedHallSubgroups",
    IsGroup, "mutable" );


#############################################################################
##
#O  NrConjugacyClassesInSupergroup( <U>, <G> )
##
NrConjugacyClassesInSupergroup := NewOperation(
    "NrConjugacyClassesInSupergroup", [ IsGroup, IsGroup ] );


#############################################################################
##

#O  GroupByGenerators( <gens> ) . . . . . . . . . . . . . group by generators
#O  GroupByGenerators( <gens>, <id> ) . . . . . . . . . . group by generators
##
GroupByGenerators := NewConstructor( "GroupByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Group( <gen>, ... )
#F  Group( <gens>, <id> )
##
##  'Group( <gen>, ... )' is the group generated by the arguments <gen>, ...
##
##  If the only  argument <obj> is a list  that is not  a matrix then 'Group(
##  <obj> )' is the group generated by the elements of that list.
##
##  If there  are two arguments,   a list <gens>  and  an element <id>,  then
##  'Group( <gens>, <id> )'  is the group generated  by <gens>, with identity
##  <id>.
##
Group := NewOperationArgs( "Group" );


#############################################################################
##
#F  InstallGroupMethod( <coll-prop>, <grp-prop>, <func> )
##
GROUP_METHODS := [];

InstallGroupMethod := function( coll, grp, func )
    Add( GROUP_METHODS, [ FLAGS_FILTER(coll), FLAGS_FILTER(grp), func ] );
end;

RunGroupMethods := RunMethodsFunction2(GROUP_METHODS);


#############################################################################
##

#F  Subgroup( <G>, <gens> ) . . . . . . . subgroup of <G> generated by <gens>
#F  SubgroupNC( <G>, <gens> )
##
Subgroup := NewOperationArgs( "Subgroup" );
SubgroupNC := NewOperationArgs( "SubgroupNC" );


#############################################################################
##
#F  InstallSubgroupMethod( <grp-prop>, <sub-prop>, <func> )
##
SUBGROUP_METHODS := [];

InstallSubgroupMethod := function( grp, sub, func )
    Add( SUBGROUP_METHODS, [ FLAGS_FILTER(grp), FLAGS_FILTER(sub), func ] );
end;

RunSubgroupMethods := RunMethodsFunction2(SUBGROUP_METHODS);


#############################################################################
##

#R  IsRightTransversal  . . . . . . . . . . . . . . . . . . right transversal
##
IsRightTransversal := NewRepresentation( "IsRightTransversal",
    IsEnumerator and IsDuplicateFreeList and
    IsComponentObjectRep and IsAttributeStoringRep,
    [ "group", "subgroup" ] );

RightTransversal := NewOperation( "RightTransversal", [ IsGroup, IsGroup ] );
RightTransversalInParent := NewAttribute( "RightTransversalInParent",
                                    IsGroup );
SetRightTransversalInParent := Setter( RightTransversalInParent );
HasRightTransversalInParent := Tester( RightTransversalInParent );


#############################################################################
##
#F  IsomorphismTypeFiniteSimpleGroup( <G> ) . . . . . . . . . ismorphism type
##
IsomorphismTypeFiniteSimpleGroup := NewOperationArgs(
    "IsomorphismTypeFiniteSimpleGroup" );


#############################################################################
##
#F  FreeGroup( <rank> ) . . . . . . . . . . . . . .  free group of given rank
#F  FreeGroup( <rank>, <name> )
#F  FreeGroup( <name1>, <name2>, ... )
##
FreeGroup := NewOperationArgs( "FreeGroup" );


#############################################################################
##
#A  IsomorphismPcGroup( <G> )
##
IsomorphismPcGroup := NewAttribute( "IsomorphismPcGroup", IsGroup );


#############################################################################
##
#A  PrimePowerComponents( <g> )
##
PrimePowerComponents := NewAttribute(
    "PrimePowerComponents",
    IsMultiplicativeElement );


#############################################################################
##
#O  PrimePowerComponent( <g>, <p> )
##
PrimePowerComponent := NewOperation(
    "PrimePowerComponent",
    [ IsMultiplicativeElement, IsInt and IsPosRat ] );


#############################################################################
##
#E  grp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


