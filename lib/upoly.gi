#############################################################################
##
#W  upoly.gi                     GAP Library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains the  methods for univariate polynomials
##
Revision.upoly_gi:=
  "@(#)$Id$";

DOULP:=DegreeOfUnivariateLaurentPolynomial;

#############################################################################
##
#M  \<( <upol>, <upol> )  comparison
##
InstallMethod(\<,IsIdentical,
              [IsUnivariateLaurentPolynomial,IsUnivariateLaurentPolynomial],0,
function(a,b)
  a:=CoefficientsOfUnivariateLaurentPolynomial(a);
  a:=ShiftedCoeffs(a[1],a[2]);
  b:=CoefficientsOfUnivariateLaurentPolynomial(b);
  b:=ShiftedCoeffs(b[1],b[2]);
  return a<b;
end);

#############################################################################
##
#F  RandomPol( <fam>, <deg> )
##
RandomPol:=function(dom,deg)
local i,c;
  c:=[];
  for i in [0..deg] do
    Add(c,Random(dom));
  od;
  return UnivariateLaurentPolynomialByCoefficients(FamilyObj(c[1]),c,0,1);
end;

#############################################################################
##
#M  Value( <upol>, <elm> )
##
InstallMethod(Value,"Value LPol",true,
  [IsUnivariateLaurentPolynomial,IsRingElement],0,
function(f,x)
local val,i,id;
  id:=x^0;
  val:=Zero(id);
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  i:=Length(f[1]);
  while 0<i do
    val:=val*x+id*f[1][i];
    i:=i-1;
  od;
  if 0<>f[2]  then
    val:=val*x^f[2];
  fi;
  return val;
end);


#############################################################################
##
#M  Value( <upol>, <elm>, <one> )
##
InstallOtherMethod( Value,
    "method for univ. Laurent pol., ring element, and mult. neutral element",
    true,
    [ IsUnivariateLaurentPolynomial, IsRingElement, IsRingElement ], 0,
    function( f, x, one )
    local val, i;
    val:= Zero( one );
    f:= CoefficientsOfUnivariateLaurentPolynomial( f );
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
#M  LeadingCoefficient( <upol> )
##
InstallMethod(LeadingCoefficient,true,[IsUnivariateLaurentPolynomial],0,
function(f)
  if f=Zero(f) then
    return Zero(CoefficientsRing(FamilyObj(f)));
  fi;
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  return f[1][Length(f[1])];
end);

#############################################################################
##
#M  IrrFacsPol(<f>) . . . lists of irreducible factors of polynomial over
##                        ring
##
InstallMethod(IrrFacsPol,true,[IsPolynomial],0,f -> []);


#############################################################################
##
#M  EuclideanRemainder( <pring>, <upol>, <upol> )
##
InstallMethod(EuclideanRemainder,"EuclRemUnivPols",true,
	      [IsEuclideanRing,IsUnivariatePolynomial,
	       IsUnivariatePolynomial],0,
function(R,f,g)
local brci;
  brci:=BRCIUnivPols(f,g);
  if brci=fail then TryNextMethod();fi;
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);
  f:=ShiftedCoeffs(f[1],f[2]);
  g:=ShiftedCoeffs(g[1],g[2]);
  ReduceCoeffs(f,g);
  ShrinkCoeffs(f);
  return UnivariateLaurentPolynomialByCoefficients(brci[1],f,0,brci[2]);
end);

#############################################################################
##
#M  StandardAssociate( <pring>, <upol> )
##
InstallMethod(StandardAssociate,"StdAssoc Pol",true,[IsPolynomialRing,
                IsUnivariatePolynomial],0,
function(R,f)
local l,a,ind;

  l:=CoefficientsOfUnivariateLaurentPolynomial(f);
  ind:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);

  # <f> should be nontrivial
  if 0 < Length(l[1])  then

    # get standard associate of leading term
    a:=l[1][Length(l[1])];
    f:=f*Quotient(CoefficientsRing(R),
                  StandardAssociate(CoefficientsRing(R),a),a);
  fi;
  return f;
end);

