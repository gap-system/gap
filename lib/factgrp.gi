###########################################################################
##
#W  factgrp.gi                      GAP library              Alexander Hulpke
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations of operations for factor group maps
##

#############################################################################
##
#M  NaturalHomomorphismsPool(G) . . . . . . . . . . . . . . initialize method
##
InstallMethod(NaturalHomomorphismsPool,true,[IsGroup],0,
  G->rec(GopDone:=false,ker:=[],ops:=[],cost:=[],group:=G,lock:=[],
         intersects:=[],blocksdone:=[],in_code:=false,dotriv:=false));

#############################################################################
##
#F  EraseNaturalHomomorphismsPool(G) . . . . . . . . . . . . initialize
##
InstallGlobalFunction(EraseNaturalHomomorphismsPool,function(G)
local r;
  r:=NaturalHomomorphismsPool(G);
  if r.in_code=true then return;fi;
  r.GopDone:=false;
  r.ker:=[];
  r.ops:=[];
  r.cost:=[];
  r.group:=G;
  r.lock:=[];
  r.intersects:=[];
  r.blocksdone:=[];
  r.in_code:=false;
  r.dotriv:=false;
  r:=NaturalHomomorphismsPool(G);
end);

#############################################################################
##
#F  AddNaturalHomomorphismsPool(G,N,op[,cost[,blocksdone]]) . Store operation
##       op for kernel N if there is not already a cheaper one
##       returns false if nothing had been added and 'fail' if adding was
##       forbidden
##
InstallGlobalFunction(AddNaturalHomomorphismsPool,function(arg)
local G, N, op, pool, p, c, perm, ch, diff, nch, nd, involved, i;
  G:=arg[1];
  N:=arg[2];
  op:=arg[3];

  # don't store trivial cases
  if Size(N)=Size(G) then
    Info(InfoFactor,4,"full group");
    return false;
  elif Size(N)=1 then
    # do we really want the trivial subgroup?
    if not (HasNaturalHomomorphismsPool(G) and
      NaturalHomomorphismsPool(G).dotriv=true) then
      Info(InfoFactor,4,"trivial sub: ignore");
      return false;
    fi;
    Info(InfoFactor,4,"trivial sub: OK");
  fi;

  pool:=NaturalHomomorphismsPool(G);

  # split lists in their components
  if IsList(op) and not IsInt(op[1]) then
    p:=[];
    for i in op do
      if IsMapping(i) then
        c:=Intersection(G,KernelOfMultiplicativeGeneralMapping(i));
      else
        c:=Core(G,i);
      fi;
      Add(p,c);
      AddNaturalHomomorphismsPool(G,c,i);
    od;
    # transfer in numbers list
    op:=List(p,i->PositionSet(pool.ker,i));
    if Length(arg)<4 then
      # add the prices
      c:=Sum(pool.cost{op});
    fi;
  # compute/get costs
  elif Length(arg)>3 then
    c:=arg[4];
  else
    if IsGroup(op) then
      c:=Index(G,op);
    elif IsMapping(op) then
      c:=Image(op);
      if IsPcGroup(c) then
	c:=1;
      elif IsPermGroup(c) then
	c:=NrMovedPoints(c);
      else
        c:=Size(c);
      fi;
    fi;
  fi;

  # check whether we have already a better operation (or whether this normal
  # subgroup is locked)

  p:=PositionSet(pool.ker,N);
  if p=fail then
    if pool.in_code then
      return fail;
    fi;
    p:=PositionSorted(pool.ker,N);
    # compute the permutation we have to apply finally
    perm:=PermList(Concatenation([1..p-1],[Length(pool.ker)+1],
                   [p..Length(pool.ker)]))^-1;

    # first add at the end
    p:=Length(pool.ker)+1;
    pool.ker[p]:=N;
    Info(InfoFactor,2,"Added price ",c," for size ",Index(G,N),
         " in group of size ",Size(G));
  elif c>=pool.cost[p] then
    Info(InfoFactor,4,"bad price");
    return false; # nothing added
  elif pool.lock[p]=true then
    return fail; # nothing added
  else
    Info(InfoFactor,2,"Changed price ",c," for size ",Index(G,N));
    perm:=();
    # update dependent costs
    ch:=[p];
    diff:=[pool.cost[p]-c];
    while Length(ch)>0 do
      nch:=[];
      nd:=[];
      for i in [1..Length(pool.ops)] do
        if IsList(pool.ops[i]) then
	  involved:=Intersection(pool.ops[i],ch);
	  if Length(involved)>0 then
	    involved:=Sum(diff{List(involved,x->Position(ch,x))});
	    pool.cost[i]:=pool.cost[i]-involved;
	    Add(nch,i);
	    Add(nd,involved);
	  fi;
	fi;
      od;
      ch:=nch;
      diff:=nd;
    od;
  fi;

  if IsMapping(op) and not HasKernelOfMultiplicativeGeneralMapping(op) then
    SetKernelOfMultiplicativeGeneralMapping(op,N);
  fi;
  pool.ops[p]:=op;
  pool.cost[p]:=c;
  pool.lock[p]:=false;

  # update the costs of all intersections that are affected
  for i in [1..Length(pool.ker)] do
    if IsList(pool.ops[i]) and IsInt(pool.ops[i][1]) and p in pool.ops[i] then
      pool.cost[i]:=Sum(pool.cost{pool.ops[i]});
    fi;
  od;

  if Length(arg)>4 then
    pool.blocksdone[p]:=arg[5];
  else
    pool.blocksdone[p]:=false;
  fi;

  if perm<>() then
    # sort the kernels anew
    pool.ker:=Permuted(pool.ker,perm);
    # sort/modify the other components accordingly
    pool.ops:=Permuted(pool.ops,perm);
    for i in [1..Length(pool.ops)] do
      # if entries are lists of integers
      if IsList(pool.ops[i]) and IsInt(pool.ops[i][1]) then
	pool.ops[i]:=List(pool.ops[i],i->i^perm);
      fi;
    od;
    pool.cost:=Permuted(pool.cost,perm);
    pool.lock:=Permuted(pool.lock,perm);
    pool.blocksdone:=Permuted(pool.blocksdone,perm);
    pool.intersects:=Set(List(pool.intersects,i->List(i,j->j^perm)));
  fi;

  return perm; # if anyone wants to keep the permutation
end);


