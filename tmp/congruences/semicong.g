#############################################################################
##
#W  semicong.g                  														Andrew Solomon
##
#H  @(#)$Id: semicong.g,v 1.15 2000/01/13 13:12:29 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains routines for computing the congruences of
##  a finite semigroup.
##
##
##
Revision.semicong_g :=
    "@(#)$Id: semicong.g,v 1.15 2000/01/13 13:12:29 gap Exp $";


RequirePackage("transemi");
Read("posets.g");

###########################################################################
##
##  Some declarations
##
DeclareGlobalFunction( "MinimalCongruencesSWITCH" );
DeclareGlobalFunction( "AllCongruencesSWITCH" );
DeclareGlobalFunction( "JoinCongruencesSWITCH" );
GREEN_TIME := 0;


###########################################################################
##
#O  EquivalenceIsFiner(<e>, <f>)
##
##  Returns true iff <e> is *finer* than <f> 
##  i.e every block of <e> is contained in a block of <f>.
##
EquivalenceIsFiner := 
function( e, f )

	local ep, fp, b;

	# a quick check not requiring closure (note: IsSubset(super, sub))
	if IsSubset(List(GeneratingPairsOfMagmaCongruence(f), x->AsSSortedList(x)),
			List(GeneratingPairsOfMagmaCongruence(e), x->AsSSortedList(x))) then
		# Print("used new test\n");
		return true;
	fi;

	ep := EquivalenceRelationPartition(e);
	fp := EquivalenceRelationPartition(f);
	for b in ep do
		# try to find a block of fp of which b is a subset
		if First(fp, x->IsSubset(x, b)) = fail then
			return false;
		fi;
	od;
	return true;
end ;

######################################################################
##
##
#F  AddSetOfMinimalEquivalences( <congset>, <cong> )
##
##  If <cong> is coarser than some congruence in <congset>, do nothing.
##  Otherwise, <congset> = <congset> - T \union <cong>, where
##  T is the set of all congruences in <congset> which are coarser than
##  <cong>.
##
######################################################################
AddSetOfMinimalEquivalences :=  
function(MinCongs, C)
	AddMinSet(MinCongs, C, EquivalenceIsFiner);
end;

######################################################################
##
#F  GreensRelationsPrecomputation(<s>)
##
##  Precomputes information about Green's relations on
##  <s> and stores it to minimize recomputation.
##
##  Things our algorithms require:
##  * list of J classes in topologically sorted order
##  * knowledge of which J-classes are idempotent free
##  * covers and undercovers as sets of indices into list of J classes
##
GreensRelationsPrecomputation := 
function(s)
	# p is GreensJClasses(s)
	# [x,y] in relations[1]  if p[x] <= p[y]
	s!.relations := PosetRelations(GreensJClasses(s), IsGreensLessThanOrEqual);

	# p[linearorder[1],..., p[linearorder[n]] is a topological sort of p
	s!.linearorder := PosetLinearOrder(s!.relations[1]);


	# if i is in covers[j] then p[i] covers p[j]
	s!.covers := PosetRelationCovers(s!.relations[1]);
	s!.undercovers := PosetRelationUnderCovers(s!.relations[1]);

	s!.idempotentfree := List(GreensJClasses(s), IsRegularDClass);
end;




######################################################################
##
##
#F  MinimalCongruencesOfSemigroupNaive( <s> )
##
##  Determines the set of all minimal congruences of <s> by the
##  following algorithm:
##  For each pair of elements, generate its congruence and then
##  add the congruence to the set of minimal equivalences.
##
######################################################################
MinimalCongruencesOfSemigroupNaive := 
function(s)
	local l, i, j, c, mincongs;

	mincongs := Set([]);

	l := AsList(s);
	for i in [1 .. Length(l) - 1] do
		for  j in [i + 1 .. Length(l)] do
			c := SemigroupCongruenceByGeneratingPairs(s, [[l[i], l[j]]]);
			AddSetOfMinimalEquivalences(mincongs, c);
		od;
	od;
	return mincongs;
end;
			


