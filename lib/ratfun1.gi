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
##  This file  contains those  methods  for    rational  functions,  laurent
##  polynomials and polynomials and their families which are time critical
##  and will benefit from compilation.
##

# Functions to create objects

BindGlobal( "LAUR_POL_BY_EXTREP", function(rfam,coeff,val,inum)
local f,typ,lc;

# trap code for unreduced coeffs.
# if Length(coeffs[1])>0
#    and (IsZero(coeffs[1][1]) or IsZero(coeffs[1][Length(coeffs[1])])) then
#   Error("zero coeff!");
# fi;

  # check for constants and zero
  lc:=Length(coeff);
  if 0 = val and 1 = lc  then
    # unshifted and one coefficient - constant
    typ := rfam!.threeLaurentPolynomialTypes[2];
  elif 0 = lc then
    # it is the zero polynomial
    val:=0; # special case: result is 0.
    typ := rfam!.threeLaurentPolynomialTypes[2];
  elif 0 <= val  then
    # possibly shifted left - polynomial
    typ := rfam!.threeLaurentPolynomialTypes[3];
  else
    typ := rfam!.threeLaurentPolynomialTypes[1];
  fi;

  # slightly better to do this after the Length has been determined
  if IsFFECollection(coeff) and IS_PLIST_REP(coeff) then
    f:=DefaultRing(coeff);
    if IsFinite(f) and Size(f)>MAXSIZE_GF_INTERNAL then
      # do not pack Zmodnz objects into vectors
      coeff := Immutable(coeff);
    else
      coeff := ImmutableVector(f, coeff);
    fi;
  fi;


  # objectify. We have to be *fast*. Thus we don't even call
  # `ObjectifyWithAttributes' but `Objectify' itself.

  # note that `IndNum.LaurentPol. is IndnumUnivRatFun !
  f := rec(IndeterminateNumberOfUnivariateRationalFunction:=inum,
           CoefficientsOfLaurentPolynomial:=Immutable([coeff,val]));
  Objectify(typ,f);

#  ObjectifyWithAttributes(f,typ,
#    IndeterminateNumberOfLaurentPolynomial, inum,
#    CoefficientsOfLaurentPolynomial, coeffs);

  # and return the polynomial
  return f;
end );

# conversion

BindGlobal( "EXTREP_POLYNOMIAL_LAURENT", function(f)
local coefs, ind, extrep, i, shift,fam;
  fam:=FamilyObj(f);
  coefs := CoefficientsOfLaurentPolynomial(f);
  ind := IndeterminateNumberOfLaurentPolynomial(f);
  extrep := [];
  shift := coefs[2];
  for i in [1 .. Length(coefs[1])] do
    if coefs[1][i]<>fam!.zeroCoefficient then
      if 1-i<>shift then
        Append(extrep,[[ind, i + shift -1], coefs[1][i]]);
      else
        Append(extrep,[[], coefs[1][i]]);
      fi;
    fi;
  od;
  return extrep;

end );

BindGlobal( "INDETS_POLY_EXTREP", function(extrep)
local indets, i, j;
  indets:=[];
  for i in [1,3..Length(extrep)-1] do
    for j in [1,3..Length(extrep[i])-1] do
      AddSet(indets, extrep[i][j]);
    od;
  od;
  return indets;
end );

