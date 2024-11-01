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
##  This file contains the methods for computing presentations for
##  (permutation) groups.
##

#############################################################################
##
#M  IsomorphismFpGroup( G )
##
InstallOtherMethod( IsomorphismFpGroup, "supply name", true, [IsGroup], 0,
function( G )
  return IsomorphismFpGroup( G, "F" );
end );

InstallGlobalFunction( IsomorphismFpGroupByGenerators,function(arg)
local G,gens,nam;
  G:=arg[1];
  gens:=arg[2];
  if Length(arg)>2 then
    nam:=arg[3];
  else
    nam:="F";
  fi;
  if not ForAll(gens,i->i in G) or Index(G,SubgroupNC(G,gens))>1 then
    Error("<gens> must be a generating set for G");
  fi;
  return IsomorphismFpGroupByGeneratorsNC(G,gens,nam);
end);

InstallOtherMethod(IsomorphismFpGroupByGeneratorsNC,"supply name",
  IsIdenticalObj,[IsGroup,IsList],0,
function(G,gens)
  return IsomorphismFpGroupByGeneratorsNC(G,gens,"F");
end);

InstallOtherMethod( IsomorphismFpGroupByCompositionSeries,
                    "supply name", true, [IsGroup], 0,
function( G )
  return IsomorphismFpGroupByCompositionSeries( G, "F" );
end );

InstallOtherMethod( IsomorphismFpGroupByChiefSeries,
                    "supply name", true, [IsGroup], 0,
function( G )
  return IsomorphismFpGroupByChiefSeries( G, "F" );
end );

InstallOtherMethod(IsomorphismFpGroup,"for perm groups",true,
  [IsPermGroup,IsString],0,
function( G,nam )
  # test frequent, special cases
  if (not HasIsSymmetricGroup(G) and IsSymmetricGroup(G)) or
     (not HasIsAlternatingGroup(G) and IsAlternatingGroup(G)) then
    return IsomorphismFpGroup(G,nam);
  fi;

  return IsomorphismFpGroupByChiefSeries( G, nam );
end );

InstallOtherMethod( IsomorphismFpGroup,"for simple solvable permutation groups",
  true,
  [IsPermGroup and IsSimpleGroup and IsSolvableGroup,IsString],0,
function(G,str)
  return IsomorphismFpGroupByPcgs( Pcgs(G), str );
end);

InstallOtherMethod( IsomorphismFpGroup,"for nonabelian simple permutation groups",
  true, [IsPermGroup and IsNonabelianSimpleGroup,IsString],0,
function(G,str)
local l,iso,fp,stbc,gens;
  # use the perfect groups library (as far as hand-created)
  PerfGrpLoad(Size(G));
  if Size(G)<10^6 and IsRecord(PERFRec) and
     ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true and
     not Size(G) in PERFRec.notKnown then
    Info(InfoPerformance,2,"Using Perfect Groups Library");
    # loop over the groups
    for l in List([1..NrPerfectGroups(Size(G))],
                  i->PerfectGroup(IsPermGroup,Size(G),i)) do
      iso:=IsomorphismGroups(G,l);
      if iso<>fail then
        fp:=IsomorphismFpGroup(l);
        iso:=GroupHomomorphismByImagesNC(G,Range(fp),
               List(MappingGeneratorsImages(fp)[1],
                    i->PreImagesRepresentative(iso,i)),
               MappingGeneratorsImages(fp)[2]);
        SetIsBijective(iso,true);
        return iso;
      fi;
    od;
  fi;

  stbc:=StabChainMutable(G);
  gens:=StrongGeneratorsStabChain(stbc);
  iso:=IsomorphismFpGroupByGeneratorsNC( G, gens, str:chunk );
  ProcessEpimorphismToNewFpGroup(iso);
  return iso;
end);

