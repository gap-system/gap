#############################################################################
##
#W  ratfun.gi                   GAP Library                      Frank Celler
#W                                                             Andrew Solomon
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file  contains    methods  for    rational  functions,  laurent
##  polynomials and polynomials and their families.
##
Revision.ratfun_gi :=
    "@(#)$Id$";

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
  true,[IsLaurentPolynomial,IsString],
  0,
function(indet,name)
local c;
  c:=CoefficientsOfLaurentPolynomial(indet);
  if not Length(c[1])=1 and One(c[1][1])=c[1][1] and c[2]=1 then
    TryNextMethod();
  fi;
  SetIndeterminateName(FamilyObj(indet),
      IndeterminateNumberOfLaurentPolynomial(indet),name);
end);

# Functions to create objects in the three representations

#############################################################################
##
#F  LaurentPolynomialByExtRep(<rfam>,<coeffs>,<inum>)
##
InstallGlobalFunction(LaurentPolynomialByExtRep, LAUR_POL_BY_EXTREP);

#############################################################################
##
#F  PolynomialByExtRep(<rfam>,<ext>)
##
InstallGlobalFunction(PolynomialByExtRep,
function(rfam,ext)
local f;

  # objectify
  f := rec();
  ObjectifyWithAttributes(f,rfam!.defaultPolynomialType,
    ExtRepPolynomialRatFun, ext);

  # and return the polynomial
  return f;
end );

#############################################################################
##
#F  RationalFunctionByExtRep(<rfam>,<num>,<den>)
##
##
InstallGlobalFunction(RationalFunctionByExtRep,
function(rfam,num,den)
local f;
  # objectify
  f := rec();
  ObjectifyWithAttributes(f,rfam!.defaultRatFunType,
    ExtRepNumeratorRatFun, num,
    ExtRepDenominatorRatFun, den);

  # and return the polynomial
  return f;
end );

# basic operations to compute attribute values for the properties
# This is the only place where methods should be installed based on the
# representation.


#############################################################################
##
#M  IsLaurentPolynomial( <rat-fun> )
##
InstallMethod( IsLaurentPolynomial,
    true,
    [ IsUnivariateRationalFunction ],
    0,

function( obj )
    local   den;
   
#T: GGT
    den := ExtRepDenominatorRatFun( obj );

    # there has to be only one monomial
    return 2 = Length(den);
end );


#############################################################################
##
#M  IsConstantRationalFunction(<ulaurent>)
##
InstallMethod(IsConstantRationalFunction,"polynomial",true,
  [IsRationalFunction and IsPolynomial],0,
function(f)
local extf;

  extf := ExtRepPolynomialRatFun(f);
  return  Length(extf) = 0 or (Length(extf)=2 and extf[1]=[]);
end);

#############################################################################
##
#M  IsPolynomial(<ratfun>)
##
InstallMethod(IsPolynomial,"rational function rep.",true,
  [IsRationalFunctionDefaultRep],0,
function(f)
local q;
  q:=QuotientPolynomialsExtRep(FamilyObj(f),
	  ExtRepNumeratorRatFun(f),ExtRepDenominatorRatFun(f));
  if q=fail then
    return false;
  else
    SetExtRepPolynomialRatFun(f,q);
    return true;
  fi;
end);

#############################################################################
##
#M  ExtRepPolynomialRatFun(<ulaurent>)
##
InstallMethod(ExtRepPolynomialRatFun,"laurent polynomial rep.",true,
  [IsLaurentPolynomialDefaultRep and IsPolynomial],0,
  EXTREP_POLYNOMIAL_LAURENT);

#############################################################################
##
#M  ExtRepPolynomialRatFun(<ratfun>)
##
InstallMethod(ExtRepPolynomialRatFun,"rational function rep.",true,
  [IsRationalFunctionDefaultRep and IsPolynomial],0,
function(f)
  return QuotientPolynomialsExtRep(FamilyObj(f),
	  ExtRepNumeratorRatFun(f),ExtRepDenominatorRatFun(f));
end);

#############################################################################
##
#M  ExtRepNumeratorRatFun(<poly>)
##
InstallMethod(ExtRepNumeratorRatFun,"polynomial rep -> ExtRepPolynomialRatFun",
  true, [IsPolynomialDefaultRep],0,ExtRepPolynomialRatFun);

#############################################################################
##
#M  ExtRepDenominatorRatFun(<poly>)
##
InstallMethod(ExtRepDenominatorRatFun,"polynomial, return constant",true,
  [IsPolynomialDefaultRep],0,
function(f)
local fam;
  fam:=FamilyObj(f);
  # store the constant ext rep. for one in the family
  if not IsBound(fam!.constantDenominatorExtRep) then
    fam!.constantDenominatorExtRep:=
      Immutable([[],One(CoefficientsFamily(fam))]);
  fi;
  return fam!.constantDenominatorExtRep;
end);

# unused:
# #############################################################################
# ##
# #F  IsUnivariateRationalFunctionByNumerAndDenom( <num>, <den> )
# ##
# ##  <num> and <den> are the second entries in the 'ExtRep' value of
# ##  polynomials, 
# ##
# IsUnivariateRationalFunctionByNumerAndDenom := function( num, den )
#     local   ind,  i;
# #T: GGT
#     # now check the monomials
#     ind := false;
#     for i  in [ 1, 3 .. Length(den)-1 ]  do
#         if 2 < Length(den[i])  then
#             return false;
#         elif 2 = Length(den[i])  then
#             if ind = false  then
#                 ind := den[i][1];
#             elif ind <> den[i][1]  then
#                 return false;
#             fi;
#         fi;
#     od;
#     for i  in [ 1, 3 .. Length(num)-1 ]  do
#         if 2 < Length(num[i])  then
#             return false;
#         elif 2 = Length(num[i])  then
#             if ind = false  then
#                 ind := num[i][1];
#             elif ind <> num[i][1]  then
#                 return false;
#             fi;
#         fi;
#     od;
#     return true;
# end;

