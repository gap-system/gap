#############################################################################
##
#W  grplatt.gi                GAP library                   Martin Sch"onert,
#W                                                          Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This  file  contains declarations for subgroup latices
##
Revision.grplatt_gi:=
  "@(#)$Id$";

#############################################################################
##
#F  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
InstallMethod(Zuppos,"group",true,[IsGroup],0,
function (G)
local   zuppos,            # set of zuppos,result
	c,                 # a representative of a class of elements
	o,                 # its order
	N,                 # normalizer of < c >
	t;                 # loop variable

  # compute the zuppos
  zuppos:=[One(G)];
  for c in List(ConjugacyClasses(G),Representative)  do
    o:=Order(c);
    if IsPrimePowerInt(o)  then
      if ForAll([2..o],i -> Gcd(o,i) <> 1 or not c^i in zuppos) then
	N:=Normalizer(G,Subgroup(G,[c]));
	for t in RightTransversal(G,N)  do
	  Add(zuppos,c^t);
	od;
      fi;
    fi;
  od;

  # return the set of zuppos
  Sort(zuppos);
  return zuppos;
end);


#############################################################################
##
#M  ConjugacyClassSubgroups(<G>,<g>)  . . . . . . . . . . . .  constructor
##
InstallMethod(ConjugacyClassSubgroups,IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,U)
local filter,cl;

    if CanComputeSizeAnySubgroup(G) then
      filter:=IsConjugacyClassSubgroupsByStabilizerRep;
    else
      filter:=IsConjugacyClassSubgroupsRep;
    fi;
    cl:=Objectify(NewType(CollectionsFamily(FamilyObj(G)),
      filter),rec());
    SetActingDomain(cl,G);
    SetRepresentative(cl,U);
    SetFunctionAction(cl,OnPoints);
    return cl;
end);

#############################################################################
##
#M  <clasa> = <clasb> . . . . . . . . . . . . . . . . . . by conjugacy test
##
InstallMethod( \=, IsIdenticalObj, [ IsConjugacyClassSubgroupsRep,
  IsConjugacyClassSubgroupsRep ], 0,
function( clasa, clasb )
  if not IsIdenticalObj(ActingDomain(clasa),ActingDomain(clasb))
    then TryNextMethod();
  fi;
  return RepresentativeAction(ActingDomain(clasa),Representative(clasa),
		 Representative(clasb))<>fail;
end);


#############################################################################
##
#M  <G> in <clas> . . . . . . . . . . . . . . . . . . by conjugacy test
##
InstallMethod( \in, IsElmsColls, [ IsGroup,IsConjugacyClassSubgroupsRep], 0,
function( G, clas )
  return RepresentativeAction(ActingDomain(clas),Representative(clas),G)
		 <>fail;
end);

#############################################################################
##
#M  AsList(<cls>)
##
InstallOtherMethod(AsList, "for classes of subgroups",
  true, [ IsConjugacyClassSubgroupsRep],0,
function(c)
local rep;
  rep:=Representative(c);
  if not IsBound(c!.normalizerTransversal) then
    c!.normalizerTransversal:=
      RightTransversal(ActingDomain(c),StabilizerOfExternalSet(c));
  fi;
  if HasParent(rep) and IsSubset(Parent(rep),ActingDomain(c)) then
    return List(c!.normalizerTransversal,i->ConjugateSubgroup(rep,i));
  else
    return List(c!.normalizerTransversal,i->ConjugateGroup(rep,i));
  fi;
end);

InstallOtherMethod( \[\], "for classes of subgroups",
  true, [ IsConjugacyClassSubgroupsRep, IsPosInt],0,
function(c,nr)
local rep;
  rep:=Representative(c);
  if not IsBound(c!.normalizerTransversal) then
    c!.normalizerTransversal:=
      RightTransversal(ActingDomain(c),StabilizerOfExternalSet(c));
  fi;
  return ConjugateSubgroup(rep,c!.normalizerTransversal[nr]);
end);

InstallMethod( StabilizerOfExternalSet, true, [ IsConjugacyClassSubgroupsRep ], 
    # override eventual pc method
    10,
function(xset)
  return Normalizer(ActingDomain(xset),Representative(xset));
end);

InstallOtherMethod( NormalizerOp, true, [ IsConjugacyClassSubgroupsRep ], 0,
    StabilizerOfExternalSet );


#############################################################################
##
#M  PrintObj(<cl>)  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod(PrintObj,true,[IsConjugacyClassSubgroupsRep],0,
function(cl)
    Print("ConjugacyClassSubgroups(",ActingDomain(cl),",",
           Representative(cl),")");
end);


#############################################################################
##
#M  ConjugacyClassesSubgroups(<G>) . classes of subgroups of a group
##
InstallMethod(ConjugacyClassesSubgroups,"group",true,[IsGroup],0,
function(G)
  return ConjugacyClassesSubgroups(LatticeSubgroups(G));
end);

InstallOtherMethod(ConjugacyClassesSubgroups,"lattice",true,
  [IsLatticeSubgroupsRep],0,
function(L)
  return L!.conjugacyClassesSubgroups;
end);

