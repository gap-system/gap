#############################################################################
##
#W  polyrat.gi                 GAP Library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions for polynomials over the rationals
##
Revision.polyrat_gi:=
  "@(#)$Id$";

#############################################################################
##
#F  APolyProd(<a>,<b>,<p>)   . . . . . . . . . . polynomial product a*b mod p
##
APolyProd := function(a,b,p)
local ac,bc,i,j,pc,pv,brci;

#return a*b mod p;

  brci:=BRCIUnivPols(a,b);
  a:=CoefficientsOfUnivariateLaurentPolynomial(a);
  b:=CoefficientsOfUnivariateLaurentPolynomial(b);

  pv:=a[2]+b[2];
  #pc:=ProductCoeffs(a.coefficients,b.coefficients);
  ac:=List(a[1],i->i mod p);
  bc:=List(b[1],i->i mod p);
  if Length(ac)>Length(bc) then
    pc:=ac;
    ac:=bc;
    bc:=pc;
  fi; 
  # prepare result list
  pc:=[];
  for i in [1..Length(ac)+Length(bc)-1] do
    pc[i]:=0;
  od;
  for i in [1..Length(ac)] do
    #pc:=SumCoeffs(pc,i*bc) mod p; 
    for j in [1..Length(bc)] do
      pc[i+j-1]:=(pc[i+j-1]+ac[i]*bc[j]) mod p;
    od;
  od;
  return UnivariateLaurentPolynomialByCoefficients(brci[1],pc,pv,brci[2]);
end;

#############################################################################
##
#F  BPolyProd(<a>,<b>,<m>,<p>) . . . . . . polynomial product a*b mod m mod p
##
BPolyProd := function(a,b,m,p)
local ac,bc,mc,i,j,pc,brci,f;

#return EuclideanRemainder(PolynomialRing(Rationals),a*b mod p,m) mod p;

  brci:=BRCIUnivPols(a,b);
  a:=CoefficientsOfUnivariateLaurentPolynomial(a);
  b:=CoefficientsOfUnivariateLaurentPolynomial(b);
  m:=CoefficientsOfUnivariateLaurentPolynomial(m);
  # we shift as otherwise the mod will mess up valuations (should occur
  # rarely anyhow)
  ac:=List(a[1],i->i mod p);
  ac:=ShiftedCoeffs(ac,a[2]);
  bc:=List(b[1],i->i mod p);
  bc:=ShiftedCoeffs(bc,b[2]);
  mc:=List(m[1],i->i mod p);
  mc:=ShiftedCoeffs(mc,m[2]);
  ReduceCoeffsMod(ac,mc,p);
  ShrinkCoeffs(ac);
  ReduceCoeffsMod(bc,mc,p);
  ShrinkCoeffs(bc);
  if Length(ac)>Length(bc) then
    pc:=ac;
    ac:=bc;
    bc:=pc;
  fi; 
  pc:=[];
  f:=false;
  for i in ac do
    if f then
      # only do it 2nd time (here to avoin doing once too often)
      bc:=ShiftedCoeffs(bc,1);
      ReduceCoeffsMod(bc,mc,p);
      ShrinkCoeffs(bc);
    else
      f:=true;
    fi;
    #pc:=SumCoeffs(pc,i*bc) mod p; 
    for j in [Length(pc)+1..Length(bc)] do
      pc[j]:=0;
    od;
    for j in [1..Length(bc)] do
      pc[j]:=(pc[j]+i*bc[j] mod p) mod p;
    od;
    ShrinkCoeffs(pc);
    ReduceCoeffsMod(pc,mc,p);
    ShrinkCoeffs(pc);
  od;
  return UnivariatePolynomialByCoefficients(brci[1],pc,brci[2]);
end;

#############################################################################
##
#F  RootRat: . . . . . . . . . . . . . . like RootInt, but also for rationals
##
RootRat := function(z)
  return RootInt(NumeratorRat(z))/(1+RootInt(DenominatorRat(z)-1));
end;


#############################################################################
##
#F  ApproxRational:  approximativ k"urzen
##
ApproxRational := function(r,s)
local n,d,u;
  n:=NumeratorRat(r);
  d:=DenominatorRat(r);
  u:=LogInt(d,10)-s+1;
  if u>0 then
    u:=10^u;
    return QuoInt(n,u)/QuoInt(d,u);
  else 
    return r;
  fi;
end;

#############################################################################
##
#F  ApproximateRoot(<num>,<n>[,<digits>]) . . approximate th n-th root of num
##   numerically with a denominator of 'digits' digits.
##
ApproximateRoot := function(arg)
local r,e,f,x,nf,lf,c;
  r:=arg[1];
  e:=arg[2];
  if Length(arg)>2 then
    f:=arg[3];
  else
    f:=10;
  fi; 
  x:=RootInt(NumeratorRat(r),e)/RootInt(DenominatorRat(r),e);
  nf:=r;
  c:=0;
  repeat
    lf:=nf;
    x:=ApproxRational(1/e*((e-1)*x+r/(x^(e-1))),f+6);
    nf:=AbsInt(x^e-r);
    if nf=0 then
      c:=6;
    else
      if nf>lf then
        lf:=nf/lf;
      else
        lf:=lf/nf;
      fi;
      if lf<2 then
        c:=c+1;
      else
        c:=0;
      fi;
    fi;
  # until 3 times no improvement
  until c>2;
  return x;
end;

#############################################################################
##
#F  ApproxRootBound(f) Numerical approximation of RootBound (better, but
##  may fail)
##
ApproxRootBound := function(f)
local pl,x,p,pc,tp,diff,app,d,scheit,loop,v,nkon;
  
  x:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);
  p:=CoefficientsOfUnivariateLaurentPolynomial(f);
  if p[2]<0 or not ForAll(p[1],IsRat) then
    # avoid complex conjugation etc.
    Error("only yet implemented for rational polynomials");
  fi;
  
  # eliminate valuation
  f:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,p[1],x);
  x:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,[0,1],x);

  # probably first test, whether polynomial should be inverted. However,
  # we expect roots larger than one.
  d:=DegreeOfUnivariateLaurentPolynomial(f);
  f:=Value(f,1/x)*x^d;
  app:=1/2;
  diff:=1/4;
  nkon:=true;
  repeat
    # pol, whose roots are the 1/app of the roots of f
    tp:=Value(f,x*app);
    tp:=CoefficientsOfUnivariateLaurentPolynomial(tp)[1];
    tp:=tp/tp[1];
    tp:=List(tp,i->ApproxRational(i,10));
    # now check, by using the Lehmer/Schur method, whether tp has a root
    # in the unit circle, i.e. f has a root in the app-circle
    repeat
      scheit:=false;
      p:=tp;
      repeat
        d:=Length(p);
        # compute T[p]=\bar a_n p-a_0 p*, everything rational.
        pl:=p;
        p:=p[1]*p-p[d]*Reversed(p);
        p:=List(p,i->ApproxRational(i,10));
        d:=Length(p);
        while d>1 and p[d]=0 do
          Unbind(p[d]);
          d:=d-1;
        od;
        v:=p[1];
        if v=0 then
          scheit:=nkon;
        fi;
        nkon:=ForAny(p{[2..Length(p)]},i->i<>0);
      until v<=0;
      if scheit then
        # we fail due to rounding errors
        return fail;
      else
        if v<0 then
          # zero in the unit circle, app smaller
          app:=app-diff;
        else
          # no zero in the unit circle, app larger
          app:=app+diff;
        fi;
      fi;
    until not scheit;
    diff:=diff/2;
  # until good circle found, which does not contain roots.
  until v=0 and (1-app/(app+diff))<1/40;

  # revert last enlargement and add accuracy to be secure
  app:=app-2*diff;
  return 1/app+1/20;
