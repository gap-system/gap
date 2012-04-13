#############################################################################
##
#W  oprtglat.gi                GAP library                   Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This  file  contains methods for orbits on subgroups
##

#############################################################################
##
#M  GroupOnSubgroupsOrbit(G,H) . . . . . . . . . . . . . . orbit of H under G
##
InstallGlobalFunction( GroupOnSubgroupsOrbit, function(G,H)
  return Enumerator(ConjugacyClassSubgroups(G,H));
end );

#############################################################################
##
#M  MinimumGroupOnSubgroupsOrbit(G,H [,N_G(H)]) minimum of orbit of H under G
##
InstallGlobalFunction( MinimumGroupOnSubgroupsOrbit, function(arg)
local cont,lim,s,i,j,m,Hc,o,og;
  # try some orbit calculation first (at most orbit of length 20) to avoid
  # normalizer calculations.
  cont:=true;
  lim:=QuoInt(Size(arg[1]),Size(arg[2]));
  if lim>20 then
    cont:=lim<200000; # otherwise give up at once
    lim:=20;
  fi;

  if cont then
    o:=[arg[2]];
  else
    o:=[];
  fi;
  m:=arg[2];
  i:=1;
  while cont and i<=Length(o) do
    for j in GeneratorsOfGroup(arg[1]) do
      if not ForAny(o,x->ForAll(GeneratorsOfGroup(o[i]),y->y^j in x)) then
	Hc:=o[i]^j;
	Add(o,Hc);
	if Hc<m then
	  m:=Hc;
	fi;
	cont:=Length(o)<lim;
      fi;
    od;
    i:=i+1;
  od;

  if not cont then
    # orbit is longer -- have to work
    s:=ConjugacyClassSubgroups(arg[1],arg[2]);
    if Length(arg)>2 then
      SetStabilizerOfExternalSet(s,arg[3]);
    fi;
    s:=Enumerator(s);
    if Length(s)>2*lim then
      o:=[]; # the orbit is not worth keeping -- test would be too expensive
    fi;
    for i in [1..Length(s)] do
      Hc:=s[i];
      if not ForAny(o,x->ForAll(GeneratorsOfGroup(Hc),y-> y in x)) then
	if Hc<m then
	  m:=Hc;
	fi;
      fi;
    od;
  fi;
  return m;
end );

InstallMethod(SubgroupsOrbitsAndNormalizers,"generic on list",true,
  [IsGroup,IsList,IsBool],0,
function(G,dom,all)
local  n,l,o,b,r,p,cl,i,sel,selz,gens,ti,t,tl;

  n:=Length(dom);
  l:=n;
  o:=[];
  b:=BlistList([1..l],[1..n]);
  while n>0 do
    p:=Position(b,true);
    b[p]:=false;
    n:=n-1;
    r:=rec(representative:=dom[p],pos:=p);
    cl:=ConjugacyClassSubgroups(G,r.representative);
    gens:=GeneratorsOfGroup(r.representative);
    r.normalizer:=StabilizerOfExternalSet(cl);
    t:=RightTransversal(G,r.normalizer);
    tl:=Length(t);
    sel:=Filtered([1..l],i->b[i]);
    selz:=Filtered(sel,i->Size(dom[i])=Size(r.representative));
    if Length(selz)>0 then
      i:=1;
      while Length(sel)>0 and i<=tl do;
	ti:=t[i];
	p:=PositionProperty(sel,
			    j->j in selz and ForAll(gens,k->k^ti in dom[j]));
	if p<>fail then
	  p:=sel[p];
	  b[p]:=false;
	  n:=n-1;
	  RemoveSet(sel,p);
	fi;
	i:=i+1;
      od;
    fi;
    if all then
      cl:=Enumerator(cl);
      r.elements:=cl;
    fi;
    Add(o,r);
  od;
  return o;
end);

