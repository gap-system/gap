#############################################################################
##
#W  compat3.g                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definitions of
##  1. names,
##  2. methods,
##  3. functions
##  for the {\GAP-3} compatibility mode.
##
##  This file is read only if the user explicitly reads it.
##  *Note* that it is not possible to switch off the compatibility mode once
##  it has been loaded.
##
#T I think we should make the compatibility mode available only via a
#T command line option.
#T (This will be unavoidable if it involves changes in the kernel.)
##
#T If the handling of objects with operations records shall be supported
#T in GAP-4 then this should be done by the library (only in compatibility
#T mode), so the kernel can get rid of the corresponding code.
##
Revision.compat3_g :=
    "@(#)$Id$";


#############################################################################
##
##  1. names
##


#############################################################################
##
#V  fail
##
##  In the compatibility mode, 'fail' and 'false' are identical.
##  This is necessary to handle the different behaviour of e.g. 'Position'.
##  
fail := false;


#############################################################################
##
#F  CharFFE( <ffe> )  . . . . . . . . . . . . . . . . . characteristic of FFE
##
CharFFE := Characteristic;


#############################################################################
##
#F  Closure( <G>, <g> )
#F  Closure( <G>, <U> )
##
##  Handle the different closures for groups, modules, algebras,
##  and vector spaces.
##
Closure := function( D, E )
    if   IsAlgebra( D ) then
        return ClosureAlgebra( D, E );
    elif IsGroup( D ) then
        return ClosureGroup( D, E );
    elif IsVectorSpace( D ) then
        return ClosureLeftModule( D, E );
    fi;
end;


#############################################################################
##
#F  Elements( <D> )
##
Elements := AsListSorted;


#############################################################################
##
#F  IntCyc( <cyc> )
##
IntCyc := Int;


#############################################################################
##
#F  InverseMapping( <map> )
##
InverseMapping := Inverse;


#############################################################################
##
#F  IsBijection( <map> )
##
IsBijection := IsBijective;


#############################################################################
##
#F  IsCommutativeRing( <R> )
##
IsCommutativeRing := IsCommutative and IsRing;


#############################################################################
##
#F  IsSet( <list> )
##
IsSet := IsSSortedList;


#############################################################################
##
#F  Mod( <R>, <r>, <s> )
##
##  (was already obsolete in {\GAP}-3)
##
Mod := EuclideanRemainder;


#############################################################################
##
#F  OrderCyc( <cyc> ) . . . . . . . . . . . . . . . . . order of a cyclotomic
##
OrderCyc := Order;


#############################################################################
##
#F  PowerMapping( <map>, <n> )
##
PowerMapping := \^;


#############################################################################
##
#F  RandomInvertableMat( <n>, <F> )
##
RandomInvertableMat := RandomInvertibleMat;


#############################################################################
##
#F  RecFields( <record> )
##
RecFields := RecNames;


#############################################################################
##
#F  Sublist( <list>, <list> ) . . . . . . . . . . .  extract a part of a list
##
Sublist := ELMS_LIST;



#############################################################################
##
##  2. methods
##


#############################################################################
##
#M  Order( <D>, <elm> ) . . . . . . . . . . . . . . two argument order method
##
InstallOtherMethod( Order, true, [ IsObject, IsObject ], 0,
    function( D, elm )
    return Order( elm );
    end );


#############################################################################
##
#M  List( <obj> ) . . . . . . . . . . . . . . . . . . . . . convert to a list
##
##  In this version, <obj> may be a list, or a permutation, or any
##  object for that a method for 'List' is installed.
##
##  (Note the different behaviour in {\GAP-3} if the argument is a string;
##  but fortunately this was never documented.)
##
InstallOtherMethod( List, true, [ IsList ], SUM_FLAGS, IdFunc );

InstallOtherMethod( List, true, [ IsPerm ], SUM_FLAGS,
    function( perm )
    local lst, i;
    lst:= [];
    for i in [ 1 .. LargestMovedPointPerm( perm ) ] do
      lst[i]:= i ^ perm;
    od;
    return lst;
    end );



