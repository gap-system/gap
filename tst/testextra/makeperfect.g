# construct perfect groups of given order

Practice:=function(n) #makes perfect
local isot,res,resp,d,i,j,nt,p,e,q,cf,m,coh,v,new,quot,nts,pf,pl,comp,reps;
  isot:=function(g,h)
  local c,d;
    if Collected(List(ConjugacyClasses(g),
      x->[Order(Representative(x)),Size(x)]))<>
       Collected(List(ConjugacyClasses(h),
      x->[Order(Representative(x)),Size(x)])) then return false;
    fi;
    if Collected(List(MaximalSubgroupClassReps(g),Size))<>
       Collected(List(MaximalSubgroupClassReps(h),Size)) then return false;
    fi;
    if Collected(List(NormalSubgroups(g),
      x->[Size(x),IsAbelian(x),Size(Centralizer(g,x))]))<>
       Collected(List(NormalSubgroups(h),
      x->[Size(x),IsAbelian(x),Size(Centralizer(h,x))])) then return false;
    fi;
    c:=CharacterTable(g);;Irr(c);
    d:=CharacterTable(h);;Irr(d);
    if TransformingPermutationsCharacterTables(c,d)=fail then return false;fi;
    return IsomorphismGroups(g,h)<>fail;
  end;

  res:=[];
  resp:=[];
  d:=Filtered(DivisorsInt(n),x->x<n);
  for i in d do
    nts:=n/i;
    if IsPrimePowerInt(nts) then
      p:=Factors(nts)[1];
      e:=LogInt(nts,p);
      pl:=[];
      for j in [1..NrPerfectGroups(i)] do
        q:=PerfectGroup(IsPermGroup,i,j);
        new:=Name(q);
        q:=Group(SmallGeneratingSet(q));
        SetName(q,new);
        Add(pl,q);
      od;
      for j in [1..Length(pl)] do
        q:=pl[j];
        #Print("Using ",i,", ",j,": ",q,"\n");
        cf:=IrreducibleModules(q,GF(p),e)[2];
        cf:=Filtered(cf,x->x.dimension=e);
        for m in cf do
          #Print("Module dimension ",m.dimension,"\n");
          coh:=TwoCohomologyGeneric(q,m);

          comp:=CompatiblePairs(q,m);
          reps:=CompatiblePairOrbitRepsGeneric(comp,coh);
          for v in reps do
            new:=FpGroupCocycle(coh,v,true);
            if IsPerfect(new) then
              # could it have been gotten in another way?
              pf:=Image(IsomorphismPermGroup(new));
              nt:=NormalSubgroups(pf);
              if ForAll(nt,x->Size(x)=1 or Size(x)>=nts) then
                nt:=Filtered(nt,x->Size(x)=nts);
                if (not ForAny(List(nt,x->pf/x),x->ForAny([1..j-1],y->
                    isot(pl[y],x)))) and ForAll(resp,
                      x->isot(x,Image(IsomorphismPermGroup(new)))=false) then
                  Add(res,new);
                  Add(resp,Image(IsomorphismPermGroup(new)));
                  #Print("found nr. ",Length(res),"\n");
                else
                  #Print("smallerb\n");
                fi;
              #else Print("smallera\n");
              fi;
            fi;
          od;

        od;
      od;
    fi;
  od;
  return res;
end;

