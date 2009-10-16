#############################################################################
##
#W  compat3b.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id: compat3b.g,v 4.26 2002/04/15 10:04:30 sal Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the parts of the {\GAP}~3 compatibility mode that
##  implement the following.
##
##  1) Enable to access attribute and property values via the `\.' operator,
##     that is, `IsBound( <D>.<name> )' and access to `<D>.<name>' are
##     interpreted as calls to tester resp. getter of the attribute
##     associated to <name>.
##
##  2) Admit to store/access/unbind ``private'' components of objects,
##     that is, components for which the {\GAP}~3 library did not provide
##     dispatcher functions, and for which there are no associated
##     attributes.
##
##  3) The conversion functions `PermGroup', `AgGroup', `FpGroup'
##     are implemented.
##
##  4) Simulate the presence of a {\GAP}~3 `operations' record in an object.
##
##  This file is read only if the user explicitly reads it.
##
Revision.compat3b_g :=
    "@(#)$Id: compat3b.g,v 4.26 2002/04/15 10:04:30 sal Exp $";


#############################################################################
##
##  The file `compat3a.g' must have been read before this file can be read.
##
if not IsBound( Revision.compat3a_g ) then
  ReadLib( "compat3a.g" );
fi;


#############################################################################
##
##  1) Enable to access attribute and property values via the `\.' operator,
##     that is, `IsBound( <D>.<name> )' and access to `<D>.<name>' are
##     interpreted as calls to tester resp. getter of the attribute
##     associated to <name>.
##

#############################################################################
##
#A  Generators( <D> )
##
##  Fetch the right generators, depending on whether <D> is a group, a field,
##  a ring, an algebra, a unital algebra.
##  This attribute will be used for access via `<D>.generators'.
##
DeclareAttribute( "Generators", IsDomain );

InstallMethod( Generators, "for a group", true, [ IsGroup ], 0,
    GeneratorsOfMagmaWithInverses );
InstallMethod( Generators, "for a field", true, [ IsField ], 0,
    GeneratorsOfDivisionRing );
InstallMethod( Generators, "for a ring", true, [ IsRing ], 0,
    GeneratorsOfRing );
InstallMethod( Generators, "for an algebra", true, [ IsAlgebra ], 0,
    GeneratorsOfAlgebra );
InstallMethod( Generators, "for an algebra-with-one", true,
    [ IsAlgebraWithOne ], 0,
    GeneratorsOfAlgebraWithOne );


#############################################################################
##
#M  <pol>.coefficients
#M  <pol>.valuation
##
##  We enable the access of coefficients list and valuation of univariate
##  Laurent polynomials via the new attributes `ULPCoefficients' and
##  `ULPValuation'.
##
DeclareAttribute( "ULPCoefficients", IsLaurentPolynomial );

InstallMethod( ULPCoefficients,
    "for a univariate Laurent polynomial",
    true,
    [ IsLaurentPolynomial ], 0,
    pol -> CoefficientsOfLaurentPolynomial( pol )[1] );


DeclareAttribute( "ULPValuation", IsLaurentPolynomial );

InstallMethod( ULPValuation,
    "for a univariate Laurent polynomial",
    true,
    [ IsLaurentPolynomial ], 0,
    pol -> CoefficientsOfLaurentPolynomial( pol )[2] );


#############################################################################
##
#F  AssociateNameAttribute( <name>, <getter> )
##
##  The value of the attribute or property <getter> for the object <obj>
#T  with representation `IsAttributeStoringRep' ?
##  shall be accessible as `<obj>.<name>'.
##
BindGlobal( "ATTR_GETTERS", [] );
BindGlobal( "ATTR_SETTERS", [] );
BindGlobal( "ATTR_TESTERS", [] );

BindGlobal( "AssociateNameWithAttribute",
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
end );

InstallAttributeFunction( AssociateNameWithAttribute );


#############################################################################
##
##  Handle the cases where component names are not obtained from the name of
##  the operation by turning the first letter to lowercase.
##
BindGlobal( "AssociateNameAttribute", function ( name, getter )
    AssociateNameWithAttribute( name, Ignore,
        getter, Setter(getter), Tester(getter), true );
end );

AssociateNameAttribute( "elements", AsSSortedList );
AssociateNameAttribute( "isAbelian", IsCommutative );
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
AssociateNameAttribute( "identity", One );

AssociateNameAttribute( "coefficients", ULPCoefficients );
AssociateNameAttribute( "valuation", ULPValuation );

AssociateNameAttribute( "vectordim", DimensionOfVectors );


#############################################################################
##
##  2) Admit to store/access/unbind ``private'' components of objects,
##     that is, components for which the {\GAP}~3 library did not provide
##     dispatcher functions, and for which there are no associated
##     attributes.
##

#############################################################################
##
#A  Compat3Info( <D> )
##
##  If <D> is an object in `IsAttributeStoringRep' then the user can store
##  ``private components of <D>'' via this record.
##
DeclareAttribute( "Compat3Info",
    IsAttributeStoringRep, "mutable" );


#############################################################################
##
#M  Compat3Info( <D> )
##
InstallMethod( Compat3Info,
    "for an object in `IsAttributeStoringRep'",
    true,
    [ IsAttributeStoringRep ], 0,
    D -> rec() );


#############################################################################
##
#M  \.( <D>, <name> )
#M  IsBound\.( <D>, <name> )
#M  \.\:\=( <D>, <name> )
#M  Unbind\.( <D>, <name> )
##
##  If an attribute is associated to <name> then
##  access, test for boundedness, and assignment are delegated to the
##  getter, tester, and setter of this attribute, respectively.
##  Otherwise it is assumed that the component with name <name> in the
##  record `Compat3Info( <D> )' is meant.
##
InstallMethod( \.,
    "for two objects (compatibility mode)",
    true,
    [ IsObject, IsObject ], 0,
    function ( obj, rnam )
      if IsBound( ATTR_GETTERS[rnam] )  then

        # The component is associated to an attribute.
        return ATTR_GETTERS[rnam]( obj );

      elif HasCompat3Info( obj ) then
        if IsBound( Compat3Info( obj ).( NameRNam( rnam ) ) ) then
          return Compat3Info( obj ).( NameRNam( rnam ) );
        else
          Error( "component `", NameRNam( rnam ), "' must have a value" );
        fi;
      else
        Error( "`", NameRNam( rnam ), "' is not an attribute" );
      fi;
    end );

