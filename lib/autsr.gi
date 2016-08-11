#############################################################################
##
#W  auttf.gi                GAP library                      Alexander Hulpke
#W                                                           Soley Jonsdottir
##
##
#Y  Copyright (C) 2016 The GAP Group
##
##  This  file  contains an implementation of the Cannon/Holt automorphism
##  group algorithm.

BindGlobal("AGTFPrepareAutomLift",function(G,pcgs,nat)
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

BindGlobal("AGTFAutomLift",function(ocr,nat,fhom,miso)
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
BindGlobal("AutomGrpSR",function(G)
local ff,r,d,ser,u,v,i,j,p,bd,e,gens,lhom,M,N,hom,Q,Mim,q,ocr,split,MPcgs,
      b,fratsim,AQ,OQ,Zm,D,innC,bas,oneC,imgs,C,maut,innB,tmpAut,imM,a,A,B,
      cond,sub,AQI,AQP,AQiso,rf,res,resperm,proj,
      comiso,extra,mo,rada,makeaqiso,ind,lastperm;

  makeaqiso:=function();
    AQiso:=IsomorphismPermGroup(AQ);
    AQP:=Image(AQiso,AQ);
    # force degree down
    a:=Size(AQP);
    AQP:=Group(SmallGeneratingSet(AQP));
    SetSize(AQP,a);
    a:=SmallerDegreePermutationRepresentation(AQP:cheap);
    if NrMovedPoints(Image(a))<NrMovedPoints(AQP) then
      Info(InfoMorph,2,"Permdegree reduced ",
	    NrMovedPoints(AQP),"->",NrMovedPoints(Image(a)));
      AQiso:=AQiso*a;
      AQP:=Image(a,AQP);
    fi;
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
    for i in Set(Factors(Size(r))) do
      u:=PCore(r,i);
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
  AQ:=AutomorphismGroupFittingFree(Q);
  AQI:=InnerAutomorphismsAutomorphismGroup(AQ);
  lastperm:=fail;
  while i<Length(ser) do
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
      AQP:=Image(AQiso,AQ);
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

      cond:=function(perm)
      local aut,newgens,mo2,iso,a;
        aut:=PreImagesRepresentative(AQiso,perm);
	newgens:=List(GeneratorsOfGroup(Q),
	  x->PreImagesRepresentative(q,Image(aut,ImagesRepresentative(q,x))));
        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
	iso:=MTX.IsomorphismModules(mo,mo2);
	if iso=fail then
	  return false;
	else
	  # build associated auto

	  a:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(gens,MPcgs),
	          Concatenation(List(gens,x->PreImagesRepresentative(comiso,
		        ImagesRepresentative(aut,ImagesRepresentative(comiso,x)))),
                   List(MPcgs,x->PcElementByExponents(MPcgs,
		     (ExponentsOfPcElement(MPcgs,x)*One(mo.field))*iso  ))));
	 Assert(2,IsBijective(a));
         Add(A,a);
         return true;
	fi;
      end;

    else
      # there is no B in the nonsplit case
      B:=[];

      ocr:=AGTFPrepareAutomLift( Q, MPcgs, q );

      cond:=function(perm)
      local aut,newgens,mo2,iso,a;
        aut:=PreImagesRepresentative(AQiso,perm);
	newgens:=List(GeneratorsOfGroup(Q),
	  x->PreImagesRepresentative(q,Image(aut,ImagesRepresentative(q,x))));
        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
	iso:=MTX.IsomorphismModules(mo,mo2);
	if iso=fail then
	  return false;
	else
	  # build associated auto

	  a:=AGTFAutomLift(ocr,q,aut,iso);
	  if a=fail then
	    return false;
	  else
	    Add(A,a);
	    return true;
	  fi;
	fi;
      end;

    fi;

    # find A using the set condition
    A:=[];
    sub:=SubgroupProperty(AQP,cond,
      SubgroupNC(AQP,List(GeneratorsOfGroup(AQI),x->ImagesRepresentative(AQiso,x))));
    Info(InfoMorph,2,"Lift Index ",Size(AQP)/Size(sub));

    # now make the new automorphism group
    innB:=List(SmallGeneratingSet(Q),x->InnerAutomorphism(Q,x));
    gens:=ShallowCopy(innB);
    Append(gens,C);
    Append(gens,B);
    Append(gens,A);

    A:=Group(gens);
    SetIsAutomorphismGroup(A,true);
    SetIsGroupOfAutomorphismsFiniteGroup(A,true);
    SetIsFinite(A,true);

    AQI:=SubgroupNC(A,innB);
    SetInnerAutomorphismsAutomorphismGroup(A,AQI);

    AQ:=A;

    # do we use induced radical automorphisms to help next step?
    if Size(KernelOfMultiplicativeGeneralMapping(hom))>1 and
      # potentially large GL
      Size(GL(Length(MPcgs),RelativeOrders(MPcgs)[1]))>10^10 and
      # automorphism size really grew from B/C-bit
      Size(A)/Size(AQP)*Index(AQP,sub)>10^10
     then
      if rada=fail then
	rada:=AutomorphismGroup(r);
      fi;
      rf:=Image(hom,r);
      Info(InfoMorph,2,"Use radical automorphisms for reduction");

      makeaqiso();
      B:=MappingGeneratorsImages(AQiso);
      C:=List(B[1],x->
        GroupHomomorphismByImagesNC(rf,rf,GeneratorsOfGroup(rf),
	  List(GeneratorsOfGroup(rf),y->ImagesRepresentative(x,y))));
      res:=Group(C);
      SetIsFinite(res,true);
      SetIsGroupOfAutomorphismsFiniteGroup(res,true);

      ind:=List(GeneratorsOfGroup(rada),x->
        GroupHomomorphismByImagesNC(rf,rf,GeneratorsOfGroup(rf),
	  List(GeneratorsOfGroup(rf),y->ImagesRepresentative(hom,ImagesRepresentative(x,PreImagesRepresentative(hom,y))))));
      ind:=SubgroupNC(res,ind);
      #SetIsFinite(ind,true);
      #SetIsAutomorphismGroup(ind,true);
      #SetIsGroupOfAutomorphismsFiniteGroup(ind,true);

      if Size(ind)*100<Size(res) then
        # reduce to subgroup that induces valid automorphisms
	Info(InfoMorph,1,"Reduce by factor ",Size(res)/Size(ind));
        resperm:=IsomorphismPermGroup(res);
	proj:=GroupHomomorphismByImagesNC(AQP,Image(resperm),
	  B[2],List(C,x->ImagesRepresentative(resperm,x)));
	C:=PreImage(proj,Image(resperm,ind));
	C:=List(SmallGeneratingSet(C),x->PreImagesRepresentative(AQiso,x));
	AQ:=Group(C);
	SetIsFinite(AQ,true);
	SetIsGroupOfAutomorphismsFiniteGroup(AQ,true);
        makeaqiso();
      fi;

      lastperm:=AQiso;
    else
      lastperm:=fail;
    fi;


    i:=i+1;
  od;

  return AQ;

end);