#############################################################################
##
#F  LockNaturalHomomorphismsPool(G,N)  . .  store flag to prohibit changes of
##                                                               the map to N
##
InstallGlobalFunction(LockNaturalHomomorphismsPool,function(G,N)
local pool;
  pool:=NaturalHomomorphismsPool(G);
  N:=PositionSet(pool.ker,N);
  if N<>fail then
    pool.lock[N]:=true;
  fi;
end);


#############################################################################
##
#F  UnlockNaturalHomomorphismsPool(G,N) . . .  clear flag to allow changes of
##                                                               the map to N
##
InstallGlobalFunction(UnlockNaturalHomomorphismsPool,function(G,N)
local pool;
  pool:=NaturalHomomorphismsPool(G);
  N:=PositionSet(pool.ker,N);
  if N<>fail then
    pool.lock[N]:=false;
  fi;
end);


#############################################################################
##
#F  KnownNaturalHomomorphismsPool(G,N) . . . . .  check whether Hom is stored
##                                                               (or obvious)
##
InstallGlobalFunction(KnownNaturalHomomorphismsPool,function(G,N)
  return N=G or Size(N)=1 
      or PositionSet(NaturalHomomorphismsPool(G).ker,N)<>fail;
end);


#############################################################################
##
#F  GetNaturalHomomorphismsPool(G,N)  . . . .  get operation for G/N if known
##
InstallGlobalFunction(GetNaturalHomomorphismsPool,function(G,N)
local pool,p,h,ise,emb,i,j;
  if not HasNaturalHomomorphismsPool(G) then
    return fail;
  fi;
  pool:=NaturalHomomorphismsPool(G);
  p:=PositionSet(pool.ker,N);
  if p<>fail then
    h:=pool.ops[p];
    if IsList(h) then
      # just stored as intersection. Construct the mapping!
      # join intersections
      ise:=ShallowCopy(h);
      for i in ise do
	if IsList(pool.ops[i]) and IsInt(pool.ops[i][1]) then
	  for j in Filtered(pool.ops[i],j-> not j in ise) do
	    Add(ise,j);
	  od;
	elif not pool.blocksdone[i] then
	  h:=GetNaturalHomomorphismsPool(G,pool.ker[i]);
	  pool.in_code:=true; # don't add any new kernel here
	  # (which would mess up the numbering)
	  ImproveActionDegreeByBlocks(G,pool.ker[i],h);
	  pool.in_code:=false;
	fi;
      od;
      ise:=List(ise,i->GetNaturalHomomorphismsPool(G,pool.ker[i]));
      h:=CallFuncList(DirectProduct,List(ise,Image));
      emb:=List([1..Length(ise)],i->Embedding(h,i));
      emb:=List(GeneratorsOfGroup(G),
	   i->Product([1..Length(ise)],j->Image(emb[j],Image(ise[j],i))));
      ise:=SubgroupNC(h,emb);

      h:=GroupHomomorphismByImagesNC(G,ise,GeneratorsOfGroup(G),emb);
      SetKernelOfMultiplicativeGeneralMapping(h,N);
      pool.ops[p]:=h;
    elif IsGroup(h) then
      h:=FactorCosetAction(G,h,N); # will implicitely store
    fi;
    p:=h;
  fi;
  return p;
end);


#############################################################################
##
#F  DegreeNaturalHomomorphismsPool(G,N) degree for operation for G/N if known
##
InstallGlobalFunction(DegreeNaturalHomomorphismsPool,function(G,N)
local p,pool;
  pool:=NaturalHomomorphismsPool(G);
  p:=First([1..Length(pool.ker)],i->IsIdenticalObj(pool.ker[i],N));
  if p=fail then
    p:=PositionSet(pool.ker,N);
  fi;
  if p<>fail then
    p:=pool.cost[p];
  fi;
  return p;
end);


#############################################################################
##
#F  CloseNaturalHomomorphismsPool(<G>[,<N>]) . . calc intersections of known
##         operation kernels, don't continue anything which is smaller than N
##
InstallGlobalFunction(CloseNaturalHomomorphismsPool,function(arg)
local G,pool,p,comb,i,c,perm,l,isi,N,discard,ab;
  G:=arg[1];
  pool:=NaturalHomomorphismsPool(G);
  p:=[1..Length(pool.ker)];

  if Length(arg)>1 then
    N:=arg[2];
    p:=Filtered(p,i->IsSubset(pool.ker[i],N));
  else
    N:=fail;
  fi;

  # do the abelians extra.
  p:=Filtered(p,x->not HasAbelianFactorGroup(G,pool.ker[x]));
  
  discard:=[];
  repeat
    # obviously it is sufficient to consider only pairs iteratively
    p:=Set(p);
    comb:=Combinations(p,2);
    comb:=Filtered(comb,i->not (i in pool.intersects or i in discard));
    l:=Length(pool.ker);
    Info(InfoFactor,2,"CloseNaturalHomomorphismsPool: ",Length(comb));
    for i in comb do
      Info(InfoFactor,3,"Intersect ",i,": ",
           Size(pool.ker[i[1]]),Size(pool.ker[i[2]]));
      if N=fail or not ForAny(pool.ker{p},j->Size(j)>Size(N) and
	      IsSubset(pool.ker[i[1]],j) and IsSubset(pool.ker[i[2]],j)) then
	c:=Intersection(pool.ker[i[1]],pool.ker[i[2]]);
	Info(InfoFactor,3,"yields ",Size(c));
	isi:=ShallowCopy(i);

	# unpack 'iterated' lists
	if IsList(pool.ops[i[2]]) and IsInt(pool.ops[i[2]][1]) then
	  isi:=Concatenation(isi{[1]},pool.ops[i[2]]);
	fi;
	if IsList(pool.ops[i[1]]) and IsInt(pool.ops[i[1]][1]) then
	  isi:=Concatenation(isi{[2..Length(isi)]},pool.ops[i[1]]);
	fi;
	isi:=Set(isi);

	perm:=AddNaturalHomomorphismsPool(G,c,isi,Sum(pool.cost{i}));
	if perm<>fail then
	  # note that we got the intersections
	  if perm<>false then
	    AddSet(pool.intersects,List(i,j->j^perm));
	  else
	    AddSet(pool.intersects,i);
	  fi;
	fi;

	# note index shifts
	if IsPerm(perm) then
	  p:=List(p,i->i^perm);
	  Apply(comb,j->OnSets(j,perm));
	fi;

	if Length(arg)=1 or IsSubgroup(c,arg[2]) then
	  AddSet(p,
	    PositionSet(pool.ker,c)); # to allow iterated intersections
	fi;
      else
	Add(discard,i);
	Info(InfoFactor,4," not done");
      fi;
    od;
  until Length(comb)=0; # nothing new was added
  
end);


