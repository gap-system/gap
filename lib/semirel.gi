#############################################################################
##
#W  semirel.gi                  GAP library                   Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for Green's equivalence relations on
##  semigroups. 
##
Revision.semirel_gi :=
    "@(#)$Id$";


#############################################################################
#############################################################################
##                                                                         ##
##                        Green's Relations                                ##
##                                                                         ##
#############################################################################
#############################################################################

#############################################################################
## 
##	Make sure that each of our separate relations is a greens relation.
##	Similary for classes.
##
InstallTrueMethod(IsGreensRelation, IsGreensRRelation);
InstallTrueMethod(IsGreensRelation, IsGreensLRelation);
InstallTrueMethod(IsGreensRelation, IsGreensDRelation);
InstallTrueMethod(IsGreensRelation, IsGreensJRelation);
InstallTrueMethod(IsGreensRelation, IsGreensHRelation);
InstallTrueMethod(IsGreensClass, IsGreensRClass);
InstallTrueMethod(IsGreensClass, IsGreensLClass);
InstallTrueMethod(IsGreensClass, IsGreensDClass);
InstallTrueMethod(IsGreensClass, IsGreensJClass);
InstallTrueMethod(IsGreensClass, IsGreensHClass);


#############################################################################
## 
#F	GreensRRelation( <S> )
#F	GreensLRelation( <S> )
#F	GreensDRelation( <S> )
#F	GreensJRelation( <S> )
#F	GreensHRelation( <S> )
##
##	Create Green's R, L, D, J and H relations as binary relations.  
##  No calculations are performed.   If <S> is finite, D=J.
##
InstallGlobalFunction(GreensRRelation, 
	S->EquivalenceRelationByProperty(S, IsGreensRRelation));
InstallGlobalFunction(GreensLRelation, 
	S->EquivalenceRelationByProperty(S, IsGreensLRelation));
InstallGlobalFunction(GreensDRelation, 
function(S)
    local e;    

    e:= EquivalenceRelationByProperty(S, IsGreensDRelation);
    if HasIsFinite(S) and IsFinite(S) then
        SetIsGreensJRelation(e, true);
    fi;
    return e;
end);

InstallGlobalFunction(GreensJRelation, 
function(S)
    local e;    

    e:= EquivalenceRelationByProperty(S, IsGreensJRelation);
    if HasIsFinite(S) and IsFinite(S) then
        SetIsGreensDRelation(e, true);
    fi;
    return e;
end);

InstallGlobalFunction(GreensHRelation, 
	S->EquivalenceRelationByProperty(S, IsGreensHRelation));

#############################################################################
## 
#M	EquivalenceClassOfElementNC( <R>, <rep> )
##
##	For Green's relations.
##
InstallMethod(EquivalenceClassOfElementNC, "for greens relations", true,
	[IsGreensRelation, IsObject], 0,
function(rel, rep)

	local 
		new, 									# new equivalence class containing rep
		has_specific_relation; 	# knows that it is in a specific greens relation

	new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)),
		IsEquivalenceClass and IsEquivalenceClassDefaultRep), rec());
	SetEquivalenceClassRelation(new, rel);
	SetRepresentative(new, rep);
	SetParent(new, UnderlyingDomainOfBinaryRelation(rel));
	SetIsGreensClass(new, true);

	has_specific_relation := false;

	if HasIsGreensRRelation(rel) and IsGreensRRelation(rel) then
		SetIsGreensRClass(new, true);
		has_specific_relation := true;
	fi;

	if HasIsGreensLRelation(rel) and IsGreensLRelation(rel) then
		SetIsGreensLClass(new, true);
		has_specific_relation := true;
	fi;

	if HasIsGreensDRelation(rel) and IsGreensDRelation(rel) then
		SetIsGreensDClass(new,true);
		has_specific_relation := true;
	fi;

	if HasIsGreensJRelation(rel) and IsGreensJRelation(rel) then
		SetIsGreensJClass(new, true);
		has_specific_relation := true;
	fi;

	if HasIsGreensHRelation(rel) and IsGreensHRelation(rel) then
		SetIsGreensHClass(new, true);
		has_specific_relation := true;
	fi;

	Assert(2, has_specific_relation);

	return new;
end);

#############################################################################
## 
#M	RClassOfHClass( <H> )
##
InstallMethod(RClassOfHClass, "r class of h class", true,
	[IsGreensHClass], 0,
function( H )
	local s;

	s:= Parent(H);
	return EquivalenceClassOfElementNC(GreensRRelation(s), Representative(H));
end);

