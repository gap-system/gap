#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for semigroups.
##

# Everything from here...

InstallMethod(IsGeneratorsOfSemigroup, "for a list", [IsList], ReturnFalse);

InstallMethod(IsGeneratorsOfSemigroup,
"for an FFE coll coll coll",
[IsFFECollCollColl],
function(coll)
  if ForAll(coll, x -> IsMatrix(x) and Length(x) = Length(coll[1])) then
    return true;
  fi;
  return false;
end);

# fall back methods

InstallMethod(SemigroupViewStringPrefix, "for a semigroup",
[IsSemigroup], S -> "");

InstallMethod(SemigroupViewStringSuffix, "for a semigroup",
[IsSemigroup], S -> "");

BindGlobal("_ViewStringForSemigroups",
function(S)
  local str, nrgens, suffix;

  str := "\><";

  if IsEmpty(S) then
    Append(str, "\>empty\< ");
  elif HasIsTrivial(S) and IsTrivial(S) then
    Append(str, "\>trivial\< ");
  else
    if HasIsFinite(S) and not IsFinite(S) then
      Append(str, "\>infinite\< ");
    fi;
    if HasIsCommutative(S) and IsCommutative(S) then
      Append(str, "\>commutative\< ");
    fi;
  fi;

  if not IsGroup(S) and not IsEmpty(S) then
    if HasIsTrivial(S) and IsTrivial(S) then
      # do nothing
    elif HasIsZeroSimpleSemigroup(S) and IsZeroSimpleSemigroup(S) then
      Append(str, "\>0-simple\< ");
    elif HasIsSimpleSemigroup(S) and IsSimpleSemigroup(S) then
      Append(str, "\>simple\< ");
    fi;

    if HasIsInverseSemigroup(S) and IsInverseSemigroup(S) then
      Append(str, "\>inverse\< ");
    elif HasIsRegularSemigroup(S)
        and not (HasIsSimpleSemigroup(S) and IsSimpleSemigroup(S)) then
      if IsRegularSemigroup(S) then
        Append(str, "\>regular\< ");
      else
        Append(str, "\>non-regular\< ");
      fi;
    fi;
  fi;

  Append(str, SemigroupViewStringPrefix(S));

  if IsEmpty(S) then
    Append(str, "\>semigroup\<>\<");
    return str;
  elif HasIsMonoid(S) and IsMonoid(S) then
    Append(str, "\>monoid\< ");
    if HasGeneratorsOfInverseMonoid(S) then
      nrgens := Length(GeneratorsOfInverseMonoid(S));
    else
      nrgens := Length(GeneratorsOfMonoid(S));
    fi;
  else
    Append(str, "\>semigroup\< ");
    if HasGeneratorsOfInverseSemigroup(S) then
      nrgens := Length(GeneratorsOfInverseSemigroup(S));
    else
      nrgens := Length(GeneratorsOfSemigroup(S));
    fi;
  fi;

  if HasIsTrivial(S) and not IsTrivial(S) and HasSize(S) and IsFinite(S) then
    Append(str, "\>of size\> ");
    Append(str, ViewString(Size(S)));
    Append(str, ",\<\< ");
  fi;

  suffix := SemigroupViewStringSuffix(S);

  if suffix <> ""
      and not (HasIsTrivial(S) and not IsTrivial(S) and HasSize(S)) then
    suffix := Concatenation("\>of\< ", suffix);
  fi;
  Append(str, suffix);

  Append(str, "\>with\< \>");
  Append(str, ViewString(nrgens));
  Append(str, "\< \>generator");
  if nrgens > 1 or nrgens = 0 then
    Append(str, "s");
  fi;
  Append(str, "\<>\<");

  return str;
end);

# ViewString

InstallMethod(ViewString, "for a semigroup with semigroup generators",
[IsSemigroup and HasGeneratorsOfSemigroup], _ViewStringForSemigroups);

InstallMethod(ViewString, "for a monoid with monoid generators",
[IsMonoid and HasGeneratorsOfMonoid], _ViewStringForSemigroups);

InstallMethod(ViewString, "for an inverse semigroup with semigroup generators",
[IsInverseSemigroup and HasGeneratorsOfSemigroup],
_ViewStringForSemigroups);

InstallMethod(ViewString, "for an inverse monoid with semigroup generators",
[IsInverseMonoid and HasGeneratorsOfSemigroup],
_ViewStringForSemigroups);

InstallMethod(ViewString,
"for an inverse semigroup with inverse semigroup generators",
[IsInverseSemigroup and HasGeneratorsOfInverseSemigroup],
_ViewStringForSemigroups);

InstallMethod(ViewString,
"for an inverse monoid with inverse monoid generators",
[IsInverseMonoid and HasGeneratorsOfInverseMonoid],
_ViewStringForSemigroups);

MakeReadWriteGlobal("_ViewStringForSemigroups");
Unbind(_ViewStringForSemigroups);

#