InstallMethod( ISB_REC,
    "for two objects (compatibility mode)",
    true,
    [ IsObject, IsObject ], 0,
    function ( obj, rnam )
      if IsBound( ATTR_TESTERS[rnam] )  then
        return ATTR_TESTERS[rnam]( obj );
      else
        return     HasCompat3Info( obj )
               and IsBound( Compat3Info( obj ).( NameRNam( rnam ) ) );
      fi;
    end );

InstallMethod( ASS_REC,
    "for three objects (compatibility mode)",
    true,
    [ IsObject, IsObject, IsObject ], 0,
    function ( obj, rnam, val )
      if IsBound( ATTR_SETTERS[rnam] )  then
        ATTR_SETTERS[rnam]( obj, val );
      else
        Compat3Info( obj ).( NameRNam( rnam ) ):= val;
      fi;
    end );

InstallMethod( Unbind\.,
    "for two objects (compatibility mode)",
    true,
    [ IsObject, IsObject ], 0,
    function( obj, rnam )
      if IsBound( ATTR_GETTERS[rnam] )  then
        Error( "cannot unbind attribute values" );
      elif HasCompat3Info( obj ) then
        Unbind( Compat3Info( obj ).( NameRNam( rnam ) ) );
      fi;
    end );


#############################################################################
##
##  3) The conversion functions `PermGroup', `AgGroup', `FpGroup'
##     are implemented.
##

#############################################################################
##
#A  Comp3BijectionToOldGroup( <D> )
##
##  Attribute to store the old `.bijection' component.
##
DeclareAttribute("Comp3BijectionToOldGroup",IsDomain);

AssociateNameAttribute( "bijection", Comp3BijectionToOldGroup );


#############################################################################
##
#F  PermGroup       functions to convert the representation
#F  AgGroup
#F  FpGroup
##
BindGlobal( "ConversionFunctionFromIsomorphism", function( isomop )
  return
    function(G)
    local isom,img;
      isom:=isomop(G);
      img:=Image(isom);
      SetComp3BijectionToOldGroup(img,InverseGeneralMapping(isom));
      return img;
    end;
end );

BindGlobal( "PermGroup",
    ConversionFunctionFromIsomorphism( IsomorphismPermGroup ) );
BindGlobal( "AgGroup",
    ConversionFunctionFromIsomorphism( IsomorphismPcGroup ) );
BindGlobal( "FpGroup",
    ConversionFunctionFromIsomorphism( IsomorphismFpGroup ) );


#############################################################################
##
##  4) Simulate the presence of a {\GAP}~3 `operations' record in an object.
##
##  The compatibility mode of {\GAP}~4 supports the use of such `operations'
##  records for domains and as components of plain records.
##
#F  OperationsRecord( <name>, <parent> )
#F  OperationsRecord( <name> )
##
##  Operations records are created with the function `OperationsRecord'.
##  <name> is the name of the operations record, the optional argument
##  <parent> is the operations record from which the components shall be
##  inherited to the result.
##  The result <oprec> of `OperationsRecord' is mutable, one can assign
##  the function <fun> to the component <compname> of <oprec> via
##
#M  <oprec>.<compname>:= <fun>
##
##  and one can access this value via
##
#M  <oprec>.<compname>
##
##  Valid values of the second argument <parent> of `OperationsRecord' are
##  all objects created with `OperationsRecord'.
##  It is also possible to use a predefined operations records from the
##  {\GAP}~3 library, such as `DomainOps' and `GroupOps', but note that these
##  variables are immutable, so one can only access their components but one
##  cannot change them.
##
##  If <oprec> is an object constructed with `OperationsRecord' then one can
##  assign it to the component `operations' of a plain record or domain <D>
##  via
##
#M  <D>.operations := <oprec>
##
##  This has the effect that the functions in <oprec> are made available
##  as methods for the operations with names given by the component names,
##  when called with <D> as argument.
##  Note that it is *not* possible to assign an operations record to the
##  `operations' component of a domain that has already such a component.
##
##  Afterwards one can access <oprec> via
##
#M  <D>.operations
##
##  so the value of the component <name> of <oprec> is
##  `<D>.operations.<name>'.
##
##  The behaviour of a record <rec> and a domain <D> with `operations'
##  component is the following.
##
##  If the component `<rec>.operations.<name>' is bound, where <name>
##  is the name of an operation <opr>, then the call `<opr>( <rec> )'
##  will be translated into `<rec>.operations.<name>( <rec> )'.
##  If <opr> is an operation with more than one argument and <rec>
##  is the first argument then the call of <opr> is also translated
##  into a call of `<rec>.operations.<name>', with the same arguments.
##  Only the binary operations `\=', `\<', `\+', `\-', `\*', `\/',
##  `Comm', and `LeftQuotient' behave in a different way.
##  As in {\GAP}~3, if both operands are records with `operations'
##  component, the function in the *right* argument is called;
##  only if there is no such function then the function in the *left*
##  argument is called.
##  If the required component is not bound then an error is signalled.
##
##  For a *domain* <D> with operations record, this means the following.
##  If the component `<D>.operations.<name>' is bound, where <name>
##  is the name of an attribute <attr> such that the value of <attr>
##  for <D> is not yet known then the call `<attr>( <D> )' is
##  translated into `<D>.operations.<name>( <D> )', and the result
##  is stored in <D> as attribute value.
##  For an operation <opr> that is *not* an attribute, the above
##  statements about records hold.
##  If the operations record of <D> does not contain the required component
##  then the applicable {\GAP}~4 method of highest rank for the operation
##  is called.
##
##  Also if <D> is a domain to which *no* operations record has been
##  assigned then the access `<D>.operations' is possible.
##  The result is the immutable object `OPS', the values of its components
##  are the operations themselves; this object is also the value of the
##  variables that denote the predefined operations records of the {\GAP}~3
##  library, such as `DomainOps' and `GroupOps'.
##  So the call to `<D>.operations.Size( <D> )' will result in the call
##  `Size( <D> )'.
##
##  Note that it is *not* possible to get ``the best applicable method''
##  for `Size' via `<D>.operations.Size' since this method may call
##  `TryNextMethod', whereas `<D>.operations.Size( <D> )' should really be
##  the size of <D>.
##  Further note that the behaviour of domains can differ from the
##  usual {\GAP}~4 behaviour only if a user defined operations record
##  has been assigned to this domain; if no such operations record
##  has been assigned to it, the possibility to call
##  `<D>.operations.Size' means only an extension of the syntax.
##

