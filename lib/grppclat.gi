#############################################################################
##
#W  grppclat.gi                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997  
##
##  This  file contains declarations for the subgroup lattice functions for
##  pc groups.
##
Revision.grppclat_gi:=
  "@(#)$Id$";

#############################################################################
##
#F  InvariantElementaryAbelianSeries( <G>, <morph>, [ <N> ] )
##           find <morph> invariant EAS of G (through N)
##
InvariantElementaryAbelianSeries := function(arg)
local G,morph,N,s,p,e,i,j,k,ise;
  G:=arg[1];
  morph:=arg[2];
  if Length(arg)>2 then
    N:=arg[3];
    e:=[G,N];
  else
    N:=TrivialSubgroup(G);
    e:=DerivedSeriesOfGroup(G);
  fi;
  e:=ElementaryAbelianSeries(e);
  s:=[G];
  i:=2;
  while i<=Length(e) do
    # intersect all images of normal subgroup to obtain invariant one
    # as G is invariant, we dont have to deal with special cases
    ise:=[e[i]];
    for j in ise do
      for k in morph do
	p:=Image(k,j);
	if not p in ise then
	  Add(ise,p);
        fi;
      od;
    od;
    ise:=Intersection(ise);
    Add(s,ise);
    p:=Position(e,ise);
    if p<>false then
      i:=p+1;
    else
      e:=ElementaryAbelianSeries([G,ise,TrivialSubgroup(G)]);
      i:=Position(e,ise)+1;
    fi;
  od;
  return s;
end;

#############################################################################
##
#F  InducedAutomorphism(<epi>,<aut>)
##
InducedAutomorphism := function(epi,aut)
local f;
  f:=Range(epi);
  if IsInnerAutomorphismRep(aut) and aut!.conjugator in Source(epi) then
    aut:=InnerAutomorphism(f,Image(epi,aut!.conjugator));
  else
    aut:=GroupHomomorphismByImages(f,f,GeneratorsOfGroup(f),
				   List(GeneratorsOfGroup(f),
	       i->Image(epi,Image(aut,PreImagesRepresentative(epi,i)))));
    SetIsInjective(aut,true);
    SetIsSurjective(aut,true);
  fi;
  return aut;
end;