BindGlobal( "UNIVARTEST_RATFUN", function(f)
local fam,notuniv,cannot,num,den,hasden,indn,col,dcol,val,i,j,nud,pos;
  fam:=FamilyObj(f);

  notuniv:=[false,fail,false,fail];  # answer if know to be not univariate
  cannot:=[fail,fail,fail,fail];     # answer if the test fails because
                                     # there is no multivariate GCD.

  # try to become a polynomial if possible. In particular we know the
  # denominator to be cancelled out if possible.
  if IsPolynomial(f) then
    num := ExtRepPolynomialRatFun(f);
    den:=[[],fam!.oneCoefficient];
  else
    num := ExtRepNumeratorRatFun(f);
    den := ExtRepDenominatorRatFun(f);
  fi;

  # if the symmetric difference of the indeterminates of the numerator and
  # denominator contains more than one element, can't be univariate
  i:=INDETS_POLY_EXTREP(num);
  j:=INDETS_POLY_EXTREP(den);
  if Size(Union(i,j)) > Size(Intersection(i,j))+1 then
    return notuniv;
  fi;

  if Length(den[1])> 0 then
    # try a GCD cancellation
    i:=TryGcdCancelExtRepPolynomials(fam,num,den);
    if i<>fail then
      num:=i[1];
      den:=i[2];
    fi;

    #T: must do multivariate GCD (otherwise a `false' answer is not guaranteed)
  fi;
  hasden:=true;

  indn:=false; # the indeterminate number we want to get
  if Length(den)=2 and Length(den[1])=0 then
    if not IsOne(den[2]) then
      # take care of denominator so that we can throw it away afterwards.
      den:=den[2];
      num:=ShallowCopy(num);
      for i in [2,4..Length(num)] do
        num[i]:=num[i]/den;
      od;
    fi;
    hasden:=false;
    val:=0;

  elif Length(den)=2 then
    # this is the case in which we can spot a laurent polynomial

    # We assume that the cancellation test will have dealt properly with
    # denominators which are monomials. So what we need here is only one
    # indeterminate, otherwise we must fail
    if Length(den[1])>2 then
      return cannot; # or: notuniv?
    fi;

    indn:=den[1][1]; # this is the indeterminate number we need to have
    val:=-den[1][2];
    if not IsOne(den[2]) then
      # take care of denominator so that we can throw it away afterwards.
      den:=den[2];
      num:=ShallowCopy(num);
      for i in [2,4..Length(num)] do
        num[i]:=num[i]/den;
      od;
    fi;
    hasden:=false;
  fi;

  col:=[];
  nud:=1; # last position isto which we can assign without holes
  # now process the numerator
  for i in [2,4..Length(num)] do

    if Length(num[i-1])>0 then
      if indn=false then
        #set the indeterminate
        indn:=num[i-1][1];
      elif indn<>num[i-1][1] then
        # inconsistency:
        if hasden then
          return cannot;
        else
          return notuniv;
        fi;
      fi;
    fi;

    if Length(num[i-1])>2 then
      if hasden then
        return cannot;
      else
        return notuniv;
      fi;
    fi;

    # now we know the monomial to be [indn,exp]

    # set the coefficient
    if Length(num[i-1])=0 then
      # exp=0
      pos:=1;
    else
      pos:=num[i-1][2]+1;
    fi;

    # fill zeroes in the coefficient list
    for j in [nud..pos-1] do
      col[j]:=fam!.zeroCoefficient;
    od;

    col[pos]:=num[i];
    nud:=pos+1;

  od;

  if hasden then
    dcol:=[];
    nud:=1; # last position isto which we can assign without holes
    # because we have a special hook above for laurent polynomials, we know
    # it cannot be a laurent polynomial any longer.

    # now process the denominator
    for i in [2,4..Length(den)] do

      if Length(den[i-1])>0 then
        if indn=false then
          #set the indeterminate
          indn:=den[i-1][1];
        elif indn<>den[i-1][1] then
          # inconsistency:
          return cannot;
        fi;
      fi;

      if Length(den[i-1])>2 then
        return cannot;
      fi;

      # now we know the monomial to be [indn,exp]

      # set the coefficient
      if Length(den[i-1])=0 then
        # exp=0
        pos:=1;
      else
        pos:=den[i-1][2]+1;
      fi;

      # fill zeroes in the coefficient list
      for j in [nud..pos-1] do
        dcol[j]:=fam!.zeroCoefficient;
      od;

      dcol[pos]:=den[i];
      nud:=pos+1;

    od;

    val:=RemoveOuterCoeffs(col,fam!.zeroCoefficient);
    val:=val-RemoveOuterCoeffs(dcol,fam!.zeroCoefficient);

    # the indeterminate number must be set, we have a nonvanishing
    # denominator
    return [true,indn,false,Immutable([col,dcol,val])];

  else
    # no denominator to deal with: We are univariate laurent

    # shift properly
    val:=val+RemoveOuterCoeffs(col,fam!.zeroCoefficient);

    if indn=false then
      indn:=1; #default value
    fi;

    return [true,indn,true,Immutable([col,val])];
  fi;

end );

BindGlobal( "EXTREP_COEFFS_LAURENT", function(cofs,val,ind,zero)
local   ext,  i,  j;

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

  return ext;

end );