BindGlobal("_ViewStringForSemigroupsGroups",
function(S)
  local str, suffix, gens;

  str := "\><";

  if HasIsTrivial(S) and IsTrivial(S) then
    Append(str, "\>trivial\< ");
  fi;
  Append(str, SemigroupViewStringPrefix(S));
  Append(str, "\>group\< ");
  if HasIsTrivial(S) and not IsTrivial(S) and HasSize(S) then
    Append(str, "\>of size\> ");
    Append(str, ViewString(Size(S)));
    Append(str, ",\<\< ");
  fi;

  suffix := SemigroupViewStringSuffix(S);
  if suffix <> ""
      and not (HasIsTrivial(S) and not IsTrivial(S) and HasSize(S)) then
    suffix := Concatenation("of ", suffix);
  fi;
  Append(str, suffix);

  if IsGroup(S) and HasGeneratorsOfGroup(S) then
    gens := GeneratorsOfGroup(S);
  elif IsInverseMonoid(S) and HasGeneratorsOfInverseMonoid(S) then
    gens := GeneratorsOfInverseMonoid(S);
  elif IsInverseSemigroup(S) and HasGeneratorsOfInverseSemigroup(S) then
    gens := GeneratorsOfInverseSemigroup(S);
  elif IsMonoid(S) and HasGeneratorsOfMonoid(S) then
    gens := GeneratorsOfMonoid(S);
  elif HasGeneratorsOfSemigroup(S) then
    gens := GeneratorsOfSemigroup(S);
  fi;

  if IsBound(gens) then
    Append(str, "with\> ");
    Append(str, ViewString(Length(gens)));
    Append(str, "\< generator");

    if Length(gens) > 1 or Length(gens) = 0 then
      Append(str, "s");
    fi;
  else
    Remove(str, Length(str));
  fi;

  Append(str, ">\<");

  return str;
end);

InstallMethod(ViewString,
"for a group as semigroup with known generators (as a semigroup)",
[IsGroupAsSemigroup and HasGeneratorsOfSemigroup],
_ViewStringForSemigroupsGroups);

InstallMethod(ViewString,
"for a group with known generators (as a semigroup)",
[IsGroup and HasGeneratorsOfSemigroup],
_ViewStringForSemigroupsGroups);

# the next two methods required to use _ViewStringForSemigroupsGroups instead
# of the ViewString for IsGroup and HasGeneratorsOfGroup.

InstallMethod(ViewString, "for a group of transformations",
[IsGroup and HasGeneratorsOfGroup and IsTransformationSemigroup],
_ViewStringForSemigroupsGroups);

InstallMethod(ViewString, "for a group of partial perms",
[IsGroup and HasGeneratorsOfGroup and IsPartialPermSemigroup],
_ViewStringForSemigroupsGroups);

InstallMethod(ViewString, "for a group as semigroup",
[IsGroupAsSemigroup and IsSemigroupIdeal],
SUM_FLAGS, # to beat the method for semigroup ideals
_ViewStringForSemigroupsGroups);

MakeReadWriteGlobal("_ViewStringForSemigroupsGroups");
Unbind(_ViewStringForSemigroupsGroups);

InstallMethod(IsGeneratorsOfSemigroup, "for an empty list",
[IsList and IsEmpty], ReturnFalse);

#

InstallMethod(InversesOfSemigroupElement,
"for a semigroup and a multiplicative element",
[IsSemigroup, IsMultiplicativeElement],
function(S, x)
  if not x in S then
    ErrorNoReturn("usage: the 2nd argument must be an element of the 1st,");
  fi;
  return Filtered(AsSSortedList(S), y -> x * y * x = x and y * x * y = y);
end);

#

InstallMethod(\.,"for a semigroup with generators and pos int",
[IsSemigroup and HasGeneratorsOfSemigroup, IsPosInt],
function(s, n)
  s:=GeneratorsOfSemigroup(s);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(s)<n then
    ErrorNoReturn("usage: the second argument should be a pos int not greater than",
     " the number of generators of the semigroup in the first argument,");
  fi;
  return s[n];
end);

#

InstallMethod(\., "for a monoid with generators and pos int",
[IsMonoid and HasGeneratorsOfMonoid, IsPosInt],
function(s, n)
  s:=GeneratorsOfMonoid(s);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(s)<n then
    ErrorNoReturn("usage: the second argument should be a pos int not greater than",
     " the number of generators of the semigroup in the first argument,");
  fi;
  return s[n];
end);

#

InstallMethod(IsSubsemigroup,
"for semigroup and semigroup with generators",
[IsSemigroup, IsSemigroup and HasGeneratorsOfSemigroup],
function(s, t)
  return ForAll(GeneratorsOfSemigroup(t), x-> x in s);
end);

#

InstallMethod(IsSubsemigroup, "for a semigroup and semigroup",
[IsSemigroup, IsSemigroup], IsSubset);

#

InstallMethod(\=,
"for semigroup with generators and semigroup with generators",
[IsSemigroup and HasGeneratorsOfSemigroup,
 IsSemigroup and HasGeneratorsOfSemigroup],
function(s, t)
  return ForAll(GeneratorsOfSemigroup(s), x-> x in t) and
   ForAll(GeneratorsOfSemigroup(t), x-> x in s);
end);

#

InstallTrueMethod(IsRegularSemigroup, IsInverseSemigroup);

#

