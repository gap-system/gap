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

#############################################################################
##
##  methods for homomorphisms that map the standard generators -- no
##  rewriting necessary

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )
##
InstallMethod( ImagesRepresentative,
  "map from fp group or free group, use 'MappedWord'",
  FamSourceEqFamElm, [ IsFromFpGroupStdGensGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  return MappedWord(elm,mapi[1],mapi[2]);
end);


#############################################################################
##
#M  IsSingleValued
##
InstallMethod( IsSingleValued,
  "map from fp group or free group on arbitrary gens: rewrite",
  true,
  [IsFromFpGroupGeneralMappingByImages and HasMappingGeneratorsImages],0,
function(hom)
local m, fp, s, sg, o, gi;
  m:=MappingGeneratorsImages(hom);
  fp:=IsomorphismFpGroupByGenerators(Source(hom),m[1]);
  s:=Image(fp);
  sg:=FreeGeneratorsOfFpGroup(s);
  o:=One(Range(hom));
  gi:=m[2];
  return ForAll(RelatorsOfFpGroup(s),i->MappedWord(i,sg,gi)=o);
end);

InstallMethod( IsSingleValued,
  "map from whole fp group or free group, given on std. gens: test relators",
  true,
  [IsFromFpGroupStdGensGeneralMappingByImages],0,
function(hom)
local s,sg,o,gi;
  s:=Source(hom);
  if not IsWholeFamily(s) then
    TryNextMethod();
  fi;
  if IsFreeGroup(s) then
    return true;
  fi;
  sg:=FreeGeneratorsOfFpGroup(s);
  o:=One(Range(hom));
  # take the images corresponding to the free gens in case of reordering or
  # duplicates
  #gi:=MappingGeneratorsImages(hom)[2]{ListPerm(PermList(hom!.genpositions)^-1,
  #  Length(hom!.genpositions))};
  gi:=[];
  gi{hom!.genpositions}:=MappingGeneratorsImages(hom)[2];

  return ForAll(RelatorsOfFpGroup(s),i->MappedWord(i,sg,gi)=o);
end);

InstallMethod( IsSingleValued,
  "map from whole fp group or free group to perm, std. gens: test relators",
  true,
  [IsFromFpGroupStdGensGeneralMappingByImages and
   IsToPermGroupGeneralMappingByImages],0,
function(hom)
local s, bas, gi, l, p, rel, start, i;
  s:=Source(hom);
  if not IsWholeFamily(s) then
    TryNextMethod();
  fi;
  if IsFreeGroup(s) then
    return true;
  fi;
  bas:=BaseStabChain(StabChainMutable(Range(hom)));
  # take the images corresponding to the free gens in case of reordering or
  # duplicates
  #gi:=MappingGeneratorsImages(hom)[2]{ListPerm(PermList(hom!.genpositions)^-1,
  #  Length(hom!.genpositions))};
  gi:=[];
  gi{hom!.genpositions}:=MappingGeneratorsImages(hom)[2];
  for rel in RelatorsOfFpGroup(s) do
    l:=LetterRepAssocWord(rel);
    for start in bas do
      p:=start;
      for i in l do
        if i>0 then
          p:=p^gi[i];
        else
          p:=p/gi[-i];
        fi;
      od;
      if p<>start then
        return false;
      fi;
    od;
  od;
  return true;
end);


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "from fp/free group, std. gens., to perm group",
  true, [ IsFromFpGroupGeneralMapping
          and IsToPermGroupGeneralMappingByImages ],0,
function(hom)
local f,p,t,orbs,o,cor,u;

  f:=Source(hom);
  if not (HasIsWholeFamily(f) and IsWholeFamily(f)) then
    TryNextMethod();
  fi;
  t:=List(GeneratorsOfGroup(f),i->Image(hom,i));
  p:=SubgroupNC(Range(hom),t);
  Assert(1,GeneratorsOfGroup(p)=t);
  # construct coset table
  t:=[];
  orbs:=OrbitsDomain(p,MovedPoints(p));
  cor:=f;

  for o in orbs do
    u:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(f),
         p,Core(p,Stabilizer(p,o[1])));
    cor:=Intersection(cor,u);
  od;

  if IsIdenticalObj(cor,f) then # in case we get a wrong parent
    SetIsNormalInParent(cor,true);
  fi;
  return cor;
end);


#############################################################################
##
## methods for arbitrary mappings. We must use rewriting.
##

#############################################################################
##
#F  SecondaryImagesAugmentedCosetTable(<aug>,<gens>,<genimages>)
##
InstallGlobalFunction(SecondaryImagesAugmentedCosetTable,function(aug)
local si,sw,i,ug,tt,p;
  if not IsBound(aug.secondaryImages) then
    # set the secondary generators images
    si:=[];
    ug:=List(aug.homgens,UnderlyingElement);
    tt:=GeneratorTranslationAugmentedCosetTable(aug);
    sw:=SecondaryGeneratorWordsAugmentedCosetTable(aug);
    for i in [1..Length(tt)] do
      # get the word representative for the secondary generator
      p:=Position(ug,UnderlyingElement(sw[i]));
      if p<>fail then
        Add(si,aug.homgenims[p]);
      else
        # its not. We must map the image from the primary generators images.
        # For this we use that their images must be given already in `si', as
        # the primary generators come first.
        Add(si,MappedWord(tt[i],aug.primarySubgroupGenerators,
                          si{[1..Length(aug.primarySubgroupGenerators)]}));
      fi;
    od;
    aug.secondaryImages:=si;
  fi;
  return aug.secondaryImages;
end);

# test whether evaluating all the secondary images might be sensible.
InstallGlobalFunction(TrySecondaryImages,function(aug)
local p;
  p:=aug.primaryImages;
  if Length(p)>0 and (
    # would it cost too much storage, to store all secondary generators?
    (IsPerm(p[1]) and ForAll(p,i->LargestMovedPoint(i)<50)) or
    (IsNBitsPcWordRep(p[1])) ) then
    aug.secondaryImages:=ShallowCopy(p);
  fi;
end);

#############################################################################
##
#M  CosetTableFpHom(<hom>)
##
InstallMethod(CosetTableFpHom,"for fp homomorphisms",true,
  [ IsFromFpGroupGeneralMappingByImages and IsGroupGeneralMappingByImages],0,
function(hom)
local aug,hgu,mapi,w;
  # source group with suitable generators
  aug:=false;
  mapi:=MappingGeneratorsImages(hom);
  hgu:=List(mapi[1],UnderlyingElement);

  # construct augmented coset table
  w:=FamilyObj(mapi[1])!.wholeGroup;
  aug:=NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(w),
        RelatorsOfFpGroup(w),
        hgu,
        true);

  aug.homgens:=mapi[1];
  aug.homgenims:=mapi[2];

  # assign the primary generator images
  aug.primaryImages:=List(aug.subgens,
                          i->aug.homgenims[Position(hgu,i)]);

  # TODO: possibly re-use an existing augmented table stored already

  TrySecondaryImages(aug);

  return aug;
