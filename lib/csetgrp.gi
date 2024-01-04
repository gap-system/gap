#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
local cla,clb,i,j,k,bd,r,rep,b2,dc,
  gens,conjugate;

  Info(InfoCoset,2,"call DoConjugateInto ",Size(g)," ",Size(a)," ",Size(b));
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

  if onlyone and IsSubset(a,b) then return One(g);fi;

  # match points of perm group
  if IsPermGroup(g) and IsSubset(g,a) and IsSubset(g,b) then
    # how can we map orbits into orbits?
    cla:=List(Orbits(a,MovedPoints(g)),Set);
    clb:=List(Orbits(b,MovedPoints(g)),Set);
    # no improvement if all orbits of a are fixed
    if ForAny(cla,x->ForAny(GeneratorsOfGroup(g),y->OnSets(x,y)<>x)) then
      r:=AllSubsetSummations(List(cla,Length),List(clb,Length),10^5);
      if r=fail then
        Info(InfoCoset,1,"Too many subset combinations");
      else
        Info(InfoCoset,1,"Testing ",Length(r)," combinations");
        dc:=[];
        for i in r do
          k:=List(i,x->Union(clb{x}));
          k:=RepresentativeAction(g,k,cla,OnTuplesSets);
          if k<>fail then
            Add(dc,[i,k]);
          fi;
        od;
        if Length(dc)>0 then g:=Stabilizer(g,cla,OnTuplesSets);fi;
        rep:=[];
        for i in dc do
          r:=DoConjugateInto(g,a,b^i[2],onlyone);
          if onlyone then
            if r<>fail then return i[2]*r;fi;
          else
            if r<>fail then Append(rep,List(r,x->i[2]*x));fi;
          fi;
        od;
        if onlyone then return fail; #otherwise would have found and stopped
        else return rep;fi;
      fi;
    else
      # orbits are fixed. Make sure b is so
      if ForAny(clb,x->not ForAny(cla,y->IsSubset(y,x))) then
        if onlyone then return fail;else return [];fi;
      fi;
    fi;
  fi;

  # don't try the `MorGen...` search for more than two generators if
  # generator number seems OK
  if Length(SmallGeneratingSet(b))=AbelianRank(b) and
    Length(SmallGeneratingSet(b))>2 then
    gens:=SmallGeneratingSet(b);
  elif IsPermGroup(b) and Size(b)<RootInt(NrMovedPoints(b)^3,2) then
    r:=SmallerDegreePermutationRepresentation(b:cheap);
    k:=Image(r,b);
    gens:=MorFindGeneratingSystem(k,MorMaxFusClasses(MorRatClasses(k)));
    gens:=List(gens,x->PreImagesRepresentative(r,x));
  else
    gens:=MorFindGeneratingSystem(b,MorMaxFusClasses(MorRatClasses(b)));
  fi;
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

  # use maximals, use `Try` as we call with limiting options
  IsNaturalAlternatingGroup(G);
  IsNaturalSymmetricGroup(G);
  if ValueOption("usemaximals")<>false then
    m:=TryMaximalSubgroupClassReps(G:cheap,intersize:=intersize,nolattice);
    if m<>fail and Length(m)>0 then

      m:=Filtered(m,x->Size(x) mod Size(U)=0 and Size(x)>Size(U));
      SortBy(m,x->Size(G)/Size(x));

      gens:=SmallGeneratingSet(U);
      for c in m do
        if Index(G,c)<50000 then
          t:=RightTransversal(G,c:noascendingchain); # conjugates
          for k in t do
            if ForAll(gens,x->k*x/k in c) then
              Info(InfoCoset,2,"Found Size ",Size(c));
              # U is contained in c^k
              return c^k;
            fi;
          od;
        else
          t:=DoConjugateInto(G,c,U,true:intersize:=intersize,onlyone:=true);
          if t<>fail and t<>[] then
            Info(InfoCoset,2,"Found Size ",Size(c));
            return c^(Inverse(t));
          fi;
        fi;
      od;

      Info(InfoCoset,2,"Found no intermediate subgroup ",Size(G)," ",Size(U));
      return fail;
    fi;
  fi;

  c:=ValueOption("refineChainActionLimit");
  if IsInt(c) then
    hardlimit:=c;
  else
    hardlimit:=1000000;
  fi;

  if Index(G,U)>hardlimit/10
   and ValueOption("callinintermediategroup")<>true then
    # try the `AscendingChain` mechanism
    c:=AscendingChain(G,U:cheap,refineIndex:=QuoInt(IndexNC(G,U),2),
      callinintermediategroup);
    if Length(c)>2 then
      return First(c,x->Size(x)>Size(U));
    fi;
  fi;

  if Index(G,U)>hardlimit then
    Info(InfoWarning,1,
      "will have to use permutation action of degree bigger than ", hardlimit);
  fi;

  # old code -- obsolete

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
local bound,a,b,c,cnt,r,i,j,bb,normalStep,gens,cheap,olda;
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
          #if cheap then cnt:=Minimum(cnt,50);fi;
          cnt:=Minimum(cnt,40); # as we have better intermediate
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
local d,fam,typ;
  fam:=FamilyObj(U);
  typ:=NewType(fam,IsDoubleCosetDefaultRep
          and HasIsFinite and IsFinite
          and HasLeftActingGroup and HasRightActingGroup
          and HasRepresentative);
  d:=rec();
  ObjectifyWithAttributes(d,typ,
    LeftActingGroup,U,RightActingGroup,V,Representative,g);
  SetSize(d,sz); # Size has private setter which will cause problems with
  # HasSize triggering an immediate method.
  return d;
