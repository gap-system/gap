#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for finitely presented groups (fp groups).
##  Methods for subgroups of fp groups can also be found in `sgpres.gi'.
##
##  1. methods for elements of f.p. groups
##  2. methods for f.p. groups
##


#############################################################################
##
##  1. methods for elements of f.p. groups
##

#############################################################################
##
#M  ElementOfFpGroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpGroup,
    "for a family of f.p. group elements, and an assoc. word",
    true,
    [ IsElementOfFpGroupFamily, IsAssocWordWithInverse ],
    0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( PrintObj,"for an element of an f.p. group (default repres.)",
    true, [ IsElementOfFpGroup and IsPackedElementDefaultRep ], 0,
function( obj )
  Print( obj![1] );
end );

#############################################################################
##
#M  ViewObj( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( ViewObj,"for an element of an f.p. group (default repres.)",
  true, [ IsElementOfFpGroup and IsPackedElementDefaultRep ],0,
function( obj )
  View( obj![1] );
end );

#############################################################################
##
#M  String( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( String,"for an element of an f.p. group (default repres.)",
  true, [ IsElementOfFpGroup and IsPackedElementDefaultRep ],0,
function( obj )
  return String( obj![1] );
end );


#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . . . . . for element of f.p. group
##
InstallMethod( UnderlyingElement,
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep ],
    0,
    obj -> obj![1] );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( ExtRepOfObj,
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep ],
    0,
    obj -> ExtRepOfObj( obj![1] ) );

InstallOtherMethod( Length,
    "for an element of an f.p. group (default repres.)", true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep ],0,
  x->Length(UnderlyingElement(x)));

InstallOtherMethod(Subword,"for an element of an f.p. group (default repres.)",true,
    [ IsElementOfFpGroup and IsPackedElementDefaultRep, IsInt, IsInt ],0,
function(word,a,b)
  return ElementOfFpGroup(FamilyObj(word),Subword(UnderlyingElement(word),a,b));
end);


#############################################################################
##
#M  InverseOp( <elm> )  . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( InverseOp, "for an element of an f.p. group", true,
    [ IsElementOfFpGroup ],0,
function(obj)
local fam,w;
  fam:= FamilyObj( obj );
  w:=Inverse(UnderlyingElement(obj));
  if HasFpElementNFFunction(fam) and
    IsBound(fam!.reduce) and fam!.reduce=true then
    w:=FpElementNFFunction(fam)(w);
  fi;
  return ElementOfFpGroup( fam,w);
end );

#############################################################################
##
#M  One( <fam> )  . . . . . . . . . . . . . for family of f.p. group elements
##
InstallOtherMethod( One,
    "for a family of f.p. group elements",
    true,
    [ IsElementOfFpGroupFamily ],
    0,
    fam -> ElementOfFpGroup( fam, One( fam!.freeGroup ) ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( One, "for an f.p. group element", true, [ IsElementOfFpGroup ],
    0, obj -> One( FamilyObj( obj ) ) );

# a^0 calls OneOp, so we have to catch this as well.
InstallMethod( OneOp, "for an f.p. group element", true,[IsElementOfFpGroup ],
    0, obj -> One( FamilyObj( obj ) ) );


#############################################################################
##
#M  \*( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \*, "for two f.p. group elements",
    IsIdenticalObj, [ IsElementOfFpGroup, IsElementOfFpGroup ], 0,
function( left, right )
local fam,w;
  fam:= FamilyObj( left );
  w:=UnderlyingElement(left)*UnderlyingElement(right);
  if HasFpElementNFFunction(fam) and
    IsBound(fam!.reduce) and fam!.reduce=true then
    w:=FpElementNFFunction(fam)(w);
  fi;
  return ElementOfFpGroup( fam,w);
end );

#############################################################################
##
#M  \=( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \=, "for two f.p. group elements", IsIdenticalObj,
    [ IsElementOfFpGroup, IsElementOfFpGroup ],0,
# this is the only method that may ever be called!
function( left, right )
  if UnderlyingElement(left)=UnderlyingElement(right) then
    return true;
  fi;
  return FpElmEqualityMethod(FamilyObj(left))(left,right);
end );

#############################################################################
##
#M  \<( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \<, "for two f.p. group elements", IsIdenticalObj,
    [ IsElementOfFpGroup, IsElementOfFpGroup ],0,
# this is the only method that may ever be called!
function( left, right )
  return FpElmComparisonMethod(FamilyObj(left))(left,right);
end );

InstallMethod(FPFaithHom,"try perm or pc hom",true,[IsFamily],0,
function( fam )
local hom,gp,f;
  gp:=CollectionsFamily(fam)!.wholeGroup;
  if HasIsFinite(gp) and not IsFinite(gp) then
    return fail;
  fi;
  if HasIsomorphismPermGroup(gp) then return IsomorphismPermGroup(gp); fi;
  if HasIsomorphismPcGroup(gp) then return IsomorphismPcGroup(gp); fi;

  if HasSize(gp) then
    f:=Factors(Size(gp));
    if Length(Set(f))=1 then
      SetIsPGroup(gp,true);
      SetPrimePGroup(gp,f[1]);
    elif Length(Set(f))=2 then
      SetIsSolvableGroup(gp,true);
    fi;
  fi;
  if HasIsPGroup(gp) and IsPGroup(gp) then
    if Size(gp)=1 then
      # special case trivial group
      hom:=GroupHomomorphismByImagesNC(gp,Group(()),
             GeneratorsOfGroup(gp),
             List(GeneratorsOfGroup(gp),x->()));
      SetEpimorphismFromFreeGroup(Image(hom),
        GroupHomomorphismByImagesNC(FreeGroupOfFpGroup(gp),Image(hom),
          FreeGeneratorsOfFpGroup(gp),
          List(GeneratorsOfGroup(gp),x->Image(hom,x))));
      return hom;
    fi;
    # nilpotent
    f:=Factors(Size(gp));
    hom:=EpimorphismPGroup(gp,f[1],Length(f));
  elif HasIsSolvableGroup(gp) and IsSolvableGroup(gp) and
    not (HasSize(gp) and Size(gp)=infinity) then
    # solvable
    hom:=EpimorphismSolvableQuotient(gp,Size(gp));
    if Size(Image(hom))<>Size(gp) then
      hom:=IsomorphismPermGroup(gp);
    fi;
  elif HasSize(gp) and Size(gp)<=10000 then
    hom:=IsomorphismPermGroup(gp);
  else
    hom:=IsomorphismPermGroupOrFailFpGroup(gp);
  fi;
  if hom<>fail then
    SetEpimorphismFromFreeGroup(Image(hom),
      GroupHomomorphismByImagesNC(FreeGroupOfFpGroup(gp),Image(hom),
         FreeGeneratorsOfFpGroup(gp),
         List(GeneratorsOfGroup(gp),x->Image(hom,x))));
  fi;
  return hom;
end);

# the heuristics about what comparison methods to use for < and = are all
# concentrated in the following function to make the decision tree clear
# without having to rely on method ranking and to ensure that both < and =
# are treated the same way.
# Note that the total ordering used may depend on what is known about the
# group at the time of the first comparison. (See manual) (See manual) (See
# manual) (See manual)
BindGlobal( "MakeFpGroupCompMethod", function(CMP)
  return function(fam)
    local hom,f,com;
    # if a normal form method is known, and it is not known to be crummy
    if HasFpElementNFFunction(fam) and not IsBound(fam!.hascrudeFPENFF) then
      f:=FpElementNFFunction(fam);
      com:=x->f(UnderlyingElement(x));
    # if we know a faithful representation, use it
    elif HasFPFaithHom(fam) and
     FPFaithHom(fam)<>fail then
      hom:=FPFaithHom(fam);
      com:=x->Image(hom,x);
    # if neither is known, try a faithful representation (forcing its
    # computation)
    elif FPFaithHom(fam)<>fail then
      hom:=FPFaithHom(fam);
      com:=x->Image(hom,x);
    #T Here one could try more elaborate things first
    # otherwise force computation of a normal form.
    else
      f:=FpElementNFFunction(fam);
      com:=x->f(UnderlyingElement(x));
    fi;
    SetCanEasilyCompareElements(fam,true);
    SetCanEasilySortElements(fam,true);
    # now build the comparison function
    return function(left,right)
             return CMP(com(left),com(right));
           end;
  end;
end );

InstallMethod( FpElmEqualityMethod, "generic dispatcher",
true,[IsElementOfFpGroupFamily],0,MakeFpGroupCompMethod(\=));

InstallMethod( FpElmComparisonMethod, "generic dispatcher", true,
[IsElementOfFpGroupFamily],0,MakeFpGroupCompMethod(\<));


#############################################################################
##
#M  Order <elm> )
##
InstallMethod( Order,"fp group element", [ IsElementOfFpGroup ],0,
function( elm )
local fam;
   fam:=FamilyObj(elm);
   if not HasFPFaithHom(fam) or FPFaithHom(fam)=fail then
     TryNextMethod(); # don't try the hard way
   fi;
   return Order(Image(FPFaithHom(fam),elm));
end );

#############################################################################
##
#M  Random <gp> )
##
InstallMethodWithRandomSource( Random,
    "for a random source and an fp group",
    [ IsRandomSource, IsSubgroupFpGroup and IsFinite],
function( rs, gp )
local fam,hom;
  fam:=ElementsFamily(FamilyObj(gp));
  hom:=FPFaithHom(fam);
  if hom=fail then
     TryNextMethod();
  fi;
  return PreImagesRepresentative(hom,Random(rs, Image(hom,gp)));
end );

#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
InstallOtherMethod( MappedWord,"for fp group element",IsElmsCollsX,
    [ IsPackedElementDefaultRep, IsElementOfFpGroupCollection and IsList,
      IsList ],
    0,
function(w,g,i)
  # just defer to the underlying elements, then use the good method there
  return MappedWord(UnderlyingElement(w),List(g,UnderlyingElement),i);
end);

#############################################################################
##
#M  FpGrpMonSmgOfFpGrpMonSmgElement(<elm>)
##
InstallMethod(FpGrpMonSmgOfFpGrpMonSmgElement,
  "for an element of an fp group", true,
  [IsElementOfFpGroup], 0,
  x -> CollectionsFamily(FamilyObj(x))!.wholeGroup);


#############################################################################
##
##  2. methods for f.p. groups
##

InstallGlobalFunction(IndexCosetTab,function(t)
  if Length(t)=0 then
    return 1;
  else
    return Length(t[1]);
  fi;
end);

InstallMethod( PseudoRandom,"subgroups fp group: force generators",true,
    [IsSubgroupFpGroup],0,
function( grp )
local gens, lim, n, r, l, w, a,la,f,up;
  gens:=GeneratorsOfGroup(grp);
  lim:=ValueOption("radius");
  if lim=fail then
    return Group_PseudoRandom(grp);
  else
    n:=2*Length(gens)-1;
    if not IsBound(grp!.randomrange) or lim<>grp!.randlim then
      # there are 1+(n+1)(1+n+n^2+...+n^(lim-1))=(n^lim*(n+1)-2)/(n-1)
      # words of length up to lim in the free group on |gens| generators
      if n=1 then
        grp!.randomrange:=[1..Minimum(lim,2^28-1)];
        f:=1;
      else
        up:=(n^lim*(n+1)-2)/(n-1);
        if up>=2^28 then
          f:=Int(up/2^28+1);
          grp!.randomrange:=[1..2^28-1];
        else
          grp!.randomrange:=[1..up];
          f:=1;
        fi;
      fi;
      l:=[Int(1/f),Int((n+2)/f)];
      a:=n+1;
      for r in [2..lim+1] do
        a:=a*n;
        l[r+1]:=l[r]+Maximum(1,Int(a/f));
      od;
      grp!.randdist:=l;
      grp!.randlim:=lim;
    fi;
    r:=Random(grp!.randomrange); # equal distribution of uncancelled words
    l:=1;
    while r>grp!.randdist[l] do
      l:=l+1;
    od;
    l:=l-1;
    # we multiply a lot here, but multiplication is cheap
    w:=One(grp);
    la:=false;
    n:=n+1;
    for r in [1..l] do
      repeat
        a:=Random(1,n);
      until a<>la;
      if a>Length(gens) then
        la:=a-Length(gens);
        w:=w/gens[la];
      else
        w:=w*gens[a];
        la:=a+Length(gens);
      fi;
    od;
    return w;
  fi;
end);

#############################################################################
##
#M  SubgroupOfWholeGroupByCosetTable(<fpfam>,<tab>)
##
InstallGlobalFunction(SubgroupOfWholeGroupByCosetTable,function(fam,tab)
local S;
  S := Objectify(NewType(fam,IsGroup and IsAttributeStoringRep ),
        rec() );
  SetParent(S,fam!.wholeGroup);
  SetCosetTableInWholeGroup(S,tab);
  SetIndexInWholeGroup(S,IndexCosetTab(tab));
  return S;
end);

#############################################################################
##
#M  SubgroupOfWholeGroupByQuotientSubgroup(<fpfam>,<Q>,<U>)
##
InstallGlobalFunction(SubgroupOfWholeGroupByQuotientSubgroup,function(fam,Q,U)
local S;
#  if (IsPermGroup(Q) or IsPcGroup(Q)) and Index(Q,U)=1 then
#    # we get the full group
#    S:=fam!.wholeGroup;
#    if not IsBound(S!.quot) then # in case some algorithm wants it
#      S!.quot:=GroupWithGenerators(List(GeneratorsOfGroup(S),i->()));
#      S!.sub:=S!.quot;
#    fi;
#    return S;
#  fi;

  Assert(1,Length(GeneratorsOfGroup(Q))=Length(GeneratorsOfGroup(fam!.wholeGroup)));
  S := Objectify(NewType(fam, IsGroup and
    IsSubgroupOfWholeGroupByQuotientRep and IsAttributeStoringRep ),
        rec(quot:=Q,sub:=U) );
  SetParent(S,fam!.wholeGroup);
  if CanComputeIndex(Q,U) and HasSize(Q) then
    SetIndexInWholeGroup(S,IndexNC(Q,U));
    if IndexNC(Q,U)<infinity then
      SetIsFinitelyGeneratedGroup(S,true);
    fi;
  elif HasIsFinite(Q) and IsFinite(Q) then
    SetIsFinitelyGeneratedGroup(S,true);
  fi;
  # transfer normality information
  if (HasIsNormalInParent(U) and Q=Parent(U)) or
    (HasGeneratorsOfGroup(U) and Length(GeneratorsOfGroup(U))=0) or
    (CanComputeSize(U) and Size(U)=1) then
      SetIsNormalInParent(S,true);
  fi;
  return S;
end);


BindGlobal("MakeNiceDirectQuots",function(G,H)
  local hom, a, b;
  if not ((IsPermGroup(G!.quot) and IsPermGroup(H!.quot)) or
          (IsPcGroup(G!.quot) and IsPcGroup(H!.quot))) then
    # force permrep
    if not IsPermGroup(G!.quot) then
      hom:=IsomorphismPermGroup(G!.quot);
      a:=GroupWithGenerators(
        List(GeneratorsOfGroup(G!.quot),i->Image(hom,i)),());
      b:=Image(hom,G!.sub);
      G:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),a,b);
    fi;

    if not IsPermGroup(H!.quot) then
      hom:=IsomorphismPermGroup(H!.quot);
      a:=GroupWithGenerators(
        List(GeneratorsOfGroup(H!.quot),i->Image(hom,i)),());
      b:=Image(hom,H!.sub);
      H:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(H),a,b);
    fi;
  fi;
  return [G,H];
end);


InstallGlobalFunction(TracedCosetFpGroup,function(t,elm,p)
local i,j,e,pos,ex;
  ex:=ExtRepOfObj(elm);
  for i in [1,3..(Length(ex)-1)] do
    e:=ex[i+1];
    if e<0 then
      pos:=2*ex[i];
      e:=-e;
    else
      pos:=2*ex[i]-1;
    fi;
    for j in [1..e] do
      p:=t[pos][p];
    od;
  od;
  return p;
end);


#############################################################################
##
#M  \in ( <elm>, <U> )  in subgroup of fp group
##
InstallMethod( \in, "subgroup of fp group", IsElmsColls,
  [ IsMultiplicativeElementWithInverse, IsSubgroupFpGroup ], 0,
function(elm,U)
  return TracedCosetFpGroup(CosetTableInWholeGroup(U),
                            UnderlyingElement(elm),1)=1;
end);

InstallMethod( \in, "subgroup of fp group by quotient rep", IsElmsColls,
  [ IsMultiplicativeElementWithInverse,
    IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(elm,U)
  # transfer elm in factor
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),
                  GeneratorsOfGroup(U!.quot));

  return elm in U!.sub;
end);


#############################################################################
##
#M  \=( <U>, <V> )  . . . . . . . . .  for two subgroups of a f.p. group
##
InstallMethod( \=, "subgroups of fp group", IsIdenticalObj,
    [ IsSubgroupFpGroup, IsSubgroupFpGroup ], 0,
function( left, right )
  return IndexInWholeGroup(left)=IndexInWholeGroup(right)
         and IsSubset(left,right) and IsSubset(right,left);
end );

#############################################################################
##
#M  IsSubset( <U>, <V> )  . . . . . . . . .  for two subgroups of a f.p. group
##
InstallMethod( IsSubset, "subgroups of fp group: test generators",
  IsIdenticalObj,
  [ IsSubgroupFpGroup, # don't use the `CanEasilyTestMembership' filter here
                       # as the generator list may be empty.
    IsSubgroupFpGroup and HasGeneratorsOfGroup], 0,
function(left,right)
  if Length(GeneratorsOfGroup(right))>0
    and not CanEasilyTestMembership(left) then
    TryNextMethod();
  fi;
  return ForAll(GeneratorsOfGroup(right),i->i in left);
end);

InstallMethod(IsSubset,"subgroups of fp group by quot. rep",IsIdenticalObj,
    [ IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
local A,B,U,V,W,E,F,map;
  # trivial plausibility
  if HasIndexInWholeGroup(G) and HasIndexInWholeGroup(H) and
      IndexInWholeGroup(G)>IndexInWholeGroup(H) then
    return false;
  fi;

  A:=G!.quot;
  B:=H!.quot;
  U:=G!.sub;
  V:=H!.sub;
  # are we represented in the same quotient?
  if GeneratorsOfGroup(A)=GeneratorsOfGroup(B) then
    # we are, compare simply in the quotient
    return IsSubset(U,V);
  fi;

  # now we have to test ``subsetness'' in the subdirect product defined by
  # the quotients. WLOG the whole group is this subdirect product S
  #   A  |   |S  | B      Let E<A and F<B be the normal subgroups
  #      |   |   |        whose factors are glued together. We have
  #  E  /   / \   \  F    E=(ker(S->B))->A
  #    /   /   \   \      F=(ker(S->A))->B
  #        \   /
  #         \ /
  #  Then G>H if and only if the following two conditions hold:
  #  1) The image of G in B contains V.
  #  2) G contains ker(S->B) (so with 1 it is sufficient, this is trivially
  #     necessary as H contains this kernel).
  #     This condition is fulfilled, if U>E

  #  To compute this, first note that F is generated (as normal subgroup) by
  #  the relators of A evaluated in the generators of B. This is the
  #  coKernel of a mapping A->B
  if not IsTrivial(V) then
    map:=GroupGeneralMappingByImagesNC(A,B,GeneratorsOfGroup(A),
                                        GeneratorsOfGroup(B));
    F:=CoKernelOfMultiplicativeGeneralMapping(map);
    W:=ClosureGroup(F,
                    List(GeneratorsOfGroup(U),i->ImagesRepresentative(map,i)));
    if not IsSubset(W,V) then
      return false; # condition 1
    fi;
  fi;

  map:=GroupGeneralMappingByImagesNC(B,A,GeneratorsOfGroup(B),
                                       GeneratorsOfGroup(A));
  E:=CoKernelOfMultiplicativeGeneralMapping(map);
  return IsSubset(U,E);
end);

InstallMethod( IsSubset, "subgp fp group: via quotient rep", IsIdenticalObj,
  [ IsSubgroupFpGroup, IsSubgroupFpGroup ], 0,
function(left,right)
  return IsSubset(AsSubgroupOfWholeGroupByQuotient(left),
                  AsSubgroupOfWholeGroupByQuotient(right));
end);

InstallMethod( CanComputeIsSubset, "whole fp family group", IsIdenticalObj,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup ], 0,
    ReturnTrue);