######################################################################
##
##
#F  Class3Congruences( <S> )
##
##  See Grillet Chapter V, Theorem 2.6:
##  Class 3 minimal congruences are disjoint from $\cal H$. 
##  If (x,y) are related, then they are both contained in 
##  J u K where K covers J in the poset of J-classes and
##  they are not both in J.
##   
##  Note: we don't check disjointness with H on the grounds that it
##  is expensive.
##
######################################################################
Class3Congruences := 
function(s)
	local
		class3congs, # what we're trying to compute
		dcl, # the D-classes, topologically sorted
		covers, # covers[i] is the set of indices into dcl of the 
						# covers if dcl[i]
		i,j,k, # indices
		a, b, # elements of J and K resp.
		t, # time
		c; # a congruence.

	class3congs := [];
	t := Runtime();
	dcl := ShallowCopy(GreensJClasses(s));

	# construct the information about covers in s/J
	# covers[i] will be the indices of the J classes 
	# which cover i
	covers := PosetCovers(dcl, IsGreensLessThanOrEqual);
	GREEN_TIME := GREEN_TIME + (Runtime() - t);

	# possible congruences are generated by (a,b) a \in J and b \in K
	# such that no two related elements are both in J
	for j in [1 .. Length(dcl)] do
		for k in covers[j] do
			for a in dcl[j] do
				for b in dcl[k] do
					c := SemigroupCongruenceByGeneratingPairs(s, [[a,b]]);
					if (First(EquivalenceRelationPartition(c), 
							x->Length(Intersection(x, dcl[j]))>1) = fail) 
							and not IsEmpty(EquivalenceRelationPartition(c)) then

						AddSetOfMinimalEquivalences(class3congs, c);
					fi;
				od;
			od;
		od;
	od;
	return class3congs;
end;
						
	
			

	

######################################################################
##
##
#F  Class4Congruences( <S> )
##
##  See Grillet Chapter V, Theorem 2.6:
##  Class 4 minimal congruences are disjoint from $\cal H$. 
##  If (x,y) are related, then wlog, x in J and y in K,
##  J and K contain no idempotents and cover exactly the 
##  same elements in s/J, furthermore the congruence dictates a 
##  bijection between J and K.
##   
##  Note: we don't check disjointness with H on the grounds that it
##  is expensive.
##
######################################################################
Class4Congruences := 
function(s)
	local
		class4congs, # what we're trying to compute
		dcl, # the D-classes of s
		undercovers, # undercovers[i] is the set of D-classes which dcl[i] covers
		i, j, k, # indexing 
		juk, # the elements of Dclasses J and K
		ifree, # idempotent free D-classes
		a, b, #elements
		t, # time;
		c; # a congruence

	class4congs := [];
	t := Runtime();
	dcl := ShallowCopy(GreensJClasses(s));
	

	# construct the `undercovers' of s/J
	# undercovers[i] will be the indices of the J classes 
	# which *are covered by* i
	undercovers := PosetUnderCovers(dcl, IsGreensLessThanOrEqual);

	# find the indices of the idempotent-free J-classes
	ifree := Filtered([1 .. Length(dcl)], x->First(dcl[x], y->y^2=y) = fail);
	GREEN_TIME := GREEN_TIME + (Runtime() - t);

	for j in [1 .. Length(ifree)-1] do
		# get every other idempotent free D-class with the same undercovers
		for k in [j+1 .. Length(ifree)] do
			if undercovers[ifree[j]] = undercovers[ifree[k]] then
				# ... and create congruences from pairs (a,b), a in J, b in K
				for a in dcl[ifree[j]] do
					for b in dcl[ifree[k]] do
						c := SemigroupCongruenceByGeneratingPairs(s, [[a,b]]);

						juk := Concatenation(AsList(dcl[ifree[j]]),
											AsList(dcl[ifree[k]]));
						# check that it is a bijection:
						if First(EquivalenceRelationPartition(c),x->Length(x)>2)=fail 
							# also check that it only involves J and K.
							and IsSubset(juk, Concatenation(EquivalenceRelationPartition(c))) then
								
								AddSetOfMinimalEquivalences(class4congs, c);
						fi;
					od;
				od;
			fi;
		od;
	od;

	return class4congs;
end;
			




