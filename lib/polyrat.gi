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
##  This file contains functions for polynomials over the rationals
##

#############################################################################
##
#F  APolyProd(<a>,<b>,<p>)   . . . . . . . . . . polynomial product a*b mod p
##
##return a*b mod p;
InstallGlobalFunction(APolyProd,function(a,b,p)
local ac,bc,i,j,pc,pv,ci,fam;

  ci:=CIUnivPols(a,b);
  fam:=FamilyObj(a);
  a:=CoefficientsOfLaurentPolynomial(a);
  b:=CoefficientsOfLaurentPolynomial(b);

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
  pv:=pv+RemoveOuterCoeffs(pc,fam!.zeroCoefficient);
  return LaurentPolynomialByExtRepNC(fam,pc,pv,ci);
end);

#############################################################################
##
#F  BPolyProd(<a>,<b>,<m>,<p>) . . . . . . polynomial product a*b mod m mod p
##
##  return EuclideanRemainder(PolynomialRing(Rationals),a*b mod p,m) mod p;
InstallGlobalFunction(BPolyProd,function(a,b,m,p)
local ac,bc,mc,i,j,pc,ci,f,fam;


  ci:=CIUnivPols(a,b);
  fam:=FamilyObj(a);
  a:=CoefficientsOfLaurentPolynomial(a);
  b:=CoefficientsOfLaurentPolynomial(b);
  m:=CoefficientsOfLaurentPolynomial(m);
  # we shift as otherwise the mod will mess up valuations (should occur
  # rarely anyhow)
  ac:=List(a[1],i->i mod p);
  ac:=ShiftedCoeffs(ac,a[2]);
  bc:=List(b[1],i->i mod p);
  bc:=ShiftedCoeffs(bc,b[2]);
  mc:=List(m[1],i->i mod p);
  mc:=ShiftedCoeffs(mc,m[2]);
  ReduceCoeffsMod(ac,mc,p);
  ShrinkRowVector(ac);
  ReduceCoeffsMod(bc,mc,p);
  ShrinkRowVector(bc);
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
      ShrinkRowVector(bc);
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
    ShrinkRowVector(pc);
    ReduceCoeffsMod(pc,mc,p);
    ShrinkRowVector(pc);
  od;
  p:=RemoveOuterCoeffs(pc,fam!.zeroCoefficient);
  return LaurentPolynomialByExtRepNC(fam,pc,p,ci);
end);


#############################################################################
##
#F  ApproxRational:  approximativ k"urzen
##
BindGlobal("ApproxRational",function(r,s)
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
end);

#############################################################################
##
#F  ApproximateRoot(<num>,<n>[,<digits>]) . . approximate th n-th root of num
##   numerically with a denominator of 'digits' digits.
##
BIND_GLOBAL( "APPROXROOTS", NEW_SORTED_CACHE(false) );

BindGlobal("ApproximateRoot",function(arg)
local r,e,f,store,maker;
  r:=arg[1];
  e:=arg[2];
  if Length(arg)>2 then
    f:=arg[3];
  else
    f:=10;
  fi;

  store:= e<=10 and IsInt(r) and 0<=r and r<=100 and f=10;

  maker := function()
  local x,nf,lf,c,letzt;

  x:=RootInt(NumeratorRat(r),e)/RootInt(DenominatorRat(r),e);
  nf:=r;
  c:=0;
  letzt:=[];
  repeat
    lf:=nf;
    Add(letzt,x);
    x:=ApproxRational(1/e*((e-1)*x+r/(x^(e-1))),f+6);
    nf:=AbsoluteValue(x^e-r);
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
  until c>2 or x in letzt;
  return x;
  end;

  if store then
    return GET_FROM_SORTED_CACHE(APPROXROOTS, [e,r], maker);
  fi;
  return maker();
end);

#############################################################################
##
#F  ApproxRootBound(f) Numerical approximation of RootBound (better, but
##  may fail)
##
BindGlobal("ApproxRootBound",function(f)
local x,p,tp,diff,app,d,scheit,v,nkon;

  x:=IndeterminateNumberOfLaurentPolynomial(f);
  p:=CoefficientsOfLaurentPolynomial(f);
  if p[2]<0 or not ForAll(p[1],IsRat) then
    # avoid complex conjugation etc.
    Error("only yet implemented for rational polynomials");
  fi;

  # eliminate valuation
  f:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,p[1],x);
  x:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,[0,1],x);

  # probably first test, whether polynomial should be inverted. However,
  # we expect roots larger than one.
  d:=DegreeOfLaurentPolynomial(f);
  f:=Value(f,1/x)*x^d;
  app:=1/2;
  diff:=1/4;
  nkon:=true;
  repeat
    # pol, whose roots are the 1/app of the roots of f
    tp:=Value(f,x*app);
    tp:=CoefficientsOfLaurentPolynomial(tp)[1];
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
end);

#############################################################################
##
#F  RootBound(<f>) . . . . bound for absolute value of (complex) roots of f
##
InstallGlobalFunction(RootBound,function(f)
local a,b,c,d;
  # valuation gives only 0 as zero, this can be neglected
  f:=CoefficientsOfLaurentPolynomial(f)[1];
  # normieren
  f:=f/f[Length(f)];
  f:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,f,1);

  a:=ApproxRootBound(f);
  # did the numerical part fail?
  if a=fail then
    c:=CoefficientsOfLaurentPolynomial(f)[1];
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
end);

