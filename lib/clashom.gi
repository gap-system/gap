#############################################################################
##
#W  clashom.gi                  GAP library                  Alexander Hulpke
##
##
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains functions that compute the conjugacy classes of a
##  finite group by homomorphic images.
##  Literature: A.H: Conjugacy classes in finite permutation groups via
##  homomorphic images, MathComp, to appear.
##


#############################################################################
##
#F  GeneralStepClEANSNonsolv( <H>,<N>,<NT>,<cl> )
##
BindGlobal("GeneralStepClEANSNonsolv",function( H, N,NT, cl )
    local  classes,    # classes to be constructed, the result
           field,      # field over which <N> is a vector space
	   one,
           h,          # preimage `cl.representative' under <hom>
           cNh,        # centralizer of <h> in <N>
           C,  gens,   # preimage `Centralizer( cl )' under <hom>
           r,          # dimension of <N>
           ran,        # constant range `[ 1 .. r ]'
           aff,        # <N> as affine space
           xset,       # affine operation of <C> on <aff>
	   eo,	       # xorbits/stabilizers
           imgs,  M,   # generating matrices for affine operation
           orb,        # orbit of affine operation
           rep,# set of classes with canonical representatives
           c,  i, # loop variables
	   reduce,
	   stabsub,
	   comm,s,stab;# for class correction
	  
  #NT:=AsSubgroup(H,NT);
  C := cl[2];
  field := GF( RelativeOrders( N )[ 1 ] );
  one:=One(field);
  h := cl[1];
  reduce:=ReducedPermdegree(C);
  if reduce<>fail then
    C:=Image(reduce,C);
    Info(InfoHomClass,4,"reduced to deg:",NrMovedPoints(C));
    h:=Image(reduce,h);
    NT:=Image(reduce,NT);
    N:=ModuloPcgs(SubgroupNC(C,Image(reduce,NumeratorOfModuloPcgs(N))),NT);
  fi;
  
  
  # Determine the subspace $[h,N]$ and calculate the centralizer of <h>.
  #cNh := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
  #               KernelHcommaC( N, h, N!.capH ) );
  N!.capH:=N;
  cNh:=KernelHcommaC( N, h, N!.capH,2 );

  r := Length( N!.subspace.baseComplement );
  ran := [ 1 .. r ];
  
  # Construct matrices for the affine operation on $N/[h,N]$.
  aff := ExtendedVectors( field ^ r );

  if IsSolvableGroup(C) then
    gens:=Pcgs(C);
  else
    gens:=GeneratorsOfGroup(C);
  fi;
  imgs := [  ];
  for c  in gens  do
    M := [  ];
    for i  in [ 1 .. r ]  do
	M[ i ] := Concatenation( ExponentsConjugateLayer( N,
	      N[ N!.subspace.baseComplement[ i ] ] , c )
	      * N!.subspace.projection, [ Zero( field ) ] );
    od;
    M[ r + 1 ] := Concatenation( ExponentsOfPcElement
			  ( N, Comm( h, c ) ) * N!.subspace.projection,
			  [ One( field ) ] );

    M:=ImmutableMatrix(field,M);
    Add( imgs, M );
  od;
  xset := ExternalSet( C, aff, gens, imgs );

  classes := [  ];

  # NC is safe
  stabsub:=ClosureSubgroupNC(NT,cNh);
  SetActionKernelExternalSet(xset,stabsub);
  eo:=ExternalOrbitsStabilizers( xset );

  for orb in eo do
    rep := PcElementByExponentsNC( N, N{ N!.subspace.baseComplement },
		    Representative( orb ){ ran } );
    Assert(2,ForAll(GeneratorsOfGroup(stabsub),i->Comm(i,h*rep) in NT));

    # filter those we don't get anyhow.
    stab:=Filtered(GeneratorsOfGroup(StabilizerOfExternalSet(orb)),
                   i->not i in stabsub);

    comm := [  ];
    for s  in [ 1 .. Length( stab ) ]  do
	comm[ s ] := ExponentsOfPcElement( N,
	    Comm( rep, stab[ s ] ) * Comm( h, stab[ s ] ) )*one;
    od;
    comm:=ImmutableMatrix(field,comm);
    comm := comm * N!.subspace.inverse;
    for s  in [ 1 .. Length( comm ) ]  do
      stab[ s ] := stab[ s ] / PcElementByExponentsNC
	  ( N, N{ N!.subspace.needed }, comm[ s ] );
	  #( N!.capH, N!.capH{ N!.subspace.needed }, comm[ s ] );
      Assert(2,Comm(h*rep,stab[s]) in NT);
    od;

  # NC is safe
    stab:=ClosureSubgroupNC(stabsub,stab);

    if IsSolvableGroup(C) then
      SetIsSolvableGroup(stab,true);
    fi;
    c := [h * rep,stab];
    Assert(2,ForAll(GeneratorsOfGroup(stab),i->Comm(i,c[1]) in NT));

    if reduce<>fail then
      Add(classes,[PreImagesRepresentative(reduce,c[1]),
	PreImage(reduce,c[2])]);
    else
      Add(classes,c);
    fi;
  od;

  Assert(1,ForAll(classes,i->i[1] in H and IsSubset(H,i[2])));
  return classes;

end);

