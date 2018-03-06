#############################################################################
##
#W  grplatt.gi                GAP library                   Martin Schönert,
#W                                                          Alexander Hulpke
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This  file  contains declarations for subgroup latices
##

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
#F  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
InstallOtherMethod(Zuppos,"group with condition",true,[IsGroup,IsFunction],0,
function (G,func)
local   zuppos,            # set of zuppos,result
	c,                 # a representative of a class of elements
	o,                 # its order
	h,                 # the subgroup < c > of G
	N,                 # normalizer of < c >
	t;                 # loop variable

  if HasZuppos(G) then
    return Filtered(Zuppos(G), c -> func(Subgroup(G,[c])));
  fi;

  # compute the zuppos
  zuppos:=[One(G)];
  for c in List(ConjugacyClasses(G),Representative)  do
    o:=Order(c);
    h:=Subgroup(G,[c]);
    if IsPrimePowerInt(o) and func(h)  then
      if ForAll([2..o],i -> Gcd(o,i) <> 1 or not c^i in zuppos) then
	N:=Normalizer(G,h);
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
#M  \^( <H>, <G> ) . . . . . . . . . conjugacy class of a subgroup of a group
##
InstallOtherMethod( \^, "conjugacy class of a subgroup of a group",
                    IsIdenticalObj, [ IsGroup, IsGroup ], 0,

  function ( H, G )
    if IsSubgroup(G,H) then return ConjugacyClassSubgroups(G,H);
                       else TryNextMethod(); fi;
  end );

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

#############################################################################
##
#M  ClassElementLattice
##
InstallMethod(ClassElementLattice, "for classes of subgroups",
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

InstallOtherMethod( \[\], "for classes of subgroups",
  true, [ IsConjugacyClassSubgroupsRep, IsPosInt],0,ClassElementLattice );

InstallMethod( StabilizerOfExternalSet, true, [ IsConjugacyClassSubgroupsRep ], 
    # override potential pc method
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

BindGlobal("LatticeFromClasses",function(G,classes)
local lattice;
  # sort the classes
  Sort(classes,
	function (c,d)
	  return Size(Representative(c)) < Size(Representative(d))
	    or (Size(Representative(c)) = Size(Representative(d))
		and Size(c) < Size(d));
	end);

  # create the lattice
  lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
    rec(conjugacyClassesSubgroups:=classes,
        group:=G));

  # return the lattice
  return lattice;
end );

#############################################################################
##
#F  LatticeByCyclicExtension(<G>[,<func>[,<noperf>]])  Lattice of subgroups
##
##  computes the lattice of <G> using the cyclic extension algorithm. If the
##  function <func> is given, the algorithm will discard all subgroups not
##  fulfilling <func> (and will also not extend them), returning a partial
##  lattice. If <func> is a list of length 2, the first entry is such a
##  function, the second a function for selecting zuppos.
##  This can be useful to compute only subgroups with certain
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
	zuppofunc,         # test fct for zuppos
	noperf,		   # discard perfect groups
        lattice,           # lattice (result)
	factors,           # factorization of <G>'s size
	zuppos,            # generators of prime power order
	zupposPrime,       # corresponding prime
	zupposPower,       # index of power of generator
	ZupposSubgroup,    # function to compute zuppos for subgroup
	zuperms,	   # permutation of zuppos by group
	Gimg,		   # grp image under zuperms
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
	ac,
	transv,
	factored,
	mapped,
	expandmem,
	h,i,k,l,ri,rl,r;      # loop variables

    G:=arg[1];
    noperf:=false;
    zuppofunc:=false;
    if Length(arg)>1 and (IsFunction(arg[2]) or IsList(arg[2])) then
      func:=arg[2];
      Info(InfoLattice,1,"lattice discarding function active!");
      if IsList(func) then
	zuppofunc:=func[2];
	func:=func[1];
      fi;
      if Length(arg)>2 and IsBool(arg[3]) then
	noperf:=arg[3];
      fi;
    else
      func:=false;
    fi;

    expandmem:=ValueOption("Expand")=true;

  # if store is true, an element list will be kept in `Ielms' if possible
  ZupposSubgroup:=function(U,store)
  local elms,zups;
    if Size(U)=Size(G) then
      if store then Ielms:=fail;fi;
      zups:=BlistList([1..Length(zuppos)],[1..Length(zuppos)]);
    elif Size(U)>10^4 then
      # the group is very big - test the zuppos with `in'
      Info(InfoLattice,3,"testing zuppos with `in'");
      if store then Ielms:=fail;fi;
      zups:=List(zuppos,i->i in U);
      IsBlist(zups);
    else
      elms:=AsSSortedListNonstored(U);
      if store then Ielms:=elms;fi;
      zups:=BlistList(zuppos,elms);
    fi;
    return zups;
  end;

    # compute the factorized size of <G>
    factors:=Factors(Size(G));

    # compute a system of generators for the cyclic sgr. of prime power size
    if zuppofunc<>false then
      zuppos:=Zuppos(G,zuppofunc);
    else
      zuppos:=Zuppos(G);
    fi;

    Info(InfoLattice,1,"<G> has ",Length(zuppos)," zuppos");

    # compute zuppo permutation
    if IsPermGroup(G) then
      zuppos:=List(zuppos,SmallestGeneratorPerm);
      zuppos:=AsSSortedList(zuppos);
      zuperms:=List(GeneratorsOfGroup(G),
		i->Permutation(i,zuppos,function(x,a)
		                          return SmallestGeneratorPerm(x^a);
					end));
      if NrMovedPoints(zuperms)<200*NrMovedPoints(G) then
	zuperms:=GroupHomomorphismByImagesNC(G,Group(zuperms),
		  GeneratorsOfGroup(G),zuperms);
	# force kernel, also enforces injective setting
	Gimg:=Image(zuperms);
	if Size(KernelOfMultiplicativeGeneralMapping(zuperms))=1 then
	  SetSize(Gimg,Size(G));
	fi;
      else
	zuperms:=fail;
      fi;
    else
      zuppos:=AsSSortedList(zuppos);
      zuperms:=fail;
    fi;

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
      perfect:=List(perfect,i->AsSubgroup(Parent(G),i));
    fi;

    perfectZups:=[];
    perfectNew :=[];
    for i  in [1..Length(perfect)]  do
        I:=perfect[i];
        #perfectZups[i]:=BlistList(zuppos,AsSSortedListNonstored(I));
        perfectZups[i]:=ZupposSubgroup(I,false);
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
	      # NC is safe -- all groups are subgroups of Parent(H)
	      I:=ClosureSubgroupNC(H,zuppos[i]);
	      #Subgroup(Parent(G),Concatenation(GeneratorsOfGroup(H),
	      #			   [zuppos[i]]));
	      if func=false or func(I) then

		SetSize(I,Size(H) * zupposPrime[i]);

		# compute the zuppos blist of <I>
		#Ielms:=AsSSortedListNonstored(I);
		#Izups:=BlistList(zuppos,Ielms);
		if zuperms=fail then
		  Izups:=ZupposSubgroup(I,true);
		else
		  Izups:=ZupposSubgroup(I,false);
		fi;

		# compute the normalizer of <I>
		N:=Normalizer(G,I);
		#AH 'NormalizerInParent' attribute ?
		Info(InfoLattice,2,"found new class ",nrClasses+1,
		      ", size = ",Size(I)," length = ",Size(G)/Size(N));

		# make the new conjugacy class
		C:=ConjugacyClassSubgroups(G,I);
		SetSize(C,Size(G) / Size(N));
		SetStabilizerOfExternalSet(C,N);
		nrClasses:=nrClasses + 1;
		classes[nrClasses]:=C;

		# store the extend by list
		if l < Length(factors)-1  then
		  classesZups[nrClasses]:=Izups;
		  #Nzups:=BlistList(zuppos,AsSSortedListNonstored(N));
		  Nzups:=ZupposSubgroup(N,false);
		  SubtractBlist(Nzups,Izups);
		  classesExts[nrClasses]:=Nzups;
		fi;

		# compute the right transversal
		# (but don't store it in the parent)
		if expandmem and zuperms<>fail then
		  if Index(G,N)>400 then
		    ac:=AscendingChainOp(G,N); # do not store
		    while Length(ac)>2 and Index(ac[3],ac[1])<100 do
		      ac:=Concatenation([ac[1]],ac{[3..Length(ac)]});
		    od;
		    if Length(ac)>2 and
		      Maximum(List([3..Length(ac)],x->Index(ac[x],ac[x-1])))<500
		     then

		      # mapped factorized transversal
		      Info(InfoLattice,3,"factorized transversal ",
		             List([2..Length(ac)],x->Index(ac[x],ac[x-1])));
		      transv:=[];
		      ac[Length(ac)]:=Gimg;
		      for ri in [Length(ac)-1,Length(ac)-2..1] do
			ac[ri]:=Image(zuperms,ac[ri]);
			if ri=1 then
			  transv[ri]:=List(RightTransversalOp(ac[ri+1],ac[ri]),
			                   i->Permuted(Izups,i));
			else
			  transv[ri]:=AsList(RightTransversalOp(ac[ri+1],ac[ri]));
			fi;
		      od;
		      mapped:=true;
		      factored:=true;
		      reps:=Cartesian(transv);
		      Unbind(ac);
		      Unbind(transv);
		    else
		      reps:=RightTransversalOp(Gimg,Image(zuperms,N));
		      mapped:=true;
		      factored:=false;
		    fi;
		  else
		    reps:=RightTransversalOp(G,N);
		    mapped:=false;
		    factored:=false;
		  fi;
		else
		  reps:=RightTransversalOp(G,N);
		  mapped:=false;
		  factored:=false;
		fi;

		# loop over the conjugates of <I>
		for ri in [1..Length(reps)] do
		  CompletionBar(InfoLattice,3,"Coset loop: ",ri/Length(reps));
		  r:=reps[ri];

		  # compute the zuppos blist of the conjugate
		  if zuperms<>fail then
		    # we know the permutation of zuppos by the group
		    if mapped then
		      if factored then
			Jzups:=r[1];
			for rl in [2..Length(r)] do
			  Jzups:=Permuted(Jzups,r[rl]);
			od;
		      else
			Jzups:=Permuted(Izups,r);
		      fi;
		    else
		      if factored then
			Error("factored");
		      else
			Jzups:=Image(zuperms,r);
			Jzups:=Permuted(Izups,Jzups);
		      fi;
		    fi;
		  elif r = One(G)  then
		    Jzups:=Izups;
		  elif Ielms<>fail then
		    Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
		  else
		    Jzups:=ZupposSubgroup(I^r,false);
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
		CompletionBar(InfoLattice,3,"Coset loop: ",false);

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
	    #Ielms:=AsSSortedListNonstored(I);
	    #Izups:=BlistList(zuppos,Ielms);
	    if zuperms=fail then
	      Izups:=ZupposSubgroup(I,true);
	    else
	      Izups:=ZupposSubgroup(I,false);
	    fi;

	    # compute the normalizer of <I>
	    N:=Normalizer(G,I);
	    # AH: NormalizerInParent ?
	    Info(InfoLattice,2,"found perfect class ",nrClasses+1,
		  " size = ",Size(I),", length = ",Size(G)/Size(N));

	    # make the new conjugacy class
	    C:=ConjugacyClassSubgroups(G,I);
	    SetSize(C,Size(G)/Size(N));
	    SetStabilizerOfExternalSet(C,N);
	    nrClasses:=nrClasses + 1;
	    classes[nrClasses]:=C;

	    # store the extend by list
	    if l < Length(factors)-1  then
	      classesZups[nrClasses]:=Izups;
	      #Nzups:=BlistList(zuppos,AsSSortedListNonstored(N));
	      Nzups:=ZupposSubgroup(N,false);
	      SubtractBlist(Nzups,Izups);
	      classesExts[nrClasses]:=Nzups;
	    fi;

	    # compute the right transversal
	    # (but don't store it in the parent)
	    reps:=RightTransversalOp(G,N);

	    # loop over the conjugates of <I>
	    for r  in reps  do

	      # compute the zuppos blist of the conjugate
	      if zuperms<>fail then
		# we know the permutation of zuppos by the group
		Jzups:=Image(zuperms,r);
		Jzups:=Permuted(Izups,Jzups);
	      elif r = One(G)  then
		Jzups:=Izups;
	      elif Ielms<>fail then
		Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
	      else
		Jzups:=ZupposSubgroup(I^r,false);
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

  lattice:=LatticeFromClasses(G,classes);
  if func<>false then
    lattice!.func:=func;
  fi;
  return lattice;
end);

BindGlobal("VectorspaceComplementOrbitsLattice",function(n,a,c,ker)
local s, m, dim, p, field, one, bas, I, l, avoid, li, gens, act, actfun,
      rep, max, baselist, ve, new, lb, newbase, e, orb, stb, tr, di,
      cont, j, img, idx, stabilizer, i, base, d, gn;
  m:=ModuloPcgs(a,ker);
  dim:=Length(m);
  p:=RelativeOrders(m)[1];
  field:=GF(p);
  one:=One(field);
  bas:=List(GeneratorsOfGroup(c),i->ExponentsOfPcElement(m,i)*one);
  TriangulizeMat(bas);
  bas:=Filtered(bas,i->not IsZero(i));
  I := IdentityMat(dim, field);
  l:=BaseSteinitzVectors(I,bas);
  avoid:=Length(l.subspace);
  l:=Concatenation(l.factorspace,l.subspace);
  l:=ImmutableMatrix(field,l);
  li:=l^-1;
  gens:=GeneratorsOfGroup(n);
  act:=LinearActionLayer(n,m);
  act:=List(act,i->l*i*li);
  if p=2 then
    actfun:=OnSubspacesByCanonicalBasisGF2;
  else
    actfun:=OnSubspacesByCanonicalBasis;
  fi;
  rep:=[];
  max:=dim-avoid;
  baselist := [[]];
  ve:=AsList(field);
  for i in [1..dim] do
    Info(InfoLattice,5,"starting dim :",i," bases found :",Length(baselist));
    new := [];
    for base in baselist do

      #subspaces of equal dimension
      lb:=Length(base);
      for d in [0..p^lb-1] do
	if d=0 then
	  # special case for subspace of higher dimension
	  if Length(base) < max and i<=max then
	    newbase:=Concatenation(List(base,ShallowCopy), [I[i]]);
	  else
	    newbase:=[];
	  fi;
	else
	  # possible extension number d
	  newbase := List(base,ShallowCopy);
	  e:=d;
	  for j in [1..lb] do
	    newbase[j][i]:=ve[(e mod p)+1];
	    e:=QuoInt(e,p);
	  od;
	  #for j in [1..Length(vec)] do
	  #  newbase[j][i] := vec[j];
	  #od;
	fi;
	if i<dim and Length(newbase)>0 then
	  # we will need the space for the next level
	  Add(new, newbase);
	fi;

	if Length(newbase)=max then
	  # compute orbit
	  orb:=[newbase];
	  stb:=a;
	  tr:=[One(a)];
	  di:=NewDictionary(newbase,true,
			# fake entry to simulate a ``grassmannian'' object
	                    1);
	  AddDictionary(di,newbase,1);
	  cont:=true;
	  j:=1;
	  while cont and j<=Length(orb) do
	    for gn in [1..Length(gens)] do
	      img:=actfun(orb[j],act[gn]);
	      idx:=LookupDictionary(di,img);
	      if idx=fail then
		if img<newbase then
		  # element is not minimal -- discard
		  cont:=false;
		fi;
		Add(orb,img);
		AddDictionary(di,img,Length(orb));
		Add(tr,tr[j]*gens[gn]);
	      else
		idx:=tr[j]*gens[gn]/tr[idx];
		stb:=ClosureGroup(stb,idx);
	      fi;
	    od;
	    j:=j+1;
	  od;

	  if cont then
	    Info(InfoLattice,5,"orbitlength=",Length(orb));
	    newbase:=List(newbase*l,i->PcElementByExponents(m,i));
	    s:=Group(Concatenation(GeneratorsOfGroup(ker),newbase));
	    SetSize(s,Size(ker)*p^Length(newbase));
	    j:=Size(stb);
	    if IsAbelian(stb) and
	      p^Length(GeneratorsOfGroup(stb))=j then
	      # don't waste too much time
	      stb:=Group(GeneratorsOfGroup(stb),One(stb));
	    else
	      stb:=Group(SmallGeneratingSet(stb),One(stb));
	    fi;
	    SetSize(stb,j);
	    Add(rep,rec(representative:=s,normalizer:=stb));
	  fi;
	fi;
      od;
    od;

    # book keeping for the next level
    Append(baselist, new);

  od;
  return rep;
end);


#############################################################################
##
#M  LatticeViaRadical(<G>[,<H>])  . . . . . . . . . .  lattice of subgroups
##
InstallGlobalFunction(LatticeViaRadical,function(arg)
  local G,H,HN,HNI,ser, pcgs, u, hom, f, c, nu, nn, nf, a, k, ohom, mpcgs, gf,
  act, nts, orbs, n, ns, nim, fphom, as, p, isn, isns, lmpc, npcgs, ocr, v,
  com, cg, i, j, w, ii,first,cgs,cs,presmpcgs,select,fselect,
  makesubgroupclasses,cefastersize;

  #group order below which cyclic extension is usually faster
  if IsPackageMarkedForLoading("tomlib","")=true then
    cefastersize:=1; 
  else
    cefastersize:=40000; 
  fi;

  makesubgroupclasses:=function(g,l)
  local i,m,c;
    m:=[];
    for i in l do
      c:=ConjugacyClassSubgroups(g,i);
      if IsBound(i!.GNormalizer) then
	SetStabilizerOfExternalSet(c,i!.GNormalizer);
	Unbind(i!.GNormalizer);
      fi;
      Add(m,c);
    od;
    return m;
  end;

  G:=arg[1];
  H:=fail;
  select:=fail;
  if Length(arg)>1 then
    if IsGroup(arg[2]) then
      H:=arg[2];
      if not (IsSubgroup(G,H) and IsNormal(G,H)) then
	Error("H must be normal in G");
      fi;
    elif IsFunction(arg[2]) then
      select:=arg[2];

    fi;
  fi;

  ser:=PermliftSeries(G:limit:=300); # do not form too large spaces as they
                                     # clog up memory
  pcgs:=ser[2];
  ser:=ser[1];
  if Index(G,ser[1])=1 then
    Info(InfoWarning,3,"group is solvable");
    hom:=NaturalHomomorphismByNormalSubgroup(G,G);
    hom:=hom*IsomorphismFpGroup(Image(hom));
    u:=[[G],[G],[hom]];
  elif Size(ser[1])=1 then
    if H<>fail then
      return LatticeByCyclicExtension(G,[u->IsSubset(H,u),u->IsSubset(H,u)]);
    elif select<>fail then
      return LatticeByCyclicExtension(G,select);
    elif (HasIsSimpleGroup(G) and IsSimpleGroup(G)) 
      or Size(G)<=cefastersize then
      # in the simple case we cannot go back into trivial fitting case
      # or cyclic extension is faster as group is small
      if IsSimpleGroup(G) then
	c:=TomDataSubgroupsAlmostSimple(G);
	if c<>fail then
	  c:=makesubgroupclasses(G,c);
	  return LatticeFromClasses(G,c);
	fi;
      fi;

      return LatticeByCyclicExtension(G);
    else
      c:=SubgroupsTrivialFitting(G);
      c:=makesubgroupclasses(G,c);
      u:=[List(c,Representative),List(c,StabilizerOfExternalSet)];
    fi;
  else
    hom:=NaturalHomomorphismByNormalSubgroupNC(G,ser[1]);
    f:=Image(hom,G);
    fselect:=fail;
    if H<>fail then
      HN:=Image(hom,H);
      c:=LatticeByCyclicExtension(f,
	  [u->IsSubset(HN,u),u->IsSubset(HN,u)])!.conjugacyClassesSubgroups;
    elif select<>fail and (select=IsPerfectGroup  or select=IsSimpleGroup) then
      c:=ConjugacyClassesPerfectSubgroups(f);
      c:=Filtered(c,x->Size(Representative(x))>1);
      fselect:=U->not IsSolvableGroup(U);
    elif select<>fail then
      c:=LatticeByCyclicExtension(f,select)!.conjugacyClassesSubgroups;
    elif Size(f)<=cefastersize then
      c:=LatticeByCyclicExtension(f)!.conjugacyClassesSubgroups;
    else
      c:=SubgroupsTrivialFitting(f);
      c:=makesubgroupclasses(f,c);
    fi;
    if select<>fail then
      nu:=Filtered(c,i->select(Representative(i)));
      Info(InfoLattice,1,"Selection reduced ",Length(c)," to ",Length(nu));
      c:=nu;
    fi;
    nu:=[];
    nn:=[];
    nf:=[];
    for i in c do
      a:=Representative(i);
      k:=PreImage(hom,a);
      Add(nu,k);
      Add(nn,PreImage(hom,Stabilizer(i)));
      Add(nf,RestrictedMapping(hom,k)*IsomorphismFpGroup(a));
    od;
    u:=[nu,nn,nf];
  fi;
  for i in [2..Length(ser)] do
    Info(InfoLattice,1,"Step ",i," : ",Index(ser[i-1],ser[i]));
    #ohom:=hom;
    #hom:=NaturalHomomorphismByNormalSubgroupNC(G,ser[i]);
    if H<>fail then
      HN:=ClosureGroup(H,ser[i]);
      HNI:=Intersection(ClosureGroup(H,ser[i]),ser[i-1]);
#      if pcgs=false then
	mpcgs:=ModuloPcgs(HNI,ser[i]);
#      else
#	mpcgs:=pcgs[i-1] mod pcgs[i];
#      fi;
      presmpcgs:=ModuloPcgs(ser[i-1],ser[i]);
    else
      if pcgs=false then
	mpcgs:=ModuloPcgs(ser[i-1],ser[i]);
      else
	mpcgs:=pcgs[i-1] mod pcgs[i];
      fi;
      presmpcgs:=mpcgs;
    fi;

    if Length(mpcgs)>0 then
      gf:=GF(RelativeOrders(mpcgs)[1]);
      if select=IsPerfectGroup then
	# the only normal subgroups are those that are normal under any
	# subgroup so far.

	# minimal of the subgroups so far
	nu:=Filtered(u[1],x->not ForAny(u[1],y->Size(y)<Size(x)
                     and IsSubgroup(x,y)));
        nts:=[];
	#T: Use invariant subgroups here
	for j in nu do
	  for k in Filtered(NormalSubgroups(j),y->IsSubset(ser[i-1],y)
	      and IsSubset(y,ser[i])) do
            if not k in nts then Add(nts,k);fi;
	  od;
	od;
	# by setting up `act' as fail, we force a different selection later
	act:=[nts,fail];

      elif select=IsSimpleGroup then
	# simple -> no extensions, only the trivial subgroup is valid.
	act:=[[ser[i]],GroupHomomorphismByImagesNC(G,Group(()),
	    GeneratorsOfGroup(G),
	    List(GeneratorsOfGroup(G),i->()))];
      else
	act:=ActionSubspacesElementaryAbelianGroup(G,mpcgs);
      fi;
    else
      gf:=GF(Factors(Index(ser[i-1],ser[i]))[1]);
      act:=[[ser[i]],GroupHomomorphismByImagesNC(G,Group(()),
           GeneratorsOfGroup(G),
           List(GeneratorsOfGroup(G),i->()))];
    fi;
    nts:=act[1];
    act:=act[2];
    nu:=[];
    nn:=[];
    nf:=[];
    # Determine which ones we need and keep old ones
    orbs:=[];
    for j in [1..Length(u[1])] do
      a:=u[1][j];
#if ForAny(GeneratorsOfGroup(a),i->SIZE_OBJ(i)>maxsz) then Error("1");fi;
      n:=u[2][j];
#if ForAny(GeneratorsOfGroup(n),i->SIZE_OBJ(i)>maxsz) then Error("2");fi;

      # find indices of subgroups normal under a and form orbits under the
      # normalizer
      if act<>fail then
	ns:=Difference([1..Length(nts)],MovedPoints(Image(act,a)));
	nim:=Image(act,n);
	ns:=Orbits(nim,ns);
      else
	nim:=Filtered([1..Length(nts)],x->IsNormal(a,nts[x]));
	ns:=[];
	for k in [1..Length(nim)] do
	  if not ForAny(ns,x->nim[k] in x) then
	    p:=Orbit(n,nts[k]);
	    p:=List(p,x->Position(nts,x));
	    p:=Filtered(p,x->x<>fail and x in nim);
	    Add(ns,p);
	  fi;
	od;
      fi;
      if Size(a)>Size(ser[i-1]) then
	# keep old groups
	if H=fail or IsSubset(HN,a) then
	  Add(nu,a);Add(nn,n);
	  if Size(ser[i])>1 then
	    fphom:=LiftFactorFpHom(u[3][j],a,ser[i-1],ser[i],presmpcgs);
	    Add(nf,fphom);
	  fi;
	fi;
	orbs[j]:=ns;
      else # here a is the trivial subgroup in the factor. (This will never
	   # happen if we look for perfect or simple groups!)
	orbs[j]:=[];
	# previous kernel -- there the orbits are classes of subgroups in G
	for k in ns do
	  Add(nu,nts[k[1]]);
	  Add(nn,PreImage(act,Stabilizer(nim,k[1])));
	  if Size(ser[i])>1 then
	    fphom:=IsomorphismFpGroupByChiefSeriesFactor(nts[k[1]],"x",ser[i]);
	    Add(nf,fphom);
	  fi;
	od;
      fi;
    od;

    # run through nontrivial subspaces (greedy test whether they are needed)
    for j in [1..Length(nts)] do
      if Size(nts[j])<Size(ser[i-1]) then
	as:=[];
	for k in [1..Length(orbs)] do
	  p:=PositionProperty(orbs[k],z->j in z);
	  if p<>fail then
	    # remove orbit
	    orbs[k]:=orbs[k]{Difference([1..Length(orbs[k])],[p])};
	    Add(as,k);
	  fi;
	od;
	if Length(as)>0 then
	  Info(InfoLattice,2,"Normal subgroup ",j,", ",Length(as),
	       " subgroups to consider");
	  # there are subgroups that will complement with this kernel.
	  # Construct the modulo pcgs and the action of the largest subgroup
	  # (which must be the normalizer)
	  isn:=fail;
	  isns:=1;
	  for k in as do
	    if Size(u[1][k])>isns then
	      isns:=Size(u[1][k]);
	      isn:=k;
	    fi;
	  od;

	  if pcgs=false then
	    lmpc:=ModuloPcgs(ser[i-1],nts[j]);
	    if Size(nts[j])=1 and Size(ser[i])=1 then
	      # avoid degenerate case
	      npcgs:=Pcgs(nts[j]);
	    else
	      npcgs:=ModuloPcgs(nts[j],ser[i]);
	    fi;
	  else
	    if IsTrivial(nts[j]) then
	      lmpc:=pcgs[i-1];
	      npcgs:="not used";
	    else
	      c:=InducedPcgs(pcgs[i-1],nts[j]);
	      lmpc:=pcgs[i-1] mod c;
	      npcgs:=c mod pcgs[i];
	    fi;
	  fi;

	  for k in as do
	    a:=u[1][k];
	    if IsNormal(u[2][k],nts[j]) then
	      n:=u[2][k];
	    else
	      n:=Normalizer(u[2][k],nts[j]);
#if ForAny(GeneratorsOfGroup(n),i->SIZE_OBJ(i)>maxsz) then Error("2a");fi;
	    fi;
	    if Length(GeneratorsOfGroup(n))>3 then
	      w:=Size(n);
	      n:=Group(SmallGeneratingSet(n));
	      SetSize(n,w);
	    fi;
	    ocr:=rec(group:=a,
		    modulePcgs:=lmpc);
	    #fphom:=RestrictedMapping(ohom,a)*IsomorphismFpGroup(Image(ohom,a));
	    #ocr.factorfphom:=fphom;
	    ocr.factorfphom:=u[3][k];
	    OCOneCocycles(ocr,true);
	    if IsBound(ocr.complement) then
#if ForAny(ocr.complementGens,i->SIZE_OBJ(i)>maxsz) then Error("3");fi;
	      v:=BaseSteinitzVectors(
		BasisVectors(Basis(ocr.oneCocycles)),
		BasisVectors(Basis(ocr.oneCoboundaries)));
	      v:=VectorSpace(gf,v.factorspace,Zero(ocr.oneCocycles));
	      com:=[];
	      cgs:=[];
	      first:=false;
	      if Size(v)>100 and Size(ser[i])=1
		 and HasElementaryAbelianFactorGroup(a,nts[j]) then
		com:=VectorspaceComplementOrbitsLattice(n,a,ser[i-1],nts[j]);
		Info(InfoLattice,4,"Subgroup ",Position(as,k),"/",Length(as),
		      ", ",Size(v)," local complements, ",Length(com)," orbits");
		for c in com do
		  if H=fail or IsSubset(HN,c.representative) then
		    Add(nu,c.representative);
		    Add(nn,c.normalizer);
		  fi;
		od;
	      else
		for w in Enumerator(v) do
		  cg:=ocr.cocycleToList(w);
  #if ForAny(cg,i->SIZE_OBJ(i)>maxsz) then Error("3");fi;
		  for ii in [1..Length(cg)] do
		    cg[ii]:=ocr.complementGens[ii]*cg[ii];
		  od;
		  if first then
		    # this is clearly kept -- so calculate a stabchain
		    c:=ClosureSubgroup(nts[j],cg);
		  first:=false;
		  else
		    c:=SubgroupNC(G,Concatenation(SmallGeneratingSet(nts[j]),cg));
		  fi;
		  Assert(1,Size(c)=Index(a,ser[i-1])*Size(nts[j]));
		  if H=fail or IsSubset(HN,c) then
		    SetSize(c,Index(a,ser[i-1])*Size(nts[j]));
		    Add(cgs,cg);
		    #c!.comgens:=cg;
		    Add(com,c);
		  fi;
		od;
		w:=Length(com);
		com:=SubgroupsOrbitsAndNormalizers(n,com,false:savemem:=true);
		Info(InfoLattice,3,"Subgroup ",Position(as,k),"/",Length(as),
		      ", ",w," local complements, ",Length(com)," orbits");
		for w in com do
		  c:=w.representative;
		  if fselect=fail or fselect(c) then
		    Add(nu,c);
		    Add(nn,w.normalizer);
		    if Size(ser[i])>1 then
		      # need to lift presentation
		      fphom:=ComplementFactorFpHom(ocr.factorfphom,
		      a,ser[i-1],nts[j],c,
		      ocr.generators,cgs[w.pos]);

		      Assert(1,KernelOfMultiplicativeGeneralMapping(fphom)=nts[j]);
		      if Size(nts[j])>Size(ser[i]) then
			fphom:=LiftFactorFpHom(fphom,c,nts[j],ser[i],npcgs);
			Assert(1,
			  KernelOfMultiplicativeGeneralMapping(fphom)=ser[i]);
		      fi;
		      Add(nf,fphom);
		    fi;
		  fi;

		od;
	      fi;

	      ocr:=false;
	      cgs:=false;
	      com:=false;
	    fi;
	  od;
	fi;
      fi;
    od;

    u:=[nu,nn,nf];

  od;
  nn:=[];
  for i in [1..Length(u[1])] do
    a:=ConjugacyClassSubgroups(G,u[1][i]);
    n:=u[2][i];
    SetSize(a,Size(G)/Size(n));
    SetStabilizerOfExternalSet(a,n);
    Add(nn,a);
  od;

  # some `select'ions remove the trivial subgroup
  if select<>fail and not ForAny(u[1],x->Size(x)=1) 
    and select(TrivialSubgroup(G)) then
    Add(nn,ConjugacyClassSubgroups(G,TrivialSubgroup(G)));
  fi;
  return LatticeFromClasses(G,nn);
end);


#############################################################################
##
#M  LatticeSubgroups(<G>)  . . . . . . . . . .  lattice of subgroups
##
InstallMethod(LatticeSubgroups,"via radical",true,[IsGroup and
  IsFinite and CanComputeFittingFree],0, LatticeViaRadical );

InstallMethod(LatticeSubgroups,"cyclic extension",true,[IsGroup and
  IsFinite],0, LatticeByCyclicExtension );

RedispatchOnCondition( LatticeSubgroups, true,
    [ IsGroup ], [ IsFinite ], 0 );


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
  G := DerivedSeriesOfGroup(G);
  G := G[Length(G)];
  SetIsPerfectGroup(G, true);
  return G;
end);