end);

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )
##
InstallMethod( ImagesRepresentative, "map from (sub)fp group, rewrite",
  FamSourceEqFamElm,
  [ IsFromFpGroupGeneralMappingByImages and IsGroupGeneralMappingByImages,
    IsMultiplicativeElementWithInverse ], 0,
function( hom, word )
local aug,si,r,i,j,ct,cft,c,f,g,ind,e,eval;
  # catch trivial group
  if HasMappingGeneratorsImages(hom)
    and Length(MappingGeneratorsImages(hom)[1])=0 then
    return One(Range(hom));
  fi;
  # get a coset table
  aug:=CosetTableFpHom(hom);
  r:=One(Range(hom));

  if IsBound(aug.secondaryImages) then
    si:=aug.secondaryImages;
  elif IsBound(aug.primaryImages) then
    si:=aug.primaryImages;
  else
    Error("no decoding possible");
  fi;
  word:=UnderlyingElement(word);

  if IsBound(aug.isNewAugmentedTable) then

    eval:=function(i)
    local w,j;
      w:=One(si[1]);
      if not IsBound(si[i]) then
        for j in aug.secondary[i] do
          if j<0 then
            w:=w/eval(-j);
          else
            w:=w*eval(j);
          fi;
        od;
        si[i]:=w;
      fi;
      return si[i];
    end;

    for i in NEWTC_Rewrite(aug,1,LetterRepAssocWord(word)) do
      if i<0 then r:=r/eval(-i);
      else r:=r*eval(i);
      fi;
    od;
    return r;

  fi;

  # old version

  # instead of calling `RewriteWord', we rewrite locally in the images.
  # this ought to be a bit faster and better on memory.
  ct := aug.cosetTable;
  cft := aug.cosetFactorTable;

  # translation table for group generators to numbers
  if not IsBound(aug.transtab) then
    # should do better, also cope with inverses
    aug.transtab:=List(aug.groupGenerators,i->GeneratorSyllable(i,1));
  fi;

  c:=1; # current coset

  if not IsLetterAssocWordRep(word) then
    # syllable version
    for i in [1..NrSyllables(word)] do
      g:=GeneratorSyllable(word,i);
      e:=ExponentSyllable(word,i);
      if e<0 then
        ind:=2*aug.transtab[g];
        e:=-e;
      else
        ind:=2*aug.transtab[g]-1;
      fi;
      for j in [1..e] do
        # apply the generator, collect cofactor
        f:=cft[ind][c]; # cofactor
        if f>0 then
          r:=r*DecodedTreeEntry(aug.tree,si,f);
        elif f<0 then
          r:=r/DecodedTreeEntry(aug.tree,si,-f);
        fi;
        c:=ct[ind][c]; # new coset number
      od;
    od;

  else
    # letter version
    word:=LetterRepAssocWord(word);
    for i in [1..Length(word)] do
      g:=word[i];
      if g<0 then
        g:=-g;
        ind:=2*aug.transtab[g];
      else
        ind:=2*aug.transtab[g]-1;
      fi;

      # apply the generator, collect cofactor
      f:=cft[ind][c]; # cofactor
      if f>0 then
        r:=r*DecodedTreeEntry(aug.tree,si,f);
      elif f<0 then
        r:=r/DecodedTreeEntry(aug.tree,si,-f);
      fi;
      c:=ct[ind][c]; # new coset number

    od;
  fi;

  # make sure we got back to start
  if c<>1 then
    Error("<elm> is not contained in the source group");
  fi;

  return r;

end);


InstallMethod( ImagesRepresentative,
  "simple tests on equal words to check whether the `generators' are mapped",
  FamSourceEqFamElm,
  [ IsFromFpGroupGeneralMappingByImages and IsGroupGeneralMappingByImages,
    IsMultiplicativeElementWithInverse ],
  # this is a better method than the previous, as it will probably avoid
  # rewriting.
    1,
function( hom, elm )
local ue,p,mapi;
  ue:=UnderlyingElement(elm);
  if IsLetterAssocWordRep(ue) and IsOne(ue) then
    return One(Range(hom));
  fi;
  mapi:=MappingGeneratorsImages(hom);
  p:=PositionProperty(mapi[1],i->IsIdenticalObj(UnderlyingElement(i),ue));
  if p<>fail then
    return mapi[2][p];
  fi;
  ue:=ue^-1;
  p:=PositionProperty(mapi[1],i->IsIdenticalObj(UnderlyingElement(i),ue));
  if p<>fail then
    return mapi[2][p]^-1;
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping, "hom from fp grp", true,
 [ IsFromFpGroupGeneralMapping and IsGroupGeneralMapping], 0,
function(hom)
local k;
  k:=PreImage(hom,TrivialSubgroup(Range(hom)));

  if HasIsSurjective(hom) and IsSurjective( hom ) and
     HasIndexInWholeGroup( Source(hom) )
     and HasRange(hom) # surjective action homomorphisms do not store
                       # the range by default
     and HasSize( Range( hom ) ) then
          SetIndexInWholeGroup( k,
                 IndexInWholeGroup( Source(hom) ) * Size( Range(hom) ));
  fi;
  return k;
end);

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping, "GHBI from fp grp", true,
 [ IsFromFpGroupGeneralMappingByImages
   and IsGroupGeneralMappingByImages ], 0,
function(map)
local so,fp,isofp,rels,mapi;
  # the mapping is on the std. generators. So we just have to evaluate the
  # relators in the generators on the genimages and take the normal closure.
  so:=Source(map);
  mapi:=MappingGeneratorsImages(map);
  if Length(GeneratorsOfGroup(so))=0
    or ForAll(GeneratorsOfGroup(so),x->IsOne(UnderlyingElement(x))) then
    rels:=ShallowCopy(mapi[2]);
  else
    isofp:=IsomorphismFpGroupByGeneratorsNC(so,mapi[1],"F");
    fp:=Range(isofp);
    rels:=RelatorsOfFpGroup(fp);
    rels:=List(rels,i->MappedWord(i,FreeGeneratorsOfFpGroup(fp),mapi[2]));
  fi;
  return NormalClosure(Range(map),SubgroupNC(Range(map),rels));