#############################################################################
##
#F  InvariantSubgroupsElementaryAbelianGroup(<G>,<homs>[,<dims])  submodules
#F    find all subgroups of el. ab. <G>, which are invariant under all <homs>
#F    which have dimension in dims
##
InvariantSubgroupsElementaryAbelianGroup := function(arg)
local g,op,a,pcgs,ma,mat,d,f,i,j,new,newmat,id,p,dodim,compldim,compl,dims;
  g:=arg[1];
  op:=arg[2];
  if not IsElementaryAbelian(g) then
    Error("<g> must be a vector space");
  fi;
  if IsTrivial(g) then
    return [g];
  fi;
  pcgs:=Pcgs(g);
  d:=Length(pcgs);
  p:=RelativeOrderOfPcElement(pcgs,pcgs[1]);
  f:=GF(p);
  if Length(arg)=2 then
    dims:=[0..d];
  else
    dims:=arg[3];
  fi;

  if Length(dims)=0 then
    return [];
  fi;

  if Length(op)=0 then

    # trivial operation: enumerate subspaces
    # check which dimensions we'll need
    ma:=QuoInt(d,2);
    dodim:=[];
    compldim:=[];
    for i in dims do
      if i<=ma then
        AddSet(dodim,i);
      else
        AddSet(dodim,d-i);
	AddSet(compldim,d-i);
      fi;
    od;
    if d<3 then compldim:=[]; fi;
    dodim:=Maximum(dodim);

    # enumerate spaces
    id:=IdentityMat(d, 1);
    ma:=[[],[id[1]]];
    # the complements to ma
    if d>1 then
      compl:=[ShallowCopy(id)];
    else
      compl:=[];
    fi;
    if d>2 then
      Add(compl,NullspaceMat(TransposedMat(id{[1]})));
    fi;
    for i in [2..d] do
      new:=[];
      for mat in ma do
	# subspaces of equal dimension
	for j in [0..p^Length(mat)-1] do
	  if j=0 then
	    # special case for subspace of higher dimension
	    if Length(mat)<dodim then
	      newmat:=Concatenation(mat,[id[i]]);
	    else
	      newmat:=false;
	    fi;
	  else
	    # possible extension number d
	    a:=CoefficientsQadic(j,p);
	    newmat:=List(mat,ShallowCopy);
	    for j in [1..Length(a)] do
		newmat[j][i]:=a[j];
	    od;
	  fi;
	  if newmat<>false then
	    # we will need the space for the next level
	    Add(new,newmat);

	    # note complements if necc.
	    if Length(newmat) in compldim then
	      Add(compl,List(NullspaceMat(TransposedMat(newmat*One(f))),
	                     i->List(i,IntFFE)));
	    fi;
	  fi;
        od;
      od;
      ma:=Concatenation(ma,new);
    od;
    
    ma:=Concatenation(ma,compl);

    # take only those of right dim
    ma:=Filtered(ma,i->Length(i) in dims);

    # convert to grps (noting also the triv. one)
    new:=[];
    for i in ma do
      Add(new,Subgroup(Parent(g),
        List(i,j->Product([1..d],k->pcgs[k]^j[k]))));
    od;
    ma:=new;

  else

    # compute representation
    ma:=[];
    for i in op do
      mat:=[];
      for j in pcgs do
	Add(mat,ExponentsOfPcElement(pcgs,Image(i,j))*One(f));
      od;
      Add(ma,mat);
    od;

    ma:=GModuleByMats(ma,f);
    mat:=MTX.BasesSubmodules(ma);

    ma:=[];
    for i in mat do
      Add(ma,Subgroup(Parent(g),
		      List(i,j->Product([1..d],k->pcgs[k]^IntFFE(j[k])))));
    od;
  fi;
  return ma;
end;

# test whether the c-conjugate of g is h-invariant, internal
HasInvariantConjugateSubgroup:=function(g,c,h)
  # This should be done better!
  g:=ConjugateSubgroup(g,c);
  return ForAll(h,i->Image(i,g)=g);
end;