# new version, no subspace
#############################################################################
##
#F  GeneralStepCanEANSNonsolv( <H>,<N>,<NT>,<C>,<reps> )
##
## canonical rep
BindGlobal("GeneralStepCanEANSNonsolv",function( H, N,NT, C,h,reps,repo,nostab )
  local SchreierVectorProduct, field, one, r, ran, gens, imgs, M, invimgs, repvec, repgps, newreps, aff, sel, i, repsofi, orb, rep, dict, q, stab, sti, stabgens, p, img, mi, os, a, mipo, mimap, map, ngrp, c, j;

  SchreierVectorProduct:=function(n)
  local w,q,a;
    w:=One(C);
    while n<>1 do
      q:=rep[n];
      w:=gens[q]*w;
      n:=LookupDictionary(dict,orb[n]*invimgs[q]);
    od;
    return w;
  end;

  #NT:=AsSubgroup(H,NT);
  field := GF( RelativeOrders( N )[ 1 ] );
  one:=One(field);
  #reduce:=ReducedPermdegree(C);
  #if reduce<>fail then
  #  C:=Image(reduce,C);
  #  Info(InfoHomClass,4,"reduced to deg:",NrMovedPoints(C));
  #  h:=Image(reduce,h);
  #  NT:=Image(reduce,NT);
  #  N:=ModuloPcgs(SubgroupNC(C,Image(reduce,NumeratorOfModuloPcgs(N))),NT);
  #fi;

  r := Length(N);
  ran := [ 1 .. r ];
  
  # Construct matrices for the affine operation on $N/[h,N]$.
  gens:=Filtered(GeneratorsOfGroup(C),i->not i in NT);
  if Length(gens)>20 then
    gens:=Filtered(SmallGeneratingSet(C),i->not i in NT);
  fi;
  imgs := [  ];
  for c  in gens  do
    M := [  ];
    for i  in ran  do
      #M[i]:=Concatenation(ExponentsConjugateLayer(N,N[i],c)*one,[Zero(field)]);
      M[i]:=Concatenation(ExponentsOfPcElement(N,N[i]^c)*one,[Zero(field)]);
    od;
    M[r+1]:=Concatenation(ExponentsOfPcElement(N,Comm(h,c))*one,[One(field)]);

    M:=ImmutableMatrix(field,M);
    Add( imgs, M );
  od;
  invimgs:=List(imgs,Inverse);

  # get vectors for reps
  repvec:=List(repo,i->Concatenation(
	   ExponentsOfPcElement(N,LeftQuotient(h,reps[i][1]))*one,[one]));
  for i in repvec do
    ConvertToVectorRep(i,field);
  od;
  repgps:=[];
  newreps:=[];
  aff:=field^(r+1);
  sel:=[1..Length(repo)];
  while Length(sel)>0 do
    i:=sel[1];
    repsofi:=reps[repo[i]];
    RemoveSet(sel,i);
    # since we want representatives as well, recode the orbit algorithm.
    orb:=[repvec[i]];
    rep:=[0];
    dict:=NewDictionary(repvec[i],true,aff);
    AddDictionary(dict,repvec[i],1);

    # get stabilizing generators
    q:=gens{Filtered([1..Length(gens)],i->orb[1]*imgs[i]=orb[1])};
    if q=gens or nostab then 
      stab:=C;
    else
      stab:=ClosureGroup(NT,q);
    fi;
    sti:=5;
    if nostab then sti:=-1;fi;
    stabgens:=[];
    p:=1;
    while p<=Length(orb) do
      for j in [1..Length(gens)] do
	img:=orb[p]*imgs[j];
	q:=LookupDictionary(dict,img);
	if q=fail then
	  Add(orb,img);
	  AddDictionary(dict,img,Length(orb));
	  Add(rep,j);
	elif Size(C)/Size(stab)>Length(orb) then
	  if sti=0 then
	    Add(stabgens,[p,j,q]);
	    if Random([1..QuoInt(Length(orb),5)])=1 then
	      os:=Random([1..Length(stabgens)]);
	      mi:=stabgens[os];
	      stabgens[os]:=stabgens[Length(stabgens)];
	      Unbind(stabgens[Length(stabgens)]);
	      os:=Size(stab);
	      stab:=ClosureGroup(stab,SchreierVectorProduct(mi[1])*gens[mi[2]]
					/ SchreierVectorProduct(mi[3]));
              if Size(stab)>os then
		sti:=1;
	      fi;
	    fi;
	  else
	    os:=Size(stab);
	    stab:=ClosureGroup(stab,SchreierVectorProduct(p)*gens[j]
				      / SchreierVectorProduct(q));
            if Size(stab)=os then
	      sti:=sti-1;
	    fi;
	  fi;
	fi;
      od;
      p:=p+1;
    od;
    # add missing schreier gens
    a:=Size(C)/Length(orb);
    while Size(stab)<a and not nostab do
      os:=Random([1..Length(stabgens)]);
      mi:=stabgens[os];
      stabgens[os]:=stabgens[Length(stabgens)];
      Unbind(stabgens[Length(stabgens)]);
      stab:=ClosureGroup(stab,SchreierVectorProduct(mi[1])*gens[mi[2]]
				/ SchreierVectorProduct(mi[3]));
    od;

    Info(InfoHomClass,3,"Orbit length ",Length(orb),
        " with ",Length(gens)," generators");
    mi:=Minimum(orb); # the ``canonical'' rep.
    mipo:=LookupDictionary(dict,mi);
    mimap:=SchreierVectorProduct(mipo); # element moving starter to minimal
    map:=mimap;
    stab:=stab^map; # stabilize minimal element
    mi:=PcElementByExponentsNC(N,mi{ran});

    Assert(1,ForAll(GeneratorsOfGroup(stab),x->Comm(x,h*mi) in NT));

    ngrp:=[[repo[i]],h*mi,stab];
    Add(repgps,ngrp);
    newreps[repo[i]]:=[repsofi[1]^map,repsofi[2]*map,Length(repgps)];
    Assert(1,LeftQuotient(h*mi*One(NT),repsofi[1]^map) in NT);

    for i in ShallowCopy(sel) do
      q:=LookupDictionary(dict,repvec[i]);
      if q<>fail then
	RemoveSet(sel,i);
	repsofi:=reps[repo[i]];
	Add(ngrp[1],repo[i]);
	map:=LeftQuotient(SchreierVectorProduct(q),mimap);
	newreps[repo[i]]:=[repsofi[1]^map,repsofi[2]*map,Length(repgps)];
	Assert(1,LeftQuotient(h*mi,repsofi[1]^map) in NT);
      fi;
    od;

  od;

  return [repgps,newreps];

end);

  
#############################################################################
##
#F  CentralStepClEANSNonsolv( <H>, <N>, <cl> )
##
# the version for pc groups implicitly uses a pc-group orbit-stabilizer
# algorithm. We can't  do this but have to use a more simple-minded
# orbit/stabilizer approach.
BindGlobal("CentralStepClEANSNonsolv",function( H, N, cl )
local  classes,    	# classes to be constructed, the result
	f,          	# field over which <N> is a vector space
	o,
	n,r,		# dimensions
	space,
	com,
	comms,
	mats,
	decomp,
	reduce,
	v,
	h,          	# preimage `cl.representative' under <hom>
	C,		# preimage `Centralizer( cl )' under <hom>
	w,    		# coefficient vectors for projection along $[h,N]$
	c;          	# loop variable

  C:=cl[2];
  h := cl[1];
  reduce:=ReducedPermdegree(C);
  if reduce<>fail then
    C:=Image(reduce,C);
    Info(InfoHomClass,4,"reduced to deg:",NrMovedPoints(C));
    h:=Image(reduce,h);
    N:=ModuloPcgs(SubgroupNC(C,Image(reduce,NumeratorOfModuloPcgs(N))),
	          SubgroupNC(C,Image(reduce,DenominatorOfModuloPcgs(N))));
  fi;

  # centrality still means that conjugation by c is multiplication with
  # [h,c] and that the complement space is generated by commutators [h,c]
  # for a generating set {c|...} of C.

  f:=GF(RelativeOrders(N)[1]);
  n:=Length(N);
  o:=One(f);
  # commutator space basis
  comms:=List(GeneratorsOfGroup(C),c->o*ExponentsOfPcElement(N,Comm(h,c)));
  List(comms,x->ConvertToVectorRep(x,f));
  space:=List(comms,ShallowCopy);
  TriangulizeMat(space);
  space:=Filtered(space,i->i<>Zero(i)); # remove spurious columns

  com:=BaseSteinitzVectors(IdentityMat(n,f),space);

  # decomposition of vectors into the subspace basis
  r:=Length(com.subspace);
  if r>0 then
    # if the subspace is trivial, everything stabilizes

    decomp:=Concatenation(com.subspace,com.factorspace)^-1;
    decomp:=decomp{[1..Length(decomp)]}{[1..r]};
    decomp:=ImmutableMatrix(f,decomp);

    # build matrices for the affine action
    mats:=[];
    for w in comms do
      c:=IdentityMat(r+1,o);
      c[r+1]{[1..r]}:=w*decomp; # translation bit
      c:=ImmutableMatrix(f,c);
      Add(mats,c);
    od;

    #subspace affine enumerator
    v:=ExtendedVectors(f^r);

    C := Stabilizer( C, v, v[1],GeneratorsOfGroup(C), mats,OnPoints );
  fi;
  Assert(1,Size(cl[2])/Size(C)=Size(f)^r);

  if Length(com.factorspace)=0 then
    if reduce<>fail then
      classes:=[[PreImagesRepresentative(reduce,h),PreImage(reduce,C)]];
    else
      classes:=[[h,C]];
    fi;
  else
    classes:=[];
    # enumerator of complement
    v:=f^Length(com.factorspace);
    for w in v do
      c := [h * PcElementByExponentsNC( N,w*com.factorspace),C ];
      if reduce<>fail then
	Add(classes,[PreImagesRepresentative(reduce,c[1]),
	  PreImage(reduce,c[2])]);
      else
	Add(classes,c);
      fi;
    od;
  fi;

  Assert(1,ForAll(classes,i->i[1] in H and IsSubset(H,i[2])));
  return classes;
end);


#############################################################################    

#############################################################################
##
#F  ClassRepsPermutedTuples(<g>,<ran>)
##
##  computes representatives of the colourbars with colours selected from
##  <ran>.
BindGlobal("ClassRepsPermutedTuples",function(g,ran)
local anz,erg,pat,pat2,sym,nrcomp,coldist,stab,dc,i,j,k,sum,schieb,lstab,
      stabs,p;
  anz:=NrMovedPoints(g);
  sym:=SymmetricGroup(anz);
  erg:=[];
  stabs:=[];
  for nrcomp in [1..anz] do
    # all sorted colour distributions
    coldist:=Combinations(ran,nrcomp);
    for pat in OrderedPartitions(anz,nrcomp) do
      Info(InfoHomClass,3,"Pattern: ",pat);
      # compute the partition stabilizer
      stab:=[];
      sum:=0;
      for i in pat do
	schieb:=MappingPermListList([1..i],[sum+1..sum+i]);
	sum:=sum+i;
	stab:=Concatenation(stab,
	        List(GeneratorsOfGroup(SymmetricGroup(i)),j->j^schieb));
      od;
      stab:=Subgroup(sym,stab);
      dc:=List(DoubleCosetRepsAndSizes(sym,stab,g),i->i[1]);

      # compute expanded pattern
      pat2:=[];
      for i in [1..nrcomp] do
        for j in [1..pat[i]] do
	  Add(pat2,i);
	od;
      od;

      for j in dc do
	# the new bar's stabilizer
	lstab:=Intersection(g,ConjugateSubgroup(stab,j));
	p:=Position(stabs,lstab);
	if p=fail then
	  Add(stabs,lstab);
	else
	  lstab:=stabs[p];
	fi;
	# the new bar
	j:=Permuted(pat2,j);
        for k in coldist do
	  Add(erg,[List(j,i->k[i]),lstab]);
	od;
      od;
    od;
  od;
  return erg;
end);

