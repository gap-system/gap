#############################################################################
##
#W  ratfunul.gi                 GAP Library                      Frank Celler
#W                                                             Andrew Solomon
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for rational functions that know that they
##  are univariate laurent polynomials.
##
Revision.ratfunul_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  LaurentPolynomialByCoefficients( <fam>, <cofs>, <val>, <ind> )
##
InstallMethod( LaurentPolynomialByCoefficients, "with indeterminate", true,
    [ IsUFDFamily, IsList, IsInt, IsInt ], 0,
function( fam, cofs, val, ind )
  # construct a laurent polynomial

  fam:=RationalFunctionsFamily(fam);
  if Length(cofs)>0 and (IsZero(cofs[1]) or IsZero(cofs[Length(cofs)])) then
      if not IsMutable(cofs) then
          cofs:=ShallowCopy(cofs);
      fi;
      val:=val+RemoveOuterCoeffs(cofs,fam!.zeroCoefficient);
  fi;

  return LaurentPolynomialByExtRep(fam,cofs,val,ind);

end );

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
InstallMethod( CoefficientsOfUnivariatePolynomial, "use laurent coeffs",true,
    [ IsUnivariatePolynomial ], 0,
function(f);
  f:=CoefficientsOfLaurentPolynomial(f);
  return ShiftedCoeffs(f[1],f[2]);
end );

RedispatchOnCondition( CoefficientsOfUnivariatePolynomial, true, 
    [ IsRationalFunction ], [ IsUnivariatePolynomial ], 0);

