#############################################################################
##
#W  ctblfuns.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for class functions.
##
##  1. class functions as lists
##  2. comparison and arithmetic operations for class functions
##  3. methods for class function specific operations
##  4. methods for auxiliary operations
##  5. vector spaces of class functions
##
Revision.ctblfuns_gi :=
    "@(#)$Id$";


#T TODO: code of 'InertiaSubgroup'


#############################################################################
##
##  1. class functions as lists
##

#############################################################################
##
#M  \[\]( <psi>, <i> )
#M  Length( <psi> )
#M  IsBound\[\]( <psi>, <i> )
#M  Position( <psi>, <obj>, 0 )
##
##  Class functions shall behave as (immutable) lists,
##  we install methods for '\[\]', 'Length', 'IsBound\[\]', 'Position'.
##
InstallMethod( \[\],
    "method for class function and positive integer",
    true,
    [ IsClassFunction, IsInt and IsPosRat ], 0,
    function( chi, i )
    return ValuesOfClassFunction( chi )[i];
    end );

InstallMethod( Length,
    "method for class function",
    true,
    [ IsClassFunction ], 0,
    chi -> Length( ValuesOfClassFunction( chi ) ) );

InstallMethod( IsBound\[\],
    "method for class function and positive integer",
    true,
    [ IsClassFunction, IsInt and IsPosRat ], 0,
    function( chi, i )
    return IsBound( ValuesOfClassFunction( chi )[i] );
    end );

InstallMethod( Position,
    "method for class function, cyclotomic, and nonnegative integer",
    true,
    [ IsClassFunction, IsCyc, IsInt ], 0,
    function( chi, obj, pos )
    return Position( ValuesOfClassFunction( chi ), obj, pos );
    end );


#############################################################################
##
##  2. comparison and arithmetic operations for class functions
##

#############################################################################
##
#M  \=( <chi>, <psi> )  . . . . . . . . . . . . . equality of class functions
##
##  Two class functions in the same family belong necessarily to the same
##  (identical) character table.
##  If the families differ then we can compare the class functions only
##  if the underlying groups are known, namely we check whether the groups
##  are equal, and if yes then we take the conjugacy classes and compare the
##  values.
##
InstallMethod( \=,
    "method for two class functions (same family)",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    return ValuesOfClassFunction( chi ) = ValuesOfClassFunction( psi );
    end );

InstallMethod( \=,
    "method for two class functions (nonidentical families)",
    IsNotIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    if    not HasUnderlyingGroup( UnderlyingCharacterTable( chi ) )
       or not HasUnderlyingGroup( UnderlyingCharacterTable( psi ) ) then
      Error( "cannot compare class functions <chi> and <psi>" );
#T try degree or length or so?
    elif UnderlyingGroup( chi ) <> UnderlyingGroup( psi ) then
      return false;
    else
      return ForAll( ConjugacyClasses( UnderlyingGroup( chi ) ),
                     C -> C^chi = C^psi );
    fi;
    end );


#############################################################################
##
#M  \<( <chi>, <psi> )  . . . . . . . . . . . . comparison of class functions
##
InstallMethod( \<,
    "method for two class functions",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    return ValuesOfClassFunction( chi ) < ValuesOfClassFunction( psi );
    end );


#############################################################################
##
#M  \+( <chi>, <psi> )  . . . . . . . . . . . . . . .  sum of class functions
##
InstallMethod( \+,
    "method for two class functions",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    return ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) + ValuesOfClassFunction( psi ) );
    end );

InstallMethod( \+,
    "method for two virtual characters",
    IsIdentical,
    [ IsClassFunction and IsVirtualCharacter,
      IsClassFunction and IsVirtualCharacter ], 0,
    function( chi, psi )
    return VirtualCharacterByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) + ValuesOfClassFunction( psi ) );
    end );

InstallMethod( \+,
    "method for two characters",
    IsIdentical,
    [ IsClassFunction and IsCharacter,
      IsClassFunction and IsCharacter ], 0,
    function( chi, psi )
    return CharacterByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) + ValuesOfClassFunction( psi ) );
    end );


#############################################################################
##
#M  AdditiveInverse( <psi> )  . . . . . . . . . . . . .  for a class function
##
InstallMethod( AdditiveInverse,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    psi -> ClassFunctionByValues( UnderlyingCharacterTable( psi ),
               AdditiveInverse( ValuesOfClassFunction( psi ) ) ) );


InstallMethod( AdditiveInverse,
    "method for a virtual character",
    true,
    [ IsClassFunction and IsVirtualCharacter ], 0,
    psi -> VirtualCharacterByValues( UnderlyingCharacterTable( psi ),
               AdditiveInverse( ValuesOfClassFunction( psi ) ) ) );


#############################################################################
##
#M  Zero( <psi> ) . . . . . . . . . . . . . . . . . . .  for a class function
##
InstallMethod( Zero,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    psi -> VirtualCharacterByValues( UnderlyingCharacterTable( psi ),
               Zero( ValuesOfClassFunction( psi ) ) ) );


#############################################################################
##
#M  \-( <chi>, <psi> )  . . . . . . . . . . . . difference of class functions
##
InstallMethod( \-,
    "method for two class functions",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    return ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) - ValuesOfClassFunction( psi ) );
    end );

InstallMethod( \-,
    "method for two virtual characters",
    IsIdentical,
    [ IsVirtualCharacter, IsVirtualCharacter ], 0,
    function( chi, psi )
    return VirtualCharacterByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) - ValuesOfClassFunction( psi ) );
    end );


#############################################################################
##
#M  \*( <cyc>, <psi> )  . . . . . . . . . . scalar multiple of class function
##
InstallMethod( \*,
    "method for a cyclotomic and a class function",
    true,
    [ IsCyc, IsClassFunction ], 0,
    function( cyc, chi )
    return ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               cyc * ValuesOfClassFunction( chi ) );
    end );

InstallMethod( \*,
    "method for an integer and a virtual character",
    true,
    [ IsInt, IsVirtualCharacter ], 0,
    function( cyc, chi )
    return VirtualCharacterByValues( UnderlyingCharacterTable( chi ),
               cyc * ValuesOfClassFunction( chi ) );
    end );

InstallMethod( \*,
    "method for a positive integer and a character",
    true,
    [ IsInt and IsPosRat, IsCharacter ], 0,
    function( cyc, chi )
    return CharacterByValues( UnderlyingCharacterTable( chi ),
               cyc * ValuesOfClassFunction( chi ) );
    end );


#############################################################################
##
#M  \*( <psi>, <cyc> )  . . . . . . . . . . scalar multiple of class function
##
InstallMethod( \*,
    "method for class function and cyclotomic",
    true,
    [ IsClassFunction, IsCyc ], 0,
    function( chi, cyc )
    return ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) * cyc );
    end );

InstallMethod( \*,
    "method for virtual character and integer",
    true,
    [ IsVirtualCharacter, IsInt ], 0,
    function( chi, cyc )
    return VirtualCharacterByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) * cyc );
    end );

InstallMethod( \*,
    "method for character and positive integer",
    true,
    [ IsCharacter, IsInt and IsPosRat ], 0,
    function( chi, cyc )
    return CharacterByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) * cyc );
    end );


#############################################################################
##
#M  \/( <chi>, <cyc> )  . . . . . . . . . . . . . . .  divide by a cyclotomic
##
InstallMethod( \/,
    "method for class function and cyclotomic",
    true,
    [ IsClassFunction, IsCyc ], 0,
    function( chi, n )
    return ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               ValuesOfClassFunction( chi ) / n );
    end );


#############################################################################
##
#M  One( <psi> )  . . . . . . . . . . . . . . . . . . .  for a class function
##
InstallMethod( One,
    "method for class function",
    true,
    [ IsClassFunction ], 0,
    psi -> TrivialCharacter( UnderlyingCharacterTable( psi ) ) );


#############################################################################
##
#M  \*( <chi>, <cyc> )  . . . . . . . . . . tensor product of class functions
##
InstallMethod( \*,
    "method for two class functions",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    local valschi, valspsi;
    valschi:= ValuesOfClassFunction( chi );
    valspsi:= ValuesOfClassFunction( psi );
    return ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               List( [ 1 .. Length( valschi ) ],
                     x -> valschi[x] * valspsi[x] ) );
    end );

InstallMethod( \*,
    "method for two virtual characters",
    IsIdentical,
    [ IsVirtualCharacter, IsVirtualCharacter ], 0,
    function( chi, psi )
    local valschi, valspsi;
    valschi:= ValuesOfClassFunction( chi );
    valspsi:= ValuesOfClassFunction( psi );
    return VirtualCharacterByValues( UnderlyingCharacterTable( chi ),
               List( [ 1 .. Length( valschi ) ],
                     x -> valschi[x] * valspsi[x] ) );
    end );

InstallMethod( \*,
    "method for two characters",
    IsIdentical,
    [ IsCharacter, IsCharacter ], 0,
    function( chi, psi )
    local valschi, valspsi;
    valschi:= ValuesOfClassFunction( chi );
    valspsi:= ValuesOfClassFunction( psi );
    return CharacterByValues( UnderlyingCharacterTable( chi ),
               List( [ 1 .. Length( valschi ) ],
                     x -> valschi[x] * valspsi[x] ) );
    end );


#############################################################################
##
#M  Order( <chi> )  . . . . . . . . . . . . . . . . . . . determinantal order
##
##  Note that we are not allowed to regard the determinantal order of any
##  (virtual) character as order, since nonlinear characters do not have an
##  order as mult. elements.
##
InstallOtherMethod( Order,
    true,
    [ IsCharacter ], 0,
    function( chi )
    if DegreeOfCharacter( chi ) <> 1 then
      Error( "nonlinear character <chi> has no order" );
    fi;
    return Lcm( ValuesOfClassFunction( chi ), NofCyc );
    end );


#############################################################################
##
#M  \^( <chi>, <n> )  . . . . . . . . . . for class function and pos. integer
##
InstallOtherMethod( \^,
    "method for class function and positive integer",
    true,
    [ IsClassFunction, IsInt and IsPosRat ], 0,
    function( chi, n )
    return ClassFunctionSameType( UnderlyingCharacterTable( chi ),
               chi,
               List( ValuesOfClassFunction( chi ), x -> x ^ n ) );
    end );


#############################################################################
##
#M  \^( <chi>, <g> )  . . . . .  conjugate class function under action of <g>
##
##  If the underlying group $H$ of <chi> has a parent and knows the value of
##  'NormalizerInParent' then we use the information stored in
##  'PermClassesHomomorphism(' $H$ ')',
##  that is,
##  we write $g = \prod_i g_i^{a_i}$ in terms of the generators $g_i$ of $G$,
##  and compute the permutation $\pi_g = \prod_i \pi_{g_i}^{a_i}$, where the
##  $\pi_{g_i}$ have already been computed.
##
##  If <obj> just acts on $H$ via '\^' then we compute the
##  permutation of classes induced by this action in the same way as the
##  $\pi_{g_i}$ mentioned above are computed
##  (see 'CorrespondingPermutation').
##  
InstallMethod( \^,
    "method for class function with group, and group element",
    true,
    [ IsClassFunctionWithGroup, IsMultiplicativeElementWithInverse ], 0,
    function( chi, g )

    local G,      # underlying group
          perm;   # conjugating permutation

    G:= UnderlyingGroup( chi );

    if     HasParent( G ) and HasNormalizerInParent( G )
       and g in NormalizerInParent( G ) then

      # Compute the image of 'obj' under the homomorphism.
      perm:= Image( PermClassesHomomorphism( G ), g );

    else

      perm:= CorrespondingPermutation( chi, g );

    fi;

    return ClassFunctionSameType( G, chi,
               Permuted( ValuesOfClassFunction( chi ), perm ) );
    end );


