#############################################################################
##
#W  ratfunul.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for rational functions that know that they
##  are univariate laurent polynomials.
##
Revision.ratfunul_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  UnivariateLaurentPolynomialByCoefficients( <fam>, <cofs>, <val>, <ind> )
##


#############################################################################
InstallMethod( UnivariateLaurentPolynomialByCoefficients,
    true,
    [ IsUFDFamily,
      IsList,
      IsInt,
      IsInt ],
    0,

function( fam, cofs, val, ind )
    local   f,  zeroCoefficient,  coefficients,  i,  j,  rfun;

    # construct a laurent polynomial
    f := rec();
    zeroCoefficient := Zero(fam);

    # make sure that the valuation is correct
    if 0 = Length(cofs)  then
        coefficients := [ cofs, 0 ];
    elif cofs[1] = zeroCoefficient  then
        i := 0;
        while i < Length(cofs) and cofs[i+1] = zeroCoefficient  do
            i := i+1;
        od;
        j := Length(cofs);
        while i < j and cofs[j] = zeroCoefficient  do
            j := j - 1;
        od;
        if i = j  then
            coefficients := [ [], 0 ];
        else
            coefficients := [ cofs{[i+1..j]}, val+i ];
        fi;
        coefficients := Immutable(coefficients);
    else
        j := Length(cofs);
        while 0 < j and cofs[j] = zeroCoefficient  do
            j := j - 1;
        od;
        if 0 = j  then
            coefficients := [ [], 0 ];
        elif Length(cofs) = j  then
            coefficients := [ cofs, val ];
        else
            coefficients := [ cofs{[1..j]}, val ];
        fi;
        coefficients := Immutable(coefficients);
    fi;

    # the rational functions family knows a type
    rfun := RationalFunctionsFamily(fam);

    # objectify
    Objectify( rfun!.univariateLaurentPolynomialType, f );
    SetIndeterminateNumberOfUnivariateLaurentPolynomial( f, ind );
    SetCoefficientsOfUnivariateLaurentPolynomial( f, coefficients );

    # check for constants and zero
    if 0 = coefficients[2] and 0 = Length(coefficients[1])  then
        SetIsConstantRationalFunction( f, true );
        SetIsZeroRationalFunction( f, true );
        SetIsUnivariatePolynomial( f, true );

    elif 0 = coefficients[2] and 1 = Length(coefficients[1])  then
        SetIsConstantRationalFunction( f, true );
        SetIsUnivariatePolynomial( f, true );

    elif 0 <= coefficients[2]  then
        SetIsUnivariatePolynomial( f, true );
    fi;

    # and return the polynomial
    return f;

end );


#############################################################################
InstallOtherMethod( UnivariateLaurentPolynomialByCoefficients,
    true,
    [ IsFamily,
      IsList,
      IsInt ],
    0,

function( fam, cofs, val )
    return UnivariateLaurentPolynomialByCoefficients( fam, cofs, val, 1 );
end );


#############################################################################
##
#M  UnivariatePolynomialByCoefficients( <fam>, <cofs>, <ind> )
##


#############################################################################
InstallMethod( UnivariatePolynomialByCoefficients,
    true,
    [ IsFamily,
      IsList,
      IsInt ],
    0,

function( fam, cofs, ind )
    return UnivariateLaurentPolynomialByCoefficients( fam, cofs, 0, ind );
end );


#############################################################################
InstallOtherMethod( UnivariatePolynomialByCoefficients,
    true,
    [ IsFamily,
      IsList ],
    0,

function( fam, cofs )
    return UnivariateLaurentPolynomialByCoefficients( fam, cofs, 0, 1 );
end );


#############################################################################
##
#M  UnivariatePolynomial( <ring>, <cofs>, <ind> )
##


#############################################################################
InstallMethod( UnivariatePolynomial,"ring,coeffs,ind",
    function(a,b,c) return IsIdenticalObj(a,b); end,
    [ IsRing, IsRingElementCollection, IsPosInt ], 0,
function( r, c, i )
    return UnivariatePolynomialByCoefficients(
        ElementsFamily(FamilyObj(r)), c, i );
end );


#############################################################################
InstallOtherMethod( UnivariatePolynomial,"ring,[],ind", true,
    [ IsRing, IsList and IsEmpty, IsPosInt ], 0,
function( r, c, i )
    return UnivariatePolynomialByCoefficients(
        ElementsFamily(FamilyObj(r)), c, i );
end );


