#############################################################################
##
#W  smgideal.gi              GAP library                     Robert Arthur
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains generic methods for semigroup ideals.
##
Revision.smgideal_gi :=
    "@(#)$Id$";


#############################################################################
##
##  Immediate methods for 
##
##  IsLeftSemigroupIdeal
##  IsRightSemigroupIdeal
##  IsSemigroupIdeal
##
#############################################################################
InstallImmediateMethod(IsLeftSemigroupIdeal, 
IsLeftMagmaIdeal and HasLeftActingDomain and IsAttributeStoringRep, 0,
function(I)
	return HasIsSemigroup(LeftActingDomain(I)) and 
		IsSemigroup(LeftActingDomain(I));
end);


InstallImmediateMethod(IsRightSemigroupIdeal, 
IsRightMagmaIdeal and HasRightActingDomain and IsAttributeStoringRep, 0,
function(I)
	return HasIsSemigroup(RightActingDomain(I)) and 
		IsSemigroup(RightActingDomain(I));
end);


InstallImmediateMethod(IsSemigroupIdeal, 
IsMagmaIdeal and HasActingDomain and IsAttributeStoringRep, 0,
function(I)
	return HasIsSemigroup(ActingDomain(I)) and IsSemigroup(ActingDomain(I));
end);




#############################################################################
#############################################################################
##                                                                         ##
##                   ENUMERATORS                                           ##
##                                                                         ##
#############################################################################
#############################################################################

#############################################################################
##
#F	RightSemigroupIdealEnumeratorDataGetElement( <enum>, <n> )
##
##	Returns a pair [T/F, elm], such that if <n> is less than or equal to
##	the size of the right ideal the first of the pair will be
##	true, and elm will be the element at the <n>th place.   Otherwise, the
##	first of the pair will be false.
##
BindGlobal("RightSemigroupIdealEnumeratorDataGetElement", 
function (enum, n)

	local i, ideal, new;

	ideal:= UnderlyingCollection(enum);

	if n <= Length(enum!.currentlist) then
		return [true, enum!.currentlist[n]];
	fi;

	# Starting at the first non-expanded element of the list, multiply
	# every element of the list by generators, until it is large enough
	# to give the nth element.
	while IsBound(enum!.currentlist[enum!.nextelm]) do
		for i in enum!.gens do
			new:= enum!.currentlist[enum!.nextelm] * i;
			if not new in enum!.orderedlist then
				Add(enum!.currentlist, new);
				AddSet(enum!.orderedlist, new);
			fi;
		od;
		enum!.nextelm:= enum!.nextelm+1;

		# If we have now evaluated the element in the nth place
		if n <= Length(enum!.currentlist) then
			return [true, enum!.currentlist[n]];
		fi;
	od;

	# By now we have closed the list, and found it not to contain n
	# elements.
	if not HasAsSSortedList(ideal) then
		SetAsSSortedList(ideal, enum!.orderedlist);
	fi;
	return [false, 0];
end);

#############################################################################
##
#F	LeftSemigroupIdealEnumeratorDataGetElement( <Enum>, <n> )
##
##	Returns a pair [T/F, elm], such that if <n> is less than or equal to
##	the size of the underlying left ideal the first of the pair will be
##	true, and elm will be the element at the <n>th place.   Otherwise, the
##	first of the pair will be false.
##
BindGlobal("LeftSemigroupIdealEnumeratorDataGetElement", 
function (enum, n)

	local i, ideal, new;

	ideal:= UnderlyingCollection(enum);

	if n <= Length(enum!.currentlist) then
		return [true, enum!.currentlist[n]];
	fi;

	# Starting at the first non-expanded element of the list, multiply
	# every element of the list by generators, until it is large enough
	# to give the nth element.
	while IsBound(enum!.currentlist[enum!.nextelm]) do
		for i in enum!.gens do
			new:= i * enum!.currentlist[enum!.nextelm];
			if not new in enum!.orderedlist then
				Add(enum!.currentlist, new);
				AddSet(enum!.orderedlist, new);
			fi;
		od;
		enum!.nextelm:= enum!.nextelm+1;

		# If we have now evaluated the element in the nth place
		if n <= Length(enum!.currentlist) then
			return [true, enum!.currentlist[n]];
		fi;
	od;

	# By now we have closed the list, and found it not to contain n
	# elements.
	if not HasAsSSortedList(ideal) then
		SetAsSSortedList(ideal, enum!.orderedlist);
	fi;
	return [false, 0];
end);