#############################################################################
##
#M  \^( <chi>, <G> )  . . . . . . . . . . . . . . . .  induced class function
#M  \^( <chi>, <tbl> )  . . . . . . . . . . . . . . .  induced class function
##
InstallOtherMethod( \^,
    "method for class function with group, and group",
    true,
    [ IsClassFunctionWithGroup, IsGroup ], 0,
    InducedClassFunction );

InstallOtherMethod( \^,
    "method for class function and nearly character table",
    true,
    [ IsClassFunction, IsNearlyCharacterTable ], 0,
    InducedClassFunction );


#############################################################################
##
#M  \^( <chi>, <galaut> ) . . . Galois automorphism <galaut> applied to <chi>
##
InstallOtherMethod( \^,
    "method for class function and Galois automorphism",
    true,
    [ IsClassFunction, IsGeneralMapping and IsANFAutomorphismRep ], 0,
    function( chi, galaut )
    galaut:= galaut!.galois;
    return List( chi, x -> GaloisCyc( x, galaut ) );
    end );


#############################################################################
##
#M  \^( <g>, <chi> )  . . . . . . . . . . value of <chi> on group element <g>
##
InstallOtherMethod( \^,
    true,
    [ IsMultiplicativeElementWithInverse, IsClassFunctionWithGroup ], 0,
    function( g, chi )
    local ccl, i;
    if g in UnderlyingGroup( chi ) then
      ccl:= ConjugacyClasses( UnderlyingGroup( chi ) );
      for i in [ 1 .. Length( ccl ) ] do
        if g in ccl[i] then
          return ValuesOfClassFunction( chi )[i];
        fi;
      od;
    else
      Error( "<g> must lie in the underlying group of <chi>" );
    fi;
    end );


#############################################################################
##
#M  \^( <psi>, <chi> )  . . . . . . . . . .  conjugation of linear characters
##
InstallOtherMethod( \^,
    "method for two class functions (conjugation)",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )
    return chi;
    end );


#############################################################################
##
#M  Inverse( <chi> )  . . . . . . . . . . . . . . . . .  for a class function
##
InstallOtherMethod( Inverse,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    function( chi )
    local values;
    values:= List( ValuesOfClassFunction( chi ), Inverse );
    if fail in values then
      return fail;
    else
      return ClassFunctionByValues( UnderlyingCharacterTable(chi), values );
    fi;
    end );


#############################################################################
##
##  3. methods for class function specific operations
##

#############################################################################
##
#M  ClassFunctionsFamily( <tbl> )
##
InstallMethod( ClassFunctionsFamily,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )

    local Fam;      # the family, result

    # Make the family.
    if HasUnderlyingGroup( tbl ) then
      Fam:= NewFamily( "Class functions family", IsClassFunctionWithGroup );
    else
      Fam:= NewFamily( "Class functions family", IsClassFunction );
    fi;

    Fam!.char:= UnderlyingCharacteristic( tbl );
    Fam!.underlyingCharacterTable:= tbl;

    SetCharacteristic( Fam, 0 );

    return Fam;
    end );


#############################################################################
##
#M  One( <Fam> )  . . . . . . . . . . . . . . for a family of class functions
##
InstallOtherMethod( One,
    "method for a family of class functions",
    true,
    [ IsClassFunctionsFamily ], 0,
    Fam -> TrivialCharacter( Fam!.underlyingCharacterTable ) );


#############################################################################
##
#M  Zero( <Fam> ) . . . . . . . . . . . . . . for a family of class functions
##
InstallOtherMethod( Zero,
    "method for a family of class functions",
    true,
    [ IsClassFunctionsFamily ], 0,
    Fam -> Zero( One( Fam ) ) );


#############################################################################
##
#M  UnderlyingCharacterTable( <psi> ) . . . . . . . . .  for a class function
##
InstallMethod( UnderlyingCharacterTable,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    psi -> FamilyObj( psi )!.underlyingCharacterTable );


#############################################################################
##
#M  UnderlyingCharacteristic( <psi> ) . . . . . . . . .  for a class function
##
InstallOtherMethod( UnderlyingCharacteristic,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    psi -> FamilyObj( psi )!.char );


#############################################################################
##
#M  UnderlyingGroup( <psi> )  . . . . . . . . . . . . .  for a class function
##
InstallOtherMethod( UnderlyingGroup,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    psi -> UnderlyingGroup( FamilyObj( psi )!.underlyingCharacterTable ) );


#############################################################################
##
#M  PrintObj( <psi> ) . . . . . . . . . . . . . . . .  print a class function
##
InstallMethod( PrintObj,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    function( psi )
    Print( "ClassFunction( ", UnderlyingCharacterTable( psi ),
           ", ", ValuesOfClassFunction( psi ), " )" );
    end );

InstallMethod( PrintObj,
    "method for a class function with group",
    true,
    [ IsClassFunctionWithGroup ], 0,
    function( psi )
    Print( "ClassFunction( ", UnderlyingGroup( psi ),
           ", ", ValuesOfClassFunction( psi ) );
    if UnderlyingCharacteristic( psi ) <> 0 then
      Print( ", ", UnderlyingCharacteristic( psi ) );
    fi;
    Print( " )" );
    end );

InstallMethod( PrintObj,
    "method for a virtual character",
    true,
    [ IsClassFunction and IsVirtualCharacter ], 0,
    function( psi )
    Print( "VirtualCharacter( ", UnderlyingCharacterTable( psi ),
           ", ", ValuesOfClassFunction( psi ), " )" );
    end );

InstallMethod( PrintObj,
    "method for a virtual character with group",
    true,
    [ IsVirtualCharacter and IsClassFunctionWithGroup ], 0,
    function( psi )
    Print( "VirtualCharacter( ", UnderlyingGroup( psi ),
           ", ", ValuesOfClassFunction( psi ) );
    if UnderlyingCharacteristic( psi ) <> 0 then
      Print( ", ", UnderlyingCharacteristic( psi ) );
    fi;
    Print( " )" );
    end );

InstallMethod( PrintObj,
    "method for a character",
    true,
    [ IsClassFunction and IsCharacter ], 0,
    function( psi )
    Print( "Character( ", UnderlyingCharacterTable( psi ),
           ", ", ValuesOfClassFunction( psi ), " )" );
    end );

InstallMethod( PrintObj,
    "method for a character with group",
    true,
     [ IsClassFunctionWithGroup and IsCharacter ], 0,
    function( psi )
    Print( "Character( ", UnderlyingGroup( psi ),
           ", ", ValuesOfClassFunction( psi ) );
    if UnderlyingCharacteristic( psi ) <> 0 then
      Print( ", ", UnderlyingCharacteristic( psi ) );
    fi;
    Print( " )" );
    end );


#############################################################################
##
#M  Display( <chi> )  . . . . . . . . . . . . . . .  display a class function
#M  Display( <chi>, <arec> )
##
InstallOtherMethod( Display,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    function( chi )
    Display( UnderlyingCharacterTable( chi ), rec( chars:= [ chi ] ) );
    end );

InstallOtherMethod( Display,
    "method for a class function, and a record",
    true,
    [ IsClassFunction, IsRecord ], 0,
    function( chi, arec )
    arec:= ShallowCopy( arec );
    arec.chars:= [ chi ];
    Display( UnderlyingCharacterTable( chi ), arec );
    end );


#############################################################################
##
#M  IsVirtualCharacter( <chi> ) . . . . . . . . . . . .  for a class function
##
InstallMethod( IsVirtualCharacter,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    function( chi )

    local irr,
          psi,
          scpr;

    irr:= Irr( UnderlyingCharacterTable( chi ) );
    for psi in irr do
      scpr:= ScalarProduct( chi, psi );
      if not IsInt( scpr ) then
        return false;
      fi;
#T use NonnegIntScprs!!
    od;
    return true;
    end );


#############################################################################
##
#M  IsCharacter( <obj> )  . . . . . . . . . . . . . . for a virtual character
##
InstallMethod( IsCharacter,
    "method for a virtual character",
    true,
    [ IsClassFunction and IsVirtualCharacter ], 0,
    function( obj )

    local chi;

    # Proper characters have positive degree.
    if ValuesOfClassFunction( obj )[1] <= 0 then
      return false;
    fi;

    # Check the scalar products with all irreducibles.
    for chi in Irr( UnderlyingCharacterTable( obj ) ) do
      if ScalarProduct( chi, obj ) < 0 then
        return false;
      fi;
    od;
#T use NonnegIntScprs!
    return true;
    end );

InstallMethod( IsCharacter,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    function( obj )

    local irr,
          chi,
          scpr,
          foundneg;

    if HasIsVirtualCharacter( obj ) and not IsVirtualCharacter( obj ) then
      return false;
    fi;
#T can disappear when inverse implications are supported!

    # check also for virtual character
    foundneg:= false;
    for chi in Irr( UnderlyingCharacterTable( obj ) ) do
      scpr:= ScalarProduct( chi, obj );
      if not IsInt( scpr ) then
        SetIsVirtualCharacter( obj, false );
        return false;
      elif scpr < 0 then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  CentreOfCharacter( <chi> )  . . . . . . . . . . . . centre of a character
##
InstallMethod( CentreOfCharacter,
    "method for a character with group",
    true,
    [ IsClassFunctionWithGroup and IsCharacter ], 0,
    chi -> NormalSubgroupClasses( UnderlyingCharacterTable( chi ),
                                  CentreChar( chi ) ) );


#############################################################################
##
#M  CentreChar( <chi> )  . . . . . . . . classes in the centre of a character
##
InstallMethod( CentreChar,
    "method for a character",
    true,
    [ IsClassFunction and IsCharacter ], 0,
    chi -> CentreChar( ValuesOfClassFunction( chi ) ) );

InstallOtherMethod( CentreChar,
    "method for a homogeneous list of cyclotomics",
    true,
    [ IsHomogeneousList and IsCyclotomicsCollection ], 0,
    char -> Filtered( [ 1 .. Length( char ) ],
                     i -> char[i] = char[1] or
                          char[i] = - char[1] or
                          IsCyc( char[i] ) and ForAny( COEFFSCYC( char[i] ),
                                            x -> AbsInt( x ) = char[1] ) ) );


#############################################################################
##
#M  ConstituentsOfCharacter( <chi> )  . . . . .  irred. constituents of <chi>
##
InstallMethod( ConstituentsOfCharacter,
    true,
    [ IsClassFunction ], 0,
    function( chi )

    local irr,    # irreducible characters of underlying table of 'chi'
          const,  # list of constituents, result
          proper, # is 'chi' a proper character
          i,      # loop over 'irr'
          scpr;   # one scalar product

    const:= [];
    proper:= true;
    for i in Irr( UnderlyingCharacterTable( chi ) ) do
      scpr:= ScalarProduct( chi, i );
      if scpr <> 0 then
        Add( const, i );
        proper:= proper and IsInt( scpr ) and ( 0 < scpr );
      fi;
    od;

    # In the case 'proper = true' we know that 'chi' is a character.
    if proper then
      SetIsCharacter( chi, true );
    fi;

    return Set( const );
    end );

InstallMethod( ConstituentsOfCharacter,
    "method for a character",
    true,
    [ IsClassFunction and IsCharacter ], 0,
    function( chi )

    local irr,    # irreducible characters of underlying table of 'chi'
          values, # character values
          deg,    # degree of 'chi'
          const,  # list of constituents, result
          i,      # loop over 'irr'
          irrdeg, # degree of an irred. character
          scpr;   # one scalar product

    irr:= Irr( UnderlyingCharacterTable( chi ) );
    values:= ValuesOfClassFunction( chi );
    deg:= values[1];
    const:= [];
    i:= 1;
    while 0 < deg and i <= Length( irr ) do
      irrdeg:= DegreeOfCharacter( irr[i] );
      if irrdeg <= deg then
        scpr:= ScalarProduct( chi, irr[i] );
        if scpr <> 0 then
          deg:= deg - scpr * irrdeg;
          Add( const, irr[i] );
        fi;
      fi;
      i:= i+1;
    od;

    return Set( const );
    end );


#############################################################################
##
#M  DegreeOfCharacter( <chi> )  . . . . . . . . . . . . . . . for a character
##
InstallMethod( DegreeOfCharacter,
    "method for a character",
    true,
    [ IsClassFunction and IsCharacter ], 0,
    chi -> ValuesOfClassFunction( chi )[1] );


#############################################################################
##
#M  InertiaSubgroupInParent( <chi> )  . . . . . .  for a character with group
##
InstallMethod( InertiaSubgroupInParent,
    "method for a character",
    true,
    [ IsClassFunctionWithGroup and IsCharacter ], 0,
    function( chi )
    local G, N;
    G:= UnderlyingGroup( chi );
    if not HasParent( G ) then
      return G;
    fi;
    N:= NormalizerInParent( G );
    return InertiaSubgroup( chi, N );
    end );


#############################################################################
##
#M  KernelOfCharacter( <chi> )  . . . . . . . . . . . . . . . for a character
##
InstallMethod( KernelOfCharacter,
    "method for a character with group",
    true,
    [ IsClassFunctionWithGroup and IsCharacter ], 0,
    chi -> NormalSubgroupClasses( UnderlyingCharacterTable( chi ),
               KernelChar( ValuesOfClassFunction( chi ) ) ) );


#############################################################################
##
#M  KernelChar( <char> ) . . . . . . .  the set of classes forming the kernel
##
InstallMethod( KernelChar,
    "method for a character",
    true,
    [ IsClassFunction and IsCharacter ], 0,
    chi -> KernelChar( ValuesOfClassFunction( chi ) ) );

InstallOtherMethod( KernelChar,
    "method for a homogeneous list of cyclotomics",
    true,
    [ IsHomogeneousList and IsCyclotomicsCollection], 0,
    function( char )
    local degree;
    degree:= char[1];
    return Filtered( [ 1 .. Length( char ) ], x -> char[x] = degree );
    end );


#############################################################################
##
#M  TrivialCharacter( <G> ) . . . . . . . . . . . . . . . . . . . for a group
##
InstallOtherMethod( TrivialCharacter,
    "method for a group (delegate to the table)",
    true,
    [ IsGroup ], 0,
    G -> TrivialCharacter( OrdinaryCharacterTable( G ) ) );


#############################################################################
##
#M  TrivialCharacter( <tbl> ) . . . . . . . . . . . . . for a character table
##
InstallMethod( TrivialCharacter,
    "method for a character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> CharacterByValues( tbl, List( [ 1 .. NrConjugacyClasses( tbl ) ],
                                         x -> 1 ) ) );


