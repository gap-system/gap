#############################################################################
##
#W  csetgrp.gi                      GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the generic operations for cosets.
##
Revision.csetgrp_gi:=
  "@(#)$Id$";

#############################################################################
##
#R  IsRightCosetDefaultRep
##
DeclareRepresentation( "IsRightCosetDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsRightCoset, [] );

#############################################################################
##
#R  IsRightCosetEnumerator
##
DeclareRepresentation( "IsRightCosetEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "groupEnumerator", "representative" ] );

InstallMethod( HomeEnumerator,
    "for a right coset",
    true,
    [ IsRightCoset ], 0,
    function( C )
    local   enum;
    
    enum := Objectify( NewType( FamilyObj( C ), IsRightCosetEnumerator ),
            rec( groupEnumerator := Enumerator( ActingDomain( C ) ),
                  representative := Representative( C ) ) );
    SetUnderlyingCollection( enum, C );
    if HasIsFinite( C ) then
      SetIsFinite( enum, IsFinite( C ) );
    fi;
    return enum;
end );

InstallMethod( \[\],
    "for right coset enumerator",
    true,
    [ IsRightCosetEnumerator, IsPosInt ], 0,
    function( enum, pos )
    return enum!.groupEnumerator[ pos ] * enum!.representative;
end );

InstallMethod( Position,
    "for right coset enumerator",
    true,
    [ IsRightCosetEnumerator, IsMultiplicativeElementWithInverse, IsInt ], 0,
    function( enum, elm, after )
    return Position( enum!.groupEnumerator, elm / enum!.representative,
                   after );
end );

#############################################################################
##
#R  IsDoubleCosetDefaultRep
##
DeclareRepresentation( "IsDoubleCosetDefaultRep",
  IsComponentObjectRep and IsAttributeStoringRep and IsDoubleCoset, [] );

InstallMethod(ComputedAscendingChains,"init",true,[IsGroup],0,G->[]);

#############################################################################
##
#F  AscendingChain(<G>,<U>) . . . . . . .  chain of subgroups G=G_1>...>G_n=U
##
InstallGlobalFunction( AscendingChain, function(G,U)
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
end );

#############################################################################
##
##  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  This routine tries to find a subgroup E of G, such that G>E>U. If U is
##  maximal, it returns fail. This is done by finding minimal blocks for
##  the operation of G on the Right Cosets of U.
##
InstallGlobalFunction( IntermediateGroup, function(G,U)
local o,b,img;

  if U=G then
    return fail;
  fi;
  o:=ActionHomomorphism(G,RightTransversal(G,U),OnRight);
  img:=ImagesSource(o);
  b:=Blocks(img,MovedPoints(img));
  if Length(b)=1 then
    return fail;
  else
    b:=StabilizerOfBlockNC(img,First(b,i->1 in i));
    b:=PreImages(o,b);
    return b;
  fi;
end );

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
BindGlobal("RefinedChain",function(G,cc)
local bound,a,b,c,cnt,r,i,j,bb,normalStep,gens;
  bound:=(10*LogInt(Size(G),10)+1)*Maximum(Factors(Size(G)));
  bound:=200;
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
	    if Index(bb,a)<20000 then
	      b:=IntermediateGroup(bb,a);
	      if b=fail then
		b:=bb;
	      fi;
	      cnt:=0;
	    else
	    # larger indices may take more tests...
	      Info(InfoCoset,1,"Random");
	      repeat
		r:=Random(bb);
	      until not(r in a);
	      if normalStep then
		b:=ClosureSubgroupNC(a,r);
              else
		# self normalizing subgroup: thus every element not in <a>
     		# will surely map one generator out
	        j:=0;
		gens:=GeneratorsOfGroup(a);
		repeat
		  j:=j+1;
                until not(gens[j]^r in a);
		r:=gens[j]^r;

		b:=ClosureSubgroupNC(a,r);
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
  a:=c[Length(c)];
  for i in [Length(c)-1,Length(c)-2..1] do
    #enforce parent relations
    if not HasParent(c[i]) then
      SetParent(c[i],a);
      a:=c[i];
    else
      a:=AsSubgroup(a,c[i]);
      c[i]:=a;
    fi;
  od;
  return c;
end);

InstallMethod( AscendingChainOp, "generic", IsIdenticalObj, [IsGroup,IsGroup],0,
function(G,U)
  return RefinedChain(G,[U,G]);
end);

InstallMethod(DoubleCoset,"generic",IsCollsElmsColls,
  [IsGroup,IsObject,IsGroup],0,
function(U,g,V)
local d,fam;
  fam:=FamilyObj(U);
  if not IsBound(fam!.doubleCosetsDefaultType) then
    fam!.doubleCosetsDefaultType:=NewType(fam,IsDoubleCosetDefaultRep
          and HasLeftActingGroup and HasRightActingGroup
	  and HasRepresentative);
  fi;
  d:=rec();
  ObjectifyWithAttributes(d,fam!.doubleCosetsDefaultType,
    LeftActingGroup,U,RightActingGroup,V,Representative,g);
  return d;
end);


InstallOtherMethod(DoubleCoset,"with size",true,
  [IsGroup,IsObject,IsGroup,IsPosInt],0,
function(U,g,V,sz)
local d,fam;
  fam:=FamilyObj(U);
  if not IsBound(fam!.doubleCosetsDefaultSizeType) then
    fam!.doubleCosetsDefaultSizeType:=NewType(fam,IsDoubleCosetDefaultRep
	  and HasSize and HasIsFinite and IsFinite
          and HasLeftActingGroup and HasRightActingGroup
	  and HasRepresentative);
  fi;
  d:=rec();
  ObjectifyWithAttributes(d,fam!.doubleCosetsDefaultSizeType,
    LeftActingGroup,U,RightActingGroup,V,Representative,g,
    Size,sz);
  return d;
end);

InstallMethod(\=,"DoubleCosets",IsIdenticalObj,[IsDoubleCoset,IsDoubleCoset],0,
function(a,b)
   return LeftActingGroup(a)=LeftActingGroup(b) and
          RightActingGroup(a)=RightActingGroup(b) and
          RepresentativesContainedRightCosets(a)
	  =RepresentativesContainedRightCosets(b);
end);

InstallMethod(PrintObj,"DoubleCoset",true,[IsDoubleCoset],0,
function(d)
  Print("DoubleCoset(",LeftActingGroup(d),",",Representative(d),",",
        RightActingGroup(d),")");
end);

InstallMethod(RepresentativesContainedRightCosets,"generic",true,
  [IsDoubleCoset],0,
function(c)
local u,v,o,i,j,img;
  u:=LeftActingGroup(c);
  v:=RightActingGroup(c);
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

InstallMethod(\in,"double coset",IsElmsColls,
  [IsMultiplicativeElementWithInverse,IsDoubleCoset],0,
function(e,d)
  return CanonicalRightCosetElement(LeftActingGroup(d),e)
        in RepresentativesContainedRightCosets(d);
end);

InstallMethod(Size,"double coset",true,[IsDoubleCoset],0,
function(d)
  return
  Size(LeftActingGroup(d))*Length(RepresentativesContainedRightCosets(d));
end);

InstallMethod(AsList,"double coset",true,[IsDoubleCoset],0,
function(d)
  return Union(List(RepresentativesContainedRightCosets(d),
                    i->RightCoset(LeftActingGroup(d),i)));
end);

RightCosetCanonicalRepresentativeDeterminator := 
function(U,a)
  return [CanonicalRightCosetElement(U,a)];
end;

InstallMethod(RightCoset,"generic",IsCollsElms,
  [IsGroup,IsObject],0,
function(U,g)
local d,fam;
  # noch tests...

  fam:=FamilyObj(U);
  if not IsBound(fam!.rightCosetsDefaultType) then
    fam!.rightCosetsDefaultType:=NewType(fam,IsRightCosetDefaultRep and
          HasActingDomain and HasFunctionAction and HasRepresentative and
	  HasCanonicalRepresentativeDeterminatorOfExternalSet);
  fi;

  d:=rec();
  ObjectifyWithAttributes(d,fam!.rightCosetsDefaultType,
    ActingDomain,U,FunctionAction,OnLeftInverse,Representative,g,
    CanonicalRepresentativeDeterminatorOfExternalSet,
    RightCosetCanonicalRepresentativeDeterminator);
  return d;
end);

InstallMethod(RightCoset,"use subgroup size",IsCollsElms,
  [IsGroup and HasSize,IsObject],0,
function(U,g)
local d,fam;
  # noch tests...

  fam:=FamilyObj(U);
  if not IsBound(fam!.rightCosetsDefaultSizeType) then
    fam!.rightCosetsDefaultSizeType:=NewType(fam,IsRightCosetDefaultRep and
          HasActingDomain and HasFunctionAction and HasRepresentative and
	  HasSize and HasCanonicalRepresentativeDeterminatorOfExternalSet);
  fi;

  d:=rec();
  ObjectifyWithAttributes(d,fam!.rightCosetsDefaultSizeType,
    ActingDomain,U,FunctionAction,OnLeftInverse,Representative,g,
    Size,Size(U),CanonicalRepresentativeDeterminatorOfExternalSet,
    RightCosetCanonicalRepresentativeDeterminator);
  return d;
end);

InstallMethod(PrintObj,"RightCoset",true,[IsRightCoset],0,
function(d)
  Print("RightCoset(",ActingDomain(d),",",Representative(d),")");
end);

InstallMethod(ViewObj,"RightCoset",true,[IsRightCoset],0,
function(d)
  Print("RightCoset(",ActingDomain(d),",",Representative(d),")");
end);

InstallMethod(\=,"RightCosets",IsIdenticalObj,[IsRightCoset,IsRightCoset],0,
function(a,b)
  return ActingDomain(a)=ActingDomain(b) and
         Representative(a)/Representative(b) in ActingDomain(a);
end);

InstallOtherMethod(\*,"RightCosets",IsCollsElms,
        [IsRightCoset,IsMultiplicativeElementWithInverse],0,
function(a,g)
    return RightCoset( ActingDomain( a ), Representative( a ) * g );
end);

# disabled because of comparison incompatibilities
#InstallMethod(\<,"RightCosets",IsIdenticalObj,[IsRightCoset,IsRightCoset],0,
#function(a,b)
#  # this comparison is *NOT* necessarily equivalent to a comparison of the 
#  # element lists!
#  if ActingDomain(a)<>ActingDomain(b) then
#    return ActingDomain(a)<ActingDomain(b);
#  fi;
#  return CanonicalRepresentativeOfExternalSet(a)
#         <CanonicalRepresentativeOfExternalSet(b);
#end);

InstallGlobalFunction( DoubleCosets, function(G,U,V)
  if not IsSubgroup(G,U) and IsSubgroup(G,V) then
    Error("not subgroups");
  fi;
  return DoubleCosetsNC(G,U,V);
end );

InstallGlobalFunction( RightCosets, function(G,U)
  if not IsSubgroup(G,U) then
    Error("not subgroups");
  fi;
  return RightCosetsNC(G,U);
end );

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
BindGlobal("CalcDoubleCosets",function(G,a,b)
local c,a1,a2,r,s,t,rg,st,i,j,nr,o,oi,nu,step,p,img,rep,
      sifa,stabs,nstab,lst,compst,e,cnt,rt,flip,dcs,unten,normal,
      lstgens,lstgensop,siz,ps,blist,bsz,indx,ep;

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

  if Index(G,a)=1 then
    return [[One(G),Size(G)]];
  fi;

  c:=AscendingChain(G,a);
  r:=[One(G)];
  stabs:=[b];
  dcs:=[];
  for step in [1..Length(c)-1] do
    a1:=c[Length(c)-step+1];
    a2:=c[Length(c)-step];
    normal:=IsNormal(a1,a2);
    indx:=Index(a1,a2);
    if normal then
      Info(InfoCoset,1,"Normal Step :",indx);
    else
      Info(InfoCoset,1,"Step :",indx);
    fi;
    

    # is this the last step?
    unten:=step=Length(c)-1;

    # shall we compute stabilizers?
    compst:=(not unten) or normal;

    t:=RightTransversal(a1,a2);
    s:=[];
    nr:=[];
    nstab:=[];
    for nu in [1..Length(r)] do
      lst:=stabs[nu];
      sifa:=Size(a2)*Size(b)/Size(lst); 
      p:=r[nu];
      blist:=BlistList([1..indx],[]);
      bsz:=indx;

      # if a2 is normal in a1, the stabilizer is the same for all Orbits of
      # right cosets. Thus we need to compute only one, and will receive all
      # others by simple calculations afterwards

      if normal then
	cnt:=1;
      else
	cnt:=indx;
      fi;

      while bsz>0 and cnt>0 do
	cnt:=cnt-1;

	# compute orbit and stabilizers for the next step
        # own Orbitalgorithm and stabilizer computation

	ps:=Position(blist,false);
	blist[ps]:=true;
	bsz:=bsz-1;
	e:=t[ps];
	o:=[e];
	oi:=[];
	oi[ps]:=1; # reverse index
	ep:=e*p;
	Add(nr,ep);

	lstgens:=GeneratorsOfGroup(lst);
	if Length(lstgens)>2 then
	  lstgens:=SmallGeneratingSet(lst);
	fi;
	lstgensop:=List(lstgens,i->p*i/p); # conjugate generators: operation
	# is on cosets a.p; we keep original cosets: Ua.p.g/p, this
	# corresponds to conjugate operation
	rep := [ One(b) ];
	st := TrivialSubgroup(G);
	i:=1;
	while i<=Length(o) do
	  for j in [1..Length(lstgens)] do
	    img:=o[i]*lstgensop[j];
	    ps:=PositionCanonical(t,img);
	    if blist[ps] then
	      if compst then
		# known image
		st := ClosureSubgroupNC(st,rep[i]*lstgens[j]/rep[oi[ps]]);
	      fi;
	    else
	      # new image
	      blist[ps]:=true;
	      bsz:=bsz-1;
	      Add(o,img);
	      Add(rep,rep[i]*lstgens[j]);
	      oi[ps]:=Length(o);
	    fi;
	  od;
	  i:=i+1;
	od;

	siz:=sifa*Length(o); #order

        if unten then
	  if flip then
	    Add(dcs,[ep^(-1),siz]);
	  else
	    Add(dcs,[ep,siz]);
	  fi;
	fi;

	if compst then
	  Add(nstab,st);
	fi;

      od;

      if normal then
	# in the normal case, we can obtain the other orbits easily via
	# the orbit theorem (same stabilizer)
	if Length(o)>1 then
	  rt:=RightTransversal(a1,
	        ClosureSubgroupNC(a2,t{Filtered([1..Length(oi)],
		                     i->IsBound(oi[i]))}));
	else
	  rt:=t;
	fi;

	for rg in rt do
          if not IsOne(rg) then
	    ps:=e*rg*p;
	    Add(nr,ps);
	    Add(nstab,st);
	    if unten then
	      if flip then
		Add(dcs,[ps^(-1),siz]);
	      else
		Add(dcs,[ps,siz]);
	      fi;
	    fi;
	  fi;
	od;
      fi;

    od;
    stabs:=nstab;
    r:=nr;
    Info(InfoCoset,3,Length(r)," double cosets so far.");
  od;

  if AssertionLevel()>1 then
    # test
    bsz:=Size(G);
    t:=[];
    if flip then
      # flip back
      c:=a;
      a:=b;
      b:=c;
    fi;
    for i in dcs do
      bsz:=bsz-i[2];
      r:=CanonicalRightCosetElement(a,i[1]);
      if ForAny(t,j->r in RepresentativesContainedRightCosets(j)) then
	Error("duplicate!");
      fi;
      r:=DoubleCoset(a,i[1],b);
      if Size(r)<>i[2] then
	Error("single size!");
      fi;
      Add(t,r);
    od;
    if bsz<>0 then
      Error("number");
    fi;
  fi;

  return dcs;
end);

InstallMethod(DoubleCosetsNC,"generic",true,
  [IsGroup,IsGroup,IsGroup],0,
function(G,U,V)
  return List(DoubleCosetRepsAndSizes(G,U,V),i->DoubleCoset(U,i[1],V,i[2]));
end);

InstallMethod(DoubleCosetRepsAndSizes,"generic",true,
  [IsGroup,IsGroup,IsGroup],0,
  CalcDoubleCosets);

#############################################################################
##
#M  RightTransversal   generic
##
InstallMethod(RightTransversalOp, "generic, use RightCosets",
  IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,U)
  return Objectify( NewType( FamilyObj( G ),
		    IsRightTransversalRep and IsList and 
		    IsDuplicateFreeList and IsAttributeStoringRep ),
          rec( group := G,
            subgroup := U,
            cosets:=RightCosets(G,U)));
end);

InstallMethod( \[\], "right transversal rep", true,
    [ IsList and IsRightTransversalRep, IsPosInt ], 0,
function( cs, num )
  return Representative(cs!.cosets[num]);
end );

InstallMethod( PositionCanonical,"RightTransversalRep", IsCollsElms,
    [ IsList and IsRightTransversalRep,
    IsMultiplicativeElementWithInverse ], 0,
function( cs, elm )
  return First([1..Index(cs!.group,cs!.subgroup)],i->elm in cs!.cosets[i]);
end );

InstallMethod(RightCosetsNC,"generic: orbit",IsIdenticalObj,
  [IsGroup,IsGroup],0,
function(G,U)
  return Orbit(G,RightCoset(U,One(U)),OnRight);
end);

# methods for groups which have a better 'RightTransversal' function
InstallMethod(RightCosetsNC,"perm groups, use RightTransversal",IsIdenticalObj,
  [IsPermGroup,IsPermGroup],0,
function(G,U)
  return List(RightTransversal(G,U),i->RightCoset(U,i));
end);

InstallMethod(RightCosetsNC,"pc groups, use RightTransversal",IsIdenticalObj,
  [IsPcGroup,IsPcGroup],0,
function(G,U)
  return List(RightTransversal(G,U),i->RightCoset(U,i));
end);


#############################################################################
##
#M  RightTransversal( <G>, <U> )  . . . . . . . . . . . . . . for trivial <U>
##
InstallMethod( RightTransversalOp,
    "for trivial subgroup, call `EnumeratorSorted' for the big group",
    IsIdenticalObj,
    [ IsGroup, IsGroup and IsTrivial ],
    100,   # the method for pc groups has this offset but shall be avoided
    function( G, U )
    return EnumeratorSorted( G );
    end );


#############################################################################
##
#E