end);

InstallGlobalFunction(KuKGenerators,
function(G,beta,alpha)
local q,r,tg,dtg,pemb,ugens,g,gi,d,o,gens,genims,i,gr,img,l,mapi;
  q:=Range(beta);
  d:=NrMovedPoints(q);
  # transversal (sorted)

  #better: orbit algo
  #r:=ShallowCopy(RightTransversal(q,qu));
  #Sort(r,function(a,b) return 1^a<1^b;end);
  #r:=List(r,i->PreImagesRepresentative(beta,i));

  # compute transversal with short words from orbit algorithm on points
  o:=[1];
  mapi:=MappingGeneratorsImages(beta);
  gens:=mapi[1];
  genims:=mapi[2];
  gr:=[1..Length(gens)];
  r:=[One(gens[1])];
  i:=1;
  while i<=Length(o) do
    for g in gr do
      img:=o[i]^genims[g];
      if not img in o then
        Add(o,img);
        Add(r,r[i]*gens[g]);
      fi;
    od;
    i:=i+1;
  od;
  SortParallel(o,r); # indices in right position -- this *is* important
        # because we use the index to get the transversal representative!

  tg:=Range(alpha);
  if IsPermGroup(tg) then
    pemb:=IdentityMapping(tg);
    dtg:=LargestMovedPoint(Range(pemb));
  elif Size(tg)<20 then
    pemb:=IsomorphismPermGroup(tg);
    dtg:=LargestMovedPoint(Range(pemb));
  else
    pemb:=IdentityMapping(tg);
    dtg:=-1;
  fi;
  if dtg=0 then
    dtg:=1; # the darn trivial group again.
  fi;

  # images of the generators in the wreath
  ugens:=[];
  for g in GeneratorsOfGroup(G) do
    gi:=ImagesRepresentative(beta,g);
    l:=[];
    for i in [1..d] do
      Info(InfoFpGroup,3,"KuK coset ",i," @",g);
      l[i]:=ImagesRepresentative(pemb,
                       ImagesRepresentative(alpha,r[i]*g/r[i^gi]));
    od;
    Add(ugens,WreathElm(dtg,l,gi) );
  od;
  return ugens;
end);

#############################################################################
##
#M  InducedRepFpGroup(<hom>,<u> )
##
##  induce <hom> def. on <u> up to the full group
InstallGlobalFunction(InducedRepFpGroup,function(thom,s)
local w,c,q,chom,u;
  w:=FamilyObj(s)!.wholeGroup;

  # permutation action on the cosets
  c:=CosetTableInWholeGroup(s);
  c:=List(c{[1,3..Length(c)-1]},PermList);
  q:=Group(c,());  # `c' arose from `PermList'
  chom:=GroupHomomorphismByImagesNC(w,q,GeneratorsOfGroup(w),c);

  if Size(q)=1 then
    # degenerate case
    return thom;
  else
    u:=KuKGenerators(w,chom,thom);
  fi;
  q:=GroupWithGenerators(u,());  # `u' arose from `KuKGenerators'
  return GroupHomomorphismByImagesNC(w,q,GeneratorsOfGroup(w),u);
end);

BindGlobal("IsTransPermStab1",function(G,U)
  return IsPermGroup(G) and IsTransitive(G,MovedPoints(G))
    and (1 in MovedPoints(G)) and Length(Orbit(U,1))=1
    and Size(G)/Size(U)=Length(MovedPoints(G));
end);

#############################################################################
##
#M  PreImagesSet( <hom>, <u> )
##
InstallMethod( PreImagesSet, "map from (sub)group of fp group",
  CollFamRangeEqFamElms,
  [ IsFromFpGroupHomomorphism,IsGroup ],0,
function(hom,u)
local s,t,p,w,c,q,chom,tg,thom,hi,i,lp,max;
  s:=Source(hom);
  if HasIsWholeFamily(s) and IsWholeFamily(s) then
    t:=List(GeneratorsOfGroup(s),i->Image(hom,i));
    if IsPermGroup(Range(hom)) and LargestMovedPoint(t)<>NrMovedPoints(t) then
      c:=MappingPermListList(MovedPoints(t),[1..NrMovedPoints(t)]);
      t:=List(t,i->i^c);
      u:=u^c;
    else
      c:=false;
    fi;
    p:=GroupWithGenerators(t);
    if HasImagesSource(hom) and HasSize(Image(hom)) then
      SetSize(p,Size(Image(hom)));
    fi;
    if c=false then
      SetParent(p,Range(hom));
    fi;
    if HasIsSurjective(hom) and IsSurjective(hom) then
      SetIndexInParent(p,1);
    fi;
    return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(s),p,u);
  fi;

  w:=FamilyObj(s)!.wholeGroup;

  # permutation action on the cosets
  if IsBound(s!.quot) and IsTransPermStab1(s!.quot,s!.sub) then
    q:=s!.quot;
    c:=GeneratorsOfGroup(q);
  else
    c:=CosetTableInWholeGroup(s);
    c:=List(c{[1,3..Length(c)-1]},PermList);
    q:=Group(c,());  # `c' arose from `PermList'
    if IsBound(s!.quot) and HasSize(s!.quot) then
      # transfer size information
      StabChainOp(q,rec(limit:=Size(s!.quot)));
    fi;
  fi;

  chom:=GroupHomomorphismByImagesNC(w,q,GeneratorsOfGroup(w),c);

  # action on cosets of U
  hi:=Image(hom);
  if Index(hi,u)<>infinity then
    t:=CosetTableBySubgroup(hi,u);
    t:=List(t{[1,3..Length(t)-1]},PermList);
    tg:=Group(t,());  # `t' arose from `PermList'
    thom:=hom*GroupHomomorphismByImagesNC(hi,tg,GeneratorsOfGroup(hi),t);

    # don't use size -- could be expensive
    if ForAll(GeneratorsOfGroup(q),IsOne) then
      # degenerate case
      u:=List(GeneratorsOfGroup(w),i->ImageElm(thom,i));
      u:=GroupWithGenerators(u,());
    else
      u:=KuKGenerators(w,chom,thom);
      # could the group be too expensive?
      if (not IsBound(s!.quot)) or
        (IsPermGroup(s!.quot)
          and Size(s!.quot)>10^50 and NrMovedPoints(s!.quot)>10000) then
        t:=[];
        max:=LargestMovedPoint(u);
        for i in u do
          #Add(t,ListPerm(i));
          lp:=ListPerm(i);
          while Length(lp)<max do Add(lp,Length(lp)+1);od;
          Add(t,lp);
          #Add(t,ListPerm(i^-1));
          lp:=ListPerm(i^-1);
          while Length(lp)<max do Add(lp,Length(lp)+1);od;
          Add(t,lp);
        od;
        return SubgroupOfWholeGroupByCosetTable(FamilyObj(s),t);
      fi;
      u:=GroupWithGenerators(u,());  # `u' arose from `KuKGenerators'
      # indicate wreath structure
      StabChainOp(u,rec(limit:=Size(tg)^NrMovedPoints(q)*Size(q)));
    fi;
  else
    #[hi:u] might be infinite
    u:=WreathProduct(hi,q);
    Error("infinite");
  fi;

  return SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(s),u,Stabilizer(u,1));