#############################################################################
##
#M  NaturalCharacter( <G> ) . . . . . . . . . . . . . for a permutation group
##
InstallMethod( NaturalCharacter,
    "method for a permutation group",
    true,
    [ IsGroup and IsPermCollection ], 0,
    function( G )
    local deg;
    deg:= NrMovedPoints( G );
    return CharacterByValues( OrdinaryCharacterTable( G ),
               List( ConjugacyClasses( G ),
               C -> deg - NrMovedPointsPerm( Representative( C ) ) ) );
    end );


#############################################################################
##
#M  NaturalCharacter( <G> ) . . . . for a matrix group in characteristic zero
##
InstallMethod( NaturalCharacter,
    "method for a matrix group in characteristic zero",
    true,
    [ IsGroup and IsRingElementCollCollColl ], 0,
    function( G )
    if Characteristic( G ) = 0 then
      return CharacterByValues( OrdinaryCharacterTable( G ),
                 List( ConjugacyClasses( G ),
                       C -> TraceMat( Representative( C ) ) ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  PermutationCharacter( <G>, <U> )  . . . . . . . . . . . .  for two groups
##
InstallMethod( PermutationCharacter,
    "method for two groups (use double cosets)",
    IsIdentical,
    [ IsGroup, IsGroup ], 0,
    function( G, U )
    local C, c, s, i;

    C := ConjugacyClasses( G );
    c := [ Index( G, U ) ];
    s := Size( U );

    for i  in [ 2 .. Length(C) ]  do
      c[i]:= Number( DoubleCosets( G, U,
                         SubgroupNC( G, [ Representative( C[i] ) ] ) ),
                     x -> Size( x ) = s );
    od;

    # Return the character.
    return CharacterByValues( OrdinaryCharacterTable( G ), c );
    end );


#T #############################################################################
#T ##
#T #M  PermutationCharacter( <G>, <U> )  . . . . . . . . .  for two small groups
#T ##
#T InstallMethod( PermutationCharacter,
#T     "method for two small groups",
#T     IsIdentical,
#T     [ IsGroup and IsSmallGroup, IsGroup and IsSmallGroup ], 0,
#T     function( G, U )
#T     local E, I;
#T 
#T     E := AsList( U );
#T     I := Size( G ) / Length( E );
#T     return CharacterByValues( OrdinaryCharacterTable( G ),
#T         List( ConjugacyClasses( G ),
#T         C -> I * Length( Intersection2( AsList( C ), E ) ) / Size( C ) ) );
#T     end );


#############################################################################
##
#M  ClassFunctionByValues( <tbl>, <values> )
##
#T change this to return list objects!
##
InstallMethod( ClassFunctionByValues,
    "method for nearly character table, and coll. of cyclotomics",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, values )
    local chi;

    # Check the no. of classes if known.
    if     HasNrConjugacyClasses( tbl )
       and NrConjugacyClasses( tbl ) <> Length( values ) then
      Error( "no. of classes in <tbl> and <values> must be equal" );
    fi;

    chi:= Objectify( NewType( ClassFunctionsFamily( tbl ),
                                  IsClassFunction
                              and IsAttributeStoringRep ),
                     rec() );

    SetValuesOfClassFunction( chi, values );
    return chi;
    end );

InstallMethod( ClassFunctionByValues,
    "method for nearly character table with group, and coll. of cyclotomics",
    true,
    [ IsNearlyCharacterTable and HasUnderlyingGroup,
      IsList and IsCyclotomicsCollection ], 0,
    function( tbl, values )
    local chi;

    # Check the no. of classes if known.
    if     HasNrConjugacyClasses( tbl )
       and NrConjugacyClasses( tbl ) <> Length( values ) then
      Error( "no. of classes in <tbl> and <values> must be equal" );
    fi;

    chi:= Objectify( NewType( ClassFunctionsFamily( tbl ),
                                  IsClassFunctionWithGroup
                              and IsAttributeStoringRep ),
                     rec() );
    SetValuesOfClassFunction( chi, values );
    return chi;
    end );


#############################################################################
##
#M  VirtualCharacterByValues( <tbl>, <values> )
##
InstallMethod( VirtualCharacterByValues,
    "method for nearly character table, and coll. of cyclotomics",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, values )
    values:= ClassFunctionByValues( tbl, values );
    SetIsVirtualCharacter( values, true );
    return values;
    end );


#############################################################################
##
#M  CharacterByValues( <tbl>, <values> )
##
InstallMethod( CharacterByValues,
    "method for nearly character table, and coll. of cyclotomics",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, values )
    values:= ClassFunctionByValues( tbl, values );
    SetIsCharacter( values, true );
    return values;
    end );


#############################################################################
##
#F  ClassFunctionSameType( <tbl>, <chi>, <values> )
##
ClassFunctionSameType:=
    function( tbl, chi, values )
    if HasIsCharacter( chi ) and IsCharacter( chi ) then
      return CharacterByValues( tbl, values );
    elif HasIsVirtualCharacter( chi ) and IsVirtualCharacter( chi ) then
      return VirtualCharacterByValues( tbl, values );
    else
      return ClassFunctionByValues( tbl, values );
    fi;
end;


#############################################################################
##
#M  Norm( <chi> )  . . . . . . . . . . . . . . . . . . norm of class function
##
InstallOtherMethod( Norm,
    "method for a class function",
    true,
    [ IsClassFunction ], 0,
    chi -> ScalarProduct( chi, chi ) );


#############################################################################
##
#M  CentralCharacter( <chi> ) . . . . . . . . . . . . . . . . for a character
##
InstallMethod( CentralCharacter,
    "method for a character",
    true,
    [ IsClassFunction and IsCharacter ], 0,
    chi -> ClassFunctionByValues( UnderlyingCharacterTable( chi ),
               CentralChar( UnderlyingCharacterTable( chi ),
                            ValuesOfClassFunction( chi ) ) ) );


#############################################################################
##
#M  CentralChar( <tbl>, <char> )
##
InstallMethod( CentralChar,
    "method for a character table and a character",
    true,
    [ IsCharacterTable, IsClassFunction and IsCharacter ], 0,
    function( tbl, char )
    return CentralChar( tbl, ValuesOfClassFunction( char ) );
    end );

InstallOtherMethod( CentralChar,
    "method for a nearly character table and a homogeneous list",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, char )
    local classes;
    classes:= SizesConjugacyClasses( tbl );
    if Length( classes ) <> Length( char ) then
      Error( "<classes> and <char> must have same length" );
    fi;
    return List( [ 1 .. Length( char ) ],
                 x -> classes[x] * char[x] / char[1] );
    end );


##############################################################################
##
#M  DeterminantChar( <tbl>, <chi> )
##
##  The determinant is computed as follows.
##  Diagonalize the matrix; the determinant is the product of the diagonal
##  entries, which can be computed by 'Eigenvalues'.
##
##  Note that the determinant of a virtual character $\chi - \psi$ is
##  well-defined as the quotient of the determinants of the characters $\chi$
##  and $\psi$, since the determinant of a sum of characters is the product
##  of the determinants of the summands.
##  
InstallMethod( DeterminantChar,
    "method for a nearly character table and a class function",
    true,
    [ IsNearlyCharacterTable, IsClassFunction and IsVirtualCharacter ], 0,
    function( tbl, chi )
    return DeterminantChar( tbl, ValuesOfClassFunction( chi ) );
    end );

InstallOtherMethod( DeterminantChar,
    "method for a nearly character table and a homogeneous list",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, chi )
    local det,      # result list
          ev,       # eigenvalues
          ord,      # one element order
          i;        # loop over classes

    if chi[1] = 1 then
      return ShallowCopy( chi );
    fi;

    det:= [];

    for i in [ 1 .. Length( chi ) ] do

      ev:= EigenvaluesChar( tbl, chi, i );
      ord:= Length( ev );

      # The determinant is 'E(ord)' to the 'exp'-th power,
      # where $'exp' = \sum_{j=1}^{ord} j 'ev'[j]$.
      # (Note that the $j$-th entry in 'ev' is the multiplicity of
      # 'E(ord)^j' as eigenvalue.)
      det[i]:= E(ord) ^ ( [ 1 .. ord ] * ev );

    od;

    return det;
    end );
    

##############################################################################
##
#M  DeterminantOfCharacter( <chi> ) . . . . . . . . .  for a virtual character
##
InstallOtherMethod( DeterminantOfCharacter,
    "method for a virtual character",
    true,
    [ IsClassFunction and IsVirtualCharacter ], 0,
    chi -> CharacterByValues( UnderlyingCharacterTable( chi ),
               DeterminantChar( UnderlyingCharacterTable( chi ),
                                ValuesOfClassFunction( chi ) ) ) );


#############################################################################
##
#M  EigenvaluesChar( <tbl>, <char>, <class> )
##
InstallMethod( EigenvaluesChar,
    "method for a nearly character table, a class function, and a pos.",
    true,
    [ IsNearlyCharacterTable, IsClassFunction and IsCharacter,
      IsInt and IsPosRat ], 0,
    function( tbl, chi, class )
    return EigenvaluesChar( tbl, ValuesOfClassFunction( chi ), class );
    end );

