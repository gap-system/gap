#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Robert Arthur.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for semigroup ideals.
##


#############################################################################
##
##  Immediate methods for
##
##  IsLeftSemigroupIdeal
##  IsRightSemigroupIdeal
##  IsSemigroupIdeal
##
#############################################################################
InstallImmediateMethod( IsLeftSemigroupIdeal,
    IsLeftMagmaIdeal and HasLeftActingDomain and IsAttributeStoringRep, 0,
    I -> HasIsSemigroup(LeftActingDomain(I)) and
         IsSemigroup(LeftActingDomain(I)) );

InstallImmediateMethod( IsRightSemigroupIdeal,
    IsRightMagmaIdeal and HasRightActingDomain and IsAttributeStoringRep, 0,
    I -> HasIsSemigroup(RightActingDomain(I)) and
         IsSemigroup(RightActingDomain(I)) );

InstallImmediateMethod(IsSemigroupIdeal,
    IsMagmaIdeal and HasActingDomain and IsAttributeStoringRep, 0,
    I -> HasIsSemigroup(ActingDomain(I)) and IsSemigroup(ActingDomain(I)) );


#############################################################################
#############################################################################
##                                                                         ##
##                   ENUMERATORS                                           ##
##                                                                         ##
#############################################################################
#############################################################################

#############################################################################
##
#F  RightSemigroupIdealEnumeratorDataGetElement( <enum>, <n> )
##
##  Returns a pair [T/F, elm], such that if <n> is less than or equal to
##  the size of the right ideal the first of the pair will be
##  true, and elm will be the element at the <n>th place.   Otherwise, the
##  first of the pair will be false.
##
BindGlobal( "RightSemigroupIdealEnumeratorDataGetElement",
    function( enum, n )
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
    end );


#############################################################################
##
#F  LeftSemigroupIdealEnumeratorDataGetElement( <Enum>, <n> )
##
##  Returns a pair [T/F, elm], such that if <n> is less than or equal to
##  the size of the underlying left ideal the first of the pair will be
##  true, and elm will be the element at the <n>th place.   Otherwise, the
##  first of the pair will be false.
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
#F  SemigroupIdealEnumeratorDataGetElement( <Enum>, <n> )
##
##  Returns a pair [T/F, elm], such that if <n> is less than or equal to
##  the size of the underlying  ideal the first of the pair will be
##  true, and elm will be the element at the <n>th place.   Otherwise, the
##  first of the pair will be false.
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
#M  \[\]( <E>, <n> )
##
##  Returns the <n>th element of a right semigroup ideal enumerator.   Sets
##  AsSSorted list for the underlying ideal when all elements have been
##  found.
##
BindGlobal( "ElementNumber_SemigroupIdealEnumerator", function( enum, n )
    if IsBound( enum[n] ) then
      return( enum!.currentlist[n] );  # we know it to be bound, so
                                       # must have computed it!
    else
      Error("Position out of range");
    fi;
    end );


#############################################################################
##
#M  Position( <E>, <elm>, 0 )
##
##  There was no special `Position' method for these enumerators,
##  so we install a simpleminded approach.
##
BindGlobal( "NumberElement_SemigroupIdealEnumerator", function( enum, elm )
    local pos;

    if not IsCollsElms( FamilyObj( enum ), FamilyObj( elm ) ) then
      return fail;
    fi;

    pos:= 1;
    while IsBound( enum[ pos ] ) do
      if enum[ pos ] = elm then
        return pos;
      fi;
      pos:= pos + 1;
    od;
    return fail;
    end );


#############################################################################
##
#M  IsBound\[\]( <E>, <n> )
##
##  Returns true if the enumerator has size at least <n>.   This is the meat
##  of the enumerators calculation, with \[\] relying on it to set the
##  required data.
##
InstallGlobalFunction( IsBound_RightSemigroupIdealEnumerator,
    function( enum, n )
    return RightSemigroupIdealEnumeratorDataGetElement( enum, n )[1];
    end );

InstallGlobalFunction( IsBound_LeftSemigroupIdealEnumerator,
    function( enum, n )
    return LeftSemigroupIdealEnumeratorDataGetElement( enum, n )[1];
    end );

BindGlobal( "IsBound_SemigroupIdealEnumerator", function( enum, n )
    return SemigroupIdealEnumeratorDataGetElement( enum, n )[1];
    end );


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