#############################################################################
##
#F  BombieriNorm(<pol>) . . . . . . . . . . . . compute weighted Norm [pol]_2
##
InstallGlobalFunction(BombieriNorm,function(f)
local c,i,n,s;
  c:=CoefficientsOfLaurentPolynomial(f);
  c:=ShiftedCoeffs(c[1],c[2]);
  n:=Length(c)-1;
  s:=0;
  for i in [0..n] do
    s:=s+AbsInt(c[i+1])^2/Binomial(n,i);
  od;
  return ApproximateRoot(s,2);
end);

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
       IndeterminateNumberOfLaurentPolynomial(f));
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
    elif not(a>b and c>b) and (a+c<>2*b) then
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
BindGlobal("BeauzamyBound",function(f)
local n;
  n:=DegreeOfLaurentPolynomial(f);
  return Int(
  # the strange number in the next line is an (upper) rational approximation
  # for 3^{3/4}/2/\sqrt(\pi)
  643038/1000000*ApproximateRoot(3^n,2)/ApproximateRoot(n,2)*BombieriNorm(f))+1;
end);

#############################################################################
##
#F  OneFactorBound(<pol>) . . . . . . . . . . . . Bound for one factor of pol
##
InstallGlobalFunction(OneFactorBound,function(f)
local d,n;
  n:=DegreeOfLaurentPolynomial(f);
  if n>=3 then
    # Single factor bound of Beauzamy, Trevisan and Wang (1993)
    return Int(10912/10000*(ApproximateRoot(2^n,2)/ApproximateRoot(n^3,8)
           *(ApproximateRoot(BombieriNorm(f),2))))+1;
  else
    # Mignotte's single factor bound
    d:=QuoInt(n,2);
    return
    Binomial(d,QuoInt(d,2))
      *(1+RootInt(Sum(CoefficientsOfLaurentPolynomial(f)[1],
                      i->i^2),2));
  fi;
end);

#############################################################################
##
#F  PrimitivePolynomial(<f>) . . . remove denominator and coefficients gcd
##
InstallMethod(PrimitivePolynomial,"univariate polynomial",true,
  [IsUnivariatePolynomial],0,
function(f)
local lcm, c, fc,fac;

  fc:=CoefficientsOfLaurentPolynomial(f)[1];
  # compute lcm of denominator
  lcm := 1;
  for c  in fc  do
    lcm := LcmInt(lcm,DenominatorRat(c));
  od;

  # remove all denominators
  f := f*lcm;
  fac:=1/lcm;
  fc:=CoefficientsOfLaurentPolynomial(f)[1];

  # remove gcd of coefficients
  if Length(fc)>0 then
    fc:=Gcd(fc);
  else
    fc:=1;
  fi;
  fac:=fac*fc;
  return [f*(1/fc),fac];

end);

BindGlobal("PrimitiveFacExtRepRatPol",function(e)
local d,lcm,i,fac;
  d:=e{[2,4..Length(e)]};
  if not ForAll(d,IsRat) then
    TryNextMethod();
  fi;
  lcm:=1;
  for i in d do
    lcm := LcmInt(lcm,DenominatorRat(i));
  od;
  fac:=1/lcm;
  d:=d*lcm;
  if Length(d)>0 then
    fac:=fac*Gcd(d);
  fi;
  return fac;
end);

InstallMethod(PrimitivePolynomial,"rational polynomial",true,
  [IsPolynomial],0,
function(f)
local e,fac;
  e:=ExtRepPolynomialRatFun(f);
  fac:=PrimitiveFacExtRepRatPol(e);
  return [f/fac,fac];
end);


#############################################################################
##
#F  BeauzamyBoundGcd(<f>,<g>) . . . . . Beauzamy's Bound for Gcd Coefficients
##
##  cf. JSC 13 (1992),463-472
##
BindGlobal("BeauzamyBoundGcd",function(f,g)
local   n, A, B,lf,lg;

  lf:=LeadingCoefficient(f);
  if not IsOne(lf) then
    f:=f/lf;
  fi;

  lg:=LeadingCoefficient(f);
  if not IsOne(lg) then
    g:=g/lg;
  fi;
  n := DegreeOfLaurentPolynomial(f);
  # the   strange   number  in   the   next line  is   an  (upper) rational
  # approximation for 3^{3/4}/2/\sqrt(\pi)
  A := Int(643038/1000000
        * ApproximateRoot(3^n,2)/ApproximateRoot(n,2)
        * BombieriNorm(f))+1;

  # the   strange  number   in  the   next   line is  an   (upper) rational
  # approximation for 3^{3/4}/2/\sqrt(\pi)
  n := DegreeOfLaurentPolynomial(g);
  B := Int(643038/1000000
        * ApproximateRoot(3^n,2)/ApproximateRoot(n,2)
        * BombieriNorm(g))+1;
  B:=Minimum(A,B);
  if not (IsOne(lf) or IsOne(lg)) then
     B:=B*GcdInt(lf,lg);
  fi;
  return B;

end);


#############################################################################
##
#F  RPGcdModPrime(<f>,<g>,<p>,<a>,<brci>)  . . gcd mod <p>
##
BindGlobal("RPGcdModPrime",function(f,g,p,a,brci)
local fam,gcd, u, v, w, val, r, s;

  fam:=CoefficientsFamily(FamilyObj(f));
  f:=CoefficientsOfLaurentPolynomial(f);
  g:=CoefficientsOfLaurentPolynomial(g);
  # compute in the finite field F_<p>
  val := Minimum(f[2], g[2]);
  s   := ShiftedCoeffs(f[1],f[2]-val);
  r   := ShiftedCoeffs(g[1],g[2]-val);
  ReduceCoeffsMod(s,p);  ShrinkRowVector(s);
  ReduceCoeffsMod(r,p);  ShrinkRowVector(r);

  # compute the gcd
  u := r;
  v := s;
  while 0 < Length(v)  do
    w := v;
    ReduceCoeffsMod(u,v,p);
    ShrinkRowVector(u);
    v := u;
    u := w;
  od;
  #gcd := u * (a/u[Length(u)]);
  gcd:=u;
  MultVector(gcd,a/u[Length(u)]);
  ReduceCoeffsMod(gcd,p);

  # and return the polynomial
  return LaurentPolynomialByCoefficients(fam,gcd,val,brci);

end);