#############################################################################
InstallOtherMethod( UnivariatePolynomial,"ring,coeffs",IsIdenticalObj,
    [ IsRing, IsList ], 0,
function( r, c )
    return UnivariatePolynomialByCoefficients(
        ElementsFamily(FamilyObj(r)), c, 1 );
end );


#############################################################################
##

#M  IndeterminateOfUnivariateLaurentPolynomial( <uni-laurent> )
##
InstallMethod( IndeterminateOfUnivariateLaurentPolynomial,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return UnivariatePolynomialByCoefficients(
        CoefficientsFamily(fam),
        [ FamilyObj(obj)!.zeroCoefficient, FamilyObj(obj)!.oneCoefficient ],
        IndeterminateNumberOfUnivariateLaurentPolynomial(obj) );
end );


#############################################################################
##
#M  CoefficientsOfUnivariateLaurentPolynomial( <uni-laurent>, <ind> )
##


#############################################################################
InstallOtherMethod( CoefficientsOfUnivariateLaurentPolynomial,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial,
      IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( poly, ind )
    local   tmp;

    tmp := CoefficientsOfUnivariateLaurentPolynomial(ind);
    if tmp[2] <> 1  then
        Error( "<ind> must be an indeterminate" );
    fi;
    if Length(tmp[1]) <> 1  then
        Error( "<ind> must be an indeterminate" );
    fi;
    if tmp[1][1] <> One(tmp[1][1])  then
        Error( "<ind> must be an indeterminate" );
    fi;
    return CoefficientsOfUnivariateLaurentPolynomial( poly,
        IndeterminateNumberOfUnivariateLaurentPolynomial(ind) );
end );


#############################################################################
InstallOtherMethod( CoefficientsOfUnivariateLaurentPolynomial,
    true,
    [ IsUnivariateLaurentPolynomial,
      IsInt ],
    0,

function( poly, ind )
    if IndeterminateNumberOfUnivariateLaurentPolynomial(poly) <> ind  then
        Error( "you must use ' PolynomialCoefficientsOfLaurentPolynomial'",
               " to get polynomial coefficients" );
    else
        return CoefficientsOfUnivariateLaurentPolynomial(poly);
    fi;
end );


#############################################################################
##
#M  CoefficientsOfUnivariatePolynomial( <uni-laurent> )
##
InstallMethod( CoefficientsOfUnivariatePolynomial,
    true,
    [ IsRationalFunction and IsUnivariatePolynomial ],
    0,

function( poly )
    local   tmp,  c;

    tmp := CoefficientsOfUnivariateLaurentPolynomial(poly);
    if tmp[2] < 0  then
        Error( "<poly> must not be a true Laurent polynomial" );
    fi;
    c := ShallowCopy(tmp[1]);
    RightShiftRowVector( c, tmp[2], FamilyObj(poly)!.zeroCoefficient );
    return c;
end );


#############################################################################
##
#M  DegreeOfUnivariateLaurentPolynomial( <uni-laurent> )
##
InstallMethod( DegreeOfUnivariateLaurentPolynomial,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   cofs;

    cofs := CoefficientsOfUnivariateLaurentPolynomial(obj);
    if IsEmpty(cofs[1])  then
        return infinity;
    else
        return cofs[2] + Length(cofs[1]) - 1;
    fi;
end );


#############################################################################
##
#M  DenominatorOfRationalFunction( <uni-laurent> )
##
InstallMethod( DenominatorOfRationalFunction,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   val;

    val := CoefficientsOfUnivariateLaurentPolynomial(obj)[2];
    if val < 0  then
        return IndeterminateOfUnivariateLaurentPolynomial(obj)^-val;
    else
        return One(obj);
    fi;
end );


#############################################################################
##
#M  NumeratorOfRationalFunction( <uni-laurent> )
##
InstallMethod( NumeratorOfRationalFunction,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   val;

    val := CoefficientsOfUnivariateLaurentPolynomial(obj)[2];
    if val < 0  then
        return IndeterminateOfUnivariateLaurentPolynomial(obj)^-val * obj;
    else
        return obj;
    fi;
end );


#############################################################################
##