InstallMethod(IsInverseSemigroup, "for a semigroup",
[IsSemigroup],
function(s)
local F, e, f;

  if not IsRegularSemigroup(s) then
    return false;
  fi;

  F:=Idempotents(s);

  for e in F do
    for f in F do
      if e*f<>f*e then
        return false;
      fi;
    od;
  od;

  return true;
end);

# to here was added by JDM.

#############################################################################
##
##  Compute a data structure that can be used to compute the
##  CayleyGraph of a semigroup. This data structure is essentially
##  a list of lists of points each list recording the action of the
##  generators of the semigroup on every element in the semigroup.
##  The points represent the elements of the semigroup in sorted order.
##  This representation is so a more condensed list of elements can be
##  used rather than the elements of the semigroup.
##
##  Similarly for the dual of the semigroup.
##
##  Clearly, these graphs can be computed only for finite semigroups
##  which can be enumerated. Other methods will be needed for very large
##  semigroups or the infinite cases.
##
#A  CayleyGraphSemigroup(<semigroup>)
#A  CayleyGraphDualSemigroup(<semigroup>)
##
InstallMethod(CayleyGraphSemigroup, "for generic finite semigroups",
        [IsSemigroup and IsFinite],
    function(s)

    FroidurePinExtendedAlg(s);
    return CayleyGraphSemigroup(s);

    end);

InstallMethod(CayleyGraphDualSemigroup, "for generic finite semigroups",
        [IsSemigroup and IsFinite],
    function(s)

    FroidurePinExtendedAlg(s);
    return CayleyGraphDualSemigroup(s);

    end);

#############################################################################
##
#M  PrintObj( <S> ) . . . . . . . . . . . . . . . . . . . . print a semigroup
##

InstallMethod( String,
    "for a semigroup",
    [ IsSemigroup ],
    function( S )
    return "Semigroup( ... )";
    end );

InstallMethod( PrintObj,
    "for a semigroup with known generators",
    [ IsSemigroup and HasGeneratorsOfMagma ],
    function( S )
    Print( "Semigroup( ", GeneratorsOfMagma( S ), " )" );
    end );


InstallMethod( String,
    "for a semigroup with known generators",
    [ IsSemigroup and HasGeneratorsOfMagma ],
    function( S )
    return STRINGIFY( "Semigroup( ", GeneratorsOfMagma( S ), " )" );
    end );

InstallMethod( PrintString,
    "for a semigroup with known generators",
    [ IsSemigroup and HasGeneratorsOfMagma ],
    function( S )
    return PRINT_STRINGIFY( "\>Semigroup(\>\n", GeneratorsOfMagma( S ), " \<)\<" );
    end );

#############################################################################
##
#M  ViewString( <S> )  . . . . . . . . . . . . . . . . . . . .  view a semigroup
##
InstallMethod( ViewString,
    "for a semigroup",
    [ IsSemigroup ],
    function( S )
    return "<semigroup>";
    end );

#############################################################################
##
#M  DisplaySemigroup( <S> )
##
InstallMethod(DisplaySemigroup, "for finite semigroups",
    [IsTransformationSemigroup],
function(S)

    local dc, i, len, sh, D, layer, displayDClass, n;

    displayDClass:= function(D)
        local h, nrL, nrR;
        h:= GreensHClassOfElement(AssociatedSemigroup(D),Representative(D));
        if IsRegularDClass(D) then
            Print("*");
        else
            Print(" ");
        fi;
        nrL := Size(GreensRClassOfElement(AssociatedSemigroup(D),
                                          Representative(h))) / Size(h);
        nrR := Size(GreensLClassOfElement(AssociatedSemigroup(D),
                                          Representative(h))) / Size(h);
        Print("[H size = ", Size(h), ", ",
              Pluralize(nrL, "L-class"), ", ", Pluralize(nrR, "R-class"),
              "]\n");
    end;

    #########################################################################
    ##
    ##  Function Proper
    ##
    #########################################################################

    # check finiteness
    if not IsFinite(S) then
        TryNextMethod();
    fi;

    # determine D classes and sort according to rank.
    n := DegreeOfTransformationSemigroup(S);

    if n = 0 then
        # special case for the full transformation monoid on one point
        Print("Rank 0: ");
        displayDClass(GreensDClasses(S)[1]);
        return;
    fi;

    layer:= List([1 .. n], x->[]);
    for D in GreensDClasses(S) do
        Add(layer[RankOfTransformation(Representative(D), n)], D);
    od;

    # loop over the layers.
    len:= Length(layer);
    for i in [len, len-1..1] do
        if layer[i] <> [] then

            # loop over D classes.
            for D in layer[i] do
                Print("Rank ", i, ": \c");
                displayDClass(D);
            od;
        fi;
    od;

end);



