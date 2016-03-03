#############################################################################
##
#W  primitiv.gi       GAP primitive groups library          Alexander Hulpke
##
##
#Y  Copyright (C)  1999, School Math.&Comp. Sci., University of St Andrews
##
##  This file contains the routines for the primitive groups library
##

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
    if IsBound(PRIMLOAD[1]) then
      while s>200 do
	s:=s-PRIMLENGTHS[PRIMLOAD[1]];
	Unbind(PRIMGRP[PRIMLOAD[1]]);
	PRIMLOAD:=PRIMLOAD{[2..Length(PRIMLOAD)]};      od;
    fi;

    ind:=PRIMINDX[deg];
    new:=Filtered([1..Length(PRIMINDX)],i->PRIMINDX[i]=ind);
    fname:=Concatenation("gps",String(ind));
    ReadGapRoot( Concatenation( "prim/grps/", fname, ".g" ) );

    # store the degree
    PRIMLOAD:=Filtered(PRIMLOAD,i->not i in new);
    Append(PRIMLOAD,new);

  fi;
end);

BIND_GLOBAL("PRIMGrp",function(deg,nr)
  PrimGrpLoad(deg);
  if nr>PRIMLENGTHS[deg] then
    Error("There are only ",PRIMLENGTHS[deg]," groups of degree ",deg,"\n");
  fi;
  return PRIMGRP[deg][nr];
end);

InstallGlobalFunction(NrPrimitiveGroups, function(deg)
  if not IsBound(PRIMLENGTHS[deg]) then
    PrimGrpLoad(deg);
  fi;
  return PRIMLENGTHS[deg];
end);