BindGlobal( "UNIV_FUNC_BY_EXTREP", function(rfam,ncof,dcof,val,inum)
local f;

  # constant denominator -> ratfun
  if Length(dcof)=1 then
    if not IsOne(dcof[1]) then
      return LAUR_POL_BY_EXTREP(rfam,1/dcof[1]*ncof,val,inum);
    else
      return LAUR_POL_BY_EXTREP(rfam,ncof,val,inum);
    fi;
  fi;

  # slightly better to do this after the Length id determined
  if IsFFECollection(ncof) and IS_PLIST_REP(ncof) then
    ConvertToVectorRep(ncof);
  fi;
  if IsFFECollection(dcof) and IS_PLIST_REP(dcof) then
    ConvertToVectorRep(dcof);
  fi;

  # objectify. We have to be *fast*. Thus we don't even call
  # `ObjectifyWithAttributes' but `Objectify' itself.

  # note that `IndNum.LaurentPol. is IndnumUnivRatFun !
  f := rec(IndeterminateNumberOfUnivariateRationalFunction:=inum,
          CoefficientsOfUnivariateRationalFunction:=Immutable([ncof,dcof,val]));
  Objectify(rfam!.univariateRatfunType,f);

#  ObjectifyWithAttributes(f,typ,...

  # and return the polynomial
  return f;
end );

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
#F  MonomialRevLexicoLess(mon1,mon2) . . . .  reverse lexicographic ordering
##
BindGlobal( "MONOM_REV_LEX", function(m,n)
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
  return x<=0 and y>0;
end );

