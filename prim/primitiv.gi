#############################################################################
##
#W  primitiv.gi       GAP primitive groups library          Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999, School Math.&Comp. Sci., University of St Andrews
##
##  This file contains the routines for the primitive groups library
##
Revision.primitiv_gi:=
  "@(#)$Id$";

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("trans","1.0");

Unbind(PRIMGRP);

#############################################################################
##
#V  PRIMGRP
##  Generators, names and properties of the primitive groups.
##  entries are
##  1: id
##  2: size
##  3: Simple+2*Solvable
##  4: ONan-Scott-type
##  5: Collected suborbits
##  6: Transitivity
##  7: name
##  8: socle type
##  9: generators
PRIMGRP:=[];

#############################################################################
##
#V  PRIMLOAD
##
##  Queue of order in which the groups were loaded.
PRIMLOAD:=[];

BIND_GLOBAL("PrimGrpLoad",function(deg)
local s,fname,ind,new;
  if not IsBound(PRIMGRP[deg]) then
    if not (deg in PRIMRANGE and IsBound(PRIMINDX[deg])) then
      Error("Primitive groups of degree ",deg," are not known!");
    fi;

    # are there too many groups stored?
    s:=Sum(Filtered(PRIMGRP,i->IsBound(i)),Length);
    while s>200 do
      s:=s-PRIMLENGTHS[PRIMLOAD[1]];
      Unbind(PRIMGRP[PRIMLOAD[1]]);
      PRIMLOAD:=PRIMLOAD{[2..Length(PRIMLOAD)]};
    od;

    ind:=PRIMINDX[deg];
    new:=Filtered([1..Length(PRIMINDX)],i->PRIMINDX[i]=ind);
    fname:=Concatenation("prim",String(ind));
    ReadGapRoot( Concatenation( "prim/grps/", fname, ".grp" ) );

    # store the degree
    PRIMLOAD:=Filtered(PRIMLOAD,i->not i in new);
    Append(PRIMLOAD,new);

  fi;
end);

BIND_GLOBAL("PRIMGrp",function(deg,nr)
  PrimGrpLoad(deg);
  if nr>PRIMLENGTHS[deg] then
    Error("There are only ",PRIMLENGTHS[deg]," groups of degree ",nr,"\n");
  fi;
  return PRIMGRP[deg][nr];
end);

InstallGlobalFunction(NrPrimitiveGroups, function(deg)
  PrimGrpLoad(deg);
  return PRIMLENGTHS[deg];
end);

InstallGlobalFunction( PrimitiveGroup, function(deg,num)
local l,g;
  l:=PRIMGrp(deg,num);

  # special case: Symmetric and Alternating Group
  if l[7]="A_n" then
    g:=AlternatingGroup(deg);
  elif l[7]="S_n" then
    g:=SymmetricGroup(deg);
  else
    g:= GroupByGenerators( l[9], () );
    if IsString(l[7]) and l[7]<>"" then
      SetName(g,l[7]);
    #else
    #  SetName(g,Concatenation("p",String(deg),"n",String(num)));
    fi;
    SetSize(g,l[2]);
  fi;
  SetPrimitiveIdentification(g,l[1]);
  SetONanScottType(g,l[4]);
  SetSocleTypePrimitiveGroup(g,rec(series:=l[8][1],
                                   parameter:=l[8][2],
				   width:=l[8][3]));
  if deg<=50 then
    SetSimsNo(g,l[10]);
  fi;
  return g;
end );

# local cache for `PrimitiveIdentification':
PRILD:=0;
PGICS:=[];