BindGlobal("RPGcdCRT",function(f,p,g,q,ci)
local min, cf, lf, cg, lg, i, P, m, r, fam;

  fam := CoefficientsFamily(FamilyObj(f));
  f:=CoefficientsOfLaurentPolynomial(f);
  g:=CoefficientsOfLaurentPolynomial(g);
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
  return LaurentPolynomialByCoefficients(fam,cf,min,ci);

end);


BindGlobal("RPGcd1",function(t,a,f,g)
local G, P, l, m, i;

  # <P> will hold the product of primes use so far
  t.modulo := t.prime;

  # <G> will hold the approximation of the gcd
  G := t.gcd;

  # use next prime until we reach the Beauzamy bound
  while t.modulo < t.bound  do
    repeat t.prime := NextPrimeInt(t.prime);  until a mod t.prime <> 0;

    # compute modular gcd
    t.gcd := RPGcdModPrime(f,g,t.prime,a,t.brci);
    Info(InfoPoly,3,"gcd mod ",t.prime," = ",t.gcd);

    # if the degree of <C> is smaller we started with wrong <p>
    if DegreeOfLaurentPolynomial(t.gcd)
       < DegreeOfLaurentPolynomial(G)
    then
      Info(InfoPoly,3,"found lower degree,restarting");
      return false;
    fi;

    # if the degrees of <C> and <G> are equal use chinese remainder
    if DegreeOfLaurentPolynomial(t.gcd)
       = DegreeOfLaurentPolynomial(G)
    then
      P := G;
      G := RPGcdCRT(P,t.modulo,t.gcd,t.prime,t.brci);
      t.modulo := t.modulo * t.prime;
      Info(InfoPoly,3,"gcd mod ",t.modulo," = ",G);
      if G = P  then
        t.correct :=  IsZero(f mod G) and IsZero(g mod G);
        if t.correct  then
          Info(InfoPoly,3,"found correct gcd");
          t.gcd := G;
          return true;
        fi;
      fi;
    fi;
  od;

  # get <G> into the -<t.modulo>/2 to +<t.modulo> range
  G:=CoefficientsOfLaurentPolynomial(G);
  l := [];
  m := t.modulo/2;
  for i  in [ 1 .. Length(G[1]) ]  do
    if m < G[1][i]  then
      l[i] := G[1][i] - t.modulo;
    else
      l[i] := G[1][i];
    fi;
  od;
  G := LaurentPolynomialByExtRepNC(FamilyObj(f),l,G[2],t.brci);
  Info(InfoPoly,3,"gcd mod ",t.modulo," = ",G);

  # check if <G> is correct but return 'true' in any case
  t.correct := IsZero(f mod G) and IsZero(g mod G);
  t.gcd := G;
  return true;

end);


BindGlobal("RPIGcd", function(f,g)
local a,t;

  # special case zero:
  if IsZero(f) then
    return g;
  elif IsZero(g) then
    return f;
  fi;
  # compute the Beauzamy bound for the gcd
  t := rec(prime := 1000);
  t.brci:=CIUnivPols(f,g);

  t.bound := 2 * Int(BeauzamyBoundGcd(f,g)+1);
  Info(InfoPoly,3,"Beauzamy bound = ",t.bound/2);

  # avoid gcd of leading coefficients
  a := GcdInt(LeadingCoefficient(f),LeadingCoefficient(g));
  repeat

    # start with first prime avoiding gcd of leading coefficients
    repeat t.prime := NextPrimeInt(t.prime);  until a mod t.prime <> 0;

    # compute modular gcd with leading coefficient <a>
    t.gcd := RPGcdModPrime(f,g,t.prime,a,t.brci);
    Info(InfoPoly,3,"gcd mod ",t.prime," = ",t.gcd);

    # loop until we have success
    repeat
      if 0 = DegreeOfLaurentPolynomial(t.gcd)  then
        Info(InfoPoly,3,"<f> and <g> are relative prime");
        return One(f);
      fi;
    until RPGcd1(t,a,f,g);
  until t.correct;

  # return the gcd
  return t.gcd;

end);

#############################################################################
##
#F  GcdOp( <R>, <f>, <g> )  . . . . . . . for rational univariate polynomials
##
InstallRingAgnosticGcdMethod("rational univariate polynomials",
  IsCollsElmsElms,IsIdenticalObj,
  [IsRationalsPolynomialRing and IsEuclideanRing,
   IsUnivariatePolynomial,IsUnivariatePolynomial],0,
function(f,g)
local brci,gcd,fam,fc,gc;

  fam:=FamilyObj(f);

  if not (IsIdenticalObj(CoefficientsFamily(fam),CyclotomicsFamily)
     and ForAll(CoefficientsOfLaurentPolynomial(f)[1],IsRat)
     and ForAll(CoefficientsOfLaurentPolynomial(g)[1],IsRat)) then
    TryNextMethod(); # not applicable as not rational
  fi;

  brci:=CIUnivPols(f,g);
  if brci=fail then TryNextMethod();fi;
  # check trivial cases
  if -infinity = DegreeOfLaurentPolynomial(f)  then
    return g;
  elif -infinity = DegreeOfLaurentPolynomial(g)  then
    return f;
  elif 0 = DegreeOfLaurentPolynomial(f)
       or 0 = DegreeOfLaurentPolynomial(g)
  then
    return One(f);
  fi;

  # convert polynomials into integer polynomials
  f := PrimitivePolynomial(f)[1];
  g := PrimitivePolynomial(g)[1];
  Info(InfoPoly,3,"<f> = ",f);
  Info(InfoPoly,3,"<g> = ",g);

  fc:=CoefficientsOfLaurentPolynomial(f);
  gc:=CoefficientsOfLaurentPolynomial(g);

  # try heuristic method:
  gcd:=HeuGcdIntPolsCoeffs(fc[1],gc[1]);
  if gcd=fail then
    # fall back to the original version:
    gcd:=RPIGcd(f,g);
    return StandardAssociate(gcd);

  fi;
  fc:=Minimum(fc[2],gc[2]);
  fc:=fc+RemoveOuterCoeffs(gcd,fam!.zeroCoefficient);
  if Length(gcd)>0 and not IsOne(gcd[Length(gcd)]) then
    gcd:=gcd/gcd[Length(gcd)];
  fi;
  return LaurentPolynomialByExtRepNC(fam,gcd,fc,brci);
end);