#M  AdditiveInverse( <uni-laurent> )
##
##  This method  is installed for all  rational functions because it does not
##  matter if one  is in a 'RationalFunctionsFamily', a  'LaurentPolynomials-
##  Family', or  a  'UnivariatePolynomialsFamily'.  The  additive inverse  is
##  defined in all three cases.
##
UnivariateLaurentPolynomial_AdditiveInverse := function( obj )
    local   cofs,  indn;

    cofs := CoefficientsOfUnivariateLaurentPolynomial(obj);
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(obj);

    return UnivariateLaurentPolynomialByCoefficients(
        CoefficientsFamily( FamilyObj(obj) ),
        List( cofs[1], AdditiveInverse ), cofs[2], indn );
end;

InstallMethod( AdditiveInverse,
    "univariate laurent polynomial",
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,
    UnivariateLaurentPolynomial_AdditiveInverse );


#############################################################################
##
#M  Inverse( <uni-laurent>
##
##  This method is installed  only for elements of  'RationalFunctionsFamily'
##  because the inverse is not defined for elements of a 'LaurentPolynomials-
##  Family' or a 'UnivariatePolynomialsFamily'.
##
UnivariateLaurentPolynomial_Inverse := function( obj )
    local   cofs,  indn;

    # this only works if we have only one coefficient
    cofs := CoefficientsOfUnivariateLaurentPolynomial(obj);
    if 1 <> Length(cofs[1])  then
        TryNextMethod();
    fi;
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(obj);

    # invert the valuation
    return UnivariateLaurentPolynomialByCoefficients(
        CoefficientsFamily( FamilyObj(obj) ),
        cofs[1], -cofs[2], indn );


end;

InstallMethod( Inverse,
    "univariate laurent polynomial",
    true,
    [ IsRationalFunctionsFamilyElement and IsUnivariateLaurentPolynomial ],
    0,
    UnivariateLaurentPolynomial_Inverse );


#############################################################################
##
#M  One( <uni-laurent>
##
##  This method is installed for  all rational functions  because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The one is defined  in all
##  three cases.
##
InstallMethod( One,
    "univariate laurent polynomial",
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   efam,  indn;

    efam := CoefficientsFamily( FamilyObj(obj) );
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(obj);
    return UnivariateLaurentPolynomialByCoefficients( efam,
      [One(efam)], 0, indn );

end );


#############################################################################
##
#M  Zero( <uni-laurent>
##
##  This method is  installed for all rational functions  because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  zero is defined in all
##  three cases.
##
InstallMethod( Zero,
    "univariate laurent polynomial",
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   efam,  indn;

    efam := CoefficientsFamily( FamilyObj(obj) );
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(obj);
    return UnivariateLaurentPolynomialByCoefficients( efam,
      [], 0, indn );

end );


#############################################################################
##

#M  <uni-laurent> * <uni-laurent>
##
##  This method is installed for  all rational functions  because it does not
##  matter if  one is in  a 'RationalFunctionsFamily', a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  product is defined  in
##  all three cases.
##
UnivariateLaurentPolynomial_Prod := function( left, right )
    local   indn,  fam,  prd,  l,  r,  m,  n,  i,  z,  j,  val;

    # this only works for the same indeterminate
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(left);
    if indn <> IndeterminateNumberOfUnivariateLaurentPolynomial(right)  then
        TryNextMethod();
    fi;

    # fold the coefficients
    fam := FamilyObj(left);
    prd := [];
    l   := CoefficientsOfUnivariateLaurentPolynomial(left);
    r   := CoefficientsOfUnivariateLaurentPolynomial(right);
    m   := Length(l[1]);
    n   := Length(r[1]);
    for i  in [ 1 .. m+n-1 ]  do
        z := fam!.zeroCoefficient;
        for j  in [ Maximum(i+1-n,1) .. Minimum(m,i) ]  do
            z := z + l[1][j] * r[1][i+1-j];
        od;
        prd[i] := z;
    od;
    val := l[2] + r[2];

    # return the polynomial
    return UnivariateLaurentPolynomialByCoefficients(
        CoefficientsFamily( FamilyObj(left) ),
        prd, val, indn );

end;

InstallMethod( \*,
    "uni-laurent * uni-laurent",
    IsIdenticalObj,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial,
      IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,
    UnivariateLaurentPolynomial_Prod );


