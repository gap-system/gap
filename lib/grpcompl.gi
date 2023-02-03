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
##  This file contains the operations for the computation of complements in
##  'white box groups'
##


BindGlobal("COCohomologyAction",function(oc,actgrp,auts,orbs)
  local b, mats, orb, com, stabilizer, i,coc,u;
  if not IsBound(oc.complement) then
    return [];
  fi;
  oc.zero:=Zero(LeftActingDomain(oc.oneCocycles));
  b:=BaseSteinitzVectors(BasisVectors(Basis(oc.oneCocycles)),
                         BasisVectors(Basis(oc.oneCoboundaries)));
  if Length(b.factorspace)=0 then
    u:=rec(com:=[rec(cocycle:=Zero(oc.oneCocycles),stabilizer:=actgrp)],
           bas:=b);
    if orbs then
      u.com[1].orbit:=[Zero(oc.oneCocycles)];
    fi;
    return u;
  fi;
  Info(InfoComplement,2,"fuse ",
    Characteristic(oc.zero)^Length(b.factorspace)," classes");
  if Length(auts)=0 then
    auts:=[One(actgrp)];
  fi;

  mats:=COAffineCohomologyAction(oc,oc.complementGens,auts,b);
  orb:=COAffineBlocks(actgrp,auts,mats,orbs);
  com:=[];
  for i in orb do

    coc:=i.vector*b.factorspace;
    #u:=oc.cocycleToComplement(coc);
    u:=rec(cocycle:=coc,
                #complement:=u,
                stabilizer:=i.stabilizer);
    if orbs then u.orbit:=i.orbit;fi;
    Add(com,u);
  od;
  Info(InfoComplement,1,"obtain ",Length(com)," orbits");
  return rec(com:=com,bas:=b,mats:=mats);
end);