InstallMethod(\mod,"reduction of univariate rational polynomial at a prime",
  true,[IsUnivariatePolynomial,IsInt],0,
function(f,p)
local c;
  c:=CoefficientsOfLaurentPolynomial(f);
  if Length(c[1])>0 and
      ForAny(c[1],i->not (IsRat(i) or IsAlgebraicElement(i))) then
    TryNextMethod();
  fi;
  return LaurentPolynomialByCoefficients(
      CoefficientsFamily(FamilyObj(f)),List(c[1],i->i mod p),c[2],
      IndeterminateNumberOfLaurentPolynomial(f));
end);

InstallMethod(\mod,"reduction of general rational polynomial at a prime",
  true,[IsPolynomial,IsInt],0,
function(f,p)
local c,d,i,m;
  c:=ExtRepPolynomialRatFun(f);
  d:=[];
  for i in [2,4..Length(c)] do
    if not (IsRat(c[i]) or IsAlgebraicElement(c[i])) then
      TryNextMethod();
    fi;
    m:=c[i] mod p;
    if m<>0 then
      Add(d,c[i-1]);
      Add(d,m);
    fi;
  od;
  return PolynomialByExtRepNC(FamilyObj(f),d);
end);

#############################################################################
##
#F  RPQuotientModPrime(<f>,<g>,<p>) . . .  quotient
##
BindGlobal("RPQuotientModPrime",function(f,g,p)
local   m, n, i, k, c, q, val, fc,gc,brci,fam;

  # get base ring
  brci:=CIUnivPols(f,g);
  fam:=FamilyObj(f);
  # reduce <f> and <g> mod <p>
  f := f mod p;
  g := g mod p;

  fc:=CoefficientsOfLaurentPolynomial(f);
  gc:=CoefficientsOfLaurentPolynomial(g);

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
    if f[i] <> fam!.zeroCoefficient then
      return false;
    fi;
  od;
  val:=val+RemoveOuterCoeffs(q,fam!.zeroCoefficient);
  return LaurentPolynomialByExtRepNC(fam,q,val,brci);

end);


#############################################################################
##
#F  RPGcdRepresentationModPrime(<f>,<g>,<p>)  . gcd
##
BindGlobal("RPGcdRepresentationModPrime",function(f,g,p)

  local   val,     # the minimal valuation of <f> and <g>
      s, sx,    # first line of gcd algorithm
      t, tx,    # second line of gcd algorithm
      h, hx,    # temp for swapping lines
      q,       # quotient
      n,m,r,c,  # used in quotient
      brci,
      i,k;       # loops

  Info(InfoPoly,3,"f=",f,"g=",g);
  # get base ring
  brci:=CIUnivPols(f,g);
  brci:=[CoefficientsFamily(FamilyObj(f)),brci];

  # remove common x^i term
  f:=CoefficientsOfLaurentPolynomial(f);
  g:=CoefficientsOfLaurentPolynomial(g);

  val:=Minimum(f[2],g[2]);
  f  :=ShiftedCoeffs(f[1],f[2]-val);
  g  :=ShiftedCoeffs(g[1],g[2]-val);
  ReduceCoeffsMod(f,p);  ShrinkRowVector(f);
  ReduceCoeffsMod(g,p);  ShrinkRowVector(g);

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
    ShrinkRowVector(t);
    tx := sx;
    AddCoeffs(tx,ProductCoeffs(q,hx),-1);
    ReduceCoeffsMod(tx,p);
    ShrinkRowVector(tx);
    s  := h;
    sx := hx;
  od;
  Info(InfoPoly,3,"<s> = ",s,", <sx> = ",sx);

  # compute conversion for standard associate
  q := (1/s[Length(s)]) mod p;

  # convert <s> and <x> back into polynomials
  if 0 = Length(g)  then
    #sx := q * sx;
    MultVector(sx,q);
    ReduceCoeffsMod(sx,p);
    return [ LaurentPolynomialByCoefficients(brci[1],sx,0,brci[2]),
         Zero(brci[1]) ];
  else
    #hx := q * sx;
    hx:=ShallowCopy(sx);
    MultVector(hx,q);
    ReduceCoeffsMod(hx,p);
    hx := LaurentPolynomialByCoefficients(brci[1],hx,0,brci[2]);
    AddCoeffs(s,ProductCoeffs(sx,f),-1);
    #s := q * s;
    MultVector(s,q);
    ReduceCoeffsMod(s,p);
    s := LaurentPolynomialByCoefficients(brci[1],s,0,brci[2]);
    g := LaurentPolynomialByCoefficients(brci[1],g,0,brci[2]);
    q := RPQuotientModPrime(s,g,p);
    return [ hx,q ];
  fi;

end);