##  Low level workhorse for operations with monomials in Zipped form
##  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
BindGlobal( "ZIPPED_SUM_LISTS_LIB", function( z1, z2, zero, f )
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


##  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
BindGlobal( "ZIPPED_PRODUCT_LISTS", function( z1, z2, zero, f )
local   mons,  cofs,  i,  j,  c,  prd;

  # check for constant factors
  if Length(z1)=2 and IsList(z1[1]) and Length(z1[1])=0 then
    c:=z1[2];
    prd:=ShallowCopy(z2);
    cofs:=[2,4..Length(prd)];
    if not IsOne(c) then
      prd{cofs}:=c*prd{cofs};
    fi;
    return prd;
  elif Length(z2)=2 and IsList(z2[1]) and Length(z2[1])=0 then
    c:=z2[2];
    prd:=ShallowCopy(z1);
    cofs:=[2,4..Length(prd)];
    if not IsOne(c) then
      prd{cofs}:=c*prd{cofs};
    fi;
    return prd;
  fi;

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
#F  ZippedListQuotient  . . . . . . . . . . . .  divide a monomial by another
##
BindGlobal("ZippedListQuotient",function( a, b )
local l, m, i, j, c, e;
  l:=Length(a);
  m:=Length(b);
  i:=1;
  j:=1;
  c:=[];
  while i<l and j<m do
    if a[i]=b[j] then
      e:=a[i+1]-b[j+1];
      if e<>0 then
        Add(c,a[i]);
        Add(c,e);
      fi;
      i:=i+2;
      j:=j+2;
    elif a[i]<b[j] then
      Add(c,a[i]);
      Add(c,a[i+1]);
      i:=i+2;
    else
      Add(c,b[j]);
      Add(c,-b[j+1]);
      j:=j+2;
    fi;
  od;
  while i<l do
    Add(c,a[i]);
    Add(c,a[i+1]);
    i:=i+2;
  od;
  while j<m do
    Add(c,b[j]);
    Add(c,-b[j+1]);
    j:=j+2;
  od;
  return c;
end);

# Arithmetic

BindGlobal( "ADDITIVE_INV_RATFUN", function( obj )
    local   fam,  i, newnum;

    fam := FamilyObj(obj);
    newnum := ShallowCopy(ExtRepNumeratorRatFun(obj));
    for i  in [ 2, 4 .. Length(newnum) ]  do
        newnum[i] := -newnum[i];
    od;
    return RationalFunctionByExtRepNC(fam,newnum,ExtRepDenominatorRatFun(obj));
end );

BindGlobal( "ADDITIVE_INV_POLYNOMIAL", function( obj )
    local   fam,  i, newnum;

    fam := FamilyObj(obj);
    newnum := ShallowCopy(ExtRepNumeratorRatFun(obj));
    for i  in [ 2, 4 .. Length(newnum) ]  do
        newnum[i] := -newnum[i];
    od;
    return PolynomialByExtRepNC(fam,newnum);
end );

BindGlobal( "SMALLER_RATFUN", function(left,right)
local a,b,fam,i, j,ln,ld,rn,rd;
  if HasIsPolynomial(left) and IsPolynomial(left)
     and HasIsPolynomial(right) and IsPolynomial(right) then
    a:=ExtRepPolynomialRatFun(left);
    b:=ExtRepPolynomialRatFun(right);
  else
    fam:=FamilyObj(left);
    ln:=ExtRepNumeratorRatFun(left);
    ld:=ExtRepDenominatorRatFun(left);
    # avoid negative leading coefficients in the denominator
    i:=Length(ld);
    if ld[i]<0*ld[i] then
      ld:=ShallowCopy(ld);
      for i in [2,4..Length(ld)] do
        ld[i]:=-ld[i];
      od;
      ln:=ShallowCopy(ln);
      for i in [2,4..Length(ln)] do
        ln[i]:=-ln[i];
      od;
    fi;

    rn:=ExtRepNumeratorRatFun(right);
    rd:=ExtRepDenominatorRatFun(right);
    # avoid negative leading coefficients in the denominator
    i:=Length(rd);
    if rd[i]<0*rd[i] then
      rd:=ShallowCopy(rd);
      for i in [2,4..Length(rd)] do
        rd[i]:=-rd[i];
      od;
      rn:=ShallowCopy(rn);
      for i in [2,4..Length(rn)] do
        rn[i]:=-rn[i];
      od;
    fi;

    a := ZippedProduct(ln,rd,fam!.zeroCoefficient,fam!.zippedProduct);

    b := ZippedProduct(rn,ld,fam!.zeroCoefficient,fam!.zippedProduct);
  fi;

  i:=Length(a)-1;
  j:=Length(b)-1;
  while i>0 and j>0 do
    # compare the last monomials
    if a[i]=b[j] then
      # the monomials are the same, compare the coefficients
      if a[i+1]=b[j+1] then
        # the coefficients are also the same. Must continue
        i:=i-2;
        j:=j-2;
      else
        # let the coefficients decide
        return a[i+1]<b[j+1];
      fi;
    elif MonomialExtGrlexLess(a[i],b[j]) then
      # a is strictly smaller
      return true;
    else
      # a is strictly larger
      return false;
    fi;
  od;
  # is there an a-remainder (then a is larger)
  # or are both polynomials equal?
  return not (i>0 or i=j);
end );

#############################################################################
##
#M  <polynomial>     + <coeff>
##
BindGlobal( "SUM_COEF_POLYNOMIAL", function( cf, rf )
local   fam,  extrf;

  if IsZero(cf) then
    return rf;
  fi;

  fam   := FamilyObj(rf);
  extrf  := ExtRepPolynomialRatFun(rf);
  # assume the constant term is in the first position
  if Length(extrf)>0 and Length(extrf[1])=0 then
    if extrf[2]=-cf then
      extrf:=extrf{[3..Length(extrf)]};
    else
      extrf:=ShallowCopy(extrf);
      extrf[2]:=extrf[2]+cf;
    fi;
  else
    extrf:=Concatenation([[],cf],extrf);
  fi;

  return PolynomialByExtRepNC(fam,extrf);

end );

BindGlobal( "QUOTIENT_POLYNOMIALS_EXT", function(fam, p, q )
local   quot, lcq,  lmq,  mon,  i, coeff;

  if Length(q)=0 then
    return fail; #safeguard
  fi;

  quot := [];

  lcq := q[Length(q)];
  lmq := q[Length(q)-1];

  p:=ShallowCopy(p);
  while Length(p)>0 do
    ##  divide the leading monomial of q by the leading monomial of p
    mon  := ZippedListQuotient( p[Length(p)-1], lmq );

      ##  check if mon has negative exponents
      for i in [2,4..Length(mon)] do
          if mon[i] < 0 then return fail; fi;
      od;

      ##  now add the quotient of the coefficients
      coeff := p[Length(p)] / lcq;

      ##  Add coeff, mon to quot, the result is sorted in reversed order.
      Add( quot,  coeff );
      Add( quot,  mon );

      ## p := p - mon * q;
      #  compute -q*mon;
      mon  := ZippedProduct(q,[mon,-coeff],
        fam!.zeroCoefficient,fam!.zippedProduct);

      # add it to p
      p:=ZippedSum(p,mon,fam!.zeroCoefficient,fam!.zippedSum);
  od;

  quot := Reversed(quot);
  return quot;
end );

BindGlobal( "SUM_LAURPOLS", function( left, right )
local   indn,  fam,  zero,  l,  r,  val,  sum;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfLaurentPolynomial(left) and
    HasIndeterminateNumberOfLaurentPolynomial(right) then
    indn:=IndeterminateNumberOfLaurentPolynomial(left);
    if indn<>IndeterminateNumberOfLaurentPolynomial(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then
      TryNextMethod();
    fi;
  fi;

  # get the coefficients
  fam  := FamilyObj(left);
  zero := fam!.zeroCoefficient;
  l    := CoefficientsOfLaurentPolynomial(left);
  r    := CoefficientsOfLaurentPolynomial(right);

  # catch zero cases
  if Length(l[1])=0 then
    return right;
  elif Length(r[1])=0 then
    return left;
  fi;

  if l[2]=r[2] then
    sum:=ShallowCopy(l[1]);
    AddCoeffs(sum,r[1]);
    # only in this case the initial coefficient might be cancelled out
    # (assuming that f and g are proper)
    val:=l[2]+RemoveOuterCoeffs(sum,zero);
  elif l[2]<r[2] then
    sum:=ShallowCopy(r[1]);
    RightShiftRowVector(sum,r[2]-l[2],zero);
    AddCoeffs(sum,l[1]);
    ShrinkRowVector(sum);
    val:=l[2];
  else #l[2]>r[2]
    sum:=ShallowCopy(l[1]);
    RightShiftRowVector(sum,l[2]-r[2],zero);
    AddCoeffs(sum,r[1]);
    ShrinkRowVector(sum);
    val:=r[2];
  fi;

  # and return the polynomial (we might get a new valuation!)
  return LaurentPolynomialByExtRepNC(fam, sum, val, indn );

end );

DIFF_LAURPOLS:=
function( left, right )
local   indn,  fam,  zero,  l,  r,  val,  sum;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfLaurentPolynomial(left) and
    HasIndeterminateNumberOfLaurentPolynomial(right) then
    indn:=IndeterminateNumberOfLaurentPolynomial(left);
    if indn<>IndeterminateNumberOfLaurentPolynomial(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then
      TryNextMethod();
    fi;
  fi;

  # get the coefficients
  fam  := FamilyObj(left);
  zero := fam!.zeroCoefficient;
  l    := CoefficientsOfLaurentPolynomial(left);
  r    := CoefficientsOfLaurentPolynomial(right);

  # catch zero cases
  if Length(l[1])=0 then
    return AdditiveInverseOp(right);
  elif Length(r[1])=0 then
    return left;
  fi;

  if l[2]=r[2] then
    sum:=ShallowCopy(l[1]);
    AddCoeffs(sum,r[1],-fam!.oneCoefficient);
    # only in this case the initial coefficient might be cancelled out
    # (assuming that f and g are proper)
    val:=l[2]+RemoveOuterCoeffs(sum,zero);
  elif l[2]<r[2] then
    sum:=ShallowCopy(AdditiveInverseOp(r[1]));
    RightShiftRowVector(sum,r[2]-l[2],zero);
    AddCoeffs(sum,l[1]);
    ShrinkRowVector(sum);
    val:=l[2];
  else #l[2]>r[2]
    sum:=ShallowCopy(l[1]);
    RightShiftRowVector(sum,l[2]-r[2],zero);
    # was: AddCoeffs(sum,AdditiveInverseOp(r[1]));
    AddCoeffs(sum,r[1],-fam!.oneCoefficient);
    ShrinkRowVector(sum);
    val:=r[2];
  fi;

  # and return the polynomial (we might get a new valuation!)
  return LaurentPolynomialByExtRepNC(fam, sum, val, indn );

end;

BindGlobal( "PRODUCT_LAURPOLS", function( left, right )
local   indn,  fam,  prd,  l,  r,  m,  n, val;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfLaurentPolynomial(left) and
    HasIndeterminateNumberOfLaurentPolynomial(right) then
    indn:=IndeterminateNumberOfLaurentPolynomial(left);
    if indn<>IndeterminateNumberOfLaurentPolynomial(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then
      TryNextMethod();
    fi;
  fi;

  fam := FamilyObj(left);

  # special treatment of zero
  l   := CoefficientsOfLaurentPolynomial(left);
  m   := Length(l[1]);
  if m=0 then
    return left;
  fi;

  r   := CoefficientsOfLaurentPolynomial(right);
  n   := Length(r[1]);
  if n=0 then
    return right;
  fi;

  # fold the coefficients
  prd:=ProductCoeffs(l[1],m,r[1],n);
  val := l[2] + r[2];
  val:=val+RemoveOuterCoeffs(prd,fam!.zeroCoefficient);

  # return the polynomial
  return LaurentPolynomialByExtRepNC(fam,prd, val, indn );
end );

BindGlobal( "GCD_COEFFS", function(u,v)
local w;

  # perform a Euclidean algorithm
  u:=ShallowCopy(u);
  v:=ShallowCopy(v);
  while 0<Length(v) do
    w:=v;
    ReduceCoeffs(u,v);
    ShrinkRowVector(u);
    v:=u;
    u:=w;
  od;
  if Length(u)>0 then
    return u*u[Length(u)]^-1;
  else
    return u;
  fi;
end );

# This function is destructive on the first argument!
BindGlobal( "QUOTREM_LAURPOLS_LISTS", function(fc,gc)
local q,m,n,i,c,k,f,z;
  # try to divide
  q:=[];
  n:=Length(gc);
  m:=Length(fc)-n;
  # try to keep a compressed field
  if IsGF2VectorRep(fc) and IsGF2VectorRep(gc) then
    f:=2;
  elif Is8BitVectorRep(fc) then
    f:=Q_VEC8BIT(fc);
    if (not Is8BitVectorRep(gc)) or Q_VEC8BIT(gc)<>f then
      f:=0;
    fi;
  else
    f:=0;
  fi;
  z:=Zero(gc[n]);
  for i in [0..m] do
    c := fc[m-i+n];
    if c <> z then
      c:=c/gc[n];
      k:=[1+m-i..n+m-i];
      fc{k}:=fc{k}-c*gc;
    fi;
    q[m-i+1]:=c;
  od;
  if f>0 then
    ConvertToVectorRep(q,f);
  fi;
  return [q,fc];
end );

BindGlobal( "ADDCOEFFS_GENERIC_3", function( l1, l2, m )
local   a1,a2, zero,  n1;
  a1:=Length(l1);a2:=Length(l2);
  if a1>=a2 then
    n1:=[1..a2];
    l1{n1}:=l1{n1}+m*l2;
  else
    n1:=[1..a1];
    l1{n1}:=l1+m*l2{n1};
    Append(l1,m*l2{[a1+1..a2]});
  fi;

  if 0 < Length(l1)  then
      zero := Zero(l1[1]);
      n1   := Length(l1);
      while 0 < n1 and l1[n1] = zero  do
          n1 := n1 - 1;
      od;
  else
      n1 := 0;
  fi;
  return n1;
end );

PRODUCT_COEFFS_GENERIC_LISTS:=
function( l1,m,l2,n )
local i,j,p,z,s,u,o;
  if m=0 or n=0 then
    return [];
  fi;

  # this is faster than calling only `Zero'.
  s:=FamilyObj(l1[1]);
  if HasZero(s) then
    z:=Zero(s);
  else
    z:=Zero(l1[1]);
  fi;

  p:=[];
  for i  in [ 1 .. m+n-1 ]  do
    s := z;
    if m<i then
      o:=m;
    else
      o:=i;
    fi;
    if i<n then
      u:=1;
    else
      u:=i+1-n;
    fi;
    for j  in [ u .. o ]  do
      s := s + l1[j] * l2[i+1-j];
    od;
    p[i] := s;
  od;
  return p;
end;

##  RemoveOuterCoeffs( <list>, <coef> )

BindGlobal( "REMOVE_OUTER_COEFFS_GENERIC", function( l, c )
local   n,  m,  i;

  n := Length(l);
  if 0 = n  then
      return 0;
  fi;
  while 0 < n and l[n] = c  do
      Unbind(l[n]);
      n := n-1;
  od;
  if n = 0  then
      return 0;
  fi;
  m := 0;
  while m < n and l[m+1] = c  do
      m := m+1;
  od;
  if 0 = m  then
      return 0;
  fi;
  for i in [ m+1 .. n ]  do
      l[i-m]:=l[i];
  od;
  for i  in [1 .. m]  do
      Unbind(l[n-i+1]);
  od;
  return m;
end );

BindGlobal( "PRODUCT_UNIVFUNCS", function(left,right)
local indn,l,r,ln,ld,rn,rd,g,m,n;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfUnivariateRationalFunction(left) and
    HasIndeterminateNumberOfUnivariateRationalFunction(right) then
    indn:=IndeterminateNumberOfUnivariateRationalFunction(left);
    if indn<>IndeterminateNumberOfUnivariateRationalFunction(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then
      TryNextMethod();
    fi;
  fi;

  l:=CoefficientsOfUnivariateRationalFunction(left);
  r:=CoefficientsOfUnivariateRationalFunction(right);
  ln:=l[1];
  rd:=r[2];
  g:=GcdCoeffs(ln,rd);
  if Length(g)>1 then
    ln:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(ln),g)[1];
    rd:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(rd),g)[1];
  fi;

  rn:=r[1];
  ld:=l[2];
  g:=GcdCoeffs(rn,ld);
  if Length(g)>1 then
    rn:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(rn),g)[1];
    ld:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(ld),g)[1];
  fi;

  m  := Length(ln);
  if m=0 then
    return left;
  fi;

  n:=Length(rn);
  if n=0 then
    return right;
  fi;

  # product
  ln:=ProductCoeffs(ln,m,rn,n);
  ld:=ProductCoeffs(ld,rd);
  return UnivariateRationalFunctionByExtRepNC(FamilyObj(left),
           ln,ld,l[3]+r[3],indn);
end );

BindGlobal( "QUOT_UNIVFUNCS", function(left,right)
local indn,l,r,ln,ld,rn,rd,g,m,n;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfUnivariateRationalFunction(left) and
    HasIndeterminateNumberOfUnivariateRationalFunction(right) then
    indn:=IndeterminateNumberOfUnivariateRationalFunction(left);
    if indn<>IndeterminateNumberOfUnivariateRationalFunction(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then
      TryNextMethod();
    fi;
  fi;

  l:=CoefficientsOfUnivariateRationalFunction(left);
  r:=CoefficientsOfUnivariateRationalFunction(right);
  ln:=l[1];
  rd:=r[1];
  g:=GcdCoeffs(ln,rd);
  if Length(g)>1 then
    ln:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(ln),g)[1];
    rd:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(rd),g)[1];
  fi;

  rn:=r[2];
  ld:=l[2];
  g:=GcdCoeffs(rn,ld);
  if Length(g)>1 then
    rn:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(rn),g)[1];
    ld:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(ld),g)[1];
  fi;

  m  := Length(ln);
  if m=0 then
    return left;
  fi;

  n:=Length(rn); #cannot be zero since former denominator

  # product
  ln:=ProductCoeffs(ln,m,rn,n);
  ld:=ProductCoeffs(ld,rd);
  return UnivariateRationalFunctionByExtRepNC(FamilyObj(left),
           ln,ld,l[3]-r[3],indn);
