#############################################################################
##
#W  csetgrp.gi                      GAP library              Alexander Hulpke
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the generic operations for cosets.
##


#############################################################################
##
#R  IsRightCosetDefaultRep
##
DeclareRepresentation( "IsRightCosetDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsRightCoset, [] );


#############################################################################
##
#M  Enumerator
##
BindGlobal( "NumberElement_RightCoset", function( enum, elm )
    return Position( enum!.groupEnumerator, elm / enum!.representative, 0 );
end );

BindGlobal( "ElementNumber_RightCoset", function( enum, pos )
    return enum!.groupEnumerator[ pos ] * enum!.representative;
end );

InstallMethod( Enumerator,
    "for a right coset",
    [ IsRightCoset ],
    function( C )
    local enum;

    enum:= EnumeratorByFunctions( C, rec(
               NumberElement     := NumberElement_RightCoset,
               ElementNumber     := ElementNumber_RightCoset,

               groupEnumerator   := Enumerator( ActingDomain( C ) ),
               representative    := Representative( C ) ) );

    SetLength( enum, Size( ActingDomain( C ) ) );

    return enum;
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

# Find element in G to conjugate B into A
# call with G,A,B;
InstallGlobalFunction(DoConjugateInto,function(g,a,b,onlyone)
local cla,clb,i,j,k,imgs,bd,r,rep,b2,ex2,split,dc,
  gens,conjugate;

  conjugate:=function(act,asub,genl,nr)
  local i,dc,j,z,r,r2,found;
    found:=[];
    Info(InfoCoset,2,"conjugate ",Size(act)," ",Size(asub)," ",nr);

    z:=Centralizer(act,genl[nr]);
    if Index(act,z)<Maximum(List(cla[nr],Size)) then
      Info(InfoCoset,2,"!orbsize ",Index(act,z));
      # asub orbits on the act-class of genl[nr]
      dc:=DoubleCosetRepsAndSizes(act,z,asub);
      for j in dc do
        z:=genl[nr]^j[1];
        if z in a then
          r:=j[1];
          if nr=Length(genl) then
            Add(found,r);
            if onlyone then return found; fi;
          else
            r2:=conjugate(Centralizer(act,z),Centralizer(asub,z),
              List(genl,x->x^r),nr+1);
            if Length(r2)>0 then
              Append(found,r*r2);
              if onlyone then return found; fi;
            fi;
          fi;
        fi;
      od;
    else
      for i in cla[nr] do
        Info(InfoCoset,2,"!classize ",Size(i)," ",
          Index(act,Centralizer(act,genl[nr]))," ",
          QuoInt(Size(a),Size(Centralizer(i))*Size(asub)));

        # split up a-classes to asub-classes
        dc:=DoubleCosetRepsAndSizes(a,Centralizer(i),asub);
        Info(InfoCoset,2,Length(dc)," double cosets");
        for j in dc do
          z:=Representative(i)^j[1];
          r:=RepresentativeAction(act,genl[nr],z);
          if r<>fail then
            if nr=Length(genl) then
              Add(found,r);
              if onlyone then return found; fi;
            else
              r2:=conjugate(Centralizer(act,z),Centralizer(asub,z),
                List(genl,x->x^r),nr+1);
              if Length(r2)>0 then
                Append(found,r*r2);
                if onlyone then return found; fi;
              fi;
            fi;
          fi;
        od;
      od;
    fi;

    return found;
  end;

  gens:=MorFindGeneratingSystem(b,MorMaxFusClasses(MorRatClasses(b)));
  clb:=ConjugacyClasses(a);
  cla:=[];
  r:=[];
  for i in gens do
    b2:=Centralizer(g,i);
    bd:=Size(Centralizer(b,i));
    k:=Order(i);
    rep:=[];
    for j in [1..Length(clb)] do
      if Order(Representative(clb[j]))=k 
         and (Size(a)/Size(clb[j])) mod bd=0 then
        if not IsBound(r[j]) then
          r[j]:=Size(Centralizer(g,Representative(clb[j])));
        fi;
        if r[j]=Size(b2) then
          Add(rep,clb[j]);
        fi;
      fi;
    od;
    if Length(rep)=0 then
      return []; # cannot have any
    fi;
    Add(cla,rep);
  od;
  r:=List(cla,x->-Maximum(List(x,Size)));
  r:=Sortex(r);
  gens:=Permuted(gens,r);
  cla:=Permuted(cla,r);

  r:=conjugate(g,a,gens,1);

  if onlyone then 
    # get one
    if Length(r)=0 then
      return fail;
    else
      return r[1];
    fi;
  fi;

  Info(InfoCoset,2,"Found ",Length(r)," reps");
  # remove duplicate groups
  rep:=[];
  b2:=[];
  for i in r do
    bd:=b^i;
    if ForAll(b2,x->RepresentativeAction(a,x,bd)=fail) then
      Add(b2,bd);
      Add(rep,i);
    fi;
  od;
  return rep;
end);


#############################################################################
##
##  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  This routine tries to find a subgroup E of G, such that G>E>U. If U is
##  maximal, it returns fail. This is done by using the maximal subgroups machinery or
##  finding minimal blocks for
##  the operation of G on the Right Cosets of U.
##
InstallGlobalFunction( IntermediateGroup, function(G,U)
local o,b,img,G1,c,m,hardlimit,gens,t,k,intersize;

  if U=G then
    return fail;
  fi;

  intersize:=Size(G);
  m:=ValueOption("intersize");
  if IsInt(m) and m<=intersize then
    return fail; # avoid infinite recursion
  fi;

  # use maximals
  m:=MaximalSubgroupClassReps(G:cheap,intersize:=intersize);

  m:=Filtered(m,x->Size(x) mod Size(U)=0 and Size(x)>Size(U));
  SortBy(m,x->Size(G)/Size(x));
  
  gens:=SmallGeneratingSet(U);
  for c in m do
    if Index(G,c)<50000 then
      t:=RightTransversal(G,c:noascendingchain); # conjugates
      for k in t do
        if ForAll(gens,x->k*x/k in c) then
	  Info(InfoCoset,2,"Found Size ",Size(c),"\n");
          # U is contained in c^k
          return c^k;
        fi;
      od;
    else
      t:=DoConjugateInto(G,c,U,true:intersize:=intersize);
      if t<>fail then 
	Info(InfoCoset,2,"Found Size ",Size(c),"\n");
        return c^(Inverse(t));
      fi;
    fi;
  od;

  Info(InfoCoset,2,"Found no intermediate subgroup ",Size(G)," ",Size(U));
  return fail;

  # old code -- obsolete

  c:=ValueOption("refineChainActionLimit");
  if IsInt(c) then
    hardlimit:=c;
  else
    hardlimit:=100000;
  fi;

  if Index(G,U)>hardlimit then return fail;fi;

  if IsPermGroup(G) and Length(GeneratorsOfGroup(G))>3 then
    G1:=Group(SmallGeneratingSet(G));
    if HasSize(G) then
      SetSize(G1,Size(G));
    fi;
    G:=G1;
  fi;
  o:=ActionHomomorphism(G,RightTransversal(G,U:noascendingchain),
    OnRight,"surjective");
  img:=Range(o);
  b:=Blocks(img,MovedPoints(img));
  if Length(b)=1 then
    return fail;
  else
    b:=StabilizerOfBlockNC(img,First(b,i->1 in i));
    b:=PreImage(o,b);
    return b;
  fi;
end );

#############################################################################
##
#F  RefinedChain(<G>,<c>) . . . . . . . . . . . . . . . .  refine chain links
##
InstallGlobalFunction(RefinedChain,function(G,cc)
local bound,a,b,c,cnt,r,i,j,bb,normalStep,gens,hardlimit,cheap,olda;
  bound:=(10*LogInt(Size(G),10)+1)*Maximum(Factors(Size(G)));
  bound:=Minimum(bound,20000);
  cheap:=ValueOption("cheap")=true;
  c:=ValueOption("refineIndex");
  if IsInt(c) then
    bound:=c;
  fi;

  c:=[];  
  for i in [2..Length(cc)] do  
    Add(c,cc[i-1]);
    if Index(cc[i],cc[i-1]) > bound then
      a:=AsSubgroup(Parent(cc[i]),cc[i-1]);
      olda:=TrivialSubgroup(a);
      while Index(cc[i],a)>bound and Size(a)>Size(olda) do
	olda:=a;
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
	  cnt:=8+2^(LogInt(Index(bb,a),9));
	  if cheap then cnt:=Minimum(cnt,50);fi;
	  repeat
	    if cnt<20 and not cheap then
	      # if random failed: do hard work
	      b:=IntermediateGroup(bb,a);
	      if b=fail then
		b:=bb;
	      fi;
	      cnt:=0;
	    else
	    # larger indices may take more tests...
	      Info(InfoCoset,5,"Random");
	      repeat
		r:=Random(bb);
	      until not(r in a);
	      if normalStep then
		# NC is safe
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

		# NC is safe
		b:=ClosureSubgroupNC(a,r);
	      fi;
	      if Size(b)<Size(bb) then
		Info(InfoCoset,1,"improvement found ",Size(bb)/Size(b));
		bb:=b;
	      fi;
	      cnt:=cnt-1;
	    fi;
	  until Index(bb,a)<=bound or cnt<1;
	fi;
	if Index(b,a)>bound and Length(c)>1 then
	  bb:=IntermediateGroup(b,c[Length(c)-1]);
	  if bb<>fail and Size(bb)>Size(c[Length(c)]) then
	    c:=Concatenation(c{[1..Length(c)-1]},[bb],Filtered(cc,x->Size(x)>=Size(b)));
	    return RefinedChain(G,c);
	  fi;
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

InstallMethod(ViewString,"DoubleCoset",true,[IsDoubleCoset],0,
function(d)
  return(STRINGIFY("DoubleCoset(\<",
                   ViewString(LeftActingGroup(d)),",\>",
                   ViewString(Representative(d)),",\>",
                   ViewString(RightActingGroup(d)),")"));
end);

InstallMethodWithRandomSource(Random,
  "for a random source and a double coset",
  [IsRandomSource, IsDoubleCoset],0,
function(rs, d)
  return Random(rs,LeftActingGroup(d))*Representative(d)
         *Random(rs,RightActingGroup(d));
end);

InstallMethod(PseudoRandom,"double coset",true,[IsDoubleCoset],0,
function(d)
  return PseudoRandom(LeftActingGroup(d))*Representative(d)
         *PseudoRandom(RightActingGroup(d));
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
local l;
  l:=Union(List(RepresentativesContainedRightCosets(d),
                    i->RightCoset(LeftActingGroup(d),i)));
  return l;
end);

#############################################################################
##
#M  Enumerator
##
BindGlobal( "ElementNumber_DoubleCoset", function( enum, pos )
    pos:= pos-1;
    return enum!.leftgroupEnumerator[ ( pos mod enum!.leftsize )+1 ] 
           * enum!.rightCosetReps[ QuoInt( pos, enum!.leftsize )+1 ];
end );

BindGlobal( "NumberElement_DoubleCoset", function( enum, elm )
    local p;

    p:= First( [ 1 .. Length( enum!.rightCosetReps ) ],
               i -> elm / enum!.rightCosetReps[i] in enum!.leftgroup );
    p:= (p-1) * enum!.leftsize
        + Position( enum!.leftgroupEnumerator,
                    elm / enum!.rightCosetReps[p], 0 );
    return p; 
end );

InstallMethod( Enumerator,
    "for a double coset",
    [ IsDoubleCoset ],
    d -> EnumeratorByFunctions( d, rec(
             NumberElement     := NumberElement_DoubleCoset,
             ElementNumber     := ElementNumber_DoubleCoset,

             leftgroupEnumerator := Enumerator( LeftActingGroup( d ) ),
             leftgroup := LeftActingGroup( d ),
             leftsize := Size( LeftActingGroup( d ) ),
             rightCosetReps := RepresentativesContainedRightCosets( d ) ) ) );


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

InstallOtherMethod(\*,"group times element",IsCollsElms,
  [IsGroup,IsMultiplicativeElementWithInverse],0,
function(s,a)
  return RightCoset(s,a);
end);

InstallMethod(ViewString,"RightCoset",true,[IsRightCoset],0,
function(d)
  return STRINGIFY("RightCoset(\<",
                    ViewString(ActingDomain(d)),",\>",
                    ViewString(Representative(d)),")");
end);

InstallMethod(PrintString,"RightCoset",true,[IsRightCoset],0,
function(d)
  return STRINGIFY("RightCoset(\<",
                    PrintString(ActingDomain(d)),",\>",
                    PrintString(Representative(d)),")");
end);

InstallMethod(PrintObj,"RightCoset",true,[IsRightCoset],0,
function(d)
  Print(PrintString(d));
end);

InstallMethod(ViewObj,"RightCoset",true,[IsRightCoset],0,
function(d)
  Print(ViewString(d));
end);

InstallMethodWithRandomSource(Random,
  "for a random source and a RightCoset",
  [IsRandomSource, IsRightCoset],0,
function(rs, d)
  return Random(rs, ActingDomain(d))*Representative(d);
end);

InstallMethod(PseudoRandom,"RightCoset",true,[IsRightCoset],0,
function(d)
  return PseudoRandom(ActingDomain(d))*Representative(d);
end);

InstallMethod(\=,"RightCosets",IsIdenticalObj,[IsRightCoset,IsRightCoset],0,
function(a,b)
  return ActingDomain(a)=ActingDomain(b) and
         Representative(a)/Representative(b) in ActingDomain(a);
end);

InstallOtherMethod(\*,"RightCoset with element",IsCollsElms,
        [IsRightCoset,IsMultiplicativeElementWithInverse],0,
function(a,g)
    return RightCoset( ActingDomain( a ), Representative( a ) * g );
end);

InstallOtherMethod(\*,"RightCosets",IsIdenticalObj,
        [IsRightCoset,IsRightCoset],0,
function(a,b)
  if ActingDomain(a)<>ActingDomain(b) then
    Error("no multiplication defined for cosets of different subgroups");
  fi;
  return RightCoset(ActingDomain(a), Representative(a) * Representative(b) );
end);

InstallOtherMethod(InverseOp,"Right cosets",true,
  [IsRightCoset],0,
function(a)
local s,r;
  s:=ActingDomain(a);
  r:=Representative(a);
  if ForAny(GeneratorsOfGroup(s),x->not x^r in s) then
    Error("Inversion only works for cosets of normal subgroups");
  fi;
  return RightCoset(s,Inverse(r));
end);

InstallOtherMethod(OneOp,"Right cosets",true,
  [IsRightCoset],0,
function(a)
  return RightCoset(ActingDomain(a),One(Representative(a)));
end);

InstallMethod(IsGeneratorsOfMagmaWithInverses,"cosets",true,
  [IsMultiplicativeElementWithInverseCollColl],0,
function(l)
local a,r;
  if Length(l)>0 and ForAll(l,IsRightCoset) then
    a:=ActingDomain(l[1]);
    r:=List(l,Representative);

    if ForAll(l,x->ActingDomain(x)=a) and
      ForAll(r,x->ForAll(GeneratorsOfGroup(a),y->y^x in a)) then
      return true;
    fi;
  fi;
  TryNextMethod();
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
  if not IsSubset(G,U) and IsSubset(G,V) then
    Error("not contained");
  fi;
  return DoubleCosetsNC(G,U,V);
end );

InstallGlobalFunction( RightCosets, function(G,U)
  if not IsSubset(G,U) then
    Error("not contained");
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
local c, flip, maxidx, refineChainActionLimit, cano, tryfct, p, r, t,
      stabs, dcs, homs, tra, a1, a2, indx, normal, hom, omi, omiz,c1,
      unten, compst, s, nr, nstab, lst, sifa, pinv, blist, bsz, cnt,
      ps, e, mop, mo, lstgens, lstgensop, rep, st, o, oi, i, img, ep,
      siz, rt, j, canrep, rsiz, step, nu,
      actlimit, uplimit, badlimit;

  actlimit:=100000; # maximal degree on which we try blocks
  uplimit:=200;
  badlimit:=50000;

  # if a is small and b large, compute cosets b\G/a and take inverses of the
  # representatives: Since we compute stabilizers in b and a chain down to
  # a, this is notably faster
  if ValueOption("noflip")<>true and 3*Size(a)<2*Size(b) then
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

  # maximal index of a series
  maxidx:=function(ser)
    return Maximum(List([1..Length(ser)-1],x->Size(ser[x+1])/Size(ser[x])));
  end;

  # compute ascending chain and refine if necessarily (we anyhow need action
  # on cosets).
  #c:=AscendingChain(G,a:refineChainActionLimit:=Index(G,a));
  c:=AscendingChain(G,a:refineChainActionLimit:=actlimit);

  # cano indicates whether there is a final up step (and thus we need to
  # form canonical representatives). ```Canonical'' means that on each
  # transversal level the orbit representative is chosen to be minimal (in
  # the transversal position).
  cano:=false;

  if maxidx(c)>badlimit then
    # try to do better

    # what about flipping (back)?
    c1:=AscendingChain(G,b:refineChainActionLimit:=actlimit);
    if maxidx(c1)<=badlimit then
      Info(InfoCoset,1,"flip to get better chain");
      c:=b;
      b:=a;
      a:=c;
      flip:=not flip;
      c:=c1;

    elif IsPermGroup(G) then

      actlimit:=Maximum(actlimit,NrMovedPoints(G));
      badlimit:=Maximum(badlimit,NrMovedPoints(G));

      tryfct:=function(obj,act)
	local G1,a1,c1;
	if IsList(act) and Length(act)=2 then
	  G1:=act[1];
	  a1:=act[2];
	else
	  #Print(maxidx(c),obj,Length(Orbit(G,obj,act))," ",
	  #          Length(Orbit(a,obj,act)),"\n");
	  G1:=Stabilizer(G,obj,act);
	  if Index(G,G1)<maxidx(c) then
	    a1:=Stabilizer(a,obj,act);
	  fi;
	fi;
	if Index(G,G1)<maxidx(c) and (
	  maxidx(c)>10*actlimit or Size(a1)>Size(c[1])) then
	  c1:=AscendingChain(G1,a1:refineChainActionLimit:=actlimit);
	  if maxidx(c1)<maxidx(c) then
	    c:=Concatenation(c1,[G]);
	    cano:=true;
	    Info(InfoCoset,1,"improved chain with up step ",obj,
	    " index:",Size(a)/Size(a1));
	  fi;
	fi;
      end;

      for i in MaximalSubgroupClassReps(G:cheap) do
	if Index(G,i)<maxidx(c) and Index(G,i)<badlimit then
	  p:=Intersection(a,i);
	  if Index(a,p)<uplimit then
	    Info(InfoCoset,3,"Try maximal of Indices ",Index(G,i),":",
	      Index(a,p));
	    tryfct("max",[i,p]);
	  fi;
	fi;
      od;

      p:=LargestMovedPoint(a);
      tryfct(p,OnPoints); 
	  
      for i in Orbits(Stabilizer(a,p),Difference(MovedPoints(a),[p])) do
	tryfct(Set([i[1],p]),OnSets);
      od;
	  
    fi;
    
    if maxidx(c)>10*actlimit then

      r:=ShallowCopy(MaximalSubgroupClassReps(a:cheap));
      r:=Filtered(r,x->Index(a,x)<uplimit);

      Sort(r,function(a,b) return Size(a)<Size(b);end);
      for j in r do
	#Print("j=",Size(j),"\n");
	t:=AscendingChain(G,j:refineChainActionLimit:=actlimit);
	if maxidx(t)<maxidx(c) and maxidx(t)<badlimit then
	  c:=t;
	  cano:=true;
	  Info(InfoCoset,1,"improved chain with up step index:",
		Size(a)/Size(j));
	fi;

      od;

    fi;

  fi;

  r:=[One(G)];
  stabs:=[b];
  dcs:=[];

  # calculate setup for once
  homs:=[];
  tra:=[];
  for step in [1..Length(c)-1] do
    a1:=c[Length(c)-step+1];
    a2:=c[Length(c)-step];
    indx:=Index(a1,a2);
    normal:=IsNormal(a1,a2);
    t:=RightTransversal(a1,a2);
    tra[step]:=t;

    # is it worth using a permutation representation?
    if (step>1 or cano) and Length(t)<actlimit and IsPermGroup(G) and 
      not normal then
      # in this case, we can beneficially compute the action once and then use
      # homomorphism methods to obtain the permutation image
      Info(InfoCoset,2,"using perm action on step ",step,": ",Length(t));
      hom:=Subgroup(G,SmallGeneratingSet(a1));
      hom:=ActionHomomorphism(hom,t,OnRight,"surjective");
    else
      hom:=fail;
    fi;
    homs[step]:=hom;
  od;

  omi:=[];
  omiz:=[];

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
    unten:=step=Length(c)-1 and cano=false;

    # shall we compute stabilizers?
    compst:=(not unten) or normal;

    t:=tra[step];
    hom:=homs[step];

    s:=[];
    nr:=[];
    nstab:=[];
    for nu in [1..Length(r)] do
      Info(InfoCoset,5,"number ",nu);
      lst:=stabs[nu];
      sifa:=Size(a2)*Size(b)/Size(lst); 
      p:=r[nu];
      pinv:=p^-1;
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
	mop:=1;
	mo:=ps;

	lstgens:=GeneratorsOfGroup(lst);
	if Length(lstgens)>2 then
	  lstgens:=SmallGeneratingSet(lst);
	fi;
	lstgensop:=List(lstgens,i->i^pinv); # conjugate generators: operation
	# is on cosets a.p; we keep original cosets: Ua.p.g/p, this
	# corresponds to conjugate operation

	rep := [ One(b) ];
	st := TrivialSubgroup(lst);

	if hom<>fail then
	  lstgensop:=List(lstgensop,i->Image(hom,i));
	fi;
	o:=[ps];
	oi:=[];
	oi[ps]:=1; # reverse index

	i:=1;
	while i<=Length(o) do
	  for j in [1..Length(lstgens)] do
	    if hom=fail then
	      img:=t[o[i]]*lstgensop[j];
	      ps:=PositionCanonical(t,img);
	    else
	      ps:=o[i]^lstgensop[j];
	    fi;
	    if blist[ps] then
	      if compst then
		# known image
		#NC is safe (initializing as TrivialSubgroup(G)
		st := ClosureSubgroupNC(st,rep[i]*lstgens[j]/rep[oi[ps]]);
	      fi;
	    else
	      # new image
	      blist[ps]:=true;
	      bsz:=bsz-1;
	      Add(o,ps);
	      Add(rep,rep[i]*lstgens[j]);
	      if cano and ps<mo then
		mo:=ps;
		mop:=Length(rep);
	      fi;
	      oi[ps]:=Length(o);
	    fi;
	  od;
	  i:=i+1;
	od;

	ep:=e*rep[mop]*p;
	st:=st^rep[mop];
	Add(nr,ep);

	if cano and step=1 and not normal then 
	  Add(omi,mo);
	  Add(omiz,Length(o));
	  #if Length(omi)=1 then
	  #  omis:=st;
	  #fi;
	fi;

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
	rt:=RightTransversal(lst,st);
	Assert(1,Length(rt)=Length(o));

	while bsz>0 do
	  ps:=Position(blist,false);
	  e:=t[ps];
	  blist[ps]:=true;

	  ep:=e*p;
	  mo:=ep;
	  mop:=ps;
	  # tick off the orbit
	  for i in rt do
	    #ps:=PositionCanonical(t,e*p*i/p);
	    j:=ep*i/p;
	    ps:=PositionCanonical(t,ep*i/p);
	    if cano then
	      if ps<mop then
		mop:=ps;
		mo:=j;
	      fi;
	    fi;
	    blist[ps]:=true;
	  od;
	  bsz:=bsz-Length(rt);

	  Add(nr,mo);
	  Add(nstab,st);

	  if unten then
	    if flip then
	      Add(dcs,[ep^(-1),siz]);
	    else
	      Add(dcs,[ep,siz]);
	    fi;
	  fi;

	od;

      fi;

    od;
    stabs:=nstab;
    r:=nr;
    Info(InfoCoset,3,Length(r)," double cosets so far.");
  od;

  if cano then
    # do the final up step

    IsSSortedList(omi);

    # canonization fct
    canrep:=function(x)
    local stb, p, pinv, t, hom,ps, mop, mo, o, oi, rep, st, lstgens, lstgensop,
          i, img, step, j,calcs;
      stb:=b;
      p:=One(G);
      for step in [1..Length(c)-1] do
	calcs:=step<Length(c)-1;
	pinv:=p^-1;
	t:=tra[step];
	hom:=homs[step];
	# orbit-stabilizer algorithm
	ps:=PositionCanonical(t,x);
	mop:=1;
	mo:=ps;
	o:=[ps];
	oi:=[];
	oi[ps]:=1;
	rep:=[One(stb)];
	st:=TrivialSubgroup(b);

	lstgens:=GeneratorsOfGroup(stb);
	if Length(lstgens)>4 and
	  Length(lstgens)/(Length(AbelianInvariants(stb))+1)*2>5 then
	  lstgens:=SmallGeneratingSet(stb);
	fi;
	lstgensop:=List(lstgens,i->i^pinv); # conjugate generators: operation

	if hom<>fail then
	  lstgensop:=List(lstgensop,i->Image(hom,i));
	fi;
	i:=1;
	while i<=Length(o) do
	  for j in [1..Length(lstgensop)] do
	    if hom=fail then
	      img:=t[o[i]]*lstgensop[j];
	      ps:=PositionCanonical(t,img);
	    else
	      ps:=o[i]^lstgensop[j];
	    fi;
	    if IsBound(oi[ps]) then
	      # known image

	      # if there is only one orbit on the top step, we know the
	      # stabilizer!
	      if calcs then
		#NC is safe (initializing as TrivialSubgroup(G)
		st := ClosureSubgroupNC(st,rep[i]*lstgens[j]/rep[oi[ps]]);
		if Size(st)*Length(o)=Size(b) then i:=Length(o);fi;
	      fi;
	      #fi;
	    else
	      Add(o,ps);
	      Add(rep,rep[i]*lstgens[j]);
	      if ps<mo then
		mo:=ps;
		mop:=Length(rep);
		if step=1 and mo in omi then
		  #Print("found\n");
		  if Size(st)*omiz[Position(omi,mo)]=Size(stb) then
		    # we have the minimum and the right stabilizer: break
		    #Print("|Orbit|=",Length(o),
		    #" of ",omiz[Position(omi,mo)]," min=",mo,"\n");
		    i:=Length(o);
		  fi;
		fi;
	      fi;
	      oi[ps]:=Length(o);
	      if Size(st)*Length(o)=Size(b) then i:=Length(o);fi;
	    fi;
	  od;
	  i:=i+1;
	od;
	
	if calcs then
	  stb:=st^(rep[mop]);
	fi;
	#if HasSmallGeneratingSet(st) then
	#  SetSmallGeneratingSet(stb,List(SmallGeneratingSet(st),x->x^rep[mop]));
	#fi;

	#else
	#  stb:=omis;
	#fi;
	x:=x*(rep[mop]^pinv)/t[mo];
	p:=t[mo]*p;
	#Print("step ",step," |Orbit|=",Length(o),"nmin=",mo,"\n");

	#if ForAny(GeneratorsOfGroup(stb),
	#     i->not x*p*i/p in t!.subgroup) then
	#     Error("RRR");
	#fi;

      od;
      return p;
    end;

    # now fuse orbits under the left action of a
    indx:=Index(a,a2);
    Info(InfoCoset,2,"fusion index ",indx);
    t:=Filtered(RightTransversal(a,a2),x->not x in a2);
    sifa:=Size(a2)*Size(b);

    SortParallel(r,stabs); # quick find
    IsSSortedList(r);

    bsz:=Length(r);
    blist:=BlistList([1..bsz],[]);
    while bsz>0 do
      ps:=Position(blist,false);
      blist[ps]:=true;
      bsz:=bsz-1;
      siz:=sifa/Size(stabs[ps]);
      rsiz:=Size(a)*Size(b)/Size(Intersection(b,a^r[ps]));
      o:=[ps];
      e:=r[ps];
      j:=1;
      while siz<rsiz do #j<=Length(t) do
	img:=t[j]*e;
	img:=canrep(img);
	ps:=Position(r,img);
	if blist[ps]=false then
	  blist[ps]:=true;
	  siz:=siz+sifa/Size(stabs[ps]);
	  bsz:=bsz-1;
	  Add(o,ps);
	fi;
	j:=j+1;
      od;
      Info(InfoCoset,4,"end at ",j-1);
      if flip then
	Add(dcs,[r[o[1]]^(-1),siz]);
      else
	Add(dcs,[r[o[1]],siz]);
      fi;
      Info(InfoCoset,2,"new fusion ",Length(dcs)," orblen=",Length(o),
           " remainder ",bsz);
    od;

  fi;

  if AssertionLevel()>2 then
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
      if AssertionLevel()>0 then
	r:=CanonicalRightCosetElement(a,i[1]);
	if ForAny(t,j->r in RepresentativesContainedRightCosets(j)) then
	  Error("duplicate!");
	fi;
      fi;
      r:=DoubleCoset(a,i[1],b);
      if AssertionLevel()>0 and Size(r)<>i[2] then
	Error("size error!");
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
DeclareRepresentation( "IsRightTransversalViaCosetsRep",
    IsRightTransversalRep,
    [ "group", "subgroup", "cosets" ] );

InstallMethod(RightTransversalOp, "generic, use RightCosets",
  IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,U)
  return Objectify( NewType( FamilyObj( G ),
		    IsRightTransversalViaCosetsRep and IsList and 
		    IsDuplicateFreeList and IsAttributeStoringRep ),
          rec( group := G,
            subgroup := U,
            cosets:=RightCosets(G,U)));
end);

InstallMethod(Length, "for a right transversal in cosets representation",
       [IsList and IsRightTransversalViaCosetsRep],
              t->Length(t!.cosets));


InstallMethod( \[\], "rt via coset", true,
    [ IsList and IsRightTransversalViaCosetsRep, IsPosInt ], 0,
function( cs, num )
  return Representative(cs!.cosets[num]);
end );

InstallMethod( PositionCanonical,"rt via coset", IsCollsElms,
    [ IsList and IsRightTransversalViaCosetsRep,
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
#M  RightTransversalOp( <G>, <U> )  . . . . . . . . . . . . . for trivial <U>
##
InstallMethod( RightTransversalOp,
    "for trivial subgroup, call `EnumeratorSorted' for the big group",
    IsIdenticalObj,
    [ IsGroup, IsGroup and IsTrivial ],
    100,   # the method for pc groups has this offset but shall be avoided
           # because  the element enumerator is faster.
function( G, U )
  if IsSubgroupFpGroup(G) then
    TryNextMethod(); # this method is bad for the fp groups.
  fi;
  return Enumerator( G );
end );

#############################################################################
##
#R  Length, \in functions for transversals via cosets rep
##
InstallMethod(Length, "for a right transversal in cosets representation",
        [IsList and IsRightTransversalViaCosetsRep],
        t->Length(t!.cosets));

InstallMethod(\in, "for a right coset with representative",
        IsElmsColls, [IsObject,IsRightCosetDefaultRep and
                HasActingDomain and HasFunctionAction and HasRepresentative],
        function(x,C)
    return x/Representative(C) in ActingDomain(C);
end);

#############################################################################
##
#R  IsFactoredTransversalRep
##
##  A transversal stored as product of several shorter transversals
DeclareRepresentation( "IsFactoredTransversalRep",
    IsRightTransversalRep,
    [ "transversals", "moduli" ] );

    # group, subgroup, list of transversals (descending)
BindGlobal("FactoredTransversal",function(G,S,t)
local trans,m,i;
  Assert(1,ForAll([1..Length(t)-1],i->t[i]!.subgroup=t[i+1]!.group));

  m:=[1];
  for i in [Length(t),Length(t)-1..2] do
    Add(m,m[Length(m)]*Length(t[i]));
  od;
  m:=Reversed(m);
  trans:=Objectify(NewType(FamilyObj(G),
			IsFactoredTransversalRep and IsList 
			and IsDuplicateFreeList and IsAttributeStoringRep),
          rec(group:=G,
	      subgroup:=S,
	      transversals:=t,
	      moduli:=m) );

  return trans;
end);

InstallMethod( \[\],"factored transversal",true,
    [ IsList and IsFactoredTransversalRep, IsPosInt ], 0,
function( t, num )
local e, m, q, i;
  num:=num-1; # indexing with 0 start
  e:=One(t!.group);
  m:=t!.moduli;
  for i in [1..Length(m)] do
    q:=QuoInt(num,m[i]);
    e:=t!.transversals[i][q+1]*e;
    num:=num mod m[i];
  od;
  return e;
end );

InstallMethod( PositionCanonical, "factored transversal", IsCollsElms,
    [ IsList and IsFactoredTransversalRep,
      IsMultiplicativeElementWithInverse ], 0,
function( t, elm )
  local num, m, p, i;
  num:=0;
  m:=t!.moduli;
  for i in [1..Length(m)] do
    p:=PositionCanonical(t!.transversals[i],elm);
    elm:=elm/t!.transversals[i][p];
    num:=num+(p-1)*m[i];
  od;
  return num+1;
end );


#############################################################################
##
#E