#############################################################################
##
#F  UnivariatenessTestRationalFunction(<f>)
##
InstallGlobalFunction(UnivariatenessTestRationalFunction, UNIVARTEST_RATFUN);

#############################################################################
##
#M  IsUnivariateRationalFunction
##
##
InstallMethod( IsUnivariateRationalFunction,"ratfun", true,
  [ IsRationalFunction ], 0,
function(f)
local l;
  l:=UnivariatenessTestRationalFunction(f);
  if l[1]=fail then
    Error("cannot test univariateness without a proper multivariate GCD");
  fi;

  # note Laurent information
  if not HasIsLaurentPolynomial(f) then
    SetIsLaurentPolynomial(f,l[3]);
  fi;

  if l[1]=false then
    return false;
  fi;

  # note indeterminate number
  if not HasIndeterminateNumberOfUnivariateRationalFunction(f) then
    SetIndeterminateNumberOfUnivariateRationalFunction(f,l[2]);
  fi;

  # note Coefficients information
  if l[3]=true and not HasCoefficientsOfLaurentPolynomial(f) then
    SetCoefficientsOfLaurentPolynomial(f,l[4]);
  fi;

  return true;
end);

#############################################################################
##
#M  IsLaurentPolynomial
##
##
InstallMethod( IsLaurentPolynomial,"ratfun", true,
  [ IsRationalFunction ], 0,
function(f)
local l;
  l:=UnivariatenessTestRationalFunction(f);
  if l[1]=fail then
    Error("cannot test laurentness without a proper multivariate GCD");
  fi;

  # note Univariateness information
  if not HasIsUnivariateRationalFunction(f) then
    SetIsUnivariateRationalFunction(f,l[1]);
  fi;

  if l[3]=false then
    return false;
  fi;

  # note indeterminate number
  if not HasIndeterminateNumberOfUnivariateRationalFunction(f) then
    SetIndeterminateNumberOfUnivariateRationalFunction(f,l[2]);
  fi;

  # note Coefficients information
  if not HasCoefficientsOfLaurentPolynomial(f) then
    SetCoefficientsOfLaurentPolynomial(f,l[4]);
  fi;

  return true;
end);

#############################################################################
##
#M  IndeterminateNumberOfUnivariateRationalFunction
##
##
InstallMethod( IndeterminateNumberOfUnivariateRationalFunction,"ratfun", true,
  [ IsUnivariateRationalFunction ], 0,
function(f)
local l;
  l:=UnivariatenessTestRationalFunction(f);
  if l[1]=fail then
    Error(
      "cannot determine indeterminate # without a proper multivariate GCD");
  elif l[1]=false then
    Error("inconsistency!");
  fi;

  # note univariateness number
  if not HasIsUnivariateRationalFunction(f) then
    SetIsUnivariateRationalFunction(f,true);
  fi;

  # note Laurent information
  if not HasIsLaurentPolynomial(f) then
    SetIsLaurentPolynomial(f,l[3]);
  fi;

  # note Coefficients information
  if l[3]=true and not HasCoefficientsOfLaurentPolynomial(f) then
    SetCoefficientsOfLaurentPolynomial(f,l[4]);
  fi;

  return l[2];
end);


#############################################################################
##
#M  CoefficientsOfLaurentPolynomial( <rat-fun> )
##
InstallMethod( CoefficientsOfLaurentPolynomial,"ratfun",true,
    [ IsRationalFunction and IsLaurentPolynomial ], 0,
function(f)
local l;
  l:=UnivariatenessTestRationalFunction(f);
  if l[1]=fail then
    Error(
      "cannot determine coefficients without a proper multivariate GCD");
  elif l[3]=false then
    Error("inconsistency!");
  fi;

  # note univariateness number
  if not HasIsUnivariateRationalFunction(f) then
    SetIsUnivariateRationalFunction(f,true);
  fi;

  # note Laurent information
  if not HasIsLaurentPolynomial(f) then
    SetIsLaurentPolynomial(f,true);
  fi;

  return l[4];
end);

## now everything else will be installed based on properties and will use
# these basic functions as an interface.

#############################################################################
##
#M  NumeratorOfRationalFunction( <ratfun> )
##
InstallMethod( NumeratorOfRationalFunction,"call ExtRepNumerator",true,
  [ IsRationalFunction ],0,
function( f )
  return PolynomialByExtRep(FamilyObj(f),ExtRepNumeratorRatFun(f));
end );

#############################################################################
##
#M  DenominatorOfRationalFunction( <ratfun> )
##
InstallMethod( DenominatorOfRationalFunction,"call ExtRepDenominator",true,
  [ IsRationalFunction ],0,
function( f )
  return PolynomialByExtRep(FamilyObj(f),ExtRepDenominatorRatFun(f));
end );

#############################################################################
##
#M  AsPolynomial( <ratfun> )
##
InstallMethod( AsPolynomial,"call ExtRepPolynomial",true,
  [ IsRationalFunction and IsPolynomial],0,
function( f )
  return PolynomialByExtRep(FamilyObj(f),ExtRepPolynomialRatFun(f));
end );