InstallMethod(IsNormalOp,"subgroups of fp group by quot. rep in full fp grp.",
  IsIdenticalObj, [ IsSubgroupFpGroup and IsWholeFamily,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
  return IsNormal(H!.quot,H!.sub);
end);

InstallMethod(IsFinitelyGeneratedGroup,"subgroups of fp group",true,
  [IsSubgroupFpGroup],0,
function(U)
local G;
  G:=FamilyObj(U)!.wholeGroup;
  if not IsFinitelyGeneratedGroup(G) then
    TryNextMethod();
  fi;
  if CanComputeIndex(G,U) and Index(G,U)<infinity  then
    return true;
  fi;
  Info(InfoWarning,1,
    "Forcing index computation to test whether subgroup is finitely generated"
    );
 if Index(G,U)<infinity then
   return true;
 fi;
 TryNextMethod(); # give up
end);

#############################################################################
##
#M  GeneratorsOfGroup( <F> )  . . . . . . . . . . . . . . .  for a f.p. group
##
InstallMethod( GeneratorsOfGroup, "for whole family f.p. group", true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function( F )
local Fam;
  Fam:= ElementsFamily( FamilyObj( F ) );
  return List( FreeGeneratorsOfFpGroup( F ), g -> ElementOfFpGroup( Fam, g ) );
end );


#############################################################################
##
#M  AbelianInvariants( <G> ) . . . . . . . . . . . . . . . . . for a fp group
##
InstallMethod( AbelianInvariants,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   mat,        # relator matrix of <G>
            gens,       # generators of free group
            genind,     # their indices
            row,        # a row of <mat>
            rel,        # a relator of <G>
            p,          # position of <g> or its inverse in <gens>
            i,          # loop variable
            word,
            inv;

    gens := FreeGeneratorsOfFpGroup( G );
    genind:=List(gens,i->AbsInt(LetterRepAssocWord(i)[1]));

    # handle groups with no relators
    if IsEmpty( RelatorsOfFpGroup( G ) ) then
        return [ 1 .. Length( gens ) ] * 0;
    fi;

    # make the relator matrix
    mat := [];
    for rel  in RelatorsOfFpGroup( G ) do
        row := [];
        for i  in [ 1 .. Length( gens ) ]  do
          row[i] := 0;
        od;
        #for i  in [ 1 .. NrSyllables( rel ) ]  do
        #  p := Position( genind, GeneratorSyllable(rel,i));
        #  row[p]:=row[p]+ExponentSyllable(rel,i);
        #od;
        word:=LetterRepAssocWord(rel);
        for i in [1..Length(rel)] do
          p:=Position(genind,AbsInt(word[i]));
          row[p]:=row[p]+SignInt(word[i]);
        od;
        Add( mat, row );
    od;

    # diagonalize the matrix
    DiagonalizeMat( Integers, mat );

    # return the abelian invariants
    inv:=AbelianInvariantsOfList( DiagonalOfMat( mat ) );
    if 0 in inv then
      SetSize(G,infinity);
    elif Length(gens)=1 or (HasIsAbelian(G) and IsAbelian(G)) then
      # abelian
      SetSize(G,Product(inv));
    fi;
    return inv;
end );


#############################################################################
##
#M  AbelianInvariants( <H> ) . . . . . . . . . . for a subgroup of a fp group
##
InstallMethod( AbelianInvariants,
  "for a subgroup of a finitely presented group", true,
  [ IsSubgroupFpGroup ], 0,
function(H)

    local G,inv;

    if IsGroupOfFamily(H) then
      TryNextMethod();
    fi;

    # Get the whole group `G' of `H'.
    G:= FamilyObj(H)!.wholeGroup;

    # Call the global function for subgroups of f.p. groups.
    inv:=AbelianInvariantsSubgroupFpGroup( G, H );
    if 0 in inv then
      SetSize(H,infinity);
    elif HasIsAbelian(H) and IsAbelian(H) then
      # abelian
      SetSize(H,Product(inv));
    fi;
    return inv;
end );

#############################################################################
##
#M  IsInfiniteAbelianizationGroup( <G> ) . . . . . . . . . . . for a fp group
##
BindGlobal("HasFullColumnRankIntMatDestructive",function( mat )
  local n, rb, next, primes, mp, r, pm, ns, nns, j, p, i;
  n:=Length(mat[1]);
  if Length(mat)<n then
    return false;
  fi;
  # first check modulo some primes
  rb:=0;
  next:=7;
  primes:=[2,7,251];
  for p in primes do
    mp:=ImmutableMatrix(p,mat*Z(p)^0);
    r:=RankMat(mp);
    if rb>0 and r<>rb and next<250 then
      next:=NextPrimeInt(next);
      Add(primes,next);
    fi;
    rb:=Maximum(r,rb);
    Info(InfoMatrix,2,"Rank modulo ",p,":",r);
    if rb=n then
      return true;
    fi;
    if p=251 then
      pm:=125;
      ns:=NullspaceMat(TransposedMat(mp));
      nns:=[];
      for i in ns do
        r:=List(i,Int);
        for j in [1..Length(r)] do
          if r[j]>pm then r[j]:=r[j]-p;fi;
        od;
        if IsZero(mat*r) then
          Info(InfoMatrix,2,"Kernel element modulo lifts!");
          return false;
        fi;
        Add(nns,r);
      od;
    fi;
  od;
  if rb<n-1 then
    # the modulo calculation gesses rank `rb'. If this is the rank, then rb+1
    # columns should be dependent!
    r:=[1..rb+1];
    mp:=List(mat,x->x{r});
    TriangulizeIntegerMat(mp);
    if Number(mp,x->not IsZero(x))<=rb then
      # we are missing full rank already in the first rb+1 columns
      return false;
    fi;
  fi;

  # it failed -- hard work
  Info(InfoMatrix,2,"reduced calculation failed");
  TriangulizeIntegerMat(mat);
  return Number(mat,x->not IsZero(x))=n;
end);


InstallMethod( IsInfiniteAbelianizationGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   mat,        # relator matrix of <G>
            gens,       # generators of free group
            genind,     # their indices
            row,        # a row of <mat>
            rel,        # a relator of <G>
            p,          # position of <g> or its inverse in <gens>
            i,          # loop variable
            word;

  gens := FreeGeneratorsOfFpGroup( G );
  genind:=List(gens,i->AbsInt(LetterRepAssocWord(i)[1]));

  # handle groups with no relators
  if IsEmpty( RelatorsOfFpGroup( G ) ) then
      return Length(gens)>0;
  fi;

  # make the relator matrix
  mat := [];
  for rel  in RelatorsOfFpGroup( G ) do
      row := [];
      for i  in [ 1 .. Length( gens ) ]  do
        row[i] := 0;
      od;
      #for i  in [ 1 .. NrSyllables( rel ) ]  do
      #  p := Position( genind, GeneratorSyllable(rel,i));
      #  row[p]:=row[p]+ExponentSyllable(rel,i);
      #od;
      word:=LetterRepAssocWord(rel);
      for i in [1..Length(rel)] do
        p:=Position(genind,AbsInt(word[i]));
        row[p]:=row[p]+SignInt(word[i]);
      od;
      Add( mat, row );
  od;

  if Length(mat)=0 then
    return false;
  fi;
  if Length(mat)>=Length(mat[1]) then
    if HasFullColumnRankIntMatDestructive(mat) then
      return false;
    fi;
  fi;
  SetSize(G,infinity);
  return true;

end );


#############################################################################
##
#M  IsInfiniteAbelianizationGroup( <H> ) . . . . for a subgroup of a fp group
##
InstallMethod( IsInfiniteAbelianizationGroup,
  "for a subgroup of a finitely presented group", true,
  [ IsSubgroupFpGroup ], 0,
function(H)
    local G,mat;

  if IsGroupOfFamily(H) then
    TryNextMethod();
  fi;

  # Get the whole group `G' of `H'.
  G:= FamilyObj(H)!.wholeGroup;

  # Call the global function for subgroups of f.p. groups.
  mat:=RelatorMatrixAbelianizedSubgroupRrs(G,H);
  if Length(mat)=0 then
    return false;
  fi;

  if Length(mat)>=Length(mat[1]) then
    if HasFullColumnRankIntMatDestructive(mat) then
      return false;
    fi;
  fi;
  SetSize(G,infinity);
  return true;

end);

# a free group has infinite abelianization if and only if it is non-trivial
InstallTrueMethod( IsInfiniteAbelianizationGroup, IsFreeGroup and IsNonTrivial );
InstallTrueMethod( HasIsInfiniteAbelianizationGroup, IsFreeGroup and IsTrivial );

#############################################################################
##
#M  IsPerfectGroup( <H> )
##
InstallMethod( IsPerfectGroup,
  "for a (subgroup of a) finitely presented group", true,
  [ IsSubgroupFpGroup ], 0,
# for fp groups `AbelianInvariants' works.
    G -> IsEmpty( AbelianInvariants( G ) ) );

#############################################################################
##
#M  DerivedSubgroup( <G> ) . . . . . . . . . . . . . . . . . for a fp group
##
InstallMethod( DerivedSubgroup, "for a finitely presented group", true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function(G)
local hom,u;
  hom:=MaximalAbelianQuotient(G);
  if Size(Range(hom))=1 then
    return G; # this is needed because the trivial quotient is represented
              # as fp group on no generators
  fi;
  u:=PreImage(hom,TrivialSubgroup(Range(hom)));
  SetIndexInWholeGroup(u,Size(Range(hom)));
  if IsFreeGroup(G) and not IsAbelian(G) then
    SetIsFinite(u,false);
    SetIsFinitelyGeneratedGroup(u,false);
  fi;
  return u;
end);

InstallMethod( DerivedSubgroup, "subgroup of a finitely presented group", true,
    [ IsSubgroupFpGroup ], 0,
function(G)
local iso,hom,u;
  iso:=IsomorphismFpGroup(G);
  hom:=MaximalAbelianQuotient(Range(iso));
  if HasAbelianInvariants(Range(iso)) then
    SetAbelianInvariants(G,AbelianInvariants(Range(iso)));
  fi;
  if HasIsAbelian(G) and IsAbelian(G) then
    return TrivialSubgroup(G);
  elif Size(Image(hom))=infinity then
    # test a special case -- one generator
    if Length(GeneratorsOfGroup(G))=1 then
      SetIsAbelian(G,true);
      return TrivialSubgroup(G);
    fi;
    Error("Derived subgroup has infinite index, cannot represent");
  elif Size(Range(hom))=1 then
    return G; # this is needed because the trivial quotient is represented
              # as fp group on no generators
  fi;
  hom:=CompositionMapping(hom,iso);
  u:=PreImage(hom,TrivialSubgroup(Range(hom)));
  if HasIndexInWholeGroup(G) then
    SetIndexInWholeGroup(u,IndexInWholeGroup(G)*Size(Range(hom)));
  fi;
  return u;
end);


#############################################################################
##
#M  CosetTable( <G>, <H> )  . . . . coset table of a finitely presented group
##
InstallMethod( CosetTable,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsSubgroupFpGroup ],
    0,
function( G, H );

    if G <> FamilyObj(H)!.wholeGroup then
        Error( "<H> must be a subgroup of <G>" );
    fi;
    return CosetTableInWholeGroup(H);

end );


#############################################################################
##
#M  CosetTableNormalClosure( <G>, <H> ) . . coset table of the normal closure
#M                                of a subgroup in a finitely presented group
##
InstallMethod( CosetTableNormalClosure,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsSubgroupFpGroup ],
    0,
function( G, H );

    if G <> FamilyObj( H )!.wholeGroup then
        Error( "<H> must be a subgroup of <G>" );
    fi;
    return CosetTableNormalClosureInWholeGroup( H );

end );


#############################################################################
##
#M  CosetTableFromGensAndRels( <fgens>, <grels>, <fsgens> ) . . . . . . . . .
#M                                                     do a coset enumeration
##
##  'CosetTableFromGensAndRels'  is the workhorse  for computing  a coset
##  table of H in G where G is a finitley presented group, H is a subgroup of
##  G,  and  G  is the whole group of  H.  It applies a Felsch strategy Todd-
##  Coxeter coset enumeration. The expected parameters are
##
##  \beginitems
##    fgens  & generators of the free group F associated to G,
##
##    grels  & relators of G,
##
##    fsgens & preimages of the subgroup generators of H in F.
##  \enditems
##
##  `CosetTableFromGensAndRels' processes two options (see
##  chapter~"Options"):
##  \beginitems
##    `max' & The limit of the number of cosets to be defined. If the
##    enumeration does not finish with this number of cosets, an error is
##    raised and the user is asked whether she wants to continue
##
##    `silent'  & if set to `true' the algorithm will not rais the error
##    mentioned under option `max' but silently return `fail'. This can be
##    useful if an enumeration is only wanted unless it becomes too big.
##  \enditems
InstallGlobalFunction( CosetTableFromGensAndRels,
function ( fgens, grels, fsgens )
  Info( InfoFpGroup, 3, "CosetTableFromGensAndRels called:" );
  # catch trivial subgroup generators
  if ForAny(fsgens,i->Length(i)=0) then
    fsgens:=Filtered(fsgens,i->Length(i)>0);
  fi;
  if Length(fgens)=0 then
    return [];
  fi;
  # call the TC plugin. Option ensures no factorization takes place in printing
  # (which can confuse the ACE interface).
  return TCENUM.CosetTableFromGensAndRels(fgens,grels,fsgens:printnopowers:=true);
end);

# this function implements the library version of the Todd-Coxeter routine.
BindGlobal("GTC_CosetTableFromGensAndRels",function(arg)
    local   fgens,grels,fsgens,
            next,  prev,            # next and previous coset on lists
            firstFree,  lastFree,   # first and last free coset
            firstDef,   lastDef,    # first and last defined coset
            table,                  # columns in the table for gens
            rels,                   # representatives of the relators
            relsGen,                # relators sorted by start generator
            subgroup,               # rows for the subgroup gens
            i, gen, inv,            # loop variables for generator
            g,                      # loop variable for generator col
            rel,                    # loop variables for relation
            p, p1, p2,              # generator position numbers
            app,                    # arguments list for 'MakeConsequences'
            limit,                  # limit of the table
            maxlimit,               # maximal size of the table
            j,                      # integer variable
            length, length2,        # length of relator (times 2)
            cols,
            nums,
            l,
            nrdef,                  # number of defined cosets
            nrmax,                  # maximal value of the above
            nrdel,                  # number of deleted cosets
            nrinf,                  # number for next information message
            infstep,
            silent,                 # do we want the algorithm to silently
                                    # return `fail' if the algorithm did not
                                    # finish in the permitted size?
            TCEOnBreakMessage,      # to provide a local OnBreakMessage
            SavedOnBreakMessage;    # the value of OnBreakMessage before
                                    # this function was called

    fgens:=arg[1];
    grels:=arg[2];
    fsgens:=arg[3];
    # give some information
    Info( InfoFpGroup, 2, "    defined deleted alive   maximal");
    nrdef := 1;
    nrmax := 1;
    nrdel := 0;
    # to give tidy instructions if one enters a break-loop
    SavedOnBreakMessage := OnBreakMessage;
    TCEOnBreakMessage := function(n)
      Print( "type 'return;' if you want to continue with a new limit of ",
             n, " cosets,\n",
             "type 'quit;' if you want to quit the coset enumeration,\n",
             "type 'maxlimit := 0; return;' in order to continue without a ",
             "limit\n" );
      OnBreakMessage := SavedOnBreakMessage;
    end;

    # initialize size of the table
    maxlimit := ValueOption("max");
    if maxlimit = fail or not (IsInt(maxlimit) or maxlimit=infinity) then
      maxlimit := CosetTableDefaultMaxLimit;
    fi;
    infstep:=QuoInt(maxlimit,10);
    nrinf := infstep;
    limit := CosetTableDefaultLimit;
    if limit > maxlimit and maxlimit > 0 then
      limit := maxlimit;
    fi;

    silent := ValueOption("silent") = true;

    # define one coset (1)
    firstDef  := 1;  lastDef  := 1;
    firstFree := 2;  lastFree := limit;

    # make the lists that link together all the cosets
    next := [ 2 .. limit + 1 ];  next[1] := 0;  next[limit] := 0;
    prev := [ 0 .. limit - 1 ];  prev[2] := 0;

    # compute the representatives for the relators
    rels := RelatorRepresentatives( grels );

    # make the columns for the generators
    table := [];
    for gen  in fgens  do
        g := ListWithIdenticalEntries( limit, 0 );
        Add( table, g );
        if not ( gen^2 in rels or gen^-2 in rels ) then
            g := ListWithIdenticalEntries( limit, 0 );
        fi;
        Add( table, g );
    od;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table, true );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in fsgens  do
      #T this code should use ExtRepOfObj -- its faster
      # cope with SLP elms
      if IsStraightLineProgElm(rel) then
        rel:=EvalStraightLineProgElm(rel);
      fi;
      length := Length( rel );
      if length>0 then
        length2 := 2 * length;
        nums := [ ]; nums[length2] := 0;
        cols := [ ]; cols[length2] := 0;

        # compute the lists.
        i := 0;  j := 0;
        while i < length do
            i := i + 1;  j := j + 2;
            gen := Subword( rel, i, i );
            p := Position( fgens, gen );
            if p = fail then
                p := Position( fgens, gen^-1 );
                p1 := 2 * p;
                p2 := 2 * p - 1;
            else
                p1 := 2 * p - 1;
                p2 := 2 * p;
            fi;
            nums[j]   := p1;  cols[j]   := table[p1];
            nums[j-1] := p2;  cols[j-1] := table[p2];
        od;
        Add( subgroup, [ nums, cols ] );
      fi;
    od;

    # make the structure that is passed to 'MakeConsequences'
    app := [ table, next, prev, relsGen, subgroup ];

    # we do not want minimal gaps to be marked in the coset table
    app[12] := 0;

    # run over all the cosets
    while firstDef <> 0  do

        # run through all the rows and look for undefined entries
        for i  in [ 1 .. Length( table ) ]  do
            gen := table[i];

            if gen[firstDef] <= 0  then

                inv := table[i + 2*(i mod 2) - 1];

                # if necessary expand the table
                if firstFree = 0  then
                    if 0 < maxlimit and  maxlimit <= limit  then
                        if silent then
                          if ValueOption("returntable")=true then
                            return table;
                          else
                            return fail;
                          fi;
                        fi;
                        maxlimit := Maximum(maxlimit*2,limit*2);
                        OnBreakMessage := function()
                          TCEOnBreakMessage(maxlimit);
                        end;
                        Error( "the coset enumeration has defined more ",
                               "than ", limit, " cosets\n");
                    fi;
                    next[2*limit] := 0;
                    prev[2*limit] := 2*limit-1;
                    for g  in table  do g[2*limit] := 0;  od;
                    for l  in [ limit+2 .. 2*limit-1 ]  do
                        next[l] := l+1;
                        prev[l] := l-1;
                        for g  in table  do g[l] := 0;  od;
                    od;
                    next[limit+1] := limit+2;
                    prev[limit+1] := 0;
                    for g  in table  do g[limit+1] := 0;  od;
                    firstFree := limit+1;
                    limit := 2*limit;
                    lastFree := limit;
                fi;

                # update the debugging information
                nrdef := nrdef + 1;
                if nrmax <= firstFree  then
                    nrmax := firstFree;
                fi;

                # define a new coset
                gen[firstDef]   := firstFree;
                inv[firstFree]  := firstDef;
                next[lastDef]   := firstFree;
                prev[firstFree] := lastDef;
                lastDef         := firstFree;
                firstFree       := next[firstFree];
                next[lastDef]   := 0;

                # set up the deduction queue and run over it until it's empty
                app[6] := firstFree;
                app[7] := lastFree;
                app[8] := firstDef;
                app[9] := lastDef;
                app[10] := i;
                app[11] := firstDef;
                nrdel := nrdel + MakeConsequences( app );
                firstFree := app[6];
                lastFree := app[7];
                firstDef := app[8];
                lastDef  := app[9];

                # give some information
                if nrinf <= nrdef+nrdel then
                    Info( InfoFpGroup, 3, "\t", nrdef, "\t", nrinf-nrdef,
                          "\t", 2*nrdef-nrinf, "\t", nrmax );
                    nrinf := ( Int(nrdef+nrdel)/infstep + 1 ) * infstep;
                fi;

            fi;
        od;

        firstDef := next[firstDef];
    od;

    Info( InfoFpGroup, 2, "\t", nrdef, "\t", nrdel, "\t", nrdef-nrdel, "\t",
          nrmax );

    # separate pairs of identical table columns.
    for i in [ 1 .. Length( fgens ) ] do
        if IsIdenticalObj( table[2*i-1], table[2*i] ) then
            table[2*i] := StructuralCopy( table[2*i-1] );
        fi;
    od;

    # standardize the table
    StandardizeTable( table );

    # return the table
    return table;
end);

GAPTCENUM.CosetTableFromGensAndRels := GTC_CosetTableFromGensAndRels;

if IsHPCGAP then
    MakeReadOnlyObj( GAPTCENUM );
fi;


#############################################################################
##
#M  CosetTableInWholeGroup( <H> )  . . . . . .  coset table of an fp subgroup
#M                                                         in its whole group
##
##  is equivalent to `CosetTable( <G>, <H> )' where <G> is the (unique)
##  finitely presented group such that <H> is a subgroup of <G>.
##
InstallMethod( TryCosetTableInWholeGroup,"for finitely presented groups",
    true, [ IsSubgroupFpGroup ], 0,
function( H )
    local   G,          # whole group of <H>
            fgens,      # generators of the free group F associated to G
            grels,      # relators of G
            sgens,      # subgroup generators of H
            fsgens,     # preimages of subgroup generators in F
            T;          # coset table

    # do we know it already?
    if HasCosetTableInWholeGroup(H) then
      return CosetTableInWholeGroup(H);
    fi;

    # Get whole group <G> of <H>.
    G := FamilyObj( H )!.wholeGroup;

    # get some variables
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    sgens := GeneratorsOfGroup( H );
    fsgens := List( sgens, gen -> UnderlyingElement( gen ) );

    # Construct the coset table of <G> by <H>.
    T := CosetTableFromGensAndRels( fgens, grels, fsgens );

    if T<>fail then
      SetCosetTableInWholeGroup(H,T);
    fi;
    return T;

end );

InstallMethod( CosetTableInWholeGroup,"for finitely presented groups",
    true, [ IsSubgroupFpGroup ], 0,
function( H )
  # don't get trapped by a `silent' option lingering around.
  return TryCosetTableInWholeGroup(H:silent:=false);
end );

InstallMethod( CosetTableInWholeGroup,"from augmented table Rrs",
    true, [ IsSubgroupFpGroup and HasAugmentedCosetTableRrsInWholeGroup], 0,
function( H )
  return AugmentedCosetTableRrsInWholeGroup(H).cosetTable;
end );

InstallMethod(CosetTableInWholeGroup,"ByQuoSubRep",true,
  [IsSubgroupOfWholeGroupByQuotientRep],0,
function(G)
  # construct coset table
  return CosetTableBySubgroup(G!.quot,G!.sub);
end);


#############################################################################
##
#M  CosetTableNormalClosureInWholeGroup( <H> )  . . . . .  coset table of the
#M                        normal closure of an fp subgroup in its whole group
##
##  is equivalent to  `CosetTableNormalClosure( <G>, <H> )'  where <G> is the
##  (unique) finitely presented group such that <H> is a subgroup of <G>.
##
InstallMethod( CosetTableNormalClosureInWholeGroup,
    "for finitely presented groups",
    true, [ IsSubgroupFpGroup ], 0,
function( H )
    local   G,          # whole group of H
            F,          # associated free group
            grels,      # relators of G
            sgens,      # subgroup generators of H
            fsgens,     # preimages of subgroup generators in F
            krels,      # relators of the normal closure N of H in G
            K,          # factor group of F isomorphic to G/N
            T;          # coset table

    # do we know it already?
    if HasCosetTableNormalClosureInWholeGroup( H ) then
        T := CosetTableNormalClosureInWholeGroup( H );
    else
        # Get whole group G of H.
        G := FamilyObj( H )!.wholeGroup;

        # get some variables
        F     := FreeGroupOfFpGroup( G );
        grels := RelatorsOfFpGroup( G );
        sgens := GeneratorsOfGroup( H );
        fsgens := List( sgens, gen -> UnderlyingElement( gen ) );

        # construct a factor group K of F isomorphic to the factor group of G
        # by the normal closure N of H.
        krels := Concatenation( grels, fsgens );
        K := F / krels;

        # get the coset table of N in G by constructing the coset table of
        # the trivial subgroup in K.
        T := CosetTable( K, TrivialSubgroup( K ) );
        Info( InfoFpGroup, 1, "index is ", IndexCosetTab(T) );
    fi;

    return T;

end );


#############################################################################
##
#F  StandardizeTable( <table> [, <standard>] ) . . .  standardize coset table
##
##  standardizes a coset table.
##
InstallGlobalFunction( StandardizeTable, function( arg )

    local standard, table;

    # get the arguments
    table := arg[1];
    if Length( arg ) > 1 then
      standard := arg[2];
    else
      standard := CosetTableStandard;
    fi;
    if standard <> "lenlex" and standard <> "semilenlex" then
       Error( "unknown coset table standard" );
    fi;
    if standard = "lenlex" then
      standard := 0;
    else
      standard := 1;
    fi;

    # call an appropriate kernel function which does the job
    StandardizeTableC( table, standard );

end );


#############################################################################
##
#F  StandardizeTable2( <table>, <table2> [, <standard>] )  .  standardize ACT
##
##  standardizes an augmented coset table.
##
InstallGlobalFunction( StandardizeTable2, function( arg )

    local standard, table, table2;

    # get the arguments
    table := arg[1];
    table2 := arg[2];
    if Length( arg ) > 2 then
      standard := arg[3];
    else
      standard := CosetTableStandard;
    fi;
    if standard <> "lenlex" and standard <> "semilenlex" then
       Error( "unknown coset table standard" );
    fi;
    if standard = "lenlex" then
      standard := 0;
    else
      standard := 1;
    fi;

    # call an appropriate kernel function which does the job
    StandardizeTable2C( table, table2, standard );

end );


#############################################################################
##
#M  Display( <G> ) . . . . . . . . . . . . . . . . . . .  display an fp group
##
InstallMethod( Display,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   gens,       # generators o the free group
            rels,       # relators of <G>
            nrels,      # number of relators
            i;          # loop variable

    gens := FreeGeneratorsOfFpGroup( G );
    rels := RelatorsOfFpGroup( G );
    Print( "generators = ", gens, "\n" );
    nrels := Length( rels );
    Print( "relators = [" );
    if nrels > 0 then
        Print( "\n ", rels[1] );
        for i in [ 2 .. nrels ] do
            Print( ",\n ", rels[i] );
        od;
    fi;
    Print( " ]\n" );
end );