end);


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallMethod( IsConjugatorIsomorphism,
    "for a f.p. group general mapping",
    true,
    [ IsGroupGeneralMapping ], 1,
    # There is no filter to test whether source and range of a homomorphism
    # are f.p. groups.
    # So we have to test explicitly and make this method
    # higher ranking than the default one in `ghom.gi'.
    function( hom )

    local s, r, G, genss, rep;

    s:= Source( hom );
    if not IsSubgroupFpGroup( s ) then
      TryNextMethod();
    elif not ( IsGroupHomomorphism( hom ) and IsBijective( hom ) ) then
      return false;
    elif IsEndoGeneralMapping( hom ) and IsInnerAutomorphism( hom ) then
      return true;
    fi;
    r:= Range( hom );

    # Check whether source and range are in the same family.
    if FamilyObj( s ) <> FamilyObj( r ) then
      return false;
    fi;

    # Compute a conjugator in the full f.p. group.
    G:= FamilyObj( s )!.wholeGroup;
    genss:= GeneratorsOfGroup( s );
    rep:= RepresentativeAction( G, genss, List( genss,
                    i -> ImagesRepresentative( hom, i ) ), OnTuples );

    # Return the result.
    if rep <> fail then
      Assert( 1, ForAll( genss, i -> Image( hom, i ) = i^rep ) );
      SetConjugatorOfConjugatorIsomorphism( hom, rep );
      return true;
    else
      return false;
    fi;
    end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . . . . .  via images
##
##  we override the method for group homomorphisms, to transfer the coset
##  table information as well.
InstallMethod( CompositionMapping2,
    "for gp. hom. and fp. hom, transferring the coset table",
    FamSource1EqFamRange2,
    [ IsGroupHomomorphism,
      IsGroupHomomorphism and IsFromFpGroupGeneralMappingByImages and
      HasCosetTableFpHom], 0,
function( hom1, hom2 )
local map,tab,tab2,i;
  if IsNiceMonomorphism(hom2) then
    # this is unlikely, but who knows of the things to come...
    TryNextMethod();
  fi;
  if not IsSubset(Source(hom1),ImagesSource(hom2)) then
    TryNextMethod();
  fi;
  map:=MappingGeneratorsImages(hom2);
  map:=GroupGeneralMappingByImagesNC( Source( hom2 ), Range( hom1 ),
         map[1], List( map[2], img ->
            ImagesRepresentative( hom1, img ) ) );
  SetIsMapping(map,true);
  tab:=CosetTableFpHom(hom2);
  tab2:=CopiedAugmentedCosetTable(tab);
  tab2.primaryImages:=[];
  for i in [1..Length(tab.primaryImages)] do
    if IsBound(tab.primaryImages[i]) then
      tab2.primaryImages[i]:=ImagesRepresentative(hom1,tab.primaryImages[i]);
    fi;
  od;
  TrySecondaryImages(tab2);
  SetCosetTableFpHom(map,tab2);
  return map;
end);


#############################################################################
##
##  methods for homomorphisms to fp groups.

#############################################################################
##
#M  PreImagesRepresentative
##
InstallMethod( PreImagesRepresentative,
  "hom. to standard generators of fp group, using 'MappedWord'",
  FamRangeEqFamElm,
  [IsToFpGroupHomomorphismByImages,IsMultiplicativeElementWithInverse],
  # there is no filter indicating the images are standard generators, so we
  # must rank higher than the default.
  1,
function(hom,elm)
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  # check, whether we map to the standard generators
  if not (HasIsWholeFamily(Range(hom)) and IsWholeFamily(Range(hom)) and
          Set(FreeGeneratorsOfFpGroup(Range(hom)))
            =Set(GeneratorsOfGroup(Range(hom)),UnderlyingElement) and
          IsIdenticalObj(mapi[2],GeneratorsOfGroup(Range(hom))) and
          ForAll(List(mapi[2],i->LetterRepAssocWord(UnderlyingElement(i))),
          i->Length(i)=1 and i[1]>0) ) then
    TryNextMethod();
  fi;
  if Length(mapi[2])=0 then
    mapi:=One(Source(hom));
  else
    mapi:=MappedWord(elm,mapi[2],mapi[1]);
  fi;
  return mapi;
end);

#############################################################################
##
##  methods to construct homomorphisms to fp groups
##
InstallOtherMethod(IsomorphismFpGroup,"subgroups of fp group",true,
  [IsSubgroupFpGroup,IsString],0,
function(u,str)
local aug,w,pres,f,fam,opt;
  if HasIsWholeFamily(u) and IsWholeFamily(u) then
    return IdentityMapping(u);
  fi;

  # catch trivial case of rank 0 group
  if Length(GeneratorsOfGroup(FamilyObj(u)!.wholeGroup))=0 then
    return IsomorphismFpGroup(FamilyObj(u)!.wholeGroup,str);
  fi;

  # get an augmented coset table from the group. Since we don't care about
  # any particular generating set, we let the function chose.
  aug:=AugmentedCosetTableInWholeGroup(u);

  Info( InfoFpGroup, 1, "Presentation with ",
    Length(aug.subgroupGenerators), " generators");

  # create a tietze object to reduce the presentation a bit
  if not IsBound(aug.subgroupRelators) then
    aug.subgroupRelators := RewriteSubgroupRelators( aug, aug.groupRelators);
  fi;

  # as the presentation might be rather long, we do not decode all secondary
  # generators and their images, but will do it ``on the fly'' when
  # rewriting.
  aug:=CopiedAugmentedCosetTable(aug);
  pres := PresentationAugmentedCosetTable( aug, "y",0# printlevel
                    ,true) ;# initialize tracking before the `1or2' routine!
  opt:=TzOptions(pres);

  if ValueOption("expandLimit")<>fail then
    opt.expandLimit:=ValueOption("expandLimit");
  else
    opt.expandLimit:=108; # do not grow too much.
  fi;
  if ValueOption("eliminationsLimit")<>fail then
    opt.eliminationsLimit:=ValueOption("eliminationsLimit");
  else
    opt.eliminationsLimit:=20; # do not be too greedy
  fi;
  if ValueOption("lengthLimit")<>fail then
    opt.lengthLimit:=ValueOption("lengthLimit");
  else
    opt.lengthLimit:=Int(3/2*pres!.tietze[TZ_TOTAL]); # not too big.
  fi;
  if ValueOption("generatorsLimit")<>fail then
    opt.generatorsLimit:=ValueOption("generatorsLimit");
  fi;

  TzOptions(pres).printLevel:=InfoLevel(InfoFpGroup);
  if ValueOption("cheap")=true then
    TzGo(pres);
  else
    TzEliminateRareOcurrences(pres,50);
    TzGoGo(pres); # cleanup
  fi;

  # new free group
  f:=FpGroupPresentation(pres,str);

  # images for the old primary generators
  aug.primaryImages:=Immutable(List(
        TzImagesOldGens(pres){[1..Length(aug.primaryGeneratorWords)]},
        i->MappedWord(i,GeneratorsOfPresentation(pres),GeneratorsOfGroup(f))));
  TrySecondaryImages(aug);
  # generator numbers of the new generators
  w:=List(TzPreImagesNewGens(pres),
          i->aug.treeNumbers[Position(OldGeneratorsOfPresentation(pres),i)]);

  # and the corresponding words in the original group
  w:=List(w,i->TreeRepresentedWord(aug.primaryGeneratorWords,aug.tree,i));
  if not IsWord(One(u)) then
    fam:=ElementsFamily(FamilyObj(u));
    w:=List(w,i->ElementOfFpGroup(fam,i));
  fi;

  # write the homomorphism in terms of the image's free generators
  # (so preimages are cheap)
  # this object cannot test whether it is a proper mapping, so skip
  # safety assertions that could be triggered by the construction process
  f:=GroupHomomorphismByImagesNC(u,f,w,GeneratorsOfGroup(f):noassert);
  # but give it `aug' as coset table, so we will use rewriting for images
  SetCosetTableFpHom(f,aug);

  SetIsBijective(f,true);

  return f;
end);

InstallOtherMethod(IsomorphismFpGroupByGeneratorsNC,"subgroups of fp group",
  IsFamFamX,
  [IsSubgroupFpGroup,IsList and IsMultiplicativeElementWithInverseCollection,
   IsObject],0,
function(u,gens,nam)
local aug,w,pres,f,trace;

  trace:=[];

  if HasIsWholeFamily(u) and IsWholeFamily(u) and
    IsIdenticalObj(gens,GeneratorsOfGroup(u)) then
      return IdentityMapping(u);
  fi;
  # get an augmented coset table from the group. It must be compatible with
  # `gens', so we must always use MTC.

  # use new MTC
  w:=FamilyObj(u)!.wholeGroup;
  aug:=NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(w),
        RelatorsOfFpGroup(w),
        List(gens,UnderlyingElement),
        true,trace);

  pres:=NEWTC_PresentationMTC(aug,1,nam);
  if Length(GeneratorsOfPresentation(pres))>Length(gens) then
    aug:=NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(w),
          RelatorsOfFpGroup(w),
          List(gens,UnderlyingElement),
          true,trace);

    pres:=NEWTC_PresentationMTC(aug,0,nam);
  fi;
  # check that we have the exact generators as we want and no rearrangement
  # or so happened.
  Assert(0,Length(GeneratorsOfPresentation(pres))=Length(gens)
    and pres!.primarywords=[1..Length(gens)]);

  # new free group
  f:=FpGroupPresentation(pres);
  aug.homgens:=gens;
  aug.homgenims:=GeneratorsOfGroup(f);
  aug.primaryImages:=GeneratorsOfGroup(f);
  aug.secondaryImages:=ShallowCopy(GeneratorsOfGroup(f));

  f:=GroupHomomorphismByImagesNC(u,f,gens,GeneratorsOfGroup(f):noassert);

  # tell f, that `aug' can be used as its coset table
  SetCosetTableFpHom(f,aug);

  SetIsBijective(f,true);

  return f;