#############################################################################
##
#F  ExtRepOfPolynomial_String( <obj>, <names>, [<bra>] )
##
##  If the optional third argument is `true', brackets are put around the
##  expression if any summands occur.
##  If the optional fourth argument is `true' then brackets are put around
##  the expression if at least one `\*' sign occurs in the string.
##
ExtRepOfPolynomial_String := function(arg)
local fam,ext,zero,one,mone,i,j,ind,bra,str,s,b,c, mbra;

  fam:=arg[1];
  ext:=arg[2];
  bra:=false;
  mbra:= false;
  str:="";
  zero := fam!.zeroCoefficient;
  one := fam!.oneCoefficient;
  mone := -one;
  if Length(ext)=0 then
    return String(zero);
  fi;
  for i  in [ 1, 3 .. Length(ext)-1 ]  do

    if i>1 then
      # this is the second summand, so arithmetic will occur
      bra:=true;
    fi;

    if ext[i+1]=one then
      if i>1 then
	Add(str,'+');
      fi;
      c:=false;
    elif ext[i+1]=mone then
      Add(str,'-');
      c:=false;
    else
      s:=String(ext[i+1]);

      b:=false;
      if not (IsRat(ext[i+1]) or IsFFE(ext[i+1])) then
	# do 1-st level arithmetics occur in s?
	# we could do better by checking bracketing as well, but this would be
	# harder.
	j:=2;
	while j<=Length(s) do
	  if s[j]='+' or s[j]='-' then
	    b:=true;
	    j:=Length(s)+1; # break
	  fi;
	  j:=j+1;
	od;
	if b then
	  s:=Concatenation("(",s,")");
	fi;
      fi;

      if i>1 and s[1]<>'-' then
	Add(str,'+');
      fi;
      Append(str,s);
      c:=true;
    fi;

    if Length(ext[i])<2 then
      # trivial monomial. Do we have to add a '1'?
      if c=false then
        Append(str,String(one));
      fi;
    else
      if c then
	Add(str,'*');
        mbra:= true;
      fi;
      for j  in [ 1, 3 .. Length(ext[i])-1 ]  do
	if 1 < j  then
	  Add(str,'*');
          mbra:= true;
	fi;
	ind:=ext[i][j];
	if HasIndeterminateName(fam,ind) then
	  Append(str,IndeterminateName(fam,ind));
	else
	  Append(str,"x_");
	  Append(str,String(ind)); 
	fi;
	if 1 <> ext[i][j+1]  then
	  Add(str,'^');
	  Append(str,String(ext[i][j+1]));
	fi;
      od;
    fi;
  od;

  if    ( bra and Length( arg ) >= 3 and arg[3] = true )
     or ( mbra and Length( arg ) = 4 and arg[4] = true ) then
    str:=Concatenation("(",str,")");
  fi;
  return str;
end;


#############################################################################
##
#M  PrintObj( <rat-fun> )
##
##  This method is installed for all  rational function.
##
InstallMethod( String,"rational function", [ IsRationalFunction ],
function( obj )
local fam,s;
  fam := FamilyObj(obj);
  s:= ExtRepOfPolynomial_String( fam,
          ExtRepNumeratorRatFun( obj ), true, false );
  Add(s,'/');
  Append( s, ExtRepOfPolynomial_String( fam,
                 ExtRepDenominatorRatFun( obj ), true, true ) );
  return s;
end );

InstallMethod( String,"polynomial", [ IsPolynomial ],
function( obj )
  return ExtRepOfPolynomial_String(FamilyObj(obj),ExtRepPolynomialRatFun(obj));
end );

# the print methods don't use `String' because we don't want to collect
# `String' attributes in memory.

InstallMethod( PrintObj,"rational function", [ IsRationalFunction ],
function( obj ) local   fam;
    fam:= FamilyObj(obj);
    Print( ExtRepOfPolynomial_String( fam,
               ExtRepNumeratorRatFun( obj ), true, false ),
           "/",
           ExtRepOfPolynomial_String( fam,
               ExtRepDenominatorRatFun( obj ), true, true ) );
end );

InstallMethod( PrintObj,"polynomial", [ IsPolynomial ],
function( obj )
    Print( ExtRepOfPolynomial_String( FamilyObj( obj ),
                                      ExtRepPolynomialRatFun( obj ) ) );
end );


#############################################################################
##
#M  OneOp( <rat-fun> )
##
InstallMethod( OneOp, "defer to family", true,
    [ IsRationalFunction ], 0,
function(obj)
  return One(FamilyObj(obj));
end);

#############################################################################
##
#M  ZeroOp( <rat-fun> )
##
InstallMethod( ZeroOp, "defer to family", true,
    [ IsRationalFunction ], 0,
function(obj)
  return Zero(FamilyObj(obj));
end);

#############################################################################
# 
# Functions for dealing with monomials 
# The monomials are represented as Zipped Lists. 
# i.e. sorted lists [i1,e1,i2, e2,...] where i1<i2<...are the indeterminates
# from smallest to largest
#
#############################################################################

