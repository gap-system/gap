#############################################################################
##
#W  autsr.gi                GAP library                      Alexander Hulpke
#W                                                           Soley Jonsdottir
##
##
#Y  Copyright (C) 2016 The GAP Group
##
##  This  file  contains an implementation of the Cannon/Holt automorphism
##  group algorithm.

BindGlobal("AGSRPrepareAutomLift",function(G,pcgs,nat)
local ocr, fphom, fpg, free, len, dim, tmp, L0, S, R, rels, mat, r, RS, i, g, v;

  ocr:=rec(group:=G,modulePcgs:=pcgs);
  fphom:=IsomorphismFpGroup(G);
  ocr.identity := One(ocr.modulePcgs[1]);
  fpg:=FreeGeneratorsOfFpGroup(Range(fphom));
  ocr.factorpres:=[fpg,RelatorsOfFpGroup(Range(fphom))];
  ocr.generators:=List(GeneratorsOfGroup(Range(fphom)),
			i->PreImagesRepresentative(fphom,i));
  OCAddMatrices(ocr,ocr.generators);
  OCAddRelations(ocr,ocr.generators);
  OCAddSumMatrices(ocr,ocr.generators);
  OCAddToFunctions(ocr);

  ocr.module:=GModuleByMats(
    LinearActionLayer(G,ocr.generators,ocr.modulePcgs),ocr.field);
  ocr.moduleauts:=MTX.ModuleAutomorphisms(ocr.module);

  ocr.factorgens:=List(ocr.generators,i->Image(nat,i));
  free:=FreeGroup(Length(ocr.generators),"f");
  ocr.free:=free;
  ocr.decomp:=GroupGeneralMappingByImages(Image(nat,G),free,
	ocr.factorgens,GeneratorsOfGroup(free));

  # Initialize system.
  len:=Length(ocr.generators);
  dim:=Length(pcgs);
  tmp := ocr.moduleMap( ocr.identity );
  L0  := Concatenation( List( [ 1 .. len ], x -> tmp ) );
  ConvertToVectorRep(L0,ocr.field);
  S := List( [ 1 .. len * dim ], x -> L0 );
  R := ListWithIdenticalEntries( len * dim,Zero( ocr.field ) );
  ConvertToVectorRep(R,ocr.field);

  rels:=ocr.relators;
  mat:=List([1..len*dim],x->[]);
  for i in mat do
    ConvertToVectorRep(i,ocr.field);
  od;
  for i in [1..Length(rels)] do
    Info(InfoCoh,2,"  relation ", i, " (",Length(rels),")");
    r:=1;
    for g  in [1..len]  do
      RS:=OCEquationMatrix(ocr,rels[i],g);
      for v in RS do
	Append(mat[r],v);
	r:=r+1;
      od;
    od;
  od;
  ocr.matrix:=mat;
  return ocr;
end);

#############################################################################
##
#F  OCEquationVectorAutom(<ocr>,<r>,<genimages>)
##
BindGlobal("OCEquationVectorAutom",function(ocr,r,genimages)
local n,i;

  # If <r> has   an entry 'conjugated'   the records is  no relator  for  a
  # presentation,but belongs to relation
  #       (g_i n_i) ^ s_j =<r>
  # which is  used to determinate  normal  complements.   [i,j] is bound to
  # <conjugated>.
  if IsBound(r.conjugated)  then
    Error("not yet implemented");
  fi;
  n:=ocr.identity;

  for i in [1 .. Length(r.generators)] do
    n:=n*genimages[r.generators[i]]^r.powers[i];
  od;

  Assert(1,n in GroupByGenerators(NumeratorOfModuloPcgs(ocr.modulePcgs)));

  return ShallowCopy(ocr.moduleMap(n));

end);

BindGlobal("AGSRAutomLift",function(ocr,nat,fhom,miso)
  local v, rels, genimages, v1, psim, w, s, t, l, hom, i, e, j,ep,phom;

  v:=[];
  rels:=ocr.relators;
  genimages:=List(ocr.factorgens,i->MappedWord(
	        ImagesRepresentative(ocr.decomp,Image(fhom,i)),
		GeneratorsOfGroup(ocr.free),
		ocr.generators));
  for i in [1..Length(rels)] do
    v1:=OCEquationVectorAutom(ocr,rels[i],genimages);
    Add(v,v1);
  od;

  #for ep in Enumerator(ocr.moduleauts) do
  phom:=IsomorphismPermGroup(ocr.moduleauts);
  for ep in Enumerator(Image(phom)) do
    e:=PreImagesRepresentative(phom,ep);
    psim:=e*miso;
	psim:=psim^-1;
    w:=-List(v,i->i*psim);
    s:=SolutionMat(ocr.matrix,Concatenation(w));
    if s<>fail then
      psim:=psim^-1;
      t:=[];
      ConvertToVectorRep(t,ocr.field);
      l:=Length(ocr.modulePcgs);
      for i in [1..Length(genimages)] do
        v1:=s{[(i-1)*l+1..(i*l)]}*psim;
	for j in [1..Length(v1)] do
	  t[(i-1)*l+j]:=v1[j];
	od;
      od;
      s:=ocr.cocycleToList(t);
      for i in [1..Length(genimages)] do
	genimages[i]:=genimages[i]*s[i];
      od;
      # later use NC version
      hom:=GroupHomomorphismByImagesNC(ocr.group,ocr.group,
	      ocr.generators,genimages);
      Assert(2,IsBijective(hom));
      return hom;
    fi;
  od;
  return fail;

end);

