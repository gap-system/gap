#############################################################################
##
#W  oprt.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.oprt_gd :=
    "@(#)$Id$";

InfoOperation := NewInfoClass( "InfoOperation" );

#############################################################################
##
#C  IsExternalSet . . . . . . . . . . . . . . . . . category of external sets
##
##  An external set  specifies an operation <opr>:  <D>  x <G>  --> <D>  of a
##  group <G> on a finite domain <D>. If <D> is not a list, an enumerator for
##  <D> is automatically chosen and fixed.
##
IsExternalSet := NewCategory( "IsExternalSet", IsDomain );

#############################################################################
##
#R  IsExternalSubset . . . . . . . . . . . representation of external subsets
##
##  An external subset is the restriction  of an external  set to a subset of
##  <D>, i.e., to a union of orbits.
##
IsExternalSubset := NewRepresentation( "IsExternalSubset",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "start" ] );                            

#############################################################################
##
#R  IsExternalOrbit  . . . . . . . . . . .  representation of external orbits
##
##  An external orbit is an external subset on one orbit.
##
IsExternalOrbit := NewRepresentation( "IsExternalOrbit",
    IsExternalSubset, [ "start" ] );
IsExternalSetByPcgs := NewCategory( "IsExternalSetByPcgs", IsExternalSet );

XSET_XSSETTYPE := 4;
XSET_XORBTYPE  := 5;