######################################################################
##
#F  Class1_2Congruences_loopcheck( <S> )
##
##  See Grillet Chapter V, Theorem 2.6:
##
##  Class 1 minimal congruences are contained in $\cal H$, and 
##  there is a unique $\cal J$-class J which contains all elements
##  in nontrivial congruence classes.
##
##  Class 2 minimal congruences are disjoint from $\cal H$, and 
##  there is a unique $\cal J$-class J which contains all elements
##  in nontrivial congruence classes.
##
##  H-class computation tends to be very expensive, so we simply
##  generate all congruences <(a,b)> with a,b in a single D-class
##  and throw away the ones which cause collapse
##  in other D-classes.
##
##  One might possibly do the check that the congruence doesn't interfere
##  with other D-classes within the closure loop.
##
######################################################################
Class1_2Congruences_loopcheck := 
function(s)
	local
		class1_2congs, # what we're trying to calculate
		invalid,
		dcl,  # the D-Classes of s
		d, # a d-class
		dels, # an H class
		i, j, # index into eh
		t,	# time
		c; # semigroup congruence

	t := Runtime();
	class1_2congs := [];
	dcl := GreensJClasses(s);
	GREEN_TIME := GREEN_TIME + (Runtime() - t);

	for d in dcl do
		dels := AsList(d);
		################
    invalid :=
      function(c, f)
        # f is the set of blocks calculated so far (might not be closed)
        # returns true if c is an invalid Class 1 or 2 congruence.

        local b; # (a part of) a block of the congruence


        # 1. c is invalid if there are nontrivial blocks not contained in d
				if not IsSubset(dels, Concatenation(f)) then
            return true;
        fi;

        return false; # c is not known to be invalid
      end;
    ################

		for i in [1 .. Length(dels) -1] do
			for j in [i .. Length(dels)] do
				c := SemigroupCongruenceByGeneratingPairs(s, [[dels[i], dels[j]]]);

        # now close c, making sure it obeys the criteria of Class 1 and 2:
        MagmaCongruencePartition(c, invalid);


				# check that it is contained in the present D-class, 
				# and that it isn't trivial
        if not (# invalid
            ((HasPartialClosureOfCongruence(c) and
              invalid(c, PartialClosureOfCongruence(c))))
            or  # trivial
              IsEmpty(EquivalenceRelationPartition(c))) then

					AddSetOfMinimalEquivalences(class1_2congs, c);
				fi;
			od;
		od;
	od; # loop over D-classes
	return class1_2congs;
end;				

######################################################################
##
##
#F  MinimalCongruencesOfSemigroup( <S> )
##
##  See Grillet Chapter V, Theorem 2.6:
##  Umbrella function collecting together congruences of
##  classes 1-4. This includes all minimal congruences.
##
##  Non minimal congruences are filtered out and precisely
##  the minimal congruences are returned.
##
######################################################################
MinimalCongruencesOfSemigroup := 
function(s)
	local
		c, # array of class-i congruences
		i, # indexes type of congruences
		ac, # all minimal conruences
		t, # time
		cong; # a congruence



	
	c := [];

	t := Runtime();
	c[1] := Class1_2Congruences_loopcheck(s);
	# # Print(" Computed Class 1 and 2 Congruences in ", Runtime() - t, " ms.\n");


	t := Runtime();
	c[2] := Class3Congruences(s);
	# Print(" Computed Class 3 Congruences in ", Runtime() - t, " ms.\n");

	t := Runtime();
	c[3] := Class4Congruences(s);
	# Print(" Computed Class 4 Congruences in ", Runtime() - t, " ms.\n");

	t := Runtime();
	ac := ShallowCopy(c[1]);
	for i in [2 ..3] do
		for  cong in c[i] do
			AddSetOfMinimalEquivalences(ac, cong);
		od;
	od;
	# Print("Merged Congruences in ", Runtime() - t, " ms.\n");

	return ac;
end;



######################################################################
##
#F  CongruencesAbove( <c> )
##
##  Finds the congruences which cover <c> in the congruence lattice
##  of <Source(c)>.
##
######################################################################
CongruencesAbove := 
function(c)
	local
		h, # the quotient map relative to c
		m, # the minimal congruences of Source(c)/c
		abovelist, # the list of congruences covering c in Source(c)
		i,
		a,b; # elements of Source(c)

	h := HomomorphismQuotientSemigroup(c);
	m := MinimalCongruencesSWITCH(Range(h));


	abovelist := [];
	for i in [1 .. Length(m)] do
		a := Representative(GeneratingPairsOfMagmaCongruence(m[i])[1][1]);
		b := Representative(GeneratingPairsOfMagmaCongruence(m[i])[1][2]);

		Append(abovelist, [SemigroupCongruenceByGeneratingPairs(Source(c), 
			Concatenation(GeneratingPairsOfMagmaCongruence(c),[[a,b]]))]);
	od;

	return abovelist;
end;



######################################################################
##
#F  AllCongruences( <s> )
##
##  Finds all congruences on a semigroup <s> using the Pullback method
##
######################################################################
AllCongruences :=
function(s)
	local
		done, # we have found the covers of congruences in clist[1 .. done]
		x, # a congruence
		above, # the congruences above
		clist; # list of congruences


	done := 0;
	clist := MinimalCongruencesSWITCH(s);

	while done < Length(clist) do
		above := CongruencesAbove(clist[done+1]);
		for x in above do
			if not x in clist then
				Append(clist, [x]);
			fi;
		od;
		done := done + 1;
	od;

	return clist;