InstallOtherMethod( EigenvaluesChar,
    "method for a nearly character table and a hom. list, and a pos.",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection,
      IsInt and IsPosRat ], 0,
    function( tbl, char, class )

    local i, j, n, powers, eigen, e, val;

    n:= OrdersClassRepresentatives( tbl )[ class ];
    if n = 1 then return [ char[ class ] ]; fi;

    # Compute necessary power maps and the restricted character.
    powers:= [];
    powers[n]:= char[1];
    for i in [ 1 .. n-1 ] do
      if not IsBound( powers[i] ) then

        # necessarily 'i' divides 'n', since 'i/Gcd(n,i)' is invertible
        # mod 'n', and thus powering with 'i' is Galois conjugate to
        # powering with 'Gcd(n,i)'
        powers[i]:= char[ PowerMap( tbl, i, class ) ];
        for j in PrimeResidues( n/i ) do

          # Note that the position cannot be 0.
          powers[ ( i*j ) mod n ]:= GaloisCyc( powers[i], j );
        od;
      fi;
    od;

    # compute the scalar products of the characters given by 'E(n)->E(n)^i'
    # with the restriction of <char> to the cyclic group generated by
    # <class>
    eigen:= [];
    for i in [ 1 .. n ] do
      e:= E(n)^(-i);
      val:= 0;
      for j in [ 1 .. n ] do val:= val + e^j * powers[j]; od;
      eigen[i]:= val / n;
    od;

    return eigen;
    end );


#############################################################################
##
#M  EigenvaluesChar( <chi>, <class> )
##
InstallOtherMethod( EigenvaluesChar,
    "method for a character and a positive integer",
    true,
    [ IsClassFunction, IsInt and IsPosRat ], 0,
    function( chi, class )
    if IsCharacter( chi ) then
      return EigenvaluesChar( UnderlyingCharacterTable( chi ),
                              ValuesOfClassFunction( chi ), class );
    else
      Error( "<chi> must be a character" );
    fi;
    end );


#############################################################################
##
#M  ScalarProduct( <chi>, <psi> ) . . . . . . . . . . for two class functions
##
InstallMethod( ScalarProduct,
    "method for two class functions",
    IsIdentical,
    [ IsClassFunction, IsClassFunction ], 0,
    function( chi, psi )

    local tbl, i, size, weights, scalarproduct;

    tbl:= UnderlyingCharacterTable( chi );
    size:= Size( tbl );
    weights:= SizesConjugacyClasses( tbl );
    chi:= ValuesOfClassFunction( chi );
    psi:= ValuesOfClassFunction( psi );
    scalarproduct:= 0;
    for i in [ 1 .. Length( weights ) ] do
      scalarproduct:= scalarproduct
                      + weights[i] * chi[i] * GaloisCyc( psi[i], -1 );
    od;

    return scalarproduct / size;
    end );


#############################################################################
##
#M  ScalarProduct( <tbl>, <chi>, <psi> ) .  scalar product of class functions
##
Is2Identical3 := function( F1, F2, F3 ) return IsIdentical( F2, F3 ); end;

InstallOtherMethod( ScalarProduct,
    "method for ordinary table and two class functions",
    Is2Identical3,
    [ IsOrdinaryTable, IsClassFunction, IsClassFunction ], 0,
    function( tbl, x1, x2 )

     local i,       # loop variable
           scpr,    # scalar product, result
           weight;  # lengths of conjugacy classes

     weight:= SizesConjugacyClasses( tbl );
     x1:= ValuesOfClassFunction( x1 );
     x2:= ValuesOfClassFunction( x2 );
     scpr:= 0;
     for i in [ 1 .. Length( x1 ) ] do
       scpr:= scpr + x1[i] * GaloisCyc( x2[i], -1 ) * weight[i];
     od;
     return scpr / Size( tbl );
     end );


#############################################################################
##
#M  ScalarProduct( <tbl>, <chivals>, <psivals> )
##
InstallOtherMethod( ScalarProduct,
    "method for ordinary table and two values lists",
    true,
    [ IsOrdinaryTable, IsHomogeneousList, IsHomogeneousList ], 0,
    function( tbl, x1, x2 )

     local i,       # loop variable
           scpr,    # scalar product, result
           weight;  # lengths of conjugacy classes

     weight:= SizesConjugacyClasses( tbl );
     scpr:= 0;
     for i in [ 1 .. Length( x1 ) ] do
       scpr:= scpr + x1[i] * GaloisCyc( x2[i], -1 ) * weight[i];
     od;
     return scpr / Size( tbl );
     end );


#############################################################################
##
#M  RestrictedClassFunction( <chi>, <H> )
#M  RestrictedClassFunction( <chi>, <tbl> )
##
InstallMethod( RestrictedClassFunction,
    "method for class function with group, and group",
    true,
    [ IsClassFunctionWithGroup, IsGroup ], 0,
    function( chi, H );
    return ClassFunctionSameType( H, chi, ValuesOfClassFunction( chi ){ 
               FusionConjugacyClasses( H, UnderlyingGroup( chi ) ) } );
    end );

InstallOtherMethod( RestrictedClassFunction,
    "method for class function and nearly character table",
    true,
    [ IsClassFunction, IsNearlyCharacterTable ], 0,
    function( chi, tbl )
    local fus;
    fus:= FusionConjugacyClasses( tbl, UnderlyingCharacterTable( chi ) );
    if fus = fail then
      Error( "class fusion not available" );
    fi;
    return ClassFunctionSameType( tbl, chi,
               ValuesOfClassFunction( chi ){ fus } );
    end );


#############################################################################
##
#M  RestrictedClassFunctions( <chars>, <H> )
#M  RestrictedClassFunctions( <chars>, <tbl> )
##
InstallMethod( RestrictedClassFunctions,
    "method for collection of class functions with group, and group",
    true,
    [ IsClassFunctionWithGroupCollection, IsGroup ], 0,
    function( chars, H );
    return List( chars, chi -> RestrictedClassFunction( chi, H ) );
    end );

InstallOtherMethod( RestrictedClassFunctions,
    "method for collection of class functions, and nearly character table",
    true,
    [ IsClassFunctionCollection, IsNearlyCharacterTable ], 0,
    function( chars, tbl );
    return List( chars, chi -> RestrictedClassFunction( chi, tbl ) );
    end );


#############################################################################
##
#M  RestrictedClassFunctions( <tbl>, <subtbl>, <chars> )
#M  RestrictedClassFunctions( <tbl>, <subtbl>, <chars>, <specification> )
#M  RestrictedClassFunctions( <chars>, <fusionmap> )
##
InstallOtherMethod( RestrictedClassFunctions,
    "method for two nearly character tables, and homogeneous list",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsHomogeneousList ], 0,
    function( tbl, subtbl, chars )
    local fusion;
    fusion:= FusionConjugacyClasses( subtbl, tbl );
#T really ?
    if fusion = fail then
      return fail;
    fi;
    return List( chars, chi -> chi{ fusion } );
    end );

InstallOtherMethod( RestrictedClassFunctions,
    "method for two nearly character tables, homogeneous list, and string",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsMatrix,
      IsString ], 0,
    function( tbl, subtbl, chars, specification )
    local fusion;
    fusion:= FusionConjugacyClasses( subtbl, tbl, specification );
    if fusion = fail then
      return fail;
    fi;
    return List( chars, chi -> chi{ fusion } );
    end );

InstallOtherMethod( RestrictedClassFunctions,
    "method for matrix and list of cyclotomics",
    true,
    [ IsMatrix, IsList and IsCyclotomicsCollection ], 0,
    function( chars, fusionmap )
    return List( chars, x -> x{ fusionmap } );
    end );


#############################################################################
##
#F  InducedClassFunctionByFusionMap( <chi>, <tbl> )
##
InducedClassFunctionByFusionMap := function( chi, tbl, fus )

    local H,
          values,
          Gcentsizes,
          induced,
          Hclasslengths,
          j,
          size;

    if fus = fail then
      return fail;
    fi;

    H:= UnderlyingCharacterTable( chi );
    values:= ValuesOfClassFunction( chi );

    # initialize zero vector
    Gcentsizes:= SizesCentralizers( tbl );
    induced:= Zero( Gcentsizes );

    # add the weighted values
    Hclasslengths:= SizesConjugacyClasses( H );
    for j in [ 1 .. Length( Hclasslengths ) ] do
      if values[j] <> 0 then
        induced[ fus[j] ]:= induced[ fus[j] ] + values[j] * Hclasslengths[j];
      fi;
    od;

    # multiply be the weight
    size:= Size( H );
    for j in [ 1 .. Length( induced ) ] do
      induced[j]:= induced[j] * Gcentsizes[j] / size;
    od;

    return ClassFunctionSameType( tbl, chi, induced );
end;


#############################################################################
##
#M  InducedClassFunction( <chi>, <G> )
#M  InducedClassFunction( <chi>, <tbl> )
##
InstallMethod( InducedClassFunction,
    "method for class function with group, and group",
    true,
    [ IsClassFunctionWithGroup, IsGroup ], 0,
    function( chi, G )
    return InducedClassFunctionByFusionMap( chi,
               OrdinaryCharacterTable( G ),
               FusionConjugacyClasses( UnderlyingGroup( chi ), G ) );
    end );


InstallOtherMethod( InducedClassFunction,
    "method for class function and nearly character table",
    true,
    [ IsClassFunction, IsNearlyCharacterTable ], 0,
    function( chi, tbl )
    return InducedClassFunctionByFusionMap( chi, tbl,
               FusionConjugacyClasses( UnderlyingCharacterTable( chi ),
                   tbl ) );
    end );


#############################################################################
##
#F  InducedClassFunctionsByFusionMap( <subtbl>, <tbl>, <chars>, <fusionmap> )
##
##  is the list of class function values lists
##
InducedClassFunctionsByFusionMap := function( subtbl, tbl, chars, fusion )

    local j, im,          # loop variables
          centralizers,   # centralizer orders in hte supergroup
          nccl,           # number of conjugacy classes of the group
          subnccl,        # number of conjugacy classes of the subgroup
          suborder,       # order of the subgroup
          subclasses,     # class lengths in the subgroup
          induced,        # list of induced characters, result
          singleinduced,  # one induced character
          char;           # one character to be induced

    if fusion = fail then
      return fail;
    fi;

    centralizers:= SizesCentralizers( tbl );
    nccl:= Length( centralizers );
    suborder:= Size( subtbl );
    subclasses:= SizesConjugacyClasses( subtbl );
    subnccl:= Length( subclasses );

    induced:= [];

    for char in chars do

      # preset the character with zeros
      singleinduced:= Zero( centralizers );

      # add the contribution of each class of the subgroup
      for j in [ 1 .. subnccl ] do
        if char[j] <> 0 then
          if IsInt( fusion[j] ) then
            singleinduced[ fusion[j] ]:= singleinduced[ fusion[j] ]
                                     + char[j] * subclasses[j];
          else
            for im in fusion[j] do singleinduced[ im ]:= Unknown(); od;
#T only for TableInProgress!
          fi;
        fi;
      od;

      # adjust the values by multiplication
      for j in [ 1 .. nccl ] do
        singleinduced[j]:= singleinduced[j] * centralizers[j] / suborder;
        if not IsCycInt( singleinduced[j] ) then
          singleinduced[j]:= Unknown();
          Info( InfoCharacterTable, 1,
                "Induced: subgroup order not dividing sum in character ",
                Length( induced ) + 1, " at class ", j );
        fi;
      od;

      Add( induced, ClassFunctionSameType( tbl, char, singleinduced ) );

    od;

    # Return the list of induced characters.
    return induced;
end;


#############################################################################
##
#M  InducedClassFunctions( <chars>, <G> )
#M  InducedClassFunctions( <chars>, <tbl> )
##
InstallOtherMethod( InducedClassFunctions,
    "method for empty list, and group",
    true,
    [ IsList and IsEmpty, IsGroup ], 0,
    function( empty, G )
    return [];
    end );