#############################################################################
##
#F  ConjugacyClassesSubwreath(<F>,<M>,<n>,<autT>,<T>,<Lloc>,<comp>,<emb>,<proj>)
##
InstallGlobalFunction(ConjugacyClassesSubwreath,
function(F,M,n,autT,T,Lloc,components,embeddings,projections)
local clT,	# classes T
      lcl,	# Length(clT)
      clTR,	# classes under other group (autT,centralizer)
      fus,	# class fusion
      sci,	# |centralizer_i|
      oci,	# |reps_i|
      i,j,k,l,	# loop
      pfus,	# potential fusion
      op,	# operation of F on components
      ophom,	# F -> op
      clF,	# classes of F
      clop,	# classes of op
      bars,	# colour bars
      barsi,    # partial bars
      lallcolors,# |all colors|
      reps,Mproj,centralizers,centindex,emb,pi,varpi,newreps,newcent,
      newcentindex,centimages,centimgindex,C,p,P,selectcen,select,
      cen,eta,newcentlocal,newcentlocalindex,d,dc,s,t,elm,newcen,shift,
      cengen,b1,ore,
      # as in paper
      colourbar,newcolourbar,possiblecolours,potentialbars,bar,colofclass,
      clin,clout,
      etas,	# list of etas
      opfun,	# operation function
      r,rp,	# op-element complement in F
      cnt,
      brp,bcen,
      centralizers_r, # centralizers of r
      newcent_r,# new list to buid
      centrhom, # projection \rest{centralizer of r}
      localcent_r, # image
      cr,
      isdirprod,# is just M a direct product
      genpos,	# generator index
      genpos2,
      gen,	# generator
      stab,	# stabilizer
      stgen,	# local stabilizer generators
      trans,
      repres,
      img,
      limg,
      con,
      pf,
      orb,	# orbit
      orpo,	# orbit position
      minlen,	# minimum orbit length
      remainlen,#list of remaining lengths
      gcd,	# gcd of remaining orbit lengths
      stabtrue,
      diff,
      possible,
      combl,
      smacla,
      smare,
      ppos,
      maxdiff,
      again,	# run orbit again to get all
      trymap,	# operation to try
      skip,	# skip (if u=ug)
      ug,	# u\cap u^{gen^-1}
      scj,	# size(centralizers[j])
      dsz;	# Divisors(scj);


  Info(InfoHomClass,1,
       "ConjugacyClassesSubwreath called for almost simple group of size ",
        Size(T));
  isdirprod:=Size(M)=Size(autT)^n;

  # classes of T
  if IsNaturalSymmetricGroup(T) or IsNaturalAlternatingGroup(T) then
    clT:=ConjugacyClasses(T);
  else
    clT:=ConjugacyClassesByRandomSearch(T);
  fi;
  clT:=List(clT,i->[Representative(i),Centralizer(i)]);
  lcl:=Length(clT);
  Info(InfoHomClass,1,"found ",lcl," classes in almost simple");
  clTR:=List(clT,i->ConjugacyClass(autT,i[1]));

  # possible fusion under autT
  fus:=List([1..lcl],i->[i]);
  for i in [1..lcl] do
    sci:=Size(clT[i][2]);
    # we have taken a permutation representation that  prolongates to autT!
    oci:=CycleStructurePerm(clT[i][1]); 

    # we have tested already the smaller-# classes
    pfus:=Filtered([i+1..lcl],j->CycleStructurePerm(clT[j][1])=oci and
      Size(clT[j][2])=sci);
    pfus:=Difference(pfus,fus[i]);
    if Length(pfus)>0 then
      Info(InfoHomClass,3,"possible fusion ",pfus);
      for j in pfus do
        if clT[j][1] in clTR[i] then
	  fus[i]:=Union(fus[i],fus[j]);
	  # fuse the entries
	  for k in fus[i] do
	    fus[k]:=fus[i];
	  od;
	fi;
      od;
    fi;
  od;
  fus:=Set(fus); # throw out duplicates
  colofclass:=List([1..lcl],i->PositionProperty(fus,j->i in j));
  Info(InfoHomClass,2,"fused to ",Length(fus)," colours");

  # get the allowed colour bars
  ophom:=ActionHomomorphism(F,components,OnSets,"surjective");
  op:=Image(ophom);
  lallcolors:=Length(fus);
  bars:=ClassRepsPermutedTuples(op,[1..lallcolors]);

  Info(InfoHomClass,1,"classes in normal subgroup");
  # inner classes
  reps:=[One(M)];
  centralizers:=[M];
  centindex:=[1];
  colourbar:=[[]];

  Mproj:=[];
  varpi:=[];

  for i in [1..n] do
    Info(InfoHomClass,1,"component ",i);
    barsi:=Set(Immutable(List(bars,j->j[1]{[1..i]})));
    emb:=embeddings[i];
    pi:=projections[i];
    Add(varpi,ActionHomomorphism(M,Union(components{[1..i]}),"surjective"));
    Add(Mproj,Image(varpi[i],M));
    newreps:=[];
    newcent:=[];
    newcentindex:=[];
    centimages:=[];
    centimgindex:=[];
    newcolourbar:=[];

    etas:=[]; # etas for the centralizers

    # fuse centralizers that become the same
    for j in [1..Length(centralizers)] do
      C:=Image(pi,centralizers[j]);
      p:=Position(centimages,C);
      if p=fail then
        Add(centimages,C);
	p:=Length(centimages);
      fi;
      Add(centimgindex,p);

      # #force 'centralizers[j]' to have its base appropriate to the component
      # # (this will speed up preimages)
      # cen:=centralizers[j];
      # d:=Size(cen);
      # cen:=Group(GeneratorsOfGroup(cen),());
      # StabChain(cen,rec(base:=components[i],size:=d));
      # centralizers[j]:=cen;
      # etas[j]:=ActionHomomorphism(cen,components[i],"surjective");

    od;
    Info(InfoHomClass,2,Length(centimages)," centralizer images");

    # consider previous centralizers
    for j in [1..Length(centimages)] do
      # determine all reps belonging to this centralizer
      C:=centimages[j];
      selectcen:=Filtered([1..Length(centimgindex)],k->centimgindex[k]=j);
      Info(InfoHomClass,2,"Number ",j,": ",Length(selectcen),
            " previous centralizers to consider");
      
      # 7'
      select:=Filtered([1..Length(centindex)],k->centindex[k] in selectcen);
      # Determine the addable colours
      if i=1 then 
	possiblecolours:=[1..Length(fus)];
      else
	possiblecolours:=[];
	#for k in select do
	#  bar:=colourbar[k];
	k:=1;
	while k<=Length(select) 
	  and Length(possiblecolours)<lallcolors do
	  bar:=colourbar[select[k]];
	  potentialbars:=Filtered(bars,j->j[1]{[1..i-1]}=bar);
	  UniteSet(possiblecolours,
	           potentialbars{[1..Length(potentialbars)]}[1][i]);
	  k:=k+1;
	od;

      fi;

      for k in Union(fus{possiblecolours}) do
	# double cosets
	if Size(C)=Size(T) then
	  dc:=[One(T)];
	else

	  Assert(1,IsSubgroup(T,clT[k][2]));
	  Assert(1,IsSubgroup(T,C));

	  dc:=List(DoubleCosetRepsAndSizes(T,clT[k][2],C),i->i[1]);
	fi;
	for t in selectcen do
	  # continue partial rep. 

#	  #force 'centralizers[j]' to have its base appropriate to the component
#	  # (this will speed up preimages)
#	  if not (HasStabChainMutable(cen) 
#	     and i<=Length(centralizers)
#	     and BaseStabChain(StabChainMutable(cen))[1] in centralizers[i])
#	    then
#	    d:=Size(cen);
#	    cen:= Group( GeneratorsOfGroup( cen ), One( cen ) );
#	    StabChain(cen,rec(base:=components[i],size:=d));
#	    #centralizers[t]:=cen;
#	  fi;

	  cen:=centralizers[t];

	  if not IsBound(etas[t]) then
	    if Number(etas,i->IsBound(i))>500 then
	      for d in
		Filtered([1..Length(etas)],i->IsBound(etas[i])){[1..500]} do
		Unbind(etas[d]);
	      od;
	    fi;
	    etas[t]:=ActionHomomorphism(cen,components[i],"surjective");
	  fi;
	  eta:=etas[t];

	  select:=Filtered([1..Length(centindex)],l->centindex[l]=t);
	  Info(InfoHomClass,3,"centralizer nr.",t,", ",
	       Length(select)," previous classes");
	  newcentlocal:=[];
	  newcentlocalindex:=[];

	  for d in dc do
	    for s in select do
	      # test whether colour may be added here
	      bar:=Concatenation(colourbar[s],[colofclass[k]]);
	      bar:=ShallowCopy(colourbar[s]);
	      Add(bar,colofclass[k]);
	      MakeImmutable(bar);
	      #if ForAny(bars,j->j[1]{[1..i]}=bar) then
	      if bar in barsi then
		# new representative
		elm:=reps[s]*Image(emb,clT[k][1]^d);
		if elm in Mproj[i] then
		  # store the new element
		  Add(newreps,elm);
		  Add(newcolourbar,bar);
		  if i<n then # we only need the centralizer for further 
		              # components
		    newcen:=ClosureGroup(Lloc,
		              List(GeneratorsOfGroup(clT[k][2]),g->g^d));
		    p:=Position(newcentlocal,newcen);
		    if p=fail then
		      Add(newcentlocal,newcen);
		      p:=Length(newcentlocal);
		    fi;
		    Add(newcentlocalindex,p);
		  else
		    Add(newcentlocalindex,1); # dummy, just for counting
		  fi;
		#else
		#  Info(InfoHomClass,5,"not in");
		fi;

	      #else
	      #	Info(InfoHomClass,5,bar,"not minimal");
	      fi;
	      # end the loops from step 9
	    od;
	  od;
	  Info(InfoHomClass,2,Length(newcentlocalindex),
	       " new representatives");

	  if i<n then # we only need the centralizer for further components

	    # Centralizer preimages
	    shift:=[];
	    for l in [1..Length(newcentlocal)] do
	      P:=PreImage(eta,Intersection(Image(eta),newcentlocal[l]));

	      p:=Position(newcent,P);
	      if p=fail then
		Add(newcent,P);
		p:=Length(newcent);
	      fi;
	      shift[l]:=p;
	    od;

	    # move centralizer indices to global
	    for l in newcentlocalindex do
	      Add(newcentindex,shift[l]);
	    od;

	  fi;

	# end the loops from step 6,7 and 8
	od;
      od;
    od;

    centralizers:=newcent;
    centindex:=newcentindex;
    reps:=newreps;
    colourbar:=newcolourbar;
    # end the loop of step 2.
  od;

  Info(InfoHomClass,1,Length(reps)," classreps constructed");

  # further fusion among bars
  newreps:=[];
  Info(InfoHomClass,2,"computing centralizers");
  for bar in bars do
    b1:=Immutable(bar[1]);
    select:=Filtered([1..Length(reps)],i->colourbar[i]=b1);
    if Length(select)>1 then
      Info(InfoHomClass,2,"test ",Length(select)," classes for fusion");
    fi;
    newcentlocal:=[];
    for i in [1..Length(select)] do
      if not ForAny(newcentlocal,j->reps[select[i]] in j) then
	#AH we could also compute the centralizer
        C:=Centralizer(F,reps[select[i]]);
	Add(newreps,[reps[select[i]],C]);
	if i<Length(select) and Size(bar[2])>1 then
	  # there are other reps with the same bar left and the bar
	  # stabilizer is bigger than M
	  if not IsBound(bar[2]!.colstabprimg) then
	    # identical stabilizers have the same link. Therefore store the
	    # preimage in them
	    bar[2]!.colstabprimg:=PreImage(ophom,bar[2]);
	  fi;
	  # any fusion would take place in the stabilizer preimage
	  # we know that C must fix the bar, so it is the centralizer there.
	  r:=ConjugacyClass(bar[2]!.colstabprimg,reps[select[i]],C);
	  Add(newcentlocal,r);
	fi;
      fi;
    od;
  od;

  Info(InfoHomClass,1,"fused to ",Length(newreps)," inner classes");
  clF:=newreps;
  clin:=ShallowCopy(clF);
  Assert(1,Sum(clin,i->Index(F,i[2]))=Size(M));
  clout:=[];

  # outer classes

  clop:=Filtered(ConjugacyClasses(op),i->Order(Representative(i))>1);

  for k in clop do
    Info(InfoHomClass,1,"lifting class ",Representative(k));

    r:=PreImagesRepresentative(ophom,Representative(k));
    # try to make r of small order
    rp:=r^Order(Representative(k));
    rp:=RepresentativeAction(M,Concatenation(components),
                                  Concatenation(OnTuples(components[1],rp^-1),
				  Concatenation(components{[2..n]})),OnTuples);
    if rp<>fail then
      r:=r*rp;
    else
      Info(InfoHomClass,2,
           "trying random modification to get large centralizer");
      cnt:=LogInt(Size(autT),2)*10;
      brp:=();
      bcen:=Size(Centralizer(F,r));
      repeat
        rp:=Random(M);
	cengen:=Size(Centralizer(M,r*rp));
        if cengen>bcen then
	  bcen:=cengen;
	  brp:=rp;
	  cnt:=LogInt(Size(autT),2)*10;
	else
	  cnt:=cnt-1;
	fi;
      until cnt<0;
      r:=r*brp;
      Info(InfoHomClass,2,"achieved centralizer size ",bcen);
    fi;
    Info(InfoHomClass,2,"representative ",r);
    cr:=Centralizer(M,r);

    # first look at M-action
    reps:=[One(M)];
    centralizers:=[M];
    centralizers_r:=[cr];
    for i in [1..n] do;
      newreps:=[];
      newcent:=[];
      newcent_r:=[];
      opfun:=function(a,m)
               return Comm(r,m)*a^m;
             end;

      for j in [1..Length(reps)] do
	scj:=Size(centralizers[j]);
	dsz:=0;
	centrhom:=ActionHomomorphism(centralizers_r[j],components[i],
	            "surjective");
	localcent_r:=Image(centrhom);
	Info(InfoHomClass,4,i,":",j);
	Info(InfoHomClass,3,"acting: ",Size(centralizers[j])," minimum ",
	      Int(Size(Image(projections[i]))/Size(centralizers[j])),
	      " orbits.");
	# compute C(r)-classes
	clTR:=[];
	for l in clT do
	  Info(InfoHomClass,4,"DC",Index(T,l[2])," ",Index(T,localcent_r));
	  dc:=DoubleCosetRepsAndSizes(T,l[2],localcent_r);
	  clTR:=Concatenation(clTR,List(dc,i->l[1]^i[1]));
	od;

	orb:=[];
	for p in [1..Length(clTR)] do

	  repres:=PreImagesRepresentative(projections[i],clTR[p]);
	  if i=1 or isdirprod
	     or reps[j]*RestrictedPermNC(repres,components[i]) 
	            in Mproj[i] then
	    stab:=Centralizer(localcent_r,clTR[p]);
	    if Index(localcent_r,stab)<Length(clTR)/10 then
	      img:=Orbit(localcent_r,clTR[p]);
	      #ensure Representative is in first position
	      if img[1]<>clTR[p] then
	        genpos:=Position(img,clTR[p]);
		img:=Permuted(img,(1,genpos));
	      fi;
	    else
	      img:=ConjugacyClass(localcent_r,clTR[p],stab);
	    fi;
	    Add(orb,[repres,PreImage(centrhom,stab),img,localcent_r]);
	  fi;
	od;
	clTR:=orb;

	#was:
	#clTR:=List(clTR,i->ConjugacyClass(localcent_r,i));
	#clTR:=List(clTR,j->[PreImagesRepresentative(projections[i],
	#                                            Representative(j)),
	#	         PreImage(centrhom,Centralizer(j)),
	#		 j]);

	# put small classes to the top (to be sure to hit them and make
	# large local stabilizers)
	Sort(clTR,function(a,b) return Size(a[3])<Size(b[3]);end);

	Info(InfoHomClass,3,Length(clTR)," local classes");

	cengen:=GeneratorsOfGroup(centralizers[j]);
	#cengen:=Filtered(cengen,i->not i in localcent_r);

	while Length(clTR)>0 do

	  # orbit algorithm on classes
	  stab:=clTR[1][2];
	  orb:=[clTR[1]];
	  #repres:=RestrictedPermNC(clTR[1][1],components[i]);
	  repres:=clTR[1][1];
	  trans:=[One(M)];
	  select:=[2..Length(clTR)];

	  orpo:=1;
	  minlen:=Size(orb[1][3]);
	  possible:=false;
	  stabtrue:=false;
	  pf:=infinity;
	  maxdiff:=Size(T);
	  again:=0;
	  trymap:=false;
	  ug:=[];
	  # test whether we have full orbit and full stabilizer
	  while Size(centralizers[j])>(Sum(orb,i->Size(i[3]))*Size(stab)) do
	    genpos:=1;
	    while genpos<=Length(cengen) and
	      Size(centralizers[j])>(Sum(orb,i->Size(i[3]))*Size(stab)) do
	      gen:=cengen[genpos];
	      skip:=false;
	      if trymap<>false then
	        orpo:=trymap[1];
	        gen:=trymap[2];
		trymap:=false;
	      elif again>0 then
		if not IsBound(ug[genpos]) then
		  ug[genpos]:=Intersection(centralizers_r[j],
				   ConjugateSubgroup(centralizers_r[j],gen^-1));
		fi;
		if again<500 and ForAll(GeneratorsOfGroup(centralizers_r[j]),
		          i->i in ug[genpos])
		 then
		  # the random elements will give us nothing new
		  skip:=true;
		else
		  # get an element not in ug[genpos]
		  repeat
		    img:=Random(centralizers_r[j]);
		  until not img in ug[genpos] or again>=500;
		  gen:=img*gen;
	        fi;
	      fi;

	      if not skip then

		img:=Image(projections[i],opfun(orb[orpo][1],gen));

		smacla:=select;

		if not stabtrue then
		  p:=PositionProperty(orb,i->img in i[3]);
		  ppos:=fail;
                else
		  # we have the stabilizer and thus are only interested in
		  # getting new elements.
		  ppos:=PositionProperty(select,
			   i->Size(clTR[i][3])<=maxdiff and img in clTR[i][3]);
		  if ppos=fail then
		    p:="ignore"; #to avoid the first case
		  else
		    ppos:=select[ppos]; # get the right value
		    p:=fail; # go to first case
		  fi;
		fi;

		if p=fail then
		  if ppos=fail then
		    p:=First(select,
			   i->Size(clTR[i][3])<=maxdiff and img in clTR[i][3]);
                  else
		    p:=ppos;
		  fi;

		  RemoveSet(select,p);
		  Add(orb,clTR[p]);

		  #change the transversal element to map to the representative
		  con:=trans[orpo]*gen;
		  limg:=opfun(repres,con);
		  con:=con*PreImagesRepresentative(centrhom,
			   RepresentativeAction(localcent_r,
						 Image(projections[i],limg),
						 Representative(clTR[p][3])));
		  Assert(1,Image(projections[i],opfun(repres,con))
			   =Representative(clTR[p][3]));
		  Add(trans,con);
		  for stgen in GeneratorsOfGroup(clTR[p][2]) do
		    Assert( 1, IsOne( Image( projections[i],
				   opfun(repres,con*stgen/con)/repres ) ) );
		    stab:=ClosureGroup(stab,con*stgen/con);
		  od;

		  # compute new minimum length

		  if Length(select)>0 then
		    remainlen:=List(clTR{select},i->Size(i[3]));
		    gcd:=Gcd(remainlen);
		    diff:=minlen-Sum(orb,i->Size(i[3]));

		    if diff<0 then
		      # only go through this if the orbit actually grew
		      # larger
		      minlen:=Sum(orb,i->Size(i[3]));
		      repeat
			if dsz=0 then
			  dsz:=DivisorsInt(scj);
			fi;
			while not minlen in dsz do
			  # minimum gcd multiple to get at least the
			  # smallest divisor
			  minlen:=minlen+
			            (QuoInt((First(dsz,i->i>=minlen)-minlen-1),
				            gcd)+1)*gcd;
			od;

			# now try whether we actually can add orbits to make up
			# that length
			diff:=minlen-Sum(orb,i->Size(i[3]));
			Assert(1,diff>=0);
			# filter those remaining classes small enough to make
			# up the length
			smacla:=Filtered(select,i->Size(clTR[i][3])<=diff);
			remainlen:=List(clTR{smacla},i->Size(i[3]));
			combl:=1;
			possible:=false;
			if diff=0 then
			  possible:=fail;
			fi;
			while gcd*combl<=diff 
			      and combl<=Length(remainlen) and possible=false do
			  if NrCombinations(remainlen,combl)<100 then
			    possible:=ForAny(Combinations(remainlen,combl),
					     i->Sum(i)=diff);
			  else
			    possible:=fail;
			  fi;
			  combl:=combl+1;
			od;
			if possible=false then
			  minlen:=minlen+gcd;
			fi;
		      until possible<>false;
		    fi; # if minimal orbit length grew

		    Info(InfoHomClass,5,"Minimum length of this orbit ",
		         minlen," (",diff," missing)");

                  fi;

		  if minlen*Size(stab)=Size(centralizers[j]) then
		    #Assert(1,Length(smacla)>0);
		    maxdiff:=diff;
		    stabtrue:=true;
                  fi;

		elif not stabtrue then
		  # we have an element that stabilizes the conjugacy class.
		  # correct this to an element that fixes the representative.
		  # (As we have taken already the centralizer in
		  # centralizers_r, it is sufficient to correct by
		  # centralizers_r-conjugation.)
		  con:=trans[orpo]*gen;
		  limg:=opfun(repres,con);
		  con:=con*PreImagesRepresentative(centrhom,
			   RepresentativeAction(localcent_r,
						 Image(projections[i],limg),
						 Representative(orb[p][3])));
		  stab:=ClosureGroup(stab,con/trans[p]);
		  if Size(stab)*2*minlen>Size(centralizers[j]) then
		    Info(InfoHomClass,3,
		         "true stabilizer found (cannot grow)");
		    minlen:=Size(centralizers[j])/Size(stab);
		    maxdiff:=minlen-Sum(orb,i->Size(i[3]));
		    stabtrue:=true;
		  fi;
		fi;

		if stabtrue then

		  smacla:=Filtered(select,i->Size(clTR[i][3])<=maxdiff);

		  if Length(smacla)<pf then
		    pf:=Length(smacla);
		    remainlen:=List(clTR{smacla},i->Size(i[3]));

		    Info(InfoHomClass,3,
			"This is the true orbit length (missing ",
			maxdiff,")");

		    if Size(stab)*Sum(orb,i->Size(i[3]))
		        =Size(centralizers[j]) then
                      maxdiff:=0;

		    elif Sum(remainlen)=maxdiff then
		      Info(InfoHomClass,2,
			  "Full possible remainder must fuse");
		      orb:=Concatenation(orb,clTR{smacla});
		      select:=Difference(select,smacla);

		    else
		      # test whether there is only one possibility to get
		      # this length
		      if Length(smacla)<20 and
		       Sum(List([1..Minimum(Length(smacla),
		                    Int(maxdiff/gcd+1))],
			   x-> NrCombinations(smacla,x)))<10000 then
			# get all reasonable combinations
			smare:=[1..Length(smacla)]; #range for smacla
			combl:=Concatenation(List([1..Int(maxdiff/gcd+1)],
					      i->Combinations(smare,i)));
			# pick those that have the correct length
			combl:=Filtered(combl,i->Sum(remainlen{i})=maxdiff);
			if Length(combl)>1 then
			  Info(InfoHomClass,3,"Addendum not unique (",
			  Length(combl)," possibilities)");
			  if (maxdiff<10 or again>0) 
			    and ForAll(combl,i->Length(i)<=5) then
			    # we have tried often enough, now try to pick the
			    # right ones 
			    possible:=false;
			    combl:=Union(combl);
			    combl:=smacla{combl};
			    genpos2:=1;
			    smacla:=[];
			    while possible=false and Length(combl)>0 do
			      img:=Image(projections[i],
				opfun(clTR[combl[1]][1],cengen[genpos2]));
			      p:=PositionProperty(orb,i->img in i[3]);
			      if p<>fail then
				# it is!
				Info(InfoHomClass,4,"got one!");

				# remember the element to try
				trymap:=[p,(cengen[genpos2]*
				  PreImagesRepresentative(
				    RestrictedMapping(projections[i],
				      centralizers[j]),
				    RepresentativeAction(
				    orb[p][4],
				    img,Representative(orb[p][3]))  ))^-1];

				Add(smacla,combl[1]);
				combl:=combl{[2..Length(combl)]};
				if Sum(clTR{smacla},i->Size(i[3]))=maxdiff then
				  # bingo!
				  possible:=true;
				fi;
			      fi;
			      genpos2:=genpos2+1;
			      if genpos2>Length(cengen) then
				genpos2:=1;
				combl:=combl{[2..Length(combl)]};
			      fi;
			    od;
			    if possible=false then
			      Info(InfoHomClass,4,"Even test failed!");
			    else
			      orb:=Concatenation(orb,clTR{smacla});
			      select:=Difference(select,smacla);
			      Info(InfoHomClass,3,"Completed orbit (hard)");
			    fi;
			  fi;
			else
			  combl:=combl[1];
			  orb:=Concatenation(orb,clTR{smacla{combl}});
			  select:=Difference(select,smacla{combl});
			  Info(InfoHomClass,3,"Completed orbit");
			fi;
		      fi;
		    fi;
		  fi;

	        fi;
	      else
	        Info(InfoHomClass,5,"skip");
	      fi; # if not skip

	      genpos:=genpos+1;
	    od;
	    orpo:=orpo+1;
	    if orpo>Length(orb) then
	      Info(InfoHomClass,3,"Size factor:",EvalF(
	      (Sum(orb,i->Size(i[3]))*Size(stab))/Size(centralizers[j])),
	      " orbit consists of ",Length(orb)," suborbits, iterating");

	      orpo:=1;
	      again:=again+1;
	    fi;
	  od;
	  Info(InfoHomClass,2,"Stabsize = ",Size(stab),
		", centstabsize = ",Size(orb[1][2]));
	  clTR:=clTR{select};

	  Info(InfoHomClass,2,"orbit consists of ",Length(orb)," suborbits,",
	       Length(clTR)," classes left.");

	  Info(InfoHomClass,3,List(orb,i->Size(i[2])));
	  Info(InfoHomClass,4,List(orb,i->Size(i[3])));

          # select the orbit element with the largest local centralizer
	  orpo:=1;
	  p:=2;
	  while p<=Length(orb) do
	    if IsBound(trans[p]) and Size(orb[p][2])>Size(orb[orpo][2]) then
	      orpo:=p;
	    fi;
	    p:=p+1;
	  od;
	  if orpo<>1 then
	    Info(InfoHomClass,3,"switching to orbit position ",orpo);
	    repres:=opfun(repres,trans[orpo]);
	    #repres:=RestrictedPermNC(clTR[1][1],repres);
	    stab:=stab^trans[orpo];
	  fi;


	  Assert(1,ForAll(GeneratorsOfGroup(stab),
                j -> IsOne( Image(projections[i],opfun(repres,j)/repres) )));

	  # correct stabilizer to element stabilizer
	  Add(newreps,reps[j]*RestrictedPermNC(repres,components[i]));
	  Add(newcent,stab);
	  Add(newcent_r,orb[orpo][2]);
	od;

      od;
      reps:=newreps;
      centralizers:=newcent;
      centralizers_r:=newcent_r;

      Info(InfoHomClass,2,Length(reps)," representatives");
    od;

    select:=Filtered([1..Length(reps)],i->reps[i] in M);
    reps:=reps{select};
    reps:=List(reps,i->r*i);
    centralizers:=centralizers{select};
    centralizers_r:=centralizers_r{select};
    Info(InfoHomClass,1,Length(reps)," in M");

    # fuse reps if necessary
    cen:=PreImage(ophom,Centralizer(k));
    newreps:=[];
    newcentlocal:=[];
    for i in [1..Length(reps)] do
      bar:=CycleStructurePerm(reps[i]);
      ore:=Order(reps[i]);
      newcentlocal:=Filtered(newreps,
		     i->Order(Representative(i))=ore and
		     i!.elmcyc=bar);
      if not ForAny(newcentlocal,j->reps[i] in j) then
        C:=Centralizer(cen,reps[i]);
	# AH can we use centralizers[i] here ? 
	Add(clF,[reps[i],C]);
	Add(clout,[reps[i],C]);
	bar:=ConjugacyClass(cen,reps[i],C);
	bar!.elmcyc:=CycleStructurePerm(reps[i]);
	Add(newreps,bar);
      fi;
    od;
    Info(InfoHomClass,1,"fused to ",Length(newreps)," classes");
  od;
  
  Assert(1,Sum(clout,i->Index(F,i[2]))=Size(F)-Size(M));

  Info(InfoHomClass,2,Length(clin)," inner classes, total size =",
        Sum(clin,i->Index(F,i[2])));
  Info(InfoHomClass,2,Length(clout)," outer classes, total size =",
        Sum(clout,i->Index(F,i[2])));
  Info(InfoHomClass,3," Minimal ration for outer classes =",
	EvalF(Minimum(List(clout,i->Index(F,i[2])/(Size(F)-Size(M)))),30));

  Info(InfoHomClass,1,"returning ",Length(clF)," classes");

  Assert(1,Sum(clF,i->Index(F,i[2]))=Size(F));
  return clF;

end);

