#############################################################################
##
#W  oprtglat.gi                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$ 
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This  file  contains methods for orbits on subgroups
##
Revision.oprtglat_gi:=
  "@(#)$Id$";

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
    r:=rec(representative:=dom[p]);
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
local  n,l,o,b,r,p,cl,i,sel,selz,gens,ti,t,tl;

  n:=Length(dom);
  l:=n;
  o:=[];
  b:=BlistList([1..l],[1..n]);
  while n>0 do
    p:=Position(b,true);
    b[p]:=false;
    n:=n-1;
    r:=rec(representative:=dom[p]);
    gens:=GeneratorsOfGroup(r.representative);
    r.normalizer:=Normalizer(G,r.representative);
    tl:=Index(G,r.normalizer);
    sel:=Filtered([1..l],i->b[i]);
    selz:=Filtered(sel,i->Size(dom[i])=Size(r.representative));
    if tl<=50*Length(selz) then
      t:=RightTransversal(G,r.normalizer);
      if Length(selz)>0 then
	i:=1;
	while Length(sel)>0 and Length(selz)>0 and i<=tl do;
	  ti:=t[i];
	  p:=PositionProperty(sel,
	                      j->j in selz and ForAll(gens,k->k^ti in dom[j]));
	  if p<>fail then
	    p:=sel[p];
	    b[p]:=false;
	    n:=n-1;
	    RemoveSet(sel,p);
	    RemoveSet(selz,p);
	  fi;
	  i:=i+1;
	od;
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
    r:=rec(representative:=dom[p]);

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