#############################################################################
##
#M  Derivative( <upol> )
##
InstallMethod(Derivative,"DerivativePol",true,
                [IsUnivariateLaurentPolynomial],0,
function(f)
local d,i,ind;

  ind:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);
  d:=CoefficientsOfUnivariateLaurentPolynomial(f);
  if Length(d[1])=0 then
    # special case: Derivative of 0-Polynomial
    return f;
  fi;
  f:=d;
  d:=[];
  for i in [1..Length(f[1])]  do
      d[i] := (i+f[2]-1)*f[1][i];
  od;
  return UnivariateLaurentPolynomialByCoefficients(FamilyObj(f[1][1]),d,
                                                   f[2]-1,ind);
end);

#############################################################################
##
#M  QuotientRemainder( <pring>, <upol>, <upol> )
##
InstallMethod(QuotientRemainder,"QR Pol/Pol",true,[IsPolynomialRing,
                IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function (R,f,g)
local m,n,i,k,c,q,val,brci;
  brci:=BRCIUnivPols(f,g);
  if brci=fail then TryNextMethod();fi;
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  if f[2]<0  then
    Error("<f> must not be a laurent polynomial");
  fi;
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);
  if g[2]<0  then
    Error("<g> must not be a laurent polynomial");
  fi;

  # if <g> is zero signal an error
  if 0=Length(g[1]) then
    Error("<g> must not be zero");
  fi;

  # if <f> is zero return it
  if 0=Length(f[1])  then
    return UnivariateLaurentPolynomialByCoefficients(brci[1],[],0,brci[2]);
  fi;

  # remove the valuation of <f> and <g>
  f:=ShiftedCoeffs(f[1],f[2]);
  g:=ShiftedCoeffs(g[1],g[2]);

  # Try to divide <f> by <g>
  q := [];
  n := Length(g);
  m := Length(f) - n;
  for i  in [0..m]  do
      c := f[m-i+n] / g[n];
      for k  in [1..n]  do
	  f[m-i+k] := f[m-i+k] - c*g[k];
      od;
      q[m-i+1] := c;
  od;

  # return the polynomial
  return [UnivariateLaurentPolynomialByCoefficients(brci[1],q,0,brci[2]),
          UnivariateLaurentPolynomialByCoefficients(brci[1],f,0,brci[2])];

end);

#############################################################################
##
#M  Quotient( <upol>, <upol> )
##
QUOT_POLS:=function (f,g)
local m,n,i,k,c,q,val,brci;
  brci:=BRCIUnivPols(f,g);
  if brci=fail then TryNextMethod();fi;
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  if f[2]<0  then
    Error("<f> must not be a laurent polynomial");
  fi;
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);
  if g[2]<0  then
    Error("<g> must not be a laurent polynomial");
  fi;

  # if <g> is zero signal an error
  if 0=Length(g[1]) then
    Error("<g> must not be zero");
  fi;

  # if <f> is zero return it
  if 0=Length(f[1])  then
    return UnivariateLaurentPolynomialByCoefficients(brci[1],[],0,brci[2]);
  fi;

  # remove the valuation of <f> and <g>
  f:=ShiftedCoeffs(f[1],f[2]);
  g:=ShiftedCoeffs(g[1],g[2]);

  # Try to divide <f> by <g>
  q := [];
  n := Length(g);
  m := Length(f) - n;
  for i  in [0..m]  do
      c := f[m-i+n] / g[n];
      for k  in [1..n]  do
	  f[m-i+k] := f[m-i+k] - c*g[k];
      od;
      q[m-i+1] := c;
  od;

  ShrinkCoeffs(f);

  if Length(f)=0 then
    # return the polynomial
    return UnivariateLaurentPolynomialByCoefficients(brci[1],q,0,brci[2]);
  else
    return fail;
  fi;

end;

