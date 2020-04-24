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
  # use the perfect groups library
  PerfGrpLoad(Size(G));
  if Size(G)<10^6 and IsRecord(PERFRec) and
     ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true and
     not Size(G) in Union(PERFRec.notAvailable,PERFRec.notKnown) then
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

    # the solvable case
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
  m,abelianlimit,locallim,abpow,needgens,fampcgs;

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
  elif IsTrivial(N) then
    ser:=ChiefSeries(g);
  else
    if HasChiefSeries(g) and N in ChiefSeries(g) then
      ser:=ChiefSeries(g);
    else
      ser:=ChiefSeriesThrough(g,[N]);
    fi;
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
      f:=Range(hom);
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
InstallMethod( IsomorphismFpGroupByChiefSeries,"permgrp",true,
               [IsPermGroup,IsString], 0,
function(g,str)
  return IsomorphismFpGroupByChiefSeriesFactor(g,str,TrivialSubgroup(g));
end);

InstallMethod( IsomorphismFpGroupByChiefSeries,"pc grp",true,
               [IsPcGroup,IsString], 0,
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
function(hom,G,M,N,mnsf)
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
function(h,g,m,n,k,ggens,cgens)
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
          w, t, i, j;

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

        # get composition factor
        N := series[k];
        M := series[k+1];
        hom   := NaturalHomomorphismByNormalSubgroupNC( N, M );
        H     := Image( hom );
        gensH := Set( GeneratorsOfGroup( H ) );
        gensH := Filtered( gensH, x -> x <> One(H) );
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );
        c     := Length( gensH );

        # compute presentation of H
        new := IsomorphismFpGroupByGeneratorsNC( H, gensH, "g" );
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

