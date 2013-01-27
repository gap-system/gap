#############################################################################
##
#W  fitfree.gd                  GAP library                  Alexander Hulpke
##
##
#Y  Copyright (C) 2012 The GAP Group
##
##  This file contains functions using the trivial-fitting paradigm.
##

BindGlobal("SylowViaRadical",function(G,prime)
local ser,hom,s,fphom,sf,sg,sp,fp,d,head,mran,nran,mpcgs,ocr,len,pcgs,gens;
  ser:=FittingFreeLiftSetup(G);
  pcgs:=ser.pcgs;
  len:=Length(pcgs);
  hom:=ser.factorhom;
  s:=SylowSubgroup(Image(hom),prime);
  fphom:=IsomorphismFpGroup(s);
  fp:=Image(fphom);
  sf:=List(GeneratorsOfGroup(Image(fphom)),x->PreImagesRepresentative(fphom,x));
  sg:=List(sf,x->PreImagesRepresentative(hom,x));
  sp:=[];
  RUN_IN_GGMBI:=true; # hack to skip Nice treatment
  fphom:=GroupGeneralMappingByImagesNC(Group(sg,One(G)),fp,sg,
    GeneratorsOfGroup(fp));
  RUN_IN_GGMBI:=false;



  for d in [2..Length(ser.depths)] do
    mran:=[ser.depths[d-1]..len];
    nran:=[ser.depths[d]..len];
    head:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran});

    mpcgs:=head mod
           InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});
    if RelativeOrders(mpcgs)[1]=prime then
      if d=Length(ser.depths) then
        # last step, no presentation needed
	Append(sp,mpcgs);
      else
	# extend presentation
	RUN_IN_GGMBI:=true; # hack to skip Nice treatment
        fphom:=LiftFactorFpHom(fphom,Source(fphom),false,false,mpcgs);
	RUN_IN_GGMBI:=false;
	fp:=Image(fphom);
	sp:=Concatenation(sp,mpcgs);
      fi;
    else

      ocr:=rec(group:=Group(Concatenation(head,sg,sp)),modulePcgs:=mpcgs);
      ocr.factorfphom:=fphom;
      OCOneCocycles(ocr,true);
      gens:=GeneratorsOfGroup(ocr.complement);
      sg:=gens{[1..Length(sg)]};
      sp:=gens{[Length(sg)+1..Length(gens)]};
      RUN_IN_GGMBI:=true; # hack to skip Nice treatment
      fphom:=GroupGeneralMappingByImagesNC(ocr.complement,fp,gens,
	GeneratorsOfGroup(fp));
      RUN_IN_GGMBI:=false;
      
    fi;
  od;
  return SubgroupByFittingFreeData(G,sg,sf,InducedPcgsByPcSequenceNC(pcgs,sp));
end);

InstallMethod(DirectFactorsFittingFreeSocle,"generic",true,
  [IsGroup and IsFinite],0,
function(G)
local s,o,a,n,d,f,fn,j,b,i;
  s:=Socle(G);

  #try to split first according to orbits
  if IsPermGroup(G) then
    o:=Orbits(s,MovedPoints(s));
    f:=[s]; #prefactors
    for i in o do
      fn:=[];
      for j in f do
	a:=Stabilizer(j,i,OnTuples);
	if Size(a)=Size(j) or Size(a)=1 then
	  Add(fn,j);
	else
	  b:=Centralizer(j,a);
	  Add(fn,a);
	  Add(fn,b);
	fi;
      od;
      f:=fn;
    od;
  else
    f:=[s];
  fi;

  d:=[];
  for i in f do
    if IsSimpleGroup(i) then
      Add(d,i);
    else
      n:=Filtered(NormalSubgroups(i),x->Size(x)>1);
      # if G is not fitting-free it has a proper normal subgroup of
      #  prime-power order
      if ForAny(n,x->Length(Set(Factors(Size(x))))=1) then
	return fail;
      fi;
      n:=Filtered(n,IsSimpleGroup);
      Append(d,n);
    fi;
  od;
  return d;
end);

BindGlobal("ClosureGroupQuick",function(G,U,V)
local o,C;
  C:=SubgroupNC(G,Concatenation(GeneratorsOfGroup(U),GeneratorsOfGroup(V)));
  o:=List([1..100],x->Order(PseudoRandom(C)));
  Add(o,Size(U));
  Add(o,Size(V));
  if IsPermGroup(G) then
    Append(o,List(Orbits(C,MovedPoints(G)),Length));
  fi;
  o:=Lcm(o);
  if Set(Factors(Size(G)))=Set(Factors(o)) then
    # all primes in -- useless
    return G;
  fi;
  return C;
end);

