#############################################################################
##
#W  grpcompl.gi                  GAP Library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997
##
##  This file contains the operations for the computation of complements in
##  'white box groups'
##
Revision.grpcompl_gi :=
    "@(#)$Id$";

SetInfoLevel(InfoComplement,3);

ComplementclassesSolvableWBG:=function(G,N)
local s,h,q,fpi,factorpres,com,ncom,nlcom,comgens,ncomgens,nlcomgens,cen,
      ncen,nlcen,i,j,k,fpcgs,ocr,l,opfun,v,dimran;

  # compute a series through N
  s:=ChiefSeriesUnderAction(G,N);

  Info(InfoComplement,1,"Series of factors:",
       List([1..Length(s)-1],i->Size(s[i])/Size(s[i+1])));

  # transfer probably to better group (later, AgCase)

  # construct a presentation
  h:=NaturalHomomorphismByNormalSubgroup(G,N);

  # AH still: Try to find a more simple presentation if available.

  q:=Image(h,G);
  fpi:=IsomorphismFpGroup(q);
  Info(InfoComplement,2,"using a presentation with ",
       Length(fpi!.genimages)," generators");
  factorpres:=[FreeGeneratorsOfFpGroup(Range(fpi)),
               RelatorsOfFpGroup(Range(fpi)),
	       List(fpi!.genimages,i->PreImagesRepresentative(fpi,i))];

  # initialize
  com:=[G];
  comgens:=[List(factorpres[3],i->PreImagesRepresentative(h,i))];
  cen:=[s[1]];

  # step down
  for i in [2..Length(s)] do
    Info(InfoComplement,1,"Step ",i-1);
    # we know the complements after s[i-1], we want them after s[i].
    fpcgs:=Pcgs(s[i-1]); # the factor pcgs
    fpcgs:=fpcgs mod InducedPcgsByGenerators(fpcgs,GeneratorsOfGroup(s[i]));

    ncom:=[];
    ncomgens:=[];
    ncen:=[];
    # loop over all complements so far
    for j in [1..Length(com)] do
      nlcom:=[];
      nlcomgens:=[];
      nlcen:=[];
      # compute complements
      ocr:=rec(group:=G,
               generators:=comgens[j],
	       modulePcgs:=fpcgs,
	       factorpres:=factorpres
	       );

      OCOneCocycles(ocr,true);

      l:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
                             BasisVectors(Basis(ocr.oneCoboundaries)));

      v:=Enumerator(VectorSpace(LeftActingDomain(ocr.oneCocycles),
                                l.factorspace,Zero(ocr.oneCocycles)));

      dimran:=[1..Length(v[1])];

      # fuse
      Info(InfoComplement,2,"fuse ",Length(v)," classes; working in dim ",
       Dimension(ocr.oneCocycles),"/",Dimension(ocr.oneCoboundaries));

      opfun:=function(z,g)
        Assert(3,z in v);
        z:=ocr.cocycleToList(z);
	for k in [1..Length(z)] do
	  z[k]:=Inverse(ocr.generators[k])*(ocr.generators[k]*z[k])^g;
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
	Assert(1,z in v);
	return z;
      end;

      l:=ExternalOrbitsStabilizers(cen[j],v,opfun);
      Info(InfoComplement,2,"splits in ",Length(l)," complements");

      for k in l do
	v:=StabilizerOfExternalSet(k);
	k:=ocr.cocycleToComplement(Representative(k));
	Assert(3,Length(GeneratorsOfGroup(k))=Length(fpi!.genimages));
	# correct stabilizer to obtain centralizer
	v:=Normalizer(v,ClosureGroup(s[i],k));

if
ForAny(GeneratorsOfGroup(v),j->ForAny(GeneratorsOfGroup(k),
                 l->not Comm(j,l) in s[i])) then
  Error("does not centralize modulo");
fi;

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

InstallMethod(ComplementclassesSolvableNC,"using cohomology",IsIdentical,
  [IsGroup,IsGroup],1,
  ComplementclassesSolvableWBG);

#############################################################################
##
#E  grpcompl.gi
##