end);

#############################################################################
##
#F  IsomorphismSimplifiedFpGroup(G)
##
##
InstallMethod(IsomorphismSimplifiedFpGroup,"using tietze transformations",
  true,[IsSubgroupFpGroup],0,
function ( G )
local H, pres,map,mapi,opt;

  # check the given argument to be a finitely presented group.
  if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
      Error( "argument must be a finitely presented group" );
  fi;

  # convert the given group presentation to a Tietze presentation.
  pres := PresentationFpGroup( G, 0 );

  # perform Tietze transformations.
  opt:=TzOptions(pres);

  if ValueOption("protected")<>fail then
    opt.protected:=ValueOption("protected");
  fi;

  opt.printLevel:=InfoLevel(InfoFpGroup);
  TzInitGeneratorImages(pres);
  if ValueOption("easy")=true then
    # case of old `SimplifiedFpGroup`, use default strategy parameters
    TzGo( pres );
  else
    # Somewhat tuned strategy parameters
    if ValueOption("expandLimit")<>fail then
      opt.expandLimit:=ValueOption("expandLimit");
    else
      opt.expandLimit:=120; # do not grow too much.
    fi;
    if ValueOption("eliminationsLimit")<>fail then
      opt.eliminationsLimit:=ValueOption("eliminationsLimit");
    else
      opt.eliminationsLimit:=20; # do not be too greedy
    fi;
    if ValueOption("lengthLimit")<>fail then
      opt.lengthLimit:=ValueOption("lengthLimit");
    else
      opt.lengthLimit:=Int(3*pres!.tietze[TZ_TOTAL]); # not too big.
    fi;
    TzGoGo( pres );
  fi;

  # reconvert the Tietze presentation to a group presentation.
  H := FpGroupPresentation( pres );
  UseIsomorphismRelation( G, H );

  if Length(GeneratorsOfGroup(H))>0 then
    map:=List(TzImagesOldGens(pres),
          i->MappedWord(i,GeneratorsOfPresentation(pres),
                          GeneratorsOfGroup(H)));
  else
    map:=List(TzImagesOldGens(pres),y->One(H));
  fi;

  map:=GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),map);

  mapi:=GroupHomomorphismByImagesNC(H,G,GeneratorsOfGroup(H),
         List(TzPreImagesNewGens(pres),
           i->MappedWord(i,OldGeneratorsOfPresentation(pres),
                           GeneratorsOfGroup(G))));
  SetIsBijective(map,true);
  SetInverseGeneralMapping(map,mapi);
  SetInverseGeneralMapping(mapi,map);
  ProcessEpimorphismToNewFpGroup(map);

  return map;
