#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for univariate polynomials
##

#############################################################################
##
#M  IrrFacsPol(<f>) . . . lists of irreducible factors of polynomial over
##                        ring, initialize default
##
InstallMethod(IrrFacsPol,true,[IsPolynomial],0,f -> []);

#############################################################################
##
#F  StoreFactorsPol( <pring>, <upol>, <factlist> ) . . . . store factors list
##
InstallGlobalFunction(StoreFactorsPol,function(R,f,fact)
local irf;
  irf:=IrrFacsPol(f);
  if not ForAny(irf,i->i[1]=R) then
    Add(irf,[R,Immutable(fact)]);
  fi;
end);

#############################################################################
##
#M  IsIrreducibleRingElement(<pol>) . . . Irreducibility test for polynomials
##
InstallMethod(IsIrreducibleRingElement,"polynomial",IsCollsElms,
  [IsPolynomialRing,IsPolynomial],0,
function(R,f)
local d;
  if not IsUnivariatePolynomial(f) then
    TryNextMethod();
  fi;
  d:=DegreeOfLaurentPolynomial(f);
  if d=DEGREE_ZERO_LAURPOL then
    # the zero polynomial: irreducible elements are nonzero
    return false;
  elif d=0 then
    # constant polynomial -> refer to base ring
    f:=CoefficientsOfLaurentPolynomial(f)[1][1];
    return IsIrreducibleRingElement(LeftActingDomain(R),f);
  else
    return Length(Factors(R,f:  factoroptions:=
                    rec(stopdegs:=[1..DegreeOfLaurentPolynomial(f)-1]) ))<=1;
  fi;
end);

#############################################################################
##
#F  RootsOfUPol(<upol>) . . . . . . . . . . . . . . . . roots of a polynomial
##
InstallGlobalFunction( RootsOfUPol, function(arg)
local roots,factor,f,fact,fie,m,inum;
  roots:=[];
  f:=arg[Length(arg)];
  inum:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);
  if Length(arg)=1 then
    fact:=Factors(f);
  elif IsString(arg[1]) and arg[1]="split" then
    fie:=SplittingField(f);
    m:=List(IrrFacsPol(f),i->Maximum(List(i[2],DegreeOfLaurentPolynomial)));
    m:=IrrFacsPol(f)[Position(m,Minimum(m))][2];
    fact:=Concatenation(List(m,i->Factors(PolynomialRing(fie,[inum]),i)));
  else
    fact:=Factors(PolynomialRing(arg[1],[inum]),f);
  fi;
  for factor in fact do
    if DegreeOfLaurentPolynomial(factor)=1 then
      factor:=CoefficientsOfLaurentPolynomial(factor);
      if factor[2]=0 then
        Add(roots,-factor[1][1]/factor[1][2]);
      else
        Add(roots,0*factor[1][1]);
      fi;
    fi;
  od;
  return roots;
end );

#M  for factorization redisplatch if found out the polynomial is univariate
RedispatchOnCondition(Factors,true,[IsPolynomial],[IsUnivariatePolynomial],0);
RedispatchOnCondition(Factors,true,[IsRing,IsPolynomial],
  [,IsUnivariatePolynomial],0);
RedispatchOnCondition(IsIrreducibleRingElement,true,[IsRing,IsPolynomial],
  [,IsUnivariatePolynomial],0);


#############################################################################
##
#F  CyclotomicPol( <n> )  . . .  coefficients of <n>-th cyclotomic polynomial
##

# We use the following recursion formulae for CyclotomicPol(n)
# (see, e.g., Wikipedia).
#
# n prime: 1 + X + ... + X^{n-1}
# n = 2 k, k > 1 odd:  CyclotomicPol(k)(-X)
# n = p*m, (p,m)=1:  CyclotomicPol(m)(X^p) / CyclotomicPol(m)
# n = k * l with k|l: CyclotomicPol(l)(X^k)
# And CyclotomicPol(n) is palindromic for n > 2.
BindGlobal("CYCPOLCache", rec());
# Caching is only needed for non-prime squarefree odd numbers (see 1., 2.
# and 4. recursion rule above).
CYCPOLCache.CPdiffodd := function(ps)
    local len, str, a, l, blowup, res, n, m, k, iv, c, i;
    # Case of product of different odd primes,
    # given in list ps.
    # Caching non-trivial cases.
    len := Length(ps);
    if len = 0 then
      return [-1 ,1];
    fi;
    if len = 1 then
      return 1+0*[1..ps[1]];
    fi;
    str := Filtered(String(ps), c-> not c in " []");
    if IsBound(CYCPOLCache.(str)) then
      # we return mutable list, therefore ShallowCopy here
      return ShallowCopy(CYCPOLCache.(str));
    fi;
    a := CYCPOLCache.CPdiffodd(ps{[1..len-1]});
    l := 0*[1..ps[len]-1];
    # substitute X by X^ps[len]
    blowup := [a[1]];
    for i in [2..Length(a)] do
      Append(blowup, l);
      Add(blowup, a[i]);
    od;
    # divide blowup by a
    # need to do only first half because result is palindromic
    res := [];
    n := Length(blowup);
    m := Length(a);
    k := n-m+1;
    iv := n-m+[1..m];
    for i in [0..QuoInt(k,2)] do
      c := blowup[n-i];
      res[k-i] := c;
      res[i+1] := c;
      blowup{iv} := blowup{iv} - c*a;
      iv := iv-1;
    od;
    CYCPOLCache.(str) := Immutable(res);
    return res;