#############################################################################
##
#M  DegreeOfLaurentPolynomial( <laurent> )
##
InstallMethod( DegreeOfLaurentPolynomial,
    true,
    [ IsRationalFunction and IsLaurentPolynomial ],
    0,

function( obj )
    local   cofs;

    cofs := CoefficientsOfLaurentPolynomial(obj);
    if IsEmpty(cofs[1])  then
        return infinity;
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
InstallMethod(IsPolynomial,"rational function rep.",true,
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

  if HasIndeterminateNumberOfLaurentPolynomial(f) and
    HasIndeterminateNumberOfLaurentPolynomial(g) then
    x:=IndeterminateNumberOfLaurentPolynomial(f);
    if x<>IndeterminateNumberOfLaurentPolynomial(g) then
      return fail;
    else
      return x;
    fi;
  fi;

  if IsLaurentPolynomial(f) and IsLaurentPolynomial(g) then
    # is either polynomial constant? if yes we must permit different
    # indeterminate numbers
    d:=DegreeOfLaurentPolynomial(f);
    if d=0 or d=infinity then
      return IndeterminateNumberOfLaurentPolynomial(g);
    fi;
    x:=IndeterminateNumberOfLaurentPolynomial(f);
    d:=DegreeOfLaurentPolynomial(g);
    if d<>0 and d<>infinity and 
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
##
##  Modification of ExtRepOfObj() AS
InstallMethod(ExtRepNumeratorRatFun,"laurent polynomial rep.",true,
  [IsLaurentPolynomialDefaultRep],0, EXTREP_NUMERATOR_LAURENT);


#############################################################################
##
#M  ExtRepDenominatorRatFun(<ulaurent>)
##
InstallMethod(ExtRepDenominatorRatFun,"laurent polynomial rep.",true,
  [IsLaurentPolynomialDefaultRep],0, 
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
  [ IsRationalFunction and IsUnivariateRationalFunction ], 0,
function(p)
local indn,fam;
  fam:=FamilyObj(p);
  indn := IndeterminateNumberOfUnivariateRationalFunction(p);
  if not IsBound(fam!.univariateOnePolynomials[indn]) then
    fam!.univariateOnePolynomials[indn]:=
      LaurentPolynomialByExtRep(fam,[fam!.oneCoefficient],0,indn);
  fi;
  return fam!.univariateOnePolynomials[indn];
end);

# avoid the one of the family (which is not univariate!)
InstallMethod(One,"univariate",true,
  [ IsRationalFunction and IsUnivariateRationalFunction ], 0, OneOp);

#############################################################################
##
#M  Zero(<laurent>)
##
InstallMethod(ZeroOp,"univariate",true,
  [ IsRationalFunction and IsUnivariateRationalFunction ], 0,
function(p)
local indn,fam;
  fam:=FamilyObj(p);
  indn := IndeterminateNumberOfUnivariateRationalFunction(p);
  if not IsBound(fam!.univariateZeroPolynomials[indn]) then
    fam!.univariateZeroPolynomials[indn]:=
      LaurentPolynomialByExtRep(fam,[],0,indn);
  fi;
  return fam!.univariateZeroPolynomials[indn];

end);

# avoid the one of the family (which is not univariate!)
InstallMethod(Zero,"univariate",true,
  [ IsRationalFunction and IsUnivariateRationalFunction ], 0, ZeroOp);

#############################################################################
##
#M  IndeterminateOfUnivariateRationalFunction( <laurent> )
##
InstallMethod( IndeterminateOfUnivariateRationalFunction,
  "use `IndeterminateNumber'",true,
  [ IsRationalFunction and IsUnivariateRationalFunction ], 0,
function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return LaurentPolynomialByExtRep(fam,
        [ FamilyObj(obj)!.oneCoefficient ],1,
        IndeterminateNumberOfUnivariateRationalFunction(obj) );
end );


# Arithmetic

#############################################################################
##
#M  AdditiveInverseOp( <laurent> )
##
InstallMethod( AdditiveInverseOp,"laurent polynomial",
    true, [ IsRationalFunction and IsLaurentPolynomial ], 0,
function( obj )
local   cofs,  indn;

  cofs := CoefficientsOfLaurentPolynomial(obj);
  indn := IndeterminateNumberOfUnivariateRationalFunction(obj);

  if Length(cofs[1])=0 then
    return obj;
  fi;

  return LaurentPolynomialByExtRep(FamilyObj(obj),
      AdditiveInverseOp(cofs[1]),cofs[2],indn);

end );

#############################################################################
##
#M  InverseOp( <laurent> )
##
InstallMethod( InverseOp,"try to express as laurent polynomial", true,
    [ IsRationalFunctionsFamilyElement and IsLaurentPolynomial ], 0,
function( obj )
local   cofs,  indn;

  indn := IndeterminateNumberOfUnivariateRationalFunction(obj);

  # this only works if we have only one coefficient
  cofs := CoefficientsOfLaurentPolynomial(obj);
  if 1 <> Length(cofs[1])  then
    TryNextMethod();
  fi;

  # invert the valuation
  return LaurentPolynomialByExtRep(FamilyObj(obj),
      [Inverse(cofs[1][1])], -cofs[2], indn );
end );

#############################################################################
##
#M  <laurent> * <laurent>
##
InstallMethod( \*, "laurent * laurent", IsIdenticalObj,
    [ IsRationalFunction and IsLaurentPolynomial,
      IsRationalFunction and IsLaurentPolynomial], 0, PRODUCT_LAURPOLS);

#############################################################################
##
#M  <laurent> + <laurent>
##
InstallMethod( \+, "laurent + laurent", IsIdenticalObj,
    [ IsRationalFunction and IsLaurentPolynomial,
      IsRationalFunction and IsLaurentPolynomial ], 0, SUM_LAURPOLS);

#############################################################################
##
#M  <laurent> - <laurent>
##
##  This is almost the same as `+'. However calling `AdditiveInverse' would
##  wrap up an intermediate polynomial which gets a bit expensive. So we do
##  almost the same here.
InstallMethod( \-, "laurent - laurent", IsIdenticalObj,
    [ IsRationalFunction and IsLaurentPolynomial,
      IsRationalFunction and IsLaurentPolynomial ], 0, DIFF_LAURPOLS);

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
  return LaurentPolynomialByExtRep(fam,coef*tmp[1], tmp[2],
           IndeterminateNumberOfUnivariateRationalFunction(laur));
end );

InstallMethod( \*, "coeff * laurent", IsCoeffsElms,
  [ IsRingElement, IsRationalFunction and IsLaurentPolynomial ], 0,
  ProdCoeffLaurpol);

InstallMethod( \*, "laurent * coeff", IsElmsCoeffs,
  [ IsRationalFunction and IsLaurentPolynomial,IsRingElement ], 0,
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
      return LaurentPolynomialByExtRep(fam, [coef], 0, indn );

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
      return LaurentPolynomialByExtRep(fam, sum, val, indn );

  # every coefficients has a negative exponent
  elif val + Length(tmp[1]) <= 0  then
      sum := ShallowCopy(tmp[1]);
      for i  in [ Length(sum)+1 .. -val ]  do
	  sum[i] := zero;
      od;
      sum[1-val] := coef;
      # we add at the end, no problem occurs
      return LaurentPolynomialByExtRep(fam, sum, val, indn );

  # every coefficients has a positive exponent
  else
      sum := [coef];
      for i  in [ 2 .. val ]  do
	  sum[i] := zero;
      od;
      Append( sum, tmp[1] );
      # we add in the first position, no problem occurs
      return LaurentPolynomialByExtRep(fam, sum, 0, indn );

  fi;
end );

InstallMethod( \+, "coeff + laurent", IsCoeffsElms,
    [ IsRingElement, IsRationalFunction and IsLaurentPolynomial ], 0,
    SumCoeffLaurpol);

InstallMethod( \+, "laurent + coeff", IsElmsCoeffs,
    [ IsRationalFunction and IsLaurentPolynomial, IsRingElement ], 0,
    function(l,c) return SumCoeffLaurpol(c,l); end);

# special convenience: permit to add rationals
InstallMethod( \+, "coeff + laurent", true,
    [ IsRat, IsRationalFunction and IsLaurentPolynomial ], 0,
  function(c,r) return SumCoeffLaurpol(c*FamilyObj(r)!.oneCoefficient,r); end);

InstallMethod( \+, "laurent + coeff", true,
    [ IsRationalFunction and IsLaurentPolynomial, IsRat ], 0,
  function(l,c) return SumCoeffLaurpol(c*FamilyObj(l)!.oneCoefficient,l); end);


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
    gc:=g[1];
  fi;

  q:=QUOTREM_LAURPOLS_LISTS(fc,gc);
  fc:=q[2];
  q:=q[1];

  if mode=1 or mode=4 then
    if mode=4 and ForAny(fc,i->not IsZero(i)) then
      return fail;
    fi;
    val:=RemoveOuterCoeffs(q,fam!.zeroCoefficient);
    q:=LaurentPolynomialByExtRep(fam,q,val,indn);
    return q;
  elif mode=2 then
    val:=RemoveOuterCoeffs(fc,fam!.zeroCoefficient);
    f:=LaurentPolynomialByExtRep(fam,fc,val,indn);
    return f;
  elif mode=3 then
    val:=RemoveOuterCoeffs(q,fam!.zeroCoefficient);
    q:=LaurentPolynomialByExtRep(fam,q,val,indn);
    val:=RemoveOuterCoeffs(fc,fam!.zeroCoefficient);
    f:=LaurentPolynomialByExtRep(fam,fc,val,indn);
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
InstallMethod(\/,"upol/upol",true,[IsLaurentPolynomial and IsPolynomial,
  IsLaurentPolynomial and IsPolynomial],2,
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
  [IsPolynomialRing,IsLaurentPolynomial,IsLaurentPolynomial],0,
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
                [,IsLaurentPolynomial,IsLaurentPolynomial],0);

InstallOtherMethod(QuotientRemainder,"laurent",IsIdenticalObj,
                [IsLaurentPolynomial,IsLaurentPolynomial],0,
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
  [IsLaurentPolynomial,IsLaurentPolynomial],0);

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
  [IsLaurentPolynomial,IsLaurentPolynomial],0,
function (f,g)
  return QuotRemLaurpols(f,g,4);
end);