#############################################################################
##
#M  IsomorphismFpGroupByCompositionSeries( G, str )
##
InstallOtherMethod( IsomorphismFpGroupByCompositionSeries,
               "for permutation groups", true,
               [IsPermGroup, IsString], 0,
function( G, str )
    local l, H, gensH, iso, F, gensF, imgsF, relatorsF, free, n, k, N, M,
          hom, preiH, c, new, T, gensT, E, gensE, imgsE, relatorsE, rel,
          w, t, i, j, series;

    if IsSolvableGroup( G ) then
        return IsomorphismFpGroupByPcgs( Pcgs(G), str );
    fi;

    # compute composition series
    series := CompositionSeries( G );
    l      := Length( series );

    # set up
    H := series[l-1];
    # if IsPrime( Size( H ) ) then
    #     gensH := Filtered( GeneratorsOfGroup( H ),
    #                        x -> Order(x)=Size(H) ){[1]};
    # else
    #     gensH := Set( GeneratorsOfGroup( H ) );
    #     gensH := Filtered( gensH, x -> x <> One(H) );
    # fi;

    IsNonabelianSimpleGroup(H); #ensure H knows to be simple, thus the call to
    # `IsomorphismFpGroup' will not yield an infinite recursion.
    IsNaturalAlternatingGroup(H); # We have quite often a factor A_n for
    # which GAP knows better presentations. Thus this test is worth doing.
    iso := IsomorphismFpGroup( H,str );

    F := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := MappingGeneratorsImages(iso)[1];
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free := GroupHomomorphismByImagesNC( F, series[l-1], gensF, imgsF );
    n := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        # get composition factor
        N := series[k];
        M := series[k+1];
        # do not call `InParent'-- rather safe than sorry.
        hom := NaturalHomomorphismByNormalSubgroupNC(N, M );
        H := Image( hom );
        # if IsPrime( Size( H ) ) then
        #     gensH := Filtered( GeneratorsOfGroup( H ),
        #                        x -> Order(x)=Size(H) ){[1]};
        # else
        #     gensH := Set( GeneratorsOfGroup( H ) );
        #     gensH := Filtered( gensH, x -> x <> One(H) );
        # fi;

        # compute presentation of H
        IsNonabelianSimpleGroup(H);
        IsNaturalAlternatingGroup(H);
        new:=IsomorphismFpGroup(H,"@");
        gensH:=List(GeneratorsOfGroup(Image(new)),
                      i->PreImagesRepresentative(new,i));
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );

        c     := Length( gensH );

        T   := Image( new );
        gensT := GeneratorsOfGroup( FreeGroupOfFpGroup( T ) );

        # create new free group
        E     := FreeGroup( n+c, str );
        gensE := GeneratorsOfGroup( E );
        imgsE := Concatenation( preiH, imgsF );
        relatorsE := [];

        # modify presentation of H
        for rel in RelatorsOfFpGroup( T ) do
            w := MappedWord( rel, gensT, gensE{[1..c]} );
            t := MappedWord( rel, gensT, imgsE{[1..c]} );
            if not t = One( G ) then
                t := PreImagesRepresentative( free, t );
                t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
            else
                t := One( E );
            fi;
            Add( relatorsE, w/t );
        od;

        # add operation of T on F
        for i in [1..c] do
            for j in [1..n] do
                w := Comm( gensE[c+j], gensE[i] );
                t := Comm( imgsE[c+j], imgsE[i] );
                if not t = One( G ) then
                    t := PreImagesRepresentative( free, t );
                    t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
                else
                    t := One( E );
                fi;
                Add( relatorsE, w/t );
            od;
        od;

        # append relators of F
        for rel in relatorsF do
            w := MappedWord( rel, gensF, gensE{[c+1..c+n]} );
            Add( relatorsE, w );
        od;

        # iterate
        F := E;
        gensF := gensE;
        imgsF := imgsE;
        relatorsF := relatorsE;
        free :=  GroupHomomorphismByImagesNC( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up
    F := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    if HasSize(G) then
      SetSize(F,Size(G));
    fi;
    iso := GroupHomomorphismByImagesNC( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    ProcessEpimorphismToNewFpGroup(iso);
    return iso;
end );

#############################################################################
##
#M  IsomorphismFpGroupByChiefSeriesFactor( G, str, N )
##
InstallGlobalFunction(IsomorphismFpGroupByChiefSeriesFactor,
function(g,str,N)
  local ser, ab, homs, gens, idx, start, pcgs, hom, f, fgens, auts, sf, orb,
  tra, j, a, ad, lad, n, fg, free, rels, fp, vals, dec, still, lgens, ngens,
  nrels, nvals, p, dodecomp, decomp, hogens, di, i, k, l,
  m,abelianlimit,locallim,abpow,needgens,fampcgs,rad;

  abelianlimit:=ValueOption("abelianlimit");
  if abelianlimit=fail then
    abelianlimit:=infinity;
  fi;

  if Size(g)=1 then
    # often occurs in induction base
    return
    GroupHomomorphismByFunction(g,TRIVIAL_FP_GROUP,x->One(TRIVIAL_FP_GROUP),x->One(g):noassert);
  elif g=N then
    # often occurs in induction base
    return GroupHomomorphismByImagesNC(g,TRIVIAL_FP_GROUP,GeneratorsOfGroup(g),
             List(GeneratorsOfGroup(g),x->One(TRIVIAL_FP_GROUP)):noassert);
  fi;

  if ValueOption("rewrite")=true then
    # try to go through radical (image) and pick generators split in radical factor
    rad:=ClosureGroup(SolvableRadical(g),N);
    ser:=[];
    gens:=[];
    if Size(rad)<Size(g) then
      hom:=NaturalHomomorphismByNormalSubgroupNC(g,rad);
      f:=Image(hom);
      ser:=ShallowCopy(DirectFactorsFittingFreeSocle(f));
      gens:=Concatenation(List(ser,SmallGeneratingSet));
      j:=SubgroupNC(f,gens);
      for i in GeneratorsOfGroup(f) do
        if not i in j then
          Add(gens,i);
          j:=ClosureSubgroupNC(j,i);
        fi;
      od;
      # build series
      for i in [Length(ser)-1,Length(ser)-2..1] do
        ser[i]:=ClosureGroup(ser[i+1],ser[i]);
      od;
      if Size(ser[1])<Size(f) then
        ser:=ChiefSeriesThrough(f,ser);
        gens:=Union(gens,Union(List(ser,SmallGeneratingSet)));
      fi;
      if f<>g then
        gens:=List(gens,x->PreImagesRepresentative(hom,x));
        ser:=List(ser,x->PreImage(hom,x));
      fi;
      # change generators to make split
      ser:=List(ser,x->ClosureGroup(rad,Filtered(gens,y->y in x)));
    else
      rad:=g;
    fi;

    if Length(ser)=0 or Size(ser[Length(ser)])>Size(rad) then Add(ser,rad);fi;

    if Size(rad)>1 then
      if HasChiefSeries(g) and N in ChiefSeries(g) and rad in ChiefSeries(g) then
        f:=Filtered(ChiefSeries(g),x->IsSubset(rad,x));
      elif IsTrivial(N) then
        if rad=g then
          f:=ChiefSeries(g);
        else
          f:=ChiefSeriesUnderAction(g,rad);
        fi;
      else
        f:=ChiefSeriesThrough(g,[rad,N]);
      fi;
      Append(ser,Filtered(f,x->Size(x)<Size(rad)));
    fi;
  elif IsTrivial(N) then
    ser:=ChiefSeries(g);
  else
    if HasChiefSeries(g) and N in ChiefSeries(g) then
      ser:=ChiefSeries(g);
    else
      ser:=ChiefSeriesThrough(g,[N]);
    fi;
  fi;

  if Size(N)>1 then
    ser:=Filtered(ser,i->IsSubset(i,N));
  fi;

  if IsSolvableGroup(g) then
    fampcgs:=SpecialPcgs(g);
  else
    fampcgs:=fail;
  fi;
  ab:=[];
  homs:=[];
  gens:=[];
  idx:=[];
  abpow:=[]; # store powers for large order abelian
  for i in [2..Length(ser)] do
    start:=Length(gens)+1;
    if HasAbelianFactorGroup(ser[i-1],ser[i]) then
      ab[i-1]:=true;
      if fampcgs<>fail then
        pcgs:=CanonicalPcgs(InducedPcgs(fampcgs,ser[i-1])) mod
        CanonicalPcgs(InducedPcgs(fampcgs,ser[i]));
      else
        pcgs:=ModuloPcgs(ser[i-1],ser[i]);
      fi;
      homs[i-1]:=pcgs;
      Append(gens,pcgs);
      f:=pcgs;
      j:=RelativeOrders(pcgs)[1];
      abpow[i-1]:=[];
      if abelianlimit<>infinity then
        # split up evenly
        k:=LogInt(j-1,abelianlimit)+1; # ensure rounded up
        locallim:=RootInt(j-1,k)+1; # ensure rounded up

        while j>locallim do
          k:=Minimum(locallim,RootInt(j,2));
          Add(abpow[i-1],k);
          f:=List(f,x->x^k);
          Append(gens,f);
          j:=QuoInt(j,k);
        od;
      fi;

    else
      ab[i-1]:=false;
      hom:=NaturalHomomorphismByNormalSubgroup(ser[i-1],ser[i]:noassert);
      IsOne(hom);
      f:=Image(hom);
      # knowing simplicity makes it easy to test whether a map is faithful
      if IsNonabelianSimpleGroup(f) then
        if DataAboutSimpleGroup(f).idSimple.series="A" and
          not IsNaturalAlternatingGroup(f) then
          # force natural alternating
          hom:=hom*IsomorphismGroups(f,
            AlternatingGroup(DataAboutSimpleGroup(f).idSimple.parameter));
        elif IsPermGroup(f) and
          NrMovedPoints(f)>SufficientlySmallDegreeSimpleGroupOrder(Size(f)) then
          hom:=hom*SmallerDegreePermutationRepresentation(f:cheap);
        fi;
      elif IsPermGroup(f) then
        hom:=hom*SmallerDegreePermutationRepresentation(f:cheap);
      fi;

      # the range is elementary. Use this for the fp group isomorphism
      f:=Image(hom);
      # calculate automorphisms of f induced by G
      fgens:=GeneratorsOfGroup(f);
      auts:=List(GeneratorsOfGroup(g),i->
             GroupHomomorphismByImagesNC(f,f,fgens,
               List(fgens,j->Image(hom,PreImagesRepresentative(hom,j)^i)):noassert));
      for j in auts do
        SetIsBijective(j,true);
      od;
      # get the minimal normal subgroups, together with isomorphisms
      sf:=CompositionSeries(f);
      sf:=sf[Length(sf)-1];
      orb:=[sf];
      tra:=[IdentityMapping(f)];
      j:=1;
      while j<=Length(orb) do
        for k in auts do
          a:=Image(k,orb[j]);
          if not a in orb then
            Add(orb,a);
            Add(tra,tra[j]*k);
          fi;
        od;
        j:=j+1;
      od;

      # we know sf is simple
      SetIsNonabelianSimpleGroup(sf,true);
      IsNaturalAlternatingGroup(sf);
      if ValueOption("rewrite")=true then
        a:=IsomorphismFpGroupForRewriting(sf:noassert);
      else
        a:=IsomorphismFpGroup(sf:noassert);
      fi;
      ad:=List(GeneratorsOfGroup(Range(a)),i->PreImagesRepresentative(a,i));
      lad:=Length(ad);

      n:=Length(orb);
      if n=1 and ValueOption("rewrite")=true then
        fgens:=ad;
      else
        if ValueOption("rewrite")=true then
          Info(InfoPerformance,1,
          "Rewriting system preservation for direct product not yet written");
        fi;
        fg:=FreeGroup(Length(ad)*n,"@");
        free:=GeneratorsOfGroup(fg);
        rels:=[];
        fgens:=[];
        for j in [1..n] do
          Append(fgens,List(ad,x->Image(tra[j],x)));
          # translate relators
          for k in RelatorsOfFpGroup(Range(a)) do
            Add(rels,MappedWord(k,FreeGeneratorsOfFpGroup(Range(a)),
                                  free{[(j-1)*lad+1..j*lad]}));
          od;
          # commutators with older gens
          for k in [j+1..n] do
            for l in [1..Length(ad)] do
              for m in [1..Length(ad)] do
                Add(rels,Comm(free[(k-1)*lad+l],free[(j-1)*lad+m]));
              od;
            od;
          od;
        od;

        fp:=fg/rels;
        a:=GroupHomomorphismByImagesNC(f,fp,fgens,GeneratorsOfGroup(fp):noassert);
      fi;
      Append(gens,List(fgens,i->PreImagesRepresentative(hom,i)));

      # here we really want a composed homomorphism, to avoid extra work for
      # a new stabilizer chain
      if not IsOne(hom) then
        hom:=CompositionMapping2General(a,hom);
      else
        hom:=a;
      fi;
      homs[i-1]:=hom;
    fi;
    Add(idx,[start..Length(gens)]);
  od;

  f:=FreeGroup(Length(gens),str);
  free:=GeneratorsOfGroup(f);
  rels:=[];
  vals:=[];

  dec:=[];

  for i in [2..Length(ser)] do
    still:=i<Length(ser);
    lgens:=gens{idx[i-1]};
    ngens:=free{idx[i-1]}; # new generators on this level
    nrels:=[];
    nvals:=[];
    if ab[i-1] then
      pcgs:=homs[i-1];
      needgens:=Length(pcgs);
      p:=RelativeOrders(pcgs)[1];
      # define function in function to preserve local variables
      dodecomp:=function(ngens,pcgs,abpow)
                local l;
                  l:=Length(pcgs);
                  return function(elm)
                  local e,i,j,q;
                    e:=ShallowCopy(ExponentsOfPcElement(pcgs,elm));
                    for i in [1..Length(abpow)] do
                      for j in [1..l] do
                        # reduce entry so far
                        q:=QuotientRemainder(e[l*(i-1)+j],abpow[i]);
                        e[l*(i-1)+j]:=q[2];
                        e[l*i+j]:=q[1];
                      od;
                    od;

                    return LinearCombinationPcgs(ngens,e);
                  end;
                end;
      decomp:=dodecomp(ngens,pcgs,abpow[i-1]);
      for j in [1..Length(pcgs)] do
        Add(nrels,ngens[j]^p);
        if still then
          Add(nvals,pcgs[j]^p);
        fi;
        for k in [1..j-1] do
          Add(nrels,Comm(ngens[j],ngens[k]));
          if still then
            Add(nvals,Comm(pcgs[j],pcgs[k]));
          fi;
        od;
      od;

      # generator power relations
      if Length(abpow[i-1])>0 then
        for k in [1..Length(abpow[i-1])] do
          for j in [1..Length(pcgs)] do
            Add(nrels,ngens[Length(pcgs)*(k-1)+j]^abpow[i-1][k]
              /ngens[Length(pcgs)*k+j]);
            if still then
              Add(nvals,One(pcgs[1])); # new generator is just shorthand for
              # power, so no tail to consider
            fi;
          od;
        od;

      fi;

    else
      hom:=homs[i-1];
      hogens:=FreeGeneratorsOfFpGroup(Range(hom));
      needgens:=Length(hogens);
      dodecomp:=function(ngens,hogens,hom)
                  return elm->
                          MappedWord(UnderlyingElement(Image(hom,elm)),
                             hogens,ngens);
                end;
      decomp:=dodecomp(ngens,hogens,hom);
      for j in RelatorsOfFpGroup(Range(hom)) do
        a:=MappedWord(j,hogens,ngens);
        Add(nrels,a);
        if still then
          Add(nvals,MappedWord(j,hogens,lgens));
        fi;
      od;
    fi;
    Add(dec,decomp);
    # change relators by cofactors
    for j in [1..Length(rels)] do
      a:=decomp(vals[j]);
      rels[j]:=rels[j]/a;
      if still then
        vals[j]:=vals[j]/MappedWord(a,ngens,lgens);
      fi;
    od;
    # action relators
    for j in [1..idx[i-1][1]-1] do
      for k in [1..needgens] do
        a:=lgens[k]^gens[j];
        ad:=decomp(a);
        Add(rels,ngens[k]^free[j]/ad);
        if still then
          Add(vals,a/MappedWord(ad,ngens,lgens));
        fi;
      od;
    od;
    # new level relators
    Append(rels,nrels);
    Append(vals,nvals);
  od;
  Assert(1,ForAll(rels,i->MappedWord(i,GeneratorsOfGroup(f),gens) in N));

  fp:=f/rels;
  di:=rec(gens:=gens,fp:=fp,idx:=idx,dec:=dec,source:=g,homs:=homs,
     abpow:=abpow);
  if IsTrivial(N) then
    hom:=GroupHomomorphismByImagesNC(g,fp,gens,GeneratorsOfGroup(fp):noassert);
    SetIsBijective(hom,true);
  else
    hom:=GroupHomomorphismByImagesNC(g,fp,
          Concatenation(gens,GeneratorsOfGroup(N)),
          Concatenation(GeneratorsOfGroup(fp),
            List(GeneratorsOfGroup(N),i->One(fp))):noassert);
    SetIsSurjective(hom,true);
    SetKernelOfMultiplicativeGeneralMapping(hom,N);
  fi;

  hom!.decompinfo:=MakeImmutable(di);
  SetIsWordDecompHomomorphism(hom,true);
  ProcessEpimorphismToNewFpGroup(hom);
  return hom;
end);

#############################################################################
##
#M  IsomorphismFpGroupByChiefSeries( G, str )
##
InstallMethod( IsomorphismFpGroupByChiefSeries,"grp",true,
               [IsGroup,IsString], 0,
function(g,str)
  return IsomorphismFpGroupByChiefSeriesFactor(g,str,TrivialSubgroup(g));
end);

BindGlobal("DecompElmHomChiefSer",function(di,elm)
local f, w, a, i;
  f:=FreeGroupOfFpGroup(di.fp);
  w:=One(f);
  for i in di.dec do
    a:=i(elm);
    w:=a*w;
    elm:=elm/MappedWord(a,GeneratorsOfGroup(f),di.gens);
  od;
  return ElementOfFpGroup(ElementsFamily(FamilyObj(di.fp)),w);
end);

InstallMethod(ImagesRepresentative,"word decomp hom",FamSourceEqFamElm,
  [IsGroupGeneralMappingByImages and IsWordDecompHomomorphism,
  IsMultiplicativeElementWithInverse],0,
function(hom,elm)
  return DecompElmHomChiefSer(hom!.decompinfo,elm);
end);

InstallGlobalFunction(LiftFactorFpHom,
function(hom,G,N,mnsf)
local fpq, qgens, qreps, fpqg, rels, pcgs, p, f, qimg, idx, nimg, decomp,
      ngen, fp, hom2, di, source, dih, dec, i, j;
  fpq:=Range(hom);
  qgens:=GeneratorsOfGroup(fpq);
  qreps:=List(qgens,i->PreImagesRepresentative(hom,i));
  fpqg:=FreeGeneratorsOfFpGroup(fpq);
  rels:=[];
  if IsModuloPcgs(mnsf) then
    pcgs:=mnsf;
    p:=RelativeOrders(pcgs)[1];
    f:=FreeGroup(Length(fpqg)+Length(pcgs));
    qimg:=GeneratorsOfGroup(f){[1..Length(fpqg)]};
    idx:=[Length(fpqg)+1..Length(fpqg)+Length(pcgs)];
    nimg:=GeneratorsOfGroup(f){idx};
    decomp:=function(elm)
      return LinearCombinationPcgs(nimg,ExponentsOfPcElement(pcgs,elm));
    end;
    # n-relators
    for i in [1..Length(pcgs)] do
      Add(rels,nimg[i]^p);
      for j in [1..i-1] do
        Add(rels,Comm(nimg[i],nimg[j]));
      od;
    od;

  elif IsRecord(mnsf) then
    # mnsf is record with components:
    # pcgs: generator list for pcgs
    # p: prime
    # decomp: Exponents for element of pcgs
    pcgs:=mnsf.pcgs;
    p:=mnsf.prime;
    f:=FreeGroup(Length(fpqg)+Length(pcgs));
    qimg:=GeneratorsOfGroup(f){[1..Length(fpqg)]};
    idx:=[Length(fpqg)+1..Length(fpqg)+Length(pcgs)];
    nimg:=GeneratorsOfGroup(f){idx};
    decomp:=function(elm)
     local coeff;
      coeff:=mnsf.decomp(elm);
      if LinearCombinationPcgs(pcgs,coeff)<>elm then
        Error("decomperror");
      fi;
      return LinearCombinationPcgs(nimg,mnsf.decomp(elm));
    end;
    # n-relators
    for i in [1..Length(pcgs)] do
      Add(rels,nimg[i]^p);
      for j in [1..i-1] do
        Add(rels,Comm(nimg[i],nimg[j]));
      od;
    od;

  else
    # nonabelian
    p:=Range(mnsf);
    ngen:=FreeGeneratorsOfFpGroup(p);
    # This is not really a pcgs, but treated as layer generators the same
    # way, thus use the same variable name
    pcgs:=List(GeneratorsOfGroup(p),i->PreImagesRepresentative(mnsf,i));
    f:=FreeGroup(Length(fpqg)+Length(pcgs));
    qimg:=GeneratorsOfGroup(f){[1..Length(fpqg)]};
    idx:=[Length(fpqg)+1..Length(fpqg)+Length(pcgs)];
    nimg:=GeneratorsOfGroup(f){idx};

    decomp:=function(elm)
      return MappedWord(UnderlyingElement(Image(mnsf,elm)),ngen,nimg);
    end;

    for i in RelatorsOfFpGroup(p) do
      Add(rels,MappedWord(i,ngen,nimg));
    od;

  fi;

  # action on n
  for i in [1..Length(pcgs)] do
    for j in [1..Length(qgens)] do
      Add(rels,nimg[i]^qimg[j]/
          decomp(pcgs[i]^qreps[j]));
    od;
  od;

  # lift old relators with cofactors
  for i in RelatorsOfFpGroup(fpq) do
    Add(rels,MappedWord(i,fpqg,qimg)/decomp(MappedWord(i,fpqg,qreps)));
  od;
  fp:=f/rels;
  if HasGeneratorsOfGroup(N) then
    di:=GeneratorsOfGroup(N);
  else
    di:=[];
  fi;
  hom2:=GroupHomomorphismByImagesNC(G,fp,
         Concatenation(Concatenation(qreps,pcgs),di),
         Concatenation(GeneratorsOfGroup(fp),
         List(di,x->One(fp))):noassert);

  # build decompositioninfo
  di:=rec(gens:=Concatenation(qreps,pcgs),fp:=fp,source:=G);
  if IsBound(hom!.decompinfo) then
    dih:=hom!.decompinfo;
    if dih.source=G then
      di.idx:=Concatenation(dih.idx,[idx]);
      dec:=[];
      for i in dih.dec do
        Add(dec,elm->MappedWord(i(elm),fpqg,qimg));
      od;
      Add(dec,decomp);
      di.dec:=dec;
    fi;
  fi;

  if not IsBound(di.dec) then
    di.idx:=[[1..Length(fpqg)],idx];
    di.dec:=[elm->MappedWord(Image(hom,elm),fpqg,qimg),decomp];
  fi;

  hom2!.decompinfo:=MakeImmutable(di);
  SetIsWordDecompHomomorphism(hom2,true);

  SetIsSurjective(hom2,true);
  if N<>false then
    SetKernelOfMultiplicativeGeneralMapping(hom2,N);
  fi;

  return hom2;
end);

InstallGlobalFunction(ComplementFactorFpHom,
function(h,m,n,k,ggens,cgens)
local di, hom;
  if IsBound(h!.decompinfo) then
    di:=ShallowCopy(h!.decompinfo);
    if di.gens=ggens or cgens=ggens then
      di.gens:=cgens;
      di.source:=k;
      # this homomorphism is just to store decomposition information and is
      # not declared total, so an assertion test will fail
      hom:=GroupHomomorphismByImagesNC(k,di.fp,cgens,GeneratorsOfGroup(di.fp):noassert);
      hom!.decompinfo:=MakeImmutable(di);
      if HasIsSurjective(h) and IsSurjective(h)
        and HasKernelOfMultiplicativeGeneralMapping(h)
        and m=KernelOfMultiplicativeGeneralMapping(h) then
        SetIsSurjective(hom,true);
        SetKernelOfMultiplicativeGeneralMapping(hom,n);
      fi;

      SetIsWordDecompHomomorphism(hom,true);
      return hom;
    fi;
  fi;

  if ggens=MappingGeneratorsImages(h)[1] then
    # can we simply translate a map on generators?
    hom:=GroupHomomorphismByImagesNC(k,Range(h),
          Concatenation(GeneratorsOfGroup(n),cgens),
          Concatenation(List(GeneratorsOfGroup(n),i->One(Range(h))),
          MappingGeneratorsImages(h)[2]));
    return hom;
  fi;
  if IsBound(h!.decompinfo) then
    Error("do not know yet how to lift to complement");
  fi;
  hom:=GroupHomomorphismByImagesNC(k,Range(h),
          Concatenation(GeneratorsOfGroup(n),cgens),
          Concatenation(List(GeneratorsOfGroup(n),i->One(Range(h))),
            List(ggens,i->Image(h,i))));
  return hom;
end);

#############################################################################
##
#M  IsomorphismFpGroupByGeneratorsNC( G, gens, str )
##
InstallOtherMethod( IsomorphismFpGroupByGeneratorsNC, "for perm groups",
  IsFamFamX,[IsPermGroup, IsList, IsString], 0,
function( G, gens, str )
    local F, gensF, gensR, gensS, hom, info, iso, method, ngens, R, reg, rel,
          relators, S;

    # check for trivial cases
    ngens := Length( gens );
    if ngens = 0 then
        S := FreeGroup( 0 );
    elif ngens = 1 then
        F := FreeGroup( 1 );
        gensF := GeneratorsOfGroup( F );
        relators := [ gensF[1]^Size( G ) ];
        S := F/relators;
    # check options
    else
        F := FreeGroup( ngens, str );
        gensF := GeneratorsOfGroup( F );
        method := ValueOption( "method" );
        if not IsString( method ) and IsList( method ) and
            Length( method ) = 2 and method[1] = "regular" then
            if not IsInt( method[2] ) then
                Info( InfoFpGroup + InfoWarning, 1, "Warning: function ",
                    "IsomorphismFpGroupByGeneratorsNC encountered an" );
                Info( InfoFpGroup + InfoWarning, 1, "  non-integer bound ",
                    "for method \"regular\"; the option has been ignored" );
            elif Size( G ) <= method[2] then
                method := "regular";
            fi;
        fi;
        if method = "fast" then
            # use the old method
            hom := GroupHomomorphismByImagesNC( G, F, gens, gensF );
            relators := CoKernelGensPermHom( hom );
        elif method = "regular" and not IsRegular( G ) then
            # construct a regular permutation representation of G and then
            # apply the default method to it
            reg := RegularActionHomomorphism( G );
            R := Image( reg );
            gensR := List( gens, gen -> gen^reg );
            hom := GroupHomomorphismByImagesNC( R, F, gensR, gensF );
            relators := RelatorsPermGroupHom( hom, gensR );
        else
            # apply the default method to G
            hom := GroupHomomorphismByImagesNC( G, F, gens, gensF );
            relators := RelatorsPermGroupHom( hom, gens );
        fi;
        S := F/relators;
    fi;
    gensS := GeneratorsOfGroup( S );
    iso := GroupHomomorphismByImagesNC( G, S, gens, gensS );
    if HasSize(G) then
      SetSize(S,Size(G));
    fi;
    SetIsSurjective( iso, true );
    SetIsInjective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ));
    info := ValueOption( "infolevel" );
    if info <> 2 then
      info := 1;
    fi;
    if ngens = 0 then
      Info( InfoFpGroup, info, "the image fp group is trivial" );
    else
      Info( InfoFpGroup, info, "the image group has ", ngens, " gens and ",
        Length( relators ), " rels of total length ",
        Sum( List( relators, rel -> Length( rel ) ) ) );
    fi;
    ProcessEpimorphismToNewFpGroup(iso);
    return iso;
