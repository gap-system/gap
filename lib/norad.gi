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
##  This file contains functions that compute normalizers by the
##  fitting-free/solvable radical method. It can be competitive even in the case
##  of certain permutation groups.
##

BindGlobal("TwoLevelStabilizer",
  function(gens,imgs,acts,pcgs,pcgsacts,quot,pnt,domain,act)
local d,orb,len,S,depths,rel,stb,img,pos,i,j,k,ii,po,rep,sg,sf,sfs,fr,first,
      fra,blp,bli,terminate,induce,ind,Sact,gpsz,stabsz,pcgstabsz,stopsz,divs,
      brutelimit,permact,pacthom,good,lpos,actrange;

  first:=true;
  gpsz:=Size(Group(imgs,()))*Product(RelativeOrders(pcgs));
  divs:=Reversed(DivisorsInt(gpsz));
  Add(divs,0); # to deal with factor 1
  stopsz:=First(divs,x->x<gpsz)+1;

  terminate:=ValueOption("terminate");
  induce:=ValueOption("induce");
  actrange:=ValueOption("actrange");
  if not IsList(actrange) then
    actrange:=[1..Length(pcgs)];
  fi;

  pnt:=Immutable(pnt);
  if domain=false then
    d:=NewDictionary(pnt,true,
      DomainForAction(pnt,Concatenation(acts,pcgsacts),act));
  else
    d:=NewDictionary(pnt,true,domain);
  fi;
  orb:=[pnt];
  AddDictionary(d,pnt,1);

  # start with orbit via pcgs

  len := ListWithIdenticalEntries( Length( pcgs ) + 1, 0 );
  len[ Length( len ) ] := 1;
  S := Reversed(pcgs{Difference([1..Length(pcgs)],actrange)});
  Sact := Reversed(pcgsacts{Difference([1..Length(pcgs)],actrange)});
  depths:=[];
  rel := [  ];
  for i  in Reversed( actrange )  do
    Info(InfoFitFree,4,"PcgsOrbit ",i," ",Length(orb));
    img := act( pnt, pcgsacts[ i ] );
    #MakeImmutable(img);
    pos := LookupDictionary( d, img );
    if pos = fail  then

      # The current generator moves the orbit as a block.
      Add( orb, img );
      AddDictionary(d,img,Length(orb));

      for j  in [ 2 .. len[ i + 1 ] ]  do
        img := act( orb[ j ], pcgsacts[ i ] );
        Add( orb, img );
        AddDictionary(d,img,Length(orb));
      od;
      for k  in [ 3 .. RelativeOrders( pcgs )[ i ] ]  do
        for j  in Length( orb ) + [ 1 - len[ i + 1 ] .. 0 ]  do
          img := act( orb[ j ], pcgsacts[ i ] );
          Add( orb, img );
          AddDictionary(d,img,Length(orb));
        od;
      od;

    else

      # The current generator leaves the orbit invariant.
      stb := ListWithIdenticalEntries( Length( pcgs ), 0 );
      stb[ i ] := 1;
      ii := i + 2;
      while pos <> 1  do
        while len[ ii ] >= pos  do
          ii := ii + 1;
        od;
        stb[ ii - 1 ] := -QuoInt( pos - 1, len[ ii ] );
        pos := ( pos - 1 ) mod len[ ii ] + 1;
      od;
      Add( S, LinearCombinationPcgs( pcgs, stb ) );
      Add(Sact,LinearCombinationPcgs(pcgsacts,stb));
      Add(depths,i);
      Add( rel, RelativeOrders( pcgs )[ i ] );
    fi;
    len[ i ] := Length( orb );

  od;
  pcgstabsz:=Product(rel);
  stabsz:=pcgstabsz;

  # now S is the pcgs part of the stabilizer

  # continue forming group orbit
  po:=Length(orb);
  Info(InfoFitFree,3,"solvorb=",po);

  rep:=[[]];
  sg:=[];
  sf:=[];
  sfs:=TrivialSubgroup(Image(quot));

  brutelimit:=infinity;

  if induce<>fail then
    ind:=Action(Group(Sact),induce.obj,induce.action);
#    if Size(ind)>=induce.stop then
#      return rec(byinduced:=true,
#       gens:=sg,imgs:=sf,pcgs:=Reversed(S),orblen:=Length(orb));
#    fi;

    if IsBound(induce.allobj) and induce.allobj<>fail then
      brutelimit:=Length(induce.allobj)*10;
    fi;

  fi;

  i:=1;
  while i<=Length(orb) do

    for j in [1..Length(gens)] do
      img := act(orb[i],acts[j]);
      pos := LookupDictionary(d,img);
      bli:=(i-1)/po+1;
      if pos = fail  then
        # The current generator moves the orbit as a block.
        Add(orb,img);
        AddDictionary(d,img,Length(orb));
        fr:=Concatenation(rep[bli],[j]);
        Add(rep,fr);
        if terminate<>fail and Length(rep)>terminate then
          return fail;
        fi;
        for k in [i+1..i+po-1] do
          img:=act(orb[k],acts[j]);
  #F if LookupDictionary(d,img)<>fail then Error("err3");fi;
          Add(orb,img);
          AddDictionary(d,img,Length(orb));
        od;

        # should we give in?
        if Length(orb)>brutelimit then

          orb:=[];d:=1; #clean memory

          # projective action is fine, as we want to fix space
          Info(InfoFitFree,1,"act on whole space, fix in perm action");
          permact:=Action(GroupWithGenerators(Concatenation(acts,pcgsacts)),
            induce.allobj,induce.allact);
          i:=Concatenation(
            List([1..Length(gens)], x->DirectProductElement([gens[x],imgs[x]])),
            List(pcgs, x->DirectProductElement([x,One(imgs[1])])));
          pacthom:=GroupHomomorphismByImagesNC(GroupWithGenerators(i),permact,i,
                    GeneratorsOfGroup(permact));

          lpos:=List(induce.lvecs,x->Position(induce.allobj,x));

          # we don't care about the actual subgroup, just the inducing elements
          good:=[];
          SubgroupProperty(induce.subact,
                  function(x)
                  local r;
                    r:=RepresentativeAction(permact,lpos,Permuted(lpos,x),OnTuples);
                    if r<>fail then Add(good,r);fi;
                    return r<>fail;
                  end);
          good:=List(good,x->PreImagesRepresentative(pacthom,x));

          good:=Filtered(good,x->not IsOne(x[2]));

          return rec(byinduced:=true,
            gens:=List(good,x->x[1]),imgs:=List(good,x->x[2]),
              pcgs:=Reversed(S));

        fi;

      else
        # get stabilizing element
        blp:=QuoInt((pos-1),po)+1; # which block position are we?

        # now recalculate the representative in factor group
        fr:=One(sfs);
        for k in rep[bli] do
          fr:=fr*imgs[k];
        od;
        fr:=fr*imgs[j];
        for k in Reversed(rep[blp]) do
          fr:=fr/imgs[k];
        od;

        if not fr in sfs then
          # is it a new element for the factor? (If not, we don't need it,
          # since we know the Pcgs-part of the stabilizer.)
          sfs:=ClosureGroup(sfs,fr);
          stabsz:=pcgstabsz*Size(sfs);
          stopsz:=First(divs,x->x<gpsz/stabsz)+1;
#Print("found stab from ",i,":",pos," in ",Length(orb), " vs ",gpsz/stabsz,"\n");
          Add(sf,fr);
          fr:=One(gens[1]);
          for k in rep[bli] do
            fr:=fr*gens[k];
          od;
          fr:=fr*gens[j];
          for k in Reversed(rep[blp]) do
            fr:=fr/gens[k];
          od;

          # now we need to find the correct s-part.
          fra:=One(acts[1]);
          for k in rep[bli] do
            fra:=fra*acts[k];
          od;
          fra:=fra*acts[j];
          for k in Reversed(rep[blp]) do
            fra:=fra/acts[k];
          od;
          img:=act(pnt,fra); # that's where fr now maps it to

          # find correcting pcgs element
          pos:=LookupDictionary(d,img);

          stb := ListWithIdenticalEntries( Length( pcgs ), 0 );
          ii := 1;
          while pos <> 1  do
            while len[ ii ] >= pos  do
              ii := ii + 1;
            od;
            stb[ ii - 1 ] := -QuoInt( pos - 1, len[ ii ] );
            pos := ( pos - 1 ) mod len[ ii ] + 1;
          od;
          # now stb is the exponents of the correcting element.

          fr:=fr*LinearCombinationPcgs(pcgs,stb);
          Add(sg,fr);

          if induce<>fail then
            fra:=fra*LinearCombinationPcgs(pcgsacts,stb);
            ind:=ClosureGroup(ind,Permutation(fra,induce.obj,induce.action));
          fi;
        fi;
      fi;

    od;
    i:=i+po; # can jump in Pcgs-orbit steps, as we always form all p-images

    # ensure at least all generators have been applied
    if induce<>fail and Size(ind)>=induce.stop then

      if ValueOption("orbit")=true then
        return rec(byinduced:=true,
          gens:=sg,imgs:=sf,pcgs:=Reversed(S),orblen:=Length(orb),orbit:=orb);
      else
        return rec(byinduced:=true,
          gens:=sg,imgs:=sf,pcgs:=Reversed(S),orblen:=Length(orb));
      fi;

    elif Length(orb)>stopsz and first=true then
      Info(InfoFitFree,2,"orblen=",gpsz/stabsz,
         ", early break ",Length(orb)," from ",po);
      first:=rec(
        gens:=sg,imgs:=sf,pcgs:=Reversed(S),orblen:=gpsz/stabsz);
      if ValueOption("orbit")=true then
        first.orbit:=orb;
      fi;
      return first;
    fi;
  od;

  Info(InfoFitFree,2,"orblen=",Length(orb)," from ",po);
  S:=rec(gens:=sg,imgs:=sf,pcgs:=Reversed(S),orblen:=Length(orb));
  #if first<>true and first<>S then Error("LEAR"); fi;
  if ValueOption("orbit")=true then
    S.orbit:=orb;
  fi;
  return S;

end);

