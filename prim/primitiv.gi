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

InstallGlobalFunction(PrimitiveGroupsAvailable,function(deg)
  return deg in PRIMRANGE;
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
  if NrMovedPoints(grp) > 50 then
    Error("SimsNo is defined only for primitive groups of degree <= 50");
  fi;
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
    Print( "#W  AllPrimitiveGroups: Degree restricted to [ 2 .. ",
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

#############################################################################
##
#E  primitiv.gi
##