#############################################################################
##
#F  HenselBound(<pol>,[<minpol>,<den>]) . . . Bounds for Factor coefficients
##    if the computation takes place over an algebraic extension, then
##    minpol and denominator must be given
##
InstallGlobalFunction(HenselBound,function(arg)
local pol,n,nalpha,d,dis,rb,bound,a,i,j,k,l,w,bin,lm,bea,polc,ro,rbpow;

  pol:=arg[1];
  if Length(arg)>1 then
    n:=arg[2];
    d:=arg[3];

    dis:=Discriminant(n);
    nalpha:=RootBound(n); # bound for norm of \alpha.

    polc:=CoefficientsOfLaurentPolynomial(pol)[1];
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
          Add(a,Sum(ExtRepOfObj(i),AbsInt)*nalpha);
        fi;
      od;
      a:=-a;
      a[Length(a)]:=-a[Length(a)];
      pol:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,a,1);
    else
      pol:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,polc,1);
    fi;
    n:=DegreeOfLaurentPolynomial(n);
  else
    n:=1;
  fi;

  bound:=[];
  rb:=0;
  #BeauzamyBound
  bea:=BeauzamyBound(pol);
  # compute Landau-Mignotte bound for absolute values of
  # coefficients of any factor
  polc:=CoefficientsOfLaurentPolynomial(pol)[1];
  w:=Sum(polc,i->i^2);
  # we want an upper bound of the root, RootInt will give a lower
  # bound. So we compute the root of w-1 (in case w is a perfect square)
  # and add 1. As we nowhere selected a specific galois representative,
  # this bound (which is rational!) will bound all conjugactes as well.
  lm:=(RootInt(Int(w)-1,2)+1);
  for k in [1..DegreeOfLaurentPolynomial(pol)] do

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
        if rb>1000 and not IsInt(rb) then
          rb:=Int(rb+1);
        fi;
        rbpow:=[rb];
        a:=rb;
      fi;
      # now try factor deg k
      bin:=1;
      for j in [1..k] do
        bin:=bin*(k-j+1)/j;
        if not IsBound(rbpow[j]) then
          rbpow[j]:=rbpow[j-1]*rb;
          if rbpow[j]>10 and not IsInt(rbpow[j]) then
            rbpow[j]:=Int(rbpow[j]+1);
          fi;
        fi;
        w:=bin*rbpow[j];
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

      ro:=AbsInt(dis);
      ro:=RootInt(NumeratorRat(ro))/(1+RootInt(DenominatorRat(ro)-1));
      w:=Int(d*w*Factorial(n)/ro*nalpha^(n*(n-1)/2))+1;
    fi;

    bound[k]:=Int(w)+1;
  od;
  return bound;
end);

#############################################################################
##
#F  TrialQuotientRPF(<f>,<g>,<b>)  . . . . . . f/g if coeffbounds are given by b
##
InstallGlobalFunction(TrialQuotientRPF,function(f,g,b)
local  fc,gc,a,m, n, i, k, c, q, val, brci,fam;
  brci:=CIUnivPols(f,g);
  a:=DegreeOfLaurentPolynomial(f)-DegreeOfLaurentPolynomial(g);
  fam:=FamilyObj(f);
  fc:=CoefficientsOfLaurentPolynomial(f);
  gc:=CoefficientsOfLaurentPolynomial(g);
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
      if MaxNumeratorCoeffAlgElm(c)>a then
        Info(InfoPoly,3,"early break");
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
#      if MaxNumeratorCoeffAlgElm(c)>a then
#        Info(InfoPoly,3,"early break\n");
#        return fail;
#      fi;
#      for k in [1..n] do
#        f[m-i+k]:=f[m-i+k]-c*g.coefficients[k];
#        if MaxNumeratorCoeffAlgElm(f[m-i+k])>b then
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
  val:=val+RemoveOuterCoeffs(q,fam!.zeroCoefficient);
  return LaurentPolynomialByExtRepNC(fam,q,val,brci);
end);


#############################################################################
##
#F  TryCombinations(<f>,...)  . . . . . . . . . . . . . . . .  try factors
##
InstallGlobalFunction(TryCombinations,function(f,lc,l,p,t,bounds,opt,split,useonefacbound)
local  p2, res, j, i,ii,o,d,b,lco,degs, step, cnew, sel, deli,
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
  deli:=List(l,DegreeOfLaurentPolynomial);

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
  # final cofactor. This cannot be used if we factor only using the one
  # factor bound!

  if not useonefacbound then
    degf:=DegreeOfLaurentPolynomial(f);
    degs:=Filtered(alldegs,i -> 2*i<=degf);
  else
    degs:=alldegs;
  fi;

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
              i->CoefficientsOfLaurentPolynomial(i)[1][1]),
                   p) * lc) mod p;
          if p2 < q  then
            q:=q - p;
          fi;

          # As  we  don't  know  yet  the gcd  of  all the products
          # coefficients (to make it  primitive),we do  a slightly
          # weaker test:  (test of  leading   coeffs is  first   in
          # 'TrialQuotientRPF') this just should  reduce the number of
          # 'ProductMod' necessary.   the  absolute  part  of  the
          # product must  divide  the absolute  part of  f  up to a
          # divisor of <lc>
          q:=CoefficientsOfLaurentPolynomial(f)[1][1] / q * lc;
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
            q:=TrialQuotientRPF(f,prd,bounds);
          fi;

          if q <> fail  then
            f:=q;
            Info(InfoPoly,2,"found true factor of degree ",
                 DegreeOfLaurentPolynomial(prd));
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

              if IsBound(opt.stopdegs)
                and DegreeOfLaurentPolynomial(prd) in opt.stopdegs then
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

end);