#############################################################################
##
#F  InvariantSubgroupsPcGroup(<G>[,<opt>]) . classreps of subgrps of <G>,
##   				             <homs>-inv. with options.
##    Options are:  
##                  actions:  list of automorphisms: search for invariants
##                  normal:   just search for normal subgroups
##                  consider: function(A,N,B,M) indicator function, whether 
##			      complements of this type would be needed
##                  retnorm:  return normalizers
##
InvariantSubgroupsPcGroup := function(arg)
local g,	# group
      isom,	# isomorphism onto AgSeries group
      func,	# automorphisms to be invariant under
      funcs,    # <func>
      funcnorm, # N_G(funcs)
      efunc,	# induced automs on factor
      efnorm,	# funcnorm^epi
      e,	# EAS
      len,	# Length(e)
      start,	# last index with EA factor
      i,j,k,l,
      m,kp,	# loop
      kgens,	# generators of k
      kconh,	# complemnt conjugacy storage
      opt,	# options record
      normal,	# flag for 'normal' option
      consider,	# optional 'consider' function
      retnorm,	# option: return all normalizers
      f,	# g/e[i]
      epi,	# g -> f
      lastepi,  # epi of last step
      n,	# e[i-1]^epi
      fa,	# f/n = g/e[i-1]
      hom,	# f -> fa
      B,	# subgroups of n	
      a,	# preimg. of group over n
      no,	# N_f(a)
      bs,	# b\in B normal under a, reps
      bsnorms,	# respective normalizers
      b,	# in bs
      bpos,	# position in bs
      fb,	# N_f(b)/b
      hom2,	# N_f(b) -> fb
      nim,	# n^hom2
      nag,	# AgGroup(nim)
      fg,	# (a/b)/(n/b)
      fghom,	# assoc. epi
      t,s,	# dnk-transversals
      z,	# Cocycles
      coboundbas,# Basis(OneCobounds)
      field,	# GF(Exponent(n))
      com,	# complements
      comnorms,	# normalizers
      comproj,	# projection onto complement
      kgn,
      kgim,	# stored decompositions, translated to matrix language
      kgnr,	# assoc index
      ncom,	# dito, tested
      idmat,	# 1-matrix
      mat,	# matrix action
      mats,	# list of mats
      conj,	# matrix action	
      chom,	# homom onto <conj>
      shom,	# by s induced autom
      shoms,	# list of these
      smats,	# dito, matrices 
      conjnr,	# assoc. index
      glsyl,
      glsyr,	# left and right side of eqn system
      found,	# indicator for success
      grp,	# intermediate group
      grps,	# list of subgroups
      ngrps,	# dito, new level
      gj,	# grps[j]
      grpsnorms,# normalizers of grps
      ngrpsnorms,# dito, new level
      bgids,    # generators of b many 1's (used for copro)
      opr,	# operation on complements
      xo;	# xternal orbits


  g:=arg[1];
  if Length(arg)>1 and IsRecord(arg[Length(arg)]) then
    opt:=arg[Length(arg)];
  else
    opt:=rec();
  fi;

  # parse options
  normal:=IsBound(opt.normal) and opt.normal=true;
  if IsBound(opt.consider) then 
    consider:=opt.consider;
  else
    consider:=false;
  fi;

  retnorm:=IsBound(opt.retnorm) and opt.retnorm;

  isom:=fail;

  # get automorphisms and compute their normalizer, if applicable
  if IsBound(opt.actions) then
    func:=opt.actions;
    hom2:=Filtered(func,IsInnerAutomorphismRep);
    hom2:=List(hom2,i->i!.conjugator);

    funcs:=Group(Filtered(func,i->not IsInnerAutomorphismRep(i)),
                 IdentityMapping(g));
    if Size(funcs)=1 then
      func:=hom2;
      b:=Parent(g);
    elif IsSolvableGroup(funcs) then
      a:=IsomorphismPcGroup(funcs);
      b:=SemidirectProduct(Image(a),InverseGeneralMapping(a),g);
      hom:=Embedding(b,1);
      funcs:=List(GeneratorsOfGroup(funcs),i->Image(hom,Image(a,i)));
      isom:=Embedding(b,2);
      hom2:=List(hom2,i->Image(isom,i));
      func:=Concatenation(funcs,hom2);
      g:=Image(hom,g);
    else
      Error("lazy programmer: code not yet written");
    fi;

    # get the normalizer of <func>
    funcnorm:=Normalizer(g,Subgroup(b,func));
    Assert(1,IsSubgroup(g,funcnorm));

    func:=List(func,i->InnerAutomorphism(b,i));

    # compute <func> characteristic series
    e:=InvariantElementaryAbelianSeries(g,func);
    f:=DerivedSeriesOfGroup(g);
    if Length(e)>Length(f) and
      ForAll([1..Length(f)-1],i->IsElementaryAbelian(f[i]/f[i+1])) then
      Info(InfoPcSubgroup,1,"  Preferring Derived Series");
      e:=f;
    fi;
  else
    func:=[];
    funcnorm:=g;
    e:=ElementaryAbelianSeries(g);
  fi;

