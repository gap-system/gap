#############################################################################
##
#W  ratfun.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
        ##  are the two monomials equal ?
        if z1[i1] = z2[i2]  then
            ##  compute the sum of the coefficients
            i := f[2]( z1[i1+1], z2[i2+1] );
            if i <> zero  then
                ##  Add the term to the sum if the coefficient is not zero
                Add( sum, z1[i1] );
                Add( sum, i );
            fi;
            i1 := i1+2;
            i2 := i2+2;
        elif f[1]( z1[i1], z2[i2] )  then  ##  z1[i1] < z2[i2] ?
            ##  z1[i1] is the smaller of the two monomials and gets added to
            ##  the sum.  We have to apply the sum function to the
            ##  coefficient and zero.
            if z1[i1+1] <> zero  then
                Add( sum, z1[i1] );
                Add( sum, f[2]( z1[i1+1], zero ) );
            fi;
            i1 := i1+2;
        else
            ##  z1[i1] is the smaller of the two monomials
            if z2[i2+1] <> zero  then
                Add( sum, z2[i2] );
                Add( sum, f[2]( zero, z2[i2+1] ) );
            fi;
            i2 := i2+2;
        fi;
    od;
    ##  Now append the rest of the longer polynomial to the sum.  Note that
    ##  only one of the following loops is executed.
    for i  in [ i1, i1+2 .. Length(z1)-1 ]  do
        if z1[i+1] <> zero  then
            Add( sum, z1[i] );
            Add( sum, f[2]( z1[i+1], zero ) );
        fi;
    od;
    for i  in [ i2, i2+2 .. Length(z2)-1 ]  do
        if z2[i+1] <> zero  then
            Add( sum, z2[i] );
            Add( sum, f[2]( zero, z2[i+1] ) );
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
            ## product of the coefficients.
            c := f[4]( z1[i+1], z2[j+1] );
            if c <> zero  then
                ##  add the product of the monomials
                Add( mons, f[1]( z1[i], z2[j] ) );
                ##  and the coefficient
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
            c := f[3]( c, cofs[i] );    ##  add coefficients
        od;
        if c <> zero  then
            ## add the term to the product
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
#F  ZippedListProduct . . . . . . . . . . . . . . . .  multiply two monomials
##
ZippedListProduct := function( l, r )
    return ZippedSum( l, r, 0, [ \<, \+ ] );
end;

#############################################################################
##
#F  ZippedListQuotient  . . . . . . . . . . . .  divide a monomial by another
##
ZippedListQuotient := function( l, r )

    return ZippedSum( l, r, 0, [ \<, \- ] );
end;

#############################################################################
##

