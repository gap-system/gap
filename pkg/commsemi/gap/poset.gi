#############################################################################
##
#W  poset.gi           COMMSEMI library                        Isabel Araujo 
##
#H  @(#)$Id: poset.gi,v 1.1 2000/09/13 09:26:11 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.poset_gi:=
    "@(#)$Id: poset.gi,v 1.1 2000/09/13 09:26:11 gap Exp $";

#############################################################################
##
#M  LevelsOfMaximalElementsOfPoset( list, ord )
##
##  for a list and an ordering on the family of the elements of the list
##
InstallMethod(LevelsOfMaximalElementsOfPoset,
	"for a list and an ordering on the elements of the list", 
	[IsList,IsOrdering], 0, 
function( list, ord)
  local llist,i, j, maximal, newlist,thelevels,lt;
  thelevels :=[];
  llist := ShallowCopy(list);
	lt := LessThanFunction(ord);
  while not IsEmpty(llist) do

    maximal :=[];
    # look for the maximal elements of llist
    for i in [1..Length(llist)] do

      j:=1;
      while j in [1..Length(llist)] do
        if j<>i  and IsBound(llist[j]) then

          if lt(llist[i],llist[j]) then
            # this means that the i-th jclass is not maximal
            j := Length(llist)+1;
          fi;
        fi;
        j:=j+1;
      od;
      if j=Length(llist)+1 then
        # i-th el of llist is maximal (otherwise j=Length(llist)+2)
        Add(maximal,llist[i]);
      fi;

    od;
    # so now maximal contains a list of maximal els and llist
    # does not have those elements anymore

    # add the list of maximal elemensts to our levels list
    Add(thelevels,maximal);

    newlist:=[];
    # remove the entries that were maximal from llist
    for i in [1..Length(maximal)] do
      if Position(llist,maximal[i])<>fail then
        Unbind(llist[Position(llist,maximal[i])]);
      fi;
    od;
    for i in [1..Length(llist)] do
      if IsBound(llist[i]) then
        Add(newlist,llist[i]);
      fi;
    od;
    llist:=newlist;

  od;

  return thelevels;

end);

#############################################################################
##
#M  PosetArrangement( llist, ord )
##
##  for a list and an ordering on the family of the elements of the list
##
InstallMethod(PosetArrangement,
 "for a list and an ordering on the family of the elements of the list",
	true, [IsList,IsOrdering], 0,
function(list, ord)
  local lt,thelevels, relations,elsbelow,aux, i, j, k,l;

	lt := LessThanFunction(ord);
  thelevels := LevelsOfMaximalElementsOfPoset(list,ord);

	# so find out the relations between elements 
  relations:=[];

	# we look at the relations between the elements of level i and the ones
	# of levels below
	# at the same time we build a list of pairs 
  # the second component of each pair gives the hclasses below
	# the h class found in the first component of the pair
  elsbelow := [];
	
  for i in [1..Length(thelevels)-1] do
		# for each element of the i-th level
		for j in [1..Length(thelevels[i])] do
			# the list aux will contain all els below
			aux :=[];
			# check whether is is greater than each element of each level below
			for l in [i+1..Length(thelevels)] do
				for k in [1..Length(thelevels[l])] do
					if lt(thelevels[l][k],thelevels[i][j]) then
						Add(relations,[thelevels[i][j],thelevels[l][k]]);
						Add(aux,thelevels[l][k]);
					fi;
				od;
			od;
			Add(elsbelow,[thelevels[i][j],aux]);
		od;
  od;

  for i in [1..Length(thelevels)] do
    Print("level ",i,": ",thelevels[i],"\n");
  od;

  Print("Relations between levels: \n",relations,"\n");

	Print("\n");
	k := 0;
	for i in [1..Length(thelevels)-1] do
		for j in [1..Length(thelevels[i])] do
			k := k+1;
			Print(elsbelow[k][1]," is above ",elsbelow[k][2],"\n");
		od;
	od;
	Print("\n");

end);

#############################################################################
##
#M  PosetOfGreensHClassesOfCommutativeSemigroup( s )
##
##  for a commutative semigroup <S>
##
InstallMethod(PosetOfGreensHClassesOfCommutativeSemigroup,
"for a commutative fp semigroup or monoid", true,
[IsSemigroup and IsCommutative], 0,
function(s)
  local i, hclasses, fun, fam, ord, poset;

  # this only works for fp semigroups or fp monoid
  if not (IsFpMonoid(s) or IsFpSemigroup(s)) then
		TryNextMethod();
	fi;

	hclasses := GreensHClasses(s);
	
  # TODO
	# while I don't change Greens comparation to work as an ordering 
	# we have the following
	fun := function(a,b) return IsGreensLessThanOrEqual(a,b); end;
	fam := FamilyObj( hclasses[1] );

  ord := OrderingByLessThanOrEqualFunctionNC(fam,fun);

  PosetArrangement( hclasses, ord );

	Print("Greens H-classes of semigroup\n");
	for i in hclasses do
		Print(i," class: ",Elements(i),"\n");
  od;


	return ;

end);

	

	

	