#############################################################################
##
#F  MonomialTotalDegreeLess  . . . . . . total degree ordering for monomials
##
InstallGlobalFunction( MonomialTotalDegreeLess,MONOM_TOT_DEG_LEX);
BindGlobal("MONOM_TOT_DEG_LEX_LIBRARY",function( u, v )
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
#F  MonomialRevLexicoLess(mon1,mon2) . . . .  reverse lexicographic ordering
##
InstallGlobalFunction( MonomialRevLexicoLess, MONOM_REV_LEX);


#############################################################################
##
##  Low level workhorse for operations with monomials in Zipped form
#M  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
##
##  czero is the 0 of the coefficients ring
##  <funcs>[1] is the comparison function (usually \<)
##  <funcs>[2] is the addition operation (usu. \+ or \-)
##
InstallMethod( ZippedSum,
    true,
    [ IsList,
      IsList,
      IsObject,
      IsList ],
    0, ZIPPED_SUM_LISTS);

#############################################################################
##
#F  ZippedListProduct . . . . . . . . . . . . . . . .  multiply two monomials
##
ZippedListProduct := function( l, r )
    return ZippedSum( l, r, 0, [ \<, \+ ] );
end;

#############################################################################
##
#M  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
##
##  Finds the product of the two polynomials in extrep form. 
##  Eg.  ZippedProduct([[1,2,2,3],2,[2,4],3],[[1,3,2,1],5],0,f);
##  gives [ [ 1, 3, 2, 5 ], 15, [ 1, 5, 2, 4 ], 10 ]
##  where
##  f :=[ ZippedListProduct,  MONOM_TOT_DEG_LEX, \+, \* ]; 
##
InstallMethod( ZippedProduct,
    true,
    [ IsList,
      IsList,
      IsObject,
      IsList ],
    0, ZIPPED_PRODUCT_LISTS);

# Function to create the rational functions family and store the 
# default types

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
      CanEasilySortElements,
      IsUFDFamily and IsRationalFunctionsFamily and CanEasilySortElements);

		
    # default type for rational functions
      fam!.defaultRatFunType := NewType( fam,
	      IsRationalFunctionDefaultRep and
	      HasExtRepNumeratorRatFun and HasExtRepDenominatorRatFun);


    # default type for polynomials
      fam!.defaultPolynomialType := NewType( fam,
	      IsPolynomial and IsPolynomialDefaultRep and
	      HasExtRepPolynomialRatFun);


    # default type for univariate laurent polynomials
    fam!.threeLaurentPolynomialTypes := 
      [ NewType( fam,
	    IsLaurentPolynomial
	    and IsLaurentPolynomialDefaultRep and
	    HasIndeterminateNumberOfLaurentPolynomial and
	    HasCoefficientsOfLaurentPolynomial), 

	    NewType( fam,
	      IsLaurentPolynomial
	      and IsLaurentPolynomialDefaultRep and
	      HasIndeterminateNumberOfLaurentPolynomial and
	      HasCoefficientsOfLaurentPolynomial and
	      IsConstantRationalFunction and IsUnivariatePolynomial),

	    NewType( fam,
	      IsLaurentPolynomial and IsLaurentPolynomialDefaultRep and
	      HasIndeterminateNumberOfLaurentPolynomial and
	      HasCoefficientsOfLaurentPolynomial and
	      IsUnivariatePolynomial)];

    # functions to add zipped lists
    fam!.zippedSum := [ MONOM_TOT_DEG_LEX, \+ ];

    # functions to multiply zipped lists
    fam!.zippedProduct := [ ZippedListProduct,
                            MONOM_TOT_DEG_LEX, \+, \* ];

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
    SetZero( fam, PolynomialByExtRep(fam,[]));
    SetOne( fam, PolynomialByExtRep(fam,[[],fam!.oneCoefficient]));

    # we will store separate `one's for univariate polynomials. This will
    # allow to keep univariate calculations in this one indeterminate.
    fam!.univariateOnePolynomials:=[];
    fam!.univariateZeroPolynomials:=[];

    # assign a names list
    fam!.namesIndets := [];

    # and return
    return fam;

end );

# this method is only to get a resonable error message in case the ring does
# not know to be a UFD.
InstallOtherMethod( RationalFunctionsFamily,"not UFD ring", true,
    [ IsObject ],
    0,
function(obj)
  Error("You can only create rational functions over a UFD");
end);


# Arithmetic (only for rational functions and polynomials, everything
# particularly unvariate will be in ratfunul.gi)

#############################################################################
##
#M  AdditiveInverse( <rat-fun> )
##
##
InstallMethod( AdditiveInverseOp,"rational function", true,
    [ IsRationalFunction ], 0,ADDITIVE_INV_RATFUN);

InstallMethod( AdditiveInverseOp,"polynomial", true,
    [ IsPolynomial ], 0, ADDITIVE_INV_POLYNOMIAL);

#############################################################################
##
#M  Inverse( <rat-fun> )
##
##  This exhibits the use of RationalFunctionByPolynomials to do cancellation
##  and special cases which give rise to more specific types of rational fns.
##  RationalFunctionByExtRep does no checking whatever. 
##
InstallMethod( InverseOp, "rational function", true,
    [ IsRationalFunctionsFamilyElement ], 0,
function( obj )
local   num;

    # get the family and check the zeros
    num := ExtRepNumeratorRatFun(obj);
    if Length(num)=0 then
      Error("division by zero");
    fi;

    return RationalFunctionByExtRep(FamilyObj(obj),
      ExtRepDenominatorRatFun(obj) , num);
end );

#############################################################################
##
#M  <polynomial> + <polynomial>
##
##
InstallMethod( \+, "polynomial + polynomial", IsIdenticalObj,
    [ IsPolynomial, IsPolynomial ], 0,
function( left, right )
local   fam;

  if IsZero(right) then
    return left;
  elif IsZero(left) then
    return right;
  fi;

  fam   := FamilyObj(left);

  return PolynomialByExtRep(fam, 
	  ZippedSum(ExtRepPolynomialRatFun(left),
                    ExtRepPolynomialRatFun(right),
	            fam!.zeroCoefficient, fam!.zippedSum));
end );