end;

#############################################################################
##
#F  RootBound(<f>) . . . . bound for absolute value of (complex) roots of f
##
RootBound := function(f)
local a,b,c,d;
  # valuation gives only 0 as zero, this can be neglected
  f:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];
  # normieren
  f:=f/f[Length(f)];
  f:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,f,1);

  a:=ApproxRootBound(f);
  # did the numerical part fail?
  if a=fail then
    c:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];
    c:=List(c,AbsInt);
    d:=Length(c);
    a:=Maximum(1,Sum(c{[1..d-1]}));
    b:=1+Maximum(c);
    if b<a then
      a:=b;
    fi;
    b:=Maximum(List([1..d-1],i->RootInt(d*Int(AbsInt(c[d-i])+1/2),i)+1)); 
    if b<a then
      a:=b;
    fi;
    if ForAll(c,i->i<>0) then
      b:=List([3..d],i->2*AbsInt(c[i-1]/c[i]));
      Add(b,AbsInt(c[1]/c[2]));
      b:=Maximum(b);
      if b<a then
	a:=b;
      fi;
    fi;
    b:=Sum([1..d-1],i->AbsInt(c[i]-c[i+1]))+AbsInt(c[1]);
    if b<a then
      a:=b;
    fi;
    b:=1/20+Maximum(List([1..d-1],
		i->RootInt(Int(AbsInt(c[d-i]/Binomial(d-1,i))+1/2),i)+1))
		   /(ApproximateRoot(2,d-1)-1)+10^(-10);
    if b<a then
      a:=b;
    fi;

  fi;
  return a;
end;

#############################################################################
##
#F  BombieriNorm(<pol>) . . . . . . . . . . . . compute weighted Norm [pol]_2
##
BombieriNorm := function(f)
local c,i,n,s;
  c:=CoefficientsOfUnivariateLaurentPolynomial(f);
  c:=ShiftedCoeffs(c[1],c[2]);
  n:=Length(c)-1;
  s:=0;
  for i in [0..n] do
    s:=s+AbsInt(c[i+1])^2/Binomial(n,i); 
  od;
  return ApproximateRoot(s,2);
end;

#############################################################################
##
#F  MinimizedBombieriNorm(<pol>) . . . . . . . minimize weighted Norm [pol]_2
##                                            by shifting roots
##
InstallMethod(MinimizedBombieriNorm,true,
   [IsPolynomial and IsRationalFunctionsFamilyElement],0,
function(f)
local bn,bnf,a,b,c,d,bb,bf,bd,step,x,cnt;

  step:=1;
  bb:=infinity;
  bf:=f;
  bd:=0;
  bn:=[];
  # evaluation of norm, including storing it (avoids expensive double evals)
  bnf := function(dis)
  local p,g;
    p:=Filtered(bn,i->i[1]=dis);
    if p=[] then
      g:=Value(f,x+dis);
      p:=[dis,BombieriNorm(g)];
      Add(bn,p);
      if bb>p[2] then
	# note record
	bf:=g;
	bb:=p[2];
	bd:=dis;
      fi;
      return p[2];
    else
      return p[1][2];
    fi;
  end;

  x:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,[0,1],
       IndeterminateNumberOfUnivariateLaurentPolynomial(f));
  d:=0;
  cnt:=0;
  repeat
    cnt:=cnt+1;
    Info(InfoPoly,2,"Minimizing BombieriNorm, x->x+(",d,")");
    # local parabola approximation
    a:=bnf(d-step);
    b:=bnf(d);
    c:=bnf(d+step);
    if a<b and c<b then
      if a<c then d:=d-step;
      else d:=d+step;
      fi;
    elif not(a>b and c>b) then
      a:=-(c-a)/2/(a+c-2*b)*step;
      # stets aufrunden (wir wollen weg)
      a:=step*Int(AbsInt(a)/step+1)*SignInt(a);
      if a=0 then
	Error("???");
      else
	d:=d+a;
      fi;
    fi;
  until (a>b and c>b) # no better can be reached
        or cnt>6
	or ForAll([d-1,d,d+1],i->Filtered(bn,j->j[1]=i)<>[]); #or loop
  # best value
  return [bf,bd];
end);

#############################################################################
##
#F  BeauzamyBound(<pol>) . . . . . Beauzamy's Bound for Factors Coefficients
##                                 cf. JSC 13 (1992), 463-472
##
BeauzamyBound := function(f)
local n;
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  return Int(
  # the strange number in the next line is an (upper) rational approximation
  # for 3^{3/4}/2/\sqrt(\pi)
  643038/1000000*ApproximateRoot(3^n,2)/ApproximateRoot(n,2)*BombieriNorm(f))+1;
end;

#############################################################################
##
#F  OneFactorBound(<pol>) . . . . . . . . . . . . Bound for one factor of pol
##
OneFactorBound := function(f)
local d,n;
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  if n>=3 then
    # Single factor bound of Beauzamy, Trevisan and Wang (1993)
    return Int(10912/10000*(ApproximateRoot(2^n,2)/ApproximateRoot(n^3,8)
           *(ApproximateRoot(BombieriNorm(f),2))))+1;
  else
    # Mignotte's single factor bound
    d:=QuoInt(n,2);
    return
    Binomial(d,QuoInt(d,2))
      *(1+RootInt(Sum(CoefficientsOfUnivariateLaurentPolynomial(f)[1],
                      i->i^2),2));
  fi;
end;

#############################################################################
##
#F  IntegerPolynomial(<R>,<f>) . . . remove denominator and coefficients gcd
##
IntegerPolynomial := function(R,f)
local lcm, c, fc;

  fc:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];
  # compute lcm of denominator
  lcm := 1;
  for c  in fc  do
    lcm := LcmInt(lcm,DenominatorRat(c));
  od;

  # remove all denominators
  f := f*lcm;
  fc:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];

  # remove gcd of coefficients
  return f*(1/Gcd(fc));

end;


#############################################################################
##
#F  BeauzamyBoundGcd(<f>,<g>) . . . . . Beauzamy's Bound for Gcd Coefficients
##
##  cf. JSC 13 (1992),463-472
##
BeauzamyBoundGcd := function(f,g)
  local   n, A, B;

  n := DegreeOfUnivariateLaurentPolynomial(f);
  # the   strange   number  in   the   next line  is   an  (upper) rational
  # approximation for 3^{3/4}/2/\sqrt(\pi)
  A := Int(643038/1000000
        * ApproximateRoot(3^n,2)/ApproximateRoot(n,2)
        * BombieriNorm(f/LeadingCoefficient(f)))+1;

  # the   strange  number   in  the   next   line is  an   (upper) rational
  # approximation for 3^{3/4}/2/\sqrt(\pi)
  n := DegreeOfUnivariateLaurentPolynomial(g);
  B := Int(643038/1000000
        * ApproximateRoot(3^n,2)/ApproximateRoot(n,2)
        * BombieriNorm(f/LeadingCoefficient(g)))+1;
  return GcdInt(LeadingCoefficient(f),LeadingCoefficient(g))
       * Minimum(A,B);

