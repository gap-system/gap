#############################################################################
##
#W  grp.gd                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                             & Bettina Eick
#W                                                           & Heiko Theissen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of operations for groups.
##
#H  @(#)$Id$
##
Revision.grp_gd :=
    "@(#)$Id$";


GroupString := function(arg) return "Group"; end;
#T !!!

IsPrimeInt := "2b defined";

#############################################################################
##
#F  KeyDependentFOA( <name>, <grpreq>, <keyreq>, <keytest> )  . e.g., `PCore'
##
KeyDependentFOA := function( name, grpreq, keyreq, keytest )
    local str, oper, attr, func;
    
    if keytest = "prime"  then
        keytest := function( key )
            if not IsPrimeInt( key )  then
                Error( name, ": <p> must be a prime" );
            fi;
        end;
    fi;

    # Create the two-argument operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );
    oper:= NewOperation( str, [ grpreq, keyreq ] );

    # Create the mutable attribute and install the default method.
    str := "Computed";
    APPEND_LIST_INTR( str, name );
    APPEND_LIST_INTR( str, "s" );
    attr:= NewAttribute( str, grpreq, "mutable" );
    InstallMethod( attr, true, [ grpreq ], 0, grp -> [  ] );

    # Create the function that mainly calls the operation.
    func:= function( grp, key )
        local   known,  i, erg;
        
        if not IsFinite( grp )  then
            Error( name, ": <G> must be finite" );
        fi;
        keytest( key );
        known := attr( grp );
        i := 1;
        while     i < Length( known )
              and known[ i ] < key  do
            i := i + 2;
        od;
	# start storing only after the result has been computed. This avoids
	# errors if a calculation had been interrupted.
	erg := oper( grp, key );
        if i > Length( known )  or  known[ i ] <> key  then
            known{ [ i .. Length( known ) ] + 2 } :=
              known{ [ i .. Length( known ) ] };
            known[ i ] := key;
            known[ i + 1 ] := erg;
        fi;
        return known[ i + 1 ];
    end;
    
    # Return the triple.
    return [ func, oper, attr ];
end;


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

InstallSubsetMaintainedMethod( IsCyclic, IsGroup and IsCyclic, IsGroup );

InstallFactorMaintainedMethod( IsCyclic, IsGroup and IsCyclic, IsGroup,
    IsGroup );

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

InstallSubsetMaintainedMethod( IsElementaryAbelian,
    IsGroup and IsElementaryAbelian, IsGroup );