InstallGlobalFunction( PrimitiveGroup, function(deg,num)
local l,g,fac,mats,perms,v,t;
  l:=PRIMGrp(deg,num);

  # special case: Symmetric and Alternating Group
  if l[9]="Alt" then
    g:=AlternatingGroup(deg);
    SetName(g,Concatenation("A(",String(deg),")"));
  elif l[9]="Sym" then
    g:=SymmetricGroup(deg);
    SetName(g,Concatenation("S(",String(deg),")"));
  elif l[9] = "psl" then
    g:= PSL(2, deg-1);
    SetName(g, Concatenation("PSL(2,", String(deg-1),")"));
  elif l[9] = "pgl" then
    g:= PGL(2, deg-1);
    SetName(g, Concatenation("PGL(2,", String(deg-1), ")"));
  elif l[4] = "1" then
    if Length(l[9]) > 0 then
      fac:= Factors(deg);
      mats:=List(l[9],i->ImmutableMatrix(GF(fac[1]),i));
      v:=Elements(GF(fac[1])^Length(fac));
      perms:=List(mats,i->Permutation(i,v,OnRight));
      t:=First(v,i->not IsZero(i)); # one nonzero translation 
                                    #suffices as matrix
                                    # action is irreducible
      Add(perms,Permutation(t,v,function(i,j) return i+j;end));
      g:= Group(perms);
      SetSize(g, l[2]);
    else
      g:= Image(IsomorphismPermGroup(CyclicGroup(deg)));
    fi; 
    if IsString(l[7]) and Length(l[7])>0 then
      SetName(g, l[7]);
    fi;
  else
    g:= GroupByGenerators( l[9], () );
    if IsString(l[7]) and Length(l[7])>0 then
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
  
  if l[3] = 0 then
    SetIsSimpleGroup(g, false);
    SetIsSolvableGroup(g, false);
  elif l[3] = 1 then
    SetIsSimpleGroup(g, true);
    SetIsSolvableGroup(g, false);
  elif l[3] = 2 then
    SetIsSimpleGroup(g, false);
    SetIsSolvableGroup(g, true);
  elif l[3] = 3 then
    SetIsSimpleGroup(g, true);
    SetIsSolvableGroup(g, true);
  fi;
  SetTransitivity(g, l[6]);
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
local dom,deg,PD,s,cand,a,p,s_quot,b,cs,n,beta,alpha,i,ag,bg,q,gl,hom;
  dom:=MovedPoints(grp);
  if not (IsTransitive(grp,dom) and IsPrimitive(grp,dom)) then
    Error("Group must operate primitively");
  fi;
  deg:=Length(dom);
  PrimGrpLoad(deg);
  PD:=PRIMGRP[deg];

  if IsNaturalAlternatingGroup(grp) then
    SetSize(grp, Factorial(deg)/2);
  elif IsNaturalSymmetricGroup(grp) then
    SetSize(grp, Factorial(deg));
  fi;

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
    cand:=Filtered(cand,i->Set(PD[i][5])=Set(a));
  fi;

  # Transitivity
  if Length(cand)>1 and Length(Set(PD{cand},i->i[6]))>1 then
    a:=Transitivity(grp,dom);
    cand:=Filtered(cand,i->PD[i][6]=a);
  fi;

  if Length(cand)>1 then
    # now we need to create the groups
    p:=List(cand,i->PrimitiveGroup(deg,i));

    # in product action case, some tests on the socle quotient.
    if ONanScottType(grp) = "4c" then
     #first we just identify its isomorphism type 
      s:= Socle(grp);
      s_quot:= FactorGroup(grp, s);
      a:= IdGroup(s_quot);
      b:= [];
      for i in [1..Length(cand)] do
        b[i]:= IdGroup(FactorGroup(p[i], Socle(p[i])));
      od;
      s:= Filtered([1..Length(cand)], i->b[i] =a);
      cand:= cand{s};
      p:= p{s};
    fi;
  fi;

  if Length(cand)>1 then
    # sylow orbits
    gl:=Reversed(Set(Factors(Size(grp))));
    while Length(cand)>1 and Length(gl)>0 do
      a:=Collected(List(Orbits(SylowSubgroup(grp,gl[1]),MovedPoints(grp)),
	                Length));
      b:=[];
      for i in [1..Length(cand)] do
	b[i]:=Collected(List(Orbits(SylowSubgroup(p[i],gl[1]),
	                            MovedPoints(p[i])),
			  Length));
      od;
      s:=Filtered([1..Length(cand)],i->b[i]=a);
      cand:=cand{s};
      p:=p{s};
      gl:=gl{[2..Length(gl)]};
    od;
  fi;

  if Length(cand) > 1 then
    # Some further tests for the sylow subgroups
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

  #back for a closer look at the product action groups.
  if Length(cand) > 1 and ONanScottType(grp) = "4c" then
    #just here out of curiosity during testing.
    #Print("cand =", cand, "\n");
    #now we construct the action of the socle quotient as a
    #(necessarily transitive) action on the socle factors.
    s:= Socle(grp);
    cs:= CompositionSeries(s);
    cs:= cs[Length(cs)-1];
    n:= Normalizer(grp, cs);
    beta:= FactorCosetAction(grp, n);
    alpha:= FactorCosetAction(n, ClosureGroup(Centralizer(n, cs), s));
    a:= TransitiveIdentification(Group(KuKGenerators(grp, beta, alpha)));
    b:= [];
    for i in [1..Length(cand)] do
      s:= Socle(p[i]);
      cs:= CompositionSeries(s);
      cs:= cs[Length(cs)-1];
      n:= Normalizer(p[i], cs);
      beta:= FactorCosetAction(p[i], n);
      alpha:= FactorCosetAction(n, ClosureGroup(Centralizer(n, cs), s));
      b[i]:= TransitiveIdentification(Group(KuKGenerators(p[i], beta, alpha)));
    od;
    s:= Filtered([1..Length(cand)], i->b[i]=a);
    cand:= cand{s};
    p:= p{s};
  fi;

  if Length(cand)>1 then
    # Klassen
    a:=Collected(List(ConjugacyClasses(grp:onlysizes),
                      i->[CycleStructurePerm(Representative(i)),Size(i)]));

    # use caching
    if deg<>PRILD then
      PRILD:=deg;
      PGICS:=[];
    fi;

    b:=[];
    for i in [1..Length(cand)] do
      if not IsBound(PGICS[cand[i]]) then
        PGICS[cand[i]]:=Collected(List(ConjugacyClasses(p[i]:onlysizes),
		  j->[CycleStructurePerm(Representative(j)),Size(j)]));
      fi;
      b[i]:=PGICS[cand[i]];
    od;

    s:=Filtered([1..Length(cand)],i->b[i]=a);
    cand:=cand{s};
    p:=p{s};
  fi;

  if Length(cand)>1 and ForAll(p,i->ONanScottType(i)="1") 
     and ONanScottType(grp)="1" then
    gl:=Factors(NrMovedPoints(grp));
    gl:=GL(Length(gl),gl[1]);
    hom:=IsomorphismPermGroup(gl);
    s:=List(p,i->Subgroup(gl,LinearActionLayer(i,Pcgs(Socle(i)))));
    b:=Subgroup(gl,LinearActionLayer(grp,Pcgs(Socle(grp))));
    s:=Filtered([1..Length(cand)],
	i->RepresentativeAction(Image(hom,gl),Image(hom,s[i]),Image(hom,b))<>fail);
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

InstallMethod(SimsNo,"via `PrimitiveIdentification'",true,[IsPermGroup],0,
function(grp)
local dom;
  dom:=MovedPoints(grp);
  if not IsTransitive(grp,dom) and IsPrimitive(grp,dom) then
    Error("Group must operate primitively");
  fi;
  return SimsNo(PrimitiveGroup(Length(dom),PrimitiveIdentification(grp)));
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
  deg:=PRIMRANGE;
  # do we ask for the degree?
  p:=Position(arglis,NrMovedPoints);
  if p<>fail then
    p:=arglis[p+1];
    if IsInt(p) then
      f:=not p in deg;
      p:=[p];
    fi;
    if IsList(p) then
      f:=not IsSubset(deg,Difference(p,[1]));
      deg:=Intersection(deg,p);
    else
      # b is a function (wondering, whether anyone will ever use it...)
      f:=true;
      deg:=Filtered(deg,p); 
    fi;
  else
    f:=true; #warnung weil kein Degree angegeben ?
    b:=true;
    for a in [Size,Order] do
      p:=Position(arglis,a);
      if p<>fail then
	p:=arglis[p+1];
	if IsInt(p) then
	  p:=[p];
	fi;
	  
	if IsList(p) then
	  deg := Filtered( deg,
	       d -> ForAny( p, k -> 0 = k mod d ) );
	  b := false;
	  f := not IsSubset( PRIMRANGE, p );
	fi;
      fi;
    od;
    if b then
      Info(InfoWarning,1,"No degree restriction given!\n",
	   "#I  A search over the whole library will take a long time!");
    fi;
  fi;
  gut:=[];
  for i in deg do
    gut[i]:=[1..NrPrimitiveGroups(i)];
  od;

  for i in deg do
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
	gut[i]:=Filtered(gut[i],j->STGSelFunc(PRIMGrp(i,j)[nr],b));
      elif a=IsSimpleGroup or a=IsSimple then
	gut[i]:=Filtered(gut[i],j->STGSelFunc(PRIMGrp(i,j)[3] mod 2=1,b));
      elif a=IsSolvableGroup or a=IsSolvable then
	gut[i]:=Filtered(gut[i],j->STGSelFunc(QuoInt(PRIMGrp(i,j)[3],2)=1,b));
      elif a=SocleTypePrimitiveGroup then
	if IsFunction(b) then
	  # for a function we have to translate the list form into records
	  RFL:=function(lst)
	    return rec(series:=lst[1],parameter:=lst[2],width:=lst[3]);
	  end;
	  gut[i]:=Filtered(gut[i],j->b(RFL(PRIMGrp(i,j)[8])));
	else
	  # otherwise we may bring b into the form we want
	  if IsRecord(b) then
	    b:=[b];
	  fi;
	  if IsList(b) and IsRecord(b[1]) then
	    b:=List(b,i->[i.series,i.parameter,i.width]);
	  fi;
	  gut[i]:=Filtered(gut[i],j->PRIMGrp(i,j)[8] in b);
	fi;
      
      fi;
    od;
  od;

  if f then
    Print( "#W  AllPrimitiveGroups: Degree restricted to [ 1 .. ",
           PRIMRANGE[ Length( PRIMRANGE ) ], " ]\n" );
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

  it!.deg:=Immutable(deg);
  i:=1;
  while i<=Length(deg) and Length(gut[deg[i]])=0 do
    i:=i+1;
  od;
  it!.degi:=i;
  it!.nr:=1;
  it!.prop:=MakeImmutable(p);
  it!.gut:=MakeImmutable(gut);
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
  if x=1 then 
    return 1;
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

# maximal subgroups routine.
# precomputed data up to degree 50 (so it will be quick is most cases).
# (As there is no independent check for the primitive groups of degree >50,
# we rather do not refer to them, but only use them in a calculation.)
BindGlobal("SNMAXPRIMS", MakeImmutable([[],[],[],[],[],[2],[],[5],[],[7],[],[4],
[],[2],[],[],[],[2],[],[2],[1,3,7],[2],[],[3],[],[5],[],[12],[],[2],[],[5],[],
[],[],[12],[],[2],[],[4,6],[],[2],[],[2],[5],[],[],[2],[],[7],[],[],[],[2],[6],
[7,5],[],[],[],[7],[],[2],[2],[],[2],[],[],[3,5],[],[],[],[2],[],[2],[],[],[],
[2,4],[],[2],[],[8],[],[2,4],[4],[],[],[],[],[2],[8],[],[],[],[],[],[],[2],[],
[4,2],[],[3],[],[2],[7,9],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],[10],[],
[5],[],[],[],[2,17,11],[],[5],[],[5],[],[2],[],[],[],[12],[],[2],[],[2],[],[],
[],[],[],[],[],[],[],[2],[],[2],[],[],[],[7],[],[2],[],[],[],[5],[],[2],[2],
[],[],[7],[],[5],[4,2],[],[],[2],[2],[],[],[],[],[2],[],[2],[],[],[],[],[],[],
[],[],[],[2],[],[2],[],[],[],[2],[],[2],[],[],[],[],[],[],[],[],[],[4],[],[2],
[],[],[],[],[],[],[],[3],[],[],[],[2],[],[],[],[2],[],[2],[],[],[],[4],[],[],
[],[],[],[2],[],[2],[],[4],[],[],[],[],[],[],[],[2],[7,2],[],[],[],[],[2],[],
[],[],[],[],[2],[],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],[2,20,22],[],
[2],[],[2],[],[2],[],[],[],[5],[],[],[],[2],[],[],[2],[],[],[9,5,7],[],[],[],[],
[],[],[],[2],[],[],[],[2],[],[2],[3],[],[],[2],[],[],[],[],[],[],[5],[],[],[],
[],[],[],[2],[],[],[],[],[],[2],[],[],[2],[],[],[6],[],[],[],[2],[],[2],
[9,4,6],[],[],[2],[],[],[5],[],[],[18],[],[5],[],[9,4],[],[],[],[2],[3],[],[],
[],[],[2],[],[],[],[],[],[2],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],
[],[],[2],[],[6],[],[2],[],[],[],[4,2],[],[],[],[2],[],[],[],[],[],[],[],[],
[],[2],[],[2],[],[],[1],[],[],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],[],
[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],[2],[],[],[],[6],[],[2],[5,2,3],
[],[],[2],[],[],[],[],[],[],[],[],[],[],[],[2],[],[],[],[],[],[],[],[2],[],
[],[],[2],[],[],[],[],[],[],[],[2],[],[],[],[6],[],[],[],[],[],[2],[],[],[],
[],[],[],[],[],[],[7],[],[2],[],[2],[6],[],[],[7],[],[5],[],[],[],[],[],[],[],
[],[],[8],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],[],[],[2],[],[4],[],
[],[],[2],[],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],
[],[],[2],[],[],[],[],[],[2],[2],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],
[],[],[],[],[2],[],[],[],[2],[],[3],[],[],[],[],[],[8],[],[],[],[],[],[2],[],
[],[],[],[],[],[],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],[2],[],[],[],
[],[],[7],[],[2],[],[],[],[4,2],[],[],[],[],[],[],[],[2],[],[],[],[2],[],[2],
[],[],[],[2],[],[],[],[],[],[],[],[2],[4],[],[],[],[],[],[],[],[],[2],[],[],
[],[],[],[],[],[2],[],[],[],[],[2],[],[],[],[],[2],[],[],[],[],[],[],[],[2],
[],[13,3],[],[],[],[2],[],[],[],[],[],[2],[2],[],[],[2],[],[],[],[],[],[1],[],
[2],[],[],[],[],[],[2],[],[],[],[2],[],[],[2],[],[],[],[],[2],[],[],[],[2],[1],
[],[],[],[],[],[],[],[],[],[],[],[],[2],[],[],[],[],[],[],[],[],[],[2],[],
[],[],[],[],[],[],[8],[],[],[],[2],[],[2],[],[],[],[],[],[],[4],[11,2,19],[],
[2],[],[2],[],[],[],[2],[],[2],[],[],[],[],[],[],[],[],[],[6],[],[5],[],[],[],
[],[],[],[],[],[],[],[],[2],[],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],
[],[],[],[],[],[],[],[],[2],[],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],
[],[],[],[],[],[],[],[],[],[4,2],[],[],[],[],[2],[],[3],[],[2],[],[],[],[],[],
[],[],[2],[],[],[],[],[],[],[],[],[],[2],[],[],[],[],[],[],[],[2],[],[],[],
[2],[],[],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],[5],[],[],[],
[],[],[2],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],
[2],[],[2],[],[],[],[],[],[2],[]]));