#############################################################################
##
#F  FactorGroupFpGroupByRels( <G>, <elts> )
##
##  Returns the factor group G/N of G by the normal closure N of <elts> where
##  <elts> is expected to be a list of elements of G.
##
InstallGlobalFunction( FactorGroupFpGroupByRels,
function( G, elts )
    local   F,          # free group associated to G and to G/N
            grels,      # relators of G
            words,      # representative words in F for the elements in elts
            rels;       # relators of G/N

    # get some local variables
    F     := FreeGroupOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    words := List( elts, g -> UnderlyingElement( g ) );

    # get relators for G/N
    rels := Concatenation( grels, words );

    # return the resulting factor group G/N
    return F / rels;
end );

#############################################################################
##
#M  FactorFreeGroupByRelators(<F>,<rels>) .  factor of free group by relators
##
BindGlobal( "FactorFreeGroupByRelators", function( F, rels )
    local G, fam, gens,typ;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpGroup", IsElementOfFpGroup );

    # Create the default type for the elements.
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    fam!.freeGroup := F;
    fam!.relators := Immutable( rels );
    typ:=IsSubgroupFpGroup and IsWholeFamily and IsAttributeStoringRep;
    if IsFinitelyGeneratedGroup(F) then
      typ:=typ and IsFinitelyGeneratedGroup;
    fi;

    # Create the group.
    G := Objectify(
        NewType( CollectionsFamily( fam ), typ ), rec() );

    # Mark <G> to be the 'whole group' of its later subgroups.
    FamilyObj( G )!.wholeGroup := G;
    SetFilterObj(G,IsGroupOfFamily);

    # Create generators of the group.
    gens:= List( GeneratorsOfGroup( F ), g -> ElementOfFpGroup( fam, g ) );
    SetGeneratorsOfGroup( G, gens );
    if IsEmpty( gens ) then
      SetOne( G, ElementOfFpGroup( fam, One( F ) ) );
    fi;

    # trivial infinity deduction
    if Length(gens)>Length(rels) then
      SetSize(G,infinity);
      SetIsFinite(G,false);
    fi;

    return G;
end );


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . . . . for free group and list of relators
##
InstallOtherMethod( \/,
    "for full free group and relators",
    IsIdenticalObj,
    [ IsFreeGroup and IsWholeFamily, IsCollection ],
    FactorFreeGroupByRelators );

InstallOtherMethod( \/,
    "for free group and relators",
    IsIdenticalObj,
    [ IsFreeGroup, IsCollection ],
    function( G, rels )
    if not HasIsWholeFamily( G ) and
       IsSubset( FreeGeneratorsOfWholeGroup( G ), GeneratorsOfGroup( G ) ) then
      SetIsWholeFamily( G, true );
      return FactorFreeGroupByRelators( G, rels );
    fi;

    # If somebody thinks that it is worth the effort to support proper
    # subgroups of full free groups then this method is the right place
    # to add code for that.
    Error( "currently quotients of a free group are supported only if the ",
           "group knows to contain all generators of its parent group" );
    end );

InstallOtherMethod( \/,
    "for fp groups and relators",
    IsIdenticalObj,
    [ IsFpGroup, IsCollection ],
    0,
    FactorGroupFpGroupByRels );

InstallOtherMethod( \/,
    "for free groups and a list of equations",
    IsElmsColls,
    [ IsFreeGroup, IsCollection ],
    0,
    {F, rels} -> FactorFreeGroupByRelators(F, List(rels, r -> r[1] / r[2])));

InstallOtherMethod( \/,
    "for fp groups and a list of equations",
    IsElmsColls,
    [ IsFpGroup, IsCollection ],
    0,
    {F, rels} -> FactorGroupFpGroupByRels(F, List(rels, r -> r[1] / r[2])));

#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . for free group and empty list of relators
##
InstallOtherMethod( \/,
    "for a free group and an empty list of relators",
    true,
    [ IsFreeGroup, IsEmpty ],
    0,
    FactorFreeGroupByRelators );

#############################################################################
##
#M  FreeGeneratorsOfFpGroup( F )  . . generators of the underlying free group
##
InstallMethod( FreeGeneratorsOfFpGroup, "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> GeneratorsOfGroup( FreeGroupOfFpGroup( G ) ) );

#############################################################################
##
#M  FreeGeneratorsOfWholeGroup( U )  . . generators of the underlying free group
##
InstallMethod( FreeGeneratorsOfWholeGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup ], 0,
    G -> GeneratorsOfGroup( ElementsFamily(FamilyObj( G ))!.freeGroup ) );

#############################################################################
##
#M  FreeGroupOfFpGroup( F ) . . . . . .  underlying free group of an fp group
##
InstallMethod( FreeGroupOfFpGroup, "for a finitely presented group", true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.freeGroup );


#############################################################################
##
#M  IndexNC( <G>, <H> )
##
InstallMethod( IndexNC,
    "for finitely presented groups",
    [ IsSubgroupFpGroup, IsSubgroupFpGroup ],
function(G,H)
  # catch a stupid case
  if IsIdenticalObj(G,H) then
    return 1;
  fi;
  return IndexInWholeGroup(H)/IndexInWholeGroup(G);
end);


#############################################################################
##
#M  IndexOp( <G>, <H> ) . . . . . . . . . . . for whole family and f.p. group
##
##  We can avoid the `IsSubset' check of the default `IndexOp' method,
##  and also the division of the `IndexNC' method.
##
InstallMethod( IndexOp,
    "for finitely presented group in whole group",
    IsIdenticalObj,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup ],
function(G,H)
  return IndexInWholeGroup(H);
end);

InstallMethod( CanComputeIndex,"subgroups fp groups",IsIdenticalObj,
  [IsGroup and HasIndexInWholeGroup,IsGroup and HasIndexInWholeGroup],
  ReturnTrue);

InstallMethod( CanComputeIndex,"subgroup of full fp groups",IsIdenticalObj,
  [IsGroup and IsWholeFamily,IsGroup and HasIndexInWholeGroup],
  ReturnTrue);

InstallMethod( CanComputeIndex,"subgroup of full fp groups",IsIdenticalObj,
  [IsGroup and IsWholeFamily,IsGroup and HasCosetTableInWholeGroup],
  ReturnTrue);


#############################################################################
##
#M  IndexInWholeGroup( <H> )  . . . . . .  index of a subgroup in an fp group
##
InstallMethod(IndexInWholeGroup,"subgroup fp",true,[IsSubgroupFpGroup],0,
function( H )
local T,i;
    # Get the coset table of <H> in its whole group.
    T := CosetTableInWholeGroup( H );
    i:=IndexCosetTab( T );
    if HasGeneratorsOfGroup(H) and Length(GeneratorsOfGroup(H))=0 then
      SetSize(FamilyObj(H)!.wholeGroup,i);
    fi;
    return i;
end );

InstallMethod(IndexInWholeGroup,"subgroup fp by quotient",true,
  [IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function(U)
  return Index(U!.quot,U!.sub);
end);

InstallMethod( IndexInWholeGroup, "for full fp group",
    [ IsSubgroupFpGroup and IsWholeFamily ], a->1);

#############################################################################
##
#M  ConjugateGroup(<U>,<g>)  U^g
##
InstallMethod(ConjugateGroup,"subgroups of fp group with coset table",
  IsCollsElms, [IsSubgroupFpGroup and HasCosetTableInWholeGroup,
               IsMultiplicativeElementWithInverse],0,
function(U,g)
local t, w, wi, word, pos, V, i;
  t:=CosetTableInWholeGroup(U);
  if Length(t)<2 then
    return U; # the whole group
  fi;

  # the image of g in the permutation group
  w:=UnderlyingElement(g);
  wi:=[1..IndexCosetTab(t)];
#  for i in [1..NumberSyllables(w)] do
#    e:=ExponentSyllable(w,i);
#    if e<0 then
#      pos:=2*GeneratorSyllable(w,i);
#      e:=-e;
#    else
#      pos:=2*GeneratorSyllable(w,i)-1;
#    fi;
#    for j in [1..e] do
#      wi:=t[pos]{wi}; # multiply permutations
#    od;
#  od;
  word:=LetterRepAssocWord(w);
  for i in [1..Length(word)] do
    if word[i]<0 then
      pos:=-2*word[i];
    else
      pos:=2*word[i]-1;
    fi;
    wi:=t[pos]{wi}; # multiply permutations
  od;

  w:=PermList(wi)^-1;
  t:=List(t,i->OnTuples(i{wi},w));
  StandardizeTable(t);
  V:=SubgroupOfWholeGroupByCosetTable(FamilyObj(U),t);

  if HasGeneratorsOfGroup(U) then
    SetGeneratorsOfGroup(V,List(GeneratorsOfGroup(U),i->i^g));
  fi;
  return V;
end);

InstallMethod(ConjugateGroup,"subgroups of fp group by quotient",
  IsCollsElms, [ IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
               IsMultiplicativeElementWithInverse],0,
function(U,elm)
  # transfer elm in factor
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),
                  GeneratorsOfGroup(U!.quot));

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),U!.quot,
    ConjugateGroup(U!.sub,elm));
end);

InstallMethod(AsSubgroupOfWholeGroupByQuotient,"create",true,
  [IsSubgroupFpGroup],0,
function(U)
local tab,Q,A;
  tab:=CosetTableInWholeGroup(U);
  Q:=GroupWithGenerators(List(tab{[1,3..Length(tab)-1]},PermList));
  #T: try to improve via blocks

  A:=Stabilizer(Q,1);
  U:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,A);
  return U;
end);

InstallMethod(AsSubgroupOfWholeGroupByQuotient,"is already",true,
  [IsSubgroupOfWholeGroupByQuotientRep],0,x->x);

#############################################################################
##
#F  DefiningQuotientHomomorphism(<U>)
##
InstallGlobalFunction(DefiningQuotientHomomorphism,function(U)
local hom;
  if not IsSubgroupOfWholeGroupByQuotientRep(U) then
    Error("<U> must be in quotient representation");
  fi;
  hom:=GroupHomomorphismByImagesNC(FamilyObj(U)!.wholeGroup,
    U!.quot,
    GeneratorsOfGroup(FamilyObj(U)!.wholeGroup),
    GeneratorsOfGroup(U!.quot));
  SetIsSurjective(hom,true);
  return hom;
end);

#############################################################################
##
#M  CoreOp(<U>,<V>)  . intersection of two fin. pres. groups
##
InstallMethod(CoreOp,"subgroups of fp group: use quotient rep",IsIdenticalObj,
  [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(V,U)
  return Core(V,AsSubgroupOfWholeGroupByQuotient(U));
end);

InstallMethod(CoreOp,"subgroups of fp group by quotient",IsIdenticalObj,
  [IsSubgroupFpGroup,
  IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function(V,U)
local q,gens;
  # map the generators of V in the quotient
  gens:=GeneratorsOfGroup(V);
  gens:=List(gens,UnderlyingElement);
  q:=U!.quot;
  gens:=List(gens,i->MappedWord(i,FreeGeneratorsOfWholeGroup(U),
                                GeneratorsOfGroup(q)));
  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),q,
           Core(SubgroupNC(q,gens),U!.sub));
end);

#############################################################################
##
#M  Intersection2(<G>,<H>)  . intersection of two fin. pres. groups
##
InstallMethod(Intersection2,"subgroups of fp group",IsIdenticalObj,
  [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function ( G, H )
    local
            Fam,        # group family
            table,      # coset table for <I> in its parent
            nrcos,      # number of cosets of <I>
            tableG,     # coset table of <G>
            nrcosG,     # number of cosets of <G>
            tableH,     # coset table of <H>
            nrcosH,     # number of cosets of <H>
            freegens,   # free generators of Parent(G)
            nrgens,     # number of generators of the parent of <G> and <H>
            ren,        # if 'ren[<i>]' is 'nrcosH * <iG> + <iH>' then the
                        # coset <i> of <I> corresponds to the intersection
                        # of the pair of cosets <iG> of <G> and <iH> of <H>
            ner,        # the inverse mapping of 'ren'
            cos,        # coset loop variable
            gen,        # generator loop variable
            img;        # image of <cos> under <gen>

    Fam:=FamilyObj(G);
    # handle trivial cases
    if IsIdenticalObj(G,Fam!.wholeGroup) then
        return H;
    elif IsIdenticalObj(H,Fam!.wholeGroup) then
        return G;
    fi;

    # its worth to check inclusion first
    if IndexInWholeGroup(G)<=IndexInWholeGroup(H) and IsSubset(G,H) then
      return H;
    elif IndexInWholeGroup(H)<=IndexInWholeGroup(G) and IsSubset(H,G) then
      return G;
    fi;

    tableG := CosetTableInWholeGroup(G);
    nrcosG := IndexCosetTab( tableG ) + 1;
    tableH := CosetTableInWholeGroup(H);
    nrcosH := IndexCosetTab( tableH ) + 1;

    if nrcosH<=nrcosG and HasGeneratorsOfGroup(G) then
      if ForAll(GeneratorsOfGroup(G),i->i in H) then
        return G;
      fi;
    elif nrcosG<=nrcosH and HasGeneratorsOfGroup(H) then
      if ForAll(GeneratorsOfGroup(H),i->i in G) then
        return H;
      fi;
    fi;

    freegens:=FreeGeneratorsOfFpGroup(Fam!.wholeGroup);
    # initialize the table for the intersection
    nrgens := Length(freegens);
    table := [];
    for gen  in [ 1 .. nrgens ]  do
        table[ 2*gen-1 ] := [];
        table[ 2*gen ] := [];
    od;

    # set up the renumbering
    ren := ListWithIdenticalEntries(nrcosG*nrcosH,0);
    ner := ListWithIdenticalEntries(nrcosG*nrcosH,0);
    ren[ 1*nrcosH + 1 ] := 1;
    ner[ 1 ] := 1*nrcosH + 1;
    nrcos := 1;

    # the coset table for the intersection is the transitive component of 1
    # in the *tensored* permutation representation
    cos := 1;
    while cos <= nrcos  do

        # loop over all entries in this row
        for gen  in [ 1 .. nrgens ]  do

            # get the coset pair
            img := nrcosH * tableG[ 2*gen-1 ][ QuoInt( ner[ cos ], nrcosH ) ]
                          + tableH[ 2*gen-1 ][ ner[ cos ] mod nrcosH ];

            # if this pair is new give it the next available coset number
            if ren[ img ] = 0  then
                nrcos := nrcos + 1;
                ren[ img ] := nrcos;
                ner[ nrcos ] := img;
            fi;

            # and enter it into the coset table
            table[ 2*gen-1 ][ cos ] := ren[ img ];
            table[ 2*gen   ][ ren[ img ] ] := cos;

        od;

        cos := cos + 1;
    od;

    return SubgroupOfWholeGroupByCosetTable(Fam,table);
end);

InstallMethod(Intersection2,"subgroups of fp group by quotient",IsIdenticalObj,
  [IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
   IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function ( G, H )
local d,A,B,e1,e2,Ag,Bg,s,sg,u,v,map,sz;

  # it is not worth to check inclusion first since we're reducing afterwards
  #if IndexInWholeGroup(G)<=IndexInWholeGroup(H) and IsSubset(G,H) then
  #  return H;
  #elif IndexInWholeGroup(H)<=IndexInWholeGroup(G) and IsSubset(H,G) then
  #  return G;
  #fi;

  if Size(G!.quot)<Size(H!.quot) then
    # make G the one with larger quot
    A:=G; G:=H;H:=A;
  fi;
  A:=MakeNiceDirectQuots(G,H);
  G:=A[1];
  H:=A[2];

  A:=G!.quot;
  B:=H!.quot;
  Ag:=GeneratorsOfGroup(A);
  Bg:=GeneratorsOfGroup(B);
  # form the sdp

  # use map to determine common subdirect factor
  map:=GroupGeneralMappingByImages(A,B,Ag,Bg);
  sz:=Size(A)*Size(CoKernelOfMultiplicativeGeneralMapping(map));

  # is the image obtained all in A?
  if sz=Size(A) then
    if ForAll(GeneratorsOfGroup(G!.sub),
      x->ImagesRepresentative(map,x) in H!.sub) then
      # G!.sub maps into H!.sub, thus contained in preimage
      u:=G!.sub;
    else
      u:=PreImage(map,H!.sub);
      u:=Intersection(G!.sub,u);
    fi;
    return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),A,u);
  fi;

  d:=DirectProduct(A,B);
  e1:=Embedding(d,1);
  e2:=Embedding(d,2);

  sg:=List([1..Length(Ag)],
    i->ImagesRepresentative(e1,Ag[i])*ImagesRepresentative(e2,Bg[i]));
  s:=SubgroupNC(d,sg);
  SetSize(s,sz);
  #if HasSize(A) and HasSize(B) and IsPermGroup(s) then
  #  StabChainOptions(s).limit:=Size(d);
  #fi;


  # get both subgroups in the direct product via the projections
  # instead of intersecting both preimages with s we only intersect the
  # intersection

  u:=PreImagesSet(Projection(d,1),G!.sub);
  if HasSize(B) then
    SetSize(u,Size(G!.sub)*Size(B));
  fi;
  v:=PreImagesSet(Projection(d,2),H!.sub);
  if HasSize(A) then
    SetSize(v,Size(H!.sub)*Size(A));
  fi;
  u:=Intersection(u,v);
  if Size(u)>1 and Size(s)<Size(d) then
    u:=Intersection(u,s);
  fi;

  if IsPermGroup(A) and IsPermGroup(s) then
    # reduce
    e1:=Length(Orbits(A,MovedPoints(A)));
    e2:=Length(Orbits(s,MovedPoints(s)));
    d:=ValueOption("reduce");
    if (d<>false and HasSize(s) and
      # test proportiopnal to how much orbits added
      (Random([1..e2+1])>e1) ) or d=true then
      d:=SmallerDegreePermutationRepresentation(s:cheap);
      A:=SubgroupNC(Range(d),List(GeneratorsOfGroup(s),x->ImagesRepresentative(d,x)));
      if NrMovedPoints(A)<NrMovedPoints(s) then
        Info(InfoFpGroup,3,"reduced degree from ",NrMovedPoints(s)," to ",
            NrMovedPoints(A));
        s:=A;
        u:=Image(d,u);
      fi;
    fi;
  fi;

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),s,u);
end);

InstallOtherMethod(FactorCosetAction,
  "list of fp groups",IsElmsColls,
  [IsSubgroupFpGroup and IsWholeFamily,IsList],0,function(g,l)
local ind,q,is;
  l:=List(l,x->Core(g,x));
  ind:=List(l,IndexInWholeGroup);
  Print("Found ",Length(l)," subgroups, core indices:\n",Collected(ind),"\n");
  l:=List(Set(ind),y->Filtered(l,x->IndexInWholeGroup(x)=y));
  l:=List(l,Intersection);
  SortBy(l,IndexInWholeGroup);
  if Length(l)=1 then
    is:=l[1];
  else
    # force a final reduction
    is:=Intersection(l{[1..Length(l)-1]});
    is:=Intersection(is,l[Length(l)]:reduce:=true);
  fi;
  q:=DefiningQuotientHomomorphism(is);
  return q;
end);


#############################################################################
##
#M  ClosureGroup( <G>, <obj> )
##
InstallMethod( ClosureGroup, "subgrp fp: by quotient subgroup",IsCollsElms,
  [IsSubgroupFpGroup and HasParent and IsSubgroupOfWholeGroupByQuotientRep,
    IsMultiplicativeElementWithInverse ], 0,
function( U, elm )
local Q,V,hom;
  Q:=U!.quot;
  # transfer elm in factor
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),GeneratorsOfGroup(Q));
  if elm in U!.sub then
    return U; # no new group
  fi;

  V:=ClosureSubgroup(U!.sub,elm);
  # do we want to get a smaller representation?
  if IsPermGroup(Q) and Length(MovedPoints(Q))>2*Index(Q,V) then
#T better IndexNC?
    # we can improve the degree
    hom:=ActionHomomorphism(Q,RightTransversal(Q,V),OnRight,"surjective");
    Q:=GroupWithGenerators(List(GeneratorsOfGroup(Q),i->Image(hom,i)));
    return
      SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,Stabilizer(Q,1));
  else
    # close
    return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,V);
  fi;
end );

InstallMethod( ClosureGroup, "subgrp fp: Has coset table",IsCollsElms,
  [ IsSubgroupFpGroup and HasParent and HasCosetTableInWholeGroup,
    IsMultiplicativeElementWithInverse ], 0,
function( U, elm )
local tab,Q,es,eo,b;
  tab:=CosetTableInWholeGroup(U);
  tab:=List(tab{[1,3..Length(tab)-1]},PermList);
  Q:=GroupWithGenerators(tab);
  elm:=UnderlyingElement(elm);
  elm:=MappedWord(elm,FreeGeneratorsOfWholeGroup(U),tab);
  if 1^elm=1 then
    return U; # no new group
  fi;

  es:=SubgroupNC(Q,[elm]);
  # form a block system
  eo:=Orbit(es,1); # block seed
  b:=[[1]]; # this is guaranteed to be overwritten at least once
  while not IsSubset(b[1],eo) do
    # fuse to new blocks
    b:=Blocks(Q,[1..IndexInWholeGroup(U)],eo);
    eo:=Union(List(b[1],i->Orbit(es,i))); # all orbits of elm on the new block
  od; # until the block does not grow any more under es.

  b:=ActionHomomorphism(Q,b,OnSets,"surjective");
  tab:=List(tab,i->ImageElm(b,i));
  Q:=GroupWithGenerators(tab);
  return
    SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(U),Q,Stabilizer(Q,1));

end );


# override default because we want to close the larger group with the smaller
InstallMethod( ClosureGroup, "for subgroup of fp group, and subgroup",
  IsIdenticalObj,[IsSubgroupFpGroup and HasParent,IsSubgroupFpGroup ],0,
function( U, V )
  if IndexInWholeGroup(U)<IndexInWholeGroup(V) then
    return ClosureGroup(V,U);
  fi;
  return ClosureGroup(U,GeneratorsOfGroup(V));
end );


#############################################################################
##
#M  KnowsHowToDecompose(<G>,<gens>)
##
InstallMethod( KnowsHowToDecompose,"fp groups: Say yes if finite index",
    IsIdenticalObj, [ IsSubgroupFpGroup, IsList ], 0,
function(G,l)
  return CanComputeIndex(FamilyObj(G)!.wholeGroup,G)
         and IndexInWholeGroup(G)<infinity;
end);

#############################################################################
##
#M  IsAbelian( <G> )  . . . . . . . . . . . .  test if an fp group is abelian
##
InstallMethod( IsAbelian, "for finitely presented groups", true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function( G )
    local   isAbelian,  # result
            gens,       # generators of <G>
            fgens,      # generators of the associated free group
            rels,       # relators of <G>
            one,        # identity element of <G>
            g, h,       # two generators of <G>
            i, k;       # loop variables

    gens  := GeneratorsOfGroup( G );
    fgens := FreeGeneratorsOfFpGroup( G );
    rels  := RelatorsOfFpGroup( G );
    one   := One( G );
    isAbelian := true;
    for i  in [ 1 .. Length( gens ) - 1 ]  do
        g := fgens[i];
        for k  in [ i + 1 .. Length( fgens ) ]  do
            h := fgens[k];
            isAbelian := isAbelian and (
                           Comm( g, h ) in rels
                           or Comm( h, g ) in rels
                           or Comm( gens[i], gens[k] ) = one
                          );
        od;
    od;
    return isAbelian;

end );

InstallMethod( IsAbelian, "finite fp grp", true,
    [ IsSubgroupFpGroup and HasSize and IsFinite ], 0,
function(G)
local l;
  l:=AbelianInvariants(G);
  if 0 in l then
    Error("G not finite");
  fi;
  return Product(l,1)=Size(G);
end);