#############################################################################
##
##  3. functions
##


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
##  'Apply' will  apply <func>  to  every  member  of <list> and replaces  an
##  entry by the corresponding return value.  Warning:  The previous contents
##  of <list> will be lost.
##
Apply := function( list, func )
    local i;

    for i in [1..Length( list )] do
        list[i] := func( list[i] );
    od;
end;


#############################################################################
##
#F  CartesianProduct( <D>,... ) . . . . . .  cartesian product of collections
##
CartesianProduct := function ( arg )
    local   i;
    
    # unravel the arguments
    if Length(arg) = 1  and IsList( arg[1] )  then
        arg := ShallowCopy( arg[1] );
    fi;

    # make all domains into sets
    for i  in [1..Length(arg)]  do
        arg[i] := Elements( arg[i] );
    od;

    # make the cartesian product
    return Cartesian( arg );
end;


#############################################################################
##
#F  Equivalenceclasses( <list>, <function> )  . calculate equivalence classes
##
#T who invented this name? (fortunately, there is no help section yet)
#T (used only in 'agclass.g', with second argument 'IsIdentical')
##
##  returns
##
##      rec(
##          classes := <list>,
##          indices := <list>
##      )
##
Equivalenceclasses := function( list, isequal )

    local ecl, idx, len, new, i, j;

    len := 0;
    ecl := [];
    idx := [];
    for i in [1..Length( list )] do
        new := true;
        j   := 1;
        while new and j <= len do
            if isequal( list[i], ecl[j][1] ) then
                Add( ecl[j], list[i] );
                Add( idx[j], i );
                new := false;
            fi;
            j := j + 1;
        od;
        if new then
            len := len + 1;
            ecl[len] := [ list[i] ];
            idx[len] := [ i ];
        fi;
    od;
    return rec( classes := ecl, indices := idx );
end;


#############################################################################
##
#F  Gcd( [<R>,] <r1>, <r2>... ) . .  greatest common divisor of ring elements
##
##  Allow calls with arbitrarily many arguments.
##
if not IsBound( OLDGCD ) then
    OLDGCD := Gcd;
fi;