InstallGlobalFunction(ConjugacyClassesFittingFreeGroup,function(G)
local cs,	# chief series of G
      i,	# index cs
      cl,	# list [classrep,centralizer]
      hom,	# G->G/cs[i]
      M,	# cs[i-1]
      N,	# cs[i]
      subN,	# maximan normal in M over N
      csM,	# orbit of nt in M under G
      n,	# Length(csM)
      T,	# List of T_i
      Q,	# Action(G,T)
      Qhom,	# G->Q and F->Q
      S,	# PreImage(Qhom,Stab_Q(1))
      S1,	# Action of S on T[1]
      deg1,	# deg (s1)
      autos,	# automorphism for action
      arhom,	# autom permrep list
      Thom,	# S->S1
      T1,	# T[1] Thom
      w,	# S1\wrQ
      wbas,	# base of w
      emb,	# embeddings of w
      proj,	# projections of wbas
      components, # components of w
      reps,	# List reps in G for 1->i in Q
      F,	# action of G on M/N
      Fhom,	# G -> F
      FQhom,	# Fhom*Qhom
      genimages,# G.generators Fhom
      img,	# gQhom
      gimg,	# gFhom
      act,	# component permcation to 1
      j,k,	# loop
      C,	# Ker(Fhom)
      clF,	# classes of F
      ncl,	# new classes
      FM,	# normal subgroup in F, Fhom(M)
      FMhom,	# M->FM
      dc,	# double cosets
      jim,	# image of j
      Cim,
      CimCl,
      p,
      l,lj,
      l1,
      elm,
      zentr,
      onlysizes,
      good,bad,
      lastM;

  onlysizes:=ValueOption("onlysizes");
  # we assume the group has no solvable normal subgroup. Thus we get all
  # classes by lifts via nonabelian factors and can disregard all abelian
  # factors.

  # we will give classes always by their representatives in G and
  # centralizers by their full preimages in G.

  cs:= ChiefSeriesOfGroup( G );

  # the first step is always simple
  if HasAbelianFactorGroup(G,cs[2]) then
    # try to get the largest abelian factor
    i:=2;
    while i<Length(cs) and HasAbelianFactorGroup(G,cs[i+1]) do
      i:=i+1;
    od;
    cs:=Concatenation([G],cs{[i..Length(cs)]});
    # now cs[1]/cs[2] is the largest abelian factor

    cl:=List(RightTransversal(G,cs[2]),i->[i,G]);
  else
    # compute the classes of the simple nonabelian factor by random search
    hom:=NaturalHomomorphismByNormalSubgroupNC(G,cs[2]);
    cl:=ConjugacyClasses(Image(hom));
    cl:=List(cl,i->[PreImagesRepresentative(hom,Representative(i)),
		    PreImage(hom,StabilizerOfExternalSet(i))]);
  fi;
  lastM:=cs[2];

  for i in [3..Length(cs)] do
    # we assume that cl contains classreps/centralizers for G/cs[i-1]
    # we want to lift to G/cs[i]
    M:=cs[i-1];
    N:=cs[i];
    Info(InfoHomClass,1,i,":",Index(M,N),";  ",Size(N));
    if HasAbelianFactorGroup(M,N) then
      Info(InfoHomClass,2,"abelian factor ignored");
    else
      # nonabelian factor. Now it means real work.

      # 1) compute the action for the factor

      # first, we obtain the simple factors T_i/N.
      # we get these as intersections of the conjugates of the subnormal
      # subgroup

      csM:=CompositionSeries(M); # stored attribute
      if not IsSubset(csM[2],N) then
	# the composition series goes the wrong way. Now take closures of
	# its steps with N to get a composition series for M/N, take the
	# first proper factor for subN.
        n:=3;
	subN:=fail;
	while n<=Length(csM) and subN=fail do
	  subN:=ClosureGroup(N,csM[n]);
	  if Index(M,subN)=1 then
	    subN:=fail; # still wrong
	  fi;
	  n:=n+1;
	od;
      else
	subN:=csM[2];
      fi;
      
      if IsNormal(G,subN) then

	# only one -> Call standard process

	Fhom:=fail;
	# is this an almost top factor?
	if Index(G,M)<10 then
	  Thom:=NaturalHomomorphismByNormalSubgroupNC(G,subN);
	  T1:=Image(Thom,M);
	  S1:=Image(Thom);
	  if Size(Centralizer(S1,T1))=1 then
	    deg1:=NrMovedPoints(S1);
	    Info(InfoHomClass,2,
	      "top factor gives conjugating representation, deg ",deg1);

	    Fhom:=Thom;
	  fi;
	else
	  Thom:=NaturalHomomorphismByNormalSubgroupNC(M,subN);
	  T1:=Image(Thom,M);
	fi;

	if Fhom=fail then
	  autos:=List(GeneratorsOfGroup(G),
		    i->GroupHomomorphismByImagesNC(T1,T1,GeneratorsOfGroup(T1),
		      List(GeneratorsOfGroup(T1),
			    j->Image(Thom,PreImagesRepresentative(Thom,j)^i))));

	  # find (probably another) permutation rep for T1 for which all
	  # automorphisms can be represented by permutations
	  arhom:=AutomorphismRepresentingGroup(T1,autos);
	  S1:=arhom[1];
	  deg1:=NrMovedPoints(S1);
	  Fhom:=GroupHomomorphismByImagesNC(G,S1,GeneratorsOfGroup(G),arhom[3]);
	fi;


	C:=KernelOfMultiplicativeGeneralMapping(Fhom);
	F:=Image(Fhom,G);
	if IsNaturalSymmetricGroup(F) or IsNaturalAlternatingGroup(F) then
	  clF:=ConjugacyClasses(F);
	else
	  clF:=ConjugacyClassesByRandomSearch(F);
	fi;
	clF:=List(clF,j->[Representative(j),StabilizerOfExternalSet(j)]);

      else
	csM:=Orbit(G,subN); # all conjugates
	n:=Length(csM);

	if n=1 then
	  Error("this cannot happen");
	  T:=M;
	fi;

	T:=Intersection(csM{[2..Length(csM)]}); # one T_i
	if Length(GeneratorsOfGroup(T))>5 then
	  T:=Group(SmallGeneratingSet(T));
	fi;

	T:=Orbit(G,T); # get all the t's
	# now T[1] is a complement to csM[1] in G/N.
	
	# now compute the operation of G on M/N
	Qhom:=ActionHomomorphism(G,T,"surjective");
	Q:=Image(Qhom,G);
	S:=PreImage(Qhom,Stabilizer(Q,1)); 

	# find a permutation rep. for S-action on T[1]
	Thom:=NaturalHomomorphismByNormalSubgroupNC(T[1],N);
	T1:=Image(Thom,T[1]);
	autos:=List(GeneratorsOfGroup(S),
		  i->GroupHomomorphismByImagesNC(T1,T1,GeneratorsOfGroup(T1),
		    List(GeneratorsOfGroup(T1),
			  j->Image(Thom,PreImagesRepresentative(Thom,j)^i))));

	# find (probably another) permutation rep for T1 for which all
	# automorphisms can be represented by permutations
	arhom:=AutomorphismRepresentingGroup(T1,autos);
	S1:=arhom[1];
	deg1:=NrMovedPoints(S1);
	Thom:=GroupHomomorphismByImagesNC(S,S1,GeneratorsOfGroup(S),arhom[3]);

	T1:=Image(Thom,T[1]);

	# now embed into wreath
	w:=WreathProduct(S1,Q);
	wbas:=DirectProduct(List([1..n],i->S1));
	emb:=List([1..n+1],i->Embedding(w,i));
	proj:=List([1..n],i->Projection(wbas,i));
	components:=WreathProductInfo(w).components;

	# define isomorphisms between the components
	reps:=List([1..n],i->
		PreImagesRepresentative(Qhom,RepresentativeAction(Q,1,i)));

	genimages:=[];
	for j in GeneratorsOfGroup(G) do
	  img:=Image(Qhom,j);
	  gimg:=Image(emb[n+1],img);
	  for k in [1..n] do
	    # look at part of j's action on the k-th factor.
	    # we get this by looking at the action of
	    #   reps[k] *   j    *   reps[k^img]^-1
	    # 1   ->    k  ->  k^img    ->           1
	    # on the first component. 
	    act:=reps[k]*j*(reps[k^img]^-1);
	    # this must be multiplied *before* permuting
	    gimg:=ImageElm(emb[k],ImageElm(Thom,act))*gimg;
	    gimg:=RestrictedPermNC(gimg,MovedPoints(w));
	  od;
	  Add(genimages,gimg);
	od;

	F:=Subgroup(w,genimages);
	if AssertionLevel()>0 then
	  Fhom:=GroupHomomorphismByImages(G,F,GeneratorsOfGroup(G),genimages);
	  Assert(1,fail<>Fhom);
	else
	  Fhom:=GroupHomomorphismByImagesNC(G,F,GeneratorsOfGroup(G),genimages);
	fi;
	C:=KernelOfMultiplicativeGeneralMapping(Fhom);

	Info(InfoHomClass,1,"constructed Fhom");

	# 2) compute the classes for F

	if n>1 then
          #if IsPermGroup(F) and NrMovedPoints(F)<18 then
	  #  # the old Butler/Theissen approach is still OK
	  #  clF:=[];
	  #  for j in 
	  #   Concatenation(List(RationalClasses(F),DecomposedRationalClass)) do
	  #    Add(clF,[Representative(j),StabilizerOfExternalSet(j)]);
	  #  od;
	  #else
	    FM:=F;
	    for j in components do
	      FM:=Stabilizer(FM,j,OnSets);
	    od;

	    clF:=ConjugacyClassesSubwreath(F,FM,n,S1,
		  Action(FM,components[1]),T1,components,emb,proj);
	  #fi;
	else
	  FM:=Image(Fhom,M);
	  Info(InfoHomClass,1,
	      "classes by random search in almost simple group");
	  if IsNaturalSymmetricGroup(F) or IsNaturalAlternatingGroup(F) then
	    clF:=ConjugacyClasses(F);
	  else
	    clF:=ConjugacyClassesByRandomSearch(F);
	  fi;
	  clF:=List(clF,j->[Representative(j),StabilizerOfExternalSet(j)]);
	fi;
      fi; # true orbit of T.

      Assert(1,Sum(clF,i->Index(F,i[2]))=Size(F));
      Assert(1,ForAll(clF,i->Centralizer(F,i[1])=i[2]));

      # 3) combine to form classes of sdp 

      # the length(cl)=1 gets rid of solvable stuff on the top we got ``too
      # early''.
      if IsSubgroup(N,KernelOfMultiplicativeGeneralMapping(Fhom)) then
	Info(InfoHomClass,1,
	    "homomorphism is faithful for relevant factor, take preimages");
	if Size(N)=1 and onlysizes=true then
	  cl:=List(clF,i->[PreImagesRepresentative(Fhom,i[1]),Size(i[2])]);
	else
	  cl:=List(clF,i->[PreImagesRepresentative(Fhom,i[1]),
			    PreImage(Fhom,i[2])]);
        fi;
      else
	Info(InfoHomClass,1,"forming subdirect products");

	FM:=Image(Fhom,lastM);
	FMhom:=RestrictedMapping(Fhom,lastM);
	if Index(F,FM)=1 then
	  Info(InfoHomClass,1,"degenerated to direct product");
	  ncl:=[];
	  for j in cl do
	    for k in clF do
	      # modify the representative with a kernel elm. to project
	      # correctly on the second component
	      elm:=j[1]*PreImagesRepresentative(FMhom,
			  LeftQuotient(Image(Fhom,j[1]),k[1]));
	      zentr:=Intersection(j[2],PreImage(Fhom,k[2]));
	      Assert(2,ForAll(GeneratorsOfGroup(zentr),
		      i->Comm(i,elm) in N));
	      Add(ncl,[elm,zentr]);
	    od;
	  od;

	  cl:=ncl;

	else

	  # first we add the centralizer closures and sort by them
	  # (this allows to reduce the number of double coset calculations)
	  ncl:=[];
	  for j in cl do
	    Cim:=Image(Fhom,j[2]);
	    CimCl:=Cim;
	    #CimCl:=ClosureGroup(FM,Cim); # should be unnecessary, as we took
	    # the full preimage
	    p:=PositionProperty(ncl,i->i[1]=CimCl);
	    if p=fail then
	      Add(ncl,[CimCl,[j]]);
	    else
	      Add(ncl[p][2],j);
	    fi;
	  od;

	  Qhom:=NaturalHomomorphismByNormalSubgroupNC(F,FM);
	  Q:=Image(Qhom);
	  FQhom:=Fhom*Qhom;

	  # now construct the sdp's
	  cl:=[];
	  for j in ncl do
	    lj:=List(j[2],i->Image(FQhom,i[1]));
	    for k in clF do
	      # test whether the classes are potential mates
	      elm:=Image(Qhom,k[1]);
	      if not ForAll(lj,i->RepresentativeAction(Q,i,elm)=fail) then

		#l:=Image(Fhom,j[1]);
		      
		if Index(F,j[1])=1 then
		  dc:=[()];
		else
		  dc:=List(DoubleCosetRepsAndSizes(F,k[2],j[1]),i->i[1]);
		fi;
		good:=0;
		bad:=0;
		for l in j[2] do
		  jim:=Image(FQhom,l[1]);
		  for l1 in dc do
		    elm:=k[1]^l1;
		    if Image(Qhom,elm)=jim then
		      # modify the representative with a kernel elm. to project
		      # correctly on the second component
		      elm:=l[1]*PreImagesRepresentative(FMhom,
				  LeftQuotient(Image(Fhom,l[1]),elm));
		      zentr:=PreImage(Fhom,k[2]^l1);
		      zentr:=Intersection(zentr,l[2]);

		      Assert(2,ForAll(GeneratorsOfGroup(zentr),
			      i->Comm(i,elm) in N));

		      Info(InfoHomClass,4,"new class, order ",Order(elm),
			  ", size=",Index(G,zentr));
		      Add(cl,[elm,zentr]);
		      good:=good+1;
		    else
		      Info(InfoHomClass,5,"not in");
		      bad:=bad+1;
		    fi;
		  od;
		od;
		Info(InfoHomClass,4,good," good, ",bad," bad of ",Length(dc));
	      fi;
	    od;
	  od;
        fi; # real subdirect product

      fi; # else Fhom not faithful on factor

      # uff. That was hard work. We're finally done with this layer.
      lastM:=N;
    fi; # else nonabelian
    Info(InfoHomClass,1,"so far ",Length(cl)," classes computed");
  od;

  if Length(cs)<3 then
    Info(InfoHomClass,1,"Fitting free factor returns ",Length(cl)," classes");
  fi;
  Assert( 1, Sum( List( cl, pair -> Size(G) / Size( pair[2] ) ) ) = Size(G) );
  return cl;
end);