#############################################################################
##
#M  SemigroupByGenerators( <gens> ) . . . . . . semigroup generated by <gens>
##
InstallMethod(SemigroupByGenerators,
"for a collection",
[IsCollection],
function(gens)
  local S, pos;

  S := Objectify(NewType(FamilyObj(gens), IsSemigroup
                                             and IsAttributeStoringRep), rec());
  gens := AsList(gens);
  SetGeneratorsOfMagma(S, gens);

  if IsMultiplicativeElementWithOneCollection(gens)
      and CanEasilyCompareElements(gens)
      and IsFinite(gens) then
    pos := Position(gens, One(gens));
    if pos <> fail then
      SetFilterObj(S, IsMonoid);
      if Length(gens) = 1 then # Length(gens) <> 0 since One(gens) in gens
        SetIsTrivial(S, true);
      elif not IsPartialPermCollection(gens) or One(gens) =
        One(gens{Concatenation([1 .. pos - 1], [pos + 1 .. Length(gens)])}) then
        # if gens = [PartialPerm([1, 2]), PartialPerm([1])], then removing the One
        # = gens[1] from this, it is not possible to recreate the semigroup using
        # Monoid(PartialPerm([1])) (since the One in this case is
        # PartialPerm([1]) not PartialPerm([1, 2]) as it should be.
        gens := ShallowCopy(gens);
        Remove(gens, pos);
      fi;
      SetGeneratorsOfMonoid(S, gens);
    fi;
  fi;

  return S;
end);

#############################################################################
##
#M  AsSemigroup( <D> ) . . . . . . . . . . .  domain <D>, viewed as semigroup
##
InstallMethod( AsSemigroup,
    "for a semigroup",
    [ IsSemigroup ], 100,
    IdFunc );

InstallMethod( AsSemigroup,
    "generic method for collections",
    [ IsCollection ],
    function ( D )
    local   S,  L;

    if not IsAssociative( D ) then
      return fail;
    fi;

    D := AsSSortedList( D );
    L := ShallowCopy( D );
    S := Submagma( SemigroupByGenerators( D ), [] );
    SubtractSet( L, AsSSortedList( S ) );
    while not IsEmpty(L)  do
        S := ClosureMagmaDefault( S, L[1] );
        SubtractSet( L, AsSSortedList( S ) );
    od;
    if Length( AsSSortedList( S ) ) <> Length( D )  then
        return fail;
    fi;
    S := SemigroupByGenerators( GeneratorsOfSemigroup( S ) );
    SetAsSSortedList( S, D );
    SetIsFinite( S, true );
    SetSize( S, Length( D ) );

    # return the semigroup
    return S;
    end );


#############################################################################
##
#F  Semigroup( <gen>, ... ) . . . . . . . . semigroup generated by collection
#F  Semigroup( <gens> ) . . . . . . . . . . semigroup generated by collection
##

InstallGlobalFunction(Semigroup,
function(arg)
  local out, i;

  if Length(arg) = 0 or (Length(arg) = 1 and HasIsEmpty(arg[1])
      and IsEmpty(arg[1])) then
    ErrorNoReturn("Usage: cannot create a semigroup with no generators,");
  fi;

  out := [];
  for i in [1 .. Length(arg)] do
    if i = Length(arg) and IsRecord(arg[i]) then
      if not IsGeneratorsOfSemigroup(out) then
        ErrorNoReturn("Usage: Semigroup(<gen>, ...), ",
                      "Semigroup(<gens>), Semigroup(<D>),");
      fi;
      return SemigroupByGenerators(out, arg[i]);
    elif IsMultiplicativeElement(arg[i]) or IsMatrix(arg[i]) then
      Add(out, arg[i]);
    elif IsListOrCollection(arg[i]) then
      if IsGeneratorsOfSemigroup(arg[i]) then
        if HasGeneratorsOfSemigroup(arg[i]) or IsMagmaIdeal(arg[i]) then
          Append(out, GeneratorsOfSemigroup(arg[i]));
        elif IsList(arg[i]) then
          Append(out, arg[i]);
        else
          Append(out, AsList(arg[i]));
        fi;
      elif not IsEmpty(arg[i]) then
          ErrorNoReturn("Usage: Semigroup(<gen>, ...), ",
                        "Semigroup(<gens>), Semigroup(<D>),");
      fi;
    else
      ErrorNoReturn("Usage: Semigroup(<gen>, ...), ",
                    "Semigroup(<gens>), Semigroup(<D>),");
    fi;
  od;
  if not IsGeneratorsOfSemigroup(out) then
    ErrorNoReturn("Usage: Semigroup(<gen>,...), Semigroup(<gens>), ",
                  "Semigroup(<D>)," );
  fi;
  return SemigroupByGenerators(out);
end);

#############################################################################
##
#M  AsSubsemigroup( <G>, <U> )
##
InstallMethod( AsSubsemigroup,
    "generic method for a domain and a collection",
    IsIdenticalObj,
    [ IsDomain, IsCollection ],
    function( G, U )
    local S;
    if not IsSubset( G, U ) then
      return fail;
    fi;
    if IsMagma( U ) then
      if not IsAssociative( U ) then
        return fail;
      fi;
      S:= SubsemigroupNC( G, GeneratorsOfMagma( U ) );
    else
      S:= SubmagmaNC( G, AsList( U ) );
      if not IsAssociative( S ) then
        return fail;
      fi;
    fi;
    UseIsomorphismRelation( U, S );
    UseSubsetRelation( U, S );
    return S;
    end );