# the ``all-halls'' function by brute force Sylow-combination search
BindGlobal("Halleen",function(arg)
local G,gp,p,r,s,c,i,a,pp,prime,sy,k,b,dc,H,e,j,forbid;
  G:=arg[1];
  gp:=Set(Factors(Size(G)));
  if Length(arg)>1 then
    r:=arg[2];
    forbid:=Difference(gp,r);
    p:=Intersection(gp,r);
  else
    forbid:=[];
    p:=gp;
  fi;
  r:=List(p,x->[[x],[SylowSubgroup(G,x)]]); # real halls
  s:=ShallowCopy(r); # real and potential halls to extend
  c:=Combinations(p);
  c:=Filtered(c,x->Length(x)>1 and Length(x)<Length(gp));
  Sort(c,function(a,b) return Length(a)<Length(b);end);
  for i in c do
    a:=[];
    pp:=Product(i);
    # now build all new groups by extending the groups that were obtained
    # for one prime less. We exclude the smallest prime, as it tends to have
    # the largest sylow
    prime:=i[1];
    sy:=SylowSubgroup(G,prime);
    k:=i{[2..Length(i)]};
    # b are the groups constructed using the other primes
    b:=First(s,x->x[1]=k);
    if b=fail then b:=[];
	      else b:=b[2]; fi;

    # those that already contain the prime Sylow just go on
    e:=Filtered(b,x->1=Gcd(Index(G,x),prime));

    # are any of these actually proper hall?
    for H in e do
      if IsSubset(i,Factors(Size(H))) then
	Add(a,H);
      fi;
    od;

    # the rest should be extended
    b:=Filtered(b,x->1<Gcd(Index(G,x),prime));

    Info(InfoLattice,1,"Try ",i," from ",k," ",Length(e)," ",Length(b));

    for j in b do
      dc:=DoubleCosetRepsAndSizes(G,Normalizer(G,sy),Normalizer(G,j));
      #Print(Length(dc)," double cosets\n");
      for k in dc do
        #H:=ClosureGroup(j,sy^k[1]);
        H:=ClosureGroupQuick(G,j,sy^k[1]);
	# discard whole group and those that have all primes
	if Index(G,H)>1 and not ForAll(gp,x->IsInt(Size(H)/x)) 
	  and not ForAny(forbid,x->IsInt(Size(H)/x)) then
	  if ForAll(e,x->H<>x) and
	     ForAll(e,x->RepresentativeAction(G,H,x)=fail) then
	    Add(e,H);
	    if IsSubset(i,Factors(Size(H))) then
	      if Length(Intersection(Factors(Index(G,H)),i))=0 then
		Info(InfoLattice,2,"Found Hall",i," ",Size(H));
	      else
		Info(InfoLattice,2,"Found ",i," ",Size(H));
	      fi;
	      Add(a,H);
	    else
	      Info(InfoLattice,2,"Too large ",i," ",Size(H));
	    fi;
	  fi;
	fi;
      od;
    od;

    Add(s,[i,e]);
    if Length(a)>0 then
      Add(r,[i,a]);
    fi;

  od;
  return r;
end);

