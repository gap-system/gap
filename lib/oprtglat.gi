#############################################################################
##
#W  oprtglat.gi                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$ 
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains methods for orbits on subgroups
##
Revision.oprtglat_gi:=
  "@(#)$Id$";

#############################################################################
##
#M  GroupOnSubgroupsOrbit(G,H) . . . . . . . . . . . . . . orbit of H under G
##
GroupOnSubgroupsOrbit := function(G,H)
  return Enumerator(ConjugacyClassSubgroups(G,H));
end;

#############################################################################
##
#M  MinimumGroupOnSubgroupsOrbit(G,H [,N_G(H)]) minimum of orbit of H under G
##
MinimumGroupOnSubgroupsOrbit := function(arg)
local s,i,m,Hc;
  s:=ConjugacyClassSubgroups(arg[1],arg[2]);
  if Length(arg)>2 then
    SetStabilizerOfExternalSet(s,arg[3]);
  fi;
  s:=Enumerator(s);
  m:=s[1];
  for i in [2..Length(s)] do
    Hc:=s[i];
    if Hc<m then
      m:=Hc;
    fi;
  od;
  return m;
end;

InstallMethod(SubgroupsOrbitsAndNormalizers,"generic on list",true,
  [IsGroup,IsList,IsBool],0,
function(G,dom,all)
local  n,l,o,b,r,p,cl,i,sel;

  n:=Length(dom);
  l:=n;
  o:=[];
  b:=BlistList([1..l],[1..n]);
  while n>0 do
    p:=PositionProperty(b,false);
    b[p]:=false;
    n:=n-1;
    r:=rec(representative:=dom[p]);
    cl:=ConjugacyClassSubgroups(G,r.representative);
    r.normalizer:=StabilizerOfExternalSet(cl);
    sel:=Filtered([1..l],i->b[i]);
    cl:=Enumerator(cl);
    if Length(sel)>0 then
      for i in cl do
        p:=PositionProperty(sel,j->dom[j]=i);
	if p<>fail then
	  b[p]:=false;
	  n:=n-1;
	  RemoveSet(sel,p);
	fi;
      od;
    fi;
    if all then
      r.elements:=cl;
    fi;
    Add(o,r);
  od;
  return o;
end);

# destructive version
# this method takes the component 'list' from the record and shrinks the
# list to save memory
InstallMethod(SubgroupsOrbitsAndNormalizers,"generic on record with list",true,
  [IsGroup,IsRecord,IsBool],0,
function(G,r,all)
local  n,l,o,b,dom,p,cl,i,s,j;

  dom:=r.list;
  Unbind(r.list);

  n:=Length(dom);
  o:=[];
  while n>0 do
    r:=rec(representative:=dom[1]);
    s:=Size(dom[1]);
    cl:=ConjugacyClassSubgroups(G,r.representative);
    r.normalizer:=StabilizerOfExternalSet(cl);
    cl:=Enumerator(cl);

    for i in cl do
      j:=2;
      while j<=Length(dom) do
	if dom[j]=i then
	  dom[j]:=dom[Length(dom)];
	  Unbind(dom[Length(dom)]);
	else
	  j:=j+1;
	fi;
      od;
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
#E  oprtglat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