#R  IsRationalFunctionDefaultRep
##
DeclareRepresentation(
    "IsRationalFunctionDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##
#R  IsPolynomialDefaultRep
##
DeclareRepresentation(
    "IsPolynomialDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##
#R  IsUnivariateLaurentPolynomialDefaultRep
##
DeclareRepresentation(
    "IsUnivariateLaurentPolynomialDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );

#############################################################################
##
#M  RationalFunctionsFamily( <fam> )
##
InstallMethod( RationalFunctionsFamily,
    true,
    [ IsUFDFamily ],
    1,

function( efam )
    local   fam;

    # create a new family in the category <IsRationalFunctionsFamily>
    fam := NewFamily(
      "RationalFunctionsFamily(...)",
      IsRationalFunction and IsRationalFunctionsFamilyElement,
      IsObject,
      IsUFDFamily and IsRationalFunctionsFamily );

    # default type for rational functions
    fam!.rationalType := NewType( fam,
        IsRationalFunctionDefaultRep );

    # default type for polynomials
    fam!.polynomialType := NewType( fam,
        IsPolynomial and IsPolynomialDefaultRep );

    # default type for univariate laurent polynomials
    fam!.univariateLaurentPolynomialType := NewType( fam,
        IsUnivariateLaurentPolynomial
        and IsUnivariateLaurentPolynomialDefaultRep );

    # functions to add zipped lists
    fam!.zippedSum := [ MonomialTotalDegree_Less, \+ ];

    # functions to multiply zipped lists
    fam!.zippedProduct := [ ZippedListProduct, 
                            MonomialTotalDegree_Less, \+, \* ];

    # set the one and zero coefficient
    fam!.zeroCoefficient := Zero(efam);
    fam!.oneCoefficient  := One(efam);

    # set the coefficients
    SetCoefficientsFamily( fam, efam );

    # Set the characteristic.
    if HasCharacteristic( efam ) then
      SetCharacteristic( fam, Characteristic( efam ) );
    fi;

    # and set one and zero
    SetZero( fam, ObjByExtRep( fam, [ Zero(efam), [] ] ) );
    SetOne( fam, ObjByExtRep( fam, [ Zero(efam), [ [], One(efam) ] ] ) );

    # assign a names list
    fam!.namesIndets := [];

    # and return
    return fam;

end );

# this method is only to get a resonable error message in case the ring does
# not know to be a UFD.
InstallOtherMethod( RationalFunctionsFamily,
    true,
    [ IsObject ],
    0,
function(obj)
  Error("You can only create rational functions over a UFD");
end);

#############################################################################
##
#M  IndeterminateName(<fam>,<nr>)
#M  HasIndeterminateName(<fam>,<nr>)
#M  SetIndeterminateName(<fam>,<nr>,<name>)
##
InstallMethod(IndeterminateName,"for rational function families",true,
  [IsRationalFunctionsFamily,IsPosInt],0,
function(fam,nr)
  if IsBound(fam!.namesIndets[nr]) then
    return fam!.namesIndets[nr];
  else
    return fail;
  fi;
end);

InstallMethod(HasIndeterminateName,"for rational function families",true,
  [IsRationalFunctionsFamily,IsPosInt],0,
function(fam,nr)
  return IsBound(fam!.namesIndets[nr]);
end);

InstallMethod(SetIndeterminateName,"for rational function families",true,
  [IsRationalFunctionsFamily,IsPosInt,IsString],0,
function(fam,nr,str)
  if IsBound(fam!.namesIndets[nr]) and fam!.namesIndets[nr]<>str then
    Error("indeterminate number ",nr,
          " has been baptized already differently");
  else
    fam!.namesIndets[nr]:=Immutable(str);
  fi;
end);

InstallMethod(SetName,"set name of indeterminate",
  true,[IsUnivariateLaurentPolynomial,IsString],
  SUM_FLAGS+1, # we want to be better than the setter
function(indet,name)
local c;
  c:=CoefficientsOfUnivariateLaurentPolynomial(indet);
  if not Length(c[1])=1 and One(c[1][1])=c[1][1] and c[2]=1 then
    TryNextMethod();
  fi;
  SetIndeterminateName(FamilyObj(indet),
      IndeterminateNumberOfUnivariateLaurentPolynomial(indet),name);
end);

#############################################################################
##
#F  UnivariateLaurentPolynomial_PrintObj( <obj> )
##
UnivariateLaurentPolynomial_PrintObj := function( f )
local   fam,  ind,  zero,  one,  mone,  i,  c,name;

    fam := FamilyObj(f);
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    if HasIndeterminateName(fam,ind) then
      name:=IndeterminateName(fam,ind);
    else
      name:=Concatenation("x_",String(ind));
    fi;
    f   := CoefficientsOfUnivariateLaurentPolynomial(f);
    zero := fam!.zeroCoefficient;
    one  := One(zero);
    mone := -one;
    if Length(f[1])=0 then
      Print(0);
    fi;
    for i  in [ 1 .. Length(f[1] ) ]  do
        if f[1][i] <> zero  then

            # print a '+' if necessary
            c := "*";
            if i > 1  then
                if IsRat(f[1][i])  then
                    if f[1][i] = one  then
                        Print( "+" );
                        c := "";
                    elif f[1][i] > 0  then
                        Print( "+", f[1][i] );
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
                c := "";
            elif f[1][i] = mone  then
                Print("-");
                c := "";
            else
                Print(f[1][i]);
            fi;
            if i+f[2] <> 1  then
                Print( c, name );
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
#F  ExtRepOfPolynomial_PrintObj( <obj>, <names> )
##
ExtRepOfPolynomial_PrintObj := function(fam, ext )
local   zero,  one,  mone,  i,  d,  c,  j,ind;

    zero := ext[1];
    one  := One(zero);
    mone := -one;
    ext  := ext[2];
    if Length(ext)=0 then
      Print(zero);
    fi;
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
		ind:=ext[i][j];
		if HasIndeterminateName(fam,ind) then
                    Print(IndeterminateName(fam,ind));
                else
                    Print("x_",ind); 
		fi;
                if 1 <> ext[i][j+1]  then
		  Print("^", ext[i][j+1] );
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
    local   dom,  ext,  fam, i;

    dom := CoefficientsFamily(FamilyObj(obj));
    ext := ExtRepOfObj(obj);
    fam := FamilyObj(obj);
    if 2 = Length(ext)  then
        ExtRepOfPolynomial_PrintObj(fam, ext );
    else
        Print( "(" );
        ExtRepOfPolynomial_PrintObj(fam, ext{[1,2]});
        Print( ")" );
        Print( "/" );
        Print( "(" );
        ExtRepOfPolynomial_PrintObj(fam, ext{[1,3]});
        Print( ")" );
    fi;
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
    UnivariateLaurentPolynomial_PrintObj( f );
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
        Objectify( fam!.polynomialType, rf );
    elif 3 = Length(zipped)  then
        if 0 = Length(zipped[3])  then
            Error( "denominator must be non-trivial" );
        fi;
        rf.zeroCoefficient := Immutable(zipped[1]);
        rf.numerator       := Immutable(zipped[2]);
        rf.denominator     := Immutable(zipped[3]);
        Objectify( fam!.rationalType, rf );
    else
        Error( "<zipped> must have length 2 or 3" );
    fi;
    return rf;
end );


#############################################################################
##
#M  DenominatorOfRationalFunction( <poly> )
##
InstallMethod( DenominatorOfRationalFunction,"for polynomials",true,
    [ IsRationalFunction and IsPolynomial ], 0,
function( poly )
    return One(poly);
end );

InstallMethod( DenominatorOfRationalFunction,"general",true,
    [ IsRationalFunction ],0,
function( f )
  return ObjByExtRep(FamilyObj(f),ExtRepOfObj(f){[1,3]});
end );


#############################################################################
##
#M  NumeratorOfRationalFunction( <poly> )
##
InstallMethod( NumeratorOfRationalFunction,true,
    [ IsRationalFunction and IsPolynomial ],0,
function( poly )
    return poly;
end );


InstallMethod( NumeratorOfRationalFunction,"general",true,
    [ IsRationalFunction ],0,
function( f )
  return ObjByExtRep(FamilyObj(f),ExtRepOfObj(f){[1,2]});
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
#F  IsUnivariateRationalFunctionByNumerAndDenom( <num>, <den> )
##
##  <num> and <den> are the second entries in the 'ExtRepOfObj' value of
##  polynomials, i.e., the zero coefficient is not involved.
##
IsUnivariateRationalFunctionByNumerAndDenom := function( num, den )
    local   ind,  i;

    # now check the monomials
    ind := false;
    for i  in [ 1, 3 .. Length(den)-1 ]  do
        if 2 < Length(den[i])  then
            return false;
        elif 2 = Length(den[i])  then
            if ind = false  then
                ind := den[i][1];
            elif ind <> den[i][1]  then
                return false;
            fi;
        fi;
    od;
    for i  in [ 1, 3 .. Length(num)-1 ]  do
        if 2 < Length(num[i])  then
            return false;
        elif 2 = Length(num[i])  then
            if ind = false  then
                ind := num[i][1];
            elif ind <> num[i][1]  then
                return false;
            fi;
        fi;
    od;
    return true;
end;


#############################################################################
##
#M  IsUnivariateRationalFunction( <rat-fun> ) . . . . for a rational function
##
##  Note that we cannot use 'ExtRepOfObj' because we need a reduced num/den.
##
InstallMethod( IsUnivariateRationalFunction,
    "method for a rational function",
    true,
    [ IsRationalFunction ],
    0,
    ratfun -> IsUnivariateRationalFunctionByNumerAndDenom( 
        ExtRepOfObj( NumeratorOfRationalFunction( ratfun ) )[2],
        ExtRepOfObj( DenominatorOfRationalFunction( ratfun ) )[2] ) );


#############################################################################
##
#M  IsUnivariateRationalFunction( <rat-fun> ) . . . . . . for default repres.
##
InstallMethod( IsUnivariateRationalFunction,
    "method for a rational function in default repres.",
    true,
    [ IsRationalFunction and IsRationalFunctionDefaultRep ],
    0,
    function( ratfun )
    if IsUnivariateRationalFunctionByNumerAndDenom( 
                  ratfun!.numerator,
                  ratfun!.denominator ) then
      return true;
    else
      TryNextMethod();
    fi;
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
#M  RatfunQuoByExtReps(<fam>,<zero>,<num><den>)
##
##  constrcuts the rational function with the external representation
##  [<zero>,<num>,<den>] in the family <fam> but treats the cases of
##  denominator of degree 0 and numerator 0 specially.
RatfunQuoByExtReps:=function(fam,z,num,den)
local q;
  # special treatment of 0
  if Length(num)=0 then
    return Zero(fam);
  fi;
  q:=TryGcdCancelExtRepPol(fam,num,den,z);
  if q<>fail then
    num:=q[1];
    den:=q[2];
  fi;

  if Length(den)=2 and Length(den[1])=0 then
    # special treatment of numerator 1
    return ObjByExtRep( fam, [ z, num ] )/den[2];
  else
    return ObjByExtRep( fam, [ z, num, den ] );
  fi;
end;


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
    local   fam,  num,  den,gcd;

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
	den:=right[3];
    # rat-fun * polynomial
    elif 3 = Length(left) and 2 = Length(right)  then
        num := ZippedProduct(left[2], right[2], left[1], fam!.zippedProduct);
	den:=left[3];
    # rat-fun * rat-fun
    elif 3 = Length(left) and 3 = Length(right)  then
        num := ZippedProduct(left[2], right[2], left[1], fam!.zippedProduct);
        den := ZippedProduct(left[3], right[3], left[1], fam!.zippedProduct);
    fi;

    return RatfunQuoByExtReps(fam,left[1],num,den);

end;

#############################################################################
##
#M  TryGcdCancelExtRepPol(<fam>,<a>,<b>,<zero>);
##
##  The default method just fails to avoid `No Method found' errors.
InstallMethod(TryGcdCancelExtRepPol,"catch `no method found'",true,
  [IsRationalFunctionsFamily,IsList,IsList,IsScalar],
  # This is a catch method and therefore should have real value 0  
  - SIZE_FLAGS(FLAGS_FILTER(IsRationalFunction))
  - 2*SIZE_FLAGS(FLAGS_FILTER(IsList)),
function(fam,a,b,z)
  Error();
  return fail;
end);

InstallMethod( \*,
    "rat-fun * rat-fun",
    IsIdenticalObj,
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
    IsIdenticalObj,
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
    local   fam,  num,  den,q,dl,dr;

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
	den:=right[3];

    # rat-fun + polynomial
    elif 3 = Length(left) and 2 = Length(right)  then
        num := ZippedProduct(left[3], right[2], left[1], fam!.zippedProduct);
        num := ZippedSum(left[2], num, left[1], fam!.zippedSum);
        den:=left[3];

    # rat-fun + rat-fun
    elif 3 = Length(left) and 3 = Length(right)  then
        if left[3]=right[3] then
	  # same denominator, just add numerators
	  num := ZippedSum(left[2], right[2], left[1], fam!.zippedSum);
	  den:=left[3];
	else
	  # try to find a small denominator if possible:

	  den:=fail;
	  if Length(left[3])<Length(left[3]) then
	    # take both denominators
	    dl:=ObjByExtRep(fam,[left[1],left[3]]);
	    dr:=ObjByExtRep(fam,[right[1],right[3]]);
	    q:=Quotient(dr,dl);
	    if q<>fail then
	      den:=right[3];
	      q:=ExtRepOfObj(q)[2];
	      num:=ZippedSum(
	        ZippedProduct(left[2],q,left[1],fam!.zippedProduct),
		right[2],
		left[1],fam!.zippedSum);
	    fi;
	  elif Length(left[3])>Length(left[3]) then
	    # take both denominators
	    dl:=ObjByExtRep(fam,[left[1],left[3]]);
	    dr:=ObjByExtRep(fam,[right[1],right[3]]);
	    q:=Quotient(dl,dr);
	    if q<>fail then
	      den:=left[3];
	      q:=ExtRepOfObj(q)[2];
	      num:=ZippedSum(
		left[2],
	        ZippedProduct(right[2],q,left[1],fam!.zippedProduct),
		left[1],fam!.zippedSum);
	    fi;
	  fi;
	  if den=fail then
	    # try to cast out the gcd to find the lcm
	    q:=TryGcdCancelExtRepPol(fam,left[3],right[3],left[1]);
	    if q<>fail then
	      num:=ZippedSum(
		  ZippedProduct(left[2],q[2],left[1],fam!.zippedProduct),
		  ZippedProduct(q[1],right[2],left[1],fam!.zippedProduct),
		  left[1],fam!.zippedSum);
	      den:=ZippedProduct(left[3],q[2],left[1],fam!.zippedProduct);
	      
	    else
	      # alas, there is no improvement possible
	      num:=ZippedSum(
		  ZippedProduct(left[2],right[3],left[1],fam!.zippedProduct),
		  ZippedProduct(left[3],right[2],left[1],fam!.zippedProduct),
		  left[1],fam!.zippedSum);
	      den:=ZippedProduct(left[3],right[3],left[1],fam!.zippedProduct);
	    fi;
	  fi;
	fi;
    fi;

    return RatfunQuoByExtReps(fam,left[1],num,den);

end;

InstallMethod( \+,
    "rat-fun + rat-fun",
    IsIdenticalObj,
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
    IsIdenticalObj,
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

    # special treatment of zero
    if left=Zero(left) then
      return Zero(right);
    fi;

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

    if right=Zero(right) then
      return Zero(left);
    fi;

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
#M  <rat-fun>     + <coeff>
##
InstallMethod(\+,"fallback ratfun + ringel",true,
  [IsRationalFunction,IsRingElement],
  # as a fallback function we don't want to be just at the end
  -SIZE_FLAGS(FLAGS_FILTER(IsRationalFunction))
  -SIZE_FLAGS(FLAGS_FILTER(IsRingElement)),
function(f,c)
  return f+(c*f^0);
end);

InstallMethod(\+,"fallback ringel + ratfun",true,
  [IsRingElement,IsRationalFunction],
  # as a fallback function we don't want to be just at the end
  -SIZE_FLAGS(FLAGS_FILTER(IsRationalFunction))
  -SIZE_FLAGS(FLAGS_FILTER(IsRingElement)),
function(c,f)
  return f+(c*f^0);
end);

#############################################################################
##
#M  <ratfun> < <ratfun>
##
InstallMethod(\<,"rational functions",IsIdenticalObj,
  [IsRationalFunction,IsRationalFunction],0,
function(a,b)
  # avoid recursion by testing for polynomiality
  IsPolynomial(a);IsPolynomial(b);
  return NumeratorOfRationalFunction(a)*DenominatorOfRationalFunction(b)<
         NumeratorOfRationalFunction(b)*DenominatorOfRationalFunction(a);
end);

InstallMethod(\<,"polynomials",IsIdenticalObj,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial],0,
function(a,b)
  a:=ExtRepOfObj(a)[2];
  i:=Length(a)-1;
  b:=ExtRepOfObj(b)[2];
  j:=Length(b)-1;
  while i>0 and j>0 do
    # compare the last monomials
    if a[i]=b[j] then
      # the monomials are the same, compare the coefficients
      if a[i+1]=b[j+1] then
        # the coefficients are also the same. Must continue
	i:=i-1;
	j:=j-2;
      else
	# let the coefficients decide
        return a[i+1]<b[j+1];
      fi;
    elif MonomialTotalDegree_Less(a[i],b[j]) then
      # a is strictly smaller
      return true;
    else
      # a is strictly larger
      return false;
    fi;
  od;
  # is the an a-remainder (then a is larger)
  # or are both polynomials equal?
  if i>0 or i=j then
    return false;
  else
    return true;
  fi;
end);

#############################################################################
##
#F  DegreeIndeterminate( pol, ind )  degree in indeterminate number ind
##   #W!  fctn. will err if we take polynomial rings over polynomial rings
##
InstallMethod(DegreeIndeterminate,"pol,indetnr",true,
  [IsRationalFunction and IsPolynomial,IsPosInt],0,
function(pol,ind)
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
end);

InstallOtherMethod(DegreeIndeterminate,"pol,indet",IsIdenticalObj,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial],0,
function(pol,ind)
  return DegreeIndeterminate(pol,
           IndeterminateNumberOfUnivariateLaurentPolynomial(ind));
end);

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

#############################################################################
##
#F  UnivariatifiedPol . . . .  attempt to produce a univariate representation
##
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
#M  Resultant( <f>, <g>, ind )
##
InstallMethod(Resultant,"pol,pol,inum",IsFamFamX,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial,
  IsPosInt],0,
function(f,g,ind)
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
    res:=(-One(f))^(n*m);
    tw:=f; f:=g; g:=tw;
    tw:=m; m:=n; n:=tw;
  fi;

  # trivial cases
  if m=0 then
    return UnivariatifiedPol(res*f^n);
  elif n=0 then
    return UnivariatifiedPol(res*g^m);
  fi;

  # and now we may start really, subresultant algorithm: S_j+1=g, S_j+2=f

  x:=1;
  y:=1;
  while 0<n do
    mn:=m-n;
    res:=res*((-One(f))^m)^n;
    pr:=PseudoDivision(f,g,ind)[2];
    m:=n;
    n:=DegreeIndeterminate(pr,ind);
    f:=g;
    g:=pr/x/y^mn;
#    g:=pr/(x*y^mn);
    x:=LeadingCoefficient(f,ind);
    y:=x^mn/y^(mn-1);
  od;

  res:=res*g;
  if m>1 then
    res:=res*(g/y)^(m-1);
  fi;

  return UnivariatifiedPol(res);
end);

InstallOtherMethod(Resultant,"pol,pol,indet",IsFamFamFam,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial,
  IsRationalFunction and IsPolynomial],0,
function(a,b,ind)
  return Resultant(a,b,
           IndeterminateNumberOfUnivariateLaurentPolynomial(ind));
end);

#############################################################################
##
#M  PolynomialCoefficientsOfPolynomial(<pol>,<ind>)
##
InstallMethod(PolynomialCoefficientsOfPolynomial,"polynomial,integer",true,
  [IsRationalFunction and IsPolynomial,IsPosInt],0,
function(pol,ind)
local e,c,i,j,m,ex;
  e:=ExtRepOfObj(pol)[2];
  c:=[];
  for i in [1,3..Length(e)-1] do
    m:=e[i];
    j:=1;
    while j<=Length(m) and m[j]<>ind do
      j:=j+2;
    od;
    if j<Length(m) then
      ex:=m[j+1]+1;
      m:=m{Concatenation([1..j-1],[j+2..Length(m)])};
    else
      ex:=1;
    fi;
    if not IsBound(c[ex]) then
      c[ex]:=[];
    fi;
    Add(c[ex],m);
    Add(c[ex],e[i+1]);
  od;
  pol:=FamilyObj(pol);
  for i in [1..Length(c)] do
    if not IsBound(c[i]) then
      c[i]:=Zero(pol);
    else
      c[i]:=ObjByExtRep(pol,[Zero(CoefficientsFamily(pol)),c[i]]);
    fi;
  od;
  return c;
end);

InstallOtherMethod(PolynomialCoefficientsOfPolynomial,"polynomial,indet",
  IsIdenticalObj,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial],0,
function(pol,ind)
  return PolynomialCoefficientsOfPolynomial(pol,
           IndeterminateNumberOfUnivariateLaurentPolynomial(ind));
end);

#############################################################################
##
#M  Discriminant(<pol>,<ind>)
##
InstallOtherMethod(Discriminant,"poly,inum",true,
  [IsRationalFunction and IsPolynomial,IsPosInt],0,
function(f,ind)
local d;
  d:=DegreeIndeterminate(f,ind);
  return (-1)^(d*(d-1)/2)*Resultant(f,Derivative(f,ind),ind)/
                           LeadingCoefficient(f,ind);
end);

InstallOtherMethod(Discriminant,"poly,ind",true,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial],0,
function(pol,ind)
  return Discriminant(pol,IndeterminateNumberOfUnivariateLaurentPolynomial(ind));
end);