#############################################################################
##
#F  LatticeByCyclicExtension(<G>[,<func>[,<noperf>]])  Lattice of subgroups
##
##  computes the lattice of <G> using the cyclic extension algorithm. If the
##  function <func> is given, the algorithm will discard all subgroups not
##  fulfilling <func> (and will also not extend them), returning a partial
##  lattice. This can be useful to compute only subgroups with certain
##  properties. Note however that this will *not* necessarily yield all
##  subgroups that fulfill <func>, but the subgroups whose subgroups used
##  for the construction also fulfill <func> as well.
##

# the following functions are declared only later
SOLVABILITY_IMPLYING_FUNCTIONS:=
  [IsSolvableGroup,IsNilpotentGroup,IsPGroup,IsCyclic];

InstallGlobalFunction( LatticeByCyclicExtension, function(arg)
local   G,		   # group
	func,		   # test function
	noperf,		   # discard perfect groups
        lattice,           # lattice (result)
	factors,           # factorization of <G>'s size
	zuppos,            # generators of prime power order
	zupposPrime,       # corresponding prime
	zupposPower,       # index of power of generator
	nrClasses,         # number of classes
	classes,           # list of all classes
	classesZups,       # zuppos blist of classes
	classesExts,       # extend-by blist of classes
	perfect,           # classes of perfect subgroups of <G>
	perfectNew,        # this class of perfect subgroups is new
	perfectZups,       # zuppos blist of perfect subgroups
	layerb,            # begin of previous layer
	layere,            # end of previous layer
	H,                 # representative of a class
	Hzups,             # zuppos blist of <H>
	Hexts,             # extend blist of <H>
	C,                 # class of <I>
	I,                 # new subgroup found
	Ielms,             # elements of <I>
	Izups,             # zuppos blist of <I>
	N,                 # normalizer of <I>
	Nzups,             # zuppos blist of <N>
	Jzups,             # zuppos of a conjugate of <I>
	Kzups,             # zuppos of a representative in <classes>
	reps,              # transversal of <N> in <G>
	h,i,k,l,r;      # loop variables

    G:=arg[1];
    noperf:=false;
    if Length(arg)>1 and IsFunction(arg[2]) then
      func:=arg[2];
      Info(InfoLattice,1,"lattice discarding function active!");
      if Length(arg)>2 and IsBool(arg[3]) then
	noperf:=arg[3];
      fi;
    else
      func:=false;
    fi;

    # compute the factorized size of <G>
    factors:=Factors(Size(G));

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(G);
    Info(InfoLattice,1,"<G> has ",Length(zuppos)," zuppos");

    # compute the prime corresponding to each zuppo and the index of power
    zupposPrime:=[];
    zupposPower:=[];
    for r  in zuppos  do
        i:=SmallestRootInt(Order(r));
        Add(zupposPrime,i);
        k:=0;
        while k <> false  do
            k:=k + 1;
            if GcdInt(i,k) = 1  then
                l:=Position(zuppos,r^(i*k));
                if l <> fail  then
                    Add(zupposPower,l);
                    k:=false;
                fi;
            fi;
        od;
    od;
    Info(InfoLattice,1,"powers computed");

    if func<>false and 
      (noperf or func in SOLVABILITY_IMPLYING_FUNCTIONS) then
      Info(InfoLattice,1,"Ignoring perfect subgroups");
      perfect:=[];
    else
      if IsPermGroup(G) then
	# trigger potentially better methods
	IsNaturalSymmetricGroup(G);
	IsNaturalAlternatingGroup(G);
      fi;
      perfect:=RepresentativesPerfectSubgroups(G);
      perfect:=Filtered(perfect,i->Size(i)>1 and Size(i)<Size(G));
      if func<>false then
	perfect:=Filtered(perfect,func);
      fi;
    fi;

    perfectZups:=[];
    perfectNew :=[];
    for i  in [1..Length(perfect)]  do
        I:=perfect[i];
        perfectZups[i]:=BlistList(zuppos,AttributeValueNotSet(AsList,I));
        perfectNew[i]:=true;
    od;
    Info(InfoLattice,1,"<G> has ",Length(perfect),
                  " representatives of perfect subgroups");

    # initialize the classes list
    nrClasses:=1;
    classes:=ConjugacyClassSubgroups(G,TrivialSubgroup(G));
    SetSize(classes,1);
    classes:=[classes];
    classesZups:=[BlistList(zuppos,[One(G)])];
    classesExts:=[DifferenceBlist(BlistList(zuppos,zuppos),classesZups[1])];
    layerb:=1;
    layere:=1;

    # loop over the layers of group (except the group itself)
    for l  in [1..Length(factors)-1]  do
        Info(InfoLattice,1,"doing layer ",l,",",
                      "previous layer has ",layere-layerb+1," classes");

        # extend representatives of the classes of the previous layer
        for h  in [layerb..layere]  do

            # get the representative,its zuppos blist and extend-by blist
            H:=Representative(classes[h]);
            Hzups:=classesZups[h];
            Hexts:=classesExts[h];
            Info(InfoLattice,2,"extending subgroup ",h,", size = ",Size(H));

            # loop over the zuppos whose <p>-th power lies in <H>
            for i  in [1..Length(zuppos)]  do
                if Hexts[i] and Hzups[zupposPower[i]]  then

		  # make the new subgroup <I>
		  I:=Subgroup(Parent(G),Concatenation(GeneratorsOfGroup(H),
							   [zuppos[i]]));
                  if func=false or func(I) then

                    SetSize(I,Size(H) * zupposPrime[i]);

                    # compute the zuppos blist of <I>
                    Ielms:=AttributeValueNotSet(AsList,I);
                    Izups:=BlistList(zuppos,Ielms);

                    # compute the normalizer of <I>
                    N:=Normalizer(G,I);
		    #AH 'NormalizerInParent' attribute ?
                    #if IsParent(G)  and not IsBound(I.normalizer)  then
                    #    I.normalizer:=Subgroup(Parent(G),GeneratorsOfGroup(N));
                    #    I.normalizer.size:=Size(N);
                    #fi;
                    Info(InfoLattice,2,"found new class ",nrClasses+1,
		         ", size = ",Size(I),
                         " length = ",Size(G) / Size(N));

                    # make the new conjugacy class
                    C:=ConjugacyClassSubgroups(G,I);
                    SetSize(C,Size(G) / Size(N));
                    SetStabilizerOfExternalSet(C,
		      Subgroup(Parent(G),GeneratorsOfGroup(N)));
                    nrClasses:=nrClasses + 1;
                    classes[nrClasses]:=C;

                    # store the extend by list
                    if l < Length(factors)-1  then
                        classesZups[nrClasses]:=Izups;
                        Nzups:=BlistList(zuppos,
			                 AttributeValueNotSet(AsList,N));
                        SubtractBlist(Nzups,Izups);
                        classesExts[nrClasses]:=Nzups;
                    fi;

		    # compute the right transversal
		    # (but don't store it in the parent)
		    reps:=RightTransversalOp(G,N);

                    # loop over the conjugates of <I>
                    for r  in reps  do

                        # compute the zuppos blist of the conjugate
                        if r = One(G)  then
                            Jzups:=Izups;
                        else
                            Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
                        fi;

                        # loop over the already found classes
                        for k  in [h..layere]  do
                            Kzups:=classesZups[k];

                            # test if the <K> is a subgroup of <J>
                            if IsSubsetBlist(Jzups,Kzups)  then

                                # don't extend <K> by the elements of <J>
                                SubtractBlist(classesExts[k],Jzups);

                            fi;

                        od;

                    od;

                    # now we are done with the new class
                    Unbind(Ielms);
                    Unbind(reps);
                    Info(InfoLattice,2,"tested inclusions");

		  else
		    Info(InfoLattice,1,"discarded!");
		  fi; # if condition fulfilled

                fi; # if Hexts[i] and Hzups[zupposPower[i]]  then ...
            od; # for i  in [1..Length(zuppos)]  do ...

            # remove the stuff we don't need any more
            Unbind(classesZups[h]);
            Unbind(classesExts[h]);

        od; # for h  in [layerb..layere]  do ...

        # add the classes of perfect subgroups
        for i  in [1..Length(perfect)]  do
            if    perfectNew[i]
              and IsPerfectGroup(perfect[i])
              and Length(Factors(Size(perfect[i]))) = l
            then

                # make the new subgroup <I>
                I:=perfect[i];

                # compute the zuppos blist of <I>
                Ielms:=AttributeValueNotSet(AsList,I);
                Izups:=BlistList(zuppos,Ielms);

                # compute the normalizer of <I>
                N:=Normalizer(G,I);
		# AH: NormalizerInParent ?
                #if IsParent(G)  and not IsBound(I.normalizer)  then
                #    I.normalizer:=Subgroup(Parent(G),N.generators);
                #    I.normalizer.size:=Size(N);
                #fi;
                Info(InfoLattice,2,"found perfect class ",nrClasses+1,
                     " size = ",Size(I),", length = ",
		     Size(G) / Size(N));

                # make the new conjugacy class
                C:=ConjugacyClassSubgroups(G,I);
                SetSize(C,Size(G)/Size(N));
                SetStabilizerOfExternalSet(C,
		  Subgroup(Parent(G),GeneratorsOfGroup(N)));
                nrClasses:=nrClasses + 1;
                classes[nrClasses]:=C;

                # store the extend by list
                if l < Length(factors)-1  then
                    classesZups[nrClasses]:=Izups;
                    Nzups:=BlistList(zuppos,AttributeValueNotSet(AsList,N));
                    SubtractBlist(Nzups,Izups);
                    classesExts[nrClasses]:=Nzups;
                fi;

		# compute the right transversal
		# (but don't store it in the parent)
		reps:=RightTransversalOp(G,N);

                # loop over the conjugates of <I>
                for r  in reps  do

                    # compute the zuppos blist of the conjugate
                    if r = One(G)  then
                        Jzups:=Izups;
                    else
                        Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
                    fi;

                    # loop over the perfect classes
                    for k  in [i+1..Length(perfect)]  do
                        Kzups:=perfectZups[k];

                        # throw away classes that appear twice in perfect
                        if Jzups = Kzups  then
                            perfectNew[k]:=false;
                            perfectZups[k]:=[];
                        fi;

                    od;

                od;

                # now we are done with the new class
                Unbind(Ielms);
                Unbind(reps);
                Info(InfoLattice,2,"tested equalities");

                # unbind the stuff we dont need any more
                perfectZups[i]:=[];

            fi; 
	    # if IsPerfectGroup(I) and Length(Factors(Size(I))) = layer the...
        od; # for i  in [1..Length(perfect)]  do

        # on to the next layer
        layerb:=layere+1;
        layere:=nrClasses;

    od; # for l  in [1..Length(factors)-1]  do ...

    # add the whole group to the list of classes
    Info(InfoLattice,1,"doing layer ",Length(factors),",",
                  " previous layer has ",layere-layerb+1," classes");
    if Size(G)>1 and (func=false or func(G)) then
      Info(InfoLattice,2,"found whole group, size = ",Size(G),",","length = 1");
      C:=ConjugacyClassSubgroups(G,G);
      SetSize(C,1);
      nrClasses:=nrClasses + 1;
      classes[nrClasses]:=C;
    fi;

    # return the list of classes
    Info(InfoLattice,1,"<G> has ",nrClasses," classes,",
                  " and ",Sum(classes,Size)," subgroups");

    # sort the classes
    Sort(classes,
                  function (c,d)
                     return Size(Representative(c)) < Size(Representative(d))
                        or (Size(Representative(c)) = Size(Representative(d))
                            and Size(c) < Size(d));
                   end);

    # create the lattice
    lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
                       rec());
    lattice!.conjugacyClassesSubgroups:=classes;
    lattice!.group     :=G;

    if func<>false then
      lattice!.func:=func;
    fi;

    # return the lattice
    return lattice;
