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
##  This file contains functions using the trivial-fitting paradigm.
##  They are representation independent and will work for permutation and
##  matrix groups
##

InstallGlobalFunction(AttemptPermRadicalMethod,function(G,T)
local R;
  if not IsPermGroup(G) then return fail;fi;

  if not (HasFittingFreeLiftSetup(G) or HasSolvableRadical(G)) then
    # do not force radical method if it was not tried
    return false;
  fi;

  # used in assertions
  if ValueOption("usebacktrack")=true then return false;
  elif ValueOption("useradical")=true then return true;fi;

  R:=SolvableRadical(G);

  # any chance to apply it, and not too small?
  if Size(R)=1 or Size(G)<10000 then return false; fi;

  if T="CENT" then
    # centralizer/element conjugacy -- degree compares well with radical
    # factor, but
    return NrMovedPoints(G)^2>Size(G)/Size(R);
  else
    # Task not yet covered
    return fail;
  fi;
end);

InstallMethod(DoFFSS,"generic",IsIdenticalObj,[IsGroup and IsFinite,IsGroup],0,
function(G,U)
local ffs,pcisom,rest,kpc,k,x,ker,r,pool,i,xx,pregens,iso;

  ffs:=FittingFreeLiftSetup(G);

  pcisom:=ffs.pcisom;

  #rest:=RestrictedMapping(ffs.factorhom,U);
  if IsPermGroup(U) and AssertionLevel()>1 then
    rest:=GroupHomomorphismByImages(U,Range(ffs.factorhom),GeneratorsOfGroup(U),
      List(GeneratorsOfGroup(U),x->ImagesRepresentative(ffs.factorhom,x)));
  else
    RUN_IN_GGMBI:=true; # hack to skip Nice treatment
    rest:=GroupHomomorphismByImagesNC(U,Range(ffs.factorhom),GeneratorsOfGroup(U),
      List(GeneratorsOfGroup(U),x->ImagesRepresentative(ffs.factorhom,x)));
    RUN_IN_GGMBI:=false;
  fi;
  Assert(1,rest<>fail);

  if HasRecogDecompinfoHomomorphism(ffs.factorhom) then
    SetRecogDecompinfoHomomorphism(rest,RecogDecompinfoHomomorphism(ffs.factorhom));
  fi;

  # in radical?
  if ForAll(MappingGeneratorsImages(rest)[2],IsOne) then
    ker:=U;
    # trivial radical
    if Length(ffs.pcgs)=0 then
      k:=[];
    else
      k:=InducedPcgsByGeneratorsNC(ffs.pcgs,GeneratorsOfGroup(U));
    fi;
  elif Length(ffs.pcgs)=0 then
    # no radical
    ker:=TrivialSubgroup(G);
    k:=ffs.pcgs;
  else
    iso:=IsomorphismFpGroup(Image(rest,U));
    pregens:=List(GeneratorsOfGroup(Range(iso)),x->
      PreImagesRepresentative(rest,PreImagesRepresentative(iso,x)));
    # evaluate relators
    pool:=List(RelatorsOfFpGroup(Range(iso)),
      x->MappedWord(x,FreeGeneratorsOfFpGroup(Range(iso)),pregens));
    # divide off original generators
    Append(pool,List(GeneratorsOfGroup(U),x->x/
      MappedWord(UnderlyingElement(ImagesRepresentative(iso,ImagesRepresentative(ffs.factorhom,x))),FreeGeneratorsOfFpGroup(Range(iso)),pregens)));

    iso:=IsomorphismFpGroup(Image(rest,U));
    pregens:=List(GeneratorsOfGroup(Range(iso)),x->
      PreImagesRepresentative(rest,PreImagesRepresentative(iso,x)));
    # evaluate relators
    pool:=List(RelatorsOfFpGroup(Range(iso)),
      x->MappedWord(x,FreeGeneratorsOfFpGroup(Range(iso)),pregens));
    # divide off original generators
    Append(pool,List(GeneratorsOfGroup(U),x->x/
      MappedWord(UnderlyingElement(ImagesRepresentative(iso,ImagesRepresentative(ffs.factorhom,x))),FreeGeneratorsOfFpGroup(Range(iso)),pregens)));

    pool:=List(pool,x->ImagesRepresentative(pcisom,x));
    kpc:=SubgroupNC(Image(pcisom),pool);
    pool:=List(SmallGeneratingSet(kpc),x->PreImage(pcisom,x));
    # normal closure
    for x in pool do
      for i in GeneratorsOfGroup(U) do
        xx:=x^i;
        k:=ImagesRepresentative(pcisom,xx);
        if not k in kpc then
          kpc:=ClosureSubgroupNC(kpc,k);
          Add(pool,xx);
        fi;
      od;
    od;

#    inv:=RestrictedInverseGeneralMapping(rest);
#    pregens:=List(SmallGeneratingSet(Image(rest)),
#      x->ImagesRepresentative(inv,x));
#    it:=CoKernelGensIterator(inv);
#    kpc:=TrivialSubgroup(Image(pcisom));
#    while not IsDoneIterator(it) do
#      x:=NextIterator(it);
#      pool:=[x];
#      for x in pool do
#       xx:=ImagesRepresentative(pcisom,x);
#       if not xx in kpc then
#         kpc:=ClosureGroup(kpc,xx);
#         for i in pregens do
#           Add(pool,x^i);
#         od;
#       fi;
#      od;
#      #Print("|pool|=",Length(pool),"\n");
#    od;
    SetSize(U,Size(Image(rest))*Size(kpc));
    k:=InducedPcgs(FamilyPcgs(Image(pcisom)),kpc);
    k:=List(k,x->PreImagesRepresentative(pcisom,x));
    k:=InducedPcgsByPcSequenceNC(ffs.pcgs,k);
    ker:=SubgroupNC(G,k);
    SetSize(ker,Size(kpc));
  fi;

  SetPcgs(ker,k);
  SetKernelOfMultiplicativeGeneralMapping(rest,ker);
  if Length(ffs.pcgs)=0 then
    r:=[1];
  else
    r:=Concatenation(k!.depthsInParent,[Length(ffs.pcgs)+1]);
  fi;

  AddNaturalHomomorphismsPool(U,ker,rest);
  r:=rec(parentffs:=ffs,
            rest:=rest,
            radical:=ker,
            pcgs:=k,
            serdepths:=List(ffs.depths,y->First([1..Length(r)],x->r[x]>=y))
            );

  return r;

end);