#############################################################################
## 
#M	LClassOfHClass( <H> )
##
InstallMethod(LClassOfHClass, "l class of h class", true,
	[IsGreensHClass], 0,
function( H )
	local s;

	s:= Parent(H);
	return EquivalenceClassOfElementNC(GreensLRelation(s), Representative(H));
end);

#############################################################################
##
#M  GreensRClasses( <S> )
#M  GreensLClasses( <S> )
#M  GreensJClasses( <S> )
#M  GreensDClasses( <S> )
#M  GreensHClasses( <S> )
##
##	for a semigroup <S>.
##	To do this we iterate throught the elements of S and
##	produce their classes
##
InstallMethod( GreensRClasses, "for a semigroup", true, [IsSemigroup], 0, S->EquivalenceClasses(GreensRRelation(S)));

InstallMethod( GreensLClasses, "for a semigroup", true, [IsSemigroup], 0, S->EquivalenceClasses(GreensLRelation(S)));

InstallMethod( GreensJClasses, "for a semigroup", true, [IsSemigroup], 1, S->EquivalenceClasses(GreensJRelation(S)));

InstallMethod( GreensDClasses, "for a semigroup", true, [IsSemigroup], 0, S->EquivalenceClasses(GreensDRelation(S)));

InstallMethod( GreensHClasses, "for a semigroup", true, [IsSemigroup], 0, S->EquivalenceClasses(GreensHRelation(S)));

#############################################################################
##
#M  GreensHClasses( <R> )
#M  GreensHClasses( <L> )
#M  GreensHClasses( <J> )
#M  GreensHClasses( <D> )
##
##  for a Greens R,L,J  or D-class.
##
InstallMethod( GreensHClasses, "for Green's R class", true, 
	[IsGreensRClass and IsEquivalenceClass], 0, 
	r->EquivalenceClasses(GreensHRelation(Parent(r)),r));

InstallMethod( GreensHClasses, "for Green's L class", true, 
	[IsGreensLClass and IsEquivalenceClass], 0, 
	r->EquivalenceClasses(GreensHRelation(Parent(r)),r));

InstallMethod( GreensHClasses, "for Green's J class", true, 
	[IsGreensJClass and IsEquivalenceClass], 0, 
	r->EquivalenceClasses(GreensHRelation(Parent(r)),r));

InstallMethod( GreensHClasses, "for Green's D class", true, 
	[IsGreensDClass and IsEquivalenceClass], 0, 
	r->EquivalenceClasses(GreensHRelation(Parent(r)),r));

#############################################################################
##
#F  GreensRClassOfElement(<S>, <a>)
#F  GreensLClassOfElement(<S>, <a>)
#F  GreensDClassOfElement(<S>, <a>)
#F  GreensJClassOfElement(<S>, <a>)
#F  GreensHClassOfElement(<S>, <a>)
##
InstallGlobalFunction(GreensRClassOfElement, 
function(S,a) return EquivalenceClassOfElement(GreensRRelation(S), a); end);

InstallGlobalFunction(GreensLClassOfElement, 
function(S,a) return EquivalenceClassOfElement(GreensLRelation(S), a); end);

InstallGlobalFunction(GreensDClassOfElement, 
function(S,a) return EquivalenceClassOfElement(GreensDRelation(S), a); end);

InstallGlobalFunction(GreensJClassOfElement, 
function(S,a) return EquivalenceClassOfElement(GreensJRelation(S), a); end);

InstallGlobalFunction(GreensHClassOfElement, 
function(S,a) return EquivalenceClassOfElement(GreensHRelation(S), a); end);

#############################################################################
##
#M  GreensRClasses( <J> )
##
InstallMethod( GreensRClasses, "for Green's J class", true, 
	[IsGreensJClass and IsEquivalenceClass], 0, 
	r->EquivalenceClasses(GreensRRelation(Parent(r)),r));


#############################################################################
##
#M  GreensLClasses( <J> )
##
InstallMethod( GreensLClasses, "for Green's J class", true,
  [IsGreensJClass and IsEquivalenceClass], 0,
  r->EquivalenceClasses(GreensLRelation(Parent(r)),r));