end );

#############################################################################
##
#M  LatticeSubgroups(<G>)  . . . . . . . . . .  lattice of subgroups
##
InstallMethod(LatticeSubgroups,"cyclic extension",true,[IsGroup],0,
  LatticeByCyclicExtension);

#############################################################################
##
#M  Print for lattice
##
InstallMethod(ViewObj,"lattice",true,[IsLatticeSubgroupsRep],0,
function(l)
  Print("<subgroup lattice of ");
  ViewObj(l!.group);
  Print(", ", Length(l!.conjugacyClassesSubgroups)," classes, ",
    Sum(l!.conjugacyClassesSubgroups,Size)," subgroups");
  if IsBound(l!.func) then
    Print(", restricted under further condition l!.func");
  fi;
  Print(">");
end);

InstallMethod(PrintObj,"lattice",true,[IsLatticeSubgroupsRep],0,
function(l)
  Print("LatticeSubgroups(",l!.group);
  if IsBound(l!.func) then
    Print("),# under further condition l!.func\n");
  else
    Print(")");
  fi;
end);

#############################################################################
##
#M  ConjugacyClassesPerfectSubgroups 
##
InstallMethod(ConjugacyClassesPerfectSubgroups,"generic",true,[IsGroup],0,
function(G)
  return
    List(RepresentativesPerfectSubgroups(G),i->ConjugacyClassSubgroups(G,i));
end);