IsExternalSetDefaultRep := NewRepresentation( "IsExternalSetDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [  ] );
IsExternalSetByOperatorsRep := NewRepresentation
  ( "IsExternalSetByOperatorsRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "generators", "operators", "funcOperation" ] );

IsOperationHomomorphism := NewRepresentation( "IsOperationHomomorphism",
    IsGroupHomomorphism and
    IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
    IsAttributeStoringRep, [  ] );

IsOperationHomomorphismDirectly := NewRepresentation
    ( "IsOperationHomomorphismDirectly",
      IsOperationHomomorphism,
      [  ] );
IsOperationHomomorphismByOperators := NewRepresentation
    ( "IsOperationHomomorphismByOperators",
      IsOperationHomomorphism,
      [  ] );
IsOperationHomomorphismSubset := NewRepresentation
    ( "IsOperationHomomorphismSubset",
      IsOperationHomomorphism,
      [  ] );
IsOperationHomomorphismByBase := NewRepresentation
    ( "IsOperationHomomorphismByBase",
      IsOperationHomomorphism,
      [  ] );

IsConstituentHomomorphism := NewRepresentation( "IsConstituentHomomorphism",
    IsOperationHomomorphismDirectly, [ "conperm" ] );

IsBlocksHomomorphism := NewRepresentation( "IsBlocksHomomorphism",
    IsOperationHomomorphismDirectly, [ "reps" ] );

IsGeneralLinearOperationHomomorphism := NewRepresentation
    ( "IsGeneralLinearOperationHomomorphism",
      IsOperationHomomorphismDirectly,
      [  ] );

IsGeneralLinearOperationHomomorphismWithBase := NewRepresentation
    ( "IsGeneralLinearOperationHomomorphismWithBase",
      IsGeneralLinearOperationHomomorphism,
      [  ] );

#############################################################################
##
#A  ActingDomain( <xset> )  . . . . . . . . . . . . . . . . . . the group <G>
##
ActingDomain := NewAttribute( "ActingDomain", IsExternalSet );
SetActingDomain := Setter( ActingDomain );
HasActingDomain := Tester( ActingDomain );

#############################################################################
##
#A  HomeEnumerator( <xset> )  . . . . . . .  the enumerator of the domain <D>
##
##  For external   subsets, this is  different  from `Enumerator(  <xset> )',
##  which enumerates the union of orbits.
##
HomeEnumerator := NewAttribute( "HomeEnumerator", IsExternalSet );
SetHomeEnumerator := Setter( HomeEnumerator );
HasHomeEnumerator := Tester( HomeEnumerator );

#############################################################################
##
#A  FunctionOperation( <xset> ) . . . . . . . . . . . . .  the function <opr>
##
FunctionOperation := NewAttribute( "FunctionOperation", IsExternalSet );
SetFunctionOperation := Setter( FunctionOperation );
HasFunctionOperation := Tester( FunctionOperation );

#############################################################################
##
#A  CanonicalRepresentativeOfExternalSet( <xset> )  . . . . . . . . . . . . .
##
##  The canonical representative of an  external set may  only depend on <G>,
##  <D>, <opr> and (in the case of  external subsets) `Enumerator( <xset> )'.
##  It must not depend, e.g., on the representative of an external orbit.
##
CanonicalRepresentativeOfExternalSet := NewAttribute
    ( "CanonicalRepresentativeOfExternalSet", IsExternalSet );
SetCanonicalRepresentativeOfExternalSet :=
  Setter( CanonicalRepresentativeOfExternalSet );
HasCanonicalRepresentativeOfExternalSet :=
  Tester( CanonicalRepresentativeOfExternalSet );

# a CanonicalRepresentativeDeterminatorOfExternalSet is a function that
# takes as arguments the acting group and the point. It returns a list
# of length 3: [CanonRep, NormalizerCanonRep, ConjugatingElm]. 
# list components 2 and 3 do not need to be bound.

CanonicalRepresentativeDeterminatorOfExternalSet := NewAttribute
    ( "CanonicalRepresentativeDeterminatorOfExternalSet", IsExternalSet );
SetCanonicalRepresentativeDeterminatorOfExternalSet :=
  Setter( CanonicalRepresentativeDeterminatorOfExternalSet );
HasCanonicalRepresentativeDeterminatorOfExternalSet :=
  Tester( CanonicalRepresentativeDeterminatorOfExternalSet );

# Xsets that know how to get a canonical representative should claim they
# have one for purposes of method selection
InstallTrueMethod(HasCanonicalRepresentativeOfExternalSet,
  HasCanonicalRepresentativeDeterminatorOfExternalSet);

#############################################################################
##
#A  OperatorOfExternalSet( <xset> ) . . . . . . . . . . . . . . . . . . . . .
##
##  an     element     mapping      `Representative(     <xset>    )'      to
##  `CanonicalRepresentativeOfExternalSet( <xset> ' under the given operation
##
OperatorOfExternalSet := NewAttribute( "OperatorOfExternalSet",
                                 IsExternalSet );
SetOperatorOfExternalSet := Setter( OperatorOfExternalSet );
HasOperatorOfExternalSet := Tester( OperatorOfExternalSet );

#############################################################################
##
#A  OperationHomomorphism( <xset> ) . homomorphism into S_{HomeEnumerator(D)}
##
OperationHomomorphismAttr := NewAttribute( "OperationHomomorphism",
                                 IsExternalSet );

#############################################################################
##
#A  UnderlyingExternalSet( <ohom> ) . . . . . . . . . underlying external set
##
UnderlyingExternalSet := NewAttribute( "UnderlyingExternalSet",
                                 IsOperationHomomorphism );
SetUnderlyingExternalSet := Setter( UnderlyingExternalSet );
HasUnderlyingExternalSet := Tester( UnderlyingExternalSet );

OrbitishReq  := [ IsGroup, IsList, IsObject,
                  IsList,
                  IsList,
                  IsFunction ];
OrbitsishReq := [ IsGroup, IsList,
                  IsList,
                  IsList,
                  IsFunction ];

#############################################################################
##

#O  ExternalSet( <G>, <D>, [<gens>,<oprs>,] <opr> ) .  construct external set
##
##  If <gens> and  <oprs> are specified, <gens>  must be a generating set for
##  <G>, and the operation is $(d,gens[i]) -> opr(d,oprs[i])$.
##
ExternalSet := NewOperationArgs( "ExternalSet" );
ExternalSetOp := NewOperation( "ExternalSet", OrbitsishReq );
ExternalSetAttr := NewAttribute( "ExternalSet", IsGroup );
                                    # properly: ^IsExternalSet
ExternalSetByFilterConstructor := NewOperationArgs
                                  ( "ExternalSetByFilterConstructor" );
ExternalSetByTypeConstructor := NewOperationArgs
                                ( "ExternalSetByTypeConstructor" );

#############################################################################
##
#O  ExternalSubset( <G>, <D>, <start>, [<gens>,<oprs>,] <opr> ) . . . . . . .
##
##  constructs the external subset on the union of orbits of <start>.
##
ExternalSubset := NewOperationArgs( "ExternalSubset" );
ExternalSubsetOp := NewOperation( "ExternalSubset",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ] );

#############################################################################
##
#O  ExternalOrbit( <G>, <D>, <pnt>, [<gens>,<oprs>,] <opr> )  . . . . . . . .
##
##  constructs the external subset on the orbit of <pnt>.
##
ExternalOrbit := NewOperationArgs( "ExternalOrbit" );
ExternalOrbitOp := NewOperation( "ExternalOrbit", OrbitishReq );

Orbit := NewOperationArgs( "Orbit" );
OrbitOp := NewOperation( "Orbit", OrbitishReq );

Orbits := NewOperationArgs( "Orbits" );
OrbitsOp := NewOperation( "Orbits", OrbitsishReq );
OrbitsAttr := NewAttribute( "Orbits", IsExternalSet );

SparseOperationHomomorphism := NewOperationArgs
                               ( "SparseOperationHomomorphism" );
SparseOperationHomomorphismOp := NewOperation( "SparseOperationHomomorphismOp",
    OrbitishReq );

ExternalOrbits := NewOperationArgs( "ExternalOrbits" );
ExternalOrbitsOp := NewOperation( "ExternalOrbits", OrbitsishReq );
ExternalOrbitsAttr := NewAttribute( "ExternalOrbits", IsExternalSet );

ExternalOrbitsStabilizers := NewOperationArgs( "ExternalOrbitsStabilizers" );
ExternalOrbitsStabilizersOp := NewOperation( "ExternalOrbitsStabilizers",
                                       OrbitsishReq );
ExternalOrbitsStabilizersAttr := NewAttribute( "ExternalOrbitsStabilizers",
                                         IsExternalSet );

Permutation := NewOperationArgs( "Permutation" );
PermutationOp := NewOperation( "Permutation",
    [ IsObject, IsList, IsFunction ] );

PermutationCycle := NewOperationArgs( "PermutationCycle" );
PermutationCycleOp := NewOperation( "PermutationCycle",
    [ IsObject, IsList, IsObject, IsFunction ] );

Cycle := NewOperationArgs( "Cycle" );
CycleOp := NewOperation( "Cycle",
    [ IsObject, IsList, IsObject, IsFunction ] );

Cycles := NewOperationArgs( "Cycles" );
CyclesOp := NewOperation( "Cycles",
    [ IsObject, IsList, IsFunction ] );

Blocks := NewOperationArgs( "Blocks" );
BlocksOp := NewOperation( "Blocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ] );

MaximalBlocks := NewOperationArgs( "MaximalBlocks" );
MaximalBlocksOp := NewOperation( "MaximalBlocks",
    [ IsGroup, IsList, IsList,
      IsList,
      IsList,
      IsFunction ] );

OrbitLength := NewOperationArgs( "OrbitLength" );
OrbitLengthOp := NewOperation( "OrbitLength", OrbitishReq );

OrbitLengths := NewOperationArgs( "OrbitLengths" );
OrbitLengthsOp := NewOperation( "OrbitLengths", OrbitsishReq );
OrbitLengthsAttr := NewAttribute( "OrbitLengths", IsExternalSet );

CycleLength := NewOperationArgs( "CycleLength" );
CycleLengthOp := NewOperation( "CycleLength",
    [ IsObject, IsList, IsObject, IsFunction ] );

CycleLengths := NewOperationArgs( "CycleLengths" );
CycleLengthsOp := NewOperation( "CycleLengths",
    [ IsObject, IsList, IsFunction ] );

IsTransitive := NewOperationArgs( "IsTransitive" );
IsTransitiveOp := NewOperation( "IsTransitive", OrbitsishReq );
IsTransitiveProp := NewProperty( "IsTransitive", IsObject );

Transitivity := NewOperationArgs( "Transitivity" );
TransitivityOp := NewOperation( "Transitivity", OrbitsishReq );
TransitivityAttr := NewAttribute( "Transitivity", IsObject );

IsPrimitive := NewOperationArgs( "IsPrimitive" );
IsPrimitiveOp := NewOperation( "IsPrimitive", OrbitsishReq );
IsPrimitiveProp := NewProperty( "IsPrimitive", IsObject );

Earns := NewOperationArgs( "Earns" );
EarnsOp := NewOperation( "Earns", OrbitsishReq );
EarnsAttr := NewAttribute( "Earns", IsObject );

IsPrimitiveAffine := NewOperationArgs( "IsPrimitiveAffine" );
IsPrimitiveAffineOp := NewOperation( "IsPrimitiveAffine", OrbitsishReq );
IsPrimitiveAffineProp := NewProperty( "IsPrimitiveAffine", IsObject );

IsSemiRegular := NewOperationArgs( "IsSemiRegular" );
IsSemiRegularOp := NewOperation( "IsSemiRegular", OrbitsishReq );
IsSemiRegularProp := NewProperty( "IsSemiRegular", IsObject );

IsRegular := NewOperationArgs( "IsRegular" );
IsRegularOp := NewOperation( "IsRegular", OrbitsishReq );
IsRegularProp := NewProperty( "IsRegular", IsObject );

RepresentativeOperation := NewOperationArgs( "RepresentativeOperation" );
RepresentativeOperationOp := NewOperation( "RepresentativeOperation",
    [ IsGroup, IsList, IsObject, IsObject, IsFunction ] );

#############################################################################
##
#O  Stabilizer( <G>, <pnt>, <opr> ) . . . . . . . . . . . . . . . . . . . . .
#O  OrbitStabilizer( <G>, <pnt>, <opr> )  . . rec(orbit:=...,stabilizer:=...)
#A  StabilizerOfExternalSet( <xset> ) .  stabilizer of `Representative(xset)'
##
##  The stabilizer must have <G> as its parent.
##
Stabilizer := NewOperationArgs( "Stabilizer" );
StabilizerOp := NewOperation( "Stabilizer", OrbitishReq );

OrbitStabilizer := NewOperationArgs( "OrbitStabilizer" );
OrbitStabilizerOp := NewOperation( "OrbitStabilizer", OrbitishReq );

StabilizerOfExternalSet := NewAttribute( "StabilizerOfExternalSet",
                                   IsExternalSet );
SetStabilizerOfExternalSet := Setter( StabilizerOfExternalSet );
HasStabilizerOfExternalSet := Tester( StabilizerOfExternalSet );

AttributeOperation := NewOperationArgs( "AttributeOperation" );
OrbitishOperation := NewOperationArgs( "OrbitishOperation" );
OperationHomomorphism := NewOperationArgs( "OperationHomomorphism" );
OperationHomomorphismSubsetAsGroupGeneralMappingByImages := NewOperationArgs
    ( "OperationHomomorphismSubsetAsGroupGeneralMappingByImages" );
Operation := NewOperationArgs( "Operation" );
OperationOrbit := NewOperationArgs( "OperationOrbit" );
OrbitByPosOp := NewOperationArgs( "OrbitByPosOp" );
OrbitStabilizerByGenerators := NewOperationArgs
                               ( "OrbitStabilizerByGenerators" );
OrbitStabilizerListByGenerators := NewOperationArgs
                               ( "OrbitStabilizerListByGenerators" );
SetCanonicalRepresentativeOfExternalOrbitByPcgs :=
  NewOperationArgs( "SetCanonicalRepresentativeOfExternalOrbitByPcgs" );

#############################################################################
##

#F  StabilizerOfBlockNC( <G>, <B> )  . . . . block stabilizer for perm groups
##
StabilizerOfBlockNC := NewOperationArgs( "StabilizerOfBlockNC" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  oprt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