BindGlobal("ANMAXPRIMS", MakeImmutable([[],[],[],[],[],[1],[5],[],[9],[6],[6],
[2],[7],[1],[4],[],[8],[1],[],[1],[2,6],[1],[5],[1],[],[3],[13],[6,11],[],[1],
[9,10],[4],[2],[],[2],[10,11],[],[1],[],[3,5],[],[1],[],[1],[4,7],[],[],[1],[],
[2,6],[],[1],[],[1],[5],[4,6],[1,3],[],[],
[6],[],[1],[1,4,6],[],[1,5,7,11],[5],[],
[2,4],[],[],[],[1],[14],[1],[],[],[2],[1,3],[],[1],[],[7],[],[1,3],[3],[],[],
[],[],[1],[6,7],[],[],[],[],[],[],[1],[],[1,3],[],[1,2],[],[1],[6,8],[],[],[1],
[],[1],[],[8],[],[1],[],[],[1,3],[],[2],
[5,9,14,15,17,21],[49],[4],[],[],[],[1,6,8,16],
[13],[4],[2],[3],[],[1],[1],[],[3],[6,11],
[],[1],[],[1],[],[],[],[2,4,5],[],[],[],[],[],[1],[],[1],[4],[],[1],[6],[],[1],
[],[],[],[2],[],[1],[1,5],[],[],[6],[],
[3],[1,3],[],[],[1],[1,4],[2,4],[],[],[],[1],[],[1],[2],[],[],[1],[],[],[],[4],
[],[1],[],[1],[],[],[],[1],[],[1],[],[],[1],[],[],[],[],[3],[],[2,3],[],[1],[],
[],[],[],[],[],[],[2],[],[],[],[1],[],[],[],[1],[],[1],[4],[],[],[2,3],[],[],
[],[],[],[1],[],[1],[],[3],[],[],[],[1],[],[],[],[1],[1,3,6],[],[2],[],[4],[1],
[],[],[],[],[],[1],[],[1],[],[],[],[1],[],[1],[6],[],[2],[3,6],[],[1],[],
[1,17,21],[],[1],[],[1],[1],[1],[],[],[],
[3],[],[],[],[1],[],[],[1],[],[],[2,6,8],
[],[],[],[],[],[],[1],[1],[],[],[],[1],[],[1],[1,2],[],[],[1],[],[],[],[],[],
[],[2,4,12],[],[],[],[],[2,4],[],[1],[],
[],[],[6,7],[],[1],[],[],[1],[],[],[2,5],
[],[],[],[1],[],[1],[3,5,8],[],[],[1],[],
[],[4],[],[],[17],[],[4],[],[3,7,8],[],
[],[],[1],[2],[],[],[],[],[1],[],[],[],[6,9],[],[1],[2],[],[],[1],[],[],[],[],
[],[1],[],[],[],[],[],[2],[],[1],[],[5],
[],[1],[],[],[],[1,3],[],[],[],[1],[],[],[],[],[],[4],[],[],[],[1],[],[1],[],
[],[],[],[],[],[],[],[],[1],[],[1],[4],
[],[],[],[],[1],[],[],[],[1],[],[],[],[],[],[1],[],[],[],[],[2],[2],[],[1],[],
[],[],[2,5],[],[1],[1,4],[],[],[1],[],[],[],[],[],[],[],[],[],[],[],[1],[],[],
[],[],[],[],[],[1],[],[],[],[1],[],[],[2],[3,7,10],[],[],[],[1],[],[],[],[5],
[],[1],[],[],[],[1],[1],[],[9,12],[],[],
[],[],[],[],[4,5],[],[1],[],[1],[4,5],[],[2],[3,6],[],[4],[],[],[],[],[],[],[],
[],[],[7],[],[1],[],[],[],[],[],[1],[],[],[],[],[1],[],[],[],[],[1],[],[2,3],
[2],[],[],[1],[],[],[5],[],[],[1],[],[1],[],[],[],[],[],[1],[],[],[],[],[],
[],[4],[],[],[1],[],[],[],[],[],[1],[1],[],[],[],[],[1],[],[1],[],[],[],[],[],
[1],[],[],[],[],[],[1],[],[2],[],[1],[],[1,2],[],[],[],[],[],[6],[],[],[],[2],
[],[1],[],[],[],[],[],[],[],[],[],[1],[],[1],[],[],[],[1],[],[],[1,5],[],[],
[1],[],[],[2],[],[],[6],[],[1],[],[],[],[1,3],[],[],[],[],[2],[4],[],[1],[],[],
[],[1],[],[1],[],[],[],[1],[],[],[],[],[],[],[],[1],[3],[],[],[],[],[],[],[],
[],[1],[4],[],[],[],[],[],[],[1],[],[],[],[],[1],[],[],[],[],[1],[],[],[],[],
[],[],[],[1],[],[2,12],[],[],[],[1],[],[],[],[],[],[1],[1],[],[],[1],[],[],[],
[],[],[],[],[1],[],[],[],[5],[2],[1],[1],[],[],[1],[],[],[1],[],[],[],[],[1],
[],[],[],[1],[],[],[],[],[],[2],[1],[],[],[],[],[],[],[1],[],[],[],[2],[],[],
[],[],[],[1],[],[],[],[],[],[],[],[2],[],[],[],[1],[],[1],[],[],[],[2],[],[],
[3,6],[1,10,16],[],[1],[],[1],[],[],[],[1],[],[1],[],[],[],[],[],[],[],[],[],
[2,4,5],[],[3],[],[],[],[],[],[],[],[],[],[],[],[1],[],[],[],[1],[],[1],[4],[],
[],[1],[],[],[],[],[],[],[1],[],[],[],[],[],[],[1],[],[1],[],[1],[],[1],[],[],
[],[1],[],[],[4],[],[],[],[],[],[],[],[],[],[],[],[1,3],[],[],[],[],[1],[],
[1],[],[1],[],[],[],[],[],[],[],[1],[],[],[],[],[],[],[],[],[],[1],[],[],[],
[],[],[],[],[1],[],[],[],[1],[],[],[2],[4],[],[1],[],[],[],[],[],[1],[],[],[],
[],[],[5,8],[],[4],[],[],[],[],[],[1],[2],[],[],[1],[],[],[],[],[],[1],[],[2],
[],[],[],[1],[],[],[],[],[],[1],[],[1],[2],[],[],[],[],[1],[]]));