#############################################################################
##
#F  RPSquareHensel(<f>,<t>,<opt>)
##
BindGlobal("RPSquareHensel",function(f,t,opt)

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
      max,     # maximum absolute coefficient of <f>
      res,     # result
      gcd,     # used in gcd representation
      i, j;    # loop

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
  k:=bounds[Maximum(Filtered(t.degrees,
                             i-> 2*i<=DegreeOfLaurentPolynomial(f)))];
  Info(InfoPoly,2,"Hensel bound = ",k);

  # compute a representation of the 1 mod <p>
  Info(InfoPoly,2,"computing gcd representation: ",Runtime());
  prd:=(1/lc * f) mod p;
  gcd:=RPQuotientModPrime(prd,l[1],p);
  rep:=[ One(f) ];
  for i  in [ 2 .. Length(l) ]  do
    dis:=RPQuotientModPrime(prd,l[i],p);
    cor:=RPGcdRepresentationModPrime(gcd,dis,p);
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
    #if not ForAll(CoefficientsOfLaurentPolynomial(Product(l)-f)[1],
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
      if max <= q then
        Info(InfoPoly,2,"searching for factors: ",Runtime());
        fcn:=TryCombinations(f,lc,l,q,t,bounds,opt,false,false);
      elif ofb < q  then
        Info(InfoPoly,2,"searching for factors: ",Runtime());
        fcn:=TryCombinations(f,lc,l,q,t,bounds,opt,false,true);

        #Info(InfoPoly,2,"finishing search:    ",Runtime());
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

        f  :=f/prd;
        if IsBound(fcn.stop) then
          res.stop:=true;
          return res;
        fi;

        lc :=LeadingCoefficient(f);
        ofb:=2*AbsInt(lc)*OneFactorBound(f);
        Info(InfoPoly,2,"new one factor bound = ",ofb);

        # degree arguments or OFB arguments prove f irreducible
        if (ForAll(t.degrees,i->i=0 or 2*i>=DegreeOfLaurentPolynomial(f))
           or ofb<q) and DegreeOfLaurentPolynomial(f)>0 then
          Add(fcn.irrFactors,f);
          Add(res.irrFactors,f);
          f:=f^0;
        fi;

        # if <f> is trivial return
        if DegreeOfLaurentPolynomial(f) < 1  then
          Info(InfoPoly,2,"found non-trivial factorization");
          return res;
        fi;

        # compute the factor coefficient bounds
        k:=HenselBound(f);
        bounds:=List([ 1 .. Length(k) ],
                i -> Minimum(bounds[i],k[i]));
         k:=2 * AbsInt(lc)
             * bounds[Maximum(Filtered(t.degrees,
                         i-> 2*i<=DegreeOfLaurentPolynomial(f)))];
        Info(InfoPoly,2,"new Hensel bound = ",k);

        # remove true factors from <l> and corresponding <rep>
        prd:=(1/LeadingCoefficient(prd)) * prd mod q;
        l  :=l{fcn.remaining};
        rep:=List(rep{fcn.remaining},x -> prd * x);

        # reduce <rep>[i] mod <l>[i]
        for i  in [ 1 .. Length(l) ]  do
          #rep[i]:=rep[i] mod l[i] mod q;
          rep[i]:=CoefficientsOfLaurentPolynomial(rep[i]);
          rep[i]:=ShiftedCoeffs(rep[i][1],rep[i][2]);
          j:=CoefficientsOfLaurentPolynomial(l[i]);
          j:=ReduceCoeffsMod(rep[i],ShiftedCoeffs(j[1],j[2]),q);
          # shrink the list rep[i], according to the 'j' value
          rep[i]:=rep[i]{[1..j]};
          rep[i]:=LaurentPolynomialByCoefficients(
                    CyclotomicsFamily,rep[i],0,t.ind);
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

end);


#############################################################################
##
#F  RPFactorsModPrime(<f>)   find suitable prime and factor
##
##  <f> must be squarefree.  We test 3 "small" and 2 "big" primes.
##
BindGlobal("RPFactorsModPrime",function(f)
local i,     # loops
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
      cof,   # new coefficients
      tmp;

  fc:=CoefficientsOfLaurentPolynomial(f)[1];
  # set minimal number of factors to the degree of <f>
  min:=DegreeOfLaurentPolynomial(f)+1;
  lc :=LeadingCoefficient(f);

  # find a suitable prime
  t:=rec(ind:=IndeterminateNumberOfLaurentPolynomial(f));
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
    until 0 = DegreeOfLaurentPolynomial(Gcd(PR,fp,Derivative(fp)));

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
      Info(InfoPoly,2,"of degree ",List(lp,DegreeOfLaurentPolynomial));
    fi;

    # choose a maximal prime with minimal number of factors
    if Length(lp) <= min  then
      min:=Length(lp);
      P  :=p;
      LP :=lp;
    fi;

    # compute the possible degrees
    tmp:=Set(Combinations(List(lp,DegreeOfLaurentPolynomial)),Sum);
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

end);


#############################################################################
##
#M  FactorsSquarefree(<R>,<f>,<opt>) . factors of <f>
##
##  <f> must be square free and must have a constant term.
##
InstallMethod( FactorsSquarefree, "univariate rational poly", true,
  [IsRationalsPolynomialRing,IsUnivariatePolynomial,IsRecord],0,
function(R,f,opt)
local t, h, fac, g, tmp;

  # find a suitable prime,if <f> is irreducible return
  t:=RPFactorsModPrime(f);
  if t.isIrreducible  then return [f];  fi;
  Info(InfoPoly,2,"using prime ",t.prime," for factorization");

  # for easy combining,we want large degree factors first
  Sort(t.factors,
    function(a,b)
      return DegreeOfLaurentPolynomial(a) > DegreeOfLaurentPolynomial(b);
    end);

  # start Hensel
  h:=RPSquareHensel(f,t,opt);

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
                   true,false);
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

