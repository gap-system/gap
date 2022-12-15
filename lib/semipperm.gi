#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include J. D. Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation of some basics for partial perm
##  semigroups.

InstallMethod(PrintObj,
"for a semigroup with known generators",
[IsPartialPermSemigroup and IsGroup and HasGeneratorsOfMagma],
function(S)
  Print("Group(", GeneratorsOfMagma(S), ")");
end);

InstallMethod(DisplayString, "for a partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup], ViewString);

InstallMethod(SemigroupViewStringPrefix, "for a partial perm semigroup",
[IsPartialPermSemigroup], S -> "\>partial perm\< ");

InstallMethod(SemigroupViewStringSuffix, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  return Concatenation("\>rank \>",
                       ViewString(RankOfPartialPermSemigroup(S)),
                       "\<\< ");
end);

InstallMethod(OneMutable, "for a partial perm semigroup",
[IsPartialPermSemigroup], OneImmutable);

# The next method matches more than one declaration, hence the
# InstallOtherMethod to avoid warnings on startup

InstallOtherMethod(OneImmutable, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  local x;
  if HasGeneratorsOfSemigroup(S) then
    x := OneImmutable(GeneratorsOfSemigroup(S));
  else
    x := OneImmutable(AsList(S));
  fi;

  if x in S then
    return x;
  fi;
  return fail;
end);

# The next method matches more than one declaration, hence the
# InstallOtherMethod to avoid warnings on startup

InstallOtherMethod(OneImmutable, "for a partial perm monoid",
[IsPartialPermMonoid],
function(S)
  return One(GeneratorsOfSemigroup(S));
end);

#

InstallTrueMethod(IsFinite, IsPartialPermSemigroup);

#

InstallMethod(DegreeOfPartialPermSemigroup,
"for a partial perm semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> DegreeOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(DegreeOfPartialPermCollection,
"for a partial perm semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> DegreeOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(CodegreeOfPartialPermSemigroup,
"for a partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> CodegreeOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(CodegreeOfPartialPermCollection,
"for a partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> CodegreeOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(CodegreeOfPartialPermSemigroup,
"for an inverse partial perm semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup and HasGeneratorsOfSemigroup],
s-> DegreeOfPartialPermSemigroup(s));

InstallMethod(RankOfPartialPermSemigroup,
"for a partial perm semigroup with generators of semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
S -> RankOfPartialPermCollection(GeneratorsOfSemigroup(S)));

InstallMethod(RankOfPartialPermSemigroup,
"for a partial perm monoid",
[IsPartialPermMonoid],
S -> RankOfPartialPerm(One(S)));

InstallMethod(RankOfPartialPermCollection,
"for a partial perm semigroup with generators of semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> RankOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(DomainOfPartialPermCollection,
"for a partal perm semigroup",
[IsPartialPermSemigroup],
s-> DomainOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(ImageOfPartialPermCollection,
"for a partal perm semigroup",
[IsPartialPermSemigroup],
s-> ImageOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(FixedPointsOfPartialPerm, "for a partial perm semigroup",
[IsPartialPermSemigroup],
s-> FixedPointsOfPartialPerm(GeneratorsOfSemigroup(s)));

InstallMethod(MovedPoints, "for a partial perm semigroup",
[IsPartialPermSemigroup],
s-> MovedPoints(GeneratorsOfSemigroup(s)));

InstallMethod(NrFixedPoints, "for a partial perm semigroup",
[IsPartialPermSemigroup],
s-> NrFixedPoints(GeneratorsOfSemigroup(s)));

InstallMethod(NrMovedPoints, "for a partial perm semigroup",
[IsPartialPermSemigroup],
s-> NrMovedPoints(GeneratorsOfSemigroup(s)));

InstallMethod(LargestMovedPoint, "for a partial perm semigroup",
[IsPartialPermSemigroup], s-> LargestMovedPoint(GeneratorsOfSemigroup(s)));

InstallMethod(LargestImageOfMovedPoint, "for a partial perm semigroup",
[IsPartialPermSemigroup],
s-> LargestImageOfMovedPoint(GeneratorsOfSemigroup(s)));

InstallMethod(SmallestMovedPoint, "for a partial perm semigroup",
[IsPartialPermSemigroup], s-> SmallestMovedPoint(GeneratorsOfSemigroup(s)));

InstallMethod(SmallestImageOfMovedPoint, "for a partial perm semigroup",
[IsPartialPermSemigroup],
s-> SmallestImageOfMovedPoint(GeneratorsOfSemigroup(s)));

#

InstallMethod(GeneratorsOfInverseSemigroup,
"for an inverse partial perm semigroup with generators",
[IsPartialPermSemigroup and IsInverseSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local gens, pos, f;

  gens:=ShallowCopy(GeneratorsOfSemigroup(s));
  for f in gens do
    pos:=Position(gens, f^-1);
    if pos<>fail and f<>f^-1 then
      Remove(gens, pos);
    fi;
  od;
  MakeImmutable(gens);
  return gens;
end);

#

InstallMethod(GeneratorsOfInverseMonoid,
"for an inverse partial perm monoid with generators",
[IsPartialPermSemigroup and IsInverseMonoid and HasGeneratorsOfMonoid],
function(S)
  local gens, pos, x;

  gens := ShallowCopy(GeneratorsOfMonoid(S));
  for x in gens do
    pos := Position(gens, x ^ -1);
    if pos <> fail and x <> x ^ -1  then
      Remove(gens, pos);
    fi;
  od;
  MakeImmutable(gens);
  return gens;
end);

#

InstallImmediateMethod(GeneratorsOfSemigroup,
IsPartialPermSemigroup and HasGeneratorsOfInverseSemigroup, 0,
function(s)
  local gens, f;

  gens:=ShallowCopy(GeneratorsOfInverseSemigroup(s));
  for f in gens do
    if DomainOfPartialPerm(f)<>ImageSetOfPartialPerm(f) and not f^-1 in gens
     then
      Add(gens, f^-1);
    fi;
  od;
  MakeImmutable(gens);
  return gens;
end);

#

InstallImmediateMethod(GeneratorsOfMonoid,
IsPartialPermMonoid and HasGeneratorsOfInverseMonoid, 0,
function(s)
  local gens, f;

  gens:=ShallowCopy(GeneratorsOfInverseMonoid(s));
  for f in gens do
    if DomainOfPartialPerm(f)<>ImageSetOfPartialPerm(f)
     and not f^-1 in gens then
      Add(gens, f^-1);
    fi;
  od;
  MakeImmutable(gens);
  return gens;
end);

# Isomorphism from an arbitrary inverse semigroup/monoid to a partial perm
# semigroup/monoid, this is the fall back method

InstallMethod(IsomorphismPartialPermSemigroup, "for a semigroup",
[IsSemigroup],
function(S)
  local set, iso, gens, T;

  if not IsInverseSemigroup(S) then
    ErrorNoReturn("the argument must be an inverse semigroup");
  fi;

  set := AsSet(S);

  iso := function(x)
    local dom;
    dom := Set(set * InversesOfSemigroupElement(S, x)[1]);
    return PartialPermNC(List(dom, y -> Position(set, y)),
                         List(List(dom, y -> y * x),
                              y -> Position(set, y)));
  end;

  if HasGeneratorsOfSemigroup(S) then
    gens := GeneratorsOfSemigroup(S);
  else
    gens := set;
  fi;

  T := InverseSemigroup(List(gens, iso));
  UseIsomorphismRelation(S, T);

  return MagmaHomomorphismByFunctionNC(S, T, iso);
end);

InstallMethod(IsomorphismPartialPermMonoid, "for a semigroup",
[IsSemigroup],
function(S)
  local iso1, inv1, iso2, inv2;

  if MultiplicativeNeutralElement(S) = fail then
    ErrorNoReturn("the argument must be a semigroup with a ",
                  "multiplicative neutral element");
  elif not IsInverseSemigroup(S) then
    ErrorNoReturn("the argument must be an inverse semigroup");
  fi;

  iso1 := IsomorphismTransformationMonoid(S);
  inv1 := InverseGeneralMapping(iso1);
  iso2 := IsomorphismPartialPermSemigroup(Range(iso1));
  inv2 := InverseGeneralMapping(iso2);
  UseIsomorphismRelation(S, Range(iso2));

  return MagmaIsomorphismByFunctionsNC(S,
                                       Range(iso2),
                                       x -> (x ^ iso1) ^ iso2,
                                       x -> (x ^ inv2) ^ inv1);
end);

# Isomorphisms from a partial perm semigroups/monoids to a partial perm
# semigroup/monoid

InstallMethod(IsomorphismPartialPermSemigroup, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  return MagmaIsomorphismByFunctionsNC(S, S, IdFunc, IdFunc);
end);

InstallMethod(IsomorphismPartialPermMonoid, "for a partial perm monoid",
[IsPartialPermMonoid],
function(S)
  return MagmaIsomorphismByFunctionsNC(S, S, IdFunc, IdFunc);
end);

InstallMethod(IsomorphismPartialPermMonoid,
"for a partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  local T;

  if MultiplicativeNeutralElement(S) = fail then
    ErrorNoReturn("the argument must be a semigroup with a ",
                  "multiplicative neutral element");
  fi;

  # In this case One(S) = MultiplicativeNeutralElement(S), but we want to make
  # sure that the range of the returned isomorphism is really a monoid

  if IsInverseSemigroup(S) and HasGeneratorsOfInverseSemigroup(S) then
    T := AsInverseMonoid(S);
  else
    T := AsMonoid(S);
  fi;
  UseIsomorphismRelation(S, T);

  return MagmaIsomorphismByFunctionsNC(S, T, IdFunc, IdFunc);
end);

# Isomorphism from an inverse transformation semigroup/monoid to a partial perm
# semigroup/monoid

InstallMethod(IsomorphismPartialPermSemigroup,
"for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(S)
  local deg, iso, T;

  if not IsInverseSemigroup(S) then
    ErrorNoReturn("the argument must be an inverse semigroup");
  fi;

  deg := DegreeOfTransformationSemigroup(S);

  iso := function(x)
    local y, dom;
    y := InversesOfSemigroupElement(S, x)[1];
    dom := ImageSetOfTransformation(y, deg);
    return PartialPerm(dom, List(dom, i -> i ^ x));
  end;

  T := InverseSemigroup(List(GeneratorsOfSemigroup(S), iso));
  UseIsomorphismRelation(S, T);

  return MagmaHomomorphismByFunctionNC(S, T, iso);
end);

# Isomorphisms from perm groups to partial perm semigroups/monoids

InstallMethod(IsomorphismPartialPermMonoid,
"for a perm group with generators",
[IsPermGroup and HasGeneratorsOfGroup],
function(G)
  local dom, S;

  dom := MovedPoints(G);
  if IsEmpty(GeneratorsOfGroup(G)) then
    S := InverseMonoid(EmptyPartialPerm());
  else
    S := InverseMonoid(List(GeneratorsOfGroup(G), p -> AsPartialPerm(p, dom)));
  fi;
  UseIsomorphismRelation(G, S);
  SetIsGroupAsSemigroup(S, true);

  return MagmaIsomorphismByFunctionsNC(G,
                                       S,
                                       p -> AsPartialPerm(p, dom),
                                       AsPermutation);
end);

InstallMethod(IsomorphismPartialPermSemigroup,
"for a perm group with generators",
[IsPermGroup and HasGeneratorsOfGroup],
function(G)
  local dom, S;

  dom := MovedPoints(G);
  if IsEmpty(GeneratorsOfGroup(G)) then
    S := InverseSemigroup(EmptyPartialPerm());
  else
    S := InverseSemigroup(List(GeneratorsOfGroup(G),
                               p -> AsPartialPerm(p, dom)));
  fi;
  UseIsomorphismRelation(G, S);
  SetIsGroupAsSemigroup(S, true);

  return MagmaIsomorphismByFunctionsNC(G,
                                       S,
                                       p -> AsPartialPerm(p, dom),
                                       AsPermutation);
end);
#

InstallMethod(SymmetricInverseSemigroup, "for a integer",
[IsInt],
function(n)
  local s;

  if n<0 then
    ErrorNoReturn("the argument should be a non-negative integer");
  elif n=0 then
    s:=InverseMonoid(PartialPermNC([]));
  elif n=1 then
    s:=InverseMonoid(PartialPermNC([1]), PartialPermNC([]));
  elif n=2 then
    s:=InverseMonoid(PartialPermNC([2,1]), PartialPermNC([1]));;
  else
    s:=InverseMonoid(List(GeneratorsOfGroup(SymmetricGroup(n)), x->
     PartialPermNC(ListPerm(x, n))), PartialPermNC([0..n-1]*1));
  fi;

  SetIsSymmetricInverseSemigroup(s, true);
  return s;
end);

#

InstallMethod(ViewString, "for a symmetric inverse monoid",
[IsSymmetricInverseSemigroup and IsPartialPermSemigroup], SUM_FLAGS,
function(S)
  return STRINGIFY("<symmetric inverse monoid of degree ",
                   DegreeOfPartialPermSemigroup(S), ">");
end);

#InstallMethod(IsSymmetricInverseSemigroup,
#"for a semigroup", [IsSemigroup], ReturnFalse);

#

InstallMethod(IsSymmetricInverseSemigroup,
"for a partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
function(s)
  return ForAll(GeneratorsOfSemigroup(
   SymmetricInverseSemigroup(DegreeOfPartialPermSemigroup(s))),
    x-> x in s);
end);

#

InstallMethod(NaturalPartialOrder,
"for an inverse partial perm semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup],
function(s)
  local elts, p, n, out, i, j;

  elts:=ShallowCopy(AsSSortedList(s));
  p:=Sortex(elts, ShortLexLeqPartialPerm)^-1;
  n:=Length(elts);
  out:=List([1..n], x-> []);
  for i in [n, n-1..2] do
    for j in [i-1,i-2 ..1] do
      if NaturalLeqPartialPerm(elts[j], elts[i]) then
        AddSet(out[i], j);
      fi;
    od;
  od;
  Perform(out, ShrinkAllocationPlist);
  Apply(out, x-> OnSets(x, p));
  return Permuted(out, p);
end);

#

InstallMethod(ReverseNaturalPartialOrder,
"for an inverse partial perm semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup],
function(s)
  local elts, p, n, out, i, j;

  elts:=ShallowCopy(AsSSortedList(s));
  p:=Sortex(elts, ShortLexLeqPartialPerm)^-1;
  n:=Length(elts);
  out:=List([1..n], x-> []);
  for i in [1..n-1] do
    for j in [i+1..n] do
      if NaturalLeqPartialPerm(elts[i], elts[j]) then
        AddSet(out[i], j);
      fi;
    od;
  od;
  Perform(out, ShrinkAllocationPlist);
  Apply(out, x-> OnSets(x, p));
  return Permuted(out, p);
end);