#  # check, if the series is compatible with the AgSeries and if g is a
#  # parent group. If not, enforce this
#  if not(IsParent(g) and ForAll(e,i->IsElementAgSeries(i))) then
#    Info(InfoPcSubgroup,1,"  computing better series");
#    isom:=IsomorphismAgGroup(e);
#    g:=Image(isom,g);
#    e:=List(e,i->Image(isom,i));
#    funcnorm:=Image(isom,funcnorm);
#
#    #func:=List(func,i->isom^-1*i*isom); 
#    hom:=[];
#    for i in func do
#      hom2:=GroupHomomorphismByImages(g,g,g.generators,List(g.generators,
#                 j->Image(isom,Image(i,PreImagesRepresentative(isom,j)))));
#      hom2.isMapping:=true;
#      Add(hom,hom2);
#    od;
#    func:=hom;
#  else
#    isom:=false;
#  fi;

  len:=Length(e);
  # search the largest elementary abelian quotient
  start:=2;
  while start<len and IsElementaryAbelian(g/e[start+1]) do
    start:=start+1;
  od;

  # compute all subgroups there
  if start<len then
    # form only factor groups if necessary
    epi:=NaturalHomomorphismByNormalSubgroup(g,e[start]);
    LockNaturalHomomorphismsPool(g,e[start]);
    f:=Image(epi,g);
  else
    f:=g;
    epi:=IdentityMapping(f);
  fi;
  lastepi:=epi;
  efunc:=List(func,i->InducedAutomorphism(epi,i));
  grps:=InvariantSubgroupsElementaryAbelianGroup(f,efunc);
  Assert(1,ForAll(grps,i->ForAll(efunc,j->Image(j,i)=i)));
  grpsnorms:=List(grps,i->f);

  for i in [start+1..len] do
    Info(InfoPcSubgroup,1," step ",i,": ",Index(e[i-1],e[i]),", ",
                    Length(grps)," groups"); 
    # compute modulo e[i]
    if i<len then
      # form only factor groups if necessary
      epi:=NaturalHomomorphismByNormalSubgroup(g,e[i]);
      f:=Image(epi,g);
    else
      f:=g;
      epi:=IdentityMapping(g);
    fi;
    n:=Image(epi,e[i-1]);

    # the induced factor automs
    efunc:=List(func,i->InducedAutomorphism(epi,i));
#NOCH: filtere nichttriv.

    if Length(efunc)>0 then
      efnorm:=Image(epi,funcnorm);
    fi;

    B:=InvariantSubgroupsElementaryAbelianGroup(n,efunc);
    Info(InfoPcSubgroup,2,"  ",Length(B)," normal subgroups"); 

    # note the groups in B
    ngrps:=SubgroupsOrbitsAndNormalizers(f,B,true);
    ngrpsnorms:=List(ngrps,i->i.normalizer);
    ngrps:=List(ngrps,i->i.representative);

    # Get epi to the old factor group
    # as hom:=NaturalHomomorphism(f,fa); does not work, we have to play tricks
    hom:=lastepi;
    lastepi:=epi;
    fa:=Image(hom,g);

    hom:=GroupHomomorphismByImages(f,fa,GeneratorsOfGroup(f),
           List(GeneratorsOfGroup(f),i->
	     Image(hom,PreImagesRepresentative(epi,i))));

    # lift the known groups
    for j in [1..Length(grps)] do

      gj:=grps[j];
      if Size(gj)>1 then
	a:=PreImage(hom,gj);
	Add(ngrps,a);
	no:=PreImage(hom,grpsnorms[j]);
	Add(ngrpsnorms,no);

	if Length(efunc)>0 then
	  # get the double cosets
	  t:=List(DoubleCosets(f,no,efnorm),Representative);
	  Info(InfoPcSubgroup,2,"  |t|=",Length(t));
	  t:=Filtered(t,i->HasInvariantConjugateSubgroup(a,i,efunc));
	  Info(InfoPcSubgroup,2,"invar:",Length(t));
        fi;

	# we have to extend with those b in B, that are normal in a
	bs:=Filtered(B,i->IsNormal(a,i) and Size(i)<Size(n));

        if Length(efunc)>0 and Length(t)>1 then
	  # compute also the invariant ones under the conjugates:
	  # equivalently: Take all equivalent ones and take those, whose
	  # conjugates lie in a and are normal under a
	  for k in Filtered(t,i->not i in no) do
	    bs:=Union(bs,Filtered(List(B,i->ConjugateSubgroup(i,k^(-1))),
		  i->IsSubgroup(a,i) and IsNormal(a,i) and Size(i)<Size(n) ));
	  od;
	fi;

	# take only those bs which are valid
	if consider<>false then
	  Info(InfoPcSubgroup,2,"  ",Length(bs)," subgroups lead to ");
	  bs:=Filtered(bs,j->consider(a,n,j,e[i])<>false);
	  Info(InfoPcSubgroup,2,Length(bs)," valid ones");
	fi;

	# fuse under the action of no and compute the local normalizers
	bs:=SubgroupsOrbitsAndNormalizers(no,bs,true);
        bsnorms:=List(bs,i->i.normalizer);
	bs:=List(bs,i->i.representative);