InstallGlobalFunction(FittingFreeSubgroupSetup,function(G,U)
local ffs,cache,rest,ker,k,r;
  ffs:=FittingFreeLiftSetup(G);

  # result cached?
  if not IsBound(U!.cachedFFS) then
    cache:=[];
    U!.cachedFFS:=cache;
  else
    cache:=U!.cachedFFS;
  fi;
  r:=First(cache,x->IsIdenticalObj(x[1],ffs));
  if r<>fail then
    return r[2];
  fi;

  if IsIdenticalObj(G,U) or GeneratorsOfGroup(G)=GeneratorsOfGroup(U) then
    rest:=ffs.factorhom;
    ker:=ffs.radical;
    k:=ffs.pcgs;
    r:=[1..Length(k)];
    r:=rec(parentffs:=ffs,
              rest:=rest,
              radical:=ker,
              pcgs:=k,
              serdepths:=List(ffs.depths,y->First([1..Length(r)],x->r[x]>=y))
              );
  else
    r:=DoFFSS(G,U);
  fi;

  k:=r.pcgs;
  rest:=r.rest;
  Add(cache,[ffs,r]); # keep
  if Length(k)=0 then
    SetSize(U,Size(Image(rest)));
  else
    SetSize(U,Product(RelativeOrders(k))*Size(Image(rest)));
  fi;
  return r;

end);

InstallGlobalFunction(SubgroupByFittingFreeData,function(G,gens,imgs,ipcgs)
local ffs,hom,U,rest,ker,r,p,l,i,depths,pcisom,subsz,pcimgs;

  ffs:=FittingFreeLiftSetup(G);
  # get back to initial group -- dont induce of induce
  while IsBound(ffs.inducedfrom) do
    ffs:=ffs.inducedfrom;
  od;

  hom:=ffs.factorhom;

  if Length(ffs.pcgs)=0 then
    if Length(ipcgs)>0 then
      Error("pc elements arise suddenly");
    fi;
    depths:=[];
  elif not IsGeneralPcgs(ipcgs) then
    ipcgs:=InducedPcgsByPcSequenceNC(ffs.pcgs,ipcgs);
  fi;

  if Length(ipcgs)>0 then
    if not HasOneOfPcgs(ipcgs) then
      SetOneOfPcgs(ipcgs,One(G));
    fi;
    depths:=IndicesEANormalSteps(ipcgs);
  else
    depths:=[];
  fi;

  # transfer the IndicesEANormalSteps
  if ffs.pcgs<>ipcgs and HasIndicesEANormalSteps(ffs.pcgs) then
    U:=IndicesEANormalSteps(ffs.pcgs);
    if IsBound(ipcgs!.depthsInParent) then
      r:=ipcgs!.depthsInParent;
    else
      r:=List(ipcgs,x->DepthOfPcElement(ffs.pcgs,x));
    fi;
    l:=[];
    for i in U{[1..Length(U)-1]} do # last one is length+1
      p:=PositionProperty(r,x->x>=i);
      if p<>fail and p<=Length(ipcgs) and not p in l then
        Add(l,p);
      fi;
    od;
    Add(l,Length(ipcgs)+1);
    SetIndicesEANormalSteps(ipcgs,l);
  fi;

  pcimgs:=List(ipcgs,x->ImagesRepresentative(ffs.pcisom,x));

  ker:=SubgroupNC(G,List(MinimalGeneratingSet(Group(pcimgs,One(Range(ffs.pcisom)))),
    x->PreImagesRepresentative(ffs.pcisom,x)));
  SetPcgs(ker,ipcgs);
  if Length(ipcgs)=0 then
    SetSize(ker,1);
  else
    SetPcgs(ker,ipcgs);
    SetSize(ker,Product(RelativeOrders(ipcgs)));
  fi;
  subsz:=Size(Group(imgs,One(Image(ffs.factorhom))))*Size(ker);

  U:=SubgroupNC(G,Concatenation(gens,GeneratorsOfGroup(ker)));
  SetSize(U,subsz);

  gens:=Concatenation(gens,ipcgs);
  imgs:=Concatenation(imgs,List(ipcgs,x->One(Range(hom))));

  if IsPermGroup(U) and AssertionLevel()>1 then
    rest:=GroupHomomorphismByImages(U,Range(hom),gens,imgs);
  else
    RUN_IN_GGMBI:=true; # hack to skip Nice treatment
    rest:=GroupHomomorphismByImagesNC(U,Range(hom),gens,imgs);
    RUN_IN_GGMBI:=false;
  fi;
  Assert(1,rest<>fail);

  if HasRecogDecompinfoHomomorphism(hom) then
    SetRecogDecompinfoHomomorphism(rest,RecogDecompinfoHomomorphism(hom));
  fi;

  SetKernelOfMultiplicativeGeneralMapping(rest,ker);


  if Length(ipcgs)=0 then
    r:=[Length(ffs.pcgs)+1];
  elif IsBound(ipcgs!.depthsInParent) then
    r:=Concatenation(ipcgs!.depthsInParent,[Length(ffs.pcgs)+1]);
  else
    r:=Concatenation(List(ipcgs,x->DepthOfPcElement(ffs.pcgs,x)),
      [Length(ffs.pcgs)+1]);
  fi;
  r:=rec(parentffs:=ffs,
            rest:=rest,
            radical:=ker,
            pcgs:=ipcgs,
            serdepths:=List(ffs.depths,y->First([1..Length(r)],x->r[x]>=y))
            );

  U!.cachedFFS:=[[ffs,r]];

  # FittingFreeLiftSetup for U, if correct
  if Size(SolvableRadical(Image(rest,U)))=1 then
    if ipcgs=MappingGeneratorsImages(ffs.pcisom)[1] then
      pcisom:=ffs.pcisom;
    else
      pcisom:=pcimgs;
      if Length(ipcgs)>0 then
        # work around error for special trivial group.
        r:=Group(ipcgs,OneOfPcgs(ipcgs));
      else
        r:=SubgroupNC(G,ipcgs);
      fi;
      RUN_IN_GGMBI:=true;
      pcisom:=GroupHomomorphismByImagesNC(r,
        SubgroupNC(Range(ffs.pcisom),pcisom),
        ipcgs,pcisom);
      RUN_IN_GGMBI:=false;
    fi;
    r:=rec(inducedfrom:=ffs,
          pcgs:=ipcgs,
          depths:=depths,
          pcisom:=pcisom,
          radical:=ker,
          factorhom:=rest
          );
    SetFittingFreeLiftSetup(U,r);
    AddNaturalHomomorphismsPool(U,ker,rest);
  fi;

  return U;

end);