#############################################################################
##
#M  <polynomial> * <polynomial>
##
##  We assume that if we have a polynomial
##  then ExtRepPolynomialRatFun will work. 
##
InstallMethod( \*, "polynomial * polynomial", IsIdenticalObj,
    [ IsPolynomial, IsPolynomial ], 0,
function( left, right )
local   fam;

  if IsZero(left) then
    return left;
  elif IsZero(right) then
    return right;
  elif HasIsOne(left) and IsOne(left) then
    return right;
  elif HasIsOne(right) and IsOne(right) then
    return left;
  fi;

  # get the family and check the zeros
  fam   := FamilyObj(left);

  return PolynomialByExtRep(fam, ZippedProduct(
	    ExtRepPolynomialRatFun(left),
	    ExtRepPolynomialRatFun(right),
	    fam!.zeroCoefficient, fam!.zippedProduct));

end);

#############################################################################
##
#M  <rat-fun>     = <rat-fun>
##
##  This method is  installed for all  rational functions.
##
##  Relies on Zipped multiplication ... a/b = c/d <=> ac = bd.
##  This way we do not need any GCD
##
InstallMethod( \=,"rational functions", IsIdenticalObj,
    [ IsRationalFunction, IsRationalFunction ], 0,
function( left, right )
local   fam, leftden, rightnum, p1, p2;

  # get the family and check the zeros
  fam   := FamilyObj(left);
  leftden  := ExtRepDenominatorRatFun(left);
  rightnum := ExtRepNumeratorRatFun(right);

  p1 := ZippedProduct(ExtRepNumeratorRatFun(left),
		      ExtRepDenominatorRatFun(right),
		      fam!.zeroCoefficient,fam!.zippedProduct);

  p2 := ZippedProduct(ExtRepNumeratorRatFun(right),
		      ExtRepDenominatorRatFun(left),
		      fam!.zeroCoefficient,fam!.zippedProduct);

  return p1 = p2;
end);

InstallMethod( \=,"polynomial", IsIdenticalObj,
    [ IsPolynomial, IsPolynomial ], 0,
function( left, right )
  return ExtRepPolynomialRatFun(left)=ExtRepPolynomialRatFun(right);
end);

#############################################################################
##
#M  <ratfun> < <ratfun>
##
InstallMethod(\<,"rational functions",IsIdenticalObj,
  [IsRationalFunction,IsRationalFunction],0, SMALLER_RATFUN);


#############################################################################
##
#M  <coeff>  * <rat-fun>
##
##
InstallGlobalFunction(ProdCoefRatfun,
function( coef, ratfun)
local   fam,  i, extnum,pol;

  if IsZero(coef) then
    return Zero(ratfun);
  fi;

  if IsOne(coef) then
    return ratfun;
  fi;

  fam   := FamilyObj(ratfun);

  pol:=HasIsPolynomial(ratfun) and IsPolynomial(ratfun);

  if pol then
    extnum := ShallowCopy(ExtRepPolynomialRatFun(ratfun));
  else
    extnum := ShallowCopy(ExtRepNumeratorRatFun(ratfun));
  fi;

  for i  in [ 2, 4 .. Length(extnum) ]  do
    extnum[i] := coef * extnum[i];
  od;

  # We can do this because a/b is cancelled <=> c*a/b is cancelled
  # where c is a constant.
  if pol then
    return PolynomialByExtRep( fam, extnum);
  else
    return RationalFunctionByExtRep( fam, extnum, 
	  ExtRepDenominatorRatFun(ratfun));
  fi;

end);


#############################################################################
##
#M  <coeff>       * <rat-fun>
##
##
InstallMethod( \*, "coeff * rat-fun", IsCoeffsElms,
    [ IsRingElement, IsRationalFunction ],
    3, # so we dont call  positive integer * additive element
function(c, r)
  return ProdCoefRatfun(c,r);
end);
		
#############################################################################
##
#M  <rat-fun>     * <coeff>
##
##
InstallMethod( \*, "rat-fun * coeff", IsElmsCoeffs,
    [ IsRationalFunction, IsRingElement ],
    3, # so we dont call  positive integer * additive element
function(r, c)
  return ProdCoefRatfun(c,r);
end);

#############################################################################
##
#M  <polynomial>     + <coeff>
##
InstallGlobalFunction(SumCoefPolynomial, SUM_COEF_POLYNOMIAL);

InstallMethod( \+, "polynomial + coeff", IsElmsCoeffs,
    [ IsPolynomial, IsRingElement ], 0,
function( left, right )
  return SumCoefPolynomial(right, left);
end );

InstallMethod( \+, "coeff + polynomial ", IsCoeffsElms,
    [ IsRingElement, IsPolynomial], 0,
function( left, right )
  return SumCoefPolynomial(left, right);
end);

InstallGlobalFunction( QuotientPolynomialsExtRep,QUOTIENT_POLYNOMIALS_EXT);

#############################################################################
##
#F  SpecializedExtRepPol(<fam>,<ext>,<ind>,<val>)
##
InstallGlobalFunction(SpecializedExtRepPol, SPECIALIZED_EXTREP_POL);

InstallMethod(HeuristicCancelPolynomialsExtRep,"ignore",true,
  [IsRationalFunctionsFamily,IsList,IsList],
  # fallback: lower than default for the weakest conditions
  -1,
function(f,a,b)
  return fail; # can't do anything
end);

InstallGlobalFunction(TryGcdCancelExtRepPolynomials,TRY_GCD_CANCEL_EXTREP_POL);

InstallGlobalFunction(RationalFunctionByExtRepWithCancellation,
function(fam,num,den)
local t;
  t:=TryGcdCancelExtRepPolynomials(fam,num,den);
  if Length(t[2])=2 and Length(t[2][1])=0 and IsOne(t[2][2]) then
    return PolynomialByExtRep(fam,t[1]);
  else
    return RationalFunctionByExtRep(fam,t[1],t[2]);
  fi;
end);

