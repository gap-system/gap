#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains functions using the trivial-fitting paradigm for
##  determining maximal subgroups.
##


##
## methods for soluble normal subgroups
##
#############################################################################
##
#F MaxSubmodsByPcgs( G, pcgs, field )
##
BindGlobal("MaxSubmodsByPcgs",function( G, pcgs, field )
    local mats, modu, max, pcgD, pcgN, i, base, sub;
    mats := LinearOperationLayer( G, pcgs );
    modu := GModuleByMats( mats, Length(pcgs), field );
    if modu.dimension=1 then
      max:=[[]];
    else
      max  := MTX.BasesMaximalSubmodules( modu );
    fi;
    pcgD := DenominatorOfModuloPcgs( pcgs );
    pcgN := NumeratorOfModuloPcgs( pcgs );
    for i in [1..Length( max )] do
        base := List( max[i], x -> PcElementByExponents( pcgs, x ) );
        Append( base, pcgD );
        sub := InducedPcgsByPcSequenceNC( pcgN, base );
        if Length(pcgD)=0 then
          max[i]:=sub;
        else
          max[i] := sub mod pcgD;
        fi;
    od;
    return max;
end);

#############################################################################
##
#F IsCentralModule( G, modu )
##
BindGlobal("IsCentralModule",function( G, modu )
    local mats;
    if Length( modu ) > 1 then return false; fi;
    mats := LinearOperationLayer( G, modu );
    return ForAll( mats, x -> x = x^0 );
end);

#############################################################################
##
#F ComplementClassesByPcgsModulo( G, pcgs, fphom,words,wordgens,wordimgs )
##
BindGlobal("ComplementClassesByPcgsModulo",
function( G, fampcgs,pcgs,fphom,words,wordgens,wordimgs)
    local ocr, cc, cb, co, field, z, V, reps, cls, r, den,ggens;

    den:=DenominatorOfModuloPcgs(pcgs);
    # the mysterious one-cocycle record
    ocr := rec( modulePcgs := pcgs,
                group := G,
                factorfphom:=fphom
                         );

    OCOneCocycles( ocr, false );
    if not IsBound( ocr.complement ) then return []; fi;

    # derive complementreps
    cc := Basis( ocr.oneCocycles );
    cb := Basis( ocr.oneCoboundaries );
    co := BaseSteinitzVectors( BasisVectors( cc ), BasisVectors( cb ) );
    field := LeftActingDomain( ocr.oneCocycles );
    z := Zero( ocr.oneCocycles );
    V := VectorSpace( field, co.factorspace, z );

    cls:=[];
    for r in V do
      # complement generators (as per presentation)
      reps:=ocr.cocycleToList(r);
      reps:=List([1..Length(reps)],x->ocr.complementGens[x]*reps[x]);
      # translate factor gens to original generators
      ggens:=List(words,
              x->MappedWord(x,FreeGeneratorsOfFpGroup(Range(fphom)),reps));
      # and keep the extra pc generators
      reps:=reps{[Length(wordgens)+1..Length(reps)]};
      reps:=Concatenation(reps,den);
      reps:=InducedPcgsByGenerators(fampcgs,reps);
      SetOneOfPcgs(reps,OneOfPcgs(fampcgs));
      #z:=Size(Group(wordimgs,()))*Product(RelativeOrders(reps));
      reps:=SubgroupByFittingFreeData( G, ggens, wordimgs,reps);
      #SetSize(reps,z);
#if IsSubset(reps,SolvableRadical(G)) then Error("radicalA");fi;
      reps!.classsize:=Size(ocr.oneCoboundaries);
      Add(cls,reps);
    od;

    return cls;
end);

#############################################################################
##
#F MaxsubSifted( pcgs, elm ) . . . sift elm through modulo pcgs
##
BindGlobal("MaxsubSifted",function( pcgs, elm )
    local exp, new;
    exp := ExponentsOfPcElement( pcgs, elm );
    new := PcElementByExponents( pcgs, exp );
    return new^-1 * elm;
end);

#############################################################################
##
#F HeadComplementGens( gensG, pcgsT, pcgsA, field )
##
BindGlobal("HeadComplementGens",function( gensG, pcgsT, pcgsA, field )
    local gensK, g, V, M, t, h, b, v, A, B, l, s, a;

    # lift gensG to generators of the complement
    gensK := [];

    # loop over gensG
    for g in gensG do

        # set up system of linear equations
        V := [];
        M := List( [1..Length(pcgsA)], x -> [] );

        for t in pcgsT do
            h := Comm( t, g );
            b := MaxsubSifted( pcgsT, h );
            v := ExponentsOfPcElement( pcgsA, b ) * One( field );
            Append( V, v );

            A := List( pcgsA, x -> ExponentsOfPcElement( pcgsA, x ^ (t^g) ));
            A := A * One( field );
            B := A - A^0;
            for l in [1..Length(pcgsA)] do
                Append( M[l], B[l] );
            od;
        od;

        # solve system
        s := SolutionMat( M, V );
        a := PcElementByExponents( pcgsA, s );
        Add( gensK, g*a );
    od;
    return gensK;
end);