#############################################################################
##
#M  <uni-laurent> + <uni-laurent>
##
##  This method is  installed for all  rational functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The sum is defined  in all
##  three cases.
##
UnivariateLaurentPolynomial_Sum := function( left, right )
    local   indn,  fam,  prd,  zero,  l,  r,  val,  sum,  vdf,  i;

    # this only works for the same indeterminate
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(left);
    if indn <> IndeterminateNumberOfUnivariateLaurentPolynomial(right)  then
        TryNextMethod();
    fi;

    # get the coefficients
    fam  := FamilyObj(left);
    prd  := [];
    zero := fam!.zeroCoefficient;
    l    := CoefficientsOfUnivariateLaurentPolynomial(left);
    r    := CoefficientsOfUnivariateLaurentPolynomial(right);

    # add both coefficients lists
    if l[2] < r[2]  then
        val := l[2];
        sum := ShallowCopy(l[1]);
        vdf := r[2] - l[2];
        for i  in [ Length(sum)+1 .. Length(r[1])+vdf ] do
            sum[i] := zero;
        od;
        for i  in [ 1 .. Length(r[1]) ]  do
            sum[i+vdf] := sum[i+vdf] + r[1][i];
        od;
    else
        val := r[2];
        sum := ShallowCopy(r[1]);
        vdf := l[2] - r[2];
        for i  in [ Length(sum)+1 .. Length(l[1])+vdf ] do
            sum[i] := zero;
        od;
        for i  in [ 1 .. Length(l[1]) ]  do
            sum[i+vdf] := l[1][i] + sum[i+vdf];
        od;
    fi;

    # and return the polynomial
    return UnivariateLaurentPolynomialByCoefficients(
        CoefficientsFamily( FamilyObj(left) ),
        sum, val, indn );

end;

InstallMethod( \+,
    "uni-laurent + uni-laurent",
    IsIdenticalObj,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial,
      IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,
    UnivariateLaurentPolynomial_Sum );


#############################################################################
##
#M  <coeff>       * <uni-laurent>
##
##  This method is installed for  all rational functions  because it does not
##  matter if  one is in  a 'RationalFunctionsFamily', a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  product is defined  in
##  all three cases.
##
InstallMethod( \*,
    "coeff * uni-laurent",
    IsCoeffsElms,
    [ IsRingElement,
      IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,


function( left, right )
    local   zero,  indn,  tmp,  prd,  val;

    # multiply by zero gives the zero polynomial
    zero := FamilyObj(right)!.zeroCoefficient;
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(right);
    if left = zero  then
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(right) ),
            [], 0, indn );

    # construct the product and check the valuation in case zero divisors
    else
        tmp := CoefficientsOfUnivariateLaurentPolynomial(right);
        prd := left * tmp[1];
        val := 0;
        while val < Length(prd) and prd[val+1] = zero  do
            val := val + 1;
        od;
        if Length(prd) = val  then
            return UnivariateLaurentPolynomialByCoefficients(
                CoefficientsFamily( FamilyObj(right) ),
                [], 0, indn );
        elif 0 = val  then
            return UnivariateLaurentPolynomialByCoefficients(
                CoefficientsFamily( FamilyObj(right) ),
                prd, tmp[2], indn );
        else
            return UnivariateLaurentPolynomialByCoefficients(
                CoefficientsFamily( FamilyObj(right) ),
                prd{[val+1..Length(prd)]}, tmp[2]+val, indn );
        fi;
    fi;

end );


#############################################################################
##
#M  <coeff>       + <uni-laurent>
##
##  This method is  installed for all  rational functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The sum is defined  in all
##  three cases.
##
InstallMethod( \+,
    "coeff + uni-laurent",
    IsCoeffsElms,
    [ IsRingElement,
      IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,


function( left, right )
    local   zero,  tmp,  indn,  val,  sum,  i;

    zero := FamilyObj(right)!.zeroCoefficient;
    tmp  := CoefficientsOfUnivariateLaurentPolynomial(right);
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(right);
    val  := tmp[2];

    # if left is trivial return right
    if left = zero  then
        return right;

    # the polynomial is trivial
    elif 0 = Length(tmp[1])  then
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(right) ),
            [left], 0, indn );

    # the constant is present
    elif val <= 0 and 0 < val + Length(tmp[1])  then
        sum := ShallowCopy(tmp[1]);
        sum[1-val] := left + sum[1-val];
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(right) ),
            sum, val, indn );

    # every coefficients has a negative exponent
    elif val + Length(tmp[1]) <= 0  then
        sum := ShallowCopy(tmp[1]);
        for i  in [ Length(sum)+1 .. -val ]  do
            sum[i] := zero;
        od;
        sum[1-val] := left;
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(right) ),
            sum, val, indn );

    # every coefficients has a positive exponent
    else
        sum := [left];
        for i  in [ 2 .. val ]  do
            sum[i] := zero;
        od;
        Append( sum, tmp[1] );
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(right) ),
            sum, 0, indn );

    fi;