end;


#############################################################################
##
#F  RPGcdModPrime(<R>,<f>,<g>,<p>,<a>,<brci>)  . . gcd mod <p>
##
RPGcdModPrime := function(R,f,g,p,a,brci)
local gcd, u, v, w, val, r, s, e;
  
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);
  # compute in the finite field F_<p>
  val := Minimum(f[2], g[2]);
  s   := ShiftedCoeffs(f[1],f[2]-val);
  r   := ShiftedCoeffs(g[1],g[2]-val);
  ReduceCoeffsMod(s,p);  ShrinkCoeffs(s);
  ReduceCoeffsMod(r,p);  ShrinkCoeffs(r);
  
  # compute the gcd
  u := r;
  v := s;
  while 0 < Length(v)  do
    w := v;
    ReduceCoeffsMod(u,v,p);
    ShrinkCoeffs(u);
    v := u;
    u := w;
  od;
  gcd := u * (a/u[Length(u)]);
  ReduceCoeffsMod(gcd,p);

  # and return the polynomial
  return UnivariateLaurentPolynomialByCoefficients(brci[1],gcd,val,brci[2]);

end;


RPGcdCRT := function(f,p,g,q,brci)
local min, cf, lf, cg, lg, i, P, m, r;

  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);
  # remove valuation
  min := Minimum(f[2],g[2]);
  if f[2] <> min  then 
    cf := ShiftedCoeffs(f[1],f[2] - min);
  else
    cf := ShallowCopy(f[1]);
  fi;
  lf := Length(cf);
  if g[2] <> min  then 
    cg := ShiftedCoeffs(g[1],g[2] - min);
  else
    cg := ShallowCopy(g[1]);
  fi;
  lg := Length(cg);

  # use chinese remainder
  r := [ p,q ];
  P := p * q;
  m := P/2;
  for i  in [ 1 .. Minimum(lf,lg) ]  do
    cf[i] := ChineseRem(r,[ cf[i],cg[i] ]);
    if m < cf[i]  then cf[i] := cf[i] - P;  fi;
  od;
  if lf < lg  then
    for i  in [ lf+1 .. lg ]  do
      cf[i] := ChineseRem(r,[ 0,cg[i] ]);
      if m < cf[i]  then cf[i] := cf[i] - P;  fi;
    od;
  elif lg < lf  then
    for i  in [ lg+1 .. lf ]  do
      cf[i] := ChineseRem(r,[ cf[i],0 ]);
      if m < cf[i]  then cf[i] := cf[i] - P;  fi;
    od;
  fi;

  # return the polynomial
  return UnivariateLaurentPolynomialByCoefficients(brci[1],cf,min,brci[2]);

end;


RPGcd1 := function(R,t,a,f,g)
local G, P, l, m, i;

  # <P> will hold the product of primes use so far
  t.modulo := t.prime;

  # <G> will hold the approximation of the gcd
  G := t.gcd;

  # use next prime until we reach the Beauzamy bound
  while t.modulo < t.bound  do
    repeat t.prime := NextPrimeInt(t.prime);  until a mod t.prime <> 0;

    # compute modular gcd
    t.gcd := RPGcdModPrime(R,f,g,t.prime,a,t.brci);
    Info(InfoPoly,3,"gcd mod ",t.prime," = ",t.gcd);

    # if the degree of <C> is smaller we started with wrong <p>
    if DegreeOfUnivariateLaurentPolynomial(t.gcd)
       < DegreeOfUnivariateLaurentPolynomial(G)
    then
      Info(InfoPoly,3,"found lower degree,restarting");
      return false;
    fi;

    # if the degrees of <C> and <G> are equal use chinese remainder
    if DegreeOfUnivariateLaurentPolynomial(t.gcd) 
       = DegreeOfUnivariateLaurentPolynomial(G)
    then
      P := G;
      G := RPGcdCRT(G,t.modulo,t.gcd,t.prime,t.brci);
      t.modulo := t.modulo * t.prime;
      Info(InfoPoly,3,"gcd mod ",t.modulo," = ",G);
      if G = P  then
        t.correct :=   Quotient(R,f,G)<>fail
               and Quotient(R,g,G)<>fail;
        if t.correct  then
          Info(InfoPoly,3,"found correct gcd");
          t.gcd := G;
          return true;
        fi;
      fi;
    fi;
  od;

  # get <G> into the -<t.modulo>/2 to +<t.modulo> range
  G:=CoefficientsOfUnivariateLaurentPolynomial(G);
  l := [];
  m := t.modulo/2;
  for i  in [ 1 .. Length(G[1]) ]  do
    if m < G[1][i]  then
      l[i] := G[1][i] - t.modulo;
    else
      l[i] := G[1][i];
    fi;
  od;
  G := UnivariateLaurentPolynomialByCoefficients(t.brci[1],l,G[2],t.brci[2]);
  Info(InfoPoly,3,"gcd mod ",t.modulo," = ",G);

  # check if <G> is correct but return 'true' in any case
  t.correct := Quotient(R,f,G) <> fail and Quotient(R,g,G) <> fail;
  t.gcd := G;
  return true;

end;


RPIGcd := function(R,f,g)
local a,t;

  # compute the Beauzamy bound for the gcd
  t := rec(prime := 1000);
  t.brci:=BRCIUnivPols(f,g);

  t.bound := 2 * Int(BeauzamyBoundGcd(f,g)+1);
  Info(InfoPoly,3,"Beauzamy bound = ",t.bound/2);

  # avoid gcd of leading coefficients
  a := GcdInt(LeadingCoefficient(f),LeadingCoefficient(g));
  repeat

    # start with first prime avoiding gcd of leading coefficients
    repeat t.prime := NextPrimeInt(t.prime);  until a mod t.prime <> 0;

    # compute modular gcd with leading coefficient <a>
    t.gcd := RPGcdModPrime(R,f,g,t.prime,a,t.brci);
    Info(InfoPoly,3,"gcd mod ",t.prime," = ",t.gcd);

    # loop until we have success
    repeat
      if 0 = DegreeOfUnivariateLaurentPolynomial(t.gcd)  then
        Info(InfoPoly,3,"<f> and <g> are relative prime");
        return One(f);
      fi;
    until RPGcd1(R,t,a,f,g);
  until t.correct;

  # return the gcd
  return t.gcd;

end;