#############################################################################
##
#F MaximalSubgroupClassesSol( G )
##
BindGlobal("MaximalSubgroupClassesSol",function(G)
    local pcgs, spec, first, weights, m, max, i, gensG, f, n, p, w, field,
          pcgsN, pcgsM, pcgsF, modus, modu, oper, L, cl, K, R, I, hom,
          V, W, index, pcgsT, gensK, pcgsL, pcgsML, M, H,ff,S,
          fphom,mgi,sel,words,wordgens,homliftlevel,
          fam,wordfpgens,wordpre;

    # set up
    ff:=FittingFreeLiftSetup(G);
    S:=ff.radical;
    pcgs := ff.pcgs;

    spec:=SpecialPcgs(S);
    first := LGFirst( spec );
    weights := LGWeights( spec );
    m := Length( spec );

    max := [];
    f:=ff.factorhom;
    mgi:=MappingGeneratorsImages(ff.factorhom);
    sel:=Filtered([1..Length(mgi[2])],x->not IsOne(mgi[2][x]));
    if 4^Length(sel)>Size(Range(ff.factorhom)) then
      f:=SmallGeneratingSet(Image(ff.factorhom));
      mgi:=[List(f,x->PreImagesRepresentative(ff.factorhom,x)),f];
      sel:=[1..Length(mgi[1])];
    fi;
    gensG:=mgi[1]{sel};

    # fp group and word representation for gensG
    fphom:=IsomorphismFpGroup(Image(ff.factorhom));
    words:=List(mgi[2]{sel},
      x->UnderlyingElement(ImagesRepresentative(fphom,x)));
    wordgens:=FreeGeneratorsOfFpGroup(Range(fphom));
    fam:=FamilyObj(One(Range(fphom)));
    # just in case the stored group generators differ...
    wordfpgens:=List(wordgens,x->ElementOfFpGroup(fam,x));
    wordpre:=List(wordfpgens,x->PreImagesRepresentative(ff.factorhom,
              PreImagesRepresentative(fphom,x)));
    fphom:=ff.factorhom*fphom;
    # no assertion as this is not a proper homomorphism, but an inverse
    # multiplicative map
    f:=GroupGeneralMappingByImagesNC(Range(fphom),Source(fphom),
        wordfpgens,wordpre:noassert);
    SetInverseGeneralMapping(fphom,f);

    homliftlevel:=0;

    # loop down LG series
    for i in [1..Length( first )-1] do
        f := first[i];
        n := first[i+1];
        w := weights[f];
        p := w[3];
        field := GF(p);
        if w[2] = 1 then
          Info(InfoLattice,2,"start layer with weight ", w," ^ ",n-f);

          # if necessary extent the fphom
          if homliftlevel+1<f then
            pcgsM := InducedPcgsByPcSequenceNC( spec, spec{[homliftlevel+1..f-1]} );
            RUN_IN_GGMBI:=true;
            fphom:=LiftFactorFpHom(fphom,G,
              Group(spec{[f..Length(spec)]}),pcgsM);
            RUN_IN_GGMBI:=false;
            homliftlevel:=f-1;
            # translate words
            L:=FreeGeneratorsOfFpGroup(Range(fphom)){[1..Length(wordgens)]};
            words:=List(words,x->MappedWord(x,wordgens,L));
            wordgens:=L;
          fi;

          # compute modulo pcgs
          pcgsM := InducedPcgsByPcSequenceNC( spec, spec{[f..m]} );
          pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[n..m]} );

          pcgsF := pcgsM mod pcgsN;

          # compute maximal submodules
          Info(InfoLattice,3,"  compute maximal submodules");
          oper  := Concatenation( gensG, spec{[1..f-1]} );
          modus := MaxSubmodsByPcgs( oper, pcgsF, field );

          # lift to maximal subgroups
          if w[1] = 1 and Length(gensG) = 0 then

            # this is the trivial case
            for modu in modus do
              L:=Concatenation(spec{[1..f-1]},NumeratorOfModuloPcgs( modu ) );
              L := SubgroupNC(G,L);
              #cl := ConjugacyClassSubgroups( G, L );
              #SetSize( cl, 1 );
              #Add( max, cl );
              L!.classsize:=1;
              Add(max,L);
            od;
          elif w[1] = 1 then

            # here we need general complements
            for modu in modus do
              pcgsL  := NumeratorOfModuloPcgs( modu );
              pcgsML := pcgsM mod pcgsL;
              if true or not IsCentralModule( G, pcgsML ) then
                Info(InfoLattice,3,"  compute complement classes ",
                  Length(pcgsML));
                cl := ComplementClassesByPcgsModulo( G, ff.pcgs,
                        pcgsML, fphom,words,wordgens, mgi[2]{sel});
                Append( max, cl );
              else
                Info(InfoLattice,4,"  central case");
            Error("PRUMP");
                R := PRump( G, p );
                M := SubgroupNC( G, pcgsM );
                L := SubgroupNC( G, pcgsL );
                I := Intersection( R, M );
                if IsSubgroup( L, I ) then
                    H:=ClosureGroup( L, R );
                    hom:=NaturalHomomorphismByNormalSubgroup(G,H);
                    V := Image( hom );
                    W := Image( hom, M );
                    cl := ComplementClassesRepresentatives( V, W );
                    cl := List( cl, x -> PreImage( hom, x ) );
                    for K in cl do
                        #new := ConjugacyClassSubgroups( G, K );
                        #SetSize( new, 1 );
                        #Add( max, new );
                        K!.classsize:=1;
                        Add(max,K);
                    od;
                fi;
            fi;
        od;
    else

        # here we use head complements
        Info(InfoLattice,2,"  compute head complement");
        index := Filtered( [1..m], x -> weights[x][1] = w[1]-1
                                    and weights[x][2] = 1
                                    and weights[x][3] <> p );
        pcgsT := Concatenation( spec{index}, pcgsM );
        pcgsT := InducedPcgsByPcSequenceNC( spec, pcgsT );
        pcgsT := pcgsT mod pcgsM;
        gensK := HeadComplementGens( gensG, pcgsT, pcgsF, field );
        index := Filtered( [1..m], x -> weights[x] <> w );
        #Append( gensK, spec{index} );
        for modu in modus do
          K:=Concatenation(spec{index},modu);
          K:=InducedPcgsByGenerators(ff.pcgs,K);
          K:=SubgroupByFittingFreeData(G,gensK,mgi[2]{sel},K);
  #if IsSubset(K,SolvableRadical(G)) then Error("radicalB");fi;
          #cl := ConjugacyClassSubgroups( G, K );
          #SetSize( cl, p^(Length(pcgsF)-Length(modu)) );
          #Add( max, cl );
          K!.classsize:=p^(Length(pcgsF)-Length(modu));
          Add(max,K);
        od;
      fi;
    fi;

  od;
  return max;