#############################################################################
##
#M  Length(<semigroupenum>)
##
##  Find the length of the enumerator of a semigroup ideal enumerator.
##
BindGlobal( "Length_SemigroupIdealEnumerator", function( e )
    local n;

    n:=1;
    while IsBound(e[n]) do
      n := n+1;
    od;
    return n-1;
    end );


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
BindGlobal( "Membership_SemigroupIdealEnumerator", function( obj, enum )
    local i;

    i := 1;
    while IsBound( enum[i] ) do
      if obj = enum[i] then
        return true;
      fi;
      i := i +1;
    od;
    return false;
    end );


#############################################################################
##
#M  Enumerator( <I> ) . . . . . . . . . . . . . . for a right semigroup ideal
#M  Enumerator( <I> ) . . . . . . . . . . . . . .  for a left semigroup ideal
#M  Enumerator( <I> ) . . . . . . . . . . . for a (two sided) semigroup ideal
##
InstallGlobalFunction( EnumeratorOfSemigroupIdeal,
    function( I, actdom, isbound, gens )

    if not HasGeneratorsOfSemigroup( actdom ) then
      TryNextMethod();
    fi;

    return EnumeratorByFunctions( I, rec(
        ElementNumber := ElementNumber_SemigroupIdealEnumerator,
        NumberElement := NumberElement_SemigroupIdealEnumerator,
        IsBound\[\]   := isbound,
        Length        := Length_SemigroupIdealEnumerator,
        Membership    := Membership_SemigroupIdealEnumerator,

        currentlist   := ShallowCopy( AsSet( gens ) ),
        gens          := AsSet( GeneratorsOfSemigroup( actdom ) ),
        nextelm       := 1,
        orderedlist   := ShallowCopy( AsSet( gens ) ) ) );
    end );

InstallMethod( Enumerator,
    "for a right semigroup ideal",
    [ IsRightSemigroupIdeal and HasGeneratorsOfRightMagmaIdeal ],
    I -> EnumeratorOfSemigroupIdeal( I, RightActingDomain( I ),
             IsBound_RightSemigroupIdealEnumerator,
             GeneratorsOfRightMagmaIdeal( I ) ) );

InstallMethod( Enumerator,
    "for a left semigroup ideal",
    [ IsLeftSemigroupIdeal and HasGeneratorsOfLeftMagmaIdeal ],
    I -> EnumeratorOfSemigroupIdeal( I, LeftActingDomain( I ),
             IsBound_LeftSemigroupIdealEnumerator,
             GeneratorsOfLeftMagmaIdeal( I ) ) );

InstallMethod( Enumerator,
    "for a semigroup ideal",
    [ IsSemigroupIdeal and HasGeneratorsOfMagmaIdeal ],
    I -> EnumeratorOfSemigroupIdeal( I, ActingDomain( I ),
             IsBound_SemigroupIdealEnumerator,
             GeneratorsOfMagmaIdeal( I ) ) );


#############################################################################
##
#M  ReesCongruenceOfSemigroupIdeal( <I> )
##
##  A two sided ideal <I> of a semigroup <S>  defines a congruence on
##  <S> given by $\Delta \cup I \times I$.
##
InstallMethod(ReesCongruenceOfSemigroupIdeal,
    "for a two sided semigroup congruence",
    [ IsMagmaIdeal and IsSemigroupIdeal ],
    function(i)
    local mc;

    mc := LR2MagmaCongruenceByPartitionNCCAT(Parent(i),
              [Enumerator(i)], IsMagmaCongruence);
    SetIsSemigroupCongruence(mc, true);

    return mc;
    end );


#############################################################################
##
#M  PrintObj( <S> ) . . . . . . . . . . . . . . . . . .  for a SemigroupIdeal
##
InstallMethod( PrintObj,
    "for a semigroup ideal",
    [ IsMagmaIdeal and IsSemigroupIdeal ],
    function( S )
    Print( "SemigroupIdeal( ... )" );
    end );

InstallMethod( PrintObj,
    "for a semigroup ideal with known generators",
    [ IsMagmaIdeal and IsSemigroupIdeal and HasGeneratorsOfMagmaIdeal ],
    function( S )
    Print( "SemigroupIdeal( ", GeneratorsOfMagmaIdeal( S ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <S> )  . . . . . . . . . . . . . . . . . .  for a SemigroupIdeal
##
InstallMethod( ViewObj,
    "for a semigroup ideal",
    [ IsMagmaIdeal and IsSemigroupIdeal ],
    function( S )
    Print( "<SemigroupIdeal>" );
    end );

InstallMethod( ViewObj,
    "for a semigroup ideal with known generators",
    [ IsMagmaIdeal and IsSemigroupIdeal and HasGeneratorsOfMagmaIdeal ],
    function( S )
    Print( "<semigroup ideal with ",
           Pluralize( Length(GeneratorsOfMagmaIdeal( S )), "generator" ), ">");
    end );
