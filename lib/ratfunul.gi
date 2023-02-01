#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Andrew Solomon, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for rational functions that know that they
##  are univariate.
##

#############################################################################
##
#M  LaurentPolynomialByCoefficients( <fam>, <cofs>, <val>, <ind> )
##
InstallMethod( LaurentPolynomialByCoefficients, "with indeterminate",
  true, [ IsFamily, IsList, IsInt, IsInt ], 0,
function( fam, cofs, val, ind )
local lc;
  # construct a laurent polynomial

  lc:=Length(cofs);
  if lc>0 and not IsIdenticalObj(ElementsFamily(FamilyObj(cofs)),fam) then
    # try to fix
    Info(InfoWarning,1,
      "Convert coefficient list to get compatibility with family");
    cofs:=cofs*One(fam);
    if not IsIdenticalObj(ElementsFamily(FamilyObj(cofs)),fam) then
      # did not work
      TryNextMethod();
    fi;
  fi;
  fam:=RationalFunctionsFamily(fam);
  if lc>0 and (IsZero(cofs[1]) or IsZero(cofs[lc])) then
      cofs:=ShallowCopy(cofs); # always copy to avoid destroying list
      val:=val+RemoveOuterCoeffs(cofs,fam!.zeroCoefficient);
  fi;

  return LaurentPolynomialByExtRepNC(fam,cofs,val,ind);

end );

ITER_POLY_WARN:=true;

InstallMethod( LaurentPolynomialByCoefficients,
  "warn about iterated polynomials", true,
    [ IsFamily and HasCoefficientsFamily, IsList, IsInt, IsInt ], 0,
function( fam, cofs, val, ind )
  # catch algebraic extensions
  if ITER_POLY_WARN=true and not IsBound(fam!.primitiveElm)
    # also sc rings are fine.
    and not IsBound(fam!.moduli) then
    Info(InfoWarning,1,
      "You are creating a polynomial *over* a polynomial ring (i.e. in an");
    Info(InfoWarning,1,
      "iterated polynomial ring). Are you sure you want to do this?");
    Info(InfoWarning,1,
    "If not, the first argument should be the base ring, not a polynomial ring"
      );
    Info(InfoWarning,1,
    "Set ITER_POLY_WARN:=false; to remove this warning."
      );
  fi;
  TryNextMethod();
end);

#############################################################################
InstallOtherMethod( LaurentPolynomialByCoefficients, "fam, cof,val",true,
    [ IsFamily, IsList, IsInt ], 0,
function( fam, cofs, val )
    return LaurentPolynomialByCoefficients( fam, cofs, val, 1 );
end );

#############################################################################
##
#M  UnivariatePolynomialByCoefficients( <fam>, <cofs>, <ind> )
##


#############################################################################
InstallMethod( UnivariatePolynomialByCoefficients, "fam, cof,ind",true,
    [ IsFamily, IsList, IsPosInt ], 0,
function( fam, cofs, ind )
    return LaurentPolynomialByCoefficients( fam, cofs, 0, ind );
end );

#############################################################################
InstallOtherMethod( UnivariatePolynomialByCoefficients, "fam,cof",true,
    [ IsFamily, IsList ], 0,
function( fam, cofs )
    return LaurentPolynomialByCoefficients( fam, cofs, 0, 1 );
end );

#############################################################################
InstallMethod( UnivariatePolynomial, "ring,cof,indn",true,
    [ IsRing, IsRingElementCollection,IsPosInt ], 0,
function( ring, cofs,indn )
    return LaurentPolynomialByCoefficients( ElementsFamily(FamilyObj(ring)),
                                            cofs, 0, indn );
end );

#############################################################################
InstallOtherMethod( UnivariatePolynomial, "ring,cof",true,
    [ IsRing, IsRingElementCollection ], 0,
function( ring, cofs )
    return LaurentPolynomialByCoefficients( ElementsFamily(FamilyObj(ring)),
                                            cofs, 0, 1 );
end );

#############################################################################
InstallOtherMethod( UnivariatePolynomial, "ring,empty cof",true,
    [ IsRing, IsEmpty ], 0,
function( ring, cofs )
    return LaurentPolynomialByCoefficients( ElementsFamily(FamilyObj(ring)),
                                            cofs, 0, 1 );
end );

#############################################################################
InstallOtherMethod( UnivariatePolynomial, "ring,empty cof, indnr",true,
    [ IsRing, IsEmpty,IsObject ], 0,
function( ring, cofs,inum )
    return LaurentPolynomialByCoefficients( ElementsFamily(FamilyObj(ring)),
                                            cofs, 0, inum );
end );

#############################################################################
InstallOtherMethod( UnivariatePolynomial, "ring,cof,indpol",true,
    [ IsRing, IsRingElementCollection,IsUnivariateRationalFunction ], 0,
function( ring, cofs,ind )
    return LaurentPolynomialByCoefficients( ElementsFamily(FamilyObj(ring)),
                                            cofs, 0,
                    IndeterminateNumberOfUnivariateRationalFunction(ind) );
end );

#############################################################################
InstallMethod( CoefficientsOfUnivariatePolynomial, "use laurent coeffs",true,
    [ IsUnivariatePolynomial ], 0,
function(f);
  f:=CoefficientsOfLaurentPolynomial(f);
  return ShiftedCoeffs(f[1],f[2]);
end );

RedispatchOnCondition( CoefficientsOfUnivariatePolynomial, true,
    [ IsPolynomialFunction ], [ IsUnivariatePolynomial ], 0);

#############################################################################
##
#M  DegreeOfLaurentPolynomial( <laurent> )
##
InstallMethod( DegreeOfLaurentPolynomial,
    true,
    [ IsPolynomialFunction and IsLaurentPolynomial ],
    0,

function( obj )
    local   cofs;

    cofs := CoefficientsOfLaurentPolynomial(obj);
    if IsEmpty(cofs[1])  then
        return DEGREE_ZERO_LAURPOL;
    else
        return cofs[2] + Length(cofs[1]) - 1;
    fi;
end );

#############################################################################
##
#M  DegreeIndeterminate( pol, ind )
##
InstallOtherMethod(DegreeIndeterminate,"laurent,indetnr",true,
  [IsLaurentPolynomial,IsPosInt],0,
function(pol,ind)
local d;
  d:=DegreeOfLaurentPolynomial(pol);
  # unless constant: return 0 as we are in the wrong game
  if d>0 and IndeterminateNumberOfUnivariateRationalFunction(pol)<>ind then
    return 0;
  fi;
  return d;
end);

#############################################################################
##
#M  IsPolynomial(<laurpol>)
##
InstallMethod(IsPolynomial,"laurent rep.",true,
  [IsLaurentPolynomialDefaultRep],0,
function(f)
  return CoefficientsOfLaurentPolynomial(f)[2]>=0; # test valuation
end);