Assert(1,ForAll(bs,i->ForAll(efunc,j->Image(j,i)=i)));

	# now run through the b in bs
	for bpos in [1..Length(bs)] do
	  b:=bs[bpos];
	  # test, whether we'll have to consider this case

# this test has basically be done before the orbit calculation already
#	  if consider<>false and consider(a,n,b,e[i])=false then
#	    Info(InfoPcSubgroup,2,"  Ignoring case");
#	    s:=[];

	  # test, whether b is invariant
	  if Length(efunc)>0 then
	    # extend to dcs of bnormalizer
	    s:=RightTransversal(no,bsnorms[bpos]);
	    nag:=Length(s);
	    s:=Concatenation(List(s,i->List(t,j->i*j)));
	    z:=Length(s);
	    #NOCH: Fusion
	    # test, which ones are usable at all
	    s:=Filtered(s,i->HasInvariantConjugateSubgroup(b,i,efunc));
	    Info(InfoPcSubgroup,2,"  |s|=",nag,"-(m)>",z,"-(i)>",Length(s));
	  else
	    s:=[()];
	  fi;

          if Length(s)>0 then
	    nag:=InducedPcgsWrtHomePcgs(n);
	    nag:=nag mod InducedPcgsByGenerators(nag,GeneratorsOfGroup(b));
#	    if Index(Parent(a),a.normalizer)>1 then
#	      Info(InfoPcSubgroup,2,"  normalizer index ",
#	                      Index(Parent(a),a.normalizer));
#	    fi;

	    z:=OneCocycles(a,nag);
	    if z.isSplitExtension and 
	      # normal complements exist, iff the coboundaries are trivial
	      (normal=false or Dimension(z.oneCoboundaries)=0)
	      then
	      # now fetch the complements
	      coboundbas:=Basis(z.oneCoboundaries);
	      com:=BaseSteinitzVectors(BasisVectors(Basis(z.oneCocycles)),
	                               BasisVectors(coboundbas));
	      field:=LeftActingDomain(z.oneCocycles);
	      if Size(field)^Length(com.factorspace)>10000 then
	        Error("too many (",Size(field)^Length(com.factorspace),
		      ") complements");
	      fi;
	      com:=Enumerator(VectorSpace(field,com.factorspace,
	                                       Zero(z.oneCocycles)));
	      Info(InfoPcSubgroup,2,"  ",Length(com),
	           " local complement classes");

	      # compute fusion
	      kconh:=List([1..Length(com)],i->[i]);
	      if i<len or retnorm then
		# we need to compute normalizers
		comnorms:=[];
	      else
		comnorms:=fail;
	      fi;

	      if Length(com)>1 and Size(a)<Size(bsnorms[bpos]) then

	        opr:=function(cyc,elm)
		  return SiftedVector(coboundbas,
		  z.complementToCocycle(z.cocycleToComplement(cyc)^elm));
		end;
		xo:=ExternalOrbitsStabilizers(
		     ExternalSet(bsnorms[bpos],com,opr));
                for k in xo do
		  l:=List(k,i->Position(com,i));
		  if comnorms<>fail then
		    comnorms[l[1]]:=StabilizerOfExternalSet(k);
		  fi;
		  l:=Set(l);
		  for kp in l do
		    kconh[kp]:=l;
		  od;
		od;

	      elif comnorms<>fail then
		comnorms:=List(com,i->z.cocycleToComplement(i));
		if Size(a)=Size(bsnorms[bpos]) then
		  comnorms:=List(comnorms,
			      i->ClosureGroup(CentralizerModulo(n,b,i),i));
	        else
		  comnorms:=List(comnorms,i->Normalizer(bsnorms[bpos],i));
		fi;
	      fi;


              if Length(efunc)>0 then
		ncom:=[];

	        #search for invariant ones

		# force exponents corresponding to vector space

                # get matrices for the inner automorphisms