#############################################################################
##
#M  IsTrivial( <G> ) . . . . . . . . . . . . . . . . . test if <G> is trivial
##
InstallMethod( IsTrivial,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
  if 0 = Length( GeneratorsOfGroup( G ) )  then
    return true;
  else
    return Size( G ) = 1;
  fi;
end );
#T why is this just a method for f.p. groups?


#############################################################################
##
#F  NextIterator_LowIndexSubgroupsFpGroup( <iter> )
#F  IsDoneIterator_LowIndexSubgroupsFpGroup( <iter> )
#F  ShallowCopy_LowIndexSubgroupsFpGroup( <iter> )
##
BindGlobal( "NextIterator_LowIndexSubgroupsFpGroup", function( iter )
    local result;

    if not IsDoneIterator( iter ) then
      result:= iter!.data.nextSubgroup;
      iter!.data.nextSubgroup:= fail;
      return result;
    fi;
    Error( "iterator is exhausted" );
    end );

BindGlobal( "IsDoneIterator_LowIndexSubgroupsFpGroup", function( iter )
    local G,            # parent group
          ngens,        # number of generators of associated free group
          index,        # maximal index of subgroups to be determined
          exclude,      # true, if element classes to be excluded are given
          excludeGens,  # table columns corresponding to gens to be excluded
          excludeWords, # words to be excluded, sorted by start generator
          subs,         # number of found subgroups of <G>
          sub,          # one subgroup
          table,        # coset table
          nrgens,       # 2*(number of generators)+1
          nrcos,        # number of cosets in the coset table
          definition,   # "definition"
          choice,       # "choice"
          deduction,    # "deduction"
          action,       # 'action[<i>]' is definition or choice or deduction
          actgen,       # 'actgen[<i>]' is the gen where this action was
          actcos,       # 'actcos[<i>]' is the coset where this action was
          nract,        # number of actions
          nrded,        # number of deductions already handled
          coinc,        # 'true' if a coincidence happened
          gen,          # current generator
          cos,          # current coset
          relsGen,      # relators sorted by start generator
          subgroup,     # rows for the subgroup gens
          nrsubgrp,     # number of subgroups
          app,          # arguments list for 'ApplyRel'
          later,        # 'later[<i>]' is <> 0 if <i> is smaller than 1
          nrfix,        # index of a subgroup in its normalizer
          pair,         # loop variable for subgroup generators as pairs
          triple,       # loop variable for relators as triples
          r, s,         # renumbering lists
          x, y,         # loop variables
          g, c, d,      # loop variables
          length,       # relator length
          numgen,
          numcos,
          perms,        # permutations on the cosets
          Q,            # Quotient group
          done,
          i;            # loop variables

    # Do nothing if we know already that the iterator is exhausted,
    # or if we know already the next subgroup.
    if iter!.data.isDone then
      return true;
    elif iter!.data.nextSubgroup <> fail then
      return false;
    fi;

    # Compute the next subgroup if there is one.
    G            := iter!.data.G;
    ngens        := iter!.data.ngens;
    index        := iter!.data.index;
    exclude      := iter!.data.exclude;
    excludeGens  := iter!.data.excludeGens;
    excludeWords := iter!.data.excludeWords;
    subs         := iter!.data.subs;
    table        := iter!.data.table;
    nrcos        := iter!.data.nrcos;
    action       := iter!.data.action;
    actgen       := iter!.data.actgen;
    actcos       := iter!.data.actcos;
    nract        := iter!.data.nract;
    gen          := iter!.data.gen;
    cos          := iter!.data.cos;
    relsGen      := iter!.data.relsGen;
    later        := iter!.data.later;
    r            := iter!.data.r;
    s            := iter!.data.s;
    subgroup     := iter!.data.subgroup;

    nrsubgrp     := Length( subgroup );
    app          := ListWithIdenticalEntries( 4, 0 );

    definition   := 1;
    choice       := 2;
    deduction    := 3;

    nrgens := 2 * ngens + 1;

    # do an exhaustive backtrack search
    while 1 < nract  or table[1][1] < 2  do

        # find the next choice that does not already appear in this col.
        c := table[ gen ][ cos ];
        repeat
            c := c + 1;
        until index < c  or table[ gen+1 ][ c ] = 0;

        # if there is a further choice try it
        if action[nract] <> definition  and c <= index  then

            # remove the last choice from the table
            d := table[ gen ][ cos ];
            if d <> 0  then
                table[ gen+1 ][ d ] := 0;
            fi;

            # enter it in the table
            table[ gen ][ cos ] := c;
            table[ gen+1 ][ c ] := cos;

            # and put information on the action stack
            if c = nrcos + 1  then
                nrcos := nrcos + 1;
                action[ nract ] := definition;
            else
                action[ nract ] := choice;
            fi;

            # run through the deduction queue until it is empty
            nrded := nract;
            coinc := false;
            while nrded <= nract and not coinc  do

                # check given exclude elements to be excluded
                if exclude then
                    numgen := actgen[nrded];
                    numcos := actcos[nrded];
                    if excludeGens[numgen] = 1 and
                        numcos = table[numgen][numcos] then
                        coinc := true;
                    else
                        length := Length( excludeWords[actgen[nrded]] );
                        i := 1;
                        while i <= length and not coinc do
                            triple := excludeWords[actgen[nrded]][i];
                            app[1] := triple[3];
                            app[2] := actcos[ nrded ];
                            app[3] := -1;
                            app[4] := app[2];
                            if not ApplyRel( app, triple[2] ) and
                                app[1] = app[3] + 1 then
                                coinc := true;
                            fi;
                            i := i + 1;
                        od;
                    fi;
                fi;

                # if there are still subgroup generators apply them
                i := 1;
                while i <= nrsubgrp and not coinc do
                    pair := subgroup[i];
                    app[1] := 2;
                    app[2] := 1;
                    app[3] := Length(pair[2])-1;
                    app[4] := 1;
                    if ApplyRel( app, pair[2] )  then
                        if   pair[2][app[1]][app[2]] <> 0  then
                            coinc := true;
                        elif pair[2][app[3]][app[4]] <> 0  then
                            coinc := true;
                        else
                            pair[2][app[1]][app[2]] := app[4];
                            pair[2][app[3]][app[4]] := app[2];
                            nract := nract + 1;
                            action[ nract ] := deduction;
                            actgen[ nract ] := pair[1][app[1]];
                            actcos[ nract ] := app[2];
                        fi;
                    fi;
                    i := i + 1;
                od;

                # apply all relators that start with this generator
                length := Length( relsGen[actgen[nrded]] );
                i := 1;
                while i <= length and not coinc do
                    triple := relsGen[actgen[nrded]][i];
                    app[1] := triple[3];
                    app[2] := actcos[ nrded ];
                    app[3] := -1;
                    app[4] := app[2];
                    if ApplyRel( app, triple[2] )  then
                        if   triple[2][app[1]][app[2]] <> 0  then
                            coinc := true;
                        elif triple[2][app[3]][app[4]] <> 0  then
                            coinc := true;
                        else
                            triple[2][app[1]][app[2]] := app[4];
                            triple[2][app[3]][app[4]] := app[2];
                            nract := nract + 1;
                            action[ nract ] := deduction;
                            actgen[ nract ] := triple[1][app[1]];
                            actcos[ nract ] := app[2];
                        fi;
                    fi;
                    i := i + 1;
                od;

                nrded := nrded + 1;
            od;

            # unless there was a coincidence check lexicography
            if not coinc then
              nrfix := 1;
              x := 1;
              while x < nrcos and not coinc do
                x := x + 1;

                # set up the renumbering
                for i in [1..nrcos] do
                    r[i] := 0;
                    s[i] := 0;
                od;
                r[x] := 1;  s[1] := x;

                # run through the old and the new table in parallel
                c := 1;  y := 1;

                #while c <= nrcos  and not coinc  and later[x] = 0  do
                done := coinc or later[x] <> 0;
                while c <= nrcos  and not done  do


                    # get the corresponding coset for the new table
                    d := s[c];

                    # loop over the entries in this row
                    g := 1;
                    #while   g < nrgens
                    #    and c <= nrcos  and not coinc  and later[x] = 0  do
                    while g<nrgens and not done do

                        # if either entry is missing we cannot decide yet
                        if table[g][c] = 0  or table[g][d] = 0  then
                            c := nrcos + 1;
                            done:=true;

                        # if old and new contain defs, extend the renumbering
                        elif table[g][c] = y+1 and r[ table[g][d] ] = 0  then
                            y := y + 1;
                            r[ table[g][d] ] := y;
                            s[ y ] := table[g][d];

                        # if only new is a definition
                        elif r[ table[g][d] ] = 0  then
                            later[x] := nract;
                            done:=true;

                        # if olds entry is smaller, old must be earlier
                        elif table[g][c] < r[ table[g][d] ]  then
                            later[x] := nract;
                            done := true;

                        # if news entry is smaller, test if new contains sgr
                        elif r[ table[g][d] ] < table[g][c]  then

                            # check that <x> fixes <H>
                            coinc := true;
                            for pair in subgroup  do
                                app[1] := 2;
                                app[2] := x;
                                app[3] := Length(pair[2])-1;
                                app[4] := x;
                                if ApplyRel( app, pair[2] )  then

                                    # coincidence: <x> does not fix <H>
                                    if   pair[2][app[1]][app[2]] <> 0  then
                                        later[x] := nract;
                                        coinc := false;
                                    elif pair[2][app[3]][app[4]] <> 0  then
                                        later[x] := nract;
                                        coinc := false;

                                    # non-closure (ded): <x> may not fix <H>
                                    else
                                        coinc := false;
                                    fi;

                                # non-closure (not ded): <x> may not fix <H>
                                elif app[1] <= app[3]  then
                                    coinc := false;
                                fi;

                            od;

                        # # if old is the smaller one very good
                        # elif table[g][c] < r[ table[g][d] ]  then
                        #     later[x] := nract;
                            done:=true;

                        fi;

                        g := g + 2;
                    od;

                    c := c + 1;
                od;

                if c = nrcos + 1  then
                    nrfix := nrfix + 1;
                fi;

              od;
            fi;

            # if there was no coincidence
            if not coinc  then

                # look for another empty place
                c := cos;
                g := gen;
                while c <= nrcos  and table[ g ][ c ] <> 0  do
                    g := g + 2;
                    if g = nrgens  then
                        c := c + 1;
                        g := 1;
                    fi;
                od;

                # if there is an empty place, make this a new choice point
                if c <= nrcos  then

                    nract := nract + 1;
                    action[ nract ] := choice; # necessary?
                    gen := g;
                    actgen[ nract ] := gen;
                    cos := c;
                    actcos[ nract ] := cos;
                    table[ gen ][ cos ] := 0; # necessary?

                # otherwise we found a subgroup
                else

                  # Increase the counter.
                  subs:= subs + 1;

                  # give some information
                  Info( InfoFpGroup, 2,  " class ", subs,
                                " of index ", nrcos,
                                " and length ", nrcos / nrfix );

                  # instead of a coset table,
                  # create the permutation action on the cosets
                  perms:=[];
                  for g  in [ 1 .. ngens ]  do
                    perms[g]:=PermList(table[2*g-1]{[1..nrcos]});
                  od;
                  Q:=Group(perms);
                  sub:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),
                           Q,Stabilizer(Q,1));

                    if HasSize( G ) and Size(G)<>infinity then
                      SetSize( sub, Size( G ) / Index(G,sub) );
                    fi;

                    # undo all deductions since the previous choice point
                    while action[ nract ] = deduction  do
                        g := actgen[ nract ];
                        c := actcos[ nract ];
                        d := table[ g ][ c ];
                        if g mod 2 = 1  then
                            table[ g   ][ c ] := 0;
                            table[ g+1 ][ d ] := 0;
                        else
                            table[ g   ][ c ] := 0;
                            table[ g-1 ][ d ] := 0;
                        fi;
                        nract := nract - 1;
                    od;
                    for x  in [2..index]  do
                        if nract <= later[x]  then
                            later[x] := 0;
                        fi;
                    od;

                # Update the variable components of the iterator.
                iter!.data.nrcos        := nrcos;
                iter!.data.nract        := nract;
                iter!.data.gen          := gen;
                iter!.data.cos          := cos;
                iter!.data.subs         := subs;
                iter!.data.nextSubgroup := sub;

                return false;

              fi;

            # if there was a coincendence go back to the current choice point
            else

                # undo all deductions since the previous choice point
                while action[ nract ] = deduction  do
                    g := actgen[ nract ];
                    c := actcos[ nract ];
                    d := table[ g ][ c ];
                    table[ g ][ c ] := 0;
                    if g mod 2 = 1  then
                        table[ g+1 ][ d ] := 0;
                    else
                        table[ g-1 ][ d ] := 0;
                    fi;
                    nract := nract - 1;
                od;
                for x  in [2..index]  do
                    if nract <= later[x]  then
                        later[x] := 0;
                    fi;
                od;

            fi;

        # go back to the previous choice point if there are no more choices
        else

            # undo the choice point
            if action[ nract ] = definition  then
                nrcos := nrcos - 1;
            fi;
          # undo all deductions since the previous choice point
          repeat
            g := actgen[ nract ];
            c := actcos[ nract ];
            d := table[ g ][ c ];
            table[ g ][ c ] := 0;
            if g mod 2 = 1  then
                table[ g+1 ][ d ] := 0;
            else
                table[ g-1 ][ d ] := 0;
            fi;
            nract := nract - 1;
          until action[ nract ] <> deduction;

            for x  in [2..index]  do
                if nract <= later[x]  then
                    later[x] := 0;
                fi;
            od;

            cos := actcos[ nract ];
            gen := actgen[ nract ];

        fi;

    od;

    # give some final information
    Info( InfoFpGroup, 1, "LowIndexSubgroupsFpGroup done. Found ",
                 subs, " classes" );

    # The iterator is exhausted.
    iter!.data.isDone := true;
    return true;
    end );

BindGlobal( "ShallowCopy_LowIndexSubgroupsFpGroup",
    iter -> rec( data:= StructuralCopy( iter!.data ) ) );


#############################################################################
##
#M  DoLowIndexSubgroupsFpGroupIterator( <G>, <H>, <index>[, <excluded>] ) . .
#M  . . . . . . . find subgroups of small index in a finitely presented group
##
BindGlobal( "DoLowIndexSubgroupsFpGroupIteratorWithSubgroupAndExclude",
    function( arg )
    local G,            # parent group
          H,            # subgroup to be included in all resulting subgroups
          index,        # maximal index of subgroups to be determined
          exclude,      # true, if element classes to be excluded are given
          excludeList,  # representatives of element classes to be excluded
          result,       # result in the trivial case
          fgens,        # generators of associated free group
          ngens,        # number of generators of G
          involutions,  # indices of involutory gens of G
          excludeGens,  # table columns corresponding to gens to be excluded
          excludeWords, # words to be excluded, sorted by start generator
          table,        # coset table
          gen,          # current generator
          subgroup,     # rows for the subgroup gens
          rel,          # loop variable for relators
          r, s,         # renumbering lists
          i, j, g,      # loop variables
          p, p1, p2,    # generator position numbers
          length,       # relator length
          length2,      # twice a relator length
          cols,
          nums,
          word;         # loop variable for words to be excluded

    # give some information
    Info( InfoFpGroup, 1, "LowIndexSubgroupsFpGroup called" );

    # check the arguments
    G := arg[1];
    H := arg[2];
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
      Error( "<G> must be a finitely presented group" );
    elif not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
      Error( "<H> must be a subgroup of <G>" );
    fi;
    index := arg[3];

    # initialize the exclude lists, if elements to be excluded are given
    exclude := Length( arg ) > 3 and not IsEmpty( arg[4] );
    if exclude then
      excludeList := arg[4];
    fi;

    # handle the special case index = 1.
    if index = 1 then
      result:= TrivialIterator( G );
      if exclude then
        NextIterator( result );
      fi;
      return result;
    fi;

    # get some local variables
    fgens := FreeGeneratorsOfFpGroup( G );
    ngens := Length( fgens );
    involutions := IndicesInvolutaryGenerators( G );

    # initialize table
    table := [];
    for i in [ 1 .. Length( fgens ) ] do
        g := ListWithIdenticalEntries( index, 0 );
        Add( table, g );
        if not i in involutions then
          g:= ShallowCopy( g );
        fi;
        Add( table, g );
    od;

    # prepare the exclude lists
    excludeGens := fail;
    excludeWords := fail;
    if exclude then

      # mark the column numbers of the generators to be excluded
      excludeGens := ListWithIdenticalEntries( 2 * ngens, 0 );
      for i in [ 1 .. ngens ] do
        gen := fgens[i];
        if gen in excludeList or gen^-1 in excludeList then
          excludeGens[2*i-1] := 1;
          excludeGens[2*i] := 1;
        fi;
      od;

      # make the rows for the words of length > 1 to be excluded
      excludeWords := [];
      for word in excludeList do
        if Length( word ) > 1 then
          Add( excludeWords, word );
        fi;
      od;
      excludeWords := RelsSortedByStartGen(
          fgens, excludeWords, table, false );

    fi;

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in Filtered(List( GeneratorsOfGroup( H ), UnderlyingElement ),
                         x->not IsOne(x)) do
      length := Length( rel );
      length2 := 2 * length;
      nums := [ ]; nums[length2] := 0;
      cols := [ ]; cols[length2] := 0;

      # compute the lists.
      i := 0;  j := 0;
      while i < length do
        i := i + 1;  j := j + 2;
        gen := Subword( rel, i, i );
        p := Position( fgens, gen );
        if p = fail then
          p := Position( fgens, gen^-1 );
          p1 := 2 * p;
          p2 := 2 * p - 1;
        else
          p1 := 2 * p - 1;
          p2 := 2 * p;
        fi;
        nums[j]   := p1;  cols[j]   := table[p1];
        nums[j-1] := p2;  cols[j-1] := table[p2];
      od;
      Add( subgroup, [ nums, cols ] );
    od;

    # initialize the renumbering lists
    r := [ ]; r[index] := 0;
    s := [ ]; s[index] := 0;

    return IteratorByFunctions( rec(
        # functions
        IsDoneIterator := IsDoneIterator_LowIndexSubgroupsFpGroup,
        NextIterator   := NextIterator_LowIndexSubgroupsFpGroup,
        ShallowCopy    := ShallowCopy_LowIndexSubgroupsFpGroup,

        data:= rec(
          # data components that need no update for the next calls
          G            := G,
          ngens        := ngens,
          index        := index,
          exclude      := exclude,
          excludeGens  := excludeGens,
          excludeWords := excludeWords,
          subs         := 0,            # the number of subgroups up to now
          table        := table,
          action       := [ 2 ],        # 'action[<i>]' is definition or
                                        # choice or deduction
          actgen       := [ 1 ],        # 'actgen[<i>]' is the gen where
                                        # this action was
          actcos       := [ 1 ],        # 'actcos[<i>]' is the coset where
                                        # this action was
          relsGen      := RelsSortedByStartGen( fgens,
                            RelatorRepresentatives( RelatorsOfFpGroup( G ) ),
                            table, true ),
                                        # relators sorted by start generator
          later        := ListWithIdenticalEntries( index, 0 ),
                                        # 'later[<i>]' is <> 0 if <i> is
                                        # smaller than 1
          r            := r,
          s            := s,
          subgroup     := subgroup,

          # data components that must be updated before leaving the function
          nrcos        := 1,            # no. of cosets in the table
          nract        := 1,
          gen          := 1,            # current generator
          cos          := 1,            # current coset
          isDone       := false,        # we do not know this
          nextSubgroup := fail,         # we do not compute the first group
         ) ) );
    end );

InstallMethod( LowIndexSubgroupsFpGroupIterator,
    "full f.p. group, subgroup of it -- still the old code",
    IsFamFamX,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup, IsPosInt ],
    # use this only if the newer method bailed out because a nontrivial
    # subgroup  was submitted as second argument
    -1,
    DoLowIndexSubgroupsFpGroupIteratorWithSubgroupAndExclude );

InstallMethod( LowIndexSubgroupsFpGroupIterator,
    "supply trivial subgroup, with exclusion list",
    [ IsSubgroupFpGroup and IsWholeFamily, IsPosInt, IsList ],
    function( G, n, excluded )
    return DoLowIndexSubgroupsFpGroupIteratorWithSubgroupAndExclude( G,
               TrivialSubgroup( G ), n, excluded );
    end );

InstallMethod( LowIndexSubgroupsFpGroupIterator,
    "full f.p. group, subgroup of it, with exclusion list",
    IsFamFamXY,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup, IsPosInt,
      IsList],
    DoLowIndexSubgroupsFpGroupIteratorWithSubgroupAndExclude );


# newer version of low index -- currently does not support contained subgroups
# or exclusion lists
BindGlobal("LowIndSubs_NextIter",function(iter)
local res;
  if not IsDoneIterator( iter ) then
    res:= iter!.data.nextSubgroup;
    iter!.data.nextSubgroup:= fail;
    return res;
  fi;
  Error( "iterator is exhausted" );
end);

# data types for low index memory blocks
BindGlobal("TYPE_LOWINDEX_DATA",
  NewType(NewFamily("LowIndexDataFamily",IsObject),
    IsObject and IsDataObjectRep));

BindGlobal("IsDoneIter_LowIndSubs",function(iter)
local data, G, N, ts, rels, m, mm, stack1, stack2, mu, nu, s, t, n, i, sj,
j, ok, b,k,tr;

  data:=iter!.data;
  if data.isDone then
    return true;
  elif data.nextSubgroup<>fail then
    return false;
  fi;

  G:=data.G;
  N:=data.N;
  ts:=data.ts;
  rels:=data.rels;
  m:=Length(FreeGeneratorsOfFpGroup(G));
  mm:=2*m-1;

  # stacks for the kernel
  stack1:=List([1..2*N],i->0);
  stack2:=List([1..2*N],i->0);

  # these are scratch space for the kernel (partial permutations)
  mu:=NEW_LOWINDEX_DATA(N);
  nu:=NEW_LOWINDEX_DATA(N);

  tr:=[2*m,2*m-1..1];

  while Length(ts)>0 do
    s:=Remove(ts);
    t:=s[1];
    n:=s[2];
    i:=s[3];
    sj:=s[4];
    if i>mm then
      i:=1;
      sj:=sj+1;
    fi;
    j:=sj;

    # find first open entry
    ok:=true;
    while ok and j<=n do
      if j>sj then
        i:=1;
      fi;
      while ok and i<=mm do
        if t[i][j]=0 then
          # try n+1
          ok:=false;
          if n<N then
            #s:=List(t,ShallowCopy);
            s:=[];
            for k in tr do
              #Add(s,ShallowCopy(k));
              s[k]:=ShallowCopy(t[k]);
            od;
            s[i][j]:=n+1;
            s[i+1][n+1]:=j;
            #Try(s,n+1,i,j);
            stack1[1]:=j;stack2[1]:=i;
            if LOWINDEX_COSET_SCAN(s,rels,stack1,stack2)
                and LOWINDEX_IS_FIRST(s,n+1,mu,nu) then
              Add(ts,[s,n+1,i+2,j]);
            fi;
          fi;

          # try other values (reverse order so that stack process gives same
          # traversal order as recursion)
          for b in [n,n-1..1] do
            if t[i+1][b]=0 then
              # define
              if b>1 then
                #s:=List(t,ShallowCopy);
                s:=[];
                for k in tr do
                  #Add(s,ShallowCopy(k));
                  s[k]:=ShallowCopy(t[k]);
                od;
              else
                # no need to copy as this is the last branch.
                s:=t;
              fi;
              s[i][j]:=b;
              s[i+1][b]:=j;
              #Try(s,n,i,j);
              stack1[1]:=j;stack2[1]:=i;
              if LOWINDEX_COSET_SCAN(s,rels,stack1,stack2)
                and LOWINDEX_IS_FIRST(s,n,mu,nu) then
                if b=1 then
                  ok:=true;
                else
                  Add(ts,[s,n,i+2,j]);
                fi;
              fi;

            fi;
          od;

        fi;
        i:=i+2;
      od;
      j:=j+1;
    od;
    # table is complete
    if ok then
      data.cnt:=data.cnt+1;
      s:=List(t{[1,3..mm]},i->PermList(i{[1..n]}));
      b:=GroupWithGenerators(s,());
      Info( InfoFpGroup, 2,  " class ", data.cnt, " of index ", n,
        ", quotient size ",Size(b));
      data.nextSubgroup:=SubgroupOfWholeGroupByQuotientSubgroup(
         FamilyObj(G),b,Stabilizer(b,1));
                    #" and length ", nrcos / nrfix );
      return false;
    fi;
  od;
  data.isDone:=true;
  return true;
end);

