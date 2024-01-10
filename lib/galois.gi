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
##  This file contains the implementation for the computation of Galois Groups.


#############################################################################
##
#F  ParityPol(<f>) . . . . . . . . . . . . . . . . . . parity of a
##
InstallGlobalFunction(ParityPol,function(ring,f)
local d;
  d:=Discriminant(f);
  if ring=Rationals then
    if d>0
      and d=(RootInt(NumeratorRat(d),2)/RootInt(DenominatorRat(d),2))^2 then
      return 1;
    else
      return -1;
    fi;
  else
    f:=Indeterminate(ring)^2-d;
    if IsIrreducibleRingElement(PolynomialRing(ring,
                      [IndeterminateNumberOfUnivariateRationalFunction(f)]),f)
      then
      return -1;
    else
      return 1;
    fi;
  fi;
  return d;
end);

#############################################################################
##
#F  PowersumsElsyms( <pols> ) . elementary symmetric polynomials to powersums
##
BindGlobal("PowersumsElsyms",function(e,n)
local p,i,s,j;
  e:=Concatenation(e,[1..n-Length(e)]*0);
  p:=[];
  for i in [1..n] do
    s:=0;
    for j in [1..i-1] do
      s:=s-(-1)^j*e[j]*p[i-j];
    od;
    p[i]:=s-i*(-1)^i*e[i];
  od;
  return p;
end);

#############################################################################
##
#F  ElsymmsPowersums( <powers> ) . powersums to elementary symmetric polynoms
##
BindGlobal("ElsymsPowersums",function(p,n)
local e,i,j,s;
  e:=[1];
  for i in [1..n] do
    s:=0;
    for j in [1..i] do
      s:=s-(-1)^j*p[j]*e[i-j+1];
    od;
    e[i+1]:=s*1/i;
  od;
  return e{[2..Length(e)]};
end);

#############################################################################
##
#F  SumRootsPol( <f>, <m> ) . . . . . . . . . . . . . . . . .  compute f^{+m}
##
BindGlobal("SumRootsPolComp",function(fam,p,m,n,nn)
local ch,c,z,i,j,k,h,hi,his,zv,f;
  ch:=Characteristic(fam);

  p:=Concatenation([n* One( fam ) ],p);
  f:=1;
  for i in [1..nn+1] do
    p[i]:=p[i]/f;
    f:=f*i;
    if ch>0 then
      f:=f mod ch;
    fi;
  od;
  z:= Zero( fam );
  zv:=p*z;
  h:=[p*z,p];
  h[1][1]:= One( fam );
  for i in [2..m] do
    hi:=p*z;
    for j in [1..i] do
      his:=[];
      for k in [1..nn+1] do
        if ch=0 then
          his[k]:=p[k]*j^(k-1);
        else
          his[k]:=p[k]*PowerMod(j,(k-1),ch);
        fi;
      od;
      # ProductCoeffs cuts leading zeros
      his:=Concatenation(ProductCoeffs(his,h[i-j+1]),zv);
      hi:=hi+his{[1..nn+1]}*(-1)^(j+1);
    od;
    if ch=0 then
      h[i+1]:=hi/i;
    else
      h[i+1]:=hi*(1/i mod ch);
    fi;
  od;
  p:=h[m+1];
  f:=1;
  for i in [1..nn+1] do
    p[i]:=p[i]*f;
    f:=f*i;
    if ch>0 then
      f:=f mod ch;
    fi;
  od;
  p:=p{[2..nn+1]};
  c:=ElsymsPowersums(p,nn);
  for i in [1..nn] do
    c[i]:=c[i]*(-1)^i;
  od;
  c:=Reversed(c);
  return c;
end);