InstallMethod(PerfectResiduum,"for perfect groups",true,
  [IsPerfectGroup],0,
function(G)
  return G;
end);

InstallMethod(PerfectResiduum,"for solvable groups",true,
  [IsSolvableGroup],0,
function(G)
  return TrivialSubgroup(G);
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

BindGlobal("RepsPerfSimpSub",function(G,simple)
local badsizes,n,un,cl,r,i,l,u,bw,cnt,gens,go,imgs,bg,bi,emb,nu,k,j,
      D,params,might,bo;
  if IsSolvableGroup(G) then
    return [TrivialSubgroup(G)];
  elif Size(RadicalGroup(G))>1 then
    D:=LatticeViaRadical(G,IsPerfectGroup);
    D:=List(D!.conjugacyClassesSubgroups,Representative);
    if simple then
      D:=Filtered(D,IsSimpleGroup);
    else
      D:=Filtered(D,IsPerfectGroup);
    fi;
    return D;
  else
    PerfGrpLoad(0);
    badsizes := Union(PERFRec.notAvailable,PERFRec.notKnown);
    D:=G;
    D:=PerfectResiduum(D);
    n:=Size(D);
    Info(InfoLattice,1,"The perfect residuum has size ",n);

    # sizes of possible perfect subgroups
    un:=Filtered(DivisorsInt(n),i->i>1
		 # index <=4 would lead to solvable factor
		 and i<n/4);

    # if D is simple, we can limit indices further
    if IsSimpleGroup(D) then
      k:=4;
      l:=120;
      while l<n do
        k:=k+1;
	l:=l*(k+1);
      od;
      # now k is maximal such that k!<Size(D). Thus subgroups of D must have
      # index more than k
      k:=Int(n/k);
      un:=Filtered(un,i->i<=k);
    fi;
    Info(InfoLattice,1,"Searching perfect groups up to size ",Maximum(un));

    if ForAny(un,i->i>10^6) then
      Error("the perfect residuum is too large");
    fi;

    un:=Filtered(un,i->i in PERFRec.sizes);
    if Length(Intersection(badsizes,un))>0 then
      Error(
        "failed due to incomplete information in the Holt/Plesken library");
    fi;

    cl:=Filtered(ConjugacyClasses(G),i->Representative(i) in D);
    Info(InfoLattice,2,Length(cl)," classes of ",
         Length(ConjugacyClasses(G))," to consider");

    if Length(un)>0 and ValueOption(NO_PRECOMPUTED_DATA_OPTION)=true then
      Info(InfoWarning,1,
      "Using (despite option) data library of perfect groups, as the perfect\n",
      "#I  subgroups otherwise cannot be obtained!");
    elif Length(un)>0 then
      Info(InfoPerformance,2,"Using Perfect Groups Library");
    fi;

    r:=[];
    for i in un do

      l:=NumberPerfectGroups(i);
      if l>0 then
	for j in [1..l] do
	  u:=PerfectGroup(IsPermGroup,i,j);
	  Info(InfoLattice,1,"trying group ",i,",",j,": ",u);

	  # test whether there is a chance to embed
	  might:=simple=false or IsSimpleGroup(u);
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
		    gens:=List([1..Random([2..Length(SmallGeneratingSet(u))])],
		      i->Random(u));
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

InstallMethod(RepresentativesPerfectSubgroups,"using Holt/Plesken library",
  true,[IsGroup],0,G->RepsPerfSimpSub(G,false));

InstallMethod(RepresentativesSimpleSubgroups,"using Holt/Plesken library",
  true,[IsGroup],0,G->RepsPerfSimpSub(G,true));

InstallMethod(RepresentativesSimpleSubgroups,"if perfect subs are known",
  true,[IsGroup and HasRepresentativesPerfectSubgroups],0,
  G->Filtered(RepresentativesPerfectSubgroups(G),IsSimpleGroup));

#############################################################################
##
#M  MaximalSubgroupsLattice
##
InstallMethod(MaximalSubgroupsLattice,"cyclic extension",true,
  [IsLatticeSubgroupsRep],0,
function (L)
    local   maximals,          # maximals as pair <class>,<conj> (result)
            maximalsConjs,     # corresponding conjugator element inverses
            cnt,               # count for information messages
            classes,           # list of all classes
            I,                 # representative of a class
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            Jgens,             # zuppos of a conjugate of <I>
            Kgroup,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group
	    lcl,	       # length(lcasses);
	    clsz,
	    notinmax,
	    maxsz,
	    mkk,
	    ppow,
	    notperm,
	    dom,
	    orbs,
	    Iorbs,Jorbs,
            i,k,kk,r;         # loop variables

    if IsBound(L!.func) then
      Error("cannot compute maximality inclusions for partial lattice");
    fi;

    grp:=L!.group;
    if Size(grp)=1 then
      return [[]]; # trivial group
    fi;
    # relevant prime powers
    ppow:=Collected(Factors(Size(grp)));
    ppow:=Union(List(ppow,i->List([1..i[2]],j->i[1]^j)));

    # compute the lattice,fetch the classes,and representatives
    classes:=L!.conjugacyClassesSubgroups;
    lcl:=Length(classes);
    clsz:=List(classes,i->Size(Representative(i)));
    if IsPermGroup(grp) then
      notperm:=false;
      dom:=[1..LargestMovedPoint(grp)];
      orbs:=List(classes,i->Set(List(Orbits(Representative(i),dom),Set)));
      orbs:=List(orbs,i->List([1..Maximum(dom)],p->Length(First(i,j->p in j))));
    else
      notperm:=true;
    fi;

    # compute a system of generators for the cyclic sgr. of prime power size

    # initialize the maximals list
    Info(InfoLattice,1,"computing maximal relationship");
    maximals:=List(classes,c -> []);
    maximalsConjs:=List(classes,c -> []);
    maxsz:=[];
    if IsSolvableGroup(grp) then
      # maxes of grp
      maxsz[lcl]:=Set(List(MaximalSubgroupClassReps(grp),Size));
    else
      maxsz[lcl]:=fail; # don't know about group
    fi;

    # find the minimal supergroups of the whole group
    Info(InfoLattice,2,"testing class ",lcl,", size = ",
         Size(grp),", length = 1, included in 0 minimal subs");

    # loop over all classes
    for i  in [lcl-1,lcl-2..1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);
	if not notperm then
	  Iorbs:=orbs[i];
	fi;
        Info(InfoLattice,2," testing class ",i);

	if IsSolvableGroup(I) then
	  maxsz[i]:=Set(List(MaximalSubgroupClassReps(I),Size));
	else
	  maxsz[i]:=fail;
	fi;

        # compute the normalizer of <I>
        N:=StabilizerOfExternalSet(classes[i]);

	# compute the right transversal (but don't store it in the parent)
	reps:=RightTransversalOp(grp,N);

        # initialize the counter
        cnt:=0;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the generators of the conjugate
            if reps[r] = One(grp)  then
                Jgens:=SmallGeneratingSet(I);
		if not notperm then
		  Jorbs:=Iorbs;
		fi;
            else
                Jgens:=OnTuples(SmallGeneratingSet(I),reps[r]);
		if not notperm then
		  Jorbs:=Permuted(Iorbs,reps[r]);
		fi;
            fi;

            # loop over all other (larger) classes
            for k  in [i+1..lcl]  do
	      Kgroup:=Representative(classes[k]);
	      kk:=clsz[k]/clsz[i];
	      if IsInt(kk) and kk>1 and
		# maximal sizes known?
		(maxsz[k]=fail or clsz[i] in maxsz[k]) and
		(notperm or ForAll(dom,x->Jorbs[x]<=orbs[k][x])) then
                # test if the <K> is a minimal supergroup of <J>
                if  ForAll(Jgens,i->i in Kgroup) then
		  # at this point we know all maximals of k of larger order
		  notinmax:=true;
		  kk:=1;
		  while notinmax and kk<=Length(maximals[k]) do
		    mkk:=maximals[k][kk];
		    if IsInt(clsz[mkk[1]]/clsz[i]) # could be in by order
	             and ForAll(Jgens,i->i^maximalsConjs[k][kk] in
				    Representative(classes[mkk[1]])) then
                      notinmax:=false;
		    fi;
                    kk:=kk+1;
		  od;

		  if notinmax then
                    Add(maximals[k],[i,r]);
		    # rep of x-th class ^r is contained in k-th class rep,
		    # so to remove nonmax inclusions we need to test whether
		    # conjugate of putative max by r^-1 is rep of x-th
		    # class.
		    Add(maximalsConjs[k],reps[r]^-1);
                    cnt:=cnt + 1;
		  fi;
                fi;
	      fi;

            od;
        od;

        Unbind(reps);
        # inform about the count
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

    if IsBound(L!.func) then
      Error("cannot compute maximality inclusions for partial lattice");
    fi;

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
        Ielms:=AsSSortedListNonstored(I);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=StabilizerOfExternalSet(classes[i]);

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
#F  NormalSubgroupsCalc(<G>[,<onlysimple>]) normal subs for pc or perm groups
##
NormalSubgroupsCalc := function (arg)
local G,	# group
      onlysimple,  # determine only subgroups with simple composition factors
      nt,nnt,	# normal subgroups
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
      comp,
      firsts,
      still,
      ab,
      idx,
      opr,
      zim,
      mat,
      eig,
      qhom,affm,vsb,
      T,S,C,A,ji,orb,orbi,cllen,r,o,c,inv,cnt,
      ii,i,j,k;	# loop

  G:=arg[1];
  onlysimple:=false;
  if Length(arg)>1 and arg[2]=true then
    onlysimple:=true;
  fi;
  if IsElementaryAbelian(G) then
    # we need to do this separately as the inductive process misses its
    # start if the chies series has only one step
    return InvariantSubgroupsElementaryAbelianGroup(G,[]);
  fi;

  #cs:=ChiefSeriesTF(G);
  cs:=ChiefSeries(G);
  G!.lattfpres:=IsomorphismFpGroupByChiefSeriesFactor(G,"x",G);
  nt:=[G];


  for i in [2..Length(cs)] do
    still:=i<Length(cs);
    # we assume that nt contains all normal subgroups above cs[i-1]
    # we want to lift to G/cs[i]
    M:=cs[i-1];
    N:=cs[i];
    ab:=HasAbelianFactorGroup(M,N);

    # the normal subgroups already known
    if (not onlysimple) or (not ab) then
      nnt:=ShallowCopy(nt);
    else
      nnt:=[];
    fi;
    firsts:=Length(nnt);

    Info(InfoLattice,1,i,":",Index(M,N)," ",ab);
    if ab then
      # the modulo pcgs
      mpcgs:=ModuloPcgs(M,N);

      p:=RelativeOrderOfPcElement(mpcgs,mpcgs[1]);

      for j in Filtered(nt,i->Size(i)>Size(M)) do
	# test centrality
	if ForAll(GeneratorsOfGroup(j),
	          i->ForAll(mpcgs,j->Comm(i,j) in N)) then

	  Info(InfoLattice,2,"factorsize=",Index(j,N),"/",Index(M,N));

	  # reasons not to go complements
	  if (HasAbelianFactorGroup(j,N) and
	    p^(Length(mpcgs)*LogInt(Index(j,M),p))>100)
	    then
            Info(InfoLattice,3,"Set l to fail");
	    l:=fail;  # we will compute the subgroups later
	  else

	    ocr:=rec(
		   group:=j,
		   modulePcgs:=mpcgs
		 );
            if not IsBound(j!.lattfpres) then
	      Info(InfoLattice,2,"Compute new factorfp");
	      j!.lattfpres:=IsomorphismFpGroupByChiefSeriesFactor(j,"x",M);
	    fi;
	    ocr.factorfphom:=j!.lattfpres;
	    Assert(3,KernelOfMultiplicativeGeneralMapping(ocr.factorfphom)=M);

	    # we want only normal complements. Therefore the 1-Coboundaries must
	    # be trivial. We compute these first.
	    if Dimension(OCOneCoboundaries(ocr))=0 then
	      l:=[];
	      OCOneCocycles(ocr,true);
	      if IsBound(ocr.complement) then
		if Length(BasisVectors(Basis(ocr.oneCoboundaries)))>0 then
		  Error("nontrivial coboundaries basis!");
		fi;
		vs:=ocr.oneCocycles;
		Info(InfoLattice,2,Size(vs)," cocycles");

		# get affine action on cocycles that represents conjugation
		if Size(vs)>10 then

		  if IsModuloPcgs(ocr.generators) then
		    # cohomology by pcgs -- factorfphom was not used
		    k:=PcGroupWithPcgs(ocr.generators);
		    k:=Image(IsomorphismFpGroup(k));

		    qhom:=GroupHomomorphismByImagesNC(ocr.group,k,
			    Concatenation(ocr.generators,
			      ocr.modulePcgs,
			      GeneratorsOfGroup(M)),
			    Concatenation(GeneratorsOfGroup(k),
			      List(ocr.modulePcgs,x->One(k)),
			      List(GeneratorsOfGroup(M),x->One(k)) ));

		  else 
                    # generators should correspond to factorfphom
		    # comment out as homomorphism is different
		    # Assert(1,List(ocr.generators,
		    #  x->ImagesRepresentative(ocr.factorfphom,x))
		    #  =GeneratorsOfGroup(Range(ocr.factorfphom)));

		    qhom:=GroupHomomorphismByImagesNC(ocr.group,
			    Range(ocr.factorfphom),
			    Concatenation(
			      MappingGeneratorsImages(ocr.factorfphom)[1],
			      GeneratorsOfGroup(M)),
			    Concatenation(
			      MappingGeneratorsImages(ocr.factorfphom)[2],
			      List(GeneratorsOfGroup(M),
				x->One(Range(ocr.factorfphom)))));

		  fi;
		  Assert(2,GroupHomomorphismByImages(Source(qhom),Range(qhom),
		    MappingGeneratorsImages(qhom)[1],
		    MappingGeneratorsImages(qhom)[2])<>fail);

		  opr:=function(cyc,elm)
		  local l,i,lc,lw;
		    l:=ocr.cocycleToList(cyc);
		    for i in [1..Length(l)] do
		      l[i]:=ocr.complementGens[i]*l[i];
		    od;

		    # inverse conjugation will give us words that undo the
		    # action on the factor
		    lc:=[];
		    for i in [1..Length(l)] do
		      lc[i]:=ImagesRepresentative(qhom,l[i]^(elm^-1));
		      l[i]:=l[i]^elm;
		    od;
		    # other generators for same complement, these should be
		    # nice ones.
		    lw:=List(lc,x->MappedWord(x,GeneratorsOfGroup(Range(qhom)),l));

		    lc:=List([1..Length(lc)],x->LeftQuotient(ocr.complementGens[x],lw[x]));
		    Assert(1,ForAll(lc,x->x in M));

		    return ocr.listToCocycle(lc);

		  end;
		  affm:=[];
		  vsb:=Basis(vs);
		  for k in SmallGeneratingSet(G) do
		    zim:=Coefficients(vsb,opr(Zero(vs),k));
		    mat:=List(BasisVectors(vsb),x->
	    Concatenation(Coefficients(vsb,opr(x,k))-zim,[Zero(ocr.field)]));
	            Add(mat,Concatenation(zim,[One(ocr.field)]));
		    Add(affm,mat);
		  od;

		  # ensure the action is OK
		  Assert(1,GroupHomomorphismByImages(G,Group(affm),
		    SmallGeneratingSet(G),affm)<>fail);

		  #eve:=ExtendedVectors(ocr.field^Length(vsb));
		  #ooo:=Orbits(Group(affm),eve);
		  #Info(InfoLattice,2,"orblens=",Collected(List(ooo,Length)));

		  # common eigenspaces for eigenvalue 1:
		  eig:=List(affm,x->NullspaceMat(x-x^0));
		  mat:=eig[1];
		  for k in [2..Length(eig)] do
		    mat:=SumIntersectionMat(mat,eig[k])[2];
		  od;
		  Info(InfoLattice,2,"eigenspace 1=",Length(mat));
		  # take only vectors with last entry one
		  vs:=[];
		  if Length(mat)>0 then
		    for k in AsList(VectorSpace(ocr.field,mat)) do
		      if IsOne(k[Length(k)]) then
			Add(vs,k{[1..Length(vsb)]}*vsb);
		      fi;
		    od;
		  fi;
		  Info(InfoLattice,2,"vectors=",Length(vs));
		fi;
	        

		# try to catch some solvable cases that look awful
		if Size(vs)>1000 and Length(PrimeDivisors(Index(j,N)))<=2
		  then
		  l:=fail;
		else
		  l:=[];
		  for k in vs do
		    comp:=ocr.cocycleToList(k);
		    for ii in [1..Length(comp)] do
		      comp[ii]:=ocr.complementGens[ii]*comp[ii];
		    od;
		    k:=ClosureGroup(N,comp);
		    if IsNormal(G,k) then
		      if still then
			# transfer a known presentation
			if not IsPcGroup(k) then
			  k!.lattfpres:=ComplementFactorFpHom(
			    ocr.factorfphom,l,M,N,k,ocr.generators,comp);
	    Assert(3,KernelOfMultiplicativeGeneralMapping(k!.lattfpres)=N);
			fi;
                        k!.obtain:="compl";
		      fi;
		      Add(l,k);
		    fi;
		  od;

		  Info(InfoLattice,2," -> ",Length(l)," normal complements");
		  nnt:=Concatenation(nnt,l);
	        fi;
	      fi;
	    fi;
          fi;
	  Info(InfoLattice,3,"Set l to ",l);

          if l=fail then
	    if onlysimple then
	      # all groups obtained will have a solvable factor
	      l:=[];
	    else
	      Info(InfoLattice,1,"using invariant subgroups");
	      idx:=Index(j,M);
	      # the factor is abelian, we therefore find this homomorphism
	      # quick.
	      hom:=NaturalHomomorphismByNormalSubgroup(j,N);
	      r:=Image(hom,j);
	      jg:=List(GeneratorsOfGroup(j),i->Image(hom,i));
	      # construct the automorphisms
	      auts:=List(GeneratorsOfGroup(G),
		i->GroupHomomorphismByImagesNC(r,r,jg,
		  List(GeneratorsOfGroup(j),k->Image(hom,k^i))));
	      C:=Image(hom,M);
	      C:=Group(SmallGeneratingSet(C));
	      l:=SubgroupsSolvableGroup(r,rec(
		  actions:=auts,
		  funcnorm:=r,
		  consider:=function(c,a,n,b,m)
			    local cs;
			      cs:=Size(a)/Size(n)*Size(b);
			      return IsInt(cs*Size(m)/idx)
				      and not cs>idx
				      and (Size(m)>1 
				          or Size(Intersection(C,b))=1);
			      end,
		  normal:=true));
	      Info(InfoLattice,2,"found ",Length(l)," invariant subgroups");
	      l:=Filtered(l,i->Size(i)=idx and Size(Intersection(i,C))=1);
	      l:=List(l,i->PreImage(hom,i));
	      l:=Filtered(l,i->IsNormal(G,i));
	      Info(InfoLattice,1,Length(l)," of these normal");

	      nnt:=Concatenation(nnt,l);
	    fi;
          fi;

        fi;

      od;
      
    else
      # nonabelian factor.
      if still then
	# fp isom for decomposition
	mpcgs:=IsomorphismFpGroupByChiefSeriesFactor(M,"x",N);
      fi;

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
	Info(InfoLattice,3,"New centralizing element of order ",o,
			   ", Index=",Index(S,C));

      until Index(S,C)<=cllen;

      C:=Core(G,C); #the true centralizer is the core of the involution
		    # centralizer

      if Size(C)>Size(N) then
	for j in Filtered(nt,i->Size(i)>Size(M)) do
	  j:=Intersection(C,j);
	  if Size(j)>Size(N) and not j in nnt then
	    j!.obtain:="nonab";
	    Add(nnt,j);
	  fi;
	od;
      fi;

    fi; # else nonabelian

    # the kernel itself
    N!.lattfpres:=IsomorphismFpGroupByChiefSeriesFactor(N,"x",N);
    N!.obtain:="kernel";
    Add(nnt,N);
    if onlysimple then
      c:=Length(nnt);
      nnt:=Filtered(nnt,j->Size(ClosureGroup(N,DerivedSubgroup(j)))=Size(j) );
      Info(InfoLattice,2,"removed ",c-Length(nnt)," nonperfect groups");
    fi;

    Info(InfoLattice,1,Length(nnt)-Length(nt),
          " new normal subgroups (",Length(nnt)," total)");
    nt:=nnt;

    # modify hohomorphisms
    if still then
      for i in [1..firsts] do
	l:=nt[i];
	if IsBound(l!.lattfpres) then
	  Assert(3,KernelOfMultiplicativeGeneralMapping(l!.lattfpres)=M);
	  # lift presentation
	  # note: if notabelian mpcgs is an fp hom
	  l!.lattfpres:=LiftFactorFpHom(l!.lattfpres,l,M,N,mpcgs);
	  l!.obtain:="lift";
	fi;
      od;
    fi;

  od;

  # remove partial presentation info
  for i in nt do
    Unbind(i!.lattfpres);
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
#M  Socle(<G>)
##
InstallMethod(Socle,"from normal subgroups",true,[IsGroup and IsFinite],0,
function(G)
local n,i,s;
  if Size(G)=1 then return G;fi;

  # force an IsNilpotent check
  # should have and IsSolvable check, as well,
  # but methods for solvable groups are only in CRISP
  # which aggeressively checks for solvability, anyway
  if (not HasIsNilpotentGroup(G) and IsNilpotentGroup(G)) then
    return Socle(G);
  fi;

  # deal with large EA socle factor for fitting free

  # this could be a bit shorter.
  if Size(RadicalGroup(G))=1 then
    n:=NormalSubgroups(PerfectResiduum(G));
    n:=Filtered(n,x->IsNormal(G,x));
  else
    n:=NormalSubgroups(G);
  fi;
  
  n:=Filtered(n,i->2=Number(n,j->IsSubset(i,j)));
  s:=n[1];
  for i in [2..Length(n)] do
    s:=ClosureGroup(s,n[i]);
  od;
  return s;
end);

#############################################################################
##
#M  IntermediateSubgroups(<G>,<U>)
##
# this should only be used for tiny index
InstallMethod(IntermediateSubgroups,"blocks for coset operation",
  IsIdenticalObj, [IsGroup,IsGroup],0,
function(G,U)
local rt,op,a,l,i,j,u,max,subs;
  if Length(GeneratorsOfGroup(G))>2 then
    a:=SmallGeneratingSet(G);
    if Length(a)<Length(GeneratorsOfGroup(G)) then
      G:=Subgroup(Parent(G),a);
    fi;
  fi;
  rt:=RightTransversal(G,U);
  op:=Action(G,rt,OnRight); # use the special trick for right transversals
  a:=ShallowCopy(AllBlocks(op));
  l:=Length(a);

  if l = 0 then return rec( inclusions := [ [0,1] ], subgroups := [] ); fi;

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

InstallMethod(IntermediateSubgroups,"using maximal subgroups",
  IsIdenticalObj, [IsGroup,IsGroup],
  1, # better than previous if index larger
function(G,U)
local uind,subs,incl,i,j,k,m,gens,t,c,p,conj,bas,basl,r;
  if (not IsFinite(G)) and Index(G,U)=infinity then
    TryNextMethod();
  fi;
  uind:=IndexNC(G,U);
  if uind<200 and ValueOption("usemaximals")<>true then
    TryNextMethod();
  fi;
  subs:=[G]; #subgroups so far
  conj:=[fail];
  incl:=[];
  i:=1;
  gens:=SmallGeneratingSet(U);
  while i<=Length(subs) do
    if conj[i]<>fail then
      m:=MaximalSubgroupClassReps(subs[conj[i][1]]); # fetch attribute
      m:=List(m,x->x^conj[i][2]);
    else
      # find all maximals containing U
      m:=MaximalSubgroupClassReps(subs[i]);
    fi;
    m:=Filtered(m,x->IndexNC(subs[i],U) mod IndexNC(subs[i],x)=0);
    
    if IsPermGroup(G) then
      # test orbit split
      bas:=List(Orbits(U,MovedPoints(G)),Length);
      if NrCombinations(bas)<10^6 then
        bas:=Set(List(Combinations(bas),Sum));
	m:=Filtered(m,
	  x->ForAll(List(Orbits(x,MovedPoints(G)),Length),z->z in bas));
      fi;
    fi;

    Info(InfoLattice,1,"Subgroup ",i,", Order ",Size(subs[i]),": ",Length(m),
      " maxes");
    for j in m do
      Info(InfoLattice,2,"Max index ",Index(subs[i],j));
      # maximals must be self-normalizing or normal
      if IsNormal(subs[i],j) then
	t:=ContainingConjugates(subs[i],j,U:anormalizer:=subs[i]);
      else
	t:=ContainingConjugates(subs[i],j,U:anormalizer:=j);
      fi;

      bas:=fail;
      for k in t do

	# U is contained in the conjugate k[1]
	c:=k[1];
	Assert(1,IsSubset(c,U));
	#is it U?
	if uind=IndexNC(G,c) then
	  Add(incl,[0,i]);
	else
	  # is it new?
	  p:=PositionProperty(subs,x->IndexNC(G,x)=IndexNC(G,c) and
	    ForAll(GeneratorsOfGroup(c),y->y in x));
	  if p<>fail then 
	    Add(incl,[p,i]);
	    if bas=fail then
	      bas:=PositionProperty(t,x->IsIdenticalObj(x,k));
	      basl:=p;
	    fi;
	  else
	    Add(subs,c);
	    Add(conj,fail); # default setting
	    Add(incl,[Length(subs),i]);
	    r:=fail;
	    if bas=fail then
	      bas:=PositionProperty(t,x->IsIdenticalObj(x,k));
	      basl:=Length(conj);

	      # is there conjugacy?
	      p:=PositionsProperty(subs,x->Size(x)=Size(c));
	      p:=Filtered(p,x->conj[x]=fail and x<Length(subs)); # only conj. base.
	      if Length(p)>0 then
		j:=1;
		while j<=Length(p) do
		  r:=RepresentativeAction(G,subs[p[j]],c);
		  if r<>fail then
		    # note conjugacy
		    conj[Length(conj)]:=[p[j],r];
		    j:=Length(p)+1;
		  fi;
		  j:=j+1;
		od;
	      fi;

	    else
	      r:=t[bas][2]^-1*k[2]; # conj. element
	      if conj[basl]<>fail then # base is conjugate itself
	        p:=conj[basl][1];
		r:=conj[basl][2]*r;
	      else
		p:=basl;
	      fi;
	      conj[Length(conj)]:=[p,r];
	    fi;

	  fi;
	fi;

      od;
    od;
    i:=i+1;
  od;
  # rearrange
  c:=List(subs,x->IndexNC(x,U));
  p:=Sortex(c);
  subs:=Permuted(subs,p);
  subs:=subs{[1..Length(subs)-1]}; # remove whole group
  for i in incl do
    if i[1]>0 then i[1]:=i[1]^p; fi;
    if i[2]>0 then i[2]:=i[2]^p; fi;
  od;
  Sort(incl);
  return rec(inclusions:=incl,subgroups:=subs);
end);

InstallMethod(IntermediateSubgroups,"normal case",
  IsIdenticalObj, [IsGroup,IsGroup],
  2,# better than the previous methods
function(G,N)
local hom,F,cl,cls,lcl,sub,sel,unsel,i,j,rmNonMax;
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
  rmNonMax := function(j) if j > 0 then UniteSet( unsel, sub[j] ); Perform( sub[j], rmNonMax ); fi; end;
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
	  rmNonMax(j);
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
#F  DotFileLatticeSubgroups(<L>,<file>)
##
InstallGlobalFunction(DotFileLatticeSubgroups,function(L,file)
local cls, len, sz, max, rep, z, t, i, j, k;
  cls:=ConjugacyClassesSubgroups(L);
  len:=[];
  sz:=[];
  for i in cls do
    Add(len,Size(i));
    AddSet(sz,Size(Representative(i)));
  od;

  PrintTo(file,"digraph lattice {\nsize = \"6,6\";\n");
  # sizes and arrangement
  for i in sz do
    AppendTo(file,"\"s",i,"\" [label=\"",i,"\", color=white];\n");
  od;
  sz:=Reversed(sz);
  for i in [2..Length(sz)] do
    AppendTo(file,"\"s",sz[i-1],"\"->\"s",sz[i],
      "\" [color=white,arrowhead=none];\n");
  od;

  # subgroup nodes, also acccording to size
  for i in [1..Length(cls)] do
    for j in [1..len[i]] do
      if len[i]=1 then
	AppendTo(file,"\"",i,"x",j,"\" [label=\"",i,"\", shape=box];\n");
      else
	AppendTo(file,"\"",i,"x",j,"\" [label=\"",i,"-",j,"\", shape=circle];\n");
      fi;
    od;
    AppendTo(file,"{ rank=same; \"s",Size(Representative(cls[i])),"\"");
    for j in [1..len[i]] do
      AppendTo(file," \"",i,"x",j,"\"");
    od;
    AppendTo(file,";}\n");
  od;

  max:=MaximalSubgroupsLattice(L);
  for i in [1..Length(cls)] do
    for j in max[i] do
      rep:=ClassElementLattice(cls[i],1);
      for k in [1..len[i]] do
	if k=1 then
	  z:=j[2];
	else
	  t:=cls[i]!.normalizerTransversal[k];
	  z:=ClassElementLattice(cls[j[1]],1); # force computation of transv.
	  z:=cls[j[1]]!.normalizerTransversal[j[2]]*t;
	  z:=PositionCanonical(cls[j[1]]!.normalizerTransversal,z);
	fi;
	AppendTo(file,"\"",i,"x",k,"\" -> \"",j[1],"x",z,
	         "\" [arrowhead=none];\n");
      od;
    od;
  od;
  AppendTo(file,"}\n");
end);

InstallGlobalFunction("ExtendSubgroupsOfNormal",function(G,N,Bs)
local l,mark,i,b,M,no,cnt,j,q,As,a,hom,c,p,ap,prea,prestab,new,sz,k,h;
  l:=[]; # list of subgroups
  mark:=BlistList([1..Length(Bs)],[]); # mark off conjugates
  for i in [1..Length(Bs)] do
    if not mark[i] then
      Info(InfoLattice,1,"extending ",i);
      mark[i]:=true;
      b:=Bs[i];
      Add(l,b);
      M:=Normalizer(G,b);
      b!.GNormalizer:=M;
      no:=Intersection(M,N); # normalizer in N
      if Index(G,M)>Index(N,no) then
        # there are further conjugates
	cnt:=Index(G,M)/Index(N,no)-1;
	for j in RightTransversal(G,ClosureGroup(N,M)) do
	  if cnt>0 and not IsOne(j) then
	    a:=b^j;
	    p:=First([i..Length(Bs)],x->
	      RepresentativeAction(N,a,Bs[x])<>fail);
    #if Size(b)=2 then Error("WWW");fi;
	    if p<>fail and not mark[p] then
	      # mark conjugate subgroup off as used
	      mark[p]:=true;
	      cnt:=cnt-1;
	    fi;
	  fi;
	od;
	if cnt<>0 then Info(InfoLattice,3,"cnt=",cnt);fi;
      fi;

      q:=NaturalHomomorphismByNormalSubgroup(M,no);
      As:=ConjugacyClassesSubgroups(Image(q));
      for ap in [1..Length(As)] do
	Info(InfoLattice,2,"extending ",ap," of ",Length(As));
	a:=As[ap];
	if Size(Representative(a))>1 then # no complement of trivial
	  # complement to no/b in a/b

	  prea:=PreImage(q,Representative(a));
	  prestab:=PreImage(q,Stabilizer(a));
	  hom:=NaturalHomomorphismByNormalSubgroup(prea,b);
	  if IsPermGroup(Range(hom)) and NrMovedPoints(Range(hom))>Index(prea,b)/LogInt(Index(prea,b),2)^2 then
	    hom:=hom*SmallerDegreePermutationRepresentation(Image(hom));
	    Info(InfoLattice,3,"Reducedegee!!");
	  fi;

	  #AAA:=[Image(hom),Image(hom,no)];
	  c:=ComplementClassesRepresentatives(Image(hom),Image(hom,no));
	  c:=List(c,x->PreImage(hom,x));
	  #oc:=c;
	  c:=PermPreConjtestGroups(prestab,c);
	  #c:=[[prestab,c]];
	  for j in c do
	    new:=List(SubgroupsOrbitsAndNormalizers(j[1],j[2],false),
	                   x->x.representative);
            for k in new do
	      sz:=Size(k);
	      h:=Group(SmallGeneratingSet(k));
	      SetSize(h,sz);
	      Add(l,h);
	    od;
	    Info(InfoLattice,1,"now found ",Length(l)," subgroups");
	  od;
	  #if
	  #  Length(new)<>Length(SubgroupsOrbitsAndNormalizers(prestab,oc,false))
	  #  then
          #  Error("hier");
	  #fi;

	  #fi;
	fi;
      od;

    fi;
  od;

  # finally subgroups of G/N
  #q:=NaturalHomomorphismByNormalSubgroup(G,N);
  #for a in ConjugacyClassesSubgroups(Image(q)) do
  #  if Size(Representative(a))>1 then # no complement of trivial
  #    Add(l,PreImage(q,Representative(a)));
  #  fi;
  #od;
  return l;

end);


InstallGlobalFunction("SubdirectSubgroups",function(D)
local fgi,inducedfactorautos,projs,psubs,info,n,l,nl,proj,emb,u,pos,
      subs,s,t,i,j,k,myid,myfgi,iso,dc,f,no,ind,g,hom,uselib;

  uselib:=ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true;
  if uselib then
    Info(InfoPerformance,2,"Using Small Groups Library");
  fi;

  fgi:=function(gp,nor)
  local idx,hom,l,f;
    idx:=Index(gp,nor);
    hom:=NaturalHomomorphismByNormalSubgroup(gp,nor);
    if idx>1000 or idx=512 or not uselib then
      l:=[idx,fail];
    else
      l:=ShallowCopy(IdGroup(gp/nor));
    fi;
    f:=Image(hom,gp);
    Add(l,hom);
    Add(l,f);
    Add(l,AutomorphismGroup(f));
    return l;
  end;

  inducedfactorautos:=function(n,f,hom)
  local gens,auts,aut,i;
    gens:=GeneratorsOfGroup(f);
    auts:=[];
    for i in GeneratorsOfGroup(n) do
      aut:=GroupHomomorphismByImages(f,f,gens,List(gens,x->
	    Image(hom,PreImagesRepresentative(hom,x)^i)));
      SetIsBijective(aut,true);
      Add(auts,aut);
    od;
    return auts;
  end;

  projs:=[];
  psubs:=[];
  info:=DirectProductInfo(D);
  n:=Length(info.groups);
  # previous embedding is all trivial
  l:=[[TrivialSubgroup(D),D]];
  for i in [1..n] do
    proj:=Projection(D,i);
    emb:=Embedding(D,i);

    u:=info.groups[i];
    pos:=Position(projs,u);
    if pos=fail then
      subs:=[];
      for j in ConjugacyClassesSubgroups(u) do
	s:=[Representative(j),Stabilizer(j)];
	no:=SubgroupsOrbitsAndNormalizers(s[2],NormalSubgroups(s[1]),false);
	nl:=[];
	for k in no do
	  myfgi:=fgi(s[1],k.representative);
	  Add(myfgi,Subgroup(myfgi[5],
	     inducedfactorautos(k.normalizer,myfgi[4],myfgi[3])));
	     Add(nl,Concatenation([k.representative,k.normalizer],myfgi));
	od;
        Add(s,nl);
        Add(subs,s);
      od;
      Add(projs,u);
      Add(psubs,subs);
      pos:=Length(projs);
    else
      subs:=psubs[pos];
    fi;

    if i=1 then
      l:=[];
      for j in subs do
	g:=Image(emb,j[1]);
	Add(l,[g,Normalizer(D,g)]);
      od;
    else # i>1. Proper subdirect products
      nl:=[];
      for j in l do
	no:=NormalSubgroups(j[1]);
	no:=SubgroupsOrbitsAndNormalizers(j[2],no,false);
  #Print("Try",j," ",Length(no),"\n");
	for k in no do
	  hom:=NaturalHomomorphismByNormalSubgroup(j[1],k.representative);
	  f:=Image(hom);
	  if Size(f)<1000 and Size(f)<>512 and uselib then
	    myid:=ShallowCopy(IdGroup(f));
	  else
	    myid:=[Size(f),fail];
	  fi;
	  for s in subs do
	    for t in s[3] do # look over normals of subgroup
      #Print(t,"\n");
	      if t{[3,4]}=myid then
		if false and myid=[1,1] then
		  #Print("direct\n");
		  g:=Subgroup(D,Concatenation(GeneratorsOfGroup(j[1]),List(GeneratorsOfGroup(s[1]),x->Image(emb,x))));
		  Add(nl,[g,Normalizer(D,g)]);
		else
		  iso:=IsomorphismGroups(f,t[6]);
		  if iso<>fail then
		    #Found isomorphic factor groups
		    iso:=hom*iso;
		    ind:=Subgroup(t[7],inducedfactorautos(k.normalizer,t[6],iso));
		    for dc in DoubleCosetRepsAndSizes(t[7],ind,t[8]) do
		      # form the subdirect product
		      g:=List(GeneratorsOfGroup(j[1]),
			    x->x*Image(emb,PreImagesRepresentative(t[5],
			      Image(dc[1],Image(iso,x))) ));
		      Append(g,List(GeneratorsOfGroup(t[1]),x->Image(emb,x)));
		      g:=Subgroup(D,g);
if Size(g)<>Size(j[1])*Size(s[1])/Size(f) then Error("sudi\n");fi;
		      Add(nl,[g,Normalizer(D,g)]);
		    od;
		  fi;

		fi;
	      fi;
	    od;
	  od;
	od;
      od;

      l:=nl;
    fi;



    Info(InfoLattice,1,"subdirect level ",i," got ",Length(l));
  od;
  return l;

end);

InstallGlobalFunction("SubgroupsTrivialFitting",function(G)
  local s,a,n,fac,iso,types,t,p,i,map,go,gold,nf,tom,sub,len;

  n:=DirectFactorsFittingFreeSocle(G);

  # is it almost simple and stored?
  if Length(n)=1 then
    tom:=TomDataAlmostSimpleRecognition(G);
    if tom<>fail and
	ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
      Info(InfoPerformance,2,"Using Table of Marks Library");
      go:=ImagesSource(tom[1]);
      tom:=tom[2];
      Info(InfoLattice,1, "Fetching subgroups of simple ",
	  Identifier(tom)," from table of marks");
      len:=LengthsTom(tom);
      sub:=List([1..Length(len)],x->RepresentativeTom(tom,x));
      return sub;
    fi;
  fi;

  s:=Socle(G);

  a:=TrivialSubgroup(G);
  fac:=[];
  nf:=[];
  types:=[];
  gold:=[];
  iso:=[];
  for i in n do
    if not IsSubgroup(a,i) then
      a:=ClosureGroup(a,i);
      if not IsSimpleGroup(i) then
	TryNextMethod();
      fi;
      t:=ClassicalIsomorphismTypeFiniteSimpleGroup(i);
      p:=Position(types,t);
      if p=fail then
	Add(types,t);

	# fetch subgroup data from tom library, if possible
	tom:=TomDataAlmostSimpleRecognition(i);
	if tom<>fail then
	  go:=ImagesSource(tom[1]);
	  tom:=tom[2];
	  if tom<>fail and
	   ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
	    Info(InfoPerformance,2,"Using Table of Marks Library");
	    Info(InfoLattice,1, "Fetching subgroups of simple ",
	      Identifier(tom)," from table of marks");
	    len:=LengthsTom(tom);
	    sub:=List([1..Length(len)],x->RepresentativeTom(tom,x));
	    sub:=List(sub,x->ConjugacyClassSubgroups(go,x));
	    SetConjugacyClassesSubgroups(go,sub);
	  fi;
	fi;

	if tom=fail then
	  go:=SimpleGroup(t);
	fi;
	Add(gold,go);


	p:=Length(types);
      fi;
      Add(iso,IsomorphismGroups(i,gold[p]));
      Add(fac,gold[p]);
      Add(nf,i);
    fi;
  od;

  if a<>s then
    TryNextMethod();
  fi;

  Info(InfoLattice,1,"socle index ",Index(G,s)," has ",
       Length(fac)," factors from ",Length(types)," types");

  if Length(fac)=1 then
    map:=iso[1];
    a:=ConjugacyClassesSubgroups(gold[1]);
    a:=List(a,x->PreImage(map,Representative(x)));
  else
    n:=DirectProduct(fac);

    # map to direct product
    a:=[];
    map:=[];
    for i in [1..Length(fac)] do
      Append(a,GeneratorsOfGroup(nf[i]));
      Append(map,List(GeneratorsOfGroup(nf[i]),
	x->Image(Embedding(n,i),Image(iso[i],x))));
    od;
    map:=GroupHomomorphismByImages(s,n,a,map);

    a:=SubdirectSubgroups(n);
    a:=List(a,x->PreImage(map,x[1]));
  fi;
  Info(InfoLattice,1,"socle has ",Length(a)," classes of subgroups");
  s:=ExtendSubgroupsOfNormal(G,s,a);
  Info(InfoLattice,1,"Overall ",Length(s)," subgroups");
  return s;
end);

## transfer of Tom Library information

InstallMethod(TomDataAlmostSimpleRecognition,"alt",true,
  [IsNaturalAlternatingGroup],0,
function(G)
local dom,n,t,map;
  dom:=Set(MovedPoints(G));
  n:=Length(dom);
  if dom=[1..n] then
    map:=IdentityMapping(G);
  else
    map:=MappingPermListList(dom,[1..n]);
    map:=ConjugatorIsomorphism(G,map);
  fi;

  if IsPackageMarkedForLoading("tomlib","")<>true or
          ValueOption(NO_PRECOMPUTED_DATA_OPTION)=true then
    return fail; # no tomlib available
  fi;
  Info(InfoPerformance,2,"Using Table of Marks Library");
  t:=TableOfMarks(Concatenation("A",String(n)));
  if t=fail then
    return fail;
  fi;
  return [map,t];
end);

BindGlobal("TomExtensionNames",function(r)
local n,pool,ext,sz,lsz,t,f,i,ns;
  if IsBound(r.tomExtensions) then
    return r.tomExtensions;
  fi;
  n:=r.tomName;
  ns:=[n];
  pool:=[n];
  ext:=[];
  sz:=fail;
  for i in pool do
    t:=TableOfMarks(i);
    if t<>fail then
      # does the TOM use a different simple group name?
      if i=n and Identifier(t)<>i then
	r.tomName:=Identifier(t);
      fi;
      f:=Position(Identifier(t),'.');
      if f=fail then
	f:=Identifier(t);
      else
	f:=Identifier(t){[1..f-1]};
      fi;
      if not f in ns then
	Add(ns,f);
      fi;

      lsz:=Maximum(OrdersTom(t));
      if sz=fail then sz:=lsz;fi;
      if lsz>sz then
	Add(ext,[lsz/sz,i{[Length(n)+2..Length(i)]}]);
      fi;
      for f in FusionsTom(t) do
	if ForAny(ns,x->x=f[1]{[1..Minimum(Length(f[1]),Length(x))]})
	#f[1]{[1..Minimum(Length(f[1]),Length(n))]} in ns 
	and not f[1] in pool then
	  Add(pool,f[1]);
	fi;
      od;
    fi;
  od;
  ext:=List(ext,x->[x[1],Concatenation(r.tomName,".",x[2])]);

  # an extension A_n.2 is called S_n
  if Length(n)>1 and n[1]='A' 
    and ForAll([2..Length(n)],x->n[x] in CHARS_DIGITS) then
    Add(ext,[2,Concatenation("S",n{[2..Length(n)]})]);
  fi;

  r!.tomExtensions:=ext;
  return ext;
end);

InstallMethod(TomDataAlmostSimpleRecognition,"generic",true,
  [IsGroup],0,
function(G)
local T,t,hom,inf,nam,i,aut;
  # avoid the isomorphism test falling back
  if ValueOption("cheap")=true and IsInt(ValueOption("intersize")) and
  ValueOption("intersize")<=Size(G) then
    return fail;
  fi;

  T:=PerfectResiduum(G);
  inf:=DataAboutSimpleGroup(T);
  Info(InfoLattice,1,"Simple type: ",inf.idSimple.name);
  # missing?
  if inf=fail then return fail;fi;

  if IsPackageMarkedForLoading("tomlib","")<>true or # force tomlib load
          ValueOption(NO_PRECOMPUTED_DATA_OPTION)=true then
    return fail; # no tomlib available
  fi;
  Info(InfoPerformance,2,"Using Table of Marks Library");

  TomExtensionNames(inf); # possibly change nam
  nam:=inf.tomName;

  # simple group
  if Index(G,T)=1 then
    t:=TableOfMarks(nam);
    if t=fail or not HasUnderlyingGroup(t) then
      Info(InfoLattice,2,"Table of marks has no group");
      return fail;
    fi;
    Info(InfoLattice,3,"Trying Isomorphism");
    hom:=IsomorphismGroups(G,UnderlyingGroup(t):intersize:=Size(G));
    if hom=fail then
      Error("could not find isomorphism");
    fi;
    Info(InfoLattice,1,"Found isomorphism ",Identifier(t));
    return [hom,t];
  fi;

  #extensions (as far as tom knows)
  inf:=Filtered(TomExtensionNames(inf),i->i[1]=Index(G,T));
  for i in inf do
    t:=TableOfMarks(i[2]);
    if t<>fail and HasUnderlyingGroup(t) then
      Info(InfoLattice,3,"Trying Isomorphism");
      hom:=IsomorphismGroups(G,UnderlyingGroup(t):intersize:=Size(G));
      if hom<>fail then
	Info(InfoLattice,1,"Found isomorphism ",Identifier(t));
	return [hom,t];
      fi;
      Info(InfoLattice,2,Identifier(t)," not isomorphic");
    fi;
  od;
  Info(InfoLattice,1,"Recognition failed");
  return fail;
end);

InstallGlobalFunction(TomDataMaxesAlmostSimple,function(G)
local recog,m;
  recog:=TomDataAlmostSimpleRecognition(G);
  if recog=fail then
    return fail;
  fi;
  m:=List(MaximalSubgroupsTom(recog[2])[1],i->RepresentativeTom(recog[2],i));
  Info(InfoLattice,1,"Recognition found ",Length(m)," classes");
  m:=List(m,i->PreImage(recog[1],i));
  return m;
end);

InstallGlobalFunction(TomDataSubgroupsAlmostSimple,function(G)
local recog,m,len;
  recog:=TomDataAlmostSimpleRecognition(G);
  if recog=fail then
    return fail;
  fi;
  len:=LengthsTom(recog[2]);
  m:=List([1..Length(len)],i->RepresentativeTom(recog[2],i));
  Info(InfoLattice,1,"Recognition found ",Length(m)," classes");
  m:=List(m,i->PreImage(recog[1],i));
  return m;
end);

InstallMethod(LowIndexSubgroups,"finite groups, using iterated maximals",
  true,[IsGroup and IsFinite,IsPosInt],0,
function(G,n)
local m,all,m2;
  m:=[G];
  all:=[G];
  while Length(m)>0 do
    m2:=Concatenation(List(m,MaximalSubgroupClassReps));
    m2:=Unique(Filtered(m2,x->Index(G,x)<=n));
    m2:=List(SubgroupsOrbitsAndNormalizers(G,m2,false),x->x.representative);
    m2:=Filtered(m2,x->ForAll(all,y->RepresentativeAction(G,x,y)=fail));
    Append(all,m2);
    m:=Filtered(m2,x->Index(G,x)<=n/2); # otherwise subgroups will have too large index
  od;
  return all;
end);

#############################################################################
##
#F  LowLayerSubgroups( [<act>,] <G>, <lim> [,<cond> [,<dosub>]] )
##
InstallGlobalFunction(LowLayerSubgroups,function(arg)
local act,offset,G,lim,cond,dosub,all,m,i,j,new,old;
  act:=arg[1];
  if IsGroup(act) and IsGroup(arg[2]) then
    offset:=2;
  else
    offset:=1;
  fi;

  G:=arg[offset];
  lim:=arg[offset+1];
  cond:=ReturnTrue;
  dosub:=ReturnTrue;
  if Length(arg)>offset+1 then
    cond:=arg[offset+2];
    if Length(arg)>offset+2 then
      dosub:=arg[offset+3];
    fi;
  fi;

  all:=[G];
  m:=[G];
  for i in [1..lim] do
    Info(InfoLattice,1,"Layer ",i,": ",Length(m)," groups");
    new:=[];
    for j in m do
      if dosub(j) then
	m:=MaximalSubgroupClassReps(j);
	Append(new,m);
      fi;
    od;
    new:=Unique(new);
    # discard?
    j:=Length(new);
    new:=Filtered(new,cond);
    Info(InfoLattice,2,"Only ",Length(new)," subgroups of ",j);

    # conjugate?
    m:=[];
    # any conjugate before?
    for j in new do
      old:=Filtered(all,x->Size(x)=Size(j));
      if ForAll(old,x->RepresentativeAction(act,x,j)=fail) then
        Add(m,j);
      fi;
    od;
    m:=List(SubgroupsOrbitsAndNormalizers(act,m,false),x->x.representative);
    Info(InfoLattice,1,"Layer ",i,": ",Length(m)," new");
    Append(all,m);
  od;
  return all;
end);

#############################################################################
##
#F  ContainedConjugates( <G>, <A>, <B> )
##
InstallMethod(ContainedConjugates,"finite groups",IsFamFamFam,[IsGroup,IsGroup,IsGroup],0,
function(G,A,B)
local l,N,dc,gens,i;
  if not IsFinite(G) and IsFinite(A) and IsFinite(B) then
     TryNextMethod();
  fi;
  if not IsSubset(G,A) and IsSubset(G,B) then
    Error("A and B must be subgroups of G");
  fi;
  if Size(A) mod Size(B)<>0 then
    return []; # cannot be contained by order
  fi;

  l:=[];
  N:=Normalizer(G,B);
  if Index(G,N)<50000 then
    dc:=DoubleCosetRepsAndSizes(G,N,A);
    gens:=SmallGeneratingSet(B);
    for i in dc do
      if ForAll(gens,x->x^i[1] in A) then
        Add(l,[B^i[1],i[1]]);
      fi;
    od;
    return l;
  else
    l:=DoConjugateInto(G,A,B,false);
    return List(l,x->[B^x,x]);
  fi;
end);

#############################################################################
##
#F  ContainingConjugates( <G>, <A>, <B> )
##
InstallMethod(ContainingConjugates,"finite groups",IsFamFamFam,[IsGroup,IsGroup,IsGroup],0,
function(G,A,B)
local l,N,t,gens,i,c,o,rep,r,sub,gen;
  if not IsFinite(G) and IsFinite(A) and IsFinite(B) then
     TryNextMethod();
  fi;
  if not IsSubset(G,A) and IsSubset(G,B) then
    Error("A and B must be subgroups of G");
  fi;
  if Size(A) mod Size(B)<>0 then
    return []; # cannot be contained by order
  fi;

  l:=[];
  N:=ValueOption("anormalizer");
  if N=fail then
    N:=Normalizer(G,A);
  fi;
  if Index(G,N)<50000 then
    t:=RightTransversal(G,N);
    gens:=SmallGeneratingSet(B);
    for i in t do
      if ForAll(gens,x->i*x/i in A) then
        Add(l,[A^i,i]);
      fi;
    od;
    return l;
  else
    r:=DoConjugateInto(G,A,B,false);
    N:=Normalizer(G,B);
    for i in r do
      rep:=Inverse(i);
      c:=A^rep;
      Add(l,[c,rep]);
      # N-orbit
      o:=[c];
      t:=[rep];
      sub:=1;
      while sub<=Length(o) do
        for gen in SmallGeneratingSet(N) do
	  c:=o[sub]^gen;
	  if not c in o then
	    Add(o,c);
	    Add(t,t[sub]*gen);
	    Add(l,[c,t[sub]*gen]);
	  fi;
	od;
	sub:=sub+1;
      od;
    od;
    return l;
  fi;
end);

InstallMethod(MinimalFaithfulPermutationDegree,"use lattice",true,
  [IsGroup and IsFinite],0,
function(G)
local c,n,deg,ind,core,i,j,sum;
  if Size(G)=1 then
    # option allows to calculate actual representation -- maybe access under
    # different name
    if ValueOption("representation")<>true then
      return 1;
    else
      return GroupHomomorphismByImages(G,Group(()),[One(G)],[()]);
    fi;
  fi;
  c:=ConjugacyClassesSubgroups(G);
  # sort by reversed order to get core by inclusion test
  c:=ShallowCopy(c); # allow sorting
  SortBy(c,x->-Size(Representative(x))); 
  n:=Filtered(c,x->Size(x)=1); # normals
  n:=List(n,Representative); 
  c:=List(c,Representative); # reps of classes


  deg:=List(n,x->[IndexNC(G,x),[Position(c,x)]]); # best known degrees for
    # factors of each of n and how.

  # determine minimal degrees by descending through lattice
  for i in [2..Length(c)-1] do # exclude trivial subgroup and whole group
    ind:=IndexNC(G,c[i]);

    if ind<deg[Length(n)][1] then # otherwise degree too big for new optimal
      core:=First([2..Length(n)],x->IsSubset(c[i],n[x])); # position of core
      if ind<deg[core][1] then # new smaller degree from subgroups
        deg[core]:=[ind,[i]];
      fi;
    elif IsNormal(G,c[i]) then # subgroup normal, must be in other case
      core:=Position(n,c[i]);
      for j in [2..core-1] do # Intersect with all prior normals
        sum:=deg[core][1]+deg[j][1];
        if sum<deg[Length(n)][1] then # otherwise too big for new optimal
          ind:=Position(n,Intersection(n[j],n[core])); # intersect of normals
          if sum<deg[ind][1] then # intersection is better
            deg[ind]:=[deg[core][1]+deg[j][1],Union(deg[core][2],deg[j][2])];
          fi;
        fi;
      od;
    fi;

  od;

  if ValueOption("representation")<>true then
    return deg[Length(n)][1]; # smallest degree
  fi;
  # calculate the representation
  deg:=deg[Length(n)][2]; # the subgroups needed
  deg:=List(deg,x->FactorCosetAction(G,c[x]));

  sum:=List(GeneratorsOfGroup(G),x->Image(deg[1],x));
  for i in [2..Length(deg)] do
    sum:=SubdirectDiagonalPerms(sum,List(GeneratorsOfGroup(G),
      x->Image(deg[i],x)));
  od;

  ind:=Group(sum); SetSize(ind,Size(G));

  return GroupHomomorphismByImages(G,ind,GeneratorsOfGroup(G),sum);

end);