#############################################################################
##
#F  Gcd(<R>,<f>,<g>)  for rational polynomials
##
InstallMethod(Gcd,"RatPol",true,
  [IsRationalsPolynomialRing and IsEuclideanRing,
   IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function(R,f,g)

  if BRCIUnivPols(f,g)=fail then TryNextMethod();fi;
  # check trivial cases
  if -1 = DegreeOfUnivariateLaurentPolynomial(f)  then
    return g;
  elif -1 = DegreeOfUnivariateLaurentPolynomial(g)  then
    return f;
  elif 0 = DegreeOfUnivariateLaurentPolynomial(f)
       or 0 = DegreeOfUnivariateLaurentPolynomial(g)
  then
    return One(f);
  fi;

  # convert polynomials into integer polynomials
  f := IntegerPolynomial(R,f);
  g := IntegerPolynomial(R,g);
  Info(InfoPoly,3,"<f> = ",f);
  Info(InfoPoly,3,"<g> = ",g);

  # return the standard associate
  return StandardAssociate(R,RPIGcd(R,f,g));

end);

InstallMethod(\mod,"poly MOD int",true,[IsUnivariatePolynomial,IsInt],0,
function(f,p)
local c;
  c:=CoefficientsOfUnivariateLaurentPolynomial(f);
  c:=[List(c[1],i->i mod p),c[2]];
  return UnivariateLaurentPolynomialByCoefficients(
      CoefficientsFamily(FamilyObj(f)),c[1],c[2],
      IndeterminateNumberOfUnivariateLaurentPolynomial(f));
end);

#############################################################################
##
#F  RPQuotientModPrime(<R>,<f>,<g>,<p>) . . .  quotient
##
RPQuotientModPrime := function(R,f,g,p)
local   m, n, i, k, c, q, val, fc,gc,brci;

  # get base ring
  brci:=BRCIUnivPols(f,g);

  # reduce <f> and <g> mod <p>
  f := f mod p;
  g := g mod p;

  fc:=CoefficientsOfUnivariateLaurentPolynomial(f);
  gc:=CoefficientsOfUnivariateLaurentPolynomial(g);

  # if <f> is zero return it
  if 0 = Length(fc[1])  then
    return f;
  fi;

  # check the value of the valuation of <f> and <g>
  if fc[2] < gc[2]  then
    return false;
  fi;
  val := fc[2]-gc[2];

  # Try to divide <f> by <g>,compute mod <p>
  q := [];
  n := Length(gc[1]);
  m := Length(fc[1]) - n;
  gc:=gc[1];
  f := ShallowCopy(fc[1]);
  for i  in [0..m]  do
    c := f[m-i+n]/gc[n] mod p;
    for k  in [1..n]  do
      f[m-i+k] := (f[m-i+k] - c*gc[k]) mod p;
    od;
    q[m-i+1] := c;
  od;

  # Did the division work?
  for i  in [ 1 .. m+n ]  do
    if f[i] <> Zero(brci[1]) then
      return false;
    fi;
  od;
  return UnivariateLaurentPolynomialByCoefficients(brci[1],q,val,brci[2]);

end;


#############################################################################
##
#F  RPGcdRepresentationModPrime(<R>,<f>,<g>,<p>)  . gcd
##
RPGcdRepresentationModPrime := function(R,f,g,p)

  local   val,     # the minimal valuation of <f> and <g>
      s, sx,    # first line of gcd algorithm
      t, tx,    # second line of gcd alogrithm
      h, hx,    # temp for swapping lines
      q,       # quotient
      n,m,r,c,  # used in quotient
      brci,	
      i,k;       # loops

  Info(InfoPoly,3,"f=",f,"g=",g);
  # get base ring
  brci:=BRCIUnivPols(f,g);

  # remove common x^i term
  f:=CoefficientsOfUnivariateLaurentPolynomial(f);
  g:=CoefficientsOfUnivariateLaurentPolynomial(g);

  val:=Minimum(f[2],g[2]);
  f  :=ShiftedCoeffs(f[1],f[2]-val);
  g  :=ShiftedCoeffs(g[1],g[2]-val);
  ReduceCoeffsMod(f,p);  ShrinkCoeffs(f);
  ReduceCoeffsMod(g,p);  ShrinkCoeffs(g);
  
  # compute the gcd and representation mod <p>
  s := ShallowCopy(f);  sx := [ One(brci[1]) ];
  t := ShallowCopy(g);  tx := [];
  while 0 < Length(t)  do
    Info(InfoPoly,3,"<s> = ",s,", <sx> = ",sx,"\n",
           "#I  <t> = ",t,", <tx> = ",tx);

    # compute the euclidean quotient of <s> by <t>
    q := [];
    n := Length(t);
    m := Length(s) - n;
    r := ShallowCopy(s);
    for i  in [ 0 .. m ]  do
      c := r[m-i+n] / t[n] mod p;
      for k  in [ 1 .. n ]  do
        r[m-i+k] := (r[m-i+k] - c * t[k]) mod p;
      od;
      q[m-i+1] := c;
    od;
    Info(InfoPoly,3,"<q> = ",q);
    
    # update representation
    h  := t;
    hx := tx;
    t  := s;
    AddCoeffs(t,ProductCoeffs(q,h),-1);
    ReduceCoeffsMod(t,p);
    ShrinkCoeffs(t);
    tx := sx;
    AddCoeffs(tx,ProductCoeffs(q,hx),-1);
    ReduceCoeffsMod(tx,p);
    ShrinkCoeffs(tx);
    s  := h;     
    sx := hx;
  od;
  Info(InfoPoly,3,"<s> = ",s,", <sx> = ",sx);

  # compute conversion for standard associate
  q := (1/s[Length(s)]) mod p;
  
  # convert <s> and <x> back into polynomials
  if 0 = Length(g)  then
    sx := q * sx;
    ReduceCoeffsMod(sx,p);
    return [ UnivariateLaurentPolynomialByCoefficients(brci[1],sx,0,brci[2]),
         Zero(brci[1]) ];
  else
    hx := q * sx;
    ReduceCoeffsMod(hx,p);
    hx := UnivariateLaurentPolynomialByCoefficients(brci[1],hx,0,brci[2]);
    AddCoeffs(s,ProductCoeffs(sx,f),-1);
    s := q * s;
    ReduceCoeffsMod(s,p);
    s := UnivariateLaurentPolynomialByCoefficients(brci[1],s,0,brci[2]);
    g := UnivariateLaurentPolynomialByCoefficients(brci[1],g,0,brci[2]);
    q := RPQuotientModPrime(R,s,g,p);
    return [ hx,q ];
  fi;

end;


#############################################################################
##
#F  HenselBound(<pol>,[<minpol>,<den>]) . . . Bounds for Factor coefficients
##    if the computation takes place over an algebraic extension, then
##    minpol and denominator must be given
##
HenselBound := function(arg)
local pol,n,nalpha,d,dis,rb,bound,a,i,j,k,l,w,bin,lm,lb,bea,polc;

  pol:=arg[1];
  if Length(arg)>1 then
    n:=arg[2];
    d:=arg[3];

    dis:=Discriminant(n);
    nalpha:=RootBound(n); # bound for norm of \alpha.

    polc:=CoefficientsOfUnivariateLaurentPolynomial(pol)[1];
    if not ForAll(polc,IsRat) then
      # now try to bound the roots of f accordingly. As in all estimates by
      # RootBound only the absolute value of the coefficients is used, we will
      # estimate these first, and replace f by the polynomial
      # x^n-b_{n-1}x^(n-1)-...-b_0 whose roots are certainly larger
      a:=[];
      for i in polc do
        # bound for coefficients of pol
        if IsRat(i) then
          Add(a,AbsInt(i));
        else
          Add(a,Sum(i.coefficients,AbsInt)*nalpha);
        fi;
      od;
      a:=-a;
      a[Length(a)]:=-a[Length(a)];
      pol:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,a,1);
    else
      pol:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,polc,1);
    fi;
    n:=DOULP(n);
  else
    n:=1;
  fi;

  bound:=[];
  rb:=0;
  #BeauzamyBound
  bea:=BeauzamyBound(pol);
  # compute Landau-Mignotte bound for absolute values of
  # coefficients of any factor
  polc:=CoefficientsOfUnivariateLaurentPolynomial(pol)[1];
  w:=Sum(polc,i->i^2);
  # we want an upper bound of the root, RootInt will give a lower
  # bound. So we compute the root of w-1 (in case w is a perfect square)
  # and add 1. As we nowhere selected a specific galois representative,
  # this bound (which is rational!) will bound all conjugactes as well.
  lm:=(RootInt(Int(w)-1,2)+1);
  lb:=2^QuoInt(DOULP(pol),2)*lm;
  for k in [1..DOULP(pol)] do

    l:=2^k*lm;
    if l<bea then
      w:=l;
    else
      w:=bea;
    fi;

    #if lb>10^30 or n>1 then
    if bea>10^200 or n>1 then
      if rb=0 then
        rb:=RootBound(pol);
        a:=rb;
      fi;
      # now try factor deg k
      bin:=1;
      for j in [1..k] do
        bin:=bin*(k-j+1)/j;
        w:=bin*rb^j;
        if w>a then
          a:=w;
        fi;
      od;

      # select the better bound
      if a<l then
        w:=a;
      else
        w:=l;
      fi;
    fi;

    if n>1 then
      # algebraic Extension case
      # finally we have to bound (again) the coefficients of \alpha when
      # writing the coefficients of the factor as \sum c_i/d\alpha^i.
      w:=Int(d*w*Factorial(n)/RootRat(AbsInt(dis))*nalpha^(n*(n-1)/2))+1;
    fi;

    bound[k]:=Int(w)+1;
  od;
  return bound;