BindGlobal("HallsFittingFree",function(G,pi)
local s,d,c,act,o,i,j,h,p,hf,img,n,prd,k,nk,map,ns,all,hl,hcomp,
  reps,orb,m,mk,shall,marks,t,thom,b,ntb,hom,dser,pcgs,
  fphom,fp,gens,imgs,ocr,elabser,cgens,a,kim,r,z;

  # get elementary abelian series from -> to
  elabser:=function(from,to)
  local ser,a,p;
    ser:=[from];
    while Size(from)>Size(to) do
      a:=from;
      from:=DerivedSubgroup(a);
      if Size(from)=Size(a) then
	# nonsolvable case
	return ser;
      fi;
      p:=Factors(Index(a,from))[1];
      from:=ClosureGroup(from,List(GeneratorsOfGroup(a),x->x^p));
      Assert(1,HasElementaryAbelianFactorGroup(a,from) and Index(a,from)>1);
      Add(ser,from);
    od;
    return ser;
  end;

  # needs to go higher
  pi:=Set(pi);
  prd:=Product(pi);
  if ForAny(pi,x->not IsPrimeInt(x)) then
    Error("pi must be a set of primes");
  fi;
  pi:=Filtered(pi,x->IsInt(Size(G)/x));
  if Length(pi)=0 then
    return [TrivialSubgroup(G)];
  elif false and Length(pi)=1 then
    return [SylowSubgroup(G,pi[1])];
  elif pi=Set(Factors(Size(G))) then
    return [G];
  fi;

  s:=Socle(G);
  d:=DirectFactorsFittingFreeSocle(G);
  c:=[]; # conjugation info
  act:=ActionHomomorphism(G,d);
  t:=KernelOfMultiplicativeGeneralMapping(act);
  img:=Image(act);

  # compute Hall in factor
  hf:=HallViaRadical(img,pi);
  Info(InfoLattice,1,"Permact factor:",Length(hf)," hall subgroups");

  if Length(hf)=0 then
    # nothing in the factor
    return [];
  fi;

  # compute b such that b/s is hall in t/s
  thom:=NaturalHomomorphismByNormalSubgroupNC(t,s);
  b:=HallSubgroup(Image(thom),pi);
  b:=PreImage(thom,b);
  ntb:=Normalizer(t,b); # likely equal to t or of small index, thus harmless

  # also compute halls for socle
  o:=Orbits(Image(act),[1..Length(d)]);
  hl:=[];
  for i in o do
    p:=Intersection(Factors(Size(d[i[1]])),pi);
    if Length(p)=0 then 
      h:=[,[TrivialSubgroup(d[i[1]])]];
    else
      h:=Halleen(d[i[1]],p);
      h:=First(h,x->x[1]=p);
    fi;
    # TODO: Reduce via B-action
    if h=fail then
      return [];
    fi;
    h:=h[2];
    Info(InfoLattice,2,"Socle factor size ",Size(d[i[1]]),": ",Length(h),
      " Hall subgroups");
    for j in i do
      hl[j]:=Length(h);
    od;
    n:=List(h,x->Normalizer(d[i[1]],x));
    c[i[1]]:=rec(orbit:=i,orbitpos:=1,rep:=One(G),component:=d[i[1]],hall:=h,
      norm:=n);
    for j in [2..Length(i)] do
      c[i[j]]:=rec(orbit:=i,orbitpos:=j,
	rep:=PreImagesRepresentative(act,
	  RepresentativeAction(Image(act),i[1],i[j])),
	component:=d[i[j]],hall:=h, norm:=n);
    od;
  od;

  # now form all halls in s
  shall:=[];
  for p in Cartesian(List(hl,x->[1..x])) do
    h:=TrivialSubgroup(G);
    hcomp:=[];
    ns:=TrivialSubgroup(G);
    for i in [1..Length(d)] do
      hcomp[i]:=c[i].hall[p[i]]^c[i].rep;
      h:=ClosureGroup(h,hcomp[i]);
      ns:=ClosureGroup(ns,c[i].norm[p[i]]^c[i].rep);
    od;
    Add(shall,rec(hall:=h,hcomp:=hcomp,ns:=ns));
  od;
  if Length(shall)=0 then
    return [];
  fi;
  Info(InfoLattice,1,Length(shall)," in socle");

  # get elementary abelian series from ntb to b
  dser:=elabser(ntb,b);
  pcgs:=List([2..Length(dser)],x->ModuloPcgs(dser[x-1],dser[x]));

  all:=[];
  # run through halls in factor (and correct)
  for i in hf do
    if Size(i)>1 then

      # replace hf's by complements
      fphom:=IsomorphismFpGroup(i);
      fp:=Range(fphom);
      gens:=MappingGeneratorsImages(fphom);
      imgs:=gens[2];gens:=gens[1];
      gens:=List(gens,x->PreImagesRepresentative(act,x));

      # adapt to normalize B
      gens:=List(gens,x->x/RepresentativeAction(t,b^x,b));

      # now do complements one by one
      for j in [1..Length(pcgs)] do
	h:=ClosureGroup(dser[j],gens);
	RUN_IN_GGMBI:=true; # hack to skip Nice treatment
	fphom:=GroupGeneralMappingByImagesNC(h,fp,
		Concatenation(GeneratorsOfGroup(dser[j]),gens),
		Concatenation(List(GeneratorsOfGroup(dser[j]),x->One(fp)),imgs));
	RUN_IN_GGMBI:=false;

	ocr:=rec(group:=h,modulePcgs:=pcgs[j],
		factorfphom:=fphom);
	OCOneCocycles(ocr,true);
	gens:=GeneratorsOfGroup(ocr.complement);
      od;

      # lift presentation with b/s, if necessary
      if Size(b)>Size(s) then

	h:=ClosureGroup(b,gens);
	RUN_IN_GGMBI:=true; # hack to skip Nice treatment
	fphom:=GroupGeneralMappingByImagesNC(h,fp,
		Concatenation(GeneratorsOfGroup(b),gens),
		Concatenation(List(GeneratorsOfGroup(b),x->One(fp)),imgs));
	RUN_IN_GGMBI:=false;
	# get elementary abelian series from b to s
	dser:=elabser(b,s);
	pcgs:=List([2..Length(dser)],x->ModuloPcgs(dser[x-1],dser[x]));
	for j in pcgs do
	  RUN_IN_GGMBI:=true; # hack to skip Nice treatment
	  fphom:=LiftFactorFpHom(fphom,Source(fphom),false,false,j);
	  RUN_IN_GGMBI:=false;
	od;
	gens:=MappingGeneratorsImages(fphom);
	imgs:=gens[2];gens:=gens[1];
	fp:=Image(fphom);
      fi;
    else
      # trivial in factor -- continue with b
      hom:=NaturalHomomorphismByNormalSubgroupNC(b,s);
      fphom:=IsomorphismFpGroup(Image(hom));
      fp:=Image(fphom);
      gens:=MappingGeneratorsImages(fphom);
      imgs:=gens[2];gens:=gens[1];
      gens:=List(gens,x->PreImagesRepresentative(hom,x));
    fi;

    # now run through the candidates for Hall in S
    for j in shall do

      k:=j.hall;
      # normalize k -- correct gens
      cgens:=[];
      h:=1;
      while cgens<>fail and h<=Length(gens) do
	a:=gens[h];
	kim:=List(j.hcomp,x->x^a);
	# reindex
	kim:=kim{ListPerm(Image(act,a)^-1,Length(d))};
	z:=1;
	while a<>fail and z<=Length(d) do
	  r:=RepresentativeAction(d[z],kim[z],j.hcomp[z]);
	  if r<>fail then
	    a:=a*r;
	  else
	    a:=fail;
	  fi;
	  z:=z+1;
	od;
	if a<>fail then
	  Add(cgens,a);
	else
	  cgens:=fail;
	fi;
	h:=h+1;
      od;

      if cgens=[] then
	# degenerate case -- nothing in the factor, just use hall in s
	Add(all,j.hall);
      elif cgens<>fail then
	# The s-class of k is fixed and cgens are generators for N_C(K),
	# corresponding to gens (and imgs).
	dser:=elabser(j.ns,j.hall);
	pcgs:=List([2..Length(dser)],x->ModuloPcgs(dser[x-1],dser[x]));

	# now do complement to NS(k)/k
	for z in [1..Length(pcgs)] do
	  h:=ClosureGroup(dser[z],cgens);
	  RUN_IN_GGMBI:=true; # hack to skip Nice treatment
	  fphom:=GroupGeneralMappingByImagesNC(h,fp,
		  Concatenation(GeneratorsOfGroup(dser[z]),cgens),
		  Concatenation(List(GeneratorsOfGroup(dser[z]),x->One(fp)),
		    imgs));
	  RUN_IN_GGMBI:=false;

	  ocr:=rec(group:=h,modulePcgs:=pcgs[z],
		  factorfphom:=fphom);
	  OCOneCocycles(ocr,true);
	  cgens:=GeneratorsOfGroup(ocr.complement);
	od;

	if Size(dser[Length(dser)])>Size(j.hall) then
	  gens:=[];
	  for z in cgens do
	    b:=Order(z);
	    a:=Product(Filtered(Factors(b),x->x in pi));
	    c:=GcdRepresentation(a,b/a);
	    Add(gens,z^((b/a)*c[2]));
	  od;
	  h:=Group(gens);
	  Info(InfoLattice,2,"Coprimize to ",Size(h));
	  n:=NormalIntersection(j.ns,h);
	  if Size(n)>1 then
	    k:=NormalIntersection(k,h);
	    if Size(k)>1 then
	      Error("nonsolvable case with nontrivial k still to do");
	    fi;

	    # now work in sylow normalizer -- correct gens to normalize
	    a:=SylowSubgroup(n,2);
	    cgens:=[];
	    for z in gens do
	      Add(cgens,z->z*RepresentativeAction(n,a^z,a));
	    od;
	    h:=Group(cgens);
	    a:=ComplementClassesRepresentatives(h,NormalIntersection(n,h));
	    cgens:=GeneratorsOfGroup(h[1]);
	  else
	    cgens:=gens;
	    k:=TrivialSubgroup(G);
	  fi;


	fi;
	Add(all,ClosureGroup(k,cgens));

      else
	Info(InfoLattice,3,"does not work");
      fi;


    od;


  od;

  return all;

end);