end );

#############################################################################
##
#M  SimplifiedFpGroup( <FpGroup> ) . . . . . . . . .  simplify the FpGroup by
#M                                                     Tietze transformations
##
##  `SimplifiedFpGroup'  returns a group  isomorphic to the given one  with a
##  presentation which has been tried to simplify via Tietze transformations.
##
InstallGlobalFunction( SimplifiedFpGroup, function ( G )
  return Range(IsomorphismSimplifiedFpGroup(G:easy));
end);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup(<G>,<N>)
##
InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "for subgroups of fp groups",IsIdenticalObj,
    [IsSubgroupFpGroup, IsSubgroupFpGroup],0,
function(G,N)
local T,m;

  # try to use rewriting if the index is not too big.
  if IndexInWholeGroup(G)>1 and IndexInWholeGroup(G)<=1000
    and HasGeneratorsOfGroup(N) and not
    HasCosetTableInWholeGroup(N) then
    T:=IsomorphismFpGroup(G);
    return T*NaturalHomomorphismByNormalSubgroup(Image(T,G),Image(T,N));
  fi;

  if not HasCosetTableInWholeGroup(N) and not
    IsSubgroupOfWholeGroupByQuotientRep(N) then

    # try to compute a coset table
    T:=TryCosetTableInWholeGroup(N:silent:=true);
    if T=fail then
      if not (HasIsWholeFamily(G) and IsWholeFamily(G)) then
        TryNextMethod(); # can't do
      fi;
      # did not succeed - do the stupid thing
      m:=CosetTableDefaultMaxLimit;
      repeat
        m:=m*1000;
        T:=TryCosetTableInWholeGroup(N:silent:=true,max:=m);
      until T<>fail;
    fi;

  fi;
  return NaturalHomomorphismByNormalSubgroupNC(G,
           AsSubgroupOfWholeGroupByQuotient(N));
end);

InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "for subgroups of fp groups by quotient rep.",IsIdenticalObj,
    [IsSubgroupFpGroup,
     IsSubgroupFpGroup and IsSubgroupOfWholeGroupByQuotientRep ],0,
function(G,N)
local Q,B,Ggens,gens,hom;
  Q:=N!.quot;
  Ggens:=GeneratorsOfGroup(G);
  # generators of G in image
  gens:=List(Ggens,elm->
    MappedWord(UnderlyingElement(elm),
               FreeGeneratorsOfWholeGroup(N),GeneratorsOfGroup(Q)));
  B:=SubgroupNC(Q,gens);
  hom:=NaturalHomomorphismByNormalSubgroupNC(B,N!.sub);
  gens:=List(gens,i->ImageElm(hom,i));
  hom:=GroupHomomorphismByImagesNC(G,Range(hom),Ggens,gens);
  SetKernelOfMultiplicativeGeneralMapping(hom,N);
  return hom;
end);

InstallMethod(NaturalHomomorphismByNormalSubgroupOp,
  "trivial image fp case",IsIdenticalObj,
    [IsSubgroupFpGroup,
     IsSubgroupFpGroup and IsWholeFamily ],0,
function(G,N)
local Q,Ggens,gens,hom;

  Ggens:=GeneratorsOfGroup(G);
  # generators of G in image
  gens:=List(Ggens,elm->());  # a new group is created
  Q:=GroupWithGenerators(gens);
  hom:=GroupHomomorphismByImagesNC(G,Q,Ggens,gens);
  SetKernelOfMultiplicativeGeneralMapping(hom,N);
  return hom;
end);

#########################################################
##
#M MaximalAbelianQuotient(<fp group>)
##
##
InstallMethod(MaximalAbelianQuotient,"whole fp group",
        true, [IsSubgroupFpGroup and IsWholeFamily], 0,
function(f)
local m,s,g,i,j,gen,img,hom,d,pos;

  # since f is the full group, exponent sums are with respect to its
  # generators.
  m:=List(RelatorsOfFpGroup(f),ExponentSums);

  if Length(m)>0 then
    m:=ReducedRelationMat(m);
    s:=NormalFormIntMat(m,25); # 9+16: SNF with transforms, destructive
    d:=DiagonalOfMat(s.normal);
    pos:=Filtered([1..Length(d)],x->d[x]<>1);
    d:=d{pos};
    SetAbelianInvariants(f,d);

    # Make abelian group
    g:=AbelianGroup(d);
    SetAbelianInvariants(g,d);
    if not IsFinite(g) then SetReducedMultiplication(g);fi;

    gen:=ListWithIdenticalEntries(Length(m[1]),One(g));
    gen{pos}:=GeneratorsOfGroup(g);

    s:=s.coltrans;
    img:=[];
    for i in [1..Length(s)] do
      m:=Identity(g);
      for j in [1..Length(gen)] do
        m:=m*gen[j]^s[i][j];
      od;
      Add(img,m);
    od;
  else

    g:=AbelianGroup(ListWithIdenticalEntries(Length(GeneratorsOfGroup(f)),0));
    SetIsFinite(g,Length(GeneratorsOfGroup(f))=0);
    img:=GeneratorsOfGroup(g);
    SetAbelianInvariants(f,ListWithIdenticalEntries(Length(GeneratorsOfGroup(f)),0));
    SetIsAbelian(g,true);
  fi;

  hom:=GroupHomomorphismByImagesNC(f,g,GeneratorsOfGroup(f),img);
  SetIsSurjective(hom,true);
  return hom;
end);

InstallMethod(MaximalAbelianQuotient,
        "for subgroups of finitely presented groups, fallback",
        true, [IsSubgroupFpGroup], -1,
function(U)
local phi, m;
  # do cheaper Tietze (and thus do not store)
  phi:=AttributeValueNotSet(IsomorphismFpGroup,U:
    eliminationsLimit:=50,
    generatorsLimit:=Length(GeneratorsOfGroup(Parent(U)))*LogInt(IndexInWholeGroup(U),2),
    cheap);
  m:=MaximalAbelianQuotient(Image(phi));
  SetAbelianInvariants(U,AbelianInvariants(Image(phi)));
  return phi*m;
end);

