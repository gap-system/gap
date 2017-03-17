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
  ti, cl,lsd,domoj,startn;

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
    startn:=n;
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
Info(InfoLattice,5,startn-n," conjugates");
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

InstallGlobalFunction(PermPreConjtestGroups,function(G,l)
local pats,spats,lpats,result,pa,lp,dom,lens,h,orbs,p,rep,cln,allorbs,
      allco,panu,gpcl,i,j,k,Gm,a,corbs,orbun,dict,norb,m,ornums,sornums,
      ssornums,sel,sela,statra,lrep,gpcl2,je,lrep1,partimg,nobail,cnt,hpos;

  if not IsPermGroup(G) then
    return [[G,l]];
  fi;

  dom:=MovedPoints(G);
  pats:=List(l,x->Collected(List(Orbits(x,MovedPoints(x)),Length)));
  spats:=Set(pats);
  Info(InfoLattice,2,Length(spats)," patterns");
  result:=[];
  for pa in [1..Length(spats)] do
    lp:=Filtered([1..Length(pats)],x->pats[x]=spats[pa]);
    lp:=l{lp};
    Info(InfoLattice,3,"Pattern ",pa,": ",Length(lp)," groups");
    lens:=List(spats[pa],x->x[1]);

    # now try to move the orbits always to the same
    allorbs:=[];
    allco:=[];
    panu:=0;
    gpcl:=[];

    for h in lp do
      orbs:=Orbits(h,MovedPoints(h));
      orbs:=List(lens,x->Union(Filtered(orbs,y->Length(y)=x)));
      p:=Position(allorbs,orbs);
      if p<>fail then
	rep:=allco[p][1];
	cln:=allco[p][2];
      else
	Add(allorbs,orbs);
	# try to map to a known one
	j:=1;
	while j<>fail and j<Length(allorbs) do
	  if orbs=allorbs[j] then
	    rep:=One(G);
	  else
	    Gm:=G;
	    rep:=One(G);
	    corbs:=List(orbs,ShallowCopy);
	    for k in [1..Length(orbs)] do
	      if rep<>fail then
		a:=RepresentativeAction(Gm,corbs[k],allorbs[j][k],OnSets);
		if a<>fail then
		  rep:=rep*a;
		  corbs:=List(corbs,x->OnSets(x,a));
		  Gm:=Stabilizer(Gm,allorbs[j][k],OnSets);
		else
		  rep:=fail;
		fi;
	      fi;
	    od;
	  fi;
	  if rep<>fail then
	    # found a conjugator -- join to class
	    cln:=allco[j][2];
	    Add(allco,[rep,cln]);
	    j:=fail;
	  else
	    j:=j+1;
	  fi;

	od;
	if j<>fail then
	  # none found -- new class
	  panu:=panu+1;
	  Add(allco,[One(G),panu]);
	  Gm:=G;
	  for k in orbs do
	    Gm:=Stabilizer(Gm,k,OnSets);
	  od;
	  Add(gpcl,[Gm,[]]);
	  cln:=panu;
	  rep:=One(G);
	fi;
      fi;
      #if rep<>() then Error("hee"); fi;
      #if not IsOne(rep) and Set(List(orbs,x->OnSets(x,rep)))<>allorbs[cln] then

      h:=h^rep;
      Add(gpcl[cln][2],h);
      #a:=Set(List(Orbits(h,MovedPoints(h)),Set));
      #p:=Position(allorbs,List(Set(List(a,Length)),x->Union(Filtered(a,y->Length(y)=x))));
      #if allco[p][2]<>cln then
#	Error("GGG");
#      fi;

    od;
    Info(InfoLattice,3,Length(gpcl)," orbit lengths classes ");
    Info(InfoLattice,5,List(gpcl,x->Length(x[2])));

    # split according to orbits. First orbits as they are orbits under j[1],
    # then as partitions.
    panu:=[];
    for j in gpcl do
      if Length(j[2])=1 then
	Add(panu,j);
      else
	allorbs:=[];
	lpats:=[];
	cnt:=Minimum(1000,Binomial(Length(j[2]),2)); # pairs
	nobail:=true;
	dict:=NewDictionary(MovedPoints(j[1]),true);
	norb:=0;
	hpos:=1;
	while nobail and hpos<=Length(j[2]) do
	  h:=j[2][hpos];
	  orbs:=Set(List(Orbits(h,MovedPoints(h)),Set));
	  MakeImmutable(orbs);List(orbs,IsSet);IsSet(orbs);
	  lp:=[];
	  for k in orbs do
	    rep:=LookupDictionary(dict,k);
	    if nobail and rep=fail then
	      a:=Orbit(j[1],k,OnSets);
	      cnt:=cnt-Length(a);
	      if cnt<0 then
		nobail:=false; # stop this orbit listing as too expensive.
	      else
      #Print("orblen=",Length(a),"\n");
		MakeImmutable(a);List(a,IsSet);
		norb:=norb+1;
		rep:=norb;
		for m in a do
		  AddDictionary(dict,m,norb);
		od;
	      fi;
	    fi;
	    Add(lp,rep);
	  od;
	  Sort(lp); # orbit pattern as numbers
	  rep:=Position(allorbs,lp);
	  if rep=fail then
	    Add(allorbs,lp);
	    Add(lpats,[j[1],[h]]);
	  else
	    Add(lpats[rep][2],h);
	  fi;
	  hpos:=hpos+1;
	od;

	if nobail then
#Print("nobail\n");
	  # now lpats are local patterns, but we still have the dictionary to
	  # make the orbit conjugation tests cheaper.
	  gpcl2:=lpats;

	  for je in gpcl2 do
	    if Length(je[2])=1 then
	      Add(panu,je);
	    else
	      allorbs:=[];
	      lpats:=[];
	      for h in je[2] do
		orbs:=Set(List(Orbits(h,MovedPoints(h)),Set));
		MakeImmutable(orbs);List(orbs,IsSet);IsSet(orbs);
		ornums:=List(orbs,x->LookupDictionary(dict,x));
		sornums:=ShallowCopy(ornums);Sort(sornums);
		ssornums:=Set(sornums);
		a:=Filtered([1..Length(allorbs)],x->allorbs[x][2]=sornums);
		rep:=fail;
		k:=0;
		while rep=fail and k<Length(a) do
		  k:=k+1;
		  lrep:=One(je[1]);
		  m:=1;
		  while lrep<>fail and m<=Length(ssornums) do
		    sel:=Filtered([1..Length(ornums)],x->ornums[x]=ssornums[m]);
		    sela:=Filtered([1..Length(ornums)],
		      x->allorbs[k][4][x]=ssornums[m]);
		    partimg:=OnSetsSets(orbs{sel},lrep^-1);
		    # only try to map these indexed orbits
		    if allorbs[k][1]{sela}=partimg then
		      lrep1:=One(je[1]);
		    elif Size(allorbs[k][5][m][1])/
			  Size(allorbs[k][5][m+1][1])>50 then
		      if allorbs[k][5][m][2]=0 then
			# delayed transversal
			allorbs[k][5][m][2]:=
			  RightTransversal(allorbs[k][5][m][1],
			    allorbs[k][5][m+1][1]);
		      fi;
		      lrep1:=First(allorbs[k][5][m][2],
			x->OnSetsSets(allorbs[k][1]{sela},x)=partimg);
		    else
		      lrep1:=RepresentativeAction(allorbs[k][5][m][1],
			allorbs[k][1]{sela},partimg,OnSetsSets);
		    fi;
		    if lrep1=fail then 
  #if RepresentativeAction(je[1],allorbs[k][1],orbs,OnSetsSets)<>fail then Error("HEH");fi;
		      lrep:=fail;
		    else
		      lrep:=lrep1*lrep;
		    fi;

		    m:=m+1;
		  od;

		  rep:=lrep;
		od;
		if rep=fail then

		  a:=je[1];
		  statra:=[];
		  for m in ssornums do
		    sel:=Filtered([1..Length(ornums)],x->ornums[x]=m);
		    Add(statra,[a,0]); # 0 is delayed transversal
		    a:=Stabilizer(a,orbs{sel},OnSetsSets);
		  od;
		  Add(statra,[a,0]);
  #if a<>Stabilizer(je[1],orbs,OnSetsSets) then Error("STB");fi;

		  Add(allorbs,[orbs,sornums,a,ornums,statra]);
		  Add(lpats,[a,[h]]);
		else
		  Add(lpats[k][2],h^(rep^-1));
		fi;
	      od;
	      Append(panu,lpats);
	    fi;
	  od;
	else
	  # if bailed
#Print("bailed\n");
	  Add(panu,j);
	fi;
      fi;
    od;
    gpcl:=panu;
    Info(InfoLattice,3,Length(gpcl)," orbit classes ");
    Info(InfoLattice,5,List(gpcl,x->Length(x[2])));

# this is redundant now
#    # now split according to actual orbit partition
#    panu:=[];
#    for j in gpcl do
#      if Length(j[2])=1 then
#	Add(panu,j);
#      else
#	allorbs:=[];
#	lpats:=[];
#	for h in j[2] do
#	  orbs:=Set(List(Orbits(h,MovedPoints(h)),Set));
#	  MakeImmutable(orbs);List(orbs,IsSet);IsSet(orbs);
#	  lp:=Collected(List(orbs,Length));
#	  a:=Filtered([1..Length(allorbs)],x->allorbs[x][2]=lp);
#	  rep:=fail;
#	  k:=0;
#	  while rep=fail and k<Length(a) do
#	    k:=k+1;
#	    # there isn't yet a good method for RepresentativeAction, but
#	    # short orbit is quick
#	    if allorbs[k][1]=orbs then
#	      rep:=One(j[1]);
#	    elif Size(j[1])/Size(allorbs[k][3])>50 then
#	      if allorbs[k][4]=0 then
#		# delayed transversal
##		allorbs[k][4]:=RightTransversal(j[1],allorbs[k][3]);
#	      fi;
#	      rep:=First(allorbs[k][4],x->OnSetsSets(allorbs[k][1],x)=orbs);
#	    else
#	      rep:=RepresentativeAction(j[1],allorbs[k][1],orbs,OnSetsSets);
#	    fi;
#	  od;
#	  if rep=fail then
#	    a:=Stabilizer(j[1],orbs,OnSetsSets);
#	    Add(allorbs,[orbs,lp,a,0]);
#	    Add(lpats,[a,[h]]);
#	  else
#	    Add(lpats[k][2],h^(rep^-1));
#	  fi;
#	od;
#	Append(panu,lpats);
#      fi;
#    od;
#    gpcl:=panu;
#
#    Info(InfoLattice,3,Length(gpcl)," orbit partition classes ");
#    Info(InfoLattice,5,List(gpcl,x->Length(x[2])));

    # now split by cycle structures
    panu:=[];
    for j in gpcl do
      if Size(j[2][1])<1000 then
	if Size(j[2][1])<=100 or IsAbelian(j[2][1]) then
	  allorbs:=List(j[2],x->Collected(List(Enumerator(x),CycleStructurePerm)));
	else
	  allorbs:=List(j[2],x->Collected(List(ConjugacyClasses(x),
	    y->Concatenation([Size(y)],
	           CycleStructurePerm(Representative(y))))));
        fi;

	allco:=Set(allorbs);
	for k in allco do
	  a:=Filtered([1..Length(allorbs)],x->allorbs[x]=k);
	  orbs:=[];
	  for i in j[2]{a} do
	    if not ForAny(orbs,x->ForAll(GeneratorsOfGroup(i),y->y in x)) then
	      Add(orbs,i);
	    #else Print("duplicate\n");
	    fi;
	  od;
	  Add(result,[j[1],orbs]);
	  Add(panu,Length(orbs));
	od;

      else
	Add(result,j);
	Add(panu,1);
      fi;

    od;
    Info(InfoLattice,3," to ",Length(panu)," cyclestruct classes ");

    #Append(result,gpcl);

  od;
  return result;

end);

#############################################################################
##
#E  oprtglat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