#############################################################################
##
#V  OPERATION_RNAM  . . . . . . . . . . . . cache of operations via `RNamObj'
#V  RENAMED_OPERATIONS  . . . . . . . . . . . . .  list of renamed operations
##
##  Similar to the situation with the access of attribute values via compoent
##  names, there are cases where the operation name given by `NameFunction'
##  does not coincide with the component name used in {\GAP}~3 operations
##  records.
##
DeclareGlobalVariable( "OPERATION_RNAM",
    "list of operations, OPERATION_RNAM[n] = op. with name NameRNam(n)");
InstallFlushableValue( OPERATION_RNAM, [] );

BindGlobal( "RENAMED_OPERATIONS", [] );
Add( RENAMED_OPERATIONS, [ "Elements", AsSSortedList ] );
Add( RENAMED_OPERATIONS, [ "IsAbelian", IsCommutative ] );
Add( RENAMED_OPERATIONS, [ "Print", PrintObj ] );
Add( RENAMED_OPERATIONS, [ "\=", EQ ] );
Add( RENAMED_OPERATIONS, [ "\<", LT ] );
Add( RENAMED_OPERATIONS, [ "\+", SUM ] );
Add( RENAMED_OPERATIONS, [ "\-", DIFF ] );
Add( RENAMED_OPERATIONS, [ "\*", PROD ] );
Add( RENAMED_OPERATIONS, [ "\/", QUO ] );
Add( RENAMED_OPERATIONS, [ "\^", POW ] );
Add( RENAMED_OPERATIONS, [ "\in", IN ] );
Add( RENAMED_OPERATIONS, [ "\mod", MOD ] );
Add( RENAMED_OPERATIONS, [ "Comm", COMM ] );
Add( RENAMED_OPERATIONS, [ "LeftQuotient", LQUO ] );
Add( RENAMED_OPERATIONS, [ "Cgs", Pcgs ] ); # is this correct at all? what about an equivalent to Igs?
Add( RENAMED_OPERATIONS, [ "AsAlgebra", AsFLMLOR ] );
Add( RENAMED_OPERATIONS, [ "AsUnitalAlgebra", AsFLMLORWithOne ] );
Add( RENAMED_OPERATIONS, [ "AsSubalgebra", AsSubFLMLOR ] );
Add( RENAMED_OPERATIONS, [ "AsUnitalSubalgebra", AsSubFLMLORWithOne ] );
Add( RENAMED_OPERATIONS, [ "AsVectorSpace", AsLeftModule ] );
Add( RENAMED_OPERATIONS, [ "CharTable", CharacterTable ] );
Add( RENAMED_OPERATIONS, [ "One", ONE ] );
Add( RENAMED_OPERATIONS, [ "PowerMapping", POW ] );
Add( RENAMED_OPERATIONS, [ "TrivialSubalgebra",
         TrivialSubadditiveMagmaWithZero ] );
Add( RENAMED_OPERATIONS, [ "TrivialSubgroup", TrivialSubmagmaWithOne ] );
Add( RENAMED_OPERATIONS, [ "InverseMapping", InverseGeneralMapping ] );


#############################################################################
##
#F  OperationByString( <s> )  . . . . . . . . . . . . operation with name <s>
##
BindGlobal( "OperationByString", function( s )
    local n, p;

    # Treat "\<" in a special way because it is different from "<".
    if s = "\<" then
      n:= RNamObj( "<" );
    else
      n:= RNamObj( s );
    fi;

    if not IsBound( OPERATION_RNAM[n] ) then

      p:= PositionProperty( RENAMED_OPERATIONS, i -> i[1] = s );
      if p <> fail then

        # The name `s' is valid only in {\GAP}~3.
        OPERATION_RNAM[n]:= RENAMED_OPERATIONS[p][2];

      else
        p:= PositionProperty( OPERATIONS,
                i -> IsFunction(i) and NameFunction(i) = s );
        if p = fail then
#T also test variables created by DeclareGlobalFunction &c. ?
          OPERATION_RNAM[n]:= fail;
        else
          OPERATION_RNAM[n]:= OPERATIONS[p];
        fi;
      fi;
    fi;
    return OPERATION_RNAM[n];
end );


#############################################################################
##
#R  IsOperationsRecord( <oprec> )
##
##  representation for ``operations records''
##
DeclareRepresentation( "IsOperationsRecord",
    IsAttributeStoringRep,
    [ "FILTER", "COMPONENTS" ] );


#############################################################################
##
#M  \=( <oprec1>, <oprec2> )
##
InstallMethod( \=,
    "for two operations records",
    IsIdenticalObj,
    [ IsOperationsRecord, IsOperationsRecord ], 0,
    function( oprec1, oprec2 )
    return     oprec1!.FILTER = oprec2!.FILTER
           and oprec1!.COMPONENTS = oprec2!.COMPONENTS;
    end );