BindGlobal("TwoLevelSubspaceCentralizer",
  function(ng,nf,ngm,np,npm,factorhom,sub,mpcgs,dual)
local i,stb;

  for i in sub do
    stb:=TwoLevelStabilizer(ng,nf,ngm,np,npm,factorhom,i,false,OnRight);
    ng:=stb.gens;
    nf:=stb.imgs;
    np:=InducedPcgsByPcSequenceNC(np,stb.pcgs);
    stb:=LinearActionLayer(Concatenation(ng,np),mpcgs);
  #F if Length(sub[1])<>Length(stb[1]) then Error("heh!");fi;
    ngm:=stb{[1..Length(ng)]};
    npm:=stb{[Length(ng)+1..Length(stb)]};
    if dual then
      ngm:=List(ngm,x->TransposedMat(x^-1));
      npm:=List(npm,x->TransposedMat(x^-1));
    fi;

  od;
  return rec(gens:=ng,imgs:=nf,pcgs:=np);
end);

BindGlobal("RealizeAffineAction",function(allgens,sub,sel,f,myact)
local expandvec,bassrc,basimg,transl,getbasimg,gettransl,myact2;

  expandvec:=function(v)
    local z;
    z:=ShallowCopy(Zero(sub));
    z{sel}:=v;
    MakeImmutable(z);
    return z;
  end;
  allgens:=ShallowCopy(allgens);
  bassrc:=[];
  basimg:=List(allgens,x->[]);
  transl:=[];
  # lazy evaluators
  getbasimg:=function(a,b)
    if not IsBound(basimg[a][b]) then
      basimg[a][b]:=myact(expandvec(bassrc[b]),allgens[a]){sel}-gettransl(a);
#Print("assign ",a," ",b,"\n");
      MakeImmutable(basimg[a][b]);
    fi;
    return basimg[a][b];
  end;
  gettransl:=function(a)
    if not IsBound(transl[a]) then
      transl[a]:=myact(Zero(sub),allgens[a]){sel};
      MakeImmutable(transl[a]);
    fi;
    return transl[a];
  end;

  myact2:=function(fv,g)
  local p,v,sol,i;
    p:=Position(allgens,g);
    if p=fail then
      #Print("IMAGE\n");
      Add(allgens,g);
      p:=Length(allgens);
    fi;
    if not IsBound(basimg[p]) then
      basimg[p]:=[];
    fi;
    if Length(bassrc)=0 then
      sol:=fail;
    else
      sol:=SolutionMat(bassrc,fv);
    fi;
    if sol=fail then
      Add(bassrc,Immutable(fv));
      sol:=List(bassrc,x->Zero(f));
      sol[Length(bassrc)]:=One(f);
    fi;
    v:=Zero(fv);
#Print("A\n");
    for i in [1..Length(sol)] do
      if not IsZero(sol[i]) then
        v:=v+sol[i]*getbasimg(p,i);
      fi;
    od;
    v:=v+gettransl(p);
    #v:=Sum([1..Length(sol)],x->sol[x]*getbasimg(p,x))+gettransl(p);

    #if v<>myact(expandvec(fv),g){sel} then Error("nonaffine");fi;
    return v;
  end;

  return myact2;
end);