#############################################################################
##
#M  Enumerator( <S> )
#M  Enumerator( <S> : Side:= "left" )
#M  Enumerator( <S> : Side:= "right")
##
##  Creates a naive semigroup enumerator.   By default this enumerates the
##  right semigroup ideal of the set of generators.   This is the same as
##  the third form.
##
##  In the second form it enumerates the left semigroup ideal generated by
##  the semigroup generators.
##
InstallMethod( Enumerator, "for a generic semigroup",
    [ IsSemigroup and HasGeneratorsOfSemigroup ],
    function( s )

    if ValueOption( "Side" ) = "left" then
      return EnumeratorOfSemigroupIdeal( s, s,
                 IsBound_LeftSemigroupIdealEnumerator,
                 GeneratorsOfSemigroup( s ) );
    else
      return EnumeratorOfSemigroupIdeal( s, s,
                 IsBound_RightSemigroupIdealEnumerator,
                 GeneratorsOfSemigroup( s ) );
    fi;
    end );


#############################################################################
##
#M  IsSimpleSemigroup( <S> ) . . . . . . . . . . . . . . . . . .  for a group
#M  IsSimpleSemigroup( <S> ) . . . . . . . . . . . .  for a trivial semigroup
##
##  All groups are simple semigroups.
##  A trivial semigroup is a simple semigroup.
##
InstallTrueMethod( IsSimpleSemigroup, IsGroup );
InstallTrueMethod( IsSimpleSemigroup, IsSemigroup and IsTrivial );


#############################################################################
##
#M  IsSimpleSemigroup( <S> ) . . . . . . . for semigroup which has generators
##
##  In such a case the semigroup is simple iff all generators are
##  Greens J less than or equal to any element of the semigroup.
##
##  Proof:
##  (->) Suppose <S> is simple; equivalently this means than
##  for all element <t> of <S>, <StS=S>. So let <t> be an
##  arbitrary element of <S> and let <x> be any generator of <S>.
##  Then $S^1xS^1 \subseteq S = StS \subseteq S^1tS^1$ and this
##  means that <x> is J less than or equal to t.
##
##  (<-) Conversely.
##  Recall that <S> simple is equivalent to J being
##  the universal relation in <S>. So that is what we have to proof.
##  All elements of the semigroup are J less than or equal to the generators
##  since they are products of generators. But since by the condition
##  given all generators are less than or equal to all other elements
##  it follows that all elements of the semigroup are J related, and
##  hence J is universal.
##  QED
##
##  In order to apply the above result we are going to check that
##  one of the generators is J-minimal and that all other generators are
##  J-less than or equal to  that first generator.
##
##  It returns true if the semigroup is finite and is simple.
##  It returns false if the semigroup is not simple and is finite.
##  It might return false if the semigroup is not simple and infinite.
##  It does not terminate if the semigroup although simple, is infinite
##
InstallMethod(IsSimpleSemigroup,
        "for semigroup with generators",
        [ IsSemigroup and HasGeneratorsOfSemigroup],
    function(s)
         local it,          # the iterator of the semigroup s
               t,           # an element of the semigroup
               J,           # Greens J relation of the semigroup
               gens,        # a set of generators of the semigroup
               a,           # a generator
               i,           # loop variable
               jt,ja,jx;    # J classes

         # the iterator, the J-relation and a generating set for the semigroup
         it:=Iterator(s);
         J:=GreensJRelation(s);
         gens:=GeneratorsOfSemigroup(s);

         # pick a generator, gens[1], and build its J class
         jx:=EquivalenceClassOfElementNC(J,gens[1]);

         # check whether gens[1] is J less than or equal to all other els of the smg
         while not(IsDoneIterator(it)) do
             # pick the next element of the semigroup
             t:=NextIterator(it);
             # if gens[1] is not J-less than or equal to t then S is not simple
             jt:=EquivalenceClassOfElementNC(J,t);
             if not(IsGreensLessThanOrEqual(jx,jt)) then
                 return false;
             fi;
         od;

         # notice that the above cycle only terminates without returning false
         # when the semigroup is finite

         # now check whether all other generators are J less than or equal
         # the first one. No need to compare with first one (itself), so start in the
         # second one. Also, no need to compare with any other generator equal
         # to first one
         i:=2;
         while i in [1..Length(gens)] do
             a:=gens[i];
             ja:=EquivalenceClassOfElementNC(J,a);
             if not(IsGreensLessThanOrEqual(ja,jx)) then
                 return false;
             fi;
             i:=i+1;
         od;

         # hence the semigroup is simple
         return true;

    end);