#############################################################################
##
#M  Derivative(<pol>,<ind>)
##
InstallOtherMethod(Derivative,"poly,inum",true,
  [IsRationalFunction and IsPolynomial,IsPosInt],0,
function(pol,ind)
local fam;
  fam:=CoefficientsFamily(FamilyObj(pol));
  return Derivative(pol,UnivariatePolynomialByCoefficients(fam,
		          [Zero(fam),One(fam)],ind));
end);

InstallOtherMethod(Derivative,"poly,ind",true,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial],0,
function(pol,ind)
local d,c,i;
  d:=Zero(pol);
  c:=PolynomialCoefficientsOfPolynomial(pol,ind);
  for i in [2..Length(c)] do
    d := d + (i-1) * c[i] * ind^(i-2);
  od;
  return d;
end);

#############################################################################
##
#F  MonomialTotalDegree_Less  . . . . . . total degree ordering for monomials
##
InstallGlobalFunction( MonomialTotalDegree_Less,
    function( u, v ) 
    local   lu, lv,      # length of u/v as a list
            len,         # difference in length of u/v as words
            i,           # loop variable  
            lexico;      # flag for the lexicoghraphic ordering of u and v

    lu := Length(u); lv := Length(v);

    ##  Discard a common prefix in u and v and decide if u is
    ##  lexicographically smaller than v.
    i := 1; while i <= lu and i <= lv and u[i] = v[i] do
        i := i+1;
    od;

    if i > lu then  ## u is a prefix of v.
        return lu < lv;
    fi;
    if i > lv then  ## v is a prefix of u, but not equal to u.
        return false;
    fi;

    ##  Decide if u is lexicographically smaller than v.
    if i mod 2 = 1 then         ##  the indeterminates in u and v differ
        lexico := u[i] < v[i]; i := i+1;
    else                        ##  the exponents in u and v differ
        lexico := u[i] > v[i];
    fi;

    ##  Now compute the difference of the lengths
    len := 0; while i <= lu and i <= lv do
        len := len + u[i];
        len := len - v[i];
        i := i+2;
    od;
    ##  Only one of the following while loops will be executed.
    while i <= lu do len := len + u[i]; i := i+2; od;
    while i <= lv do len := len - v[i]; i := i+2; od;

    if len = 0 then return lexico; fi;

    return len < 0;
end );