#############################################################################
##
#V  OperationsRecordFamily
##
BindGlobal( "OperationsRecordFamily", NewFamily( "OperationsRecordFamily",
    IsOperationsRecord ) );


#############################################################################
##
#V  OPS
##
##  We construct `OPS' directly, without using `OperationsRecord',
##  since we do not want to install methods with the assignments of
##  components.
##
##  We do not need components that correspond to operations, i.e. for which
##  there is an operation with same name or for which there is an entry in
##  `RENAMED_OPERATIONS'.
##
##  We need components for all {\GAP}~3 dispatchers that correspond to
##  simple functions in {\GAP}~4.
##
BindGlobal( "OPS",
    Objectify( NewType( OperationsRecordFamily, IsOperationsRecord ),
               rec( FILTER     := IsObject,
                    COMPONENTS := rec() ) ) );
SetName( OPS, "OPS" );


#############################################################################
##
##  Fill `OPS' with those components that are not operations.
##  Several components that were available in {\GAP}~3 have no analogue in
##  {\GAP}~4, they show up in the lines starting with a comment sign.
##
BindGlobal( "COPS", OPS!.COMPONENTS );

# COPS.AbsoluteIrreducibilityTest := AbsoluteIrreducibilityTest;
COPS.AffineOperation := function( G, x, y, z )
   return AffineOperation( GeneratorsOfGroup( G ), x, y, z); end;