end );

BindGlobal( "SUM_UNIVFUNCS", function(left,right)
local l,r,indn,ld,rd,ln,rn,g,fam,zero,val;

  # this method only works for the same indeterminate
  # to be *Fast* we don't even call `CIUnivPols' but work directly.
  if HasIndeterminateNumberOfUnivariateRationalFunction(left) and
    HasIndeterminateNumberOfUnivariateRationalFunction(right) then
    indn:=IndeterminateNumberOfUnivariateRationalFunction(left);
    if indn<>IndeterminateNumberOfUnivariateRationalFunction(right) then
      TryNextMethod();
    fi;
  else
    indn:=CIUnivPols(left,right);
    if indn=fail then
      TryNextMethod();
    fi;
  fi;

  fam  := FamilyObj(left);
  zero := fam!.zeroCoefficient;
  l:=CoefficientsOfUnivariateRationalFunction(left);
  r:=CoefficientsOfUnivariateRationalFunction(right);

  # catch zero cases
  if Length(l[1])=0 then
    return right;
  elif Length(r[1])=0 then
    return left;
  fi;

  ln:=l[1];
  ld:=l[2];
  rn:=r[1];
  rd:=r[2];

  # take care of valuation
  if l[3]<r[3] then
    val:=l[3];
    rn:=ShallowCopy(rn);
    RightShiftRowVector(rn,r[3]-l[3],zero);
  elif l[3]>r[3] then
    val:=r[3];
    ln:=ShallowCopy(ln);
    RightShiftRowVector(ln,l[3]-r[3],zero);
  else
    val:=l[3];
  fi;

  if ld=rd then
    ln:=ShallowCopy(ln);
    AddCoeffs(ln,rn);
  else
    # different denominators
    g:=GcdCoeffs(ld,rd);
    if Length(g)=1 then
      # coprime
      ln:=ProductCoeffs(ln,rd);
      rn:=ProductCoeffs(rn,ld);
      # new denominator
      ld:=ProductCoeffs(ld,rd);
    else
      rd:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(rd),g)[1];
      ln:=ProductCoeffs(ln,rd);
      # left divided denominator
      g:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(ld),g)[1];
      rn:=ProductCoeffs(rn,g);
      # new denominator
      ld:=ProductCoeffs(ld,rd);
    fi;
    AddCoeffs(ln,rn);
  fi;
  val:=val+RemoveOuterCoeffs(ln,zero);
  g:=GcdCoeffs(ln,ld);
  if Length(g)>1 then
    ln:=QUOTREM_LAURPOLS_LISTS(ln,g)[1];
    ld:=QUOTREM_LAURPOLS_LISTS(ShallowCopy(ld),g)[1];
  fi;

  return UnivariateRationalFunctionByExtRepNC(fam,ln,ld,val,indn);