#############################################################################
##
#M  QuotientMod( <pring>, <upol>, <upol>, <upol> )
##
InstallMethod(QuotientMod,"laurent",IsCollsElmsElmsElms,
  [IsRing,IsRingElement,IsRingElement,IsRingElement],0,
function (R,r,s,m)
local f,g,h,fs,gs,hs,q,t;
    f := s;  fs := 1;
    g := m;  gs := 0;
    while g <> Zero(g) do
        t := QuotientRemainder(f,g);
        h := g;          hs := gs;
        g := t[2];       gs := fs - t[1]*gs;
        f := h;          fs := hs;
    od;
    q:=QuotRemLaurpols(r,f,1);
    if q = fail  then
        return fail;
    else
        return (fs*q) mod m;
    fi;
end);

#############################################################################
##
#M  PowerMod( <pring>, <upol>, <exp>, <upol> )	. . . . power modulo
##
InstallMethod(PowerMod,"laurent",IsCollsElmsXElms,
   [IsPolynomialRing,IsLaurentPolynomial,IsInt,IsLaurentPolynomial],0,
function(R,g,e,m)
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
  g:=EuclideanRemainder(R,g,m);

  # and invert if necessary
  if e < 0  then
    g := QuotientMod(R,One(R),g,m);
    if g = fail  then
      Error("<g> must be invertable module <m>");
    fi;
    e := -e;
  fi;

  g:=CoefficientsOfLaurentPolynomial(g);
  m:=CoefficientsOfLaurentPolynomial(m);

  # use 'PowerModCoeffs' to power polynomial
  if g[2]=m[2] then
    val:=g[2];
    g:=g[1];
    m:=m[1];
  else
    val:=0;
    g:=ShiftedCoeffs(g[1],g[2]);
    m:=ShiftedCoeffs(m[1],m[2]);
  fi;
  g:=PowerModCoeffs(g,e,m);
  val:=val+RemoveOuterCoeffs(g,fam!.zeroCoefficient);
  g:=LaurentPolynomialByExtRep(fam,g,val,brci);
  return g;
end);

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
  if Length(ac[1])+ac[2]>1 and IndeterminateNumberOfLaurentPolynomial(a)<>
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
#M  EuclideanRemainder( <pring>, <upol>, <upol> )
##
InstallOtherMethod(EuclideanRemainder,"laurent",IsCollsElmsElms,
	      [IsPolynomialRing,IsLaurentPolynomial,IsLaurentPolynomial],0,
function(R,a,b)
local q;
  q:=QuotRemLaurpols(a,b,2);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);