InstallMethod(MaximalAbelianQuotient,
        "subgroups of fp., rewrite", true, [IsSubgroupFpGroup], 0,
function(u)
local iso;
  if (HasIsWholeFamily(u) and IsWholeFamily(u))
  # catch trivial case of rank 0 group
   or Length(GeneratorsOfGroup(FamilyObj(u)!.wholeGroup))=0 then
    TryNextMethod();
  fi;

  iso:=IsomorphismFpGroup(u);
  return iso*MaximalAbelianQuotient(Range(iso));
end);


#InstallMethod(MaximalAbelianQuotient,
#        "subgroups of fp. abelian rewriting", true, [IsSubgroupFpGroup], 0,
#function(u)
#local aug,r,sec,expwrd,rels,ab,s,m,img,gen,i,j,t1,t2,tn,d,pos;
#  if (HasIsWholeFamily(u) and IsWholeFamily(u))
#  # catch trivial case of rank 0 group
#   or Length(GeneratorsOfGroup(FamilyObj(u)!.wholeGroup))=0 then
#    TryNextMethod();
#  fi;
#
#  # get an augmented coset table from the group. Since we don't care about
#  # any particular generating set, we let the function chose.
#  aug:=AugmentedCosetTableInWholeGroup(u);
#
#  aug:=CopiedAugmentedCosetTable(aug);
#
#  r:=Length(aug.primaryGeneratorWords);
#  Info( InfoFpGroup, 1, "Abelian presentation with ",
#    Length(aug.subgroupGenerators), " generators");
#
#  # make vectors
#  expwrd:=function(l)
#  local v,i;
#    v:=ListWithIdenticalEntries(r,0);
#    for i in l do
#      if i>0 then v:=v+sec[i];
#      else v:=v-sec[-i];fi;
#    od;
#    return v;
#  end;
#
#  # do GeneratorTranslation abelianized
#  sec:=ShallowCopy(IdentityMat(r,1)); # initialize so next command works
#
#  t1:=aug.tree[1];
#  t2:=aug.tree[2];
#  tn:=aug.treeNumbers;
#  if Length(tn)>0 then
#    for i in [Length(sec)+1..Maximum(tn)] do
#      sec[i]:=sec[AbsInt(t1[i])]*SignInt(t1[i])
#            +sec[AbsInt(t2[i])]*SignInt(t2[i]);
#    od;
#  fi;
#
#  sec:=sec{aug.treeNumbers};
#
#  # now make relators abelian
#  rels:=[];
#  rels:=RewriteSubgroupRelators( aug, aug.groupRelators);
#  rels:=List(rels,expwrd);
#
#  rels:=ReducedRelationMat(rels);
#  if Length(rels)=0 then
#    Add(rels,ListWithIdenticalEntries(r,0));
#  fi;
#  s:=NormalFormIntMat(rels,25); # 9+16: SNF with transforms, destructive
#  d:=DiagonalOfMat(s.normal);
#  pos:=Filtered([1..Length(d)],x->d[x]<>1);
#  d:=d{pos};
#  ab:=AbelianGroup(d);
#  SetAbelianInvariants(u,d);
#  SetAbelianInvariants(ab,d);
#  if not IsFinite(ab) then SetReducedMultiplication(ab);fi;
#
#  gen:=ListWithIdenticalEntries(Length(rels[1]),One(ab));
#  gen{pos}:=GeneratorsOfGroup(ab);
#
#  s:=s.coltrans;
#  img:=[];
#  for i in [1..Length(s)] do
#    m:=One(ab);
#    for j in [1..Length(gen)] do
#      m:=m*gen[j]^s[i][j];
#    od;
#    Add(img,m);
#  od;
#  aug.primaryImages:=img;
#  if ForAll(img,IsOne) then
#    sec:=List(sec,x->img[1]);
#  else
#    sec:=List(sec,x->LinearCombinationPcgs(img,x));
#  fi;
#  aug.secondaryImages:=sec;
#
#  m:=List(aug.primaryGeneratorWords,x->ElementOfFpGroup(FamilyObj(One(u)),x));
#  m:=GroupHomomorphismByImagesNC(u,ab,m,img:noassert);
#
#  # but give it `aug' as coset table, so we will use rewriting for images
#  SetCosetTableFpHom(m,aug);
#
#  SetIsSurjective(m,true);
#
#  return m;
#end);

# u must be a subgroup of the image of home
InstallGlobalFunction(
LargerQuotientBySubgroupAbelianization,function(hom,u)
local v,aiu,aiv,G,primes,irrel,ma,mau,a,k,gens,imgs,q,dec,deco,piv,co;
  v:=PreImage(hom,u);
  aiu:=AbelianInvariants(u);

  G:= FamilyObj(v)!.wholeGroup;
  aiv:=AbelianInvariantsSubgroupFpGroup( G, v:cheap:=false );
  if aiv=fail then
    ma:=MaximalAbelianQuotient(v);
    aiv:=AbelianInvariants(Image(ma,v));
  fi;
  if aiu=aiv then
    return fail;
  fi;
  # are there irrelevant primes?
  primes:=Union(List(Union(aiu, aiv), PrimeDivisors));
  irrel:=Filtered(primes,x->Filtered(aiv,z->IsInt(z/x))=
                            Filtered(aiu,z->IsInt(z/x)));

  Info(InfoFpGroup,1,"Larger by factor ",Product(aiv)/Product(aiu));
  ma:=MaximalAbelianQuotient(v);
  mau:=MaximalAbelianQuotient(u);
  a:=Image(ma);
  k:=TrivialSubgroup(a);
  for primes in irrel do
    k:=ClosureGroup(k,GeneratorsOfGroup(SylowSubgroup(a,primes)));
  od;
  if Size(k)>1 then
    ma:=ma*NaturalHomomorphismByNormalSubgroup(a,k);
    a:=Image(ma);
    k:=TrivialSubgroup(Image(mau));
    for primes in irrel do
      k:=ClosureGroup(k,GeneratorsOfGroup(SylowSubgroup(Image(mau),primes)));
    od;
    mau:=mau*NaturalHomomorphismByNormalSubgroup(Image(mau),k);
  fi;

  gens:=SmallGeneratingSet(a);
  imgs:=List(gens,x->Image(mau,Image(hom,PreImagesRepresentative(ma,x))));
  q:=GroupHomomorphismByImages(a,Image(mau),gens,imgs);
  k:=KernelOfMultiplicativeGeneralMapping(q);

  # generators of prime power orders but larger powers first (to have pivots
  # on larger order elements)
  gens:=Reversed(IndependentGeneratorsOfAbelianGroup(a));
  aiv:=List(gens,Order);
  dec:=EpimorphismFromFreeGroup(Group(gens));
  deco:=function(x)
    local i;
    x:=ExponentSums(PreImagesRepresentative(dec,x));
    for i in [1..Length(aiv)] do
      x[i]:=x[i] mod aiv[i];
    od;
    return x;
  end;

  k:=Filtered(HermiteNormalFormIntegerMat(List(GeneratorsOfGroup(k),deco)),
    x->not IsZero(x));

  piv:=List(k,PositionNonZero);

  # k is the kernel we have. We want to find a subgroup intersecting
  # trivially with k. This is given by the non-pivot positions (and we
  # cannot do better).
  co:=SubgroupNC(a,gens{Difference([1..Length(gens)],piv)});
  if ValueOption("cheap")=true then
    # take also all pivots but last (larger order ones)
    co:=ClosureSubgroup(co,gens{piv{[1..Length(piv)-1]}});
  fi;
  Info(InfoFpGroup,2,"Degree larger ",Index(a,co));
  return PreImage(ma,co);
end);

