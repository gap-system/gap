#
# This file contains code which formerly was in lib/algfld.gi
#



#############################################################################
##
#M  DefectApproximation(<e>)
##
InstallMethod(DefectApproximation,"Algebraic Extension",true,
  [IsAlgebraicExtension],0,
function(e)
local f, d, def, w, i, dr, g, g1, cf, f0, f1, h, p;

  if LeftActingDomain(e)<>Rationals then
    Error("DefectApproximation is only for extensions of the rationals");
  fi;
  f:=DefiningPolynomial(e);
  f:=f*Lcm(List(CoefficientsOfUnivariatePolynomial(f),DenominatorRat));
  d:=Discriminant(f);
  # largest square, that divides discriminant
  if d>=0 and RootInt(d)^2=d then
    def:=RootInt(d);
  else
    def:=Factors(AbsInt(d));
    w:=[];
    for i in def do
      if not IsPrimeInt(i) then
        i:=RootInt(i);
        Add(w,i);
      fi;
      Add(w,i);
    od;
    def:=Product(Collected(w),i->i[1]^QuoInt(i[2],2));
  fi; 
  # reduced discriminant (c.f. Bradford's thesis)
  dr:=Lcm(Union(List(GcdRepresentation(f,Derivative(f)),
          i->List(CoefficientsOfUnivariatePolynomial(i),DenominatorRat))));
  def:=Gcd(def,dr);
  for p in Filtered(Factors(def),i->i<65536 and IsPrime(i)) do
    # test, whether we can drop i:
    ##  Apply the Dedekind-Kriterion by Zassenhaus(1975), cf. Bradford's thesis.
    g:=Collected(Factors(PolynomialModP(f,p)));
    g1:=[];
    for i in g do
      cf:=CoefficientsOfUnivariateLaurentPolynomial(i[1]);
      Add(g1,LaurentPolynomialByCoefficients(FamilyObj(1),
        List(cf[1],Int),cf[2],
	IndeterminateNumberOfLaurentPolynomial(i[1])));
    od;
    f0:=Product(g1);
    f1:=Product(List([1..Length(g)],i->g1[i]^(g[i][2]-1)));
    h:=(f-f0*f1)/p;
    g:=Gcd(PolynomialModP(f1,p),PolynomialModP(h,p));

    if DegreeOfLaurentPolynomial(g)=0 then
      while IsInt(def/p) do
        def:=def/p;
      od;
    fi;
  od;
  return def;
end);


#############################################################################
##
#F  ChaNuPol(<pol>,<alphamod>,<alpha>,<modfieldbase>,<field> . reverse modulo
##  transfer pol from modfield with alg. root alphamod to field with
##  alg. root alpha by taking the standard preimages of the coefficients
##  mod p
##
BindGlobal("ChaNuPol",function(f,alm,alz,coeffun,fam,inum)
local b,p,r,nu,w,i,z,fnew;
  p:=Characteristic(alm);
  z:=Z(p);
  r:=PrimitiveRootMod(p);
  nu:=0*alm;
  b:=IsPolynomial(f);
  if b then
    f:=CoefficientsOfUnivariateLaurentPolynomial(f);
    f:=ShiftedCoeffs(f[1],f[2]);
  else
    f:=[f];
  fi;
  fnew:=[]; # f could be compressed vector, so we cannot assign to it.
  for i in [1..Length(f)] do
    w:=f[i];
    if w=nu then
      w:=Zero(alz);
    else
      if IsFFE(w) and DegreeFFE(w)=1 then
        w:=PowerModInt(r,LogFFE(w,z),p)*One(alz);
      else
        w:=ValuePol(List(coeffun(w),IntFFE),alz);
      fi;
    fi;
    #f[i]:=w;
    fnew[i]:=w;
  od;
  return UnivariatePolynomialByCoefficients(fam,fnew,inum);
end);