BindGlobal("DoLowIndexSubgroupsFpGroupIterator",function(G,S,N)
local m, rels, rel,w, wo, ok, a, k, t, ts, data, i, j;

  if Length(GeneratorsOfGroup(S))>0 then
    TryNextMethod();
  fi;

  m:=Length(FreeGeneratorsOfFpGroup(G));
  rels:=List([1..2*m],i->[]);
  for i in RelatorsOfFpGroup(G) do
    w:=LetterRepAssocWord(i);
    # cyclic reduction
    while Length(w)>0 and w[1]=-w[Length(w)] do
      w:=w{[2..Length(w)-1]};
    od;

    if Length(w)>0 then
      # all conjugates of w and inverse
      wo:=ShallowCopy(w);
      for j in [1..2] do
        MakeImmutable(w);
        ok:=true;
        while ok do
          if w[1]<0 then
            a:=-2*w[1];
          else
            a:=2*w[1]-1;
          fi;
          if not w in rels[a] then
            AddSet(rels[a],w);
            # cyclic permutation
            w:=Concatenation(w{[2..Length(w)]},[w[1]]);
            MakeImmutable(w);
          else
            # relator known -- this means we have processed everything that
            # is to come
            ok:=false;
          fi;
        od;
        if j=1 then
          # invert wo
          w:=Reversed(-wo);
        fi;
      od;
    fi;
  od;

  # translate rels:
  for i in [1..Length(rels)] do
    for j in [1..Length(rels[i])] do
      rel:=rels[i][j];
      w:=[Length(rel)]; # Length in position 1 (as we change to data type...)
      for k in rel do
        if k<0 then k:=-2*k; else k:=2*k-1;fi;
        Add(w,k);
      od;
      MakeImmutable(w);
      rels[i][j]:=w;
    od;
  od;

  LOWINDEX_PREPARE_RELS(rels);

  t:=List([1..2*m],i->ListWithIdenticalEntries(N,0));

  ts:=[[t,1,1,1]];
  data:=rec(G:=G,
            N:=N,
            ts:=ts,
            rels:=rels,
            cnt:=0,
            nextSubgroup:=fail,
            isDone:=false);

  return IteratorByFunctions(rec(
      IsDoneIterator:=IsDoneIter_LowIndSubs,
      NextIterator:=LowIndSubs_NextIter,
      ShallowCopy:=Error,
      data:=data));

end);



#############################################################################
##
#M  LowIndexSubgroupsFpGroupIterator( <G>[, <H>], <index>[, <excluded>] ) . .
##
InstallMethod( LowIndexSubgroupsFpGroupIterator,
    "supply trivial subgroup",
    [ IsSubgroupFpGroup, IsPosInt ],
    function( G, n )
    return LowIndexSubgroupsFpGroupIterator( G,
               TrivialSubgroup( Parent( G ) ), n );
    end );

InstallMethod( LowIndexSubgroupsFpGroupIterator,
    "full f.p. group, subgroup of it",
    IsFamFamX,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup, IsPosInt ],
    DoLowIndexSubgroupsFpGroupIterator );

InstallMethod( LowIndexSubgroupsFpGroupIterator,
    "subgroups of f.p. group",
    IsFamFamX,
    [ IsSubgroupFpGroup, IsSubgroupFpGroup, IsPosInt ],
    function( G, H, ind )
    local fpi;

    fpi:= IsomorphismFpGroup( G );

    return IteratorByFunctions( rec(
        NextIterator  := function( iter )
            local u, v;

            u:= NextIterator( iter!.fullIterator );
            v:= PreImagesSet( fpi, u );
            SetIndexInWholeGroup( v,
                IndexInWholeGroup( G ) * IndexInWholeGroup( u ) );
            return v;
            end,
        IsDoneIterator := iter -> IsDoneIterator( iter!.fullIterator ),
        ShallowCopy    := iter -> rec( fullIterator:= iter!.fullIterator ),
        fullIterator   := LowIndexSubgroupsFpGroupIterator( Range( fpi ),
                              Image( fpi, H ), ind ),
          ) );
    end );


#############################################################################
##
#M  LowIndexSubgroupsFpGroup(<G>,<H>,<index>[,<excluded>]) . . find subgroups
#M                               of small index in a finitely presented group
##
BindGlobal( "DoLowIndexSubgroupsFpGroupViaIterator", function( arg )
    local iter, result;

    iter:= CallFuncList( LowIndexSubgroupsFpGroupIterator, arg );
    result:= [];
    while not IsDoneIterator( iter ) do
      Add( result, NextIterator( iter ) );
    od;
    return result;
    end );

InstallMethod(LowIndexSubgroupsFpGroup, "subgroups of full fp group",
  IsFamFamX,
  [IsSubgroupFpGroup and IsWholeFamily,IsSubgroupFpGroup,IsPosInt],0,
  DoLowIndexSubgroupsFpGroupViaIterator );

InstallMethod(LowIndexSubgroups, "FpFroups, using LowIndexSubgroupsFpGroup",
  true,
  [IsSubgroupFpGroup,IsPosInt],
  # rank higher than method for finit groups using maximal subgroups
  {} -> RankFilter(IsGroup and IsFinite),
  LowIndexSubgroupsFpGroup );

InstallOtherMethod(LowIndexSubgroupsFpGroup,
  "subgroups of full fp group, with exclusion list", IsFamFamXY,
  [IsSubgroupFpGroup and IsWholeFamily,IsSubgroupFpGroup,IsPosInt,IsList],0,
  DoLowIndexSubgroupsFpGroupViaIterator );

InstallOtherMethod(LowIndexSubgroupsFpGroup,
  "supply trivial subgroup", true,
  [IsSubgroupFpGroup,IsPosInt],0,
function(G,n)
  return LowIndexSubgroupsFpGroup(G,TrivialSubgroup(Parent(G)),n);
end);

InstallOtherMethod( LowIndexSubgroupsFpGroup,
    "with exclusion list, supply trivial subgroup",
    [ IsSubgroupFpGroup and IsWholeFamily, IsPosInt, IsList ],
    function( G, n, exclude )
      return LowIndexSubgroupsFpGroup( G, TrivialSubgroup( G ), n, exclude );
    end);

InstallMethod(LowIndexSubgroupsFpGroup, "subgroups of fp group",
  IsFamFamX, [IsSubgroupFpGroup,IsSubgroupFpGroup,IsPosInt],0,
function(G,H,ind)
local fpi,u,l,i,a;
  fpi:=IsomorphismFpGroup(G);
  u:=LowIndexSubgroupsFpGroup(Range(fpi),Image(fpi,H),ind);

  l:=[];
  for i in u do
    a:=PreImagesSet(fpi,i);
    SetIndexInWholeGroup(a,IndexInWholeGroup(G)*IndexInWholeGroup(i));
    Add(l,a);
  od;
  return l;
end);



#############################################################################
##
#M  NormalizerOp(<G>,<H>)
##
InstallMethod(NormalizerOp,"subgroups of fp group: find stabilizing cosets",
  IsIdenticalObj,[IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function ( G, H )
local   N,          # normalizer of <H> in <G>, result
        Ntab,       # normalizer coset table
        pargens,    # parent generators
        table,      # coset table of <H> in its parent
        nrcos,      # number of cosets in the table
        nrgens,     # 2*(number of generators of <H>s parent)+1
        iseql,      # true if coset <c> normalizes <H>
        r,          # renumbering of the coset table
        t,          # list of renumbered cosets
        n,          # number of renumbered cosets
        c, i, j, k, # coset loop variables
        g,          # generator loop variable
        tgi, tgj,   # table entries
        d;          # orbit length

  # compute the normalizer in the full group.

  # first we need the coset table of <H>
  table := CosetTableInWholeGroup(H);
  pargens:=GeneratorsOfGroup(FamilyObj(G)!.wholeGroup);
  nrcos := IndexCosetTab( table );
  nrgens := 2*Length( pargens ) + 1;

  # find the cosets of <H> in its parent whose elements normalize <H>
  N := [1];
  t := 0 * [ 1 .. nrcos ];
  for c  in [ 2 .. nrcos ]  do

    # test if the renumbered table is equal to the original table
    r := 0 * [ 1 .. nrcos ];
    r[c] := 1;
    t[1] := c;
    n := 1;
    k := 1;
    iseql := true;
    while k < nrcos  and iseql  do
      j := t[k];
      i := r[j];
      g := 1;
      while g < nrgens  and iseql  do
        tgi := table[g][i];
        tgj := table[g][j];
        if r[tgj] = 0  then
          n := n + 1;
          t[n] := tgj;
          r[tgj] := tgi;
        else
          iseql := r[tgj] = tgi;
        fi;
        g := g + 2;
      od;
      k := k + 1;
    od;

    # add the index of this coset if it normalizes
    if iseql  then
      AddSet(N,c);
    fi;

  od;

  # now N is the block representing the normalizer cosets.

  if Length(N)=1 then
    # self-normalizing
    N:=H;
  else
    # form the whole block system
    table:=List(table{[1,3..Length(table)-1]},PermList);
    N:=Orbit(Group(table,()),N,OnSets);
    N:=Set(N);
    d:=Length(N);

    # make a table for the action on these blocks.
    N:=List(table,i->Permutation(i,N,OnSets));
    Ntab:=[];
    for c in N do
      Add(Ntab,OnTuples([1..d],c));
      Add(Ntab,OnTuples([1..d],c^-1));
    od;
    StandardizeTable(Ntab);

    N:=SubgroupOfWholeGroupByCosetTable(FamilyObj(H),Ntab);
  fi;

  # if necessary intersect with G
  if HasIsWholeFamily(G) and IsWholeFamily(G) then
    return N;
  fi;
  N:=Intersection(G,N);

  return N;
end);

InstallMethod(NormalizerOp,"subgroups of fp group by quot. rep",
  IsIdenticalObj,
    [ IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
local d,A,B,e1,e2,Ag,Bg,s,sg,u,v;

  A:=MakeNiceDirectQuots(G,H);
  G:=A[1];
  H:=A[2];

  A:=G!.quot;
  B:=H!.quot;
  # are we represented in the same quotient?
  if GeneratorsOfGroup(A)=GeneratorsOfGroup(B) then
    # we are, compute simply in the quotient
    return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),G!.quot,
             Normalizer(G!.sub,H!.sub));
  fi;

  d:=DirectProduct(A,B);
  e1:=Embedding(d,1);
  e2:=Embedding(d,2);
  Ag:=GeneratorsOfGroup(A);
  Bg:=GeneratorsOfGroup(B);
  # form the sdp
  sg:=List([1..Length(Ag)],i->Image(e1,Ag[i])*Image(e2,Bg[i]));
  s:=SubgroupNC(d,sg);
  Assert(1,GeneratorsOfGroup(s)=sg);

  # get both subgroups in the direct product via the projections
  # instead of intersecting both preimages with s we only intersect the
  # intersection
  u:=PreImagesSet(Projection(d,1),G!.sub);
  v:=PreImagesSet(Projection(d,2),H!.sub);
  u:=Intersection(u,s);
  v:=Intersection(v,s);

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),s,
            Normalizer(u,v));

end);

InstallMethod(NormalizerOp,"in whole group by quot. rep",
  IsIdenticalObj,
    [ IsSubgroupFpGroup and IsWholeFamily,
      IsSubgroupFpGroup  and IsSubgroupOfWholeGroupByQuotientRep], 0,
function(G,H)
  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(G),H!.quot,
            Normalizer(H!.quot,H!.sub));
end);


#############################################################################
##
#F  MostFrequentGeneratorFpGroup( <G> ) . . . . . . . most frequent generator
##
##  is an internal function which is used in some applications of coset
##  table methods. It returns the first of those generators of the given
##  finitely presented group <G> which occur most frequently in the
##  relators.
##
InstallGlobalFunction( MostFrequentGeneratorFpGroup, function ( G )

    local altered, gens, gens2, i, i1, i2, k, max, j, num, numgens,
          numrels, occur, power, rel, relj, rels, set;

#@@ # check the first argument to be a finitely presented group.
#@@ if not ( IsRecord( G ) and IsBound( G.isFpGroup ) and G.isFpGroup ) then
#@@     Error( "argument must be a finitely presented group" );
#@@ fi;

    # Get some local variables.
    gens := FreeGeneratorsOfFpGroup( G );
    rels := RelatorsOfFpGroup( G );
    numgens := Length( gens );
    numrels := Length( rels );

    # Initialize a counter.
    occur := ListWithIdenticalEntries( numgens, 0 );
    power := ListWithIdenticalEntries( numgens, 0 );

    # initialize a list of the generators and their inverses
    gens2 := [ ]; gens2[numgens] := 0;
    for i in [ 1 .. numgens ] do
      gens2[i] := AbsInt(LetterRepAssocWord(gens[i])[1]);
      gens2[numgens+i] := -gens2[i];
    od;

    # convert the relators to vectors of generator numbers and count their
    # occurrences.
    for j in [ 1 .. numrels ] do

        # convert the j-th relator to a Tietze relator
        relj := LetterRepAssocWord(rels[j]);
        i1 := 1;
        i2 := Length( relj );
        while i1 < i2 and relj[i1]=-relj[i2] do
            i1 := i1 + 1;
            i2 := i2 - 1;
        od;
        rel := List([i1..i2], i -> Position( gens2, relj[i] ));

        # count the occurrences of the generators in rel
        for i in [ 1 .. Length( rel ) ] do
            k := rel[i];
            if k = fail then
                Error( "given relator is not a word in the generators" );
            elif k <= numgens then
                occur[k] := occur[k] + 1;
            else
                k := k - numgens;
                rel[i] := -k;
                occur[k] := occur[k] + 1;
            fi;
        od;
        # check the current relator for being a power relator.
        set := Set( rel );
        if Length( set ) = 2 then
            num := [ 0, 0 ];
            for i in rel do
                if i = set[1] then num[1] := num[1] + 1;
                else num[2] := num[2] + 1; fi;
            od;
            if num[1] = 1 then
                power[AbsInt( set[2] )] := AbsInt( set[1] );
            elif num[2] = 1 then
                power[AbsInt( set[1] )] := AbsInt( set[2] );
            fi;
        fi;
    od;

    # increase the occurrences numbers of generators which are roots of
    # other ones, but avoid infinite loops.
    i := 1;
    altered := true;
    while altered do
        altered := false;
        for j in [ i .. numgens ] do
            if power[j] > 0 and power[power[j]] = 0 then
                occur[j] := occur[j] + occur[power[j]];
                power[j] := 0;
                altered := true;
                if i = j then i := i + 1; fi;
            fi;
        od;
    od;

    # find the most frequently occurring generator and return it.
    i := 1;
    max := occur[1];
    for j in [ 2 .. numgens ] do
        if occur[j] > max then
            i := j;
            max := occur[j];
        fi;
    od;
    gens := GeneratorsOfGroup( G );
    return gens[i];
end );


#############################################################################
##
#F  RelatorRepresentatives(<rels>) . set of representatives of a list of rels
##
##  'RelatorRepresentatives' returns a set of  relators,  that  contains  for
##  each relator in the list <rels> its minimal cyclical  permutation  (which
##  is automatically cyclically reduced).
##
InstallGlobalFunction( RelatorRepresentatives, function ( rels )
local reps, word, length, fam, reversed, cyc, min, rel, i,j;

    reps := [ ];

    # loop over all nontrivial relators
    for rel in rels  do

#        length := NrSyllables( rel );
#        if length > 0  then
#
#            # invert the exponents to their negative values in order to get
#            # an appropriate lexicographical ordering of the relators.
#            fam := FamilyObj( rel );
#
#            list := ShallowCopy(ExtRepOfObj( rel ));
#            for i in [ 2, 4 .. Length( list ) ] do
#                list[i] := -list[i];
#            od;
#            reversed := ObjByExtRep( fam, list );
#
##            # find the minimal cyclic permutation
#            cyc := reversed;
#            min := cyc;
#            if cyc^-1 < min  then min := cyc^-1;  fi;
#            for i  in [ 1 .. length ]  do
#              g:=ObjByExtRep(fam,[GeneratorSyllable(reversed,i),
#                                  SignInt(ExponentSyllable(reversed,i))]);
#              for j in [1..AbsInt(ExponentSyllable(reversed,i))] do
#                cyc := cyc ^ g;
#                if cyc    < min  then min := cyc;     fi;
#                if cyc^-1 < min  then min := cyc^-1;  fi;
#              od;
#            od;
#
#            # if the relator is new, add it to the representatives
#            min:=Immutable([ Length( min ), min ] );
#            if not min in reps  then
#                AddSet( reps,min);
#            fi;
#
#        fi;


      word:=LetterRepAssocWord(rel);
      length:=Length(word);
      if length>0 then
        # invert the exponents to their negative values in order to get
        # an appropriate lexicographical ordering of the relators.
        word:=-word;
        fam:=FamilyObj( rel );
        reversed:=AssocWordByLetterRep(fam,word);

        # find the minimal cyclic permutation
        cyc:=reversed;
        min:=cyc;
        if cyc^-1<min then min:=cyc^-1;fi;
        i:=1;
        while i<=length do
          j:=1;
          while j<Length(word) and word[j]=word[j+1] do j:=j+1;od;
          word:=Concatenation(word{[j+1..Length(word)]},word{[1..j]});
          cyc:=AssocWordByLetterRep(fam,word);
          if cyc<min then min:=cyc;fi;
          if cyc^-1<min then min:=cyc^-1;fi;
          i:=i+j;
          #g:=AssocWordByLetterRep(fam,word{[i]});
          #g:=Subword(cyc,1,1);
          #cyc:=cyc^g;
        od;

        # if the relator is new, add it to the representatives
        min:=Immutable([ Length( min ), min ] );
        if not min in reps  then
          AddSet( reps,min);
        fi;

      fi;
    od;

    # reinvert the exponents.
    for i in [ 1 .. Length( reps ) ]  do
      rel := reps[i][2];
      fam := FamilyObj( rel );
#        list := ShallowCopy(ExtRepOfObj( rel ));
#        for j in [ 2, 4 .. Length( list ) ] do
#            list[j] := -list[j];
#        od;
#        reps[i] := ObjByExtRep( fam, list );
      reps[i]:=AssocWordByLetterRep(fam,-LetterRepAssocWord(rel));
    od;

    # return the representatives
    return reps;
end );