end);

InstallMethod(\=,"DoubleCosets",IsIdenticalObj,[IsDoubleCoset,IsDoubleCoset],0,
function(a,b)
  if LeftActingGroup(a)<>LeftActingGroup(b) or
          RightActingGroup(a)<>RightActingGroup(b) then
    return false;
  fi;
  # avoid forcing RepresentativesContainedRightCosets on both if one has
  if HasRepresentativesContainedRightCosets(b) then
    if HasRepresentativesContainedRightCosets(a) then
      return RepresentativesContainedRightCosets(a)
          =RepresentativesContainedRightCosets(b);
    else
      return CanonicalRightCosetElement(LeftActingGroup(a),
         Representative(a)) in
         RepresentativesContainedRightCosets(b);
    fi;
  else
    return CanonicalRightCosetElement(LeftActingGroup(b),
        Representative(b)) in
        RepresentativesContainedRightCosets(a);
  fi;
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

  if HasSize(U) then
    # We cannot set the size in the previous ObjectifyWithAttributes as there
    # is a custom setter method. In such a case ObjectifyWithAttributes just
    # does `Objectify` and calls all setters separately which is what we want
    # to avoid here.
    SetSize(d,Size(U));
  fi;

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

InstallMethod(IsBiCoset,"test property",true,[IsRightCoset],0,
function(c)
local s,r;
  s:=ActingDomain(c);
  r:=Representative(c);
  return ForAll(GeneratorsOfGroup(s),x->x^r in s);
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
local c;
  if ActingDomain(a)<>ActingDomain(b) then TryNextMethod();fi;
  if not IsBiCoset(a) then # product does not require b to be bicoset
    ErrorNoReturn("right cosets can only be multiplied if the left operand is a bicoset");
  fi;
  c:=RightCoset(ActingDomain(a), Representative(a) * Representative(b) );
  if HasIsBiCoset(b) then
    SetIsBiCoset(c,IsBiCoset(b));
  fi;

  return c;
end);

InstallOtherMethod(InverseOp,"Right cosets",true,
  [IsRightCoset],0,
function(a)
local s,r;
  s:=ActingDomain(a);
  r:=Representative(a);
  if not IsBiCoset(a) then
    ErrorNoReturn("only right cosets which are bicosets can be inverted");
  fi;
  r:=RightCoset(s,Inverse(r));
  SetIsBiCoset(r,true);
  return r;
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


InstallMethod(Intersection2, "general cosets", IsIdenticalObj,
              [IsRightCoset,IsRightCoset],
function(cos1,cos2)
    local swap, H1, H2, x1, x2, sigma, U, rho;
    if Size(cos1) < 10 then
        TryNextMethod();
    elif Size(cos2) < 10 then
        return Intersection2(cos2, cos1);
    fi;
    if Size(cos1) > Size(cos2) then
        swap := cos1;
        cos1 := cos2;
        cos2 := swap;
    fi;
    H1:=ActingDomain(cos1);
    H2:=ActingDomain(cos2);
    x1:=Representative(cos1);
    x2:=Representative(cos2);
    sigma := x1 / x2;
    if Size(H1) = Size(H2) and H1 = H2 then
        if sigma in H1 then
            return cos1;
        else
            return [];
        fi;
    fi;
    # We want to compute the intersection of cos1 = H1*x1 with cos2 = H2*x2.
    # This is equivalent to intersecting H1 with H2*x2/x1, which is either empty
    # or equal to a coset U*rho, where U is the intersection of H1 and H2.
    # In the non-empty case, the overall result then is U*rho*x1.
    #
    # To find U*rho, we iterate over all cosets of U in H1 and for each test
    # if it is contained in H2*x2/x1, which is the case if and only if rho is
    # in H2*x2/x1, if and only if rho/(x2/x1) = rho*x1/x2 is in H2
    U:=Intersection(H1, H2);
    for rho in RightTransversal(H1, U) do
        if rho * sigma in H2 then
            return RightCoset(U, rho * x1);
        fi;
    od;
    return [];
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

# TODO: In the long run this should become a more general operation,
# but for the moment it is specialized for the application at hand
BindGlobal("DCFuseSubgroupOrbits",function(P,G,reps,act,lim,count)
local live,orbs,orbset,done,nr,p,o,os,orbitextender,bahn,i,j,enum,dict,map,pam;

  # return positive fuse number or negative position how far it got
  orbitextender:=function(o,os,start,limit,this)
  local i,gen,img,e;
    i:=start;
    while i<=Length(o) and Length(o)<limit do
      for gen in GeneratorsOfGroup(G) do
        img:=act(o[i],gen);
        e:=Position(enum,img);
        if not e in os then # duplicate? Still use os as we need to grow o
          #p:=PositionProperty(orbset,x->e in x);
          p:=LookupDictionary(dict,e);
          if p<>fail and
            # we could have found an element that we know (because of
            # fusion) to be already in this orbit (but must store)
            pam[map[p]]<>this then
            p:=map[p]; #retrieved image position might have been fused away
            return p;
          fi;
          Add(o,img);
          AddSet(os,e);
          if p=fail then AddDictionary(dict,e,this);fi;
        fi;
      od;
      i:=i+1;
    od;
    #if i>Length(o) and Length(os)>Length(o) then Error("ran out of orbit");fi;
    return -(i-1);
  end;

  bahn:=[];
  enum:=Enumerator(P);
  live:=[];
  orbs:=[];
  orbset:=[];
  done:=[];
  dict:=NewDictionary(1,true,rec(hashfun:=x->x));
  map:=[];
  pam:=[]; # reverse of map
  for nr in [1..Length(reps)] do
    #p:=PositionProperty(orbset,x->Position(enum,reps[nr]) in x);
    p:=LookupDictionary(dict,Position(enum,reps[nr]));
    if p=fail then
      # start orbit algorithm
      o:=[reps[nr]];
      os:=[Position(enum,reps[nr])];
      AddDictionary(dict,os[1],nr);
      p:=orbitextender(o,os,1,lim,nr);
      if p<0 then
        # new orbit
        Info(InfoCoset,4,nr," lives");
        Add(live,nr);
        Add(orbs,o);
        Add(orbset,os);
        Add(done,-p);
        Add(bahn,[nr]);
        map[nr]:=Length(orbs);
        pam[Length(orbs)]:=nr;
        i:=1;
        while Length(orbs)>count do
          # one orbit too many
          if ForAll(orbs,x->Length(x)>=lim) then
            if lim<20000 then
              lim:=lim*2;
            else
              lim:=(QuoInt(lim,8000)+1)*8000;
            fi;
          fi;
          Info(InfoCoset,4,"Redo ",i," ",lim);
          p:=orbitextender(orbs[i],orbset[i],done[i],lim,pam[i]);
          if p>0 then
            Info(InfoCoset,4,"Join ",i," to ",p);
            if p=i then Error("selfjoin cannot happen");fi;
            bahn[p]:=Union(bahn[p],bahn[i]);

            #UniteSet(orbset[p],orbset[i]);
            for j in [1..Length(map)] do
              if IsBound(map[j]) and map[j]=i then map[j]:=p; fi;
            od;

            # delete entry i, move higher ones one up
            for j in [1..Length(map)] do
              if IsBound(map[j]) and map[j]>i then map[j]:=map[j]-1; fi;
            od;

            # Remove entry i
            Remove(orbs,i);
            Remove(orbset,i);
            Remove(done,i);
            Remove(bahn,i);
            Remove(pam,i);
          else
            done[i]:=-p;
          fi;
          i:=i+1; if i>Length(orbs) then i:=1;fi;
        od;
      else
        Info(InfoCoset,4,nr," fuses into ",p," @",Length(os));
        map[nr]:=p; # and indeed nr itself maps to p
        AddSet(bahn[p],nr);
        #UniteSet(orbset[p],os);
        # not needed
        #for j in os do AddDictionary(dict,j,p); od;
      fi;
    else
      p:=map[p]; #retrieved image position might have been fused away
      Info(InfoCoset,4,nr," lies in ",p);
      map[nr]:=p;
      AddSet(bahn[p],nr);
      #AddDictionary(dict,Position(enum,reps[nr]),p);
    fi;
  od;
  return bahn;
end);


#############################################################################
##
#F  CalcDoubleCosets( <G>, <A>, <B> ) . . . . . . . . .  double cosets: A\G/B
##
##  DoubleCosets routine using an
##  ascending chain of subgroups from A to G, using the fact, that a
##  double coset is an union of right cosets
##
InstallGlobalFunction(CalcDoubleCosets,function(G,a,b)
local c, flip, maxidx, cano, tryfct, p, r, t,
      stabs, dcs, homs, tra, a1, a2, indx, normal, hom, omi, omiz,c1,
      unten, compst, s, nr, nstab, lst, sifa, pinv, blist, bsz, cnt,
      ps, e, mop, mo, lstgens, lstgensop, rep, st, o, oi, i, img, ep,
      siz, rt, j, canrep,step,nu,doneidx,orbcnt,posi,
      sizes,cluster,sel,lr,lstabs,ssizes,num,actfun,mayflip,rs,
      actlimit, uplimit, badlimit,avoidlimit,start,includestab,quot;

  actlimit:=300000; # maximal degree on which we try blocks
  uplimit:=10000; # maximal index for up step
  avoidlimit:=200000; # beyond this index we want to get smaller
  badlimit:=1000000; # beyond this index things might break down

  mayflip:=true; # are we allowed to flip?

  # Do we *want* stabilizers
  includestab:=ValueOption("includestab")=true;

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
  c:=AscendingChain(G,a:refineChainActionLimit:=actlimit,indoublecoset);

  # do we first go into a factor group?
  quot:=ValueOption("usequotient");
  PushOptions(rec(usequotient:=fail));# not to be used within itself
  if not IsBool(quot) then
    if IsMapping(quot) then
      a1:=KernelOfMultiplicativeGeneralMapping(quot);
    else
      a1:=quot;
      quot:=NaturalHomomorphismByNormalSubgroupNC(G,quot);
    fi;
    r:=RestrictedMapping(quot,b);
    a2:=ClosureGroup(a1,a);
    Size(a2);
    start:=PositionProperty(c,
      x->Size(x)=Size(a2) and ForAll(GeneratorsOfGroup(x),y->y in a2));
    if start=fail then Error("closure not in chain");fi;
    p:=Image(quot,G);
    c1:=Image(quot,a);
    tra:=Image(quot,b);

    dcs:=CalcDoubleCosets(p,c1,tra:includestab,usequotient:=fail);
    for i in dcs do
      # add missing stabilizers (caused by flip)
      if not IsBound(i[3]) then
        i[3]:=Intersection(c1^i[1],tra);
      fi;
    od;

    mayflip:=false;
    Info(InfoCoset,1,"Factor returns ",Length(dcs)," double cosets");
    # try kernel
    a2:=Filtered(GeneratorsOfGroup(b),x->IsOne(ImagesRepresentative(quot,x)));
    a2:=SubgroupNC(Parent(b),a2);
    Assert(2,Size(a2)*Size(tra)=Size(b));
    SetKernelOfMultiplicativeGeneralMapping(r,a2);

    dcs:=List(dcs,x->[PreImagesRepresentative(quot,x[1]),Size(a1)*x[2],
      PreImage(r,x[3])]);
    r:=List(dcs,x->x[1]);
    stabs:=List(dcs,x->x[3]);
  else
    start:=1;
    r:=[One(G)];
    stabs:=[b];
    quot:=fail;
  fi;

  # cano indicates whether there is a final up step (and thus we need to
  # form canonical representatives). ```Canonical'' means that on each
  # transversal level the orbit representative is chosen to be minimal (in
  # the transversal position).
  cano:=false;

  doneidx:=[]; # indices done already -- avoid duplicate
  if maxidx(c)>avoidlimit and mayflip then
    # try to do better

    # what about flipping (back)?
    c1:=AscendingChain(G,b:refineChainActionLimit:=actlimit,indoublecoset);
    if maxidx(c1)<=avoidlimit then
      Info(InfoCoset,1,"flip to get better chain");
      c:=b;
      b:=a;
      a:=c;
      flip:=not flip;
      c:=c1;

    elif IsPermGroup(G) then

      actlimit:=Maximum(actlimit,NrMovedPoints(G));
      avoidlimit:=Maximum(avoidlimit,NrMovedPoints(G));

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
          else
            a1:=G;
          fi;
        fi;
        Info(InfoCoset,4,"attempt up step ",obj," index:",Size(a)/Size(a1));
        if Index(G,G1)<maxidx(c) and Index(a,a1)<=uplimit and (
          maxidx(c)>avoidlimit or Size(a1)>Size(c[1])) then
          c1:=AscendingChain(G1,a1:refineIndex:=avoidlimit,
                                   refineChainActionLimit:=actlimit,
                                   indoublecoset);
          if maxidx(c1)<maxidx(c) then
            c:=Concatenation(c1,[G]);
            cano:=true;
            Info(InfoCoset,1,"improved chain with up step ",obj,
            " index:",Size(a)/Size(a1)," maxidx=",maxidx(c));
          fi;
        fi;
      end;

      rs:=Filtered(TryMaximalSubgroupClassReps(G:cheap),
        x->Index(G,x)<=5*avoidlimit);
      SortBy(rs,a->-Size(a));
      for i in rs do
        if Index(G,i)<maxidx(c) then
          p:=Intersection(a,i);
          AddSet(doneidx,Index(a,p));
          if Index(a,p)<=uplimit then
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

    if maxidx(c)>badlimit then

      rs:=ShallowCopy(TryMaximalSubgroupClassReps(a:cheap));
      rs:=Filtered(rs,x->Index(a,x)<uplimit and not Index(a,x) in doneidx);

      SortBy(rs,a->-Size(a));
      for j in rs do
        #Print("j=",Size(j),"\n");
        t:=AscendingChain(G,j:refineIndex:=avoidlimit,
                              refineChainActionLimit:=actlimit,indoublecoset);
        Info(InfoCoset,4,"maxidx ",Index(a,j)," yields ",maxidx(t),": ",
          List(t,Size));
        if maxidx(t)<maxidx(c) and (maxidx(c)>badlimit or
          # only increase up-step if index gets better by extra index
          (maxidx(c)>maxidx(t)*Size(c[1])/Size(t[1])) ) then
          c:=t;
          cano:=true;
          Info(InfoCoset,1,"improved chain with up step index:",
                Size(a)/Size(j));
        fi;

      od;

    fi;

  elif ValueOption("sisyphus")=true then
    # purely to allow for tests of up-step mechanism in smaller examples.
    # This is creating unnecessary extra work and thus should never be used
    # in practice, but will force some code to be run through.
    c:=Concatenation([TrivialSubgroup(G)],c);
    cano:=true;
  fi;

  dcs:=[];

  # Do we want to keep result for a smaller group (as cheaper fuse is possible
  # outside function at a later stage)?
  if ValueOption("noupfuse")=true then cano:=false;fi;

  Info(InfoCoset,1,"Chosen series is ",List(c,Size));
  #if ValueOption("indoublecoset")<>true then Error("GNASH");fi;

  # calculate setup for once
  homs:=[];
  tra:=[];
  for step in [start..Length(c)-1] do
    a1:=c[Length(c)-step+1];
    a2:=c[Length(c)-step];
    indx:=Index(a1,a2);
    normal:=IsNormal(a1,a2);
    # don't try to refine again for transversal, we've done so already.
    t:=RightTransversal(a1,a2:noascendingchain);
    tra[step]:=t;

    # is it worth using a permutation representation?
    if (step>1 or cano) and Length(t)<badlimit and IsPermGroup(G) and
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

  for step in [start..Length(c)-1] do
    a1:=c[Length(c)-step+1];
    a2:=c[Length(c)-step];
    normal:=IsNormal(a1,a2);
    indx:=Index(a1,a2);
    if normal then
      Info(InfoCoset,1,"Normal Step :",indx,": ",Length(r)," double cosets");
    else
      Info(InfoCoset,1,"Step :",indx,": ",Length(r)," double cosets");
    fi;


    # is this the last step?
    unten:=step=Length(c)-1 and cano=false;

    # shall we compute stabilizers?
    compst:=(not unten) or normal or includestab;

    t:=tra[step];
    hom:=homs[step];

    s:=[];
    nr:=[];
    nstab:=[];
    for nu in [1..Length(r)] do
      lst:=stabs[nu];
      Info(InfoCoset,4,"number ",nu,", |stab|=",Size(lst));
      sifa:=Size(a2)*Size(b)/Size(lst);
      p:=r[nu];
      pinv:=p^-1;
      blist:=BlistList([1..indx],[]);
      bsz:=indx;
      orbcnt:=0;

      # if a2 is normal in a1, the stabilizer is the same for all Orbits of
      # right cosets. Thus we need to compute only one, and will receive all
      # others by simple calculations afterwards

      if normal then
        cnt:=1;
      else
        cnt:=indx;
      fi;

      if cano=false and indx>20 and IsSolvableGroup(lst) then
        lstgens:=Pcgs(lst);
      else
        lstgens:=GeneratorsOfGroup(lst);
        if Length(lstgens)>2 and Length(t)>100 then
          lstgens:=SmallGeneratingSet(lst);
        fi;
      fi;

      lstgensop:=List(lstgens,i->i^pinv); # conjugate generators: operation
      # is on cosets a.p; we keep original cosets: Ua.p.g/p, this
      # corresponds to conjugate operation

      if hom<>fail then
        lstgensop:=List(lstgensop,i->Image(hom,i));
        actfun:=OnPoints;
      else
        actfun:=function(num,gen)
              return PositionCanonical(t,t[num]*gen);
            end;
      fi;

      posi:=0;
      while bsz>0 and cnt>0 do
        cnt:=cnt-1;

        # compute orbit and stabilizers for the next step
        # own Orbitalgorithm and stabilizer computation

        #while blist[posi] do posi:=posi+1;od;
        posi:=Position(blist,false,posi);
        ps:=posi;
        blist[ps]:=true;
        bsz:=bsz-1;
        e:=t[ps];
        mop:=1;
        mo:=ps;

        rep := [ One(b) ];

        o:=[ps];
        if cano or compst then
          oi:=[];
          oi[ps]:=1; # reverse index
        fi;
        orbcnt:=orbcnt+1;

        if cano=false and IsPcgs(lstgens) then

          if compst then
            o:=OrbitStabilizer(lst,o[1],lstgens,lstgensop,actfun);
            st:=o.stabilizer;
            o:=o.orbit;
          else
            o:=Orbit(lst,o[1],lstgens,lstgensop,actfun);
          fi;

          for i in o do
            blist[i]:=true;
          od;
          bsz:=bsz-Length(o)+1;

        else

          if compst then
            # stabilizing generators
            st:=Filtered(GeneratorsOfGroup(lst),
              x->PositionCanonical(r,t[ps]*x)=ps);
            if Length(st)=Length(GeneratorsOfGroup(lst)) then
              st:=lst; # immediate end -- orbit 1
            else
              st := SubgroupNC(lst,st);
            fi;
          else
            st:=TrivialSubgroup(lst);
          fi;

          i:=1;
          while i<=Length(o)
            # will not grab if nonreg,. orbit and stabilizer not computed,
            # but comparatively low cost and huge help if hom=fail
            and Size(st)*Length(o)<Size(lst) do

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
                if cano or compst then
                  Add(rep,rep[i]*lstgens[j]);
                  if cano and ps<mo then
                    mo:=ps;
                    mop:=Length(rep);
                  fi;
                  oi[ps]:=Length(o);
                fi;
              fi;
            od;
            i:=i+1;
          od;
        fi;

        Info(InfoCoset,5,"|o|=",Length(o));

        ep:=e*rep[mop]*p;
        Add(nr,ep);

        if compst then
          st:=st^rep[mop];
          Add(nstab,st);
        fi;

        if cano and step=1 and not normal then
          Add(omi,mo);
          Add(omiz,Length(o));
        fi;

        siz:=sifa*Length(o); #order

        if unten then
          if includestab then
            if flip then
              Add(dcs,[ep^(-1),siz]);
            else
              Add(dcs,[ep,siz,st]);
            fi;
          else
            if flip then
              Add(dcs,[ep^(-1),siz]);
            else
              Add(dcs,[ep,siz]);
            fi;
          fi;
        fi;

      od;
      Info(InfoCoset,4,"Get ",orbcnt," orbits");

      if normal then
        # in the normal case, we can obtain the other orbits easily via
        # the orbit theorem (same stabilizer)
        if Size(lst)/Size(st)<10 then
          # if the group `st` is handled by a nice monomorphism, the
          # identity might not be the canonical element for the subgroup.
          rt:=Orbit(lst,CanonicalRightCosetElement(st,One(st)),
            function(rep,g) return CanonicalRightCosetElement(st,rep*g);end);
        else
          rt:=RightTransversal(lst,st:noascendingchain);
        fi;
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
            if includestab then
              if flip then
                Add(dcs,[ep^(-1),siz]);
              else
                Add(dcs,[ep,siz,st]);
              fi;
            else
              if flip then
                Add(dcs,[ep^(-1),siz]);
              else
                Add(dcs,[ep,siz]);
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
          Length(lstgens)/(AbelianRank(stb)+1)*2>5 then
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
    #t:=Filtered(RightTransversal(a,a2),x->not x in a2);
    t:=RightTransversal(a,a2);
    sifa:=Size(a2)*Size(b);

    # cluster according to A-double coset sizes and C lengths
    #sizes:=List(r,x->Size(a)*Size(b)/Size(Intersection(b,a^x)));
    hom:=ActionHomomorphism(a,t,OnRight,"surjective");
    sizes:=[];
    for i in [1..Length(r)] do
      lr:=Intersection(a,b^(r[i]^-1));
      # size of double coset and
      Add(sizes,[Size(a)*Size(b)/Size(lr),
                 Length(OrbitsDomain(Image(hom,lr),[1..Length(t)],OnPoints))]);
    od;
    ps:=ShallowCopy(sizes);
    sizes:=Set(sizes); # sizes corresponding to clusters
    cluster:=List(sizes,s->Filtered([1..Length(r)],x->ps[x]=s));

    # now process per cluster
    for i in [1..Length(sizes)] do
      sel:=cluster[i];
      lr:=r{sel};
      lstabs:=stabs{sel};
      SortParallel(lr,lstabs); # quick find
      IsSSortedList(lr);
      ssizes:=List(lstabs,x->sifa/Size(x));
      num:=Sum(ssizes)/sizes[i][1]; # number of double cosets to be created
      if num>1 and sizes[i][1]/Size(a)<=10*Index(a,a2)^2 then
        # fuse orbits together
        lr:=List(lr,x->CanonicalRightCosetElement(a,x));
        o:=DCFuseSubgroupOrbits(G,b,lr,function(r,g)
            return CanonicalRightCosetElement(a,r*g);
          end,1000,num);
        for j in o do
          # record double coset
          if flip then
            Add(dcs,[lr[j[1]]^(-1),sizes[i][1]]);
          else
            Add(dcs,[lr[j[1]],sizes[i][1]]);
          fi;
          Info(InfoCoset,2,"orbit fusion ",Length(dcs)," orblen=",Length(j));
        od;
        lr:=[];lstabs:=[];
      else
        while num>1 do
          # take first representative as rep for double coset
          #stab:=Intersection(b,a^lr[1]);

          # check how does its double coset a*lr[1]*b split up into a2-DC's
          o:=OrbitsDomain(Image(hom,Intersection(a,b^(lr[1]^-1))),
                [1..Length(t)],OnPoints);

          # identify which of the a2-cosets they are they are (so we can
          # remove them)
          o:=List(o,x->Position(lr,canrep(t[x[1]]*lr[1])));

          # record double coset
          if flip then
            Add(dcs,[lr[1]^(-1),sizes[i][1]]);
          else
            Add(dcs,[lr[1],sizes[i][1]]);
          fi;
          sel:=Difference([1..Length(lr)],o);
          lr:=lr{sel};lstabs:=lstabs{sel};
          Info(InfoCoset,2,"new fusion ",Length(dcs)," orblen=",Length(o),
              " remainder ",Length(lr));

          num:=num-1;
        od;

        # remainder must be a single double coset
        if flip then
          Add(dcs,[lr[1]^(-1),sizes[i][1]]);
        else
          Add(dcs,[lr[1],sizes[i][1]]);
        fi;
        Info(InfoCoset,2,"final fusion ",Length(dcs)," orblen=",Length(lr),
            " remainder ",0);

      fi;

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

  PopOptions(); # the usequotient option
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