InstallGlobalFunction(FittingFreeElementarySeries,function(arg)
local G,A,wholesocle,ff,r,ser,fser,hom,q,s,d,act,o,i,j,a,perm,k;

  G:=arg[1];
  if Length(arg)>1 then
    A:=arg[2];
    wholesocle:=arg[3];
  else
    A:=TrivialSubgroup(G);
    wholesocle:=false;
  fi;
  ff:=FittingFreeLiftSetup(G);

  if IsSubset(G,A) then
    # just use inner automorphisms...
    A:=Group(List(GeneratorsOfGroup(G),x->InnerAutomorphismNC(G,x)));
  fi;

  r:=ff.radical;
  if Size(r)=1 then
    ser:=[r];
  else
    ser:=InvariantElementaryAbelianSeries(r,GeneratorsOfGroup(A));
  fi;
  if Size(r)<Size(G) then
    ser:=Reversed(ser);
    hom:=ff.factorhom;
    q:=Image(hom);
    s:=Socle(q);

    d:=DirectFactorsFittingFreeSocle(q);
    if wholesocle<>true then
      # orbits on socle components
      act:=List(GeneratorsOfGroup(A),x->InducedAutomorphism(hom,x));
      o:=Orbits(Group(act,IdentityMapping(q)),d,
          function(u,a) return Image(a,u);end);
      fser:=[TrivialSubgroup(q)];
      for i in o do
        a:=fser[Length(fser)];
        for j in i do
          a:=ClosureGroup(a,j);
        od;
        Add(fser,a);
      od;
    else
      fser:=[TrivialSubgroup(q),s];
    fi;
    for i in fser{[2..Length(fser)]} do
      Add(ser,PreImage(hom,i));
    od;
#Print("A",List(ser,Size),"\n");
    # pker/S*
    perm:=ActionHomomorphism(q,d,"surjective");
    k:=PreImage(hom,KernelOfMultiplicativeGeneralMapping(perm));
    if Size(s)<Size(KernelOfMultiplicativeGeneralMapping(perm)) then
      s:=ser[Length(ser)];
      hom:=NaturalHomomorphismByNormalSubgroupNC(k,s);
      q:=Image(hom);
      act:=List(GeneratorsOfGroup(A),x->InducedAutomorphism(hom,x));
      fser:=InvariantElementaryAbelianSeries(q,act);
      for i in fser{[1..Length(fser)-1]} do
        Add(ser,PreImage(hom,i));
      od;
    fi;
#Print("B",List(ser,Size),"\n");

    if Size(k)<Size(G) then
      # G/Pker, recursive
      hom:=NaturalHomomorphismByNormalSubgroupNC(G,k);
      q:=Image(hom);
      act:=List(GeneratorsOfGroup(A),x->InducedAutomorphism(hom,x));
      A:=Group(act,IdentityMapping(q));
      fser:=FittingFreeElementarySeries(q,A,wholesocle);
      for i in fser{[Length(fser)-1,Length(fser)-2..1]} do
        Add(ser,PreImage(hom,i));
      od;
    fi;
    ser:=Reversed(ser);
  fi;
#Print(List([1..Length(ser)-1],x->Size(ser[x])/Size(ser[x+1])),"\n");
  return ser;

end);

#############################################################################
##
#M  \in( <e>,<G> ) . . . . . . . . . . . . . . using TF method
##
InstallMethod( \in, "TF method, use tree",IsElmsColls,
  [ IsMultiplicativeElementWithInverse,
    IsGroup and IsFinite and HasFittingFreeLiftSetup], OVERRIDENICE,
function(e, G)
local f;
  f:=FittingFreeLiftSetup(G);
  # permutation groups don't need the .csi component
  if not IsBound(f.csi) then TryNextMethod();fi;
  return e in f.csi.recog;
end );

#############################################################################
##
#M  SolvableRadical( <G> ) . . . . . . . . . . . . . . using TF method
##
InstallMethod( SolvableRadical, "TF method, use tree",
  [ IsGroup and IsFinite and HasFittingFreeLiftSetup], OVERRIDENICE,
function(G)
local f;
  f:=FittingFreeLiftSetup(G);
  if not IsBound(f.radical) then TryNextMethod();fi;
  return f.radical;
end );

# We will be in the situation that an IGS has been corrected only on the
# lowest level, i.e. the only obstacle to being an IGS is on the lowest
# level. Thus the situation is that of a vector space and we do not need to
# consider commutators and powers, but simply do a Gaussian elimination.
InstallGlobalFunction(TFMakeInducedPcgsModulo,function(pcgs,gens,ignoredepths)
local i,j,d,igs,g,a,l,al;
  d:=[];
  igs:=[];
  l:=[];
  for g in gens do
    a:=DepthAndLeadingExponentOfPcElement(pcgs,g); al:=a[2]; a:=a[1];
    #Print(a,"\n");
    if not a in ignoredepths then
      j:=1;
      while j<=Length(d) do
        if a<d[j] then
          #insert
          for i in [Length(d),Length(d)-1..j] do
            d[i+1]:=d[i];
            igs[i+1]:=igs[i];
            l[i+1]:=l[i];
          od;
          d[j]:=a;
          igs[j]:=g;
          l[j]:=al;
          j:=Length(d)+2; # pop
        elif a=d[j] then
          # conflict--divide off
          g:=igs[j]/g^(l[j]/al mod RelativeOrders(pcgs)[a]);
          a:=DepthAndLeadingExponentOfPcElement(pcgs,g); al:=a[2]; a:=a[1];
#Print("change ",a,"\n");
          if a=d[j] then Error("clash!");fi;
          if a in ignoredepths then
            j:=Length(d)+2; # force ignore
          fi;
        else
          j:=j+1;
        fi;
      od;
      if j<Length(d)+2 then #we did not insert
        Add(igs,g);
        Add(d,a);
        Add(l,al);
      fi;
    fi;
  od;
  IsRange(d);
#Print("Made IGS ",d," lendiff ",Length(gens)-Length(d),"\n");
  return igs;
end);

# Orbit functions for multi-stage calculations