#############################################################################
##
#F  FactorCosetAction( <G>, <U>, [<N>] )  operation on the right cosets Ug
##                                        with possibility to indicate kernel
##
BindGlobal("DoFactorCosetAction",function(arg)
local G,u,op,h,N,rt;
  G:=arg[1];
  u:=arg[2];
  if Length(arg)>2 then
    N:=arg[3];
  else
    N:=false;
  fi;
  if IsList(u) and Length(u)=0 then
    u:=G;
    Error("only trivial operation ?  I Set u:=G;");
  fi;
  if N=false then
    N:=Core(G,u);
  fi;
  rt:=RightTransversal(G,u);
  if not IsRightTransversalRep(rt) then
    # the right transversal has no special `PositionCanonical' method.
    rt:=List(rt,i->RightCoset(u,i));
  fi;
  h:=ActionHomomorphism(G,rt,OnRight,"surjective");
  op:=Image(h,G);
  SetSize(op,Index(G,N));

  # and note our knowledge
  SetKernelOfMultiplicativeGeneralMapping(h,N);
  AddNaturalHomomorphismsPool(G,N,h);
  return h;
end);

InstallMethod(FactorCosetAction,"by right transversal operation",
  IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,U)
  return DoFactorCosetAction(G,U);
end);

InstallOtherMethod(FactorCosetAction,
  "by right transversal operation, given kernel",IsFamFamFam,
  [IsGroup,IsGroup,IsGroup],0,
function(G,U,N)
  return DoFactorCosetAction(G,U,N);
end);

InstallMethod(FactorCosetAction,"by right transversal operation, Niceo",
  IsIdenticalObj,[IsGroup and IsHandledByNiceMonomorphism,IsGroup],0,
function(G,U)
local hom;
  hom:=RestrictedNiceMonomorphism(NiceMonomorphism(G),G);
  return hom*DoFactorCosetAction(Image(hom,G),Image(hom,U));
end);

InstallOtherMethod(FactorCosetAction,
  "by right transversal operation, given kernel, Niceo",IsFamFamFam,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup,IsGroup],0,
function(G,U,N)
local hom;
  hom:=RestrictedNiceMonomorphism(NiceMonomorphism(G),G);
  return hom*DoFactorCosetAction(Image(hom,G),Image(hom,U),Image(hom,N));
end);


#############################################################################
##
#M  DoCheapActionImages(G) . . . . . . . . . . All cheap operations for G
##
InstallMethod(DoCheapActionImages,"generic",true,[IsGroup],0,Ignore);

InstallMethod(DoCheapActionImages,"permutation",true,[IsPermGroup],0,
function(G)
local pool, dom, o, bl, op, Go, j, b, i,allb,newb,mov;

  pool:=NaturalHomomorphismsPool(G);
  if pool.GopDone=false then

    dom:=MovedPoints(G);
    # orbits
    o:=OrbitsDomain(G,dom);
    o:=Set(List(o,Set));

    # do orbits and test for blocks 
    bl:=[];
    for i in o do
      if Length(i)<>Length(dom) or
	# only works if domain are the first n points
	not (1 in dom and 2 in dom and IsRange(dom)) then
	op:=ActionHomomorphism(G,i,"surjective");
	Range(op:onlyimage); #`onlyimage' forces same generators 
        AddNaturalHomomorphismsPool(G,Stabilizer(G,i,OnTuples),
			    op,Length(i));
      else
	op:=IdentityMapping(G);
      fi;

      Go:=Image(op,G);
      # all minimal and maximal blocks
      mov:=MovedPoints(Go);
      allb:=ShallowCopy(RepresentativesMinimalBlocks(Go,mov));
      for j in allb do
	b:=Orbit(G,i{j},OnSets);
	Add(bl,Immutable(Set(b)));
	# also one finer blocks (as we iterate only once)
	newb:=Blocks(Go,Blocks(Go,mov,j),OnSets);
	if Length(newb)>1 then
	  newb:=Union(newb[1]);
	  if not newb in allb then
	    Add(allb,newb);
	  fi;
	fi;
      od;

      #if Length(i)<500 and Size(Go)>10*Length(i) then
      #else
#	# one block system
#	b:=Blocks(G,i);
#	if Length(b)>1 then
#	  Add(bl,Immutable(Set(b)));
#	fi;
#      fi;
    od;

    for i in bl do
      op:=ActionHomomorphism(G,i,OnSets,"surjective");
      ImagesSource(op:onlyimage); #`onlyimage' forces same generators 
      b:=KernelOfMultiplicativeGeneralMapping(op);
      AddNaturalHomomorphismsPool(G,b,op);
    od;

    pool.GopDone:=true;
  fi;

end);