end;
InstallGlobalFunction( CyclotomicPol, function(n)
    local f, k, res, i, a, l;
    if n = 1 then
      return [-1, 1];
    fi;
    if IsPrime(n) then
      return 1+0*[1..n];
    fi;
    f := Collected(FactorsInt(n));
    k := Product(f, a-> a[1]^(a[2]-1));
    if f[1][1] = 2 then
      if Length(f) = 1 then
        res := [1, 1];
      else
        if Length(f) = 2 then
          res := 1+0*[1..f[2][1]];
        else
          # we cache result for non-prime squarefree odd numbers
          res := CYCPOLCache.CPdiffodd(List([2..Length(f)], i-> f[i][1]));
        fi;
        # substitute X by -X
        i := 2;
        while i <= Length(res) do
          res[i] := -res[i];
          i := i+2;
        od;
      fi;
    else
      res := CYCPOLCache.CPdiffodd(List(f, a-> a[1]));
    fi;
    if k > 1 then
      # substitute X by X^k
      a := res;
      l := 0*[1..k-1];
      res := [a[1]];
      for i in [2..Length(a)] do
        Append(res, l);
        Add(res, a[i]);
      od;
    fi;
    return res;
end);

############################################################################
##
#F  CyclotomicPolynomial( <F>, <n> ) . . . . . .  <n>-th cycl. pol. over <F>
##
##  returns the <n>-th cyclotomic polynomial over the ring <F>.
##
InstallGlobalFunction( CyclotomicPolynomial, function( F, n )

    local char;   # characteristic of 'F'

    if not IsInt( n ) or n <= 0 or not IsRing( F ) then
      Error( "<n> must be a positive integer, <F> a ring" );
    fi;

    char:= Characteristic( F );
    if char <> 0 then

      # replace 'n' by its $p^{\prime}$ part
      while n mod char = 0  do
        n := n / char;
      od;
    fi;
    return UnivariatePolynomial( F, One( F ) * CyclotomicPol(n) );
end );


#############################################################################
##
#M  IsPrimitivePolynomial( <F>, <pol> )
##
InstallMethod( IsPrimitivePolynomial,
    "for a (finite) field, and a polynomial",
    function( F1, F2 )
    return     HasCoefficientsFamily( F2 )
           and IsCollsElms( F1, CoefficientsFamily( F2 ) );
    end,
    [ IsField, IsRationalFunction ], 0,
    function( F, pol )

    local coeffs,      # coefficients of `pol'
          one,         # `One( F )'
          pmc,         # result of `PowerModCoeffs'
          size,        # size of mult. group of the extension field
          x,           # polynomial `x'
          p;           # loop over prime divisors of `size'

    # Check the arguments.
    if not IsPolynomial( pol ) then
      return false;
    elif not IsFinite( F ) then
      TryNextMethod();
    fi;

    coeffs:= CoefficientsOfUnivariatePolynomial( pol );
    one:= One( F );
    if IsZero( coeffs[1] ) or coeffs[ Length( coeffs ) ] <> one then
      return false;
    fi;

    size:= Size( F ) ^ ( Length( coeffs ) - 1 ) - 1;
    # make sure that compressed coeffs are used if input is compressed
    x:=  ShallowCopy(Zero( F ) * coeffs{[1,1]});
    x[2] :=  one;

    # Primitive polynomials divide the polynomial $x^{q^d-1} - 1$ \ldots
    pmc:= PowerModCoeffs( x, size, coeffs );
    ShrinkRowVector( pmc );
    if pmc <> [ one ] then
      return false;
    fi;

    # \ldots and are not divisible by $x^m - 1$
    # for proper divisors $m$ of $q^d-1$.
    if size <> 1 then
      for p in PrimeDivisors( size ) do
        pmc:= PowerModCoeffs( x, size / p, coeffs );
        ShrinkRowVector( pmc );
        if pmc = [ one ] then
          return false;
        fi;
      od;
    fi;

    return true;
    end );