InstallGlobalFunction(SumRootsPol,function(f,m)
local den,ch,n,nn,p,fam,i,j,w,pl,b,c,k,mp,mc;
  if LeadingCoefficient(f)<>1 then
    Error("f must be monic");
  fi;
  Info(InfoGalois,3,"SumRootsPol ",m);
  fam:=CoefficientsFamily(FamilyObj(f));
  ch:=Characteristic(fam);
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  nn:=Binomial(n,m);
  c:=ShallowCopy(CoefficientsOfUnivariatePolynomial(f));
  if ForAll(c,IsInt) then
    den:=1;
  else
    # We have nontrivial denominators. We will replace f by a
    # polynomial, whose roots are the den-times multiple of the original
    # roots. Thus coefficients of this new f become integers. This
    # implies, that the sums of the new roots are stretched about the
    # same factor. At the end, we will thus simply revert this
    # procedure.
    den:=Lcm(List(c,DenominatorRat));
    p:=1;
    for i in [1..Length(c)-1] do
      p:=p*den;
      c[Length(c)-i]:=c[Length(c)-i]*p;
    od;
  fi;

  c:=c{[n,n-1..1]};
  for i in [1..n] do
    c[i]:=c[i]*(-1)^i;
  od;
  c:=PowersumsElsyms(c,nn);
  if ch=0 and nn>10 then
    # intermediate values might become too big; modular computation
    pl:=[];
    # bound for coefficients:
    # bound for m-Sum of Roots
    w:=Minimum([Maximum(m*den*RootBound(f),1)
                ]);
    # bound for elementary symmetric functions in numbers of absolute
    # value <=w
    b:=0;
    for i in [1..nn] do
      b:=Maximum(w^i*Binomial(nn,i),b);
    od;

    p:=Maximum(nn+1,10000);
    mp:=1;
    while mp<2*b do
      p:=NextPrimeInt(p);
      mp:=mp*p;
      Add(pl,p);
    od;
    Info(InfoGalois,3,"using modular method with ",Length(pl)," primes");
    b:=mp;

    mp:=[];
    for i in pl do
      Info(InfoGalois,3,"modulo ",i);
      k:=GF(i);
      mc:=SumRootsPolComp(k,List(c,j->(j mod i)* One( k ) ),m,n,nn);
      Add(mp,List(mc,IntFFE));

#      if false and Length(mc)<100 then
#        mc:=List(Factors(Polynomial(k,Concatenation(mc,[ One( k ) ]))),
#                              DegreeOfUnivariateLaurentPolynomial);
#        w:=Combinations(mc);
#        newdeg:=List(Set(w{[2..Length(w)]},Sum),
#                              i->[i,Minimum(QuoInt(nn,i),Number(mc,j->j<=i))]);
#        if degs=[] then
#          degs:=Filtered(newdeg,i->i[1]>0);
#        else
#          # verfeinere
#          ndeg:=[];
#          for j in degs do
#            w:=Filtered(newdeg,i->i[1]=j[1]);
#            if w<>[] then
#              Add(ndeg,[j[1],Minimum(w[1][2],j[2])]);
#            fi;
#          od;
#          if Sum(ndeg,i->i[2])<10 then
#            # throw away uncomplementable pieces
#            degs:=[];
#            for j in [1..Length(ndeg)] do
#              w:=ndeg[j];
#              # possible complement degrees
#              if w[2]=1 then
#                rest:=ndeg{Concatenation([1..j-1],[j+1..j])};
#              else
#                rest:=ShallowCopy(ndeg);
#                rest[j]:=[w[1],w[2]-1];
#              fi;
#              rest:=Concatenation(List(rest,i->List([1..i[2]],j->i[1])));
#              if (nn=w[1]) or (nn-w[1] in List(Combinations(rest),Sum)) then
#                Add(degs,w);
#              fi;
#            od;
#          else
#            degs:=ndeg;
#          fi;
#        fi;
#        Info(InfoGalois,3,"yields degrees ",degs);
#      fi;
    od;

    c:=[];
    for i in [1..nn] do
      w:=ChineseRem(pl,List(mp,j->j[i])) mod b;
      if 2*w>b then
        w:=w-b;
      fi;
      Add(c,w);
    od;
  else
    c:=SumRootsPolComp(fam,c,m,n,nn);
  fi;
  Add(c, One( fam ) );
  if den<>1 then
    # revert ``integerization'' if necessary
    p:=1;
    for i in [1..Length(c)-1] do
      p:=p*den;
      c[Length(c)-i]:=c[Length(c)-i]/p;
    od;
  fi;
  return UnivariatePolynomialByCoefficients(fam,c,
           IndeterminateNumberOfUnivariateRationalFunction(f));
end);

#############################################################################
##
#F  ProductRootsPol( <f>, <m> ) . . . . . . . . . . . . . . .  compute f^{xm}
##
InstallGlobalFunction(ProductRootsPol,function(f,m)
local c,n,nn,p,fam,i,j,h,w,q;
  Info(InfoGalois,3,"ProductRootsPol ",m);
  fam:=CoefficientsFamily(FamilyObj(f));
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  nn:=Binomial(n,m);
  c:=CoefficientsOfUnivariatePolynomial(f){[n,n-1..1]};
  for i in [1..n] do
    c[i]:=c[i]*(-1)^i;
  od;

  p:=PowersumsElsyms(c,m*nn);
  q:=[List(p{[1..nn]},i->i^0),p{[1..nn]}];
  q[1][1]:= One( fam );
  for i in [2..m] do
    q[i+1]:=[];
    for j in [1..nn] do
      w:= Zero( fam );
      for h in [1..i] do
        w:=w-(-1)^h*p[j*h]*q[i-h+1][j];
      od;
      q[i+1][j]:=w/i;
    od;
  od;
  p:=q[m+1];
  c:=ElsymsPowersums(p,nn);
  for i in [1..nn] do
    c[i]:=c[i]*(-1)^i;
  od;
  c:=Reversed(c);
  Add(c, One( fam ) );
  return UnivariatePolynomialByCoefficients(fam,c,
           IndeterminateNumberOfUnivariateRationalFunction(f));
end);

#############################################################################
##
##  Tschirnhausen(<pol>[,<trans>][,true]) . . . . . Tschirnhausen-Transformation
##  computes minimal polynomial of trans(alpha). If no <trans> is given, it
##  is taken by random. An added true will also return the <trans> polynomial.
##
InstallGlobalFunction(Tschirnhausen,function(arg)
local pol, fam, inum, r;
  pol:=arg[1];
  fam:=CoefficientsFamily(FamilyObj(pol));
  inum:=IndeterminateNumberOfUnivariateRationalFunction(pol);
  pol:=UnivariatePolynomialByCoefficients(fam,
         CoefficientsOfUnivariatePolynomial(pol),inum+1);
  if Length(arg)>1 and IsPolynomial(arg[2]) then
    r:=CoefficientsOfUnivariatePolynomial(arg[2]);
  else
    repeat
      r:=List([1..Minimum(DegreeOfUnivariateLaurentPolynomial(pol),
                          Random([2,2,2,2,3,3,3,4,5,6]))],
              i->One(fam)*Random(Integers));
    until not IsZero(r[Length(r)]);
  fi;
  r:=UnivariatePolynomialByCoefficients(fam,r,inum+1);
  Info(InfoPoly,2,"Tschirnhausen transformation with ",r);
  pol:=Resultant(pol,Indeterminate(fam,inum)-r,inum+1);
  if Length(arg)>2 then
    return [pol,r];
  else
    return pol;
  fi;
end);