end;

######################################################################
##
##
#F  AllCongruencesNaive( <s> )
##
##  Finds all congruences on a semigroup <s> using joins 
##  from principal congruences.
##  Tested on c4 reveals an error with the method above
##
######################################################################
AllCongruencesNaive := 
function(s)
	local
		allcongs, # all congruences - what we're calculating
		slist,		# list of all elements of s
		i, j,			# indices
		c,				# congruence
		pairs2check,	# indices of pairs of congruences we are joining
		p,				# a pair of congruences
		ci;				# index of the congruence just added
		

	allcongs := [];
	slist := AsList(s);

	for i in [1 .. Length(slist) -1] do
		for j in [i + 1 .. Length(slist)] do
			c := SemigroupCongruenceByGeneratingPairs(s, [[slist[i],slist[j]]]);
			if not c in allcongs  then
				Append(allcongs, [c]);
			fi;
		od;
	od;

	pairs2check := Combinations([1.. Length(allcongs)],2);
	while Length(pairs2check) > 0 do
		p := pairs2check[Length(pairs2check)];
		pairs2check := pairs2check{[1..Length(pairs2check)-1]};
		c := JoinCongruencesSWITCH(allcongs[p[1]],allcongs[p[2]]);

		if not c in allcongs then
			Append(allcongs, [c]);
			ci := Length(allcongs);
			for i in [1 .. ci-1] do
				Append(pairs2check, [[i, ci]]);
			od;
		fi;
	od;
	return allcongs;
end;
		

#######################################
##
##  Switchable functions
##
#####################################
## Defaults
MINIMAL_RHODES := true;
ALLCONG_PULLBACK := true;
JOIN_MORSE := true;
GREEN_TIME := 0;
CONGRUENCE_CLOSURES := 0;


InstallGlobalFunction(MinimalCongruencesSWITCH,
function(s)
	if MINIMAL_RHODES then
		 return MinimalCongruencesOfSemigroup(s);
	else
		return MinimalCongruencesOfSemigroupNaive(s);
	fi;
end);

InstallGlobalFunction(AllCongruencesSWITCH,
function(s)
	if ALLCONG_PULLBACK then
		 return AllCongruences(s);
	else
		return AllCongruencesNaive(s);
	fi;
end);

InstallGlobalFunction(JoinCongruencesSWITCH,
function(c1, c2)
	if JOIN_MORSE then
		return JoinSemigroupCongruences(c1,c2);
	else
		return SemigroupCongruenceByGeneratingPairs(Source(c1), 
			Concatenation(GeneratingPairsOfMagmaCongruence(c1),
			GeneratingPairsOfMagmaCongruence(c2)));
	fi;
end);

Test := 
function(s, sname)
	local t, min, all, tottime;

	Print("Calculating minimal congruences and all congruences on ",sname,":\n");

	Print("MINIMAL :");
	if MINIMAL_RHODES then
		Print("RHODES \n");
	else
		Print("NAIVE \n");
	fi;


	Print("ALL CONGRUENCES : ");
	if ALLCONG_PULLBACK  then
		Print("PULLBACK \n");
	else
		Print("NAIVE \n");
	fi;

	Print("JOINS : ");
	if JOIN_MORSE then
		Print("MORSE \n");
	else
		Print("NAIVE \n");
	fi;



	# minimal congruences
	CONGRUENCE_CLOSURES  := 0;
	GREEN_TIME := 0;
  t := Runtime();
	min := MinimalCongruencesSWITCH(s);
	tottime := Runtime() - t;
  Print("The MINIMAL congruences take ", tottime," ms\n");
  Print("Green Time = ", GREEN_TIME, " ms\n");
  Print("Net time = ", tottime - GREEN_TIME, " ms\n");
	Print("Congruence closures :",CONGRUENCE_CLOSURES);

	# all congruences
	CONGRUENCE_CLOSURES  := 0;
	GREEN_TIME := 0;
  t := Runtime();
	all := AllCongruencesSWITCH(s);
	tottime := Runtime() - t;
  Print("ALL congruences take ", tottime," ms\n");
  Print("Green Time = ", GREEN_TIME, " ms\n");
  Print("Net time = ", tottime - GREEN_TIME, " ms\n");
	Print("Congruence closures :",CONGRUENCE_CLOSURES);

	return [min, all];
end;

