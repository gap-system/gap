#############################################################################
##
#W  ratfun.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains    the  methods  for    rational  functions,  laurent
##  polynomials and polynomials and their families.
##
Revision.ratfun_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
##
InstallMethod( ZippedSum,
    true,
    [ IsList,
      IsList,
      IsObject,
      IsList ],
    0,

function( z1, z2, zero, f )
    local   sum,  i1,  i2,  i;

    sum := [];
    i1  := 1;
    i2  := 1;
    while i1 <= Length(z1) and i2 <= Length(z2)  do
        if z1[i1] = z2[i2]  then
            i := f[2]( z1[i1+1], z2[i2+1] );
            if i <> zero  then
                Add( sum, z1[i1] );
                Add( sum, i );
            fi;
            i1 := i1+2;
            i2 := i2+2;
        elif f[1]( z1[i1], z2[i2] )  then
            if z1[i1+1] <> zero  then
                Add( sum, z1[i1] );
                Add( sum, z1[i1+1] );
            fi;
            i1 := i1+2;
        else
            if z2[i2+1] <> zero  then
                Add( sum, z2[i2] );
                Add( sum, z2[i2+1] );
            fi;
            i2 := i2+2;
        fi;
    od;
    for i  in [ i1, i1+2 .. Length(z1)-1 ]  do
        if z1[i+1] <> zero  then
            Add( sum, z1[i] );
            Add( sum, z1[i+1] );
        fi;
    od;
    for i  in [ i2, i2+2 .. Length(z2)-1 ]  do
        if z2[i+1] <> zero  then
            Add( sum, z2[i] );
            Add( sum, z2[i+1] );
        fi;
    od;
    return sum;
end );


#############################################################################
##
#M  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
##
InstallMethod( ZippedProduct,
    true,
    [ IsList,
      IsList,
      IsObject,
      IsList ],
    0,

function( z1, z2, zero, f )
    local   mons,  cofs,  i,  j,  c,  prd;

    # fold the product
    mons := [];
    cofs := [];
    for i  in [ 1, 3 .. Length(z1)-1 ]  do
        for j  in [ 1, 3 .. Length(z2)-1 ]  do
            c := f[4]( z1[i+1], z2[j+1] );
            if c <> zero  then
                Add( mons, f[1]( z1[i], z2[j] ) );
                Add( cofs, c );
            fi;
        od;
    od;

    # sort monomials
    SortParallel( mons, cofs, f[2] );

    # sum coeffs
    prd := [];
    i   := 1;
    while i <= Length(mons)  do
        c := cofs[i];
        while i < Length(mons) and mons[i] = mons[i+1]  do
            i := i+1;
            c := f[3]( c, cofs[i] );
        od;
        if c <> zero  then
            Add( prd, mons[i] );
            Add( prd, c );
        fi;
        i := i+1;
    od;

    # and return the product
    return prd;

end );


#############################################################################
##