BindGlobal("MakeFpGroupToMonoidHomType1",function(fp,m)
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
              Unbind(g[Length(g)]);
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
# confluent (wrt wreath order). Returns list [fphom,monhom,ordering]
InstallMethod(ConfluentMonoidPresentationForGroup,"generic",
  [IsGroup and IsFinite],
function(G)
local iso,fp,n,dec,homs,mos,i,j,ffp,imo,m,k,gens,fm,mgens,rules,
      loff,off,monreps,left,right,fmgens,r,diff,monreal,nums,reduce,hom,dept;
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
    n:=Length(gens);
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
    reduce:=function(w)
    local red,i,p;
      w:=LetterRepAssocWord(w);
      repeat
        i:=1;
        red:=false;
        while i<=Length(rules) and red=false do
          p:=PositionSublist(w,LetterRepAssocWord(rules[i][1]));
          if p<>fail then
            w:=Concatenation(w{[1..p-1]},LetterRepAssocWord(rules[i][2]),
              w{[p+Length(rules[i][1])..Length(w)]});
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
        Add(rules,[left,right]);
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
              Add(rules,[mgens[k]*mgens[j],right]);
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

    if ForAny(rules,x->x[2]<>reduce(x[2])) then Error("irreduced right");fi;

    # inverses are true inverses, also for extension
    for i in [1..Length(gens)] do
      left:=mgens[2*i-1]*mgens[2*i];
      left:=reduce(left);
      if left<>One(fm) then Add(rules,[left,One(fm)]); fi;
      left:=mgens[2*i]*mgens[2*i-1];
      left:=reduce(left);
      if left<>One(fm) then Add(rules,[left,One(fm)]); fi;
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
  k:=KnuthBendixRewritingSystem(FamilyObj(One(m)),j.ordering);
  MakeConfluent(k); # will store in monoid as reducedConfluent
  return j;
end);

BindGlobal("WeylGroupFp",function(ser,n)
local f,rels,i,j,gens;
  f:=FreeGroup(List([1..n],x->Concatenation("s",String(x))));
  gens:=GeneratorsOfGroup(f);
  rels:=List(gens,x->x^2);
  if ser="A" then
    for i in [1..n] do
      for j in [1..i-1] do
        if i-j>1 then
          Add(rels,(gens[i]*gens[j])^2);
        else
          Add(rels,(gens[i]*gens[j])^3);
        fi;
      od;
    od;
  elif ser="B" or ser="C" then
    for i in [1..n] do
      for j in [1..i-1] do
        if i-j>1 then
          Add(rels,(gens[i]*gens[j])^2);
        elif j=1 then
          Add(rels,(gens[i]*gens[j])^4);
        else
          Add(rels,(gens[i]*gens[j])^3);
        fi;
      od;
    od;
  elif ser="D" and n>=4 then
    Add(rels,(gens[1]*gens[2])^2);
    Add(rels,(gens[1]*gens[3])^3);
    Add(rels,(gens[2]*gens[3])^3);
    for i in [4..n] do
      for j in [1..i-1] do
        if i-j>1 then
          Add(rels,(gens[i]*gens[j])^2);
        else
          Add(rels,(gens[i]*gens[j])^3);
        fi;
      od;
    od;
  elif ser="E" then
    Add(rels,(gens[1]*gens[2])^3);
    Add(rels,(gens[2]*gens[3])^3);
    Add(rels,(gens[3]*gens[4])^3);
    Add(rels,(gens[3]*gens[5])^3);
    Add(rels,(gens[5]*gens[6])^3);

    Add(rels,(gens[1]*gens[3])^2);
    Add(rels,(gens[1]*gens[4])^2);
    Add(rels,(gens[2]*gens[4])^2);
    Add(rels,(gens[1]*gens[5])^2);
    Add(rels,(gens[2]*gens[5])^2);
    Add(rels,(gens[4]*gens[5])^2);
    Add(rels,(gens[1]*gens[6])^2);
    Add(rels,(gens[2]*gens[6])^2);
    Add(rels,(gens[3]*gens[6])^2);
    Add(rels,(gens[4]*gens[6])^2);
    if n>=7 then
      Add(rels,(gens[6]*gens[7])^3);
      for i in [1..5] do
        Add(rels,(gens[i]*gens[7])^2);
      od;
    fi;
    if n=8 then
      Add(rels,(gens[7]*gens[8])^3);
      for i in [1..6] do
        Add(rels,(gens[i]*gens[7])^2);
      od;
    elif n>8 then 
      Error("E>8 does not exist");
    fi;
  elif ser="F" and n=4 then
    Add(rels,(gens[1]*gens[2])^3);
    Add(rels,(gens[2]*gens[3])^4);
    Add(rels,(gens[3]*gens[4])^3);

    Add(rels,(gens[1]*gens[3])^2);
    Add(rels,(gens[1]*gens[4])^2);
    Add(rels,(gens[2]*gens[4])^2);
  elif ser="G" and n=2 then
    Add(rels,(gens[1]*gens[2])^6);
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

# rewriting systems for simple groups based on BN pairs, following 
# (Schmidt,  Finite groups have short rewriting systems. Computational group
# theory and the theory of groups, II, 185–200, Contemp. Math., 511.)
BindGlobal("BNnyRewritingPresentation",function(group,borel,weyl)
local isob,isos,iso,gens,u,a,rels,l,i,j,bgens,cb,cs,b,f,k,w,monoid,
  lev,ord,monb,mons,gp,trawo,hom,tst,dc,dcreps,act,decomp,ranb,ranw,
  nofob,nofow,reduce,pcgs,can,pri,stb,addrule,invmap,jj,wo;

  if Size(ClosureGroup(borel,weyl))<Size(group) then return fail;fi;
  dc:=DoubleCosets(group,borel,borel);

  if Size(Intersection(borel,weyl))>1 then
    # can we fix this?
    # asume weyl is not too large
    cs:=Concatenation(List(ConjugacyClassesSubgroups(weyl),AsList));;
    SortBy(cs,x->-Size(x));
    l:=false;
    i:=1;
    while l=false and i<=Length(cs) do
      if Size(Intersection(borel,cs[i]))=1 and Size(cs[i])>=Length(dc)
        and Size(ClosureGroup(borel,cs[i]))=Size(group) and 
        Length(Set(List(Elements(cs[i]),
          x->PositionProperty(dc,y->x in y))))=Length(dc) then
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
  pcgs:=SpecialPcgs(borel);
  borel:=Group(GeneratorsOfGroup(borel));
  SetPcgs(borel,pcgs);
  b:=List(LGFirst(pcgs),x->SubgroupNC(borel,pcgs{[x..Length(pcgs)]}));
  SetChiefSeries(borel,b);

  cb:=ConfluentMonoidPresentationForGroup(borel);

  isob:=cb.fphom;
  b:=Range(isob);
  bgens:=List(GeneratorsOfGroup(b),x->PreImagesRepresentative(isob,x));
  monoid:=Range(cb.monhom);

  reduce:=function(wo,rules)
  local w,fam,red,i,j,p,tzrules,tzf;
    fam:=FamilyObj(wo);
    w:=LetterRepAssocWord(wo);
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

    # collect from the right
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
	      p:=Minimum(p+Length(red[i][2]),Length(w));
	      i:=Length(red);
	    fi;
	  fi;
	  i:=i+1;
	od;

      fi;
      p:=p-1;
    od;

    w:=AssocWordByLetterRep(fam,w);
    return w;
  end;

  nofob:=function(x)
    x:=UnderlyingElement(ImagesRepresentative(cb.monhom,x));
    x:=reduce(x,RelationsOfFpMonoid(monoid));
    x:=ElementOfFpMonoid(FamilyObj(One(monoid)),x);
    return PreImagesRepresentative(cb.monhom,x);
  end;

  cs:=IsomorphismFpGroupForWeyl(weyl);
  if cs<>fail then
    cs:=rec(fphom:=cs,monhom:=IsomorphismFpMonoid(Range(cs)));
  else
    cs:=ConfluentMonoidPresentationForGroup(weyl);
  fi;
  isos:=cs.fphom;
  w:=Range(isos);
  a:=MappingGeneratorsImages(isos)[1];

  nofow:=function(x)
    x:=UnderlyingElement(ImagesRepresentative(cs.monhom,x));
    x:=reduce(x,RelationsOfFpMonoid(Range(cs.monhom)));
    x:=ElementOfFpMonoid(FamilyObj(One(Range(cs.monhom))),x);
    return PreImagesRepresentative(cs.monhom,x);
  end;

  gens:=bgens;
  l:=Length(gens);
  gens:=Concatenation(gens,a);

  iso:=IsomorphismFpGroupByGenerators(group,gens);

  # BN decomposition
  dcreps:=[];
  for i in AsList(weyl) do
    a:=PositionProperty(dc,y->i in y);
    if not IsBound(dcreps[a]) then dcreps[a]:=i;fi;
  od;

  if not ForAll([1..Length(dc)],x->IsBound(dcreps[x])) then
    Error("weyl does not cover dc");
  fi;

  act:=function(r,g)
    return CanonicalRightCosetElement(borel,r*g);
  end;

  decomp:=function(elm)
  local pos,rep;
    if elm in borel then return [elm,One(borel),One(borel)];fi;
    pos:=PositionProperty(dc,y->elm in y);
    rep:=RepresentativeAction(borel,CanonicalRightCosetElement(borel,elm),
           CanonicalRightCosetElement(borel,dcreps[pos]),act);
    rep:=[elm*rep/dcreps[pos],dcreps[pos],rep^-1];
    Assert(0,rep[1] in borel);
    return rep;
  end;

  # now build new presentation
  a:=[];
  for i in [1..Length(GeneratorsOfGroup(b))] do
    Add(a,Concatenation("b",String(i)));
  od;
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
  addrule:=function(rule)
  local left,right,let,old;
    left:=reduce(rule[1],rels);
    right:=reduce(rule[2],rels);
    if IsLessThanUnder(ord,right,left) then
      rule:=[left,right];
    else
      rule:=[right,left];
    fi;
    if rule[1]=rule[2] then return;fi;
    # try to shift
  old:=rule;
    let:=LetterRepAssocWord(rule[1])[1];
    left:=Subword(rule[1],2,Length(rule[1]));
    right:=reduce(invmap[let]*rule[2],rels);
    while IsLessThanUnder(ord,right,left) do
      rule:=[left,right];
      let:=LetterRepAssocWord(rule[1])[1];
      left:=Subword(rule[1],2,Length(rule[1]));
      right:=reduce(invmap[let]*rule[2],rels);
    od;
    let:=LetterRepAssocWord(rule[1])[Length(rule[1])];
    left:=Subword(rule[1],1,Length(rule[1])-1);
    right:=reduce(rule[2]*invmap[let],rels);
    while IsLessThanUnder(ord,right,left) do
      rule:=[left,right];
      let:=LetterRepAssocWord(rule[1])[Length(rule[1])];
      left:=Subword(rule[1],1,Length(rule[1])-1);
      right:=reduce(rule[2]*invmap[let],rels);
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


    Add(rels,rule);
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
  for i in [1..Length(MappingGeneratorsImages(isos)[2])] do
    Add(a,Concatenation("w",String(i)));
    Add(a,Concatenation("W",String(i)));
  od;
  f:=FreeMonoid(a);

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

  lev:=Concatenation(lev,
    ListWithIdenticalEntries(Length(GeneratorsOfMonoid(mons)),Maximum(lev)+1));

  ord:=WreathProductOrdering(f,lev);
  gens:=GeneratorsOfMonoid(f);

  invmap:=[];
  j:=FreeGeneratorsOfFpGroup(gp);
  for i in Concatenation(j,List(j,x->x^-1)) do
    invmap[LetterRepAssocWord(trawo(i))[1]]:=trawo(i^-1);
  od;

  j:=Intersection(borel,weyl);
  if Size(j)>1 then
    for i in Pcgs(j) do
      a:=[
      MappedWord(Image(cs.fphom,i),GeneratorsOfGroup(Range(cs.fphom)),
        GeneratorsOfGroup(gp){[Length(GeneratorsOfGroup(Range(cb.fphom)))+1
          ..Length(GeneratorsOfGroup(gp))]}),
      MappedWord(Image(cb.fphom,i),GeneratorsOfGroup(Range(cb.fphom)),
        GeneratorsOfGroup(gp){[1..Length(GeneratorsOfGroup(Range(cb.fphom)))]})
          ];
      Info(InfoFpGroup,2,"intersection:",a);
      a:=List(a,x->trawo(UnderlyingElement(x)));
      addrule(a);
    od;
  fi;

  for i in RelationsOfFpMonoid(monb) do
    addrule(List(i,x->MappedWord(x,FreeGeneratorsOfFpMonoid(monb),
      gens{[1..l]})));
  od;
  for i in RelationsOfFpMonoid(mons) do
    addrule(List(i,x->MappedWord(x,FreeGeneratorsOfFpMonoid(mons),
      gens{[l+1..Length(gens)]})));
  od;


  # BN-style reductions
  pcgs:=List(GeneratorsOfGroup(b),x->PreImagesRepresentative(isob,x));
  # remove powers
  pcgs:=pcgs{
    Filtered([1..Length(pcgs)],i->not ForAny([1..i-1],
        j->Order(pcgs[i])=Order(pcgs[j])
          and ForAny([1..Order(pcgs[j])],o->pcgs[j]^o=pcgs[i]))) };
  pcgs:=PcgsByPcSequence(FamilyObj(()),pcgs);

  wo:=Filtered(w,x->not IsOne(x));
  for i in wo do

    # which elements b*i can we write as i*\tilde b. Then b^i=\tilde b, that
    # is b\in B\cvap B^(i^-1)
    pri:=PreImagesRepresentative(isos,i);
    stb:=Intersection(borel,borel^(pri^-1));
    Info(InfoFpGroup,2,i," ",Size(stb));

    if Size(stb)>1 then 
      can:=CanonicalPcgs(InducedPcgs(pcgs,stb));
      can:=Filtered(Elements(stb),x->not IsOne(x));
      for j in can do
        #for jj in borel do # Also products borel*stb
        for jj in List(RightTransversal(borel,stb),Inverse) do
          k:=trawo(MappedWord(UnderlyingElement(i),FreeGeneratorsOfFpGroup(w),
            ranw));
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

  for i in wo do

    # rewrite i*b*j as \tilde b*k*\hat b.
    pri:=PreImagesRepresentative(isos,i);
    stb:=Intersection(borel^pri,borel);

    for j in wo do
      Info(InfoFpGroup,2,"DC:",i,", ",j," from ",Length(rels));
      for k in borel do #RightTransversal(borel,stb) do
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

  # group relators to make sure its the proper group
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

  # back-reduce
  repeat
    jj:=[];
    a:=true;
    i:=1;
    while i<=Length(rels) do
      l:=rels{Difference([1..Length(rels)],[i])};
      tst:=[reduce(rels[i][1],l),reduce(rels[i][2],l)];
      if tst<>rels[i] then
        Add(jj,i);
        rels:=l;
        if tst[1]<>tst[2] then
          addrule(tst);
        fi;
        a:=false;
        #i:=Length(rels); #just continue
      fi;
      i:=i+1;
    od;
    Info(InfoFpGroup,2,"rulereduce ",jj);
  until a;



  i:=Length(rels);
  Info(InfoFpGroup,2,"have ",i," rules");
  a:=KnuthBendixRewritingSystem(f/rels,ord);
  #Error("HUH2");
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
  if Size(FreeGroupOfFpGroup(gp)/tst)<>Size(group) then Error("wrong2!");fi;

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
          if Length(g)>0 and x=-g[Length(g)] then
            Unbind(g[Length(g)]);
          else Add(g,x); fi;
        od;
        return ElementOfFpGroup(FamilyObj(One(gp)),
                AssocWordByLetterRep(FamilyObj(One(FreeGroupOfFpGroup(gp))),g));
      end);
  SetIsomorphismFpMonoid(gp,hom);
  SetIsBijective(hom,true);
  return iso;
end);


InstallMethod(IsomorphismFpGroupForRewriting,"linear or symplectic",
  [IsSimpleGroup and IsFinite],0,
function(G)
local d,f,group,act,g,sy,b,c,borel,weyl,a,i,iso;

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
    weyl:=SymmetricGroup(d);
    a:=List(GeneratorsOfGroup(weyl),x->PermutationMat(x,d,GF(f)));
    for i in [1..Length(a)] do
      if not IsOne(DeterminantMat(a[i])) then
        a[i][1]:=-a[i][1];
      fi;
    od;
    weyl:=Group(a);
    weyl:=Image(act,weyl);

  elif a.idSimple.series="C" or
    #B(n,2^m) ~ C(n,2^m)
    (a.idSimple.series="B" and
      SmallestPrimeDivisor(a.classicalId.parameter[2])=2) then
    d:=a.idSimple.parameter[1];
    f:=a.idSimple.parameter[2];
    group:=PSP(2*d,f);
    act:=group!.actionHomomorphism;

    g:=Source(act);
    sy:=SylowSubgroup(g,SmallestPrimeDivisor(f));
    sy:=Image(act,sy);
    borel:=Normalizer(group,sy);

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
    weyl:=List(a,x->ImagesRepresentative(act,x));
    b:=PermutationMat((d,d+1),2*d,GF(f));
    b[d+1]:=-b[d+1];
    Add(weyl,ImagesRepresentative(act,b));
    weyl:=Group(weyl);
    if group<>ClosureGroup(borel,weyl) then Error("wrong BN");fi;

  else
    TryNextMethod();
  fi;
  iso:=BNnyRewritingPresentation(group,borel,weyl);
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
      r:=Complementclasses(s,sub[1]);
      if Length(r)>0 then
        s:=r[1];
      fi;
      r:=BNnyRewritingPresentation(G,l,s);
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
        Length(Set(List(Elements(s),
          x->PositionProperty(dc,y->x in y))))=Length(dc) then
        r:=BNnyRewritingPresentation(G,l,s);
        if r<>fail then return r;fi;
      fi;
    od;
  od;

  TryNextMethod();
end);