#############################################################################
##
#F	SemigroupIdealEnumeratorDataGetElement( <Enum>, <n> )
##
##	Returns a pair [T/F, elm], such that if <n> is less than or equal to
##	the size of the underlying  ideal the first of the pair will be
##	true, and elm will be the element at the <n>th place.   Otherwise, the
##	first of the pair will be false.
##
BindGlobal("SemigroupIdealEnumeratorDataGetElement", 
function (enum, n)

	local i, j, new, onleft, ideal;

	ideal:= UnderlyingCollection(enum);

	if n <= Length(enum!.currentlist) then
		return [true, enum!.currentlist[n]];
	fi;

	# Starting at the first non-expanded element of the list, multiply
	# every element of the list by generators, until it is large enough
	# to give the nth element.
	onleft:= false;	
	while IsBound(enum!.currentlist[enum!.nextelm]) do
		for i in enum!.gens do
			for j in [1,2] do
				if onleft then
					new:= i * enum!.currentlist[enum!.nextelm];
				else
					new:= enum!.currentlist[enum!.nextelm] * i;
				fi;
				if not new in enum!.orderedlist then
					Add(enum!.currentlist, new);
					AddSet(enum!.orderedlist, new);
				fi;
				onleft:= not onleft;
			od;
		od;
		enum!.nextelm:= enum!.nextelm+1;

		# If we have now evaluated the element in the nth place
		if n <= Length(enum!.currentlist) then
			return [true, enum!.currentlist[n]];
		fi;
	od;

	# By now we have closed the list, and found it not to contain n
	# elements.
	if not HasAsSSortedList(ideal) then
		SetAsSSortedList(ideal, enum!.orderedlist);
	fi;
	return [false, 0];
end);

#############################################################################
##
#M	Enumerator( <I> )
##
##	Enumerator for a right semigroup ideal.
##
InstallMethod( Enumerator, "for a right semigroup ideal", true,
	[IsRightSemigroupIdeal and HasGeneratorsOfRightMagmaIdeal], 0,
function(I)

	local s, enum, enumdata;

	s:= RightActingDomain(I);
	if not HasGeneratorsOfSemigroup(s) then
		TryNextMethod();
	fi;

	enumdata:= rec(
		currentlist:= ShallowCopy(AsSet(GeneratorsOfRightMagmaIdeal(I))),
		gens:= AsSet(GeneratorsOfSemigroup(s)),
		nextelm:= 1,
		orderedlist:= ShallowCopy(AsSet(GeneratorsOfRightMagmaIdeal(I)))
	);

	enum:=  Objectify(NewType(FamilyObj(s), IsRightSemigroupIdealEnumerator
	 and IsSemigroupIdealEnumRep), enumdata);
      	SetUnderlyingCollection( enum, I);
	return enum;
end);

#############################################################################
##
#M	Enumerator( <I> )
##
##	Enumerator for a left semigroup ideal.
##
InstallMethod( Enumerator, "for a left semigroup ideal", true,
	[IsLeftSemigroupIdeal and HasGeneratorsOfLeftMagmaIdeal], 0,
function(I)

	local s, enum, enumdata;

	s:= LeftActingDomain(I);
	if not HasGeneratorsOfSemigroup(s) then
		TryNextMethod();
	fi;

	enumdata:= rec(
		currentlist:= ShallowCopy(AsSet(GeneratorsOfLeftMagmaIdeal(I))),
		gens:= AsSet(GeneratorsOfSemigroup(s)),
		nextelm:= 1,
		orderedlist:= ShallowCopy(AsSet(GeneratorsOfLeftMagmaIdeal(I)))
	);

	enum:=  Objectify(NewType(FamilyObj(s), IsLeftSemigroupIdealEnumerator
		and IsSemigroupIdealEnumRep), enumdata);
	SetUnderlyingCollection( enum, I);
	return enum;
end);