#############################################################################
##
#F  TwoSeqPol( <f>, <m> ) . . . . . . . . . . . . . . . . . . compute f^{1+m}
##
InstallGlobalFunction(TwoSeqPol,function(pol,m)
local f,c,n,nn,p,fam,i,j,w,q;
  Info(InfoGalois,3,"TwoSeqPol ",m);
  f:=pol;
  fam:=CoefficientsFamily(FamilyObj(f));
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  nn:=n*(n-1);
  p:=0;
  repeat
    if p=1 then
      repeat
        f:=Tschirnhausen(pol);
      until DegreeOfUnivariateLaurentPolynomial(Gcd(f,Derivative(f)))=0;
    else
      f:=pol;
    fi;
    c:=CoefficientsOfUnivariatePolynomial(f){[n,n-1..1]};
    for i in [1..n] do
      c[i]:=c[i]*(-1)^i;
    od;

    p:=PowersumsElsyms(c,nn);
    p:=Concatenation([n* One( fam ) ],p);
    q:=[];
    for i in [1..nn] do
      w:=0;
      for j in [0..i] do
        w:=w+m^j*Binomial(i,j)*(p[j+1]*p[i-j+1]-p[i+1]);
      od;
      q[i]:=w;
    od;
    c:=ElsymsPowersums(q,nn);
    for i in [1..nn] do
      c[i]:=c[i]*(-1)^i;
    od;
    c:=Reversed(c);
    Add(c, One( fam ) );
    c:=UnivariatePolynomialByCoefficients(fam,c,
         IndeterminateNumberOfUnivariateRationalFunction(pol));
    p:=1;
  until DegreeOfUnivariateLaurentPolynomial(Gcd(c,Derivative(c)))=0;
  return c;
end);


#############################################################################
##
#F  GaloisSetResolvent(<pol>,<n>)                  <n>-set resolvent of <pol>
##
InstallGlobalFunction(GaloisSetResolvent,function(f,m)
local i,p,r,x,d;
  x:=Indeterminate(CoefficientsFamily(FamilyObj(f)),
    IndeterminateNumberOfUnivariateRationalFunction(f));
  # remember, which resolvent types already failed (most likely for
  # smaller sums), so we won't have to use them twice!
  # e.g.: if 2-Sum is double, then 3-Sum will vbe double most likely!
  if not IsBound(f!.failedResolvents) then
    f!.failedResolvents:=[];
  fi;
  if Value(f,-x)=f then
    # then for every root there is a negative one, causing trobles with sums
    f!.failedResolvents:=Union(f!.failedResolvents,[0,1,2]);
  fi;
  i:=0;
  d:=true;
  while d do
    if not i in f!.failedResolvents then
      Info(InfoGalois,2,"trying res nr. ",i);
      if i in [0,2,3] or i>5 then
        if i=0 then
          p:=f;
        elif i=2 then
          p:=Value(f,1/x)*x^DegreeOfUnivariateLaurentPolynomial(f);
          p:=p/LeadingCoefficient(p);
        elif i=3 then
          p:=Value(f,1/x+1)*x^DegreeOfUnivariateLaurentPolynomial(f);
          p:=p/LeadingCoefficient(p);
        else
          repeat
            p:=Tschirnhausen(f);
          until DegreeOfUnivariateLaurentPolynomial(Gcd(f,Derivative(f)))=0;
        fi;
        r:=SumRootsPol(p,m);
      else
        if i=1 then
          p:=f;
        elif i=4 then
          p:=Value(f,x+1);
        else
          p:=Value(f,x-2);
        fi;
        r:=ProductRootsPol(p,m);
      fi;
      d:=DegreeOfUnivariateLaurentPolynomial(Gcd(r,Derivative(r)))>0;
      if d and i<6 then
        # note failure
        AddSet(f!.failedResolvents,i);
      fi;
    fi;
    i:=i+1;
  od;
  return r;
end);


#############################################################################
##
#F  GaloisDiffResolvent(<pol>)  . . . . . . . . . . diff-resolvent of <pol>
##
InstallGlobalFunction(GaloisDiffResolvent,function(f)
local s,i,p,r,x,m,pc;
  m:=DegreeOfUnivariateLaurentPolynomial(f);
  x:=Indeterminate(CoefficientsFamily(FamilyObj(f)),
       IndeterminateNumberOfUnivariateRationalFunction(f));
  r:=x^2; # just to set initial value to non-squarefree pol
  i:=0;
  while DegreeOfUnivariateLaurentPolynomial(Gcd(r,Derivative(r)))>0 do
    if i=0 then
      p:=f;
    elif i=1 then
      p:=Value(f,1/x)*x^DegreeOfUnivariateLaurentPolynomial(f);
    elif i=2 then
      p:=Value(f,1/x+1)*x^DegreeOfUnivariateLaurentPolynomial(f);
    elif i=3 then
      # 1/(x-3)
      p:=Value(f,x-3);
      p:=Value(p,1/x)*x^DegreeOfUnivariateLaurentPolynomial(f);
    else
      repeat
        p:=Tschirnhausen(f);
      until DegreeOfUnivariateLaurentPolynomial(Gcd(f,Derivative(f)))=0;
    fi;
    p:=p/LeadingCoefficient(p);
    # The sum of the roots of p should be 0
    pc:=CoefficientsOfUnivariatePolynomial(p);
    s:=pc[Length(pc)-1];
  #Print(p," ",s,"\n");
    p:=Value(p,x-s/m);
    Info(InfoGalois,3,"p=",p);
    r:=SumRootsPol(p,m/2);
    if DegreeOfUnivariateLaurentPolynomial(Gcd(r,Derivative(r)))=0 then
      # x^2->x; the condition implies, that the @#%&*! valuation is zero

      r:=CoefficientsOfUnivariatePolynomial(r){[1,3..(DegreeOfUnivariateLaurentPolynomial(r)+1)]};
      #p:=2*[1..DegreeOfUnivariateLaurentPolynomial(r)/2+1]-1;
      r:=UnivariatePolynomialByCoefficients(CoefficientsFamily(FamilyObj(f)),r);
    fi;
    i:=i+1;
  od;
  return r;
end);