#############################################################################
##
#M  PerfectResiduum
##
InstallMethod(PerfectResiduum,"for groups",true,
  [IsGroup],0,
function(G)
  while not IsPerfectGroup(G) do
    G:=DerivedSubgroup(G);
  od;
  return G;
end);

#############################################################################
##
#M  RepresentativesPerfectSubgroups  solvable
##
InstallMethod(RepresentativesPerfectSubgroups,"solvable",true,
  [IsSolvableGroup],0,
function(G)
  return [TrivialSubgroup(G)];
end);

#############################################################################
##
#M  RepresentativesPerfectSubgroups
##
InstallMethod(RepresentativesPerfectSubgroups,"using Holt/Plesken library",
  true,[IsGroup],0,
function(G)
local badsizes,n,un,cl,r,i,l,u,bw,cnt,gens,go,imgs,bg,bi,emb,nu,k,j,
      D,params,might,bo;
  if IsSolvableGroup(G) then
    return [TrivialSubgroup(G)];
  else
    PerfGrpLoad(0);
    badsizes := Union(PERFRec.notAvailable,PERFRec.notKnown);
    D:=G;
    D:=PerfectResiduum(D);
    n:=Size(D);
    Info(InfoLattice,1,"The perfect residuum has size ",n);
    if n>=10^6 then
      Error("the perfect residuum is too large");
    fi;
    un:=Filtered(DivisorsInt(n),i->i in PERFRec.sizes and i>1
		 # index <=4 would lead to solvable factor
		 and i<n/4);
    if Length(Intersection(badsizes,un))>0 then
      Error(
        "failed due to incomplete information in the Holt/Plesken library");
    fi;
    cl:=Filtered(ConjugacyClasses(G),i->Representative(i) in D);
    Info(InfoLattice,2,Length(cl)," classes of ",
         Length(ConjugacyClasses(G))," to consider");

    r:=[];
    for i in un do

      l:=NumberPerfectGroups(i);
      if l>0 then
	for j in [1..l] do
	  u:=PerfectGroup(IsPermGroup,i,j);
	  Info(InfoLattice,1,"trying group ",i,",",j,": ",u);

	  # test whether there is a chance to embed
	  might:=true;
	  cnt:=0;
	  while might and cnt<20 do
	    bg:=Order(Random(u));
	    might:=ForAny(cl,i->Order(Representative(i))=bg);
	    cnt:=cnt+1;
	  od;

	  if might then
	    # find a suitable generating system
	    bw:=infinity;
	    bo:=[0,0];
	    cnt:=0;
	    repeat
	      if cnt=0 then
		# first the small gen syst.
		gens:=SmallGeneratingSet(u);
	      else
		# then something random
		repeat
		  if Length(gens)>2 and Random([1,2])=1 then
		    # try to get down to 2 gens
		    gens:=List([1,2],i->Random(u));
		  else
		    gens:=List(gens,i->Random(u));
		  fi;
                  # try to get small orders
		  for k in [1..Length(gens)] do
		    go:=Order(gens[k]);
		    # try a p-element
		    if Random([1..2*Length(gens)])=1 then
		      gens[k]:=gens[k]^(go/(Random(Factors(go))));
		    fi;
		  od;

	        until Index(u,SubgroupNC(u,gens))=1;
	      fi;
	      go:=List(gens,Order);
	      imgs:=List(go,i->Filtered(cl,j->Order(Representative(j))=i));
	      Info(InfoLattice,3,go,":",Product(imgs,i->Sum(i,Size)));
	      if Product(imgs,i->Sum(i,Size))<bw then
		bg:=gens;
		bo:=go;
		bi:=imgs;
		bw:=Product(imgs,i->Sum(i,Size));
	      elif Set(go)=Set(bo) then
		# we hit the orders again -> sign that we can't be
		# completely off track
	        cnt:=cnt+Int(bw/Size(G)*3);
	      fi;
	      cnt:=cnt+1;
	    until bw/Size(G)*6<cnt;

	    if bw>0 then
	      Info(InfoLattice,2,"find ",bw," from ",cnt);
	      # find all embeddings
	      params:=rec(gens:=bg,from:=u);
	      emb:=MorClassLoop(G,bi,params,
		# all injective homs = 1+2+8
	        11); 
	      #emb:=MorClassLoop(G,bi,rec(type:=2,what:=3,gens:=bg,from:=u,
	      #		elms:=false,size:=Size(u)));
	      Info(InfoLattice,2,Length(emb)," embeddings");
	      nu:=[];
	      for k in emb do
		k:=Image(k,u);
		if not ForAny(nu,i->RepresentativeAction(G,i,k)<>fail) then
		  Add(nu,k);
		  k!.perfectType:=[i,j];
		fi;
	      od;
	      Info(InfoLattice,1,Length(nu)," classes");
	      r:=Concatenation(r,nu);
	    fi;
	  else
	    Info(InfoLattice,2,"cannot embed");
	  fi;
	od;
      fi;
    od;
    # add the two obvious ones
    Add(r,D);
    Add(r,TrivialSubgroup(G));
    return r;
  fi;
end);

