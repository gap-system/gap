#############################################################################
##
#W  cyclotom.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with cyclotomics.
##
Revision.cyclotom_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsCyclotomic  . . . . . . . . . . . . . . . . category of all cyclotomics
##
IsCyclotomic := NewCategory( "IsCyclotomic",
    IsScalar and IsAssociativeElement and IsCommutativeElement );


#############################################################################
##
#C  IsCyclotomicsCollection . . . . . . category of collection of cyclotomics
##
IsCyclotomicsCollection := CategoryCollections( IsCyclotomic );


#############################################################################
##
#C  IsCyclotomicsCollColl . . . . . . .  category of collection of collection
##
IsCyclotomicsCollColl := CategoryCollections( IsCyclotomicsCollection );


#############################################################################
##
#C  IsCyclotomicsCollCollColl . . . .  category of collection of coll of coll
##
IsCyclotomicsCollCollColl := CategoryCollections( IsCyclotomicsCollColl );


#############################################################################
##
#C  IsCyc . . . . . . . . . . . . . . . . . . . . . . .  internal cyclotomics
##
IsCyc := NewCategoryKernel( "IsCyc", IsCyclotomic, IS_CYC );


#############################################################################
##
#C  IsRat . . . . . . . . . . . . . . . . . . . . . . . .  internal rationals
##
IsRat := NewCategoryKernel( "IsRat", IsCyc, IS_RAT );


#############################################################################
##
#C  IsInt . . . . . . . . . . . . . . . . . . . . . . . . . internal integers
##
IsInt := NewCategoryKernel( "IsInt", IsRat, IS_INT );


#############################################################################
##
#C  IsPosRat  . . . . . . . . . . . . . . . . . . internal positive rationals
##
IsPosRat := NewCategory( "IsPosRat", IsRat );


#############################################################################
##
#C  IsNegRat  . . . . . . . . . . . . . . . . . . internal negative rationals
##
IsNegRat := NewCategory( "IsNegRat", IsRat );


#############################################################################
##
#C  IsZeroCyc . . . . . . . . . . . . . . . . . . . . . internal zero integer
##
IsZeroCyc := NewCategory( "IsZeroCyc", IsInt );


#############################################################################
##

#V  CyclotomicsFamily . . . . . . . . . . . . . . . . . family of cyclotomics
##
CyclotomicsFamily := NewFamily( "CyclotomicsFamily", IsCyclotomic );


#############################################################################
##

#R  IsSmallIntRep . . . . . . . . . . . . . . . . . .  small internal integer
##
IsSmallIntRep := NewRepresentation( "IsSmallIntRep", IsInternalRep, [] );


#############################################################################
##
#V  TYPE_INT_SMALL_ZERO . . . . . . . . . . . . . . type of the internal zero
##
TYPE_INT_SMALL_ZERO := NewType( CyclotomicsFamily,
                            IsInt and IsZeroCyc and IsSmallIntRep );


#############################################################################
##
#V  TYPE_INT_SMALL_NEG  . . . . . . type of a small negative internal integer
##
TYPE_INT_SMALL_NEG := NewType( CyclotomicsFamily,
                            IsInt and IsNegRat and IsSmallIntRep );


#############################################################################
##
#V  TYPE_INT_SMALL_POS  . . . . . . type of a small positive internal integer
##
TYPE_INT_SMALL_POS := NewType( CyclotomicsFamily,
                            IsInt and IsPosRat and IsSmallIntRep );


#############################################################################
##
#V  TYPE_INT_LARGE_NEG  . . . . . . type of a large negative internal integer
##
TYPE_INT_LARGE_NEG := NewType( CyclotomicsFamily,
                            IsInt and IsNegRat and IsInternalRep );


#############################################################################
##
#V  TYPE_INT_LARGE_POS  . . . . . . type of a large positive internal integer
##
TYPE_INT_LARGE_POS := NewType( CyclotomicsFamily,
                            IsInt and IsPosRat and IsInternalRep );


#############################################################################
##
#V  TYPE_RAT_NEG  . . . . . . . . . . .  type of a negative internal rational
##
TYPE_RAT_NEG := NewType( CyclotomicsFamily,
                            IsRat and IsNegRat and IsInternalRep );


#############################################################################
##
#V  TYPE_RAT_POS  . . . . . . . . . . .  type of a positive internal rational
##
TYPE_RAT_POS := NewType( CyclotomicsFamily,
                            IsRat and IsPosRat and IsInternalRep );

#############################################################################
##
#V  TYPE_CYC  . . . . . . . . . . . . . . . . type of an internal cyclotomics
##
TYPE_CYC := NewType( CyclotomicsFamily, IsCyc and IsInternalRep );


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
IsInfinity := NewCategory( "IsInfinity", IsCyclotomic );