#############################################################################
##
#M  GroupHClassOfGreensDClass( <D> )
##
##  for a greens H class of a semigroup. 
##
InstallMethod( GroupHClassOfGreensDClass,
  "for a greens D class of a semigroup", 
  true,
  [IsGreensDClass and IsEquivalenceClass], 0,
function( d )
  local s,				# the semigroup			
				it,       # iterator 
        H,R,      # Greens H,D relations on s
				h,r,			# an H class, an R class
        e,x,      # an element of s
        isidemp;

	s := Parent( d );
  H := GreensHRelation( s );

	# if the semigroup s is simple then any H class is a group
	if HasIsSimpleSemigroup(s) and IsSimpleSemigroup( s ) then
		it := Iterator( s );
		h := EquivalenceClassOfElementNC( H, NextIterator( it ) );
		return h;
	fi;

	# Otherwise an H class is a group iff it contains an idempotent
	# So we look for an idempotent

	# Now, there is an idempotent in D iff there is an idempotent
	# in all R classes of D
	#	Therefore there is an idempotent in D iff there is an idempotent
	# in any given R class of D	

	# so fix the R class of the representative of the D class
	e := Representative( d );
	R := GreensRRelation( s ); 
	r := EquivalenceClassOfElementNC( R, e);
	it := Iterator( r );

  isidemp := false;
  while not (isidemp)  and not (IsDoneIterator( it )) do
   x := NextIterator( it );
   if x^2 = x then
     isidemp := true;
   fi;
	od;

	# if there was no idempotent, there are no group H classes
	if not(isidemp) then
		return fail;
	fi;

  # an H class is a group iff it contains an idempotent
  # so we return the H class of the idempotent we found
  return EquivalenceClassOfElementNC( H, x );

end);

#############################################################################
## 
#M	IsGreensLessThanOrEqual( <C1>, <C2> )
##
##	Implementation for R classes.
##
InstallMethod( IsGreensLessThanOrEqual, "for r classes", IsIdenticalObj,
	[IsGreensRClass, IsGreensRClass], 0,
function( c1, c2 )
	local s;

	s:= Parent(c1);

	return Representative(c1) in 
		RightMagmaIdealByGenerators(s, [Representative(c2)]);
end);



#############################################################################
## 
#M	IsGreensLessThanOrEqual( <C1>, <C2> )
##
##	Implementation for L classes.
##
InstallMethod( IsGreensLessThanOrEqual, "for l classes", IsIdenticalObj,
	[IsGreensLClass, IsGreensLClass], 0,
function( c1, c2 )
	local s;

	s:= Parent(c1);

	return Representative(c1) in 
		LeftMagmaIdealByGenerators(s, [Representative(c2)]);
end);

#############################################################################
## 
#M	IsGreensLessThanOrEqual( <C1>, <C2> )
##
##	Implementation for J classes.
##
InstallMethod( IsGreensLessThanOrEqual, "for j classes", IsIdenticalObj,
	[IsGreensJClass, IsGreensJClass], 1,
function( c1, c2 )
	local s;

	s:= Parent(c1);

	return Representative(c1) in 
		MagmaIdealByGenerators(s, [Representative(c2)]);
end);

#############################################################################
## 
#M	\in ( <T>, <R> )
##
##	Tests membership of a 2-tuple in Green's relations
##
InstallMethod(\in, "for greens relation", true,
	[IsList, IsGreensRelation], 0,
function( tup, rel )

	if Length(tup) <> 2 then
		Error("Left hand side must contain exactly 2 elements");
	fi;

	return tup[1] in EquivalenceClassOfElement(rel, tup[2]);
end);

#############################################################################
## 
#M	\in ( <x>, <C> )
##
##	Tests membership of elements in R classes.
##
InstallMethod( \in, "for r classes", true,
	[IsObject, IsGreensRClass], 0,
function (x, C)
	local c2;

	# if not x in Parent(C) then
		# return false;
	# fi;
	c2:= EquivalenceClassOfElement(EquivalenceClassRelation(C), x);
	return IsGreensLessThanOrEqual(c2, C) and IsGreensLessThanOrEqual(C, c2);
		
end);

#############################################################################
## 
#M	\in ( <x>, <C> )
##
##	Tests membership of elements in L classes.
##
InstallMethod( \in, "for l classes", true,
	[IsObject, IsGreensLClass], 0,
function (x, C)
	local c2;

	# if not x in UnderlyingDomainOfBinaryRelation(
		# EquivalenceClassRelation(C)) then
		# return false;
	# fi;
	c2:= EquivalenceClassOfElement(EquivalenceClassRelation(C), x);
	return IsGreensLessThanOrEqual(c2, C) and IsGreensLessThanOrEqual(C, c2);
		
end);