#############################################################################
##
#M  \mod( <upol>, <upol> )
##
InstallMethod(\mod,"laurent",IsIdenticalObj,
	      [IsLaurentPolynomial,IsLaurentPolynomial],0,
function(a,b)
local q;
  q:=QuotRemLaurpols(a,b,2);
  if q=fail then
    TryNextMethod();
  fi;
  return q;
end);

#############################################################################
##
#M  GcdOp( <pring>, <upol>, <upol> )  . . . . . .  for univariate polynomials
##
InstallMethod( GcdOp,"univariate polynomial",IsCollsElmsElms,[IsEuclideanRing,
                IsPolynomial,IsPolynomial],0,
function(R,f,g)
local gcd,u,v,w,val,brci,fam;

  brci:=CIUnivPols(f,g);
  fam:=FamilyObj(f);
  if brci=fail then TryNextMethod();fi;
  f:=CoefficientsOfLaurentPolynomial(f);
  g:=CoefficientsOfLaurentPolynomial(g);

  # remove common x^i term
  val:=Minimum(f[2],g[2]);
  # the gcd cannot contain any further x^i parts, we removed them all!
  f:=ShallowCopy(f[1]);
  g:=ShallowCopy(g[1]);

  # perform a Euclidean algorithm
  u:=f;
  v:=g;
  while 0<Length(v) do
    w:=v;
    ReduceCoeffs(u,v);
    ShrinkCoeffs(u);
    v:=u;
    u:=w;
  od;
  gcd:=ShallowCopy(u*u[Length(u)]^-1);

  # return the gcd
  val:=val+RemoveOuterCoeffs(gcd,fam!.zeroCoefficient);
  return LaurentPolynomialByExtRep(fam,gcd,val,brci);
end);