end);

#############################################################################
##
#M  FrattiniSubgroup( <G> ) . . . . . . . . . .  Frattini subgroup of a group
##
InstallMethod( FrattiniSubgroup, "Using radical",
[ IsGroup and CanComputeFittingFree ],0,
function(G)
local m,f,i;
  i:=HasIsSolvableGroup(G); # remember if the group knew about its solvability
  if IsTrivial(G) then
    return G;
  elif IsTrivial(SolvableRadical(G)) then
    return TrivialSubgroup(G);
  fi;
  f:=SolvableRadical(G);

  # computing the radical also determines if the group is solvable; if
  # it is, and if solvability was not known before, redispatch, to give
  # methods requiring solvability (e.g. for permutation groups) a chance.
  if not i and IsSolvableGroup(G) then
    return FrattiniSubgroup(G);
  fi;

  m:=MaximalSubgroupClassesSol(G);
  for i in [1..Length(m)] do
    if not IsSubset(m[i],f) then
      f:=Core(G,NormalIntersection(f,m[i]));
    fi;
  od;
  if HasIsFinite(G) and IsFinite(G) then
    SetIsNilpotentGroup(f,true);
  fi;
  return f;
end);

BindGlobal("MaxesByLattice",function(G)
local  c, maxs,sel,reps;

  c:=ConjugacyClassesSubgroups(G);
  c:=Filtered(c,x->Size(Representative(x))<Size(G));
  reps:=List(c,Representative);
  sel:=Filtered([1..Length(c)],x->ForAll(reps,y->Size(y)<=Size(reps[x]) or
        not IsSubset(y,reps[x])));
  sel:=Filtered(sel,x->IsPrime(Size(G)/Size(reps[x]))
        or Size(reps[x])=Size(StabilizerOfExternalSet(c[x])));

  reps:=reps{sel};
  SortBy(reps, Size);

  # nor go by descending order through the representatives. Always eliminate
  # all remaining proper subgroups of conjugates. What remains must be
  # maximal.
  maxs:=[];
  while Length(reps)>0 do
    c:=reps[Length(reps)];
    reps:=reps{[1..Length(reps)-1]};
    # we have eliminated all subgroups of larger maxes, so remaining must be
    # maximal
    Add(maxs,c);
    sel:=Filtered([1..Length(reps)],x->Size(reps[x])<Size(c)
          and (Size(c) mod Size(reps[x]))=0);
    if Length(sel)>0 then
      # some remaining groups could be subgroups
      c:=Orbit(G,c);
      sel:=Filtered(sel,x->ForAny(c,y->IsSubset(y,reps[x])));
      reps:=reps{Difference([1..Length(reps)],sel)};
    fi;

  od;
  return maxs;

end);

# here in case the generic normalizer code is still missing improvements
BindGlobal("MaxesCalcNormalizer",function(P,U)
local map, s, b, bl, bb, sp;
  map:=SmallerDegreePermutationRepresentation(P:inmax);
  if Range(map)=P then
    map:=fail;
  else
    P:=Image(map,P);
    U:=Image(map,U);
  fi;
  s:=Size(U);
  b:=SmallGeneratingSet(U);
  if not IsSubset(P,b) then
    TryNextMethod();
  fi;
  U:=SubgroupNC(P,b);
  SetSize(U,s);
  if Size(P)/s>10^6 then
    if IsTransitive(U,MovedPoints(P)) then
      b:=AllBlocks(U);
      bl:=Collected(List(b,Length));
      bl:=Filtered(bl,i->i[2]=1);
      if Length(bl)>0 then
        b:=First(b,i->Length(i)=bl[1][1]);
        bb:=Stabilizer(U,Set(b),OnSets);
        bb:=Core(U,bb);
        sp:=NormalizerParentSA(SymmetricGroup(MovedPoints(P)),bb);
      else
        sp:=Normalizer(P,U);
        if map<>fail then
          sp:=PreImage(map,sp);
        fi;
        return sp;
      fi;
    else
      sp:=NormalizerParentSA(SymmetricGroup(MovedPoints(P)),U);
    fi;
#Error("B");
    Assert(1,IsSubset(sp,U));
    if (Size(sp)/Size(U))^2<Size(P)/s then
      sp:=Intersection(P,Normalizer(sp,U));
      if map<>fail then
        sp:=PreImage(map,sp);
      fi;
      return sp;
    fi;
  fi;
  sp:=Normalizer(P,U);
  if map<>fail then
    sp:=PreImage(map,sp);
  fi;
  return sp;
end);