#############################################################################
##
#F  ShapeFrequencies . . . . . . . . . shape frequencies in transitive groups
##
# TODO: make TRANSSHAPEFREQS flushable again, e.g.
# using MemoizePosIntFunction or some other similar method
TRANSSHAPEFREQS := MakeWriteOnceAtomic([]);


BindGlobal("ShapeFrequencies",function(n,i)
local list,g,fu,j,k,ps,pps,sh;
  if not TransitiveGroupsAvailable(n) then
    Error("Transitive groups of degree ",n," are not available");
  fi;
  if not IsBound(TRANSSHAPEFREQS[n]) then
    TRANSSHAPEFREQS[n]:=MakeWriteOnceAtomic([]);
  fi;
  list:=TRANSSHAPEFREQS[n];
  if not IsBound(list[i]) then
    sh:=Partitions(n);
    g:=TransitiveGroup(n,i);
    fu:=List([1..Length(sh)-1],i->0);
    for j in ConjugacyClasses(g) do
      ps:=ShallowCopy(CycleStructurePerm(Representative(j)));
      pps:=[];
      for k in [1..Length(ps)] do
        if IsBound(ps[k]) then
          while ps[k]>0 do
            Add(pps,k+1);
            ps[k]:=ps[k]-1;
          od;
        fi;
      od;
      while Sum(pps)<n do
        Add(pps,1);
      od;
      Sort(pps);
      pps:=Reversed(pps);
      ps:=Position(sh,pps)-1;
      if ps>0 then
        fu[ps]:=fu[ps]+Size(j);
      fi;
    od;
    fu:=fu/Size(g);
    list[i]:=fu;
  fi;
  return list[i];
end);

#############################################################################
##
#F  ProbabilityShapes(<pol>,[<discard>]) . . . . . . . . . Tschebotareff test
##
InstallGlobalFunction(ProbabilityShapes,function(arg)
local f,n,i,sh,fu,ps,pps,ind,keineu,ba,bk,j,a,anz,pm,
      cnt,cand,d,alt,p,weg,fac;
  Info(InfoPerformance,2,"Using Transitive Groups Library");
  f:=arg[1];
  f:=f/LeadingCoefficient(f);
  if not IsIrreducibleRingElement(f) then
    Error("f must be irreducible");
  fi;
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  if not TransitiveGroupsAvailable(n) then
    Error("Transitive groups of degree ",n," are not available");
  fi;
  fac:=3;
  if n>11 then
    fac:=7;
  elif n>7 then
    fac:=5;
  fi;

  cand:=[1..NrTransitiveGroups(n)];
  if Length(arg)=2 then
    weg:=arg[2];
  else
    weg:=[];
  fi;
  d:=Discriminant(f);
  alt:= d>0 and ParityPol(Rationals,f)=1;
  if alt then
    cand:=Filtered(cand,i->TRANSProperties(n,i)[4]=1);
  fi;
  p:=1;
  # Nenner mit in den Z"ahler bringen
  d:=d*DenominatorRat(d)^2
      *Lcm(List(CoefficientsOfUnivariatePolynomial(f),DenominatorRat));
  Info(InfoGalois,1,"Partitions Test");
  n:=DegreeOfUnivariateLaurentPolynomial(f);

  sh:=Partitions(n);
  fu:=List([1..Length(sh)-1],ReturnFalse);
  anz:=List(fu,i->0);
  cnt:=0;
  keineu:=0;
  repeat
    repeat
      repeat
        p:=NextPrimeInt(p);
      until not IsInt(d/p);
      pm:=PolynomialModP(f,p);
    until
    DegreeOfUnivariateLaurentPolynomial(pm)=DegreeOfUnivariateLaurentPolynomial(f);
    ps:=List(Factors(pm),DegreeOfUnivariateLaurentPolynomial);
    Sort(ps);
    ps:=Reversed(ps);
    ind:=Position(sh,ps)-1;
    cnt:=cnt+1;
    if ind>0 then
      anz[ind]:=anz[ind]+1;
      if fu[ind]=false then
        keineu:=0;
        fu[ind]:=true;
        cand:=Filtered(cand,i->TRANSProperties(n,i)[5][ind]);
        if IsSubset(weg,cand) then
          return [];
        fi;
        # add power cycleshapes, we just need the powers to |g|/2
        for i in [2..QuoInt(Lcm(ps),2)] do
          pps:=PowerPartition(ps,i);
          Sort(pps);
          pps:=Reversed(pps);
          fu[Position(sh,pps)-1]:=true;
        od;
      elif ForAny([1..NrTransitiveGroups(n)],i->TRANSProperties(n,i)[5]=fu) then
        keineu:=keineu+1;
      fi;
    fi;
  until Length(cand)<2 or keineu>fac*n or p>500*n;
  cand:=Difference(cand,weg);
  Info(InfoGalois,2,"cands:",cand);
  if Length(cand)=0 then
    return [];
  elif Length(cand)=1 then
    return cand;
  fi;
  anz:=anz/cnt;
  ba:="infinity";
  bk:=[];
  for i in cand do
    fu:=ShapeFrequencies(n,i);
    a:=0;
    for j in [1..Length(fu)] do
      a:=a+(fu[j]-anz[j])^2;
    od;
    if a<ba then
      ba:=a;
      bk:=[i];
    elif a=ba then
      Add(bk,i);
    fi;
  od;
  bk:=Difference(bk,weg);
  return bk;
end);

