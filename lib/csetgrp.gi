#############################################################################
##
#W  csetgrp.gi                      GAP library              Alexander Hulpke
##
#H  @(#)$Id:
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the generic operations for cosets.
##
Revision.csetgrp_gi:=
  "@(#)$Id$";

#############################################################################
##
#R  IsRightCosetDefaultRep
##
IsRightCosetDefaultRep := NewRepresentation( "IsRightCosetDefaultRep",
  IsComponentObjectRep and IsAttributeStoringRep and IsRightCoset, [] );

#############################################################################
##
#R  IsDoubleCosetDefaultRep
##
IsDoubleCosetDefaultRep := NewRepresentation( "IsDoubleCosetDefaultRep",
  IsComponentObjectRep and IsAttributeStoringRep and IsDoubleCoset, [] );

InstallMethod(ComputedAscendingChains,"init",true,[IsGroup],0,G->[]);

#############################################################################
##
#F  AscendingChain(<G>,<U>) . . . . . . .  chain of subgroups G=G_1>...>G_n=U
##
AscendingChain := function(G,U)
local c,i;
  if not IsSubgroup(G,U) then
    Error("not subgroup");
  fi;
  c:=ComputedAscendingChains(U);
  i:=PositionProperty(c,i->i[1]=G);
  if i=fail then
    i:=AscendingChainOp(G,U);
    Add(c,[G,i]);
    return i;
  else
    return c[i][2];
  fi;
end;

#############################################################################
##
##  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  This routine tries to find a subgroup E of G, such that G>E>U. If U is
##  maximal, it returns false. This is done by finding minimal blocks for
##  the operation of G on the Right Cosets of U.
##
IntermediateGroup := function(G,U)
local o,b;

  if U=G then
    return false;
  fi;
  o:=OperationHomomorphism(G,RightTransversal(G,U),OnRight);
  b:=Blocks(o,MovedPoints(o));
  if Length(b)=1 then
    return false;
  else
    b:=First(b,i->1 in i);
    b:=Stabilizer(ImagesSource(o),b[1],OnSets);
    b:=PreImage(o,b);
  fi;
end;

#############################################################################
##
#F  RefinedChain(<G>,<c>) . . . . . . . . . . . . . . . .  refine chain links
##
##  <c> is an ascending chain in the Group <G>. The task of this routine is
##  to refine c, i.e. if there is a "link" U>L in c with [U:L] too big,
##  this procedure tries to find Subgroups G_0,...,G_n of G; such that 
##  U=G_0>...>G_n=L. This is done by extending L inductively: Since normal
##  steps can help in further calculations, the routine first tries to
##  extend to the normalizer in U. If the subgroup is self-normalizing,
##  the group is extended via a random element. If this results in a step
##  too big, it is repeated several times to find hopefully a small
##  extension!
##
RefinedChain := function(G,cc)
local bound,a,b,c,cnt,r,i,j,bb,normalStep,gens;
  bound:=(10*LogInt(Size(G),10)+1)*Maximum(Factors(Size(G)));
  c:=[];  
  for i in [2..Length(cc)] do  
    Add(c,cc[i-1]);
    if Index(cc[i],cc[i-1]) > bound then
      a:=cc[i-1];
      while Index(cc[i],a)>bound do
	# try extension via normalizer
	b:=Normalizer(cc[i],a);
	if Size(b)>Size(a) then
	 # extension by normalizer surely is a normal step
	  normalStep:=true;
	  bb:=b;
        else
	  bb:=cc[i];
	  normalStep:=false;
	  b:=Centralizer(cc[i],Centre(a));
        fi;
	if Size(b)=Size(a) or Index(b,a)>bound then
	  cnt:=8+2^(LogInt(Index(bb,a),5)+2);
	  repeat
	    if Index(bb,a)<3000 then
	      b:=IntermediateGroup(bb,a);
	      if b=false then
		b:=bb;
	      fi;
	      cnt:=0;
	    else
	    # larger indices may take more tests...
	      Info(InfoCoset,1,"Random");
	      repeat
		r:=Random(bb);
	      until not(r in a);
	      if a.normalStep then
		b:=ClosureGroup(a,r);
              else
		# self normalizing subgroup: thus every element not in <a>
     		# will surely map one generator out
	        j:=0;
		gens:=GeneratorsOfGroup(a);
		repeat
		  j:=j+1;
                until not(gens[j]^r in a);
		r:=gens[j]^r;

		b:=ClosureGroup(a,r);
	      fi;
	      if Size(b)<Size(bb) then
		bb:=b;
		Info(InfoCoset,1,"improvement found");
	      fi;
	      cnt:=cnt-1;
	    fi;
	  until Index(bb,a)<=bound or cnt<1;
	fi;
	a:=b;
	if a<>cc[i] then #not upper level
	  Add(c,a);
	fi;
      od;
    fi;
  od;
  Add(c,cc[Length(cc)]);
  return c;