#############################################################################
##
#F  MonomialRevLexico_Less(mon1,mon2) . . . .  reverse lexicographic ordering
##
InstallGlobalFunction( MonomialRevLexico_Less, function(m,n)
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
  if x<=0 and y>0 then
    return true;
  else
    return false;
  fi;
end );

#############################################################################
##
#F  LeadingCoefficient  . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( LeadingCoefficient,
        "multivariate polynomials wrt total degree",
        true,
        [ IsPolynomial and IsPolynomialDefaultRep ],
        0,
    function( pol )
    return pol!.numerator[ Length(pol!.numerator) ];

end );

#############################################################################
##
#F  LeadingMonomial . . . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( LeadingMonomial,
        "multivariate polynomials wrt total degree",
        true,
        [ IsPolynomial and IsPolynomialDefaultRep ],
        0,
    function( pol )

    if Length( pol!.numerator ) = 0 then
        return [];
    fi;
    return pol!.numerator[ Length(pol!.numerator) - 1 ];

end );

#############################################################################
##
#F  LeadingMonomialPosExtRep    position of leading monomial in external rep.
##                              list
##
InstallGlobalFunction( LeadingMonomialPosExtRep, function(e,order)
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
end );

#############################################################################
##
#F  PolynomialReduction(poly,plist,order)     reduces poly with the ideal
##                                 generated by plist, according to order
##  The routine returns a list [remainder,[quotients]]
##
InstallGlobalFunction( PolynomialReduction, function(poly,plist,order)
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
end );