#############################################################################
##
#M  RelatorsOfFpGroup( F )
##
InstallMethod( RelatorsOfFpGroup,
    "for finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.relators );


#############################################################################
##
#M  IndicesInvolutaryGenerators( F )
##
InstallMethod( IndicesInvolutaryGenerators, "for finitely presented group",
  true, [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function(G)
local g,r;
  g:=FreeGeneratorsOfFpGroup(G);
  r:=RelatorsOfFpGroup(G);
  r:=Filtered(r,i->NumberSyllables(i)=1);
  return Filtered([1..Length(g)],i->g[i]^2 in r or g[i]^-2 in r);
end);


#############################################################################
##
#F  RelsSortedByStartGen( <gens>, <rels>, <table> [, <ignore> ] )
#F                                         relators sorted by start generator
##
##  'RelsSortedByStartGen'  is a  subroutine of the  Felsch Todd-Coxeter  and
##  the  Reduced Reidemeister-Schreier  routines. It returns a list which for
##  each  generator or  inverse generator  contains a list  of all cyclically
##  reduced relators,  starting  with that element,  which can be obtained by
##  conjugating or inverting given relators.  The relators are represented as
##  lists of the coset table columns corresponding to the generators and,  in
##  addition, as lists of the respective column numbers.
##
##  Square relators  will be ignored  if ignore = true.  The default value of
##  ignore is false.
##
InstallGlobalFunction( RelsSortedByStartGen, function ( arg )
local   gens,                   # group generators
        gennums,                # indices of generators
        rels,                   # relators
        table,                  # coset table
        ignore,                 # if true, ignore square relators
        relsGen,                # resulting list
        rel,                    # one relator and cyclic permutation
        length, extleng,        # length and extended length of rel
        base, base2,            # base length of rel
        gen,                    # one generator in rel
        es,                     # exponents sum
        nums, invnums,          # numbers list and inverse
        cols, invcols,          # columns list and inverse
        p, p1, p2,              # positions of generators
        l,m,poslist,
        i, j, k;                # loop variables

    # get the arguments
    gens := arg[1];
    # the indices of the generators
    gennums:= List(gens,i->AbsInt(LetterRepAssocWord(i)[1]));

    poslist:=List([1..Maximum(gennums)],i->Position(gennums,i));
    rels := arg[2];
    table := arg[3];
    ignore := false;
    if  Length( arg ) > 3 then  ignore := arg[4];  fi;

    # check that the table has the right number of columns
    if 2 * Length(gens) <> Length(table) then
        Error( "table length is inconsistent with number of generators" );
    fi;

    # initialize the list to be constructed
    relsGen := [ ]; relsGen[2*Length(gens)] := 0;
    for i  in [ 1 .. Length(gens) ]  do
        relsGen[ 2*i-1 ] := [];
        if not IsIdenticalObj( table[ 2*i-1 ], table[ 2*i ] )  then
            relsGen[ 2*i ] := [];
        else
            relsGen[ 2*i ] := relsGen[ 2*i-1 ];
        fi;
    od;

    # now loop over all parent group relators
    for rel  in rels  do

        # get the length and the basic length of relator rel
        length := Length( rel );
        base := 1;

#        cyc := rel ^ Subword( rel, base, base );
#        while cyc <> rel do
#            base := base + 1;
#            cyc := cyc ^ Subword( rel, base, base );
#        od;

        # work in letter rep
        es:=LetterRepAssocWord(rel);

        base:=2;
        l:=Length(es);
        m:=l-base+1;

        while (base<=l) and (es{[base..l]}<>es{[1..m]} or
                             es{[1..base-1]}<>es{[m+1..l]}) do
          base:=base+1;
          m:=m-1;
        od;
        base:=base-1;

#        m:=base;
#        base:=1;
#        cyc := rel ^ Subword( rel, base, base );
#        while cyc <> rel do
#            base := base + 1;
#            cyc := cyc ^ Subword( rel, base, base );
#        od;
#        if m<>base then
#          Error("Y");
#        fi;

        # ignore square relators
        if length <> 2 or base <> 1 or not ignore then

            # initialize the columns and numbers lists corresponding to the
            # current relator
            base2 := 2 * base;
            extleng := 2 * ( base + length ) - 1;
            nums    := [ ]; nums[extleng]    := 0;
            cols    := [ ]; cols[extleng]    := 0;
            invnums := [ ]; invnums[extleng] := 0;
            invcols := [ ]; invcols[extleng] := 0;

            # compute the lists
            i := 0;  j := 1;  k := base2 + 3;
            rel:=LetterRepAssocWord(rel);
            while i < base do
                i := i + 1;  j := j + 2;  k := k - 2;
                gen := rel[i];
                if gen>0 then
                  p:=poslist[gen];
                  p1 := 2 * p - 1;
                  p2 := 2 * p;
                else
                  p:=poslist[-gen];
                  p1 := 2 * p;
                  p2 := 2 * p - 1;
                fi;
                nums[j]   := p1;         invnums[k-1] := p1;
                nums[j-1] := p2;         invnums[k]   := p2;
                cols[j]   := table[p1];  invcols[k-1] := table[p1];
                cols[j-1] := table[p2];  invcols[k]   := table[p2];
                Add( relsGen[p1], [ nums, cols, j ] );
                Add( relsGen[p2], [ invnums, invcols, k ] );
            od;

            while j < extleng do
                j := j + 1;
                nums[j] := nums[j-base2];  invnums[j] := invnums[j-base2];
                cols[j] := cols[j-base2];  invcols[j] := invcols[j-base2];
            od;

            nums[1] := length;          invnums[1] := length;
            cols[1] := 2 * length - 3;  invcols[1] := cols[1];
        fi;
    od;

    # return the list
    return relsGen;
end );

#############################################################################
##
#M  FinIndexCyclicSubgroupGenerator( <G>, <maxtable> )
##
##  tries to find a cyclic subgroup of finite index. This tries coset
##  enumerations with cumulatively bigger coset tables up to table size
##  <maxtable>. It returns `fail' if no table could be found.
BindGlobal("FinIndexCyclicSubgroupGenerator",function(G,maxtable)
  local fgens, grels, powers, max, gens, t, Attempt, perms, short;

  fgens:=FreeGeneratorsOfFpGroup(G);
  grels:=RelatorsOfFpGroup(G);

  max:=ValueOption("max");
  if max=fail then
    max:=CosetTableDefaultMaxLimit;
  fi;
  max:=Minimum(max,maxtable);

  powers := List(grels, ExtRepOfObj);
  powers := Filtered(powers, x -> Length(x) = 2);
  if not IsEmpty(powers) then
    SortBy(powers, x -> x[2]);
    if Last(powers)[2] > 10 then
      max := Last(powers)[2];
    fi;
  fi;

  # take the generators, most frequent first
  gens:=GeneratorsOfGroup(G);
  t:=MostFrequentGeneratorFpGroup(G);
  gens:=Concatenation([t,
    #pseudorandom element - try if it works
    PseudoRandom(G:radius:=Random(2,3))],
    Filtered(gens,j->UnderlyingElement(j)<>UnderlyingElement(t)));
  gens:=Set(gens,UnderlyingElement);

  # recursive search (via smaller and smaller partitions) for a finite index
  # subgroup
  Attempt:=function(sgens)
  local l,m,t,trial;
    l:=Length(sgens);
    m:=Int((l-1)/2)+1; #middle, rounded up

    trial:=sgens{[1..m]};
    Info(InfoFpGroup,1,"FIS: trying ",trial);
    t:=CosetTableFromGensAndRels(fgens,grels,
        trial:silent:=true,max:=max);
    if t<>fail and Length(trial)>1 then
      Unbind(t);
      t:=Attempt(trial);
      if t<>fail then
        return t;
      fi;
    fi;
    if t=fail then
      trial:=sgens{[m+1..l]};
      Info(InfoFpGroup,1,"FIS: trying other half ",trial);
      t:=CosetTableFromGensAndRels(fgens,grels,
          List(trial,UnderlyingElement):silent:=true,max:=max);
      if t=fail then
        return fail;
      elif Length(trial)>1 then
        Unbind(t);
        return Attempt(trial);
      fi;
    fi;
    Info(InfoFpGroup,1,"FIS: found ",IndexCosetTab(t));
    return [trial[1],t,max];
  end;

  while max<=maxtable do
    t:=Attempt(gens);
    if t<>fail then
      # do not try to redo the work if the index is comparatively small, as
      # it's not worth doing double work in this case.
      if Length(t[2][1])<100 then
        return [ElementOfFpGroup(FamilyObj(One(G)),t[1]),max];
      fi;

      perms:=List(t[2]{[1,3..Length(t[2])-1]},PermList);
      short:=FreeGeneratorsOfFpGroup(G);
      short:=Concatenation(short, List(short,Inverse));
      short:=Set(Concatenation(List([1..3],x->Arrangements(short,x))),
                 Product);
      short:=List(short,
        x->[Order(MappedWord(x,FreeGeneratorsOfFpGroup(G),perms)),x]);
      # prefer large order and short word length
      SortBy(short,x->[x[1],-Length(x[2])]);
      Info(InfoFpGroup,1,"FIS: better ",short[Length(short)][1]);
      return [ElementOfFpGroup(FamilyObj(One(G)),short[Length(short)][2]),
              max];
    fi;
    if max*3/2<maxtable and max*2>maxtable then
      max:=maxtable;
    else
      max:=max*2;
    fi;
    if max<=maxtable then
      Info(InfoWarning,1,
        "Coset table calculation failed -- trying with bigger table limit");
    fi;
  od;
  return fail;
end);

#############################################################################
##
#M  Size( <G> )  . . . . . . . . . . . . . size of a finitely presented group
##
InstallMethod(Size, "for finitely presented groups", true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function( G )
local   fgens,      # generators of the free group
        rels,       # relators of <G>
        H,          # subgroup of <G>
        gen,        # generator of cyclic subgroup
        max,        # maximal coset table length required
        e,
        T;          # coset table of <G> by <H>

  fgens := FreeGeneratorsOfFpGroup( G );
  rels  := RelatorsOfFpGroup( G );

  # handle free and trivial group
  if 0 = Length( fgens ) then
      return 1;
  elif Length( fgens ) > Length(rels) then
      return infinity;

  # handle nontrivial fp group by computing the index of its trivial
  # subgroup
  else
    # the abelian invariants are comparatively cheap
    if 0 in AbelianInvariants(G) then
      return infinity;
    fi;
    # the group could be quite big -- try to find a cyclic subgroup of
    # finite index.
    gen:=FinIndexCyclicSubgroupGenerator(G,infinity);
    max:=gen[2];
    gen:=gen[1];

    H := Subgroup(G,[gen]);
    T := NEWTC_CosetEnumerator( FreeGeneratorsOfFpGroup(G),
          RelatorsOfFpGroup(G),GeneratorsOfGroup(H),true,false:
            cyclic:=true,limit:=1+max );
    e:=NEWTC_CyclicSubgroupOrder(T);
    SetCyclicSubgroupFpGroup(G, H);
    # TODO is this correct?
    SetAugmentedCosetTableMtcInWholeGroup(H, T);
    if e=0 then
      return infinity;
    else
      return T.index * e;
    fi;
  fi;

end );


#############################################################################
##
#M  Size( <H> )  . . . . . . size of s subgroup of a finitely presented group
##
InstallMethod(Size,"subgroups of finitely presented groups",true,
    [ IsSubgroupFpGroup ], 0,

function( H )
    local G;

    # Get whole group <G> of <H>.
    G := FamilyObj( H )!.wholeGroup;

    # Compute the size of <G> and the index of <H> in <G>.
    return Size( G ) / IndexInWholeGroup( H );

end );

InstallMethod(Size,"infinite abelianization",true,
    [IsSubgroupFpGroup and HasAbelianInvariants],0,
function(G)
  if 0 in AbelianInvariants(G) then
    return infinity;
  else
    TryNextMethod();
  fi;
end);


#############################################################################
##
#M  IsomorphismPermGroup(<G>)
##
InstallGlobalFunction(IsomorphismPermGroupOrFailFpGroup,
function(arg)
local mappow, G, max, p, gens, rels, comb, i, l, m, H, t, gen, sz,
  t1, bad, trial, b, bs, r, nl, o, u, rp, eo, rpo, e, e2, sc, j, z,
  timerFunc,amax,iso,useind;

  timerFunc := GET_TIMER_FROM_ReproducibleBehaviour();

  mappow:=function(n,g,e)
    while e>0 do
      n:=n^g;
      e:=e-1;
    od;
    return n;
  end;

  G:=arg[1];
  if HasIsomorphismPermGroup(G) then
    return IsomorphismPermGroup(G);
  fi;

  # abelian invariants is comparatively cheap
  if 0 in AbelianInvariants(G) then
    SetSize(G,infinity);
    return fail;
  fi;

  if Length(arg)>1 then
    max:=arg[2];
  else
    max:=CosetTableDefaultMaxLimit;
  fi;

  # handle free and trivial group
  if 0 = Length( FreeGeneratorsOfFpGroup( G )) then
    p:=GroupHomomorphismByImagesNC(G,GroupByGenerators([],()),[],[]);
    SetIsomorphismPermGroup(G,p);
    return p;
  fi;

  gens:=FreeGeneratorsOfFpGroup(G);
  rels:=RelatorsOfFpGroup(G);

  # build combinations
  comb:=[gens];
  i:=1;
  while i<=Length(comb) do
    l:=Length(comb[i]);
    if l>1 then
      m:=Int((l-1)/2)+1;
      Add(comb,comb[i]{[1..m]});
      Add(comb,comb[i]{[m+1..l]});
    fi;
    i:=i+1;
  od;
  comb:=Concatenation(
    # a few combs: all gen but one
    List(
      Set([1..3],i->Random(1,Length(gens))),
      i->gens{Difference([1..Length(gens)],[i])}),
    # first combination is full list and thus uninteresting
    comb{[2..Length(comb)]});
  Add(comb,[]);

  H:=[]; # indicate pseudo-size 0
  if not HasSize(G) then
    Info(InfoFpGroup,1,"First compute size via cyclic subgroup");
    t:=FinIndexCyclicSubgroupGenerator(G,max);
    if t<>fail then
      gen:=t[1];
      Unbind(t);
      t := NEWTC_CosetEnumerator( FreeGeneratorsOfFpGroup(G),
            RelatorsOfFpGroup(G),[gen],true,false:
              cyclic:=true,limit:=1+max,quiet:=true );
    fi;

    if t=fail then
      # we cannot get the size within the permitted limits -- give up
      return fail;
    fi;
    e:=NEWTC_CyclicSubgroupOrder(t);
    if e=0 then
      SetSize(G,infinity);
      return fail;
    fi;
    sz:=e*t.index;
    SetSize(G,sz);
    Info(InfoFpGroup,1,"found size ",sz);
    if sz>200*t.index then
      # try the corresponding perm rep
      p:=t.ct{t.offset+[1..Length(FreeGeneratorsOfFpGroup(G))]};
      Unbind(t);

      for j in [1..Length(p)] do
        p[j]:=PermList(p[j]);
      od;
      H:= GroupByGenerators( p );
      # compute stabilizer chain with size info.
      StabChain(H,rec(limit:=sz));
      if Size(H)<sz then
        # don't try this again
        comb:=Filtered(comb,i->i<>[gen]);
      fi;
    else
      # for memory reasons it might be better to try other perm rep first
      Unbind(t);
    fi;

  elif Size(G)=infinity then
    return fail;
  fi;

  sz:=Size(G);
  if sz*10>max then
    max:=sz*10;
  fi;

  # Do not die on large coset table
  amax:=max;
  if max>10^4*sz then
    max:=10^3*sz;
  fi;

  amax:=Maximum(amax,max+1);

  useind:=false;
  t1:=timerFunc();
  while max<amax do
    bad:=[];
    i:=1;
    while Size(H)<sz and i<=Length(comb) do
      trial:=comb[i];
      if not ForAny(bad,i->IsSubset(i,trial)) then
        Info(InfoFpGroup,1,"Try subgroup ",trial," with ",max);
        t:=CosetTableFromGensAndRels(gens,rels,trial:silent:=true,max:=max );
        if t<>fail then
          Info(InfoFpGroup,1,"has index ",IndexCosetTab(t));
          p:=t{[1,3..Length(t)-1]};
          Unbind(t);
          for j in [1..Length(p)] do
            p[j]:=PermList(p[j]);
          od;
          H:= GroupByGenerators( p );
          # compute stabilizer chain with size info.
          if Length(trial)=0 then
            # regular is faithful
            SetSize(H,sz);
          else
            StabChain(H,rec(limit:=sz));
          fi;


          # try to use induced rep
          if Size(H)<sz and Size(H)>1 then
            iso:=IsomorphismFpGroup(SubgroupNC(G,
              List(trial,x->ElementOfFpGroup(FamilyObj(One(G)),x))
              ):silent:=true,max:=2*max);
            H:=Range(iso);
            t:=IsomorphismPermGroupOrFailFpGroup(H,max);
            if t<>fail then
              t:=iso*t;
              iso:=InducedRepFpGroup(t,Source(iso));
              H:=Group(List(GeneratorsOfGroup(G),
                x->ImagesRepresentative(iso,x)));
              StabChain(H,rec(limit:=sz));
              if IsAbelian(H) then
                t:=MinimalFaithfulPermutationRepresentation(H);
                H:=Group(List(GeneratorsOfGroup(H),
                  x->ImagesRepresentative(t,x)));
                StabChain(H,rec(limit:=sz));
              fi;
              useind:=true;
            fi;
          fi;
        else
          # note that this subset fails a coset enumeration
          Add(bad,Set(trial));
        fi;
      fi;

      i:=i+1;
    od;
    max:=Minimum(amax,max*10);
  od;

  if Size(H)<sz then
    # we did not succeed
    return fail;
  fi;

  Info(InfoFpGroup,1,"faithful representation of degree ",NrMovedPoints(H));

  # regular case (unless induced)?
  if Size(H)=NrMovedPoints(H) and not useind then
    t1:=timerFunc()-t1;
    # try to find a cyclic subgroup that gives a faithful rep.
    b:=fail;
    bs:=1;
    t1:=t1*4;
    repeat
      t1:=t1+timerFunc();
      r:=Random(H);
      nl:=[];
      o:=Order(r);
      Info(InfoFpGroup,3,"try ",o);
      u:=DivisorsInt(o);
      for i in u do
        if i>bs and not ForAny(nl,z->IsInt(i/z)) then
          rp:=r^(o/i);
          eo:=[1]; # {1} is a base
          for z in [2..i] do
            Add(eo,eo[Length(eo)]^rp);
          od;
          rpo:=[0..i-1];
          SortParallel(eo,rpo);
          e:=ShallowCopy(eo);
          repeat
            bad:=false;
            for z in GeneratorsOfGroup(H) do
              e2:=Set(e,j->mappow(1/z,rp,rpo[Position(eo,j)])^z);
              if not 1 in e2 then
                Error("one!");
              fi;
              e:=Filtered(e,i->i in e2);
              bad:=bad or Length(e)<Length(e2);
            od;
          until not bad;
          sc:=Length(e);
          if sc=1 then
            b:=rp;
            bs:=i;
            Info(InfoFpGroup,3,"better order ",bs);
          else
            Info(InfoFpGroup,3,"core size ",sc);
            AddSet(nl,sc); # collect core sizes
          fi;
        fi;
      od;
      t1:=t1-timerFunc();
    until t1<0;
    if b<>fail then
      b:=Orbit(H,Set(OrbitPerms([b],1)),OnSets);
      b:=ActionHomomorphism(H,b,OnSets);
      H:=Group(List(GeneratorsOfGroup(H),i->Image(b,i)),());
      Info(InfoFpGroup,2,"nonregular degree ",NrMovedPoints(H));
      SetSize(H,sz);
    fi;

  fi;

  if NrMovedPoints(H)*10>=Size(H) then
    p:=SmallerDegreePermutationRepresentation(H);
  else
    p:=SmallerDegreePermutationRepresentation(H:cheap);
  fi;
  # tell the family that we can now compare elements
  SetCanEasilyCompareElements(FamilyObj(One(G)),true);
  SetCanEasilySortElements(FamilyObj(One(G)),true);

  r:=Range(p);
  SetSize(r,Size(H));
  p:= GroupHomomorphismByImagesNC(G,r,GeneratorsOfGroup(G),
                        List(GeneratorsOfGroup(H),i->Image(p,i)));
  SetIsInjective(p,true);
  i:=NrMovedPoints(Range(p));
  if i<NrMovedPoints(H) then
    Info(InfoFpGroup,1,"improved to degree ",i);
  fi;
  SetIsomorphismPermGroup(G,p);
  return p;
end);

InstallMethod(IsomorphismPermGroup,"for full finitely presented groups",
    true, [ IsGroup and IsSubgroupFpGroup and IsGroupOfFamily ],
    # as this method may be called to compare elements we must get higher
    # than a method for finite groups (via right multiplication).
    {} -> RankFilter(IsFinite and IsGroup),
function(G)
  return IsomorphismPermGroupOrFailFpGroup(G,10^30);
end);

InstallMethod(IsomorphismPermGroup,"for subgroups of finitely presented groups",
    true, [ IsGroup and IsSubgroupFpGroup ],
    # even if we don't demand to know to be finite, we have to assume it.
    {} -> RankFilter(IsFinite and IsGroup),
function(G)
local P,imgs,hom;
  Size(G);
  P:=FamilyObj(G)!.wholeGroup;
  if (HasSize(P) and Size(P)<10^6) or HasIsomorphismPermGroup(P) then
    hom:=IsomorphismPermGroup(P);
    imgs:=List(GeneratorsOfGroup(G),i->Image(hom,i));
    hom:=GroupHomomorphismByImagesNC(G,Subgroup(Range(hom),imgs),
       GeneratorsOfGroup(G),imgs);
  else
    hom:=IsomorphismFpGroup(P);
    hom:=hom*IsomorphismPermGroup(Image(hom));
  fi;
  SetIsBijective(hom,true);
  return hom;
end);

InstallOtherMethod(IsomorphismPermGroup,"for family of fp words",true,
  [IsElementOfFpGroupFamily],0,
function(fam)
  # use the full group
  return IsomorphismPermGroup(CollectionsFamily(fam)!.wholeGroup);
end);

InstallMethod(IsomorphismPcGroup,
  "for finitely presented groups that know their size",
    true, [ IsGroup and IsSubgroupFpGroup and IsFinite and HasSize],0,
function(G)
local s, a, hom;
  s:=Size(G);
  if not (HasIsWholeFamily(G) and IsWholeFamily(G)) then
    a:=IsomorphismFpGroup(G);
    G:=Image(a);
    SetSize(G,s);
  else
    a:=fail;
  fi;
  hom:=EpimorphismSolvableQuotient(G,s);
  if Size(Image(hom))<>s then
    Error("group is not solvable");
  else
    SetIsInjective(hom, true);
  fi;
  if a<>fail then
    hom:=a*hom;
  fi;
  return hom;
end);

#############################################################################
##
#M  FactorCosetAction( <G>, <U> )
##
InstallMethod(FactorCosetAction,"for full fp group on subgroup",
  IsIdenticalObj,[IsSubgroupFpGroup and IsGroupOfFamily,IsSubgroupFpGroup],
  5,# we want this to be better than the method below for the subgroup in
    # quotient rep.
function(G,U)
local t;
  t:=CosetTableInWholeGroup(U);
  t:=List(t{[1,3..Length(t)-1]},PermList);
  return GroupHomomorphismByImagesNC( G, GroupByGenerators( t ),
                                      GeneratorsOfGroup( G ), t );
end);

InstallMethod(FactorCosetAction,"for subgroups of an fp group",
  IsIdenticalObj,[IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(G,U)
  return FactorCosetAction(G,AsSubgroupOfWholeGroupByQuotient(U));
end);

InstallMethod(FactorCosetAction,"subgrp in quotient Rep", IsIdenticalObj,
  [IsSubgroupFpGroup,
   IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep],0,
function(G,U)
local gens,q,h;
  # map the generators of G in the quotient
  gens:=GeneratorsOfGroup(G);
  gens:=List(gens,UnderlyingElement);
  q:=U!.quot;
  gens:=List(gens,i->MappedWord(i,FreeGeneratorsOfWholeGroup(U),
                                GeneratorsOfGroup(q)));
  h:=FactorCosetAction(SubgroupNC(q,gens),U!.sub);
  gens:=List(gens,i->ImagesRepresentative(h,i));
  return GroupHomomorphismByImagesNC( G, Range(h),
                                      GeneratorsOfGroup( G ), gens );
end);


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##     determines subgroup generators from free generators, relators and
##     coset table. It returns elements of the free group!
##
InstallGlobalFunction( SubgroupGeneratorsCosetTable,
    function ( freegens, fprels, table )
    local   gens,               # generators for the subgroup
            rels,               # representatives for the relators
            relsGen,            # relators sorted by start generator
            deductions,         # deduction queue
            ded,                # index of current deduction in above
            nrdeds,             # current number of deductions in above
            nrgens,
            cos,                # loop variable for coset
            i, gen, inv,        # loop variables for generator
            g,                  # loop variable for generator col
            triple,             # loop variable for relators as triples
            app,                # arguments list for 'ApplyRel'
            x, y, c;

    nrgens := 2 * Length( freegens ) + 1;
    gens := [];

    table:=List(table,ShallowCopy);
    # make all entries in the table negative
    for cos  in [ 1 .. IndexCosetTab( table ) ]  do
        for gen  in table  do
            if 0 < gen[cos]  then
                gen[cos] := -gen[cos];
            fi;
        od;
    od;

    # make the rows for the relators and distribute over relsGen
    rels := RelatorRepresentatives( fprels );
    relsGen := RelsSortedByStartGen( freegens, rels, table );

    # make the structure that is passed to 'ApplyRel'
    app := ListWithIdenticalEntries(4,0);

    # run over all the cosets
    cos := 1;
    while cos <= IndexCosetTab( table )  do

        # run through all the rows and look for undefined entries
        for i  in [1..Length(freegens)]  do
            gen := table[2*i-1];

            if gen[cos] < 0  then

                inv := table[2*i];

                # make the Schreier generator for this entry
                x := One(freegens[1]);
                c := cos;
                while c <> 1  do
                    g := nrgens - 1;
                    y := nrgens - 1;
                    while 0 < g  do
                        if AbsInt(table[g][c]) <= AbsInt(table[y][c])  then
                            y := g;
                        fi;
                        g := g - 2;
                    od;
                    x := freegens[ y/2 ] * x;
                    c := AbsInt(table[y][c]);
                od;
                x := x * freegens[ i ];
                c := AbsInt( gen[ cos ] );
                while c <> 1  do
                    g := nrgens - 1;
                    y := nrgens - 1;
                    while 0 < g  do
                        if AbsInt(table[g][c]) <= AbsInt(table[y][c])  then
                            y := g;
                        fi;
                        g := g - 2;
                    od;
                    x := x * freegens[ y/2 ]^-1;
                    c := AbsInt(table[y][c]);
                od;
                if x <> One(x)  then
                    Add( gens, x );
                fi;

                # define a new coset
                gen[cos]   := - gen[cos];
                inv[ gen[cos] ] := cos;

                # set up the deduction queue and run over it until it's empty
                deductions := [ [i,cos] ];
                nrdeds := 1;
                ded := 1;
                while ded <= nrdeds  do

                    # apply all relators that start with this generator
                    for triple in relsGen[deductions[ded][1]] do
                        app[1] := triple[3];
                        app[2] := deductions[ded][2];
                        app[3] := -1;
                        app[4] := app[2];
                        if ApplyRel( app, triple[2] ) then
                            triple[2][app[1]][app[2]] := app[4];
                            triple[2][app[3]][app[4]] := app[2];
                            nrdeds := nrdeds + 1;
                            deductions[nrdeds] := [triple[1][app[1]],app[2]];
                        fi;
                    od;

                    ded := ded + 1;
                od;

            fi;
        od;

        cos := cos + 1;
    od;

    # return the generators
    return gens;
end );

# methods to compute subgroup generators. We have to be careful that
# computed generators and computed augmented coset tables are consistent.


#############################################################################
##
#M  GeneratorsOfGroup
##
InstallMethod(GeneratorsOfGroup,"subgroup fp, via augmented coset table",true,
  [IsSubgroupFpGroup],0,
function(U)
  # Compute the augmented coset table. This will set the generators
  # component
  AugmentedCosetTableInWholeGroup(U);
  return GeneratorsOfGroup(U);
end);


#############################################################################
##
#M  IntermediateSubgroups(<G>,<U>)
##
InstallMethod(IntermediateSubgroups,"fp group via quotient subgroups",
  IsIdenticalObj, [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(G,U)
local A,B,Q,gens,int,i,fam;
  U:=AsSubgroupOfWholeGroupByQuotient(U);
  Q:=U!.quot;
  A:=U!.sub;
  # generators of G in permutation image
  gens:=List(GeneratorsOfGroup(G),elm->
    MappedWord(UnderlyingElement(elm),
      FreeGeneratorsOfWholeGroup(U),GeneratorsOfGroup(Q)));
  B:=Subgroup(Q,gens);
  int:=IntermediateSubgroups(B,A);
  B:=[];
  fam:=FamilyObj(U);
  for i in int.subgroups do
    Add(B,SubgroupOfWholeGroupByQuotientSubgroup(fam,Q,i));
  od;
  return rec(subgroups:=B,inclusions:=int.inclusions);
end);

# test whether abelian invariants can be mapped
InstallGlobalFunction(CanMapFiniteAbelianInvariants,function(from,to)
local pf,pt,fp,tp,p,i,f;
  # first get primes and then run for each prime
  pf:=Union(List(from,Factors));
  pt:=Union(List(to,Factors));
  if not IsSubset(pf,pt) then
    return false;
  fi;
  for p in pf do
    fp:=[];
    for i in from do
      f:=Filtered(Factors(i),x->x=p);
      if Length(f)>0 then
        Add(fp,Product(f));
      fi;
    od;
    tp:=[];
    for i in to do
      f:=Filtered(Factors(i),x->x=p);
      if Length(f)>0 then
        Add(tp,Product(f));
      fi;
    od;
    #Print(fp,tp,"\n");
    if Length(fp)<Length(tp) then return false;fi;
    Sort(fp);Sort(tp);
    fp:=Reversed(fp);
    tp:=Reversed(tp);
    if ForAny([1..Length(tp)],i->fp[i]<tp[i]) then
      return false;
    fi;
  od;
  return true;
end);


#############################################################################
##
#F  GQuotients(<F>,<G>)  . . . . . epimorphisms from F onto G up to conjugacy
##
InstallMethod(GQuotients,"whole fp group to finite group",true,
  [IsSubgroupFpGroup and IsWholeFamily,IsGroup and IsFinite],1,
function (F,G)
local Fgens,    # generators of F
      rels,     # power relations
      cl,       # classes of G
      imgo,imgos,sel,
      e,        # excluded orders (for which the presentation collapses
      u,        # trial generating set's group
      pimgs,    # possible images
      val,      # its value
      i,j,      # loop
      ma,
      dp,emb1,emb2, # direct product
      sameKernel,
      A,bigG,Gmap,opt,
      h;        # epis

  Fgens:=GeneratorsOfGroup(F);

  if Length(Fgens)=0 then
    if Size(G)>1 then
      return [];
    else
      return [GroupHomomorphismByImagesNC(F,G,[],[])];
    fi;
  fi;

  if Size(G)=1 then
    return [GroupHomomorphismByImagesNC(F,G,Fgens,
                          List(Fgens,i->One(G)))];
  elif Length(Fgens)=1 then
    Info(InfoMorph,1,"Cyclic group: only one quotient possible");
    # a cyclic group has at most one quotient

    # force size (in abelian invariants)
    e:=AbelianInvariants(F);

    if not IsCyclic(G) or (IsFinite(F) and not IsInt(Size(F)/Size(G))) then
      return [];
    else
      # get the cyclic gens
      h:=First(AsList(G),i->Order(i)=Size(G));
      # just map them
      return [GroupHomomorphismByImagesNC(F,G,Fgens,[h])];
    fi;
  fi;

  # try abelian part first
  if not IsPerfectGroup(G) then
    ma:=ShallowCopy(AbelianInvariants(F));
    for i in [1..Length(ma)] do
      if ma[i]=0 then ma[i]:=Size(G);fi; # the largest interesting bit
    od;
    if CanMapFiniteAbelianInvariants(ma,AbelianInvariants(G))=false then
      return [];
    fi;
  fi;

  bigG:=G; # generic settings
  Gmap:=fail;

  # try to reduce with automorphisms
  if IsSolvableGroup(G) and Length(Fgens)>2
      and ValueOption("noauto")<>true then
    A:=AutomorphismGroup(G);
    if (IsSolvableGroup(A) or Size(G)<10000) and
        not ForAll(GeneratorsOfGroup(A),IsInnerAutomorphism) then

      # could decide based on HasGeneralizedPcgs...SemidirectProduct(A,G);
      i:=IsomorphismPermGroup(A); # IsomorphismPc might be composition
      bigG:=SemidirectProduct(Image(i),InverseGeneralMapping(i),G);
      Gmap:=Embedding(bigG,2);
      G:=Image(Gmap);
      Gmap:=InverseGeneralMapping(Gmap);
    fi;
  fi;

  cl:=Filtered(ConjugacyClasses(bigG),x->Representative(x) in G);

  # search relators in only one generator
  rels:=ListWithIdenticalEntries(Length(Fgens),false);

  for i in RelatorsOfFpGroup(F) do
    if NrSyllables(i)=1 then
      # found relator in only one generator
      val:=Position(List(FreeGeneratorsOfFpGroup(F),j->GeneratorSyllable(j,1)),
                    GeneratorSyllable(i,1));
      u:=AbsInt(ExponentSyllable(i,1));
      if rels[val]=false then
        rels[val]:=u;
      else
        rels[val]:=Gcd(rels[val],u);
      fi;
    fi;
  od;


  # exclude orders
  e:=Set(cl,i->Order(Representative(i)));
  e:=List(Fgens,i->ShallowCopy(e));
  for i in [1..Length(Fgens)] do
    if rels[i]<>false then
      e[i]:=Filtered(e[i],j->rels[i]<>j and IsInt(rels[i]/j));
    fi;
  od;
  e:=ExcludedOrders(F,e);

  # find potential images
  pimgs:=[];

  for i in [1..Length(Fgens)] do
    if rels[i]<>false then
      Info(InfoMorph,2,"generator order must divide ",rels[i]);
      u:=Filtered(cl,j->IsInt(rels[i]/Order(Representative(j))));
    else
      Info(InfoMorph,2,"no restriction on generator order");
      u:=ShallowCopy(cl);
    fi;
    u:=Filtered(u,j->not Order(Representative(j)) in e[i]);
    Add(pimgs,u);
  od;

  val:=Product(pimgs,i->Sum(i,Size));
  Info(InfoMorph,1,List(pimgs,Length)," possibilities, Value: ",val);

  val:=1;
  opt:=rec(gens:=Fgens,to:=bigG,
        from:=F, free:=FreeGeneratorsOfFpGroup(F),
        rels:=List(RelatorsOfFpGroup(F),i->[i,1]));

  if G=bigG then
    val:=val+4; # surjective
  else
    opt.condition:=hom->Size(Image(hom))=Size(G);
  fi;

  if ValueOption("findall")<>false then
    val:=val+8; # onlyone
  fi;
  h:=MorClassLoop(bigG,pimgs,opt,val);
  if not IsList(h) then h:=[h];fi;

  #if ForAny(h,x->opt.condition(x)=false) then Error("CRAP");fi;

  Info(InfoMorph,1,"Found ",Length(h)," maps, test kernels");

  dp:=DirectProduct(G,G);
  emb1:=Embedding(dp,1);
  emb2:=Embedding(dp,2);
  sameKernel:=function(m1,m2)
  local a;
    m1:=MappingGeneratorsImages(m1)[2];
    m2:=MappingGeneratorsImages(m2)[2];
    a:=List([1..Length(Fgens)],i->
      ImagesRepresentative(emb1,m1[i])*ImagesRepresentative(emb2,m2[i]));
    return Size(SubgroupNC(dp,a))=Size(G);
  end;

  imgos:=[];
  cl:=[];
  u:=[];
  for i in h do
    imgo:=List(Fgens,j->Image(i,j));
    imgo:=Concatenation(imgo,MorFroWords(imgo));
    # fingerprint: Order of fros and commuting indication
    imgo:=Concatenation(List(imgo,Order),
      Concatenation(List([1..Length(imgo)],
        a->Filtered([a+1..Length(imgo)],x->IsOne(Comm(imgo[a],imgo[x]))))));
    sel:=Filtered([1..Length(imgos)],i->imgos[i]=imgo);
    #Info(InfoMorph,3,"|sel|=",Length(sel));
    if Length(sel)=0 then
      Add(imgos,imgo);
      Add(cl,i);
    else
      for j in sel do
        if not IsBound(u[j]) then
          u[j]:=KernelOfMultiplicativeGeneralMapping(cl[j]);
        fi;
      od;

      #e:=KernelOfMultiplicativeGeneralMapping(i);
      if not ForAny(cl{sel},x->sameKernel(x,i)) then
        Add(imgos,imgo);
        Add(cl,i);
        #u[Length(cl)]:=e;
      fi;

    fi;
  od;

  Info(InfoMorph,1,Length(h)," found -> ",Length(cl)," homs");
  if Gmap<>fail then
    cl:=List(cl,x->x*Gmap);
  fi;
  return cl;
end);

InstallMethod(GQuotients,"subgroup of an fp group",true,
  [IsSubgroupFpGroup,IsGroup and IsFinite],1,
function (F,G)
local e,fpi;
  fpi:=IsomorphismFpGroup(F);
  e:=GQuotients(Range(fpi),G);
  return List(e,i->fpi*i);
end);

# new style conversion functions
BindGlobal("GroupwordToMonword",function(id,w)
local m,i;
  m:=[];
  for i in LetterRepAssocWord(w) do
    if i>0 then
      Add(m,2*i-1);
    else
      Add(m,-2*i);
    fi;
  od;
  return AssocWordByLetterRep(FamilyObj(id),m);
end);

BindGlobal("MonwordToGroupword",function(id,w)
local g,i,x;
  g:=[];
  for i in LetterRepAssocWord(w) do
    if IsOddInt(i) then
      x:=(i+1)/2;
    else
      x:=-i/2;
    fi;
    # free cancellation
    if Length(g)>0 and x=-Last(g) then
      Remove(g);
    else
      Add(g,x);
    fi;
  od;
  return AssocWordByLetterRep(FamilyObj(id),g);
end);

################################################
# Gpword2MSword
# Change a word in the free group into a word
# in the free monoid: Generator numbers doubled
# The first <shift> generators in the semigroup are used for identity elements
BindGlobal("Gpword2MSword",function(id, w,shift)
local
    wlist,    # external rep of the word
    i;        # loop variable

  wlist:=LetterRepAssocWord(w);
  if Length(wlist) = 0 then # it is the identity
    return id;
  fi;
  wlist:=ShallowCopy(2*wlist);
  for i in [1..Length(wlist)] do
    if wlist[i]<0 then
      wlist[i]:=-wlist[i]-1;
    fi;
  od;
  return AssocWordByLetterRep(FamilyObj(id),wlist+shift);
end);

################################################
# MSword2gpword
# Change a word in the free monoid into a word
# in the free group monoid: Generator numbers halved
# The first <shift> generators in the semigroup are used for identity elements
BindGlobal("MSword2gpword",function( id, w,shift )
local  wlist, i,l;

  wlist:=LetterRepAssocWord(w);
  if Length(wlist) = 0 then # it is the identity
    return id;
  fi;
  wlist:=ShallowCopy(1/2*(wlist-shift));
  #zero entries correspond to identity elements (in semigroup case)

  for i in [1..Length(wlist)] do
    if not IsInt(wlist[i]) then
      wlist[i]:=-wlist[i]-1/2;
    fi;
  od;

  # free cancellation and removal of identities
  w:=[];
  l:=0;
  i:=1;
  while i<=Length(wlist) do
    if wlist[i]<>0 then
      if l=0 or w[l]<>-wlist[i] then
        l:=l+1;
        w[l]:=wlist[i];
      else
        l:=l-1;
      fi;
    fi;
    i:=i+1;
  od;
  if l<Length(w) then
    w:=w{[1..l]};
  fi;

  return AssocWordByLetterRep(FamilyObj(id),w);
end);

#############################################################################
##
#M  IsomorphismFpSemigroup( <G> )
##
##  for a finitely presented group.
##  Returns an isomorphism to a finitely presented semigroup.
##
InstallMethod(IsomorphismFpSemigroup,"for fp groups",
  true, [IsFpGroup], 0,
function(g)

  local i, rel,       # loop variable
        freegp,       # free group underlying g
        id,           # identity of free group
        gensfreegp,   # semigroup generators of the free group
        freesmg,      # free semigroup on the generators gensfreegp
        gensfreesmg,  # generators of freesmg
        idgen,        # identity generator
        newrels,      # relations
        rels,         # relators of g
        smgrel,       # relators transformed into relation in the semigroup
        semi,         # fp semigroup
        isomfun,      # the isomorphism function
        invfun,       # the inverse isomorphism function
        gpword2semiword,
        smgword2gpword,
        gens,
        hom;

  # first we create the fp semigroup

  # get the free group underlying the fp group given
  freegp := FreeGroupOfFpGroup( g );
  # and get its semigroup generators
  gensfreegp := List(GeneratorsOfSemigroup( freegp ),String);
  freesmg := FreeSemigroup(gensfreegp{[1..Length(gensfreegp)]});

  # now give names to the generators of freesmg
  gensfreesmg := GeneratorsOfSemigroup( freesmg );
  idgen := gensfreesmg[1];

  # now relations that make the free smg into a group
  # first the ones concerning the identity
  newrels := [ [idgen*idgen,idgen] ];
  for i in [ 2 .. Length(gensfreesmg) ] do
    Add(newrels, [idgen*gensfreesmg[i], gensfreesmg[i]]);
    Add(newrels, [gensfreesmg[i]*idgen, gensfreesmg[i]]);
  od;

  # then relations gens * gens^-1 = idgen (and the other way around)
  for i in [2..Length(gensfreesmg)] do
    if IsOddInt( i ) then
      Add( newrels, [gensfreesmg[i]*gensfreesmg[i-1],idgen]);
    else
      Add( newrels, [gensfreesmg[i]*gensfreesmg[i+1],idgen]);
    fi;
  od;

  # now add the relations from the fp group to newrels
  # We have to transform relators into relations in the free semigroup
  # (in particular we have to transform the words in the free
  # group to words in the free semigroup)
  rels := RelatorsOfFpGroup( g );
  for rel in rels do
     smgrel:= [Gpword2MSword(idgen, rel,1), idgen ];
     Add( newrels, smgrel );
  od;

  # finally create the fp semigroup
  semi := FactorFreeSemigroupByRelations( freesmg, newrels);
  gens := GeneratorsOfSemigroup( semi );

  isomfun := x -> ElementOfFpSemigroup( FamilyObj(gens[1] ),
                  Gpword2MSword( idgen, UnderlyingElement(x),1 ));

  # Further addition from Chris Wensley
  id := One( freegp );
  invfun := x->ElementOfFpGroup(FamilyObj(One(g)),
              MSword2gpword( id, UnderlyingElement( x ),1 ) );
  # CW - end

  hom:=MagmaIsomorphismByFunctionsNC(g, semi, isomfun, invfun);
  return hom;
end);

#############################################################################
##
#M  IsomorphismFpMonoid( <G> )
##
##  for a free group or a finitely presented group.
##  Returns an isomorphism to a finitely presented monoid.
##  If the option ``relations'' is given, it must be a list of relations
##  given by words in the free group. The monoid then is created with these
##  relations (plus the ``inverse'' relations).
##

InstallGlobalFunction("IsomorphismFpMonoidGeneratorsFirst",
function(g)
local freegp, gens, mongens, s, t, p, freemon, gensmon, id, newrels,
      rels, w, monrel, mon, monfam, isomfun, idg, invfun, hom, i, j, rel;

  # can we use attribute?
  if HasIsomorphismFpMonoid(g) and IsBound(IsomorphismFpMonoid(g)!.type) and
    # type 0 is inverses first
    IsomorphismFpMonoid(g)!.type=1 then
    return IsomorphismFpMonoid(g);
  fi;

  # first we create the fp mon

  # get the free group underlying the fp group given
  freegp := FreeGroupOfFpGroup( g );
  gens:=GeneratorsOfGroup(g);

  # make monoid generators. Inverses are chosen to be bigger than original
  # elements
  mongens:=[];
  for i in gens do
    s:=String(i);
    Add(mongens,s);
    if ForAll(s,x->x in CHARS_UALPHA or x in CHARS_LALPHA) then
      # inverse: change casification
      t:="";
      for j in [1..Length(s)] do
        p:=Position(CHARS_LALPHA,s[j]);
        if p<>fail then
          Add(t,CHARS_UALPHA[p]);
        else
          p:=Position(CHARS_UALPHA,s[j]);
          Add(t,CHARS_LALPHA[p]);
        fi;
      od;
      s:=t;
    else
      s:=Concatenation(s,"^-1");
    fi;
    Add(mongens,s);
  od;

  freemon:=FreeMonoid(mongens);
  gensmon:=GeneratorsOfMonoid( freemon);
  id:=Identity(freemon);
  newrels:=[];
  # inverse relators
  for i in [1..Length(gens)] do
    Add(newrels,[gensmon[2*i-1]*gensmon[2*i],id]);
    Add(newrels,[gensmon[2*i]*gensmon[2*i-1],id]);
  od;

  rels:=ValueOption("relations");
  if rels=fail then
    # now add the relations from the fp group to newrels
    # We have to transform relators into relations in the free monoid
    # (in particular we have to transform the words in the free
    # group to words in the free monoid)
    rels := RelatorsOfFpGroup( g );
    for rel in rels do
      w:=rel;
      #w:=LetterRepAssocWord(rel);
      #l:=QuoInt(Length(w)+1,2);
      #v:=[];
      #for  i in [Length(w),Length(w)-1..l+1] do
      #  Add(v,-w[i]);
      #od;
      #w:=w{[1..l]};
      w:=GroupwordToMonword(id,w);
      #v:=Gpword2MSword(idmon,AssocWordByLetterRep(FamilyObj(rel),v),0);
      #Info(InfoFpGroup,1,rel," : ",w," -> ",v);
      monrel:= [w,id];
      Add( newrels, monrel );
    od;
  else
    if not ForAll(Flat(rels),x->x in FreeGroupOfFpGroup(g)) then
      Info(InfoFpGroup,1,"Converting relation words into free group");
      rels:=List(rels,i->List(i,UnderlyingElement));
    fi;
    for rel in rels do
      Add(newrels,List(rel,x->GroupwordToMonword(id,x)));
    od;
  fi;

  # finally create the fp monoid
  mon := FactorFreeMonoidByRelations( freemon, newrels);
  gens := GeneratorsOfMonoid( mon);
  monfam := FamilyObj(Representative(mon));

  isomfun := x -> ElementOfFpMonoid( monfam,
                  GroupwordToMonword( id, UnderlyingElement(x) ));

  idg := One( freegp );
  invfun := x -> ElementOfFpGroup( FamilyObj(One(g)),
     MonwordToGroupword( idg, UnderlyingElement( x ) ) );
  hom:=MagmaIsomorphismByFunctionsNC(g, mon, isomfun, invfun);
  # type 0 is inverses first
  hom!.type:=1;
  if not HasIsomorphismFpMonoid(g) then
    SetIsomorphismFpMonoid(g,hom);
  fi;
  return hom;
end);

InstallMethod(IsomorphismFpMonoid,"for an fp group",
  true, [IsFpGroup], 0, IsomorphismFpMonoidGeneratorsFirst);

InstallGlobalFunction("IsomorphismFpMonoidInversesFirst",
function(g)

  local i, rel,       # loop variable
        freegp,       # free group underlying g
        id,           # identity of free group
        gensfreegp,   # semigroup generators of the free group
        freemon,      # free monoid on the generators gensfreegp
        gensfreemon,  # generators of freemon
        idmon,        # identity generator
        newrels,      # relations
        rels,         # relators of g
        monrel,       # relators transformed into relation in the monoid
        mon ,         # fp monoid
        isomfun,      # the isomorphism function
        invfun,       # the inverse isomorphism function
        monfam,       # the family of the monoid's elements
        gens,
        l,v,w,
        hom;

  # can we use attribute?
  if HasIsomorphismFpMonoid(g) and IsBound(IsomorphismFpMonoid(g)!.type) and
    # type 0 is inverses first
    IsomorphismFpMonoid(g)!.type=0 then
    return IsomorphismFpMonoid(g);
  fi;

  # first we create the fp mon

  # get the free group underlying the fp group given
  freegp := FreeGroupOfFpGroup( g );
  # and get its monoid generators
  gensfreegp := List(GeneratorsOfMonoid( freegp ),String);
  freemon := FreeMonoid(gensfreegp);

  # now give names to the generators of freemon
  gensfreemon := GeneratorsOfMonoid( freemon);
  # and to its identity
  idmon := Identity(freemon);

  # now relations that make the free mon into a group
  # ie relations gens * gens^-1 = idmon(and the other way around)
  newrels := [];
  for i in [1..Length(gensfreemon)] do
    if IsOddInt( i ) then
      Add( newrels, [gensfreemon[i]*gensfreemon[i+1],idmon]);
    else
      Add( newrels, [gensfreemon[i]*gensfreemon[i-1],idmon]);
    fi;
  od;

  # now add the relations from the fp group to newrels
  rels:=ValueOption("relations");
  if rels=fail then

    # We have to transform relators into relations in the free monoid
    # (in particular we have to transform the words in the free
    # group to words in the free monoid)
    rels := RelatorsOfFpGroup( g );
    for rel in rels do
      w:=LetterRepAssocWord(rel);
      l:=QuoInt(Length(w)+1,2);
      v:=[];
      for  i in [Length(w),Length(w)-1..l+1] do
        Add(v,-w[i]);
      od;
      w:=w{[1..l]};
      w:=Gpword2MSword(idmon,AssocWordByLetterRep(FamilyObj(rel),w),0);
      v:=Gpword2MSword(idmon,AssocWordByLetterRep(FamilyObj(rel),v),0);
      Info(InfoFpGroup,1,rel," : ",w," -> ",v);
      monrel:= [w,v];
      Add( newrels, monrel );
    od;
  else
    if not ForAll(Flat(rels),x->x in FreeGroupOfFpGroup(g)) then
      Info(InfoFpGroup,1,"Converting relation words into free group");
      rels:=List(rels,i->List(i,UnderlyingElement));
    fi;
    for rel in rels do
      Add(newrels,List(rel,x->Gpword2MSword(idmon,x,0)));
    od;
  fi;

  # finally create the fp monoid
  mon := FactorFreeMonoidByRelations( freemon, newrels);
  gens := GeneratorsOfMonoid( mon);
  monfam := FamilyObj(Representative(mon));

  isomfun := x -> ElementOfFpMonoid( monfam,
                  Gpword2MSword( idmon, UnderlyingElement(x),0 ));

  id := One( freegp );
  invfun := x -> ElementOfFpGroup( FamilyObj(One(g)),
     MSword2gpword( id, UnderlyingElement( x ),0 ) );
  hom:=MagmaIsomorphismByFunctionsNC(g, mon, isomfun, invfun);
  # type 0 is inverses first
  hom!.type:=0;
  if not HasIsomorphismFpMonoid(g) then
    SetIsomorphismFpMonoid(g,hom);
  fi;
  return hom;
end);

InstallGlobalFunction(SetReducedMultiplication,function(o)
local fam;
  fam:=FamilyObj(One(o));
  fam!.reduce:=true; # turn on reduction
  # force determination of the attribute
  FpElementNFFunction(fam);
end);

InstallMethod(FpElementNFFunction,true,[IsElementOfFpGroupFamily],0,
# default reduction --
function(fam)
local iso,k,id,f,ran,g;
  g:=CollectionsFamily(fam)!.wholeGroup;
  if not (HasIsomorphismFpMonoid(g) and
    HasReducedConfluentRewritingSystem(Image(IsomorphismFpMonoid(g)))) then
    # first try whether the group is ``small''
    iso:=FPFaithHom(fam);
    if iso<>fail and Size(Image(iso))<50000 then
      k:=ImagesSource(iso);
      return w->UnderlyingElement(Factorization(k,
        Image(iso,ElementOfFpGroup(fam,w))));
    fi;
  fi;

  iso:=IsomorphismFpMonoidGeneratorsFirst(g);
  ran:=Range(iso);
  f:=FreeMonoidOfFpMonoid(ran);
  if HasReducedConfluentRewritingSystem(ran) then
    k:=ReducedConfluentRewritingSystem(ran);
  else
    k:=ReducedConfluentRewritingSystem(ran,
          BasicWreathProductOrdering(f,GeneratorsOfMonoid(f)));
  fi;
  id:=UnderlyingElement(Image(iso,One(fam)));
  return w->MonwordToGroupword(UnderlyingElement(One(fam)),
               ReducedForm(k,GroupwordToMonword(id,w)));
end);

#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod(ViewObj,"fp group",true,[IsSubgroupFpGroup],
 10,# to override the pure `Size' method
function(G)
  if IsFreeGroup(G) then TryNextMethod();fi;
  if IsGroupOfFamily(G) then
    Print("<fp group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    if Length(GeneratorsOfGroup(G)) > GAPInfo.ViewLength * 10 then
      Print(" with ",Length(GeneratorsOfGroup(G))," generators>");
    else
      Print(" on the generators ",GeneratorsOfGroup(G),">");
    fi;
  else
    Print("Group(");
    if HasGeneratorsOfGroup(G) then
      if not IsBound(G!.gensWordLengthSum) then
        G!.gensWordLengthSum:=Sum(List(GeneratorsOfGroup(G),
                 i->Length(UnderlyingElement(i))));
      fi;
      if G!.gensWordLengthSum <= GAPInfo.ViewLength * 30 then
        Print(GeneratorsOfGroup(G));
      else
        Print("<",Pluralize(Length(GeneratorsOfGroup(G)),"generator"),">");
      fi;
    else
      Print("<fp, no generators known>");
    fi;
    Print(")");
  fi;
end);

#############################################################################
##
#M  ExcludedOrders(<G>)
##
InstallMethod(StoredExcludedOrders,"fp group",true,
  [IsSubgroupFpGroup and
  # for each gen: first entry: excluded orders, second: tested orders
  # (superset)
  IsGroupOfFamily],0,G->List(GeneratorsOfGroup(G),x->[[],[]]));

InstallGlobalFunction(ExcludedOrders,
function(arg)
local f,a,b,i,j,gens,tstord,excl,p,s;
  f:=arg[1];
  s:=StoredExcludedOrders(f);
  gens:=FreeGeneratorsOfFpGroup(f);
  if Length(arg)>1 then
    tstord:=List(arg[2],ShallowCopy);
  else
    tstord:=List(gens,i->[1]);
    for i in RelatorsOfFpGroup(f) do
      for j in [1..NumberSyllables(i)] do
        a:=AbsInt(ExponentSyllable(i,j));
        if a>1 then
          UniteSet(tstord[GeneratorSyllable(i,j)],DivisorsInt(a));
        fi;
      od;
    od;
  fi;

  # take those orders we know already to be true
  excl:=List([1..Length(gens)],i->ShallowCopy(Intersection(tstord[i],s[i][1])));

  for i in [1..Length(tstord)] do
    # remove orders which have been tested once
    tstord[i]:=Difference(tstord[i],s[i][2]);
  od;

  for i in [1..Length(gens)] do
    for j in Reversed(tstord[i]) do
      AddSet(s[i][2],j);
      if ForAny(excl[i],k->IsInt(k/j)) then
        # we know it even with a power => is true
        AddSet(excl[i],j);
        AddSet(s[i][1],j);
      else
        p:=PresentationFpGroup(f,0);
        AddRelator(p,p!.generators[i]^j);
        TzInitGeneratorImages(p);
        TzGoGo(p);
        if Length(p!.generators)=0 then
          AddSet(excl[i],j);
          AddSet(s[i][1],j);
        else
          if i=1 then
            b:=[gens[2]];
          else
            b:=[gens[1]];
          fi;
          a:=CosetTableFromGensAndRels(gens,
               Concatenation(RelatorsOfFpGroup(f),[gens[i]^j]),b:
               max:=15999,silent);
          if IsList(a) and Length(a[1])=1 then
            a:=FpGroupPresentation(p);
            b:=List(b,x->MappedWord(x,FreeGeneratorsOfFpGroup(f),TzImagesOldGens(p)));
            b:=List(b,x->MappedWord(x,p!.generators,GeneratorsOfGroup(a)));
            # now we can try the size. Ensure we use the generator we know
            a:=NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(a),RelatorsOfFpGroup(a),
              List(b,UnderlyingElement), true, false : cyclic := true,
              limit := 50000 );
            if NEWTC_CyclicSubgroupOrder(a)=1 then
              AddSet(excl[i],j);
              AddSet(s[i][1],j);
            fi;
          fi;
        fi;
      fi;
    od;
  od;
  return excl;
end);

# redispatcher -- some group methods require finiteness
RedispatchOnCondition(CompositionSeries,true,[IsFpGroup],[IsFinite],0);

InstallMethod(NormalClosureOp,"whole fp group with normal subgroup",
  IsIdenticalObj,[IsSubgroupFpGroup and IsWholeFamily,IsSubgroupFpGroup],0,
function(G,U)
  return SubgroupOfWholeGroupByCosetTable(FamilyObj(G),
           CosetTableNormalClosureInWholeGroup(U));
end);

InstallMethod(LowerCentralSeriesOfGroup,"fp group",
  true, [IsSubgroupFpGroup],0,
function(G)
local epi,q,lcs;
  epi:=EpimorphismNilpotentQuotient(G);
  q:=Image(epi);
  if ForAny(Collected(Factors(Size(q))),i->i[2]>1000) then
    # As this point is probably never reached, writing extra code for this
    # is not pressing...
    Error("Warning: Class was restricted, this might not be the full quotient");
  fi;
  lcs:=LowerCentralSeriesOfGroup(q);
  return List(lcs,i->PreImage(epi,i));
end);

# this function might not terminate if there is an infinite index.
# for infinite index we'd need a nilpotent quotient
BindGlobal( "CoSuFp", function(G,U)
local f,i,j,rels,H,iso,quo,hom;
  if not IsNormal(G,U) then
    TryNextMethod();
  fi;
  # produce a quotient by forcing that U becomes central. The kernel is the
  # commutator group
  f:=FreeGroupOfFpGroup(G);
  rels:=ShallowCopy(RelatorsOfFpGroup(G));
  for i in GeneratorsOfGroup(U) do
    i:=UnderlyingElement(i);
    for j in GeneratorsOfGroup(f) do
      Add(rels,Comm(j,i));
    od;
  od;
  H:=f/rels;

  # is the quotient already nilpotent? If yes, putting something central
  # below will keep it nilpotent
  quo:=G/U;
  if IsNilpotentGroup(quo) then
    # we run the NQ one class further
    iso:=EpimorphismNilpotentQuotient(H,Length(LowerCentralSeriesOfGroup(quo)));
  else
    # the factor is not nilpotent. So we go via a permutation rep.
    iso:=IsomorphismPermGroup(H);
    Size(H); # in older versions, IsomorphismPermGroup does not set the size.
    if IsSolvableGroup(Image(iso)) then
      iso:=IsomorphismPcGroup(H);
    fi;
  fi;

  hom:=GroupHomomorphismByImagesNC(G,Image(iso),GeneratorsOfGroup(G),
        List(GeneratorsOfGroup(H),i->Image(iso,i)));
  return KernelOfMultiplicativeGeneralMapping(hom);
end );

InstallMethod(CommutatorSubgroup,"whole fp group with normal subgroup",
  IsIdenticalObj,[IsSubgroupFpGroup and IsWholeFamily,IsSubgroupFpGroup],0,
  CoSuFp);

InstallMethod(CommutatorSubgroup,"normal subgroup with whole fp group",
  IsIdenticalObj, [IsSubgroupFpGroup,IsSubgroupFpGroup and IsWholeFamily],0,
function(N,G)
  return CoSuFp(G,N);
end);

# if neither is the full group we'll have to transfer in a new group
InstallMethod(CommutatorSubgroup,"normal subgroup with whole fp group",
  IsIdenticalObj, [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(U,V)
local W,iso;
  if IndexInWholeGroup(U)>IndexInWholeGroup(V) then
    # swap
    W:=U;U:=V;V:=W;
  fi;
  if not IsSubgroup(U,V) or not IsNormal(U,V) then
    TryNextMethod();
  fi;
  if Index(U,V)=1 then
    return DerivedSubgroup(U);
  fi;
  iso:=IsomorphismFpGroup(U);
  W:=CommutatorSubgroup(Image(iso),Image(iso,V));
  return PreImage(iso,W);
end);

#############################################################################
##
#M  RightTransversal   fp group
##
DeclareRepresentation( "IsRightTransversalFpGroupRep",
    IsRightTransversalRep, [ "group", "subgroup", "table", "iso","reps" ] );

InstallMethod(RightTransversalOp, "via coset table",
  IsIdenticalObj,[IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(OG,U)
local G,T,gens,g,reps,ng,index,i,j,ndef,n,iso;
  G:=OG;

  # if G is not the whole group, we need to translate to a new fp group
  if HasIsWholeFamily(G) and IsWholeFamily(G) then
    iso:=IdentityMapping(G);
  else
    iso:=IsomorphismFpGroup(G);
    G:=Range(iso);
  fi;

  # Find short representative words (in the image)
  # this code is thanks to Derek Holt
  T:=CosetTableInWholeGroup(ImagesSet(iso,U));
  gens := [];
  for g in GeneratorsOfGroup(G) do
    Add(gens,g); Add(gens,g^-1);
  od;
  ng := Length(gens);
  index := IndexCosetTab(T);
  reps := [Identity(G)];

  if index=1 then
    # trivial case
    return Objectify( NewType( FamilyObj( OG ),
                      IsRightTransversalFpGroupRep and IsList and
                      IsDuplicateFreeList and IsAttributeStoringRep ),
      rec( group := OG,
        subgroup := U,
        iso:=iso,
        table:=T,
        reps:=List(reps,i->PreImagesRepresentative(iso,i))));
  fi;

  ndef := 1;
  for j in [1..index] do
    for i in [1..ng] do
      n := T[i][j];
      if not IsBound(reps[n]) then
        reps[n] := reps[j]*gens[i];
        #This assumes that reps[j] is already defined - but
        #this is true because T is 'standardized'
        ndef := ndef+1;
        if ndef=index then
          return Objectify( NewType( FamilyObj( OG ),
                            IsRightTransversalFpGroupRep and IsList and
                            IsDuplicateFreeList and IsAttributeStoringRep ),
            rec( group := OG,
              subgroup := U,
              iso:=iso,
              table:=T,
              reps:=List(reps,i->PreImagesRepresentative(iso,i))));
        fi;
      fi;
    od;
  od;
  Error("huh?");
end);

InstallMethod( \[\], "right transversal fp group", true,
    [ IsList and IsRightTransversalFpGroupRep, IsPosInt ], 0,
function( cs, num )
  return cs!.reps[num];
end );

InstallOtherMethod( Position,"right transversal fp gp.",
    [ IsList and IsRightTransversalFpGroupRep,
    IsMultiplicativeElementWithInverse,IsZeroCyc ], 0,
function( cs, elm,zero )
local a;
  a:=TracedCosetFpGroup(cs!.table,
           UnderlyingElement(ImagesRepresentative(cs!.iso,elm)),1);
  if (HasIsTrivial(cs!.subgroup) and IsTrivial(cs!.subgroup))
      or cs!.reps[a]=elm then
    return a;
  else
    return fail;
  fi;
end );

InstallMethod( PositionCanonical,"right transversal fp gp.", IsCollsElms,
    [ IsList and IsRightTransversalFpGroupRep,
    IsMultiplicativeElementWithInverse ], 0,
function( cs, elm )
  return TracedCosetFpGroup(cs!.table,
           UnderlyingElement(ImagesRepresentative(cs!.iso,elm)),1);
end );

InstallMethod( Enumerator,"fp gp.", true,[IsSubgroupFpGroup and IsFinite],0,
  G->RightTransversal(G,TrivialSubgroup(G)));

InstallMethod(Enumerator,
"for a finite subgroup of an f. p. group with known cyclic subgroup",
[IsSubgroupFpGroup and IsFinite and HasCyclicSubgroupFpGroup],
function(G)
  local H, record;

  H := CyclicSubgroupFpGroup(G);
  if Size(H) = 1 then # Checking IsTrivial is slow
    TryNextMethod();
  fi;

  record := rec(G_mod_H := RightTransversal(G, H),
                H_mod_1 := RightTransversal(H, TrivialSubgroup(H)));

  record.Length := enum -> Size(enum!.G_mod_H!.group);

  record.NumberElement := function(enum, elt)
    local n, r, q;
    n := Size(enum!.G_mod_H!.subgroup);
    q := PositionCanonical(enum!.G_mod_H, elt);
    r := PositionCanonical(enum!.H_mod_1, elt * enum!.G_mod_H[q] ^ -1);
    return (q - 1) * n + r;
  end;

  record.ElementNumber := function(enum, pos)
    local n, r, q;
    n := Size(enum!.G_mod_H!.subgroup);
    r := RemInt(pos - 1, n) + 1;
    q := QuoInt(pos - 1, n) + 1;
    return enum!.H_mod_1[r] * enum!.G_mod_H[q];
  end;

  record.Membership := function(elt, enum)
    return ElementsFamily(FamilyObj(enum)) = FamilyObj(elt);
  end;

  return EnumeratorByFunctions(G, record);
end);

InstallGlobalFunction(NewmanInfinityCriterion,function(G,p)
local GO,q,d,e,b,r,val,agemo,ngens;
  if not IsPrimeInt(p) then
    Error("<p> must be a prime");
  fi;
  GO:=G;
  if not (HasIsWholeFamily(G) and IsWholeFamily(G)) then
    G:=Image(IsomorphismFpGroup(G));
  fi;
  b:=Length(GeneratorsOfGroup(G));
  r:=Length(RelatorsOfFpGroup(G));
  val:=fail;
  ngens:=32;
  repeat
    ngens:=ngens*8;
    q:=PQuotient(G,p,2,ngens:noninteractive);
  until q<>fail;
  q:=Image(EpimorphismQuotientSystem(q));
  # factor out G^p
  q:=ShallowCopy(PCentralSeries(q,p));
  if Length(q)=1 then
    Error("Trivial <p> quotient");
  fi;
  if Length(q)=2 then
    Add(q,q[2]); # maximal quotient is abelian, second term is trivial
  fi;

  d:=LogInt(Index(q[1],q[2]),p);

  if p=2 then
    # This case is taken from the book by Johnson, as Newman's paper only
    # treats odd n.
    e:=LogInt(Index(q[2],q[3]),p);
    Info(InfoFpGroup,1,b," generators, ",r," relators, p=",p,", d=",d," e=",e);
    q:=r-b+d;
    if q<d^2/2+d/2-e then
      Info(InfoFpGroup,1,"infinite by criterion 1");
      val:=true;
    else
      Info(InfoFpGroup,2,"r-b=",r-b," d^2/2+d/2-d-e=",d^2/2-d/2-e);
    fi;
    if q<=d^2/2-d/2-e+(e-d/2-d^2/4)*d/2 then
      Info(InfoFpGroup,1,"infinite by criterion 2");
      val:=true;
    else
      Info(InfoFpGroup,2,"r-b=",r-b," d^2/2-d/2-e+(e-d/2-d^2/4)*d/2-d=",
           d^2/2-d/2-e+(e-d/2-d^2/4)*d/2-d);
    fi;
  else
    # can we cut short the agemo calculation?
    if ForAll(GeneratorsOfGroup(q[1]),i->IsOne(i^p)) and
      IsCentral(q[1],q[2]) then
      # all generators have order p. q[2] has exponent p. As q[2] is
      # central, the commutators of generators are central and
      # (ab)^p=a^p*b^p*[a,b]^(p(p-1)/2)=1. So the agemo is trivial.
      agemo:=TrivialSubgroup(q[1]);
    else
      agemo:=Agemo(q[1],p);
    fi;

    q[2]:=ClosureSubgroup(q[2],agemo);
    q[3]:=ClosureSubgroup(q[3],agemo);
    e:=LogInt(Index(q[2],q[3]),p);
    Info(InfoFpGroup,1,b," generators, ",r," relators, p=",p,", d=",d," e=",e);
    q:=r-b+d;
    if q<d^2/2-d/2-e then
      Info(InfoFpGroup,1,"infinite by criterion 1");
      val:=true;
    fi;
    if q<=d^2/2-d/2-e+(e+d/2-d^2/4)*d/2 then
      Info(InfoFpGroup,1,"infinite by criterion 2");
      val:=true;
    fi;
  fi;
  if val=true then
    SetIsFinite(G,false);
    SetSize(G,infinity);
    if not IsIdenticalObj(G,GO) then
      SetIsFinite(GO,false);
      SetSize(GO,infinity);
    fi;
  fi;
  return val;
end);

InstallGlobalFunction(FibonacciGroup,function(arg)
local r,n,f,gens,rels;
  if Length(arg)=1 then
    r:=2;
    n:=arg[1];
  else
    r:=arg[1];
    n:=arg[2];
  fi;
  f:=FreeGroup(n);
  gens:=GeneratorsOfGroup(f);
  rels:=List([1..n],i->Product([0..r-1],j->
       gens[((i+j-1)mod n)+1])/gens[((i+r-1)mod n)+1]);
  return f/rels;
end);

#############################################################################
##  Direct product operation for FpGroups                     Robert F. Morse
##
#M  DirectProductOp( <list>, <G> )
##
InstallMethod( DirectProductOp,
    "for a list of fp groups, and a fp group",
    true,
    [ IsList, IsFpGroup ], 0,
    function( list, fpgp )

    local freeprod,      # Free product of the list of groups given
          freegrp,       # Underlying free group for direct product
          rels,          # relations for direct product
          dirprod,       # Direct product to be returned
          dinfo,         # Direct product info
          geni, genj,    # Generators of the embeddings
          idgens,        # list of identity elements used in for projection
          p1,p2,         # Position indices for embeddings and projections
          i,j,gi,gj;     # index variables


    ## Check the arguments. Each element of the list must be an FpGroup
    ##
    if ForAny( list, G -> not IsFpGroup( G ) ) then
      TryNextMethod();
    fi;

    ## Create the free product of the list of groups
    ##
    freeprod := FreeProductOp(list,fpgp);

    ## Set up the initial generators and relations for the direct
    ## product from free product
    ##
    freegrp  := FreeGroupOfFpGroup(freeprod);
    rels     := ShallowCopy(RelatorsOfFpGroup(freeprod));

    ## Add relations for the direct product
    ##
    for i in [1..Length(list)-1] do
        for j in [i+1..Length(list)] do

            ## Get the corresponding generators of each base
            ## group in the free product via their embeddings and
            ## form the relations for the direct product -- each
            ## generator is each base group commutes with every other
            ## generator in the other base groups.
            ##
            geni := GeneratorsOfGroup(Image(Embedding(freeprod,i)));
            genj := GeneratorsOfGroup(Image(Embedding(freeprod,j)));

            for gi in geni do
                for gj in genj do
                    Add(rels, UnderlyingElement(Comm(gi,gj)));
                od;
            od;
        od;

    od;

    ## Create the direct product as an FpGroup
    ##
    dirprod := freegrp/rels;

    ## Initialize the directproduct info
    ##
    dinfo := rec(groups := list, embeddings := [], projections := []);

    ## Build embeddings and projections for direct product info
    ##
    ## Initialize generator index in free product
    ##
    p1 := 1;

    for i in [1..Length(list)] do

        ## Compute the generator indices to map embedding
        ## into direct product
        ##
        geni := GeneratorsOfGroup(Image(Embedding(freeprod,i)));
        p2 := p1+Length(geni)-1;

        ## Compute a list of generators most of which are the
        ## identity to compute the projection mapping
        ##
        idgens := List([1..Length(GeneratorsOfGroup(dirprod))], g->
                      Identity(list[i]));
        idgens{[p1..p2]} := GeneratorsOfGroup(list[i]);

        ## Build the embedding for group list[i]
        ##
        dinfo.embeddings[i] :=
            GroupHomomorphismByImagesNC(list[i], dirprod,
                GeneratorsOfGroup(list[i]),
                GeneratorsOfGroup(dirprod){[p1..p2]});

        ## Build the projection for group list[i]
        ##
        dinfo.projections[i] :=
            GroupHomomorphismByImagesNC(dirprod,list[i],
                GeneratorsOfGroup(dirprod), idgens);

        ## Set next starting point.
        ##
        p1 := p2+1;
    od;

    ## Set information and return dirprod
    ##
    SetDirectProductInfo( dirprod, dinfo );
    return dirprod;

    end
);

# Textbook application of Smith normal form.
# The function is careful to handle empty matrices and to return
# the generators in the order corresponding to AbelianInvariants.
# If the FpGroup is abelian, then it is suitable as a method for
# IndependentGeneratorsOfAbelianGroup.
BindGlobal( "IndependentGeneratorsOfMaximalAbelianQuotientOfFpGroup", function( G )
  local gens, matrix, snf, base, ord, cti, row, g, o, cf, j, i;

  gens := FreeGeneratorsOfFpGroup( G );
  if Size( gens ) = 0 then return []; fi;
  matrix := List( RelatorsOfFpGroup( G ), rel ->
    List( gens, gen -> ExponentSumWord( rel, gen ) ) );
  if Size( matrix ) = 0 then return gens; fi;
  snf := NormalFormIntMat( matrix, 1+8+16 );

  base := [];
  ord := [];
  cti := snf.coltrans^-1;
  for i in [ 1 .. Length(cti) ] do
    row := cti[i];
    if i <= Length( snf.normal ) then o := snf.normal[i][i]; else o := 0; fi;
    if o <> 1 then
      # get the involved prime factors
      g := LinearCombinationPcgs( gens, row, One(G) );
      cf := Collected( Factors( o ) );
      if Length( cf ) > 1 then
        for j in cf do
          j := j[1] ^ j[2];
          Add( ord, j );
          Add( base, g^(o/j) );
        od;
      else
        Add( base, g );
        Add( ord, o );
      fi;
    fi;
  od;
  SortParallel( ord, base );
  base := List( base, gen -> MappedWord( gen, gens, GeneratorsOfGroup( G ) ) );
  return base;
end );

InstallMethod( IndependentGeneratorsOfAbelianGroup,
  "for abelian fpgroup, use Smith normal form",
  [ IsFpGroup and IsAbelian ],
  IndependentGeneratorsOfMaximalAbelianQuotientOfFpGroup );

BindGlobal( "TRIVIAL_FP_GROUP", FreeGroup(0) / [] );