# Aut(T)\wr S_n, G, Aut(T),T,n
BindGlobal("MaxesType3",function(w,g,a,t,n,donorm)
local hom,embs,s,k,agens,ad,i,j,perm,dia,ggens,e,tgens,d,m,reco,emba,outs,id;
  if n<>2 and not IsPrimitive(g,WreathProductInfo(w).components,OnSets) then
    # primitivity condition
    Info(InfoLattice,2,"Type 3: Primitivity condition violated");
    return [];
  fi;

  # we need embedding in full automorphism group
  IsNaturalSymmetricGroup(a);
  IsNaturalAlternatingGroup(a);
  reco:=TomDataAlmostSimpleRecognition(a);
  if reco=fail then
    outs:=Size(AutomorphismGroup(Socle(a)))/Size(Socle(a));
  else
    id:=DataAboutSimpleGroup(PerfectResiduum(a));
    outs:=id.fullAutGroup[1];
  fi;

  if Size(g)/Size(Image(Projection(w),g))/(Size(t)^n)>outs then
    Info(InfoLattice,2,"Type 3 can't happen as Outer part is too big");
    return [];
  fi;

  if Size(a)/Size(t)<outs then
    Info(InfoLattice,3,"Not full automorphism group");
    emba:=EmbedFullAutomorphismWreath(w,a,t,n);
    g:=Image(emba[1],g);
    w:=emba[2];
    a:=emba[3];
    t:=emba[4];
  else
    emba:=fail;
  fi;

  embs:=List([1..n+1],i->Embedding(w,i));
  tgens:=GeneratorsOfGroup(t);
  d:=List(tgens,i->Image(embs[1],i));
  s:=Subgroup(w,d);
  k:=TrivialSubgroup(w); # the first component autos can be undone.
  agens:=GeneratorsOfGroup(a);
  ad:=List(agens,i->Image(embs[1],i));
  for i in [2..n] do
    for j in [1..Length(ad)] do
      e:=Image(embs[i],agens[j]);
      ad[j]:=ad[j]*e;
      k:=ClosureGroup(k,e);
    od;
    for j in [1..Length(d)] do
      e:=Image(embs[i],tgens[j]);
      d[j]:=d[j]*e;
      s:=ClosureGroup(s,e);
    od;
  od;
  hom:=NaturalHomomorphismByNormalSubgroup(w,s);
  k:=Image(hom,k);
  ad:=Image(hom,ad);
  perm:=Image(hom,Image(embs[n+1]));
  dia:=ClosureGroup(perm,ad);
  ggens:=List(GeneratorsOfGroup(g),i->Image(hom,i));
  e:=Filtered(AsList(k),i->ForAll(ggens,j->j^i in dia));
  Info(InfoLattice,1,"Type3: ",Length(e)," invariant classes");
  m:=[];
  d:=SubgroupNC(w,d);
  for i in e do
    j:=PreImagesRepresentative(hom,i^-1);
    Info(InfoLattice,2,"Orders:",Order(i),",",Order(j));
    j:=d^j;
    if donorm then
      j:=MaxesCalcNormalizer(g,j);
      Assert(1,Index(g,j)=Size(t)^(n-1));
    fi;
    Add(m,j);
  od;
  if emba<>fail then
    m:=List(m,i->PreImage(emba[1],i));
  fi;
  return m;
end);

InstallMethod(MaxesAlmostSimple,"fallback to lattice",true,[IsGroup],0,
function(G)
  if ValueOption("cheap")=true then return [];fi;
  Info(InfoLattice,1,"MaxesAlmostSimple: Fallback to lattice");
  return MaxesByLattice(G);
end);

InstallMethod(MaxesAlmostSimple,"table of marks and classical",true,[IsGroup],0,
function(G)
local m,id,epi,H,ids,ft;

  # does the table of marks have it?
  m:=TomDataMaxesAlmostSimple(G);
  if m<>fail then return m;fi;

  if IsNonabelianSimpleGroup(G) then
    # following is stopgap for L
    id:=DataAboutSimpleGroup(G);
    ids:=id.idSimple;
    if ids.series="A" then
      Info(InfoPerformance,1,"Alternating recognition needed!");
      H:=AlternatingGroup(ids.parameter);
      m:=MaximalSubgroupClassReps(H); # library, natural
      epi:=IsomorphismGroups(G,H);
      m:=List(m,x->PreImage(epi,x));
      return m;
    elif IsBound(ids.parameter) and IsList(ids.parameter)
      and Length(ids.parameter)=2 and ForAll(ids.parameter,IsInt) then

      # O(odd,2) is stored as SP(odd-1,2)
      if ids.series="B" and ids.parameter[2]=2 then
        ids:=rec(name:=ids.name,parameter:=ids.parameter,series:="C",
        shortname:=ids.shortname);
        ft:=ids;
      else
        ft:=fail;
      fi;

      # ClassicalMaximals will fail if it can't find
      m:=ClassicalMaximals(ids.series,
        ids.parameter[1],ids.parameter[2]);
      if m<>fail then
        epi:=EpimorphismFromClassical(G:classicepiuseiso:=true,
          forcetype:=ft,
          usemaximals:=false);
        if epi<>fail then
          m:=List(m,x->SubgroupNC(Range(epi),
              List(GeneratorsOfGroup(x),y->ImageElm(epi,y))));
          return m;
        fi;
      fi;
    fi;

  fi;
  TryNextMethod();
end);