InstallGlobalFunction(ConjugacyClassesViaRadical,function (G)
local r,	#radical
      f,	# G/r
      hom,	# G->f
      pcgs,mpcgs, #(modulo) pcgs
      ser,	# series
      M,N,	# normal subgrops
      ind,	# indices
      i,	#loop
      new,	# new classes
      cl,ncl;	# classes

  # it seems to be cleaner (and avoids deferring abelian factors) if we
  # factor out the radical first. (Note: The radical method for perm groups
  # stores the nat hom.!)
  ser:=PermliftSeries(G);
  pcgs:=ser[2];
  ser:=ser[1];
  r:=ser[1];

  if Size(r)<Size(G) then
    if Size(r)>1 then
      hom:=NaturalHomomorphismByNormalSubgroupNC(G,r);
      f:=Image(hom);
      # we need centralizers
      cl:=ConjugacyClassesFittingFreeGroup(f:onlysizes:=false);
    else
      hom:=SmallerDegreePermutationRepresentation(G);
      f:=Image(hom);
      cl:=ConjugacyClassesFittingFreeGroup(f);
    fi;

    if not IsOne(hom) then
      ncl:=[];
      for i in cl do
	new:=[PreImagesRepresentative(hom,i[1])];
	if not IsInt(i[2]) then
	  Add(new,PreImage(hom,i[2]));
	fi;
        Add(ncl,new);
      od;
      cl:=ncl;
    fi;
  else
    cl:=[[One(G),G]];
  fi;

  for i in [2..Length(ser)] do
    M:=ser[i-1];
    N:=ser[i];
    
    # abelian factor, use affine methods
    Info(InfoHomClass,1,"abelian factor: ",Size(M),"->",Size(N));
    if pcgs=false then
      mpcgs:=ModuloPcgs(M,N);
    else
      mpcgs:=pcgs[i-1] mod pcgs[i];
    fi;

    ncl:=[];
    for i in cl do
      Assert(2,ForAll(GeneratorsOfGroup(i[2]),j->Comm(i[1],j) in M));
      if ForAll(GeneratorsOfGroup(i[2]),
		i->ForAll(mpcgs,j->Comm(i,j) in N)) then
	Info(InfoHomClass,3,"central step");
	new:=CentralStepClEANSNonsolv(G,mpcgs,i);
      else
	new:=GeneralStepClEANSNonsolv(G,mpcgs,AsSubgroup(G,N),i);
      fi;
      Assert(1,ForAll(new,
                  i->ForAll(GeneratorsOfGroup(i[2]),j->Comm(j,i[1]) in N)));
      Info(InfoHomClass,2,Length(new)," new classes");
      ncl:=Concatenation(ncl,new);
    od;
    cl:=ncl;
    Info(InfoHomClass,1,"Now: ",Length(cl)," classes");
  od;

  if Order(cl[1][1])>1 then
    # the idenity is not in first position
    Info(InfoHomClass,2,"identity not first, sorting");
    Sort(cl,function(a,b) return Order(a[1])<Order(b[1]);end);
  fi;

  Info(InfoHomClass,1,"forming classes");
  ncl:=[];
  for i in cl do
    if IsInt(i[2]) then
      r:=ConjugacyClass(G,i[1]);
      SetSize(r,Size(G)/i[2]);
    else
      #Assert(1,Centralizer(G,i[1])=i[2]);
      r:=ConjugacyClass(G,i[1],i[2]);
    fi;
    Add(ncl,r);
  od;

  cl:=ncl;

  # temporary fix for wrong centralizers -- this code will go away anyhow
  # in next release
  if Sum(ncl,Size)<>Size(G) then
    ncl:=List(ncl,x->ConjugacyClass(G,Representative(x)));
    if Sum(ncl,Size)<>Size(G) then
      Error("wrong classes");
    fi;
  fi;

  return ncl;
end);

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . . . of perm group
##
InstallMethod( ConjugacyClasses, "perm group", true, [ IsPermGroup ], 0,
function( G )
local cl;
  if (not HasIsNaturalSymmetricGroup(G) and IsNaturalSymmetricGroup(G)) or 
      (not HasIsNaturalAlternatingGroup(G) and IsNaturalAlternatingGroup(G))
      then
    # we found out anew that the group is symmetric or alternating ->
    # Redispatch
    return ConjugacyClasses(G);
  fi;

  cl:=ConjugacyClassesForSmallGroup(G);
  if cl<>fail then
    return cl;
  elif IsSimpleGroup( G )  then
    return ConjugacyClassesByRandomSearch( G );
  else
    return ConjugacyClassesViaRadical(G);
  fi;
end );