#############################################################################
##
#M  Quotient  . . . . . . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( Quotient,
        "multivariate polynomials",
        IsCollsElmsElms,
        [ IsPolynomialRing, IsPolynomial, IsPolynomial ],
        0,
    function( ring, p, q )
    return Quotient( p, q );
end );

InstallOtherMethod( Quotient,
        "multivariate polynomials without ring",
        IsIdenticalObj,
        [ IsPolynomial, IsPolynomial ],
        0,
    function( p, q )
    local   zero,  fam,  quot,  null,  lcq,  lmq,  mon,  i,  
            coeff;

    zero := 0*p;
    fam  := FamilyObj( p );

    quot := [];
    null := Zero( CoefficientsFamily(fam) );

    lcq := LeadingCoefficient( q );
    lmq := LeadingMonomial( q );
    
    while p <> zero do
        ##  divide the leading monomial of q by the leading monomial of p
        mon  := ZippedListQuotient( LeadingMonomial( p ), lmq );

        ##  check if mon has negative exponents
        for i in [2,4..Length(mon)] do
            if mon[i] < 0 then return fail; fi;
        od;
        
        ##  now add the quotient of the coefficients
        coeff := LeadingCoefficient(p) / lcq;

        ##  Add coeff, mon to quot, the result is sorted in reversed order.
        Add( quot,  coeff );
        Add( quot,  mon );

        ##  convert it into a polynomial
        mon  := ObjByExtRep( fam, [ null, [mon, coeff] ] );
        
        p := p - mon * q;
    od;

    quot := ObjByExtRep( fam, [ null, Reversed(quot) ] );
    return quot;
end );
        