#############################################################################
##
#F  GenericFindActionKernel  random search for subgroup with faithful core
##
BADINDEX:=1000; # the index that is too big
GenericFindActionKernel:=function(arg)
local G, N, knowi, goodi, simple, uc, zen, cnt, pool, ise, v, bv, badi,
totalcnt, interupt, u, nu, cor, zzz,bigperm,perm,badcores;

  G:=arg[1];
  N:=arg[2];
  if Length(arg)>2 then
    knowi:=arg[3];
  else
    knowi:=Index(G,N);
  fi;

  # special treatment for solvable groups. This will never be triggered for
  # perm groups or nice groups
  if Size(N)>1 and HasSolvableFactorGroup(G,N) then
    perm:=ActionHomomorphism(G,RightCosets(G,N),OnRight,"surjective");
    perm:=perm*IsomorphismPcGroup(Image(perm));
    return perm;
  fi;

  # special treatment for abelian factor
  if HasAbelianFactorGroup(G,N) then
    if IsPermGroup(G) and Size(N)=1 then
      return IdentityMapping(G);
    else
      perm:=ActionHomomorphism(G,RightCosets(G,N),OnRight,"surjective");
    fi;
    return perm;
  fi;

  bigperm:=IsPermGroup(G) and NrMovedPoints(G)>10000;

  # what is a good degree:
  goodi:=Minimum(Int(knowi*9/10),LogInt(Index(G,N),2)^2);

  simple:=HasIsSimpleGroup(G) and IsSimpleGroup(G) and Size(N)=2;
  uc:=TrivialSubgroup(G);
  # look if it is worth to look at action on N
  # if not abelian: later replace by abelian Normal subgroup
  if IsAbelian(N) and (Size(N)>50 or Index(G,N)<Factorial(Size(N)))
      and Size(N)<50000 then
    zen:=Centralizer(G,N);
    if Size(zen)=Size(N) then
      cnt:=0;
      repeat
	cnt:=cnt+1;
	zen:=Centralizer(G,Random(N));
	if (simple or Size(Core(G,zen))=Size(N)) and
	    Index(G,zen)<Index(G,uc) then
	  uc:=zen;
	fi;
      # until enough searched or just one orbit
      until cnt=9 or (Index(G,zen)+1=Size(N));
      AddNaturalHomomorphismsPool(G,N,uc,Index(G,uc));
    else
      Info(InfoFactor,3,"centralizer too big");
    fi;
  fi;

  pool:=NaturalHomomorphismsPool(G);
  pool.dotriv:=true;
  CloseNaturalHomomorphismsPool(G,N);
  pool.dotriv:=false;
  ise:=Filtered(pool.ker,x->IsSubset(x,N));
  if Length(ise)=0 then
    ise:=G;
  else
    ise:=Intersection(ise);
  fi;

  # try a random extension step
  # (We might always first add a random element and get something bigger)
  v:=N;
  bv:=v;

  #if Length(arg)=3 then
    ## in one example 512->90, ca. 40 tries
    #cnt:=Int(arg[3]/10);
  #else
    #cnt:=25;
  #fi;

  badcores:=[];
  badi:=BADINDEX;
  totalcnt:=0;
  interupt:=false;
  cnt:=20;
  repeat
    u:=v;
    repeat
      repeat
	if Length(arg)<4 or Random([1,2])=1 then
	  if IsCyclic(u) and Random([1..4])=1 then
	    # avoid being stuck with a bad first element
	    u:=Subgroup(G,[Random(G)]);
	  fi;
	  if Length(GeneratorsOfGroup(u))<2 then
	    # closing might cost a big stabilizer chain calculation -- just
	    # recreate
	    nu:=Group(Concatenation(GeneratorsOfGroup(u),[Random(G)]));
	  else
	    nu:=ClosureGroup(u,Random(G));
	  fi;
	else
	  if Length(GeneratorsOfGroup(u))<2 then
	    # closing might cost a big stabilizer chain calculation -- just
	    # recreate
	    nu:=Group(Concatenation(GeneratorsOfGroup(u),[Random(arg[4])]));
	  else
	    nu:=ClosureGroup(u,Random(arg[4]));
	  fi;
	fi;
	totalcnt:=totalcnt+1;
	if KnownNaturalHomomorphismsPool(G,N) and
	  Minimum(Index(G,v),knowi)<20000 
	     and 5*totalcnt>Minimum(Index(G,v),knowi,1000) then
	  # interupt if we're already quite good
	  interupt:=true;
	fi;
	# Abbruchkriterium: Bis kein Normalteiler, es sei denn, es ist N selber
	# (das brauchen wir, um in einigen trivialen F"allen abbrechen zu
	# k"onnen)
#Print("nu=",Length(GeneratorsOfGroup(nu))," : ",Size(nu),"\n");
      until 
        
        # der Index ist nicht so klein, da"s wir keine Chance haben
	not ForAny(badcores,x->IsSubset(nu,x)) and (((not bigperm or
	Length(Orbit(nu,MovedPoints(G)[1]))<NrMovedPoints(G)) and 
	(Index(G,nu)>50 or Factorial(Index(G,nu))>=Index(G,N)) and
	not IsNormal(G,nu)) or IsSubset(u,nu) or interupt);

      Info(InfoFactor,4,"Index ",Index(G,nu));
      u:=nu;

    until 
      # und die Gruppe ist nicht zuviel schlechter als der
      # beste bekannte Index. Daf"ur brauchen wir aber wom"oglich mehrfache
      # Erweiterungen.
      interupt or (((Length(arg)=2 or Index(G,u)<knowi)));

    if Index(G,u)<knowi then

      #Print("Index:",Index(G,u),"\n");    

      if simple and u<>G then
	cor:=TrivialSubgroup(G);
      else
	cor:=Core(G,u);
      fi;
      if Size(cor)>Size(N) and IsSubset(cor,N) and not cor in badcores then
	Add(badcores,cor);
      fi;
      # store known information(we do't act, just store the subgroup.
      # Thus this is fairly cheap
      pool.dotriv:=true;
      zzz:=AddNaturalHomomorphismsPool(G,cor,u,Index(G,u));

      if IsPerm(zzz) and zzz<>() then
	CloseNaturalHomomorphismsPool(G,N);
      fi;
      pool.dotriv:=false;

      zzz:=DegreeNaturalHomomorphismsPool(G,N);

      Info(InfoFactor,3,"  ext ",cnt,": ",Index(G,u)," best degree:",zzz);
    else
      zzz:=DegreeNaturalHomomorphismsPool(G,N);
    fi;
    if IsInt(zzz) then
      knowi:=zzz;
    fi;

    cnt:=cnt-1;

    if cnt=0 and zzz>badi then
      Info(InfoWarning,2,"index unreasonably large, iterating");
      badi:=Int(badi*12/10);
      cnt:=20;
      v:=N; # all new
    fi;
  until interupt or cnt<=0 or zzz<=goodi;
#Print(goodi," vs ",badi,"\n");

  return GetNaturalHomomorphismsPool(G,N);

end;