InstallGlobalFunction(OrbitsRepsAndStabsVectorsMultistage,
  function(pcgs,pcgsimgs,pcisom,solvsz,solvtriv,gens,imgs,fgens,
           factorhom,gpsz,actfun,domain)

local stabilizergen,st,stabrsub,stabrsubsz,ratio,subsz,sz,vp,stabrad,
      stabfacgens,s,orblock,orb,rep,b,p,repwords,orpo,i,j,k,repword,
      imgsinv,img,stabfac,reps,stage,genum,orbstabs,stabfacimg,
      fgrp,solsubsz,failcnt,stabstack,relo,orbitseed;

  orbitseed:=ValueOption("orbitseed");

  stabilizergen:=function()
  local im,i,fe,gpe;

    if stage=1 then

      Error("solv stage is gone");
      #stabilizer in radical
      if IsRecord(st) then st:=st.left/st.right;fi;
      fe:=ImagesRepresentative(pcisom,st);
      if not fe in stabrsub then
        stabrsub:=ClosureGroup(stabrsub,fe);
        stabrsubsz:=Size(stabrsub);
        subsz:=stabrsubsz*Size(stabfac);
        ratio:=gpsz/subsz/Length(orb);
        if ratio=1 then vp:=Length(orb);fi;
        Add(stabrad,st);
      else
        failcnt:=failcnt+1;
        if IsInt(failcnt/50) then
          Info(InfoFitFree,5,"failed ",failcnt," times, ratio ",EvalF(ratio),
                ", ",Length(stabrad)," gens\n");
        fi;
      fi;

    else
      # in radical factor, still it could be the identity
      if Length(repword)>0 then
        # build the factor group element
        fe:=One(Image(factorhom));
        for i in repword do
          fe:=fe*fgens[i];
        od;
        for i in Reversed(repwords[p]) do
          fe:=fe/fgens[i];
        od;
        if not fe in stabfac then
          # not known -- add to generators
          Add(stabfacimg,fe);

          if IsRecord(st) then
            if st.left<>fail then
              Error("cannot happen");
              st:=st.left/st.right;
            else
              gpe:=One(Source(factorhom));
              for i in repwords[st.vp] do
                gpe:=gpe*gens[i];
              od;
              gpe:=gpe*gens[st.genumr];
              for i in Reversed(repwords[st.right]) do
                gpe:=gpe/gens[i];
              od;

              # vector image under st
              im:=orb[1];
              for i in repwords[st.vp] do
                im:=actfun(im,imgs[i]);
              od;
              im:=actfun(im,imgs[st.genumr]);
              for i in Reversed(repwords[st.right]) do
                im:=actfun(im,imgsinv[i]);
              od;
            fi;

            # make sure st really stabilizes by dividing off solvable bit
            st:=gpe/reps[orpo[Position(domain,im)]];
          fi;

          Add(stabfacgens,st);
          stabfac:=ClosureGroup(stabfac,fe);
          subsz:=stabrsubsz*Size(stabfac);
          ratio:=gpsz/subsz/Length(orb);
          if ratio=1 then vp:=Length(orb);fi;
          Assert(1,GeneratorsOfGroup(stabfac)=stabfacimg);

        fi;
      fi;
    fi;

    # radical stabilizer element. TODO: Use PCGS to remove
    # duplicates
  end;

  fgrp:=Group(fgens,One(Range(factorhom)));
  imgsinv:=List(imgs,Inverse);

  # now compute orbits, being careful to get stabilizers in steps
  orbstabs:=[];
  # use positions in bit list to know which ones are done
  sz:=Length(domain);
  b:=BlistList([1..sz],[]);
  while sz>0 do
    failcnt:=0;
    if orbitseed<>fail then
      # get seed number
      p:=Position(domain,orbitseed);
    else
      # still orbits left to do
      p:=Position(b,false);
    fi;
    orb:=[domain[p]];
    orpo:=[];
    orpo[p]:=1;
    b[p]:=true;
    sz:=sz-1;
    reps:=[One(Source(factorhom))];
    stabstack:=[];
    stabrad:=[];
    stabrsub:=solvtriv;
    stabrsubsz:=Size(solvtriv);
    stabfac:=TrivialSubgroup(fgrp);
    subsz:=stabrsubsz*Size(stabfac);
    stabfacgens:=[];
    stabfacimg:=[];
    repwords:=[[]];

    # now do a two-stage orbit algorithm. first solvable, then via the
    # factor group. Both times we can check that we have the correct orbit.

    # ratio 1: full orbit/stab known, ratio <2 stab cannot grow any more.
    ratio:=5;
    vp:=1; # position in orbit to process

    # solvable iteration
    stage:=1;
    for genum in [Length(pcgs),Length(pcgs)-1..1] do
      relo:=RelativeOrders(pcisom!.sourcePcgs)[
              DepthOfPcElement(pcisom!.sourcePcgs,pcgs[genum])];
      img:=actfun(orb[1],pcgsimgs[genum]);
      repword:=repwords[1];
      p:=Position(domain,img);
      if p>Length(b) or not b[p] then
        # new orbit images
        vp:=Length(orb)*(relo-1);
        sz:=sz-vp;
        for j in [1..vp] do
          img:=actfun(orb[j],pcgsimgs[genum]);
          p:=Position(domain,img);
          b[p]:=true;
          Add(orb,img);
          orpo[p]:=Length(orb);
          Add(reps,reps[j]*pcgs[genum]);
          Add(repwords,repword);
        od;
      else
        rep:=pcgs[genum]/reps[orpo[p]];
#if Order(rep)=1 then Error("HUH4"); fi;
        Add(stabrad,rep);
#Print("increased ",stabrsubsz," by ",relo,"\n");
        stabrsubsz:=stabrsubsz*relo;
        subsz:=stabrsubsz;
        ratio:=gpsz/subsz/Length(orb);
      fi;

    od;
    stabrad:=Reversed(stabrad);

    subsz:=stabrsubsz;
    if  solvsz>subsz*Length(orb) then
      Error("processing stabstack solvable ", Length(stabrad));

      s:=1;
      while solvsz<>subsz*Length(orb) do
        vp:=stabstack[s][1];
        genum:=stabstack[s][2];
        img:=orb[vp]*pcgsimgs[genum];
        rep:=reps[vp]*pcgs[genum];
        repword:=repwords[vp];
        p:=Position(domain,img);
        p:=orpo[p];
        #st:=rep/reps[p];
        st:=rec(left:=rep,right:=reps[p]);
        stabilizergen();
        s:=s+1;
      od;
      Info(InfoFitFree,5,"processed solvable ",s," from ",Length(stabstack));
    fi;

    subsz:=stabrsubsz;
    solsubsz:=subsz;

    orblock:=Length(orb);
    Info(InfoFitFree,5,"solvob=",orblock);

    # nonsolvable iteration: We act on orbits
    stage:=2;

    # ratio 1: full orbit/stab known, ratio <2 stab cannot grow any more.
    ratio:=5;
    vp:=1;
    while vp<=Length(orb) do
      for genum in [1..Length(gens)] do
        img:=actfun(orb[vp],imgs[genum]);

        repword:=Concatenation(repwords[vp],[genum]);

        p:=Position(domain,img);
        if not b[p] then
          # new orbit image
          Add(orb,img);
          orpo[p]:=Length(orb);
          #if rep<>fail then Add(reps,rep); fi;
          Add(repwords,repword);
          b[p]:=true;
          for j in [1..orblock-1] do
            img:=actfun(orb[vp+j],imgs[genum]);
            p:=Position(domain,img);
            if b[p] then Error("duplicate!");fi;
            Add(orb,img);
            orpo[p]:=Length(orb);
            #if IsBound(reps[vp+j]) then
            #  Add(reps,reps[vp+j]*gens[genum]);
            #fi;
            # repwordslso needs to change!
            Add(repwords,Concatenation(repwords[vp+j],[genum]));
            b[p]:=true;
          od;

          sz:=sz-orblock;
          ratio:=gpsz/subsz/Length(orb);
          if ratio=1 then vp:=Length(orb);fi;

        elif ratio>=2 then
          # old orbit element -- stabilizer generator
          # if ratio <2 the stabilizer cannot grow any more

          p:=orpo[p];
          st:=rec(left:=fail,vp:=vp,genumr:=genum,right:=p);
          stabilizergen();
        fi;
      od;
      vp:=vp+orblock; # jump in steps
    od;

    s:=1;
    subsz:=stabrsubsz*Size(stabfac);
    if  gpsz<>subsz*Length(orb) then
      Error("should not happen nonslv stabstack");
    fi;


    Info(InfoFitFree,4,"orblen=",Length(orb)," blocked ",orblock," left:",
      sz," len=", Length(stabrad)," ",Length(stabfacgens));

    #Assert(2,ForAll(GeneratorsOfGroup(stabsub),i->Comm(i,h*rep) in NT));
    s:=rec(rep:=orb[1],len:=Length(orb),stabradgens:=stabrad,
           stabfacgens:=stabfacgens,stabfacimgs:=stabfacimg,
           stabrsub:=stabrsub,stabrsubsz:=stabrsubsz,subsz:=subsz
                  );
    if orbitseed<>fail then
      s.gens:=gens;
      s.fgens:=fgens;
      s.orbit:=orb;
      s.orblock:=orblock;
      s.reps:=reps;
      s.repwords:=repwords;
      sz:=0; # force bailout
    else
      # by construction, we seed each orbit with its smallest element
      Assert(1,orb[1]=Minimum(orb));
    fi;
    Add(orbstabs,s);
  od;
  return orbstabs;
end);

