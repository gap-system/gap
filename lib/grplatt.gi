#############################################################################
##
#W  grplatt.gi                GAP library                   Martin Sch"onert,
#W                                                          Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
  #IsSet(zuppos);
  return zuppos;
end);


#############################################################################
##
#M  ConjugacyClassSubgroups(<G>,<g>)  . . . . . . . . . . . .  constructor
##
InstallMethod(ConjugacyClassSubgroups,IsIdentical,[IsGroup,IsGroup],0,
function(G,U)
local filter,cl;

    cl:=Objectify(NewType(CollectionsFamily(FamilyObj(G)),
      IsConjugacyClassSubgroupsRep),rec());
    SetActingDomain(cl,G);
    SetRepresentative(cl,U);
    SetFunctionOperation(cl,OnPoints);
    return cl;
end);

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

CopiedGroup := function (G)
local S;
  S:=Subgroup(Parent(G),GeneratorsOfGroup(G));
  if IsIdentical(S,G) then
    Error("Subgroup returned identical object!");
  fi;
  return S;
end;

#############################################################################
##
#F  LatticeByCyclicExtension(<G>[,<func>])  Lattice of subgroups
##    if func is given, the algorithm will discard all subgroups not
##    fulfilling <func>, returning probably a pseudolattice.
##         
##
LatticeByCyclicExtension:=function(arg)
local   G,		   # group
	func,		   # test function
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
	Icopy,             # copy of <I>
	N,                 # normalizer of <I>
	Nzups,             # zuppos blist of <N>
	Ncopy,             # copy of <N>
	Jzups,             # zuppos of a conjugate of <I>
	Kzups,             # zuppos of a representative in <classes>
	reps,              # transversal of <N> in <G>
	h,i,k,l,r;      # loop variables

    G:=arg[1];
    if Length(arg)>1 and IsFunction(arg[2]) then
      func:=arg[2];
      Info(InfoLattice,1,"lattice discarding function active!");
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

    perfect:=RepresentativesPerfectSubgroups(G);
    perfect:=Filtered(perfect,i->Size(i)>1 and Size(i)<Size(G));
    if func<>false then
      perfect:=Filtered(perfect,func);
    fi;

    perfectZups:=[];
    perfectNew :=[];
    for i  in [1..Length(perfect)]  do
        I:=perfect[i];
        Icopy:=CopiedGroup(I);
        SetSize(I,Size(Icopy));
        perfectZups[i]:=BlistList(zuppos,AsList(Icopy));
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

                    Icopy:=CopiedGroup(I);
                    SetSize(Icopy,Size(H) * zupposPrime[i]);
                    SetSize(I,Size(Icopy));

                    # compute the zuppos blist of <I>
                    Ielms:=AsList(Icopy);
                    Izups:=BlistList(zuppos,Ielms);

                    # compute the normalizer of <I>
                    N:=Normalizer(G,Icopy);
                    Ncopy:=CopiedGroup(N);
                    SetSize(Ncopy,Size(N));
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
                        Nzups:=BlistList(zuppos,AsList(Ncopy));
                        SubtractBlist(Nzups,Izups);
                        classesExts[nrClasses]:=Nzups;
                    fi;

                    # compute the transversal
                    reps:=RightTransversal(G,Ncopy);
                    Unbind(Icopy);
                    Unbind(Ncopy);

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
                Icopy:=CopiedGroup(I);
                SetSize(Icopy,Size(I));

                # compute the zuppos blist of <I>
                Ielms:=AsList(Icopy);
                Izups:=BlistList(zuppos,Ielms);

                # compute the normalizer of <I>
                N:=Normalizer(G,Icopy);
                Ncopy:=CopiedGroup(N);
                SetSize(Ncopy,Size(N));
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
                    Nzups:=BlistList(zuppos,AsList(Ncopy));
                    SubtractBlist(Nzups,Izups);
                    classesExts[nrClasses]:=Nzups;
                fi;

                # compute the transversal
                reps:=RightTransversal(G,Ncopy);
                Unbind(Icopy);
                Unbind(Ncopy);

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

    # return the lattice
    return lattice;