InstallMethod(Quotient,"Quotient Pol/Pol",true,[IsPolynomialRing,
   IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function(R,a,b)
  return QUOT_POLS(a,b);
end);
InstallOtherMethod(Quotient,"Quotient Pol/Pol",true,
         [IsUnivariatePolynomial,IsUnivariatePolynomial],0,QUOT_POLS);

#############################################################################
##
#M  QuotientMod( <pring>, <upol>, <upol>, <upol> )
##
InstallMethod(QuotientMod,"QuotientMod Pol/Pol mod Pol",true,
  [IsRing,IsRingElement,IsRingElement,IsRingElement],0,
function (R,r,s,m)
local f,g,h,fs,gs,hs,q,t;
    f := s;  fs := 1;
    g := m;  gs := 0;
    while g <> Zero(g) do
        t := QuotientRemainder(R,f,g);
        h := g;          hs := gs;
        g := t[2];       gs := fs - t[1]*gs;
        f := h;          fs := hs;
    od;
    q := Quotient(r,f);
    #AH
    if q = fail  then
        return fail;
    else
        return EuclideanRemainder(R,fs*q,m);
    fi;
end);

#############################################################################
##
#M  Gcd( <pring>, <upol>, <upol> ) . . . . . . . . . . gcd
##
InstallMethod(Gcd,"Gcd(Pol,Pol)",true,[IsEuclideanRing,
                IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function(R,f,g)
local gcd,u,v,w,val,brci;

  brci:=BRCIUnivPols(f,g);
  if brci=fail then TryNextMethod();fi;
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);

  # remove common x^i term
  val:=Minimum(f[2],g[2]);
  f:=ShiftedCoeffs(f[1],f[2]-val);
  g:=ShiftedCoeffs(g[1],g[2]-val);

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
  gcd:=u*u[Length(u)]^-1;

  # return the gcd
  return UnivariateLaurentPolynomialByCoefficients(brci[1],gcd,val,brci[2]);
end);


#############################################################################
##
#M  PowerMod( <pring>, <upol>, <exp>, <upol> )	. . . . power modulo
##
InstallMethod(PowerMod,"PowerModPol",true,
   [IsPolynomialRing,IsPolynomial,IsInt,IsPolynomial],0,
function(R,g,e,m)
local val,brci;

  brci:=BRCIUnivPols(g,m);
  if brci=fail then TryNextMethod();fi;

  # if <m> is of degree zero return the zero polynomial
  if DegreeOfUnivariateLaurentPolynomial(m) = 0  then
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

  g:=CoefficientsOfUnivariateLaurentPolynomial(g);
  m:=CoefficientsOfUnivariateLaurentPolynomial(m);

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
  g:=UnivariateLaurentPolynomialByCoefficients(brci[1],
		 PowerModCoeffs(g,e,m),val,brci[2]);
  return g;
end);

#############################################################################
##
#F  StoreFactorsPol( <pring>, <upol>, <factlist> ) . . . . store factors list
##
StoreFactorsPol:=function(R,f,fact)
local i,irf;
  irf:=IrrFacsPol(f);
  if not ForAny(irf,i->i[1]=R) then
    Add(irf,[R,fact]);
  fi;
end;


#############################################################################
##
#F  Discriminant( <f> ) . . . . . . . . . . . . discriminant of polynomial f
##
Discriminant := function(f)
local d;
  # the discriminant is \prod_i\prod_{j\not= i}(\alpha_i-\alpha_j), but
  # to avoid chaos with symmetric polynomials, we better compute it as
  # the resultant of f and f'
  d:=DegreeOfUnivariateLaurentPolynomial(f);
  return (-1)^(d*(d-1)/2)*Resultant(f,Derivative(f),
    IndeterminateNumberOfUnivariateLaurentPolynomial(f))/LeadingCoefficient(f);
end;

#############################################################################
##
#M  IsIrreducible(<pol>) . . . . Irreducibility test for polynomials
##
InstallMethod(IsIrreducible,"Pol",true,
  [IsPolynomialRing,IsPolynomial],0,
function(R,f)
  return Length(Factors(R,f))<=1;
end);


#############################################################################
##
#F  CyclotomicPol( <n> )  . . .  coefficients of <n>-th cyclotomic polynomial
##
CyclotomicPol := function( n )

    local f,   # result (after stripping off other cyclotomic polynomials)
          div, # divisors of 'n'
          d,   # one divisor of 'n'
          q,   # coefficiens of a quotient that arises in division
          g,   # coefficients of 'd'-th cyclotomic polynomial
          l,   # degree of 'd'-th cycl. pol.
          m,
          i,
          c,
          k;

    if not IsBound( CYCLOTOMICPOLYNOMIALS[ n ] ) then

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

      # store the coefficients list
      CYCLOTOMICPOLYNOMIALS[n]:= Immutable( f );
    else

      # just fetch the coefficients list
      f := CYCLOTOMICPOLYNOMIALS[n];
    fi;

    # return the coefficients list
    return f;
end;


############################################################################
##
#F  CyclotomicPolynomial( <F>, <n> ) . . . . . .  <n>-th cycl. pol. over <F>
##
##  returns the <n>-th cyclotomic polynomial over the ring <F>.
##
CyclotomicPolynomial := function( F, n )

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
end;


#############################################################################
##
#E  upoly.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