#############################################################################
##
#M  MaximalSubgroupsLattice
##
InstallMethod(MaximalSubgroupsLattice,"cyclic extension",true,
  [IsLatticeSubgroupsRep],0,
function (L)
    local   maximals,          # maximals as pair <class>,<conj> (result)
            maximalsZups,      # their zuppos blist
            cnt,               # count for information messages
            zuppos,            # generators of prime power order
            classes,           # list of all classes
            classesZups,       # zuppos blist of classes
            I,                 # representative of a class
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group
            i,k,r;         # loop variables

    grp:=L!.group;
    # compute the lattice,fetch the classes,zuppos,and representatives
    classes:=L!.conjugacyClassesSubgroups;
    classesZups:=[];

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(grp);

    # initialize the maximals list
    Info(InfoLattice,1,"computing maximal relationship");
    maximals:=List(classes,c -> []);
    maximalsZups:=List(classes,c -> []);

    # find the minimal supergroups of the whole group
    Info(InfoLattice,2,"testing class ",Length(classes),", size = ",
         Size(grp),", length = 1, included in 0 minimal subs");
    classesZups[Length(classes)]:=BlistList(zuppos,zuppos);

    # loop over all classes
    for i  in [Length(classes)-1,Length(classes)-2..1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);
        Info(InfoLattice,2," testing class ",i);

        # compute the zuppos blist of <I>
        Ielms:=AttributeValueNotSet(AsList,I);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=Normalizer(grp,I);

	# compute the right transversal
	# (but don't store it in the parent)
	reps:=RightTransversalOp(grp,N);

        # initialize the counter
        cnt:=0;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the zuppos blist of the conjugate
            if reps[r] = One(grp)  then
                Jzups:=Izups;
            else
                Jzups:=BlistList(zuppos,OnTuples(Ielms,reps[r]));
            fi;

            # loop over all other (larger classes)
            for k  in [i+1..Length(classes)]  do
                Kzups:=classesZups[k];

                # test if the <K> is a minimal supergroup of <J>
                if    IsSubsetBlist(Kzups,Jzups)
                  and ForAll(maximalsZups[k],
                              zups -> not IsSubsetBlist(zups,Jzups))
                then
                    Add(maximals[k],[ i,r ]);
                    Add(maximalsZups[k],Jzups);
                    cnt:=cnt + 1;
                fi;

            od;

        od;

        # inform about the count
        Unbind(Ielms);
        Unbind(reps);
        Info(InfoLattice,2,"size = ",Size(I),", length = ",
	  Size(grp) / Size(N),", included in ",cnt," minimal sups");

    od;

    return maximals;
end);