#############################################################################
##
#F  AlgebraicPolynomialModP(<field>,<pol>,<indetimage>,<prime>) . .  internal
##      reduces <pol> mod <prime> to a polynomial over <field>, mapping 
##      'alpha' of f to <indetimage>
##
BindGlobal("AlgebraicPolynomialModP",function(fam,f,a,p)
local fk, w, cf, i, j;
  fk:=[];
  for i in CoefficientsOfUnivariatePolynomial(f) do
    if IsRat(i) then
      Add(fk,One(fam)*(i mod p));
    else
      w:=Zero(fam);
      cf:=ExtRepOfObj(i);
      for j in [1..Length(cf)] do
        w:=w+(cf[j] mod p)*a^(j-1);
      od;
      Add(fk,w);
    fi;
  od;
  return
  UnivariatePolynomialByCoefficients(fam,fk,
    IndeterminateNumberOfUnivariateLaurentPolynomial(f));
end);

#############################################################################
##
#F  AlgFacUPrep( <f> ) . . . . Hensel preparation: f=\prod ff, \sum h_i u_i=1
##
BindGlobal("AlgFacUPrep",function(R,f)
local ff,h,u,i,j,ggt,ggr;
  h:=[];
  ff:=Factors(R,f);
  for i in [1..Length(ff)] do
    h[i]:=f/ff[i];
  od;
  u:=[One(CoefficientsFamily(FamilyObj(f)))]; 
  ggt:=h[1];
  for i in [2..Length(ff)] do
    ggr:=GcdRepresentation(ggt,h[i]);
    ggt:=Gcd(ggt,h[i]);
    for j in [1..i-1] do
      u[j]:=u[j]*ggr[1];
    od;
    u[i]:=ggr[2];
  od;
  return u;
end);

#############################################################################
##
#F  TransferedExtensionPol(<ext>,<polynomial>[,<minpol>]) 
##  interpret polynomial over different algebraic extension. If minpol
##  is given, the algebraic elements are reduced according to minpol.
##
BindGlobal("TransferedExtensionPol",function(arg)
local atc, kl, inum, alfam, red, c, operations, i;
  atc:=CoefficientsOfUnivariateLaurentPolynomial(arg[2]);
  kl:=ShallowCopy(atc[1]);
  inum:=arg[Length(arg)];
  alfam:=ElementsFamily(FamilyObj(arg[1]));
  if Length(arg)>3 then
    red:=CoefficientsOfUnivariatePolynomial(arg[3]);
    # Rational case, reduce according to Minpol
    for i in [1..Length(kl)] do
      if IsAlgebraicElement(kl[i]) then
        #c:=RemainderCoeffs(kl[i].coefficients,red);
	c:=QuotRemPolList(ExtRepOfObj(kl[i]),red)[2];
        if Length(red)=2 then
          kl[i]:=c[1];
        else
          while Length(c)<Length(red)-1 do
            Add(c,0*red[1]);
          od;
          kl[i]:=AlgExtElm(alfam,c);
        fi;
      fi;
    od;
  else
    for i in [1..Length(kl)] do
      if IsAlgebraicElement(kl[i]) then
	kl[i]:=AlgExtElm(alfam,ExtRepOfObj(kl[i]));
      fi;
    od;
  fi;
  return LaurentPolynomialByExtRepNC(RationalFunctionsFamily(alfam),
           kl,atc[2],inum);
end);

#############################################################################
##
#F  OrthogonalityDefectEuclideanLattice(<lattice>,<latticebase>)
##
BindGlobal("OrthogonalityDefectEuclideanLattice",function(bas)
  return AbsInt(Product(List(bas,i->RootInt(i*i,2)+1))/ DeterminantMat(bas));
end);

