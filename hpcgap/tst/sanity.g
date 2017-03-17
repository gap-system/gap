#############################################################################
##
#W  sanity.g                   GAP tests                     Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  St Andrews
##
##  This file runs a vast number of sanity checks on a large number of
##  groups.

SetAssertionLevel(2);

TestsForGroup:=function(G)
local u,cs,ncs,n,rep,i,au,hom,cl,co;
  Print("testing group ",G,"\n");
  cs:=CompositionSeries(G);
  ncs:=List(cs,i->Normalizer(G,i));
  Assert(1,ForAll([1..Length(cs)],i->IsNormal(ncs[i],cs[i])));
  IsSolvable(G); # enforce the (more instable) solvable algorithms even on
  Assert(1,IsNormal(G,Centre(G)));
  u:=fail;
  if Length(AbelianInvariants(CommutatorFactorGroup(G)))<6 then
    if Size(G)<500 then
      Print("subgroups\n");
      u:=ConjugacyClassesSubgroups(G);
      for i in u do
	rep:=Subgroup(G,GeneratorsOfGroup(Representative(i)));
	Assert(1,Index(G,Normalizer(G,rep))=Size(i));
	Assert(1,IsNormal(Normalizer(G,rep),rep));
      od;
    fi;
    if Size(G)<10000 then
      Print("normal subgroups\n");
      n:=NormalSubgroups(G);

      # did we already get them as subgroups?
      if u<>fail then
	Assert(1,Number(u,i->Size(i)=1)=Length(n));
      fi;

      for i in n do
	Assert(1,IsNormal(G,i));
	hom:=NaturalHomomorphismByNormalSubgroup(G,i);
	Assert(1,Index(G,i)=Size(Image(hom,G)));
	if IsSolvableGroup(i) then
	  co:=ComplementClassesRepresentatives(G,i);
	  Assert(1,ForAll(co,j->Size(j)=Index(G,i)
	                        and Size(Intersection(i,j))=1));
	  if u<>fail then
	    Assert(1,Length(co)=Number(u,
	       j->Size(Representative(j))=Index(G,i)
		  and Size(Intersection(Representative(j),i))=1));
	  fi;
	fi;
      od;
    fi;
  fi;

  Assert(1,IsNormal(G,Centre(G)));
  Print("conjugacy classes\n");
  cl:=ConjugacyClasses(G);
  Assert(1,Sum(List(cl,Size))=Size(G));
  for i in cl do
    Assert(1,Centralizer(i)=Centralizer(G,Representative(i)));
    Assert(1,Size(i)=Index(G,Centralizer(i)));
    Assert(1,Length(Orbit(Centralizer(i),Representative(i)))=1);
  od;

  Print("rational classes\n");
  cl:=RationalClasses(G);
  Assert(1,Sum(List(cl,Size))=Size(G));

  if Length(AbelianInvariants(CommutatorFactorGroup(G)))<=3 then
    Print("automorphism group\n");
    au:=AutomorphismGroup(G);
    if HasNiceMonomorphism(au) then
      AbelianInvariants(CommutatorFactorGroup(au));
    fi;
  fi;

end;

Sanity:=function(arg)
local deg,sz,anzdeg,anzsz,i,j;
  deg:=2;
  sz:=2;
  i:=0;
  j:=0;
  if Length(arg)>0 then
    deg:=arg[1];
    i:=arg[2];
    sz:=arg[3];
    j:=arg[4];
  fi;
  TransGrpLoad(deg,0);
  repeat
    Print(deg,",",i,",",sz,",",j,"\n");
    i:=i+1;
    if i>TRANSLENGTHS[deg] then
      deg:=deg+1;
      TransGrpLoad(deg,0);
      i:=1;
    fi;
    if deg<=TRANSDEGREES then
      TestsForGroup(TransitiveGroup(deg,i));
    fi;

    j:=j+1;
    if j>NumberSmallGroups(sz) then
      sz:=sz+1;
      j:=1;
    fi;
    if sz<=1000 and not sz in [512,768] then
      TestsForGroup(SmallGroup(sz,j));
    fi;

  until deg>TRANSDEGREES and sz>1000;
  Print("passed!\n");
end;



#############################################################################
##
#E  sanity.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