# COPS.AgGroup := AgGroup;
# COPS.AgSubgroup := AgSubgroup;
COPS.Agemo := Agemo;
COPS.Algebra := Algebra;
COPS.AlgebraHomomorphismByImages := AlgebraHomomorphismByImages;
# COPS.AsModule := AsModule;
# COPS.AsSubmodule := AsSubmodule;
COPS.AscendingChain := AscendingChain;
COPS.Basis := Basis;
COPS.Blocks := Blocks;
# COPS.CanonicalCosetElement := CanonicalCosetElement;
# COPS.CanonicalRepresentative := CanonicalRepresentative;
COPS.Centralizer := Centralizer;
COPS.CharPol := CharPol;
COPS.CharacterDegrees := CharacterDegrees;
COPS.Closure := Closure;
# COPS.CollectorlessFactorGroup := CollectorlessFactorGroup;
# COPS.CompanionMatrix := CompanionMatrix;
# COPS.Complement := Complement;
# COPS.Components := Components;
# COPS.CompositionFactors := CompositionFactors;
# COPS.CompositionLength := CompositionLength;
COPS.CompositionMapping := CompositionMapping;
# COPS.CompositionSubgroup := CompositionSubgroup;
# COPS.Constituents := Constituents;
COPS.CoprimeComplement := OCCoprimeComplement;
COPS.Core := Core;
COPS.Cosets := RightCosets;
COPS.Cycle := Cycle;
COPS.CycleLength := CycleLength;
COPS.CycleLengths := CycleLengths;
COPS.Cycles := Cycles;
COPS.CyclicGroup := CyclicGroup;
COPS.DefaultField := DefaultField;
COPS.DefaultRing := DefaultRing;
# COPS.DefectApproximation := DefectApproximation;
COPS.Denominator := Denominator;
# COPS.Depth := Depth;
COPS.DihedralGroup := DihedralGroup;
COPS.DirectProduct := DirectProduct;
COPS.DoubleCosets := DoubleCosets;
# COPS.DualMatGroupSagGroup := DualMatGroupSagGroup;
# COPS.DualModuleDescrSagGroup := DualModuleDescrSagGroup;
COPS.ElementaryAbelianGroup := ElementaryAbelianGroup;
# COPS.EmbeddedPolynomial := EmbeddedPolynomial;
# COPS.Enumeration := Enumeration;
# COPS.EquivalenceTest := EquivalenceTest;
# COPS.ExponentAgWord := ExponentAgWord;
# COPS.Exponents := Exponents;
# COPS.ExponentsAgWord := ExponentsAgWord;
COPS.ExtraspecialGroup := ExtraspecialGroup;
# COPS.Factorization := Factorization;
COPS.Field := Field;
COPS.Fingerprint := Fingerprint;
# COPS.FixedSubmodule := FixedSubmodule;
# COPS.FpAlgebra := FpAlgebra;
# COPS.FpGroup := FpGroup;
COPS.FusionConjugacyClasses := FusionConjugacyClasses;
# COPS.GaloisType := GaloisType;
COPS.Gcd := Gcd;
COPS.GcdRepresentation := GcdRepresentation;
COPS.GeneralLinearGroup := GeneralLinearGroup;
COPS.GeneralUnitaryGroup := GeneralUnitaryGroup;
COPS.Group := Group;
COPS.GroupHomomorphismByImages := GroupHomomorphismByImages;
COPS.HallSubgroup := HallSubgroup;
# COPS.Igs := Igs;
COPS.Index := Index;
COPS.Intersection := Intersection;
# COPS.InvariantSubspace := InvariantSubspace;
# COPS.IrreducibilityTest := IrreducibilityTest;
# COPS.IrreducibleGeneratingSet := IrreducibleGeneratingSet;
# COPS.IsAutomorphism := IsAutomorphism;
COPS.IsBijection := IsBijection;
COPS.IsCommutativeRing := IsCommutative and IsRing;
# COPS.IsConsistent := IsConsistent;
# COPS.IsEndomorphism := IsEndomorphism;
# COPS.IsEpimorphism := IsEpimorphism;
# COPS.IsEquivalent := IsEquivalent;
# COPS.IsEquivalentOperation := IsEquivalentOperation;
# COPS.IsFaithful := IsFaithful;
# COPS.IsFixpointFree := IsFixpointFree;
COPS.IsGroupHomomorphism := IsGroupHomomorphism;
# COPS.IsHomomorphism := IsHomomorphism;
# COPS.IsIsomorphism := IsIsomorphism;
COPS.IsMapping := IsMapping;
# COPS.IsMonomorphism := IsMonomorphism;
COPS.IsNormal := IsNormal;
# COPS.IsNormalExtension := IsNormalExtension;
# COPS.IsNormalized := IsNormalized;
COPS.IsPNilpotent := IsPNilpotent;
# COPS.IsParent := IsParent;
COPS.IsPrimitive := IsPrimitive;
COPS.IsRegular := IsRegular;
# COPS.IsSemiEchelonBasis := IsSemiEchelonBasis;
COPS.IsSemiRegular := IsSemiRegular;
# COPS.IsSubalgebra := IsSubalgebra;
# COPS.IsSubspace := IsSubspace;
COPS.IsTransitive := IsTransitive;
# COPS.KernelAlgebraHomomorphism := KernelAlgebraHomomorphism;
# COPS.KernelFieldHomomorphism := KernelFieldHomomorphism;
# COPS.KernelGroupHomomorphism := KernelGroupHomomorphism;
# COPS.Lattice := Lattice;
# COPS.LaurentPolynomialRing := LaurentPolynomialRing;
COPS.Lcm := Lcm;
# COPS.LeadingExponent := LeadingExponent;
# COPS.LeftCoset := LeftCoset;
# COPS.LeftCosets := LeftCosets;
# COPS.LeftTransversal := LeftTransversal;
# COPS.MatGroupSagGroup := MatGroupSagGroup;
COPS.MaximalBlocks := MaximalBlocks;
# COPS.MaximalElement := MaximalElement;
# COPS.MergedCgs := MergedCgs;
# COPS.MergedIgs := MergedIgs;
COPS.MinPol := MinPol;
# COPS.MinpolFactors := MinpolFactors;
# COPS.Module := Module;
# COPS.ModuleDescrSagGroup := ModuleDescrSagGroup;
# COPS.NaturalHomomorphism := NaturalHomomorphism;
# COPS.NaturalModule := NaturalModule;
COPS.NormalClosure := NormalClosure;
# COPS.Normalize := Normalize;
# COPS.NormalizeIgs := NormalizeIgs;
# COPS.Normalized := Normalized;
COPS.Normalizer := Normalizer;
COPS.NumberConjugacyClasses := NumberConjugacyClasses;
COPS.Omega := Omega;
# COPS.OnCanonicalCosetElements := OnCanonicalCosetElements;
COPS.OneCoboundaries := OneCoboundaries;
COPS.OneCocycles := OneCocycles;
COPS.Operation := Operation;
COPS.OperationHomomorphism := OperationHomomorphism;
COPS.Orbit := Orbit;
COPS.OrbitLength := OrbitLength;
COPS.OrbitLengths := OrbitLengths;
COPS.Orbits := Orbits;
COPS.PCentralSeries := PCentralSeries;
COPS.PCore := PCore;
COPS.Parent := Parent;
# COPS.PermGroup := PermGroup;
COPS.Permutation := Permutation;
# COPS.PolyhedralGroup := PolyhedralGroup;
COPS.Polynomial := Polynomial;
# COPS.ProperSubmodule := ProperSubmodule;
COPS.PRump := PRump;
# COPS.Radical := Radical;
COPS.Rank := Rank;
# COPS.ReducedAgWord := ReducedAgWord;
# COPS.RelativeOrder := RelativeOrder;
# COPS.Representation := Representation;
COPS.RepresentativeOperation := RepresentativeOperation;
# COPS.RepresentativesOperation := RepresentativesOperation;
COPS.RightCosets := RightCosets;
COPS.RightTransversal := RightTransversal;
COPS.Ring := Ring;
COPS.SemiEchelonBasis := SemiEchelonBasis;
# COPS.SetPrintLevel := SetPrintLevel;
# COPS.SmallestGenerators := SmallestGenerators;
# COPS.SpaceCoset := SpaceCoset;
COPS.SpecialLinearGroup := SpecialLinearGroup;
COPS.SpecialUnitaryGroup := SpecialUnitaryGroup;
COPS.StabChain := StabChain;
COPS.Stabilizer := Stabilizer;
# COPS.StandardBasis := StandardBasis;
# COPS.StructureConjugacyClasses := StructureConjugacyClasses;
COPS.Subalgebra := Subalgebra;
COPS.Subgroup := Subgroup;
COPS.Submodule := Submodule;
COPS.SubnormalSeries := SubnormalSeries;
COPS.Subspace := Subspace;
# COPS.SylowComplements := SylowComplements;
COPS.SylowSubgroup := SylowSubgroup;
COPS.SymmetricGroup := SymmetricGroup;
COPS.SymplecticGroup := SymplecticGroup;
# COPS.SystemNormalizer := SystemNormalizer;
COPS.Transitivity := Transitivity;
# COPS.Transposed := Transposed;
COPS.Union := Union;
COPS.UnitalAlgebra := AlgebraWithOne;
COPS.UnitalSubalgebra := SubalgebraWithOne;
# COPS.Weight := Weight;

MakeImmutable( OPS );