#############################################################################
##
#M	Enumerator( <I> )
##
##	Enumerator for a (two sided) semigroup ideal.
##
InstallMethod( Enumerator, "for a semigroup ideal", true,
	[IsSemigroupIdeal and HasGeneratorsOfMagmaIdeal], 0,
function(I)

	local s, enum, enumdata;

	s:= ActingDomain(I);
	if not HasGeneratorsOfSemigroup(s) then
		TryNextMethod();
	fi;

	enumdata:= rec(
		currentlist:= ShallowCopy(AsSet(GeneratorsOfMagmaIdeal(I))),
		gens:= AsSet(GeneratorsOfSemigroup(s)),
		nextelm:= 1,
		orderedlist:= ShallowCopy(AsSet(GeneratorsOfMagmaIdeal(I)))
	);

	enum:=  Objectify(NewType(FamilyObj(s), IsSemigroupIdealEnumerator
		and IsSemigroupIdealEnumRep), enumdata);
	SetUnderlyingCollection( enum, I);
	return enum;
end);

#############################################################################
##
#M	\[\]( <E>, <n> )
##
##	Returns the <n>th element of a right semigroup ideal enumerator.   Sets
##	AsSSorted list for the underlying ideal when all elements have been
##	found.
##
InstallMethod( \[\], "for a right semigroup ideal enumerator", true,
	[IsRightSemigroupIdealEnumerator and IsSemigroupIdealEnumRep, 
	IsPosInt], 0,
function(enum, n)
	if IsBound(enum[n]) then
		return(enum!.currentlist[n]);	# we know it to be bound, so
										# must have computed it!
	else
		Error("Position out of range");
	fi;
end);

#############################################################################
##
#M	\[\]( <E>, <n> )
##
##	Returns the <n>th element of a left semigroup ideal enumerator.
##
InstallMethod( \[\], "for a left semigroup ideal enumerator", true,
	[IsLeftSemigroupIdealEnumerator and IsSemigroupIdealEnumRep,
	IsPosInt], 0,
function(enum, n)
	if IsBound(enum[n]) then
		return(enum!.currentlist[n]);	# we know it to be bound, so
										# must have computed it!
	else
		Error("Position out of range");
	fi;		
end);

#############################################################################
##
#M	\[\]( <E>, <n> )
##
##	Returns the <n>th element of a semigroup ideal enumerator.
##
InstallMethod( \[\], "for a semigroup ideal enumerator", true,
	[IsSemigroupIdealEnumerator and IsSemigroupIdealEnumRep,
	IsPosInt], 0,
function(enum, n)
	if IsBound(enum[n]) then
		return(enum!.currentlist[n]);	# we know it to be bound, so
										# must have computed it!
	else
		Error("Position out of range");
	fi;		
end);