#############################################################################
##
#F  PartitionsTest(<pol>,<prime>,<cand>,<discr>)  internal Tschebotareff test
##
BindGlobal("PartitionsTest",function(f,p,cand,d)
local n,i,sh,fu,ps,pps,ind,keineu,avoid,cf;
  # Nenner mit in den Z"ahler bringen
  cf:=CoefficientsOfUnivariatePolynomial(f);
  avoid:=Lcm(Concatenation([NumeratorRat(d),DenominatorRat(d)],
                List(cf,DenominatorRat),[NumeratorRat(cf[Length(cf)])]));
  Info(InfoGalois,1,"Partitions Test");
  n:=DegreeOfUnivariateLaurentPolynomial(f);

  sh:=Partitions(n);
  fu:=List([1..Length(sh)-1],ReturnFalse);
  keineu:=0;
  repeat
    repeat
      p:=NextPrimeInt(p);
    until not IsInt(avoid/p);
    ps:=List(Factors(PolynomialModP(f,p)),DegreeOfUnivariateLaurentPolynomial);
    Sort(ps);
    ps:=Reversed(ps);
    ind:=Position(sh,ps)-1;
    if ind>0 then
      if fu[ind]=false then
        keineu:=0;
        fu[ind]:=true;
        cand:=Filtered(cand,i->TRANSProperties(n,i)[5][ind]);
        # add power cycleshapes, we just need the powers to |g|/2
        for i in [2..QuoInt(Lcm(ps),2)] do
          pps:=PowerPartition(ps,i);
          Sort(pps);
          pps:=Reversed(pps);
          fu[Position(sh,pps)-1]:=true;
        od;
      elif ForAny([1..NrTransitiveGroups(n)],i->TRANSProperties(n,i)[5]=fu) then
        keineu:=keineu+1;
      fi;
    fi;
  until Length(cand)=1 or keineu>3*n or p>500*n;
  Info(InfoGalois,2,"cands:",cand);
  return [p,cand];
end);