InstallMethod( InducedClassFunctions,
    "method for collection of class functions with group, and group",
    true,
    [ IsClassFunctionWithGroupCollection, IsGroup ], 0,
    function( chars, G )
    return InducedClassFunctionsByFusionMap( chars,
               OrdinaryCharacterTable( G ),
               FusionConjugacyClasses( UnderlyingGroup( chars[1] ), G ) );
    end );


InstallOtherMethod( InducedClassFunctions,
    "method for collection of class functions, and nearly character table",
    true,
    [ IsClassFunctionCollection, IsNearlyCharacterTable ], 0,
    function( chars, tbl )
    return InducedClassFunctionsByFusionMap( chars, tbl,
               FusionConjugacyClasses( UnderlyingCharacterTable( chars[1] ),
                   tbl ) );
    end );


#############################################################################
##
#M  InducedClassFunctions( <subtbl>, <tbl>, <chars> )
#M  InducedClassFunctions( <subtbl>, <tbl>, <chars>, <specification> )
#M  InducedClassFunctions( <subtbl>, <tbl>, <chars>, <fusionmap> )
##
InstallOtherMethod( InducedClassFunctions,
    "method for two nearly character tables and homog list",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsHomogeneousList ], 0,
    function( subtbl, tbl, chars )
    return InducedClassFunctionsByFusionMap( subtbl, tbl, chars,
               FusionConjugacyClasses( subtbl, tbl ) );
    end );

InstallOtherMethod( InducedClassFunctions,
    "method for two nearly character tables, homog list, and string",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable,
      IsHomogeneousList, IsString ], 0,
    function( subtbl, tbl, chars, specification )
    return InducedClassFunctionsByFusionMap( subtbl, tbl, chars, 
               FusionConjugacyClasses( subtbl, tbl, specification ) );
    end );

InstallOtherMethod( InducedClassFunctions,
    "method for two nearly character tables and two homog. lists",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable,
      IsHomogeneousList, IsHomogeneousList and IsCyclotomicsCollection ], 0,
    InducedClassFunctionsByFusionMap );


#############################################################################
##
#M  ReducedClassFunctions( <ordtbl>, <constituents>, <reducibles> )
#M  ReducedClassFunctions( <ordtbl>, <reducibles> )
##
InstallMethod( ReducedClassFunctions,
    "method for ordinary character table, and two lists of class functions",
    true,
    [ IsOrdinaryTable, IsHomogeneousList , IsHomogeneousList ], 0,
    function( ordtbl, constituents, reducibles )

    local i, j,
          normsquare,
          upper,
          found,          # list of found irreducible characters
          remainders,     # list of reducible remainders after reduction
          single,
          reduced,
          scpr;

    upper:= Length( constituents );
    upper:= List( reducibles, x -> upper );
    normsquare:= List( constituents, x -> ScalarProduct( ordtbl, x, x ) );
    found:= [];
    remainders:= [];

    for i in [ 1 .. Length( reducibles ) ] do
      single:= reducibles[i];
      for j in [ 1 .. upper[i] ] do
        scpr:= ScalarProduct( ordtbl, single, constituents[j] );
        if IsInt( scpr ) then
          scpr:= Int( scpr / normsquare[j] );
          if scpr <> 0 then
            single:= single - scpr * constituents[j];
          fi;
        else
          Info( InfoCharacterTable, 1,
                "ReducedClassFunctions: scalar product of X[", j,
                "] with Y[", i, "] not integral (ignore)" );
        fi;
      od;
      if ForAny( single, x -> x <> 0 ) then
        if single[1] < 0 then single:= - single; fi;
        if ScalarProduct( ordtbl, single, single ) = 1 then
          if not single in found and not single in constituents then
            Info( InfoCharacterTable, 2,
                  "ReducedClassFunctions: irreducible character of degree ",
                  single[1], " found" );
            AddSet( found, single );
          fi;
        else 
          AddSet( remainders, single );
        fi;
      fi;
    od;

    # If no irreducibles were found, return the remainders.
    if IsEmpty( found ) then
      return rec( remainders:= remainders, irreducibles:= [] );
    fi;

    # Try to find new irreducibles by recursively calling the reduction.
    reduced:= ReducedClassFunctions( ordtbl, found, remainders );

    # Return the result.
    return rec( remainders:= reduced.remainders,
                irreducibles:= Union( found, reduced.irreducibles ) );
    end );

InstallOtherMethod( ReducedClassFunctions,
    "method for ordinary character table, and list of class functions",
    true,
    [ IsOrdinaryTable, IsHomogeneousList ], 0,
    function( ordtbl, reducibles )

    local upper,
          normsquare,
          found,        # list of found irreducible characters
          remainders,   # list of reducible remainders after reduction
          i, j,
          single,
          reduced,
          scpr;

    upper:= [ 0 .. Length( reducibles ) - 1 ];
    normsquare:= List( reducibles, x -> ScalarProduct( ordtbl, x, x ) );
    found:= [];
    remainders:= [];
  
    for i in [ 1 .. Length( reducibles ) ] do
      if normsquare[i] = 1 then
        if 0 < reducibles[i][1] then
          AddSet( found, reducibles[i] );
        else
          AddSet( found, - reducibles[i] );
        fi;
      fi;
    od;

    for i in [ 1 .. Length( reducibles ) ] do
      single:= reducibles[i];
      for j in [ 1 .. upper[i] ] do
        scpr:= ScalarProduct( ordtbl, single, reducibles[j] );
        if IsInt( scpr ) then
          scpr:= Int( scpr / normsquare[j] );
          if scpr <> 0 then
            single:= single - scpr * reducibles[j];
          fi;
        else
          Info( InfoCharacterTable, 1,
                "ReducedClassFunctions: scalar product of X[", j,
                "] with Y[", i, "] not integral (ignore)" );
        fi;
      od;
      if ForAny( single, x -> x <> 0 ) then
        if single[1] < 0 then single:= - single; fi;
        if ScalarProduct( ordtbl, single, single ) = 1 then
          if not single in found and not single in reducibles then
            Info( InfoCharacterTable, 2,
                  "ReducedClassFunctions: irreducible character of degree ",
                  single[1], " found" );
            AddSet( found, single );
          fi;
        else 
          AddSet( remainders, single );
        fi;
      fi;
    od;

    # If no irreducibles were found, return the remainders.
    if IsEmpty( found ) then
      return rec( remainders:= remainders, irreducibles:= [] );
    fi;

    # Try to find new irreducibles by recursively calling the reduction.
    reduced:= ReducedClassFunctions( ordtbl, found, remainders );

    # Return the result.
    return rec( remainders:= reduced.remainders,
                irreducibles:= Union( found, reduced.irreducibles ) );
    end );


#############################################################################
##
#M  ReducedCharacters( <ordtbl>, <constituents>, <reducibles> )
##
InstallMethod( ReducedCharacters,
    "method for ordinary character table, and two lists of characters",
    true,
    [ IsOrdinaryTable, IsHomogeneousList , IsHomogeneousList ], 0,
    function( ordtbl, constituents, reducibles )

    local normsquare,
          found,
          remainders,
          single,
          i, j,
          nchars,
          reduced,
          scpr;

    normsquare:= List( constituents, x -> ScalarProduct( ordtbl, x, x ) );
    found:= [];
    remainders:= [];
    nchars:= Length( constituents );
    for i in [ 1 .. Length( reducibles ) ] do

      single:= reducibles[i];
      for j in [ 1 .. nchars ] do
        if constituents[j][1] <= single[1] then
          scpr:= ScalarProduct( ordtbl, single, constituents[j] );
          if IsInt( scpr ) then
            scpr:= Int( scpr / normsquare[j] );
            if scpr <> 0 then single:= single - scpr * constituents[j]; fi;
          else
            Info( InfoCharacterTable, 1,
                  "ReducedCharacters: scalar product of X[", j, "] with Y[",
                  i, "] not integral (ignore)" );
          fi;
        fi;
      od;

      if ForAny( single, x -> x <> 0 ) then
        if ScalarProduct( ordtbl, single, single ) = 1 then
          if single[1] < 0 then single:= - single; fi;
          if not single in found and not single in constituents then
            Info( InfoCharacterTable, 2,
                  "ReducedCharacters: irreducible character of",
                  " degree ", single[1], " found" );
            AddSet( found, single );
          fi;
        else 
          AddSet( remainders, single );
        fi;
      fi;

    od;

    # If no irreducibles were found, return the remainders.
    if IsEmpty( found ) then
      return rec( remainders:= remainders, irreducibles:= [] );
    fi;

    # Try to find new irreducibles by recursively calling the reduction.
    reduced:= ReducedCharacters( ordtbl, found, remainders );

    # Return the result.
    return rec( remainders:= reduced.remainders,
                irreducibles:= Union( found, reduced.irreducibles ) );
    end );


#############################################################################
##
#F  MatScalarProducts( <ordtbl>, <characters1>, <characters2> )
#F  MatScalarProducts( <ordtbl>, <characters> )
##
MatScalarProducts := function( arg )

    local i, j, tbl, chars, chars2, chi, nccl, weight, scprmatrix, order,
          scpr;

    if not ( Length( arg ) in [ 2, 3 ] and IsNearlyCharacterTable( arg[1] )
             and IsList( arg[2] )
             and ( Length( arg ) = 2 or IsList( arg[3] ) ) ) then
      Error( "usage: MatScalarProducts( <tbl>, <chars1>, <chars2> )\n",
             " resp. MatScalarProducts( <tbl>, <chars> )" );
    fi;

    tbl:= arg[1];
    chars:= arg[2];
    if IsEmpty( chars ) then
      return [];
    fi;

    nccl:= NrConjugacyClasses( tbl );
    weight:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );

    scprmatrix:= [];
    if Length( arg ) = 3 then
      chars2:= arg[3];
      for i in [ 1 .. Length( chars2 ) ] do
        scprmatrix[i]:= [];
        chi:= List( ValuesOfClassFunction( chars2[i] ),
                    x -> GaloisCyc(x,-1) );
        for j in [ 1 .. nccl ] do
          chi[j]:= chi[j] * weight[j];
        od;
        for j in chars do
          scpr:= ( chi * j ) / order;
          Add( scprmatrix[i], scpr );
          if not IsInt( scpr ) then
            if IsRat( scpr ) then
              Info( InfoCharacterTable, 2,
                    "MatScalarProducts: sum not divisible by group order" );
            elif IsCyc( scpr ) then
              Info( InfoCharacterTable, 2,
                    "MatScalarProducts: summation not integer valued");
            fi;
          fi;
        od;
      od;
    else
      for i in [ 1 .. Length( chars ) ] do
        scprmatrix[i]:= [];
        chi:= List( chars[i], x -> GaloisCyc( x, -1 ) );
        for j in [ 1 .. nccl ] do
          chi[j]:= chi[j] * weight[j];
        od;
        for j in [ 1 .. i ] do
          scpr:= ( chi * chars[j] ) / order;
          Add( scprmatrix[i], scpr );
          if not IsInt( scpr ) then
            if IsRat( scpr ) then
              Info( InfoCharacterTable, 2,
                    "MatScalarProducts: sum not divisible by group order" );
            elif IsCyc( scpr ) then
              Info( InfoCharacterTable, 2,
                    "MatScalarProducts: summation not integer valued");
            fi;
          fi;
        od;
      od;
    fi;
    return scprmatrix;
end;


#############################################################################
##
##  4. methods for auxiliary operations
##