BindGlobal("RPIFactors",function(R,f,opt)
local   fc,ind, v, g, q, s, r, x,shift;

  fc:=CoefficientsOfLaurentPolynomial(f);
  ind:=IndeterminateNumberOfLaurentPolynomial(f);
  # if <f> is trivial return
  Info(InfoPoly,2,"starting integer factorization: ",Runtime());
  if 0 = Length(fc[1])  then
    Info(InfoPoly,2,"<f> is trivial");
    return [ f ];
  fi;

  # remove a valuation
  v:=fc[2];
  f:=UnivariatePolynomialByCoefficients(CyclotomicsFamily,fc[1],ind);
  x:=LaurentPolynomialByCoefficients(CyclotomicsFamily,[1],1,ind);

  # if <f> is almost constant return
  if Length(fc[1])=1  then
    s:=List([1..fc[2]],i->x);
    s[1]:=s[1]*LeadingCoefficient(f);
    return s;
  fi;

  # if <f> is almost linear return
  if 1 = DegreeOfLaurentPolynomial(f)  then
    Info(InfoPoly,2,"<f> is almost linear");
    s:=List([1..v],f -> x);
    Add(s,f);
    return s;
  fi;

  # shift the zeros of f if appropriate
  if DegreeOfLaurentPolynomial(f) > 20  then
    g:=MinimizedBombieriNorm(f);
    f:=g[1];
    shift:=-g[2];
  else
    shift:=0;
  fi;

  # make <f> integral,primitive and square free
  g:=Gcd(R,f,Derivative(f));
  q:=PrimitivePolynomial(f/g)[1];
  q:=q * SignInt(LeadingCoefficient(q));
  Info(InfoPoly,3,"factorizing polynomial of degree ",
       DegreeOfLaurentPolynomial(q));

  # and factorize <q>
  if DegreeOfLaurentPolynomial(q) < 2  then
    Info(InfoPoly,2,"<f> is a linear power");
    s:=[ q ];
  else
    # treat zeroes (only one possible)
    s:=CoefficientsOfLaurentPolynomial(q)[2];
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
    if 0 < DegreeOfLaurentPolynomial(g)
       and DegreeOfLaurentPolynomial(g) >= DegreeOfLaurentPolynomial(r) then
      q:=Quotient(R,g,r);
      while 0 < DegreeOfLaurentPolynomial(g) and q <> fail  do
        Add(s,r);
        g:=q;
        if DegreeOfLaurentPolynomial(g)>=DegreeOfLaurentPolynomial(r) then
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

  if not (IsBound(opt.stopdegs) or IsBound(opt.onlydegs)) and Sum(s,DegreeOfLaurentPolynomial)<>DegreeOfLaurentPolynomial(f)+v then
    Error("degree discrepancy!");
  fi;

  # return the (primitive) factors
  return s;

end);