end;

InstallMethod( AscendingChainOp, "generic", IsIdentical, [IsGroup,IsGroup],0,
function(G,U)
  return RefinedChain(G,[U,G]);
end);

InstallMethod( DoubleCosetsDefaultKind, "generic", true, [IsFamily], 0,
function(f)
  return NewKind(f,IsDoubleCosetDefaultRep);
end);

InstallMethod( RightCosetsDefaultKind, "generic", true, [IsFamily], 0,
function(f)
  return NewKind(f,IsRightCosetDefaultRep);
end);

InstallMethod(DoubleCoset,"generic",IsCollsElmsColls,
  [IsGroup,IsObject,IsGroup],0,
function(U,g,V)
local d;
  # noch tests...

  d:=Objectify(DoubleCosetsDefaultKind(FamilyObj(U)),rec());
  SetLeftActingDomain(d,U);
  SetRightActingDomain(d,V);
  SetRepresentative(d,g);
  return d;
end);

InstallMethod(\=,"DoubleCosets",IsIdentical,[IsDoubleCoset,IsDoubleCoset],0,
function(a,b)
   return LeftActingDomain(a)=LeftActingDomain(b) and
          RightActingDomain(a)=RightActingDomain(b) and
          RepresentativesContainedRightCosets(a)
	  =RepresentativesContainedRightCosets(b);
end);

InstallMethod(PrintObj,"DoubleCoset",true,[IsDoubleCoset],0,
function(d)
  Print("DoubleCoset(",LeftActingDomain(d),",",Representative(d),",",
        RightActingDomain(d),")");
end);

InstallMethod(RepresentativesContainedRightCosets,"generic",true,
  [IsDoubleCoset],0,
function(c)
local u,v,o,i,j,img;
  u:=LeftActingDomain(c);
  v:=RightActingDomain(c);
  o:=[CanonicalRightCosetElement(u,Representative(c))];
  # orbit alg.
  for i in o do
    for j in GeneratorsOfGroup(v) do
      img:=CanonicalRightCosetElement(u,i*j);
      if not img in o then
        Add(o,img);
      fi;
    od;
  od;
  return Set(o);
end);

InstallMethod(RightCoset,"generic",IsCollsElms,
  [IsGroup,IsObject],0,
function(U,g)
local d;
  # noch tests...

  d:=Objectify(RightCosetsDefaultKind(FamilyObj(U)),rec());
  SetLeftActingDomain(d,U);
  SetRepresentative(d,g);
  SetSize(d,Size(U));
  return d;
end);

InstallMethod(PrintObj,"RightCoset",true,[IsRightCoset],0,
function(d)
  Print("RightCoset(",LeftActingDomain(d),",",Representative(d),")");
end);

InstallMethod(\=,"RightCosets",IsIdentical,[IsRightCoset,IsRightCoset],0,
function(a,b)
  return CanonRepObj(a)
         =CanonRepObj(b);
end);

InstallMethod(\<,"RightCosets",IsIdentical,[IsRightCoset,IsRightCoset],0,
function(a,b)
  return CanonRepObj(a)
         <CanonRepObj(b);
end);

InstallMethod(CanonRepObj,"RightCoset",true,
[IsRightCoset],0,
function(c)
  return CanonicalRightCosetElement(LeftActingDomain(c),Representative(c));
end);

DoubleCosets := function(G,U,V)
  if not IsSubgroup(G,U) and IsSubgroup(G,V) then
    Error("not subgroups");
  fi;
  return DoubleCosetsNC(G,U,V);
end;

RightCosets := function(G,U)
  if not IsSubgroup(G,U) then
    Error("not subgroups");
  fi;
  return RightCosetsNC(G,U);
end;

InstallMethod(CanonicalRightCosetElement,"generic",IsCollsElms,
  [IsGroup,IsObject],0,
function(U,e)
local l;
  l:=List(AsList(U),i->i*e); 
  return Minimum(l);
end);