#############################################################################
##
#F  CIUnivPols( <upol>, <upol> ) test for common base ring and for
##                           common indeterminate of UnivariatePolynomials
InstallGlobalFunction( CIUnivPols, function(f,g)
local d,x;

  #if HasIndeterminateNumberOfLaurentPolynomial(f) and
  #  HasIndeterminateNumberOfLaurentPolynomial(g) then
  #  x:=IndeterminateNumberOfLaurentPolynomial(f);
  #  if x<>IndeterminateNumberOfLaurentPolynomial(g) then
  #    return fail;
  #  else
  #    return x;
  #  fi;
  #fi;

  if IsLaurentPolynomial(f) and IsLaurentPolynomial(g) then
    # is either polynomial constant? if yes we must permit different
    # indeterminate numbers
    d:=DegreeOfLaurentPolynomial(f);
    if d=0 or d=DEGREE_ZERO_LAURPOL then
      return IndeterminateNumberOfLaurentPolynomial(g);
    fi;
    x:=IndeterminateNumberOfLaurentPolynomial(f);
    d:=DegreeOfLaurentPolynomial(g);
    if d<>0 and d<>DEGREE_ZERO_LAURPOL and
       x<>IndeterminateNumberOfLaurentPolynomial(g) then
      return fail;
    fi;
    # all OK
    return x;
  fi;
  return fail;
end );

#############################################################################
##
#M  ExtRepNumeratorRatFun(<ulaurent>)
##
InstallMethod(ExtRepNumeratorRatFun,"laurent polynomial rep.",true,
  [IsLaurentPolynomialDefaultRep],0,
function(f)
local c;
  c:=CoefficientsOfLaurentPolynomial(f);
  return EXTREP_COEFFS_LAURENT(c[1],
    Maximum(0,c[2]), # negative will go into denominator
    IndeterminateNumberOfLaurentPolynomial(f),
    FamilyObj(f)!.zeroCoefficient);
end);

#############################################################################
##
#M  ExtRepDenominatorRatFun(<ulaurent>)
##
InstallMethod(ExtRepDenominatorRatFun,"laurent polynomial rep.",true,
  [IsLaurentPolynomialDefaultRep and IsRationalFunction],0,
function(obj)
local   cofs,  val,  ind,  quo;

    cofs := CoefficientsOfLaurentPolynomial(obj);
    if Length(cofs) = 0 then
        return [[], FamilyObj(obj)!.oneCoefficient];
    fi;
    val  := cofs[2];
    cofs := cofs[1];
    ind  := IndeterminateNumberOfUnivariateRationalFunction(obj);

    # This is to compute the denominator

    if val < 0  then
        quo := [ [ ind, -val ], FamilyObj(obj)!.oneCoefficient ];
    else
        quo := [ [],  FamilyObj(obj)!.oneCoefficient ];
    fi;

    return quo;

end);