InstallGlobalFunction(MaximalSubgroupsSymmAlt,function(arg)
local G,max,dom,n,A,S,issn,p,i,j,m,k,powdec,pd,gps,v,invol,sel,mf,l,prim;
  G:=arg[1];
  if Length(arg)>1 then
    prim:=arg[2];
  else 
    prim:=false;
  fi;
  dom:=Set(MovedPoints(G));
  n:=Length(dom);

  A:=AlternatingGroup(n);
  issn:=Size(A)<>Size(G);

  if n<3 then
    if n<=2 and not issn then
      return [];
    else
      return [TrivialSubgroup(G)];
    fi;
  fi;
  invol:=(1,2);

  if not issn then
    S:=SymmetricGroup(n);
  else
    S:=G;
  fi;
  max:=[];
  if issn then
    Add(max,A);
  fi;

  # types according to Liebeck,Praeger,Saxl paper:

  if not prim then
    # type (a): Intransitive
    # A_n is highly transitive, so we always get only one class

    # all partitions in 2 not equal parts
    p:=Filtered(Partitions(n,2),i->i[1]<>i[2]);
    for i in p do
      if issn then
	m:=DirectProduct(SymmetricGroup(i[1]),SymmetricGroup(i[2]));
      else
	if i[2]<2 then
	  m:=AlternatingGroup(i[1]);
	else
	  m:=DirectProduct(AlternatingGroup(i[1]),AlternatingGroup(i[2]));
	  # add a double transposition
	  m:=ClosureGroupAddElm(m,(1,2)(n-1,n));
	  SetSize(m,Factorial(i[1])*Factorial(i[2])/2);
	fi;
      fi;
      Add(max,m);
    od;

    # type (b): Imprimitive
    # A_n is highly transitive, so we always get only one class

    # all possible block system sizes
    p:=Difference(DivisorsInt(n),[1,n]);
    for i in p do
      # exception: Table I, 1
      if n<>8 or i<>2 or issn then
	v:=Group(SmallGeneratingSet(SymmetricGroup(i)));
	SetSize(v,Factorial(i));
	k:=Group(SmallGeneratingSet(SymmetricGroup(n/i)));
	SetSize(k,Factorial(n/i));
	m:=WreathProduct(v,k);
	if not issn then
	  m:=AlternatingSubgroup(m);
	fi;
	Add(max,m);
      fi;
    od;
  fi;

  # type (c): Affine
  p:=Factors(n);
  if Length(Set(p))=1 then
    k:=Length(p);
    p:=p[1];
    m:=GL(k,p);
    v:=AsSSortedList(GF(p)^k);
    m:=Action(m,v,OnRight);
    k:=First(v,i->not IsZero(i));
    m:=ClosureGroup(m,PermList(List(v,i->Position(v,i+k))));
    if Size(m)<Size(S) then
      if SignPermGroup(m)=1 then
	#its a subgroup of A_n, but there are two classes
	# (the normalizer in S_n cannot increase)
	if not issn then
	  Add(max,m);
	  Add(max,m^invol);
	fi;
      else
	# the (intersection with A_n) is a maximal subgroup
	if issn then
	  Add(max,m);
	else
	  # exceptions: table I and Aff(3)=A3.
	  if not n in [3,7,11,17,23] then
	    m:=AlternatingSubgroup(m);
	    Add(max,m);
	  fi;
	fi;
      fi;
    fi;
  fi;

  # type (d): Diagonal

  powdec:=PowerDecompositions(n);
  gps:=IsomorphismTypeInfoFiniteSimpleGroup(n);
  if gps<>fail then
    pd:=Concatenation([[n,1]],powdec);
    for i in pd do
      if IsBound(gps.series) then
        if gps.series="A" then
	  gps:=[AlternatingGroup(gps.parameter)];
	elif gps.series="L" then
	  gps:=[PSL(gps.parameter[1],gps.parameter[2])];
	elif gps.series="Z" then
	  gps:=[];
	fi;
      fi;
      if not IsList(gps) then
	Error("code for creation of simple groups not yet implemented");
      else
	# did we construct with some automorphisms?
	for j in [1..Length(gps)] do
	  while Size(gps[j])>n do
	    gps[j]:=DerivedSubgroup(gps[j]);
	  od;
	od;
        gps:=List(gps,i->Image(SmallerDegreePermutationRepresentation(i)));
      fi;
      for j in gps do
	m:=DiagonalSocleAction(j,i[2]+1);
	m:=Normalizer(S,m);
	if issn then
	  if SignPermGroup(m)=-1 then
	    Add(max,m);
	  fi;
	else
	  if SignPermGroup(m)=-1 then
	    Add(max,AlternatingSubgroup(m));
	  else
	    Add(max,m);
	    Add(max,m^invol);
	  fi;
	fi;
      od;
    od;
  fi;

  # type (e): Product type
  for i in powdec do
    if i[1]>4 then # up to s_4 we get a solvable normal subgroup
      m:=WreathProductProductAction(SymmetricGroup(i[1]),SymmetricGroup(i[2]));
      if issn then
	# add if not contained in A_n
	if SignPermGroup(m)=-1 then
	  Add(max,m);
	fi;
      else
	if SignPermGroup(m)=1 then
	  Add(max,m);
	  # the wreath product is alternating, so the normalizer cannot grow
	  # and there must be a second class
	  Add(max,m^invol);
	else
	  # the group is larger, so we have to intersect with A_n
	  m:=AlternatingSubgroup(m);
	  # but it might become imprimitive, use remark 2:
	  if i[2]<>2 or 2<>(i[1] mod 4) or IsPrimitive(m,[1..n]) then
	    Add(max,m);
	  fi;
	fi;
      fi;
    fi;
  od;

  # type (f): Almost simple
  if n>2499 then
    Error("tables missing");
  elif n>999 then
    # all type 2 nonalt groups of right parity
    k:=Factorial(n)/2;
    l:=AllPrimitiveGroups(DegreeOperation,n,
			  i->Size(i)<k and IsSimpleGroup(Socle(i))
			  and not IsAbelian(Socle(i)),true,
			  SignPermGroup,SignPermGroup(G));

    # remove obvious subgroups
    Sort(l,function(a,b)return Size(a)<Size(b);end);
    sel:=[];
    for i in [1..Length(l)] do
      if not ForAny([i+1..Length(l)],j->IsSubgroup(l[j],l[i])) then
        Add(sel,i);
      fi;
    od;
    l:=l{sel};

    # remove the LPS exceptions
    if n=8 then
      l:=Filtered(l,i->PrimitiveIdentification(i)<>4);
    elif n=36 then
      l:=Filtered(l,i->PrimitiveIdentification(i)<>5);
    elif n=144 then
      Error("144 exception");
    # this is the smallest 1/2q^4(q^2-1)^2. Its unlikely anyone will ever
    # try degrees that big.
    elif n>=28800 then
      Error("Possible Sp4(q) exception");
    fi;

    # go through all and test explicitly
    sel:=[1..Length(l)];
    mf:=[];
    for i in [Length(l),Length(l)-1..1] do
      if i in sel then
	Add(mf,l[i]);
	for j in [1..i] do
	  #is there a permisomorphic primitive subgroup?
	  k:=IsomorphicSubgroups(l[i],l[j]);
	  k:=List(k,Image);
	  if ForAny(k,x->IsTransitive(x,[1..n]) and IsPrimitive(x,[1..n]) and
	              PrimitiveIdentification(x)=PrimitiveIdentification(l[j]))
		      then
	    RemoveSet(sel,j);
	  fi;
	od;
      fi;
    od;
  else
    # use tables -- quicker
    if issn then
      mf:=List(SNMAXPRIMS[n],i->PrimitiveGroup(n,i));
    else
      mf:=List(ANMAXPRIMS[n],i->PrimitiveGroup(n,i));

    fi;
  fi;
  Append(max,mf);

  #An-split
  if not issn then
    for m in mf do
      # does the class split? If not, the normalizer gets bigger, i.e. there
      # is a larger primitive group in S_n
      k:=AllPrimitiveGroups(NrMovedPoints,n,SocleTypePrimitiveGroup,
	  SocleTypePrimitiveGroup(m),SignPermGroup,-1);
      k:=List(k,i->AlternatingSubgroup(i));
      if ForAll(k,j->not IsTransitive(j,[1..n]) or not IsPrimitive(j,[1..n])
	      or PrimitiveIdentification(j)<>PrimitiveIdentification(m)) then
	Add(max,m^invol);
      fi;
    od;
  fi;

  if dom<>[1..n] then
    # map on other points
    m:=MappingPermListList([1..n],dom);
    max:=List(max,i->i^m);
  fi;

  return max;
end);

InstallMethod( MaximalSubgroupClassReps, "symmetric", true,
    [ IsNaturalSymmetricGroup ], 0,
function ( G )
  return MaximalSubgroupsSymmAlt(G,false);
end);

InstallMethod( MaximalSubgroupClassReps, "alternating", true,
    [ IsNaturalAlternatingGroup ], 0,
function ( G )
  return MaximalSubgroupsSymmAlt(G,false);
end);

#############################################################################
##
#E  primitiv.gi
##

