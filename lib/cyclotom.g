#############################################################################
##
#W  cyclotom.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file deals with cyclotomics.
##
Revision.cyclotom_g :=
    "@(#)$Id$";


#############################################################################
##
#C  IsCyclotomic(<obj>) . . . . . . . . . . . . . . category of all cyclotomics
##
##  is the category of cyclotomic numbers
DeclareCategory( "IsCyclotomic",
    IsScalar and IsAssociativeElement and IsCommutativeElement );


#############################################################################
##
#C  IsCyclotomicCollection  . . . . . . category of collection of cyclotomics
#C  IsCyclotomicCollColl  . . . . . . .  category of collection of collection
#C  IsCyclotomicCollCollColl  . . . .  category of collection of coll of coll
##
DeclareCategoryCollections( "IsCyclotomic" );
DeclareCategoryCollections( "IsCyclotomicCollection" );
DeclareCategoryCollections( "IsCyclotomicCollColl" );


#############################################################################
##
#C  IsCyc(<obj>)
##
##  is the category of kernel cyclotomics.
DeclareCategoryKernel( "IsCyc", IsCyclotomic, IS_CYC );


#############################################################################
##
#C  IsRat . . . . . . . . . . . . . . . . . . . . . . . .  internal rationals
##
DeclareCategoryKernel( "IsRat", IsCyc, IS_RAT );


#############################################################################
##
#C  IsInt . . . . . . . . . . . . . . . . . . . . . . . . . internal integers
##
DeclareCategoryKernel( "IsInt", IsRat, IS_INT );


#############################################################################
##
#C  IsPosRat  . . . . . . . . . . . . . . . . . . internal positive rationals
##
DeclareCategory( "IsPosRat", IsRat );


#############################################################################
##
#C  IsPosInt
##
##  is the category for positive integers
DeclareSynonym( "IsPosInt", IsInt and IsPosRat );


#############################################################################
##
#C  IsNegRat  . . . . . . . . . . . . . . . . . . internal negative rationals
##
DeclareCategory( "IsNegRat", IsRat );


#############################################################################
##
#C  IsZeroCyc . . . . . . . . . . . . . . . . . . . . . internal zero integer
##
DeclareCategory( "IsZeroCyc", IsInt );


#############################################################################
##

#V  CyclotomicsFamily . . . . . . . . . . . . . . . . . family of cyclotomics
##
BIND_GLOBAL( "CyclotomicsFamily",
    NewFamily( "CyclotomicsFamily", IsCyclotomic ) );


#############################################################################
##

#R  IsSmallIntRep . . . . . . . . . . . . . . . . . .  small internal integer
##
DeclareRepresentation( "IsSmallIntRep", IsInternalRep, [] );


#############################################################################
##
#V  TYPE_INT_SMALL_ZERO . . . . . . . . . . . . . . type of the internal zero
##
BIND_GLOBAL( "TYPE_INT_SMALL_ZERO", NewType( CyclotomicsFamily,
                            IsInt and IsZeroCyc and IsSmallIntRep ) );


#############################################################################
##
#V  TYPE_INT_SMALL_NEG  . . . . . . type of a small negative internal integer
##
BIND_GLOBAL( "TYPE_INT_SMALL_NEG", NewType( CyclotomicsFamily,
                            IsInt and IsNegRat and IsSmallIntRep ) );


#############################################################################
##
#V  TYPE_INT_SMALL_POS  . . . . . . type of a small positive internal integer
##
BIND_GLOBAL( "TYPE_INT_SMALL_POS", NewType( CyclotomicsFamily,
                            IsPosInt and IsSmallIntRep ) );


#############################################################################
##
#V  TYPE_INT_LARGE_NEG  . . . . . . type of a large negative internal integer
##
BIND_GLOBAL( "TYPE_INT_LARGE_NEG", NewType( CyclotomicsFamily,
                            IsInt and IsNegRat and IsInternalRep ) );


#############################################################################
##
#V  TYPE_INT_LARGE_POS  . . . . . . type of a large positive internal integer
##
BIND_GLOBAL( "TYPE_INT_LARGE_POS", NewType( CyclotomicsFamily,
                            IsPosInt and IsInternalRep ) );


#############################################################################
##
#V  TYPE_RAT_NEG  . . . . . . . . . . .  type of a negative internal rational
##
BIND_GLOBAL( "TYPE_RAT_NEG", NewType( CyclotomicsFamily,
                            IsRat and IsNegRat and IsInternalRep ) );


#############################################################################
##
#V  TYPE_RAT_POS  . . . . . . . . . . .  type of a positive internal rational
##
BIND_GLOBAL( "TYPE_RAT_POS", NewType( CyclotomicsFamily,
                            IsRat and IsPosRat and IsInternalRep ) );

#############################################################################
##
#V  TYPE_CYC  . . . . . . . . . . . . . . . . type of an internal cyclotomics
##
BIND_GLOBAL( "TYPE_CYC",
    NewType( CyclotomicsFamily, IsCyc and IsInternalRep ) );