#############################################################################
##
#M  One(<laurent>)
##
InstallMethod(OneOp,"univariate",true,
  [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
function(p)
local indn,fam;
  fam:=FamilyObj(p);
  indn := IndeterminateNumberOfUnivariateRationalFunction(p);
  if not IsBound(fam!.univariateOnePolynomials[indn]) then
    fam!.univariateOnePolynomials[indn]:=
      LaurentPolynomialByExtRepNC(fam,fam!.oneCoefflist,0,indn);
  fi;
  return fam!.univariateOnePolynomials[indn];
end);

# avoid the one of the family (which is not univariate!)
InstallMethod(One,"univariate",true,
  [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0, OneOp);

#############################################################################
##
#M  Zero(<laurent>)
##
InstallMethod(ZeroOp,"univariate",true,
  [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
function(p)
local indn,fam;
  fam:=FamilyObj(p);
  indn := IndeterminateNumberOfUnivariateRationalFunction(p);
  if not IsBound(fam!.univariateZeroPolynomials[indn]) then
    fam!.univariateZeroPolynomials[indn]:=
      LaurentPolynomialByExtRepNC(fam,[],0,indn);
  fi;
  return fam!.univariateZeroPolynomials[indn];

end);

# avoid the one of the family (which is not univariate!)
InstallMethod(Zero,"univariate",true,
  [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0, ZeroOp);

#############################################################################
##
#M  IndeterminateOfUnivariateRationalFunction( <laurent> )
##
InstallMethod( IndeterminateOfUnivariateRationalFunction,
  "use `IndeterminateNumber'",true,
  [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return LaurentPolynomialByExtRepNC(fam,
        [ FamilyObj(obj)!.oneCoefficient ],1,
        IndeterminateNumberOfUnivariateRationalFunction(obj) );
end );


# Arithmetic

#############################################################################
##
#M  AdditiveInverseOp( <laurent> )
##
InstallMethod( AdditiveInverseOp,"laurent polynomial",
    true, [ IsPolynomialFunction and IsLaurentPolynomial ], 0,
function( obj )
local   cofs,  indn;

  cofs := CoefficientsOfLaurentPolynomial(obj);
  indn := IndeterminateNumberOfUnivariateRationalFunction(obj);

  if Length(cofs[1])=0 then
    return obj;
  fi;

  return LaurentPolynomialByExtRepNC(FamilyObj(obj),
      AdditiveInverseOp(cofs[1]),cofs[2],indn);

end );

#############################################################################
##
#M  InverseOp( <laurent> )
##
InstallMethod( InverseOp,"try to express as laurent polynomial", true,
    [ IsPolynomialFunction and IsLaurentPolynomial ], 0,
function( obj )
local   cofs,  indn;

  indn := IndeterminateNumberOfUnivariateRationalFunction(obj);

  # this only works if we have only one coefficient
  cofs := CoefficientsOfLaurentPolynomial(obj);
  if 1 <> Length(cofs[1])  then
    TryNextMethod();
  fi;

  # invert the valuation
  return LaurentPolynomialByExtRepNC(FamilyObj(obj),
      [Inverse(cofs[1][1])], -cofs[2], indn );
end );

#############################################################################
##
#M  <laurent> * <laurent>
##
InstallMethod( \*, "laurent * laurent", IsIdenticalObj,
    [ IsPolynomialFunction and IsLaurentPolynomial,
      IsPolynomialFunction and IsLaurentPolynomial], 0, PRODUCT_LAURPOLS);

#############################################################################
##
#M  <laurent> + <laurent>
##
InstallMethod( \+, "laurent + laurent", IsIdenticalObj,
    [ IsPolynomialFunction and IsLaurentPolynomial,
      IsPolynomialFunction and IsLaurentPolynomial ], 0, SUM_LAURPOLS);

#############################################################################
##
#M  <laurent> - <laurent>
##
##  This is almost the same as `+'. However calling `AdditiveInverse' would
##  wrap up an intermediate polynomial which gets a bit expensive. So we do
##  almost the same here.
InstallMethod( \-, "laurent - laurent", IsIdenticalObj,
    [ IsPolynomialFunction and IsLaurentPolynomial,
      IsPolynomialFunction and IsLaurentPolynomial ], 0, DIFF_LAURPOLS);

#############################################################################
##
#M  <coeff>       * <laurent>
##
##
BindGlobal("ProdCoeffLaurpol",function( coef, laur )
local   fam, tmp;

  # multiply by zero gives the zero polynomial
  if IsZero(coef) then return Zero(laur);
  elif IsOne(coef) then return laur;fi;

  fam:=FamilyObj(laur);

  # construct the product and check the valuation in case zero divisors
  tmp := CoefficientsOfLaurentPolynomial(laur);
  return LaurentPolynomialByExtRepNC(fam,coef*tmp[1], tmp[2],
           IndeterminateNumberOfUnivariateRationalFunction(laur));
end );

InstallMethod( \*, "coeff * laurent", IsCoeffsElms,
  [ IsRingElement, IsUnivariateRationalFunction and IsLaurentPolynomial ], 0,
  ProdCoeffLaurpol);

InstallMethod( \*, "laurent * coeff", IsElmsCoeffs,
  [ IsUnivariateRationalFunction and IsLaurentPolynomial,IsRingElement ], 0,
  function(l,c) return ProdCoeffLaurpol(c,l);end);


#############################################################################
##
#M  <coeff>       + <laurent>
##
##  This method is  installed for all  rational functions because it does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.   The sum is defined  in all
##  three cases.
##
BindGlobal("SumCoeffLaurpol", function( coef, laur )
local   fam,zero,  tmp,  indn,  val,  sum,  i;

  if IsZero(coef) then return laur;fi;

  indn := IndeterminateNumberOfUnivariateRationalFunction(laur);

  fam:=FamilyObj(laur);
  zero := fam!.zeroCoefficient;
  tmp  := CoefficientsOfLaurentPolynomial(laur);
  val  := tmp[2];

  # if coef is trivial return laur
  if coef = zero  then
      return laur;

  # the polynomial is trivial
  elif 0 = Length(tmp[1])  then
      # we create, no problem occurs
      return LaurentPolynomialByExtRepNC(fam, [coef], 0, indn );

  # the constant is present
  elif val <= 0 and 0 < val + Length(tmp[1])  then
      sum := ShallowCopy(tmp[1]);
      i:=1-val;
      if (i=1 or i=Length(sum)) and sum[i]+coef=fam!.zeroCoefficient then
        # be careful if cancellation happens at an end
        sum[i]:=fam!.zeroCoefficient;
        val:=val+RemoveOuterCoeffs(sum,fam!.zeroCoefficient);
      else
        # no cancellation in first place
        sum[i] := coef + sum[i];
      fi;
      return LaurentPolynomialByExtRepNC(fam, sum, val, indn );

  # every coefficients has a negative exponent
  elif val + Length(tmp[1]) <= 0  then
      sum := ShallowCopy(tmp[1]);
      for i  in [ Length(sum)+1 .. -val ]  do
          sum[i] := zero;
      od;
      sum[1-val] := coef;
      # we add at the end, no problem occurs
      return LaurentPolynomialByExtRepNC(fam, sum, val, indn );

  # every coefficients has a positive exponent
  else
      sum := [coef];
      for i  in [ 2 .. val ]  do
          sum[i] := zero;
      od;
      Append( sum, tmp[1] );
      # we add in the first position, no problem occurs
      return LaurentPolynomialByExtRepNC(fam, sum, 0, indn );

  fi;
end );

# test whether family b occurs anywhere as a coefficients family of a.
BindGlobal("CoefficientsFamilyEmbedded",function(a,b)
  while HasCoefficientsFamily(a) do
    a:=CoefficientsFamily(a);
    if a=b then
      return true;
    fi;
  od;
  return false;
end);

InstallMethod( \+, "coeff(embed) + laurent", true,
    [ IsRingElement, IsUnivariateRationalFunction and IsLaurentPolynomial ], 0,
function(c,l)
  if IsRat(c) #natural map from rationals into arbitrary rings
    or # Adding elements of a smaller coefficient ring that is naturally embedded
     CoefficientsFamilyEmbedded(FamilyObj(l),FamilyObj(c))
    then
    return SumCoeffLaurpol(c*FamilyObj(l)!.oneCoefficient,l);
  else
    TryNextMethod();
  fi;
end);

InstallMethod( \+, "laurent + coeff(embed)", true,
    [ IsUnivariateRationalFunction and IsLaurentPolynomial, IsRingElement ], 0,
function(l,c)
  if IsRat(c) #natural map from rationals into arbitrary rings
    or # Adding elements of a smaller coefficient ring that is naturally embedded
     CoefficientsFamilyEmbedded(CoefficientsFamily(FamilyObj(l)),FamilyObj(c))
    then
    return SumCoeffLaurpol(c*FamilyObj(l)!.oneCoefficient,l);
  else
    TryNextMethod();
  fi;
end);

# these should be ranked higher than the previous two
InstallMethod( \+, "coeff + laurent", IsCoeffsElms,
    [ IsRingElement, IsUnivariateRationalFunction and IsLaurentPolynomial ], 0,
    SumCoeffLaurpol);

InstallMethod( \+, "laurent + coeff", IsElmsCoeffs,
    [ IsUnivariateRationalFunction and IsLaurentPolynomial, IsRingElement ], 0,
    function(l,c) return SumCoeffLaurpol(c,l); end);


#############################################################################
##
#F  QuotRemLaurpols(left,right,mode)
##
InstallGlobalFunction(QuotRemLaurpols,function(f,g,mode)
local fam,indn,val,q,fc,gc;
  fam:=FamilyObj(f);
  indn := CIUnivPols(f,g); # use to get the indeterminate
  if indn=fail then
    return fail; # can't do anything
  fi;
  f:=CoefficientsOfLaurentPolynomial(f);
  g:=CoefficientsOfLaurentPolynomial(g);
  if Length(g[1])=0 then
    return fail; # cannot divide by 0
  fi;
  if f[2]>0 then
    fc:=ShiftedCoeffs(f[1],f[2]);
  else
    fc:=ShallowCopy(f[1]);
  fi;
  if g[2]>0 then
    gc:=ShiftedCoeffs(g[1],g[2]);
  else
    gc:=ShallowCopy(g[1]);
  fi;

  q:=QUOTREM_LAURPOLS_LISTS(fc,gc);
  fc:=q[2];
  q:=q[1];

  if mode=1 or mode=4 then
    if mode=4 and ForAny(fc,i->not IsZero(i)) then
      return fail;
    fi;
    val:=RemoveOuterCoeffs(q,fam!.zeroCoefficient);
    q:=LaurentPolynomialByExtRepNC(fam,q,val,indn);
    return q;
  elif mode=2 then
    val:=RemoveOuterCoeffs(fc,fam!.zeroCoefficient);
    f:=LaurentPolynomialByExtRepNC(fam,fc,val,indn);
    return f;
  elif mode=3 then
    val:=RemoveOuterCoeffs(q,fam!.zeroCoefficient);
    q:=LaurentPolynomialByExtRepNC(fam,q,val,indn);
    val:=RemoveOuterCoeffs(fc,fam!.zeroCoefficient);
    f:=LaurentPolynomialByExtRepNC(fam,fc,val,indn);
    return [q,f];
  fi;

end);

#############################################################################
##
#M  <unilau> / <unilau> (if possible)
##
##  While w rely for ordinary rat. fun. on a*Inverse(b) we do not want this
##  for laurent polynomials, as the inverse would have to be represented as
##  a rational function, not a laurent polynomial.
InstallMethod(\/,"upol/upol",true,
  [IsUnivariatePolynomial,IsUnivariatePolynomial],2,
function(a,b)
local q;
  q:=QuotRemLaurpols(a,b,4);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);

#############################################################################
##
#M  QuotientRemainder( [<pring>,] <upol>, <upol> )
##
InstallMethod(QuotientRemainder,"laurent, ring",IsCollsElmsElms,
  [IsPolynomialRing,IsUnivariatePolynomial,
                    IsUnivariatePolynomial],0,
function (R,f,g)
local q;
  q:=QuotRemLaurpols(f,g,3);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);

RedispatchOnCondition(QuotientRemainder,IsCollsElmsElms,
  [IsPolynomialRing,IsRationalFunction,IsRationalFunction],
                [,IsUnivariatePolynomial,IsUnivariatePolynomial],0);

InstallOtherMethod(QuotientRemainder,"laurent",IsIdenticalObj,
                [IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function (f,g)
local q;
  q:=QuotRemLaurpols(f,g,3);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);

RedispatchOnCondition(QuotientRemainder,IsIdenticalObj,
  [IsRationalFunction,IsRationalFunction],
  [IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#############################################################################
##
#M  Quotient( [<pring>], <upol>, <upol> )
##
InstallMethod(Quotient,"laurent, ring",IsCollsElmsElms,[IsPolynomialRing,
                IsLaurentPolynomial,IsLaurentPolynomial],0,
function (R,f,g)
  return Quotient(f,g);
end);

InstallOtherMethod(Quotient,"laurent",IsIdenticalObj,
  [IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function (f,g)
  return QuotRemLaurpols(f,g,4);
end);


RedispatchOnCondition(Quotient,IsIdenticalObj,
  [IsLaurentPolynomial,IsLaurentPolynomial],
  [IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#############################################################################
##
#M  QuotientMod( <pring>, <upol>, <upol>, <upol> )
##
BIND_GLOBAL("QUOMOD_UPOLY",function (r,s,m)
local f,g,h,fs,gs,hs,q,t;
    f := s;  fs := 1;
    g := m;  gs := 0;
    while g <> Zero(g) do
        t := QuotientRemainder(f,g);
        h := g;          hs := gs;
        g := t[2];       gs := fs - t[1]*gs;
        f := h;          fs := hs;
    od;
    q:=QuotRemLaurpols(r,f,4);
    if q = fail  then
        return fail;
    else
        return (fs*q) mod m;
    fi;
end);

InstallMethod(QuotientMod,"laurent,ring",IsCollsElmsElmsElms,
  [IsRing,IsUnivariatePolynomial,IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function (R,r,s,m)
  return QUOMOD_UPOLY(r,s,m);
end);

RedispatchOnCondition(QuotientMod,IsCollsElmsElmsElms,
  [IsRing,IsLaurentPolynomial,IsLaurentPolynomial,IsLaurentPolynomial],
  [,IsUnivariatePolynomial,IsUnivariatePolynomial,IsUnivariatePolynomial],0);

InstallOtherMethod(QuotientMod,"laurent",IsFamFamFam,
  [IsUnivariatePolynomial,IsUnivariatePolynomial,IsUnivariatePolynomial],0,
  QUOMOD_UPOLY);

RedispatchOnCondition(QuotientMod,IsFamFamFam,
  [IsLaurentPolynomial,IsLaurentPolynomial,IsLaurentPolynomial],
  [IsUnivariatePolynomial,IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#############################################################################
##
#M  PowerMod( <pring>, <upol>, <exp>, <upol> )  . . . . power modulo
##
BindGlobal("POWMOD_UPOLY",function(g,e,m)
local val,brci,fam;

  brci:=CIUnivPols(g,m);
  if brci=fail then TryNextMethod();fi;

  fam:=FamilyObj(g);
  # if <m> is of degree zero return the zero polynomial
  if DegreeOfLaurentPolynomial(m) = 0  then
    return Zero(g);

  # if <e> is zero return one
  elif e = 0  then
    return One(g);
  fi;

  # reduce polynomial
  g:=g mod m;

  # and invert if necessary
  if e < 0  then
    g := QuotientMod(One(g),g,m);
    if g = fail  then
      Error("<g> must be invertible module <m>");
    fi;
    e := -e;
  fi;

  g:=CoefficientsOfLaurentPolynomial(g);
  m:=CoefficientsOfLaurentPolynomial(m);

  g:=ShiftedCoeffs(g[1],g[2]);
  m:=ShiftedCoeffs(m[1],m[2]);

  g:=PowerModCoeffs(g,Length(g),e,m,Length(m));
  if Length(g)>0 and (g[1]=fam!.zeroCoefficient or
             g[Length(g)]=fam!.zeroCoefficient) then
      g:=ShallowCopy(g);
      val:=RemoveOuterCoeffs(g,fam!.zeroCoefficient);
  else
      val := 0;
  fi;
  g:=LaurentPolynomialByExtRepNC(fam,g,val,brci);
  return g;
end);

InstallMethod(PowerMod,"laurent,ring ",IsCollsElmsXElms,
   [IsPolynomialRing,IsUnivariatePolynomial,IsInt,IsUnivariatePolynomial],0,
function(R,g,e,m)
  return POWMOD_UPOLY(g,e,m);
end);

RedispatchOnCondition(PowerMod,IsCollsElmsXElms,
   [IsPolynomialRing,IsLaurentPolynomial,IsInt,IsLaurentPolynomial],
   [,IsUnivariatePolynomial,,IsUnivariatePolynomial],0);

InstallOtherMethod(PowerMod,"laurent",IsFamXFam,
   [IsUnivariatePolynomial,IsInt,IsUnivariatePolynomial],0,POWMOD_UPOLY);

RedispatchOnCondition(PowerMod,IsFamXFam,
   [IsLaurentPolynomial,IsInt,IsLaurentPolynomial],
   [IsUnivariatePolynomial,,IsUnivariatePolynomial],0);

#############################################################################
##
#M  \=( <upol>, <upol> )  comparison
##
InstallMethod(\=,"laurent",IsIdenticalObj,
  [IsLaurentPolynomial,IsLaurentPolynomial],0,
function(a,b)
local ac,bc;
  ac:=CoefficientsOfLaurentPolynomial(a);
  bc:=CoefficientsOfLaurentPolynomial(b);
  if ac<>bc then
    return false;
  fi;
  # is the indeterminate important?
  if (Length(ac[1])>1 or (Length(ac[1])>0 and ac[2]<>0))
    and IndeterminateNumberOfLaurentPolynomial(a)<>
     IndeterminateNumberOfLaurentPolynomial(b) then
    return false;
  fi;
  return true;
end);

#############################################################################
##
#M  \<( <upol>, <upol> )  comparison
##
InstallMethod(\<,"Univariate Polynomials",IsIdenticalObj,
              [IsLaurentPolynomial,IsLaurentPolynomial],0,
function(a,b)
local ac,bc,l,m,z,da,db;
  ac:=CoefficientsOfLaurentPolynomial(a);
  bc:=CoefficientsOfLaurentPolynomial(b);

  # we have problems if they have (truly) different indeterminate numbers
  # (i.e.: both are not constant and the indnums differ
  if (ac[2]<>0 or Length(ac[1])>1) and (bc[2]<>0 or Length(bc[1])>1) and
    IndeterminateNumberOfLaurentPolynomial(a)<>
     IndeterminateNumberOfLaurentPolynomial(b) then
    TryNextMethod();
  fi;

  da:=Length(ac[1])+ac[2];
  db:=Length(bc[1])+bc[2];

  if da=db then
    # the total length is the same. We do not need to care about shift
    # factors!
    a:=ac[1];b:=bc[1];
    l:=Length(a);
    m:=Length(b);
    while l>0 and m>0 do
      if a[l]<b[m] then
        return true;
      elif a[l]>b[m] then
        return false;
      fi;
      l:=l-1;m:=m-1;
    od;
    # all the coefficients were the same. So we have to compare with a zero
    # that would have been shifted in
    if l>0 then
      z:=Zero(a[l]);
      # we don't need a `l>0' condition, because ending zeroes were shifted
      # out initially
      while a[l]=z do
        l:=l-1;
      od;
      return a[l]<z;
    elif m>0 then
      z:=Zero(b[m]);
      # we don't need a `m>0' condition, because ending zeroes were shifted
      # out initially
      while b[m]=z do
        m:=m-1;
      od;
      return b[m]>z;
    else
      # they are the same
      return false;
    fi;
  else
    # compare the degrees
    return da<db;
  fi;
end);

#############################################################################
##
#F  RandomPol( <fam>, <deg> [,<inum>] )
##
InstallGlobalFunction(RandomPol,function(arg)
local dom,deg,inum,i,c;
  dom:=arg[1];
  deg:=arg[2];
  if Length(arg)=3 then
    inum:=arg[3];
  else
    inum:=1;
  fi;
  c:=[];
  for i in [0..deg] do
    Add(c,Random(dom));
  od;
  while c[deg+1]=Zero(dom) do
    c[deg+1]:=Random(dom);
  od;
  return LaurentPolynomialByCoefficients(FamilyObj(c[1]),c,0,inum);
end);

#############################################################################
##
#M  LeadingCoefficient( <upol> )
##
InstallMethod(LeadingCoefficient,"laurent",true,[IsLaurentPolynomial],0,
function(f)
local fam;
  fam:=FamilyObj(f);
  f:=CoefficientsOfLaurentPolynomial(f);
  if Length(f[1])=0 then
    return fam!.zeroCoefficient;
  else
    return f[1][Length(f[1])];
  fi;
end);

#############################################################################
##
#F  LeadingMonomial . . . . . . . . . . . for a univariate laurent polynomial
##
InstallMethod( LeadingMonomial,"for a univariate laurent polynomial", true,
        [ IsLaurentPolynomial ], 0,
  p -> [ IndeterminateNumberOfLaurentPolynomial( p),
         DegreeOfLaurentPolynomial( p ) ]);

#############################################################################
##
#M  EuclideanDegree( <pring>, <upol> )
##
InstallOtherMethod(EuclideanDegree,"univariate,ring",IsCollsElms,
              [IsPolynomialRing,IsUnivariatePolynomial],0,
function(R,a)
  return DegreeOfLaurentPolynomial(a);
end);

InstallOtherMethod(EuclideanDegree,"univariate",true,
              [IsUnivariatePolynomial],0,DegreeOfLaurentPolynomial);

InstallOtherMethod(EuclideanDegree,"laurent,ring",IsCollsElms,
  [IsPolynomialRing,IsLaurentPolynomial],0,
function(R,a)
  return DegreeOfLaurentPolynomial(a);
end);

InstallOtherMethod(EuclideanDegree,"laurent",true,
  [IsLaurentPolynomial],0,DegreeOfLaurentPolynomial);

#############################################################################
##
#M  EuclideanRemainder( <pring>, <upol>, <upol> )
##
BindGlobal("MOD_UPOLY",function(a,b)
local q;
  q:=QuotRemLaurpols(a,b,2);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);

InstallOtherMethod(EuclideanRemainder,"laurent,ring",IsCollsElmsElms,
          [IsPolynomialRing,IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function(R,a,b)
  return MOD_UPOLY(a,b);
end);

RedispatchOnCondition(EuclideanRemainder,IsCollsElmsElms,
  [IsPolynomialRing,IsLaurentPolynomial,IsLaurentPolynomial],
  [,IsUnivariatePolynomial,IsUnivariatePolynomial],0);

InstallOtherMethod(EuclideanRemainder,"laurent",IsIdenticalObj,
            [IsUnivariatePolynomial,IsUnivariatePolynomial],0,MOD_UPOLY);

RedispatchOnCondition(EuclideanRemainder,IsIdenticalObj,
  [IsLaurentPolynomial,IsLaurentPolynomial],
  [IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#############################################################################
##
#M  \mod( <upol>, <upol> )
##
InstallMethod(\mod,"laurent",IsIdenticalObj,
              [IsUnivariatePolynomial,IsUnivariatePolynomial],0,MOD_UPOLY);

RedispatchOnCondition(\mod,IsIdenticalObj,
        [IsLaurentPolynomial,IsLaurentPolynomial],
        [IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#T use different coeffs gcd methods depending on base ring
InstallGlobalFunction(GcdCoeffs,GCD_COEFFS);

#############################################################################
##
#M  GcdOp( <pring>, <upol>, <upol> )  . . . . . .  for univariate polynomials
##
BindGlobal("GCD_UPOLY",function(f,g)
local gcd,val,brci,fam,fc,gc;

  brci:=CIUnivPols(f,g);
  fam:=FamilyObj(f);
  if brci=fail then TryNextMethod();fi;

  fc:=CoefficientsOfLaurentPolynomial(f);
  gc:=CoefficientsOfLaurentPolynomial(g);

  # special case zero polynomial
  if IsEmpty(fc[1]) then
    return g;
  elif IsEmpty(gc[1]) then
    return f;
  fi;

  # remove common x^i term
  val:=Minimum(fc[2],gc[2]);
  # the gcd cannot contain any further x^i parts, we removed them all!
  gcd:=GcdCoeffs(fc[1],gc[1]);

  # return the gcd
  val:=val+RemoveOuterCoeffs(gcd,fam!.zeroCoefficient);
  return LaurentPolynomialByExtRepNC(fam,gcd,val,brci);
end);

InstallRingAgnosticGcdMethod("univariate polynomials, coeff list",
  IsCollsElmsElms,IsIdenticalObj,[IsEuclideanRing,IsPolynomial,IsPolynomial],0,
  GCD_UPOLY);

RedispatchOnCondition( GcdOp,IsCollsElmsElms,
  [IsEuclideanRing, IsRationalFunction,IsRationalFunction],
  [, IsUnivariatePolynomial,IsUnivariatePolynomial],0);

RedispatchOnCondition( GcdOp,IsIdenticalObj,
  [IsRationalFunction,IsRationalFunction],
  [IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#############################################################################
##
#M  StandardAssociateUnit( <pring>, <lpol> )
##
InstallMethod(StandardAssociateUnit,"laurent",
  IsCollsElms,[IsPolynomialRing, IsLaurentPolynomial],0,
function(R,f)
  # get standard associate of leading term
  return StandardAssociateUnit(CoefficientsRing(R), LeadingCoefficient(f)) * One(R);
end);

#############################################################################
##
#M  Derivative( <upol> )
##
InstallOtherMethod(Derivative,"Laurent Polynomials",true,
                [IsLaurentPolynomial],0,
function(f)
local d,i,ind,one,iF;

  ind := [CoefficientsFamily(FamilyObj(f)),
           IndeterminateNumberOfUnivariateRationalFunction(f)];
  one:=FamilyObj(f)!.oneCoefficient;
  d:=CoefficientsOfLaurentPolynomial(f);
  if Length(d[1])=0 then
    # special case: Derivative of 0-Polynomial
    return f;
  fi;
  f:=d;
  d:=[];
  iF:=Zero(one);
  if f[2]>0 then
    for i in [1..f[2]] do iF:=iF+one; od;
  elif f[2]<0 then
    for i in [1..-f[2]] do iF:=iF+one; od;
  fi;
  for i in [1..Length(f[1])]  do
    d[i] := iF*f[1][i];
    iF:=iF+one;
  od;
  return LaurentPolynomialByCoefficients(ind[1],d,f[2]-1,ind[2]);
end);

RedispatchOnCondition(Derivative,true,
  [IsPolynomial],[IsLaurentPolynomial],0);

InstallOtherMethod(Derivative,"uratfun",true,
  [IsUnivariateRationalFunction],0,
function(ratfun)
local num,den,R,cf,pow,dr;
  # try to be good for the case of iterated derivatives by using if the
  # denominator is a power
  num:=NumeratorOfRationalFunction(ratfun);
  den:=DenominatorOfRationalFunction(ratfun);
  R:=CoefficientsRing(DefaultRing([den]));
  cf:=Collected(Factors(den));
  pow:=Gcd(List(cf,x->x[2]));
  if pow>1 then
    dr:=Product(List(cf,x->x[1]^(x[2]/pow))); # root
  else
    dr:=den;
  fi;
  #cf:=(Derivative(num)*dr-num*pow*Derivative(dr))/dr^(pow+1);
  num:=Derivative(num)*dr-num*pow*Derivative(dr);
  den:=dr^(pow+1);
  if IsOne(Gcd(num,dr)) then
    # avoid cancellation
    num:=CoefficientsOfUnivariateLaurentPolynomial(num);
    den:=CoefficientsOfUnivariateLaurentPolynomial(den);
    cf:=UnivariateRationalFunctionByExtRepNC(FamilyObj(ratfun),
      num[1],den[1],num[2]-den[2],
        IndeterminateNumberOfUnivariateRationalFunction(ratfun));
    # maintain factorization of denominator
    StoreFactorsPol(R,DenominatorOfRationalFunction(cf),
      ListWithIdenticalEntries(pow+1,dr));
  else
    cf:=num/den; # cancellation
  fi;
  return cf;
  #return (Derivative(num)*den-num*Derivative(den))/(den^2);
end);

RedispatchOnCondition(Derivative,true,
  [IsPolynomial],[IsUnivariateRationalFunction],0);


InstallGlobalFunction(TaylorSeriesRationalFunction,function(f,at,deg)
local t,i,x;
  if not (IsUnivariateRationalFunction(f) and deg>=0) then
    Error("function is not univariate pol, or degree negative");
  fi;
  x:=IndeterminateOfUnivariateRationalFunction(f);
  t:=Zero(f);
  for i in [0..deg] do
    if i>0 then
      f:=Derivative(f);
    fi;
    t:=t+Value(f,at)*(x-at)^i/Factorial(i);
  od;
  return t;
end);

#############################################################################
##
#F  Discriminant( <f> ) . . . . . . . . . . . . discriminant of polynomial f
##
InstallMethod( Discriminant, "univariate", true, [IsUnivariatePolynomial], 0,
function(f)
local d;
  # the discriminant is \prod_i\prod_{j\not= i}(\alpha_i-\alpha_j), but
  # to avoid chaos with symmetric polynomials, we better compute it as
  # the resultant of f and f'
  d:=DegreeOfLaurentPolynomial(f);
  d:=(-1)^(d*(d-1)/2)*Resultant(f,Derivative(f),
    IndeterminateNumberOfLaurentPolynomial(f))/LeadingCoefficient(f);
  return ConstantInBaseRingPol(d,IndeterminateNumberOfLaurentPolynomial(f));
end);

RedispatchOnCondition(Discriminant,true,
  [IsRationalFunction],[IsUnivariatePolynomial],0);

#############################################################################
##
#M  Value( <upol>, <elm>, <one> )
##
InstallOtherMethod( Value,"Laurent, ring element, and mult. neutral element",
    true, [ IsLaurentPolynomial, IsRingElement, IsRingElement ], 0,
function( f, x, one )
local val, i,e;
  val:= Zero( one );
  f:= CoefficientsOfLaurentPolynomial( f );
  i:= Length( f[1] );
  while 0 < i do
    e:=1;
    while 0<i and IsZero(f[1][i]) do
      e:=e+1;
      i:=i-1;
    od;
    if e>1 then
      val:= val * x^e + one * f[1][i];
    else
      val:= val * x + one * f[1][i];
    fi;
    i:=i-1;
  od;
  if 0 <> f[2] then
    val:= val * x^f[2];
  fi;
  return val;
end );

InstallOtherMethod( Value,"univariate rational function",
    true, [ IsUnivariateRationalFunction, IsRingElement, IsRingElement ], 0,
function( f, x, one )
local val, i,j;
  val:= [Zero( one ),Zero(one)];
  f:= CoefficientsOfUnivariateRationalFunction( f );
  for j in [1,2] do
    i:= Length( f[j] );
    while 0 < i do
      val[j]:= val[j] * x + one * f[j][i];
      i:= i-1;
    od;
  od;
  if  IsZero(val[2]) then
    Error("Denominator evaluates as zero");
  fi;
  val:=val[1]/val[2];
  if 0 <> f[3] then
    val:= val * x^f[3];
  fi;
  return val;
end );

#############################################################################
##
#M  Value( <upol>, <elm> )
##
InstallOtherMethod(Value,"supply `one'",true,
  [IsUnivariateRationalFunction,IsRingElement],0,
function(f,x)
  return Value(f,x,One(x));
end);

RedispatchOnCondition(Value,true,[IsPolynomialFunction,IsRingElement],
  [IsUnivariateRationalFunction,IsRingElement],0);

# print coeff list f.
BindGlobal("StringUnivariateLaurent",function(fam,cofs,val,name)
  local str,zero,one,mone,i,c,lc,s;
  str:="";
  zero := fam!.zeroCoefficient;
  one  := fam!.oneCoefficient;
  mone := -one;

  if IsInt(name) then # passed as indeterminate number
    if HasIndeterminateName(fam,name) then
      name:=IndeterminateName(fam,name);
    else
      name:=Concatenation("x_",String(name));
    fi;
  fi;

  if Length(cofs)=0 then
    return String(zero);
  fi;
  lc:=Length(cofs);
  if cofs[lc] = zero then
    # assume that there is at least one non-zero coefficient
    repeat
      lc:=lc-1;
    until cofs[lc]<>zero;
  fi;
  for i  in [ lc,lc-1..1 ]  do
    if cofs[i] <> zero  then

      # print a '+' if necessary
      c := "*";
      if i <lc  then
        if IsRat(cofs[i])  then
          if cofs[i] = one  then
            Append(str,"+" );
            c:="";
          elif cofs[i]>0  then
            Append(str,"+");
            Append(str,String(cofs[i]));
          elif cofs[i]=mone  then
            Append(str,"-");
            c:="";
          else
            Append(str,String(cofs[i]));
          fi;
        elif cofs[i]=one  then
          Append(str,"+");
          c:="";
        elif cofs[i]=mone  then
          Append(str,"-");
          c:="";
        else
          Append(str,"+");
          s:=String(cofs[i]);
          if '+' in s or '-' in s then
            s:=Concatenation("(",s,")");
          fi;
          Append(str,s);
        fi;
      elif cofs[i]=one  then
        c:="";
    elif cofs[i]=mone  then
        Append(str,"-");
        c:="";
      else
        s:=String(cofs[i]);
        if not IsRat(cofs[i]) and ('+' in s or '-' in s) then
          s:=Concatenation("(",s,")");
        fi;
        Append(str,s);
      fi;
      if i+val <> 1  then
        Append(str,c);
        Append(str,name);
        if i+val <> 2  then
          Append(str,"^");
          Append(str,String( i+val-1 ));
        fi;
      elif cofs[i] = one  then
        Append(str,String(one));
      elif cofs[i] = mone  then
        Append(str,String(one));
      fi;
    fi;
  od;
  return str;
end);

#############################################################################
##
#M  PrintObj( <uni-laurent> )
##
##  This method is installed for all  rational functions because it  does not
##  matter if one is  in a 'RationalFunctionsFamily',  a 'LaurentPolynomials-
##  Family', or a 'UnivariatePolynomialsFamily'.
##
InstallMethod( PrintObj,"laurent polynomial",true,[IsLaurentPolynomial],0,
function( f )
local c;
  c:=CoefficientsOfLaurentPolynomial(f);
  Print(StringUnivariateLaurent(FamilyObj(f),
    c[1],c[2],
    IndeterminateNumberOfLaurentPolynomial(f)));
end);

InstallMethod( String,"laurent polynomial",true,[IsLaurentPolynomial],0,
function( f )
local c;
  c:=CoefficientsOfLaurentPolynomial(f);
  return StringUnivariateLaurent(FamilyObj(f),
    c[1],c[2],
    IndeterminateNumberOfLaurentPolynomial(f));
end);

# univariate rational functions

#############################################################################
##
#M  UnivariateRationalFunctionByCoefficients( <fam>, <cofs>, <denom-cofs>, <val>, <ind> )
##
InstallMethod( UnivariateRationalFunctionByCoefficients,
  "with indeterminate", true,
    [ IsFamily, IsList, IsList, IsInt, IsInt ], 0,
function( fam, cofs,dc, val, ind )
  # construct a laurent polynomial

  fam:=RationalFunctionsFamily(fam);
  if Length(cofs)>0 and (IsZero(cofs[1]) or IsZero(cofs[Length(cofs)])) then
    if not IsMutable(cofs) then
      cofs:=ShallowCopy(cofs);
    fi;
    val:=val+RemoveOuterCoeffs(cofs,fam!.zeroCoefficient);
  fi;
  if Length(dc)>0 and (IsZero(dc[1]) or IsZero(dc[Length(dc)])) then
    if not IsMutable(dc) then
      dc:=ShallowCopy(dc);
    fi;
    val:=val-RemoveOuterCoeffs(dc,fam!.zeroCoefficient);
  fi;

  return UnivariateRationalFunctionByExtRepNC(fam,cofs,dc,val,ind);

end );

#############################################################################
InstallOtherMethod( UnivariateRationalFunctionByCoefficients,
  "fam, ncof,dcof,val",true,
    [ IsFamily, IsList,IsList, IsInt ], 0,
function( fam, nc,dc, val )
    return UnivariateRationalFunctionByCoefficients( fam, nc,dc, val, 1 );
end );

InstallMethod( PrintObj,"univar",true,[IsUnivariateRationalFunction],0,
function( f )
local fam,ind,nv,dv;
  fam := FamilyObj(f);
  ind := IndeterminateNumberOfLaurentPolynomial(f);
  f   := CoefficientsOfUnivariateRationalFunction(f);
  if f[3]>=0 then
    nv:=f[3];
    dv:=0;
  else
    nv:=0;
    dv:=-f[3];
  fi;
  Print("(",StringUnivariateLaurent(fam,f[1],nv,ind),")/(",StringUnivariateLaurent(fam,f[2],dv,ind),")");
end);

InstallMethod( String,"univar",true,[IsUnivariateRationalFunction],0,
function( f )
local fam,ind,nv,dv;
  fam := FamilyObj(f);
  ind := IndeterminateNumberOfLaurentPolynomial(f);
  f   := CoefficientsOfUnivariateRationalFunction(f);
  if f[3]>=0 then
    nv:=f[3];
    dv:=0;
  else
    nv:=0;
    dv:=-f[3];
  fi;
  return Concatenation("(",StringUnivariateLaurent(fam,f[1],nv,ind),")/(",StringUnivariateLaurent(fam,f[2],dv,ind),")");
end);

# Conversion:

# laurent to univariate ratfun
InstallMethod(CoefficientsOfUnivariateRationalFunction,"laurent polynomial",
  true,[IsLaurentPolynomial],0,
function(f)
local c;
  c:=CoefficientsOfLaurentPolynomial(f);
  return [c[1],FamilyObj(f)!.oneCoefflist,c[2]];
end);

# it is unlikely that there is a laurent polynomial in univariate ratfun
# extrep. The following routines therefore are for safety only.
InstallMethod(IsLaurentPolynomial,"univariate",true,
  [IsUnivariateRationalFunction],0,
function(f)
local c;
  c:=CoefficientsOfUnivariateRationalFunction(f);
  if Length(c[2])=1 then
    c:=[c[1]/c[2][1],c[3]];
    SetCoefficientsOfLaurentPolynomial(f,c);
    return true;
  fi;
  return false;
end);

# when testing a univariate rational function for polynomiality, we check
# whether it is a laurent polynomial and then use the laurent polynomial
# routines.
InstallMethod(IsPolynomial,"univariate",true,[IsUnivariateRationalFunction],0,
function(f)
  if not IsLaurentPolynomial(f) then
    return false;
  fi;
  return CoefficientsOfLaurentPolynomial(f)[2]>=0; # test valuation
end);

InstallOtherMethod(ExtRepPolynomialRatFun,"univariate",true,
  [IsUnivariateRationalFunction],0,
function(f)
  if not IsPolynomial(f) then
    return false;
  fi;
  return EXTREP_POLYNOMIAL_LAURENT(f);
end);

RedispatchOnCondition( CoefficientsOfLaurentPolynomial, true,
    [ IsUnivariateRationalFunction ], [ IsLaurentPolynomial ], 0 );

#############################################################################
##
#M  ExtRepNumeratorRatFun(<univariate>)
##
InstallMethod(ExtRepNumeratorRatFun,"univariate",true,
  [IsUnivariateRationalFunction],0,
function(f)
local c;
  c:=CoefficientsOfUnivariateRationalFunction(f);
  return EXTREP_COEFFS_LAURENT(c[1],
    Maximum(0,c[3]), # negative will go into denominator
    IndeterminateNumberOfUnivariateRationalFunction(f),
    FamilyObj(f)!.zeroCoefficient);
end);

#############################################################################
##
#M  ExtRepDenominatorRatFun(<univariate>)
##
InstallMethod(ExtRepDenominatorRatFun,"univariate",true,
  [IsUnivariateRationalFunction],0,
function(f)
local c;
  c:=CoefficientsOfUnivariateRationalFunction(f);
  return EXTREP_COEFFS_LAURENT(c[2],
    Maximum(0,-c[3]), # positive will go into numerator
    IndeterminateNumberOfUnivariateRationalFunction(f),
    FamilyObj(f)!.zeroCoefficient);
end);


# Arithmetic

#############################################################################
##
#M  AdditiveInverseOp( <univariate> )
##
InstallMethod( AdditiveInverseOp,"univariate",
    true, [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
function( obj )
local   cofs,  indn;

  cofs := CoefficientsOfUnivariateRationalFunction(obj);
  indn := IndeterminateNumberOfUnivariateRationalFunction(obj);

  if Length(cofs[1])=0 then
    return obj;
  fi;

  return UnivariateRationalFunctionByExtRepNC(FamilyObj(obj),
      AdditiveInverseOp(cofs[1]),cofs[2],cofs[3],indn);

end );

#############################################################################
##
#M  InverseOp( <univariate> )
##
InstallMethod( InverseOp,"univariate", true,
    [ IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
function( obj )
local   cofs,  indn;

  indn := IndeterminateNumberOfUnivariateRationalFunction(obj);
  cofs := CoefficientsOfUnivariateRationalFunction(obj);

  if Length(cofs[1])=0 then
    return fail;
  elif Length(cofs[1])=1 then
    # if the numerator is a power of x, we can return a laurent polynomial
    return LaurentPolynomialByExtRepNC(FamilyObj(obj),
          cofs[2]*Inverse(cofs[1][1]), -cofs[3], indn );
  else
    # swap numerator and denominator and invert the valuation
    return UnivariateRationalFunctionByExtRepNC(FamilyObj(obj),
      cofs[2],cofs[1],-cofs[3],indn );
  fi;

end );

#############################################################################
##
#M  <univariate> * <univariate>
##
InstallMethod( \*, "univariate * univariate", IsIdenticalObj,
    [ IsPolynomialFunction and IsUnivariateRationalFunction,
      IsPolynomialFunction and IsUnivariateRationalFunction], 0,
      PRODUCT_UNIVFUNCS);

#############################################################################
##
#M  <univariate> / <univariate>
##
InstallMethod( \/, "univariate / univariate", IsIdenticalObj,
    [ IsPolynomialFunction and IsUnivariateRationalFunction,
      IsRationalFunction and IsUnivariateRationalFunction], 0,
      QUOT_UNIVFUNCS);

#############################################################################
##
#M  <univariate> + <univariate>
##
InstallMethod( \+, "univariate + univariate", IsIdenticalObj,
    [ IsPolynomialFunction and IsUnivariateRationalFunction,
      IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
      SUM_UNIVFUNCS);

#############################################################################
##
#M  <univariate> - <univariate>
##
##  This is almost the same as `+'. However calling `AdditiveInverse' would
##  wrap up an intermediate polynomial which gets a bit expensive. So we do
##  almost the same here.
InstallMethod( \-, "univariate - univariate", IsIdenticalObj,
    [ IsPolynomialFunction and IsUnivariateRationalFunction,
      IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
      DIFF_UNIVFUNCS);

#############################################################################
##
#M  <univariate> = <univariate>
##
InstallMethod( \=, "univariate = univariate", IsIdenticalObj,
    [ IsPolynomialFunction and IsUnivariateRationalFunction,
      IsPolynomialFunction and IsUnivariateRationalFunction ], 0,
function(l,r)
local lc,rc;
  lc:=CoefficientsOfUnivariateRationalFunction(l);
  rc:=CoefficientsOfUnivariateRationalFunction(r);
  # is the indeterminate important?
  if (Length(lc[1])>1 or (Length(lc[1])>0 and lc[3]<>0))
    and IndeterminateNumberOfUnivariateRationalFunction(l)<>
     IndeterminateNumberOfUnivariateRationalFunction(r) then
    return false;
  fi;
  return ProductCoeffs(lc[1],rc[2])=ProductCoeffs(lc[2],rc[1]) and lc[3]=rc[3];
end);

#############################################################################
##
#M  <coeff> * <univariate>
##
##
BindGlobal("ProdCoeffUnivfunc",function( coef, univ )
local   fam, tmp;

  # multiply by zero gives the zero polynomial
  if IsZero(coef) then return Zero(univ);
  elif IsOne(coef) then return univ;fi;

  fam:=FamilyObj(univ);

  # construct the product and check the valuation in case zero divisors
  tmp := CoefficientsOfUnivariateRationalFunction(univ);
  if Length(tmp[1])=0 then
    return UnivariateRationalFunctionByExtRepNC(fam,[], tmp[2],tmp[3],
            IndeterminateNumberOfUnivariateRationalFunction(univ));
  else
    # Here we use ShallowCopy to avoid access errors later when CLONE_OBJ
    # will be called from coef*tmp[1] and will try to modify tmp
    return UnivariateRationalFunctionByExtRepNC(fam,coef*ShallowCopy(tmp[1]), tmp[2],tmp[3],
            IndeterminateNumberOfUnivariateRationalFunction(univ));
  fi;
end );

InstallMethod( \*, "coeff * univariate", IsCoeffsElms,
  [ IsRingElement, IsPolynomialFunction and IsUnivariateRationalFunction ],
    3, # The method for rational functions is higher ranked
  ProdCoeffUnivfunc);

InstallMethod( \*, "univariate * coeff", IsElmsCoeffs,
  [ IsPolynomialFunction and IsUnivariateRationalFunction,IsRingElement ],
    3, # The method for rational functions is higher ranked
  function(l,c) return ProdCoeffUnivfunc(c,l);end);

# special convenience: permit to multiply by rationals
InstallMethod( \*, "rat * univariate", true,
    [ IsRat, IsPolynomialFunction and IsUnivariateRationalFunction ],
    -RankFilter(IsRat),#fallback method is low ranked
  function(c,r) return ProdCoeffUnivfunc(c*FamilyObj(r)!.oneCoefficient,r); end);

InstallMethod( \*, "univariate * rat", true,
    [ IsPolynomialFunction and IsUnivariateRationalFunction, IsRat ],
    -RankFilter(IsRat),#fallback method is low ranked
  function(l,c) return ProdCoeffUnivfunc(c*FamilyObj(l)!.oneCoefficient,l); end);

#############################################################################
##
#M  <coeff> + <univariate>
##
##
BindGlobal("SumCoeffUnivfunc",function( coef, univ )
local   fam, tmp;

  if IsZero(coef) then return univ;fi;

  fam:=FamilyObj(univ);
  # make the constant a polynomial
  tmp:=UnivariateRationalFunctionByExtRepNC(fam,
    coef*fam!.oneCoefflist,fam!.oneCoefflist,0,
           IndeterminateNumberOfUnivariateRationalFunction(univ));
  return univ+tmp;
end );

InstallMethod( \+, "coeff + univariate", IsCoeffsElms,
  [ IsRingElement, IsPolynomialFunction and IsUnivariateRationalFunction ],0,
  SumCoeffUnivfunc);

InstallMethod( \+, "univariate + coeff", IsElmsCoeffs,
  [ IsPolynomialFunction and IsUnivariateRationalFunction,IsRingElement ],0,
  function(l,c) return SumCoeffUnivfunc(c,l);end);

# special convenience: permit to add rationals
InstallMethod( \+, "rat + univariate", true,
    [ IsRat, IsPolynomialFunction and IsUnivariateRationalFunction ],
    -RankFilter(IsRat),#fallback method is low ranked
  function(c,r) return SumCoeffUnivfunc(c*FamilyObj(r)!.oneCoefficient,r); end);

InstallMethod( \+, "univariate + rat", true,
    [ IsPolynomialFunction and IsUnivariateRationalFunction, IsRat ],
    -RankFilter(IsRat),#fallback method is low ranked
  function(l,c) return SumCoeffUnivfunc(c*FamilyObj(l)!.oneCoefficient,l); end);
