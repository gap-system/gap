#############################################################################
##
#W  grpcompl.gi                  GAP Library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for the computation of complements in
##  'white box groups'
##
Revision.grpcompl_gi :=
    "@(#)$Id$";

ComplementclassesSolvableWBG:=function(G,N)
local s,h,q,fpi,factorpres,com,ncom,nlcom,comgens,ncomgens,nlcomgens,cen,
      ncen,nlcen,i,j,k,fpcgs,ocr,l,opfun,v,dimran,ocrels;

  # compute a series through N
  s:=ChiefSeriesUnderAction(G,N);

  Info(InfoComplement,1,"Series of factors:",
       List([1..Length(s)-1],i->Size(s[i])/Size(s[i+1])));

  # transfer probably to better group (later, AgCase)

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
	       List(MappingGeneratorsImages(fpi)[2],
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
	  l:=[ExternalSet(cen[j],[Zero(ocr.oneCocycles)])];
	  SetStabilizerOfExternalSet(l[1],cen[j]);
        else
	  l:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
				 BasisVectors(Basis(ocr.oneCoboundaries)));

	  v:=Enumerator(VectorSpace(LeftActingDomain(ocr.oneCocycles),
				    l.factorspace,Zero(ocr.oneCocycles)));

	  dimran:=[1..Length(v[1])];

	  # fuse
	  Info(InfoComplement,2,"fuse ",Length(v)," classes; working in dim ",
	   Dimension(ocr.oneCocycles),"/",Dimension(ocr.oneCoboundaries));

	  opfun:=function(z,g)
	    Assert(3,z in AsList(v));
	    z:=ocr.cocycleToList(z);
	    for k in [1..Length(z)] do
	      z[k]:=Inverse(ocr.complementGens[k])*(ocr.complementGens[k]*z[k])^g;
	    od;
	    Assert(2,ForAll(z,k->k in s[i-1]));
	    z:=ocr.listToCocycle(z);
	    Assert(2,z in ocr.oneCocycles);
	    # sift z
	    for k in dimran do
	      if IsBound(l.heads[k]) and l.heads[k]<0 then
		z:=z-z[k]*l.subspace[-l.heads[k]];
	      fi;
	    od;
	    Assert(1,z in AsList(v));
	    return z;
	  end;

	  l:=ExternalOrbitsStabilizers(cen[j],v,opfun);
	fi;

	Info(InfoComplement,2,"splits in ",Length(l)," complements");
      else
        l:=[];
	Info(InfoComplement,2,"no complements");
      fi;

      for k in l do
	v:=StabilizerOfExternalSet(k);
	k:=ocr.cocycleToComplement(Representative(k));
	Assert(3,Length(GeneratorsOfGroup(k))
	          =Length(MappingGeneratorsImages(fpi)[2]));
	# correct stabilizer to obtain centralizer
	v:=Normalizer(v,ClosureGroup(s[i],k));

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

  return com;

end;

InstallMethod(ComplementclassesSolvableNC,"using cohomology",IsIdenticalObj,
  [IsGroup,IsGroup],1,
  ComplementclassesSolvableWBG);

#############################################################################
##
#E  grpcompl.gi
##