#############################################################################
##
##  AlgExtSquareHensel( <ring>, <pol> )   hensel factorization over alg.
##                    extension. Suppose f is squarefree, has valuation 0
##                  Lenstra's or Weinberger's method
##
InstallGlobalFunction(AlgExtSquareHensel,function(R,f,opt)
local K, inum, fact, degf, m, degm, dis, def, cf, d, avoid, bw, zaehl, p,
      mm, pr, mmf, nm, dm, al, kp, ff, i, gut, w, bp, bpr, bff, bkp, bal,
      bmm, kpcoeffun, fff, degs, bounds, numbound, yet, ordef, lenstra,
      weinberger, method, pex, actli, lbound, U, u, rfunfam, ext, fam, q,
      max, M, newq, a, ef, bound, Mi, ind, perm, alfam, dl, sel, act, len,
      degsm, comb, v, dd, cbn, l, ps, z, wc, j, k,methname;

  K:=CoefficientsRing(R);
  inum:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);

  fact:=[];

  degf:=DegreeOfLaurentPolynomial(f);

  m:=DefiningPolynomial(K);
  if IndeterminateNumberOfUnivariateLaurentPolynomial(m)<>inum then
    m:=Value(m,Indeterminate(LeftActingDomain(K),inum));
  fi;
  degm:=DegreeOfLaurentPolynomial(m);

  dis:=Discriminant(m);

  def:=DefectApproximation(K);

  # find lcm of Denominators
  cf:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];
  d:=Lcm(Concatenation(Flat(List(cf,i->List(ExtRepOfObj(i),DenominatorRat))),
	List(CoefficientsOfUnivariateLaurentPolynomial(m)[1],DenominatorRat)));

  # find prime which does not divide the denominator and minpol is sqarefree
  # mod p. This is obviously satisfied, if we take d to be the Lcm of
  # the denominators and the discriminant
 
  avoid:=Lcm(d,dis*DenominatorRat(dis)^2,def);

  bw:="infinity";
  zaehl:=1;
  p:=1;

  repeat
    p:=NextPrimeInt(p);
    while DenominatorRat(avoid/p)=1 do
      p:=NextPrimeInt(p);
    od;
    mm:=PolynomialModP(m,p);
    pr:=PolynomialRing(GF(p),[inum]);
    mmf:=Factors(pr,mm);
    nm:=Length(mmf);
    Sort(mmf,function(a,b)
               return DegreeOfLaurentPolynomial(a)>DegreeOfLaurentPolynomial(b);
             end);

    dm:=List(mmf,DegreeOfLaurentPolynomial);

    if dm[1]>1 
       # don't even risk problems with the @#$%&! valuation!
       and ForAll(mmf,i->CoefficientsOfUnivariateLaurentPolynomial(i)[2]=0) then
      al:=[];
      kp:=[];
      ff:=[];
      i:=1;
      gut:=true;
      while gut and i<=nm do

        # cope with the too small range of finite fields in GAP
        if p^DegreeOfLaurentPolynomial(mmf[i])<=65536 then
	  kp[i]:=GF(GF(p),CoefficientsOfUnivariatePolynomial(mmf[i]));
	  if DegreeOfLaurentPolynomial(mmf[i])>1 then
	    al[i]:=RootOfDefiningPolynomial(kp[i]);
	  else
	    al[i]:=CoefficientsOfUnivariateLaurentPolynomial(-mmf[i])[1][1];
	  fi;
	  kp[i]!.myBasis:=Basis(kp[i],List([0..DegreeOfLaurentPolynomial(mmf[i])-1],j->al[i]^j));
	  kp[i]!.myCoeffun:=x->Coefficients(kp[i]!.myBasis,x);
	elif (IsRat(bw) and Length(Factors(bpr,bmm))=1 and zaehl>2) then
	  # avoid our extensions if not necc.
	  gut:=false;
	  zaehl:=zaehl+1;
        else
          kp[i]:=AlgebraicExtension(GF(p),mmf[i]);
	  al[i]:=RootOfDefiningPolynomial(kp[i]);
	  kp[i]!.myCoeffun:=ExtRepOfObj;
        fi;

	if gut<>false then
	  ff[i]:=AlgebraicPolynomialModP(ElementsFamily(FamilyObj(kp[i])),f,al[i],p);

	  gut:=DegreeOfLaurentPolynomial(Gcd(ff[i],Derivative(ff[i])))<1;
	  i:=i+1;
        fi;
      od;
      if gut then
	Info(InfoPoly,2,"trying prime ",p,": ",nm," factors of minpol, ",
	Length(Factors(PolynomialRing(kp[1]),ff[1]))," factors");
        # Wert ist Produkt der Cofaktorgrade des Polynoms (wir wollen
        # m"oglichst wenig gro"se Faktoren haben) sowie des
        # Kofaktorgrades des Minimalpolynoms (wir wollen bereits
        # akzeptabel approximieren) im Kubik (da es dominieren soll).
        w:=(degm/dm[1])^3*
	    Product(List(Factors(PolynomialRing(kp[1]),ff[1]),i->DegreeOfLaurentPolynomial(f)-DegreeOfLaurentPolynomial(i)));
        if w<bw then
          bw:=w;
          bp:=p;
	  bpr:=pr;
          bff:=ff;
          bkp:=kp;
          bal:=al;
          bmm:=mm;
        fi;
        zaehl:=zaehl+1;
      fi;
    fi;

  # teste 5 Primzahlen zu Anfang
  until zaehl=6;

  # beste Werte holen
  p:=bp;
  ff:=bff;
  kp:=bkp;
  kpcoeffun:=List(kp,i->i!.myCoeffun);
  al:=bal;
  mm:=bmm;
  mmf:=Factors(bpr,mm); #is stored in pol
  nm:=Length(mmf);
  dm:=List(mmf,DegreeOfLaurentPolynomial);

  # multiply denominator by defect to be sure, that \Z[\alpha] includes the
  # algebraic integers to obtain 'result' denominator

  d:=d*def;

  fff:=List([1..Length(ff)],i->Factors(PolynomialRing(bkp[i]),ff[i]));
  Info(InfoPoly,1,"using prime ",p,": ",nm," factors of minpol, ",
           List(fff,Length)," factors");

  # check possible Degrees

  degs:=Intersection(List(fff,i->List(Combinations(List(i,DegreeOfLaurentPolynomial)),Sum)));

  degs:=Difference(degs,[0]);
  degs:=Filtered(degs,i->2*i<=degf);
  IsRange(degs);
  Info(InfoPoly,1,"possible degrees: ",degs);

  # are we lucky? 
  if Length(degs)>0 then

    bounds:=HenselBound(f,m,d);
    numbound:=bounds[Maximum(degs)];

    Info(InfoPoly,1,"Bound for factor coefficients coefficients is:",numbound);

    # first suppose we get the lattice reduced to orthogonality defect 2

    yet:=0;
    ordef:=3;
    if IsBound(opt.ordef) then ordef:=opt.ordef;fi;

    #NOCH: verwende bessere beim zweiten mal bereits bekanntes
    # geliftes

    # compute bounds and select method

    lenstra:=1;
    weinberger:=2;
    methname:=["Lenstra","Weinberger"];
    method:=weinberger;
    pex:=LogInt(2*numbound-1,p)+1;
    actli:=[1..nm];

    if nm>1 then
      w:=CoefficientsOfUnivariatePolynomial(m);
      lbound:=
	# obere Absch"atzung f"ur ||F||^(m-1)
	(w*w)^(Maximum(degs)-1)

	*(2*numbound)^degf;
      w:=Int(lbound*ordef^degf)+1;
      if LogInt(w,10)<800 then
	method:=lenstra;
	pex:=LogInt(w-1,p)+1-dm[1];
	actli:=[1];
      fi;
    fi;

    Info(InfoPoly,1,"using method ",methname[method]);

    # prep U for mm Hensel

    U:=AlgFacUPrep(bpr,mm);
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));

    # prepare u for ff Hensel
    u:=List([1..Length(ff)],i->AlgFacUPrep(PolynomialRing(bkp[i]),ff[i]));

    # alles in Charakteristik 0 transportieren

    Info(InfoPoly,1,"transporting in characteristic zero");

    rfunfam:=RationalFunctionsFamily(FamilyObj(1));
    for i in [1..nm] do
      if IsPolynomial(mmf[i]) then
	cf:=CoefficientsOfUnivariateLaurentPolynomial(mmf[i]);
	mmf[i]:=LaurentPolynomialByExtRepNC(rfunfam,List(cf[1],Int),cf[2],inum);
      else
	mmf[i]:=Int(mmf[i]);
      fi;
      if IsPolynomial(U[i]) then
	cf:=CoefficientsOfUnivariateLaurentPolynomial(U[i]);
	U[i]:=LaurentPolynomialByExtRepNC(rfunfam, List(cf[1],Int),cf[2],inum);
      else
	U[i]:=Int(U[i]);
      fi;
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));
    od;

    # dabei repr"asentieren wir die Wurzel \alpha als alg. Erweiterung mit
    # dem entsprechenden Polynom als Minpol.

    ext:=[];
    for i in actli do
      if EuclideanDegree(mmf[i])>1 then
	ext[i]:=AlgebraicExtension(Rationals,mmf[i]);
      else
	ext[i]:=Rationals;
      fi;
      if DegreeOverPrimeField(ext[i])>1 then
	w:=RootOfDefiningPolynomial(ext[i]);
      else
	w:=One(ext[i]);
      fi;
      fam:=ElementsFamily(FamilyObj(ext[i]));
      fff[i]:=List(fff[i],j->ChaNuPol(j,al[i],w,kpcoeffun[i],fam,inum));
      u[i]:=List(u[i],j->ChaNuPol(j,al[i],w,kpcoeffun[i],fam,inum));
    od;

    repeat
      # jetzt hochHenseln
      q:=p^(2^yet);

      # how many square iterations needed for bound (the p-exponent)?

      max:=p^pex;

      M:=LogInt(pex-1,2)+1;
      pex:=2^M; # the new pex

      Info(InfoPoly,1,M," quadratic steps necessary");
      for i in [1..M-yet] do
        # now lift q->q^2 (or appropriate smaller number)
        # avoid modulus too large, since the computation afterwards becomes
        # harder
	if method=lenstra then
	  newq:=q^2; # we might need the better lift.
	else
	  newq:=Minimum(q^2,max);
        fi;

        Info(InfoPoly,1,"quadratic Hensel Lifting, step ",i,", ",q,"->",newq);

        if Length(mmf)>1 then
          # more than 1 factor: actual lift necessary

          if i>1 then
            # now lift the U's

            Info(InfoPoly,2,"correcting U-inverses");
            for j in [1..nm] do
              a:=ProductMod(mmf{Difference([1..nm],[j])},q) mod mmf[j] mod q;
              U[j]:=BPolyProd(U[j], (2-APolyProd(U[j],a,q)), mmf[j], q);
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));
              #a:=a*U[j] mod mmf[j] mod q;
              #if a<>a^0 then
                #Error("U-rez");
              #fi;
            od;

          fi;

          for j in [1..nm] do
            a:=(m mod mmf[j] mod newq);
            if IsPolynomial(a) and IsPolynomial(U[j]) then
              mmf[j]:=mmf[j]+BPolyProd(U[j],a,mmf[j],newq);
            else
              mmf[j]:=mmf[j]+(U[j]*a mod mmf[j] mod newq);
            fi;
          od;

          #a:=(m-ProductMod(mmf,newq)) mod newq;
          #InfoAlg2("#I  new F-discrepancy mod ",p,"^",2^i," is ",a,
                   #"(should be 0)\n");
          #if a<>0*a then
            #Error("uh-oh");
          #fi;

        else
          mmf:=[m mod newq];
        fi;

        # transport fff etc. into the new (lifted) extension fields

        ef:=[];
        for k in actli do
          ext[k]:=AlgebraicExtension(Rationals,mmf[k]);
          # also to provoke the binding of the Ring
          w:=Indeterminate(ext[k],"X");

          for j in [1..Length(fff[k])] do
            fff[k][j]:=TransferedExtensionPol(ext[k],fff[k][j],inum);
            u[k][j]:=TransferedExtensionPol(ext[k],u[k][j],inum);
          od;

          ef[k]:=TransferedExtensionPol(ext[k],f,mmf[k],inum);
        od;
        
        # lift u's
        if i>1 then

          Info(InfoPoly,2,"correcting u-inverses");
          for k in actli do
            for j in [1..Length(u[k])] do
              a:=ProductMod(fff[k]{Difference([1..Length(u[k])],[j])},q)
                         mod fff[k][j] mod q;
              u[k][j]:=BPolyProd(u[k][j],(2-APolyProd(a,u[k][j],q)),
                                 fff[k][j],q);
              #a:=a*u[k][j] mod fff[k][j] mod q;
              #if a<>a^0 then
              #  Error("u-rez");
              #fi;
            od;
          od;

        fi;

        for k in actli do
          for j in [1..Length(fff[k])] do
            a:=(ef[k] mod fff[k][j] mod newq);
            fff[k][j]:=fff[k][j]+BPolyProd(u[k][j],a,fff[k][j],newq) mod newq;
          od;

          #a:=(ef[k]-ProductMod(fff[k],newq)) mod newq;
          #InfoAlg2("#I new discrepancy mod ",p,"^",2^i," is ",a,
                   #"(should be 0)\n");
          #if a<>0*a then
            #Error("uh-oh");
          #fi;
        od;

        # now all is fine mod newq;
        q:=newq;
      od;
 
      yet:=M;
      bound:=q/2;

      if method=lenstra then
        # prepare Lattice for mmf[1]
        
        M:=[];
        for i in [0..dm[1]-1] do
          M[i+1]:=0*[1..degm];
          M[i+1][i+1]:=p^pex;
        od;
        for i in [dm[1]..degm-1] do
	  cf:=CoefficientsOfUnivariateLaurentPolynomial(mmf[1]);
          M[i+1]:=ShiftedCoeffs(cf[1],
                                cf[2]+i-dm[1]);
          while Length(M[i+1])<degm do
            Add(M[i+1],0);
          od;
        od;

        M:=LLLint(M);
        #M:=Concatenation(M.irreducibles,M.remainders);

        w:=OrthogonalityDefectEuclideanLattice(M);
	Info(InfoPoly,1,"Orthogonality defect: ",Int(w*1000)/1000);
	a:=LogInt(Int(lbound*w^degf),p)+1-dm[1];

	# check, whether we really did not lift good enough..
        if w>ordef and a>pex then
	  Info(InfoWarning,1,"'ordef' was set too small, iterating");
          ordef:=Maximum(w,ordef+1);
	  # call again
	  opt:=ShallowCopy(opt);
	  opt.ordef:=ordef;
	  return AlgExtSquareHensel(R,f,opt);
        else
          ordef:=Int(w)+1;
        fi;
      elif method=weinberger then
        w:=ordef-1; # to skip the loop
      fi;

    until w<=ordef;

    if method=lenstra then
      M:=TransposedMat(M);
      Mi:=M^(-1);

    elif method=weinberger then
      # Prepare for Chinese remainder
      if Length(mmf)>1 then
        U:=[];
        for i in [1..nm] do
          a:=ProductMod(mmf{Difference([1..nm],[i])},q);
          U[i]:=a*(GcdRepresentation(mmf[i],a)[2] mod q) mod q;
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));
        od;
      else
        U:=[Indeterminate(Rationals,inum)^0];
      fi;
      # sort according to the number of factors:
      # Our 'starting' factorisation is the one with the fewest factors,
      # because this one allows the fewest number of combinations.

      ind:=[1..nm];
      Sort(ind,function(a,b)
                 return Length(fff[a])<Length(fff[b]);
               end);
      perm:=PermList(ind);
      Permuted(mmf,perm);
      Permuted(fff,perm);

      # We will start with small degrees, in a hope that there are some
      # factors of small degrees. These small degree factors are better suited
      # for trying, because we will have fewer combinations of the other
      # factorisations to try, to obtain the according one.
      # Thus sort first factorisation according to degree

      Sort(fff[1],function(a,b)
                    return
		    DegreeOfLaurentPolynomial(a)<DegreeOfLaurentPolynomial(b);
                  end);

      # For the corresponding factors, we take on the other hand large
      # degree factors first. The hard case is the one with relative large
      # factors. If in one component, the relative large factor remains
      # irreducible, we will be thus ready a bit sooner (hopefully).

      for i in [2..nm] do
        Sort(fff[i],function(a,b)
                      return
		      DegreeOfLaurentPolynomial(a)>DegreeOfLaurentPolynomial(b);
                    end);
      od;

    fi;

    al:=RootOfDefiningPolynomial(K);
    alfam:=ElementsFamily(FamilyObj(K));

    # now the hard part starts: We try all possible combinations, whether
    # they factor.

    dl:=[];
    sel:=[];
    for k in actli do
      # 'available' factors (not yet used up)
      sel[k]:=[1..Length(fff[k])];
      dl[k]:=List(fff[k],DegreeOfLaurentPolynomial);
      Info(InfoPoly,1,"Degrees[",k,"] :",dl[k]);
    od;

    act:=1;
    len:=0;

    dm:=[];
    for i in actli do
      dm[i]:=List(fff[i],DegreeOfLaurentPolynomial);
    od;

    repeat
      # factors of larger than half remaining degree we will find as
      # final cofactor
      degf:=DegreeOfLaurentPolynomial(f);
      degs:=Filtered(degs,i->2*i<=degf);

      if Length(degs)>0 and act in sel[1] then
        # all combinations of sel[1] of length len+1, that contain act:

        degsm:=degs-dm[1][act];
        comb:=Filtered(Combinations(Filtered(sel[1],i->i>act),len),
              i->Sum(dm[1]{i}) in degsm);

        # sort according to degree
        Sort(comb,function(a,b) return Sum(dm[1]{a})<Sum(dm[1]{b});end);

        comb:=List(comb,i->Union([act],i));

        gut:=true;

        i:=1;
        while gut and i<=Length(comb) do
	  Info(InfoPoly,2,"trying ",comb[i]);

          if method=lenstra then
            a:=d*ProductMod(fff[1]{comb[i]},q) mod q;
            a:=CoefficientsOfUnivariatePolynomial(a);
            v:=[];
            for j in a do
              if IsAlgebraicElement(j) then
		w:=ShallowCopy(ExtRepOfObj(j));
              else
                w:=[j];
              fi;
              while Length(w)<degm do
                Add(w,0);
              od;
              Add(v,w); 
            od;
            w:=List(v,i->Mi*i);
            w:=List(w,i->List(i,j->SignInt(j)*Int(AbsInt(j)+1/2)));
            w:=List(w,i->M*i);
            v:=(v-w)/d;
            a:=UnivariatePolynomialByCoefficients(alfam,
		List(v,i->AlgExtElm(alfam,i)),inum);

            #Print(a,"\n");
            w:=TrialQuotientRPF(f,a,bounds);
            if w<>fail then
              Info(InfoPoly,1,"factor found");
              f:=w;
              Add(fact,a);
              sel[1]:=Difference(sel[1],comb[i]);
              #fff[1]:=fff[1]{Difference([1..Length(fff[1])],comb[i])};
              gut:=false;
            fi;

          elif method=weinberger then
            # now select all other combinations of same degree
            dd:=Sum(dl[1]{comb[i]});
            #NOCH: Combinations nach Grad ordnen. Nur neue listen
            #bestimmen, wenn der Grad sich ge"andert hat.
            cbn:=[comb{[i]}];
            for j in [2..nm] do
              # all combs in component nm of desired degree
              cbn[j]:=Concatenation(List([1..QuoInt(dd,Minimum(dl[j]))],
                      i->Filtered(Combinations(sel[j],i),
                                  i->Sum(dl[j]{i})=dd)));
            od;
            if ForAny(cbn,i->Length(i)=0) then
              gut:=false;
            else
              l:=List([1..nm],i->1); # the great variable for-Loop 
              #ff:=List([1..nm],i->ProductMod(fff[i]{cbn[i][1]},q).coefficients);
	      ff:=List([1..nm],i->CoefficientsOfUnivariatePolynomial(ProductMod(fff[i]{cbn[i][1]},q)));
            fi;

            ps:=nm;
            while gut and ps>=1 do
              a:=[];
              for j in [1..dd+1] do
                w:=0;
                for k in [1..nm] do
                  z:=ff[k][j];
                  if IsAlgebraicElement(z) then
                    z:=UnivariatePolynomial(Rationals,
			 ExtRepOfObj(z),inum);
                  fi;
                  w:=w+U[k]*z mod m mod q;
                od;
                w:=d*w mod m mod q;
		wc:=ShallowCopy(CoefficientsOfUnivariatePolynomial(w));
                for k in [1..Length(wc)] do
                  if wc[k]>q/2 then
                    wc[k]:=wc[k]-q;
                  fi;
                od;
		w:=UnivariateLaurentPolynomialByCoefficients(
                     CoefficientsFamily(FamilyObj(w)),
		     wc,0,IndeterminateNumberOfUnivariateLaurentPolynomial(w));
                a[j]:=1/d*Value(w,al);
              od;

              # now try the Factor
              a:=UnivariateLaurentPolynomialByCoefficients(alfam,a,0,inum);

              Info(InfoPoly,3,"trying subcombination ",
	        List([2..nm],i->cbn[i][l[i]]));
              w:=TrialQuotientRPF(f,a,bounds);
              if w<>fail then
                Info(InfoPoly,1,"factor found");
                Add(fact,a);
                for j in [1..nm] do
                  sel[j]:=Difference(sel[j],cbn[j][l[j]]);
                od;
                f:=w;
                gut:=false;
              fi;

              # increase and update factors
              while ps>1 and l[ps]=Length(cbn[ps]) do
                l[ps]:=1;
                a:=ProductMod(fff[ps]{cbn[ps][1]},q);
                ff[ps]:=CoefficientsOfUnivariateLaurentPolynomial(a)[1];
                ps:=ps-1;
              od;
              if ps>1 then
                l[ps]:=l[ps]+1;
                a:=ProductMod(fff[ps]{cbn[ps][l[ps]]},q);
                ff[ps]:=CoefficientsOfUnivariateLaurentPolynomial(a)[1];
              fi;

              if ps>1 then
                ps:=nm;
              else
                ps:=0;
              fi;

            od;
          fi;

          i:=i+1;
        od;

        if comb=[] then
          i:=0;
        else
          # the len minimal lengths
          i:=ShallowCopy(dm[1]);
          Sort(i);
          i:=Sum(i{[1..Minimum(Length(i),len)]});
        fi;

        if gut and dm[1][act]+i>=Maximum(degs) then
          # the actual factor will always yield factors too large, thus we
          # can avoid it furthermore
	  Info(InfoPoly,2,"factor ",act," can be further neglected");
          sel[1]:=Difference(sel[1],[act]);
          gut:=false;
        fi;

      fi;

      act:=act+1;
      if sel[1]<>[] and act>Maximum(sel[1]) then
       len:=len+1;
       act:=sel[1][1];
      fi;
      
    until ForAny(sel,i->Length(i)=0)
          or Length(sel[1])<len; #nothing left to check

  fi;

  # aufr"aumen

  if f<>f^0 then
    Add(fact,f);
  fi;

  return fact;
end);

InstallMethod( FactorsSquarefree, "polynomial/alg. ext.",IsCollsElmsX,
    [ IsAlgebraicExtensionPolynomialRing, IsUnivariatePolynomial, IsRecord ],
function(r,pol,opt)

  # the second algorithm seem to have problems -- temp. disable
  if true or
 ( 
  (Characteristic(r)=0 and DegreeOverPrimeField(CoefficientsRing(r))<=4
    and DegreeOfLaurentPolynomial(pol)
          *DegreeOverPrimeField(CoefficientsRing(r))<=20) 
     or Characteristic(r)>0)
     
     then
     return AlgExtFactSQFree(r,pol,opt);
  else
    return AlgExtSquareHensel(r,pol,opt);
  fi;
end);