#############################################################################
## 
#M	\in ( <x>, <C> )
##
##	Tests membership of elements in J classes.
##
InstallMethod( \in, "for j classes", true,
	[IsObject, IsGreensJClass], 1,
function (x, C)
	local c2;

	# if not x in Parent(C) then
		# return false;
	# fi;

#	if HasIsFinite(Parent(C)) and IsFinite(Parent(C)) then
		# check if <x> is in the D-class of the representative of <C>
#		return x in EquivalenceClassOfElement(
#			GreensDRelation(Parent(C)), 
#			Representative(C));
#	fi;

	
	c2:= EquivalenceClassOfElement(EquivalenceClassRelation(C), x);
	return IsGreensLessThanOrEqual(c2, C) and IsGreensLessThanOrEqual(C, c2);
		
end);

#############################################################################
## 
#M	\in ( <x>, <C> )
##
##	Tests membership of elements in H classes.
##
InstallMethod(\in, "for h classes", true,
	[IsObject, IsGreensHClass],0,
function (x, C)
	return x in RClassOfHClass(C) and x in LClassOfHClass(C);
end);

#############################################################################
## 
#M	\in ( <x>, <C> )
##
##	Tests membership of elements in D classes.
##
##	NOTE (RA) Currently, if the L classes of a D class are infinite, this
##	will not terminate unless x is in the L class of the representative.
##	Later versions should defer to an enumerator of the D class which should
##	use some clever counting method for the D class.
##
InstallMethod(\in, "for d classes", true,
	[IsObject, IsGreensDClass],0,
function (x, C)
	local i, s;

	s:= Parent(C);
	for i in Iterator(EquivalenceClassOfElementNC(GreensRRelation(s),
		Representative(C))) do
		if [i,x] in GreensLRelation(s) then
			return true;
		fi;
	od;
	return false;
end);


#############################################################################
##
#R      IsGreensLRJClassEnumeratorRep( <R> )
##
##      A representation for L, R and J greens class enumerators.
##
DeclareRepresentation("IsGreensLRJClassEnumeratorRep",
        IsDomainEnumerator and IsAttributeStoringRep,
		["currentlist", "idealiter"]);