end );


#############################################################################
##
#M  IsomorphismFpGroupByGeneratorsNC( G, gens, str )
##
InstallMethod( IsomorphismFpGroupByGeneratorsNC, "via cokernel", IsFamFamX,
               [IsGroup, IsList, IsString], 0,
function( G, gens, str )
    local F, hom, rels, H, gensH, iso;
    F   := FreeGroup( Length(gens), str );
    hom := GroupGeneralMappingByImagesNC( G, F, gens, GeneratorsOfGroup(F) );
    rels := GeneratorsOfGroup( CoKernelOfMultiplicativeGeneralMapping( hom ) );
    H := F /rels;
    gensH := GeneratorsOfGroup( H );
    iso := GroupHomomorphismByImagesNC( G, H, gens, gensH );
    if HasSize(G) then
      SetSize(H,Size(G));
    fi;
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup(G) );
    ProcessEpimorphismToNewFpGroup(iso);
    return iso;
end );


InstallMethod( IsomorphismFpGroupByGeneratorsNC,
               "for trivial group",
               [ IsGroup, IsList and IsEmpty, IsString ],
function( G, emptygens, name )
    local hom;

    if not IsTrivial( G ) then
      Error( "<emptygens> does not generate <G>" );
    fi;
    hom:= GroupHomomorphismByImagesNC( G, FreeGroup( 0 ), [], [] );
    SetIsBijective( hom, true );
    return hom;
end );