#############################################################################
##
#F  OperationsRecord( <name> )
#F  OperationsRecord( <name>, <parent> )
##
##  The returned object <oprec> is a component object with components
##  `FILTER' and `COMPONENTS'.
##  The former is the filter associated with <oprec>,
##  the latter is a plain record whose components are the ones that had been
##  explicitly assigned to <oprec>.
##  *Note* that there will be for example no component `"Size"' in <oprec>
##  unless either <oprec> inherited it or it was explicitly assigned.
##  Nevertheless it is always possible to fetch `<oprec>.Size', which is
##  the operation `Size' itself if `<oprec>!.COMPONENTS' has no component
##  `"Size"'.
##
BindGlobal( "OperationsRecord", function( arg )

    local name,     # name of the operations record, first argument
          filt,     # new filter associated with the operations record
          oprec,    # the operations record, result
          parent;   # operations record from which the new one shall inherit

    # Create the filter that is associated with the new operations record.
    name:= arg[1];
    filt:= NewFilter( Concatenation( "Has", name ) );
    Print( "Has", name, " := NewFilter( \"Has", name, "\" );\n" );

    # Create the new operations record.
    oprec:= Objectify( NewType( OperationsRecordFamily,
                                IsOperationsRecord ),
                       rec() );
    SetName( oprec,name );
    oprec!.FILTER:= filt;

    # Handle inheritance.
    if Length( arg ) = 2 then

      parent:= arg[2];
      if not IsOperationsRecord( parent ) then
        Error( "<parent> must be an operations record" );
      elif not IsIdenticalObj( parent, OPS ) then

        # Copy the methods of the parent.
        oprec!.COMPONENTS:= ShallowCopy( parent!.COMPONENTS );

        # Handle inheritance also on the level of filters.
        InstallTrueMethod( arg[2]!.FILTER, filt );
        Print( "# Every object with `", NameFunction( filt ),
               "' shall have also `", NameFunction( parent!.FILTER ),
               "'.\n",
               "InstallTrueMethod( ", NameFunction( parent!.FILTER ),
               ", ", NameFunction( filt ), " );\n" );

      else

        oprec!.COMPONENTS:= rec();

      fi;

    else
      oprec!.COMPONENTS:= rec();
    fi;

    return oprec;
end );


#############################################################################
##
#O  Operations( <obj> )
##
DeclareAttribute( "Operations", IsObject, "mutable" );

InstallMethod( SetOperations,
    "for object with `OPS', allow to set another value",
    true,
    [ IsObject and HasOperations, IsOperationsRecord ], 0,
    function( obj, oprec )
    if IsIdenticalObj( Operations( obj ), OPS ) then
      ResetFilterObj( obj, HasOperations );
    fi;
    TryNextMethod();
    end );

InstallMethod( Operations,
    "for any object without `operations', return `OPS'",
    true,
    [ IsObject ], 0,
    obj -> OPS );


#############################################################################
##
#M  <obj>.operations := <oprec> . . . . . . . . . . . . . .  set `operations'
##
VALUE_RNAM_OPERATIONS := RNamObj( "operations" );

InstallMethod( \.\:\=,
    "set `operations' component of object in `IsAttributeStoringRep'",
    true,
    [ IsObject, IsPosInt, IsOperationsRecord ], 100,
    function( obj, n, oprec )

    # Check whether the desired component is really `operations'.
    if n <> VALUE_RNAM_OPERATIONS then
      TryNextMethod();
    fi;

    # Force setting the operations record,
    # and mark `obj' to make the methods of the operations record applicable.
    SetOperations( obj, oprec );
    SetFilterObj( obj, oprec!.FILTER );
    end );


#############################################################################
##
#M  \.( <oprec>, <name> ) . . . . . . . . . . . . . .  for operations records
##
##  First it is checked whether `<oprec>.COMPONENTS' has a component <name>.
##  If not then it is checked whether <name> is an admissible name of an
##  operation.
##
InstallMethod( \.,
    "for operations record and positive integer",
    true,
    [ IsOperationsRecord, IsPosInt ], 0,
    function( oprec, n )
    local op;
    n:= NameRNam( n );
    if IsBound( oprec!.COMPONENTS.( n ) ) then
      return oprec!.COMPONENTS.( n );
    elif not IsIdenticalObj( oprec, OPS )
         and IsBound( OPS!.COMPONENTS.( n ) ) then
      return OPS!.COMPONENTS.( n );
    else
      op:= OperationByString( n );
      if op = fail then
        Error( "no operation with name `", n, "'" );
      else
        return op;
      fi;
    fi;
    end );


#############################################################################
##
#M  IsBound\.( <oprec>, <name> )  . . . . . . . . . .  for operations records
##
InstallMethod( IsBound\.,
    "for operations record and positive integer",
    true,
    [ IsOperationsRecord, IsPosInt ], 0,
    function( oprec, n )
    n:= NameRNam( n );
    if IsBound( oprec!.COMPONENTS.( n ) ) then
      return true;
    elif not IsIdenticalObj( oprec, OPS )
         and IsBound( OPS!.COMPONENTS.( n ) ) then
      return true;
    else
      op:= OperationByString( n );
      if op = fail then
        return false;
      else
        return true;
      fi;
    fi;
    end );