#############################################################################
##
#M  <rat-fun>     * <rat-fun>
##
InstallMethod( \*, "rat-fun * rat-fun", IsIdenticalObj,
    [ IsRationalFunction, IsRationalFunction ], 0,
function( left, right )
local fam,num,den;

  fam:=FamilyObj(left);
  if HasIsPolynomial(left) and IsPolynomial(left) then
    num:=ZippedProduct(ExtRepPolynomialRatFun(left),
		      ExtRepNumeratorRatFun(right),
		      fam!.zeroCoefficient,fam!.zippedProduct);
    den:=ExtRepDenominatorRatFun(right);
  elif HasIsPolynomial(right) and IsPolynomial(right) then
    num:=ZippedProduct(ExtRepPolynomialRatFun(right),
		      ExtRepNumeratorRatFun(left),
		      fam!.zeroCoefficient,fam!.zippedProduct);
    den:=ExtRepDenominatorRatFun(left);
  else
    num:=ZippedProduct(ExtRepNumeratorRatFun(left),
		      ExtRepNumeratorRatFun(right),
		      fam!.zeroCoefficient,fam!.zippedProduct);
    den:=ZippedProduct(ExtRepDenominatorRatFun(left),
		      ExtRepDenominatorRatFun(right),
		      fam!.zeroCoefficient,fam!.zippedProduct);
  fi;

  return RationalFunctionByExtRepWithCancellation(fam,num,den);
end);

#############################################################################
##
#M  Quotient  . . . . . . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( Quotient,"multivar with ring",IsCollsElmsElms,
        [ IsPolynomialRing, IsPolynomial, IsPolynomial ], 0,
function( ring, p, q )
    return Quotient( p, q );
end );

InstallOtherMethod( Quotient,"multivar",IsIdenticalObj,
        [ IsPolynomial, IsPolynomial ], 0,
function( p, q )
  q:=QuotientPolynomialsExtRep(FamilyObj(p),ExtRepPolynomialRatFun(p),
                                            ExtRepPolynomialRatFun(q));
  if q<>fail then
    q:=PolynomialByExtRep(FamilyObj(p),q);
  fi;
  return q;
end );

#############################################################################
##
#M  <rat-fun> + <rat-fun>
##
InstallMethod( \+, "rat-fun + rat-fun", IsIdenticalObj,
    [ IsRationalFunction, IsRationalFunction ], 0,
function( left, right )
local fam,num,den,lnum,rnum,lden,rden,q;

  fam:=FamilyObj(left);
  if HasIsPolynomial(left) and IsPolynomial(left) then
    den:=ExtRepDenominatorRatFun(right);
    num:=ZippedProduct(ExtRepPolynomialRatFun(left),den,
		      fam!.zeroCoefficient,fam!.zippedProduct);
    num:=ZippedSum(num,ExtRepNumeratorRatFun(right),
		      fam!.zeroCoefficient,fam!.zippedSum);
  elif HasIsPolynomial(right) and IsPolynomial(right) then
    den:=ExtRepDenominatorRatFun(left);
    num:=ZippedProduct(ExtRepPolynomialRatFun(right),den,
		      fam!.zeroCoefficient,fam!.zippedProduct);
    num:=ZippedSum(num,ExtRepNumeratorRatFun(left),
		      fam!.zeroCoefficient,fam!.zippedSum);

  else
    lnum:=ExtRepNumeratorRatFun(left);
    rnum:=ExtRepNumeratorRatFun(right);
    lden:=ExtRepDenominatorRatFun(left);
    rden:=ExtRepDenominatorRatFun(right);

    if lden=rden then
      # same denominator: add numerators
      den:=lden;
      num:=ZippedSum(lnum,rnum,fam!.zeroCoefficient,fam!.zippedSum);
    else
      q:=QuotientPolynomialsExtRep(fam,lden,rden);
      if q<>fail then
	# left den. is a multiple of right den.
	den:=lden;
	num:=ZippedProduct(rnum,q,fam!.zeroCoefficient,fam!.zippedProduct);
	num:=ZippedSum(num,lnum,fam!.zeroCoefficient,fam!.zippedSum);
      else
	q:=QuotientPolynomialsExtRep(fam,rden,lden);
	if q<>fail then
	  # left den. is a multiple of right den.
	  den:=rden;
	  num:=ZippedProduct(lnum,q,fam!.zeroCoefficient,fam!.zippedProduct);
	  num:=ZippedSum(num,rnum,fam!.zeroCoefficient,fam!.zippedSum);
	else
	  #TODO: GCD of denominators

	  #worst case
	  num:=ZippedSum(ZippedProduct(lnum,rden,
			    fam!.zeroCoefficient,fam!.zippedProduct),
			  ZippedProduct(rnum,lden,
			    fam!.zeroCoefficient,fam!.zippedProduct),
			  fam!.zeroCoefficient,fam!.zippedSum);

	  den:=ZippedProduct(ExtRepDenominatorRatFun(left),
			      ExtRepDenominatorRatFun(right),
			      fam!.zeroCoefficient,fam!.zippedProduct);

        fi;
      fi;
    fi;
  fi;

  return RationalFunctionByExtRepWithCancellation(fam,num,den);

end);

#############################################################################
##
#M  <ratfun>  + <coeff>
##
##
InstallGlobalFunction(SumCoefRatfun,
function( cf, rf )
local   fam,  i, num,den;

  if IsZero(cf) then
    return rf;
  fi;

  fam   := FamilyObj(rf);
  den:=ExtRepDenominatorRatFun(rf);

  # multiply coefficient with denominator to let numerator summand
  num:=ShallowCopy(den);
  for i in [2,4..Length(num)] do
    num[i]:=num[i]*cf;
  od;

  num:=ZippedSum(num,ExtRepNumeratorRatFun(rf),
                 fam!.zeroCoefficient,fam!.zippedSum);

  return RationalFunctionByExtRepWithCancellation(fam,num,den);

end );