end;

IsAlgExtElm:=ReturnFalse;

#############################################################################
##
#F  CoeffAbs(<a>) . maximal coefficient in representation of algebraic elm. a
##
CoeffAbs := function(e)
  if IsAlgExtElm(e) then
    return Maximum(List(e.coefficients,i->AbsInt(NumeratorRat(i))));
  else
    return AbsInt(NumeratorRat(e));
  fi;
end;

#############################################################################
##
#F  TrialQuotient(<f>,<g>,<b>)  . . . . . . f/g if coeffbounds are given by b
##
TrialQuotient := function(f,g,b)
local  fc,gc,a,m, n, i, k, c, q, val, brci;
  brci:=BRCIUnivPols(f,g);
  a:=DOULP(f)
    -DOULP(g);
  fc:=CoefficientsOfUnivariateLaurentPolynomial(f);
  gc:=CoefficientsOfUnivariateLaurentPolynomial(g);
  if a=0 then
    # Special case (that has to return 0)
    a:=b[1];
  else
    a:=b[a]; 
  fi;
  if 0=Length(fc[1]) then
    return f;
  fi;
  if fc[2]<gc[2] then
    return fail;
  fi;
  val:=fc[2]-gc[2];
  q:=[];
  n:=Length(gc[1]);
  m:=Length(fc[1])-n;
  f:=ShallowCopy(ShiftedCoeffs(fc[1],fc[2]));
  gc:=gc[1];
#  if IsField(R) then
    for i in [0..m] do
      c:=f[(m-i+n)]/gc[n];
      if CoeffAbs(c)>a then 
        Info(InfoPoly,3,"early break\n");
        return fail;
      fi;
      for k in [1..n] do
        f[m-i+k]:=f[m-i+k]-c*gc[k];
      od;
      q[m-i+1]:=c;
    od;
#  else
#    for i in [0..m] do
#      c:=Quotient(R,f[m-i+n],gc[n]);
#      if c=fail then
#        return fail;
#      fi;
#      if CoeffAbs(c)>a then 
#        Info(InfoPoly,3,"early break\n");
#        return fail;
#      fi;
#      for k in [1..n] do
#        f[m-i+k]:=f[m-i+k]-c*g.coefficients[k];
#        if CoeffAbs(f[m-i+k])>b then
#          Info(InfoPoly,3,"early break\n");
#          return fail;
#        fi;
#      od;
#      q[m-i+1]:=c;
#    od;
#  fi;
  k:=Zero(f[1]);
  for i in [1..m+n] do
    if f[i]<>k then
      return fail;
    fi;
  od;
  return UnivariateLaurentPolynomialByCoefficients(brci[1],q,val,brci[2]);
end;