#############################################################################
##
#V  One . . . . . . . . . . . . . . . . . . . . . . . .  of CyclotomicsFamily
##
SetOne( CyclotomicsFamily, 1 );


#############################################################################
##
#V  Zero  . . . . . . . . . . . . . . . . . . . . . . .  of CyclotomicsFamily
##
SetZero( CyclotomicsFamily, 0 );


#############################################################################
##
#V  Characteristic  . . . . . . . . . . . . . . . . . .  of CyclotomicsFamily
##
SetCharacteristic( CyclotomicsFamily, 0 );


#############################################################################
##
#V  IsUFDFamily . . . . . . . . . . . . . . . . .  true for CyclotomicsFamily
##
SetIsUFDFamily( CyclotomicsFamily, true );


#############################################################################
##

#C  IsInfinity  . . . . . . . . . . . . . . . . . . . .  category of infinity
##
DeclareCategory( "IsInfinity", IsCyclotomic );


#############################################################################
##
#V  infinity  . . . . . . . . . . . . . . . . . . . . . .  the value infinity
##
UNBIND_GLOBAL( "infinity" );
BIND_GLOBAL( "infinity",
    Objectify( NewType( CyclotomicsFamily, IsInfinity
                        and IsPositionalObjectRep ), rec() ) );

InstallMethod( PrintObj,
    "for infinity",
    true, [ IsInfinity ], 0, function(obj) Print("infinity"); end );

InstallMethod( \=,
    "for cyclotomic and `infinity'",
    IsIdenticalObj, [ IsCyc, IsInfinity ], 0, ReturnFalse );

InstallMethod( \=,
    "for `infinity' and cyclotomic",
    IsIdenticalObj, [ IsInfinity, IsCyc ], 0, ReturnFalse );

InstallMethod( \=,
    "for `infinity' and `infinity'",
    IsIdenticalObj, [ IsInfinity, IsInfinity ], 0, ReturnTrue );

InstallMethod( \<,
    "for cyclotomic and `infinity'",
    IsIdenticalObj, [ IsCyc, IsInfinity ], 0, ReturnTrue );

InstallMethod( \<,
    "for `infinity' and cyclotomic",
    IsIdenticalObj, [ IsInfinity, IsCyc ], 0, ReturnFalse );

InstallMethod( \<,
    "for `infinity' and `infinity'",
    IsIdenticalObj, [ IsInfinity, IsInfinity ], 0, ReturnFalse );


#############################################################################
##
#F  IsIntegralCyclotomic( <obj> ) . . . . . . . . . . .  integral cyclotomics
##
##  returns  `true'  if  <obj>  is a cyclotomic integer  (see  "Cyclotomic
##  Integers"), `false' otherwise.
##
DeclareProperty( "IsIntegralCyclotomic", IsObject );

DeclareSynonym( "IsCycInt", IsIntegralCyclotomic );

InstallMethod( IsIntegralCyclotomic,
    "for an internal object",
    true,
    [ IsInternalRep ], 0,
    IS_CYC_INT );


#############################################################################
##
#A  Conductor( <cyc> )
#A  Conductor( <F> )
#A  Conductor( <list> )
##
##  For an element <cyc> of a cyclotomic field, `Conductor' returns the
##  smallest integer $n$ such that <cyc> is contained in the $n$-th
##  cyclotomic field.
##  For a field <F> or a list <list> of cyclotomics, `Conductor' returns the
##  smallest integer $n$ such that all elements of <F> resp.~all entries in
##  <list> are contained in the $n$-th cyclotomic field.
##
DeclareAttributeKernel( "Conductor", IsCyc, CONDUCTOR );


#############################################################################
##
#O  GaloisCyc( <cyc>, <k> ) . . . . . . . . . . . . . . . .  Galois conjugate
##
##  returns  the cyclotomic obtained on raising the roots  of unity in the
##  representation of  the cyclotomic <z> to  the <k>-th power.  If <k> is
##  a fixed integer coprime to the integer $n$, `GaloisCyc( ., <k> )' acts
##  as a Galois automorphism of the $n$-th cyclotomic field
##  (see   "GaloisGroup  for   Number  Fields"); to get the Galois
##  automorphisms themselves, use "GaloisGroup" `GaloisGroup'.
##
##  The complex conjugate of <cyc> is `GaloisCyc( <cyc>, -1 )',
##  which can also be computed using `ComplexConjugate'
##  (see "ComplexConjugate").
##
DeclareOperationKernel( "GaloisCyc", [ IsCyc, IsInt ], GALOIS_CYC );


#############################################################################
##
#F  NumeratorRat( <rat> ) . . . . . . . . . .  numerator of internal rational
##
BIND_GLOBAL( "NumeratorRat", NUMERATOR_RAT );


#############################################################################
##
#F  DenominatorRat( <rat> ) . . . . . . . .  denominator of internal rational
##
BIND_GLOBAL( "DenominatorRat", DENOMINATOR_RAT );