#############################################################################
##
#V  infinity  . . . . . . . . . . . . . . . . . . . . . .  the value infinity
##
infinity := Objectify( NewType( CyclotomicsFamily, IsInfinity
                 and IsPositionalObjectRep ), rec() );

InstallMethod( PrintObj,
    "method for infinity",
    true, [ IsInfinity ], 0, function(obj) Print("infinity"); end );

InstallMethod( \=,
    "method for cyclotomic and 'infinity'",
    IsIdentical, [ IsCyc, IsInfinity ], 0, ReturnFalse );

InstallMethod( \=,
    "method for 'infinity' and cyclotomic",
    IsIdentical, [ IsInfinity, IsCyc ], 0, ReturnFalse );

InstallMethod( \=,
    "method for 'infinity' and 'infinity'",
    IsIdentical, [ IsInfinity, IsInfinity ], 0, ReturnTrue );

InstallMethod( \<,
    "method for cyclotomic and 'infinity'",
    IsIdentical, [ IsCyc, IsInfinity ], 0, ReturnTrue );

InstallMethod( \<,
    "method for 'infinity' and cyclotomic",
    IsIdentical, [ IsInfinity, IsCyc ], 0, ReturnFalse );

InstallMethod( \<,
    "method for 'infinity' and 'infinity'",
    IsIdentical, [ IsInfinity, IsInfinity ], 0, ReturnFalse );


#############################################################################
##

#F  IsCycInt  . . . . . . . . . . . . . . . . . internal integral cyclotomics
##
##  Eventually this could become a property call 'IsIntegralCyclotomic'.
##
IsCycInt := IS_CYC_INT;


#############################################################################
##
#A  Conductor( <F> )
#A  Conductor( <z> )
##
##  is the smallest integer $n$ such that the field <F> or the field element
##  <z> is contained in the $n$-th cyclotomic field.
##  If <F> is not an abelian extension of the rationals or if <z> is not a
##  cyclotomic then 'fail' is returned.
##
Conductor := NewAttributeKernel( "Conductor", IsCyc, CONDUCTOR );
SetConductor := Setter( Conductor );
HasConductor := Tester( Conductor );


#############################################################################
##
#O  GaloisCyc( <cyc>, <int> ) . . . . . . . . . . . . . . .  galois conjugate
##
GaloisCyc := NewOperationKernel( "GaloisCyc", [ IsCyc, IsInt ], GALOIS_CYC );


#############################################################################
##

#F  NumeratorRat( <rat> ) . . . . . . . . . .  numerator of internal rational
##
NumeratorRat   := NUMERATOR_RAT;


#############################################################################
##
#F  DenominatorRat( <rat> ) . . . . . . . .  denominator of internal rational
##
DenominatorRat := DENOMINATOR_RAT;


#############################################################################
##
#F  QuoInt( <a>, <b> )  . . . . . . . . . . . . quotient of internal integers
##
QuoInt := QUO_INT;


#############################################################################
##
#F  RemInt( <a>, <b> )  . . . . . . . . . . .  remainder of internal integers
##
RemInt := REM_INT;


#############################################################################
##
#F  GcdInt( <a>, <b> )  . . . . . . . . . . . . . .  gcd of internal integers
##
GcdInt := GCD_INT;


#############################################################################
##

#M  Order( <z> ) . . . . . . . . . . . . . . . . . .  order of an alg. number
##
InstallMethod( Order, true, [ IsCyc ], 0,
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


##########################################################################
##
#M  Int( <cyc> )  . . . . . . . . . . . . .  cyclotomic integer near to <cyc>
##
InstallMethod( Int, true, [ IsCyc ], 0,
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
InstallMethod( Int, true, [ IsRat ], 0,
    obj -> QuoInt( NumeratorRat( obj ), DenominatorRat( obj ) ) );


#############################################################################
##
#M  Int( <n> )
##
InstallMethod( Int, true, [ IsInt ], 0, IdFunc );


#############################################################################
##
#M  String( <cyc> ) . . . . . . . . . . . .  convert cyclotomic into a string
##
InstallMethod( String, true, [ IsCyc ], 0,
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
InstallMethod( String, true, [ IsRat ], 0,
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
    "method for an integer",
    true,
    [ IsInt ], 0,
    STRING_INT );


#############################################################################
##
#M  String( <infinity> )  . . . . . . . . . . . . . . . . . . .  for infinity
##
InstallMethod( String,
    "method for infinity",
    true,
    [ IsInfinity ], 0,
    x -> "infinity" );


#############################################################################
##

#E  permutat.g	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