InstallMethod(PrimitiveIdentification,"generic",true,[IsPermGroup],0,
function(grp)
local dom,deg,PD,s,cand,a,p,b,i,ag,bg,q;
  dom:=MovedPoints(grp);
  if not IsTransitive(grp,dom) and IsPrimitive(grp,dom) then
    Error("Group must operate primitively");
  fi;
  deg:=Length(dom);
  PrimGrpLoad(deg);
  PD:=PRIMGRP[deg];

  s:=Size(grp);

  # size
  cand:=Filtered([1..PRIMLENGTHS[deg]],i->PD[i][2]=s);

  #ons
  if Length(cand)>1 and Length(Set(PD{cand},i->i[4]))>1 then
    a:=ONanScottType(grp);
    cand:=Filtered(cand,i->PD[i][4]=a);
  fi;

  # suborbits
  if Length(cand)>1 and Length(Set(PD{cand},i->i[5]))>1 then
    a:=Collected(List(Orbits(Stabilizer(grp,dom[1]),dom{[2..Length(dom)]}),
                      Length));
    cand:=Filtered(cand,i->PD[i][5]=a);
  fi;

  # Transitivity
  if Length(cand)>1 and Length(Set(PD{cand},i->i[6]))>1 then
    a:=Transitivity(grp,dom);
    cand:=Filtered(cand,i->PD[i][6]=a);
  fi;

  if Length(cand)>1 then
    # now we need to create the groups
    p:=List(cand,i->PrimitiveGroup(deg,i));

    # Some tests for the sylow subgroups
    for q in Set(Factors(Size(grp)/Size(Socle(grp)))) do
      if q=1 then 
        q:=2;
      fi;

      ag:=Image(IsomorphismPcGroup(SylowSubgroup(grp,q)));
      # central series
      a:=List(LowerCentralSeries(ag),Size);
      b:=[];
      for i in [1..Length(cand)] do
	bg:=Image(IsomorphismPcGroup(SylowSubgroup(p[i],q)));
	b[i]:=List(LowerCentralSeries(bg),Size);
      od;
      s:=Filtered([1..Length(cand)],i->b[i]=a);
      cand:=cand{s};
      p:=p{s};

      if Length(cand)>1 then
	# Frattini subgroup
	a:=Size(FrattiniSubgroup(ag));
	b:=[];
	for i in [1..Length(cand)] do
	  bg:=Image(IsomorphismPcGroup(SylowSubgroup(p[i],q)));
	  b[i]:=Size(FrattiniSubgroup(bg));
	od;
	s:=Filtered([1..Length(cand)],i->b[i]=a);
	cand:=cand{s};
	p:=p{s};
      fi;

      if Length(cand)>1 and Size(ag)<512 then
	# Isomorphism type of 2-Sylow
	a:=IdGroup(ag);
	b:=[];
	for i in [1..Length(cand)] do
	  bg:=Image(IsomorphismPcGroup(SylowSubgroup(p[i],q)));
	  b[i]:=IdGroup(bg);
	od;
	s:=Filtered([1..Length(cand)],i->b[i]=a);
	cand:=cand{s};
	p:=p{s};
      fi;

    od;
  fi;

  if Length(cand)>1 then

    # Klassen
    a:=Collected(List(ConjugacyClasses(grp),
                      i->[CycleStructurePerm(Representative(i)),Size(i)]));

    # use caching
    if deg<>PRILD then
      PRILD:=deg;
      PGICS:=[];
    fi;

    b:=[];
    for i in [1..Length(cand)] do
      if not IsBound(PGICS[cand[i]]) then
        PGICS[cand[i]]:=Collected(List(ConjugacyClasses(p[i]),
		  j->[CycleStructurePerm(Representative(j)),Size(j)]));
      fi;
      b[i]:=PGICS[cand[i]];
    od;

    s:=Filtered([1..Length(cand)],i->b[i]=a);
    cand:=cand{s};
    p:=p{s};
  fi;

  if Length(cand)=1 then
    return cand[1];
  else
    Error("Uh-Oh, this should never happen ",cand);
    return cand[1];
  fi;
end);

##
#R  IsPrimGrpIterRep
##
DeclareRepresentation("IsPrimGrpIterRep",IsComponentObjectRep,[]);

# function used by the iterator to get the next group or to indicate that
# finished
BindGlobal("PriGroItNext",function(it)
local g;
  it!.next:=fail;
  repeat
    if it!.degi>Length(it!.deg) then 
      it!.next:=false;
    else
      g:=PrimitiveGroup(it!.deg[it!.degi],it!.gut[it!.deg[it!.degi]][it!.nr]);
      if ForAll(it!.prop,i->STGSelFunc(i[1](g),i[2])) then
	it!.next:=g;
      fi;
      it!.nr:=it!.nr+1;
      if it!.nr>Length(it!.gut[it!.deg[it!.degi]]) then
	it!.degi:=it!.degi+1;
	it!.nr:=1;
	while it!.degi<=Length(it!.deg) and Length(it!.gut[it!.deg[it!.degi]])=0 do
	  it!.degi:=it!.degi+1;
	od;
      fi;
    fi;
  until it!.degi>Length(it!.deg) or it!.next<>fail;
end);

