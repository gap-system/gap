#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Andrew Solomon, Juergen Mueller, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file  contains    methods  for    rational  functions,  laurent
##  polynomials and polynomials and their families.
##

#############################################################################
##
#M  IndeterminateName(<fam>,<nr>)
#M  HasIndeterminateName(<fam>,<nr>)
#M  SetIndeterminateName(<fam>,<nr>,<name>)
##
InstallMethod(IndeterminateName,"for rational function families",true,
  [IsPolynomialFunctionsFamily,IsPosInt],0,
function(fam,nr)
  if IsBound(fam!.namesIndets[nr]) then
    return fam!.namesIndets[nr];
  else
    return fail;
  fi;
end);

InstallMethod(HasIndeterminateName,"for rational function families",true,
  [IsPolynomialFunctionsFamily,IsPosInt],0,
function(fam,nr)
  return IsBound(fam!.namesIndets[nr]);
end);

InstallMethod(SetIndeterminateName,"for rational function families",true,
  [IsPolynomialFunctionsFamily,IsPosInt,IsString],0,
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
#F  LaurentPolynomialByExtRepNC(<rfam>,<coeffs>,<inum>)
##
InstallGlobalFunction(LaurentPolynomialByExtRepNC, LAUR_POL_BY_EXTREP);

#############################################################################
##
#F  UnivariateRationalFunctionByExtRepNC(<rfam>,<ncof>,<dcof>,<val>,<inum>)
##
InstallGlobalFunction(UnivariateRationalFunctionByExtRepNC, UNIV_FUNC_BY_EXTREP);

BindGlobal("SortedPolExtrepRatfun",function(fam,ext)
local d, e, cfam, mo, d1, e1, i, j;
  d:=[];
  e:=[];
  cfam:=CoefficientsFamily(fam);
  for i in [2,4..Length(ext)] do
    if not IsIdenticalObj(FamilyObj(ext[i]),cfam) then
      Error("invalid coefficient ",ext[i]);
    fi;
    mo:=ext[i-1];
    if ForAny(mo,j->not IsInt(j) or j<1) then
      Error("invalid monomial ",mo);
    fi;
    if ForAny([3,5..Length(mo)-1],i->mo[i]<=mo[i-2]) then
      # sort the monomial
      d1:=mo{[1,3..Length(mo)-1]};
      e1:=mo{[2,4..Length(mo)]};
      SortParallel(d1,e1);
      mo:=[];
      for j in [1..Length(e1)] do
        Add(mo,d1[j]);
        Add(mo,e1[j]);
      od;
      if ForAny([3,5..Length(mo)-1],i->mo[i]=mo[i-2]) then
        Error("duplicate variable in monomial ",mo);
      fi;
    fi;
    Add(d,ext[i]);
    Add(e,mo);
  od;
  SortParallel(e,d,fam!.zippedSum[1]);
  ext:=[];
  for i in [1..Length(e)] do
    Add(ext,e[i]);
    Add(ext,d[i]);
  od;
  if ForAny([3,5..Length(ext)-1],i->ext[i]=ext[i-2]) then
    Error("duplicate monomial in ",ext);
  fi;
  return ext;
end);

#############################################################################
##
#F  PolynomialByExtRepNC(<rfam>,<ext>)
##
InstallGlobalFunction(PolynomialByExtRepNC,function(rfam,ext)
local f;
  # objectify
  f := rec();
  ObjectifyWithAttributes(f,rfam!.defaultPolynomialType,
    ExtRepPolynomialRatFun, ext);
  # and return the polynomial
  return f;
end );

InstallGlobalFunction(PolynomialByExtRep,function(rfam,ext)
  return PolynomialByExtRepNC(rfam,SortedPolExtrepRatfun(rfam,ext));
end);

#############################################################################
##
#F  RationalFunctionByExtRepNC(<rfam>,<num>,<den>)
##
##
InstallGlobalFunction(RationalFunctionByExtRepNC,
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

InstallGlobalFunction(RationalFunctionByExtRep,function(rfam,num,den)
  return RationalFunctionByExtRepNC(rfam,SortedPolExtrepRatfun(rfam,num),
                                   SortedPolExtrepRatfun(rfam,den));
end);

# basic operations to compute attribute values for the properties
# This is the only place where methods should be installed based on the
# representation.


#############################################################################
##
#M  IsLaurentPolynomial( <rat-fun> )
##
InstallMethod(IsLaurentPolynomial,true,[ IsUnivariateRationalFunction ], 0,
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
  [IsPolynomialFunction and IsPolynomial],0,
function(f)
local extf;
  extf := ExtRepPolynomialRatFun(f);
  return  Length(extf) = 0 or (Length(extf)=2 and extf[1]=[]);
end);

#############################################################################
##
#M  IsConstantRationalFunction(<ulaurent>)
##
InstallMethod(IsConstantRationalFunction,"rational function",true,
  [IsPolynomialFunction],0,
function(f)
local extf;
  if not IsPolynomial(f) then
    return false;
  fi;
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

InstallOtherMethod(IsPolynomial,"fallback for non-ratfun",true,
  [IsObject],0,
function(o)
  if IsRationalFunction(o) then
    TryNextMethod();
  else
    return false;
  fi;
end);

InstallOtherMethod(IsLaurentPolynomial,"fallback for non-ratfun",true,
  [IsObject],0,
function(o)
  if IsRationalFunction(o) then
    TryNextMethod();
  else
    return false;
  fi;
end);

InstallOtherMethod(IsConstantRationalFunction,"fallback for non-ratfun",true,
  [IsObject],0,
function(o)
  if IsRationalFunction(o) then
    TryNextMethod();
  else
    return false;
  fi;
end);

InstallOtherMethod(IsUnivariateRationalFunction,"fallback for non-ratfun",true,
  [IsObject],0,
function(o)
  if IsRationalFunction(o) then
    TryNextMethod();
  else
    return false;
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
  [IsRationalFunction],0,
function(f)
local fam;
  fam:=FamilyObj(f);
  # store the constant ext rep. for one in the family
  if not IsBound(fam!.constantDenominatorExtRep) then
    fam!.constantDenominatorExtRep:= Immutable([[],fam!.oneCoefficient]);
  fi;
  return fam!.constantDenominatorExtRep;
end);

#############################################################################
##
#F  UnivariatenessTestRationalFunction(<f>)
##
InstallGlobalFunction(UnivariatenessTestRationalFunction, UNIVARTEST_RATFUN);

# this function deals with the information returned by
# `UnivariatenessTestRationalFunction' and sets attributes accordingly.
BindGlobal("DoUnivTestRatfun",function(f)
local l;
  l:=UnivariatenessTestRationalFunction(f);
  if l[1]=fail then
    Error("cannot test univariateness without a proper multivariate GCD");
  fi;

  # note Univariate information
  if not HasIsUnivariateRationalFunction(f) then
    SetIsUnivariateRationalFunction(f,l[1]);
  fi;

  if l[1] then
    # note indeterminate number
    if not HasIndeterminateNumberOfUnivariateRationalFunction(f) then
      SetIndeterminateNumberOfUnivariateRationalFunction(f,l[2]);
    fi;

    # note Laurent information
    if not HasIsLaurentPolynomial(f) then
      SetIsLaurentPolynomial(f,l[3]);
    fi;

    # note Coefficients information
    if l[3]=true and Length(l[4])=2
     and not HasCoefficientsOfLaurentPolynomial(f) then
      SetCoefficientsOfLaurentPolynomial(f,l[4]);
    fi;

    if l[3]=false and Length(l[4])=3
     and not HasCoefficientsOfUnivariateRationalFunction(f) then
      SetCoefficientsOfUnivariateRationalFunction(f,l[4]);
    fi;

  fi;
  return l;
end);

#############################################################################
##
#M  IsUnivariateRationalFunction
##
##
InstallMethod(IsUnivariateRationalFunction,"ratfun", true,
[ IsRationalFunction ], 0, f->DoUnivTestRatfun(f)[1]);

#############################################################################
##
#M  IsLaurentPolynomial
##
##
InstallMethod(IsLaurentPolynomial,"ratfun", true,
  [ IsRationalFunction ], 0, f->DoUnivTestRatfun(f)[3]);

#############################################################################
##
#M  IndeterminateNumberOfUnivariateRationalFunction
##
##
InstallMethod(IndeterminateNumberOfUnivariateRationalFunction,"ratfun", true,
  [ IsUnivariateRationalFunction ], 0,
function(f)
local l;
  l:=DoUnivTestRatfun(f);
  if l[1]=false then
    Error("inconsistency!");
  fi;

  return l[2];
end);


#############################################################################
##
#M  CoefficientsOfLaurentPolynomial( <rat-fun> )
##
InstallMethod(CoefficientsOfLaurentPolynomial,"ratfun",true,
    [ IsRationalFunction and IsLaurentPolynomial ], 0,
function(f)
local l;
  l:=DoUnivTestRatfun(f); # will set the attribute
  if l[3]=false or not HasCoefficientsOfLaurentPolynomial(f) then
    Error("inconsistency!");
  fi;
  return CoefficientsOfLaurentPolynomial(f);
end);

#############################################################################
##
#M  CoefficientsOfUnivariateRationalFunction( <rat-fun> )
##
InstallMethod( CoefficientsOfUnivariateRationalFunction,"ratfun",true,
    [ IsRationalFunction and IsUnivariateRationalFunction ], 0,
function(f)
local l;
  l:=DoUnivTestRatfun(f); # will set the attribute or laurentness. In both
                          # cases we can redispatch safely.
  if l[1]=false or not (HasCoefficientsOfUnivariateRationalFunction(f)
    or (HasIsLaurentPolynomial(f) and IsLaurentPolynomial(f)))
  then
    Error("inconsistency!");
  fi;
  return CoefficientsOfLaurentPolynomial(f);
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
  return PolynomialByExtRepNC(FamilyObj(f),ExtRepNumeratorRatFun(f));
end );

#############################################################################
##
#M  DenominatorOfRationalFunction( <ratfun> )
##
InstallMethod( DenominatorOfRationalFunction,"call ExtRepDenominator",true,
  [ IsRationalFunction ],0,
function( f )
  return PolynomialByExtRepNC(FamilyObj(f),ExtRepDenominatorRatFun(f));
end );

#############################################################################
##
#M  NumeratorOfRationalFunction( <ratfun> )
##
InstallMethod( NumeratorOfRationalFunction,"univariate using ExtRepNumerator",true,
  [ IsRationalFunction and IsUnivariateRationalFunction],0,
function( f )
local num;
  num:=IndeterminateNumberOfUnivariateRationalFunction(f);
  f:= PolynomialByExtRepNC(FamilyObj(f),ExtRepNumeratorRatFun(f));
  SetIndeterminateNumberOfUnivariateRationalFunction(f,num);
  IsUnivariatePolynomial(f);
  return f;
end );

#############################################################################
##
#M  DenominatorOfRationalFunction( <ratfun> )
##
InstallMethod( DenominatorOfRationalFunction,"univariate using ExtRepDenominator",true,
  [ IsRationalFunction and IsUnivariateRationalFunction],0,
function( f )
local num;
  num:=IndeterminateNumberOfUnivariateRationalFunction(f);
  f:= PolynomialByExtRepNC(FamilyObj(f),ExtRepDenominatorRatFun(f));
  SetIndeterminateNumberOfUnivariateRationalFunction(f,num);
  IsUnivariatePolynomial(f);
  return f;
end );

#############################################################################
##
#M  AsPolynomial( <ratfun> )
##
InstallMethod( AsPolynomial,"call ExtRepPolynomial",true,
  [ IsRationalFunction and IsPolynomial],0,
function( f )
  return PolynomialByExtRepNC(FamilyObj(f),ExtRepPolynomialRatFun(f));
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
BindGlobal("ExtRepOfPolynomial_String",function(arg)
local fam,ext,zero,one,mone,i,j,ind,bra,str,s,b,c, mbra,le;

  fam:=arg[1];
  ext:=arg[2];
  bra:=false;
  mbra:= false;
  str:="";
  zero := fam!.zeroCoefficient;
  one := fam!.oneCoefficient;
  mone := -one;
  le:=Length(ext);

  if le=0 then
    return String(zero);
  fi;
  for i  in [ le-1,le-3..1] do
    if i<le-1 then
      # this is the second summand, so arithmetic will occur
      bra:=true;
    fi;

    if ext[i+1]=one then
      if i<le-1 then
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

      if i<le-1 and s[1]<>'-' then
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
end);


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
    [ IsPolynomialFunction ], 0,
function(obj)
  return One(FamilyObj(obj));
end);

#############################################################################
##
#M  ZeroOp( <rat-fun> )
##
InstallMethod( ZeroOp, "defer to family", true,
    [ IsPolynomialFunction ], 0,
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
#F  MonomialExtGrlexLess
##
InstallGlobalFunction( MonomialExtGrlexLess,MONOM_GRLEX);


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
    0,
    ZIPPED_SUM_LISTS);
#function(a,b,c,d)
#local x,y;
#  x:=ZIPPED_SUM_LISTS_LIB(a,b,c,d);
#  y:=ZIPPED_SUM_LISTS(a,b,c,d);
#  if x<>y then
#    Error("ZS");
#  fi;
#  return y;
#end);

#ZippedListProduct := function( l, r )
#local a,b;
#    a:=ZippedSum( l, r, 0, [ \<, \+ ] );
#    b:=MONOM_PROD(l,r);
#    if a<>b then
#      Error("prod");
#    fi;
#    return b;
#end;

#############################################################################
##
#M  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
##
##  Finds the product of the two polynomials in extrep form.
##  Eg.  ZippedProduct([[1,2,2,3],2,[2,4],3],[[1,3,2,1],5],0,f);
##  gives [ [ 1, 3, 2, 5 ], 15, [ 1, 5, 2, 4 ], 10 ]
##  where
##  f :=[ MONOM_PROD,  MONOM_GRLEX, \+, \* ];
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
    [ IsFamily ],
    1,

function( efam )
  local   fam,elmfilt,filt;

  # filter
  elmfilt:=IsPolynomialFunction and IsPolynomialFunctionsFamilyElement;
  filt:= IsPolynomialFunctionsFamily and CanEasilySortElements;
  if IsUFDFamily(efam) then
    elmfilt:=elmfilt and IsRationalFunction and IsRationalFunctionsFamilyElement;
    filt:=filt and IsUFDFamily and IsRationalFunctionsFamily;
  fi;

  # create a new family in the category <IsRationalFunctionsFamily>
  fam := NewFamily(
    "RationalFunctionsFamily(...)",
    elmfilt, CanEasilySortElements,filt);

  # default type for polynomials
  fam!.defaultPolynomialType := NewType( fam,
          IsPolynomial and IsPolynomialDefaultRep and
          HasExtRepPolynomialRatFun);

  # default type for univariate laurent polynomials
  fam!.threeLaurentPolynomialTypes := MakeImmutable(
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
            IsUnivariatePolynomial)] );

  # default type for univariate rational functions
  fam!.univariateRatfunType := NewType( fam,
          IsUnivariateRationalFunctionDefaultRep  and
          HasIndeterminateNumberOfLaurentPolynomial and
          HasCoefficientsOfUnivariateRationalFunction);

  if IsUFDFamily(efam) then
    # default type for rational functions
    fam!.defaultRatFunType := NewType( fam,
            IsRationalFunctionDefaultRep and
            HasExtRepNumeratorRatFun and HasExtRepDenominatorRatFun);
  fi;

  # functions to add zipped lists
  fam!.zippedSum := MakeImmutable([ MONOM_GRLEX, \+ ]);

  # functions to multiply zipped lists
  fam!.zippedProduct := MakeImmutable([ MONOM_PROD,
                          MONOM_GRLEX, \+, \* ]);

  # set the one and zero coefficient
  fam!.zeroCoefficient := Zero(efam);
  fam!.oneCoefficient  := One(efam);
  if fam!.oneCoefficient=fail then
    Info(InfoWarning,1,"The polynomial is created over a ring without one.");
  fi;
  fam!.oneCoefflist  := Immutable([fam!.oneCoefficient]);

  # set the coefficients
  SetCoefficientsFamily( fam, efam );

  # Set the characteristic.
  if HasCharacteristic( efam ) then
    SetCharacteristic( fam, Characteristic( efam ) );
  fi;


  # and set one and zero
  SetZero( fam, PolynomialByExtRepNC(fam,[]));
  SetOne( fam, PolynomialByExtRepNC(fam,[[],fam!.oneCoefficient]));

  # we will store separate `one's for univariate polynomials. This will
  # allow to keep univariate calculations in this one indeterminate.
  fam!.univariateOnePolynomials:=[];
  fam!.univariateZeroPolynomials:=[];

  # assign a names list
  fam!.namesIndets := [];

  # and return
  return fam;

end );