InstallMethod(SubgroupsOrbitsAndNormalizers,"perm group on list",true,
  [IsPermGroup,IsList,IsBool],0,
function(G,dom,all)
  local savemem, n, l, o, pts, pbas, ptbas, un, domo, p, b, allo, ll, gp, t,
  sel, r, i, gens, rorbs, tl, selz, fcnt, rem, sely, j, torbs, torb, iinv,
  ti, cl,lsd,domoj;

  if Length(dom)=0 then
    return dom;
  fi;
  savemem:=ValueOption("savemem");
  n:=Length(dom);
  l:=n;
  o:=[];
  # determine some points that distinguish groups
  pts:=MovedPoints(G);
  pbas:=[pts[1]];
  ptbas:=[pts[1]];
  un:=ShallowCopy(Orbit(dom[1],ptbas[1]));
  domo:=List(dom,x->[Set(Orbit(x,ptbas[1]))]);
  while Length(pbas)<15 and Length(un)<Length(pts) do
    p:=First(pts,x->not x in un);
    Add(ptbas,p);
    b:=Set(Orbit(dom[1],p));
    un:=Union(un,b);
    if ForAny([1..Length(dom)],x->Set(Orbit(dom[x],p))<>b 
      and ForAll([1..Length(pbas)],z->domo[x][z]=domo[1][z]))
       then
      Add(pbas,p);
      for i in [1..Length(dom)] do
	Add(domo[i],Set(Orbit(dom[i],p)));
      od;
    fi;
  od;
  allo:=Union(domo);
  MakeImmutable(allo);
  IsSSortedList(allo);
  domo:=List(domo,x->List(x,y->Position(allo,y)));
  lsd:=Length(Set(domo));
  Info(InfoLattice,5,Length(pbas)," out of ",Length(ptbas)," yields ",
       lsd," domo types");

  #domoj:=List([1..Length(pbas)],x->domo{[1..Length(domo)]}[x]);
  domoj:=List([1..Length(pbas)],x->List([1..Length(allo)],
	  y->Filtered([1..Length(dom)],z->domo[z][x]=y)));
              

  b:=BlistList([1..l],[1..n]);
  ll:=QuoInt(Size(G),Minimum(List(dom,Size)));
  while n>0 do
    p:=Position(b,true);
    b[p]:=false;
    n:=n-1;
    gp:=dom[p];
    t:=Length(GeneratorsOfGroup(gp));
    if HasSize(gp) and not HasStabChainMutable(gp) and t>4 then
      sel:=GeneratorsOfGroup(gp);
      t:=Group(sel{Set(List([1,2],i->Random([1..t])))},One(gp));
      while Size(t)<Size(gp) do
	t:=ClosureGroup(t,Random(sel));
      od;
      Info(InfoLattice,5,"reduced ",Length(sel)," -> ",
			  Length(GeneratorsOfGroup(t)));
      if IsBound(gp!.comgens) then
	t!.comgens:=gp!.comgens;
      fi;
      gp:=t;
    fi;
    r:=rec(representative:=gp,pos:=p);
    if ll<20 and IndexNC(G,gp)<10000 and lsd*20<Length(dom) then 
      t:=OrbitStabilizer(G,gp);
      ll:=Length(t.orbit);
      Info(InfoLattice,5,"orblen=",ll);
      r.normalizer:=t.stabilizer;
      if all then r.orbit:=t.orbit; fi;
      if IsIdenticalObj(t.orbit[1],gp) then
	t:=t.orbit{[2..Length(t.orbit)]};
	ll:=ll-1;
      else
	t:=ShallowCopy(t.orbit);
      fi;
      if Length(t)>0 and Length(t)*Size(t[1])<10000 and n>40000 then
	List(t,Elements); # faster in test
      fi;
      i:=1;
      while i<=Length(dom) and ll>0 do
	if b[i] and Size(dom[i])=Size(r.representative) then
	  p:=PositionProperty(t,j->ForAll(GeneratorsOfGroup(dom[i]),k->k in j));
	  if p<>fail then
	    b[i]:=false;
	    n:=n-1;
	    ll:=ll-1;
	    t:=t{Difference([1..Length(t)],[p])};
	  fi;
	fi;
	i:=i+1;
      od;
    else
      gens:=GeneratorsOfGroup(r.representative);
      r.normalizer:=Normalizer(G,r.representative);
      rorbs:=List(Orbits(r.representative,pts),i->Immutable(Set(i)));
      tl:=Index(G,r.normalizer);
      ll:=tl;
      Info(InfoLattice,5,"Normalizerindex=",tl);
      sel:=Filtered([1..l],i->b[i]);
      selz:=Filtered(sel,
	      i->not HasSize(dom[i]) or Size(dom[i])=Size(r.representative));
      if tl<=50*Length(selz) then
	t:=RightTransversal(G,r.normalizer);
	if Length(selz)>0 then
	  rem:=[];
	  for i in t do
	    sely:=selz;
	    j:=1;
	    while j<=Length(pbas) and Length(sely)>0 do
	      #torb:=Set(List(Orbit(r.representative,pbas[j]/i),x->x^i));
	      torb:=pbas[j]/i;
	      torb:=First(rorbs,x->torb in x);
	      torb:=Set(List(torb,x->x^i));
	      MakeImmutable(torb);
	      torb:=Position(allo,torb);
	      if torb=fail then
		sely:=[];
	      else
		sely:=Intersection(sely,domoj[j][torb]);
	      fi;
	      j:=j+1;
	    od;
	    if Length(sely)>0 then
	      iinv:=i^-1;
	      p:=First(sely,z->ForAll(GeneratorsOfGroup(dom[z]),
				  x->x^iinv in r.representative));
	      if p<>fail then
		AddSet(rem,p);
		b[p]:=false;
		n:=n-1;
	      fi;
	    fi;
	  od;

	  sel:=Difference(sel,rem);
	  selz:=Difference(selz,rem);

	fi;
      else
	for i in selz do
	  p:=RepresentativeAction(G,dom[i],r.representative,OnPoints);
	  if p<>fail then
	    b[i]:=false;
	    n:=n-1;
	    RemoveSet(sel,i);
	  fi;
	od;
      fi;
      if all then
	cl:=ConjugacyClassSubgroups(G,r.representative);
	SetStabilizerOfExternalSet(cl,r.normalizer);
	cl:=Enumerator(cl);
	r.elements:=cl;
      fi;
    fi;
    if not all and savemem<>fail then
      p:=Size(r.representative);
      r.representative:=Group(GeneratorsOfGroup(r.representative));
      SetSize(r.representative,p);
      p:=Size(r.normalizer);
      r.normalizer:=Group(GeneratorsOfGroup(r.normalizer));
      SetSize(r.normalizer,p);
    fi;
    Add(o,r);
  od;
  return o;
end);

