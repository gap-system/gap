#############################################################################
##
#W  compat3b.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the parts of the {\GAP} 3 compatibility mode that
##  1) simulate the presence of `operations' records for domains, i.e.,
##     the access to `<D>.operations.<opr>' for domains <D> and operations
##     <opr> returns <opr>,
##  2) simulate the storing of attribute and property values as record
##     components in domains, i.e.,
##     `IsBound( <D>.<name> )' and access to `<D>.<name>' are interpreted as
##     calls to tester resp. getter of the attribute associated to <name>.
##  
##  This file is read only if the user explicitly reads it.
##
Revision.compat3b_g :=
    "@(#)$Id$";


#############################################################################
##
#A  Generators( <D> )
##
##  Fetch the right generators, depending on whether <D> is a group, a field,
##  a ring, an algebra, a unital algebra.
##
Generators := NewAttribute( "Generators", IsDomain );

InstallMethod( Generators, true, [ IsGroup ], 0,
    GeneratorsOfMagmaWithInverses );
InstallMethod( Generators, true, [ IsField ], 0,
    GeneratorsOfDivisionRing );
InstallMethod( Generators, true, [ IsRing ], 0,
    GeneratorsOfRing );
InstallMethod( Generators, true, [ IsAlgebra ], 0,
    GeneratorsOfAlgebra );
InstallMethod( Generators, true, [ IsAlgebraWithOne ], 0,
    GeneratorsOfAlgebraWithOne );


#############################################################################
##
#F  AssociateNameAttribute( <name>, <getter> )
##
##  The value of the attribute or property <getter> for the object <obj>
#T  with representation 'IsAttributeStoringRep' ?
##  shall be accessible 
##  as '<obj>.<name>'.
##
ATTR_GETTERS := [];
ATTR_SETTERS := [];
ATTR_TESTERS := [];

AssociateNameWithAttribute :=
    function( name, filter, getter, setter, tester, mutflag )
    local ALP, alp;
    ALP := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    alp := "abcdefghijklmnopqrstuvwxyz";
    name:= ShallowCopy( name );
    if name[1] in ALP then
      name[1]:= alp[ Position( ALP, name[1] ) ];
    fi;
    ATTR_GETTERS[ RNamObj(name) ] := getter;
    ATTR_SETTERS[ RNamObj(name) ] := setter;
    ATTR_TESTERS[ RNamObj(name) ] := tester;
end;

InstallAttributeFunction( AssociateNameWithAttribute );

InstallMethod( ELM_REC,
    true, [ IsObject, IsObject ], 0,
    function ( obj, rnam )
        if IsBound( ATTR_GETTERS[rnam] )  then
            return ATTR_GETTERS[rnam]( obj );
        else
            Error( "`", NameRNam( rnam ), "' is not an attribute" );
        fi;
    end );

InstallMethod( ASS_REC,
    true, [ IsObject, IsObject, IsObject ], 0,
    function ( obj, rnam, val )
        if IsBound( ATTR_SETTERS[rnam] )  then
            ATTR_SETTERS[rnam]( obj, val );
        else
            Error("this is not an attribute");
        fi;
    end );

InstallMethod( ISB_REC,
    true, [ IsObject, IsObject ], 0,
    function ( obj, rnam )
        if IsBound( ATTR_TESTERS[rnam] )  then
            return ATTR_TESTERS[rnam]( obj );
        else
            Error("this is not an attribute");
        fi;
    end );


#############################################################################
##
##  Handle some names that have changed.
##
AssociateNameAttribute := function ( name, getter )
    AssociateNameWithAttribute( name, Ignore,
        getter, Setter(getter), Tester(getter), true );
end;

AssociateNameAttribute( "elements", Elements );
AssociateNameAttribute( "isAbelian", IsAbelian );
AssociateNameAttribute( "field", LeftActingDomain );