#############################################################################
##
#M  \.\:\=( <oprec>, <name>, <val> )  . . . . . . . .  for operations records
##
InstallMethod( \.\:\=,
    "for operations record, positive integer, and function",
    true,
    [ IsOperationsRecord, IsPosInt, IsObject ], 0,
    function( oprec, n, method )
    local op, nargs, flags, flagsnames, i;

    # Store `method' in the record.
    n:= NameRNam( n );
    oprec!.COMPONENTS.( n ):= method;

    # Install a method for the operation.
    op:= OperationByString( n );
    if op <> fail then

      # We must know the number of arguments.
      nargs:= NARG_FUNC( method );
      if nargs < 0 then
        Error( "currently no `arg' functions permitted" );
      fi;

      # Construct the list of requirements for the method.
      # In general we expect the object with operations record `oprec'
      # to be the first operand.
      # For the other operands, we do not require anything.
      flags:= [ oprec!.FILTER ];
      flagsnames:= Concatenation( "[ ", NameFunction( oprec!.FILTER ) );
      for i in [ 2 .. nargs ] do
        Add( flags, IsObject );
        Append( flagsnames, ", IsObject" );
      od;
      Append( flagsnames, " ]" );

      # Add the leading backslash of the operation name if necessary.
      if n in [ "=", "<", "+", "-", "*", "/", "^", "mod", "in" ] then
        n:= Concatenation( "\\", n );
      fi;

      # Install the method.
      # Note that we call `InstallOtherMethod' in order to avoid
      # the error message, even if `InstallMethod' would work.
      # Also note that we use the rank `SUM_FLAGS' in order to override
      # (hopefully) all methods for objects without operations record.
      InstallOtherMethod( op,
          Concatenation( "for object with `", Name( oprec ),
                         "' as first argument" ),
          flags, SUM_FLAGS,
          method );

      # Print the method installation.
      Print( "# If the following method installation matches the",
             " requirements\n",
             "# of the operation `", NameFunction( op ), "' then",
             " `InstallMethod' should be used.\n",
             "# It might be useful to replace the rank `SUM_FLAGS' by `0'.\n",
             "InstallOtherMethod( ", NameFunction( op ), ",\n",
             "    \"for object with `", Name( oprec ),
             "' as first argument\",\n",
             "    ", flagsnames, ", SUM_FLAGS,\n",
             "    ", oprec, ".", n , " );\n\n" );

      # Note the different behaviour of the binary infix operations
      # `\=', `\<', `\+', `\-', `\*', `\/', `\^', `\mod', `LeftQuotient',
      # and `Comm', which check first the right operand and then the left;
      # in particular, we install an appropriate second method in these cases.
      if op in [ \=, \<, \+, \-, \*, \/, \^, \mod, LeftQuotient, Comm ] then

        # Install the second method.
        InstallOtherMethod( op,
            Concatenation( "for object with `", Name( oprec ),
                "' as second argument" ),
            [ IsObject, oprec!.FILTER ], SUM_FLAGS + 1,
            method );

        # Print the method installation.
        Print( "# For binary infix operators, a second method is installed\n",
               "# for the case that the object with `", Name( oprec ),
               "' is the right operand;\n",
               "# since this case has priority on GAP 3, the method is\n",
               "# installed with higher rank `SUM_FLAGS + 1'.\n",
               "InstallOtherMethod( ", NameFunction( op ), ",\n",
               "    \"for object with `", Name( oprec ),
               "' as second argument\",\n",
               "    [ IsObject, ", NameFunction( oprec!.FILTER ),
               " ], SUM_FLAGS + 1,\n",
               "    ", oprec, ".", n, " );\n\n" );

      elif op = PrintObj then

        # Install a method for `ViewObj'.
        InstallOtherMethod( ViewObj,
            Concatenation( "for object with `", Name( oprec ),
                "' as first argument" ),
            flags, SUM_FLAGS,
            method );

        # Print the method installation.
        Print( "# For printing objects, ",
               "also a `ViewObj' method is installed.\n",
               "InstallOtherMethod( ViewObj,\n",
               "    \"for object with `", Name( oprec ),
               "' as first argument\",\n",
               "    ", flagsnames, ", SUM_FLAGS,\n",
               "    ", oprec, ".", n, " );\n\n" );

      fi;

    fi;
    end);


#############################################################################
##
#F  RecFields( <oprec> )
##
##  For an operations record, `RecFields' is the return value of `RecNames'
##  when called with `<oprec>!.COMPONENTS'.
##
MakeReadWriteGlobal( "RecFields" );
UnbindGlobal( "RecFields" );
BindGlobal( "RecFields", function( obj )
    if IsOperationsRecord( obj ) then
      return RecNames( obj!.COMPONENTS );
    elif IsRecord( obj ) then
      return RecNames( obj );
    else
      Error( "<obj> must be a record" );
    fi;
end );


#############################################################################
##
#F  IsRec( <oprec> )
##
##  true records and component objects may be considered as `GAP3-records'.
##
MakeReadWriteGlobal( "IsRec" );
UnbindGlobal( "IsRec" );
BindGlobal( "IsRec", obj -> IsRecord( obj ) or IsComponentObjectRep( obj ) );