#############################################################################
##
#M  MinimalSupergroupsLattice
##
InstallMethod(MinimalSupergroupsLattice,"cyclic extension",true,
  [IsLatticeSubgroupsRep],0,
function (L)
    local   minimals,          # minimals as pair <class>,<conj> (result)
            minimalsZups,      # their zuppos blist
            cnt,               # count for information messages
            zuppos,            # generators of prime power order
            classes,           # list of all classes
            classesZups,       # zuppos blist of classes
            I,                 # representative of a class
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group
            i,k,r;         # loop variables

    grp:=L!.group;
    # compute the lattice,fetch the classes,zuppos,and representatives
    classes:=L!.conjugacyClassesSubgroups;
    classesZups:=[];

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(grp);

    # initialize the minimals list
    Info(InfoLattice,1,"computing minimal relationship");
    minimals:=List(classes,c -> []);
    minimalsZups:=List(classes,c -> []);

    # loop over all classes
    for i  in [1..Length(classes)-1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);

        # compute the zuppos blist of <I>
        Ielms:=AttributeValueNotSet(AsList,I);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=Normalizer(grp,I);

        # compute the right transversal (but don't store it in the parent)
        reps:=RightTransversalOp(grp,N);

        # initialize the counter
        cnt:=0;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the zuppos blist of the conjugate
            if reps[r] = One(grp)  then
                Jzups:=Izups;
            else
                Jzups:=BlistList(zuppos,OnTuples(Ielms,reps[r]));
            fi;

            # loop over all other (smaller classes)
            for k  in [1..i-1]  do
                Kzups:=classesZups[k];

                # test if the <K> is a maximal subgroup of <J>
                if    IsSubsetBlist(Jzups,Kzups)
                  and ForAll(minimalsZups[k],
                              zups -> not IsSubsetBlist(Jzups,zups))
                then
                    Add(minimals[k],[ i,r ]);
                    Add(minimalsZups[k],Jzups);
                    cnt:=cnt + 1;
                fi;

            od;

        od;

        # inform about the count
        Unbind(Ielms);
        Unbind(reps);
        Info(InfoLattice,2,"testing class ",i,", size = ",Size(I),
	     ", length = ",Size(grp) / Size(N),", includes ",cnt,
	     " maximal subs");

    od;

    # find the maximal subgroups of the whole group
    cnt:=0;
    for k  in [1..Length(classes)-1]  do
        if minimals[k] = []  then
            Add(minimals[k],[ Length(classes),1 ]);
            cnt:=cnt + 1;
        fi;
    od;
    Info(InfoLattice,2,"testing class ",Length(classes),", size = ",
        Size(grp),", length = 1, includes ",cnt," maximal subs");

    return minimals;
end);

#############################################################################
##
#F  MaximalSubgroupClassReps(<G>) . . . . reps of conjugacy classes of
#F                                                          maximal subgroups
##
InstallMethod(MaximalSubgroupClassReps,"using lattice",true,[IsGroup],0,
function (G)
    local   maxs,lat;

    #AH special AG treatment
    if not HasIsSolvableGroup(G) and IsSolvableGroup(G) then
      return MaximalSubgroupClassReps(G);
    fi;
    # simply compute all conjugacy classes and take the maximals
    lat:=LatticeSubgroups(G);
    maxs:=MaximalSubgroupsLattice(lat)[Length(lat!.conjugacyClassesSubgroups)];
    maxs:=List(lat!.conjugacyClassesSubgroups{
       Set(maxs{[1..Length(maxs)]}[1])},Representative);
    return maxs;
end);

#############################################################################
##
#F  ConjugacyClassesMaximalSubgroups(<G>)
##
InstallMethod(ConjugacyClassesMaximalSubgroups,
 "use MaximalSubgroupClassReps",true,[IsGroup],0,
function(G)
  return List(MaximalSubgroupClassReps(G),i->ConjugacyClassSubgroups(G,i));
end);

#############################################################################
##
#F  MaximalSubgroups(<G>)
##
InstallMethod(MaximalSubgroups,
 "expand list",true,[IsGroup],0,
function(G)
  return Concatenation(List(ConjugacyClassesMaximalSubgroups(G),AsList));
end);