# main automorphism method -- currently still using factor groups, but
# nevertheless faster..

# option somechar may be a list of characterstic subgroups, or a record with
# component subgroups, orbits
BindGlobal("AutomGrpSR",function(G)
local ff,r,d,ser,u,v,i,j,k,p,bd,e,gens,lhom,M,N,hom,Q,Mim,q,ocr,split,MPcgs,
      b,fratsim,AQ,OQ,Zm,D,innC,bas,oneC,imgs,C,maut,innB,tmpAut,imM,a,A,B,
      cond,sub,AQI,AQP,AQiso,rf,res,resperm,proj,Aperm,Apa,precond,ac,
      comiso,extra,mo,rada,makeaqiso,ind,lastperm,actbase,somechar,stablim,
      scharorb,asAutom,jorb,jorpo,substb,isBadPermrep,ma;

  # criterion for when to force degree reduction
  isBadPermrep:=function(g)
    return NrMovedPoints(g)^2>Size(g)*Index(g,DerivedSubgroup(g));
  end;

  asAutom:=function(sub,hom) return Image(hom,sub);end;

  actbase:=ValueOption("autactbase");

  makeaqiso:=function()
  local a,b;
    if HasIsomorphismPermGroup(AQ) then
      AQiso:=IsomorphismPermGroup(AQ);
    elif HasNiceMonomorphism(AQ) and IsPermGroup(Range(NiceMonomorphism(AQ))) then
      AQiso:=NiceMonomorphism(AQ:autactbase:=fail);
    elif actbase<>fail then
      AQiso:=IsomorphismPermGroup(AQ:autactbase:=List(actbase,x->Image(hom,x)));
    else
      AQiso:=IsomorphismPermGroup(AQ);
    fi;
    Info(InfoMorph,3,"Permrep of AQ ",Size(AQ));
    AQP:=Image(AQiso,AQ);
    # force degree down
    a:=Size(AQP);
    AQP:=Group(SmallGeneratingSet(AQP),One(AQP));
    SetSize(AQP,a);
    if isBadPermrep(AQP) then
      a:=SmallerDegreePermutationRepresentation(AQP:cheap);
      if NrMovedPoints(Image(a))<NrMovedPoints(AQP) then
	Info(InfoMorph,3,"Permdegree reduced ",
	      NrMovedPoints(AQP),"->",NrMovedPoints(Image(a)));
	AQiso:=AQiso*a;
	b:=Image(a,AQP);
	if Length(GeneratorsOfGroup(b))>Length(GeneratorsOfGroup(AQP)) then
	  b:=Group(List(GeneratorsOfGroup(AQP),x->ImagesRepresentative(a,x)));
	  SetSize(b,Size(AQP));
	fi;
	AQP:=b;
      fi;
    fi;

  end;

  stablim:=function(gp,cond,lim)
  local no,same,sz,ac,i,sub;
    same:=true;
    repeat
      sz:=Size(Aperm);
      if Size(gp)/Size(Aperm)>lim then
        no:=Normalizer(gp,Aperm);
	if Size(no)>Size(Aperm) and Size(no)<Size(gp) then
	  stablim(no,cond,lim);
	fi;
      else
	no:=Aperm;
      fi;
      if Size(gp)/Size(Aperm)>lim then
	ac:=AscendingChain(gp,Aperm);
	List(Union(List(ac,GeneratorsOfGroup)),cond); # try generators...
	if Size(Aperm)>sz then
	  ac:=Unique(List(ac,x->ClosureGroup(Aperm,x)));
	fi;
	
	i:=First([Length(ac),Length(ac)-1..1],x->Size(ac[x])/sz<=lim);
	sub:=ac[i];
      else
	sub:=gp;
      fi;
      if Size(sub)>Size(Aperm) and not IsSubset(no,sub) then
	SubgroupProperty(sub,cond,Aperm);
      fi;
      same:=Size(Aperm)=sz;
      if not same then
	Info(InfoMorph,3,"stablim improves by ",Size(Aperm)/sz,
	" remaining ",Size(gp)/Size(Aperm));
      fi;
    until same;
    return sub=gp;
  end;

  ff:=FittingFreeLiftSetup(G);
  r:=ff.radical;
  # find series through r

  # derived and then primes and then elementary abelian
  d:=ValueOption("series");
  if d=fail then
    d:=DerivedSeriesOfGroup(r);
    # refine
    d:=RefinedSubnormalSeries(d,Centre(r));
    scharorb:=fail;
    somechar:=ValueOption("someCharacteristics");
    if somechar<>fail then
      if IsRecord(somechar) then
	if IsBound(somechar.orbits) then
	  scharorb:=somechar.orbits;
	fi;
	somechar:=somechar.subgroups;
      fi;
      for i in somechar do
	d:=RefinedSubnormalSeries(d,i);
      od;
    fi;
    for i in Set(Factors(Size(r))) do
      u:=PCore(r,i);
      if Size(u)>1 then
	d:=RefinedSubnormalSeries(d,u);
	j:=1;
	repeat
	  v:=Agemo(u,i,j);
	  if Size(v)>1 then
	    d:=RefinedSubnormalSeries(d,v);
	  fi;
	  j:=j+1;
	until Size(v)=1;
	j:=1;
	repeat
	  v:=Omega(u,i,j);
	  if Size(v)<Size(u) then
	    d:=RefinedSubnormalSeries(d,v);
	  fi;
	  j:=j+1;
	until Size(v)=Size(u);
      fi;

    od;
    Assert(1,ForAll([1..Length(d)-1],x->Size(d[x])<>Size(d[x+1])));

    d:=Reversed(d);
  else
    d:=ShallowCopy(d);
    SortBy(d,Size); # in case reversed order....
  fi;

  ser:=[TrivialSubgroup(G)];
  for i in d{[2..Length(d)]} do
    u:=ser[Length(ser)];
    for p in Set(Factors(Size(i)/Size(u))) do
      bd:=PValuation(Size(i)/Size(u),p); # max p-exponent
      u:=ClosureSubgroup(u,SylowSubgroup(i,p));
      v:=ser[Length(ser)];
      while not HasElementaryAbelianFactorGroup(u,v) do
	gens:=Filtered(GeneratorsOfGroup(u),x->not x in v);
        e:=List(gens,x->First([1..bd],a->x^(p^a) in v));
	e:=p^(Maximum(e)-1);
	for j in gens do
	  v:=ClosureSubgroup(v,j^e);
	od;
	Add(ser,v);
      od;
      Add(ser,u);
    od;
  od;

  rada:=fail;

  ser:=Reversed(ser);
  i:=1;
  hom:=ff.factorhom;
  Q:=Image(hom,G);
  if IsPermGroup(Q) and NrMovedPoints(Q)/Size(Q)*Size(Socle(Q))
	>SufficientlySmallDegreeSimpleGroupOrder(Size(Q)) then
    # just in case the radical factor hom is inherited.
    Q:=SmallerDegreePermutationRepresentation(Q);
    Info(InfoMorph,3,"Radical factor degree reduced ",NrMovedPoints(Range(hom)),
	      " -> ",NrMovedPoints(Range(Q)));
    hom:=hom*Q;
    Q:=Image(hom,G);
  fi; 

  ma:=MaximalSubgroupClassesSol(G);

  AQ:=AutomorphismGroupFittingFree(Q:someCharacteristics:=fail);
  AQI:=InnerAutomorphismsAutomorphismGroup(AQ);
  lastperm:=fail;
  while i<Length(ser) do
    Assert(2,ForAll(GeneratorsOfGroup(AQ),x->Size(Source(x))=Size(Q)));
    # ensure that the step is OK
    lhom:=hom;
    OQ:=Q;
    repeat
      Info(InfoMorph,4,List(ser,Size)," ",i);
      Info(InfoMorph,1,"Step ",i," ",Size(ser[i]),"->",Size(ser[i+1]));
      M:=ser[i];
      N:=ser[i+1];
      hom:=NaturalHomomorphismByNormalSubgroup(G,N);
      Q:=Image(hom,G);
      # degree reduction called for?
      if Size(N)>1 and isBadPermrep(Q) then
	#if NrMovedPoints(Q)>15000 then Error("egad!");fi;
	q:=SmallerDegreePermutationRepresentation(Q);
	Info(InfoMorph,3,"reduced permrep Q ",NrMovedPoints(Q)," -> ",
	     NrMovedPoints(Range(q)));
	hom:=hom*q;
	Q:=Image(hom,G);
      fi;

      # inherit radical factor map
      q:=GroupHomomorphismByImagesNC(Q,Range(ff.factorhom),
	List(GeneratorsOfGroup(G),x->ImagesRepresentative(hom,x)),
	List(GeneratorsOfGroup(G),x->ImagesRepresentative(ff.factorhom,x)));
      b:=Image(hom,ff.radical);
      SetRadicalGroup(Q,b);
      AddNaturalHomomorphismsPool(Q,b,q);

      # Use known maximals for Frattini
      for j in ma do
        D:=Image(hom,j);
	if not IsSubset(D,b) then
	  b:=Core(Q,NormalIntersection(b,D));
	fi;
      od;
      SetIsNilpotentGroup(b,true);
      SetFrattiniSubgroup(Q,b);

      # M-factor
      Mim:=Image(hom,M);
      MPcgs:=Pcgs(Mim);
      q:=GroupHomomorphismByImagesNC(Q,OQ,
	List(GeneratorsOfGroup(G),x->ImagesRepresentative(hom,x)),
	List(GeneratorsOfGroup(G),x->ImagesRepresentative(lhom,x)));
      AddNaturalHomomorphismsPool(Q,Mim,q);

      mo:=GModuleByMats(LinearActionLayer(GeneratorsOfGroup(Q),MPcgs),GF(RelativeOrders(MPcgs)[1]));
      # is the extension split?
      ocr:=OneCocycles(Q,Mim);
      split:=ocr.isSplitExtension;
      if not split then
	# test: Semisimple and Frattini
	b:=MTX.BasisRadical(mo);
	fratsim:=Length(b)=0;
	if not fratsim then
	  b:=List(b,x->PreImagesRepresentative(hom,PcElementByExponents(MPcgs,x)));
	  for j in b do
	    N:=ClosureSubgroup(N,b);
	  od;
	  # insert
	  for j in [Length(ser),Length(ser)-1..i+1] do
	    ser[j+1]:=ser[j];
	  od;
	  ser[i+1]:=N;
	  Info(InfoMorph,2,"insert1");
	else
	  # Frattini?
	  fratsim:=IsSubset(FrattiniSubgroup(Q),Mim);
	  if not fratsim then
	    N:=Intersection(FrattiniSubgroup(Q),Mim);
	    # insert
	    for j in [Length(ser),Length(ser)-1..i+1] do
	      ser[j+1]:=ser[j];
	    od;
	    ser[i+1]:=PreImage(hom,N);
	    Info(InfoMorph,2,"insert2");
	  fi;
	fi;
      fi;
    until split or fratsim;

    # Use cocycles
    b:=BasisVectors(Basis(ocr.oneCocycles));

    # find D
    Zm:=PreImage(q,Centre(OQ));
    D:=Centralizer(Zm,Mim);

    innC:=List(GeneratorsOfGroup(D),d->InnerAutomorphism(Q,d));
    
    D:=List(innC,inn->List(ocr.generators,o->Image(inn,o)));
    D:=List(D,d->List([1..Length(ocr.generators)],i->ocr.generators[i]^-1*d[i]));
    D:=List(D,d->ocr.listToCocycle(d));
    TriangulizeMat(D);
    D:=Filtered(D,x->x<>0*x);

    b:=BaseSteinitzVectors(b,D).factorspace; 

    C:=[];
    if Size(Group(ocr.generators))<Size(Q) then
      extra:=MPcgs;
    else
      extra:=[];
    fi;
    for j  in b  do
      oneC := ocr.cocycleToList( j );
      imgs:=List([1..Length(ocr.generators)],i->ocr.generators[i]*oneC[i]); 
      oneC:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(ocr.generators,extra),Concatenation(imgs,extra));
      Assert(2,IsBijective(oneC));
      Add(C,oneC);
    od;

    B:=[];

    if lastperm<>fail then
      AQiso:=lastperm;
      AQP:=Group(List(GeneratorsOfGroup(AQ),x->ImagesRepresentative(AQiso,x))); 
    else
      makeaqiso();
    fi;

    if split then
      maut:=MTX.ModuleAutomorphisms(mo);
      # find noninner of B
      innB:=List(SmallGeneratingSet(Zm),z->InnerAutomorphism(Q,z));
      innB:=Group(One(DefaultFieldOfMatrixGroup(maut))*
		      List(innB,inn->List(MPcgs,m->ExponentsOfPcElement(MPcgs,Image(inn,m)))));

      tmpAut:=SubgroupNC(maut,Filtered(GeneratorsOfGroup(maut),aut->not aut in innB));		

      gens:=GeneratorsOfGroup(ocr.complement);
      for a  in GeneratorsOfGroup(tmpAut)  do
	imM:=List(a,i->PcElementByExponents(MPcgs,i));
	imM:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(MPcgs,gens),Concatenation(imM,gens));
	Assert(2,IsBijective(imM));
        Add(B,imM);
      od;

      # test condition for lifting, also add corresponding automorphism
      comiso:=GroupHomomorphismByImagesNC(ocr.complement,OQ,gens,List(gens,x->ImagesRepresentative(q,x)));

      precond:=fail;
      mo:=GModuleByMats(LinearActionLayer(gens,MPcgs),mo.field);
      cond:=function(perm)
      local aut,newgens,mo2,iso,a;
        if perm in Aperm then
	  return true;
	fi;
        aut:=PreImagesRepresentative(AQiso,perm);
	newgens:=List(gens,x->PreImagesRepresentative(comiso,
	  ImagesRepresentative(aut,ImagesRepresentative(comiso,x))));

        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
	iso:=MTX.IsomorphismModules(mo,mo2);
	if iso=fail then
	  return false;
	else
	  # build associated auto

	  a:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(gens,MPcgs),
	          Concatenation(newgens,
                   List(MPcgs,x->PcElementByExponents(MPcgs,
		     (ExponentsOfPcElement(MPcgs,x)*One(mo.field))*iso  ))));
	 Assert(2,IsBijective(a));
         Add(A,a);
	 Add(Apa,perm);
	 Aperm:=ClosureGroup(Aperm,perm);
         return true;
	fi;
      end;

    else
      # there is no B in the nonsplit case
      B:=[];

      ocr:=AGSRPrepareAutomLift( Q, MPcgs, q );

      precond:=function(perm)
      local aut,newgens,mo2,iso,a;
        if perm in Aperm then
	  return true;
	fi;
        aut:=PreImagesRepresentative(AQiso,perm);
	newgens:=List(GeneratorsOfGroup(Q),
	  x->PreImagesRepresentative(q,Image(aut,ImagesRepresentative(q,x))));
        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
	return MTX.IsomorphismModules(mo,mo2)<>fail;
      end;

      cond:=function(perm)
      local aut,newgens,mo2,iso,a;
        if perm in Aperm then
	  return true;
	fi;
        aut:=PreImagesRepresentative(AQiso,perm);
	newgens:=List(GeneratorsOfGroup(Q),
	  x->PreImagesRepresentative(q,Image(aut,ImagesRepresentative(q,x))));
        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
	iso:=MTX.IsomorphismModules(mo,mo2);
	if iso=fail then
	  return false;
	else
	  # build associated auto
	  a:=AGSRAutomLift(ocr,q,aut,iso);
	  if a=fail then
	    #Print("test failed\n");
	    return false;
	  else
	    Add(A,a);
	    Add(Apa,perm);
	    Aperm:=ClosureGroup(Aperm,perm);
	    #Print("test succeeded\n");
	    return true;
	  fi;
	fi;
      end;

    fi;

    # find A using the set condition
    A:=[];
    Apa:=[];
    # note: we do not include AQI here, so might need to add later
    Aperm:=SubgroupNC(AQP,List(GeneratorsOfGroup(AQI),
	    x->ImagesRepresentative(AQiso,x)));

    # try to find some further generators
    if Size(AQP)/Size(Aperm)>100 then
      for j in Pcgs(RadicalGroup(AQP)) do
	cond(j);
      od;
      for j in GeneratorsOfGroup(AQP) do
	cond(j);
      od;
    fi;

    sub:=AQP;
    #if Size(KernelOfMultiplicativeGeneralMapping(hom))=1 then
    #  Error("trigger");
    #fi;
    if precond<>fail and not ForAll(GeneratorsOfGroup(sub),precond) then
      sub:=SubgroupProperty(sub,precond,Aperm);
    fi;

    # desperately try to grab some further generators
    #stablim(sub,cond,10000)=false then

    #if Size(sub)/Size(Aperm)>1000000 then Error("Million"); fi;
    sub:=SubgroupProperty(sub,cond,Aperm);

    Aperm:=Group(Apa,());
    j:=1;
    while Size(Aperm)<Size(sub) do
      ac:=InnerAutomorphism(OQ,Image(q,GeneratorsOfGroup(Q)[j]));
      k:=ImagesRepresentative(AQiso,ac);
      if not k in Aperm then
	Aperm:=ClosureGroup(Aperm,k);
	Add(A,InnerAutomorphism(Q,GeneratorsOfGroup(Q)[j]));
      fi;
      j:=j+1;
    od;

    Info(InfoMorph,2,"Lift Index ",Size(AQP)/Size(sub));

    # now make the new automorphism group
    innB:=List(SmallGeneratingSet(Q),x->InnerAutomorphism(Q,x));
    gens:=ShallowCopy(innB);
    Append(gens,C);
    Append(gens,B);
    Append(gens,A);

    Assert(2,ForAll(gens,IsBijective));
    for j in gens do
      SetIsBijective(j,true);
    od;
    A:=Group(gens);
    SetIsAutomorphismGroup(A,true);
    SetIsGroupOfAutomorphismsFiniteGroup(A,true);
    SetIsFinite(A,true);

    AQI:=SubgroupNC(A,innB);
    SetInnerAutomorphismsAutomorphismGroup(A,AQI);
    AQ:=A;
    makeaqiso();

     # use the actbase for order computations
    #if actbase<>fail then
    #  Size(A:autactbase:=List(actbase,x->Image(hom,x)));
    #fi;

    # do we use induced radical automorphisms to help next step?
    if Size(KernelOfMultiplicativeGeneralMapping(hom))>1 and
      Size(A)>10^8 and (IsAbelian(r) or
      Length(AbelianInvariants(r))<10)
      #(
      ## potentially large GL
      #Size(GL(Length(MPcgs),RelativeOrders(MPcgs)[1]))>10^10 and
      ## automorphism size really grew from B/C-bit
      ##Size(A)/Size(AQP)*Index(AQP,sub)>10^10) )
     then

      if rada=fail then
	if IsElementaryAbelian(r) and Size(r)>1 then
	  B:=Pcgs(r);
	  rf:=GF(RelativeOrders(B)[1]);
	  ind:=Filtered(ser,x->IsSubset(r,x) and Size(x)>1 and Size(x)<Size(r)); 
	  ind:=List(ind,x->List(GeneratorsOfGroup(x),y->ExponentsOfPcElement(B,y)));
	  ind:=List(ind,x->x*One(rf));
	  ind:=SpaceAndOrbitStabilizer(Length(B),rf,ind,[]);
	  rada:=List(GeneratorsOfGroup(ind),x->
	    GroupHomomorphismByImagesNC(r,r,B,List(x,y->PcElementByExponents(B,List(y,Int)))));
	  rada:=Group(rada);
	  SetIsGroupOfAutomorphismsFiniteGroup(rada,true);
	  NiceMonomorphism(rada:autactbase:=fail,someCharacteristics:=fail);
	else
	  ind:=IsomorphismPcGroup(r);
	  rada:=AutomorphismGroup(Image(ind,r):someCharacteristics:=fail,autactbase:=fail);
	  # we only consider those homomorphism that stabilize the series we use
	  for k in List(ser,x->Image(ind,x)) do
	    if ForAny(GeneratorsOfGroup(rada),x->Image(x,k)<>k) then
	      Info(InfoMorph,3,"radical automorphism stabilizer");
	      NiceMonomorphism(rada:autactbase:=fail,someCharacteristics:=fail);
	      rada:=Stabilizer(rada,k,asAutom);
	    fi;
	  od;
	  # move back to bad degree
	  rada:=Group(List(GeneratorsOfGroup(rada),
	    x-> InducedAutomorphism(InverseGeneralMapping(ind),x)));

	fi;
      fi;

      rf:=Image(hom,r);
      Info(InfoMorph,2,"Use radical automorphisms for reduction");

      makeaqiso();
      B:=MappingGeneratorsImages(AQiso);
      res:=List(B[1],x->
        GroupHomomorphismByImagesNC(rf,rf,GeneratorsOfGroup(rf),
	  List(GeneratorsOfGroup(rf),y->ImagesRepresentative(x,y))));

      ind:=[];
      for j in GeneratorsOfGroup(rada) do
	k:=GroupHomomorphismByImagesNC(rf,rf,
          GeneratorsOfGroup(rf),
	  List(GeneratorsOfGroup(rf),
	    y->ImagesRepresentative(hom,ImagesRepresentative(j,
	         PreImagesRepresentative(hom,y)))));
	Assert(2,IsBijective(k));
        Add(ind,k);
      od;

      C:=Group(Concatenation(res,ind)); # to guarantee common parent
      SetIsFinite(C,true);
      SetIsGroupOfAutomorphismsFiniteGroup(C,true);
      Size(C:autactbase:=fail,someCharacteristics:=fail); # disable autactbase transfer
      res:=SubgroupNC(C,res);
      ind:=SubgroupNC(C,ind);
      # this should now go via the niceo of C
      Size(ind:autactbase:=fail,someCharacteristics:=fail);
      Size(res:autactbase:=fail,someCharacteristics:=fail);
      ind:=Intersection(res,ind); # only those we care about

      if Size(ind)<Size(res) then
        # reduce to subgroup that induces valid automorphisms
	Info(InfoMorph,1,"Radical autos reduce by factor ",Size(res)/Size(ind));
        resperm:=IsomorphismPermGroup(C);
	proj:=GroupHomomorphismByImagesNC(AQP,Image(resperm),
	  B[2],List(GeneratorsOfGroup(res),x->ImagesRepresentative(resperm,x)));
	C:=PreImage(proj,Image(resperm,ind));
	C:=List(SmallGeneratingSet(C),x->PreImagesRepresentative(AQiso,x));
	AQ:=Group(C);
	SetIsFinite(AQ,true);
	SetIsGroupOfAutomorphismsFiniteGroup(AQ,true);
        makeaqiso();
      fi;

      # # hook for using existing characteristics to reduce for next step
      if somechar<>fail then
        u:=Filtered(Unique(List(somechar,x->Image(hom,x))),x->Size(x)>1);
	u:=Filtered(u,s->ForAny(GeneratorsOfGroup(AQ),h->Image(h,s)<>s));
	SortBy(u,Size);
	Info(InfoMorph,1,"Forced characteristics ",List(u,Size));

	if scharorb<>fail then
	  # these are subgroups for which certain orbits must be stabilized.
	  C:=List(Reversed(scharorb),x->List(x,y->Image(hom,y)));
	  C:=Filtered(C,x->Size(x[1])>1 and Size(x[1])<Size(Q));
	  Info(InfoMorph,1,"Forced orbits ",List(C,x->Size(x[1])));
	  Append(u,C);
	fi;

	if Length(u)>0 then
	  C:=MappingGeneratorsImages(AQiso);
	  if C[2]<>GeneratorsOfGroup(AQP) then
	    C:=[List(GeneratorsOfGroup(AQP),
	             x->PreImagesRepresentative(AQiso,x)),
		     GeneratorsOfGroup(AQP)];
	  fi;
	  for j in u do
	    if IsList(j) then
	      # stabilizer set of subgroups
	      jorb:=ShallowCopy(Orbit(AQP,j[1],C[2],C[1],asAutom));
	      jorpo:=[Position(jorb,j[1]),Position(jorb,j[2])];
	      if jorpo[2]=fail then
	        Append(jorb,Orbit(AQP,j[1],C[2],C[1],asAutom));
		jorpo[2]:=Position(jorb,j[2]);
	      fi;
	      if Length(jorb)>Length(j) then
		B:=ActionHomomorphism(AQP,jorb,C[2],C[1],asAutom); 
		substb:=Group(List(C[2],x->ImagesRepresentative(B,x)),());
		substb:=Stabilizer(substb,Set(jorpo),OnSets);
		substb:=PreImage(B,substb);
		Info(InfoMorph,2,"Stabilize characteristic orbit ",Size(j[1]),
		  " :",Size(AQP)/Size(substb) );
	      else
	        substb:=AQP;
	      fi;


	    else
	      substb:=Stabilizer(AQP,j,C[2],C[1],asAutom);
	      Info(InfoMorph,2,"Stabilize characteristic subgroup ",Size(j),
		" :",Size(AQP)/Size(substb) );
	    fi;
	    if Size(substb)<Size(AQP) then
	      B:=Size(substb);
	      substb:=SmallGeneratingSet(substb);
	      AQP:=Group(substb);
	      SetSize(AQP,B);
	      C:=[List(substb,x->PreImagesRepresentative(AQiso,x)),substb];
	    fi;

	  od;
	  AQ:=Group(C[1]);
	  SetIsFinite(AQ,true);
	  SetIsGroupOfAutomorphismsFiniteGroup(AQ,true);
	  SetSize(AQ,Size(AQP));
	  #AQP:=Group(C[2]); # ensure small gen set
	  #SetSize(AQP,Size(AQ));
	  makeaqiso();
	fi;
      fi;

      lastperm:=AQiso;
    else
      lastperm:=fail;
    fi;

    i:=i+1;
  od;

  return AQ;