BindGlobal( "ComplementClassesRepresentativesSolvableWBG", function(arg)
local G,N,K,s, h, q, fpi, factorpres, com, comgens, cen, ocrels, fpcgs, ncom,
      ncomgens, ncen, nlcom, nlcomgens, nlcen, ocr, generators,
      l, complement, k, v, afu, i, j, jj;

  G:=arg[1];
  N:=arg[2];
  # compute a series through N
  if IsElementaryAbelian(N) then
    s:=[N,TrivialSubgroup(N)];
  else
    s:=ChiefSeriesUnderAction(G,N);
  fi;
  if Length(arg)=2 then
    K:=fail;
  else
    K:=arg[3];
    # build a series only down to K
    h:=List(s,x->ClosureGroup(K,x));
    s:=[h[1]];
    for i in h{[2..Length(h)]} do
      if Size(i)<Size(s[Length(s)]) then
        Add(s,i);
      fi;
    od;
  fi;

  Info(InfoComplement,1,"Series of factors:",
       List([1..Length(s)-1],i->Size(s[i])/Size(s[i+1])));

  # #T transfer probably to better group (later, AgCase)

  # construct a presentation
  h:=NaturalHomomorphismByNormalSubgroup(G,N);

  # AH still: Try to find a more simple presentation if available.

  if Source(h)=G then
    q:=ImagesSource(h);
  else
    q:=Image(h,G);
  fi;
  fpi:=IsomorphismFpGroup(q);
  Info(InfoComplement,2,"using a presentation with ",
       Length(MappingGeneratorsImages(fpi)[2])," generators");
  factorpres:=[FreeGeneratorsOfFpGroup(Range(fpi)),
               RelatorsOfFpGroup(Range(fpi)),
               List(GeneratorsOfGroup(Range(fpi)),
                    i->PreImagesRepresentative(fpi,i))];
  Assert(1,ForAll(factorpres[3],i->Image(h,PreImagesRepresentative(h,i))=i));
  # initialize
  com:=[G];
  comgens:=[List(factorpres[3],i->PreImagesRepresentative(h,i))];
  cen:=[s[1]];
  ocrels:=false;

  # step down
  for i in [2..Length(s)] do
    Info(InfoComplement,1,"Step ",i-1);
    # we know the complements after s[i-1], we want them after s[i].
    #fpcgs:=Pcgs(s[i-1]); # the factor pcgs
    #fpcgs:=fpcgs mod InducedPcgsByGenerators(fpcgs,GeneratorsOfGroup(s[i]));
    fpcgs:=ModuloPcgs(s[i-1],s[i]);

    ncom:=[];
    ncomgens:=[];
    ncen:=[];
    # loop over all complements so far
    for j in [1..Length(com)] do
      nlcom:=[];
      nlcomgens:=[];
      nlcen:=[];
      # compute complements
      ocr:=rec(group:=ClosureGroup(com[j],s[i-1]),
               generators:=comgens[j],
               modulePcgs:=fpcgs,
               factorpres:=factorpres
               );
      if ocrels<>false then
        ocr.relators:=ocrels;
        Assert(2,ForAll(ocr.relators,
                        k->Product(List([1..Length(k.generators)],
                              l->ocr.generators[k.generators[l]]^k.powers[l]))
                              in s[i-1]));
      fi;

      OCOneCocycles(ocr,true);
      ocrels:=ocr.relators;

      if IsBound(ocr.complement) then
        # special treatment for trivial case:
        if Dimension(ocr.oneCocycles)=Dimension(ocr.oneCoboundaries) then
          l:=[rec(stabilizer:=cen[j],
                  cocycle:=Zero(ocr.oneCocycles),
                  complement:=ocr.complement)];
        else
          #l:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
        #                         BasisVectors(Basis(ocr.oneCoboundaries)));
#
#          v:=Enumerator(VectorSpace(LeftActingDomain(ocr.oneCocycles),
#                                    l.factorspace,Zero(ocr.oneCocycles)));
#
#          dimran:=[1..Length(v[1])];
#
#          # fuse
#          Info(InfoComplement,2,"fuse ",Length(v)," classes; working in dim ",
#           Dimension(ocr.oneCocycles),"/",Dimension(ocr.oneCoboundaries));
#
#          opfun:=function(z,g)
#            Assert(3,z in AsList(v));
#            z:=ocr.cocycleToList(z);
#            for k in [1..Length(z)] do
#              z[k]:=Inverse(ocr.complementGens[k])*(ocr.complementGens[k]*z[k])^g;
#            od;
#            Assert(2,ForAll(z,k->k in s[i-1]));
#            z:=ocr.listToCocycle(z);
#            Assert(2,z in ocr.oneCocycles);
#            # sift z
#            for k in dimran do
#              if IsBound(l.heads[k]) and l.heads[k]<0 then
#                z:=z-z[k]*l.subspace[-l.heads[k]];
#              fi;
#            od;
#            Assert(1,z in AsList(v));
#            return z;
#          end;
#
#          k:=ExternalOrbitsStabilizers(cen[j],v,opfun);

          l:=COCohomologyAction(ocr,cen[j],GeneratorsOfGroup(cen[j]),false).com;
#          if Length(l)<>Length(k) then Error("differ!");fi;
        fi;

        Info(InfoComplement,2,"splits in ",Length(l)," complements");
      else
        l:=[];
        Info(InfoComplement,2,"no complements");
      fi;

      for k in l do
        q:=k.stabilizer;
        k:=ocr.cocycleToComplement(k.cocycle);
        Assert(3,Length(GeneratorsOfGroup(k))
                  =Length(MappingGeneratorsImages(fpi)[2]));
        # correct stabilizer to obtain centralizer

        v:=Normalizer(q,ClosureGroup(s[i],k));
        afu:=function(x,g) return CanonicalRightCosetElement(s[i],x^g);end;
        for jj in GeneratorsOfGroup(k) do
          if ForAny(GeneratorsOfGroup(v),x->not Comm(x,jj) in s[i]) then
            # we are likely very close as we centralized in the higher level
            # and stabilize the cohomology. Thus a plain stabilizer
            # calculation ought to work.
            v:=Stabilizer(v,CanonicalRightCosetElement(s[i],jj),afu);
          fi;
        od;


        Add(ncen,v);
        Add(nlcom,k);
        Add(nlcomgens,GeneratorsOfGroup(k));
      od;

      ncom:=Concatenation(ncom,nlcom);
      ncomgens:=Concatenation(ncomgens,nlcomgens);
      ncen:=Concatenation(ncen,nlcen);
    od;
    com:=ncom;
    comgens:=ncomgens;
    cen:=ncen;
    Info(InfoComplement,1,Length(com)," complements in total");
  od;

  if K<>fail then
    com:=List(com,x->ClosureGroup(K,x));
  fi;
  return com;

end );

InstallMethod(ComplementClassesRepresentativesSolvableNC,"using cohomology",
  IsIdenticalObj,
  [IsGroup,IsGroup],1,
  ComplementClassesRepresentativesSolvableWBG);