InstallGlobalFunction(OrbitMinimumMultistage,
  function(pcgs,pcgsimgs,gens,imgs,fgens,actfun,seed,orblen,stops)

#was: OrbitMinimumMultistage:=function(pcgs,pcgsimgs,gens,imgs,fgens,actfun,seed,orblen,stops)

local sel,orb,dict,reps,repwords,vp,img,cont,minpo,genum,rep,repword,p,
  orblock,s,i,j;




  orb:=[seed];
  p:=DefaultHashLength;
  DefaultHashLength:=4*orblen; # remember that we might need all orbit elements
  if IsRowVector(seed) then
    dict:=NewDictionary(seed,true,DefaultField(seed)^Length(seed));
  else
    dict:=NewDictionary(seed,true);
  fi;
  DefaultHashLength:=p;
  AddDictionary(dict,seed,Length(orb));
  reps:=[One(pcgs[1])];
  repwords:=[[]];

  # now do a two-stage orbit algorithm. first solvable, then via the
  # factor group. Both times we can check that we have the correct orbit.

  vp:=1;
  img:=fail;
  cont:=true;
  minpo:=fail;

  while vp<=Length(orb) and cont do
    for genum in [Length(pcgs),Length(pcgs)-1..1] do

      img:=actfun(orb[vp],pcgsimgs[genum]);
      rep:=reps[vp]*pcgs[genum];
      repword:=repwords[vp];
      p:=LookupDictionary(dict,img);
      if p=fail then
        # new orbit element
        Add(orb,img);
        AddDictionary(dict,img,Length(orb));
        Add(reps,rep);
        Add(repwords,repword);
        if img in stops then
          minpo:=Length(orb);
          cont:=false;
        elif Length(orb)>=orblen then
          cont:=false;
        fi;
      fi;
    od;
    vp:=vp+1;
  od;
#if Length(orb)>Length(Set(orb)) then Error("EH");fi;
  orblock:=Length(orb);
  Info(InfoFitFree,5,"solvob=",orblock);

  # nonsolvable iteration: We act on orbits

  # these are the proper actors
  sel:=Filtered([1..Length(gens)],x->Order(gens[x])>1);
  vp:=1;
  while vp<=Length(orb) and cont do
    for genum in sel do
      img:=actfun(orb[vp],imgs[genum]);
      repword:=Concatenation(repwords[vp],[genum]);
      p:=LookupDictionary(dict,img);
      if p=fail then
        # new orbit image
        Add(orb,img);
        AddDictionary(dict,img,Length(orb));
        Add(repwords,repword);
        if img in stops then
          minpo:=Length(orb);
          cont:=false;
        fi;
        for j in [1..orblock-1] do
          img:=actfun(orb[vp+j],imgs[genum]);
          Add(orb,img);
          AddDictionary(dict,img,Length(orb));
          Add(repwords,Concatenation(repwords[vp+j],[genum]));
          if img in stops then
            minpo:=Length(orb);
            cont:=false;
          fi;
        od;
        if Length(orb)>=orblen then cont:=false;fi;
      fi;
    od;
    vp:=vp+orblock; # jump in steps
  od;

  if minpo=fail then
    # guarantee minimum
    p:=orb[1];minpo:=1;
    for j in [2..Length(orb)] do
      if orb[j]<p then
        minpo:=j;p:=orb[j];
      fi;
    od;
  fi;

  # now find rep mapping to minimum
  if Length(gens)=0 then
    p:=One(pcgs[1]);
    s:=();
  else
    p:=One(gens[1]);
    s:=One(fgens[1]);
  fi;
  for i in repwords[minpo] do
    p:=p*gens[i];
    s:=s*fgens[i];
  od;
  i:=minpo mod orblock;
  if i=0 then i:=orblock;fi;
  p:=reps[i]*p;

  p:=rec(elm:=p,felm:=s,min:=orb[minpo]);
  return p;
end);

BindGlobal("SylowViaRadical",function(G,prime)
local ser,hom,s,fphom,sf,sg,sp,fp,d,head,mran,nran,mpcgs,ocr,len,pcgs,gens;
  ser:=FittingFreeLiftSetup(G);
  pcgs:=ser.pcgs;
  len:=Length(pcgs);
  hom:=ser.factorhom;
  s:=SylowSubgroup(Image(hom),prime);
  fphom:=IsomorphismFpGroup(s);
  fp:=Image(fphom);
  sf:=List(GeneratorsOfGroup(Image(fphom)),x->PreImagesRepresentative(fphom,x));
  sg:=List(sf,x->PreImagesRepresentative(hom,x));
  sp:=[];
  RUN_IN_GGMBI:=true; # hack to skip Nice treatment
  fphom:=GroupGeneralMappingByImagesNC(Group(sg,One(G)),fp,sg,
    GeneratorsOfGroup(fp));
  RUN_IN_GGMBI:=false;



  for d in [2..Length(ser.depths)] do
    mran:=[ser.depths[d-1]..len];
    nran:=[ser.depths[d]..len];
    head:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran});

    mpcgs:=head mod
           InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});
    if RelativeOrders(mpcgs)[1]=prime then
      if d=Length(ser.depths) then
        # last step, no presentation needed
        Append(sp,mpcgs);
      else
        # extend presentation
        RUN_IN_GGMBI:=true; # hack to skip Nice treatment
        fphom:=LiftFactorFpHom(fphom,Source(fphom),false,mpcgs);
        RUN_IN_GGMBI:=false;
        fp:=Image(fphom);
        sp:=Concatenation(sp,mpcgs);
      fi;
    else

      ocr:=rec(group:=Group(Concatenation(head,sg,sp)),modulePcgs:=mpcgs);
      ocr.factorfphom:=fphom;
      OCOneCocycles(ocr,true);
      gens:=GeneratorsOfGroup(ocr.complement);
      sg:=gens{[1..Length(sg)]};
      sp:=gens{[Length(sg)+1..Length(gens)]};
      RUN_IN_GGMBI:=true; # hack to skip Nice treatment
      fphom:=GroupGeneralMappingByImagesNC(ocr.complement,fp,gens,
        GeneratorsOfGroup(fp));
      RUN_IN_GGMBI:=false;

    fi;
  od;
  return SubgroupByFittingFreeData(G,sg,sf,InducedPcgsByPcSequenceNC(pcgs,sp));
end);