#############################################################################
##
#M	IsBound\[\]( <E>, <n> )
##
##	Returns true if the enumerator has size at least <n>.   This is the meat
##	of the enumerators calculation, with \[\] relying on it to set the
##	required data.
##
InstallMethod( IsBound\[\], "for a right semigroup ideal enumerator", true,
	[IsRightSemigroupIdealEnumerator and IsSemigroupIdealEnumRep, 
	IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= RightSemigroupIdealEnumeratorDataGetElement(enum, n);
	return pair[1];
end);

#############################################################################
##
#M	IsBound\[\]( <E>, <n> )
##
##	Returns true if the enumerator has size at least <n>.   This is the meat
##	of the enumerators calculation, with \[\] relying on it to set the
##	required data.
##
InstallMethod( IsBound\[\], "for a left semigroup ideal enumerator", true,
	[IsLeftSemigroupIdealEnumerator and IsSemigroupIdealEnumRep, 
	IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= LeftSemigroupIdealEnumeratorDataGetElement(enum, n);
	return pair[1];
end);

#############################################################################
##
#M	IsBound\[\]( <E>, <n> )
##
##	Returns true if the enumerator has size at least <n>.   This is the meat
##	of the enumerators calculation, with \[\] relying on it to set the
##	required data.
##
InstallMethod( IsBound\[\], "for a semigroup ideal enumerator", true,
	[IsSemigroupIdealEnumerator and IsSemigroupIdealEnumRep, 
	IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= SemigroupIdealEnumeratorDataGetElement(enum, n);
	return pair[1];
end);

#############################################################################
#############################################################################
##
##  The following Length and \in methods are needed because of an
##  infinite recursion which is caused by the method 
##  Size  "for a collection" calling 
##  Length "for domain enumerator with underlying collection"
##  which in turn calls Size "for a collection" for the underlying collection.
##  This sets up the recursion.
##
##  The methods below insure we never get into this infinite recursion
##  with Semigroup enumerators.
##
##  Example:
##
##  f:=FreeSemigroup("a","b","c");
##  x:=GeneratorsOfSemigroup(f);
##  a:=x[1];;b:=x[2];;c:=x[3];;
##  r:= [ [a*b,b*a],[a*c,c*a],[b*c,c*b],[a*a,a],[b*b,b],[c*c,c] ];
##  s := f/r;
##  Size(s);
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
##  
#############################################################################
##
#M  Length(<semigroupenum>)
##                
##  Find the length of the enumerator of a semigroup ideal enumerator.
##
InstallMethod( Length, "for a semigroup ideal enumerator", true,
        [IsSemigroupIdealEnumRep],0,
    function(e)
        local n;
        n:=1;

        while IsBound(e[n]) do
            n := n+1;
        od;
        return n-1;
    end);

#############################################################################
##
#M  \in (obj, semigroupenum) 
##
##  Needed only for infinite semigroups which do not have their own \in 
##  method e.g. finitely presented semigroups.
##  For example a semigroup of matrices over a infinite domain. 
##  
##  m := [[2,3],[4,5]];
##  s := Semigroup(m);
##  [[2,3],[4,5]] in s;
##
##  Without the \in method below we would use the default case which 
##  implicitly requires the Length of the semigroup to be computed never
##  terminating. 
## 
InstallMethod( \in, "for a semigroup ideal emunerator", true,
        [IsObject, IsSemigroupIdealEnumRep],0,
    function(obj, enum)
        local i;

        i := 1;
        while IsBound(enum[i]) do
            if obj = enum[i] then 
                return true;
            fi; 
            i := i +1;
        od;
        return false; 
    end);
#############################################################################
#############################################################################

#############################################################################
##
#M  ReesCongruenceOfSemigroupIdeal( <I> )
##
##  A two sided ideal <I> of a semigroup <S>  defines a congruence on
##  <S> given by $\Delta \cup I \times I$.
##
InstallMethod(ReesCongruenceOfSemigroupIdeal,
	"for a two sided semigroup congruence",
	true,
	[IsMagmaIdeal and IsSemigroupIdeal],0,
function(i)
	local mc;

	mc := LR2MagmaCongruenceByPartitionNCCAT(Parent(i), 
		[Enumerator(i)], IsMagmaCongruence);

	SetIsSemigroupCongruence(mc, true);

	return mc;
end);

#############################################################################
##
#M  PrintObj( <S> )
##  print a  SemigroupIdeal
##
InstallMethod( PrintObj,
    "for a semigroup ideal",
    true,
    [ IsMagmaIdeal and IsSemigroupIdeal ], 0,
    function( S )
    Print( "SemigroupIdeal( ... )" );
    end );

InstallMethod( PrintObj,
    "for a semigroup ideal with known generators",
    true,
    [ IsMagmaIdeal and IsSemigroupIdeal and HasGeneratorsOfMagmaIdeal ], 0,
    function( S )
    Print( "SemigroupIdeal( ", GeneratorsOfMagmaIdeal( S ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <S> )
##  view  a  SemigroupIdeal
##
InstallMethod( ViewObj,
    "for a semigroup ideal",
    true,
    [ IsMagmaIdeal and IsSemigroupIdeal ], 0,
    function( S )
    Print( "<SemigroupIdeal>" );
    end );

InstallMethod( ViewObj,
    "for a semigroup ideal with known generators",
    true,
    [ IsMagmaIdeal and IsSemigroupIdeal and HasGeneratorsOfMagmaIdeal ], 0,
    function( S )
    Print( "<SemigroupIdeal with ", Length(GeneratorsOfMagmaIdeal( S )), 
			" generators>" );
    end );


	


#############################################################################
##
#E