#############################################################################
##
##  Make the predefined operations record of {\GAP}~3 available, all with
##  value `OPS'.
##
BindGlobal( "AgGroupHomomorphismOps", OPS );
BindGlobal( "AgGroupOps", OPS );
BindGlobal( "AlgebraElementsOps", OPS );
BindGlobal( "AlgebraHomomorphismByImagesOps", OPS );
BindGlobal( "AlgebraHomomorphismOps", OPS );
BindGlobal( "AlgebraOps", OPS );
BindGlobal( "AlternatingPermGroupOps", OPS );
BindGlobal( "BasisClassFunctionsSpaceOps", OPS );
BindGlobal( "BasisMatAlgebraOps", OPS );
BindGlobal( "BasisQuotientRowSpaceOps", OPS );
BindGlobal( "BasisRowSpaceOps", OPS );
BindGlobal( "BlocksHomomorphismOps", OPS );
BindGlobal( "BrauerTableOps", OPS );
BindGlobal( "CanonicalBasisQuotientRowSpaceOps", OPS );
BindGlobal( "CanonicalBasisRowSpaceOps", OPS );
BindGlobal( "CharTableOps", OPS );
BindGlobal( "CharacterOps", OPS );
BindGlobal( "ClassFunctionOps", OPS );
BindGlobal( "ClassFunctionsOps", OPS );
BindGlobal( "CliffordRecordOps", OPS );
BindGlobal( "CliffordTableOps", OPS );
BindGlobal( "CompositionAlgebraHomomorphismOps", OPS );
BindGlobal( "CompositionFieldHomomorphismOps", OPS );
BindGlobal( "CompositionGroupHomomorphismOps", OPS );
BindGlobal( "CompositionHomomorphismOps", OPS );
BindGlobal( "CompositionMappingOps", OPS );
BindGlobal( "ConjugacyClassGroupOps", OPS );
BindGlobal( "ConjugationGroupHomomorphismOps", OPS );
BindGlobal( "CyclotomicFieldOps", OPS );
BindGlobal( "CyclotomicsOps", OPS );
BindGlobal( "DirectProductElementOps", OPS );
BindGlobal( "DirectProductOps", OPS );
BindGlobal( "DirectProductPermGroupOps", OPS );
BindGlobal( "DomainOps", OPS );
BindGlobal( "EmbeddingDirectProductOps", OPS );
BindGlobal( "EmbeddingDirectProductPermGroupOps", OPS );
BindGlobal( "EmbeddingSemidirectProductOps", OPS );
BindGlobal( "FactorModuleOps", OPS );
BindGlobal( "FieldElementsOps", OPS );
BindGlobal( "FieldHomomorphismOps", OPS );
BindGlobal( "FieldMatricesOps", OPS );
BindGlobal( "FieldOps", OPS );
BindGlobal( "FiniteFieldElementsOps", OPS );
BindGlobal( "FiniteFieldMatricesOps", OPS );
BindGlobal( "FiniteFieldOps", OPS );
BindGlobal( "FpAlgebraElementOps", OPS );
BindGlobal( "FpAlgebraElementsOps", OPS );
BindGlobal( "FpAlgebraOps", OPS );
BindGlobal( "FreeModuleOps", OPS );
BindGlobal( "FrobeniusAutomorphismOps", OPS );
BindGlobal( "GaussianIntegersAsAdditiveGroupOps", OPS );
BindGlobal( "GaussianIntegersOps", OPS );
BindGlobal( "GaussianRationalsAsRingOps", OPS );
BindGlobal( "GaussianRationalsOps", OPS );
BindGlobal( "GroupHomomorphismByFunctionOps", OPS );
BindGlobal( "GroupHomomorphismByImagesOps", OPS );
BindGlobal( "GroupHomomorphismOps", OPS );
BindGlobal( "GroupOps", OPS );
BindGlobal( "IdentityAlgebraHomomorphismOps", OPS );
BindGlobal( "IdentityFieldHomomorphismOps", OPS );
BindGlobal( "IdentityGroupHomomorphismOps", OPS );
BindGlobal( "InverseMappingOps", OPS );
BindGlobal( "MOCTableOps", OPS );
BindGlobal( "MappingByFunctionOps", OPS );
BindGlobal( "MappingOps", OPS );
BindGlobal( "MappingsOps", OPS );
BindGlobal( "MatAlgebraOps", OPS );
BindGlobal( "MatGroupOps", OPS );
BindGlobal( "MatricesOps", OPS );
BindGlobal( "ModuleCosetOps", OPS );
BindGlobal( "ModuleOps", OPS );
BindGlobal( "MolienSeriesOps", OPS );
BindGlobal( "NFAutomorphismOps", OPS );
BindGlobal( "NullAlgebraOps", OPS );
BindGlobal( "NumberFieldOps", OPS );
BindGlobal( "NumberRingOps", OPS );
BindGlobal( "OperationHomomorphismAlgebraOps", OPS );
BindGlobal( "OperationHomomorphismModuleOps", OPS );
BindGlobal( "OperationHomomorphismUnitalAlgebraOps", OPS );
BindGlobal( "OpsOps", OPS );
BindGlobal( "PermAutomorphismGroupOps", OPS );
BindGlobal( "PermGroupHomomorphismByImagesOps", OPS );
BindGlobal( "PermGroupHomomorphismByImagesPermGroupOps", OPS );
BindGlobal( "PermGroupOps", OPS );
BindGlobal( "PreliminaryLatticeOps", OPS );
BindGlobal( "PresentationOps", OPS );
BindGlobal( "ProjectionDirectProductOps", OPS );
BindGlobal( "ProjectionDirectProductPermGroupOps", OPS );
BindGlobal( "ProjectionSemidirectProductOps", OPS );
BindGlobal( "ProjectionSubdirectProductOps", OPS );
BindGlobal( "ProjectionSubdirectProductPermGroupOps", OPS );
BindGlobal( "QuotientRowSpaceOps", OPS );
BindGlobal( "QuotientSpaceOps", OPS );
BindGlobal( "RationalClassGroupOps", OPS );
BindGlobal( "RationalsAsRingOps", OPS );
BindGlobal( "RationalsOps", OPS );
BindGlobal( "RingElementsOps", OPS );
BindGlobal( "RingOps", OPS );
BindGlobal( "RowModuleOps", OPS );
BindGlobal( "RowSpaceOps", OPS );
BindGlobal( "STMappingOps", OPS );
BindGlobal( "SemiEchelonBasisMatAlgebraOps", OPS );
BindGlobal( "SemiEchelonBasisQuotientRowSpaceOps", OPS );
BindGlobal( "SemiEchelonBasisRowSpaceOps", OPS );
BindGlobal( "SemidirectProductElementOps", OPS );
BindGlobal( "SemidirectProductOps", OPS );
BindGlobal( "SpaceCosetRowSpaceOps", OPS );
BindGlobal( "StandardBasisMatAlgebraOps", OPS );
BindGlobal( "StandardBasisModuleOps", OPS );
BindGlobal( "SubdirectProductOps", OPS );
BindGlobal( "SubdirectProductPermGroupOps", OPS );
BindGlobal( "SymmetricPermGroupOps", OPS );
BindGlobal( "TransConstHomomorphismOps", OPS );
BindGlobal( "UnitalAlgebraHomomorphismOps", OPS );
BindGlobal( "UnitalAlgebraOps", OPS );
BindGlobal( "UnitalMatAlgebraOps", OPS );
BindGlobal( "VectorSpaceOps", OPS );
BindGlobal( "VirtualCharacterOps", OPS );
BindGlobal( "WreathProductElementOps", OPS );
BindGlobal( "WreathProductOps", OPS );


#############################################################################
##
#E