#############################################################################
##
#F  TryCombinations(<f>,...)  . . . . . . . . . . . . . . . .  try factors
##
TryCombinations := function(f,lc,l,p,t,bounds,opt,split)
local  p2, res, j, i,ii,o,d,b,lco,degs, step, c, cnew, sel, deli,
     degf, good, act, da, prd, cof, q, combi,mind,binoli,alldegs;

  alldegs:=t.degrees;
  # <res> contains the irr/reducible factors and the remaining ones
  res:=rec(irreducibles:=[],
	    irrFactors  :=[],
	    reducibles  :=[],
	    redFactors  :=[],
	    remaining   :=[ 1 .. Length(l) ]);

  # coefficients should be in -<p>/2 and <p>/2
  p2  :=p/2;
  deli:=List(l,DOULP);

  # sel are the still selected indices
  sel:=[ 1 .. Length(l) ];

  # create List of binomial coefficients to speed up the 'Combinations' process
  binoli:=[];
  for i in [0..Length(l)-1] do
  binoli[i+1]:=List([0..i],j->Binomial(i,j));
  od;

  step:=0;
  act :=1;
  repeat

  # factors of larger than half remaining degree we will find as
  # final cofactor
  degf:=DOULP(f);
  degs:=Filtered(alldegs,i -> 2*i<=degf);
  if IsBound(opt.onlydegs) then
    degs:=Intersection(degs,opt.onlydegs);
    Info(InfoPoly,3,"degs=",degs);
  fi;

  if act in sel  then

    # search all combinations of Length step+1 containing the act-th
    # factor,that are allowed
    good:=true;
    da:=List(degs,i -> i-deli[act]);

    # check,whether any combination will be of suitable degree

    cnew:=Set(deli{Filtered(sel,i->i>act)});

    if ForAny(da,i->NrRestrictedPartitions(i,cnew,step)>0) then
	# as we have all combinations including < <act>,we can skip them
	Info(InfoPoly,2,"trying length ",step+1," containing ",act);
	cnew:=Filtered(sel,i -> i > act);
    else
	Info(InfoPoly,2,"length ",step+1," containing ",act," not feasible");
	cnew:=[];
    fi;

    mind:=Sum(deli); # the maximum of the possible degrees. We surely
             # will find something smaller

    lco:=Binomial(Length(cnew),step);
    if 0 = lco  then
    # fix mind to make sure,we don't erroneously eliminate the factor
	mind:=0;
    else
	Info(InfoPoly,2,lco," combinations");
	i:=1;
	while good and i<=lco  do

	  # try combination number i
	  # combi:=CombinationNr(cnew,step,i);

	  q:=i;
	  d:=Length(cnew); # the remaining Length
	  o:=0;
	  combi:=[];
	  for ii in [step-1,step-2..0] do
	  j:=1;
	  b:=binoli[d][ii+1];
	  while q>b do
	    q:=q-b;
	    # compute b:=Binomial(d-(j+1),ii);
	    b:=b*(d-j-ii)/(d-j);
	    j:=j+1;
	  od;
	  o:=j+o;
	  d:=d-j;
	  Add(combi,cnew[o]);
	  od;

	  # check whether this yields a minimal degree
	  d:=Sum(deli{combi});
	  if d<mind then
	  mind:=d;
	  fi;

      if d in da then
	  AddSet(combi,act); # add the 'always' factor

	  # make sure that the quotient has a chance,compute the
	  # extremal coefficient of the product:
	  q:=(ProductMod(List(l{combi},
	      i->CoefficientsOfUnivariateLaurentPolynomial(i)[1][1]),
		   p) * lc) mod p;
	  if p2 < q  then
	    q:=q - p;
	  fi;

	  # As  we  don't  know  yet  the gcd  of  all the products
	  # coefficients (to make it  primitive),we do  a slightly
	  # weaker test:  (test of  leading   coeffs is  first   in
	  # 'TrialQuotient') this just should  reduce the number of
	  # 'ProductMod' neccessary.   the  absolute  part  of  the
	  # product must  divide  the absolute  part of  f  up to a
	  # divisor of <lc>
	  q:=CoefficientsOfUnivariateLaurentPolynomial(f)[1][1] / q * lc;
	  if not IsInt(q)  then
	    Info(InfoPoly,3,"ignoring combination ",combi);
	    q:=fail;
	  else
	    Info(InfoPoly,2,"testing combination ",combi);

	    # compute the product and reduce
	    prd:=ProductMod(l{combi},p);
	    prd:=CoefficientsOfUnivariatePolynomial(prd);
	    cof:=[];
	    for j  in [ 1 .. Length(prd) ]  do
		  cof[j]:=(lc*prd[j]) mod p;
		  if p2 < cof[j]  then
		    cof[j]:=cof[j] - p;
		  fi;
	    od;

	    # make the product primitive
	    cof:=cof * (1/Gcd(cof));
	    prd:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,
	      cof,t.ind);
	    q:=TrialQuotient(f,prd,bounds);
	  fi;

	  if q <> fail  then
	    f:=q;
	    Info(InfoPoly,2,"found true factor of degree ",DOULP(prd));
	    if Length(combi)=1 or split  then
		q:=0;
	    else
		q:=2*lc*OneFactorBound(prd);
		if q <= p  then
		  Info(InfoPoly,2,"proven irreducible by 'OneFactorBound'");
		fi;
	    fi;

	    # for some reason,we know,the factor is irred.
	    if q <= p  then
		Append(res.irreducibles,combi);
		Add(res.irrFactors,prd);

		if IsBound(opt.stopdegs) and DOULP(prd) in opt.stopdegs then
		  Info(InfoPoly,2,"hit stopdegree");
		  Add(res.redFactors,f);
		  res.stop:=true;
		  return res;
		fi;

	    else
		Add(res.reducibles,combi);
		Add(res.redFactors,prd);
	    fi;
	    SubtractSet(res.remaining,combi);
	    good:=false;
	    SubtractSet(sel,combi);
	  fi;

	  fi;
	  i:=i+1;

	od;
    fi;

    # we can forget about the actual factor,as any longer combination
    # is too big
    if Length(degs)>1 and deli[act]+mind >= Maximum(degs)  then
	Info(InfoPoly,2,"factor ",act," can be further neglected");
	sel:=Difference(sel,[act]);
    fi;

  fi;

  # consider next factor
  act:=act + 1;
  if 0 < Length(sel) and act>Maximum(sel)  then
    step:=step+1;
    act :=sel[1];
  fi;

  # until nothing is left
  until 0 = Length(sel) or Length(sel)<step;

  # if <split> is true we *must* find a complete factorization. 
  if split and 0 < Length(res.remaining) and f<>f^0 then
#and not(IsBound(opt.onlydegs) or IsBound(opt.stopdegs)) then

    # the remaining f must be an irreducible factor,larger than deg/2
    Append(res.irreducibles,res.remaining);
    res.remaining:=[];
    Add(res.irrFactors,f);
  fi;

  # return the result
  return res;

end;