InstallMethod( \+, "ratfun + coeff", IsElmsCoeffs,
    [ IsRationalFunction, IsRingElement ], 0,
function( left, right )
  return SumCoefRatfun(right, left);
end );

InstallMethod( \+, "coeff + ratfun ", IsCoeffsElms,
    [ IsRingElement, IsRationalFunction], 0,
function( left, right )
  return SumCoefRatfun(left, right);
end);

#############################################################################
##
#M  DegreeIndeterminate( pol, ind )  degree in indeterminate number ind
##   #W!  fctn. will err if we take polynomial rings over polynomial rings
##
InstallMethod(DegreeIndeterminate,"pol,indetnr",true,
  [IsPolynomial,IsPosInt],0,
function(pol,ind)
  return DEGREE_INDET_EXTREP_POL(ExtRepPolynomialRatFun(pol),ind);
end);

InstallOtherMethod(DegreeIndeterminate,"pol,indet",IsIdenticalObj,
  [IsPolynomial,IsLaurentPolynomial],0,
function(pol,ind)
  return DegreeIndeterminate(pol,
           IndeterminateNumberOfLaurentPolynomial(ind));
end);

#############################################################################
##
#M  GcdOp( <pring>, <upol>, <upol> )  
##  for general rational functions in the hope that we can find them to be
##  polynomials or even univariate polynomials. We install further calls as 
##  the methods are implemented.
##  
##
InstallMethod( GcdOp,"Gcd(Polyring, Pol,Pol)",
    IsCollsElmsElms,[IsEuclideanRing,
                IsRationalFunction,IsRationalFunction],0,
function(R,f,g)

	if IsUnivariatePolynomial(f) and IsUnivariatePolynomial(g) 
		and IndeterminateNumberOfUnivariateRationalFunction(f) = 
		IndeterminateNumberOfUnivariateRationalFunction(g) then
		return GcdOp(R,f,g);
	fi;

	return fail;
end);

#############################################################################
##
#M  Value
##                               
InstallOtherMethod(Value,"multivariate polynomial, with one",
  true,[IsPolynomial,IsList,IsList,IsRingElement],0,
function(pol,inds,vals,one)
local f,i,j,v,c,m,p,fam,ivals;

  if Length(inds)<>Length(vals) then
    Error("wrong number of values");
  fi;

  # convert indeterminates to numbers
  for i in [1..Length(inds)] do
    if not IsPosInt(inds[i]) then
      inds[i]:=IndeterminateNumberOfUnivariateRationalFunction(inds[i]);
    fi;
  od;

  inds:=ShallowCopy(inds);
  ivals:=[]; # values according to index

  f:=ExtRepPolynomialRatFun(pol);
  fam:=CoefficientsFamily(FamilyObj(pol));
  i:=1;
  v:=Zero(fam)*one;
  while i<=Length(f) do
    c:=f[i];
    m:=one;
    j:=1;
    while j<=Length(c) do
      if not IsBound(ivals[c[j]]) then
        p:=Position(inds,c[j]);
	if p<>fail then
	  ivals[c[j]]:=vals[p];
	else
	  ivals[c[j]]:=UnivariatePolynomialByCoefficients(
	             fam,[Zero(fam),One(fam)],c[j]);
	fi;
      fi;
      m:=m*(ivals[c[j]]*one)^c[j+1];
      j:=j+2;
    od;
    v:=v+f[i+1]*m;
    i:=i+2;
  od;
  return v;
end );

RedispatchOnCondition(Value,true,[IsRationalFunction,IsList,IsList],
  [IsPolynomial,IsList,IsList],0);

InstallMethod(Value,"multivariate polynomial",
  true,[IsPolynomial,IsList,IsList],0,
function(pol,inds,vals)
  return Value(pol,inds,vals,One(CoefficientsFamily(FamilyObj(pol))));
end);

#############################################################################
##
#F  LeadingMonomial . . . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( LeadingMonomial, "multivariate polynomials wrt total degree",
        true, [ IsPolynomial  ], 0,
function( pol )

  pol:=ExtRepPolynomialRatFun(pol);
  if Length( pol) = 0 then
      return [];
  fi;
  return pol[ Length(pol) - 1 ];

end );

#############################################################################
##
#F  LeadingCoefficient  . . . . . . . . . . . .  for multivariate polynomials
##
InstallMethod( LeadingCoefficient,"multivariate polynomials wrt total degree",
        true, [ IsPolynomial and IsPolynomialDefaultRep ], 0,
function( pol )
local e;
  e:=ExtRepPolynomialRatFun(pol);
  if Length(e)=0 then
    return FamilyObj(pol)!.zeroCoefficient;
  fi;
  return e[Length(e)];
end );

#############################################################################
##
#F  LeadingCoefficient( pol, ind )  of (multivariate) pol considered as
##         univariate pol in indeterminate # ind with polynomial coeffs.
##
InstallOtherMethod(LeadingCoefficient,"multivariate",true,
  [IsPolynomial,IsPosInt],0,
function(pol,ind)
  return PolynomialByExtRep(FamilyObj(pol),
          LEAD_COEF_POL_IND_EXTREP(ExtRepPolynomialRatFun(pol),ind));
end);

#############################################################################
##
#M  PolynomialCoefficientsOfPolynomial(<pol>,<ind>)
##
InstallMethod(PolynomialCoefficientsOfPolynomial,"polynomial,integer",true,
  [IsRationalFunction and IsPolynomial,IsPosInt],0,
function(pol,ind)
local c,i;
  c:=POL_COEFFS_POL_EXTREP(ExtRepPolynomialRatFun(pol),ind);
  pol:=FamilyObj(pol);
  for i in [1..Length(c)] do
    if not IsBound(c[i]) then
      c[i]:=Zero(pol);
    else
      c[i]:=PolynomialByExtRep(pol,c[i]);
    fi;
  od;
  return c;
end);