#############################################################################
##
#F  SmallerDegreePermutationRepresentation( <G> )
##
InstallGlobalFunction(SmallerDegreePermutationRepresentation,function(G)
local o, s, k, gut, erg, H, hom, b, ihom, improve, map, loop,
  i,cheap,first;
  cheap:=ValueOption("cheap");
  if cheap="skip" then
    return IdentityMapping(G);
  fi;

  cheap:=cheap=true;

  # deal with large abelian cases first (which could be direct)
  hom:=MaximalAbelianQuotient(G);
  i:=IndependentGeneratorsOfAbelianGroup(Image(hom));
  o:=List(i,Order);
  if ValueOption("norecurse")<>true and 
    Product(o)>20 and Sum(o)*4<NrMovedPoints(G) then
    Info(InfoFactor,2,"append abelian rep");
    s:=AbelianGroup(IsPermGroup,o);
    ihom:=GroupHomomorphismByImagesNC(Image(hom),s,i,GeneratorsOfGroup(s));
    erg:=SubdirectDiagonalPerms(
	  List(GeneratorsOfGroup(G),x->Image(ihom,Image(hom,x))),
	  GeneratorsOfGroup(G));
    k:=Group(erg);SetSize(k,Size(G));
    hom:=GroupHomomorphismByImagesNC(G,k,GeneratorsOfGroup(G),erg);
    return hom*SmallerDegreePermutationRepresentation(k:norecurse);
  fi;


  if not IsTransitive(G,MovedPoints(G)) then
    o:=ShallowCopy(OrbitsDomain(G,MovedPoints(G)));
    Sort(o,function(a,b)return Length(a)<Length(b);end);

    for loop in [1..2] do
      s:=[];
      # Try subdirect product
      k:=G;
      gut:=[];
      for i in [1..Length(o)] do
	s:=Stabilizer(k,o[i],OnTuples);
	if Size(s)<Size(k) then
	  k:=s;
	  Add(gut,i);
	fi;
      od;
      # reduce each orbit separately
      o:=o{gut};
      # second run: now take the big orbits first
      Sort(o,function(a,b)return Length(a)>Length(b);end);
    od;

    erg:=List(GeneratorsOfGroup(G),i->());
    for i in [1..Length(o)] do
      Info(InfoFactor,1,"Try to shorten orbit ",i," Length ",Length(o[i]));
      s:=ActionHomomorphism(G,o[i],OnPoints,"surjective");
      Range(s);
      s:=s*SmallerDegreePermutationRepresentation(Image(s));
      erg:=SubdirectDiagonalPerms(erg,List(GeneratorsOfGroup(G),i->Image(s,i)));
    od;
    if NrMovedPoints(erg)<NrMovedPoints(G) then
      s:=Group(erg,());  # `erg' arose from `SubdirectDiagonalPerms'
      SetSize(s,Size(G));
      s:=GroupHomomorphismByImagesNC(G,s,GeneratorsOfGroup(G),erg);
      SetIsBijective(s,true);
      return s;
    fi;
    return IdentityMapping(G);
  # simple test is comparatively cheap for permgrp
  elif IsSimpleGroup(G) and not IsAbelian(G) then 
    H:=SimpleGroup(ClassicalIsomorphismTypeFiniteSimpleGroup(G));
    if IsPermGroup(H) and NrMovedPoints(H)>=NrMovedPoints(G) then
      return IdentityMapping(G);
    fi;
  fi; # transitive/simple treatment

  # if the original group has no stabchain we probably do not want to keep
  # it (or a homomorphisms pool) there -- make a copy for working
  # intermediately with it.
  if not HasStabChainMutable(G) then
    H:= GroupWithGenerators( GeneratorsOfGroup( G ),One(G) );
    if HasSize(G) then
      SetSize(H,Size(G));
    fi;
    if HasBaseOfGroup(G) then
      SetBaseOfGroup(H,BaseOfGroup(G));
    fi;
  else
    H:=G;
  fi;
  hom:=IdentityMapping(H);
  b:=NaturalHomomorphismsPool(H);
  b.dotriv:=true;
  AddNaturalHomomorphismsPool(H,TrivialSubgroup(H),hom,NrMovedPoints(H));
  b.dotriv:=false;
  ihom:=H;
  improve:=false; # indicator for first run
  first:=true;
  repeat
    if improve=false and NrMovedPoints(H)*5>Size(H) and
      IsTransitive(H,MovedPoints(H)) then
      b:=Blocks(H,MovedPoints(H));
      map:=ActionHomomorphism(G,b,OnSets,"surjective");
      ImagesSource(map:onlyimage); #`onlyimage' forces same generators 
      b:=KernelOfMultiplicativeGeneralMapping(map);
      AddNaturalHomomorphismsPool(G,b,map);
      if Size(b)=1 then
	H:=Image(map);
	Info(InfoFactor,2," first improved to degree ",NrMovedPoints(H));
	hom:=hom*map;
	ihom:=H;
      fi;
    fi;
    improve:=false;
    b:=NaturalHomomorphismsPool(H);
    b.dotriv:=true;
    if first then # only once!
      b.GopDone:=false;
      DoCheapActionImages(H);
      CloseNaturalHomomorphismsPool(H,TrivialSubgroup(H));
      first:=false;
    fi;
    b.dotriv:=false;
    map:=GetNaturalHomomorphismsPool(H,TrivialSubgroup(H));
    if map<>fail and Image(map)<>H then
      improve:=true;
      H:=Image(map);
      Info(InfoFactor,2," improved to degree ",NrMovedPoints(H));
      hom:=hom*map;
      ihom:=H;
    fi;
  until improve=false;

  o:=DegreeNaturalHomomorphismsPool(H,TrivialSubgroup(H));
  if cheap<>true and (IsBool(o) or o*2>=NrMovedPoints(H)) then
    s:=GenericFindActionKernel(ihom,TrivialSubgroup(ihom),NrMovedPoints(ihom));
    if s<>fail then
      hom:=hom*s;
    fi;
  fi;

  return hom;
end);