#############################################################################
##
#M  IsSimpleSemigroup( <S> )
##
##  for a semigroup which has a MultiplicativeNeutralElement.
##
##  In this case is enough to show that the MultiplicativeNeutralElement
##  is J-less than or equal to all other elements.
##  This is because a MultiplicativeNeutralElement is J greater than or
##  equal to any other element and hence by showing that is less than
##  or equal any other element it follows that J is universal, and
##  therefore the semigroup <S> is simple.
##
##  If the semigroup is finite it returns true if the semigroup is
##  simple and false otherwise.
##  If the semigroup is infinite and simple it does not terminate. It
##  might terminate and return false if the semigroup is not simple.
##
InstallMethod( IsSimpleSemigroup,
  "for a semigroup with a MultiplicativeNeutralElement",
  [ IsSemigroup and HasMultiplicativeNeutralElement ],
function(s)
    local it,# the iterator of the semigroup S
          J,# Green's J relation on the semigroup
          jn,jt,# J-classes
          t,# an element of the semigroup
          neutral;# the MultiplicativeNeutralElement of s

    # the iterator and the J-relation on S
    it:=Iterator(s);
    J:=GreensJRelation(s);

    # the multiplicative neutral element and its J class
    neutral:=MultiplicativeNeutralElement(s);
  jn:=EquivalenceClassOfElementNC(J,neutral);

    while not(IsDoneIterator(it)) do
      t:=NextIterator(it);
    jt:=EquivalenceClassOfElementNC(J,t);
      # if neutral is not J less than or equal to t then S is not simple
    if not(IsGreensLessThanOrEqual(jn,jt)) then
      return false;
    fi;
  od;

    # notice that the above cycle only terminates without returning
    # false if the semigroup is finite

    # hence s is simple
    return true;

end);

#############################################################################
##
#M  IsSimpleSemigroup( <S> ) . . . . . . . . . . . . . . . .  for a semigroup
##
##  This is the general case for a semigroup.
##
##  A semigroup is simple iff J is the universal relation in S.
##  So we are going to fix a J class and look through the semigroup
##  to check whether there are other J-classes.
##
##  It returns false if it finds a new J-class.
##  It returns true if is finite and only finds one J-class.
##  It does not terminate if simple but infinite.
##
InstallMethod(IsSimpleSemigroup,
  "for a semigroup",
  [ IsSemigroup ],
function(s)
    local it,# the iterator of the semigroup s
          J,# J relation on s
          a,b,# elements of the semigroup
          ja,jb;# J-classes

    # the J-relation on s and the iterator of s
    J:=GreensJRelation(s);
    it:=Iterator(s);

    # pick an element of the semigroup
    a:=NextIterator(it);
    # and build its J class
    ja:=EquivalenceClassOfElementNC(J,a);

    # if IsDoneIterator(it) it means that the semigroup is trivial, and hence simple
    if IsDoneIterator(it) then
      return true;
    fi;

    # look through all elements of s
    # to find out if there are more J classes
    while not(IsDoneIterator(it)) do
      b:=NextIterator(it);
      jb:=EquivalenceClassOfElementNC(J,b);
      # if a and b are not in the same J class then the smg is not simple
      if not(IsGreensLessThanOrEqual(ja,jb)) then
        return false;
      elif not (IsGreensLessThanOrEqual(jb,ja)) then
        return false;
      fi;
    od;

    # notice that the above cycle only terminates without returning
    # false if the semigroup is finite

    # hence the semigroup is simple
    return true;

end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> ) . . . . . . . . . . . . . . for a zero group
##
##  All groups are simple semigroups. Hence all zero groups are 0-simple.
##
InstallTrueMethod( IsZeroSimpleSemigroup, IsZeroGroup );


#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> ) . . . . . . . . . . . . . . . .  for a group
##
##  A group is not a zero simple semigroup because does not have a zero.
##
InstallMethod( IsZeroSimpleSemigroup,
    "for a ZeroGroup",
    [ IsGroup],
    ReturnFalse );

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> ) . . . . . . . . . .  for a trivial semigroup
##
##  a trivial semigroup is not 0 simple, since S^2=0
##  Moreover is not representable by a Rees Matrix semigroup
##  over a zero group (which has at least two elements)
##
InstallMethod(IsZeroSimpleSemigroup, "for a trivial semigroup",
    [ IsSemigroup and IsTrivial], ReturnFalse );

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> ) . . . . for a semigroup which has generators
##

## A semigroup <S> is 0-simple if and only if it is non-trivial, contains a
## multiplicative zero, and has exactly two J-classes, and S^2<>{0}.

InstallMethod(IsZeroSimpleSemigroup, "for a semigroup with generators",
[IsSemigroup and HasGeneratorsOfSemigroup],
function(s)

  if IsTrivial(s) or MultiplicativeZero(s)=fail then
    return false;
  fi;

  return Length(GreensJClasses(s))=2 and IsRegularSemigroup(s);
end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> )
##
##  for a semigroup with zero which has a MultiplicativeNeutralElement.
##
##  In this case is enough to show that the MultiplicativeNeutralElement
##  is J-less than or equal to all other non-zero elements of S and
##  that if S has only two elements, s^2 is non zero.
##  This is because a MultiplicativeNeutralElement is J greater than or
##  equal to any other element and hence by showing that is less than
##  or equal any other element it follows that J is universal, and
##  therefore the semigroup <S> is simple.
##
##  This time if the semigroup only has two elements than it
##  is simple since for sure the square of the Neutral Element
##  is itself, and hence is non-zero
##
InstallMethod( IsZeroSimpleSemigroup,
  "for a semigroup with a MultiplicativeNeutralElement",
  [ IsSemigroup and HasMultiplicativeNeutralElement ],
function(s)

  local e,        # the enumerator of the semigroup s
        J,          # Green's J relation on the semigroup
        jn,ji,      # J-classes
        zero,# the zero element of s
        i,# loop variable
        neutral;    # the MultiplicativeNeutralElement of s

  e:=Enumerator(s);

   # the trivial semigroup is not 0-simple
  if not(IsBound(e[2])) then
    return false;
  fi;

    # as remarked above, if the semigroup has a neutral element then
    # if it has two elements it is simple
    if not(IsBound(e[3])) then
      return true;
    fi;

  neutral:=MultiplicativeNeutralElement(s);
    zero:=MultiplicativeZero(s);
  J:=GreensJRelation(s);
  jn:=EquivalenceClassOfElementNC(J,neutral);
    i:=1;
    while IsBound(e[i]) do
      if e[i]<>zero then
        ji:=EquivalenceClassOfElementNC(J,e[i]);
        if not(IsGreensLessThanOrEqual(jn,ji)) then
          return false;
        fi;
      fi;
      i:=i+1;
  od;

  return true;
end);