RedispatchOnCondition( GcdOp,IsCollsElmsElms,
  [IsEuclideanRing, IsRationalFunction,IsRationalFunction],
  [, IsUnivariatePolynomial,IsUnivariatePolynomial],0);

#############################################################################
##
#M  StandardAssociate( <pring>, <lpol> )
##
InstallMethod(StandardAssociate,"laurent",
  IsCollsElms,[IsPolynomialRing, IsLaurentPolynomial],0,
function(R,f)
local l;

  l:=LeadingCoefficient(f);
  if not IsZero(l) then
    # get standard associate of leading term
    f:=f*Quotient(CoefficientsRing(R),
                  StandardAssociate(CoefficientsRing(R),l),l);
  fi;
  return f;
end);

#############################################################################
##
#M  Derivative( <upol> )
##
InstallOtherMethod(Derivative,"Laurent Polynomials",true,
                [IsLaurentPolynomial],0,
function(f)
local d,i,ind;

  ind := [CoefficientsFamily(FamilyObj(f)),
           IndeterminateNumberOfUnivariateRationalFunction(f)];
  d:=CoefficientsOfLaurentPolynomial(f);
  if Length(d[1])=0 then
    # special case: Derivative of 0-Polynomial
    return f;
  fi;
  f:=d;
  d:=[];
  for i in [1..Length(f[1])]  do
      d[i] := (i+f[2]-1)*f[1][i];
  od;
  return LaurentPolynomialByCoefficients(ind[1],d,f[2]-1,ind[2]);
end);

RedispatchOnCondition(Derivative,true,
  [IsPolynomial],[IsLaurentPolynomial],0);

#############################################################################
##
#F  Discriminant( <f> ) . . . . . . . . . . . . discriminant of polynomial f
##
InstallOtherMethod(Discriminant,"laurent",true,[IsLaurentPolynomial],0,
function(f)
local d;
  # the discriminant is \prod_i\prod_{j\not= i}(\alpha_i-\alpha_j), but
  # to avoid chaos with symmetric polynomials, we better compute it as
  # the resultant of f and f'
  d:=DegreeOfLaurentPolynomial(f);
  return (-1)^(d*(d-1)/2)*Resultant(f,Derivative(f),
    IndeterminateNumberOfLaurentPolynomial(f))/LeadingCoefficient(f);
end);

RedispatchOnCondition(Discriminant,true,
  [IsPolynomial],[IsLaurentPolynomial],0);

#############################################################################
##
#M  Value( <upol>, <elm>, <one> )
##
InstallOtherMethod( Value,"Laurent, ring element, and mult. neutral element",
    true, [ IsLaurentPolynomial, IsRingElement, IsRingElement ], 0,
function( f, x, one )
local val, i;
  val:= Zero( one );
  f:= CoefficientsOfLaurentPolynomial( f );
  i:= Length( f[1] );
  while 0 < i do
    val:= val * x + one * f[1][i];
    i:= i-1;
  od;
  if 0 <> f[2] then
    val:= val * x^f[2];
  fi;
  return val;
end );

#############################################################################
##
#M  Value( <upol>, <elm> )
##
InstallOtherMethod(Value,"LaurentPolynomial",true,
  [IsLaurentPolynomial,IsRingElement],0,
function(f,x)
  return Value(f,x,One(x));
end);

RedispatchOnCondition(Value,true,[IsRationalFunction,IsRingElement],
  [IsLaurentPolynomial,IsRingElement],0);


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
local   fam,  ind,  zero,  one,  mone,  i,  c,name;

    fam := FamilyObj(f);
    ind := IndeterminateNumberOfLaurentPolynomial(f);
    if HasIndeterminateName(fam,ind) then
      name:=IndeterminateName(fam,ind);
    else
      name:=Concatenation("x_",String(ind));
    fi;
    f   := CoefficientsOfLaurentPolynomial(f);
    zero := fam!.zeroCoefficient;
    one  := One(zero);
    mone := -one;
    if Length(f[1])=0 then
      Print(zero);
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
end);

#############################################################################
##
#E
##