InstallMethod(SubgroupsOrbitsAndNormalizers,"pc group on list",true,
  [IsPcGroup,IsList,IsBool],0,
function(G,dom,all)
local  n,l,o,b,r,p,cl,i,sel,selz,allcano,cano,can2,p1;

  allcano:=[];
  n:=Length(dom);
  l:=n;
  o:=[];
  b:=BlistList([1..l],[1..n]);
  while n>0 do
    p:=Position(b,true);
    p1:=p;
    b[p]:=false;
    n:=n-1;
    r:=rec(representative:=dom[p],pos:=p);

    sel:=Filtered([1..l],i->b[i]);
    selz:=Filtered(sel,i->Size(dom[i])=Size(r.representative));

    if Length(selz)>0 then

      if IsBound(allcano[p1]) then
	cano:=allcano[p1];
      else
	cano:=CanonicalSubgroupRepresentativePcGroup(G,r.representative);
      fi;
      r.normalizer:=ConjugateSubgroup(cano[2],cano[3]^-1);

      cano:=cano[1];

      for i in selz do
	if IsBound(allcano[i]) then
	  can2:=allcano[i];
	else
	  can2:=CanonicalSubgroupRepresentativePcGroup(G,dom[i]);
	fi;
	if can2[1]=cano then
	  b[i]:=false;
	  n:=n-1;
	  RemoveSet(sel,i);
	  Unbind(allcano[i]);
	else
	  allcano[i]:=can2;
	fi;
      od;
    else
      r.normalizer:=Normalizer(G,r.representative);
    fi;

    if all then
      cl:=ConjugacyClassSubgroups(G,r.representative);
      SetStabilizerOfExternalSet(cl,r.normalizer);
      r.elements:=Enumerator(cl);
    fi;

    Add(o,r);
    Unbind(allcano[p1]);
  od;
  return o;
end);

# destructive version
# this method takes the component 'list' from the record and shrinks the
# list to save memory
InstallMethod(SubgroupsOrbitsAndNormalizers,"generic on record with list",true,
  [IsGroup,IsRecord,IsBool],0,
function(G,r,all)
local  n,o,dom,cl,i,s,j,t,ti,tl,gens;

  dom:=r.list;
  Unbind(r.list);

  n:=Length(dom);
  o:=[];
  while n>0 do
    r:=rec(representative:=dom[1]);
    gens:=GeneratorsOfGroup(dom[1]);
    s:=Size(dom[1]);
    cl:=ConjugacyClassSubgroups(G,r.representative);
    r.normalizer:=StabilizerOfExternalSet(cl);
    cl:=Enumerator(cl);
    t:=RightTransversal(G,r.normalizer);
    tl:=Length(t);

    i:=1;
    while i<=tl and Length(dom)>0 do
      ti:=t[i];
      j:=2;
      while j<=Length(dom) do
	if Size(dom[j])=s and ForAll(gens,k->k^ti in dom[j]) then
	  # hit
	  dom[j]:=dom[Length(dom)];
	  Unbind(dom[Length(dom)]);
	else
	  j:=j+1;
	fi;
      od;
      i:=i+1;
    od;

    if all then
      r.elements:=cl;
    fi;
    Add(o,r);
  od;
  return o;
end);

#############################################################################
##
#M  StabilizerOp( <G>, <D>, <subgroup>, <U>, <V>, <OnPoints> )
##
##  subgroup stabilizer
InstallMethod( StabilizerOp, "with domain, use normalizer", true,
    [ IsGroup, IsList, IsGroup, IsList, IsList, IsFunction ], 
    # raise over special methods for pcgs et. al.
    200,
function( G, D, sub, U, V, op )
    if not U=V or op<>OnPoints then
      TryNextMethod();
    fi;
    return Normalizer(G,sub);
end );

InstallOtherMethod( StabilizerOp, "use normalizer", true,
    [ IsGroup, IsGroup, IsList, IsList, IsFunction ], 
    # raise over special methods for pcgs et. al.
    200,
function( G, sub, U, V, op )
    if not U=V or op<>OnPoints then
      TryNextMethod();
    fi;
    return Normalizer(G,sub);
end );

#############################################################################
##
#E  oprtglat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