#R  IsRationalFunctionDefaultRep
##
IsRationalFunctionDefaultRep := NewRepresentation(
    "IsRationalFunctionDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##
#R  IsPolynomialDefaultRep
##
IsPolynomialDefaultRep := NewRepresentation(
    "IsPolynomialDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##
#R  IsUnivariateLaurentPolynomialDefaultRep
##
IsUnivariateLaurentPolynomialDefaultRep := NewRepresentation(
    "IsUnivariateLaurentPolynomialDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##

#M  RationalFunctionsFamily( <fam> )
##
ZippedListProduct := function( l, r )
    return ZippedSum( l, r, 0, [ \<, \+ ] );
end;

InstallMethod( RationalFunctionsFamily,
    true,
    [ IsUFDFamily ],
    0,

function( efam )
    local   fam;

    # create a new family in the category <IsRationalFunctionsFamily>
    fam := NewFamily(
      "RationalFunctionsFamily(...)",
      IsRationalFunction and IsRationalFunctionsFamilyElement,
      IsObject,
      IsUFDFamily and IsRationalFunctionsFamily );

    # default kind for rational functions
    fam!.rationalKind := NewKind( fam,
        IsRationalFunctionDefaultRep );

    # default kind for polynomials
    fam!.polynomialKind := NewKind( fam,
        IsPolynomial and IsPolynomialDefaultRep );

    # default kind for univariate laurent polynomials
    fam!.univariateLaurentPolynomialKind := NewKind( fam,
        IsUnivariateLaurentPolynomial
        and IsUnivariateLaurentPolynomialDefaultRep );

    # functions to add zipped lists
    fam!.zippedSum := [ \<, \+ ];

    # functions to multiply zipped lists
    fam!.zippedProduct := [ ZippedListProduct, \<, \+, \* ];

    # set the one and zero coefficient
    fam!.zeroCoefficient := Zero(efam);
    fam!.oneCoefficient  := One(efam);

    # set the coefficients
    SetCoefficientsFamily( fam, efam );

    # and set one and zero
    SetZero( fam, ObjByExtRep( fam, [ Zero(efam), [] ] ) );;
    SetOne( fam, ObjByExtRep( fam, [ Zero(efam), [ [], One(efam) ] ] ) );

    # and return
    return fam;

end );


#############################################################################
##
#F  UnivariateLaurentPolynomial_PrintObj( <obj> )
##
UnivariateLaurentPolynomial_PrintObj := function( f )
    local   fam,  ind,  zero,  one,  mone,  i,  c;

    fam := FamilyObj(f);
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    f   := CoefficientsOfUnivariateLaurentPolynomial(f);
    zero := fam!.zeroCoefficient;
    one  := One(zero);
    mone := -one;
    for i  in [ 1 .. Length(f[1] ) ]  do
        if f[1][i] <> zero  then

            # print a '+' if necessary
            c := "*";
            if i > 1  then
                if IsRat(f[1][i])  then
                    if f[1][i] > 0  then
                        Print( "+", f[1][i] );
                    elif f[1][i] = one  then
                        Print( "+" );
                        c := "";
                    elif f[1][i] = mone  then
                        Print( "-" );
                        c := "";
                    else
                        Print( f[1][i] );
                    fi;
                elif f[1][i] = one  then
                    Print( "+" );
                    c := "";
                elif f[1][i] = mone  then
                    Print( "-" );
                    c := "";
                else
                    Print( "+", f[1][i] );
                fi;
            elif f[1][i] = one  then
                Print("");
                c := "";
            elif f[1][i] = mone  then
                Print("-");
                c := "";
            else
                Print(f[1][i]);
            fi;
            if i+f[2] <> 1  then
                Print( c, "x" );
                if i+f[2] <> 2  then
                    Print( "^", i+f[2]-1 );
                fi;
            elif f[1][i] = one  then
                Print(one);
            elif f[1][i] = mone  then
                Print(one);
            fi;
        fi;
    od;
end;


#############################################################################
##
#F  ExtRepOfPolynomial_PrintObj( <obj> )
##
ExtRepOfPolynomial_PrintObj := function( ext )
    local   zero,  one,  mone,  i,  d,  c,  j;

    zero := ext[1];
    one  := One(zero);
    mone := -one;
    ext  := ext[2];
    for i  in [ 1, 3 .. Length(ext)-1 ]  do
        d := "";
        if 1 < i  then
            d := "+";
        fi;
        c := "*";
        if ext[i+1] = one and 0 < Length(ext[i])  then
            c := "";
        elif ext[i+1] = mone and 0 < Length(ext[i])  then
            c := "";
            d := "-";
        else
            Print( d, ext[i+1] );
            d := "";
        fi;
        Print(d);
        if 0 < Length(ext[i])  then
            Print(c);
            for j  in [ 1, 3 .. Length(ext[i])-1 ]  do
                if 1 < j  then
                    Print( "*" );
                fi;
                if 1 = ext[i][j+1]  then
                    Print( "x", ext[i][j] );
                else
                    Print( "x", ext[i][j], "^", ext[i][j+1] );
                fi;
            od;
        fi;
    od;

end;


#############################################################################
##
#M  PrintObj( <rat-fun> )
##
##  This method is installed for all  rational functions because it  does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.
##
InstallMethod( PrintObj,
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    local   dom,  ext,  fam;

    dom := CoefficientsFamily(FamilyObj(obj));
    if HasCharacteristic(dom)  then
        Print( "PmultC", Characteristic(dom), "(" );
    else
        Print( "Pmult(" );
    fi;
    ext := ExtRepOfObj(obj);
    fam := FamilyObj(obj);
    if 2 = Length(ext)  then
        ExtRepOfPolynomial_PrintObj(ext);
    else
        Print( "(" );
        ExtRepOfPolynomial_PrintObj(ext{[1,2]});
        Print( ")" );
        Print( "/" );
        Print( "(" );
        ExtRepOfPolynomial_PrintObj(ext{[1,3]});
        Print( ")" );
    fi;
    Print( ")" );
end );


#############################################################################
##
#M  PrintObj( <uni-laurent> )
##
##  This method is installed for all  rational functions because it  does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.
##
InstallMethod( PrintObj,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( f )
    local   dom,  ind;

    dom := CoefficientsFamily(FamilyObj(f));
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    if HasCharacteristic(dom)  then
        Print( "P", ind, "C", Characteristic(dom), "(" );
    else
        Print( "P", ind, "(" );
    fi;
    UnivariateLaurentPolynomial_PrintObj(f);
    Print( ")" );
end );


#############################################################################
##

#M  ExtRepOfObj( <poly> )
##
##  This method is installed for all  rational functions because it  does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.
##
InstallMethod( ExtRepOfObj,
    true,
    [ IsRationalFunction and IsPolynomialDefaultRep ],
    0,

function( obj )
    return [ obj!.zeroCoefficient, obj!.numerator ];
end );


#############################################################################
##
#M  ExtRepOfObj( <rat-fun> )
##
##  This method is installed for all  rational functions because it  does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.
##
InstallMethod( ExtRepOfObj,
    true,
    [ IsRationalFunction and IsRationalFunctionDefaultRep ],
    0,

function( obj )
    return [ obj!.zeroCoefficient, obj!.numerator, obj!.denominator ];
end );


#############################################################################
##
#M  ExtRepOfObj( <uni-laurent> )
##
##  This method is installed for all  rational functions because it  does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.
##
InstallMethod( ExtRepOfObj,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomialDefaultRep ],
    0,

function( obj )
    local   zero,  cofs,  val,  ind,  quo,  ext,  i,  j;

    zero := FamilyObj(obj)!.zeroCoefficient;
    cofs := CoefficientsOfUnivariateLaurentPolynomial(obj);
    val  := cofs[2];
    cofs := cofs[1];
    ind  := IndeterminateNumberOfUnivariateLaurentPolynomial(obj);

    if val < 0  then
        quo := [ [ ind, -val ], One(cofs[1]) ];
        val := 0;
    fi;

    ext := [];
    for i  in [ 0 .. Length(cofs)-1 ]  do
        if cofs[i+1] <> zero  then
            j := val + i;
            if j <> 0  then
                Add( ext, [ ind, j ] );
                Add( ext, cofs[i+1] );
            else
                Add( ext, [] );
                Add( ext, cofs[i+1] );
            fi;
        fi;
    od;

    if IsBound(quo)  then
        return [ zero, ext, quo ];
    else
        return [ zero, ext ];
    fi;

end );


#############################################################################
##
#M  ObjByExtRep( <rat-fun-fam>, <zipped> )
##
##   the monomials in 'zipped' must be sorted, i.e. [1,2,2,1] instead of
##   [2,1,1,2]
InstallMethod( ObjByExtRep,
    true,
    [ IsRationalFunctionsFamily,
      IsList ],
    0,

function( fam, zipped )
    local   rf;

    rf := rec();
    if 2 = Length(zipped)  then
        rf.zeroCoefficient := Immutable(zipped[1]);
        rf.numerator       := Immutable(zipped[2]);
        Objectify( fam!.polynomialKind, rf );
    elif 3 = Length(zipped)  then
        if 0 = Length(zipped[3])  then
            Error( "denominator must be non-trivial" );
        fi;
        rf.zeroCoefficient := Immutable(zipped[1]);
        rf.numerator       := Immutable(zipped[2]);
        rf.denominator     := Immutable(zipped[3]);
        Objectify( fam!.rationalKind, rf );
    else
        Error( "<zipped> must have length 2 or 3" );
    fi;
    return rf;
end );


#############################################################################
##

#M  DenominatorOfRationalFunction( <poly> )
##
InstallMethod( DenominatorOfRationalFunction,
    true,
    [ IsRationalFunction and IsPolynomial ],
    0,

function( poly )
    return One(poly);
end );


#############################################################################
##
#M  NumeratorOfRationalFunction( <poly> )
##
InstallMethod( NumeratorOfRationalFunction,
    true,
    [ IsRationalFunction and IsPolynomial ],
    0,

function( poly )
    return poly;
end );


#############################################################################
##

#M  IsLaurentPolynomial( <rat-fun> )
##
InstallMethod( IsLaurentPolynomial,
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    local   den;
    
    # we cannot use 'ExtRepOfObj' because we need a reduced denominator
    den := ExtRepOfObj( DenominatorOfRationalFunction(obj) );

    # there has to be only one monomial
    return 2 = Length(den[2]);
end );


#############################################################################
##
#M  IsPolynomial( <rat-fun> )
##
InstallMethod( IsPolynomial,
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    local   den;
    
    # we cannot use 'ExtRepOfObj' because we need a reduced denominator
    den := ExtRepOfObj( DenominatorOfRationalFunction(obj) );

    # there has to be only one monomial of degree zero
    return 2 = Length(den[2]) and IsEmpty(den[2][1]);
end );


#############################################################################
##
#M  IsUnivariateLaurentPolynomial( <rat-fun> )
##
InstallMethod( IsUnivariateLaurentPolynomial,
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    return IsUnivariateRationalFunction(obj) and IsLaurentPolynomial(obj);
end );


#############################################################################
##
#M  IsUnivariatePolynomial( <rat-fun> )
##
InstallMethod( IsUnivariatePolynomial,
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    return IsUnivariateRationalFunction(obj) and IsPolynomial(obj);
end );


#############################################################################
##
#M  IsUnivariateRationalFunction( <rat-fun> )
##
InstallMethod( IsUnivariateRationalFunction,
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    local   den,  num,  ind,  i;

    # we cannot use 'ExtRepOfObj' because we need a reduced num/den
    den := ExtRepOfObj( DenominatorOfRationalFunction(obj) );
    num := ExtRepOfObj( NumeratorOfRationalFunction(obj) );

    # now check the monials
    ind := false;
    for i  in [ 1, 3 .. Length(den[2])-1 ]  do
        if 2 < Length(den[2][i])  then
            return false;
        elif 2 = Length(den[2][i])  then
            if ind = false  then
                ind := den[2][i][1];
            elif ind <> den[2][i][1]  then
                return false;
            fi;
        fi;
    od;
    for i  in [ 1, 3 .. Length(num[2])-1 ]  do
        if 2 < Length(num[2][i])  then
            return false;
        elif 2 = Length(num[2][i])  then
            if ind = false  then
                ind := num[2][i][1];
            elif ind <> num[2][i][1]  then
                return false;
            fi;
        fi;
    od;
    return true;
                   
end );


#############################################################################
##
#M  CoefficientsOfUnivariateLaurentPolynomial( <rat-fun> )
##
InstallMethod( CoefficientsOfUnivariateLaurentPolynomial,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   num,  den,  val,  cof,  coefs,  i;

    # we cannot use 'ExtRepOfObj' because we need a reduced den/num
    num := ExtRepOfObj( NumeratorOfRationalFunction(obj) );
    den := ExtRepOfObj( DenominatorOfRationalFunction(obj) );

    # get the valuation
    if 0 = Length(den[2][1])  then
        val := 0;
        cof := One(num[1]);
    else
        val := den[2][1][2];
        cof := den[2][2];
    fi;

    # get the coeffs from <num>
    coefs := [];
    for i  in [ 1, 3 .. Length(num[2])-1 ]  do
        if 0 = Length(num[2][i])  then
            coefs[1] := num[2][i+1] / cof;
        else
            #T  1996/11/11 fceller what is correct side for <cof>?
            #T  1996/11/11 fceller "cof^-1 * num[2][i+1]"?
            coefs[num[2][i][2]+1] := num[2][i+1] / cof;
        fi;
    od;
    for i  in [ 1 .. Length(coefs) ]  do
        if not IsBound(coefs[i])  then
            coefs[i] := num[1];
        fi;
    od;

    # and normalize
    val := val + RemoveOuterCoeffs( coefs, num[1] );
    return [ coefs, val ];

end );


#############################################################################
##
#M  IndeterminateNumberOfUnivariateLaurentPolynomial( <rat-fun> )
##
InstallMethod( IndeterminateNumberOfUnivariateLaurentPolynomial,
    true,
    [ IsRationalFunction and IsUnivariateLaurentPolynomial ],
    0,

function( obj )
    local   num,  den;

    # we cannot use 'ExtRepOfObj' because we need a reduced den/num
    num := ExtRepOfObj( NumeratorOfRationalFunction(obj) );
    den := ExtRepOfObj( DenominatorOfRationalFunction(obj) );

    if 2 <= Length(den[2])  then
        if 2 <= Length(den[2][1])  then
            return den[2][1][1][1];
        else
            if 2 <= Length(num[2])  then
                if 2 <= Length(num[2][1])  then
                    return num[2][1][1];
                else
                    return 1;
                fi;
            else
                return 1;
            fi;
        fi;
    elif 2 <= Length(num[2])  then
        if 2 <= Length(num[2][1])  then
            return num[2][1][1];
        else
            return 1;
        fi;
    else
        return 1;
    fi;

end );


#############################################################################
##

#M  AdditiveInverse( <rat-fun> )
##
##  This method  is installed for all  rational functions because it does not
##  matter if one  is in a 'RationalFunctionsFamily', a  'LaurentPolynomials-
##  Family', or  a  'UnivariatePolynomialsFamily'.  The  additive inverse  is
##  defined in all three cases.
##
RationalFunction_AdditiveInverse := function( obj )
    local   fam,  i;

    fam := FamilyObj(obj);
    obj := ShallowCopy(ExtRepOfObj(obj));
    obj[2] := ShallowCopy(obj[2]);
    for i  in [ 2, 4 .. Length(obj[2]) ]  do
        obj[2][i] := -obj[2][i];
    od;
    return ObjByExtRep( fam, obj );
end;

InstallMethod( AdditiveInverse,
    "rational function",
    true,
    [ IsRationalFunction ],
    0,
    RationalFunction_AdditiveInverse );


#############################################################################
##
#M  Inverse( <rat-fun> )
##
##  This method is installed  only for elements of  'RationalFunctionsFamily'
##  because the inverse is not defined for elements of a 'LaurentPolynomials-
##  Family' or a 'UnivariatePolynomialsFamily'.
##
RationalFunction_Inverse := function( obj )
    local   fam;

    # get the family and check the zeros
    fam := FamilyObj(obj);
    obj := ExtRepOfObj(obj);

    # create a new rational function
    if 2 = Length(obj)  then
        
        #T  1996/09/30 fceller this will break for ring-family-without-1
        return ObjByExtRep( fam, [ obj[1], [[],One(obj[1])], obj[2] ] );
    else
        return ObjByExtRep( fam, [ obj[1], obj[3], obj[2] ] );
    fi;

end;

InstallMethod( Inverse,
    "rational function",
    true,
    [ IsRationalFunctionsFamilyElement ],
    0,
    RationalFunction_Inverse );


#############################################################################
##
#M  One( <rat-fun> )
##
##  This method is installed for  all rational functions  because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The one is defined  in all
##  three cases.
##
InstallMethod( One,
    "rational function",
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    local   efam;

    efam := CoefficientsFamily( FamilyObj(obj) );
    return UnivariateLaurentPolynomialByCoefficients( efam,
      [One(efam)], 0, 1 );

end );


#############################################################################
##
#M  Zero( <rat-fun> )
##
##  This method is  installed for all rational functions  because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  zero is defined in all
##  three cases.
##
InstallMethod( Zero,
    "rational function",
    true,
    [ IsRationalFunction ],
    0,

function( obj )
    local   efam;

    efam := CoefficientsFamily( FamilyObj(obj) );
    return UnivariateLaurentPolynomialByCoefficients( efam,
      [], 0, 1 );

end );


#############################################################################
##

#M  <rat-fun>     * <rat-fun>
##
##  This method is installed for  all rational functions  because it does not
##  matter if  one is in  a 'RationalFunctionsFamily', a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  product is defined  in
##  all three cases.
##
RationalFunction_Prod := function( left, right )
    local   fam,  fun,  num,  den;

    # get the family and check the zeros
    fam   := FamilyObj(left);
    left  := ExtRepOfObj(left);
    right := ExtRepOfObj(right);
    if left[1] <> right[1]  then
        Error( "incompatible zeros" );
    fi;

    # polynomial * polynomial
    if 2 = Length(left) and 2 = Length(right)  then
        num := ZippedProduct(left[2], right[2], left[1], fam!.zippedProduct);
        return ObjByExtRep( fam, [ left[1], num ] );

    # polynomial * rat-fun
    elif 2 = Length(left) and 3 = Length(right)  then
        num := ZippedProduct(left[2], right[2], left[1], fam!.zippedProduct);
        return ObjByExtRep( fam, [ left[1], num, right[3] ] );

    # rat-fun * polynomial
    elif 3 = Length(left) and 2 = Length(right)  then
        num := ZippedProduct(left[2], right[2], left[1], fam!.zippedProduct);
        return ObjByExtRep( fam, [ left[1], num, left[3] ] );

    # rat-fun * rat-fun
    elif 3 = Length(left) and 3 = Length(right)  then
        num := ZippedProduct(left[2], right[2], left[1], fam!.zippedProduct);
        den := ZippedProduct(left[3], right[3], left[1], fam!.zippedProduct);
        return ObjByExtRep( fam, [ left[1], num, den ] );
    fi;

end;

InstallMethod( \*,
    "rat-fun * rat-fun",
    IsIdentical,
    [ IsRationalFunction,
      IsRationalFunction ],
    0,
    RationalFunction_Prod );


#############################################################################
##
#M  <rat-fun>     / <rat-fun>
##
##  This method is installed  only for elements of  'RationalFunctionsFamily'
##  because the inverse is not defined for elements of a 'LaurentPolynomials-
##  Family' or a 'UnivariatePolynomialsFamily'.
##
RationalFunction_Quo := function( left, right )
    return left * Inverse(right);
end;

InstallMethod( \/,
    "rat-fun / rat-fun",
    IsIdentical,
    [ IsRationalFunctionsFamilyElement,
      IsRationalFunctionsFamilyElement ],
    0,
    RationalFunction_Quo );


#############################################################################
##
#M  <rat-fun>     + <rat-fun>
##
##  This method is  installed for all  rational functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The sum is defined  in all
##  three cases.
##
RationalFunction_Sum := function( left, right )
    local   fam,  fun,  num,  den;

    # get the family and check the zeros
    fam   := FamilyObj(left);
    left  := ExtRepOfObj(left);
    right := ExtRepOfObj(right);
    if left[1] <> right[1]  then
        Error( "incompatible zeros" );
    fi;

    # polynomial + polynomial
    if 2 = Length(left) and 2 = Length(right)  then
        num := ZippedSum(left[2], right[2], left[1], fam!.zippedSum);
        return ObjByExtRep( fam, [ left[1], num ] );

    # polynomial + rat-fun
    elif 2 = Length(left) and 3 = Length(right)  then
        num := ZippedProduct(left[2], right[3], left[1], fam!.zippedProduct);
        num := ZippedSum(num, right[2], left[1], fam!.zippedSum);
        return ObjByExtRep( fam, [ left[1], num, right[3] ] );

    # rat-fun + polynomial
    elif 3 = Length(left) and 2 = Length(right)  then
        num := ZippedProduct(left[3], right[2], left[1], fam!.zippedProduct);
        num := ZippedSum(left[2], num, left[1], fam!.zippedSum);
        return ObjByExtRep( fam, [ left[1], num, left[3] ] );

    # rat-fun + rat-fun
    elif 3 = Length(left) and 3 = Length(right)  then
        num := ZippedSum(
            ZippedProduct( left[2], right[3], left[1], fam!.zippedProduct ),
            ZippedProduct( left[3], right[2], left[1], fam!.zippedProduct ),
            left[1], fam!.zippedSum );
        den := ZippedProduct(left[3], right[3], left[1], fam!.zippedProduct);
        return ObjByExtRep( fam, [ left[1], num, den ] );
    fi;

end;

InstallMethod( \+,
    "rat-fun + rat-fun",
    IsIdentical,
    [ IsRationalFunction,
      IsRationalFunction ],
    0,
    RationalFunction_Sum );


#############################################################################
##
#M  <rat-fun>     = <rat-fun>
##
##  This method is  installed for all  rational functions because it does not
##  matter if one  is in a  'RationalFunctionsFamily', a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The equality is defined in
##  all three cases.
##
RationalFunction_Equal := function( left, right )
    local   fam,  p1,  p2;

    # get the family and check the zeros
    fam   := FamilyObj(left);
    left  := ExtRepOfObj(left);
    right := ExtRepOfObj(right);
    if left[1] <> right[1]  then
        return false;
    fi;

    # polynomial = polynomial
    if 2 = Length(left) and 2 = Length(right)  then
        return left = right;

    # polynomial = rat-fun
    elif 2 = Length(left) and 3 = Length(right)  then
        p1 := ZippedProduct(left[2], right[3], left[1], fam!.zippedProduct);
        return p1 = right[2];

    # rat-fun = polynomial
    elif 3 = Length(left) and 2 = Length(right)  then
        p1 := ZippedProduct(left[3], right[2], left[1], fam!.zippedProduct);
        return left[2] = p1;

    # rat-fun = rat-fun
    elif 3 = Length(left) and 3 = Length(right)  then
        p1 := ZippedProduct(left[2], right[3], left[1], fam!.zippedProduct);
        p2 := ZippedProduct(left[3], right[2], left[1], fam!.zippedProduct);
        return p1 = p2;
    fi;

end;

InstallMethod( \=,
    IsIdentical,
    [ IsRationalFunction,
      IsRationalFunction ],
    0,
    RationalFunction_Equal );


#############################################################################
##
#M  <coeff>       * <rat-fun>
##
##  This method is  installed for all rational functions  because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or  a 'UnivariatePolynomialsFamily'.  The  product is defined in
##  all three cases.
##
InstallMethod( \*,
    "coeff * rat-fun",
    IsCoeffsElms,
    [ IsRingElement,
      IsRationalFunction ],
    0,


function( left, right )
    local   fam,  i;

    fam   := FamilyObj(right);
    right := ShallowCopy(ExtRepOfObj(right));
    right[2] := ShallowCopy(right[2]);

    for i  in [ 2, 4 .. Length(right[2]) ]  do
        right[2][i] := left * right[2][i];
    od;

    return ObjByExtRep( fam, right );

end );


#############################################################################
##
#M  <coeff>       + <rat-fun>
##
##  This method  is installed for all rational  functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily', a  'LaurentPolynomials-
##  Family',  or a 'UnivariatePolynomialsFamily'.  The sum  is defined in all
##  three cases.
##
InstallMethod( \+,
    "coeff + rat-fun",
    IsCoeffsElms,
    [ IsRingElement,
      IsRationalFunction ],
    0,


function( left, right )
    local   fam,  i;

    fam   := FamilyObj(right);
    right := ShallowCopy(ExtRepOfObj(right));
    left  := [ [], left ];

    # coeff + polynomial
    if 2 = Length(right)  then
        right[2] := ZippedSum(left, right[2], right[1], fam!.zippedSum);
        return ObjByExtRep( fam, right );

    # coeff + rat-fun
    elif 3 = Length(right)  then
        left := ZippedProduct(left, right[3], right[1], fam!.zippedProduct);
        right[2] := ZippedSum(left, right[2], right[1], fam!.zippedSum);
        return ObjByExtRep( fam, right );
    fi;

end );


#############################################################################
##
#M  <rat-fun>     * <coeff>
##
##  This method is installed for all  rational functions because it  does not
##  matter if one  is in a  'RationalFunctionsFamily', a 'LaurentPolynomials-
##  Family',  or a 'UnivariatePolynomialsFamily'.   The product is defined in
##  all three cases.
##
InstallMethod( \*,
    "rat-fun * coeff",
    IsElmsCoeffs,
    [ IsRationalFunction,
      IsRingElement ],
    0,


function( left, right )
    local   fam,  i;

    fam   := FamilyObj(left);
    left := ShallowCopy(ExtRepOfObj(left));
    left[2] := ShallowCopy(left[2]);

    for i  in [ 2, 4 .. Length(left[2]) ]  do
        left[2][i] := left[2][i] * right;
    od;

    return ObjByExtRep( fam, left );

end );


#############################################################################
##
#M  <rat-fun>     + <coeff>
##
##  This method is installed  for all rational  functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily', a  'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.  The  sum is defined in  all
##  three cases.
##
InstallMethod( \+,
    "rat-fun + coeff",
    IsElmsCoeffs,
    [ IsRationalFunction,
      IsRingElement ],
    0,


function( left, right )
    local   fam,  i;

    fam   := FamilyObj(left);
    left  := ShallowCopy(ExtRepOfObj(left));
    right := [ [], right ];

    # polynomial + coeff
    if 2 = Length(left)  then
        left[2] := ZippedSum(left[2], right, left[1], fam!.zippedSum);
        return ObjByExtRep( fam, left );

    # rat-fun + coeff
    elif 3 = Length(left)  then
        right := ZippedProduct(left[3], right, left[1], fam!.zippedProduct);
        left[2] := ZippedSum(left[2], right, left[1], fam!.zippedSum);
        return ObjByExtRep( fam, left );
    fi;

end );


#############################################################################
##

#F  DegreeIndeterminate( pol, ind )  degree in indeterminate number ind
##      fctn. will err if we take polynomial rings over polynomial rings
##
DegreeIndeterminate := function(pol,ind)
local e,d,i,j;
  # ground ring elements
  if not (IsRationalFunction(pol) and HasIsPolynomial(pol)) then
    return 0;
  fi;
  e:=ExtRepOfObj(pol);
  if Length(e)<>2 then
    Error("<pol> must be a polynomial");
  fi;
  e:=e[2];
  e:=Filtered(e,IsList);
  d:=0;
  for i in e do
    j:=1;
    while j<Length(i) do
      if i[j]=ind then
	if i[j+1]>d then
	  d:=i[j+1];
	fi;
        j:=Length(i);
      fi;
      j:=j+2;
    od;
  od;
  return d;
end;

#############################################################################
##
#F  LeadingCoefficient( pol, ind )  of (multivariate) pol considered as
##         univariate pol in indeterminate # ind with polynomial coeffs.
##
InstallOtherMethod(LeadingCoefficient,"multivar",true,[IsPolynomial,IsInt],0,
function(pol,ind)
local a,c,e,d,fam,i,p;
  fam:=FamilyObj(pol);
  e:=ExtRepOfObj(pol);
  a:=e[1];
  c:=Zero(a);
  e:=e[2];
  d:=DegreeIndeterminate(pol,ind);
  i:=1;
  while i<Length(e) do
    # test whether the indeterminate does occur
    p:=PositionProperty([1,3..Length(e[i])-1],
                        j->e[i][j]=ind and e[i][j+1]=d);
    if p<>fail then
      p:=p*2-1;
      p:=e[i]{Difference([1..Length(e[i])],[p,p+1])};
      if Length(p)=0 then
        c:=c+e[i+1];
      else
	c:=c+ObjByExtRep(fam,[a,[p,e[i+1]]]);
      fi;
    fi;
    i:=i+2;
  od;
  return c;
end);

UnivariatifiedPol := function(pol)
local a,e,ind,mon,cof;
  e:=ExtRepOfObj(pol);
  if Length(e)>2 then
    return UnivariatifiedPol(ObjByExtRep(FamilyObj(pol),e{[1,2]}))/
           UnivariatifiedPol(ObjByExtRep(FamilyObj(pol),e{[1,3]}));
  elif Length(e[2])=0 then 
    return Zero(CoefficientsFamily(FamilyObj(pol)));
  else
    a:=Zero(e[1]);
    e:=e[2];
    # special treatment for constant term
    mon:=Position(e,[]);
    if mon<>fail then
      a:=a+e[mon+1];
      e:=e{Difference([1..Length(e)],[mon,mon+1])};
      if Length(e)=0 then
        return a;
      fi;
    fi;
    mon:=e{[1,3..Length(e)-1]};
    e:=e{[2,4..Length(e)]};
    if ForAll(mon,i->Length(i)=2) 
      # variable always the same
      and Length(Set(mon{[1..Length(mon)]}[1]))<=1 then
      # univariate case
      ind:=mon[1][1];
      mon:=mon{[1..Length(mon)]}[2]+1;
      cof:=List([1..Maximum(mon)],i->Zero(a));
      cof{mon}:=e;
      cof[1]:=a;
      return UnivariatePolynomialByCoefficients(
               CoefficientsFamily(FamilyObj(pol)),cof,ind);
    else
      return pol;
    fi;
  fi;
end;

#############################################################################
##
#F  PseudoDivision(a, b, ind )
##
PseudoDivision:=function(a,b,ind)
local m,n,d,r,q,e,s,x,ca;
  m:=DegreeIndeterminate(a,ind);
  n:=DegreeIndeterminate(b,ind);
  d:=LeadingCoefficient(b,ind);
  ca:=CoefficientsFamily(FamilyObj(a));
  x:=UnivariateLaurentPolynomialByCoefficients(ca,[One(ca)],1,ind);
  r:=a;
  q:=Zero(a);
  e:=m-n+1;
  repeat
    if DegreeIndeterminate(r,ind)<DegreeIndeterminate(b,ind) then
      b:=d^e;
      q:=b*q;
      r:=b*r;
      q:=UnivariatifiedPol(q);
      r:=UnivariatifiedPol(r);
      return [q,r];
    fi;
    s:=LeadingCoefficient(r,ind)
         *x^(DegreeIndeterminate(r,ind)-DegreeIndeterminate(b,ind));
    q:=d*q+s;
    r:=d*r-s*b;
    e:=e-1;
  until false;
end;

#############################################################################
##
#F  Resultant( <f>, <g>, ind )
##
Resultant := function(f,g,ind)
local tw,res,m,n,valf,valg,con,mn,pr,x,y;

  res:=One(f);

  # fix some special cases: for baseRing elements,  Degree
  #  may not work
  if IsPolynomial(f) then
    m:=DegreeIndeterminate(f,ind);
  else
    m:=0;
  fi;
  if IsPolynomial(g) then
    n:=DegreeIndeterminate(g,ind);
  else
    n:=0;
  fi;

  if n>m then
    # force f to be of larger degee
    res:=(-1)^(n*m);
    tw:=f; f:=g; g:=tw;
    tw:=m; m:=n; n:=tw;
  fi;

  # trivial cases
  if m=0 then
    return UnivariatifiedPol(res*1);
  elif n=0 then
    return UnivariatifiedPol(res*g^m);
  fi;

  # and now we may start really, subresultant algorithm: S_j+1=g, S_j+2=f

  x:=1;
  y:=1;
  while 0<n do
    mn:=m-n;
    res:=res*((-1)^m)^n;
    pr:=PseudoDivision(f,g,ind)[2];
    m:=n;
    n:=DegreeIndeterminate(pr,ind);
    f:=g;
    g:=pr/x/y^mn;
    x:=LeadingCoefficient(f,ind);
    y:=x^mn/y^(mn-1);
  od;

  res:=res*g;
  if m>1 then
    res:=res*(g/y)^(m-1);
  fi;

  return UnivariatifiedPol(res);
end;

#############################################################################
##
#F  MonomialOrderPlex(mon1,mon2)
##
##  functions for strictly smaller test of monomials
##  Plex order: Position/Lexicographic
MonomialOrderPlex := function(m,n)
local x,y;
  # assume m and n are lexicographically sorted (otherwise we have to do
  # further work)
  x:=Length(m)-1;
  y:=Length(n)-1;
  while x>0 and y>0 do
    if m[x]>n[y] then
      return false;
    elif m[x]<n[y] then
      return true;
    # now m[x]=n[y]
    elif m[x+1]>n[y+1] then
      return false;
    elif m[x+1]<n[y+1] then
      return true;
    fi;
    # thus same coeffs, step down
    x:=x-2;
    y:=y-2;
  od;
  if x=0 and y>0 then
    return true;
  else
    return false;
  fi;
end;

#############################################################################
##
#F  LeadingMonomialPosExtRep    position of leading monomial in external rep.
##                              list
##
LeadingMonomialPosExtRep := function(e,order)
local bp,p;
  bp:=1;
  p:=3;
  while p<Length(e) do
    if order(e[bp],e[p]) then
      bp:=p;
    fi;
    p:=p+2;
  od;
  return bp;
end;

#############################################################################
##
#F  PolynomialReduction(poly,plist,order)     reduces poly with the ideal
##                                 generated by plist, according to order
##  The routine returns a list [remainder,[quotients]]
##
PolynomialReduction := function(poly,plist,order)
local fam,zer,quot,elist,lmp,lmo,lmc,x,y,z,mon,monsel,mon2,qmon,noreduce,
      ep,pos,q2;
  fam:=FamilyObj(poly);
  zer:=ExtRepOfObj(poly)[1];
  quot:=List(plist,i->Zero(poly));
  elist:=List(plist,ExtRepOfObj);
  # test
  elist:=List(elist,i->i[2]);
  lmp:=List(elist,i->LeadingMonomialPosExtRep(i,order));
  lmo:=List([1..Length(lmp)],i->elist[i][lmp[i]]);
  lmc:=List([1..Length(lmp)],i->elist[i][lmp[i]+1]);

  repeat
    # now try whether we can reduce anywhere
    ep:=ExtRepOfObj(poly)[2];
    x:=1;
    noreduce:=true;
    while x<Length(ep) and noreduce do
      mon:=ep[x];
      monsel:=[1..Length(mon)/2];
      y:=1;
      while y<=Length(plist) and noreduce do
	mon2:=lmo[y];
	#check whether the monomial at position x is a multiple of the
	#y-th leading monomial
        z:=1;
	qmon:=[]; # potential quotient
	noreduce:=false;
	while noreduce=false and z<=Length(mon2) do
	  pos:=PositionProperty(monsel,k->mon[2*k-1]=mon2[z]);
	  if pos=fail then
	    # certainly not reducible as monomial does not occur
	    noreduce:=true;
	  else
	    #still reducible if exponent not smaller
	    noreduce:=mon[2*pos]<mon2[z+1];
	    if noreduce=false then
	      qmon:=Concatenation(qmon,[mon2[z],mon[2*pos]-mon2[z+1]]);
	    fi;
	  fi;
	  z:=z+2;
	od;
        y:=y+1;
      od;
      x:=x+2;
    od;
    if noreduce=false then
      x:=x-2;y:=y-1; # re-correct incremented numbers

      # add the variables that do not occur in the divisor monomial!
      monsel:=[1..Length(mon2)/2];
      q2:=[];
      z:=1;
      while z<=Length(mon) do
	pos:=PositionProperty(monsel,k->mon2[2*k-1]=mon[z]);
	if pos=fail then
	  q2:=Concatenation(q2,mon{[z,z+1]});
	fi;
        z:=z+2;
      od;
      # reduce!
      # AH: evtl. noch 'Quotient' aufrufen!
      qmon:=ObjByExtRep(fam,[zer,[qmon,ep[x+1]/lmc[y]]])
           *ObjByExtRep(fam,[zer,[q2,One(zer)]]); #quotient monomial
      quot[y]:=quot[y]+qmon;
      poly:=poly-qmon*plist[y]; # reduce
    fi;
  until noreduce;
  return [poly,List(quot,UnivariatifiedPol)];
end;

# try whether one polynomial really divides the other
InstallMethod( \/,
    "poly / poly => ? poly ?",
    IsIdentical,
    [ IsPolynomial,
      IsPolynomial ],
    1,
function(a,b)
local q;
  # try whether we become monomial
  a:=UnivariatifiedPol(a);
  b:=UnivariatifiedPol(b);
  if not IsRationalFunction(b) then
    b:=a*1/b;
    return b;
  fi;
  if IsUnivariatePolynomial(a) and IsUnivariatePolynomial(b) then
    if IndeterminateNumberOfUnivariateLaurentPolynomial(a)
       =IndeterminateNumberOfUnivariateLaurentPolynomial(b) then
      return a/b;
    else
      TryNextMethod();
    fi;
  fi;

  q:=PolynomialReduction(a,[b],MonomialOrderPlex);
  if q[1]<>Zero(q[1]) then
    TryNextMethod();
  fi;
  return q[2][1];
end);

#############################################################################
##
#E  ratfun.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