#############################################################################
##
#M  \/  . . . . . . . . . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( \/,
    "poly / poly => ? poly ?",
    IsIdenticalObj,
    [ IsPolynomial,
      IsPolynomial ],
    1,  # The other method for dividing polynomials just returns a rational
        # function without checking divisibility first.  This function does
        # and should therefore be selected first.
function(a,b)
local q;
  # try whether we become monomial
  a:=UnivariatifiedPol(a);
  b:=UnivariatifiedPol(b);
  if not IsRationalFunction(b) then
#T check IsPolynomial ?
    b:= a * Inverse( b );
    return b;
  fi;
  if not IsRationalFunction(a) then
#T check IsPolynomial ?
    return a/b;
  fi;
  if IsUnivariatePolynomial(a) and IsUnivariatePolynomial(b) then
    # we have tried already whether they divide each other. So we will need
    # to construct the rational function here.
    TryNextMethod();
  fi;

  q := Quotient( a, b );
  if q = fail then TryNextMethod(); fi;
  return q;
end);

#############################################################################
##
#F  ValueMultivariate(poly,vals[,one]) 
##                               
InstallGlobalFunction( ValueMultivariate, function(arg)
local f,vals,one,i,j,v,c,m;
  f:=arg[1];
  vals:=arg[2];
  if Length(arg)>2 then
    one:=arg[3];
  else
    one:=One(vals[1]);
  fi;
  f:=ExtRepOfObj(f);
  v:=f[1];
  f:=f[2];
  i:=1;
  while i<=Length(f) do
    c:=f[i];
    m:=one;
    j:=1;
    while j<=Length(c) do
      m:=m*vals[c[j]]^c[j+1];
      j:=j+2;
    od;
    v:=v+f[i+1]*m;
    i:=i+2;
  od;
  return v;
end );

InstallOtherMethod(Value,"multivariate",true,[IsPolynomial,IsList],0,
  ValueMultivariate);

InstallOtherMethod(Value,"multivariate with special one",true,
  [IsPolynomial,IsList,IsMultiplicativeElementWithInverse],0,
  ValueMultivariate);

InstallGlobalFunction(OnIndeterminates,function(p,g)
local e,f,i,j,l,ll;
  e:=ExtRepOfObj(p);
  f:=[e[1]];
  for i in [2..Length(e)] do
    l:=[];
    for j in [1,3..Length(e[i])-1] do
      ll:=List([1,3..Length(e[i][j])-1],k->[e[i][j][k]^g,e[i][j][k+1]]);
      Sort(ll);
      Add(l,[Concatenation(ll),e[i][j+1]]);
    od;
    Sort(l);
    Add(f,Concatenation(l));
  od;
  return ObjByExtRep(FamilyObj(p),f);
end);

#############################################################################
##
#E  ratfun.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