#############################################################################
##
#M  IsomorphismFpGroupBySubnormalSeries( G, series, str )
##
InstallMethod( IsomorphismFpGroupBySubnormalSeries,
               "for groups",
               true,
               [IsPermGroup, IsList, IsString],
               0,
function( G, series, str )
    local l, H, gensH, iso, F, gensF, imgsF, relatorsF, free, n, k, N, M,
          hom, preiH, c, new, T, gensT, E, gensE, imgsE, relatorsE, rel,
          w, t, i, j,known;

    known:=ValueOption("knownfactor");
    # set up with smallest subgroup of series
    l      := Length( series );
    H := series[l-1];
    gensH := Set( GeneratorsOfGroup( H ) );
    gensH := Filtered( gensH, x -> x <> One(H) );
    iso   := IsomorphismFpGroupByGeneratorsNC( H, gensH, str );
    F     := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := MappingGeneratorsImages(iso)[1];
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free  := GroupHomomorphismByImagesNC( F, series[l-1], gensF, imgsF );
    n     := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        N := series[k];
        M := series[k+1];
        if known<>fail and M=KernelOfMultiplicativeGeneralMapping(known) then
          hom:=known;
        else
          # get composition factor
          hom   := NaturalHomomorphismByNormalSubgroupNC( N, M );
        fi;
        H     := Image( hom );

        gensH := GeneratorsOfGroup( H );
        gensH := Filtered( gensH, x -> x <> One(H) );
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );
        c     := Length( gensH );

        # compute presentation of H
        if IsFpGroup(H) then
          new:=IdentityMapping(H);
        else
          new := IsomorphismFpGroupByGeneratorsNC( H, gensH, "g" );
        fi;
        T   := Image( new );
        gensT := GeneratorsOfGroup( FreeGroupOfFpGroup( T ) );

        # create new free group
        E     := FreeGroup( n+c, str );
        gensE := GeneratorsOfGroup( E );
        imgsE := Concatenation( preiH, imgsF );
        relatorsE := [];

        # modify presentation of H
        for rel in RelatorsOfFpGroup( T ) do
            w := MappedWord( rel, gensT, gensE{[1..c]} );
            t := MappedWord( rel, gensT, imgsE{[1..c]} );
            if not t = One( G ) then
                t := PreImagesRepresentative( free, t );
                t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
            else
                t := One( E );
            fi;
            Add( relatorsE, w/t );
        od;

        # add operation of T on F
        for i in [1..c] do
            for j in [1..n] do
                w := Comm( gensE[c+j], gensE[i] );
                t := Comm( imgsE[c+j], imgsE[i] );
                if not t = One( G ) then
                    t := PreImagesRepresentative( free, t );
                    t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
                else
                    t := One( E );
                fi;
                Add( relatorsE, w/t );
            od;
        od;

        # append relators of F
        for rel in relatorsF do
            w := MappedWord( rel, gensF, gensE{[c+1..c+n]} );
            Add( relatorsE, w );
        od;

        # iterate
        F := E;
        gensF := gensE;
        imgsF := imgsE;
        relatorsF := relatorsE;
        free :=  GroupHomomorphismByImagesNC( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up
    F     := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    if HasSize(G) then
      SetSize(F,Size(G));
    fi;
    iso   := GroupHomomorphismByImagesNC( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    ProcessEpimorphismToNewFpGroup(iso);
    return iso;
end);

InstallOtherMethod( IsomorphismFpGroupBySubnormalSeries, "for groups", true,
               [IsPermGroup, IsList], 0,
function( G, series )
    return IsomorphismFpGroupBySubnormalSeries( G, series, "F" );
end);

InstallOtherMethod(IsomorphismFpGroupForRewriting,
  "generic, deal with large element orders", true,
  [IsGroup],0,
function(G)
local hom;
  IsSimpleGroup(G);
  hom:=IsomorphismFpGroup(G:abelianlimit:=10);
  return hom;
end);

InstallGlobalFunction(MakeFpGroupToMonoidHomType1,function(fp,m)
local fam,mfam,fpfam,mfpfam,hom;
  fam:=FamilyObj(UnderlyingElement(One(fp)));
  mfam:=FamilyObj(UnderlyingElement(One(m)));
  fpfam:=FamilyObj(One(fp));
  mfpfam:=FamilyObj(One(m));
  hom:=MagmaIsomorphismByFunctionsNC(fp,m,
        function(w)
          local l,i;
          l:=[];
          for i in LetterRepAssocWord(UnderlyingElement(w)) do
            if i>0 then Add(l,2*i-1);
            else Add(l,-2*i);fi;
          od;
          return ElementOfFpMonoid(mfpfam,AssocWordByLetterRep(mfam,l));
        end,
        function(w)
          local g,i,x;
          g:=[];
          for i in LetterRepAssocWord(UnderlyingElement(w)) do
            if IsOddInt(i) then x:=(i+1)/2;
            else x:=-i/2;fi;
            # word must be freely cancelled
            if Length(g)>0 and x=-g[Length(g)] then
              Remove(g);
            else Add(g,x); fi;
          od;
          return ElementOfFpGroup(fpfam,AssocWordByLetterRep(fam,g));
        end);

  # type 0 is inverses first
  hom!.type:=1;
  if not HasIsomorphismFpMonoid(fp) then
    SetIsomorphismFpMonoid(fp,hom);
  fi;
  return hom;
end);

# return isomorphism G-fp and fp->mon, such that presentation of monoid is
# confluent (wrt wreath order). Returns record with fphom,monhom,ordering
InstallMethod(ConfluentMonoidPresentationForGroup,"generic",
  [IsGroup and IsFinite],
function(G)
local iso,fp,dec,homs,mos,i,j,ffp,imo,m,k,gens,fm,mgens,rules,
      loff,off,monreps,left,right,fmgens,r,diff,monreal,nums,reduce,hom,dept,
      lode,lrules,rulet,addrule;
  IsSimpleGroup(G);
  if IsSymmetricGroup(G) then
    i:=SymmetricGroup(SymmetricDegree(G));
    iso:=CheapIsomSymAlt(G,i)*IsomorphismFpGroup(i);
    fp:=Range(iso);
    hom:=IsomorphismFpMonoid(fp);
    m:=Range(hom);
    fm:=FreeMonoidOfFpMonoid(m);
    k:=KnuthBendixRewritingSystem(m);
    MakeConfluent(k);
    rules:=Rules(k);
    dept:=fail;
  else
    iso:=IsomorphismFpGroupByChiefSeries(G:rewrite);

    fp:=Range(iso);
    gens:=GeneratorsOfGroup(fp);
    dec:=iso!.decompinfo;

    fmgens:=[];
    mgens:=[];
    for i in gens do
      Add(fmgens,i);
      Add(fmgens,i^-1);
      Add(mgens,String(i));
      Add(mgens,String(i^-1));
    od;
    nums:=List(fmgens,x->LetterRepAssocWord(UnderlyingElement(x))[1]);
    fm:=FreeMonoid(mgens);
    mgens:=GeneratorsOfMonoid(fm);

    rules:=[];
    lrules:=[];
    rulet:=List(mgens,x->[]); # rules involving a particular letter

    addrule:=function(rule)
    local i,p;
      Add(rules,rule);
      rule:=List(rule,LetterRepAssocWord);
      Add(lrules,rule);
      p:=Length(lrules);
      for i in Set(rule[1]) do
        AddSet(rulet[i],p);
      od;
    end;

    reduce:=function(w)
    local red,i,p,pool,wn;
      w:=LetterRepAssocWord(w);
      repeat
        i:=1;
        pool:=Union(rulet{Set(w)});
        red:=false;
        while i<=Length(pool) and red=false do
          p:=fail;
          if Length(w)>=Length(lrules[pool[i]][1]) then
            p:=PositionSublist(w,lrules[pool[i]][1]);
          fi;
          if p<>fail then
            wn:=Concatenation(w{[1..p-1]},lrules[pool[i]][2],
              w{[p+Length(lrules[pool[i]][1])..Length(w)]});
#if Length(wn)>Length(w) then Error("HOH");fi;
             w:=wn;
#            w:=Concatenation(w{[1..p-1]},lrules[pool[i]][2],
#              w{[p+Length(lrules[pool[i]][1])..Length(w)]});
            red:=true;
          else
            i:=i+1;
          fi;
        od;
      until red=false;
      return AssocWordByLetterRep(FamilyObj(One(fm)),w);
    end;


    homs:=ShallowCopy(dec.homs);
    mos:=[];
    off:=Length(mgens);
    dept:=[];
    lode:=[];
    # go up so we may reduce tails
    for i in [Length(homs),Length(homs)-1..1] do
      Add(dept,off);
      if IsGeneralPcgs(homs[i]) then
        if Length(dec.abpow[i])>0 then
          ffp:=FreeAbelianGroup(Length(homs[i])*(Length(dec.abpow[i])+1));
          # relations: order
          m:=GeneratorsOfGroup(ffp);
          r:=List(m,x->x^RelativeOrders(homs[i])[1]);
          # power dependence
          for j in [1..Length(dec.abpow[i])] do
            for k in [1..Length(homs[i])] do
              Add(r,m[Length(homs[i])*(j-1)+k]^dec.abpow[i][j]
                /m[Length(homs[i])*j+k]);
            od;
          od;
          ffp:=ffp/r;

        else
          ffp:=AbelianGroup(IsFpGroup,RelativeOrders(homs[i]));
        fi;
      else
        ffp:=Range(homs[i]);
      fi;

      imo:=IsomorphismFpMonoid(ffp);
      Add(mos,imo);
      m:=Range(imo);
      loff:=off-Length(GeneratorsOfMonoid(m));
      monreps:=fmgens{[loff+1..off]};
      monreal:=mgens{[loff+1..off]};
      if IsBound(m!.rewritingSystem) then
        k:=m!.rewritingSystem;
      else
        k:=KnuthBendixRewritingSystem(m);
      fi;
      if HasLevelsOfGenerators(k!.ordering) then
        Add(lode,LevelsOfGenerators(k!.ordering));
      else
        Add(lode,fail);
      fi;
      MakeConfluent(k);
      # convert rules
      for r in Rules(k) do
        left:=MappedWord(r[1],FreeGeneratorsOfFpMonoid(m),monreps);
        right:=MappedWord(r[2],FreeGeneratorsOfFpMonoid(m),monreps);
        diff:=LeftQuotient(PreImagesRepresentative(iso,right),
                PreImagesRepresentative(iso,left));
        diff:=ImagesRepresentative(iso,diff);

        left:=MappedWord(r[1],FreeGeneratorsOfFpMonoid(m),monreal);
        right:=MappedWord(r[2],FreeGeneratorsOfFpMonoid(m),monreal);
        if not IsOne(diff) then
          right:=right*Product(List(LetterRepAssocWord(UnderlyingElement(diff)),
            x->mgens[Position(nums,x)]));
        fi;
        right:=reduce(right); # monoid word might change
        addrule([left,right]);
      od;
      for j in [loff+1..off] do
        # if the generator gets reduced away, won't need to use it
        if reduce(mgens[j])=mgens[j] then
          for k in [off+1..Length(mgens)] do
            if reduce(mgens[k])=mgens[k] then
              right:=fmgens[j]^-1*fmgens[k]*fmgens[j];
              #collect
              right:=ImagesRepresentative(iso,PreImagesRepresentative(iso,right));
              right:=Product(List(LetterRepAssocWord(UnderlyingElement(right)),
                x->mgens[Position(nums,x)]));
              right:=reduce(mgens[j]*right);
              #Print("Did rule ",mgens[k],"*",mgens[j],"->",right,"\n");
              addrule([mgens[k]*mgens[j],right]);
            fi;
          od;
        fi;
      od;
      #if i<Length(homs) then Error("ZU");fi;
      off:=loff;
    od;
    Add(dept,off);
    # calculate levels for ordering
    dept:=dept+1;
    dept:=List([1..Length(mgens)],
      x->PositionProperty(dept,y->x>=y)-1);

    # are there local levels to keep? First make them fractional additions
    off:=10^(1+LogInt(Length(dept),10)); # cent level for local depths
    for i in [1..Maximum(dept)] do
      if lode[i]<>fail then
        diff:=Filtered([1..Length(dept)],x->dept[x]=i);
        dept{diff}:=dept{diff}+lode[i]/off;
      fi;
    od;
    if ForAny(dept,x->not IsInt(x)) then
      # reintegralize
      diff:=Set(dept);
      dept:=List(dept,x->Position(diff,x));
    fi;

#    if AssertionLevel()>1 and ForAny(rules,x->x[2]<>reduce(x[2])) then
#      Error("irreduced right");
#    fi;

    # inverses are true inverses, also for extension
    for i in [1..Length(gens)] do
      left:=mgens[2*i-1]*mgens[2*i];
      left:=reduce(left);
      if left<>One(fm) then addrule([left,One(fm)]); fi;
      left:=mgens[2*i]*mgens[2*i-1];
      left:=reduce(left);
      if left<>One(fm) then addrule([left,One(fm)]); fi;
    od;
  fi;

  # finally create
  m:=FactorFreeMonoidByRelations(fm,rules);
  hom:=MakeFpGroupToMonoidHomType1(fp,m);

  j:=rec(fphom:=iso,monhom:=hom);
  if dept=fail then
    j.ordering:=k!.ordering;
  else
    j.ordering:=WreathProductOrdering(fm,dept);
  fi;
  k:=KnuthBendixRewritingSystem(FamilyObj(One(m)),j.ordering:isconfluent);
  MakeConfluent(k); # will store in monoid as reducedConfluent
  return j;
end);

# special method for pc groups, basically just writing down the pc
# presentation
InstallMethod(ConfluentMonoidPresentationForGroup,"pc",
  [IsGroup and IsFinite and IsPcGroup],
function(G)
local pcgs,iso,fp,i,j,gens,numi,ord,fm,fam,mword,k,r,addrule,a,e,m;
  pcgs:=Pcgs(G);
  iso:=IsomorphismFpGroup(G);
  fp:=Range(iso);
  if List(GeneratorsOfGroup(fp),x->PreImagesRepresentative(iso,x))<>pcgs then
    Error("pcgs");
  fi;
  gens:=[];
  numi:=[];
  ord:=[];
  for i in [1..Length(pcgs)] do
    Add(gens,String(fp.(i)));
    Add(gens,String(fp.(i)^-1));
    Add(numi,i);
    Add(numi,-i);
    Append(ord,[i,i]);
  od;
  fm:=FreeMonoid(gens);
  fam:=FamilyObj(One(fm));
  mword:=w->AssocWordByLetterRep(fam,
    List(LetterRepAssocWord(UnderlyingElement(w)),x->Position(numi,x)));
  ord:=WreathProductOrdering(fm,Reversed(ord));
  k:=CreateKnuthBendixRewritingSystem(FamilyObj(One(fm/[])),ord);
  if AssertionLevel()<=2 then
    # assertion level <=2 so the auto tests will never trigger it
    Unbind(k!.pairs2check);
  fi;
  addrule:=function(rul)
    #Print("Add:",rul,"\n");
    AddRuleReduced(k,List(rul,LetterRepAssocWord));
    #Print(Rules(k),"\n");
  end;

  for i in [Length(pcgs),Length(pcgs)-1..1] do
    if RelativeOrders(pcgs)[i]>2 then
      addrule([mword(fp.(i))*mword(fp.(i)^-1),One(fm)]);
      addrule([mword(fp.(i)^-1)*mword(fp.(i)),One(fm)]);
    fi;
    for j in [Length(pcgs),Length(pcgs)-1..i+1] do
      for e in [[1,1],[1,-1],[-1,1],[-1,-1]] do
        if (RelativeOrders(pcgs)[j]>2 or e[1]=1) and
          (RelativeOrders(pcgs)[i]>2 or e[2]=1) then
          a:=(pcgs[j]^e[1])^(pcgs[i]^e[2]);
          addrule([mword(fp.(j)^e[1]*fp.(i)^e[2]),mword(fp.(i)^e[2])*mword(a)]);
        fi;
      od;
    od;
    r:=RelativeOrders(pcgs)[i];
    if r=2 then
      a:=ImagesRepresentative(iso,pcgs[i]^2);
      addrule([mword(fp.(i)^2),mword(a)]);
      a:=ImagesRepresentative(iso,pcgs[i]^-2);
      addrule([mword(fp.(i)^-1),mword(fp.(i))*mword(a)]);
    else
      a:=ImagesRepresentative(iso,pcgs[i]^r);
      addrule([mword(fp.(i)^((r+1)/2)),mword(fp.(i)^(-(r-1)/2))*mword(a)]);
      a:=ImagesRepresentative(iso,pcgs[i]^-r);
      addrule([mword(fp.(i)^(-(r+1)/2)),mword(fp.(i)^((r-1)/2))*mword(a)]);
    fi;
    if IsBound(k!.pairs2check) then
      e:=StructuralCopy(Rules(k));
      MakeConfluent(k);
      Assert(3,Set(Rules(k))=Set(e));
    fi;
  od;
  SetIsConfluent(k,true);
  SetIsReduced(k,true);
  m:=fm/Rules(k);
  a:=MakeFpGroupToMonoidHomType1(fp,m);
  SetReducedConfluentRewritingSystem(m,k);
  j:=rec(fphom:=iso,monhom:=a,ordering:=ord);
  return j;
end);


# ser is a string indicating the series (A, B, C, D, E, F), n is a number. If argument `false` is added, only braid
# relations
BindGlobal("WeylGroupFp",function(ser,n,docox...)
local f,rels,i,j,gens,coxrel;
  coxrel:=function(a,b,n)
  local m,f,g;
    if n=2 then Add(rels,Comm(a,b));
    else
      if docox then
        # coxeter: no negative exponents
        Add(rels,(a*b)^n);
      else
        # braid: bababa...  = ababab...
        m:=QuoInt(n+1,2);
        f:=Subword((b*a)^m,1,n);
        g:=Subword((a*b)^m,1,n);
        Add(rels,f/g);
      fi;
    fi;
  end;
  f:=FreeGroup(List([1..n],x->Concatenation("s",String(x))));
  gens:=GeneratorsOfGroup(f);
  if Length(docox)=0 then
    docox:=true;
  else
    docox:=docox[1]=true;
  fi;
  if docox then
    rels:=List(gens,x->x^2);
  else
    rels:=[];
  fi;
  if ser="A" then
    for i in [1..n] do
      for j in [1..i-1] do
        if i-j>1 then
          coxrel(gens[j],gens[i],2);
        else
          coxrel(gens[j],gens[i],3);
        fi;
      od;
    od;
  elif ser="B" or ser="C" then
    for i in [1..n] do
      for j in [1..i-1] do
        if i-j>1 then
          coxrel(gens[j],gens[i],2);
        elif j=1 then
          coxrel(gens[j],gens[i],4);
        else
          coxrel(gens[j],gens[i],3);
        fi;
      od;
    od;
  elif ser="D" and n>=4 then
    coxrel(gens[1],gens[2],2);
    coxrel(gens[1],gens[3],3);
    coxrel(gens[2],gens[3],3);
    for i in [4..n] do
      for j in [1..i-1] do
        if i-j>1 then
          coxrel(gens[j],gens[i],2);
        else
          coxrel(gens[j],gens[i],3);
        fi;
      od;
    od;
  elif ser="E" then
    #    1-2-3-5-6-7-8
    #        |
    #        4
    coxrel(gens[1],gens[2],3);
    coxrel(gens[2],gens[3],3);
    coxrel(gens[3],gens[4],3);
    coxrel(gens[3],gens[5],3);
    coxrel(gens[5],gens[6],3);

    coxrel(gens[1],gens[3],2);
    coxrel(gens[1],gens[4],2);
    coxrel(gens[2],gens[4],2);
    coxrel(gens[1],gens[5],2);
    coxrel(gens[2],gens[5],2);
    coxrel(gens[4],gens[5],2);
    coxrel(gens[1],gens[6],2);
    coxrel(gens[2],gens[6],2);
    coxrel(gens[3],gens[6],2);
    coxrel(gens[4],gens[6],2);
    if n>=7 then
      coxrel(gens[6],gens[7],3);
      for i in [1..5] do
        coxrel(gens[i],gens[7],2);
      od;
    fi;
    if n=8 then
      coxrel(gens[7],gens[8],3);
      for i in [1..6] do
        coxrel(gens[i],gens[8],2);
      od;
    elif n>8 then
      Error("E>8 does not exist");
    fi;
  elif ser="F" and n=4 then
    coxrel(gens[1],gens[2],3);
    coxrel(gens[2],gens[3],4);
    coxrel(gens[3],gens[4],3);

    coxrel(gens[1],gens[3],2);
    coxrel(gens[1],gens[4],2);
    coxrel(gens[2],gens[4],2);
  elif ser="G" and n=2 then
    coxrel(gens[1],gens[2],6);
  else
    Error("series ",ser," not yet done");
  fi;
  return f/rels;
end);

BindGlobal("IsomorphismFpGroupForWeyl",
function(G)
local iso,n,fn,sz,bigcount,tryweyl;

  tryweyl:=function(ser,n)
  local H,isp,P,iso;
    H:=WeylGroupFp(ser,n);
    isp:=IsomorphismPermGroup(H);
    P:=Image(isp,H);
    iso:=IsomorphismGroups(G,P);
    if iso<>fail then
      P:=List(GeneratorsOfGroup(H),
        x->PreImagesRepresentative(iso,ImagesRepresentative(isp,x)));
      iso:=GroupHomomorphismByImagesNC(G,H,P,GeneratorsOfGroup(H));
    fi;
    return iso;
  end;

  # try to identify Weyl series
  n:=0;
  fn:=1;
  repeat
    n:=n+1;
    fn:=fn*n;
    bigcount:=0;
    sz:=fn*(n+1);
    if Size(G)<sz then bigcount:=bigcount+1;
    elif Size(G)=sz and IsSymmetricGroup(G) then
      # try Sn
      if HasIsomorphismFpGroup(G) then
        # We can access the special `symmetric' presentation only as method
        # for `IsomorphismFp` for the symmetric group. But if such an
        # isomorphism is already stored, it might be a different one.
        # In this case recreate a new group that will then get it (because
        # it is symmetric).
        G:=Group(GeneratorsOfGroup(G));
        SetSize(G,sz);
        SetIsSymmetricGroup(G,true);
      fi;
      return IsomorphismFpGroup(G); # uses symmetric method
    fi;
    sz:=2^n*fn;
    if Size(G)<sz then bigcount:=bigcount+1;
    elif Size(G)=sz then
      iso:=tryweyl("B",n);
      if iso<>fail then return iso;fi;
    fi;
    sz:=2^(n-1)*fn;
    if Size(G)<sz then bigcount:=bigcount+1;
    elif n>=4 and Size(G)=sz then
      iso:=tryweyl("D",n);
      if iso<>fail then return iso;fi;
    fi;
  until bigcount=3;

  if Size(G)=12 then
    iso:=tryweyl("G",2);
    if iso<>fail then return iso;fi;
  elif Size(G)=1152 then
    iso:=tryweyl("F",4);
    if iso<>fail then return iso;fi;
  elif Size(G)=51840 then
    iso:=tryweyl("E",6);
    if iso<>fail then return iso;fi;
  elif Size(G)=72*Factorial(8) then
    iso:=tryweyl("E",7);
    if iso<>fail then return iso;fi;
  elif Size(G)=192*Factorial(10) then
    iso:=tryweyl("E",8);
    if iso<>fail then return iso;fi;
  fi;

  return fail;
end);

BindGlobal("CanoDC",function(chain,sub,orep)
local i,j,u,o,r,stb,m,g,img,p,rep,b,expand,dict,act,gens,gf,writestab;

  expand:=function(n)
  local e;
    e:=r[n][2];
    while r[n][1]<>0 do
      n:=r[n][1];
      e:=r[n][2]*e;
    od;
    return e;
  end;

  writestab:=function()
  local p,k;
    p:=stb;
    if Length(p)>3 then
      # permute randomly
      p:=p{FLOYDS_ALGORITHM(
        GlobalMersenneTwister,Length(stb),false)};
    fi;
    stb:=SubgroupNC(sub,p{[1..Minimum(3,Length(p))]});
    for k in p{[4..Length(p)]} do
      stb:=ClosureSubgroupNC(stb,k);
    od;
  end;

  b:=One(sub);
  rep:=orep;
  for i in [Length(chain)-1,Length(chain)-2..1] do
    u:=chain[i];
    act:=function(e,g) return CanonicalRightCosetElement(u,e*g);end;

    # orbit/rep stabilizer
    o:=[CanonicalRightCosetElement(u,rep)];
    dict:=NewDictionary(rep,true,chain[Length(chain)]);
    AddDictionary(dict,o[1],1);
    r:=[[0,One(sub)]];
    stb:=[];
    #stb:=TrivialSubgroup(sub);
    j:=1;
    m:=1;
    gens:=GeneratorsOfGroup(sub);
    gf:=true;
    while j<=Length(o) and Length(o)*Size(stb)<Size(sub) do
      if gf and Length(o)>40 then
        gf:=false;
        gens:=SmallGeneratingSet(sub);
      fi;
      for g in gens do
        img:=act(o[j],g);
        #p:=Position(o,img);
        p:=LookupDictionary(dict,img);
        if p=fail then
          Add(o,img);
          AddDictionary(dict,img,Length(o));
          Add(r,[j,g]);
          #Add(r,[0,r[j][2]*g]);
          if img<o[m] then m:=Length(o); fi;
        elif IsList(stb) then
          AddSet(stb,expand(j)*g/expand(p));
          if Length(o)>20 then
            writestab();
          fi;
        else
          stb:=ClosureSubgroupNC(stb,expand(j)*g/expand(p));
        fi;
      od;

      j:=j+1;
    od;

    b:=b*expand(m);
    j:=expand(m);
    rep:=rep*j;

    if i>1 then
      if IsList(stb) then writestab();fi;
      sub:=stb^j;
    fi;

  od;
  return [o[m],b];
end);


# rewriting systems for simple groups based on BN pairs, following
# (Schmidt,  Finite groups have short rewriting systems. Computational group
# theory and the theory of groups, II, 185–200, Contemp. Math., 511.)
BindGlobal("SplitBNRewritingPresentation",function(group,borel,weyl,newstyle)
local isob,isos,iso,gens,a,rels,l,i,j,bgens,cb,cs,b,f,k,w,monoid,
  lev,ord,monb,mons,gp,trawo,trawou,hom,tst,dc,dcreps,act,decomp,ranb,ranw,
  nofob,nofow,reduce,pcgs,can,pri,stb,addrule,invmap,jj,wo,pciso,
  borelelm,borelran,borelreduce,bpairs,brws,specialborelreduce,
  rdag,mdag,wdag,dcnum,dcfix,
  rt,dcnums,rti,maketzf,mytzf,csetperm,pc,bpcgs,noncomm,noncelm,
  wgens,weylword,borelword,coxrels,ha,directerr,bhom,ac,relab,ostab,dcr,single;

  specialborelreduce:=false;
  if Size(ClosureGroup(borel,weyl))<Size(group) then return fail;fi;
  ha:=Intersection(borel,weyl);
  dc:=DoubleCosets(group,borel,borel);

  if newstyle then

    # use exactly the generators of borel
    bpcgs:=PcgsByPcSequence(FamilyObj(One(borel)),GeneratorsOfGroup(borel));
    pc:=PcGroupWithPcgs(bpcgs);
    pciso:=GroupHomomorphismByImages(borel,pc,bpcgs,FamilyPcgs(pc));

    cb:=ConfluentMonoidPresentationForGroup(pc);
  else
    if Size(Intersection(borel,weyl))>1 then
      # can we fix this?
      # assume weyl is not too large
      cs:=Concatenation(List(ConjugacyClassesSubgroups(weyl),AsList));;
      SortBy(cs,x->-Size(x));
      l:=false;
      i:=1;
      while l=false and i<=Length(cs) do
        if Size(Intersection(borel,cs[i]))=1 and Size(cs[i])>=Length(dc)
          and Size(ClosureGroup(borel,cs[i]))=Size(group) and
          Length(Set(Elements(cs[i]),
            x->PositionProperty(dc,y->x in y)))=Length(dc) then
          Info(InfoFpGroup,1,"replaced weyl candidate with better subgroup\n");
          l:=cs[i];
        fi;
        i:=i+1;
      od;
      if l<>false then
        weyl:=l;
      fi;
    fi;

    # Use SpecialPcgs for borel

    pciso:=IsomorphismSpecialPcGroup(borel);
    cb:=ConfluentMonoidPresentationForGroup(Range(pciso));
  fi;

  brws:=ReducedConfluentRewritingSystem(Range(cb.monhom));

  # force going to pc group, as this will give better ordering
  isob:=GroupHomomorphismByFunction(borel,Range(cb.fphom),
    x->ImagesRepresentative(cb.fphom,ImagesRepresentative(pciso,x)),
    x->PreImagesRepresentative(pciso,PreImagesRepresentative(cb.fphom,x)));

  b:=Range(isob);

  wgens:=GeneratorsOfGroup(weyl);

  bgens:=List(GeneratorsOfGroup(b),x->PreImagesRepresentative(isob,x));
  if newstyle and bgens<>GeneratorsOfGroup(borel) then Error("gens");fi;

  bpairs:=Concatenation(List(bgens,x->[x,x^-1]));
  monoid:=Range(cb.monhom);

  borelran:=[]; # initially no special borelran

  # borel-only reduction to deal with large primes
  borelreduce:=function(w)
  local i,j,need;
    i:=1;
    repeat
      # find borel range
      while i<Length(w) and not (w[i] in borelran) do
        i:=i+1;
      od;
      if i<Length(w) and w[i+1] in borelran then
        j:=i;
        need:=false;
        while j+1<=Length(w) and w[j+1] in borelran do
          j:=j+1;
          if need=false and QuoInt(w[j-1]+1,2)=QuoInt(w[j]+1,2) # element and inverse
            or w[j]<w[j-1] # wrong order
            then need:=true;
          fi;
        od;
        if need then
          need:=w{[i..j]};
          need:=Product(bpairs{need});
          need:=ImagesRepresentative(cb.monhom,ImagesRepresentative(isob,need));
          need:=UnderlyingElement(need);
          if Length(need)>0 then
            need:=ReducedForm(brws,need);
          fi;
          w:=Concatenation(w{[1..i-1]},LetterRepAssocWord(need),w{[j+1..Length(w)]});
          i:=i+Length(need);
        else
          i:=j+1;
        fi;
      else
        if i<Length(w) then i:=i+2;fi;
      fi;
    until i>=Length(w);
    return w;
  end;

  maketzf:=function(rules)
  local tzf,tzrules,p,i;
    tzrules:=List(rules,x->List(x,LetterRepAssocWord));
    tzf:=[];
    for i in tzrules do
      p:=i[1][1];
      if not IsBound(tzf[p]) then
        tzf[p]:=[i];
      else
        Add(tzf[p],i);
      fi;
    od;
    return tzf;
  end;

  reduce:=function(wo,rules,dag,tzf)
  local w,fam,red,i,j,p,ww,sp,has;
    #Print("Reduce ",wo,"\n");
    fam:=FamilyObj(wo);
    # is it in big monoid?

    w:=LetterRepAssocWord(wo);
    sp:=specialborelreduce and fam=FamilyObj(One(f)) and ForAny(w,x->x in borelran);

    # collect from the left
    if sp then
      w:=borelreduce(w);
    fi;

    if dag<>fail then
      repeat
      has:=false;
        p:=1;
        while p<=Length(w) do
          i:=RuleAtPosKBDAG(dag,w,p);
          if i<>fail then
            has:=true;
            # replace
            w:=Concatenation(w{[1..p-1]},LetterRepAssocWord(rules[i][2]),
              w{[p+Length(rules[i][1])..Length(w)]});
            if sp then
              w:=borelreduce(w);
            fi;
            p:=0;
          fi;
          p:=p+1;
        od;
      until has=false;

    else
      p:=Length(w);
      while p>0 do
        if IsBound(tzf[w[p]]) then

          red:=tzf[w[p]];
          i:=1;
          while i<=Length(red) do
            if p+Length(red[i][1])-1<=Length(w) then
              j:=2;
              while j<=Length(red[i][1]) and w[p+j-1]=red[i][1][j] do
                j:=j+1;
              od;
              if j>Length(red[i][1]) then
                # replace
                w:=Concatenation(w{[1..p-1]},red[i][2],
                  w{[p+Length(red[i][1])..Length(w)]});
                #Print("intermed ",red[i],":",AssocWordByLetterRep(fam,w),"\n");
                p:=Minimum(p+Length(red[i][2]),Length(w));
                if sp then
                  ww:=borelreduce(w);
                  if ww<>w then
                    w:=ww;
                    p:=Length(w);
                  fi;

                fi;

                i:=Length(red);
              fi;
            fi;
            i:=i+1;
          od;

        fi;
        p:=p-1;
      od;
    fi;

    w:=AssocWordByLetterRep(fam,w);
    #Print("To ",w,"\n");
    #if sp and w<>oreduce(wo,rules) then Error("baeh!");fi;
    return w;
  end;

  nofob:=function(x)
    x:=UnderlyingElement(ImagesRepresentative(cb.monhom,x));
    x:=reduce(x,RelationsOfFpMonoid(monoid),mdag,fail);
    x:=ElementOfFpMonoid(FamilyObj(One(monoid)),x);
    return PreImagesRepresentative(cb.monhom,x);
  end;

  mdag:=EmptyKBDAG(Union(List(FreeGeneratorsOfFpMonoid(monoid),
    LetterRepAssocWord)));
  a:=RelationsOfFpMonoid(monoid);
  for i in [1..Length(a)] do
    AddRuleKBDAG(mdag,LetterRepAssocWord(a[i][1]),i);
  od;

  if newstyle then

    if IsBound(weyl!.epiweyl) then
      cs:=GroupHomomorphismByImages(weyl,weyl!.epiweyl,
        GeneratorsOfGroup(weyl),GeneratorsOfGroup(weyl!.epiweyl));
      if Size(ha)>1 then
        w:=CompositionSeriesThrough(weyl,[ha]);
        w:=Concatenation([weyl],Filtered(w,x->IsSubset(ha,x)));
        cs:=IsomorphismFpGroupBySubnormalSeries(weyl,w,"w":knownfactor:=cs);
      fi;
    else
      cs:=IsomorphismFpGroupByGenerators(weyl,wgens);
    fi;
    w:=IsomorphismFpMonoid(Range(cs));
    k:=KnuthBendixRewritingSystem(Range(w));
    MakeConfluent(k);
    k:=Rules(k);
    w:=FreeMonoidOfFpMonoid(Range(w))/k;
    w:=MakeFpGroupToMonoidHomType1(Range(cs),w);

    cs:=rec(fphom:=cs,monhom:=w);
  else
    cs:=IsomorphismFpGroupForWeyl(weyl);
    if cs<>fail then
      cs:=rec(fphom:=cs,monhom:=IsomorphismFpMonoid(Range(cs)));
    else
      cs:=ConfluentMonoidPresentationForGroup(weyl);
    fi;

  fi;

  nofow:=function(x)
    x:=UnderlyingElement(ImagesRepresentative(cs.monhom,x));
    x:=reduce(x,RelationsOfFpMonoid(Range(cs.monhom)),wdag,fail);
    x:=ElementOfFpMonoid(FamilyObj(One(Range(cs.monhom))),x);
    return PreImagesRepresentative(cs.monhom,x);
  end;

  wdag:=EmptyKBDAG(Union(List(FreeGeneratorsOfFpMonoid(Range(cs.monhom)),
    LetterRepAssocWord)));
  a:=RelationsOfFpMonoid(Range(cs.monhom));
  for i in [1..Length(a)] do
    AddRuleKBDAG(wdag,LetterRepAssocWord(a[i][1]),i);
  od;

  isos:=cs.fphom;
  w:=Range(isos);
  a:=MappingGeneratorsImages(isos)[1];

  gens:=bgens;
  l:=Length(gens);
  gens:=Concatenation(gens,a);

  ac:=AscendingChain(group,borel);

  Info(InfoFpGroup,1,List(ac,Size));

  single:=IndexNC(group,borel)<10^7;

  while Length(ac)>2 and
    IndexNC(ac[Length(ac)],ac[Length(ac)-2])<10^7 do
    ac:=ac{Difference([1..Length(ac)],[Length(ac)-1])};
  od;

  i:=Length(ac)-1;
  while i>2 do
    if IndexNC(ac[i],ac[i-2])<=100 then
      ac:=ac{Difference([1..Length(ac)],[i-1])};
    fi;
    i:=i-1;
  od;

  # perm action of group on top, small gen set
  rt:=RightTransversal(group,ac[Length(ac)-1]);
  a:=Group(SmallGeneratingSet(group)); # so nothing stores
  csetperm:=List(GeneratorsOfGroup(a),x->Permutation(x,rt,OnRight));
  iso:=EpimorphismFromFreeGroup(a);
  csetperm:=List(bgens,x->MappedWord(PreImagesRepresentative(iso,x),
    MappingGeneratorsImages(iso)[1],csetperm));
  act:=Group(csetperm,());

  bhom:=GroupHomomorphismByImagesNC(borel,act,bgens,csetperm);
  #Assert(0,bhom<>fail);

  # reps for each coset
  dcnums:=OrbitsDomain(act,[1..Length(rt)]);
  dcnums:=List(dcnums,x->Immutable(Set(x)));


  # ensure that "weyl group" represents double cosets (but allow double
  # coverage)

  rti:=List(dcnums,ReturnFalse); # which double are hit already
  for i in weyl do
    a:=PositionCanonical(rt,i);
    j:=PositionProperty(dcnums,x->a in x);
    if rti[j]=false then
      rti[j]:=true;
      if dcnums[j][1]<>a then
        dcnums[j]:=Concatenation([a],Difference(dcnums[j],[a]));
      fi;
    fi;
  od;

  # index the orbit nr.
  rti:=[];
  ostab:=[];
  for i in [1..Length(dcnums)] do
    for j in dcnums[i] do
      rti[j]:=i;
    od;
    a:=Stabilizer(borel,dcnums[i][1],bgens,csetperm,OnPoints);
    a:=SubgroupNC(borel,SmallGeneratingSet(a));
    ostab[i]:=a;
  od;
  ac:=ac{[1..Length(ac)-1]}; # remove top step
  Info(InfoFpGroup,1,List(ac,Size));

  Assert(0,single=(Length(ac)=1));

  dcr:=function(elm)
  local a,b,rep;
    a:=PositionCanonical(rt,elm);
    b:=rti[a];
    rep:=RepresentativeAction(Image(bhom),a,dcnums[b][1]);
    rep:=PreImagesRepresentative(bhom,rep);
    if single then
      a:=[CanonicalRightCosetElement(ac[1],rt[dcnums[b][1]]),rep];
    else
      a:=CanoDC(ac,ostab[b],elm*rep);
      a:=[a[1],rep*a[2]];
    fi;
    if relab then
      b:=Position(dcnum,a[1]);
      a:=[dcreps[b],a[2]*dcfix[b]];
    fi;
    return a;
  end;

  # the calculated reps
  relab:=false;
  dcfix:=List(dc,x->One(group));
  dcnum:=fail;
  dcnum:=List(dc,x->dcr(Representative(x))[1]);

  # ensure the Weyl group is the reps
  dcreps:=[];
  for i in AsList(weyl) do

    j:=dcr(i);
    a:=Position(dcnum,j[1]);
    if not IsBound(dcreps[a]) then
      dcreps[a]:=i;
      dcfix[a]:=j[2]^-1; # mapping calculated to weyl elt
    fi;
  od;

  if not ForAll([1..Length(dc)],x->IsBound(dcreps[x])) then
    Error("weyl does not cover dc");
  fi;

  relab:=true;

  decomp:=function(elm)
  local rep,a;
    if elm in borel then return [elm,One(borel),One(borel)];fi;

    a:=dcr(elm);
    rep:=a[2];

    rep:=[elm*rep/a[1],a[1],rep^-1];
    Assert(0,rep[1] in borel);
    return rep;
  end;

  iso:=IsomorphismFpGroupByGenerators(group,gens);

#  else # alternative, old, code
#    # identify double cosets
#    rt:=RightTransversal(group,borel);
#
#    # perm action of group, small gen set
#    a:=Group(SmallGeneratingSet(group)); # so nothing stores
#    csetperm:=List(GeneratorsOfGroup(a),x->Permutation(x,rt,OnRight));
#    iso:=EpimorphismFromFreeGroup(a);
#    csetperm:=List(bgens,x->MappedWord(PreImagesRepresentative(iso,x),MappingGeneratorsImages(iso)[1],csetperm));
#    act:=Group(csetperm,());
#
#    bhom:=GroupHomomorphismByImagesNC(borel,act,bgens,csetperm);
#    #Assert(0,bhom<>fail);
#
#    dcnums:=OrbitsDomain(act,[1..Length(rt)]);
#    dcnums:=List(dcnums,x->Immutable(Set(x)));
#    rti:=[];
#    for i in [1..Length(dc)] do
#      a:=PositionCanonical(rt,Representative(dc[i]));
#      a:=PositionProperty(dcnums,x->a in x);
#      for j in dcnums[a] do
#        rti[j]:=i;
#      od;
#    od;
#    dcnums:=false; # clean memory
#    iso:=false;
#    act:=false;
#
#    # BN decomposition
#    dcreps:=[];
#    for i in AsList(weyl) do
#      #a:=PositionProperty(dc,y->i in y);
#      a:=rti[PositionCanonical(rt,i)];
#      if not IsBound(dcreps[a]) then dcreps[a]:=i;fi;
#    od;
#
#    if not ForAll([1..Length(dc)],x->IsBound(dcreps[x])) then
#      Error("weyl does not cover dc");
#    fi;
#
#    iso:=IsomorphismFpGroupByGenerators(group,gens);
#
#    act:=function(r,g)
#      return CanonicalRightCosetElement(borel,r*g);
#    end;
#
#    decomp:=function(elm)
#    local pos,rep;
#      if elm in borel then return [elm,One(borel),One(borel)];fi;
#      #pos:=PositionProperty(dc,y->elm in y);
#      pos:=rti[PositionCanonical(rt,elm)];
#      #rep:=RepresentativeAction(borel,PositionCanonical(rt,elm),
#      #       PositionCanonical(rt,dcreps[pos]),bgens,csetperm,OnPoints);
#      rep:=PreImagesRepresentative(bhom,
#        RepresentativeAction(Range(bhom),PositionCanonical(rt,elm),
#            PositionCanonical(rt,dcreps[pos])));
#      rep:=[elm*rep/dcreps[pos],dcreps[pos],rep^-1];
#      Assert(0,rep[1] in borel);
#      return rep;
#    end;
#  fi;


  # now build new presentation
  a:=[];
  for i in [1..Length(GeneratorsOfGroup(b))] do
    Add(a,Concatenation("b",String(i)));
  od;
  borelran:=[1..Length(a)];
  for i in [1..Length(GeneratorsOfGroup(w))] do
    Add(a,Concatenation("w",String(i)));
  od;

  f:=FreeGroup(a);
  gens:=FreeGeneratorsOfFpGroup(f);
  rels:=[];
  # take the relators of both groups
  ranb:=gens{[1..l]};
  for i in RelatorsOfFpGroup(b) do
    Add(rels,MappedWord(i,FreeGeneratorsOfFpGroup(b),ranb));
  od;
  ranw:=gens{[l+1..Length(gens)]};
  for i in RelatorsOfFpGroup(w) do
    Add(rels,MappedWord(i,FreeGeneratorsOfFpGroup(w),ranw));
  od;

  # throw in relators for the whole group, so we guarantee a presentation
  Append(rels,List(RelatorsOfFpGroup(Range(iso)),
    w->MappedWord(w,FreeGeneratorsOfFpGroup(Range(iso)),gens)));
  gp:=f/rels;

  iso:=GroupHomomorphismByImagesNC(group,gp,MappingGeneratorsImages(iso)[1],
         GeneratorsOfGroup(gp));
  SetIsBijective(iso,true);

  # now combine monoid presentations
  rels:=[];
mytzf:=maketzf(rels);
  mytzf:=fail;

  directerr:=false;
  if newstyle then directerr:=true;fi;

  addrule:=function(rule)
  local left,right,let,p,trule,j,stack;
    stack:=[];
    left:=reduce(rule[1],rels,rdag,mytzf);
    right:=reduce(rule[2],rels,rdag,mytzf);
    if left=right then return;fi;
    if IsLessThanUnder(ord,right,left) then
      rule:=[left,right];
    elif directerr then
      Error("direction!");
      rule:=[right,left];
    else
      rule:=[right,left];
    fi;
    # try to shift
    let:=LetterRepAssocWord(rule[1])[1];
    left:=Subword(rule[1],2,Length(rule[1]));
    right:=reduce(invmap[let]*rule[2],rels,rdag,mytzf);
    while IsLessThanUnder(ord,right,left) do
      rule:=[left,right];
      let:=LetterRepAssocWord(rule[1])[1];
      left:=Subword(rule[1],2,Length(rule[1]));
      right:=reduce(invmap[let]*rule[2],rels,rdag,mytzf);
    od;
    let:=LetterRepAssocWord(rule[1])[Length(rule[1])];
    left:=Subword(rule[1],1,Length(rule[1])-1);
    right:=reduce(rule[2]*invmap[let],rels,rdag,mytzf);
    while IsLessThanUnder(ord,right,left) do
      rule:=[left,right];
      let:=LetterRepAssocWord(rule[1])[Length(rule[1])];
      left:=Subword(rule[1],1,Length(rule[1])-1);
      right:=reduce(rule[2]*invmap[let],rels,rdag,mytzf);
    od;

    # delete common letters at start/end
    while Length(rule[2])>0 and Subword(rule[1],1,1)=Subword(rule[2],1,1) do
      rule:=[Subword(rule[1],2,Length(rule[1])),
             Subword(rule[2],2,Length(rule[2]))];
    od;
    while Length(rule[2])>0 and Subword(rule[1],Length(rule[1]),Length(rule[1]))
        =Subword(rule[2],Length(rule[2]),Length(rule[2])) do
      rule:=[Subword(rule[1],1,Length(rule[1])-1),
             Subword(rule[2],1,Length(rule[2])-1)];
    od;

# are they now redundant?
left:=reduce(rule[1],rels,rdag,mytzf);
right:=reduce(rule[2],rels,rdag,mytzf);
if IsLessThanUnder(ord,right,left) then
  rule:=[left,right];
else
  rule:=[right,left];
fi;
if rule[1]=rule[2] then return;fi;

    trule:=List(rule,LetterRepAssocWord);
    if rdag<>fail then
      p:=AddRuleKBDAG(rdag,trule[1],Length(rels)+1);
      if p=fail then
        # need to reduce rules
        left:=Filtered([1..Length(rels)],
          x->PositionSublist(LetterRepAssocWord(rels[x][1]),trule[1])<>fail);
        left:=Reversed(left);
        for p in left do
          Add(stack,rels[p]);
          DeleteRuleKBDAG(rdag,LetterRepAssocWord(rels[p][1]),p);
          Remove(rels,p);
        od;
        p:=AddRuleKBDAG(rdag,trule[1],Length(rels)+1);
      elif p=false then Error("could be reduced");fi;
    fi;
    Add(rels,rule);
    if mytzf<>fail then
      p:=trule[1][1];
      if not IsBound(mytzf[p]) then
        mytzf[p]:=[trule];
      else
        Add(mytzf[p],trule);
      fi;
    fi;
    if Length(stack)>0 then
#Print("deleted ",Length(stack)," rules @",Length(rels),"\n");
      for j in stack do
        addrule(j);
      od;
    fi;
  end;

  lev:=ShallowCopy(LevelsOfGenerators(cb.ordering));
  monb:=monoid;
  mons:=Range(cs.monhom);
  l:=Length(GeneratorsOfMonoid(monb));
  a:=[];
  for i in [1..l/2] do
    Add(a,Concatenation("b",String(i)));
    Add(a,Concatenation("B",String(i)));
  od;
  borelran:=[1..Length(a)];
  for i in [1..Length(MappingGeneratorsImages(isos)[2])] do
    Add(a,Concatenation("w",String(i)));
    Add(a,Concatenation("W",String(i)));
  od;
  f:=FreeMonoid(a);
  rdag:=EmptyKBDAG(Union(List(GeneratorsOfMonoid(f),LetterRepAssocWord)));

  # translate from fp word to monoid word
  trawo:=function(w)
  local a,i;
    w:=LetterRepAssocWord(w);
    a:=[];
    for i in w do
      if i>0 then
        Add(a,2*i-1);
      else
        Add(a,-2*i);
      fi;
    od;
    a:=AssocWordByLetterRep(FamilyObj(One(f)),a);
    return a;
  end;

  trawou:=w->trawo(UnderlyingElement(w));

  lev:=Concatenation(lev,
    ListWithIdenticalEntries(Length(GeneratorsOfMonoid(mons)),Maximum(lev)+1));

  ord:=WreathProductOrdering(f,lev);
  gens:=GeneratorsOfMonoid(f);

  invmap:=[];
  j:=FreeGeneratorsOfFpGroup(gp);
  for i in Concatenation(j,List(j,x->x^-1)) do
    invmap[LetterRepAssocWord(trawo(i))[1]]:=trawo(i^-1);
  od;

  if newstyle then

    weylword:=w->MappedWord(nofow(Image(cs.fphom,w)),
          GeneratorsOfGroup(Range(cs.fphom)),
          GeneratorsOfGroup(gp){[Length(GeneratorsOfGroup(Range(isob)))+1
            ..Length(GeneratorsOfGroup(gp))]});
    borelword:=w->MappedWord(nofob(Image(isob,w)),GeneratorsOfGroup(Range(isob)),
          GeneratorsOfGroup(gp){[1..Length(GeneratorsOfGroup(Range(isob)))]});

    coxrels:=[];
    if Size(ha)>1 then
      for i in Pcgs(ha) do
        a:=[weylword(i),borelword(i)];
        Info(InfoFpGroup,2,"intersection:",a);
        a:=List(a,trawou);
        addrule(a);
      od;
      b:=IsomorphismFpMonoid(weyl!.epiweyl);
      k:=KnuthBendixRewritingSystem(Range(b));
      MakeConfluent(k);
      for i in Rules(k) do
        a:=List(i,LetterRepAssocWord);
        if ForAll(a,x->ForAll(x,IsOddInt)) then
          #Relation does not involve inverses
          # write with weyl numbers
          a:=List(a,x->List(x,y->(y+1)/2));
          Add(coxrels,a);
        fi;
      od;
    else
      for i in RelationsOfFpMonoid(mons) do
        a:=List(i,LetterRepAssocWord);
        if ForAll(a,x->ForAll(x,IsOddInt)) then
          #Relation does not involve inverses
          # write with weyl numbers
          a:=List(a,x->List(x,y->(y+1)/2));
          Add(coxrels,a);
        fi;
      od;
    fi;

    directerr:=false;
  else

    j:=Intersection(borel,weyl);
    if Size(j)>1 then
      for i in Pcgs(j) do
        a:=[
        MappedWord(Image(cs.fphom,i),GeneratorsOfGroup(Range(cs.fphom)),
          GeneratorsOfGroup(gp){[Length(GeneratorsOfGroup(Range(isob)))+1
            ..Length(GeneratorsOfGroup(gp))]}),
        MappedWord(Image(isob,i),GeneratorsOfGroup(Range(isob)),
          GeneratorsOfGroup(gp){[1..Length(GeneratorsOfGroup(Range(isob)))]})
            ];
        Info(InfoFpGroup,2,"intersection:",a);
        a:=List(a,x->trawo(UnderlyingElement(x)));
        addrule(a);
      od;
    fi;
  fi;

  for i in RelationsOfFpMonoid(monb) do
    addrule(List(i,x->MappedWord(x,FreeGeneratorsOfFpMonoid(monb),
      gens{[1..l]})));
  od;

  for i in RelationsOfFpMonoid(mons) do
    addrule(List(i,x->MappedWord(x,FreeGeneratorsOfFpMonoid(mons),
      gens{[l+1..Length(gens)]})));
  od;
  directerr:=false;

  if newstyle then

    noncomm:=List(wgens,x->[]);
    # To use standard wreath product order, move borel to the right.

    # relations b*w->w*b'
    for i in [1..Length(wgens)] do
      pri:=wgens[i];
      for jj in [1..Length(bgens)] do
        j:=bgens[jj];
        k:=j^pri;
        if k in borel then
          a:=weylword(pri);
          b:=borelword(j);
          k:=borelword(k);
          a:=[b*a,a*k];
          a:=List(a,trawou);
          addrule(a);
        else
          Add(noncomm[i],jj);
        fi;
      od;
    od;

    noncelm:=List(noncomm,x->Elements(Group(bgens{x})));

    # relations   b*x*w -> x^(b^-1)*reduced(b*w) if xw  does not transform
    for i in [1..Length(wgens)] do
      for jj in Difference(noncelm[i],[One(group)]) do # non-mappable
        for j in [1..Minimum(noncomm[i])-1] do # earlier generators
          a:=weylword(wgens[i]);
          pri:=borelword(bgens[j])*a;
          pri:=reduce(trawou(pri),rels,rdag,mytzf);
          a:=[trawou(borelword(bgens[j])*borelword(jj)*a),
              trawou(borelword(jj^Inverse(bgens[j])))*pri];
          addrule(a);
        od;
      od;
    od;

    # modified coxeter relations with blocking borels in between
    # normalize using bn-pairs
    for pri in coxrels do
      pri:=pri[1];
      a:=List(pri,x->trawou(weylword(wgens[x])));
      for jj in Cartesian(noncelm{pri{[2..Length(pri)]}}) do
        if not ForAll(jj,IsOne) then
          b:=wgens[pri[1]]*Product([1..Length(jj)],x->jj[x]*wgens[pri[x+1]]);
          j:=decomp(b);
          j:=[borelword(j[1]),weylword(j[2]),borelword(j[3])];
          k:=List(jj,x->trawou(borelword(x)));
          b:=a[1]*Product([1..Length(jj)],x->k[x]*a[x+1]);
          j:=j[1]*j[2]*j[3];
          b:=[b,trawou(j)];
          addrule(b);
        fi;
      od;
    od;
  else

    # BN-style reductions
    pcgs:=List(GeneratorsOfGroup(b),x->PreImagesRepresentative(isob,x));
    # remove powers
    pcgs:=pcgs{
      Filtered([1..Length(pcgs)],i->not ForAny([1..i-1],
          j->Order(pcgs[i])=Order(pcgs[j])
            and ForAny([1..Order(pcgs[j])],o->pcgs[j]^o=pcgs[i]))) };
    pcgs:=PcgsByPcSequence(FamilyObj(()),pcgs);

    specialborelreduce:=true;
    wo:=Filtered(w,x->not IsOne(x));
    for i in wo do

      # which elements b*i can we write as i*\tilde b. Then b^i=\tilde b, that
      # is b\in B\cvap B^(i^-1)
      pri:=PreImagesRepresentative(isos,i);
      stb:=Intersection(borel,borel^(pri^-1));
      Info(InfoFpGroup,2,i," ",Size(stb));

      if Size(stb)>1 then
        can:=CanonicalPcgs(InducedPcgs(pcgs,stb));
        #can:=Filtered(Elements(stb),x->not IsOne(x));
        for j in can do
          #for jj in borel do # Also products borel*stb
          for jj in List(RightTransversal(borel,stb),Inverse) do
            k:=trawo(MappedWord(UnderlyingElement(i),FreeGeneratorsOfFpGroup(w),
              ranw));
            #Print("e.g. ",ImagesRepresentative(isob,jj*j)," => ",
            #        nofob(ImagesRepresentative(isob,jj*j)),"\n");
            a:=[  trawo(MappedWord(UnderlyingElement(
                    nofob(ImagesRepresentative(isob,jj*j))),
                    FreeGeneratorsOfFpGroup(b),ranb))*k,
                trawo(MappedWord(UnderlyingElement(
                    nofob(ImagesRepresentative(isob,jj))),
                    FreeGeneratorsOfFpGroup(b),ranb))*
                k*trawo(MappedWord(UnderlyingElement(
                    nofob(ImagesRepresentative(isob,j^pri))),
                    FreeGeneratorsOfFpGroup(b),ranb))];
            #if not IsLessThanUnder(ord,a[2],a[1]) then Error("ord!");fi;
            #tst:=List(a,LetterRepAssocWord);
            #if not ForAny(rels,x->
            #      PositionSublist(tst[1],LetterRepAssocWord(x[1]))<>fail) then
              addrule(a);
            #fi;
          od;
        od;
      fi;
    od;

    # avoid running through too many elements in borel
    if Size(borel)<100 then borelelm:=AsList(borel);
    else
      a:=Pcgs(borel);
      pri:=RelativeOrders(a);
      k:=[];
      for i in [1..Length(a)] do
        k[i]:=[];
        for j in [0..LogInt(QuoInt(pri[i],2),5)] do
          k[i]:=Union(k[i],5^j*[-2..2]);
        od;
        k[i]:=Intersection(k[i],[-QuoInt(pri[i],2)..QuoInt(pri[i],2)]);
        k[i]:=List(k[i],x->a[i]^x);
      od;
      borelelm:=Set(Cartesian(k),Product);

    fi;

    for i in wo do
      Info(InfoFpGroup,3,"borelrun ",Position(wo,i)," of ",Length(wo));

      # rewrite i*b*j as \tilde b*k*\hat b.
      pri:=PreImagesRepresentative(isos,i);
      stb:=Intersection(borel^pri,borel);

      for j in wo do
        Info(InfoFpGroup,2,"DC:",i,", ",j," from ",Length(rels));
        for k in borelelm do #RightTransversal(borel,stb) do
          a:=PreImagesRepresentative(isos,i)*k*
            PreImagesRepresentative(isos,j);
          a:=decomp(a);
          a:=[nofob(ImagesRepresentative(isob,a[1])),
              nofow(ImagesRepresentative(isos,a[2])),
              nofob(ImagesRepresentative(isob,a[3]))];
          a:=[MappedWord(UnderlyingElement(a[1]),FreeGeneratorsOfFpGroup(b),ranb),
              MappedWord(UnderlyingElement(a[2]),FreeGeneratorsOfFpGroup(w),ranw),
              MappedWord(UnderlyingElement(a[3]),FreeGeneratorsOfFpGroup(b),ranb)
              ];
          a:=List(a,trawo);
          a:=[
          trawo(MappedWord(UnderlyingElement(i),FreeGeneratorsOfFpGroup(w),ranw))
          *trawo(MappedWord(UnderlyingElement(
            nofob(ImagesRepresentative(isob,k))),
            FreeGeneratorsOfFpGroup(b),ranb))*
          trawo(MappedWord(UnderlyingElement(j),FreeGeneratorsOfFpGroup(w),ranw)),
          Product(a)];
          tst:=List(a,LetterRepAssocWord);
          #if ForAny(rels,x->
          #      PositionSublist(tst[1],LetterRepAssocWord(x[1]))<>fail) then
            addrule(a);
          #fi;
        od;
      od;
    od;
  fi;

  # group relators to make sure it's the proper group
  Info(InfoFpGroup,3,"grouprelators");
  for i in RelatorsOfFpGroup(gp) do
    # split in two -- not optimal, want to get minimal offset
    j:=Length(i);
    if IsEvenInt(j) then
      j:=QuoInt(j+1,2);
      a:=[Subword(i,1,j),Subword(i,j+1,Length(i))^-1];
      if a[1]=a[2] then
        a:=[Subword(i,1,j+1),Subword(i,j+2,Length(i))^-1];
      fi;
    else
      j:=QuoInt(j+1,2);
      a:=[Subword(i,1,j),Subword(i,j+1,Length(i))^-1];
    fi;
    a:=List(a,trawo);
    if IsLessThanUnder(ord,a[1],a[2]) then
      a:=Reversed(a);
    fi;
    addrule(a);
  od;

  l:=[];
  for i in FreeGeneratorsOfFpGroup(gp) do
    Add(l,i);
    Add(l,i^-1);
  od;
  tst:=List(rels,x->List(x,w->MappedWord(w,GeneratorsOfMonoid(f),l)));
  tst:=List(tst,x->x[1]/x[2]);
  Assert(2,Size(FreeGroupOfFpGroup(gp)/tst)=Size(group));

  rdag:=fail;

  # back-reduce
  Info(InfoFpGroup,3,"backreduce");
  repeat
    jj:=[];
    a:=true;
    i:=1;
    while i<=Length(rels) do
      if IsSubset(borelran,Union(List(rels[i],LetterRepAssocWord))) then
        specialborelreduce:=false;
      fi;
      l:=rels{Difference([1..Length(rels)],[i])};
      mytzf:=maketzf(l);
      tst:=[reduce(rels[i][1],l,fail,mytzf),reduce(rels[i][2],l,fail,mytzf)];
      if tst<>rels[i] then
        Add(jj,i);
        rels:=l; # note that tzf is already set
        if tst[1]<>tst[2] then
          addrule(tst);
        fi;
        a:=false;
        #i:=Length(rels); #just continue
      fi;
      specialborelreduce:=true;
      i:=i+1;
    od;
    Info(InfoFpGroup,2,"rulereduce ",jj);
  until a;

  i:=Length(rels);
  Info(InfoFpGroup,2,"have ",i," rules");
  a:=KnuthBendixRewritingSystem(f/rels,ord);
  MakeConfluent(a);
  Info(InfoFpGroup,1,"confluent RWS ",i," -> ",Length(Rules(a)),"\n");
  b:=f/Rules(a); # make once more for the fp monoid.
  SetReducedConfluentRewritingSystem(b,a);

  l:=[];
  for i in FreeGeneratorsOfFpGroup(gp) do
    Add(l,i);
    Add(l,i^-1);
  od;
  tst:=List(rels,x->List(x,w->MappedWord(w,GeneratorsOfMonoid(f),l)));
  tst:=List(tst,x->x[1]/x[2]);
  #if Size(FreeGroupOfFpGroup(gp)/tst)<>Size(group) then Error("wrong2!");fi;

  b!.rewritingSystem:=a;
  hom:=MagmaIsomorphismByFunctionsNC(gp,b,
      function(w)
        local l,i;
        l:=[];
        for i in LetterRepAssocWord(UnderlyingElement(w)) do
          if i>0 then Add(l,2*i-1);
          else Add(l,-2*i);fi;
        od;
        return ElementOfFpMonoid(FamilyObj(One(b)),
                AssocWordByLetterRep(FamilyObj(One(f)),l));
      end,
      function(w)
        local g,i,x;
        g:=[];
        for i in LetterRepAssocWord(UnderlyingElement(w)) do
          if IsOddInt(i) then x:=(i+1)/2;
          else x:=-i/2;fi;
          # word must be freely cancelled
          if Length(g)>0 and x=-Last(g) then
            Remove(g);
          else Add(g,x); fi;
        od;
        return ElementOfFpGroup(FamilyObj(One(gp)),
                AssocWordByLetterRep(FamilyObj(One(FreeGroupOfFpGroup(gp))),g));
      end);
  SetIsomorphismFpMonoid(gp,hom);
  SetIsBijective(hom,true);
  return iso;
end);

# creator function for data in grp/simplrerew.grp -- for documentation
#ConfluentRewritingData:=function(hom)
#local f,miso,lm,mg,l,pre,gens,m,bas,pownum;
#  pownum:=function(w)
#  local l,s,i;
#    l:=LetterRepAssocWord(w);
#    s:=0;
#    for i in [1..Length(l)] do
#      s:=s+l[i]*bas^(i-1);
#    od;
#    return s;
#  end;
#  pre:=DataAboutSimpleGroup(Source(hom));
#  pre:=ShallowCopy(pre.idSimple);
#  if not IsBound(pre.parameter) then pre.parameter:=pre.shortname;fi;
#  f:=Range(hom);
#  miso:=IsomorphismFpMonoid(f);
#  gens:=MappingGeneratorsImages(hom)[2];
#  m:=Range(miso);
#  mg:=List(GeneratorsOfMonoid(m));
#  bas:=Length(mg);
#  l:=[Size(f),pre.series,pre.parameter];
#  if IsBound(pre.shortname) then Add(l,pre.shortname);fi;
#  l:=[l,MappingGeneratorsImages(hom)[1]];
#  Add(l,bas);
#  bas:=bas+1; # need to go one larger, to avoid missing trailing 1's
#  Add(l,List(mg,String));
#  if List(mg,x->LetterRepAssocWord(UnderlyingElement(x)))<>
#    List([1..Length(mg)],x->[x]) then Error("gens!"); fi;
#  pre:=List(mg,x->LetterRepAssocWord(UnderlyingElement(
#    PreImagesRepresentative(miso,x))));
#  if ForAny(pre,x->Length(x)<>1) then Error("double");fi;
#  Add(l,Concatenation(pre));
#  if IsBound(m!.rewritingSystem) then
#    mg:=m!.rewritingSystem;
#    Add(l,LevelsOfGenerators(mg!.ordering));
#  else
#    Add(l,0);
#  fi;
#  Add(l,List(RelationsOfFpMonoid(m),x->List(x,pownum)));
#  return l;
#end;

BindGlobal("BuildRewritingFromData",function(dat)
local bas,fm,fam,mfam,mrels,rels,i,f,g,m,hom;
  bas:=dat[3]+1;
  fm:=FreeMonoid(dat[4]);
  mfam:=FamilyObj(One(fm));

  f:=Filtered([1..Length(dat[5])],x->dat[5][x]>0);
  f:=FreeGroup(dat[4]{f});
  fam:=FamilyObj(One(f));

  mrels:=[];
  rels:=[];
  for i in dat[7] do
    i:=List(i,x->CoefficientsQadic(x,bas));
    Add(mrels,List(i,x->AssocWordByLetterRep(mfam,x)));
    i:=List(i,x->dat[5]{x});
    # avoid the inverse relations
    if not (Length(i[1])=2 and i[1][1]=-i[1][2]) then
      i:=List(i,x->AssocWordByLetterRep(fam,x));
      Add(rels,i[1]/i[2]);
    fi;
  od;
  m:=fm/mrels;
  if IsList(dat[6]) then
    i:=KnuthBendixRewritingSystem(m,WreathProductOrdering(fm,dat[6]):isconfluent);
    i!.reduced:=true;
    m!.rewritingSystem:=i;
  fi;

  g:=f/rels;

  MakeFpGroupToMonoidHomType1(g,m);

  hom:=GroupHomomorphismByImagesNC(Group(dat[2]),g,dat[2],GeneratorsOfGroup(g));
  SetIsomorphismFpGroup(Source(hom),hom);
  return hom;
end);


InstallMethod(IsomorphismFpGroupForRewriting,"simple groups: stored",
  [IsSimpleGroup and IsFinite],1,
function(G)
local a,f,iso;

  a:=DataAboutSimpleGroup(G);
  if not IsBound(a.classicalId)
    or ValueOption(NO_PRECOMPUTED_DATA_OPTION)=true then
    TryNextMethod();
  fi;
  iso:=ShallowCopy(a.idSimple);
  if not IsBound(iso.parameter) then
    iso.parameter:=iso.shortname;
  fi;

  # is it a pre-stored presentation?
  f:=Filename(DirectoriesLibrary("grp"), "simplerew.grp");
  if f<>fail then
    f:=ReadAsFunction(f)();
    f:=First(f,x->x[1][2]=iso.series
      and x[1][3]=iso.parameter);
    if f<>fail then
      a:=BuildRewritingFromData(f);
      return IsomorphismGroups(G,Source(a))*a;
    fi;
  fi;
  TryNextMethod();
end);

InstallMethod(IsomorphismFpGroupForRewriting,"simple groups: L and C",
  [IsSimpleGroup and IsFinite],0,
function(G)
local d,f,group,act,g,sy,b,c,borel,weyl,a,i,iso,ucs,gens,gl;

  a:=DataAboutSimpleGroup(G);
  if not IsBound(a.classicalId) then
    TryNextMethod();
  fi;

  if a.classicalId.series="L" then
    d:=a.classicalId.parameter[1];
    f:=a.classicalId.parameter[2];

    if d=2 and f=7 then d:=3;f:=2;fi;

    group:=PSL(d,f);
    act:=group!.actionHomomorphism;

    # Borel
    g:=Source(act);
    sy:=SylowSubgroup(g,SmallestPrimeDivisor(f));
    b:=Normalizer(g,sy);
    borel:=Image(act,b);

    # Weyl
    weyl:=WeylGroupFp("A",d-1);
    a:=List([1..d-1],x->(x,x+1));
    g:=Group(a,());
    #iso:=GroupHomomorphismByImages(weyl,g,GeneratorsOfGroup(weyl),a);
    #weyl:=g;
    #SetIsomorphismFpGroup(weyl,InverseGeneralMapping(iso));

    a:=List(GeneratorsOfGroup(g),x->PermutationMat(x,d,GF(f)));
    for i in [1..Length(a)] do
      if not IsOne(DeterminantMat(a[i])) then
        a[i][1]:=-a[i][1];
      fi;
    od;
    a:=Group(a);
    a:=Image(act,a);
    a!.epiweyl:=weyl;
    weyl:=a;

    sy:=SylowSubgroup(borel,SmallestPrimeDivisor(f));
    ucs:=Reversed(PCentralSeries(sy));

    gens:=IndependentGeneratorsOfAbelianGroup(Centre(sy));
    gens:=Concatenation(List(gens,x->Filtered(Orbit(weyl,x),x->x in sy)));
    SortBy(gens,x->PositionProperty(ucs,y->x in y));
    a:=gens;
    c:=TrivialSubgroup(sy);
    gens:=[];
    for i in a do
      if not i in c and IsNormal(ClosureGroup(c,i),c) then
        Add(gens,i);
        c:=ClosureGroup(c,i);
      fi;
    od;
    if c<>sy then Error("sylow (A) generators");fi;
    gens:=Reversed(gens);

    if Size(borel)=Size(sy) then
      borel:=Group(gens);
      iso:=SplitBNRewritingPresentation(group,borel,weyl,true);
      return IsomorphismGroups(G,Source(iso))*iso;
    elif IsPrimePowerInt(Index(borel,sy)) then
      gens:=Concatenation(Pcgs(SylowSubgroup(borel,
        SmallestPrimeDivisor(IndexNC(borel,sy)))),gens);
      a:=Group(gens);
      if Size(a)<Size(borel) then Error("wrong");
      else borel:=a;fi;
      iso:=SplitBNRewritingPresentation(group,borel,weyl,true);
      return IsomorphismGroups(G,Source(iso))*iso;
    else
      borel:=Group(SpecialPcgs(borel));
      iso:=SplitBNRewritingPresentation(group,borel,weyl,true);
      return IsomorphismGroups(G,Source(iso))*iso;
    fi;

  elif a.idSimple.series="C" or
    #B(n,2^m) ~ C(n,2^m)
    (a.idSimple.series="B" and
      SmallestPrimeDivisor(a.classicalId.parameter[2])=2) then
    d:=a.idSimple.parameter[1];
    f:=a.idSimple.parameter[2];
    group:=PSP(2*d,f);
    act:=group!.actionHomomorphism;

    g:=Source(act);
    # get sylow subgroup as intersection with GL-Sylow so it is upper
    # triangular
    gl:=GL(2*d,f);
    sy:=SylowSubgroup(gl,SmallestPrimeDivisor(f));
    sy:=Intersection(g,sy);
    if Gcd(Size(sy),Size(g)/Size(sy))<>1 then
      Info(InfoWarning,1,"Sylow intersection did not work");
      sy:=SylowSubgroup(g,SmallestPrimeDivisor(f));
    fi;

    sy:=Image(act,sy);
    borel:=Normalizer(group,sy);
    borel:=Group(Pcgs(borel));

    # Weyl
    weyl:=SymmetricGroup(d);
    a:=[];
    for i in GeneratorsOfGroup(weyl) do
      c:=IdentityMat(2*d,GF(f));
      b:=PermutationMat(i,d,GF(f));
      c{[1..d]}{[1..d]}:=b;
      c{[d+1..2*d]}{[d+1..2*d]}:=Reversed(List(b,Reversed));
      if not IsOne(DeterminantMat(c)) then
        c[1]:=-c[1];
      fi;
      Add(a,c);
    od;
    b:=PermutationMat((d,d+1),2*d,GF(f));
    b[d+1]:=-b[d+1];
    Add(a,b);
    a:=Group(a);
    a:=Image(act,a);
    weyl:=WeylGroupFp("B",d);
    Size(weyl);
    c:=GQuotients(a,weyl);
    if Length(c)>1 then
      c:=Filtered(c,
        x->KernelOfMultiplicativeGeneralMapping(x)=Intersection(a,borel));
    fi;
    c:=c[1];
    a:=SubgroupNC(group,List(GeneratorsOfGroup(weyl),
      x->PreImagesRepresentative(c,x)));
    Size(a);
    a!.epiweyl:=weyl;
    weyl:=a;
    if group<>ClosureGroup(borel,weyl) then Error("wrong BN");fi;

#   cannot yet do the refined process, as its not yet the right weyl
#   candidate
#
#    sy:=SylowSubgroup(borel,SmallestPrimeDivisor(f));
#    ucs:=Reversed(PCentralSeries(sy));
#
#    #gens:=IndependentGeneratorsOfAbelianGroup(Centre(sy));
#    #gens:=Concatenation(List(gens,x->Filtered(Orbit(weyl,x),x->x in sy)));
#    gens:=Union(Orbit(weyl,Centre(sy)));
#    i:=1;
#    while not IsSubset(Group(gens),sy) do
#      i:=i+1;
#      gens:=Union(Orbit(weyl,ucs[i]));
#    od;
#
#    gens:=Difference(gens,[One(sy)]);
#    SortBy(gens,x->PositionProperty(ucs,y->x in y));
#    a:=gens;
#    c:=TrivialSubgroup(sy);
#    gens:=[];
#    for i in a do
#      if not i in c and IsNormal(ClosureGroup(c,i),c) then
#        Add(gens,i);
#        c:=ClosureGroup(c,i);
#      fi;
#    od;
#    if c<>sy then Error("sylow (B) generators");fi;
#    gens:=Reversed(gens);
#
#    if Size(borel)=Size(sy) then
#      borel:=Group(gens);
#      iso:=SplitBNRewritingPresentation(group,borel,weyl,true);
#      return IsomorphismGroups(G,Source(iso))*iso;
#    elif IsPrimePowerInt(Index(borel,sy)) then
#      gens:=Concatenation(Pcgs(SylowSubgroup(borel,
#        SmallestPrimeDivisor(IndexNC(borel,sy)))),gens);
#      a:=Group(gens);
#      if Size(a)<Size(borel) then Error("wrong");
#      else borel:=a;fi;
#      iso:=SplitBNRewritingPresentation(group,borel,weyl,true);
#      return IsomorphismGroups(G,Source(iso))*iso;
#    else
#      Error("can't do yet");
#    fi;

  else
    TryNextMethod();
  fi;
  iso:=SplitBNRewritingPresentation(group,borel,weyl,false);
  return IsomorphismGroups(G,Source(iso))*iso;
end);

InstallMethod(IsomorphismFpGroupForRewriting,"generic simple",
  [IsSimpleGroup and IsFinite],-1,
function(G)
local p,dat,lev,l,sub,c,s,r,dc;
  # try to find subgroups similar to Borel and Weyl

  dat:=DataAboutSimpleGroup(G);
  if IsBound(dat.idSimple.parameter) and IsList(dat.idSimple.parameter)
     and Length(dat.idSimple.parameter)>1 then
    p:=Factors(dat.idSimple.parameter[2])[1];
    s:=SylowSubgroup(G,p);
    l:=Normalizer(G,s);
    sub:=ComplementClassesRepresentatives(l,s); # torus
    if Length(sub)>0 and Size(sub[1])>1 then
      s:=Normalizer(G,sub[1]);
      r:=ComplementClassesRepresentatives(s,sub[1]);
      if Length(r)>0 then
        s:=r[1];
      fi;
      r:=SplitBNRewritingPresentation(G,l,s,false);
      if r<>fail then return r;fi;
    fi;
  fi;

  lev:=1;
  repeat
    lev:=lev+1;
    l:=LowLayerSubgroups(G,lev);
    l:=Filtered(l,IsSolvableGroup);
  until Length(l)>0;
  SortBy(l,Size);
  l:=l[Length(l)]; # will be "borel"

  dc:=DoubleCosets(G,l,l);

  # small subgroup that will act transitively on the double cosets.
  sub:=ShallowCopy(ConjugacyClassesSubgroups(G));;
  SortBy(sub,x->Size(Representative(x)));

  for c in sub do
    for s in c do
      if Size(Intersection(l,s))=1 and Size(s)>=Length(dc)
        and Size(ClosureGroup(l,s))=Size(G) and
        Length(Set(Elements(s),
          x->PositionProperty(dc,y->x in y)))=Length(dc) then
        r:=SplitBNRewritingPresentation(G,l,s,false);
        if r<>fail then return r;fi;
      fi;
    od;
  od;

  TryNextMethod();
end);