#		conj:=[];
#		for k in GeneratorsOfGroup(a) do
#		  mat:=[];
#		  for l in nag do
#		    Add(mat,One(field)*ExponentsOfPcElement(nag,l^k));
#		  od;
#		  Add(conj,mat);
#		od;
                conj:=LinearOperationLayer(a,GeneratorsOfGroup(a),nag);

                idmat:=conj[1]^0;
		mat:=Group(conj,idmat);
		chom:=GroupHomomorphismByImages(a,mat,
		        GeneratorsOfGroup(a),conj);

		smats:=[];
		shoms:=[];

                fghom:=Concatenation(z.factorGens,GeneratorsOfGroup(n));
		bgids:=List(GeneratorsOfGroup(n),i->One(b));

		# now run through the complements
		for kp in [1..Length(com)] do

		  if kconh[kp]=fail then
		    Info(InfoPcSubgroup,3,"already conjugate");
		  else

		    k:=z.cocycleToComplement(com[kp]);
		    # the projection on the complement
		    comproj:=GroupHomomorphismByImages(a,a,fghom,
			       Concatenation(GeneratorsOfGroup(k),bgids));
		    k:=ClosureGroup(b,k);
		    
		    # now run through the conjugating elements
		    conjnr:=1;
		    found:=false;
		    while conjnr<=Length(s) and found=false do
		      if not IsBound(smats[conjnr]) then
			# compute the matrix action for the induced, jugated
			# morphisms
			m:=s[conjnr];
			smats[conjnr]:=[];
			shoms[conjnr]:=[];
			for l in efunc do
			  # the induced, jugated morphism
			  shom:=GroupHomomorphismByImages(a,a,
				  GeneratorsOfGroup(a),
				  List(GeneratorsOfGroup(a),
				   i->Image(l,i^m)^Inverse(m)));

			  mat:=List(nag,
				i->One(field)*ExponentsOfPcElement(nag,
				 Image(shom,i)));
			  Add(smats[conjnr],mat);
			  Add(shoms[conjnr],shom);
			od;
		      fi;

		      mats:=smats[conjnr];
		      # now test whether the complement k can be conjugated to
		      # be invariant under the morphisms to mats
		      glsyl:=List(nag,i->[]);
		      glsyr:=[];
		      for l in [1..Length(efunc)] do
			kgens:=GeneratorsOfGroup(k);
			for kgnr in [1..Length(kgens)] do

			  kgn:=Image(shoms[conjnr][l],kgens[kgnr]);
			  kgim:=Image(comproj,kgn);
			  Assert(2,kgim^-1*kgn in n);
			  # nt part
			  kgn:=kgim^-1*kgn;

			  # translate into matrix terms
			  kgim:=Image(chom,kgim);
			  kgn:=One(field)*ExponentsOfPcElement(nag,kgn);

			  # the matrix action
			  mat:=idmat+(mats[l]-idmat)*kgim-mats[l];
			  
			  # store action and vector
			  for m in [1..Length(glsyl)] do
			    glsyl[m]:=Concatenation(glsyl[m],mat[m]);
			  od;
			  glsyr:=Concatenation(glsyr,kgn);

			od;
		      od;

		      # a possible conjugating element is a solution of the
		      # large LGS
		      l:= SolutionMat(glsyl,glsyr);
		      if l <> fail then
			m:=Product([1..Length(l)],
				   i->nag[i]^IntFFE(l[i]));
			# note that we found one!
			found:=[s[conjnr],m];
		      fi;

		      conjnr:=conjnr+1;
		    od;

		    # there is an invariant complement?
		    if found<>false then
		      found:=found[2]*found[1];
		      l:=ConjugateSubgroup(ClosureGroup(b,k),found);
		      Assert(1,ForAll(efunc,i->Image(i,l)=l));
		      l:=rec(representative:=l);
		      if comnorms<>fail then
			if not IsBound(comnorms[kp]) then
			  l.normalizer:=ConjugateSubgroup(comnorms[kp],found);
			else
			  l.normalizer:=ConjugateSubgroup(
			                  Normalizer(bsnorms[bpos],
					    ClosureGroup(b,k)),found);
			fi;
		      fi;
		      Add(ncom,l);

		      # tag all conjugates
		      for l in kconh[kp] do
		        kconh[l]:=fail;
		      od;

		    fi;

                  fi; # if not already a conjugate

		od;

		# if invariance test needed
	      else
		# get representatives of the fused complement classes
		l:=Filtered([1..Length(com)],i->kconh[i][1]=i);

		ncom:=[];
		for kp in l do
		  m:=rec(representative:=
		           ClosureGroup(b,z.cocycleToComplement(com[kp])));
		  if comnorms<>fail then
		    m.normalizer:=comnorms[kp];
		  fi;
		  Add(ncom,m);
		od;
	      fi; 
	      com:=ncom;

	      # take the preimages
	      for k in com do

		Assert(1,ForAll(efunc,i->Image(i,k.representative)
		                         =k.representative));
		Add(ngrps,k.representative);
		if IsBound(k.normalizer) then
		  Add(ngrpsnorms,k.normalizer);
		fi;
	      od;
	    fi;
	  fi;
	od;

      fi;
    od;

    grps:=ngrps;
    grpsnorms:=ngrpsnorms;
    Info(InfoPcSubgroup,5,List(grps,Size),List(grpsnorms,Size));
  od;

  if isom<>fail then
    grps:=List(grps,j->PreImage(isom,j));
    if retnorm then
      grpsnorms:=List(grpsnorms,j->PreImage(isom,j));
    fi;
  fi;
  
  if retnorm then
    return [grps,grpsnorms];
  else
    return grps;
  fi;