InstallGlobalFunction(HallViaRadical,function(G,pi)
local ser,hom,s,fphom,sf,sg,sp,fp,d,head,mran,nran,mpcgs,ocr,len,pcgs,
      gens,all,indu;
  if ForAny(pi,x->not IsPrimeInt(x)) then
    Error("pi must be a set of primes");
  fi;
  ser:=FittingFreeLiftSetup(G);
  pcgs:=ser.pcgs;
  len:=Length(pcgs);
  hom:=ser.factorhom;
  if Intersection(pi,Factors(Size(Image(hom))))=[] then
    s:=HallSubgroup(Image(ser.pcisom),pi);
    sp:=List(Pcgs(s),x->PreImage(ser.pcisom,x));
    return [
      SubgroupByFittingFreeData(G,[],[],InducedPcgsByPcSequenceNC(pcgs,sp))];
  fi;

  all:=[];
  for s in HallsFittingFree(Image(hom),pi) do
    fphom:=IsomorphismFpGroup(s);
    fp:=Image(fphom);
    sf:=List(GeneratorsOfGroup(Image(fphom)),x->PreImagesRepresentative(fphom,x));
    sg:=List(sf,x->PreImagesRepresentative(hom,x));
    sp:=[];
    RUN_IN_GGMBI:=true; # hack to skip Nice treatment
    fphom:=GroupGeneralMappingByImagesNC(Group(sg,One(G)),fp,sg,
      GeneratorsOfGroup(fp));
    RUN_IN_GGMBI:=false;

    for d in [2..Length(ser.depths)] do
      mran:=[ser.depths[d-1]..len];
      nran:=[ser.depths[d]..len];
      head:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran});

      mpcgs:=head mod
	    InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});
      if RelativeOrders(mpcgs)[1] in pi then
	if d=Length(ser.depths) then
	  # last step, no presentation needed
	  Append(sp,mpcgs);
	else
	  # extend presentation
	  RUN_IN_GGMBI:=true; # hack to skip Nice treatment
	  fphom:=LiftFactorFpHom(fphom,Source(fphom),false,false,mpcgs);
	  RUN_IN_GGMBI:=false;
	  fp:=Image(fphom);
	  sp:=Concatenation(sp,mpcgs);
	fi;
      else

	ocr:=rec(group:=Group(Concatenation(head,sg,sp)),modulePcgs:=mpcgs);
	ocr.factorfphom:=fphom;
	OCOneCocycles(ocr,true);
	gens:=GeneratorsOfGroup(ocr.complement);
	sg:=gens{[1..Length(sg)]};
	sp:=gens{[Length(sg)+1..Length(gens)]};
	RUN_IN_GGMBI:=true; # hack to skip Nice treatment
	fphom:=GroupGeneralMappingByImagesNC(ocr.complement,fp,gens,
	  GeneratorsOfGroup(fp));
	RUN_IN_GGMBI:=false;
	
      fi;
    od;
    if Length(pcgs)>0 then
      indu:=InducedPcgsByPcSequenceNC(pcgs,sp);
    else
      indu:=[];
    fi;
    Add(all,
      SubgroupByFittingFreeData(G,sg,sf,indu));
  od;
  return all;
end);


#############################################################################
##
#M  HallSubgroupOp( <G>, <pi> )
##
## Fitting free approach
##
InstallMethod( HallSubgroupOp, "fitting free",true,
    [ IsGroup and CanComputeFittingFree,IsList ],0,
function(G,pi)
local l;
  if CanEasilyComputePcgs(G) then
    TryNextMethod(); # pcgs method is clearly better
  fi;
  l:=HallViaRadical(G,pi);
  if Length(l)=1 then
    return l[1];
  elif Length(l)=0 then
    return fail;
  else
    return l;
  fi;
end);

