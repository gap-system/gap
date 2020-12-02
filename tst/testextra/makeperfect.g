# construct perfect groups of given order

# functions that could be used as isomorphism distinguishers
GpFingerprint:=function(g)
  if Size(g)<2000 and Size(g)<>512 and Size(g)<>1024 and Size(g)<>1536 then
    return IdGroup(g);
  else
    return [Size(g),IsPerfect(g),Collected(List(ConjugacyClasses(g),
      x->[Order(Representative(x)),Size(x)]))];
  fi;
end;

FPMaxReps:=function(g,a,b)
local l,s;
  l:=LowLayerSubgroups(g,a);
  s:=Set(l,Size);
  RemoveSet(s,Size(g));
  s:=Reversed(s);
  if b>Length(s) then return [];fi;
  return Filtered(l,x->Size(x)=s[b]);
end;

FINGERPRINTPROPERTIES:=[
  g->Collected(List(ConjugacyClasses(g),x->[Order(Representative(x)),Size(x)])),
  g->Collected(List(ConjugacyClasses(g),x->[Order(Representative(x)),GpFingerprint(Centralizer(x))])),
  g->Collected(List(MaximalSubgroupClassReps(g),GpFingerprint)),
  g->Collected(List(NormalSubgroups(g),x->[GpFingerprint(x),GpFingerprint(Centralizer(g,x))])),
  g->Collected(List(LowLayerSubgroups(g,2),GpFingerprint)),

#  g->Collected(List(LowLayerSubgroups(g,3),GpFingerprint)),

  #g->Collected(Flat(Irr(CharacterTable(g)))),
  #g->Length(ConjugacyClassesSubgroups(g)),
  #g->Collected(List(ConjugacyClassesSubgroups(g),x->[Size(x),GpFingerprint(Representative(x))])),
];

GrplistIds:=function(l)
local props,pool,test,c,f,r,tablecache,tmp;
  test:=function(p)
  local a,new,sel,i,dup,tmp;
    if c=Length(l) then return;fi;# not needed
    dup:=List(Filtered(Collected(pool),x->x[2]>1),x->x[1]);
    sel:=Filtered([1..Length(l)],x->pool[x] in dup);
    a:=[];
    for i in sel do
      tmp:=Group(GeneratorsOfGroup(l[i]));
      SetSize(tmp,Size(l[i]));
      a[i]:=p(tmp);
    od;
    if ForAny(dup,x->Length(Set(a{Filtered(sel,y->pool[y]=x)}))>1) then
      for i in sel do Add(pool[i],a[i]); od;
      Add(props,p);
      c:=Length(Set(pool));
    fi;
  end;
  props:=[];
  pool:=List(l,x->[]);c:=1;
  for f in FINGERPRINTPROPERTIES do test(f);od;
  if c<Length(l) then
    tablecache:=[];
    #Print("will have to rely on isomorphism tests\n");
  fi;
  r:=rec(props:=props,pool:=pool,
    groupinfo:=List(l,x->[Size(x),GeneratorsOfGroup(x)]),
    isomneed:=Filtered([1..Length(pool)],x->Number(pool,y->y=pool[x])>1),
    idfunc:=function(arg)
      local gorig,a,f,p,g,fingerprints,cands,badset,goodset,i;
        gorig:=arg[1];
        if Length(arg)>1 then
          badset:=arg[2];
          goodset:=arg[3];
        else
          badset:=[];
          goodset:=[];
        fi;
        if Length(r.pool)=1 then return 1;fi;
        g:=gorig;
        if IsBound(g!.fingerprints) then
          fingerprints:=g!.fingerprints;
        else
          fingerprints:=[];
          g!.fingerprints:=fingerprints;
        fi;
        if IsPermGroup(g) then
          if IsSolvableGroup(g) then
            g:=Image(IsomorphismPcGroup(g));
          else
            g:=Image(SmallerDegreePermutationRepresentation(g));
          fi;
          a:=Size(g);
          g:=Group(GeneratorsOfGroup(g)); # avoid caching lots of data
          SetSize(g,a);
        fi;
        a:=[];
        for f in r.props do
          p:=PositionProperty(fingerprints,x->x[1]=f);
          if p=fail then
            Add(a,f(g));
            Add(fingerprints,[f,a[Length(a)]]);
          else
            Add(a,fingerprints[p][2]);
          fi;
          cands:=Filtered([1..Length(r.pool)],x->
            Length(r.pool[x])>=Length(a) and r.pool[x]{[1..Length(a)]}=a);
          if IsSubset(badset,cands) then 
            #Print("badcand ",cands,"\n");
            return "bad";
          fi;
          if IsSubset(goodset,cands) then
            #Print("goodcand ",cands,"\n");
            return "good";
          fi;
          #if Length(cands)>1 then Print("Cands=",cands,"\n");fi;

          p:=Position(r.pool,a);
          if IsInt(p) and not p in r.isomneed then return p;fi;
        od;
        a:=Filtered([1..Length(r.pool)],x->r.pool[x]=a);

	if Length(ConjugacyClasses(g))<200 then
	  f:=Length(a);
	  for i in ShallowCopy(a) do
	    if Length(a)>1 then
	      if not IsBound(tablecache[i]) then
		tmp:=Group(r.groupinfo[i][2]);
		SetSize(tmp,r.groupinfo[i][1]);
		tablecache[i]:=CharacterTable(tmp);
	      fi;
	      if TransformingPermutationsCharacterTables(CharacterTable(g),
		    tablecache[i])=fail then
		RemoveSet(a,i);
	      fi;
	    fi;
	  od;
	  if Length(a)<f then
	    #Print("Character table test reduces ",f,"->", Length(a),"\n");
	  fi;
	fi;

	while Length(a)>1 do
	  i:=a[1];
	  a:=a{[2..Length(a)]};
          tmp:=Group(r.groupinfo[i][2]);
          SetSize(tmp,r.groupinfo[i][1]);
	  if IsomorphismGroups(g,tmp)<>fail then
	    return i;
	  fi;
	od;
	return a[1];
      end);
  l:=false; # clean memory
  return r;