end );


#############################################################################
##
#M  <uni-laurent> * <coeff>
##
##  This method is installed for  all rational functions  because it does not
##  matter if  one is in  a 'RationalFunctionsFamily', a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  product is defined  in
##  all three cases.
##
InstallMethod( \*,
    "uni-laurent * coeff",
    IsElmsCoeffs,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial,
      IsRingElement ],
    0,


function( left, right )
    local   zero,  indn,  tmp,  prd,  val;

    # multiply by zero gives the zero polynomial
    zero := FamilyObj(left)!.zeroCoefficient;
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(left);
    if right = zero  then
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(left) ),
            [], 0, indn );

    # construct the product and check the valuation in case zero divisors
    else
        tmp := CoefficientsOfUnivariateLaurentPolynomial(left);
        prd := tmp[1] * right;
        val := 0;
        while val < Length(prd) and prd[val+1] = zero  do
            val := val + 1;
        od;
        if Length(prd) = val  then
            return UnivariateLaurentPolynomialByCoefficients(
                CoefficientsFamily( FamilyObj(left) ),
                [], 0, indn );

        elif 0 = val  then
            return UnivariateLaurentPolynomialByCoefficients(
                CoefficientsFamily( FamilyObj(left) ),
                prd, tmp[2], indn );

        else
            return UnivariateLaurentPolynomialByCoefficients(
                CoefficientsFamily( FamilyObj(left) ),
                prd{[val+1..Length(prd)]}, tmp[2]+val, indn );
        fi;
    fi;

end );


#############################################################################
##
#M  <uni-laurent> + <coeff>
##
##  This method is  installed for all  rational functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The sum is defined  in all
##  three cases.
##
InstallMethod( \+,
    "uni-laurent + coeff",
    IsElmsCoeffs,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial,
      IsRingElement ],
    0,


function( left, right )
    local   zero,  tmp,  indn,  val,  sum,  i;

    zero := FamilyObj(left)!.zeroCoefficient;
    tmp  := CoefficientsOfUnivariateLaurentPolynomial(left);
    indn := IndeterminateNumberOfUnivariateLaurentPolynomial(left);
    val  := tmp[2];

    # if right is trivial return
    if right = zero  then
        return left;

    # the polynomial is trivial
    elif 0 = Length(tmp[1])  then
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(left) ),
            [right], 0, indn );

    # the constant is present
    elif val <= 0 and 0 < val + Length(tmp[1])  then
        sum := ShallowCopy(tmp[1]);
        sum[1-val] := right + sum[1-val];
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(left) ),
            sum, val, indn );

    # every coefficients has a negative exponent
    elif val + Length(tmp[1]) <= 0  then
        sum := ShallowCopy(tmp[1]);
        for i  in [ Length(sum)+1 .. -val ]  do
            sum[i] := zero;
        od;
        sum[1-val] := right;
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(left) ),
            sum, val, indn );

    # every coefficients has a positive exponent
    else
        sum := [right];
        for i  in [ 2 .. val ]  do
            sum[i] := zero;
        od;
        Append( sum, tmp[1] );
        return UnivariateLaurentPolynomialByCoefficients(
            CoefficientsFamily( FamilyObj(left) ),
            sum, 0, indn );

    fi;
end );

#############################################################################
##
#F  BRCIUnivPols( <upol>, <upol> ) test for common base ring and for
##                           common indeterminate of UnivariatePolynomials
InstallGlobalFunction( BRCIUnivPols, function(f,g)
local dom,x;
  if IsUnivariatePolynomial(f) and IsUnivariatePolynomial(g) then
    x:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    if x=IndeterminateNumberOfUnivariateLaurentPolynomial(g) then
      dom:=CoefficientsFamily(FamilyObj(f));
      if dom=CoefficientsFamily(FamilyObj(g)) then
	return [dom,x];
      fi;
    fi;
  fi;
  return fail;
end );

#############################################################################
##
#M  <unilau> / <unilau> (if possible)
##
InstallMethod(\/,"upol/upol",true,[IsUnivariateLaurentPolynomial,
  IsUnivariateLaurentPolynomial],2,
function(a,b)
local q;
  q:=BRCIUnivPols(a,b);
  if q=fail then 
    TryNextMethod();
  fi;
  q:=Quotient(a,b);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);


#############################################################################
##
#E  ratfunul.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