#############################################################################
##
#M  GlobalPartitionOfClasses( <G> )
##
InstallMethod( GlobalPartitionOfClasses,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )

    local part,     # partition that has to be respected
          list,     # list of all maps to be respected
          map,      # one map in 'list'
          inv,      # contains number of root classes
          newpart,  #
          values,   #
          j,        # loop over 'orb'
          pt;       # one point to map

    if     HasOrdinaryCharacterTable( G )
       and HasAutomorphismsOfTable( OrdinaryCharacterTable( G ) ) then

      # The orbits define the finest possible global partition.
      part:= Orbits( AutomorphismsOfTable( OrdinaryCharacterTable( G ) ),
                     [ 1 .. Length( NrConjugacyClasses( G ) ) ] );

    else

      # Conjugate classes must have same representative order and
      # same centralizer order.

      if HasOrdinaryCharacterTable( G ) then

        list:= [ OrdersClassRepresentatives( OrdinaryCharacterTable( G ) ),
                 SizesCentralizers( OrdinaryCharacterTable( G ) ) ];

        # The number of root classes is by definition invariant under
        # table automorphisms.
        for map in Compacted( ComputedPowerMaps(
                                  OrdinaryCharacterTable( G ) ) ) do
          inv:= map * 0;
          for j in map do
            inv[j]:= inv[j] + 1;
          od;
          Add( list, inv );
        od;
        
      else

        list:= [ List( ConjugacyClasses( G ),
                       x -> Order( Representative( x ) ) ),
                 List( ConjugacyClasses( G ), Size ) ];
#T  Use power maps also ?
      fi;

      # All elements in 'list' must be respected.
      # Transform each of them into a partition,
      # and form the intersection of these partitions.
      part:= Partition( [ [ 1 .. Length( list[1] ) ] ] );
      for map in list do
        newpart := [];
        values  := [];
        for j in [ 1 .. Length( map ) ] do
          pt:= Position( values, map[j] );
          if pt = fail then
            Add( values, map[j] );
            Add( newpart, [ j ] );
          else
            Add( newpart[ pt ], j );
          fi;
        od;
        StratMeetPartition( part, Partition( newpart ) );
      od;
      part:= List( Cells( part ), Set );
#T unfortunately 'Set' necessary ...

    fi;
  
    return part;
    end );


#############################################################################
##
#M  CorrespondingPermutation( <G>, <g> )  . . . . action on the conj. classes
##
InstallMethod( CorrespondingPermutation,
    "method for group and group element",
    IsCollsElms,
    [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, g )

    local classes,  # list of conjugacy classes
          part,     # partition that has to be respected
          base,     # base of aut. group
          images,   # list of images
          pt,       # one point to map
          im,       # actual image class
          orb,      # possible image points
          len,      # length of 'orb'
          found,    # image point found? (boolean value)
          j,        # loop over 'orb'
          perm,     # permutation, result
          list,     # one list in 'part'
          first,    # first point in orbit of 'g'
          min;      # minimal length of nontrivial orbit of 'g'

    # Test whether 'g' is the identity
    if IsOne( g ) then
      return ();
    fi;

    classes:= ConjugacyClasses( G );

    # If the table automorphisms are known then we only must determine
    # the images of a base of this group.
    if     HasOrdinaryCharacterTable( G )
       and HasAutomorphismsOfTable( OrdinaryCharacterTable( G ) ) then

      part:= AutomorphismsOfTable( OrdinaryCharacterTable( G ) );

      # Compute the images of the base points of this group.
      base:= Base( part );
      images:= [];
      for pt in base do
        im:= Representative( classes[ pt ] ) ^ g;
        orb:= Orbit( part, pt );
        len:= Length( orb );
        found:= false;
        j:= 1;
        while not found and j <= len do
#T better CanonicalClassElement ??
          if im in classes[ orb[j] ] then
            Add( images, orb[j] );
            found:= true;
          fi;
          j:= j+1;
        od;

        # check that 'g' really normalizes 'G'
        if not found then
          return fail;
        fi;

      od;

      # Determine the group element.
      perm:= RepresentativeOperation( part, base, images, OnTuples );
   
    else

      # We can use only a partition into unions of orbits.

      part:= GlobalPartitionOfClasses( G );

      # Compute orbits of 'g' on the lists in 'part', store the images.
      # Note that if we have taken away a union of orbits such that the
      # number of remaining points is smaller than the smallest prime
      # divisor of the order of 'g' then all these points must be fixed.
      min:= FactorsInt( Order( g ) )[1];
      images:= [];

      for list in part do

#T why not 'min' ?
        if Length( list ) = 1 then

          # necessarily fixed point
          images[ list[1] ]:= list[1];

        else

          orb:= ShallowCopy( list );
          while min <= Length( orb ) do
  
            # There may be nontrivial orbits.
            pt:= orb[1];
            first:= pt;
            j:= 1;
  
            while j <= Length( orb ) do
  
              im:= Representative( classes[ pt ] ) ^ g;
              found:= false; 
              while j <= Length( orb ) and not found do
#T better CanonicalClassElement ??
                if im in classes[ orb[j] ] then
                  images[pt]:= orb[j];
                  found:= true;
                fi;
                j:= j+1;
              od;
  
              # check that 'g' really normalizes 'G'
              if not found then
                return fail;
              fi;

              RemoveSet( orb, pt );
  
              if found then
                j:= 1;
                pt:= images[pt];
              fi;
  
            od;
  
            # The image must be the first point of the orbit under 'g'.
            images[pt]:= first;
  
          od;
  
          # The remaining points of the orbit must be fixed.
          for pt in orb do
            images[pt]:= pt;
          od;

        fi;

      od;
          
      # Determine the group element.
      perm:= PermList( images );
   
    fi;

    return perm;
    end );


#############################################################################
##
#M  CorrespondingPermutation( <chi>, <g> )
#T for 'g' in 'H' is the identity or not?
##
InstallOtherMethod( CorrespondingPermutation,
    "method for a class function with group, and an object",
    true,
    [ IsClassFunctionWithGroup, IsObject ], 0,
    function( chi, g )

    local G,        # underlying group
          values,   # list of class function values
          classes,  # list of conjugacy classes
          part,     # partition that has to be respected
          base,     # base of aut. group
          images,   # list of images
          pt,       # one point to map
          im,       # actual image class
          orb,      # possible image points
          len,      # length of 'orb'
          found,    # image point found? (boolean value)
          j,        # loop over 'orb'
          perm,     # permutation, result
          list,     # one list in 'part'
          first,    # first point in orbit of 'g'
          min;      # minimal length of nontrivial orbit of 'g'

    # Test whether 'g' is the identity
    if IsOne( g ) then
      return ();
    fi;

    values:= ValuesOfClassFunction( chi );
    G:= UnderlyingGroup( chi );

    classes:= ConjugacyClasses( G );

    # If the table automorphisms are known then we only must determine
    # the images of a base of this group.
    if     HasOrdinaryCharacterTable( G )
       and HasAutomorphismsOfTable( OrdinaryCharacterTable( G ) ) then

      part:= AutomorphismsOfTable( OrdinaryCharacterTable( G ) );

      # Compute the images of the base points of this group.
      base:= Base( part );
      images:= [];
      for pt in base do
        im:= Representative( classes[ pt ] ) ^ g;
        orb:= Orbit( part, pt );
        len:= Length( orb );
        found:= false;
        j:= 1;
        while not found and j <= len do
#T better CanonicalClassElement ??
          if im in classes[ orb[j] ] then
            Add( images, orb[j] );
            found:= true;
          fi;
          j:= j+1;
        od;

        # check that 'g' really normalizes
        if not found then
          return fail;
        fi;

      od;

      # Determine the group element.
      perm:= RepresentativeOperation( part, base, images, OnTuples );
   
    else

      # We can use only a partition into unions of orbits.

      part:= GlobalPartitionOfClasses( G );

      # Compute orbits of 'g' on the lists in 'part', store the images.
      # Note that if we have taken away a union of orbits such that the
      # number of remaining points is smaller than the smallest prime
      # divisor of the order of 'g' then all these points must be fixed.
      min:= FactorsInt( Order( g ) )[1];
      images:= [];

      for list in part do

#T why not 'min' ?
        if Length( list ) = 1 then

          # necessarily fixed point
          images[ list[1] ]:= list[1];

        elif Length( Set( values{ list } ) ) = 1 then

          # We may take any permutation of the orbit.
          for j in list do
            images[j]:= j;
          od;

        else

          orb:= ShallowCopy( list );
          while Length( orb ) >= min do
  
            # There may be nontrivial orbits.
            pt:= orb[1];
            first:= pt;
            j:= 1;
  
            while j <= Length( orb ) do
  
              im:= Representative( classes[ pt ] ) ^ g;
              found:= false; 
              while j <= Length( orb ) and not found do
#T better CanonicalClassElement ??
                if im in classes[ orb[j] ] then
                  images[pt]:= orb[j];
                  found:= true;
                fi;
                j:= j+1;
              od;
  
              # check that 'g' really normalizes
              if not found then
                return fail;
              fi;

              RemoveSet( orb, pt );
  
              if found then
                j:= 1;
                pt:= images[pt];
              fi;
  
            od;
  
            # The image must be the first point of the orbit under 'g'.
            images[pt]:= first;
  
          od;
  
          # The remaining points of the orbit must be fixed.
          for pt in orb do
            images[pt]:= pt;
          od;

        fi;

      od;
          
      # Determine the group element.
      perm:= PermList( images );
   
    fi;

    return perm;
    end );


#############################################################################
##
#M  PermClassesHomomorphism( <H> )
##
InstallMethod( PermClassesHomomorphism,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( H )

    local N,      # normalizer of 'H' in its parent
          Ngens,  # generators of 'N'
          gens,   # images of the generators of 'N'
          hom;    # the homomorphism, result

    N:= NormalizerInParent( H );
    Ngens:= GeneratorsOfGroup( N );

    # compute the permutations corresponding to the generators of 'N'.
    if IsEmpty( Ngens ) then
      hom:= GroupHomomorphismByImages( N, GroupByGenerators( () ),
                                       Ngens, [] );
    else
      gens:= List( Ngens, g -> CorrespondingPermutation( H, g ) );
      hom:= GroupHomomorphismByImages( N, GroupByGenerators( gens ),
                                       Ngens, gens );
    fi;

    return hom;
    end );