DeclareRepresentation("IsModuloPcgsFpGroupRep",
  IsModuloPcgs and IsPcgsDefaultRep, [ "hom", "impcgs", "groups" ] );


InstallMethod(ModuloPcgs,"subgroups fp",true,
  [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(M,N)
local hom,pcgs,impcgs;
  hom:=NaturalHomomorphismByNormalSubgroupNC(M,N);
  hom:=hom*IsomorphismSpecialPcGroup(Image(hom,M));
  impcgs:=FamilyPcgs(Image(hom,M));
  pcgs:=PcgsByPcSequenceCons(IsPcgsDefaultRep,IsModuloPcgsFpGroupRep,
          ElementsFamily(FamilyObj(M)),
          List(impcgs,i->PreImagesRepresentative(hom,i)),
          []
          );
  pcgs!.hom:=hom;
  pcgs!.impcgs:=impcgs;
  pcgs!.groups:=[M,N];
  if IsFiniteOrdersPcgs(impcgs) then
    SetIsFiniteOrdersPcgs(pcgs,true);
  fi;
  if IsPrimeOrdersPcgs(impcgs) then
    SetIsPrimeOrdersPcgs(pcgs,true);
  fi;
  return pcgs;
end);

InstallMethod(NumeratorOfModuloPcgs,"fp",true,[IsModuloPcgsFpGroupRep],0,
  p->GeneratorsOfGroup(p!.groups[1]));

InstallMethod(DenominatorOfModuloPcgs,"fp",true,[IsModuloPcgsFpGroupRep],0,
  p->GeneratorsOfGroup(p!.groups[2]));

InstallMethod(RelativeOrders,"fp",true,[IsModuloPcgsFpGroupRep],0,
  p->RelativeOrders(p!.impcgs));

InstallMethod(RelativeOrderOfPcElement,"fp",IsCollsElms,
  [IsModuloPcgsFpGroupRep,IsMultiplicativeElementWithInverse],0,
function(p,e)
  return RelativeOrderOfPcElement(p!.impcgs,ImagesRepresentative(p!.hom,e));
end);

InstallMethod(ExponentsOfPcElement,"fp",IsCollsElms,
  [IsModuloPcgsFpGroupRep,IsMultiplicativeElementWithInverse],0,
function(p,e)
  return ExponentsOfPcElement(p!.impcgs,ImagesRepresentative(p!.hom,e));
end);

InstallMethod(EpimorphismFromFreeGroup,"general",true,
  [IsGroup and HasGeneratorsOfGroup],0,
function(G)
local F,str;
  str:=ValueOption("names");
  if IsList(str) and ForAll(str,IsString) and
    Length(str)=Length(GeneratorsOfGroup(G)) then
    F:=FreeGroup(str);
  else
    if not IsString(str) then
      str:="x";
    fi;
    F:=FreeGroup(Length(GeneratorsOfGroup(G)),str);
  fi;
  return
    GroupHomomorphismByImagesNC(F,G,GeneratorsOfGroup(F),GeneratorsOfGroup(G));
end);

InstallGlobalFunction(ProcessEpimorphismToNewFpGroup,
function(hom)
local s,r,fam,fas,fpf,mapi;
  if not (HasIsSurjective(hom) and IsSurjective(hom)) then
    Info(InfoWarning,1,"fp eipimorphism is created in strange way, bail out");
    return; # hom might be ill defined.
  fi;
  s:=Source(hom);
  r:=Range(hom);
  mapi:=MappingGeneratorsImages(hom);
  if mapi[2]<>GeneratorsOfGroup(r) then
    return; # the method does not apply here. One could try to deal with the
    #extra generators separately, but that is too much work for what is
    #intended as a minor hint.
  fi;

  # Transfer some knowledge about the source group to its image.
  if HasIsMapping(hom) and IsMapping(hom) then
    if HasIsInjective(hom) and IsInjective(hom) then
      UseIsomorphismRelation(s, r);
    elif HasKernelOfMultiplicativeGeneralMapping(hom) then
      UseFactorRelation(s, KernelOfMultiplicativeGeneralMapping(hom), r);
    else
      UseFactorRelation(s, fail, r);
    fi;
  fi;

  s:=SubgroupNC(s,mapi[1]);

  fam:=FamilyObj(One(r));
  fas:=FamilyObj(One(s));
  if IsPermCollection(s) or IsMatrixCollection(s)
     or IsPcGroup(s) or CanEasilyCompareElements(s) then
    # in the long run this should be the inverse of the source restricted
    # mapping (or the corestricted inverse) but that does not work well with
    # current homomorphism code, thus build new map.
    #fpf:=InverseGeneralMapping(hom);
    fpf:=GroupHomomorphismByImagesNC(r,s,mapi[2],mapi[1]);
  elif IsFpGroup(s) and HasFPFaithHom(fas) then
    #fpf:=InverseGeneralMapping(hom)*FPFaithHom(fas);
    fpf:=GroupHomomorphismByImagesNC(r,s,mapi[2],List(mapi[1],x->Image(FPFaithHom(fas),x)));
  else
    fpf:=fail;
  fi;
  if fpf<>fail then
    SetEpimorphismFromFreeGroup(ImagesSource(fpf),fpf);
    SetFPFaithHom(fam,fpf);
    SetFPFaithHom(r,fpf);
    if IsPermGroup(s) then SetIsomorphismPermGroup(r,fpf);fi;
    if IsPcGroup(s) then SetIsomorphismPcGroup(r,fpf);fi;
  fi;
end);