#############################################################################
##
#F  GaloisType(<pol>,[<cands>]) . . . . . . . . . . . . . compute Galois type
##
##  The optional 2nd argument may be used to restrict the range of transitive
##  permutation groups that will be considered as possible Galois groups.
##  The use of the 2nd argument is experimental and is not documented.
##
BindGlobal("DoGaloisType",function(arg)
local f,n,p,cand,noca,alt,d,co,dco,res,resf,pat,i,j,k,
      orbs,GetResolvent,norb,act,repro,minpol,ext,ncand,pos,step,lens,gudeg,
      typ,pkt,fun,factors,stabs,stanr,nostanr,degs,GetProperty,
      GrabCodedLengths,UnParOrbits,cnt,polring,basring,indet,indnum,
      extring,lpos;

  Info(InfoPerformance,2,"Using Transitive Groups Library");
  GetProperty := function(l,prop)
  local i;
    for i in l{[9..Length(l)]} do
      if i[1]=prop then
        return i;
      fi;
    od;
    return false;
  end;

  GrabCodedLengths := function(lst)
  local i,l;
    lst:=Flat(lst);
    l:=[];
    for i in lst do
      if i<0 then i:=-i;fi;
      AddSet(l,i mod (10^Maximum(2,LogInt(i,10)-1)));
    od;
    return l;
  end;

  GetResolvent:=function(pol,nr)
  local p,pf;
    # normieren
    if LeadingCoefficient(pol)<>1 then
      pol:=pol/LeadingCoefficient(pol);
    fi;
    if not IsBound(orbs[nr]) then
      if nr=1 then
        orbs[nr]:=pol;
      elif nr=2 or nr=3 or nr=5 then
        orbs[nr]:=GaloisSetResolvent(pol,nr);
      elif nr=4 then
        if DegreeOfUnivariateLaurentPolynomial(pol)=8 then
          # special case deg8, easy pre-factorization
          p:=GaloisDiffResolvent(pol);
          # store Diff-Resolvent for future use
          orbs[6]:=p;
          pf:=Concatenation(List(Factors(p),
                              i->Factors(Value(i,indet^2))));
          # replace X^2
          p:=Value(p,indet^2);
          StoreFactorsPol(polring,p,pf);
          orbs[nr]:=p;
        else
          orbs[nr]:=GaloisSetResolvent(pol,4);
        fi;
      elif nr=6 then
        orbs[nr]:=GaloisDiffResolvent(pol);
      elif nr=9 then
        orbs[nr]:=TwoSeqPol(pol,2);
      else
        Error("Operation ",nr," not defined");
      fi;
      if nr<>4 or DegreeOfUnivariateLaurentPolynomial(pol)<>8 then
        #we minimize, unless we have already computed a factorization
        orbs[nr]:=MinimizedBombieriNorm(orbs[nr])[1];
      fi;
    fi;
    Info(InfoGalois,5,"Resolvent is =",orbs[nr],"\n");
    return orbs[nr];
  end;

  UnParOrbits := function(l)
  local i,m;
    m:=[];
    for i in l do
      i:=AbsInt(i);
      while i>1000 do
        Add(m,i mod 1000);
        i:=i-1000;
      od;
      Add(m,i);
    od;
    return Collected(m);
  end;

  norb:=["Roots","2-Sets","3-Sets","4-Sets","5-Sets","Diff",
         7,"Blocks","2-Sequences"];

  f:=arg[1];

  basring:=Rationals;
  indnum:=IndeterminateNumberOfUnivariateRationalFunction(f);
  indet:=Indeterminate(basring,indnum);
  polring:=PolynomialRing(basring,[indnum]);

  if LeadingCoefficient(f)<>1 then
    f:=f/LeadingCoefficient(f);
  fi;

  k:=Lcm(List(CoefficientsOfUnivariatePolynomial(f),DenominatorRat));
  if k>1 then
    f:=indet^DegreeOfUnivariateLaurentPolynomial(f)*Value(f,k/indet);
  fi;

  # minimize f
  f:=MinimizedBombieriNorm(f)[1];

  if not(IsIrreducibleRingElement(f)) then
    Error("f must be irreducible");
  fi;
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  if not TransitiveGroupsAvailable(n) then
    Error("Transitive groups of degree ",n," are not available");
  fi;

  if Length(arg)=1 then
    cand:=[1..NrTransitiveGroups(n)];
  else
    cand:=arg[2];
  fi;
  d:=Discriminant(f);
  alt:= d>0 and ParityPol(basring,f)=1;
  if alt then
    cand:=Filtered(cand,i->TRANSProperties(n,i)[4]=1);
  fi;
  p:=PartitionsTest(f,1,cand,d);
  cand:=p[2];
  p:=p[1];

  orbs:=[];

  # 2Set-Orbit Lengths
  co:=List([1..NrTransitiveGroups(n)],i->TRANSProperties(n,i)[6]);
  if Length(Set(co{cand}))>1 then
    Info(InfoGalois,1,"2-Set Resolvent");
    #degs:=List(co,GrabCodedLengths);

    dco:=[];
    for i in cand do
      dco[i]:=UnParOrbits(co[i]);
    od;
    degs:=Set(Flat(List(dco,x->List(x,y->y[1]))));
    res:=GetResolvent(f,2);
    resf:=Factors(polring,res:factoroptions:=rec(onlydegs:=degs));
    StoreFactorsPol(polring,res,resf);
    pat:=Collected(List(resf,DegreeOfUnivariateLaurentPolynomial));

    cand:=Filtered(cand,i->dco[i]=pat);
    if Length(Set(co{cand}))>1 then
      pat:=List(Collected(List(resf,i->ParityPol(basring,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
      Sort(pat);
      cand:=Filtered(cand,i->co[i]=pat);
    fi;
    Info(InfoGalois,1,"Candidates :",cand);
  fi;

  # 2Seq-Orbit Lengths
  co:=List([1..NrTransitiveGroups(n)],i->TRANSProperties(n,i)[7]);
  if Length(Set(co{cand}))>1 then
    Info(InfoGalois,1,"2-Seq Resolvent");
    #degs:=List(co,GrabCodedLengths);

    dco:=[];
    for i in cand do
      dco[i]:=UnParOrbits(co[i]);
    od;
    degs:=Set(Flat(List(dco,x->List(x,y->y[1]))));
    res:=GetResolvent(f,9);
    resf:=Factors(polring,res:factoroptions:=rec(onlydegs:=degs));
    StoreFactorsPol(polring,res,resf);
    pat:=Collected(List(resf,DegreeOfUnivariateLaurentPolynomial));

    cand:=Filtered(cand,i->dco[i]=pat);
    if Length(Set(co{cand}))>1 then
      pat:=List(Collected(List(resf,i->ParityPol(basring,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
      Sort(pat);
      cand:=Filtered(cand,i->co[i]=pat);
    fi;
    Info(InfoGalois,1,"Candidates :",cand);
  fi;

  # 3Set-Orbit Lengths
  co:=List([1..NrTransitiveGroups(n)],i->TRANSProperties(n,i)[8]);
  if n>=5 and Length(Set(co{cand}))>1 then
    Info(InfoGalois,1,"3-Set Resolvent");

    dco:=[];
    for i in cand do
      dco[i]:=UnParOrbits(co[i]);
    od;
    degs:=Set(Flat(List(dco,x->List(x,y->y[1]))));
    res:=GetResolvent(f,3);
    resf:=Factors(polring,res:factoroptions:=rec(onlydegs:=degs));
    StoreFactorsPol(polring,res,resf);
    pat:=Collected(List(resf,DegreeOfUnivariateLaurentPolynomial));

    cand:=Filtered(cand,i->dco[i]=pat);
    if Length(Set(co{cand}))>1 then
      pat:=List(Collected(List(resf,i->ParityPol(basring,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
      Sort(pat);
      cand:=Filtered(cand,i->co[i]=pat);
    fi;
    Info(InfoGalois,1,"Candidates :",cand);
  fi;

  # now search among the remaining candidates for a better
  # discriminating property

  repro:=Union(List(cand,
             i->List(TRANSProperties(n,i){[9..Length(TRANSProperties(n,i))]},
                     j->j[1])));

  # filter out the properties we cannot use
  repro:=Filtered(repro,i->i>0);

  while Length(cand)>1 and Length(repro)>0 do
    act:=repro[1];
    repro:=Difference(repro,[act]);
    noca:=Filtered(cand,i->Length(TRANSProperties(n,i))<=8 or
                           GetProperty(TRANSProperties(n,i),act)=false);
    cand:=Difference(cand,noca);
    co:=[];
    for i in cand do
      co[i]:=GetProperty(TRANSProperties(n,i),act);
      co[i]:=co[i]{[2..Length(co[i])]};
    od;
    if Length(Set(co{cand}))>1 then
      if act>=4 and act<=6 then
        Info(InfoGalois,1,norb[act]," Resolvent");
        dco:=[];
        for i in cand do
          co[i]:=co[i][1]; # throw away unneeded list
          dco[i]:=UnParOrbits(co[i]);
        od;
        degs:=List(Compacted(co),GrabCodedLengths);

        res:=GetResolvent(f,act);
        resf:=Factors(polring,res:factoroptions:=rec(onlydegs:=Union(degs)));
        StoreFactorsPol(polring,res,resf);
        pat:=Collected(List(resf,DegreeOfUnivariateLaurentPolynomial));

        cand:=Filtered(cand,i->dco[i]=pat);
        if Length(Set(co{cand}))>1 then
          pat:=List(Collected(List(resf,i->ParityPol(basring,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                    i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
          Sort(pat);
          cand:=Filtered(cand,i->co[i]=pat);
        fi;
      elif act>20 and act<50 then

        # alternating subgroup (and point stabilizer)
        if QuoInt(act,10)=2 then
          # avoid using the discriminant (which can be too big), but use
          # the non-square part instead:
          Info(InfoGalois,1,"Alternating subgroup orbits on ",
                          norb[act mod 10]);
          minpol:=indet^2-
            Product(List(Filtered(Collected(Factors(NumeratorRat(d))),
                               i->not IsInt(i[2]/2)),i->i[1]))/
            Product(List(Filtered(Collected(Factors(DenominatorRat(d))),
                               i->not IsInt(i[2]/2)),i->i[1]));
        else
          Info(InfoGalois,1,"point stabilizer orbits on ",norb[act mod 10]);
          minpol:=f;
        fi;
        act:=act mod 10;

        ext:=AlgebraicExtension(basring,minpol);
        extring:=PolynomialRing(ext,[indnum]);
        res:=List(Factors(GetResolvent(f,act)),
                 i->AlgExtEmbeddedPol(ext,i));
        lens:=[];
        for step in [1,2] do
          dco:=[];
          for i in cand do
            if step=1 then
              dco[i]:=List(co[i],UnParOrbits);
              lens[i]:=List(dco[i],i->Sum(List(i,j->j[1]*j[2])));
            else
              dco[i]:=StructuralCopy(co[i]);
            fi;
          od;

          # compute, which factor we will not have to factor at all
          # since they split always the same
          gudeg:=[];
          for j in Set(Flat(lens)) do
            pat:=[];
            for i in cand do
              Add(pat,Collected(dco[i]{Filtered([1..Length(dco[i])],
                      k->lens[i][k]=j)}));
            od;
            if Length(Set(pat))=1 then
              Info(InfoGalois,2,"ignoring length ",j);
            else
              Add(gudeg,j);
            fi;
          od;

          for i in res do
            if (DegreeOfUnivariateLaurentPolynomial(i) in gudeg)
               and (Length(Set(dco{cand}))>1) then
              if step=1 then
                pat:=Collected(List(Factors(extring,i),DegreeOfUnivariateLaurentPolynomial));
              else
                pat:=List(Collected(List(Factors(extring,i),
                                       i->ParityPol(ext,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                        i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
                Sort(pat);
              fi;
              ncand:=[];
              for j in cand do
                pos:=Position(dco[j],pat);
                if pos<>fail then
                  Add(ncand,j);
                  Unbind(dco[j][pos]);
                fi;
              od;
              cand:=ncand;
            fi;
          od;
        od;

      elif act>100 and act<1000 then
        # factor groups Galois
        typ:=QuoInt(act,100);
        pkt:=act mod 100;
        Info(InfoGalois,1,"Galois group of ",norb[typ],
                    " factor on ",pkt," points");
        dco:=[];
        for i in cand do
          dco[i]:=ShallowCopy(co[i][1]);
        od;
        res:=Filtered(Factors(GetResolvent(f,typ)),i->DegreeOfUnivariateLaurentPolynomial(i)=pkt);
        i:=1;
        while i<=Length(res) and Length(dco{cand})>1 do
          pat:=GaloisType(res[i]);
          if IsList(pat) then
            Error("Sub-Galois call not unique!");
          fi;
          ncand:=[];
          for j in cand do
            if pat in dco[j] then
              Add(ncand,j);
              Unbind(dco[j][Position(dco[j],pat)]);
            fi;
          od;
          cand:=ncand;
          i:=i+1;
        od;

      elif act>1000 and act<10000 then

        # factor groups
        typ:=QuoInt(act,1000);
        act:=act mod 1000;
        pkt:=QuoInt(act,10);
        act:=act mod 10;
        Info(InfoGalois,1,norb[typ]," factor on ",pkt," points, on ",
                          norb[act]);
        factors:=Filtered(Factors(GetResolvent(f,typ)),
                                      i->DegreeOfUnivariateLaurentPolynomial(i)=pkt);

        if act=2 or act=3 then
          fun:=function(pol)
                 return GaloisSetResolvent(pol,act);
               end;
        elif act=9 then
          fun:=function(pol)
                 return TwoSeqPol(pol,2);
               end;
        else
          Error("This operation is not supported for factor groups!");
        fi;
        res:=List(factors,fun);

        for step in [1,2] do

          dco:=[];
          for i in cand do
            if step=1 then
              dco[i]:=List(co[i],UnParOrbits);
            else
              dco[i]:=StructuralCopy(co[i]);
            fi;
          od;

          for i in res do

            if (Length(Set(co{cand}))>1) then
              if step=1 then
                pat:=Collected(List(Factors(polring,i),DegreeOfUnivariateLaurentPolynomial));
              else
                pat:=List(Collected(List(Factors(polring,i),
                                       i->ParityPol(basring,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                        i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
                Sort(pat);
              fi;
              ncand:=[];
              for j in cand do
                pos:=Position(dco[j],pat);
                if pos<>fail then
                  Add(ncand,j);
                  Unbind(dco[j][pos]);
                fi;
              od;
              cand:=ncand;
            fi;

          od;
        od;

      elif act>10000 and act<100000 then
        # stabilisator orbits
        typ:=QuoInt(act,10000);
        act:=act mod 10000;
        pkt:=QuoInt(act,10);
        act:=act mod 10;
        Info(InfoGalois,1,norb[typ]," stabilizer of index ",pkt," on ",
                          norb[act]);
        stabs:=Filtered(Factors(GetResolvent(f,typ)),
                                      i->DegreeOfUnivariateLaurentPolynomial(i)=pkt);

        # stabilizers, which have already been identified completely
        nostanr:=[];

        for minpol in stabs do
          stanr:=Difference([1..Length(stabs)],nostanr);
          ext:=AlgebraicExtension(basring,minpol);
          extring:=PolynomialRing(ext,[indnum]);
          res:=List(Factors(GetResolvent(f,act)),
                   i->AlgExtEmbeddedPol(ext,i));
          lens:=[];
          for step in [1,2] do
            dco:=[];
            for i in cand do
              if step=1 then
                dco[i]:=List(co[i],i->List(i{stanr},UnParOrbits));
                lens[i]:=List(dco[i],i->Sum(List(i[1],j->j[1]*j[2])));
              else
                dco[i]:=List(StructuralCopy(co[i]),i->i{stanr});
              fi;
            od;

            # compute, which factor we will not have to factor at all
            # since they split always the same
            gudeg:=[];
            for j in Set(Flat(lens)) do
              pat:=[];
              for i in cand do
                Add(pat,Collected(dco[i]{Filtered([1..Length(dco[i])],
                        k->lens[i][k]=j)}));
              od;
              if Length(Set(pat))=1 then
                Info(InfoGalois,2,"ignoring length ",j);
              else
                Add(gudeg,j);
              fi;
            od;

            for i in res do
              if (DegreeOfUnivariateLaurentPolynomial(i) in gudeg)
                 and (Length(Set(dco{cand}))>1) then
                if step=1 then
                  pat:=Collected(List(Factors(extring,i),DegreeOfUnivariateLaurentPolynomial));
                else
                  pat:=List(Collected(List(Factors(extring,i),
                                         i->ParityPol(ext,i)*DegreeOfUnivariateLaurentPolynomial(i))),
                          i->SignInt(i[1])*(1000*(i[2]-1)+AbsInt(i[1])));
                  Sort(pat);
                fi;
                ncand:=[];
                for j in cand do
                  pos:=Filtered([1..Length(dco[j])],i->pat in dco[j][i]);
                  if pos<>[] then
                    # we found an occurrence: Note the possible stabilizers
                    stanr:=stanr{pos};
                    # and update the patterns accordingly.
                    dco:=List(dco,i->i{pos});
                    Add(ncand,j);
                    # mark occurrence as found
                    for k in dco[j] do
                      # we may not unbind, since sublist will fail otherwise
                      lpos:=Position(dco[j],pat);
                      if lpos=fail then
                        lpos:=Position(dco[j],[pat]);
                      fi;
                      k[lpos]:="weg";
                    od;
                  fi;
                od;
                cand:=ncand;
              fi;
            od;
          od;
          if Length(stanr)=1 then
            #the stabilizer has been identified completely, we will not
            # have to deal with this stab anymore
            nostanr:=Union(nostanr,stanr);
          fi;
        od;

      else
        Error("property ",act," not yet implemented");
      fi;
    fi;
    cand:=Union(cand,noca);
    if Length(cand)>1 then
      Info(InfoGalois,1,"Candidates :",cand);
    fi;
  od;

  # Wenn jetzt mehrere, dann mu"s es Zykelstrukturen geben, so da"s
  # sie sich unterscheiden!(Ausnahmef"alle au"senvorgelassen)
  cnt:=0;
  while (Length(cand)>1 and cnt<=10000) do
    p:=PartitionsTest(f,p,cand,d);
    p:=p[1];
    cnt:=cnt+1;
  od;

  # still no discrimination ?
  if Length(cand)>1 then
    # special cases
    if n=12 and
      IsSubset(cand,[273,292]) then
      #2SetStab 18 factor
      res:=First(Factors(GetResolvent(f,2)),i->DegreeOfUnivariateLaurentPolynomial(i)=18);
      #2SetStab 9 factor
      res:=First(Factors(GaloisSetResolvent(res,2)),i->DegreeOfUnivariateLaurentPolynomial(i)=9);
      res:=GaloisType(res);
      if res=22 then
        return 273;
      else
        return 292;
      fi;
    fi;

    Error(cand," feasible discrimination not known");
  fi;

  return cand[1];
end);

InstallMethod(GaloisType,"for polynomials",true,
  [IsUnivariateRationalFunction and IsPolynomial],0,
  DoGaloisType);

InstallOtherMethod(GaloisType,"for polynomials and list",true,
  [IsUnivariateRationalFunction and IsPolynomial,IsList],0,
  DoGaloisType);