#############################################################################
##
#F  NormalSubgroupsCalc(<G>) compute normal subgroups for pc or perm groups
##
NormalSubgroupsCalc := function (G)
local nt,nnt,	# normal subgroups
      cs,	# comp. series
      M,N,	# nt . in series
      mpcgs,	# modulo pcgs
      p,	# prime
      ocr,	# 1-cohomology record
      l,	# list
      vs,	# vector space
      hom,	# homomorphism
      jg,	# generator images
      auts,	# factor automorphisms
      T,S,C,A,ji,orb,orbi,cllen,r,o,c,inv,cnt,
      i,j,k;	# loop

  nt:=[G];
  cs:=ChiefSeries(G);

  for i in [2..Length(cs)] do
    # we assume that nt contains all normal subgroups above cs[i-1]
    # we want to lift to G/cs[i]
    M:=cs[i-1];
    N:=cs[i];

    # the normal subgroups already known
    nnt:=ShallowCopy(nt);

    Info(InfoLattice,1,i,":",Index(M,N));
    if HasAbelianFactorGroup(M,N) then
      # the modulo pcgs
      mpcgs:=ModuloPcgs(M,N);

      p:=RelativeOrderOfPcElement(mpcgs,mpcgs[1]);

      for j in Filtered(nt,i->Size(i)>Size(M)) do
	# test centrality
	if ForAll(GeneratorsOfGroup(j),
	          i->ForAll(mpcgs,j->Comm(i,j) in N)) then

	  Info(InfoLattice,2,"factorsize=",Index(j,N),"/",Index(M,N));

	  if HasAbelianFactorGroup(j,N) and
	    p^(Length(mpcgs)*LogInt(Index(j,M),p))>100 then
	    l:=fail;  # we will compute the subgroups later
	  else

	    ocr:=rec(
		   group:=j,
		   modulePcgs:=mpcgs
		 );

	    # we want only normal complements. Therefore the 1-Coboundaries must
	    # be trivial. We compute these first.
	    if Dimension(OCOneCoboundaries(ocr))=0 then
	      l:=[];
	      OCOneCocycles(ocr,true);
	      if IsBound(ocr.complement) then
		l:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
		      BasisVectors(Basis(ocr.oneCoboundaries)));
		vs:=VectorSpace(LeftActingDomain(ocr.oneCocycles),
			 l.factorspace,Zero(ocr.oneCocycles));
		Info(InfoLattice,2,p^Length(l.factorspace)," cocycles");

		# try to catch some solvable cases that look awful
		if Size(vs)>1000 and Length(Set(Factors(Index(j,N))))<=2
		  then
		  l:=fail;
		else
		  l:=[];
		  for k in vs do
		    k:=ClosureGroup(N,ocr.cocycleToComplement(k));
		    if IsNormal(G,k) then
		      Add(l,k);
		    fi;
		  od;

		  Info(InfoLattice,2," -> ",Length(l)," normal complements");
		  nnt:=Concatenation(nnt,l);
	        fi;
	      fi;
	    fi;
          fi;

          if l=fail then
	    Info(InfoLattice,1,"using invariant subgroups");
	    # the factor is abelian, we therefore find this homomorphism
	    # quick.
	    hom:=NaturalHomomorphismByNormalSubgroup(j,N);
	    r:=Image(hom,j);
	    jg:=List(GeneratorsOfGroup(j),i->Image(hom,i));
	    # construct the automorphisms
	    auts:=List(GeneratorsOfGroup(G),
	      i->GroupHomomorphismByImagesNC(r,r,jg,
	        List(GeneratorsOfGroup(j),k->Image(hom,k^i))));
	    l:=SubgroupsSolvableGroup(r,rec(
	         actions:=auts,
		 funcnorm:=r,
	         consider:=ExactSizeConsiderFunction(Index(j,M)),
		 normal:=true));
	    Info(InfoLattice,2,"found ",Length(l)," invariant subgroups");
	    C:=Image(hom,M);
	    l:=Filtered(l,i->Size(i)=Index(j,M) and Size(Intersection(i,C))=1);
	    l:=List(l,i->PreImage(hom,i));
	    l:=Filtered(l,i->IsNormal(G,i));
	    Info(InfoLattice,1,Length(l)," of these normal");
	    nnt:=Concatenation(nnt,l);
          fi;

        fi;

      od;
      
    else
      # nonabelian factor.

      # 1) compute the action for the factor

      # first, we obtain the simple factors T_i/N.
      # we get these as intersections of the conjugates of the subnormal
      # subgroup
      if HasCompositionSeries(M) then
	T:=CompositionSeries(M)[2]; # stored attribute
      else
        T:=false;
      fi;
      if not (T<>false and IsSubgroup(T,N)) then
        # we did not get the right T: must compute
	hom:=NaturalHomomorphismByNormalSubgroup(M,N);
	T:=CompositionSeries(Image(hom))[2];
	T:=PreImage(hom,T);
      fi;

      hom:=NaturalHomomorphismByNormalSubgroup(M,T);
      A:=Image(hom,M);

      Info(InfoLattice,2,"Search involution");

      # find involution in M/T
      repeat
	repeat
	  inv:=Random(M);
	until (Order(inv) mod 2 =0) and not inv in T;
	o:=First([2..Order(inv)],i->inv^i in T);
      until (o mod 2 =0);
      Info(InfoLattice,2,"Element of order ",o);
      inv:=inv^(o/2); # this is an involution in the factor
      Assert(1,inv^2 in T and not inv in T);

      S:=Normalizer(G,T); # stabilize first component

      orb:=[inv]; # class representatives in A by preimages in G
      orbi:=[Image(hom,inv)];
      cllen:=Index(A,Centralizer(A,orbi[1]));
      C:=T; #starting centralizer
      cnt:=1;

      # we have to find at least 1 centralizing element
      repeat

	# find element that centralizes inv modulo T
	repeat
	  r:=Random(S);
	  c:=Comm(inv,r);
	  o:=First([1..Order(c)],i->c^i in T);
	  c:=c^QuoInt(o-1,2);
	  if o mod 2=1 then
	    c:=r*c;
	  else
	    c:=inv^r*c;
	  fi;

	  # take care of potential class fusion
	  if not c in T and c in C then
	    cnt:=cnt+1;
	    if cnt=10 then

	      # if we have 10 true centralizing elements that did not
	      # yield anything new, we assume that classes get fused.
	      # So we have to test, how much fusion takes place.
	      # We do this with an orbit algorithm on classes of A

	      for j in orb do
		for k in SmallGeneratingSet(S) do
		  j:=j^k;
		  ji:=Image(hom,j);
		  if ForAll(orbi,l->RepresentativeAction(A,l,ji)=fail) then
		    Add(orb,j);
		    Add(orbi,ji);
		  fi;
		od;
	      od;

	      # now we have the length
	      cllen:=cllen*Length(orb);
	      Info(InfoLattice,1,Length(orb)," classes fuse");

	    fi;
	  fi;

	until not c in C or Index(S,C)=cllen;

	C:=ClosureGroup(C,c);
	Info(InfoLattice,2,"New centralizing element of order ",o,
			   ", Index=",Index(S,C));

      until Index(S,C)<=cllen;

      C:=Core(G,C); #the true centralizer is the core of the involution
		    # centralizer

      if Size(C)>Size(N) then
	for j in Filtered(nt,i->Size(i)>Size(M)) do
	  j:=Intersection(C,j);
	  if Size(j)>Size(N) and not j in nnt then
	    Add(nnt,j);
	  fi;
	od;
      fi;

    fi; # else nonabelian

    # the kernel itself
    Add(nnt,N);

    Info(InfoLattice,1,Length(nnt)-Length(nt),
          " new normal subgroups (",Length(nnt)," total)");
    nt:=nnt;
  od;

  return Reversed(nt); # to stay ascending