#############################################################################
##
#F  QuoInt( <a>, <b> )  . . . . . . . . . . . . quotient of internal integers
##
BIND_GLOBAL( "QuoInt", QUO_INT );


#############################################################################
##
#F  RemInt( <a>, <b> )  . . . . . . . . . . .  remainder of internal integers
##
BIND_GLOBAL( "RemInt", REM_INT );


#############################################################################
##
#F  GcdInt( <a>, <b> )  . . . . . . . . . . . . . .  gcd of internal integers
##
BIND_GLOBAL( "GcdInt", GCD_INT );


#############################################################################
##
#M  Order( <z> ) . . . . . . . . . . . . . . . . . .  order of an alg. number
##
InstallMethod( Order,
    "for a cyclotomic",
    true,
    [ IsCyc ], 0,
    function ( cyc )
    local ord, val;
    if cyc = 0 then
      Error( "argument must be nonzero" );
    elif cyc * GaloisCyc( cyc, -1 ) <> 1 then   # not a root of unity
      return infinity;
    else
      ord:= 1;
      val:= cyc;
      while val <> 1 do
        val:= val * cyc;
        ord:= ord + 1;
      od;
      return ord;
#T improve!
    fi;
    end );


#############################################################################
##
#M  Int( <cyc> )  . . . . . . . . . . . . .  cyclotomic integer near to <cyc>
##
InstallMethod( Int,
    "for a cyclotomic",
    true,
    [ IsCyc ], 0,
    function ( x )
    local i, int, n, cfs;
    n:= Conductor( x );
    cfs:= COEFFS_CYC( x );
    int:= 0;
    for i in [ 1 .. n ] do
      int:= int + Int( cfs[i] ) * E(n)^(i-1);
    od;
    return int;
    end );


#############################################################################
##
#M  Int( <rat> ) . . . . . . . . . . . .   convert a rational into an integer
##
InstallMethod( Int,
    "for a rational",
    true,
    [ IsRat ], 0,
    obj -> QuoInt( NumeratorRat( obj ), DenominatorRat( obj ) ) );


#############################################################################
##
#M  Int( <n> )
##
InstallMethod( Int,
    "for an integer",
    true,
    [ IsInt ], 0,
    IdFunc );


#############################################################################
##
#M  String( <cyc> ) . . . . . . . . . . . .  convert cyclotomic into a string
##
InstallMethod( String,
    "for a cyclotomic",
    true,
    [ IsCyc ], 0,
    function( cyc )
    local i, j, En, coeffs, str;

    # get the coefficients
    coeffs := COEFFS_CYC( cyc );

    # get the root as a string
    En := Concatenation( "E(", String( Length( coeffs ) ), ")" );

    # print the first non zero coefficient
    i := 1;
    while coeffs[i] = 0 do i:= i+1; od;
    if i = 1  then
        str := ShallowCopy( String( coeffs[1] ) );
    elif coeffs[i] = -1 then
        str := Concatenation( "-", En );
    elif coeffs[i] = 1 then
        str := En;
    else
        str := Concatenation( String( coeffs[i] ), "*", En );
    fi;
    if 2 < i  then
        Add( str, '^' );
        Append( str, String(i-1) );
    fi;

    # print the other coefficients
    for j  in [i+1..Length(coeffs)]  do
        if   coeffs[j] = 1 then
            Add( str, '+' );
            Append( str, En );
        elif coeffs[j] = -1 then
            Add( str, '-' );
            Append( str, En );
        elif 0 < coeffs[j] then
            Add( str, '+' );
            Append( str, String( coeffs[j] ) );
            Add( str, '*' );
            Append( str, En );
        elif coeffs[j] < 0 then
            Append( str, String( coeffs[j] ) );
            Add( str, '*' );
            Append( str, En );
        fi;
        if 2 < j  and coeffs[j] <> 0  then
            Add( str, '^' );
            Append( str, String( j-1 ) );
        fi;
    od;

    # Convert to string representation.
    ConvertToStringRep( str );

    # Return the string.
    return str;
    end );


#############################################################################
##
#M  String( <rat> ) . . . . . . . . . . . .  convert a rational into a string
##
InstallMethod( String,
    "for a rational",
    true,
    [ IsRat ], 0,
    function ( rat )
    local   str;

    str := String( NumeratorRat( rat ) );
    if DenominatorRat( rat ) <> 1  then
        str := Concatenation( str, "/", String( DenominatorRat( rat ) ) );
    fi;
    ConvertToStringRep( str );
    return str;
    end );


#############################################################################
##
#M  String( <n> ) . . . . . . . . . . . . . . . . . . . . . .  for an integer
##
InstallMethod( String,
    "for an integer",
    true,
    [ IsInt ], 0,
    STRING_INT );


#############################################################################
##
#M  String( <infinity> )  . . . . . . . . . . . . . . . . . .  for `infinity'
##
InstallMethod( String,
    "for infinity",
    true,
    [ IsInfinity ], 0,
    x -> "infinity" );


#############################################################################
##

#E  cyclotom.g	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