#############################################################################
##
#F  ImproveActionDegreeByBlocks( <G>, <N> , hom )
##  extension of <U> in <G> such that   \bigcap U^g=N remains valid
##
InstallGlobalFunction(ImproveActionDegreeByBlocks,function(G,N,oh)
local gimg,img,dom,b,improve,bp,bb,i,k,bestdeg,subo,op,bc,bestblock,bdom,
      bestop,sto,gimgbas,subomax;
  Info(InfoFactor,1,"try to find block systems");

  # remember that we computed the blocks
  b:=NaturalHomomorphismsPool(G);

  # special case to use it for improving a permutation representation
  if Size(N)=1 then
    Info(InfoFactor,1,"special case for trivial subgroup");
    b.ker:=[N];
    b.ops:=[oh];
    b.cost:=[Length(MovedPoints(Range(oh)))];
    b.lock:=[false];
    b.blocksdone:=[false];
    subomax:=20;
  else
    subomax:=500;
  fi;

  i:=PositionSet(b.ker,N);
  if b.blocksdone[i] then
    return DegreeNaturalHomomorphismsPool(G,N); # we have done it already
  fi;
  b.blocksdone[i]:=true;

  if not IsPermGroup(Range(oh)) then
    return 1;
  fi;

  gimg:=Image(oh,G);
  gimgbas:=false;
  if HasBaseOfGroup(gimg) then
    gimgbas:=Filtered(BaseOfGroup(gimg),i->ForAny(GeneratorsOfGroup(gimg),
                                           j->i^j<>i));
  fi;
  img:=gimg;
  dom:=MovedPoints(img);
  bdom:=fail;

  if IsTransitive(img,dom) then
    # one orbit: Blocks
    repeat
      b:=Blocks(img,dom);
      improve:=false;
      if Length(b)>1 then
	if Length(dom)<40000 then
	  subo:=ApproximateSuborbitsStabilizerPermGroup(img,dom[1]);
	  subo:=Difference(List(subo,i->i[1]),dom{[1]});
	else
	  subo:=fail;
	fi;
	bc:=First(b,i->dom[1] in i);
	if subo<>fail and (Length(subo)<=subomax) then
	  Info(InfoFactor,2,"try all seeds");
	  # if the degree is not too big or if we are desparate then go for
	  # all blocks
	  # greedy approach: take always locally best one (otherwise there
	  # might be too much work to do)
	  bestdeg:=Length(dom);
	  bp:=[]; #Blocks pool
	  i:=1;
	  while i<=Length(subo) do
	    if subo[i] in bc then
	      bb:=b;
	    else
	      bb:=Blocks(img,dom,[dom[1],subo[i]]);
	    fi;
	    if Length(bb)>1 and not (bb[1] in bp or Length(bb)>bestdeg) then
	      Info(InfoFactor,3,"found block system ",Length(bb));
	      # new nontriv. system found 
	      AddSet(bp,bb[1]);
	      # store action
	      op:=1;# remove old homomorphism to free memory
	      if bdom<>fail then
	        bb:=Set(List(bb,i->Immutable(Union(bdom{i}))));
	      fi;

	      op:=ActionHomomorphism(gimg,bb,OnSets,"surjective");
	      if HasSize(gimg) and not HasStabChainMutable(gimg) then
		sto:=StabChainOptions(Range(op));
		sto.limit:=Size(gimg);
		# try only with random (will exclude some chances, but is
		# quicker. If the size is OK we have a proof anyhow).
		sto.random:=100;
#		if gimgbas<>false then
#		  SetBaseOfGroup(Range(op),
#		    List(gimgbas,i->PositionProperty(bb,j->i in j)));
#		fi;
		if Size(Range(op))=Size(gimg) then
		  sto.random:=1000;
		  k:=TrivialSubgroup(gimg);
		  op:=oh*op;
		  SetKernelOfMultiplicativeGeneralMapping(op,PreImage(oh,k));
		  AddNaturalHomomorphismsPool(G,
		      KernelOfMultiplicativeGeneralMapping(op),
					      op,Length(bb));
		else
		  k:=[]; # do not trigger improvement
		fi;
	      else
		k:=KernelOfMultiplicativeGeneralMapping(op);
		SetSize(Range(op),Index(gimg,k));
		op:=oh*op;
		SetKernelOfMultiplicativeGeneralMapping(op,PreImage(oh,k));
		AddNaturalHomomorphismsPool(G,
		    KernelOfMultiplicativeGeneralMapping(op),
					    op,Length(bb));

	      fi;
	      # and note whether we got better
	      #improve:=improve or (Size(k)=1);
	      if Size(k)=1 and Length(bb)<bestdeg then
		improve:=true;
		bestdeg:=Length(bb);
		bestblock:=bb;
		bestop:=op;
	      fi;
	    fi;
	    # break the test loop if we found a fairly small block system
	    # (iterate greedily immediately)
	    if improve and bestdeg<i then
	      i:=Length(dom);
	    fi;
	    i:=i+1;
	  od;
	else
	  Info(InfoFactor,2,"try only one system");
	  op:=1;# remove old homomorphism to free memory
	  if bdom<>fail then
	    b:=Set(List(b,i->Immutable(Union(bdom{i}))));
	  fi;
	  op:=ActionHomomorphism(gimg,b,OnSets,"surjective");
	  if HasSize(gimg) and not HasStabChainMutable(gimg) then
	    sto:=StabChainOptions(Range(op));
	    sto.limit:=Size(gimg);
	    # try only with random (will exclude some chances, but is
	    # quicker. If the size is OK we have a proof anyhow).
	    sto.random:=100;
#	    if gimgbas<>false then
#	      SetBaseOfGroup(Range(op),
#	         List(gimgbas,i->PositionProperty(b,j->i in j)));
#	    fi;
	    if Size(Range(op))=Size(gimg) then
	      sto.random:=1000;
	      k:=TrivialSubgroup(gimg);
	      op:=oh*op;
	      SetKernelOfMultiplicativeGeneralMapping(op,PreImage(oh,k));
	      AddNaturalHomomorphismsPool(G,
		  KernelOfMultiplicativeGeneralMapping(op),
					  op,Length(b));
	    else
	      k:=[]; # do not trigger improvement
	    fi;
	  else
	    k:=KernelOfMultiplicativeGeneralMapping(op);
	    SetSize(Range(op),Index(gimg,k));
	    # keep action knowledge
	    op:=oh*op;
	    SetKernelOfMultiplicativeGeneralMapping(op,PreImage(oh,k));
	    AddNaturalHomomorphismsPool(G,
		KernelOfMultiplicativeGeneralMapping(op),
					op,Length(b));
	  fi;

	  if Size(k)=1 then
	    improve:=true;
	    bestblock:=b;
	    bestop:=op;
	  fi;
	fi;
	if improve then
	  # update mapping
	  bdom:=bestblock;
	  img:=Image(bestop,G);
	  dom:=MovedPoints(img);
	fi;
      fi;
    until improve=false;
  fi;
  Info(InfoFactor,1,"end of blocks search");
  return DegreeNaturalHomomorphismsPool(G,N);
end);

#############################################################################
##
#M  FindActionKernel(<G>)  . . . . . . . . . . . . . . . . . . . . generic
##
InstallMethod(FindActionKernel,"generic for finite groups",IsIdenticalObj,
  [IsGroup and IsFinite,IsGroup],0,
function(G,N)
  return GenericFindActionKernel(G,N);
end);

InstallMethod(FindActionKernel,"general case: can't do",IsIdenticalObj,
  [IsGroup,IsGroup],0,
function(G,N)
  return fail;
end);