#############################################################################
##
#M  IsZeroSimpleSemigroup( <S> ) . . . . . . . .  for a semigroup with a zero
##
##  This is the general case for a semigroup with a zero.
##
##  A semigroup is 0-simple iff
##  (i) S has two elements and S^2<>0
##  (ii) S has more than two elements and its only J classes are
##       S-0 and 0
##
##  So, in the case when we have at least three elements we are going
##  to fix a non-zero J class and look through the semigroup
##  to check whether there are other non-zero J-classes.
##
##  It returns false if it finds a new non-zero J-class, ie, smg is
##  not 0-simple.
##  It returns true if is finite and only finds one nonzero J-class,
##  that is, the semigroup is 0-simple.
##  It does not terminate if 0-simple but infinite.
##
InstallMethod( IsZeroSimpleSemigroup,
  "for a semigroup",
  [ IsSemigroup ],
    function(s)
    local e,       # the enumerator of the semigroup s
          zero,# the multiplicative zero of the semigroup
          nonzero,# the nonzero el of a semigroup with two elements
          J,        # J relation on s
          b,      # elements of the semigroup
          i,# loop variable
          ja,jb;    # J-classes

  # the enumerator and the multiplicative zero of s
  e:=Enumerator(s);
    zero:=MultiplicativeZero(s);

  # the trivial semigroup is not 0-simple
  if not(IsBound(e[2])) then
    return false;
  fi;

  # next check that if S has two elements, whether the square of the
  # nonzero one is nonzero
  if not(IsBound(e[3])) then
    if e[1]<>zero then
      nonzero:=e[1];
    else
      nonzero:=e[2];
    fi;
    if nonzero^2=zero then
      # then this means that S^2 is the zero set, and hence
      # S is not 0-simple
      return false;
    else
      # S is 0-simple
      return true;
    fi;
  fi;

    # so by now we know that s has at least three elements

    # the J relation on s
  J:=GreensJRelation(s);

    # look for the first non zero element and build its J class
    if e[1]<>zero then
      ja:=EquivalenceClassOfElementNC(J,e[1]);
    else
      ja:=EquivalenceClassOfElementNC(J,e[2]);
    fi;

  # look through all nonzero elements of s
  # to find out if there are more nonzero J classes
    # We do not have to start looking from the first one, since the first
    # one is either zero or else is the element we started with.
    # In the case the first one is zero we can start looking by the 3rd one.
    if e[1]=zero then
      i:=3;
    else
      i:=2;
    fi;

  while IsBound(e[i]) do
    b:=e[i];
      if b<>zero then
        jb:=EquivalenceClassOfElementNC(J,b);
        # if ja and jb are not the same J class then the smg is not simple
        if not(IsGreensLessThanOrEqual(ja,jb)) then
          return false;
        elif not (IsGreensLessThanOrEqual(jb,ja)) then
          return false;
        fi;
      fi;
      i:=i+1;
  od;

  # notice that the above cycle only terminates without returning
  # false if the semigroup is finite

  # hence the semigroup is 0-simple
  return true;

end);


############################################################################
##
#A  ANonReesCongruenceOfSemigroup( <S> ) . . . .  for a finite semigroup <S>
##
##  In this case the following holds:
##  Proposition (A.Solomon): S is Rees Congruence <->
##                           Every congruence generated by a pair is Rees.
##  Proof: -> is immediate.
##        <- Let \rho be some non-Rees congruence in S.
##  Let [a] and [b] be distinct nontrivial congruence classes of \rho.
##  Let a, a' \in [a]. By assumption, the congruence generated
##  by the pair (a, a') is a Rees congruence.
##  Thus, since the kernel K is contained
##  in the nontrivial congruence class of <(a,a')>, and similarly K is contained
##  in the nontrivial congruence class of <(b,b')> for any b, b' \in [b]. Thus
##  we must have that (a,b) \in \rho, contradicting the assumption. \QED
##
##  So, to find a non rees congruence we only have to look within the
##  congruences generated by a pair of elements of <S>. If all
##  of these are Rees it means that there are no Non-rees congruences.
##
##  This method returns a non rees congruence if it exists and
##  fail otherwise
##
##  So we look through all possible pairs of elements of s.
##  We do this by using an iterator for N times N.
##  Notice that for this iterator IsDoneIterator is always false,
##  since there are always a next element in N times N.
##
InstallMethod( ANonReesCongruenceOfSemigroup,
    "for a semigroup",
    [IsSemigroup and IsFinite],
function( s )
    local e,x,y,i,j;

  e := EnumeratorSorted(s);
  for i in [1 .. Length(e)] do
    for j in [i+1 .. Length(e)] do
      x := e[i];
      y := e[j];
      if not IsReesCongruence( SemigroupCongruenceByGeneratingPairs(s, [[x,y]])) then
        return SemigroupCongruenceByGeneratingPairs(s, [[x,y]]);
      fi;
    od;
  od;
  return fail;
end);