end;

MemoryEfficientVersion:=function(G)
local f,k,pf,new;
  f:=FreeGroup(List(GeneratorsOfGroup(FreeGroupOfFpGroup(G)),String));
  new:=f/List(RelatorsOfFpGroup(G),x->MappedWord(x,FreeGeneratorsOfFpGroup(G),
    GeneratorsOfGroup(f)));
  k:=SmallGeneratingSet(G);
  pf:=List(k,x->ImagesRepresentative(IsomorphismPermGroup(G),x));
  k:=List(k,x->ElementOfFpGroup(FamilyObj(One(new)),MappedWord(
    UnderlyingElement(x),FreeGeneratorsOfFpGroup(G),GeneratorsOfGroup(f))));
  #pf:=MappingGeneratorsImages(IsomorphismPermGroup(G))[2];
  pf:=GroupHomomorphismByImagesNC(new,Group(pf),k,pf);
  SetIsomorphismPermGroup(new,pf);
  return new;
end;

MyIsomTest:=function(g,h)
local c,d,f;
  for f in FINGERPRINTPROPERTIES do
    if f(g)<>f(h) then return false;fi;
  od;
  if Length(ConjugacyClasses(g))<80 then
    c:=CharacterTable(g);;Irr(c);
    d:=CharacterTable(h);;Irr(d);
    if TransformingPermutationsCharacterTables(c,d)=fail then return false; fi;
  fi;

  c:=Size(g);
  if Length(GeneratorsOfGroup(g))>5 then 
    g:=Group(SmallGeneratingSet(g));
    SetSize(g,c);
  fi;
  if Length(GeneratorsOfGroup(h))>5 then 
    h:=Group(SmallGeneratingSet(h));
    SetSize(h,c);
  fi;
  return IsomorphismGroups(g,h)<>fail;
end;