#############################################################################
##
#F  PrimitiveGroupsIterator(arglis,alle)  . . . . . selection function
##
InstallGlobalFunction(PrimitiveGroupsIterator,function(arg)
local arglis,i,j,a,b,l,p,deg,gut,g,grp,nr,f,RFL,ind,it;
  if Length(arg)=1 and IsList(arg[1]) then
    arglis:=arg[1];
  else
    arglis:=arg;
  fi;
  l:=Length(arglis)/2;
  if not IsInt(l) then
    Error("wrong arguments");
  fi;
  deg:=[2..Length(PRIMINDX)];
  # do we ask for the degree?
  p:=Position(arglis,NrMovedPoints);
  if p<>fail then
    p:=arglis[p+1];
    if IsInt(p) then
      f:=not p in deg;
      p:=[p];
    fi;
    if IsList(p) then
      f:=not IsSubset(deg,p);
      deg:=Intersection(deg,p);
    else
      # b is a function (wondering, whether anyone will ever use it...)
      f:=true;
      deg:=Filtered(deg,p); 
    fi;
  else
    f:=true; #warnung weil kein Degree angegeben ?
  fi;
  gut:=[];
  for i in deg do
    gut[i]:=[1..NrPrimitiveGroups(i)];
  od;

  for ind in [1..l] do
    a:=arglis[2*ind-1];
    b:=arglis[2*ind];

    # get all cheap properties first

    if a=NrMovedPoints then
      nr:=0; # done already 
    elif a=Size or a=Transitivity or a=ONanScottType then
      if a=Size then
        nr:=2;
      elif a=Transitivity then
        nr:=6;
      elif a=ONanScottType then
        nr:=4;
	if b=1 or b=2 or b=5 then
          b:=String(b);
	elif b=3 then
	  b:=["3a","3b"];
	elif b=4 then
	  b:=["4a","4b","4c"];
	fi;
      fi;
      for i in deg do
	gut[i]:=Filtered(gut[i],j->STGSelFunc(PRIMGrp(i,j)[nr],b));
      od;
    elif a=IsSimpleGroup or a=IsSimple then
      for i in deg do
	gut[i]:=Filtered(gut[i],j->STGSelFunc(PRIMGrp(i,j)[3] mod 2=1,b));
      od;
    elif a=IsSolvableGroup or a=IsSolvable then
      for i in deg do
	gut[i]:=Filtered(gut[i],j->STGSelFunc(QuoInt(PRIMGrp(i,j)[3],2)=1,b));
      od;
    elif a=SocleTypePrimitiveGroup then
      if IsFunction(b) then
	# for a functiuon we have to translate the list form into records
	RFL:=function(lst)
	  return rec(series:=lst[1],parameter:=lst[2],width:=lst[3]);
	end;
	for i in deg do
	  gut[i]:=Filtered(gut[i],j->b(RFL(PRIMGrp(i,j)[8])));
	od;
      else
	# otherwise we may bring b into the form we want
	if IsRecord(b) then
	  b:=[b];
	fi;
	if IsList(b) and IsRecord(b[1]) then
	  b:=List(b,i->[i.series,i.parameter,i.width]);
	fi;
	for i in deg do
	  gut[i]:=Filtered(gut[i],j->PRIMGrp(i,j)[8] in b);
	od;

      fi;
      
    fi;
  od;

  if f then
    Print("#W  AllPrimitiveGroups: Degree restricted to ",PRIMRANGE,"\n");
  fi;

  # the rest is hard.

  # find the properties we have not stored
  p:=[];
  for i in [1..l] do
    if not arglis[2*i-1] in
      [NrMovedPoints,Size,Transitivity,ONanScottType,IsSimpleGroup,IsSimple,
       IsSolvableGroup,IsSolvable,SocleTypePrimitiveGroup] then
      Add(p,arglis{[2*i-1,2*i]}); 
    fi;
  od;

  it:=Objectify(NewType(IteratorsFamily,
                        IsIterator and IsPrimGrpIterRep and IsMutable),rec());

  it!.deg:=deg;
  i:=1;
  while i<=Length(deg) and Length(gut[deg[i]])=0 do
    i:=i+1;
  od;
  it!.degi:=i;
  it!.nr:=1;
  it!.prop:=p;
  it!.gut:=gut;
  PriGroItNext(it);
  return it;

end);

InstallMethod(IsDoneIterator,"primitive groups iterator",true,
  [IsPrimGrpIterRep and IsIterator and IsMutable],0,
function(it)
  return it!.next=false or it!.next=fail;
end);

InstallMethod(NextIterator,"primitive groups iterator",true,
  [IsPrimGrpIterRep and IsIterator and IsMutable],0,
function(it)
local g;
  g:=it!.next;
  if g=false or g=fail then
    Error("iterator ran out");
  fi;
  PriGroItNext(it); # next value
  return g;
end);

#############################################################################
##
#F  AllPrimitiveGroups( <fun>, <res>, ... ) . . . . . . . selection function
##
InstallGlobalFunction(AllPrimitiveGroups,function ( arg )
local l,g,it;
  it:=PrimitiveGroupsIterator(arg);
  l:=[];
  for g in it do
    Add(l,g);
  od;
  return l;
end);

#############################################################################
##
#F  OnePrimitiveGroup( <fun>, <res>, ... ) . . . . . . . selection function
##
InstallGlobalFunction(OnePrimitiveGroup,function ( arg )
local l,g,it;
  it:=PrimitiveGroupsIterator(arg);
  if IsDoneIterator(it) then
    return fail;
  else
    return NextIterator(it);
  fi;
end);

# some trivial or useless functions for nitpicking compatibility

BindGlobal("NrAffinePrimitiveGroups",
function(x)
  if x<=2 then 
    return 1;
  elif x=3 or x=4 then
    return 2;
  else
   return Length(AllPrimitiveGroups(NrMovedPoints,x,ONanScottType,"1"));
  fi;
end);

BindGlobal("NrSolvableAffinePrimitiveGroups",
  x->Length(AllPrimitiveGroups(NrMovedPoints,x,IsSolvableGroup,true)));

DeclareSynonym("SimsName",Name);

BindGlobal("PrimitiveGroupSims",
function(d,n)
  return OnePrimitiveGroup(NrMovedPoints,d,SimsNo,n);
end);

#############################################################################
##
#E  primitiv.gi
##