#T #############################################################################
#T ##
#T #M  InertiaSubgroup( <G>, <chi> ) . . . . . . inertia subgroup of a character
#T ##  
#T ##  Given a character $\chi$ of a group $H$ that is given as subgroup of
#T ##  the group $P$, compute for $G \leq N = N_P(H)$ the inertia subgroup
#T ##  $I_G(\chi) = \{ g\in G; \chi^g = \chi \}$ where the conjugate class
#T ##  function $\chi^g$ is defined by $\chi^g(h) = \chi(h^g)$.
#T ##  
#T ##  Let $\pi(g)$ denote the permutation of the conjugacy classes $Cl(H)$
#T ##  that is induced by the conjugation action of $g$.  The map $\pi$ is
#T ##  then a homomorphism $N\rightarrow S_{Cl(H)}$, obviously $H\leq\ker\pi$.
#T ##  
#T ##  Here is an algorithm to compute $I_G(\chi)$.
#T ##  Since $N_G(\chi) = G \cap I_N(\chi)$ we need to consider only the
#T ##  case $G = N$.
#T ##  
#T ##  \begin{enumerate}
#T ##  \item Let $(O_i;i\in I)$ be a partition of $Cl(H)$ such that each
#T ##        set $O_i$ is invariant under automorphisms of $H$.
#T ##        For example, take $I = \{ (\|g\|,\|C_H(g)\|); g\in H \}$ and
#T ##        $O_{(a,b)} = \{ g\in H; \|g\|=a, \|C_H(g)\|=b \}$, or refine
#T ##        this using power maps or the table automorphism group of $H$.
#T ##        Note that this is independent of $\chi$.
#T ##  
#T ##  \item Refine this partition using $\chi$.
#T ##        Define $V_{\chi} = \{ \chi(g); g\in H \}$ and
#T ##        $J = I\times V_{\chi}$, and write
#T ##        $\tilde{O}_{i,x} = \{ g\in O_i; \chi(g) = x \}$.
#T ##        Then $I_N(\chi) = \bigcap_{j\in J} Stab_{\pi(N)}(\tilde{O}_j)$
#T ##        where $Stab$ denotes the set stabilizer.
#T ##  
#T ##        We need not inspect those sets where no refinement occurs, i.e., 
#T ##        those with $\tilde{O}_{i,x} = O_i$ for a value $x$.
#T ##        Especially, if $\chi$ does not impose refinement conditions then
#T ##        it is necessarily invariant, that is, $I_N(\chi) = N$.
#T ##  
#T ##  \item If the partition $p = (\tilde{O}_j;j\in J)$ is already stored in
#T ##        a list of partitions and their stabilizers then return the
#T ##        intersection of $G$ with the corresponding stabilizer.
#T ##  
#T ##  \item If we have already stored the stabilizer of a refinement
#T ##        $p^{\prime}$ of $p$ then let $S = Stab_{\pi(N)}(p^{\prime})$.
#T ##        Otherwise take $S$ the trivial group.
#T ##        $S$ is a subgroup of $\pi(I_N(\chi))$.
#T ##  
#T ##  \item Define the homomorphism $\pi$ by computing the images $\pi(g)$
#T ##        for $g$ in a generating set of $N$.
#T ##        This is again independent of $\chi$.
#T ##  
#T ##  \item Compute $\bigcap_{j\in J} Stab_{\pi(N)}(\tilde{O}_j)$.
#T ##        If $J = \{j_1,j_2,\ldots,j_n\}$ then this can be done by first
#T ##        initializing $T = Stab_{\pi(N)}(\tilde{O}_{j_1})$ and then
#T ##        replacing $T$ by $Stab_T(\tilde{O}_{j_i}$ for $i = 2,3,\ldots,n$.
#T ##  
#T ##        The subgroup $S$ can be used to speed up the computations.
#T ##  
#T ##  \item Compute $I_N(\chi)$ which is the full preimage of $T$ under $\pi$.
#T ##  
#T ##  \item Store the partition $p$ and $I_N(\chi)$ in the lists.
#T ##  
#T ##  \item Output $I_G(\chi) = G \cap I_N(\chi)$.
#T ##  \end{enumerate}
#T ##
#T InstallMethod( InertiaSubgroup,
#T     "method for a group, and a character with group",
#T     true,
#T     [ IsGroup, IsClassFunctionWithGroup ], 0,
#T     function( G, chi )
#T 
#T     local H,          # group of 'chi'
#T           N,          # normalizer of 'H' in its parent
#T           global,     # global partition of classes
#T           part,       # refined partition
#T           p,          # one set in 'global' and 'part'
#T           val,        # one value in 'p'
#T           values,     # list of character values on 'p'
#T           new,        # list of refinements of 'p'
#T           hom,        # 'PermClassesHomomorphism( H )'
#T           i,          # loop over stored partitions
#T           pos,        # position where to store new partition later
#T           found,      # flag:  Is 'part' already stored?
#T           substab,    # known subgroup of the inertia group
#T           stab,       # the inertia subgroup, result
#T           len;        # length of 'part'
#T 
#T     if not IsCharacter( chi ) then
#T       Error( "<chi> must be a character" );
#T     fi;
#T 
#T     H:= UnderlyingGroup( chi );
#T     if not IsSubset( G, H ) then
#T       Error( "<H> must be contained in <G>" );
#T     fi;
#T 
#T     N:= NormalizerInParent( H );
#T 
#T     # The inertia subgroup stored in 'chi' is that w.r.t. 'N'.
#T     if HasInertiaSubgroupInParent( chi ) and IsIdentical( G, N ) then
#T       return InertiaSubgroupInParent( chi );
#T     fi;
#T 
#T     # 1. Compute the global partition.
#T     global:= GlobalPartitionOfClasses( H );
#T 
#T     # 2. Refine the partition using the character values distribution.
#T     #    We need only those parts where we really get a refinement.
#T     part:= [];
#T     chi_values:= ValuesOfClassFunction( chi );
#T     for p in global do
#T #T only if 'p' has length > 1 !
#T       val:= chi_values[ p[1] ];
#T       if ForAny( p,  x-> chi_values[x] <> val ) then
#T         # proper refinement
#T         values:= [];
#T         new:= [];
#T         for i in p do
#T           pos:= Position( values, chi_values[i] );
#T           if pos = false then
#T             Add( values, chi_values[i] );
#T             Add( new, [ i ] );
#T           else
#T             Add( new[ pos ], i );
#T           fi;
#T         od;
#T         Append( part, new );
#T       fi;
#T     od;
#T 
#T     if Size( N ) = Size( Parent( H ) ) then
#T       N:= Parent( H );
#T     fi;
#T #T a situation where I would prefer if this would be settled in general.
#T 
#T     if   Length( part ) = 0 then
#T 
#T       # If no refinement occurs, the character is necessarily invariant
#T       # in $N$.
#T       stab:= N;
#T 
#T     else
#T 
#T       if not IsBound( H.inertiaInfo ) then
#T         H.inertiaInfo:= rec( partitions  := [],
#T                              stabilizers := [] );
#T       fi;
#T 
#T       # 3. Check whether $I_N( 'part' )$ is already stored.
#T       pos:= Position( H.inertiaInfo.partitions, part );
#T       if pos <> false then
#T 
#T         if G = N then
#T           stab:= H.inertiaInfo.stabilizers[ pos ];
#T         else
#T           stab:= Intersection( H.inertiaInfo.stabilizers[ pos ], G );
#T         fi;
#T 
#T       else
#T 
#T         # 4. If not, try to take a stored partition that is a
#T         #    refinement of 'part'.
#T         #    The partitions are stored according to increasing length,
#T         #    so we have to check those partitions that are longer than
#T         #    'part', and may take the first that fits.
#T         len:= Length( part );
#T 
#T         # We will insert the stabilizer at position 'pos' later.
#T         pos:= 1;
#T         while pos <= Length( H.inertiaInfo.partitions ) and
#T               Length( H.inertiaInfo.partitions[ pos ] ) <= len do
#T           pos:= pos+1;
#T         od;
#T 
#T         found:= false;
#T         i:= pos - 1;
#T         while i < Length( H.inertiaInfo.partitions ) and not found do
#T 
#T           i:= i+1;
#T           if ForAll( H.inertiaInfo.partitions[i],
#T                      x -> ForAny( part, y -> IsSubset( y, x ) ) ) then
#T             found:= true;
#T           fi;
#T 
#T         od;
#T #T  Up to now we do not use 'substab'
#T         if found then
#T 
#T           # The stabilizer is a subgroup of the required inertia group.
#T #T map this under pi!
#T           substab:= H.inertiaInfo.stabilizers[i];
#T 
#T         else
#T           substab:= Group( () );
#T         fi;
#T 
#T         # 5. Compute the corresponding permutations if necessary.
#T         hom:= PermClassesHomomorphism( H );
#T 
#T         # 6. Compute the stabilizer of 'part' in 'permgrp'.
#T         stab:= hom.range;
#T         for p in part do
#T           stab:= stab.operations.StabilizerSet( stab, p );
#T #T  Here I would like to give 'substab' as additional argument!!
#T #T  Better one step (partition stabilizer) ??
#T         od;
#T 
#T         # 7. Compute the preimage in $N$.
#T         stab:= PreImage( hom, stab );
#T 
#T         # 8. Store the stabilizer at position 'pos'.
#T         for i in Reversed( [ pos ..
#T                              Length( H.inertiaInfo.partitions ) ] ) do
#T           H.inertiaInfo.partitions[ i+1 ]:= H.inertiaInfo.partitions[i];
#T           H.inertiaInfo.stabilizers[ i+1 ]:= H.inertiaInfo.stabilizers[i];
#T         od;
#T         H.inertiaInfo.partitions[ pos ]:= part;
#T         H.inertiaInfo.stabilizers[ pos ]:= stab;
#T 
#T       fi;
#T     fi;
#T 
#T     # 9. Return the result.
#T     if G = N then
#T 
#T       # If the inertia subgroup os equal to the whole group 'N'
#T       # or to the normal subgroup 'H' then take these groups themselves.
#T       if   Size( stab ) = Size( H ) then
#T         stab:= H;
#T       elif Size( stab ) = Size( N ) then
#T         stab:= N;
#T       else
#T         stab:= AsSubgroup( Parent( H ), stab );
#T       fi;
#T   
#T       # Store and return the inertia subgroup.
#T       chi.inertiaSubgroup:= stab;
#T       return chi.inertiaSubgroup;
#T 
#T     else
#T 
#T       # We return the inertia subgroup without storing it.
#T       return Intersection( stab, G );
#T 
#T     fi;
#T     end );


##############################################################################
##
#F  OrbitChar( <chi>, <linear> )
##
OrbitChar := function( chi, linear )

    local classes,   # range of positions in 'chi'
          nofcyc,    # describes the conductor of values of 'chi'
          gens,      # generators of Galois automorphism group
          orb,       # the orbit, result
          gen,       # loop over 'gens'
          image;     # one image of 'chi' under operation

    classes:= [ 1 .. Length( chi ) ];
    nofcyc:= NofCyc( chi );

    # Apply Galois automorphisms if necessary.
    orb:= [ chi ];
    if 1 < nofcyc then
      gens:= Flat( GeneratorsPrimeResidues( nofcyc ).generators );
      for chi in orb do
        for gen in gens do
          image:= List( chi, x -> GaloisCyc( x, gen ) );
          if not image in orb then
            Add( orb, image );
          fi;
        od;
      od;
    fi;

    # Apply multiplication with linear characters.
    for chi in orb do
      for gen in linear do
        image:= List( classes, x -> gen[x] * chi[x] );
        if not image in orb then
          Add( orb, image );
        fi;
      od;
    od;
      
    # Return the orbit.
    return orb;
end;


##############################################################################
##
#F  OrbitsCharacters( <irr> )
##
OrbitsCharacters := function( irr )

    local irrvals,     # list of value lists
          oldirrvals,  # store original succession
          tbl,         # underlying character table
          linear,      # linear characters of 'tbl'
          orbits,      # list of orbits, result
          indices,     # from 1 to number of conjugacy classes of 'tbl'
          orb,         # one orbit
          gens,        # generators of the acting group
          chi,         # one irreducible character
          gen,         # one generator of the acting group
          image,       # image of a character
          i,           # loop over one orbit
          pos;         # position of value list in 'oldirrvals'

    orbits:= [];

    if not IsEmpty( irr ) then

      if IsClassFunction( irr[1] ) then

        # Replace group characters by their value lists.
        # Store the succession in the original list.
        irrvals:= List( irr, ValuesOfClassFunction );
        oldirrvals:= ShallowCopy( irrvals );
        irrvals:= Set( irrvals );

      else
        irrvals:= Set( irr );
      fi;

      indices:= [ 1 .. Length( irrvals[1] ) ];

      # Compute the orbit of linear characters if there are any.
      linear:= Filtered( irrvals, x -> x[1] = 1 );

      if 0 < Length( linear ) then

        # The linear characters form an orbit.
        # We remove them from the other characters,
        # and remove the trivial character from 'linear'.
        orb:= ShallowCopy( linear );
        SubtractSet( irrvals, linear );
        RemoveSet( linear, List( linear[1], x -> 1 ) );

        # Make 'linear' closed under Galois automorphisms.
        gens:= Flat( GeneratorsPrimeResidues(
                        NofCyc( Flat( linear ) ) ).generators );

        for chi in orb do
          for gen in gens do
            image:= List( chi, x -> GaloisCyc( x, gen ) );
            if not image in orb then
              Add( orb, image );
            fi;
          od;
        od;

        # Make 'linear' closed under multiplication with linear characters.
        for chi in orb do
          for gen in linear do
            image:= List( indices, x -> gen[x] * chi[x] );
            if not image in orb then
              Add( orb, image );
            fi;
          od;
        od;

        orbits[1]:= orb;

      fi;

      # Compute the other orbits.
      while Length( irrvals ) > 0 do

        orb:= OrbitChar( irrvals[1], linear );
        Add( orbits, orb );
        SubtractSet( irrvals, orb );

      od;

      # Replace the value lists by the group characters
      # if the input was a list of characters.
      # Be careful not to copy characters if not necessary.
      if IsCharacter( irr[1] ) then
        tbl:= UnderlyingCharacterTable( irr[1] );
        for orb in orbits do
          for i in [ 1 .. Length( orb ) ] do
            pos:= Position( oldirrvals, orb[i] );
            if pos = fail then
              orb[i]:= CharacterByValues( tbl, orb[i] );
            else
              orb[i]:= irr[ pos ];
            fi;
          od;
        od;
      fi;

    fi;

    return orbits;