#############################################################################
##
#M  FindActionKernel(<G>)  . . . . . . . . . . . . . . . . . . . . permgrp
##
InstallMethod(FindActionKernel,"perm",IsIdenticalObj,
  [IsPermGroup,IsPermGroup],0,
function(G,N)
local pool, dom, bestdeg, blocksdone, o, s, badnormals, cnt, v, u, oo, m,
      badcomb, idx, i, comb;

  if Index(G,N)<50 then
    # small index, anything is OK
    return GenericFindActionKernel(G,N);
  else
    # get the known ones, including blocks &c. which might be of use
    DoCheapActionImages(G);

    pool:=NaturalHomomorphismsPool(G);
    dom:=MovedPoints(G);

    # store regular to have one anyway
    bestdeg:=Index(G,N);
    AddNaturalHomomorphismsPool(G,N,N,bestdeg);

    # check if there are multiple orbits
    o:=Orbits(G,MovedPoints(G));
    s:=List(o,i->Stabilizer(G,i,OnTuples));
    if not ForAny(s,i->IsSubset(N,i)) then
      Info(InfoFactor,2,"Try reduction to orbits");
      s:=List(s,i->ClosureGroup(i,N));
      if Intersection(s)=N then
	Info(InfoFactor,1,"Reduction to orbits will do");
	List(s,i->NaturalHomomorphismByNormalSubgroup(G,i));
      fi;
    fi;
    CloseNaturalHomomorphismsPool(G,N);

    bestdeg:=DegreeNaturalHomomorphismsPool(G,N);

    Info(InfoFactor,1,"Orbits and known, best Index ",bestdeg);

    blocksdone:=false;
    # use subgroup that fixes a base of N
    # get orbits of a suitable stabilizer.
    o:=BaseOfGroup(N);
    s:=Stabilizer(G,o,OnTuples);
    badnormals:=Filtered(pool.ker,i->IsSubset(i,N) and Size(i)>Size(N));
    if Size(s)>1 and Index(G,s)/Size(N)<2000 and bestdeg>Index(G,s) then
      cnt:=Filtered(OrbitsDomain(s,dom),i->Length(i)>1);
      for i in cnt do
	v:=ClosureGroup(N,Stabilizer(s,i[1]));
	if Size(v)>Size(N) and Index(G,v)<2000 
	  and not ForAny(badnormals,j->IsSubset(v,j)) then
	  u:=Core(G,v);
	  if Size(u)>Size(N) and IsSubset(u,N) and not u in badnormals then
	    Add(badnormals,u);
	  fi;
	  AddNaturalHomomorphismsPool(G,u,v,Index(G,v));
	fi;
      od;

      # try also intersections
      CloseNaturalHomomorphismsPool(G,N);

      bestdeg:=DegreeNaturalHomomorphismsPool(G,N);

      Info(InfoFactor,1,"Base Stabilizer and known, best Index ",bestdeg);

      if bestdeg<500 and bestdeg<Index(G,N) then
	# should be better...
	bestdeg:=ImproveActionDegreeByBlocks(G,N,
	  GetNaturalHomomorphismsPool(G,N));
	blocksdone:=true;
	Info(InfoFactor,2,"Blocks improve to ",bestdeg);
      fi;
    fi;

    # then we should look at the orbits of the normal subgroup to see,
    # whether anything stabilizing can be of use
    o:=Filtered(OrbitsDomain(N,dom),i->Length(Orbit(G,i[1]))>Length(i));
    Apply(o,Set);
    oo:=OrbitsDomain(G,o,OnSets);
    s:=G;
    for i in oo do
      s:=StabilizerOfBlockNC(s,i[1]);
    od;
    Info(InfoFactor,2,"stabilizer of index ",Index(G,s));

    if not ForAny(badnormals,j->IsSubset(s,j)) then
      m:=Core(G,s); # the normal subgroup we get this way.
      if Size(m)>Size(N) and IsSubset(m,N) and not m in badnormals then
	Add(badnormals,m);
      fi;
      AddNaturalHomomorphismsPool(G,m,s,Index(G,s));
    else
      m:=G; # guaranteed fail
    fi;

    if Size(m)=Size(N) and Index(G,s)<bestdeg then
      bestdeg:=Index(G,s);
      blocksdone:=false;
      Info(InfoFactor,2,"Orbits Stabilizer improves to index ",bestdeg);
    elif Size(m)>Size(N) then
      # no hard work for trivial cases
      if 2*Index(G,N)>Length(o) then
	# try to find a subgroup, which does not contain any part of m
	# For wreath products (the initial aim), the following method works
	# fairly well
	v:=Subgroup(G,Filtered(GeneratorsOfGroup(G),i->not i in m));
	v:=SmallGeneratingSet(v);

	cnt:=1;
	badcomb:=[];
	repeat
	  Info(InfoFactor,3,"Trying",cnt);
	  for comb in Combinations([1..Length(v)],cnt) do
    #Print(">",comb,"\n");
	    if not ForAny(badcomb,j->IsSubset(comb,j)) then
	      u:=SubgroupNC(G,v{comb});
	      o:=ClosureGroup(N,u);
	      idx:=Size(G)/Size(o);
	      if idx<10 and Factorial(idx)*Size(N)<Size(G) then
		# the permimage won't be sufficiently large
		AddSet(badcomb,Immutable(comb));
	      fi;
	      if idx<bestdeg and Size(G)>Size(o) 
	      and not ForAny(badnormals,i->IsSubset(o,i)) then
		m:=Core(G,o);
		if Size(m)>Size(N) and IsSubset(m,N) then
		  Info(InfoFactor,3,"Core ",comb," failed");
		  AddSet(badcomb,Immutable(comb));
		  if not m in badnormals then
		    Add(badnormals,m);
		  fi;
		fi;
		if idx<bestdeg and Size(m)=Size(N) then
		  Info(InfoFactor,3,"Core ",comb," succeeded");
		  bestdeg:=idx;
		  AddNaturalHomomorphismsPool(G,N,o,bestdeg);
		  blocksdone:=false;
		  cnt:=0;
		fi;
	      fi;
	    fi;
	  od;
	  cnt:=cnt+1;
	until cnt>Length(v);
      fi;
    fi;

    Info(InfoFactor,2,"Orbits Stabilizer, Best Index ",bestdeg);
    # first force blocks
    if (not blocksdone) and bestdeg<200 and bestdeg<Index(G,N) then
      Info(InfoFactor,3,"force blocks");
      bestdeg:=ImproveActionDegreeByBlocks(G,N,
	GetNaturalHomomorphismsPool(G,N));
      blocksdone:=true;
      Info(InfoFactor,2,"Blocks improve to ",bestdeg);
    fi;

    if bestdeg=Index(G,N) or 
      (bestdeg>400 and not(bestdeg<=2*NrMovedPoints(G))) then
      if GenericFindActionKernel(G,N,bestdeg,s)<>fail then
	blocksdone:=true;
      fi;
      Info(InfoFactor,1,"  Random search found ",
           DegreeNaturalHomomorphismsPool(G,N));
    #if (bestdeg>500 and Index(G,o)<5000) or Index(G,o)<bestdeg then
    #  # tell 'IODBB' not to doo too much blocksearch
    #  o:=ImproveActionDegreeByBlocks(G,o,N,bestdeg<Index(G,o));
    #  Info(InfoFactor,1,"  Blocks improve to ",Index(G,o),"\n");
    #fi;
    fi;

    if not blocksdone then
      ImproveActionDegreeByBlocks(G,N,GetNaturalHomomorphismsPool(G,N));
    fi;

    Info(InfoFactor,3,"return hom");
    return GetNaturalHomomorphismsPool(G,N);
    return o;
  fi;

end);