InstallFactorMaintainedMethod( IsElementaryAbelian,
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

InstallFactorMaintainedMethod( IsFinitelyGeneratedGroup,
    IsGroup and IsFinitelyGeneratedGroup, IsGroup, IsGroup );

InstallTrueMethod( IsFinitelyGeneratedGroup, IsGroup and IsTrivial );

#############################################################################
##
#P  IsSubsetLocallyFiniteGroup(<M>) . . . . test if a group is locally finite
##
##  A group is called locally finite if every finitely generated subgroup is
##  finite.
##
IsSubsetLocallyFiniteGroup :=
    NewProperty( "IsSubsetLocallyFiniteGroup", IsGroup );
SetIsSubsetLocallyFiniteGroup := Setter( IsSubsetLocallyFiniteGroup );
HasIsSubsetLocallyFiniteGroup := Tester( IsSubsetLocallyFiniteGroup );

# this true method will enforce that many groups are finite, which is needed
# implicitly
InstallTrueMethod( IsFinite, IsFinitelyGeneratedGroup and IsGroup
                             and IsSubsetLocallyFiniteGroup );

InstallTrueMethod( IsSubsetLocallyFiniteGroup, IsFinite and IsGroup );

InstallSubsetMaintainedMethod( IsSubsetLocallyFiniteGroup,
    IsGroup and IsSubsetLocallyFiniteGroup, IsGroup );

#############################################################################
##
#P  IsNilpotentGroup( <G> )
##
IsNilpotentGroup := NewProperty( "IsNilpotentGroup", IsGroup );
SetIsNilpotentGroup := Setter( IsNilpotentGroup );
HasIsNilpotentGroup := Tester( IsNilpotentGroup );

InstallSubsetMaintainedMethod( IsNilpotentGroup,
    IsGroup and IsNilpotentGroup, IsGroup );

InstallFactorMaintainedMethod( IsNilpotentGroup,
    IsGroup and IsNilpotentGroup, IsGroup, IsGroup );

InstallTrueMethod( IsNilpotentGroup, IsGroup and IsCommutative );


#############################################################################
##
#P  IsPerfectGroup( <G> )
##
IsPerfectGroup := NewProperty( "IsPerfectGroup", IsGroup );
SetIsPerfectGroup := Setter( IsPerfectGroup );
HasIsPerfectGroup := Tester( IsPerfectGroup );

InstallFactorMaintainedMethod( IsPerfectGroup,
    IsGroup and IsPerfectGroup, IsGroup, IsGroup );


#############################################################################
##
#P  IsSimpleGroup( <G> )
##
IsSimpleGroup := NewProperty( "IsSimpleGroup", IsGroup );
SetIsSimpleGroup := Setter( IsSimpleGroup );
HasIsSimpleGroup := Tester( IsSimpleGroup );

InstallIsomorphismMaintainedMethod( IsSimpleGroup,
    IsGroup and IsSimpleGroup, IsGroup );


#############################################################################
##
#P  IsSupersolvableGroup( <G> )
##
IsSupersolvableGroup := NewProperty( "IsSupersolvableGroup", IsGroup );
SetIsSupersolvableGroup := Setter( IsSupersolvableGroup );
HasIsSupersolvableGroup := Tester( IsSupersolvableGroup );

InstallSubsetMaintainedMethod( IsSupersolvableGroup,
    IsGroup and IsSupersolvableGroup, IsGroup );

InstallFactorMaintainedMethod( IsSupersolvableGroup,
    IsGroup and IsSupersolvableGroup, IsGroup, IsGroup );

InstallTrueMethod( IsSupersolvableGroup, IsNilpotentGroup );


#############################################################################
##
#P  IsMonomialGroup( <G> )
##
IsMonomialGroup := NewProperty( "IsMonomialGroup", IsGroup );
SetIsMonomialGroup := Setter( IsMonomialGroup );
HasIsMonomialGroup := Tester( IsMonomialGroup );

InstallFactorMaintainedMethod( IsMonomialGroup,
    IsGroup and IsMonomialGroup, IsGroup, IsGroup );

InstallTrueMethod( IsMonomialGroup, IsSupersolvableGroup and IsFinite );


#############################################################################
##
#P  IsSolvableGroup( <G> )
##
IsSolvableGroup := NewProperty( "IsSolvableGroup", IsGroup );
SetIsSolvableGroup := Setter( IsSolvableGroup );
HasIsSolvableGroup := Tester( IsSolvableGroup );

InstallSubsetMaintainedMethod( IsSolvableGroup,
    IsGroup and IsSolvableGroup, IsGroup );

InstallFactorMaintainedMethod( IsSolvableGroup,
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
#A  ChiefSeries( <G> )
##
ChiefSeries := NewAttribute( "ChiefSeries", IsGroup );
SetChiefSeries := Setter( ChiefSeries );
HasChiefSeries := Tester( ChiefSeries );


#############################################################################
##
#O  ChiefSeriesUnderAction( <U>, <G> )
##
##  is a chief series of the group <G> w.r.t. to the action of the supergroup
##  <U>.
##
ChiefSeriesUnderAction := NewOperation( "ChiefSeriesUnderAction",
    [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ChiefSeriesThrough( <G>,<list> )
##
##  is a chief series of the group <G> going through the normal subgroups in
##  <l>. <l> must be a list of normal subgroups of <G> contained in each
##  other, sorted by size.
##
ChiefSeriesThrough := NewOperation( "ChiefSeriesThrough",
    [ IsGroup, IsList ] );


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
#O  OmegaOp( <G>, <p>, <n> )
##
##  is the largest elementary abelian normal subgroup in the $p$-group <G>.
##
Omega := NewOperationArgs( "Omega" );
OmegaOp := NewOperation( "OmegaOp",
    [ IsGroup, IsPosRat and IsInt, IsPosRat and IsInt ] );
ComputedOmegas := NewAttribute( "ComputedOmegas", IsGroup, "mutable" );


#############################################################################
##
#O  AgemoOp( <G>, <p>, <n> )
##
Agemo := NewOperationArgs( "Agemo" );
AgemoOp := NewOperation( "AgemoOp",
    [ IsGroup, IsPosRat and IsInt, IsPosRat and IsInt ] );
ComputedAgemos := NewAttribute( "ComputedAgemos", IsGroup, "mutable" );


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
#A  SmallGeneratingSet(<G>) small generating set (hopefully even irredundant)
##
SmallGeneratingSet := NewAttribute( "SmallGeneratingSet", IsGroup );
SetSmallGeneratingSet := Setter( SmallGeneratingSet );
HasSmallGeneratingSet := Tester( SmallGeneratingSet );

#############################################################################
##
#A  SupersolvableResiduum( <G> )
##
SupersolvableResiduum := NewAttribute( "SupersolvableResiduum", IsGroup );
SetSupersolvableResiduum := Setter( SupersolvableResiduum );
HasSupersolvableResiduum := Tester( SupersolvableResiduum );


#############################################################################
##
#F  SupersolvableResiduumDefault( <G> ) . . . . supersolvable residuum of <G>
##
##  `SupersolvableResiduumDefault' returns a record with components
##  `ssr' :
##      the supersolvable residuum of the group <G>, that is,
##      the largest normal subgroup of <G> with supersolvable factor group,
##  `ds' :
##      a chain of normal subgroups of <G>, descending from <G> to the
##      supersolvable residuum, such that any refinement of this chain
##      is a normal series.
##
SupersolvableResiduumDefault := NewOperationArgs(
    "SupersolvableResiduumDefault" );


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
TrivialSubgroup := TrivialSubmagmaWithOne;
SetTrivialSubgroup := SetTrivialSubmagmaWithOne;
HasTrivialSubgroup := HasTrivialSubmagmaWithOne;


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
#O  ConjugateGroup( <G>, <obj> )  . . . . . . conjugate of group <G> by <obj>
##
##  To form a conjugate (group) by any object acting via '\^', one can use
##  the operator '\^'.
#T This should not be restricted to objects in the parent, or?
#T (Remember the hacks in the dispatchers of 'Centralizer' and 'Normalizer'
#T in GAP-3!)
##
#T Do we need 'ConjugateSubgroupNC', which does not check containment in
#T the parent?
##
ConjugateGroup := NewOperation( "ConjugateGroup",
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
tmp:= InParentFOA( "Core", IsGroup, IsGroup, NewAttribute );
Core         := tmp[1];
CoreOp       := tmp[2];
CoreInParent := tmp[3];
SetCoreInParent := Setter( CoreInParent );
HasCoreInParent := Tester( CoreInParent );


#############################################################################
##
#O  CosetTable( <G>, <H> )
##
CosetTable := NewOperation( "CosetTable", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  CosetTableInWholeGroup( <G> )
##
CosetTableInWholeGroup := NewAttribute( "CosetTableInWholeGroup", IsGroup );
SetCosetTableInWholeGroup := Setter( CosetTableInWholeGroup );
HasCosetTableInWholeGroup := Tester( CosetTableInWholeGroup );


#############################################################################
##
#O  FactorGroup( <G>, <N> )
##
FactorGroup := NewOperation( "FactorGroup", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  Index( <G>, <U> )
##
tmp:= InParentFOA( "Index", IsGroup, IsGroup, NewAttribute );
Index         := tmp[1];
IndexOp       := tmp[2];
IndexInParent := tmp[3];
SetIndexInParent := Setter( IndexInParent );
HasIndexInParent := Tester( IndexInParent );


#############################################################################
##
#A  IndexInWholeGroup( <G> )
##
IndexInWholeGroup := NewAttribute( "IndexInWholeGroup", IsGroup );
SetIndexInWholeGroup := Setter( IndexInWholeGroup );
HasIndexInWholeGroup := Tester( IndexInWholeGroup );


#############################################################################
##
#A  IndependentGeneratorsOfAbelianGroup( <A> )
##
IndependentGeneratorsOfAbelianGroup := NewAttribute
    ( "IndependentGeneratorsOfAbelianGroup", IsGroup and IsAbelian );
SetIndependentGeneratorsOfAbelianGroup :=
  Setter( IndependentGeneratorsOfAbelianGroup );
HasIndependentGeneratorsOfAbelianGroup :=
  Tester( IndependentGeneratorsOfAbelianGroup );


#############################################################################
##
#O  IsConjugate( <G>, <x>, <y> )
##
IsConjugate := NewOperation( "IsConjugate",
    [ IsGroup, IsObject, IsObject ] );


#############################################################################
##
#O  IsNormal( <G>, <U> )
##
tmp:= InParentFOA( "IsNormal", IsGroup, IsGroup, NewProperty );
IsNormal         := tmp[1];
IsNormalOp       := tmp[2];
IsNormalInParent := tmp[3];
SetIsNormalInParent := Setter( IsNormalInParent );
HasIsNormalInParent := Tester( IsNormalInParent );


#############################################################################
##
#F  IsPNilpotent( <G>, <p> )
##
tmp := KeyDependentFOA( "IsPNilpotent", IsGroup,
               IsPosRat and IsInt, "prime" );
IsPNilpotent          := tmp[1];
IsPNilpotentOp        := tmp[2];
ComputedIsPNilpotents := tmp[3];


#############################################################################
##
#F  IsPSolvable( <G>, <p> )
##
tmp := KeyDependentFOA( "IsPSolvable", IsGroup,
               IsPosRat and IsInt, "prime" );
IsPSolvable          := tmp[1];
IsPSolvableOp        := tmp[2];
ComputedIsPSolvables := tmp[3];


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
#O  NormalClosure( <G>, <U> )
##
tmp:= InParentFOA( "NormalClosure", IsGroup, IsGroup, NewAttribute );
NormalClosure         := tmp[1];
NormalClosureOp       := tmp[2];
NormalClosureInParent := tmp[3];
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
tmp:= InParentFOA( "Normalizer", IsGroup, IsObject, NewAttribute );
Normalizer         := tmp[1];
NormalizerOp       := tmp[2];
NormalizerInParent := tmp[3];
SetNormalizerInParent := Setter( NormalizerInParent );
HasNormalizerInParent := Tester( NormalizerInParent );


#############################################################################
##
#O  CentralizerModulo(<G>,<N>,<elm>)   full preimage of C_(G/N)(elm.N)
##
CentralizerModulo := NewOperation("CentralizerModulo",
  [IsGroup,IsGroup,IsObject]);


#############################################################################
##
#F  PCentralSeries( <G>, <p> )
##
tmp := KeyDependentFOA( "PCentralSeries", IsGroup,
               IsPosRat and IsInt,
               "prime" );
PCentralSeries          := tmp[1];
PCentralSeriesOp        := tmp[2];
ComputedPCentralSeriess := tmp[3];


#############################################################################
##
#F  PRump( <G>, <p> )
##
tmp := KeyDependentFOA( "PRump", IsGroup,
               IsPosRat and IsInt, "prime" );
PRump          := tmp[1];
PRumpOp        := tmp[2];
ComputedPRumps := tmp[3];


#############################################################################
##
#F  PCore( <G>, <p> )
##
tmp := KeyDependentFOA( "PCore", IsGroup,
               IsPosRat and IsInt, "prime" );
PCore          := tmp[1];
PCoreOp        := tmp[2];
ComputedPCores := tmp[3];


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
tmp:= InParentFOA( "SubnormalSeries", IsGroup, IsGroup, NewAttribute );
SubnormalSeries         := tmp[1];
SubnormalSeriesOp       := tmp[2];
SubnormalSeriesInParent := tmp[3];
SetSubnormalSeriesInParent := Setter( SubnormalSeriesInParent );
HasSubnormalSeriesInParent := Tester( SubnormalSeriesInParent );


#############################################################################
##
#F  SylowSubgroup( <G>, <p> )
##
tmp := KeyDependentFOA( "SylowSubgroup", IsGroup,
               IsPosRat and IsInt, "prime" );
SylowSubgroup          := tmp[1];
SylowSubgroupOp        := tmp[2];
ComputedSylowSubgroups := tmp[3];


#############################################################################
##
#F  SylowComplement( <G>, <p> )
##
tmp := KeyDependentFOA( "SylowComplement", IsGroup,
               IsPosRat and IsInt, "prime" );
SylowComplement          := tmp[1];
SylowComplementOp        := tmp[2];
ComputedSylowComplements := tmp[3];


#############################################################################
##
#F  HallSubgroup( <G>, <pi> )
##
tmp := KeyDependentFOA( "HallSubgroup", IsGroup, IsList, ReturnTrue );
HallSubgroup          := tmp[1];
HallSubgroupOp        := tmp[2];
ComputedHallSubgroups := tmp[3];


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
GroupByGenerators := NewOperation( "GroupByGenerators", [ IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


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
GROUP_METHODS      := [];
InstallGroupMethod := InstallMethodsFunction2(GROUP_METHODS);
RunGroupMethods    := RunMethodsFunction2(GROUP_METHODS);


#############################################################################
##

#F  Subgroup( <G>, <gens> ) . . . . . . . subgroup of <G> generated by <gens>
#F  SubgroupNC( <G>, <gens> )
##
Subgroup := SubmagmaWithInverses;

SubgroupNC := SubmagmaWithInversesNC;


#############################################################################
##

#R  IsRightTransversal  . . . . . . . . . . . . . . . . . . right transversal
##
IsRightTransversal := NewRepresentation( "IsRightTransversal",
    IsEnumerator and IsDuplicateFreeList and
    IsComponentObjectRep and IsAttributeStoringRep,
    [ "group", "subgroup" ] );

#############################################################################
##
#O  RightTransversal( <G>, <U> )  . . . . . . . . . . . . . right transversal
##
tmp:= InParentFOA( "RightTransversal", IsGroup, IsGroup, NewAttribute );
RightTransversal         := tmp[1];
RightTransversalOp       := tmp[2];
RightTransversalInParent := tmp[3];
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
#F  FreeGroup( <rank> )
#F  FreeGroup( <rank>, <name> )
#F  FreeGroup( <name1>, <name2>, ... )
#F  FreeGroup( <names> )
##
##  Called in the first form, 'FreeGroup' returns a free group on
##  <rank> generators.
##  Called in the second form, 'FreeGroup' returns a free group on
##  <rank> generators, printed as '<name>1', '<name>2' etc.
##  Called in the third form, 'FreeGroup' returns a free group on
##  as many generators as arguments, printed as <name1>, <name2> etc.
##  Called in the fourth form, 'FreeGroup' returns a free group on
##  as many generators as the length of the list <names>, the $i$-th
##  generator being printed as '<names>[$i$]'.
##
FreeGroup := NewOperationArgs( "FreeGroup" );


#############################################################################
##
#A  IsomorphismPcGroup( <G> )
##
IsomorphismPcGroup := NewAttribute( "IsomorphismPcGroup", IsGroup );

#############################################################################
##
#A  IsomorphismFpGroup( <G> )
##
IsomorphismFpGroup := NewAttribute( "IsomorphismFpGroup", IsGroup );
HasIsomorphismFpGroup := Tester(IsomorphismFpGroup);
SetIsomorphismFpGroup := Setter(IsomorphismFpGroup);

IsomorphismFpGroupByGenerators := NewOperation( 
    "IsomorphismFpGroupByGenerators", [IsGroup, IsList, IsString] );
IsomorphismFpGroupBySubnormalSeries := NewOperation( 
    "IsomorphismFpGroupBySubnormalSeries", [IsGroup, IsList, IsString] );
IsomorphismFpGroupByCompositionSeries := NewOperation( 
    "IsomorphismFpGroupByCompositionSeries", [IsGroup, IsString] );
IsomorphismFpGroupByPcgs := NewOperationArgs( "IsomorphismFpGroupByPcgs" );

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
#O  PowerMapOfGroup( <G>, <n>, <ccl> )
##
##  is a list of positions, at position $i$ the position of the conjugacy
##  class containing the <n>-th powers of the elements in the $i$-th class
##  of the list <ccl> of conjugacy classes.
##
PowerMapOfGroup := NewOperation( "PowerMapOfGroup",
    [ IsGroup, IsInt, IsHomogeneousList ] );


#############################################################################
##
#F  PowerMapOfGroupWithInvariants( <G>, <n>, <ccl>, <invariants> )
##
##  is a list of integers, at position $i$ the position of the conjugacy
##  class containimg the <n>-th powers of elements in class $i$ of <ccl>.
##  The list <invariants> contains all invariants besides element order
##  that shall be used before membership tests.
##
##  Element orders are tested first in any case since they may allow a
##  decision without forming the <n>-th powers of elements.
##
PowerMapOfGroupWithInvariants := NewOperationArgs(
    "PowerMapOfGroupWithInvariants" );


#############################################################################
##
#O  KnowsHowToDecompose(<G>,<gens>)      test whether the group can decompose 
##                                       into the generators
##
KnowsHowToDecompose := NewOperation("KnowsHowToDecompose",[IsGroup,IsList]);


#############################################################################
##
#O  HasAbelianFactorGroup(<G>,<N>)   test whether G/N is abelian
##
HasAbelianFactorGroup := NewOperationArgs("HasAbelianFactorGroup");

#############################################################################
##

#E  grp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