# main normalizer routine
InstallGlobalFunction(NormalizerViaRadical,function(G,U)
local sus,ser,len,factorhom,uf,n,d,up,mran,nran,mpcgs,pcgs,pcisom,nf,ng,np,sub,
  central,f,ngm,npm,no2pcgs,part,stb,mods,famo,nopcgs,uff,ufg,prev,
  ufr,dims,vecs,ovecs,vecsz,l,prop,properties,clusters,clusterspaces,
  fs,i,v1,o1,p1,
  orblens,stabilizespaceandupdate,dual,myact,bound,boundbas,ranges,j,module,sumos,
  minimalsubs,localinduce,lmpcgs,nonzero,sel,myact2,tailnum,lfamo;

#timer:=List([1..15],x->0);
  localinduce:=function(seq)
    if Length(seq)=Length(pcgs) then
      return pcgs;
    else
      return InducedPcgsByPcSequenceNC(pcgs,seq);
    fi;
  end;

  stabilizespaceandupdate:=function(space)
  local localgl,stb,glhom,glperm,glact,clu,stabsz,cent,lvecs,idx,
        localclust,subact,xlvecs;
    localgl:=GL(Dimension(space),f);
    subact:=fail; lvecs:=fail;xlvecs:=fail;
    if Size(localgl)=1 or vecs=fail then
      localclust:=[];
      stabsz:=Size(localgl);
    else
      lvecs:=NormedRowVectors(f^Dimension(space));
      clu:=BasisVectors(Basis(space));
      xlvecs:=List(lvecs,x->OnLines(x*clu,One(npm[1])));
      # for each local vector the position in vecs
      idx:=List(xlvecs,x->Position(vecs,x));

      # clusters as relevant for this subspace
      localclust:=List(clusters,x->Filtered([1..Length(lvecs)],y->idx[y] in x));
      SortBy(localclust, Length);

      glhom:=IsomorphismPermGroup(localgl);
      glperm:=Image(glhom);
      glact:=ActionHomomorphism(glperm,lvecs,
        GeneratorsOfGroup(glperm),
        List(GeneratorsOfGroup(glperm),
          x->PreImagesRepresentative(glhom,x)),
        OnLines,"surjective");
      stb:=Image(glact);
      for clu in localclust do
        stb:=Stabilizer(stb,clu,OnSets);
      od;
      subact:=stb;
      stb:=PreImage(glact,stb);
      stabsz:=Size(stb);
    fi;
    Info(InfoFitFree,3,"clustersub=",Collected(List(localclust,Length)),
      stabsz);

    # act on subspace but use maximal induced action size as terminator
    stb:=TwoLevelStabilizer(ng,nf,ngm,np,npm,factorhom,
          Concatenation(TriangulizedMat(BasisVectors(Basis(space)))),
          false,
          OnSubspacesByCanonicalBasisConcatenations:
        induce:=rec(obj:=AsSSortedList(space),
                    subact:=subact,allobj:=ovecs,allact:=OnLines,
                    lvecs:=xlvecs,
                    action:=OnRight,
                    stop:=stabsz));


    if IsBound(stb.byinduced) then
      Info(InfoFitFree,2,"early stop by induced action ",stabsz);

      # add centralizing elements in factor (don't need pcgs part
      # since we always compute full pcgs orbit and thus have it)
      # in (unlikely) case they are missing.
      cent:=TwoLevelSubspaceCentralizer(ng,nf,ngm,np,npm,
                factorhom,BasisVectors(Basis(space)),lmpcgs,dual:induce:=fail);
      nf:=Group(stb.imgs,One(Image(factorhom)));
      np:=Filtered([1..Length(cent.imgs)],x->not x in nf);
      Info(InfoFitFree,2,"added centralizers ",np);
      Append(stb.gens,cent.gens{np});
      Append(stb.imgs,cent.imgs{np});
    fi;
    ng:=stb.gens;
    nf:=stb.imgs;
    np:=localinduce(stb.pcgs);
  end;

#timer[1]:=Runtime()-timer[1];

  ovecs:=fail;

  sus:=FittingFreeSubgroupSetup(G,U);
  ser:=sus.parentffs;
  factorhom:=ser.factorhom;

  # first work in radical factor
  #TODO use socle of radical factor

  uf:=Image(sus.rest);
  ufr:=SolvableRadical(uf);
  Info(InfoFitFree,1,"Radsize= ",Size(ufr)," index ",Index(uf,ufr));

  uff:=SmallGeneratingSet(uf);
  ufg:=List(uff,x->PreImagesRepresentative(sus.rest,x));

  n:=Normalizer(Image(factorhom),uf);

  pcgs:=ser.pcgs;
  pcisom:=ser.pcisom;
  len:=Length(pcgs);

  # generators of derived subgroup help with quickly getting stabilizers
  if not IsPerfectGroup(n) then
    d:=Reversed(DerivedSeriesOfGroup(n));
    nf:=[];
    l:=TrivialSubgroup(n);
    for i in d do
      for j in SmallGeneratingSet(i) do
        if not j in l then
          Add(nf,j);
          l:=ClosureGroup(l,j);
        fi;
      od;
    od;
  else
    nf:=SmallGeneratingSet(n);
  fi;

  ng:=List(nf,x->PreImagesRepresentative(factorhom,x));
  np:=pcgs;

  up:=sus.pcgs;

  prev:=ser.pcgs;

  mods:=[]; # collect modulo pcgs for up steps -- they are to be used again

  for d in [2..Length(ser.depths)] do

    # number of pcgs generators in the kernel
    tailnum:=Maximum(0,Length(pcgs)-ser.depths[d]);

    mran:=[ser.depths[d-1]..len];
    nopcgs:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran});
    nran:=[ser.depths[d]..len];
    no2pcgs:=InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});

    mpcgs:=nopcgs mod no2pcgs;
    mods[d]:=mpcgs;

    f:=GF(RelativeOrders(mpcgs)[1]);

    central:= ForAll(GeneratorsOfGroup(G),
                i->ForAll(mpcgs,
                  j->DepthOfPcElement(pcgs,Comm(i,j))>=ser.depths[d]));

    # abelian factor, use affine methods
    Info(InfoFitFree,1,"abelian factor ",d,": ",
      Product(RelativeOrders(ser.pcgs){mran}), "->",
      Product(RelativeOrders(ser.pcgs){nran})," central:",central);

    # step up via depths
    for j in [d-1,d-2..1] do

      # the part of U-pcgs in this step
      part:=up{[sus.serdepths[j]..sus.serdepths[d]-1]};


      if j=d-1 then
        Info(InfoFitFree,2,"down");
        # down step -- stabilize the subspace

        # determine layer action
        stb:=LinearActionLayer(Concatenation(ng,np),mpcgs);
        ngm:=stb{[1..Length(ng)]};
        npm:=stb{[Length(ng)+1..Length(stb)]};

        # work in quotient modules first
        module:=GModuleByMats(Concatenation(ngm,npm),f);
        sumos:=Reversed(MTX.BasesCompositionSeries(module));
        Info(InfoFitFree,2,"module layers ",List(sumos,Length));
        sumos:=sumos{[2..Length(sumos)]};

        for fs in sumos do
          if Length(fs)=0 then
            # whole module
            lmpcgs:=mpcgs;
          else
            lmpcgs:=nopcgs mod InducedPcgsByGeneratorsNC(pcgs,
              Concatenation(no2pcgs,
                List(fs,x->PcElementByExponentsNC(mpcgs,x))));
          fi;

          # avoid duplication if irreducible
          if Length(sumos)>1 then
            # determine layer action
            stb:=LinearActionLayer(Concatenation(ng,np),lmpcgs);
            ngm:=stb{[1..Length(ng)]};
            npm:=stb{[Length(ng)+1..Length(stb)]};
          fi;

          # determine subspace
          sub:=List(part,x->ExponentsOfPcElement(lmpcgs,x)*One(f));
          TriangulizeMat(sub);
          sub:=Filtered(sub,x->not IsZero(x));

          Info(InfoFitFree,2,"module of dimension ",Length(lmpcgs),
               " subspace ",Length(sub));

          if Length(sub)>0 and Length(sub)<Length(lmpcgs) then

            dual:=false;
            if Length(sub)>Length(sub[1])/2 then
              # dualize to act on smaller objects
              Info(InfoFitFree,2,"dualize");
              dual:=true;
              sub:=List(NullspaceMat(TransposedMat(sub)),ShallowCopy);
              TriangulizeMat(sub);
              ngm:=List(ngm,x->TransposedMat(x^-1));
              npm:=List(npm,x->TransposedMat(x^-1));
            fi;
            # stabilize the subspace
            sub:=ImmutableMatrix(f,sub);

            module:=GModuleByMats(Concatenation(ngm,npm),f);
            minimalsubs:=
              List(MTX.BasesMinimalSubmodules(module),x->VectorSpace(f,x));

            if GaussianCoefficient(Length(sub[1]),Length(sub),Size(f))>5*10^5
              and Size(f)^Length(sub)/(Size(f)-1)<10000
              and Size(f)^Length(sub)/(Size(f)-1)<2000 then

              # is the calculation potentially expensive?

              # first try the naive way
              stb:=TwoLevelStabilizer(ng,nf,ngm,np,npm,factorhom,
                    Concatenation(sub),false,
                    OnSubspacesByCanonicalBasisConcatenations:terminate:=200,
                    actrange:=[1..Length(np)-tailnum]);

              if stb=fail then

                # it failed. Now get vectors
                Info(InfoFitFree,2,"use vectors of ",Size(f)^Length(sub));

                # 1-dim subspaces
                vecs:=NormedRowVectors(VectorSpace(f,sub));
                if Size(f)^Length(sub[1])/(Size(f)-1)<500000 then
                  ovecs:=NormedRowVectors(f^Length(sub[1]));
                fi;

                properties:=[];
                orblens:=[];
                for l in [1..Length(vecs)] do
                  prop:=[];
                  if IsBound(orblens[l]) then
                    Add(prop,orblens[l]);
                  else
                    o1:=TwoLevelStabilizer(ng,nf,ngm,np,npm,factorhom,vecs[l],
                          false, OnLines:orbit,
                          actrange:=[1..Length(np)-tailnum]);
                    Add(prop,o1.orblen);
                    for v1 in o1.orbit do
                      p1:=Position(vecs,v1);
                      if p1<>fail then
                        orblens[p1]:=o1.orblen;
                      fi;
                    od;

                  fi;
                  Add(prop,Filtered([1..Length(minimalsubs)],
                    y->vecs[l] in minimalsubs[y]));
                  if Length(fs)=0 and Length(nran)=0 and dual=false then
                    # subspace is proper subgroup
                    if IsPermGroup(G) then
                      Add(prop,
                        CycleStructurePerm(PcElementByExponentsNC(mpcgs,vecs[l])));
                    fi;
                  fi;
                  Add(properties,prop);
                od;

                prop:=Set(properties);
                clusters:=List(prop,x->Filtered([1..Length(vecs)],
                  y->properties[y]=x));

                if Length(vecs)>10 and Minimum(List(clusters,Length))>1 then
                  # refine clusters by using the additive structure of the vector
                  # space: test for each element x how often x+c*y lies in which
                  # cluster where y runs through the elements in some cluster and c
                  # running through all nonzero scalars.

                  # reverse lookup list
                  nonzero:=Difference(AsSSortedList(f),[Zero(f)]);
                  dims:=List([1..Length(vecs)],
                    x->PositionProperty(clusters,y->x in y));
                  Info(InfoFitFree,3,"clusters=",
                    Collected(List(clusters,Length)));

                  # sum could be 0
                  vecsz:=Concatenation(vecs,[Zero(vecs[1])]);
                  Add(dims,-1);

                  i:=1;
                  while i<=Length(clusters) do
                    l:=i;
                    while l<=Length(clusters) do
                      # try sums of i with j for split
                      prop:=[];
                      for v1 in clusters[i] do
                        Add(prop,Collected(Concatenation(List(clusters[l],x->
                          List(nonzero,nz->
                            dims[Position(vecsz,
                              NormedRowVector(vecs[v1]+nz*vecs[x]))])))));
                      od;
                      if Length(Set(prop))>1 then
                        # split up using this multiplication data
                        prop:=List(Set(prop),
                          x->Filtered([1..Length(prop)],y->prop[y]=x));
                        SortBy(prop, Length);
                        Info(InfoFitFree,5,"split ",clusters[i]," with ",l,":",prop);
                        clusters:=Concatenation(clusters{[1..i-1]},
                                  List(prop,x->clusters[i]{x}),
                                  clusters{[i+1..Length(clusters)]});
                        # don't increment l as we try again
                      else
                        l:=l+1;
                      fi;

                    od;
                    i:=i+1;
                  od;
                  Info(InfoFitFree,3,"refined clusters=",
                    Collected(List(clusters,Length)));
                fi;

                clusterspaces:=List([1..Length(clusters)],x->
                  VectorSpace(f,vecs{clusters[x]}));
                dims:=List(clusterspaces,Dimension);
                SortParallel(dims,clusterspaces);

                for l in Filtered(clusterspaces,x->Dimension(x)<Length(sub)) do
                  Info(InfoFitFree,2,
                      "first stabilize subspace of dimension ",
                      Dimension(l)," of ",Length(sub)," in ",Length(sub[1]));

                  stabilizespaceandupdate(l);

                  stb:=LinearActionLayer(Concatenation(ng,np),lmpcgs);
                  ngm:=stb{[1..Length(ng)]};
                  npm:=stb{[Length(ng)+1..Length(stb)]};
                  if dual then
                    ngm:=List(ngm,x->TransposedMat(x^-1));
                    npm:=List(npm,x->TransposedMat(x^-1));
                  fi;
                od;
              else
                vecs:=fail;
              fi;
              Info(InfoFitFree,2,
                  "now stabilize full space of dimension ",
                  Length(sub)," in ",Length(sub[1]));

              # proper space stabilizer
              stabilizespaceandupdate(VectorSpace(f,sub));

            else
              vecs:=fail;
              Info(InfoFitFree,2,
                  "Only stabilize space of dimension ",
                  Length(sub)," in ",Length(sub[1]));
              stabilizespaceandupdate(VectorSpace(f,sub));
            fi;
          fi;
        od;

        # calculate modulo pcgs for ``mpcgs mod part'' for following up steps


        part:=CanonicalPcgs(InducedPcgsByGeneratorsNC(pcgs,Concatenation(up,no2pcgs)));
        if Length(part)>0 then
          famo:=prev mod part;
          IndicesEANormalSteps(NumeratorOfModuloPcgs(famo));
        else
          famo:=prev;
        fi;
        prev:=part;

      else
        # up step

        part:=CanonicalPcgs(InducedPcgsByPcSequenceNC(pcgs,part));

        #add: for any depth changed from last time.
        if Length(part)>0 and Length(famo)>0 and
          DepthOfPcElement(pcgs,part[1])<ser.depths[j+1]
          then

          # Act on complements by action on 1-cohomology group

          ranges:=List([1..Length(part)],
            x->[(x-1)*Length(famo)+1..x*Length(famo)]);

          sub:=Concatenation(List(part,a->List(famo,x->Zero(f))));

          # coboundaries
          boundbas:=List(famo,x->Concatenation(List(part,
                   y->ExponentsOfPcElement(famo,Comm(y,x))*One(f))));
          boundbas:=ImmutableMatrix(f,boundbas);
          bound:=List(boundbas,ShallowCopy);
          TriangulizeMat(bound);
          bound:=Basis(VectorSpace(f,bound));

          if Length(bound)<Length(sub) then
            Info(InfoFitFree,2,"up ",j,":",
              Product(RelativeOrders(part))," on ",
              Product(RelativeOrders(famo))," cobounds:",Size(f)^Length(bound)
              );

            myact:=function(l,gen)
              l:=List([1..Length(part)],
                x->part[x]*PcElementByExponentsNC(famo,l{ranges[x]}));
              l:=List([1..Length(part)],x->l[x]^gen);

              l:=CanonicalPcgs(InducedPcgsByGeneratorsNC(pcgs,l));

              l:=List([1..Length(part)],
                x->ExponentsOfPcElement(famo, LeftQuotient(part[x],l[x]))*One(f));
              l:=Concatenation(l);
              l:=SiftedVector(bound,l);
              ConvertToVectorRep(l,Size(f));
              MakeImmutable(l);
              return l;
            end;

            sub:=myact(sub,One(famo[1])); # standardize -- force compression

            if Length(bound)>0 then
              sel:=Filtered([1..Length(sub)],x->bound!.heads[x]=0);
            else
              sel:=[1..Length(sub)];
            fi;
            myact2:=RealizeAffineAction(Concatenation(ng,np),sub,sel,f,myact);

            # stabilize in cohomology group
            stb:=TwoLevelStabilizer(ng,nf,ng,np,np,factorhom,
                  sub{sel},f^Length(sel),myact2:
                            actrange:=[1..Length(np)-tailnum]);

            Info(InfoFitFree,2,"orblen=",stb.orblen);

            ng:=stb.gens;
            nf:=stb.imgs;
            np:=localinduce(stb.pcgs);
          fi;


          if Length(bound)>0 then
            #nontrivial blocks -- now correct

            myact:=function(l,gen)
              l:=List([1..Length(part)],
                x->part[x]*PcElementByExponentsNC(famo,List(l{ranges[x]},Int)));
              l:=List([1..Length(part)],x->l[x]^gen);
              l:=CanonicalPcgs(InducedPcgsByGeneratorsNC(pcgs,l));

              l:=List([1..Length(part)],
                x->ExponentsOfPcElement(famo,
                  LeftQuotient(part[x],l[x]))*One(f));
              l:=Concatenation(l);
              ConvertToVectorRep(l,Size(f));
              MakeImmutable(l);
              return l;
            end;

            # as corrections involve only pcgs parts, the images in the
            # radical factor are not affected.
            ng:=List(ng,x->x/PcElementByExponents(famo,
              SolutionMat(boundbas,myact(sub,x))));

            np:=InducedPcgsByGeneratorsNC(pcgs,
                  Concatenation(
                    List(np{[1..Length(np)-tailnum]},
                      x->x/PcElementByExponents(famo,
                         SolutionMat(boundbas,myact(sub,x)))),
              np{[Length(np)-tailnum+1..Length(np)]}));
            Assert(1,ForAll(ng,x->myact(sub,x)=sub));
            Assert(1,ForAll(np,x->myact(sub,x)=sub));


          fi;

        fi;

      fi;


    od;

    # act on cohomology in topmost step

    part:=ufg;

    if Length(part)>0 and Length(famo)>0 then

      #old: lfamo:=famo;

      # calculate cohomology for quotient modules first to reduce orbit lengths
      module:=GModuleByMats(LinearActionLayer(Concatenation(ng,np),famo),f);
      sumos:=Reversed(MTX.BasesCompositionSeries(module));
      sumos:=sumos{[2..Length(sumos)]};
      Info(InfoFitFree,2,"Module layers ",List(sumos,Length));

      p1:=0;
      o1:=1;
      repeat
        p1:=p1+1;
        while p1<Length(sumos) and Length(sumos[o1])-Length(sumos[p1+1])<10 do
          p1:=p1+1;
        od;

        sub:=List(sumos[p1],x->PcElementByExponents(famo,x));
        sub:=InducedPcgsByGeneratorsNC(NumeratorOfModuloPcgs(famo),Concatenation(DenominatorOfModuloPcgs(famo),sub));
        lfamo:=NumeratorOfModuloPcgs(famo) mod sub;

        Info(InfoFitFree,3,"Factor ",p1," Module ",Length(lfamo));

        ranges:=List([1..Length(part)],
          x->[(x-1)*Length(lfamo)+1..x*Length(lfamo)]);

        sub:=Concatenation(List(part,a->List(lfamo,x->Zero(f))));

        # coboundaries
        boundbas:=List(lfamo,x->Concatenation(List(part,
                  y->ExponentsOfPcElement(lfamo,Comm(y,x))*One(f))));
        boundbas:=ImmutableMatrix(f,boundbas);
        bound:=List(boundbas,ShallowCopy);
        TriangulizeMat(bound);
        bound:=List(bound,Zero);
        bound:=Basis(VectorSpace(f,bound));

        #TODO: unify with later code, requires slight change in print statement
        # and action
        Info(InfoFitFree,2,"up 0:", " on ",
          Product(RelativeOrders(lfamo))," cobounds:",Size(f)^Length(bound));

        myact:=function(l,gen)
          local pos,map;

          # make l  the conjugated generator list
          l:=List([1..Length(part)],
            x->part[x]*PcElementByExponentsNC(lfamo,l{ranges[x]}));
          l:=List([1..Length(part)],x->l[x]^gen);

          # when acting with radical elements, it centralizes in the factor
          pos:=Position(np,gen);
          if pos=fail then
            # not in the radical. There might be an induced automorphism of
            # the factor which we'll have to undo

            # find out what the images in the factor are by conjugating in the
            # factor. This is intended to avoid image calculations
            # (because we do not have `CanonicalPcgs')
            pos:=Position(ng,gen);
            if pos=fail then
              # nonstandard generator, must use image instead
              map:=ImagesRepresentative(ser.factorhom,gen);
              map:=List(uff,x->x^map);
            else
              map:=List(uff,x->x^nf[pos]);
            fi;

            # construct the map reps->preimages and map the gens we want (to work
            # in the right coordinates)
            map:=GroupGeneralMappingByImagesNC(uf,G,map,l);
            l:=List(uff,x->ImagesRepresentative(map,x));
          fi;

          #l:=List([1..Length(part)],x->LeftQuotient(part[x],l[x]));
          #l:=List(l,x->ExponentsOfPcElement(famo,x)*One(f));

          l:=List([1..Length(part)],
            x->ExponentsOfPcElement(lfamo, LeftQuotient(part[x],l[x]))*One(f));

          l:=Concatenation(l);
          l:=SiftedVector(bound,l);
          l:=ImmutableVector(f,l);
          return l;
        end;
        sub:=myact(sub,One(np[1])); # standardize -- force compression

        if Length(bound)>0 then
          sel:=Filtered([1..Length(sub)],x->bound!.heads[x]=0);
        else
          sel:=[1..Length(sub)];
        fi;
        myact2:=RealizeAffineAction(Concatenation(ng,np),sub,sel,f,myact);

        # stabilize in cohomology group
        stb:=TwoLevelStabilizer(ng,nf,ng,np,np,factorhom,sub{sel},
                f^Length(sel),myact2:
                actrange:=[1..Length(np)-tailnum]);

        Info(InfoFitFree,2,"orblen=",stb.orblen);

        ng:=stb.gens;
        nf:=stb.imgs;
        np:=localinduce(stb.pcgs);

        if Length(bound)>0 then
          #nontrivial blocks -- now correct

          myact:=function(l,gen)
            local pos,map;

            # make l  the conjugated generator list
            l:=List([1..Length(part)],
              x->part[x]*PcElementByExponentsNC(famo,l{ranges[x]}));
            l:=List([1..Length(part)],x->l[x]^gen);

            # when acting with radical elements, it centralizes in the factor
            pos:=Position(np,gen);
            if pos=fail then
              # not in the radical. There might be an induced automorphism of
              # the factor which we'll have to undo

              # find out what the images in the factor are by conjugating in the
              # factor. This is intended to avoid image calculations
              pos:=Position(ng,gen);
              if pos=fail then

                # must use image instead
                map:=ImagesRepresentative(ser.factorhom,gen);
                map:=List(uff,x->x^map);
              else
                map:=List(uff,x->x^nf[pos]);
              fi;

              # construct the map reps->preimages and map the gens we want (to work
              # in the right coordinates)
              map:=GroupGeneralMappingByImagesNC(uf,G,map,l);
              l:=List(uff,x->ImagesRepresentative(map,x));
            fi;

            l:=List([1..Length(part)],x->LeftQuotient(part[x],l[x]));
            l:=List(l,x->ExponentsOfPcElement(famo,x)*One(f));
            l:=Concatenation(l);
            return l;
          end;

          # as corrections involve only pcgs parts, the images in the
          # radical factor are not affected.
          ng:=List(ng,x->x/PcElementByExponents(famo,
            SolutionMat(boundbas,myact(sub,x))));
          np:=InducedPcgsByGeneratorsNC(pcgs,
            Concatenation(
              List(np{[1..Length(np)-tailnum]},x->x/PcElementByExponents(famo,
              SolutionMat(boundbas,myact(sub,x)))),
              np{[Length(np)-tailnum+1..Length(np)]}));
          Assert(1,ForAll(ng,x->myact(sub,x)=sub));
          Assert(1,ForAll(np,x->myact(sub,x)=sub));

        fi;

        o1:=p1;
      until p1=Length(sumos);

    fi;
  od;

  return SubgroupByFittingFreeData(G,ng,nf,np);

end);

InstallMethod( NormalizerOp,"solvable radical", IsIdenticalObj,
  [ IsGroup and CanComputeFittingFree, IsGroup],
  -1, # deliberate lower ranking to make sure this method only runs in cases
  # in which no more specialized method is installed. Once the method has
  # been used more broadly, and performance is better understood, this can
  # be changed to 0
function(G,U)
  # small pc groups fall back on generic -- don't trigger here!
  if IsPcGroup(G) then TryNextMethod();fi;
  return NormalizerViaRadical(G,U);
end);