end );

BindGlobal( "DIFF_UNIVFUNCS", function(f,g)
  TryNextMethod();
end );

#############################################################################
##
#F  SpecializedExtRepPol(<fam>,<ext>,<ind>,<val>)
##
BindGlobal( "SPECIALIZED_EXTREP_POL", function(fam,ext,ind,val)
local e,i,p,m,c;
  e:=[];
  for i in [1,3..Length(ext)-1] do
    # is the indeterminate used in the monomial
    p:=PositionProperty([1,3..Length(ext[i])-1],j->ext[i][j]=ind);
    if p=fail then
      m:=ext[i];
      c:=ext[i+1];
    else
      # yes, compute changed monomial and coefficient
      p:=2*p-1; #actual position 1,3..
      m:=ext[i]{Concatenation([1..p-1],[p+2..Length(ext[i])])};
      c:=ext[i+1]*val^ext[i][p+1];
    fi;
    e:=ZippedSum(e,[m,c],fam!.zeroCoefficient,fam!.zippedSum);
  od;
  return e;
end );

TRY_GCD_CANCEL_EXTREP_POL:=
function(fam,num,den)
local q,p,e,i,j,cnt,sel,si;
  q:=QuotientPolynomialsExtRep(fam,num,den);
  if q<>fail then
    # true quotient
    return [q,[[],fam!.oneCoefficient]];
  fi;

  q:=QuotientPolynomialsExtRep(fam,den,num);
  if q<>fail then
    # true quotient
    return [[[],fam!.oneCoefficient],q,num];
  fi;

  q:=HeuristicCancelPolynomialsExtRep(fam,num,den);
  if IsList(q) then
    # we got something
    num:=q[1];
    den:=q[2];
  fi;

  # special treatment if the denominator is a monomial
  if Length(den)=2 then
    # is the denominator a constant?
    if Length(den[1])>0 then
      q:=den[1];
      e:=q{[2,4..Length(q)]}; # the exponents
      q:=q{[1,3..Length(q)-1]}; # the indeterminate occurring
      IsSSortedList(q);
      i:=1;
      while i<Length(num) and ForAny(e,j->j>0) do
        cnt:=0; # how many indeterminates did we find
        for j in [1,3..Length(num[i])-1] do
          p:=Position(q,num[i][j]); # uses PositionSorted
          if p<>fail then
            cnt:=cnt+1; # found one
            e[p]:=Minimum(e[p],num[i][j+1]); # gcd via exponents
          fi;
        od;
        if cnt<Length(e) then
          e:=[0,0]; # not all indets found: cannot cancel!
        fi;
        i:=i+2;
      od;
      if ForAny(e,j->j>0) then
        # found a common monomial
        num:=ShallowCopy(num);
        for i in [1,3..Length(num)-1] do
          num[i]:=ShallowCopy(num[i]);
          for j in [1,3..Length(num[i])-1] do
            p:=Position(q,num[i][j]); # uses PositionSorted
            # is this an indeterminate, which gets reduced?
            if p<>fail then
              num[i][j+1]:=num[i][j+1]-e[p]; #reduce
            fi;
          od;

          # remove indeterminates with exponent zero
          sel:=[];
          for si in [2,4..Length(num[i])] do
            if num[i][si]>0 then
              Add(sel,si-1);
              Add(sel,si);
            fi;
          od;
          num[i]:=num[i]{sel};

        od;

        p:=ShallowCopy(den[1]);
        i:=[2,4..Length(p)];
        p{i}:=p{i}-e; # reduce exponents

        # remove indeterminates with exponent zero
        sel:=[];
        for si in i do
          if p[si]>0 then
            Add(sel,si-1);
            Add(sel,si);
          fi;
        od;
        p:=p{sel};

        den:=[p,den[2]]; #new denominator
      fi;
    fi;
    # remove the denominator coefficient
    if not IsOne(den[2]) then
      num:=ShallowCopy(num);
      for i in [2,4..Length(num)] do
        num[i]:=num[i]/den[2];
      od;
      den:=[den[1],fam!.oneCoefficient];
    fi;
  fi;

  return [num,den];
