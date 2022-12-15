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
InstallGlobalFunction( CyclotomicPol, MemoizePosIntFunction(
function( n )

    local f,   # result (after stripping off other cyclotomic polynomials)
          div, # divisors of 'n'
          d,   # one divisor of 'n'
          q,   # coefficients of a quotient that arises in division
          g,   # coefficients of 'd'-th cyclotomic polynomial
          l,   # degree of 'd'-th cycl. pol.
          m,
          i,
          c,
          k;

    # We have to compute the polynomial. Start with 'X^n - 1' ...
    f := List( [ 1 .. n ], x -> 0 );
    f[1]     := -1;
    f[ n+1 ] :=  1;

    div:= ShallowCopy( DivisorsInt( n ) );
    RemoveSet( div, n );

    # ... and divide by all 'd'-th cyclotomic polynomials
    # for proper divisors 'd' of 'n'.
    for d in div do
      q := [];
      g := CyclotomicPol( d );
      l := Length( g );
      m := Length( f ) - l;
      for i  in [ 0 .. m ]  do
        c := f[ m - i + l ] / g[ l ];
        for k  in [ 1 .. l ]  do
          f[ m - i + k ] := f[ m - i + k ] - c * g[k];
        od;
        q[ m - i + 1 ] := c;
      od;
      f:= q;
    od;

    # make the coefficients list immutable
    MakeImmutable( f );

    # return the coefficients list
    return f;
end ) );


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