InstallMethod(MaxesAlmostSimple,"permutation group",true,[IsPermGroup],0,
function(G)
local m,epi,cnt,h;

  # Are we just finding out that a group is symmetric or alternating?
  # if so, try to use method that uses data library
  if (IsNaturalSymmetricGroup(G) or IsNaturalAlternatingGroup(G)) then
    Info(InfoLattice,1,"MaxesAlmostSimple: Use S_n/A_n");
    m:=MaximalSubgroupsSymmAlt(G,false);
    if m<>fail then
      return m;
    fi;
  fi;

  # is a permutation degree too big?
  if NrMovedPoints(G)>
      SufficientlySmallDegreeSimpleGroupOrder(Size(PerfectResiduum(G))) then
    h:=G;
    for cnt in [1..5] do
      epi:=SmallerDegreePermutationRepresentation(h:cheap);
      if NrMovedPoints(Range(epi))<NrMovedPoints(h) then
        m:=MaxesAlmostSimple(Image(epi,G));
        m:=List(m,x->PreImage(epi,x));
        return m;
      fi;
      # re-create group to avoid storing the map
      h:=Group(GeneratorsOfGroup(G));
      SetSize(h,Size(G));
    od;
  fi;

  TryNextMethod();
end);

BindGlobal("MaxesType4a",function(w,G,a,t,n)
local dom, o, t1, a1, t1d, proj, reps, ts, ta, tb, s1, i, fix, wnew, max, s, p1, p2, en1, en2, emb, ma, img, f, j,projG;
  dom:=MovedPoints(w);
  o:=Orbits(G,dom);
  t:=Subgroup(Parent(t),SmallGeneratingSet(t));
  t1:=Image(Embedding(w,1),t);
  a1:=Image(Embedding(w,1),a);
  t1d:=Set(MovedPoints(t1));
  if not IsSubset(o[1],t1d) then
    o:=Reversed(o);
  fi;
  # get the ts corresponding to points
  proj:=Projection(w);
  projG:=RestrictedMapping(proj,G);
  reps:=List([1..n],i->PreImagesRepresentative(projG,RepresentativeAction(Image(projG),1,i)));
  reps[n+1]:=
    PreImagesRepresentative(proj,RepresentativeAction(Image(proj),[1..n],[n+1..2*n],OnSets));
  for i in [2..n] do
    j:=reps[i]*reps[n+1];
    reps[1^Image(proj,j)]:=j;
  od;

  #wremb:=Embedding(w,2*n+1);
  #reps:=List([1..2*n],i->Image(wremb,RepresentativeAction(Source(wremb),1,i)));

  ts:=List(reps,i->OnSets(t1d,i));
  ta:=Filtered([1..2*n],i->IsSubset(o[1],ts[i]));
  tb:=Difference([1..2*n],ta);
  s1:=Stabilizer(G,t1d,OnSets);
  i:=Size(s1);
  s1:=SubgroupNC(G,SmallGeneratingSet(s1));
  SetSize(s1,i);
  fix:=Filtered(tb,i->IsSubset(ts[i],Orbit(s1,ts[i][1])));
  Info(InfoLattice,2,"Type 4a: ",Length(fix)," candidates");
  wnew:=WreathProduct(a,SymmetricGroup(2));
  max:=[];
  for f in Difference(fix,[1]) do
    Info(InfoLattice,3,"trying ",f);
    # now try 1 with f -- this is essentially a type 3a test
    s:=Stabilizer(s1,Difference(dom,Union(ts[1],ts[f])),OnTuples);
    # embed into wnew
    p1:=Embedding(w,1);
    p2:=Embedding(w,f);
    en1:=Embedding(wnew,1);
    en2:=Embedding(wnew,2);
    emb:=List(GeneratorsOfGroup(s),i->
        Image(en1,PreImagesRepresentative(p1,RestrictedPerm(i,ts[1])))
       *Image(en2,PreImagesRepresentative(p2,RestrictedPerm(i,ts[f]))) );
    emb:=GroupHomomorphismByImages(s,wnew,GeneratorsOfGroup(s),emb);
    ma:=MaxesType3(wnew,Image(emb,s),a1,t1,2,false);
    for i in ma do
      i:=PreImage(emb,i);
      img:=i;
      for j in [2..n] do
        img:=ClosureGroup(img,i^reps[j]);
      od;
      if Size(img)=Size(t)^n then
        j:=MaxesCalcNormalizer(G,img);
        if Index(G,j)=Size(t)^n then;
          Add(max,j);
        fi;
      fi;
    od;
  od;
  return max;
end);