end);

# pathetic isomorphism test, based on the automorphism group of GxH. This is
# only of use as long as we don't yet have a Cannon/Holt version of
# isomorphism available and there are many generators
InstallGlobalFunction(PatheticIsomorphism,function(G,H)
local d,a,map,possibly,cG,cH,nG,nH,i,j,sel,u,v,asAutomorphism,K,L,conj,e1,e2,
      iso,api,good,gens,pre;
  possibly:=function(a,b)
    if Size(a)<>Size(b) then
      return false;
    fi;
    if AbelianInvariants(a)<>AbelianInvariants(b) then
      return false;
    fi;
    if Size(a)<1000 and Size(a)<>512
     and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
      Info(InfoPerformance,2,"Using Small Groups Library");
      if IdGroup(a)<>IdGroup(b) then
	return false;
      fi;
    fi;
    return true;
  end;

  asAutomorphism:=function(sub,hom)
    return Image(hom,sub);
  end;

  # TODO: use matgrp package
  if not (IsPermGroup(G) or IsPcGroup(G))  then
    i:=IsomorphismPermGroup(G);
    iso:=PatheticIsomorphism(Image(i,G),H);
    if iso=fail then
      return iso;
    else
      return i*iso;
    fi;
  fi;

  # TODO: use matgrp package
  if not (IsPermGroup(H) or IsPcGroup(H)) then
    i:=IsomorphismPermGroup(H);
    iso:=PatheticIsomorphism(G,Image(i,H));
    if iso=fail then
      return iso;
    else
      return iso*InverseGeneralMapping(i);
    fi;
  fi;

  # go through factors of characteristic series to keep orbits short.
  AutomorphismGroup(G:someCharacteristics:=fail);
  AutomorphismGroup(H:someCharacteristics:=fail);
  cG:=CharacteristicSubgroups(G);
  nG:=[];
  cH:=ShallowCopy(CharacteristicSubgroups(H));
  if Length(cG)<>Length(cH) then
    return fail;
  fi;
  SortBy(cH,Size);
  nH:=[];
  i:=1;
  good:=[1..Length(cH)];
  while i<=Length(cH) do
    if i in good and Size(cH[i])>1 and Size(cH[i])<Size(H) then
      sel:=Filtered([1..Length(cG)],x->possibly(cG[x],cH[i]));
      if Length(sel)=0 then
	return fail;
      elif Length(sel)=1 then
	Add(nG,cG[sel[1]]);
	Add(nH,cH[i]);
      else
	u:=TrivialSubgroup(G);
	for j in sel do
	  u:=ClosureGroup(u,cG[j]);
	od;
	sel:=Concatenation([i],Filtered([i+1..Length(cH)],
                                 x->possibly(cH[i],cH[x])));
	v:=TrivialSubgroup(H);
	for j in sel do
	  v:=ClosureGroup(v,cH[j]);
	od;
	if Size(u)<>Size(v) then
	  return fail;
	fi;
	good:=Difference(good,sel);
	if Size(u)<Size(G) then
	  Add(nG,u);
	  Add(nH,v);
	fi;
      fi;
    fi;
    i:=i+1;
  od;

  d:=DirectProduct(G,H);
  e1:=Embedding(d,1);
  e2:=Embedding(d,2);
  # combine images of characteristic factors, reverse order
  cG:=[];
  nG:=Reversed(nG);
  nH:=Reversed(nH);
  for i in [1..Length(nG)] do
    Add(cG,ClosureGroup(Image(e1,nG[i]),Image(e2,nH[i])));
  od;
  nG:=Concatenation([TrivialSubgroup(G)],nG);
  nH:=Concatenation([TrivialSubgroup(H)],nH);

  for i in [2..Length(nG)] do
    K:=Filtered([1..Length(nG)],x->Size(nG[x])*2=Size(nG[i]) 
	  and IsSubset(nG[i],nG[x]));
    if Length(K)>0 then
      K:=K[1];
      # We are seeking an isomorphism, not the full automorphism group of
      # GxG. It is thus sufficient, if we find the subgroup Aut(G)\wr 2.

      
      # We now found that G and H have two characteristic subgroups A<B with
      # [B:A]=2. An isomorphism swapping G and H will need to map B to B and
      # A to A. Furthermore, in the factor modulo A_G xA_H, a generator of
      # B_G must be swappes with a generator of B_H. 
      # This implies that A_G\times A_H, together with the diagonal of B is
      # characteristic in Aut(A)\wr 2. We thus may add this subgroup as
      # ``characteristic'' to improve the series.
    
      Add(cG,ClosureGroup(
	ClosureGroup(Image(e1,nG[K]),Image(e2,nH[K])),
	  Image(e1,First(GeneratorsOfGroup(nG[i]),x->not x in nG[K]))
	 *Image(e2,First(GeneratorsOfGroup(nH[i]),x->not x in nH[K]))));

    fi;
  od;

  K:=[Image(e1,G),Image(e2,H)];
  # we also fix the *pairs* of the characteristic subgroups as orbits. Again
  # this must happen in Aut(G)\wr 2, and reduces the size of the group.
  a:=AutomorphismGroup(d:autactbase:=K,someCharacteristics:=
    rec(subgroups:=cG,
        orbits:=List([1..Length(nG)],x->[Image(e1,nG[x]),Image(e2,nH[x])])));
  iso:=IsomorphismPermGroup(a:autactbase:=K);
  api:=Image(iso);
  #if NrMovedPoints(api)>5000 then
  #  K:=SmallerDegreePermutationRepresentation(api);
  #  Info(InfoMorph,2,"Permdegree reduced ",
#	  NrMovedPoints(api),"->",NrMovedPoints(Image(K)));
#    iso:=iso*K;
#    api:=Image(iso);
#  fi;

  # now work in reverse through the characteristic factors
  conj:=One(a);
  K:=Image(e1,G);
  L:=Image(e2,H);
  Add(cG,TrivialSubgroup(d));
  for i in cG do
    u:=ClosureGroup(i,K);
    v:=ClosureGroup(i,L);
    if u<>v then
      gens:=SmallGeneratingSet(api);
      pre:=List(gens,x->PreImagesRepresentative(iso,x));
      map:=RepresentativeAction(SubgroupNC(a,pre),u,v,asAutomorphism);
      if map=fail then
	return fail;
      fi;
      conj:=conj*map;
      K:=Image(map,K);

      u:=Stabilizer(api,v,gens,pre,asAutomorphism);
      Info(InfoMorph,1,"Factor ",Size(d)/Size(i),": ",
	  "reduce by ",Size(api)/Size(u));
      api:=u;
    fi;
  od;

  return GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),
    List(GeneratorsOfGroup(G),x->PreImagesRepresentative(e2,
         Image(conj,Image(e1,x)))));
end);