AssociateNameAttribute( "automorphisms", AutomorphismsOfTable );
AssociateNameAttribute( "blocks", BlocksInfo );
AssociateNameAttribute( "centralizers", SizesCentralizers );
AssociateNameAttribute( "classes", SizesConjugacyClasses );
AssociateNameAttribute( "classnames", ClassNames );
AssociateNameAttribute( "fusions", ComputedClassFusions );
AssociateNameAttribute( "fusionsource", NamesOfFusionSources );
AssociateNameAttribute( "group", UnderlyingGroup );
AssociateNameAttribute( "identifier", Identifier );
AssociateNameAttribute( "irreducibles", Irr );
AssociateNameAttribute( "orders", OrdersClassRepresentatives );
AssociateNameAttribute( "powermap", ComputedPowerMaps );
AssociateNameAttribute( "prime", UnderlyingCharacteristic );
AssociateNameAttribute( "text", InfoText );


#############################################################################
##
#V  OPS
#A  Operations( <D> )
##
##  Simulate the presence of an `operations' record in an object.
##  For that, we define one global variable `OPS' that stands for 
##  all operations records of {\GAP-3}.
##  This is a record whose components are the `operations' in the sense of
##  {\GAP-3},
##  with values the appropriate operations of {\GAP-4}.
##
##  The access to `<D>.operations' is handled by an attribute 'Operations'
##  that returns `OPS'.
##
OPS := rec();

Operations := NewAttribute( "Operations", IsObject, "mutable" );

InstallMethod( Operations, true, [ IsObject ], 0, obj -> OPS );



AgGroupHomomorphismOps := OPS;
AgGroupOps := OPS;
AlgebraElementsOps := OPS;
AlgebraHomomorphismByImagesOps := OPS;
AlgebraHomomorphismOps := OPS;
AlgebraOps := OPS;
BasisMatAlgebraOps := OPS;
BasisQuotientRowSpaceOps := OPS;
BasisRowSpaceOps := OPS;
BlocksHomomorphismOps := OPS;
BrauerTableOps := OPS;
CanonicalBasisQuotientRowSpaceOps := OPS;
CanonicalBasisRowSpaceOps := OPS;
CharTableOps := OPS;
CharacterOps := OPS;
ClassFunctionOps := OPS;
ClassFunctionsOps := OPS;
CompositionAlgebraHomomorphismOps := OPS;
CompositionFieldHomomorphismOps := OPS;
CompositionGroupHomomorphismOps := OPS;
CompositionHomomorphismOps := OPS;
CompositionMappingOps := OPS;
ConjugacyClassGroupOps := OPS;
ConjugationGroupHomomorphismOps := OPS;
CyclotomicFieldOps := OPS;
CyclotomicsOps := OPS;
DirectProductElementOps := OPS;
DirectProductOps := OPS;
DirectProductPermGroupOps := OPS;
DomainOps := OPS;
EmbeddingDirectProductOps := OPS;
EmbeddingDirectProductPermGroupOps := OPS;
EmbeddingSemidirectProductOps := OPS;
FactorModuleOps := OPS;
FieldElementsOps := OPS;
FieldHomomorphismOps := OPS;
FieldMatricesOps := OPS;
FieldOps := OPS;
FiniteFieldElementsOps := OPS;
FiniteFieldMatricesOps := OPS;
FiniteFieldOps := OPS;
FpAlgebraElementOps := OPS;
FpAlgebraElementsOps := OPS;
FpAlgebraOps := OPS;
FreeModuleOps := OPS;
FrobeniusAutomorphismOps := OPS;
GaussianIntegersAsAdditiveGroupOps := OPS;
GaussianIntegersOps := OPS;
GaussianRationalsAsRingOps := OPS;
GaussianRationalsOps := OPS;
GroupHomomorphismByFunctionOps := OPS;
GroupHomomorphismByImagesOps := OPS;
GroupHomomorphismOps := OPS;
GroupOps := OPS;
IdentityAlgebraHomomorphismOps := OPS;
IdentityFieldHomomorphismOps := OPS;
IdentityGroupHomomorphismOps := OPS;
InverseMappingOps := OPS;
MOCTableOps := OPS;
MappingByFunctionOps := OPS;
MappingOps := OPS;
MappingsOps := OPS;
MatAlgebraOps := OPS;
MatGroupOps := OPS;
MatricesOps := OPS;
ModuleCosetOps := OPS;
ModuleOps := OPS;
NFAutomorphismOps := OPS;
NullAlgebraOps := OPS;
NumberFieldOps := OPS;
NumberRingOps := OPS;
OperationHomomorphismAlgebraOps := OPS;
OperationHomomorphismModuleOps := OPS;
OperationHomomorphismUnitalAlgebraOps := OPS;
PermAutomorphismGroupOps := OPS;
PermGroupHomomorphismByImagesOps := OPS;
PermGroupHomomorphismByImagesPermGroupOps := OPS;
PermGroupOps := OPS;
PreliminaryLatticeOps := OPS;
ProjectionDirectProductOps := OPS;
ProjectionDirectProductPermGroupOps := OPS;
ProjectionSemidirectProductOps := OPS;
ProjectionSubdirectProductOps := OPS;
ProjectionSubdirectProductPermGroupOps := OPS;
QuotientRowSpaceOps := OPS;
QuotientSpaceOps := OPS;
RationalClassGroupOps := OPS;
RationalsAsRingOps := OPS;
RationalsOps := OPS;
RingElementsOps := OPS;
RingOps := OPS;
RowModuleOps := OPS;
RowSpaceOps := OPS;
STMappingOps := OPS;
SemiEchelonBasisMatAlgebraOps := OPS;
SemiEchelonBasisQuotientRowSpaceOps := OPS;
SemiEchelonBasisRowSpaceOps := OPS;
SemidirectProductElementOps := OPS;
SemidirectProductOps := OPS;
SpaceCosetRowSpaceOps := OPS;
StandardBasisMatAlgebraOps := OPS;
StandardBasisModuleOps := OPS;
SubdirectProductOps := OPS;
SubdirectProductPermGroupOps := OPS;
TransConstHomomorphismOps := OPS;
UnitalAlgebraHomomorphismOps := OPS;
UnitalAlgebraOps := OPS;
UnitalMatAlgebraOps := OPS;
VectorSpaceOps := OPS;
VirtualCharacterOps := OPS;
WreathProductElementOps := OPS;
WreathProductOps := OPS;


