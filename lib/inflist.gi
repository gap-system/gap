#############################################################################
##
#W  inflist.gi           GAP library          Andrew Solomon and Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains tempory kludges for infinite list
##	Should disapear after 4.1.
##
Revision.inflist_gi :=
    "@(#)$Id$";

######################################################################
##
#R  IsN2IteratorRep
#F  IteratorN2()
#M  IsDoneIterator( <it> )
#M  NextIterator( <it> )
##
##  Iterator for N times N.
##
DeclareRepresentation( "IsN2IteratorRep", IsComponentObjectRep,
    [ "sum", "first" ] );

InstallGlobalFunction(IteratorN2,
function()

  local iter;

  iter := rec ( sum   := 1, first := 0 );

  return Objectify( NewType (IteratorsFamily,IsN2IteratorRep and
                             IsMutable ), iter );
end);

InstallMethod( IsDoneIterator,
  "for iterator of N times N",
  true,
  [IsIterator and IsMutable and IsN2IteratorRep],0,
  # notice that this iterator is never done,
  # there is always a next pair in N times N
  it->false);

InstallMethod( NextIterator,
  "for iterator of N times N",
  true,
  [IsIterator and IsMutable and IsN2IteratorRep],0,
function(it)

  if it!.first=it!.sum-1 then
    it!.first:=1;
    it!.sum := it!.sum+1;
  else
    it!.first:=it!.first+1;
  fi;
  return [it!.first,it!.sum-it!.first];
end);

######################################################################
##
##  IN for infinite lists.
## 
##  Everything in this section is a substitute for writing a method
##  for IN of the form below for dense lists where length is hard 
##  to compute.
## 
## InstallMethod( IN,
## "for an object, and a dense list",
## true,
## [ IsObject, IsDenseList ], 0,
## function( elm, list )
## 	local
## 		i;    # index to step through the list.
## 
## 	i:= 1;
## 	while IsBound(list[i]) do
## 		if elm = list[i] then
## 			return true;
## 		fi;
##	 i:= i+1;
## 	od;
## 	return false;
## end );

InstallMethod( IN,
    "for an object and enumerator of `Integers'",
    true,
    [ IsObject, IsIntegersEnumerator], 0,
    function( n, e )
			if IsInt(n) then
				return true;
			else
				return false;
			fi;
    end );



BindGlobal("InfiniteEnumeratorIN",
function( elm, list )
	local
		i;    # index to step through the list.

	i:= 1;
	while IsBound(list[i]) do
		if elm = list[i] then
			return true;
		fi;
	 i:= i+1;
	od;
	return false;
end );

InstallMethod( IN,
    "for an object and enumerator of a semigroup right ideal",
    true,
    [ IsObject, IsRightSemigroupIdealEnumerator], 0,InfiniteEnumeratorIN);


InstallMethod( IN,
    "for an object and enumerator of a semigroup right ideal",
    true,
    [ IsObject, IsLeftSemigroupIdealEnumerator], 0,InfiniteEnumeratorIN);


InstallMethod( IN,
    "for an object and enumerator of a semigroup right ideal",
    true,
    [ IsObject, IsSemigroupIdealEnumerator], 0,InfiniteEnumeratorIN);

######################################################################
##
##  Length for possibly infinite lists.
## 
##  Everything in this section is a substitute for writing a method
##  for Length of the form below for dense lists where length is hard 
##  to compute and therefore relies on IsBound.
## 
##
##
##

BindGlobal("InfiniteEnumeratorLength",
function( e )
	local i;

	i := 1;

	while IsBound(e[i]) do
		i := i +1;
	od;

	return i-1;
end );

#############################################################################
##
#M  Length( <relenum> ) . . . . .. .  for enumerators of congruence classes
##
##  Crash code:
##
##  f:=FreeSemigroup("a","b","c");
##  x:=GeneratorsOfSemigroup(f);
##  a:=x[1];;b:=x[2];;c:=x[3];;
##  r:= [ [a*a,a],[b*b,b],[c*c,c] ];
##  s:=Abelianization(f/r);
##  x:=GeneratorsOfSemigroup(s);
##  a:=x[1];;b:=x[2];;c:=x[3];;
##  cong1 := MagmaCongruenceByGeneratingPairs(s,[[a*b,a*c]]);
##  cong2 := MagmaCongruenceByGeneratingPairs(s,[[a*b,b*c]]);
##  cong1=cong2;
##  
##  # This crashed because of the infinite domain enumerator Length->Size
##  # recursion bug
##  Enumerator(UnderlyingRelation(cong1));
##
InstallMethod( Length,
    "for enumerator of congruence classes",
    true,
    [ IsSemigroupCongruenceClassEnumerator], 0, InfiniteEnumeratorLength);

#############################################################################
##
#M  Length( <relenum> ) . . . .  .  for enumerators of greens classes
##
##
## crash code when this is removed:
##
##  f:=FreeSemigroup("a","b","c");
##  x:=GeneratorsOfSemigroup(f);
##  a:=x[1];;b:=x[2];;c:=x[3];;
##  r:= [ [a*a,a],[b*b,b],[c*c,c] ];
##  s:=Abelianization(f/r);
##  g := GreensRRelation(s);
##  cl := EquivalenceClassOfElement(g, GeneratorsOfSemigroup(s)[1]);
##  Length(Enumerator(cl));
##
##  recursion depth trap (5000)
##  at
##  return Size( UnderlyingCollection( enum ) );
##  Length( Enumerator( C ) ) called from
##  Size( UnderlyingCollection( enum ) ) called from
##  Length( Enumerator( C ) ) called from
##  Size( UnderlyingCollection( enum ) ) called from
##  Length( Enumerator( C ) ) called from
##  
InstallMethod( Length,
    "for enumerator of semigroup greens classes",
    true,
    [ IsGreensLRJClassEnumeratorRep], 0,InfiniteEnumeratorLength);

InstallMethod( Length,
    "for enumerator of semigroup greens classes",
    true,
    [ IsGreensHClassEnumeratorRep], 0,InfiniteEnumeratorLength);


InstallMethod( Length,
    "for an enumerator of a semigroup right ideal",
    true,
    [ IsRightSemigroupIdealEnumerator], 0,InfiniteEnumeratorLength);


InstallMethod( Length,
    "for an enumerator of a semigroup right ideal",
    true,
    [ IsLeftSemigroupIdealEnumerator], 0,InfiniteEnumeratorLength);


InstallMethod( Length,
    "for an enumerator of a semigroup right ideal",
    true,
    [ IsSemigroupIdealEnumerator], 0,InfiniteEnumeratorLength);

#############################################################################
##
#E  inflist.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