#############################################################################
##
#M  Factors(<R>,<f> ) . .  factors of rational polynomial
##
InstallMethod(Factors,"univariate rational polynomial",IsCollsElms,
  [IsRationalsPolynomialRing,IsUnivariatePolynomial],0,
function(R,f)
local r,cr,opt,irf,i;

  opt:=ValueOption("factoroptions");
  PushOptions(rec(factoroptions:=rec())); # options do not hold for
                                          # subsequent factorizations
  if opt=fail then
    opt:=rec();
  fi;

  cr:=CoefficientsRing(R);
  irf:=IrrFacsPol(f);
  i:=PositionProperty(irf,i->i[1]=cr);
  if i<>fail then
    # if we know the factors,return
    PopOptions();
    return ShallowCopy(irf[i][2]);
  fi;

  # handle trivial case
  if DegreeOfLaurentPolynomial(f) < 2  then
    StoreFactorsPol(cr,f,[f]);
    PopOptions();
    return [f];
  fi;

  # compute the integer factors
  r:=RPIFactors(R,PrimitivePolynomial(f)[1],opt);

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

#############################################################################
##
#F  SymAdic( <x>, <b> ) . . . . . . . . . . symmetric <b>-adic expansion of <x>
#F  (<b> and <x> integers)
##
BindGlobal( "SymAdic", function(x,b)
  local l, b2, r;
  b2:=QuoInt(b,2);
  l:=[];
  while x<>0 do
    r:=x mod b;
    if r>b2 then
      r:=r-b;
    fi;
    Add(l,r);
    x:=(x-r)/b;
  od;
  return l;
end );


#############################################################################
##
#F  HeuGcdIntPolsExtRep(<fam>,<a>,<b>)
##
##  takes two polynomials ext reps, primitivizes them with integer
##  coefficients and tries to
##  compute a Gcd expanding Gcds of specializations.
##  Source: Geddes,Czapor,Labahn: Algorithm 7.4

#V MAXTRYGCDHEU: defines maximal number of attempts to find Gcd heuristically
MAXTRYGCDHEU:=6;

InstallGlobalFunction(HeuGcdIntPolsExtRep,function(fam,d,e)
local x,xd,er,i,j,k,m,p,sel,xi,gamma,G,g,loop,zero,add;

  # find the indeterminates and their degrees:
  x:=[];
  xd:=[[],[]];
  er:=[d,e];
  for k in [1,2] do
    for i in [1,3..Length(er[k])-1] do
      m:=er[k][i];
      for j in [1,3..Length(m)-1] do
        p:=Position(x,m[j]);
        if p=fail then
          Add(x,m[j]);
          p:=Length(x);
          xd[1][p]:=0;
          xd[2][p]:=0;
        fi;
        xd[k][p]:=Maximum(xd[k][p],m[j+1]);
      od;
    od;
  od;

  # discard the indeterminates which occur in only one of the polynomials
  sel:=[];
  for i in [1..Length(x)] do
    if xd[1][i]>0 and xd[2][i]>0 then
      Add(sel,i);
    fi;
  od;
  x:=x{sel};
  xd:=List(xd,i->i{sel});

  # are the variables disjoint or do we have no variables at all?
  if Length(x)=0 then
    # return the gcd of all coefficients involved
    G:=Gcd(Concatenation(d{[2,4..Length(d)]},e{[2,4..Length(e)]}));
    return G;
  fi;

  # pick the first indeterminate
  x:=x[1];
  xd:=[xd[1][1],xd[2][1]];

  xi:=2*Minimum(Maximum(List(d{[2,4..Length(d)]},AbsInt)),
                Maximum(List(e{[2,4..Length(e)]},AbsInt)))+2;

  for loop in [1..MAXTRYGCDHEU] do
    if LogInt(AbsInt(Int(xi)),10)*Maximum(xd)>5000 then
      return fail;
    fi;
    # specialize both polynomials at x=xi
    # and compute their heuristic Gcd
    gamma:=HeuGcdIntPolsExtRep(fam,
              SpecializedExtRepPol(fam,d,x,xi),
              SpecializedExtRepPol(fam,e,x,xi) );

    if gamma<>fail then
      # generate G from xi-adic expansion
      G:=[];
      i:=0;
      if IsInt(gamma) then
        zero:=Zero(gamma);
      else
        zero:=[];
      fi;
      while gamma<>zero do
        if IsInt(gamma) then
          # gamma is an integer value
          g:=gamma mod xi;
          if g>xi/2 then
            g:=g-xi; # symmetric rep.
          fi;
          gamma:=(gamma-g)/xi;
          if i=0 then
            add:=[[],g];
          else
            add:=[[x,i],g];
          fi;
        else
          # gamma is an ext rep
          g:=[];
          for j in [2,4..Length(gamma)] do
            k:=gamma[j] mod xi;
            if k>xi/2 then
              k:=k - xi; #symmetric rep
            fi;
            if k<>0*k then
              Add(g,gamma[j-1]);
              Add(g,k);
            fi;
          od;
          #gamma:=(gamma-g)/xi in ext rep;
          add:=ShallowCopy(g);
          add{[2,4..Length(add)]}:=-add{[2,4..Length(add)]}; #-g
          gamma:=ZippedSum(gamma,add,0,fam!.zippedSum); # gamma-g
          gamma{[2,4..Length(gamma)]}:=gamma{[2,4..Length(gamma)]}/xi; # /xi
          #add:=g*xp^i; in extrep
          add:=ZippedProduct(g,[[x,i],1],0,fam!.zippedProduct);
        fi;
        # G:=G+add in extrep
        G:=ZippedSum(G,add,0,fam!.zippedSum);
        i:=i+1;
      od;

      if Length(G)>0 and Length(G[1])>0 and
         QuotientPolynomialsExtRep(fam,d,G)<>fail and
         QuotientPolynomialsExtRep(fam,e,G)<>fail then
        return G;
      fi;
    fi;
    xi:=QuoInt(xi*73794,27011); #square of golden ratio
  od;
  return fail;
end);

# and the same in univariate
InstallGlobalFunction(HeuGcdIntPolsCoeffs,function(f,g)
local xi, t, h, i, lf, lg, lh,fr,gr;

  if IsEmpty(f) or IsEmpty(g) then
    return fail;
  fi;
  # first test value for heuristic gcd:
  xi:=2+2*Minimum(Maximum(List(f,AbsInt)),Maximum(List(g,AbsInt)));
  i:=0;
  lf:=f[Length(f)];
  lg:=g[Length(g)];

  # and now the tests:
  while i< MAXTRYGCDHEU do

    # xi-adic expansion of Gcd(f(xi),g(xi)) (regarded as coefficient list)
    h:=Gcd(  ValuePol(f,xi),
             ValuePol(g,xi) );
    h:=SymAdic(h,xi);

    # make it primitive:
    t:=Gcd(h);
    if t<>1 then
      h:=h/t;
    fi;
    lh:=h[Length(h)];

    # check if it divides f and g: if yes, ready! if no, try larger xi

    ## this should be done more efficiently !
    if RemInt(lg,lh)=0 and RemInt(lf,lh)=0 then
      fr:=ShallowCopy(f);
      ReduceCoeffs(fr,h);
      gr:=ShallowCopy(g);
      ReduceCoeffs(gr,h);
      t:=Set(Concatenation(fr,gr));
    else
      t:=false;
    fi;
    if t=[0] then
      Info(InfoPoly,4,"GcdHeuPrimitiveList: tried ",i+1," values");
      return h;
    else
      i:=i+1;
      xi:=QuoInt(xi*73794,27011);
    fi;
  od;
  Info(InfoPoly,2,"GcdHeuPrimitiveList: failed after trying ",
             MAXTRYGCDHEU," values");
  return fail;
end);


InstallMethod(HeuristicCancelPolynomialsExtRep,"rationals",true,
  [IsRationalFunctionsFamily,IsList,IsList],0,
function(fam,a,b)
local nf,df,g;
  if not (HasCoefficientsFamily(fam)
     and IsIdenticalObj(CoefficientsFamily(fam),CyclotomicsFamily)
     and ForAll(a{[2,4..Length(a)]},IsRat)
     and ForAll(b{[2,4..Length(b)]},IsRat)) then
    # the coefficients are not all rationals
    TryNextMethod();
  fi;

  # make numerator and denominator primitive with integer coefficients
  nf:=PrimitiveFacExtRepRatPol(a);
  if not IsOne(nf) then
    a:=ShallowCopy(a);
    a{[2,4..Length(a)]}:=a{[2,4..Length(a)]}/nf;
  fi;

  df:=PrimitiveFacExtRepRatPol(b);
  if not IsOne(df) then
    b:=ShallowCopy(b);
    b{[2,4..Length(b)]}:=b{[2,4..Length(b)]}/df;
  fi;

  # the remaining common factor
  nf:=nf/df;
  g:=HeuGcdIntPolsExtRep(fam,a,b);
  if IsList(g) and (Length(g)>2 or (Length(g)=2 and Length(g[1])>0)) then
    # make g primitive
    df:=PrimitiveFacExtRepRatPol(g);
    if not IsOne(df) then
      g:=ShallowCopy(g);
      g{[2,4..Length(g)]}:=g{[2,4..Length(g)]}/df;
    fi;

    Info(InfoPoly,3,"Heuristic integer gcd returns ",g);

    a:=QuotientPolynomialsExtRep(fam,a,g);
    b:=QuotientPolynomialsExtRep(fam,b,g);
    if a<>fail and b<>fail then
      a{[2,4..Length(a)]}:=a{[2,4..Length(a)]}*nf;
      g:=[a,b];
      return g;
    fi;
  fi;
  return fail;
end);

InstallGlobalFunction(PolynomialModP,function(pol,p)
local f, cof;
   f:=GF(p);
   cof:=CoefficientsOfUnivariatePolynomial(pol);
   return UnivariatePolynomial(f,cof*One(f),
             IndeterminateNumberOfUnivariateRationalFunction(pol));
end);