OPS.AbelianInvariants := AbelianInvariants;
# OPS.AbsoluteIrreducibilityTest := AbsoluteIrreducibilityTest;
OPS.AffineOperation := function(G,x,y,z)
   return AffineOperation(GeneratorsOfGroup(G),x,y,z);
end;
# OPS.AgGroup := AgGroup;
# OPS.AgSubgroup := AgSubgroup;
OPS.Agemo := Agemo;
OPS.Algebra := Algebra;
# OPS.AlgebraHomomorphismByImages := AlgebraHomomorphismByImages;
# OPS.AlgebraicExtension := AlgebraicExtension;
OPS.AsAlgebra := AsAlgebra;
OPS.AsGroup := AsGroup;
# OPS.AsModule := AsModule;
OPS.AsRing := AsRing;
OPS.AsSpace := AsVectorSpace;
OPS.AsSubalgebra := AsSubalgebra;
OPS.AsSubgroup := AsSubgroup;
# OPS.AsSubmodule := AsSubmodule;
OPS.AsSubspace := AsSubspace;
OPS.AsUnitalAlgebra := AsAlgebraWithOne;
OPS.AsUnitalSubalgebra := AsSubalgebraWithOne;
# OPS.AscendingChain := AscendingChain;
# OPS.Associates := Associates;
# OPS.AutomorphismGroup := AutomorphismGroup;
OPS.Base := Base;
OPS.Basis := Basis;
# OPS.BergerCondition := BergerCondition;
OPS.Blocks := Blocks;
OPS.CanonicalBasis := CanonicalBasis;
# OPS.CanonicalCosetElement := CanonicalCosetElement;
# OPS.CanonicalRepresentative := CanonicalRepresentative;
OPS.Centralizer := Centralizer;
OPS.Centre := Centre;
OPS.Cgs := Pcgs;
# OPS.CharPol := CharPol;
OPS.CharTable := CharacterTable;
OPS.CharacterDegrees := CharacterDegrees;
OPS.CharacteristicPolynomial := CharacteristicPolynomial;
OPS.ChiefSeries := ChiefSeries;
OPS.Closure := Closure;
OPS.Coefficients := Coefficients;
# OPS.CollectorlessFactorGroup := CollectorlessFactorGroup;
OPS.Comm := Comm;
OPS.CommutatorFactorGroup := CommutatorFactorGroup;
OPS.CommutatorSubgroup := CommutatorSubgroup;
# OPS.CompanionMatrix := CompanionMatrix;
# OPS.Complement := Complement;
# OPS.Complementclasses := Complementclasses;
# OPS.Components := Components;
# OPS.CompositionFactors := CompositionFactors;
# OPS.CompositionLength := CompositionLength;
OPS.CompositionMapping := CompositionMapping;
OPS.CompositionSeries := CompositionSeries;
# OPS.CompositionSubgroup := CompositionSubgroup;
OPS.ConjugacyClass := ConjugacyClass;
OPS.ConjugacyClasses := ConjugacyClasses;
OPS.ConjugacyClassesMaximalSubgroups := ConjugacyClassesMaximalSubgroups;
OPS.ConjugacyClassesPerfectSubgroups := ConjugacyClassesPerfectSubgroups;
OPS.ConjugacyClassesSubgroups := ConjugacyClassesSubgroups;
OPS.ConjugateSubgroup := ConjugateSubgroup;
OPS.ConjugateSubgroups := ConjugateSubgroups;
OPS.Conjugates := Conjugates;
# OPS.Constituents := Constituents;
# OPS.CoprimeComplement := CoprimeComplement;
OPS.Core := Core;
# OPS.Cosets := Cosets;
OPS.Cycle := Cycle;
OPS.CycleLength := CycleLength;
OPS.CycleLengths := CycleLengths;
OPS.Cycles := Cycles;
# OPS.CyclicGroup := CyclicGroup;
OPS.DefaultField := DefaultField;
OPS.DefaultRing := DefaultRing;
# OPS.DefectApproximation := DefectApproximation;
OPS.Degree := Degree;
# OPS.DegreeOperation := DegreeOperation;
# OPS.Denominator := Denominator;
# OPS.Depth := Depth;
# OPS.Derivative := Derivative;
OPS.DerivedSeries := DerivedSeriesOfGroup;
OPS.DerivedSubgroup := DerivedSubgroup;
# OPS.Determinant := Determinant;
OPS.Difference := Difference;
# OPS.DihedralGroup := DihedralGroup;
OPS.Dimension := Dimension;
OPS.DimensionsLoewyFactors := DimensionsLoewyFactors;
# OPS.DirectProduct := DirectProduct;
OPS.Display := Display;
# OPS.DoubleCoset := DoubleCoset;
# OPS.DoubleCosets := DoubleCosets;
# OPS.DualMatGroupSagGroup := DualMatGroupSagGroup;
# OPS.DualModuleDescrSagGroup := DualModuleDescrSagGroup;
# OPS.Eigenvalues := Eigenvalues;
# OPS.ElementaryAbelianGroup := ElementaryAbelianGroup;
OPS.ElementaryAbelianSeries := ElementaryAbelianSeries;
OPS.Elements := Elements;
# OPS.EmbeddedPolynomial := EmbeddedPolynomial;
OPS.Embedding := Embedding;
# OPS.Enumeration := Enumeration;
# OPS.EquivalenceTest := EquivalenceTest;
OPS.EuclideanDegree := EuclideanDegree;
OPS.EuclideanQuotient := EuclideanQuotient;
OPS.EuclideanRemainder := EuclideanRemainder;
# OPS.EulerianFunction := EulerianFunction;
OPS.Exponent := Exponent;
# OPS.ExponentAgWord := ExponentAgWord;
# OPS.Exponents := Exponents;
# OPS.ExponentsAgWord := ExponentsAgWord;
# OPS.ExtraspecialGroup := ExtraspecialGroup;
OPS.FactorGroup := FactorGroup;
# OPS.Factorization := Factorization;
OPS.Factors := Factors;
OPS.Field := Field;
# OPS.Fingerprint := Fingerprint;
OPS.FittingSubgroup := FittingSubgroup;
# OPS.FixedSubmodule := FixedSubmodule;
OPS.FpAlgebra := FpAlgebra;
# OPS.FpGroup := FpGroup;
OPS.FrattiniSubgroup := FrattiniSubgroup;
OPS.FusionConjugacyClasses := FusionConjugacyClasses;
OPS.GaloisGroup := GaloisGroup;
# OPS.GaloisType := GaloisType;
OPS.Gcd := Gcd;
# OPS.GcdRepresentation := GcdRepresentation;
# OPS.GeneralLinearGroup := GeneralLinearGroup;
# OPS.GeneralUnitaryGroup := GeneralUnitaryGroup;
OPS.Group := Group;
OPS.GroupHomomorphismByImages := GroupHomomorphismByImages;
OPS.HallSubgroup := HallSubgroup;
OPS.IdentityMapping := IdentityMapping;
# OPS.Igs := Igs;
OPS.ImagesRepresentative := ImagesRepresentative;
OPS.Indeterminate := Indeterminate;
OPS.Index := Index;
OPS.Induced := Induced;
# OPS.InertiaSubgroup := InertiaSubgroup;
OPS.Int := Int;
OPS.InterpolatedPolynomial := InterpolatedPolynomial;
OPS.Intersection := Intersection;
OPS.InvariantForm := InvariantForm;
# OPS.InvariantSubspace := InvariantSubspace;
OPS.InverseMapping := InverseMapping;
# OPS.IrreducibilityTest := IrreducibilityTest;
# OPS.IrreducibleGeneratingSet := IrreducibleGeneratingSet;
OPS.IsAbelian := IsAbelian;
# OPS.IsAlgebraHomomorphism := IsAlgebraHomomorphism;
OPS.IsAssociated := IsAssociated;
# OPS.IsAutomorphism := IsAutomorphism;
OPS.IsBijection := IsBijection;
OPS.IsCentral := IsCentral;
OPS.IsCommutativeRing := IsCommutativeRing;
OPS.IsConjugate := IsConjugate;
# OPS.IsConsistent := IsConsistent;
OPS.IsCyclic := IsCyclic;
OPS.IsElementaryAbelian := IsElementaryAbelian;
# OPS.IsEndomorphism := IsEndomorphism;
# OPS.IsEpimorphism := IsEpimorphism;
# OPS.IsEquivalent := IsEquivalent;
# OPS.IsEquivalentOperation := IsEquivalentOperation;
OPS.IsEuclideanRing := IsEuclideanRing;
# OPS.IsFaithful := IsFaithful;
OPS.IsFieldHomomorphism := IsFieldHomomorphism;
OPS.IsFinite := IsFinite;
# OPS.IsFixpointFree := IsFixpointFree;
OPS.IsGroupHomomorphism := IsGroupHomomorphism;
# OPS.IsHomomorphism := IsHomomorphism;
OPS.IsInjective := IsInjective;
OPS.IsIntegralRing := IsIntegralRing;
# OPS.IsIrreducible := IsIrreducible;
# OPS.IsIsomorphism := IsIsomorphism;
OPS.IsMapping := IsMapping;
OPS.IsMonomial := IsMonomial;
# OPS.IsMonomorphism := IsMonomorphism;
OPS.IsNilpotent := IsNilpotent;
OPS.IsNormal := IsNormal;
# OPS.IsNormalExtension := IsNormalExtension;
# OPS.IsNormalized := IsNormalized;
OPS.IsPNilpotent := IsPNilpotent;
# OPS.IsParent := IsParent;
OPS.IsPerfect := IsPerfect;
OPS.IsPrime := IsPrime;
OPS.IsPrimitive := IsPrimitive;
OPS.IsRegular := IsRegular;
# OPS.IsSemiEchelonBasis := IsSemiEchelonBasis;
OPS.IsSemiRegular := IsSemiRegular;
OPS.IsSimple := IsSimple;
OPS.IsSolvable := IsSolvable;
# OPS.IsSubalgebra := IsSubalgebra;
OPS.IsSubgroup := IsSubgroup;
OPS.IsSubnormal := IsSubnormal;
OPS.IsSubset := IsSubset;
# OPS.IsSubspace := IsSubspace;
OPS.IsSurjective := IsSurjective;
OPS.IsTransitive := IsTransitive;
OPS.IsTrivial := IsTrivial;
OPS.IsUniqueFactorizationRing := IsUniqueFactorizationRing;
OPS.IsUnit := IsUnit;
OPS.IsZero := IsZero;
OPS.JenningsSeries := JenningsSeries;
OPS.Kernel := Kernel;
# OPS.KernelAlgebraHomomorphism := KernelAlgebraHomomorphism;
# OPS.KernelFieldHomomorphism := KernelFieldHomomorphism;
# OPS.KernelGroupHomomorphism := KernelGroupHomomorphism;
OPS.KroneckerProduct := KroneckerProduct;
# OPS.Lattice := Lattice;
OPS.LatticeSubgroups := LatticeSubgroups;
# OPS.LaurentPolynomialRing := LaurentPolynomialRing;
OPS.Lcm := Lcm;
# OPS.LeadingCoefficient := LeadingCoefficient;
# OPS.LeadingExponent := LeadingExponent;
# OPS.LeftCoset := LeftCoset;
# OPS.LeftCosets := LeftCosets;
# OPS.LeftTransversal := LeftTransversal;
OPS.LinearCombination := LinearCombination;
# OPS.LinearOperation := LinearOperation;
OPS.LowerCentralSeries := LowerCentralSeriesOfGroup;
# OPS.MatGroupSagGroup := MatGroupSagGroup;
OPS.MaximalBlocks := MaximalBlocks;
# OPS.MaximalElement := MaximalElement;
OPS.MaximalNormalSubgroups := MaximalNormalSubgroups;
OPS.MaximalSubgroups := MaximalSubgroups;
# OPS.MergedCgs := MergedCgs;
# OPS.MergedIgs := MergedIgs;
# OPS.MinPol := MinPol;
# OPS.MinimalGeneratingSet := MinimalGeneratingSet;
OPS.MinimalPolynomial := MinimalPolynomial;
# OPS.MinpolFactors := MinpolFactors;
# OPS.Module := Module;
# OPS.ModuleDescrSagGroup := ModuleDescrSagGroup;
# OPS.NaturalHomomorphism := NaturalHomomorphism;
# OPS.NaturalModule := NaturalModule;
OPS.Norm := Norm;
OPS.NormalClosure := NormalClosure;
OPS.NormalIntersection := NormalIntersection;
OPS.NormalSubgroups := NormalSubgroups;
# OPS.Normalize := Normalize;
# OPS.NormalizeIgs := NormalizeIgs;
# OPS.Normalized := Normalized;
OPS.Normalizer := Normalizer;
OPS.NormedVectors := NormedVectors;
OPS.NumberConjugacyClasses := NumberConjugacyClasses;
OPS.Omega := Omega;
# OPS.OnCanonicalCosetElements := OnCanonicalCosetElements;
OPS.One := One;
# OPS.OneCoboundaries := OneCoboundaries;
# OPS.OneCocycles := OneCocycles;
OPS.Operation := Operation;
OPS.OperationHomomorphism := OperationHomomorphism;
OPS.Orbit := Orbit;
OPS.OrbitLength := OrbitLength;
OPS.OrbitLengths := OrbitLengths;
OPS.Orbits := Orbits;
OPS.Order := Order;
OPS.PCentralSeries := PCentralSeries;
OPS.PCore := PCore;
# OPS.PRump := PRump;
OPS.Parent := Parent;
# OPS.PermGroup := PermGroup;
OPS.Permutation := Permutation;
OPS.PermutationCharacter := PermutationCharacter;
# OPS.PolyhedralGroup := PolyhedralGroup;
# OPS.Polynomial := Polynomial;
OPS.PolynomialRing := PolynomialRing;
OPS.PowerMapping := PowerMapping;
OPS.PowerMod := PowerMod;
OPS.PreImagesRepresentative := PreImagesRepresentative;
# OPS.PrefrattiniSubgroup := PrefrattiniSubgroup;
OPS.Print := Print;
OPS.Projection := Projection;
# OPS.ProperSubmodule := ProperSubmodule;
OPS.Quotient := Quotient;
OPS.QuotientMod := QuotientMod;
OPS.QuotientRemainder := QuotientRemainder;
# OPS.Radical := Radical;
OPS.Random := Random;
# OPS.Rank := Rank;
# OPS.RationalClass := RationalClass;
OPS.RationalClasses := RationalClasses;
# OPS.ReducedAgWord := ReducedAgWord;
# OPS.RelativeOrder := RelativeOrder;
# OPS.Representation := Representation;
OPS.Representative := Representative;
OPS.RepresentativeOperation := RepresentativeOperation;
# OPS.RepresentativesOperation := RepresentativesOperation;
OPS.RepresentativesPerfectSubgroups := RepresentativesPerfectSubgroups;
OPS.Restricted := Restricted;
# OPS.RightCoset := RightCoset;
# OPS.RightCosets := RightCosets;
# OPS.RightTransversal := RightTransversal;
OPS.Ring := Ring;
OPS.ScalarProduct := ScalarProduct;
OPS.SemiEchelonBasis := SemiEchelonBasis;
# OPS.SemidirectProduct := SemidirectProduct;
# OPS.SetPrintLevel := SetPrintLevel;
OPS.SiftedVector := SiftedVector;
OPS.Size := Size;
OPS.SizesConjugacyClasses := SizesConjugacyClasses;
# OPS.SmallestGenerators := SmallestGenerators;
# OPS.SpaceCoset := SpaceCoset;
# OPS.SpecialLinearGroup := SpecialLinearGroup;
# OPS.SpecialUnitaryGroup := SpecialUnitaryGroup;
OPS.StabChain := StabChain;
OPS.Stabilizer := Stabilizer;
OPS.StandardAssociate := StandardAssociate;
# OPS.StandardBasis := StandardBasis;
OPS.String := String;
# OPS.StructureConjugacyClasses := StructureConjugacyClasses;
OPS.Subalgebra := Subalgebra;
# OPS.SubdirectProduct := SubdirectProduct;
OPS.Subgroup := Subgroup;
# OPS.Submodule := Submodule;
OPS.SubnormalSeries := SubnormalSeries;
OPS.Subspace := Subspace;
OPS.SupersolvableResiduum := SupersolvableResiduum;
# OPS.SylowComplements := SylowComplements;
OPS.SylowSubgroup := SylowSubgroup;
OPS.SylowSystem := SylowSystem;
OPS.SymmetricGroup := SymmetricGroup;
# OPS.SymplecticGroup := SymplecticGroup;
# OPS.SystemNormalizer := SystemNormalizer;
# OPS.TableOfMarks := TableOfMarks;
OPS.Trace := Trace;
OPS.Transitivity := Transitivity;
# OPS.Transposed := Transposed;
OPS.TrivialSubalgebra := TrivialSubalgebra;
OPS.TrivialSubgroup := TrivialSubgroup;
OPS.Union := Union;
OPS.UnitalAlgebra := AlgebraWithOne;
OPS.UnitalSubalgebra := SubalgebraWithOne;
OPS.Units := Units;
OPS.UpperCentralSeries := UpperCentralSeriesOfGroup;
# OPS.Weight := Weight;
# OPS.WreathProduct := WreathProduct;
OPS.Zero := Zero;
OPS.\* := \*;
OPS.\+ := \+;
OPS.\- := \-;
OPS.\/ := \/;
OPS.\< := \<;
OPS.\= := \=;
OPS.\^ := \^;
OPS.\in := \in;
OPS.\mod := \mod;


#############################################################################
##
#E  compat3b.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here