#############################################################################
##
#F  RPSquareHensel(<R>,<f>,<t>,<opt>)
##
RPSquareHensel := function(R,f,t,opt)

  local   p,       # prime
      q,       # current modulus
      q1,      # last modulus
      l,       # factorization mod <q>
      lc,      # leading coefficient of <f>
      bounds,    # Bounds for Factor Coefficients
      ofb,     # OneFactorBound
      k,       # Lift boundary
      prd,     # product of <l>
      rep,     # lifted representation of gcd(<lp>)
      fcn,     # index of true factor in <l>
      dis,     # distance of <f> and <l>
      cor,     # correction
      rcr,     # inverse corrections
      quo,     # quotient
      sum,     # temp
      aa, bb,   # left and right subproducts
      lq1,     # factors mod <q1>
      max,     # maximum absolute coefficient of <f>
      res,     # result
      gcd,     # used in gcd representation
      i, j, x;    # loop

  # get <l> and <p>
  l:=t.factors;
  p:=t.prime;

  # get the leading coefficient of <f>
  lc:=LeadingCoefficient(f);
  
  # and maximal coefficient
  max:=Maximum(List(CoefficientsOfUnivariatePolynomial(f),AbsInt));

  # compute the factor coefficient bounds
  ofb:=2*AbsInt(lc)*OneFactorBound(f);
  Info(InfoPoly,2,"One factor bound = ",ofb);
  bounds:=2*AbsInt(lc)*HenselBound(f);
  k:=bounds[Maximum(Filtered(t.degrees,i-> 2*i<=DOULP(f)))];
  Info(InfoPoly,2,"Hensel bound = ",k);

  # compute a representation of the 1 mod <p>
  Info(InfoPoly,2,"computing gcd representation: ",Runtime());
  prd:=(1/lc * f) mod p;
  gcd:=RPQuotientModPrime(R,prd,l[1],p);
  rep:=[ One(R) ];
  for i  in [ 2 .. Length(l) ]  do
    dis:=RPQuotientModPrime(R,prd,l[i],p);
    cor:=RPGcdRepresentationModPrime(R,gcd,dis,p);
    gcd:=(cor[1] * gcd + cor[2] * dis) mod p;
    rep:=List(rep,z -> z * cor[1] mod p);
    Add(rep,cor[2]);
  od;
  Info(InfoPoly,2,"representation computed:    ",Runtime());

  # <res> will hold our result
  res:=rec(irrFactors:=[], redFactors:=[], remaining:=[],
        bounds:=bounds);
  
  # start Hensel until <q> is greater than k
  q  :=p^2;
  q1 :=p;
  while q1 < k  do
    Info(InfoPoly,2,"computing mod ",q);

    for i in [ 1 .. Length(l) ]  do
      dis:=List(CoefficientsOfUnivariatePolynomial(f),i->i/lc mod q);
      ReduceCoeffsMod(dis,CoefficientsOfUnivariatePolynomial(l[i]),q);
  #dis:=EuclideanRemainder(PolynomialRing(Rationals),dis,l[i]) mod q;
  #dis:=CoefficientsOfUnivariatePolynomial(dis);
      dis:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,dis,t.ind);
      l[i]:=l[i] + BPolyProd(rep[i],dis,l[i],q);
    od;

    # NOCH: Assert und leading coeff
    #if not ForAll(CoefficientsOfUnivariateLaurentPolynomial(Product(l)-f)[1],
    #        i->i mod q=0) then
    #  Error("not product modulo q");
    #fi;

    # if this is not the last step update <rep> and check for factors
    if q < k  then

      # correct the inverses
      for i  in [ 1 .. Length(l) ]  do
        if Length(l)=1 then
          dis:=l[1]^0;
        else
          dis:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,
	                                          [1],t.ind);
          for j in  Difference([1..Length(l)],[i])  do
            dis:=BPolyProd(dis,l[j],l[i],q);
          od;
        fi;
        rep[i]:=BPolyProd(rep[i],
                   (2-APolyProd(rep[i],dis,q)),
                   l[i],
                   q);
      od;

      # try to find true factors
      if max <= q or ofb < q  then 
        Info(InfoPoly,2,"searching for factors: ",Runtime());
        fcn:=TryCombinations(f,lc,l,q,t,bounds,opt,false);
        Info(InfoPoly,2,"finishing search:    ",Runtime());
      else
        fcn:=rec(irreducibles:=[], reducibles:=[]);
      fi;

      # if we have found a true factor update everything
      if 0 < Length(fcn.irreducibles)+Length(fcn.reducibles)  then
        # append irreducible factors to <res>.irrFactors
        Append(res.irrFactors,fcn.irrFactors);
        
        # append reducible factors to <res>.redFactors
        Append(res.redFactors,fcn.redFactors);

        # compute new <f>
        prd:=Product(fcn.redFactors) * Product(fcn.irrFactors);
        f  :=Quotient(R,f,prd);

		if IsBound(fcn.stop) then
		  res.stop:=true;
		  return res;
		fi;

        lc :=LeadingCoefficient(f);
        ofb:=2*AbsInt(lc)*OneFactorBound(f);
        Info(InfoPoly,2,"new one factor bound = ",ofb);

        # degree arguments or OFB arguments prove f irreducible
        if ForAll(t.degrees,i->i=0 or 2*i>=DOULP(f)) or ofb<q  then
          Add(fcn.irrFactors,f);
          Add(res.irrFactors,f);
          f:=f^0;
        fi;
        
        # if <f> is trivial return
        if DOULP(f) < 1  then
          Info(InfoPoly,2,"found non-trivial factorization");
          return res;
        fi;

        # compute the factor coefficient bounds
        k:=HenselBound(f);
        bounds:=List([ 1 .. Length(k) ],
                i -> Minimum(bounds[i],k[i]));
         k:=2 * AbsInt(lc) 
             * bounds[Maximum(Filtered(t.degrees,
                         i-> 2*i<=DOULP(f)))];
        Info(InfoPoly,2,"new Hensel bound = ",k);

        # remove true factors from <l> and corresponding <rep>
        prd:=(1/LeadingCoefficient(prd)) * prd mod q;
        l  :=l{fcn.remaining};
        rep:=List(rep{fcn.remaining},x -> prd * x);

        # reduce <rep>[i] mod <l>[i]
        for i  in [ 1 .. Length(l) ]  do
          rep[i]:=rep[i] mod l[i] mod q;
        od;

      # if there was a factor,we ought to have found it
      elif ofb < q  then 
        Add(res.irrFactors,f);
        Info(InfoPoly,2,"f irreducible,since one factor would ",
               "have been found now");
        return res; 
      fi;
    fi;

    # square modulus
    q1:=q;
    q :=q^2;

    # avoid a modulus too big
    if q > k  then
      q:=p^(LogInt(k,p)+1);
    fi;
  od;
  
  # return the remaining polynomials
  res.remPolynomial:=f;
  res.remaining  :=l;
  res.primePower   :=q1;
  res.lc       :=lc;
  return res;

end;


#############################################################################
##
#F  RPFactorsModPrime(<R>,<f>)   find suitable prime and factor
##
##  <f> must be squarefree.  We test 3 "small" and 2 "big" primes.
##
RPFactorsModPrime := function(R,f)
local i,j,   # loops
      fc,    # f's coeffs
      lc,    # leading coefficient of <f>
      p,     # current prime
      PR,    # polynomial ring over F_<p>
      fp,    # <f> in <R>
      lp,    # factors of <fp>
      min,   # minimal number of factors so far
      P,     # best prime so far
      LP,    # factorization of <f> mod <P>
      deg,   # possible degrees of factors
      t,     # return record
      tab,   # integer table of GF(<P>)
      log,   # zech log of finite field element
      cof,   # new coefficients
      tmp;

  fc:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];
  # set minimal number of factors to the degree of <f>
  min:=DOULP(f)+1;
  lc :=LeadingCoefficient(f);

  # find a suitable prime
  t:=rec(ind:=IndeterminateNumberOfUnivariateLaurentPolynomial(f));
  p:=1;
  for i  in [ 1 .. 5 ]  do

    # reset <p> to big prime after first 3 test
    if i = 4  then p:=Maximum(p,1000);  fi;

    # find a prime not dividing <lc> and <f>_<p> squarefree
    repeat
      repeat
        p :=NextPrimeInt(p);
      until lc mod p <> 0 and fc[1] mod p <> 0;
      PR:=PolynomialRing(GF(p));
      tmp:=1/lc mod p;
      fp :=UnivariatePolynomialByCoefficients(FamilyObj(Z(p)),
           List(fc,x->((tmp*x) mod p)* Z(p)^0),1);
    until 0 = DOULP(Gcd(PR,fp,Derivative(fp)));

    # factorize <f> modulo <p>
    Info(InfoPoly,2,"starting factorization mod p:  ",Runtime());
    lp:=Factors(PR,fp);

    Info(InfoPoly,2,"finishing factorization mod p: ",Runtime());

    # if <fp> is irreducible so is <f>
    if 1 = Length(lp)  then
      Info(InfoPoly,2,"<f> mod ",p," is irreducible");
      t.isIrreducible:=true;
      return t;
    else
      Info(InfoPoly,2,"found ",Length(lp)," factors mod ",p);
      Info(InfoPoly,2,"of degree ",List(lp,DOULP));
    fi;

    # choose a maximal prime with minimal number of factors
    if Length(lp) <= min  then
      min:=Length(lp);
      P  :=p;
      LP :=lp;
    fi;

    # compute the possible degrees
    tmp:=Set(List(Combinations(List(lp,DOULP)),g -> Sum(g)));
    if 1 = i  then
      deg:=tmp;
    else
      deg:=Intersection(deg,tmp);
    fi;

    # if there is only one possible degree != 0 then <f> is irreducible
    if 2 = Length(deg)  then
      Info(InfoPoly,2,"<f> must be irreducible,only one degree left");
      t.isIrreducible:=true;
      return t;
    fi;
    
  od;

  # convert factors <LP> back to the integers
  lp:=ShallowCopy(LP);
  for i  in [ 1 .. Length(LP) ]  do
    cof:=CoefficientsOfUnivariatePolynomial(LP[i]);
    #cof:=IntVecFFE(cof);
    cof:=List(cof,IntFFE);
    LP[i]:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,cof,t.ind);
  od;

  # return the chosen prime
  Info(InfoPoly,2,"choosing prime ",P," with ",Length(LP)," factors");
  Info(InfoPoly,2,"possible degrees: ",deg);
  t.isIrreducible:=false;
  t.prime    :=P;
  t.factors    :=LP;
  t.degrees    :=deg;
  return t;