RedispatchOnCondition( ANonReesCongruenceOfSemigroup,
    true, [IsSemigroup], [IsFinite], 0);

############################################################################
##
#P  IsReesCongruenceSemigroup( <S> )
##
InstallMethod( IsReesCongruenceSemigroup,
    "for a (possibly infinite) semigroup",
    [ IsSemigroup],
    s -> ANonReesCongruenceOfSemigroup(s) = fail );


#############################################################################
##
#O  HomomorphismFactorSemigroup( <S>, <C> )
#O  HomomorphismFactorSemigroupByClosure( <S>, <L> )
#O  FactorSemigroup( <S>, <C> )
#O  FactorSemigroupByClosure( <S>, <L> )
##
##  In the first form <C> is a congruence and HomomorphismFactorSemigroup,
##  returns a homomorphism $<S> \rightarrow <S>/<C>
##
##  This is the only one which should do any work and is installed
##  in all the appropriate places.
##
##  All implementations of \/ should be done in terms of the above
##  four operations.
##
InstallMethod( HomomorphismFactorSemigroupByClosure,
    "for a semigroup and generating pairs of a congruence",
    IsElmsColls,
  [ IsSemigroup, IsList ],
function(s, l)
    return HomomorphismFactorSemigroup(s,
               SemigroupCongruenceByGeneratingPairs(s,l) );
end);

InstallMethod( HomomorphismFactorSemigroupByClosure,
    "for a semigroup and empty list",
  [ IsSemigroup, IsList and IsEmpty ],
function(s, l)
    return HomomorphismFactorSemigroup(s,
               SemigroupCongruenceByGeneratingPairs(s,l) );
end);

InstallMethod( FactorSemigroup,
    "for a semigroup and a congruence",
  [ IsSemigroup, IsSemigroupCongruence ],
function(s, c)
    if not s = Source(c) then
    TryNextMethod();
  fi;

  return Range(HomomorphismFactorSemigroup(s, c));
end);

InstallMethod( FactorSemigroupByClosure,
  "for a semigroup and generating pairs of a congruence",
  IsElmsColls,
  [ IsSemigroup, IsList ],
function(s, l)
  return Range(HomomorphismFactorSemigroup(s,
    SemigroupCongruenceByGeneratingPairs(s,l) ));
end);


InstallMethod( FactorSemigroupByClosure,
  "for a semigroup and empty list",
  [ IsSemigroup, IsEmpty  and IsList],
function(s, l)
  return Range(HomomorphismFactorSemigroup(s,
    SemigroupCongruenceByGeneratingPairs(s,l) ));
end);

#############################################################################
##
#M  \/( <s>, <rels> ) . . . .  for semigroup and empty list
##
InstallOtherMethod( \/,
    "for a semigroup and an empty list",
    [ IsSemigroup, IsEmpty ],
    FactorSemigroupByClosure );

#############################################################################
##
#M  \/( <s>, <rels> ) . . . .  for semigroup and list of pairs of elements
##
InstallOtherMethod( \/,
    "for semigroup and list of pairs",
    IsElmsColls,
    [ IsSemigroup, IsList ],
    FactorSemigroupByClosure );

#############################################################################
##
#M  \/( <s>, <cong> ) . . . .  for semigroup and congruence
##
InstallOtherMethod( \/,
    "for a semigroup and a congruence",
    [ IsSemigroup, IsSemigroupCongruence ],
    FactorSemigroup );

#############################################################################
##
#M  IsRegularSemigroupElement( <S>, <x> )
##
##  A semigroup element is regular if and only if its DClass is regular,
##  which in turn is regular if and only if every R and L class contains
##  an idempotent.   In the generic case, therefore, we iterate over an
##  elements R class, and look for idempotents.
##
InstallMethod(IsRegularSemigroupElement, "for generic semigroup",
    IsCollsElms, [IsSemigroup, IsAssociativeElement],
function(S, x)
    local r, i;

    if not x in S then
        return false;
    fi;

    r:= EquivalenceClassOfElementNC(GreensRRelation(S), x);
    for i in Iterator(r) do
        if i*i=i then
            # we have found an idempotent.
            return true;
        fi;
    od;

    # no idempotents in R class implies not regular.
    return false;
end);

#############################################################################
##
#M  IsRegularSemigroup( <S> )
##
InstallMethod(IsRegularSemigroup, "for generic semigroup",
    [ IsSemigroup ],
    S -> ForAll( GreensDClasses(S), IsRegularDClass ) );