BindGlobal("MaxesType4bc",function(w,g,a,t,n)
local m, fact, fg, reps, ma, idx, nm, embs, proj, kproj, k, ag, agl, ug,
  bl, lb, u, uphi, ws, ew, ueg, r, i, emb, j, b,ue,scp,s,nlb,
  comp;

  m:=[];
  # factor action
  comp:=WreathProductInfo(w).components;
  fact:=ActionHomomorphism(w,comp,OnSets,"surjective");
  fg:=Image(fact,g);

  # type 4c
  reps:=List([1..n],
             i->PreImagesRepresentative(fact,RepresentativeAction(fg,1,i)));


  # get the maximal subgroups of A, intersect with t to get the socle part
  ma:=MaxesAlmostSimple(a);
  Info(InfoLattice,2,Length(ma)," maxclasses for almost simple");
  for i in ma do
    i:=Intersection(i,t);
    if Size(i)<Size(t) then
      # otherwise the socle is in the kernel
      idx:=Index(t,i)^n;
      nm:=i;
      for j in [2..n] do
        nm:=ClosureGroup(nm,i^reps[j]);
      od;
      nm:=MaxesCalcNormalizer(g,nm);
      Assert(1,Index(g,nm)=idx);
      Add(m,nm);
      Info(InfoLattice,3,"Type 4c maximal of index ",idx);
    fi;
  od;
  Info(InfoLattice,1,"Total ",Length(m)," type 4c maxes");

  #4b: Get minimal blocks on socle components

  bl:=RepresentativesMinimalBlocks(fg,[1..n],1);
  bl:=Filtered(bl,i->Length(i)<n);
  if Length(bl)>0 then
    Info(InfoLattice,1,Length(bl)," minimal block systems");

    # preparation for mapping in smaller wreath
    embs:=List([1..n+1],i->Embedding(w,i));
    proj:=Projection(w);
    kproj:=[];
    k:=KernelOfMultiplicativeGeneralMapping(proj);
    ag:=GeneratorsOfGroup(a);
    agl:=Length(ag);
    ug:=List([1..n],i->List(ag,j->Image(embs[i],j)));
    for i in [1..n] do
      kproj[i]:=GroupHomomorphismByImages(k,a,Concatenation(ug),
              Concatenation(ListWithIdenticalEntries((i-1)*agl,One(a)),
                            ag,
                            ListWithIdenticalEntries((n-i)*agl,One(a))));
    od;

    for b in bl do
      Info(InfoLattice,2,"block system ",b);
      lb:=Length(b);
      nlb:=n/lb;
      u:=OrbitStabilizer(g,Union(comp{b}),OnSets);
      reps:=List(u.orbit,x->RepresentativeAction(g,Union(comp{b}),x,OnSets));
      u:=u.stabilizer;

      Assert(1,IsPrimitive(u,comp{b},OnSets));

      #u:=OrbitStabilizer(fg,b,OnSets);
      #phi:=ActionHomomorphism(fg,u.orbit,OnSets);
      #ue:=Image(phi,fg);
      #reps:=List([1..nlb],i->RepresentativeAction(ue,1,i));
      #reps:=List(reps,i->PreImagesRepresentative(phi,i));
      #reps:=List(reps,i->PreImagesRepresentative(fact,i));
      #u:=u.stabilizer;
      uphi:=ActionHomomorphism(Image(fact,u),b);

      uphi:=RestrictedMapping(fact,
              PreImage(fact,Stabilizer(Image(fact),b,OnSets)) )*uphi;
      # build smaller wreath
      ws:=WreathProduct(a,Image(uphi,u));
      ew:=List([1..lb+1],i->Embedding(ws,i));
      # embed
      ug:=GeneratorsOfGroup(u);
      ueg:=[];
      for i in ug do
        r:=Image(embs[n+1],Image(proj,i));
        i:=i/r;
        i:=Product([1..lb],j->Image(ew[j],Image(kproj[b[j]],i)));
        i:=i*Image(ew[lb+1],Image(uphi,r));
        Add(ueg,i);
      od;
      emb:=GroupHomomorphismByImages(u,ws,ug,ueg);
      ue:=Image(emb,u);
      Info(InfoLattice,2,"Try type 3b for size ",Size(ue));

      # the socle part
      s:=Image(embs[b[1]],t);
      for i in [2..lb] do
        s:=ClosureGroup(s,Image(embs[b[i]],t));
      od;
      scp:=List(GeneratorsOfGroup(s),i->Image(emb,i));
      scp:=GroupHomomorphismByImages(s,ue,GeneratorsOfGroup(s),scp);

      # get type 3b maxes
      ma:=MaxesType3(ws,ue,a,t,lb,true);
      Info(InfoLattice,1,Length(ma)," type 3b maxes in projection");
      for i in ma do
        idx:=Index(ue,i)^nlb;
        # get the socle part
        i:=Intersection(Socle(ws),i);
        i:=PreImage(scp,i);
        nm:=i;
        for j in [2..nlb] do
          nm:=ClosureGroup(nm,i^reps[j]);
        od;
        nm:=MaxesCalcNormalizer(g,nm);
        Assert(1,Index(g,nm)=idx);
        Add(m,nm);
      od;

    od;
  else
    Info(InfoLattice,1,"Component action primitive: No 4b maxes");
  fi;

  return m;
end);