InstallMethod(DirectFactorsFittingFreeSocle,"generic",true,
  [IsGroup and IsFinite],0,
function(G)
local s,o,a,n,d,f,fn,j,b,i;
  s:=Socle(G);

  #try to split first according to orbits
  if IsPermGroup(G) then
    o:=Orbits(s,MovedPoints(s));
    f:=[s]; #prefactors
    for i in o do
      fn:=[];
      for j in f do
        a:=Stabilizer(j,i,OnTuples);
        if Size(a)=Size(j) or Size(a)=1 then
          Add(fn,j);
        else
          b:=Centralizer(j,a);
          Add(fn,a);
          Add(fn,b);
        fi;
      od;
      f:=fn;
    od;
  else
    f:=[s];
  fi;

  d:=[];
  for i in f do
    if IsNonabelianSimpleGroup(i) then
      Add(d,i);
    else
      n:=Filtered(NormalSubgroups(i),x->Size(x)>1);
      # if G is not fitting-free it has a proper normal subgroup of
      #  prime-power order
      if ForAny(n,IsPGroup) then
        return fail;
      fi;
      n:=Filtered(n,IsNonabelianSimpleGroup);
      Append(d,n);
    fi;
  od;
  return d;
end);

BindGlobal("ClosureGroupQuick",function(G,U,V)
local o,C;
  C:=SubgroupNC(G,Concatenation(GeneratorsOfGroup(U),GeneratorsOfGroup(V)));
  o:=List([1..100],x->Order(PseudoRandom(C)));
  Add(o,Size(U));
  Add(o,Size(V));
  if IsPermGroup(G) then
    Append(o,List(Orbits(C,MovedPoints(G)),Length));
  fi;
  o:=Lcm(o);
  if PrimeDivisors(Size(G))=PrimeDivisors(o) then
    # all primes in -- useless
    return G;
  fi;
  return C;
end);

# the ``all-halls'' function by brute force Sylow-combination search
BindGlobal("Halleen",function(arg)
local G,gp,p,r,s,c,i,a,prime,sy,k,b,dc,H,e,j,forbid;
  G:=arg[1];
  gp:=PrimeDivisors(Size(G));
  if Length(arg)>1 then
    r:=arg[2];
    forbid:=Difference(gp,r);
    p:=Intersection(gp,r);
  else
    forbid:=[];
    p:=gp;
  fi;
  r:=List(p,x->[[x],[SylowSubgroup(G,x)]]); # real halls
  s:=ShallowCopy(r); # real and potential halls to extend
  c:=Combinations(p);
  c:=Filtered(c,x->Length(x)>1 and Length(x)<Length(gp));
  SortBy(c, Length);
  for i in c do
    a:=[];
    # now build all new groups by extending the groups that were obtained
    # for one prime less. We exclude the smallest prime, as it tends to have
    # the largest sylow
    prime:=i[1];
    sy:=SylowSubgroup(G,prime);
    k:=i{[2..Length(i)]};
    # b are the groups constructed using the other primes
    b:=First(s,x->x[1]=k);
    if b=fail then b:=[];
              else b:=b[2]; fi;

    # those that already contain the prime Sylow just go on
    e:=Filtered(b,x->1=Gcd(Index(G,x),prime));

    # are any of these actually proper hall?
    for H in e do
      if IsSubset(i,Factors(Size(H))) then
        Add(a,H);
      fi;
    od;

    # the rest should be extended
    b:=Filtered(b,x->1<Gcd(Index(G,x),prime));

    Info(InfoLattice,1,"Try ",i," from ",k," ",Length(e)," ",Length(b));

    for j in b do
      dc:=DoubleCosetRepsAndSizes(G,Normalizer(G,sy),Normalizer(G,j));
      #Print(Length(dc)," double cosets\n");
      for k in dc do
        #H:=ClosureGroup(j,sy^k[1]);
        H:=ClosureGroupQuick(G,j,sy^k[1]);
        # discard whole group and those that have all primes
        if Index(G,H)>1 and not ForAll(gp,x->IsInt(Size(H)/x))
          and not ForAny(forbid,x->IsInt(Size(H)/x)) then
          if ForAll(e,x->H<>x) and
             ForAll(e,x->RepresentativeAction(G,H,x)=fail) then
            Add(e,H);
            if IsSubset(i,Factors(Size(H))) then
              if Length(Intersection(Factors(Index(G,H)),i))=0 then
                Info(InfoLattice,2,"Found Hall",i," ",Size(H));
              else
                Info(InfoLattice,2,"Found ",i," ",Size(H));
              fi;
              Add(a,H);
            else
              Info(InfoLattice,2,"Too large ",i," ",Size(H));
            fi;
          fi;
        fi;
      od;
    od;

    Add(s,[i,e]);
    if Length(a)>0 then
      Add(r,[i,a]);
    fi;

  od;
  return r;
end);