#############################################################################
##
#M  FindActionKernel(<G>)  . . . . . . . . . . . . . . . . . . . . generic
##
InstallMethod(FindActionKernel,"Niceo",IsIdenticalObj,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup],0,
function(G,N)
local hom,hom2;
  hom:=NiceMonomorphism(G);
  hom2:=GenericFindActionKernel(Image(hom,G),Image(hom,N));
  if hom2<>fail then
    return hom*hom2;
  else
    return hom;
  fi;
end);

BindGlobal("FACTGRP_TRIV",Group([],()));

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> )  . .  mapping G ->> G/N
##                             this function returns an epimorphism from G
##  with kernel N. The range of this mapping is a suitable (isomorphic) 
##  permutation group (with which we can compute much easier).
InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "search for operation",IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,N)
local h;

  # catch the trivial case N=G 
  if CanComputeIndex(G,N) and Index(G,N)=1 then
    h:=FACTGRP_TRIV;  # a new group is created
    h:=GroupHomomorphismByImagesNC( G, h, GeneratorsOfGroup( G ),
           List( GeneratorsOfGroup( G ), i -> () ));  # a new group is created
    SetKernelOfMultiplicativeGeneralMapping( h, G );
    return h;
  fi;
 
  # catch trivial case N=1 (IsTrivial might not be set)
  if (HasSize(N) and Size(N)=1) or (HasGeneratorsOfGroup(N) and
    ForAll(GeneratorsOfGroup(N),IsOne)) then
    return IdentityMapping(G);
  fi;

  # check, whether we already know a factormap
  DoCheapActionImages(G);
  h:=GetNaturalHomomorphismsPool(G,N);
  if h=fail and HasIsSolvableGroup(N) and HasIsSolvableGroup(G) and
    IsSolvableGroup(N) and not IsSolvableGroup(G) and HasRadicalGroup(G) 
    and N=RadicalGroup(G)
    then
    # did we just compute it?
    h:=GetNaturalHomomorphismsPool(G,N);
  fi;
  if h=fail then
    # now we try to find a suitable operation
    h:=FindActionKernel(G,N);
    if h<>fail then
      Info(InfoFactor,1,"Action of degree ",
	Length(MovedPoints(Range(h)))," found");
    else
      Error("I don't know how to find a natural homomorphism for <N> in <G>");
      # nothing had been found, Desperately one could try again, but that
      # would create a possible infinite loop.
      h:= NaturalHomomorphismByNormalSubgroup( G, N );
    fi;
  fi;
  # return the map
  return h;
end);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . .  for solvable factors
##
NH_TRYPCGS_LIMIT:=30000;
InstallMethod( NaturalHomomorphismByNormalSubgroupOp,
  "test if known/try solvable factor for permutation groups",
  IsIdenticalObj, [ IsPermGroup, IsPermGroup ], 0,
function( G, N )
local   map,  pcgs, A, filter,p,i;
    
  if KnownNaturalHomomorphismsPool(G,N) then
    A:=DegreeNaturalHomomorphismsPool(G,N);
    if A<50 or (IsInt(A) and A<IndexNC(G,N)/LogInt(IndexNC(G,N),2)^2) then
      map:=GetNaturalHomomorphismsPool(G,N);
      if map<>fail then
	Info(InfoFactor,2,"use stored map");
	return map;
      fi;
    fi;
  fi;

  if Index(G,N)=1 or Size(N)=1
    or Minimum(Index(G,N),NrMovedPoints(G))>NH_TRYPCGS_LIMIT then
    TryNextMethod();
  fi;

  # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
  # routines).
  pcgs := TryPcgsPermGroup( [ G, N ], false, false, true );
  if not IsModuloPcgs( pcgs )  then
      TryNextMethod();
  fi;

  # Construct or look up the pcp group <A>.
  A:=CreateIsomorphicPcGroup(pcgs,false,false);

  UseFactorRelation( G, N, A );

  # Construct the epimorphism from <G> onto <A>.
  map := rec();
  filter := IsPermGroupGeneralMappingByImages and
            IsToPcGroupGeneralMappingByImages and
            IsGroupGeneralMappingByPcgs and
            IsMapping and IsSurjective and
            HasSource and HasRange and 
            HasPreImagesRange and HasImagesSource and
            HasKernelOfMultiplicativeGeneralMapping;

  map.sourcePcgs       := pcgs;
  map.sourcePcgsImages := GeneratorsOfGroup( A );

  ObjectifyWithAttributes( map,
  NewType( GeneralMappingsFamily
	  ( ElementsFamily( FamilyObj( G ) ),
	    ElementsFamily( FamilyObj( A ) ) ), filter ), 
	    Source,G,
	    Range,A,
	    PreImagesRange,G,
	    ImagesSource,A,
	    KernelOfMultiplicativeGeneralMapping,N
	    );
  
  return map;
end );

#############################################################################
##
#F  PullBackNaturalHomomorphismsPool( <hom> )
##
InstallGlobalFunction(PullBackNaturalHomomorphismsPool,function(hom)
local s,r,nat,k;
  s:=Source(hom);
  r:=Range(hom);
  for k in NaturalHomomorphismsPool(r).ker do
    nat:=hom*NaturalHomomorphismByNormalSubgroup(r,k);
    AddNaturalHomomorphismsPool(s,PreImage(hom,k),nat);
  od;
end);

#############################################################################
##
#M  UseFactorRelation( <num>, <den>, <fac> )  . . . .  for perm group factors
##
InstallMethod( UseFactorRelation,
   [ IsGroup and HasSize, IsObject, IsPermGroup ],
   function( num, den, fac )
   local limit;
   if not HasSize( fac ) then
     if HasSize(den) then
       SetSize( fac, Size( num ) / Size( den ) );
     else
       limit := Size( num );
       if IsBound( StabChainOptions(fac).limit ) then
         limit := Minimum( limit, StabChainOptions(fac).limit );
       fi;
       StabChainOptions(fac).limit:=limit;
     fi;
   fi;
   TryNextMethod();
   end );

#############################################################################
##
#E  factgrp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