Gcd := function ( arg )
    local   R, ns, i, gcd;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := Sublist( arg, [2..Length(arg)] );        
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or Length(ns) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not ForAll( ns, n -> n in R )  then
            Error("<r> must be an element of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the gcd by iterating
    gcd := ns[1];
    for i  in [2..Length(ns)]  do
        gcd := OLDGCD( R, gcd, ns[i] );
    od;

    # return the gcd
    return gcd;
end;


#############################################################################
##
#F  GcdRepresentation( [<R>,] <r>, <s> )  . . . . . representation of the gcd
##
##  Allow calls with arbitrarily many arguments.
##
if not IsBound( OLDGCDREPRESENTATION ) then
    OLDGCDREPRESENTATION := GcdRepresentation;
fi;

GcdRepresentation := function ( arg )
    local   R, ns, i, gcd, rep, tmp;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := Sublist( arg, [2..Length(arg)] );        
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or Length(ns) = 0  then
        Error("usage: GcdRepresentation( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not ForAll( ns, n -> n in R )  then
            Error("<r> must be an element of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the gcd by iterating
    gcd := ns[1];
    rep := [ R.one ];
    for i  in [2..Length(ns)]  do
        tmp := OLDGCDREPRESENTATION ( R, gcd, ns[i] );
        gcd := tmp[1] * gcd + tmp[2] * ns[i];
        rep := List( rep, x -> x * tmp[1] );
        Add( rep, tmp[2] );
    od;

    # return the gcd representation
    return rep;
end;


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
#F  Lcm( [<R>,] <r1>, <r2>,.. ) .  least common multiple of two ring elements
##
##  Allow calls with arbitrarily many arguments.
##
if not IsBound( OLDLCM ) then
    OLDLCM := Lcm;
fi;

Lcm := function ( arg )
    local   ns,  R,  lcm,  i;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: Lcm( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := Sublist( arg, [2..Length(arg)] );        
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or Length(ns) = 0  then
        Error("usage: Lcm( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not ForAll( ns, n -> n in R )  then
            Error("<r> must be an element of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the least common multiple
    lcm := ns[1];
    for i  in [2..Length(ns)]  do
        lcm := OLDLCM( R, lcm, ns[i] );
    od;

    # return the lcm
    return lcm;
end;


#############################################################################
##
#F  NumberConjugacyClasses( <G> )
#F  NumberConjugacyClasses( <U>, <G> )
##
NumberConjugacyClasses := function( arg )

    # check that the argument is a group
    if not IsGroup( arg[1] )  then
      Error("<G> must be a group");
    fi;

    if Length( arg ) = 1 then

      # return number of conjugacy classes of 'arg[1]'
      return NrConjugacyClasses( arg[1] );

    elif Length( arg ) = 2 then

      # number of conjugacy classes of 'arg[2]' under the action of 'arg[1]'
      return NrConjugacyClassesInSupergroup( arg[1], arg[2] );

    else
      Error( "usage: NumberConjugacyClasses( [<U>, ]<H> )" );
    fi;

end;


#############################################################################
##
#F  String( <obj> )
#F  String( <obj>, <width> )
##
##  The problem with 'String' is that it is an attribute in {\GAP-4},
##  so we cannot deal with two argument methods.
##
if not IsBound( OLDSTRING ) then
    OLDSTRING := String;
fi;

String := function( arg )
    if Length( arg ) = 1 then
        return OLDSTRING( arg[1] );
    elif Length( arg ) = 2 then
        return FormattedString( arg[1], arg[2] );
    fi;
end;

StringInt    := OLDSTRING;
StringRat    := OLDSTRING;
StringCyc    := OLDSTRING;
StringFFE    := OLDSTRING;
StringPerm   := OLDSTRING;
StringAgWord := OLDSTRING;
StringBool   := OLDSTRING;
StringList   := OLDSTRING;
StringRec    := OLDSTRING;


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

AssociateNameAttribute := function ( name, getter )
    AssociateNameWithAttribute( name, Ignore,
        getter, Setter(getter), Tester(getter), true );
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
AssociateNameAttribute( "elements", Elements );
AssociateNameAttribute( "isAbelian", IsAbelian );


#############################################################################
##
#V  OPS
#A  Operations( <D> )
##
##  Allow to fetch functions from operations records.
##  For that, we define all operations records of {\GAP-3} to be one global
##  variable 'OPS'.
##  This is a record whose components are the ``operations'' of {\GAP-3},
##  with values the appropriate operations of {\GAP-4}.
##  The access to '<D>.operations' is handled by an attribute 'Operations'
##  that returns 'OPS'.
##
OPS := rec();

Operations := NewAttribute( "Operations", IsObject );

InstallMethod( Operations, true, [ IsObject ], 0, obj -> OPS );


AgGroupOps := OPS;
AgGroupHomomorphismOps := OPS;
CompositionHomomorphismOps := OPS;
AlgebraElementsOps := OPS;
AlgebraOps := OPS;
UnitalAlgebraOps := OPS;
FpAlgebraElementOps := OPS;
FpAlgebraOps := OPS;
FpAlgebraElementsOps := OPS;
AlgebraHomomorphismOps := OPS;
CompositionAlgebraHomomorphismOps := OPS;
IdentityAlgebraHomomorphismOps := OPS;
AlgebraHomomorphismByImagesOps := OPS;
UnitalAlgebraHomomorphismOps := OPS;
OperationHomomorphismAlgebraOps := OPS;
OperationHomomorphismUnitalAlgebraOps := OPS;
MatAlgebraOps := OPS;
BasisMatAlgebraOps := OPS;
SemiEchelonBasisMatAlgebraOps := OPS;
StandardBasisMatAlgebraOps := OPS;
NullAlgebraOps := OPS;
UnitalMatAlgebraOps := OPS;
CharTableOps := OPS;
PreliminaryLatticeOps := OPS;
BrauerTableOps := OPS;
ClassFunctionsOps := OPS;
ClassFunctionOps := OPS;
VirtualCharacterOps := OPS;
CharacterOps := OPS;
MOCTableOps := OPS;
DomainOps := OPS;
FieldOps := OPS;
FieldElementsOps := OPS;
FieldHomomorphismOps := OPS;
CompositionFieldHomomorphismOps := OPS;
IdentityFieldHomomorphismOps := OPS;
FiniteFieldOps := OPS;
FiniteFieldElementsOps := OPS;
FrobeniusAutomorphismOps := OPS;
GaussianIntegersOps := OPS;
GaussianIntegersAsAdditiveGroupOps := OPS;
GaussianRationalsOps := OPS;
GaussianRationalsAsRingOps := OPS;
GroupOps := OPS;
ConjugacyClassGroupOps := OPS;
RationalClassGroupOps := OPS;
GroupHomomorphismOps := OPS;
CompositionGroupHomomorphismOps := OPS;
IdentityGroupHomomorphismOps := OPS;
ConjugationGroupHomomorphismOps := OPS;
GroupHomomorphismByImagesOps := OPS;
GroupHomomorphismByFunctionOps := OPS;
DirectProductElementOps := OPS;
DirectProductOps := OPS;
EmbeddingDirectProductOps := OPS;
ProjectionDirectProductOps := OPS;
SubdirectProductOps := OPS;
ProjectionSubdirectProductOps := OPS;
SemidirectProductElementOps := OPS;
SemidirectProductOps := OPS;
EmbeddingSemidirectProductOps := OPS;
ProjectionSemidirectProductOps := OPS;
WreathProductElementOps := OPS;
WreathProductOps := OPS;
MappingOps := OPS;
CompositionMappingOps := OPS;
InverseMappingOps := OPS;
MappingByFunctionOps := OPS;
MappingsOps := OPS;
MatGroupOps := OPS;
MatricesOps := OPS;
FieldMatricesOps := OPS;
FiniteFieldMatricesOps := OPS;
ModuleOps := OPS;
StandardBasisModuleOps := OPS;
OperationHomomorphismModuleOps := OPS;
FactorModuleOps := OPS;
FreeModuleOps := OPS;
ModuleCosetOps := OPS;
PermAutomorphismGroupOps := OPS;
NumberFieldOps := OPS;
NFAutomorphismOps := OPS;
CyclotomicFieldOps := OPS;
NumberRingOps := OPS;
CyclotomicsOps := OPS;
PermGroupOps := OPS;
PermGroupHomomorphismByImagesOps := OPS;
PermGroupHomomorphismByImagesPermGroupOps := OPS;
TransConstHomomorphismOps := OPS;
BlocksHomomorphismOps := OPS;
DirectProductPermGroupOps := OPS;
EmbeddingDirectProductPermGroupOps := OPS;
ProjectionDirectProductPermGroupOps := OPS;
SubdirectProductPermGroupOps := OPS;
ProjectionSubdirectProductPermGroupOps := OPS;
RationalsOps := OPS;
RationalsAsRingOps := OPS;
RingOps := OPS;
RingElementsOps := OPS;
RowModuleOps := OPS;
RowSpaceOps := OPS;
BasisRowSpaceOps := OPS;
SemiEchelonBasisRowSpaceOps := OPS;
CanonicalBasisRowSpaceOps := OPS;
QuotientRowSpaceOps := OPS;
BasisQuotientRowSpaceOps := OPS;
SemiEchelonBasisQuotientRowSpaceOps := OPS;
CanonicalBasisQuotientRowSpaceOps := OPS;
SpaceCosetRowSpaceOps := OPS;
VectorSpaceOps := OPS;
QuotientSpaceOps := OPS;
STMappingOps := OPS;


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
# OPS.Cgs := Cgs;
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
# OPS.Degree := Degree;
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
# OPS.Induced := Induced;
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
# OPS.Kernel := Kernel;
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
# OPS.PermutationCharacter := PermutationCharacter;
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
# OPS.Restricted := Restricted;
# OPS.RightCoset := RightCoset;
# OPS.RightCosets := RightCosets;
# OPS.RightTransversal := RightTransversal;
OPS.Ring := Ring;
# OPS.ScalarProduct := ScalarProduct;
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
#E  compat3.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