end;


##############################################################################
##
#F  OrbitRepresentativesCharacters( <irr> )
##
OrbitRepresentativesCharacters := function( irr )

    local irrvals,     # list of value lists
          oldirrvals,  # store original succession
          chi,         # loop over 'irrvals'
          linear,      # linear characters in 'irr'
          nonlin,      # nonlinear characters in 'irr'
          repres,      # list of representatives, result
          orb;         # one orbit

    repres:= [];

    if not IsEmpty( irr ) then

      if IsCharacter( irr[1] ) then

        # Replace group characters by their value lists.
        # Store the succession in the original list.
        irrvals:= List( irr, ValuesOfClassFunction );
        oldirrvals:= ShallowCopy( irrvals );
        irrvals:= Set( irrvals );

      else
        irrvals:= Set( irr );
      fi;

      # Get the linear characters.
      linear := [];
      nonlin := [];
      for chi in irrvals do
        if chi[1] = 1 then
          Add( linear, chi );
        else
          Add( nonlin, chi );
        fi;
      od;
      if Length( linear ) > 0 then
        repres[1]:= linear[1];
      fi;

      # Compute orbits and remove them until the set is empty.
      while Length( nonlin ) > 0 do
        Add( repres, nonlin[1] );
        orb:= OrbitChar( nonlin[1], linear );
        SubtractSet( nonlin, orb );
      od;

      # Replace the value lists by the group characters
      # if the input was a list of characters.
      # Do not copy characters!
      if IsCharacter( irr[1] ) then
        repres:= List( repres, x -> irr[ Position( oldirrvals, x ) ] );
      fi;

    fi;

    # Return the representatives.
    return repres;
end;


#############################################################################
##
#M  GroupByGenerators( <classfuns> )
#M  GroupByGenerators( <classfuns>, <id> )
##
InstallOtherMethod( GroupByGenerators,
    "method for list of class functions",
    true,
    [ IsHomogeneousList and IsClassFunctionCollection ], 0,
    function( gens )
    local G;

    # Check that the class functions are invertible.
    if ForAny( gens, psi -> Inverse( psi ) = fail ) then
      Error( "class functions in <gens> must be invertible" );
    fi;

    # Construct the group.
    G:= Objectify( NewType( FamilyObj( gens ),
                            IsGroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithInverses( G, AsList( gens ) );
    return G;
    end );

InstallOtherMethod( GroupByGenerators,
    "method for list of class functions and identity",
    IsCollsElms,
    [ IsHomogeneousList and IsClassFunctionCollection, IsClassFunction ], 0,
    function( gens, id )
    local G;

    # Check that the class functions are invertible.
    if ForAny( gens, psi -> Inverse( psi ) = fail ) then
      Error( "class functions in <gens> must be invertible" );
    elif not IsOne( id ) then
      Error( "<id> must be an identity" );
    fi;

    # Construct the group.
    G:= Objectify( NewType( FamilyObj( gens ),
                            IsGroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithInverses( G, AsList( gens ) );
    SetOne( G, id );
    return G;
    end );

InstallOtherMethod( GroupByGenerators,
    "method for empty list and trivial character",
    true,
    [ IsList and IsEmpty, IsClassFunction ], 0,
    function( empty, id )
    local G;

    # Check that the class functions are invertible.
    if not IsOne( id ) then
      Error( "<id> must be an identity" );
    fi;

    # Construct the group.
    G:= Objectify( NewType( CollectionsFamily( FamilyObj( id ) ),
                            IsGroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithInverses( G, [] );
    SetOne( G, id );
    return G;
    end );


#############################################################################
##
##  5. vector spaces of class functions
##

#############################################################################
##
#M  PrepareNiceFreeLeftModule( <V> )
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for a space of class functions",
    true,
    [ IsFreeLeftModule and IsClassFunctionsSpaceRep ], 0,
    function( V )
    V!.elementsunderlying:= UnderlyingCharacterTable(
                                Representative( V ) );
    end );


#############################################################################
##
#M  NiceVector( <V>, <v> )
##
InstallMethod( NiceVector,
    "method for a free module of class functions",
    IsCollsElms,
    [ IsFreeLeftModule and IsClassFunctionsSpaceRep, IsClassFunction ], 0,
    function( V, v )
    if UnderlyingCharacterTable( v ) = V!.elementsunderlying then
      return ValuesOfClassFunction( v );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#M  UglyVector( <V>, <r> )
##
InstallMethod( UglyVector,
    "method for a free module of class functions",
    true,
    [ IsFreeLeftModule and IsClassFunctionsSpaceRep, IsRowVector ], 0,
    function( V, r )
    return ClassFunctionByValues( V!.elementsunderlying, r );
    end );


#############################################################################
##
#M  ScalarProduct( <V>, <chi>, <psi> ) . . . .  for module of class functions
##
##  Left modules of class functions carry the usual bilinear form.
##
InstallOtherMethod( ScalarProduct,
    "method for left module of class functions, and two class functions",
    IsCollsElmsElms,
    [ IsFreeLeftModule and IsClassFunctionsSpaceRep,
      IsClassFunction, IsClassFunction ], 0,
    function( V, x1, x2 )

     local tbl,     # character table
           i,       # loop variable
           scpr,    # scalar product, result
           weight;  # lengths of conjugacy classes

     tbl:= V!.elementsunderlying;
     weight:= SizesConjugacyClasses( tbl );
     x1:= ValuesOfClassFunction( x1 );
     x2:= ValuesOfClassFunction( x2 );
     scpr:= 0;
     for i in [ 1 .. Length( x1 ) ] do
       scpr:= scpr + x1[i] * GaloisCyc( x2[i], -1 ) * weight[i];
     od;
     return scpr / Size( tbl );
     end );


#############################################################################
##
#M  ScalarProduct( <V>, <chivals>, <psivals> )  . . for module of class funs.
##
##  Left modules of class functions carry the usual bilinear form.
##
InstallOtherMethod( ScalarProduct,
    "method for module of class functions, and two values lists",
    Is2Identical3,
    [ IsFreeLeftModule and IsClassFunctionsSpaceRep,
      IsHomogeneousList, IsHomogeneousList ], 0,
    function( V, x1, x2 )

     local tbl,     # character table
           i,       # loop variable
           scpr,    # scalar product, result
           weight;  # lengths of conjugacy classes

     tbl:= V!.elementsunderlying;
     weight:= SizesConjugacyClasses( tbl );
     scpr:= 0;
     for i in [ 1 .. Length( x1 ) ] do
       scpr:= scpr + x1[i] * GaloisCyc( x2[i], -1 ) * weight[i];
     od;
     return scpr / Size( tbl );
     end );


##############################################################################
##
#F  NormalSubgroupClasses( <G>, <classes> )
##
NormalSubgroupClasses := function( G, classes )

    local info,
          pos,        # position of the group in the list of such groups
          ccl,        # <G>-conjugacy classes in our normal subgroup
          size,       # size of our normal subgroup
          candidates, # bound normal subgroups that possibly are our group
          group,      # the normal subgroup
          repres,     # list of representatives of conjugacy classes
          found,      # normal subgroup already identified
          i;          # loop over normal subgroups

    # Initialize components to store kernel information.
    if not HasNormalSubgroupClassesInfo( G ) then
      SetNormalSubgroupClassesInfo( G, rec( 
                                            nsg        := [],
                                            nsgclasses := [],
                                            nsgfactors := []
                                           ) );
    fi;
    info:= NormalSubgroupClassesInfo( G );
#T default method!

    classes:= Set( classes );
    pos:= Position( info.nsgclasses, classes );
    if pos = fail then

      # The group is not yet stored here, try 'NormalSubgroups( G )'.
      if HasNormalSubgroups( G ) then

        # Identify our normal subgroup.
        ccl:= ConjugacyClasses( G ){ classes };
        size:= Sum( ccl, Size, 0 );
        candidates:= Filtered( NormalSubgroups( G ), x -> Size( x ) = size );
        if Length( candidates ) = 1 then
          group:= candidates[1];
        else
          repres:= List( ccl, Representative );
          found:= false;
          i:= 0;
          while not found do
            i:= i+1;
            if ForAll( repres, x -> x in candidates[i] ) then
              found:= true;
            fi;
          od;
          group:= candidates[i];
        fi;

      else

        # The group is not yet stored, we have to construct it.
        repres:= List( ConjugacyClasses(G), Representative );
        group := NormalClosure( G, Subgroup( Parent(G), repres{ classes } ) );

      fi;

      Add( info.nsgclasses, classes );
      Add( info.nsg       , group   );
      pos:= Length( info.nsg );

    fi;

    return info.nsg[ pos ];
end;


##############################################################################
##
#M  ClassesNormalSubgroup( <G>, <N> )
##
ClassesNormalSubgroup := function( G, N )

    local info,
          classes,    # result list
          found,      # 'N' already found?
          pos,        # position in 'G.nsg'
          ccl;        # conjugacy classes of 'G'

    # Initialize components to store kernel information.
    if not HasNormalSubgroupClassesInfo( G ) then
      SetNormalSubgroupClassesInfo( G, rec( 
                                            nsg        := [],
                                            nsgclasses := [],
                                            nsgfactors := []
                                           ) );
    fi;
    info:= NormalSubgroupClassesInfo( G );
#T def. method!

    # Search for 'N' in 'info.nsg'.
    found:= false;
    pos:= 0;
    while ( not found ) and pos < Length( info.nsg ) do
      pos:= pos+1;
      if IsIdentical( N, info.nsg[ pos ] ) then
        found:= true;
      fi;
    od;
    if not found then
      pos:= Position( info.nsg, N );
    fi;

    if pos = false then

      # The group is not yet stored here, try 'NormalSubgroups( G )'.
      if HasNormalSubgroups( G ) then

        # Identify our normal subgroup.
        N:= NormalSubgroups( G )[ Position( NormalSubgroups( G ), N ) ];

      fi;

      ccl:= ConjugacyClasses( G );
      classes:= Filtered( [ 1 .. Length( ccl ) ],
                          x -> Representative( ccl[x] ) in N );

      Add( info.nsgclasses, classes );
      Add( info.nsg       , N       );
      pos:= Length( info.nsg );

    fi;

    return info.nsgclasses[ pos ];
end;


##############################################################################
##
#F  FactorGroupNormalSubgroupClasses( <G>, <classes> )
##
FactorGroupNormalSubgroupClasses := function( G, classes )

    local info,
          f,     # the result
          pos;   # position in list of normal subgroups

    if not HasNormalSubgroupClassesInfo( G ) then

      info:= rec( 
                  nsg        := [],
                  nsgclasses := [],
                  nsgfactors := []
                 );
      SetNormalSubgroupClassesInfo( G, info );
      f:= G / NormalSubgroupClasses( G, classes );
      info.nsgfactors[1]:= f;

    else

      info:= NormalSubgroupClassesInfo( G );
      pos:= Position( info.nsgclasses, classes );
      if pos = false then
        f:= G / NormalSubgroupClasses( G, classes );
        info.nsgfactors[ Length( info.nsgclasses ) ]:= f;
      elif IsBound( info.nsgfactors[ pos ] ) then
        f:= info.nsgfactors[ pos ];
      else
        f:= G / info.nsg[ pos ];
        info.nsgfactors[ pos ]:= f;
      fi;

    fi;

    return f;
end;


#############################################################################
##
#E  ctblfuns.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