BindGlobal("HallsFittingFree",function(G,pi)
local s,d,c,act,o,i,j,h,p,hf,img,n,k,ns,all,hl,hcomp,
  shall,t,thom,b,ntb,hom,dser,pcgs,
  fphom,fp,gens,imgs,ocr,elabser,cgens,a,kim,r,z;

  # get elementary abelian series from -> to
  elabser:=function(from,to)
  local ser,a,p;
    ser:=[from];
    while Size(from)>Size(to) do
      a:=from;
      from:=DerivedSubgroup(a);
      if Size(from)=Size(a) then
        # nonsolvable case
        return ser;
      fi;
      p:=Factors(Index(a,from))[1];
      from:=ClosureGroup(from,List(GeneratorsOfGroup(a),x->x^p));
      Assert(2,HasElementaryAbelianFactorGroup(a,from) and Index(a,from)>1);
      Add(ser,from);
    od;
    return ser;
  end;

  # needs to go higher
  pi:=Set(pi);
  if ForAny(pi,x->not IsPrimeInt(x)) then
    Error("pi must be a set of primes");
  fi;
  pi:=Filtered(pi,x->IsInt(Size(G)/x));
  if Length(pi)=0 then
    return [TrivialSubgroup(G)];
  elif false and Length(pi)=1 then
    return [SylowSubgroup(G,pi[1])];
  elif pi=PrimeDivisors(Size(G)) then
    return [G];
  fi;

  s:=Socle(G);
  d:=DirectFactorsFittingFreeSocle(G);
  c:=[]; # conjugation info
  act:=ActionHomomorphism(G,d);
  t:=KernelOfMultiplicativeGeneralMapping(act);
  img:=Image(act);

  # compute Hall in factor
  hf:=HallViaRadical(img,pi);
  Info(InfoLattice,1,"Permact factor:",Length(hf)," hall subgroups");

  if Length(hf)=0 then
    # nothing in the factor
    return [];
  fi;

  # compute b such that b/s is hall in t/s
  thom:=NaturalHomomorphismByNormalSubgroupNC(t,s);
  b:=HallSubgroup(Image(thom),pi);
  b:=PreImage(thom,b);
  ntb:=Normalizer(t,b); # likely equal to t or of small index, thus harmless

  # also compute halls for socle
  o:=Orbits(Image(act),[1..Length(d)]);
  hl:=[];
  for i in o do
    p:=Intersection(Factors(Size(d[i[1]])),pi);
    if Length(p)=0 then
      h:=[,[TrivialSubgroup(d[i[1]])]];
    else
      h:=Halleen(d[i[1]],p);
      h:=First(h,x->x[1]=p);
    fi;
    # TODO: Reduce via B-action
    if h=fail then
      return [];
    fi;
    h:=h[2];
    Info(InfoLattice,2,"Socle factor size ",Size(d[i[1]]),": ",Length(h),
      " Hall subgroups");
    for j in i do
      hl[j]:=Length(h);
    od;
    n:=List(h,x->Normalizer(d[i[1]],x));
    c[i[1]]:=rec(orbit:=i,orbitpos:=1,rep:=One(G),component:=d[i[1]],hall:=h,
      norm:=n);
    for j in [2..Length(i)] do
      c[i[j]]:=rec(orbit:=i,orbitpos:=j,
        rep:=PreImagesRepresentative(act,
          RepresentativeAction(Image(act),i[1],i[j])),
        component:=d[i[j]],hall:=h, norm:=n);
    od;
  od;

  # now form all halls in s
  shall:=[];
  for p in Cartesian(List(hl,x->[1..x])) do
    h:=TrivialSubgroup(G);
    hcomp:=[];
    ns:=TrivialSubgroup(G);
    for i in [1..Length(d)] do
      hcomp[i]:=c[i].hall[p[i]]^c[i].rep;
      h:=ClosureGroup(h,hcomp[i]);
      ns:=ClosureGroup(ns,c[i].norm[p[i]]^c[i].rep);
    od;
    Add(shall,rec(hall:=h,hcomp:=hcomp,ns:=ns));
  od;
  if Length(shall)=0 then
    return [];
  fi;
  Info(InfoLattice,1,Length(shall)," in socle");

  # get elementary abelian series from ntb to b
  dser:=elabser(ntb,b);
  pcgs:=List([2..Length(dser)],x->ModuloPcgs(dser[x-1],dser[x]));

  all:=[];
  # run through halls in factor (and correct)
  for i in hf do
    if Size(i)>1 then

      # replace hf's by complements
      fphom:=IsomorphismFpGroup(i);
      fp:=Range(fphom);
      gens:=MappingGeneratorsImages(fphom);
      imgs:=gens[2];gens:=gens[1];
      gens:=List(gens,x->PreImagesRepresentative(act,x));

      # adapt to normalize B
      gens:=List(gens,x->x/RepresentativeAction(t,b^x,b));

      # now do complements one by one
      for j in [1..Length(pcgs)] do
        h:=ClosureGroup(dser[j],gens);
        RUN_IN_GGMBI:=true; # hack to skip Nice treatment
        fphom:=GroupGeneralMappingByImagesNC(h,fp,
                Concatenation(GeneratorsOfGroup(dser[j]),gens),
                Concatenation(List(GeneratorsOfGroup(dser[j]),x->One(fp)),imgs));
        RUN_IN_GGMBI:=false;

        ocr:=rec(group:=h,modulePcgs:=pcgs[j],
                factorfphom:=fphom);
        OCOneCocycles(ocr,true);
        gens:=GeneratorsOfGroup(ocr.complement);
      od;

      # lift presentation with b/s, if necessary
      if Size(b)>Size(s) then

        h:=ClosureGroup(b,gens);
        RUN_IN_GGMBI:=true; # hack to skip Nice treatment
        fphom:=GroupGeneralMappingByImagesNC(h,fp,
                Concatenation(GeneratorsOfGroup(b),gens),
                Concatenation(List(GeneratorsOfGroup(b),x->One(fp)),imgs));
        RUN_IN_GGMBI:=false;
        # get elementary abelian series from b to s
        dser:=elabser(b,s);
        pcgs:=List([2..Length(dser)],x->ModuloPcgs(dser[x-1],dser[x]));
        for j in pcgs do
          RUN_IN_GGMBI:=true; # hack to skip Nice treatment
          fphom:=LiftFactorFpHom(fphom,Source(fphom),false,j);
          RUN_IN_GGMBI:=false;
        od;
        gens:=MappingGeneratorsImages(fphom);
        imgs:=gens[2];gens:=gens[1];
        fp:=Image(fphom);
      fi;
    else
      # trivial in factor -- continue with b
      hom:=NaturalHomomorphismByNormalSubgroupNC(b,s);
      fphom:=IsomorphismFpGroup(Image(hom));
      fp:=Image(fphom);
      gens:=MappingGeneratorsImages(fphom);
      imgs:=gens[2];gens:=gens[1];
      gens:=List(gens,x->PreImagesRepresentative(hom,x));
    fi;

    # now run through the candidates for Hall in S
    for j in shall do

      k:=j.hall;
      # normalize k -- correct gens
      cgens:=[];
      h:=1;
      while cgens<>fail and h<=Length(gens) do
        a:=gens[h];
        kim:=List(j.hcomp,x->x^a);
        # reindex
        kim:=kim{ListPerm(Image(act,a)^-1,Length(d))};
        z:=1;
        while a<>fail and z<=Length(d) do
          r:=RepresentativeAction(d[z],kim[z],j.hcomp[z]);
          if r<>fail then
            a:=a*r;
          else
            a:=fail;
          fi;
          z:=z+1;
        od;
        if a<>fail then
          Add(cgens,a);
        else
          cgens:=fail;
        fi;
        h:=h+1;
      od;

      if cgens<>fail and ForAll(cgens,IsOne) then
        # degenerate case -- nothing in the factor, just use hall in s
        Add(all,j.hall);
      elif cgens<>fail then
        # The s-class of k is fixed and cgens are generators for N_C(K),
        # corresponding to gens (and imgs).
        dser:=elabser(j.ns,j.hall);
        pcgs:=List([2..Length(dser)],x->ModuloPcgs(dser[x-1],dser[x]));

        # now do complement to NS(k)/k
        for z in [1..Length(pcgs)] do
          h:=ClosureGroup(dser[z],cgens);
          RUN_IN_GGMBI:=true; # hack to skip Nice treatment
          fphom:=GroupGeneralMappingByImagesNC(h,fp,
                  Concatenation(GeneratorsOfGroup(dser[z]),cgens),
                  Concatenation(List(GeneratorsOfGroup(dser[z]),x->One(fp)),
                    imgs));
          RUN_IN_GGMBI:=false;

          ocr:=rec(group:=h,modulePcgs:=pcgs[z],
                  factorfphom:=fphom);
          OCOneCocycles(ocr,true);
          cgens:=GeneratorsOfGroup(ocr.complement);
        od;

        if Size(dser[Length(dser)])>Size(j.hall) then
          gens:=[];
          for z in cgens do
            b:=Order(z);
            a:=Product(Filtered(Factors(b),x->x in pi));
            c:=GcdRepresentation(a,b/a);
            Add(gens,z^((b/a)*c[2]));
          od;
          h:=Group(gens);
          Info(InfoLattice,2,"Coprimize to ",Size(h));
          n:=NormalIntersection(j.ns,h);
          if Size(n)>1 then
            k:=NormalIntersection(k,h);
            if Size(k)>1 then
              Error("nonsolvable case with nontrivial k still to do");
            fi;

            # now work in sylow normalizer -- correct gens to normalize
            a:=SylowSubgroup(n,2);
            cgens:=[];
            for z in gens do
              Add(cgens,z->z*RepresentativeAction(n,a^z,a));
            od;
            h:=Group(cgens);
            a:=ComplementClassesRepresentatives(h,NormalIntersection(n,h));
            cgens:=GeneratorsOfGroup(h[1]);
          else
            cgens:=gens;
            k:=TrivialSubgroup(G);
          fi;


        fi;
        Add(all,ClosureGroup(k,cgens));

      else
        Info(InfoLattice,3,"does not work");
      fi;


    od;


  od;

  return all;

end);