end;


#############################################################################
##
#M  LatticeSubgroups(<G>)  . . . . . . . . . .  lattice of subgroups
##
InstallMethod(LatticeSubgroups,"elementary abelian extension",true,
  [IsSolvableGroup],0,
function(G)
local s,i,c,classes, lattice;
  s:=InvariantSubgroupsPcGroup(G,rec(retnorm:=true));
  classes:=[];
  for i in [1..Length(s[1])] do
    c:=ConjugacyClassSubgroups(G,s[1][i]);
    SetStabilizerOfExternalSet(c,s[2][i]);
    Add(classes,c);
  od;

  # create the lattice
  lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
		     rec());
  lattice!.conjugacyClassesSubgroups:=classes;
  lattice!.group     :=G;

  # return the lattice
  return lattice;

end);

#############################################################################
##
#M  NormalSubgroups(<G>)  . . . . . . . . . .  list of normal subgroups
##
InstallMethod(NormalSubgroups,"elementary abelian extension",true,
  [IsSolvableGroup],0,
function(G)
local n;
  n:=InvariantSubgroupsPcGroup(G,rec(
       actions:=List(GeneratorsOfGroup(G),i->InnerAutomorphism(G,i)),
       normal:=true));

  # sort the normal subgroups according to their size
  Sort(n,function(a,b) return Size(a) < Size(b); end);

  return n;
end);

#############################################################################
##
#F  SizeConsiderFunction(<size>)  returns auxiliary function for
##  'InvariantSubgroupsPcGroup' that allows to discard all subgroups whose
##  size is not divisible by <size>
##
SizeConsiderFunction:=function(size)
  return function(a,n,b,m)
	   return IsInt(Size(a)/Size(n)*Size(b)*Size(m)/size);
         end;
end;

#############################################################################
##
#F  ExactSizeConsiderFunction(<size>)  returns auxiliary function for
##  'InvariantSubgroupsPcGroup' that allows to discard all subgroups whose
##  size is not <size>
##
ExactSizeConsiderFunction:=function(size)
  return function(a,n,b,m)
	   return IsInt(Size(a)/Size(n)*Size(b)*Size(m)/size)
	      and not (Size(a)/Size(n)*Size(b))>size;
         end;
end;

#############################################################################
##
#E  grppclat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