BindGlobal("CanonicalClassRepsViaRadical",function (G,reps)
local r,	#radical
      f,	# G/r
      hom,	# G->f
      pcgs,mpcgs, #(modulo) pcgs
      data,     # stored data
      ser,	# series
      M,N,	# normal subgrops
      ind,	# indices
      i,j,q,	#loop
      can,      # canonicals list
      pos,      # position
      conj,     # conjugating elements
      imgs,     # images in factor
      new,	# new classes
      gps,sel,  # grouping
      gpnum,
      ngps,off,
      cl,ncl;	# classes

  if IsBound(G!.canClassRepData) then
    data:=G!.canClassRepData;
  else
    # use the stored permlift series to stay consistent amongst calls
    ser:=PermliftSeries(G);
    data:=rec(pcgs:=ser[2],
	      ser:=ser[1],
	      mpcgs:=[]);
    G!.canClassRepData:=data;
    pcgs:=data!.pcgs;
    ser:=data!.ser;
    data.hom:=NaturalHomomorphismByNormalSubgroupNC(G,ser[1]);

    for i in [2..Length(ser)] do
      M:=ser[i-1];
      N:=ser[i];
      
      if pcgs=false then
	mpcgs:=ModuloPcgs(M,N);
      else
	mpcgs:=pcgs[i-1] mod pcgs[i];
      fi;
      data.mpcgs[i]:=mpcgs;
    od;
  fi;
  pcgs:=data!.pcgs;
  ser:=data!.ser;
  r:=ser[1];

  gps:=[];
  if Size(r)<Size(G) then
    hom:=data.hom;
    f:=Range(hom);
    if not IsBound(data.factorcanonicalclasses) then
      # we define ``canonical'' in the factor group to be arbitrary.
      can:=List(ConjugacyClasses(f),i->[i,Representative(i),Centralizer(i)]);
      data.factorcanonicalclasses:=can;
    fi;
    can:=data.factorcanonicalclasses;
    imgs:=List(reps,i->Image(hom,i));
    pos:=[];
    cl:=[];
    gps:=[];
    gpnum:=[];
    for i in [1..Length(imgs)] do
      j:=0;
      while not IsBound(pos[i]) do
	j:=j+1;
	if Order(imgs[i])=Order(can[j][2]) and
	((not IsPermGroup(f)) 
	  or CycleStructurePerm(imgs[i])=CycleStructurePerm(can[j][2])) then
	  conj:=RepresentativeAction(f,imgs[i],can[j][2]);
	else
	  conj:=fail;
	fi;
	if conj<>fail then
	  pos[i]:=j;
	  if IsBound(gpnum[j]) then
	    q:=gpnum[j];
	    Add(gps[q][1],i);
	  else
	    Add(gps,[[i],PreImagesRepresentative(hom,can[j][2]),
			 PreImage(hom,can[j][3])]);
	    q:=Length(gps);
	    gpnum[j]:=q;
	  fi;
	  conj:=PreImagesRepresentative(hom,conj);
	  cl[i]:=[reps[i]^conj,conj,q];
	fi;
      od;
    od;

  else
    gps:=[[1..Length(reps)],One(G),G];
    cl:=List(reps,i->[i,One(G),G,1]);
  fi;

  for i in [2..Length(ser)] do
    M:=ser[i-1];
    N:=ser[i];
    
    # abelian factor, use affine methods
    Info(InfoHomClass,1,"abelian factor: ",Size(M),"->",Size(N));
    mpcgs:=data.mpcgs[i];

    ngps:=[];
    ncl:=[];
    for i in gps do
      if false and ForAll(GeneratorsOfGroup(i[2]),
		i->ForAll(mpcgs,j->Comm(i,j) in N)) then
	Info(InfoHomClass,3,"central step");
	new:=CentralStepClEANSNonsolv(G,mpcgs,i);
      else
	new:=GeneralStepCanEANSNonsolv(G,mpcgs,AsSubgroup(G,N),
             i[3], # previous centralizer
	     i[2], # previous rep
	     cl,
	     i[1],
	     i=Length(ser)
	     );
      fi;
      off:=Length(ngps);
      Append(ngps,new[1]);
      new:=new[2];
      for j in [1..Length(reps)] do
	if IsBound(new[j]) then
	  new[j][3]:=new[j][3]+off; # correct group indices
	  ncl[j]:=new[j];
	fi;
      od;
    od;
    cl:=ncl;
    gps:=ngps;
  od;
  Assert(1,ForAll([1..Length(reps)],i->reps[i]^cl[i][2]=cl[i][1]));

  return List(cl,i->i{[1,2]});
end);


#############################################################################
##
#E