InstallGlobalFunction(HallViaRadical,function(G,pi)
local ser,hom,s,fphom,sf,sg,sp,fp,d,head,mran,nran,mpcgs,ocr,len,pcgs,
      gens,all,indu;
  if ForAny(pi,x->not IsPrimeInt(x)) then
    Error("pi must be a set of primes");
  fi;
  ser:=FittingFreeLiftSetup(G);
  pcgs:=ser.pcgs;
  len:=Length(pcgs);
  hom:=ser.factorhom;
  if Intersection(pi,Factors(Size(Image(hom))))=[] then
    s:=HallSubgroup(Image(ser.pcisom),pi);
    sp:=List(Pcgs(s),x->PreImage(ser.pcisom,x));
    return [
      SubgroupByFittingFreeData(G,[],[],InducedPcgsByGeneratorsNC(pcgs,sp))];
  fi;

  all:=[];
  for s in HallsFittingFree(Image(hom),pi) do
    fphom:=IsomorphismFpGroup(s);
    fp:=Image(fphom);
    sf:=List(GeneratorsOfGroup(Image(fphom)),x->PreImagesRepresentative(fphom,x));
    sg:=List(sf,x->PreImagesRepresentative(hom,x));
    sp:=[];
    RUN_IN_GGMBI:=true; # hack to skip Nice treatment
    fphom:=GroupGeneralMappingByImagesNC(Group(sg,One(G)),fp,sg,
      GeneratorsOfGroup(fp));
    RUN_IN_GGMBI:=false;

    for d in [2..Length(ser.depths)] do
      mran:=[ser.depths[d-1]..len];
      nran:=[ser.depths[d]..len];
      head:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran});

      mpcgs:=head mod
            InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});
      if RelativeOrders(mpcgs)[1] in pi then
        if d=Length(ser.depths) then
          # last step, no presentation needed
          Append(sp,mpcgs);
        else
          # extend presentation
          RUN_IN_GGMBI:=true; # hack to skip Nice treatment
          fphom:=LiftFactorFpHom(fphom,Source(fphom),false,mpcgs);
          RUN_IN_GGMBI:=false;
          fp:=Image(fphom);
          sp:=Concatenation(sp,mpcgs);
        fi;
      else

        ocr:=rec(group:=Group(Concatenation(head,sg,sp)),modulePcgs:=mpcgs);
        ocr.factorfphom:=fphom;
        OCOneCocycles(ocr,true);
        gens:=GeneratorsOfGroup(ocr.complement);
        sg:=gens{[1..Length(sg)]};
        sp:=gens{[Length(sg)+1..Length(gens)]};
        RUN_IN_GGMBI:=true; # hack to skip Nice treatment
        fphom:=GroupGeneralMappingByImagesNC(ocr.complement,fp,gens,
          GeneratorsOfGroup(fp));
        RUN_IN_GGMBI:=false;

      fi;
    od;
    if Length(pcgs)>0 then
      indu:=InducedPcgsByPcSequenceNC(pcgs,sp);
    else
      indu:=[];
    fi;
    Add(all,
      SubgroupByFittingFreeData(G,sg,sf,indu));
  od;
  return all;
end);


#############################################################################
##
#M  HallSubgroupOp( <G>, <pi> )
##
## Fitting free approach
##
InstallMethod( HallSubgroupOp, "fitting free",true,
    [ IsGroup and IsFinite and CanComputeFittingFree,IsList ],
    OVERRIDENICE,
function(G,pi)
local l;
  if CanEasilyComputePcgs(G) then
    TryNextMethod(); # pcgs method is clearly better
  fi;
  l:=HallViaRadical(G,pi);
  if Length(l)=1 then
    return l[1];
  elif Length(l)=0 then
    return fail;
  else
    return l;
  fi;
end);


#############################################################################
##
#M  SylowSubgroupOp( <G>, <pi> )
##
## Fitting free approach
##
InstallMethod( SylowSubgroupOp, "fitting free",true,
  [ IsGroup and IsFinite and CanComputeFittingFree,IsPosInt ],
  OVERRIDENICE,
function(G,pi)
local l;
  if IsPermGroup(G) or IsPcGroup(G) then TryNextMethod();fi;

  if Set(Factors(Size(G)))=[pi] then
    SetIsPGroup(G,true);
    SetPrimePGroup(G, pi);
    return G;
  fi;
  l:=HallViaRadical(G,[pi]);
  if Length(l)=1 then
    SetIsPGroup(l[1],true);
    SetPrimePGroup(l[1],pi);
    return l[1];
  else
    Error("There can be only one class");
  fi;
end);

InstallMethod(ChiefSeriesTF,"fitting free",true,
  [IsGroup and CanComputeFittingFree ],0,
function(G)
local ff,i,j,c,q,a,b,prev,sub,m,k;
  ff:=FittingFreeLiftSetup(G);
  if Size(ff.radical)=Size(G) then
    c:=[G];
  else
    if Size(ff.radical)=1 then
      c:=ChiefSeries(G);
    else
      q:=Image(ff.factorhom,G);
      a:=ChiefSeries(q);
      c:=List(a,x->PreImage(ff.factorhom,x));
    fi;
  fi;
  # go through the depths
  prev:=ff.pcgs;
  for i in [2..Length(ff.depths)] do
    sub:=InducedPcgsByPcSequence(ff.pcgs,ff.pcgs{[ff.depths[i]..Length(ff.pcgs)]});
    m:=prev mod sub;
    k:=SubgroupNC(G,sub);
    a:=LinearActionLayer(G,m);
    a:=GModuleByMats(a,GF(RelativeOrders(m)[1]));
    b:=MTX.BasesSubmodules(a);
    b:=b{[2..Length(b)-1]}; # only intermnediate ones
    if Length(b)>0 then
      for j in Reversed(b) do
        Add(c,ClosureSubgroupNC(k,List(j,x->PcElementByExponents(m,x))));
      od;
    fi;
    Add(c,k);
    prev:=sub;
  od;
  return c;
end);