InstallOtherMethod(PolynomialCoefficientsOfPolynomial,"polynomial,indet",
  IsIdenticalObj,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial],0,
function(pol,ind)
  return PolynomialCoefficientsOfPolynomial(pol,
           IndeterminateNumberOfLaurentPolynomial(ind));
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
  return Discriminant(pol,IndeterminateNumberOfLaurentPolynomial(ind));
end);

#############################################################################
##
#M  Derivative(<pol>,<ind>)
##
# (this way around because we need the indeterminate
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

InstallGlobalFunction(OnIndeterminates,function(p,g)
local e,f,i,j,l,ll,cmp;
  if IsPolynomial(p) then
    e:=[ExtRepPolynomialRatFun(p)];
  else
    e:=[ExtRepNumeratorRatFun(p),ExtRepDenominatorRatFun(p)];
  fi;
  cmp:=FamilyObj(p)!.zippedSum[1]; # monomial comparison function

  f:=[];
  for i in [1..Length(e)] do
    l:=[];
    for j in [1,3..Length(e[i])-1] do
      ll:=List([1,3..Length(e[i][j])-1],k->[e[i][j][k]^g,e[i][j][k+1]]);
      Sort(ll);
      Add(l,[Concatenation(ll),e[i][j+1]]);
    od;
    Sort(l,function(a,b) return cmp(a[1],b[1]);end);
    f[i]:=Concatenation(l);
  od;
  if Length(f)=1 then
    return PolynomialByExtRep(FamilyObj(p),f[1]);
  else
    return RationalFunctionByExtRep(FamilyObj(p),f[1],f[2]);
  fi;
end);

#############################################################################
##
#F  ConstantInBaseRingPol(pol,ind)   remove indeterminate ind from polynomial
##
BindGlobal("ConstantInBaseRingPol",function(pol,ind)
  if IsConstantRationalFunction(pol) and
    HasIndeterminateNumberOfUnivariateRationalFunction(pol) and
    IndeterminateNumberOfUnivariateRationalFunction(pol)=ind then
    # constant polynomial represented as univariate: take coefficient
    pol:=ExtRepPolynomialRatFun(pol)[2];
  fi;
  return pol;
end);

#############################################################################
##
#M  Resultant( <f>, <g>, <ind> )
##
InstallMethod(Resultant,"pol,pol,inum",IsFamFamX,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial,
  IsPosInt],0,
function(f,g,ind)
local fam,tw,res,m,n,mn,r,e,s,d,dr,px,x,y,onepol,stop;

  fam:=FamilyObj(f);
  onepol:=One(f);
  res:=onepol;
  onepol:=-onepol;

  # fix some special cases: for baseRing elements,  Degree
  #  may not work
  m:=DegreeIndeterminate(f,ind);
  n:=DegreeIndeterminate(g,ind);

  if n>m then
    # force f to be of larger degee
    res:=(onepol)^(n*m);
    tw:=f; f:=g; g:=tw;
    tw:=m; m:=n; n:=tw;
  fi;

  # trivial cases
  if m=0 then
    return ConstantInBaseRingPol(res*f^n,ind);
  elif n=0 then
    return ConstantInBaseRingPol(res*g^m,ind);
  fi;

  # and now we may start really, subresultant algorithm: S_j+1=g, S_j+2=f

  x:=fam!.oneCoefficient;
  y:=x;
  while 0<n do
    mn:=m-n;
    res:=res*(onepol^m)^n;

    # r:=PseudoDivision(f,g,ind)[2];
    # inline pseudo division: We only need the remainder!

    d:=LeadingCoefficient(g,ind);

    px:=LaurentPolynomialByExtRep(fam,[fam!.oneCoefficient],1,ind);

    r:=f;
    e:=m-n+1;
    stop:=false;
    repeat
      dr:=DegreeIndeterminate(r,ind);
      if dr<n then
	r:=d^e*r;
        stop:=true;
      fi;
      if stop=false then
	s:=LeadingCoefficient(r,ind)*px^(dr-n);
	r:=d*r-s*g;
	e:=e-1;
      fi;
    until stop;

    m:=n;
    n:=dr;

    f:=g;
#    was: g:=r/(x*y^mn) However the double division seems more gently;
    g:=r/x/y^mn;
    x:=LeadingCoefficient(f,ind);
    y:=x^mn/y^(mn-1);
  od;

  res:=res*g;
  if m>1 then
    res:=res*(g/y)^(m-1);
  fi;

  return ConstantInBaseRingPol(res,ind);
end);


InstallOtherMethod(Resultant,"pol,pol,indet",IsFamFamFam,
  [IsRationalFunction and IsPolynomial,IsRationalFunction and IsPolynomial,
  IsRationalFunction and IsPolynomial],0,
function(a,b,ind)
  return Resultant(a,b,
           IndeterminateNumberOfLaurentPolynomial(ind));
end);


#############################################################################
##
#F  LeadingMonomialPosExtRep    position of leading monomial in external rep.
##                              list
##
InstallGlobalFunction( LeadingMonomialPosExtRep, function(fam,e,order)
local bp,p;
  # is the order the one in which the monomials are stored anyhow?
  if order=fam!.zippedSum[1] then
    return Length(e)-1;
  fi;

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
InstallGlobalFunction( PolynomialReduction, POLYNOMIAL_REDUCTION );

#############################################################################
##
#E  ratfun.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