############################################################################
##
#R	IsGreensHClassEnumeratorRep( <H> )
##
##	another representation for the enumerator of an H class
##
DeclareRepresentation("IsGreensHClassEnumeratorRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    ["currentlist", "rclassit" ]);

#############################################################################
##
#F	GreensRClassEnumeratorGetElement( <R>, <n> )
##
##	Returns a pair [T/F, elm], such that if <n> is less than or equal to
##	the size of the Green's R class the first of the pair will be
##	true, and elm will be the element at the <n>th place.   Otherwise, the
##	first of the pair will be false.
##
BindGlobal("GreensRClassEnumeratorGetElement",
function(enum, n)

	local new, s, R;

	R:= UnderlyingCollection(enum);
	s:= Parent(R);
	if n <= Length(enum!.currentlist) then
		return [true, enum!.currentlist[n]];
	fi;

	while Length(enum!.currentlist) < n 
			and not IsDoneIterator(enum!.idealiter) do
		new:= NextIterator(enum!.idealiter);
		if Representative(R) in RightMagmaIdealByGenerators(s, [new]) then
			Add(enum!.currentlist, new);
		fi;
	od;

	if Length(enum!.currentlist) < n then
		SetAsSSortedList(R, AsSSortedList(enum!.currentlist));
		return [false, 0];
	fi;

	return [true, enum!.currentlist[n]];

end);

#############################################################################
##
#F	GreensLClassEnumeratorGetElement( <L>, <n> )
##
##	Returns a pair [T/F, elm], such that if <n> is less than or equal to
##	the size of the Green's L class the first of the pair will be
##	true, and elm will be the element at the <n>th place.   Otherwise, the
##	first of the pair will be false.
##
BindGlobal("GreensLClassEnumeratorGetElement",
function(enum, n)

	local new, s, L;

	L:= UnderlyingCollection(enum);
	s:= Parent(L);
	if n <= Length(enum!.currentlist) then
		return [true, enum!.currentlist[n]];
	fi;

	while Length(enum!.currentlist) < n 
			and not IsDoneIterator(enum!.idealiter) do
		new:= NextIterator(enum!.idealiter);
		if Representative(L) in LeftMagmaIdealByGenerators(s, [new]) then
			Add(enum!.currentlist, new);
		fi;
	od;

	if Length(enum!.currentlist) < n then
		SetAsSSortedList(L, AsSSortedList(enum!.currentlist));
		return [false, 0];
	fi;

	return [true, enum!.currentlist[n]];

end);

#############################################################################
##
#F	GreensJClassEnumeratorGetElement( <J>, <n> )
##
##	Returns a pair [T/F, elm], such that if <n> is less than or equal to
##	the size of the Green's J class the first of the pair will be
##	true, and elm will be the element at the <n>th place.   Otherwise, the
##	first of the pair will be false.
##
BindGlobal("GreensJClassEnumeratorGetElement",
function(enum, n)

	local new, s, J;

	J:= UnderlyingCollection(enum);
	s:= Parent(J);
	if n <= Length(enum!.currentlist) then
		return [true, enum!.currentlist[n]];
	fi;

	while Length(enum!.currentlist) < n 
			and not IsDoneIterator(enum!.idealiter) do
		new:= NextIterator(enum!.idealiter);
		if Representative(J) in MagmaIdealByGenerators(s, [new]) then
			Add(enum!.currentlist, new);
		fi;
	od;

	if Length(enum!.currentlist) < n then
		SetAsSSortedList(J, AsSSortedList(enum!.currentlist));
		return [false, 0];
	fi;

	return [true, enum!.currentlist[n]];

end);

#############################################################################
##
#F  GreensHClassEnumeratorGetElement( <H>, <n> )
##
##  Returns a pair [T/F, elm], such that if <n> is less than or equal to
##  the size of the Green's H class the first of the pair will be
##  true, and elm will be the element at the <n>th place.   Otherwise, the
##  first of the pair will be false.
##
BindGlobal("GreensHClassEnumeratorGetElement",
function(enum, n)

  local new,				# an element of the r class of e 
				s,					# the semigroup 
				e,					# a representative of H
				l,					# greens L class of e
			  H;	 				# greens H class of s

  if n <= Length(enum!.currentlist) then
    return [true, enum!.currentlist[n]];
  fi;

  H := UnderlyingCollection(enum);
  s := Parent(H);
	e := Representative( H );
	l := EquivalenceClassOfElementNC( GreensLRelation( s ), e );
  while Length(enum!.currentlist) < n and not IsDoneIterator(enum!.rclassit) do
		# get an element of the r class
    new:= NextIterator(enum!.rclassit);
		# and checker whether it is in the l class or not
		if ( new in l) then
			# if it belongs to the l class, since it belongs to the r class,
			# it is also in the h class 
			Add( enum!.currentlist, new );
		fi;
	od;	

  if Length(enum!.currentlist) < n then
    SetAsSSortedList(H, AsSSortedList(enum!.currentlist));
    return [false, 0];
  fi;

  return [true, enum!.currentlist[n]];

end);


#############################################################################
##
#M	Enumerator( <R> )
##
##	Enumerator for a Green's R class.
##
InstallMethod( Enumerator, "for a generic r class", true,
	[IsGreensRClass], 0,
function(R)

	local s, enum, enumdata;

	s:= Parent(R);

	enumdata:= rec(
		currentlist:= [],
		idealiter:= Iterator(RightMagmaIdealByGenerators(s, 
			[Representative(R)]))
	);

	enum:= Objectify(NewType(FamilyObj(R), IsGreensRClassEnumerator and
		IsGreensLRJClassEnumeratorRep), enumdata);
	SetUnderlyingCollection(enum, R);
	return enum;
end);

#############################################################################
##
#M	Enumerator( <L> )
##
##	Enumerator for a Green's L class.
##
InstallMethod( Enumerator, "for a generic l class", true,
	[IsGreensLClass], 0,
function(L)

	local s, enum, enumdata;

	s:= Parent(L);

	enumdata:= rec(
		currentlist:= [],
		idealiter:= Iterator(LeftMagmaIdealByGenerators(s, 
			[Representative(L)]))
	);

	enum:= Objectify(NewType(FamilyObj(L), IsGreensLClassEnumerator and
		IsGreensLRJClassEnumeratorRep), enumdata);
	SetUnderlyingCollection(enum, L);
	return enum;
end);

#############################################################################
##
#M	Enumerator( <J> )
##
##	Enumerator for a Green's J class.
##  (the reason why we increase the rank of the method is to be sure that
##	when we have a D class which is also a J class, gap will choose
##	this method and not the one for D classes)
##
InstallMethod( Enumerator, "for a generic j class", true,
	[IsGreensJClass], 1,
function(J)

	local s, enum, enumdata;

	s:= Parent(J);

	enumdata:= rec(
		currentlist:= [],
		idealiter:= Iterator(MagmaIdealByGenerators(s, 
			[Representative(J)]))
	);

	enum:= Objectify(NewType(FamilyObj(J), IsGreensJClassEnumerator and
		IsGreensLRJClassEnumeratorRep), enumdata);
	SetUnderlyingCollection(enum, J);
	return enum;
end);

#############################################################################
##
#M  Enumerator( <D> )
##
##  Enumerator for a Green's D class of a finite semigroup.
##	Since in a finite semigroup D=J, we set S to be a J class and 
##	call next method	
##
InstallMethod( Enumerator, "for a d class of a finite semigroup", true,
  [IsGreensDClass], 0,
function(D)
	local s;
	s := Parent( D );
	if IsFinite( s ) then
		SetIsGreensJClass( D, true );
		# this won't be in an infinite loop since the method for enumerator
		# for J classes has rank heigher than this one. Therefore when 
		# now Enumerator is called it will go through the method for J classes 
		return Enumerator(D);
	fi;
	TryNextMethod();
end);


#############################################################################
##
#M  Enumerator( <H> )
##
##  Enumerator for a Green's H class.
##	This will only work for a semigroup with finite L classes.
##
InstallMethod( Enumerator, "for a generic h class", true,
  [IsGreensHClass], 0,
function( H )

	local s,			# the semigroup 
				e,			# a representative of H
				r,      # the R class of e 
				itr,		# the iterator of the R class of e			
				enumdata, enum;

	s := Parent( H );
	e := Representative( H );
 	r := EquivalenceClassOfElementNC( GreensRRelation( s ), e );		
	itr := Iterator( r );

  enumdata:= rec( currentlist := [], rclassit := itr );

	enum := Objectify(NewType(FamilyObj(H), IsGreensHClassEnumerator and
    IsGreensHClassEnumeratorRep), enumdata);
  SetUnderlyingCollection(enum, H);

  return enum;

end);

#############################################################################
##
#M	\[\]( <E>, <n> )
##
##	Returns the <n>th element of a Green's R class enumerator.   Sets
##	AsSSorted list for the underlying ideal when all elements have been
##	found.
##
InstallMethod(\[\], "for a generic rclass enumerator", true,
	[IsGreensRClassEnumerator and IsGreensLRJClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	if IsBound(enum[n]) then
		return enum!.currentlist[n];
	else
		Error("Position out of range");
	fi;
end);

#############################################################################
##
#M	\[\]( <E>, <n> )
##
##	Returns the <n>th element of a Green's L class enumerator.   Sets
##	AsSSorted list for the underlying ideal when all elements have been
##	found.
##
InstallMethod(\[\], "for a generic lclass enumerator", true,
	[IsGreensLClassEnumerator and IsGreensLRJClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	if IsBound(enum[n]) then
		return enum!.currentlist[n];
	else
		Error("Position out of range");
	fi;
end);

#############################################################################
##
#M	\[\]( <E>, <n> )
##
##	Returns the <n>th element of a Green's J class enumerator.   Sets
##	AsSSorted list for the underlying ideal when all elements have been
##	found.
##
InstallMethod(\[\], "for a generic jclass enumerator", true,
	[IsGreensJClassEnumerator and IsGreensLRJClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	if IsBound(enum[n]) then
		return enum!.currentlist[n];
	else
		Error("Position out of range");
	fi;
end);

###########################################################################
##
#M  \[\]( <E>, <n> )
##
##  Returns the <n>th element of a Green's H class enumerator.   Sets
##  AsSSorted list for the underlying ideal when all elements have been
##  found.
##
InstallMethod(\[\], "for a hclass enumerator", true,
  [IsGreensHClassEnumerator and IsGreensHClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
  if IsBound(enum[n]) then
    return enum!.currentlist[n];
  else
    Error("Position out of range");
  fi;
end);

#############################################################################
##
#M	IsBound\[\]( <E>, <n> )
##
##	Returns true if the enumerator has size at least <n>.
##
InstallMethod(IsBound\[\], "for generic rclass enumerator", true,
	[IsGreensRClassEnumerator and IsGreensLRJClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= GreensRClassEnumeratorGetElement(enum, n);
	return pair[1];
end);

#############################################################################
##
#M	IsBound\[\]( <E>, <n> )
##
##	Returns true if the enumerator has size at least <n>.
##
InstallMethod(IsBound\[\], "for generic lclass enumerator", true,
	[IsGreensLClassEnumerator and IsGreensLRJClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= GreensLClassEnumeratorGetElement(enum, n);
	return pair[1];
end);

#############################################################################
##
#M	IsBound\[\]( <E>, <n> )
##
##	Returns true if the enumerator has size at least <n>.
##
InstallMethod(IsBound\[\], "for generic jclass enumerator", true,
	[IsGreensJClassEnumerator and IsGreensLRJClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= GreensJClassEnumeratorGetElement(enum, n);
	return pair[1];
end);

#############################################################################
##
#M  IsBound\[\]( <E>, <n> )
##
##  Returns true if the enumerator has size at least <n>.
##
InstallMethod(IsBound\[\], "for generic hclass enumerator", true,
  [IsGreensHClassEnumerator and IsGreensHClassEnumeratorRep, IsPosInt], 0,
function(enum, n)
	local pair;

	pair:= GreensHClassEnumeratorGetElement( enum, n);
	return pair[1];
end);

#############################################################################
##
#M  IsRegularDClass( <D> )
##
InstallMethod(IsRegularDClass, "for generic semigroup", true,
    [IsGreensDClass], 0,
        D->IsRegularSemigroupElement(Parent(D), Representative(D)));

#############################################################################
##
#M  IsGroupHClass( <H> )
##
##  returns true if the Greens H-class <H> is a group, which in turn is
##  true if and only if <H>^2 intersects <H>.
##
InstallMethod(IsGroupHClass, "for generic H class", true,
    [IsGreensHClass], 0, h->Representative(h)^2 in h);

#############################################################################
##
#M  EggBoxOfDClass( <D> )
##
##  A matrix whose rows represent R classes and columns represent L classes.
##  The entries are the H classes.
##
InstallMethod(EggBoxOfDClass, "for generic semigroup", true,
    [IsGreensDClass], 0,
function(d)
  local
    tmp,    # swapping variable for h class sort
    s,      # the semigroup containing d
    rcl,    # the r classes of d
    lcl,    # the l classes of d
    hmat,   # the matrix of h classes
    depth,  # the number of r classes
    breadth,  # the number of r classes
    ridx, lidx, # indices into the r and l classes
    correcth;   # the index of the h-class we are  searching for

  s := Parent(d);
  rcl := GreensRClasses(d);
  depth := Length(rcl);

  # First make the rows of the eggbox.
  # The entries may be in the wrong order.
  hmat := List(rcl, GreensHClasses);

  breadth := Length(hmat[1]); # number of l classes

  # We take the first row as being "in order".
  # Make the L classes in that order.

  lcl := List(hmat[1],
    h->EquivalenceClassOfElementNC(GreensLRelation(s), Representative(h)));

  # now reorder the h classes
  for ridx in [2 .. depth] do
    for lidx in [1 .. breadth-1] do
      # find the h class in the L class lidx
      correcth := First([lidx .. breadth], x->
        Representative(hmat[ridx][x]) in lcl[lidx]);

      if correcth <> lidx then
        tmp := hmat[ridx][lidx];
        hmat[ridx][lidx] := hmat[ridx][correcth];
        hmat[ridx][correcth] := tmp;
      fi;
    od;
  od;
  return hmat;
end);

   
#############################################################################
##
#F  DisplayEggBoxOfDClass( <D> )
##
##  A "picture" of the D class <D>, as an array of 1s and 0s.
##  A 1 represents a group H class.
##
InstallGlobalFunction(DisplayEggBoxOfDClass, 
function(d)
	if not IsGreensDClass(d) then
		Error("requires IsGreensDClass");
	fi;

	PrintArray(List(EggBoxOfDClass(d), r->List(r,
	function(h)
	if IsGroupHClass(h) then
				return 1;
	else
				return 0;
	fi;
	end)));
end);






## 
#E