end;


#############################################################################
##
#M  FactorsSquarefree(<R>,<f>,<opt>) . factors of <f>
##
##  <f> must be square free and must have a constant term.
##
InstallOtherMethod(FactorsSquarefree,"RatPol",true,
  [IsRationalsPolynomialRing,IsPolynomial,IsRecord],0,
function(R,f,opt)
local t, h, fac, g, tmp;

  # find a suitable prime,if <f> is irreducible return
  t:=RPFactorsModPrime(R,f);
  if t.isIrreducible  then return [f];  fi;
  Info(InfoPoly,2,"using prime ",t.prime," for factorization");

  # for easy combining,we want large degree factors first
  Sort(t.factors,function(a,b) return DOULP(a) > DOULP(b); end);

  # start Hensel
  h:=RPSquareHensel(R,f,t,opt);
  
  # combine remaining factors
  fac:=[];
  
  # first the factors found by hensel
  if 0 < Length(h.remaining)  then
    Info(InfoPoly,2,"found ",Length(h.remaining)," remaining terms");
    tmp:=TryCombinations(
		   h.remPolynomial,
		   h.lc,
		   h.remaining,
		   h.primePower,
		   t,
		   h.bounds,
		   opt,
		   true);
    Append(fac,tmp.irrFactors);
    Append(fac,tmp.redFactors);
  else
    tmp:=rec();
  fi;
  
  # append the irreducible ones
  if 0 < Length(h.irrFactors)  then
    Info(InfoPoly,2,"found ",Length(h.irrFactors)," irreducibles");
    Append(fac,h.irrFactors);
  fi;
  
  # and try to factorize the (possible) reducible ones
  if 0 < Length(h.redFactors) then
    Info(InfoPoly,2,"found ",Length(h.redFactors)," reducibles");

    if not (IsBound(tmp.stop) or IsBound(h.stop)) then
	# the stopping criterion has not yet been reached
	for g  in h.redFactors  do
	  Append(fac,FactorsSquarefree(R,g,opt));
	od;
    else
	Append(fac,h.redFactors);
    fi;
  fi;
  
  # and return
  return fac;
  
end);



RPIFactors := function(R,f,opt)
local   fc,ind,l, v, g, q, s, r, x,shift;

  fc:=CoefficientsOfUnivariateLaurentPolynomial(f);
  ind:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);
  # if <f> is trivial return
  Info(InfoPoly,2,"starting integer factorization: ",Runtime());
  if 0 = Length(fc[1])  then
    Info(InfoPoly,2,"<f> is trivial");
    return [ f ];
  fi;

  # remove a valuation
  v:=fc[2];
  f:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,fc[1],ind);
  x:=UnivariateLaurentPolynomialByCoefficients(CyclotomicsFamily,[1],1,ind);

  # if <f> is almost constant return
  if Length(fc[1])=1  then
    s:=List([1..fc[2]],i->x);
    s[1]:=s[1]*LeadingCoefficient(f);
    return s;
  fi;

  # if <f> is almost linear return
  if 1 = DOULP(f)  then
    Info(InfoPoly,2,"<f> is almost linear");
    s:=List([1..v],f -> x);
    Add(s,f);
    return s;
  fi;

  # shift the zeros of f if appropriate
  if DOULP(f) > 20  then
    g:=MinimizedBombieriNorm(f);
    f:=g[1];
    shift:=-g[2];
  else
    shift:=0;
  fi;

  # make <f> integral,primitive and square free
  g:=Gcd(R,f,Derivative(f));
  q:=IntegerPolynomial(R,Quotient(R,f,g));
  q:=q * SignInt(LeadingCoefficient(q));
  Info(InfoPoly,3,"factorizing polynomial of degree ",DOULP(q));

  # and factorize <q>
  if DOULP(q) < 2  then
    Info(InfoPoly,2,"<f> is a linear power");
    s:=[ q ];
  else
    # treat zeroes (only one possible)
    s:=CoefficientsOfUnivariateLaurentPolynomial(q)[2];
    if s>0 then 
      s:=[x];
      q:=q/x;
    else
      s:=[];
    fi;
    s:=Concatenation(s,FactorsSquarefree(R,q,opt));
  fi;

  # find factors of <g>
  for r  in s  do
    if 0 < DOULP(g) and DOULP(g) >= DOULP(r)  then
      q:=Quotient(R,g,r);
      while 0 < DOULP(g) and q <> fail  do
        Add(s,r);
        g:=q;
        if DOULP(g) >= DOULP(r)   then
          q:=Quotient(R,g,r);
        else
          q:=fail;
        fi;
      od;
    fi;
  od;

  # reshift
  if shift<>0 then
    Info(InfoPoly,2,"shifting zeros back");
    Apply(s,i->Value(i,x+shift));
  fi;

  # sort the factors
  Append(s,List([1..v],f->x));
  Sort(s);

  # return the (primitive) factors
  return s;

end;


RPFactors := function (arg)
local r,R,cr,f,opt,irf,i;

  R:=arg[1];
  cr:=CoefficientsRing(R);
  f:=arg[2];
  irf:=IrrFacsPol(f);
  i:=PositionProperty(irf,i->i[1]=cr);
  if i<>fail then
    # if we know the factors,return
    return irf[i][2];
  fi;

  if Length(arg)>2 then
    opt:=arg[3];
  else 
    opt:=rec();
  fi;
  # handle trivial case
  if DOULP(f) < 2  then
    StoreFactorsPol(cr,f,[f]);
    return [f];
  fi;

  # compute the integer factors
  r:=RPIFactors(R,IntegerPolynomial(R,f),opt);

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
  return r;

end;

#############################################################################
##
#M  Factors(<R>,<f> [,<opt>]) . .  factors of rational polynomial
##
InstallMethod(Factors,"FactRatPol",true,
  [IsRationalsPolynomialRing,IsPolynomial],0,
function(R,f)
  return RPFactors(R,f);
end);

InstallOtherMethod(Factors,"FactRatPol",true,
  [IsRationalsPolynomialRing,IsPolynomial,IsRecord],0,
function(R,f,opt)
  return RPFactors(R,f,opt);
end);

#############################################################################
##
#M  IsIrreducible(<pol>) . . . . Irreducibility test for rational polynomials
##
InstallMethod(IsIrreducible,"RatPol",true,
  [IsRationalsPolynomialRing,IsPolynomial],0,
function(R,f)
  return Length(Factors(R,f,rec(stopdegs:=[1..DOULP(f)])))<=1;
end);


#############################################################################
##
#E  polyrat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