InstallGlobalFunction(DoMaxesTF,function(arg)
local G,types,ff,maxes,lmax,q,d,dorb,dorbt,i,dorbc,dorba,dn,act,comb,smax,soc,
  a1emb,a2emb,anew,wnew,e1,e2,emb,a1,a2,mm;

  G:=arg[1];

  # which kinds of maxes do we want to get
  if Length(arg)>1 then
    types:=ShallowCopy(arg[2]);
    if IsString(types) and Length(types)>0 then
      types:=[types];
    fi;
  else
    types:=[1,2,"3a","3b","4a","4b","4c",5];
  fi;
  for i in [1..Length(types)] do
    if not IsString(types[i]) then types[i]:=String(types[i]);fi;
  od;

  ff:=FittingFreeLiftSetup(G);
  if Size(SolvableRadical(Image(ff.factorhom)))>1 then
    # we can't use an inherited setup
    q:=Size(G);
    G:=Group(GeneratorsOfGroup(G));
    SetSize(G,q);
    ff:=FittingFreeLiftSetup(G);
  fi;

  if "1" in types and Length(ff.pcgs)>0 then
    smax:=MaximalSubgroupClassesSol(G);
    Info(InfoLattice,1,Length(smax),
      " maximal subgroups intersecting in radical");
  else
    smax:=[];
  fi;

  maxes:=[];
  q:=ImagesSource(ff.factorhom);
  soc:=Socle(q);
  if Size(soc)<Size(q) then
    act:=NaturalHomomorphismByNormalSubgroup(q,Socle(q));
    if IsSolvableGroup(ImagesSource(act)) then
      lmax:=MaximalSubgroupClassReps(ImagesSource(act));
    else
      lmax:=DoMaxesTF(ImagesSource(act),types);
    fi;
    List(lmax,Size);
    Info(InfoLattice,1,Length(lmax)," socle factor maxes");
    # special case: p factor
    if Length(lmax)=1 and Size(lmax[1])=1 then
      lmax:=[Socle(q)];
    else
      lmax:=List(lmax,x->PreImage(act,x));
    fi;
    for mm in lmax do mm!.type:="1";od;
    Append(maxes,lmax);
  fi;

  if "brute" in types then
    maxes:=MaxesByLattice(q);

  elif ForAny(types,x->x<>"1") then # we want other types as well, decompose
    d:=DirectFactorsFittingFreeSocle(q);
    dorb:=Orbits(q,d); # fuse under q-action -> get normal subgroups in socle

    dorb:=List(dorb,x->List(x,y->Position(d,y))); # as numbers
    # isomorphism types (to see about pairings)
    dorbt:=List(dorb,x->IsomorphismTypeInfoFiniteSimpleGroup(d[x[1]]));
    dorbc:=List(dorb,x->NormalClosure(q,d[x[1]]));
    dorba:=[];

    # run through actions on each individual
    for dn in [1..Length(dorb)] do
      act:=WreathActionChiefFactor(q,dorbc[dn],TrivialSubgroup(q));
      dorba[dn]:=act;
      if Length(dorb[dn])=1 and "2" in types then
        # type 2: almost simple
        a1:=ImagesSource(act[2]);
        lmax:=MaxesAlmostSimple(a1);
        lmax:=List(lmax,x->PreImage(act[2],x));
        # eliminate those containing the socle
        lmax:=Filtered(lmax,x->not IsSubset(x,soc));
        Info(InfoLattice,1,Length(lmax)," type 2 maxes");
        for mm in lmax do mm!.type:="2";od;
        Append(maxes,lmax);
      fi;

      if Length(dorb[dn])>1 then
        if "3" in types or "3b" in types then
          # Diagonal, Socle is minimal normal. (SD)
          lmax:=MaxesType3(act[1],Image(act[2],q),act[3],act[4],act[5],true);
          Info(InfoLattice,1,Length(lmax)," type 3b maxes");
          lmax:=List(lmax,x->PreImage(act[2],x));
          for mm in lmax do mm!.type:="3b";od;
          Append(maxes,lmax);
        fi;

        if "4" in types or "4b" in types or "4c" in types then
          # Product action with the first factor primitive of type 3b. (CD)
          # Product action with the first factor primitive of type 2. (PA)
          lmax:=MaxesType4bc(act[1],Image(act[2],q),act[3], act[4],act[5]);
          Info(InfoLattice,1,Length(lmax)," type 4bc maxes");
          lmax:=List(lmax,x->PreImage(act[2],x));
          for mm in lmax do mm!.type:="4bc";od;
          Append(maxes,lmax);
        fi;


        if Length(dorb[dn])>5
           and not IsSolvableGroup(Action(q,d{dorb[dn]}))
           and "5" in types then
          # Twisted wreath product (TW)
          if not ValueOption("cheap")=true then
            Error("Type 5 not yet implemented");
          fi;
        fi;

      fi;

    od;

    # run through actions on pairs of isomorphic socles
    comb:=Combinations([1..Length(dorb)],2);
    comb:=Filtered(comb,x->dorbt[x[1]]=dorbt[x[2]]
                   and Length(dorb[x[1]])=Length(dorb[x[2]]));
    for dn in comb do
      a1:=dorba[dn[1]];
      a2:=dorba[dn[2]];

      if Size(a1[3])>Size(a2[3]) then
        anew:=EmbedAutomorphisms(a1[3],a2[3],a1[4],a2[4]);
        a1emb:=anew[2];
        a2emb:=anew[3];
      else
        anew:=EmbedAutomorphisms(a2[3],a1[3],a2[4],a1[4]);
        a2emb:=anew[2];
        a1emb:=anew[3];
      fi;
      anew:=anew[1];

      wnew:=WreathProduct(anew,SymmetricGroup(a1[5]+a2[5]));
      e1:=EmbeddingWreathInWreath(wnew,a1[1],a1emb,1);
      e2:=EmbeddingWreathInWreath(wnew,a2[1],a2emb,a1[5]+1);
      emb:=GroupHomomorphismByImages(q,wnew,GeneratorsOfGroup(q),
              List(GeneratorsOfGroup(q),i->
              Image(e1,ImageElm(a1[2],i))*Image(e2,ImageElm(a2[2],i))));

      if Length(dorb[dn[1]])=1 then
        if "3a" in types then
          lmax:=MaxesType3(wnew,Image(emb,q),anew,Image(a1emb,a1[4]),2,true);
          Info(InfoLattice,1,Length(lmax)," type 3a maxes");
          lmax:=List(lmax,i->PreImage(emb,i));
for mm in lmax do mm!.type:="3a";od;
          Append(maxes,lmax);
        fi;
      else
        if "4a" in types then
          lmax:=MaxesType4a(wnew,Image(emb,q),anew,Image(a1emb,a1[4]),
                          Length(dorb[dn[1]]));
          Info(InfoLattice,1,Length(lmax)," type 4a maxes");
          lmax:=List(lmax,i->PreImage(emb,i));
for mm in lmax do mm!.type:="4a";od;
          Append(maxes,lmax);
        fi;
      fi;

    od;

  fi;

  # the factorhom should be able to take preimages of subgroups OK
  #maxes:=List(maxes,x->PreImage(ff.factorhom,x));
  lmax:=[];
  d:=Size(KernelOfMultiplicativeGeneralMapping(ff.factorhom))>1;
  for i in maxes do
    a2:=PreImage(ff.factorhom,i);
    if d then
      SetSolvableRadical(a2,PreImage(ff.factorhom,SolvableRadical(i)));
    fi;
    Add(lmax,a2);
  od;

  return Concatenation(smax,lmax);
end);

