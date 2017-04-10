#############################################################################
##
#W  gpfpiso.gi                  GAP library                      Bettina Eick
#W                                                           Alexander Hulpke
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2004 The GAP Group
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
    return IsomorphismFpGroupByChiefSeries( G, nam );
end );

InstallOtherMethod( IsomorphismFpGroup,"for simple solvable permutation groups",
  true,
  [IsPermGroup and IsSimpleGroup and IsSolvableGroup,IsString],0,
function(G,str)
  return IsomorphismFpGroupByPcgs( Pcgs(G), str );
end);

InstallOtherMethod( IsomorphismFpGroup,"for simple permutation groups",true,
  [IsPermGroup and IsSimpleGroup,IsString],0,
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
  return IsomorphismFpGroupByGeneratorsNC( G, gens, str:chunk );
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

    IsSimpleGroup(H); #ensure H knows to be simple, thus the call to
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
	IsSimpleGroup(H);
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
    return iso;
end );

#############################################################################
##
#M  IsomorphismFpGroupByChiefSeriesFactor( G, str, N )
##
InstallGlobalFunction(IsomorphismFpGroupByChiefSeriesFactor,
function(g,str,N)
  local ser, ab, homs, gens, idx, start, pcgs, hom, f, fgens, auts, sf, orb, tra, j, a, ad, lad, n, fg, free, rels, fp, vals, dec, still, lgens, ngens, nrels, nvals, p, dodecomp, decomp, hogens, di, i, k, l, m;
  if Size(g)=1 then
    # often occurs in induction base base
    return
    GroupHomomorphismByFunction(g,TRIVIAL_FP_GROUP,x->One(TRIVIAL_FP_GROUP),x->One(g):noassert);
  elif g=N then
    # often occurs in induction base base
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
  ab:=[];
  homs:=[];
  gens:=[];
  idx:=[];
  for i in [2..Length(ser)] do
    start:=Length(gens)+1;
    if HasAbelianFactorGroup(ser[i-1],ser[i]) then
      ab[i-1]:=true;
      pcgs:=ModuloPcgs(ser[i-1],ser[i]);
      homs[i-1]:=pcgs;
      Append(gens,pcgs);
    else
      ab[i-1]:=false;
      hom:=NaturalHomomorphismByNormalSubgroup(ser[i-1],ser[i]:noassert);
      IsOne(hom);
      f:=Image(hom);
      # knowing simplicity makes it easy to test whether a map is faithful
      if IsSimpleGroup(f) then
	if IsPermGroup(f) and
	  NrMovedPoints(f)>SufficientlySmallDegreeSimpleGroupOrder(Size(f)) then
	  hom:=hom*SmallerDegreePermutationRepresentation(f);
	fi;
      elif IsPermGroup(f) then
	hom:=hom*SmallerDegreePermutationRepresentation(f);
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
      SetIsSimpleGroup(sf,true);
      IsNaturalAlternatingGroup(sf);
      a:=IsomorphismFpGroup(sf:noassert);
      ad:=List(GeneratorsOfGroup(Range(a)),i->PreImagesRepresentative(a,i));
      lad:=Length(ad);

      n:=Length(orb);
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
      p:=RelativeOrders(pcgs)[1];
      # define function in function to preserve local variables
      dodecomp:=function(ngens,pcgs)
		 return elm ->
		   LinearCombinationPcgs(ngens,ExponentsOfPcElement(pcgs,elm));
		end;
      decomp:=dodecomp(ngens,pcgs);
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
    else
      hom:=homs[i-1];
      hogens:=FreeGeneratorsOfFpGroup(Range(hom));
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
      for k in [1..Length(ngens)] do
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
  di:=rec(gens:=gens,fp:=fp,idx:=idx,dec:=dec,source:=g);
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

  hom!.decompinfo:=`di;
  SetIsWordDecompHomomorphism(hom,true);
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

  hom2!.decompinfo:=`di;
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
      hom!.decompinfo:=`di;
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
    return iso;
end);

InstallOtherMethod( IsomorphismFpGroupBySubnormalSeries, "for groups", true,
               [IsPermGroup, IsList], 0,
function( G, series )
    return IsomorphismFpGroupBySubnormalSeries( G, series, "F" );
end);

#############################################################################
##
#E