end;

BindGlobal( "DEGREE_INDET_EXTREP_POL", function(e,ind)
local d,i,j;
  e:=Filtered(e,IsList);
  d:=0; #the maximum degree so far
  for i in e do
    j:=1;
    while j<Length(i) do # searching the monomial
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
end );

#  LeadingCoefficient( pol, ind )
BindGlobal( "LEAD_COEF_POL_IND_EXTREP", function(e,ind)
local c,d,i,p;
  d:=0;
  c:=[];
  for i in [1,3..Length(e)-1] do
    # test whether the indeterminate does occur
    p:=PositionProperty([1,3..Length(e[i])-1],j->e[i][j]=ind);
    if p<>fail then
      p:=p*2-1; # from indext in [1,3..] to number
      if e[i][p+1]>d then
        d:=e[i][p+1]; # new, higher degree
        c:=[]; # start anew
      fi;
      if e[i][p+1]=d then
        # remaining monomial with coefficient
        Append(c,[e[i]{Difference([1..Length(e[i])],[p,p+1])},e[i+1]]);
      fi;
    fi;
  od;
  return c;
end );

#  PolynomialCoefficientsOfPolynomial(<pol>,<ind>)
BindGlobal( "POL_COEFFS_POL_EXTREP", function(e,ind)
local c,i,j,m,ex;
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
  return c;
end );
