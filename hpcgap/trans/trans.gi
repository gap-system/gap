#############################################################################
##
#W  trans.gi          GAP transitive groups library          Alexander Hulpke
##
##
#Y  Copyright (C) 2001, Alexander Hulpke, Colorado State University
##
##  This file contains methods that rely on the transitive groups library
##  being available.
##

# computes the perfect subgroups of S_n or A_n. Symconj indicates whether
# they are up to conjugacy in S_n.
BindGlobal("PerfectSubgroupsAlternatingGroup",function(g,symconj)
local dom,deg,S,p,ps,perm,startp,sdps,nsdps,i,j,k,l,m,n,part,
      sysdps,syj,nk,kno,nl,lno,khom,kim,lhom,lim,iso,au,ind1,ind2,dc,d,grp,
      knom,lnon;
  dom:=Set(MovedPoints(g));
  deg:=Length(dom);
  p:=[TrivialSubgroup(g)];
  if deg<5 then 
    return p;
  fi;
 atomic readonly TRANSREGION do
  if deg>TRANSDEGREES then
    TryNextMethod();
  fi;
 od;
  
  S:=SymmetricGroup(deg);

  # all partitions with (nontrivial) orbits of length 
  part:=Filtered(Partitions(deg),i->Length(i)<deg and
                                 ForAll(i,j->j=1 or j>4));

  # we shall use implicitly, that the partitions are ordered reversly. I.e.
  # all sdps constructed don't have any earlier fixpoints &c.
  for i in part do
    Info(InfoLattice,1,"Partition: ",i);
    # for each partition construct all subdirect products.
    sdps:=[];
    startp:=1; # point we start on
    for j in i do
      if j>4 then
	Info(InfoLattice,3,j,", ",Length(sdps)," products");
	perm:=MappingPermListList([1..j],[startp..startp+j-1]);
	# get the transitive ones of this degree.
	ps:=AllTransitiveGroups(NrMovedPoints,j,IsPerfectGroup,true);
	ps:=List(ps,i->i^perm);
	if Length(sdps)=0 then
	  sdps:=ps;
	else
	  nsdps:=[];
	  # now we must form spds: run through all pairs
	  sysdps:=SymmetricGroup(MovedPoints(sdps[1]));
	  syj:=SymmetricGroup(j);

	  for k in sdps do
	    nk:=NormalSubgroups(k);
	    kno:=Normalizer(sysdps,k);
	    for l in ps do
	      nl:=NormalSubgroups(l);
	      lno:=Normalizer(syj,k);
	      # run through all combinations of normal subgroups
	      for m in nk do
		knom:=Normalizer(kno,m);
	        for n in nl do
		  lnon:=Normalizer(lno,n);
		  if Index(k,m)=Index(l,n) then
		    # factor groups have the same order.
		    khom:=NaturalHomomorphismByNormalSubgroupNC(k,m);
		    kim:=Image(khom);
		    lhom:=NaturalHomomorphismByNormalSubgroupNC(l,n);
		    lim:=Image(lhom);
		    iso:=IsomorphismGroups(kim,lim);
		    if iso<>fail then
		      # they are isomorphic. So there are subdirect
		      # products. Classify them up to conjugacy (Satz (32)
		      # in my thesis)
		      au:=AutomorphismGroup(lim);

		      # those automorphisms induced by the normalizer of k
		      ind1:=List(GeneratorsOfGroup(knom),
      y->GroupHomomorphismByImagesNC(lim,lim,
	    GeneratorsOfGroup(lim),
	    List(GeneratorsOfGroup(lim),
	         z->Image(iso,
		   Image(khom,PreImagesRepresentative(khom,
		                PreImagesRepresentative(iso,z) )^y)
		         ))));
                      Assert(1,ForAll(ind1,IsBijective));

		      # those automorphisms induced by the normalizer of l
		      ind2:=List(GeneratorsOfGroup(lnon),
      y->GroupHomomorphismByImagesNC(lim,lim,
	    GeneratorsOfGroup(lim),
	    List(GeneratorsOfGroup(lim),
	         z->Image(lhom,PreImagesRepresentative(lhom,z)^y))));
                      Assert(1,ForAll(ind1,IsBijective));

		      dc:=DoubleCosetRepsAndSizes(au,SubgroupNC(au,ind1),
		                          SubgroupNC(au,ind2));
		      dc:=List(dc,i->i[1]); # only reps
		      for d in dc do
		        grp:=ClosureGroup(n,
			       List(GeneratorsOfGroup(k),i->i*
			         PreImagesRepresentative(lhom,
				   Image(d,Image(iso,Image(khom,i)))
				                              ))
			                 );
		        Add(nsdps,grp);
		      od;

		    fi;
		  fi;
		od;
	      od;
	    od;
	  od;

	  sdps:=nsdps;
	fi;
      fi;
      startp:=startp+j;
    od;

    # S_n classes
    nsdps:=[];
    for j in sdps do
      if ForAll(nsdps,k->Size(k)<>Size(j) 
                      or Set(MovedPoints(k))<>Set(MovedPoints(l))
		      or RepresentativeAction(
			   # if they are conjugate in S_deg they are conjugate
			   # in the smaller S_n on their moved points
		           Stabilizer(S,Difference([1..deg],
			                           MovedPoints(k)),OnTuples),
			  j,k)=fail) then
        Add(nsdps,j);
      fi;
    od;

    Info(InfoLattice,2,j,", ",Length(sdps)," new perfect groups");
    if symconj then
      Append(p,nsdps);
    else
      for j in nsdps do
	n:=Normalizer(S,j);
	Add(p,j);
	if SignPermGroup(n)=1 then
	  Add(p,ConjugateGroup(j,(1,2))); # Normalizer in A_n: 2 orbits
	fi;
      od;
    fi;
  od;

  if dom<>[1..deg] then
    perm:=MappingPermListList([1..deg],dom);
    p:=List(p,i->i^perm);
  fi;

  return p;

end);

#############################################################################
##
#M  RepresentativesPerfectSubgroups
##
InstallMethod(RepresentativesPerfectSubgroups,"alternating",true,
    [ IsNaturalAlternatingGroup ], 0,
  G->PerfectSubgroupsAlternatingGroup(G,false));

InstallMethod(RepresentativesPerfectSubgroups,"symmetric",true,
    [ IsNaturalSymmetricGroup ], 0,
  G->PerfectSubgroupsAlternatingGroup(G,true));