#############################################################################
##
#F  MaximalSubgroupClassReps(<G>) . . . . TF method
##
InstallMethod(MaximalSubgroupClassReps,"TF method",true,
  [IsGroup and IsFinite and CanComputeFittingFree],OVERRIDENICE,DoMaxesTF);

InstallMethod(CalcMaximalSubgroupClassReps,"TF method",true,
  [IsGroup and IsFinite and CanComputeFittingFree],OVERRIDENICE,
function(G)
  return DoMaxesTF(G);
end);

#InstallMethod(MaximalSubgroupClassReps,"perm group",true,
#  [IsPermGroup and IsFinite],0,DoMaxesTF);

BindGlobal("NextLevelMaximals",function(g,l)
local m;
  if Length(l)=0 then return [];fi;
  m:=Concatenation(List(l,MaximalSubgroupClassReps));
  if Length(l)>1 then
    m:=Unique(m);
  fi;
  if Length(l)>1 or Size(l[1])<Size(g) then
    m:=List(SubgroupsOrbitsAndNormalizers(g,m,false),x->x.representative);
  fi;
  return m;
end);

InstallGlobalFunction(MaximalPropertySubgroups,function(g,prop)
local all,m,sel,i,new,containedconj;

  containedconj:=function(g,u,v)
  local m,n,dc,i;
    if not IsInt(Size(u)/Size(v)) then
      return false;
    fi;
    m:=Normalizer(g,u);
    n:=Normalizer(g,v);
    dc:=DoubleCosetRepsAndSizes(g,n,m);
    for i in dc do
      if ForAll(GeneratorsOfGroup(v),x->x^i[1] in u) then
        return true;
      fi;
    od;
    return false;
  end;

  all:=[];
  m:=MaximalSubgroupClassReps(g);
  while Length(m)>0 do
    sel:=Filtered([1..Length(m)],x->prop(m[x]));

    # eliminate those that are contained in a conjugate of a subgroup of all
    new:=m{sel};
    SortBy(new,x->Size(g)/Size(x)); # small indices first to deal with
                                    # conjugate inclusion here
    for i in new do
      if not ForAny(all,x->containedconj(g,x,i)) then
        Add(all,i);
      fi;
    od;

    #Append(all,Filtered(m{sel},
    #  x->ForAll(all,y->Size(x)<>Size(y) or not IsSubset(y,x))));
    m:=NextLevelMaximals(g,m{Difference([1..Length(m)],sel)});

  od;
  # there could be conjugates after all by different routes
  #all:=List(SubgroupsOrbitsAndNormalizers(g,all,false),x->x.representative);
  return all;
end);

InstallGlobalFunction(MaximalSolvableSubgroups,
  g->MaximalPropertySubgroups(g,IsSolvableGroup));