end;

#############################################################################
##
#M  NormalSubgroups(<G>)
##
InstallMethod(NormalSubgroups,"homomorphism principle pc groups",true,
  [IsPcGroup],0,NormalSubgroupsCalc);

InstallMethod(NormalSubgroups,"homomorphism principle perm groups",true,
  [IsPermGroup],0,NormalSubgroupsCalc);

#############################################################################
##
#M  IntermediateSubgroups(<G>,<U>)
##
InstallMethod(IntermediateSubgroups,"blocks for coset operation",
  IsIdenticalObj, [IsGroup,IsGroup],0,
function(G,U)
local rt,op,a,l,i,j,u,max,subs;
  rt:=RightTransversal(G,U);
  op:=Action(G,rt,OnRight); # use the special trick for right transversals
  a:=ShallowCopy(AllBlocks(op));
  l:=Length(a);

  # compute inclusion information among sets
  Sort(a,function(x,y)return Length(x)<Length(y);end);
  # this is n^2 but I hope will not dominate everything.
  subs:=List([1..l],i->Filtered([1..i-1],j->IsSubset(a[i],a[j])));
      # List the sets we know to be contained in each set

  max:=Set(List(Difference([1..l],Union(subs)), # sets which are
						# contained in no other
      i->[i,l+1]));

  for i in [1..l] do
    #take all subsets
    if Length(subs[i])=0 then
      # is minimal
      AddSet(max,[0,i]);
    else
      u:=ShallowCopy(subs[i]);
      #and remove those which come via other ones
      for j in u do
	u:=Difference(u,subs[j]);
      od;
      for j in u do
	#remainder is maximal
	AddSet(max,[j,i]);
      od;
    fi;
  od;

  return rec(subgroups:=List(a,i->ClosureGroup(U,rt{i})),inclusions:=max);
end);

InstallMethod(IntermediateSubgroups,"normal case",
  IsIdenticalObj, [IsGroup,IsGroup],
  1,# better than the previous method
function(G,N)
local hom,F,cl,cls,lcl,sub,sel,unsel,i,j;
  if not IsNormal(G,N) then
    TryNextMethod();
  fi;
  hom:=NaturalHomomorphismByNormalSubgroup(G,N);
  F:=Image(hom,G);
  unsel:=[1,Size(F)];
  cl:=Filtered(ConjugacyClassesSubgroups(F),
               i->not Size(Representative(i)) in unsel);
  Sort(cl,function(a,b)
            return Size(Representative(a))<Size(Representative(b));
	  end);
  cl:=Concatenation(List(cl,AsList));
  lcl:=Length(cl);
  cls:=List(cl,Size);
  sub:=List(cl,i->[]);
  sub[lcl+1]:=[0..Length(cl)];
  # now build a list of contained maximal subgroups
  for i in [1..lcl] do
    sel:=Filtered([1..i-1],j->IsInt(cls[i]/cls[j]) and cls[j]<cls[i]);
    # now run through the subgroups in reversed order:
    sel:=Reversed(sel);
    unsel:=[];
    for j in sel do
      if not j in unsel then
	if IsSubset(cl[i],cl[j]) then
	  AddSet(sub[i],j);
	  UniteSet(unsel,sub[j]); # these are not maximal
	  RemoveSet(sub[lcl+1],j); # j is not maximal in whole
	fi;
      fi;
    od;
    if Length(sub[i])=0 then
      sub[i]:=[0]; # minimal subgroup
      RemoveSet(sub[lcl+1],0);
    fi;
  od;
  sel:=[];
  for i in [1..Length(sub)] do
    for j in sub[i] do
      Add(sel,[j,i]);
    od;
  od;
  return rec(subgroups:=List(cl,i->PreImage(hom,i)),inclusions:=sel);
end);

#############################################################################
##
#E  grplatt.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