# this method is only to get a reasonable error message in case the ring does
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

    return RationalFunctionByExtRepNC(FamilyObj(obj),
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
local   fam,el,er;

  el:=ExtRepPolynomialRatFun(left);
  er:=ExtRepPolynomialRatFun(right);
  if Length(er)=0 then
    return left;
  elif Length(el)=0 then
    return right;
  fi;

  fam   := FamilyObj(left);

  return PolynomialByExtRepNC(fam,
          ZippedSum(el,er,fam!.zeroCoefficient, fam!.zippedSum));
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

  return PolynomialByExtRepNC(fam, ZippedProduct(
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
local   fam, p1, p2;

  # get the family and check the zeros
  fam   := FamilyObj(left);

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
  [IsPolynomialFunction,IsPolynomialFunction],0, SMALLER_RATFUN);


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
    return PolynomialByExtRepNC( fam, extnum);
  else
    return RationalFunctionByExtRepNC( fam, extnum,
          ExtRepDenominatorRatFun(ratfun));
  fi;

end);


#############################################################################
##
#M  <coeff>       * <rat-fun>
##
##
InstallMethod( \*, "coeff * rat-fun", IsCoeffsElms,
    [ IsRingElement, IsPolynomialFunction ],
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
    [ IsPolynomialFunction, IsRingElement ],
    3, # so we dont call  positive integer * additive element
function(r, c)
  return ProdCoefRatfun(c,r);
end);

InstallMethod( \*, "ratfun * rat", true,
    [ IsPolynomialFunction, IsRat ], {} -> -RankFilter(IsRat),
function( left, right )
  return left * (right*FamilyObj(left)!.oneCoefficient);
end );

InstallMethod( \*, "rat * ratfun ", true,
    [ IsRat, IsPolynomialFunction], {} -> -RankFilter(IsRat),
function( left, right )
  return (left*FamilyObj(right)!.oneCoefficient) * right;
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

# divide by constant polynomials

InstallMethod(\/,"constant denominator poly",IsIdenticalObj,
  [IsPolynomial,IsPolynomial],0,
function(num,den)
local e;
  e:=ExtRepNumeratorRatFun(den);
  if Length(e)=0 then Error("Division by zero");
  elif Length(e)>2 or Length(e[1])>0 then TryNextMethod();fi;
  e:=Inverse(e[2]);
  if e=fail then TryNextMethod();fi;
  return e*num;
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
ReturnFail);

InstallGlobalFunction(TryGcdCancelExtRepPolynomials,TRY_GCD_CANCEL_EXTREP_POL);

InstallGlobalFunction(RationalFunctionByExtRepWithCancellation,
function(fam,num,den)
local t;
  t:=TryGcdCancelExtRepPolynomials(fam,num,den);
  if Length(t[2])=2 and Length(t[2][1])=0 and IsOne(t[2][2]) then
    return PolynomialByExtRepNC(fam,t[1]);
  else
    return RationalFunctionByExtRepNC(fam,t[1],t[2]);
  fi;
end);

#############################################################################
##
#M  <rat-fun>     * <rat-fun>
##
InstallMethod( \*, "rat-fun * rat-fun", IsIdenticalObj,
    [ IsRationalFunction, IsRationalFunction ], 0,
function( left, right )
local fam,t,num,tt,den;

  fam:=FamilyObj(left);
  if (HasIsZero(left) and IsZero(left)) or
     (HasIsZero(right) and IsZero(right)) then
      return Zero(fam);
  elif HasIsOne(left) and IsOne(left) then
      return right;
  elif HasIsOne(right) and IsOne(right) then
      return left;
  elif HasIsPolynomial(left) and IsPolynomial(left) then
      t:=TryGcdCancelExtRepPolynomials(fam,
                  ExtRepPolynomialRatFun(left),
                  ExtRepDenominatorRatFun(right));
      num:=ZippedProduct(t[1],ExtRepNumeratorRatFun(right),
          fam!.zeroCoefficient,fam!.zippedProduct);
      if Length(t[2])=2 and t[2][1]=[] and t[2][2]=fam!.oneCoefficient then
          return PolynomialByExtRepNC(fam,num);
      else
          return RationalFunctionByExtRepNC(fam,num,t[2]);
      fi;
  elif HasIsPolynomial(right) and IsPolynomial(right) then
      t:=TryGcdCancelExtRepPolynomials(fam,
                  ExtRepPolynomialRatFun(right),
                  ExtRepDenominatorRatFun(left));
      num:=ZippedProduct(t[1],ExtRepNumeratorRatFun(left),
          fam!.zeroCoefficient,fam!.zippedProduct);
      if Length(t[2])=2 and t[2][1]=[] and t[2][2]=fam!.oneCoefficient then
          return PolynomialByExtRepNC(fam,num);
      else
          return RationalFunctionByExtRepNC(fam,num,t[2]);
      fi;
  else
      t:=TryGcdCancelExtRepPolynomials(fam,
          ExtRepNumeratorRatFun(left),ExtRepDenominatorRatFun(right));
      tt:=TryGcdCancelExtRepPolynomials(fam,
          ExtRepNumeratorRatFun(right),ExtRepDenominatorRatFun(left));
      num:=ZippedProduct(t[1],tt[1],fam!.zeroCoefficient,
          fam!.zippedProduct);
      den:=ZippedProduct(t[2],tt[2],fam!.zeroCoefficient,
          fam!.zippedProduct);
      if Length(den)=2 and den[1]=[] and den[2]=fam!.oneCoefficient then
          return PolynomialByExtRepNC(fam,num);
      else
          return RationalFunctionByExtRepNC(fam,num,den);
      fi;
  fi;

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
    q:=PolynomialByExtRepNC(FamilyObj(p),q);
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
local fam,num,den,lnum,rnum,lden,rden,t,tmp,tmpp,i;

  fam:=FamilyObj(left);
  if HasIsPolynomial(left) and IsPolynomial(left) then
    den:=ExtRepDenominatorRatFun(right);
    num:=ZippedProduct(ExtRepPolynomialRatFun(left),den,
                      fam!.zeroCoefficient,fam!.zippedProduct);
    num:=ZippedSum(num,ExtRepNumeratorRatFun(right),
                      fam!.zeroCoefficient,fam!.zippedSum);
    return RationalFunctionByExtRepNC(fam,num,den);
  elif HasIsPolynomial(right) and IsPolynomial(right) then
    den:=ExtRepDenominatorRatFun(left);
    num:=ZippedProduct(ExtRepPolynomialRatFun(right),den,
                      fam!.zeroCoefficient,fam!.zippedProduct);
    num:=ZippedSum(num,ExtRepNumeratorRatFun(left),
                      fam!.zeroCoefficient,fam!.zippedSum);
    return RationalFunctionByExtRepNC(fam,num,den);
  else
    lnum:=ExtRepNumeratorRatFun(left);
    rnum:=ExtRepNumeratorRatFun(right);
    lden:=ExtRepDenominatorRatFun(left);
    rden:=ExtRepDenominatorRatFun(right);

    if lden=rden then
      # same denominator: add numerators
      num:=ZippedSum(lnum,rnum,fam!.zeroCoefficient,fam!.zippedSum);
      if Length(num)=0 then
        return Zero(fam);
      fi;
      t:=TryGcdCancelExtRepPolynomials(fam,num,lden);
      if Length(t[2])=2 and Length(t[2][1])=0 and t[2][2]=fam!.oneCoefficient
        then
        return PolynomialByExtRepNC(fam,t[1]);
      else
        return RationalFunctionByExtRepNC(fam,t[1],t[2]);
      fi;
    else
      t:=TryGcdCancelExtRepPolynomials(fam,lden,rden);
      tmpp:=ZippedProduct(rnum,t[1],fam!.zeroCoefficient,
                    fam!.zippedProduct);
      tmp:=ZippedProduct(lnum,t[2],fam!.zeroCoefficient,
                    fam!.zippedProduct);
      num:=ZippedSum(tmp,tmpp,fam!.zeroCoefficient,fam!.zippedSum);
      if Length(t)=3 then
        tmp:=t[3];
      else
        tmp:=QuotientPolynomialsExtRep(fam,rden,t[2]);
      fi;
      tmpp:=TryGcdCancelExtRepPolynomials(fam,num,tmp);
      den:=ZippedProduct(tmpp[2],t[1],fam!.zeroCoefficient,
                    fam!.zippedProduct);
      den:=ZippedProduct(den,t[2],fam!.zeroCoefficient,
                    fam!.zippedProduct);
      if Length(den)=2 and Length(den[1])=0 then
        if den[2]<>fam!.oneCoefficient then
          for i in [2,4..Length(tmpp[1])] do
            tmpp[1][i]:=tmpp[1][i]/den[2];
          od;
        fi;
        return PolynomialByExtRepNC(fam,tmpp[1]);
      else
        return RationalFunctionByExtRepNC(fam,tmpp[1],den);
      fi;
    fi;
  fi;

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
    [ IsPolynomialFunction, IsRingElement ], 0,
function( left, right )
  return SumCoefRatfun(right, left);
end );

InstallMethod( \+, "coeff + ratfun ", IsCoeffsElms,
    [ IsRingElement, IsPolynomialFunction], 0,
function( left, right )
  return SumCoefRatfun(left, right);
end);

InstallMethod( \+, "ratfun + rat", true,
    [ IsPolynomialFunction, IsRat ], {} -> -RankFilter(IsRat),
function( left, right )
  return left+right*FamilyObj(left)!.oneCoefficient;
end );

InstallMethod( \+, "rat + ratfun ", true,
    [ IsRat, IsPolynomialFunction], {} -> -RankFilter(IsRat),
function( left, right )
  return left*FamilyObj(right)!.oneCoefficient+right;
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
InstallRingAgnosticGcdMethod("test polynomials for univar. and same variable",
  IsCollsElmsElms,IsIdenticalObj,
  [IsEuclideanRing,IsRationalFunction,IsRationalFunction],0,
function(f,g)

  if not (HasIsUnivariatePolynomial(f) and HasIsUnivariatePolynomial(g))
    and IsUnivariatePolynomial(f) and IsUnivariatePolynomial(g)
    and IndeterminateNumberOfUnivariateRationalFunction(f) =
    IndeterminateNumberOfUnivariateRationalFunction(g) then
    return GcdOp(f,g);
  fi;

  TryNextMethod();
end);

#############################################################################
##
#M  <upol>(<val>)
##
##  Method to allow univariate polynomials to be used like functions when
##  appropriate
InstallMethod(CallFuncList, [IsUnivariatePolynomial, IsList],
  function(poly, lst)
    if Length(lst) <> 1 then
        TryNextMethod();
    fi;
    return Value(poly, lst[1]);
end);

#############################################################################
##
#M  Value
##
InstallOtherMethod(Value,"rat.fun., with one",
  true,[IsPolynomialFunction,IsList,IsList,IsRingElement],0,
function(rf,inds,vals,one)
local i,fam,ivals,valextrep,d;

  if Length(inds)<>Length(vals) then
    Error("wrong number of values");
  fi;

  # convert indeterminates to numbers
  inds:= ShallowCopy( inds );
  for i in [1..Length(inds)] do
    if not IsPosInt(inds[i]) then
      inds[i]:=IndeterminateNumberOfUnivariateRationalFunction(inds[i]);
    fi;
  od;

  ivals:=[]; # values according to index

  fam:=CoefficientsFamily(FamilyObj(rf));


  valextrep:=function(f)
  local i,j,v,c,m,p;
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
  end;

  if HasIsPolynomial(rf) and IsPolynomial(rf) then
    return valextrep(ExtRepPolynomialRatFun(rf));
  else
    d:=valextrep(ExtRepDenominatorRatFun(rf));
    if IsZero(d) then
      Error("Denominator evaluates as zero");
    fi;
    return valextrep(ExtRepNumeratorRatFun(rf))/d;
  fi;

end );

InstallMethod(Value,"rational function: supply `one'",
  true,[IsPolynomialFunction,IsList,IsList],0,
function(rf,inds,vals)
  return Value(rf,inds,vals,FamilyObj(rf)!.oneCoefficient);
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
  return PolynomialByExtRepNC(FamilyObj(pol),
          LEAD_COEF_POL_IND_EXTREP(ExtRepPolynomialRatFun(pol),ind));
end);

#############################################################################
##
#M  PolynomialCoefficientsOfPolynomial(<pol>,<ind>)
##
InstallMethod(PolynomialCoefficientsOfPolynomial,"polynomial,integer",true,
  [IsPolynomialFunction and IsPolynomial,IsPosInt],0,
function(pol,ind)
local c,i;
  c:=POL_COEFFS_POL_EXTREP(ExtRepPolynomialRatFun(pol),ind);
  pol:=FamilyObj(pol);
  for i in [1..Length(c)] do
    if not IsBound(c[i]) then
      c[i]:=Zero(pol);
    else
      c[i]:=PolynomialByExtRepNC(pol,c[i]);
      IsLaurentPolynomial(c[i]);
    fi;
  od;
  return c;
end);

InstallOtherMethod(PolynomialCoefficientsOfPolynomial,"polynomial,indet",
  IsIdenticalObj,
  [IsPolynomialFunction and IsPolynomial,IsPolynomialFunction and IsPolynomial],0,
function(pol,ind)
  return PolynomialCoefficientsOfPolynomial(pol,
           IndeterminateNumberOfLaurentPolynomial(ind));
end);

#############################################################################
##
#M  ZeroCoefficientRatFun( <ratfun> )
##
InstallMethod(ZeroCoefficientRatFun,"via family",[IsPolynomialFunction],0,
  p->FamilyObj(p)!.zeroCoefficient);

#############################################################################
##
#F  ConstantInBaseRingPol(pol,ind)   remove indeterminate ind from polynomial
##
BindGlobal("ConstantInBaseRingPol",function(pol,ind)
local e;
  if IsPolynomialFunction(pol) and IsConstantRationalFunction(pol) and
    (not HasIndeterminateNumberOfUnivariateRationalFunction(pol) or
    IndeterminateNumberOfUnivariateRationalFunction(pol)=ind) then
    # constant polynomial represented as univariate: take coefficient
    e:=ExtRepPolynomialRatFun(pol);
    if Length(e)=0 then
      return ZeroCoefficientRatFun(pol);
    else
      return e[2];
    fi;
  fi;
  return pol;
end);


#############################################################################
##
#M  Discriminant(<pol>,<ind>)
##
InstallMethod(Discriminant,"poly,inum",true,
  [IsPolynomialFunction and IsPolynomial,IsPosInt],0,
function(f,ind)
local d,l;
  d:=DegreeIndeterminate(f,ind);
  l:=LeadingCoefficient(f,ind);
  if IsZero(l) then
    return l;
  fi;
  d:=(-1)^(d*(d-1)/2)*Resultant(f,Derivative(f,ind),ind)/l;
  return ConstantInBaseRingPol(d,ind);
end);

InstallOtherMethod(Discriminant,"poly,ind",true,
  [IsPolynomialFunction and IsPolynomial,IsPolynomialFunction and IsPolynomial],0,
function(pol,ind)
  return Discriminant(pol,IndeterminateNumberOfLaurentPolynomial(ind));
end);

#############################################################################
##
#M  Derivative(<pol>,<ind>)
##
# (this way around because we need the indeterminate
InstallOtherMethod(Derivative,"ratfun,inum",true,
  [IsPolynomialFunction,IsPosInt],0,
function(ratfun,ind)
local fam;
  fam:=CoefficientsFamily(FamilyObj(ratfun));
  return Derivative(ratfun,UnivariatePolynomialByCoefficients(fam,
                          [Zero(fam),One(fam)],ind));
end);

InstallOtherMethod(Derivative,"poly,ind",true,
  [IsPolynomialFunction and IsPolynomial,IsPolynomialFunction and IsPolynomial],0,
function(pol,ind)
local d,c,i;
  d:=Zero(pol);
  c:=PolynomialCoefficientsOfPolynomial(pol,ind);
  for i in [2..Length(c)] do
    d := d + (i-1) * c[i] * ind^(i-2);
  od;
  return d;
end);

InstallOtherMethod(Derivative,"ratfun,ind",true,
  [IsPolynomialFunction,IsPolynomialFunction and IsPolynomial],0,
function(ratfun,ind)
local num,den;
  num:=NumeratorOfRationalFunction(ratfun);
  den:=DenominatorOfRationalFunction(ratfun);
  return (Derivative(num,ind)*den-num*Derivative(den,ind))/(den^2);
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
    return PolynomialByExtRepNC(FamilyObj(p),f[1]);
  else
    return RationalFunctionByExtRepNC(FamilyObj(p),f[1],f[2]);
  fi;
end);

#############################################################################
##
#M  Resultant( <f>, <g>, <ind> )
##
InstallMethod(Resultant,"pol,pol,inum",IsFamFamX,
  [IsPolynomialFunction and IsPolynomial,IsPolynomialFunction and IsPolynomial,
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
  if n=DEGREE_ZERO_LAURPOL or m=DEGREE_ZERO_LAURPOL then
    return Zero(CoefficientsFamily(fam));
  fi;

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

    px:=LaurentPolynomialByExtRepNC(fam,fam!.oneCoefflist,1,ind);

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
  [IsPolynomialFunction and IsPolynomial,IsPolynomialFunction and IsPolynomial,
  IsPolynomialFunction and IsPolynomial],0,
function(a,b,ind)
  return Resultant(a,b,
           IndeterminateNumberOfLaurentPolynomial(ind));
end);


#############################################################################
##
#F  LeadingMonomialPosExtRep    position of leading monomial in external rep.
##                              list
##
InstallGlobalFunction(LeadingMonomialPosExtRep, function(fam,e,order)
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
#F  ConstituentsPolynomial
##
InstallGlobalFunction(ConstituentsPolynomial,
function(p)
  local fam, e, c, m, v, i;
  fam:=FamilyObj(p);
  e:=ExtRepPolynomialRatFun(p);
  c:=[];
  m:=[];
  v:=[];
  for i in [2,4..Length(e)] do
    Add(c,e[i]);
    Add(m,PolynomialByExtRepNC(fam,[ShallowCopy(e[i-1]),fam!.oneCoefficient]));
    UniteSet(v,e[i-1]{[1,3..Length(e[i-1])-1]});
  od;
  v:=List(v,i->PolynomialByExtRepNC(fam,[[i,1],fam!.oneCoefficient]));
  List(v,IsUnivariatePolynomial);
  return rec(coefficients:=c,
             monomials:=m,
             variables:=v);
end);


#####################################################################
#
# routines provide a simple multivariate factorization
# as in MCA exercise 16.10.
#
#  11-15-04,  WDJ and AH

# n is the number of terms in m. n1 is the number of variable occurring
# in each monomial term of m. returns the degrees of each variable in the
# monomial m.
BindGlobal("MVFactorDegreeMonomialTerm",function(m)
local degrees, e, n0, i, j, l, n1, n;
  e:=ExtRepPolynomialRatFun(m);
  n0:=Length(e);
  n:=Int(n0/2);
  degrees:=[];
  for i in [1..n] do
  l:=e[2*i-1];
  n1:=Length(l);
  for j  in [1..Int(n1/2)] do
    degrees:=Concatenation(degrees,[l[2*j]]);
  od;
  od;
  return degrees;
end);


BindGlobal("MVFactorKroneckerMap",function(f,vars,var,p)
# maps polys in x1,...,xn to polys in x
# induced by xi -> x^(p^(i-1))
local g;
  g:=Value(f,vars, List([1..Length(vars)],i->var[1]^(p^(i-1))));
  return g;
end);

BindGlobal("MVFactorInverseKroneckerMapUnivariate",function(g,varpow)
local coeffs,f,i;

  if not IsUnivariatePolynomial(g) then
    Error("this function assumes polynomial is univariate");
  fi;
  coeffs:=CoefficientsOfUnivariateLaurentPolynomial(g);
  coeffs:=ShiftedCoeffs(coeffs[1],coeffs[2]);
  f:=Zero(g);
  for i in [1..Length(coeffs)] do
    if not IsZero(coeffs[i]) then
      f:=f+coeffs[i]*varpow[i];
    fi;
  od;
  return f;
end);

InstallGlobalFunction(MultivariateFactorsPolynomial,function(R,f)
local cp, mons, L, T, perm, vars, nvars, F, R1, var, degrees, d, p,
      forig, cnt, vals, bv, bd, g, varpow, fam, fex, N, cand, ti,
      terms, div, ediv, r, ffactors, i, j, k;

# input: f is a poly in R=F[x1,...,xn]
# output: all divisors of f

  cp:=ConstituentsPolynomial(f);
  mons:=cp.monomials;
  # count variable frequencies
  L:=ListWithIdenticalEntries(
    Maximum(List(cp.variables,
      IndeterminateNumberOfUnivariateRationalFunction)),0);
  for i in mons do
    T:=ExtRepPolynomialRatFun(i)[1];
    for j in [1,3..Length(T)-1] do
      L[T[j]]:=L[T[j]]+T[j+1];
    od;
  od;
  T:=[1..Length(L)];
  SortParallel(L,T);
  T:=Reversed(T);
  L:=Reversed(L);
  if ForAny([1..Length(L)],i->L[i]>0 and L[T[i]]<>L[i]) then
    perm:=PermList(T)^-1;
    Info(InfoPoly,2,"Variable swap: ",perm);
    f:=OnIndeterminates(f,perm);
    cp:=ConstituentsPolynomial(f);
    mons:=cp.monomials;
  else
    perm:=(); # irrelevant swap
  fi;

  vars:=cp.variables;
  nvars:=Length(vars);
  F:=CoefficientsRing(R);
  R1:=PolynomialRing(F,1);
  var:=IndeterminatesOfPolynomialRing(R1);
  degrees:=List([1..Length(mons)],i->MVFactorDegreeMonomialTerm(mons[i]));
  d:=Maximum(Flat(degrees));
  p:=NextPrimeInt(d);
  p:=Maximum(d+1,2);

  forig:=f;

  # coefficient shift to remove duplicate roots
  cnt:=0;
  vals:=List(vars,i->Zero(F));
  bv:=vals;
  bd:=infinity;
  repeat
    if cnt>0 then
      vals:=List(vars,i->Random(F));
      f:=Value(forig,vars,List([1..nvars],i->vars[i]-vals[i]));
    fi;
    g:=MVFactorKroneckerMap(f,vars,var,p);
    cnt:=cnt+1;
    L:=DegreeOfUnivariateLaurentPolynomial(Gcd(g,Derivative(g)));
    if L<bd then
      bv:=vals;
      bd:=L;
    fi;
    Info(InfoPoly,3,"Trying shift: ",vals,": ",L);
  until cnt>DegreeOfUnivariateLaurentPolynomial(g) or L=0;
  if bv<>vals then
    vals:=bv;
    f:=Value(forig,vars,List([1..nvars],i->vars[i]-vals[i]));
    g:=MVFactorKroneckerMap(f,vars,var,p);
  fi;


  # prepare padic representations of powers
  L:=ListWithIdenticalEntries(nvars,0);
  varpow:=List([0..DegreeOfUnivariateLaurentPolynomial(g)],
                i->Concatenation(CoefficientsQadic(i,p),L){[1..nvars]});
  varpow:=List(varpow,i->Product(List([1..nvars],j->vars[j]^i[j])));

  L:=Factors(R1,g);
  Info(InfoPoly,1,"Factors of degrees ",
       List(L,DegreeOfUnivariateLaurentPolynomial));

  fam:=FamilyObj(f);
  fex:=ExtRepPolynomialRatFun(f);
  N:=Length(L);
  cand:=[1..N];
  for k in [1..QuoInt(N,2)] do
    T:=NrCombinations(cand,k);
    if T>100000 then
      Info(InfoWarning,1,
      "need to try ",T," combinations -- this might take very long");
    fi;
    T:=Combinations(cand,k);
    Info(InfoPoly,2,"Length ",k,": ",Length(T)," candidates");
    ti:=1;
    while ti<=Length(T) do;
      terms:=T[ti];
      div:=Product(L{terms});
      div:=MVFactorInverseKroneckerMapUnivariate(div,varpow);
      ediv:=ExtRepPolynomialRatFun(div);
      #if not IsOne(ediv[Length(ediv)]) then
      #  div:=div/ediv[Length(ediv)];
      #  ediv:=ExtRepPolynomialRatFun(div);
      #fi;
      # call the library routine used to test quotient of polynomials
      r:=QuotientPolynomialsExtRep(fam,fex,ediv);
      if r<>fail then
        fex:=r;
        f:=PolynomialByExtRepNC(fam,fex);
        Info(InfoPoly,1,"found factor ",terms," ",div," remainder ",f);
        ffactors:=MultivariateFactorsPolynomial(R,f);
        Add(ffactors,div);
        if ForAny(vals,i->not IsZero(i)) then
          ffactors:=List(ffactors,
                         i->Value(i,vars,List([1..nvars],j->vars[j]+vals[j])));
        fi;

        if not IsOne(perm) then
          ffactors:=List(ffactors,i->OnIndeterminates(i,perm^-1));
        fi;
        return ffactors;
      fi;
      ti:=ti+1;
    od;
  od;

  if ForAny(vals,i->not IsZero(i)) then
    f:=Value(f,vars,List([1..nvars],j->vars[j]+vals[j]));
  fi;

  if not IsOne(perm) then
    f:=OnIndeterminates(f,perm^-1);
  fi;
  return [f];
end);

#############################################################################
##
#M  Factors(<R>,<f> ) . .  factors of polynomial
##
InstallMethod(Factors,"multivariate, reduce to univariate case",IsCollsElms,
  [IsPolynomialRing,IsPolynomial],0,
function(R,f)
local cr, irf, i, opt, r,cp;

  if not HasIsUnivariateRationalFunction(f) and
    IsUnivariateRationalFunction(f) then
    return Factors(R,f);
  elif HasIsUnivariateRationalFunction(f) and
    IsUnivariateRationalFunction(f) then
    TryNextMethod(); # this is a multivariate method below
  fi;
  cr:=CoefficientsRing(R);
  irf:=IrrFacsPol(f);
  i:=PositionProperty(irf,i->i[1]=cr);
  if i<>fail then
    # if we know the factors,return
    return ShallowCopy(irf[i][2]);
  fi;

  opt:=ValueOption("factoroptions");
  PushOptions(rec(factoroptions:=rec())); # options do not hold for
                                          # subsequent factorizations
  if opt=fail then
    opt:=rec();
  fi;

  cp:=ConstituentsPolynomial(f);
  if not IsSubset(IndeterminatesOfPolynomialRing(R),cp.variables) then
    PopOptions();
    TryNextMethod();
  fi;

  r:=MultivariateFactorsPolynomial(R,f);
  if r=fail then
    PopOptions();
    TryNextMethod();
  fi;

  # convert into standard associates and sort
  r:=List(r,x -> StandardAssociate(R,x));
  Sort(r);

  if Length(r)>0 then
    # correct leading term
    r[1]:=r[1]*Quotient(R,f,Product(r));
  fi;

  # and return
  if not IsBound(opt.onlydegs) and not IsBound(opt.stopdegs) then
    StoreFactorsPol(cr,f,r);
    for i in r do
      StoreFactorsPol(cr,i,[i]);
    od;
  fi;
  PopOptions();
  return r;

end);

InstallMethod(Factors,"fallback error message",IsCollsElms,
  [IsPolynomialRing,IsPolynomial],-1,
function(R,p)
  Error("GAP currently cannot factor ",p," over ",R);
end);