#############################################################################
##
#F  CalcDoubleCosets( <G>, <A>, <B> ) . . . . . . . . .  double cosets: A\G/B
## 
##  DoubleCosets routine using an
##  ascending chain of subgroups from A to G, using the fact, that a
##  double coset is an union of right cosets
##
CalcDoubleCosets := function(G,a,b)
local c,a1,a2,r,s,t,rg,st,i,j,q,nr,o,nu,step,p,set,img,k,sch,rep,
      sifa,stabs,nstab,lst,compst,e,cnt,rt,flip,dcs,unten,pg,normal;

  # if a is small and b large, compute cosets b\G/a and take inverses of the
  # representatives: Since we compute stabilizers in b and a chain down to
  # a, this is notably faster
  if 3*Size(a)<2*Size(b) then
    c:=b;
    b:=a;
    a:=c;
    flip:=true;
    Info(InfoCoset,1,"DoubleCosetFlip");
  else
    flip:=false;
  fi;

  c:=AscendingChain(G,a);
  r:=[One(G)];
  stabs:=[b];
  dcs:=[];
  for step in [1..Length(c)-1] do
    a1:=c[Length(c)-step+1];
    a2:=c[Length(c)-step];
    normal:=IsNormal(a1,a2);
    
    Info(InfoCoset,1,"Step :",Size(a1)/Size(a2));

    # is this the last step?
    unten:=step=Length(c)-1;

    # shall we compute stabilizers?
    compst:=not(unten) or normal;

    t:=RightTransversal(a1,a2);
    s:=[];
    nr:=[];
    nstab:=[];
    for nu in [1..Length(r)] do
      lst:=stabs[nu];
      sifa:=Size(a2)*Size(b)/Size(lst); 
      p:=r[nu];

      rg:=Set(List(t,i->CanonicalRightCosetElement(a2,i*p)));

      # if a2 is normal in a1, the stabilizer is the same for all Orbits of
      # right cosets. Thus we need to compute only one, and will receive all
      # others by simple calculations afterwards

      if normal then
	cnt:=1;
      else
	cnt:=Length(rg);
      fi;

      while rg<>[] and cnt>0 do
	cnt:=cnt-1;

	# compute orbit and stabilizers for the next step
        # own Orbitalgorithm and stabilizer computation
	
	e:=rg[1];
	Add(nr,e);

	# note: e is canonic representative
	o   := [ e ];
	set := [ e ];
	rep := [ One(b) ];
	st := TrivialSubgroup(G);
	for i  in o  do
	  for j  in GeneratorsOfGroup(lst) do
	    img:=CanonicalRightCosetElement(a2,i*j);
	    if not img in set  then
	      Add( o, img );
	      AddSet( set, img );
	      Add( rep, rep[Position(o,i)]*j );
	    elif compst then
	      sch := rep[Position(o,i)]*j
		     / rep[Position(o,img)];
	      if not sch in st  then
		st := ClosureGroup(st,sch);
	      fi;
	    fi;
	  od;
	od;

        if unten then
	  if flip then
	    p:=DoubleCoset(b,e^(-1),a);
	  else
	    p:=DoubleCoset(a,e,b);
	  fi;
	  SetSize(p,sifa*Length(set));
	  Add(dcs,p);
	fi;

	SubtractSet(rg,set);

	Add(nstab,st);

      od;

      if normal then
	# in the normal case, we can obtain the other orbits easily via
	# the orbit theorem (same stabilizer)
	rt:=RightTransversal(lst,st);
	o:=sifa*Length(set); #order
	while rg<>[] do
	  e:=rg[1];
	  Add(nr,e);

	  if unten then
	    if flip then
	      p:=DoubleCoset(a,e^(-1),b);
	    else
	      p:=DoubleCoset(a,e,b);
	    fi;
	    SetSize(p,o);
	    Add(dcs,p);
	  fi;

	  SubtractSet(rg,set);
	  Add(nstab,st);
	  SubtractSet(rg,List(rt,i->CanonicalRightCosetElement(a2,e*i)));
	od;
      fi;

    od;
    stabs:=nstab;
    r:=nr;
  od;

  return dcs;
end;

InstallMethod(DoubleCosetsNC,"generic",true,
  [IsGroup,IsGroup,IsGroup],0,
function(G,U,V)
  return CalcDoubleCosets(G,U,V);
end);

InstallMethod(RightCosetsNC,"generic",true,
  [IsGroup,IsGroup],0,
function(G,U)
  return List(RightTransversal(G,U),i->RightCoset(U,i));
end);

#############################################################################
##
#E  csetgrp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