# split out as that might help with memory
DoPerfectConstructionFor:=function(q,j,nts,ids)
local respp,cf,m,mpos,coh,fgens,comp,reps,v,new,isok,pema,pf,gens,nt,quot,
      res,qk,p,e,k,primax;

  primax:=NrPerfectGroups(Size(q));
  p:=Factors(nts)[1];
  e:=LogInt(nts,p);
  res:=[];
  respp:=[];
  cf:=IrreducibleModules(q,GF(p),e)[2];
  cf:=Filtered(cf,x->x.dimension=e);
  for m in cf do
    mpos:=Position(cf,m);
    #Print("Module dimension ",m.dimension,"\n");
    coh:=TwoCohomologyGeneric(q,m);
    fgens:=GeneratorsOfGroup(coh.presentation.group);

    comp:=[];
    if Length(coh.cohomology)=0 then
      reps:=[coh.zero];
    elif Length(coh.cohomology)=1 and p=2 then
      reps:=[coh.zero,coh.cohomology[1]];
    else
      comp:=CompatiblePairs(q,m);
      reps:=CompatiblePairOrbitRepsGeneric(comp,coh);
    fi;
    #Print("Compatible pairs ",Size(comp)," give ",Length(reps),
    #      " orbits from ",Length(coh.cohomology),"\n");
    for v in reps do
      new:=FpGroupCocycle(coh,v,true);
      isok:=IsPerfect(new);

      if isok then
        # could it have been gotten in another way?
        pema:=IsomorphismPermGroup(new);
        pema:=pema*SmallerDegreePermutationRepresentation(Image(pema));
        pf:=Image(pema);

        # generators that give module action
        gens:=List(coh.presentation.prewords,
          x->MappedWord(x,fgens,GeneratorsOfGroup(pf){[1..Length(fgens)]}));
        # want: generated through smallest normal subgroup, first
        # module of this kind for factor, first factor group
        #nt:=Filtered(NormalSubgroups(pf),IsElementaryAbelian);
        nt:=MinimalNormalSubgroups(pf);
        if ForAll(nt,x->Size(x)>=nts) then
          nt:=Filtered(nt,x->Size(x)=nts);

          # leave out the one how it was created
          quot:=GroupHomomorphismByImages(pf,coh.group,
            List(GeneratorsOfGroup(new),x->ImagesRepresentative(pema,x)),
              Concatenation(
              List(GeneratorsOfGroup(Range(coh.fphom)),
                x->PreImagesRepresentative(coh.fphom,x)),
                ListWithIdenticalEntries(coh.module.dimension, 
                  One(coh.group))
                ));
          qk:=KernelOfMultiplicativeGeneralMapping(quot);
          nt:=Filtered(nt,x->x<>qk);

          # consider the factor groups:
          # any smaller index -> discard
          # any equal index -> test
          # otherwise accept
          k:=1;
          while isok<>false and k<=Length(nt) do
            qk:=ids.idfunc(pf/nt[k],[1..j-1],[j+1..primax]);
            if (IsInt(qk) and qk<j) or qk="bad" then isok:=false;
            elif IsInt(qk) and qk=j then isok:=fail;fi;
            k:=k+1;
          od;

          if (isok<>false and ForAll(respp,x->MyIsomTest(x,pf)=false)) then
#    if ForAny(respp,x->MyIsomTest(x,pf)<>false) then Error("huh"); fi;
            Add(res,new);
            Add(respp,pf); # local list
            #Print("found nr. ",Length(res),"\n");
          else
            #Print("smallerc\n");
          fi;

        else
          #Print("smallera\n");
        fi;
      else
        #Print("not perfect\n");
      fi;
    od;

  od; #for m

  # cleanup of cached data to save memory
  for m in [1..Length(res)] do
    res[m]:=MemoryEfficientVersion(res[m]);

  od;
  return res;
end;

# option from is list, entry 1 is orders, entry s2, if given, indices
Practice:=function(n) #makes perfect
local globalres,resp,d,i,j,nt,p,e,q,cf,m,coh,v,new,quot,nts,pf,pl,comp,reps,
      ids,all,gens,fgens,mpos,ntm,dosubdir,isok,qk,k,respp,pema,from,ran,
      old;

  from:=ValueOption("from");
  dosubdir:=false;

  globalres:=[];
  #resp:=[];
  q:=SizesPerfectGroups();
  d:=Filtered(DivisorsInt(n),x->x<n and x in q);

  if from<>fail then d:=Intersection(d,from[1]);fi;

  for i in d do
    nts:=n/i;
    if IsPrimePowerInt(nts) then
      pl:=[];
      #if NrPerfectLibraryGroups(i)=0 then
      #  all:=PERFECTLIST[i];
      #else
        all:=List([1..NrPerfectGroups(i)],x->PerfectGroup(IsPermGroup,i,x));
      #fi;
      ids:=GrplistIds(all);
      for j in [1..Length(all)] do
        q:=all[j];
        if HasName(q) then
          new:=Name(q);
        else
          new:=Concatenation("Perfect(",String(Size(q)),",",String(j),")");
        fi;
        q:=Group(SmallGeneratingSet(q));
        SetName(q,new);
        Add(pl,q);
      od;

      ran:=[1..Length(pl)];
      if from<>fail and Length(from)>1 and Length(from[1])=1 then
        ran:=from[2];
      fi;
      for j in ran do
        old:=Length(globalres);
        q:=pl[j];
        #Print("Using ",i,", ",j,": ",q,"\n");
        Append(globalres,DoPerfectConstructionFor(q,j,nts,ids));
        #Print("Total now: ",Length(globalres)," groups\n");
        # kill factor group and associated info, as not needed any longer
        Unbind(pl[j]); 

      od; # for j in ran
    fi;
  od;
  return globalres;
end;