end;

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
InstallMethod(PrintObj,"lattice",true,[IsLatticeSubgroupsRep],0,
function(l)
  Print("LatticeSubgroups(",l!.group,",\# ",
    Length(l!.conjugacyClassesSubgroups)," classes, ",
    Sum(l!.conjugacyClassesSubgroups,Size)," subgroups)");
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
      D,params,might;
  if IsSolvableGroup(G) then
    return [TrivialSubgroup(G)];
  else
    PerfGrpLoad(0);
    badsizes := Union(PERFRec.notAvailable,PERFRec.notKnown);
    D:=G;
    while not IsPerfectGroup(D) do
      D:=DerivedSubgroup(D);
    od;
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
	    cnt:=0;
	    repeat
	      if cnt=0 then
		# first the small gen syst.
		gens:=SmallGeneratingSet(u);
	      else
		# then something random
		repeat
		  gens:=List(gens,i->Random(u));
	        until Size(Subgroup(u,gens))=Size(u);
	      fi;
	      go:=List(gens,Order);
	      imgs:=List(go,i->Filtered(cl,j->Order(Representative(j))=i));
	      if Product(imgs,i->Sum(i,Size))<bw then
		bg:=gens;
		bi:=imgs;
		bw:=Product(imgs,i->Sum(i,Size));
	      fi;
	      cnt:=cnt+1;
	    until bw/Size(G)/10<cnt;

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
		if not ForAny(nu,i->RepresentativeOperation(G,i,k)<>fail) then
		  Add(nu,k);
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
            Icopy,             # copy of <I>
            N,                 # normalizer of <I>
            Ncopy,             # copy of <N>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group
            i,k,l,r;         # loop variables

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
        Icopy:=CopiedGroup(I);
        Info(InfoLattice,2," testing class ",i);

        # compute the zuppos blist of <I>
        Ielms:=AsList(Icopy);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=Normalizer(grp,Icopy);
        Ncopy:=CopiedGroup(N);

        # compute the right transversal
        reps:=RightTransversal(grp,Ncopy);
        Unbind(Icopy);
        Unbind(Ncopy);

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
            Icopy,             # copy of <I>
            N,                 # normalizer of <I>
            Ncopy,             # copy of <N>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group;
            i,k,l,r;         # loop variables

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
        Icopy:=CopiedGroup(I);

        # compute the zuppos blist of <I>
        Ielms:=AsList(Icopy);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=Normalizer(grp,Icopy);
        Ncopy:=CopiedGroup(N);

        # compute the right transversal
        reps:=RightTransversal(grp,Ncopy);
        Unbind(Icopy);
        Unbind(Ncopy);

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
    if IsSolvableGroup(G) then
      lat:=IsomorphismPcGroup(G);
      maxs:=MaximalSubgroupClassReps(Image(lat,G));
      return List(maxs,i->PreImage(lat,i));
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
#F  NormalSubgroups( <G> )
##
InstallMethod(NormalSubgroups,"generic method for groups",true,[IsGroup],0,
function ( G )
    local   nrm;
    nrm := NormalSubgroupsAbove(G,TrivialSubgroup(G),[]);
    Sort( nrm, function( a, b ) return Size( a ) < Size( b ); end );
    return nrm;
end );

NormalSubgroupsAbove := function ( G, N, avoid )
    local   R, C, g, M;

    R     := [ N ];
    avoid := ShallowCopy( avoid );
    for C  in ConjugacyClasses( G )  do
        g := Representative( C );
        if not g in avoid  and not g in N  then

            # compute the normal closure of <N> and <g> in <G>
            M := NormalClosure( G, ClosureGroup( N, g ) );
            if ForAll( avoid, rep -> not rep in M )  then
                Append( R, NormalSubgroupsAbove(G,M,avoid) );
            fi;

            # from now on avoid this representative
            Add( avoid, g );
        fi;
    od;

    # return the list of normal subgroups
    return R;
end;

#############################################################################
##
#M  TableOfMarks(<G>)   . . . . . . . . . . . . . . . . make a table of marks
##
InstallMethod(TableOfMarks,"cyclic extension",true,[IsGroup],0,
function (G)
local   tom,               # table of marks (result)
	mrks,              # marks for one class
	ind,               # index of <I> in <N>
	zuppos,            # generators of prime power order
	classes,           # list of all classes
	classesZups,       # zuppos blist of classes
	I,                 # representative of a class
	Ielms,             # elements of <I>
	Izups,             # zuppos blist of <I>
	Icopy,             # copy of <I>
	N,                 # normalizer of <I>
	Ncopy,             # copy of <N>
	Jzups,             # zuppos of a conjugate of <I>
	Kzups,             # zuppos of a representative in <classes>
	reps,              # transversal of <N> in <G>
	i,k,l,r;         # loop variables

    # compute the lattice,fetch the classes,zuppos,and representatives
    classes:=ConjugacyClassesSubgroups(G);
    classesZups:=[];

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(G);

    # initialize the table of marks
    Info(InfoLattice,1,"computing table of marks");
    tom:=rec(subs:=List(classes,c -> []),
                marks:=List(classes,c -> []));

    # loop over all classes
    for i  in [1..Length(classes)-1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);
        Icopy:=CopiedGroup(I);

        # compute the zuppos blist of <I>
        Ielms:=AsList(Icopy);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=Normalizer(G,Icopy);
        Ncopy:=CopiedGroup(N);
        ind:=Size(Ncopy) / Size(Icopy);
        # compute the right transversal
        reps:=RightTransversal(G,Ncopy);
        Unbind(Icopy);
        Unbind(Ncopy);

        # set up the marking list
        mrks   :=0 * [1..Length(classes)];
        mrks[1]:=Length(reps) * ind;
        mrks[i]:=1 * ind;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the zuppos blist of the conjugate
            if reps[r] = One(G) then
                Jzups:=Izups;
            else
                Jzups:=BlistList(zuppos,OnTuples(Ielms,reps[r]));
            fi;

            # loop over all other (smaller classes)
            for k  in [2..i-1]  do
                Kzups:=classesZups[k];

                # test if the <K> is a subgroup of <J>
                if IsSubsetBlist(Jzups,Kzups)  then
                    mrks[k]:=mrks[k] + ind;
                fi;

            od;

        od;

        # compress this line into the table of marks
        for k  in [1..i]  do
            if mrks[k] <> 0  then
                Add(tom.subs[i],k);
                Add(tom.marks[i],mrks[k]);
            fi;
        od;
        Unbind(Ielms);
        Unbind(reps);
        Info(InfoLattice,2,"testing class ",i,", size = ",Size(I),
	     ", length = ",Size(G) / Size(N),", includes ",
	     Length(tom.marks[i])," classes");

    od;

    # handle the whole group
      Info(InfoLattice,2,"testing class ",Length(classes),", size = ",Size(G),
	   ", length = ",1,", includes ",
           Length(tom.marks[Length(classes)])," classes");
    tom.subs[Length(classes)]:=[1..Length(classes)] + 0;
    tom.marks[Length(classes)]:=0 * [1..Length(classes)] + 1;

    # return the table of marks
    return tom;
end);

#############################################################################
##
#E  grplatt.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

