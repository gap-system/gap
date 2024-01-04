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
##  This file contains the implementation of some basics for transformation
##  semigroups and is based on earlier code of Isabel Araújo and Robert Arthur.
##

InstallMethod(PrintObj,
"for a semigroup with known generators",
[IsTransformationSemigroup and IsGroup and HasGeneratorsOfMagma],
function(S)
  Print("Group( ", GeneratorsOfMagma(S), " )");
end);

InstallMethod(SemigroupViewStringPrefix, "for a transformation semigroup",
[IsTransformationSemigroup], S -> "\>transformation\< ");

InstallMethod(SemigroupViewStringSuffix, "for a transformation semigroup",
[IsTransformationSemigroup],
function(S)
  return Concatenation("\>degree \>",
                       ViewString(DegreeOfTransformationSemigroup(S)),
                       "\<\< ");
end);

InstallMethod(\<, "for transformation semigroups",
[IsTransformationSemigroup, IsTransformationSemigroup],
function(S, T)
  return AsSet(S)<AsSet(T);
end);

InstallMethod(MovedPoints, "for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
s-> MovedPoints(GeneratorsOfSemigroup(s)));

InstallMethod(NrMovedPoints, "for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
s-> NrMovedPoints(GeneratorsOfSemigroup(s)));

InstallMethod(LargestMovedPoint, "for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
s-> LargestMovedPoint(GeneratorsOfSemigroup(s)));

InstallMethod(SmallestMovedPoint, "for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
s-> SmallestMovedPoint(GeneratorsOfSemigroup(s)));

InstallMethod(LargestImageOfMovedPoint, "for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
s-> LargestImageOfMovedPoint(GeneratorsOfSemigroup(s)));

InstallMethod(SmallestImageOfMovedPoint, "for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
s-> SmallestImageOfMovedPoint(GeneratorsOfSemigroup(s)));

#

InstallMethod(DisplayString, "for a transformation semigroup with generators",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup], ViewString);

#

InstallMethod(ViewString, "for a full transformation semigroup",
[IsTransformationSemigroup and IsFullTransformationSemigroup and
 HasGeneratorsOfSemigroup], SUM_FLAGS,
function(S)
  return STRINGIFY("<full transformation monoid of degree ",
                   DegreeOfTransformationSemigroup(S), ">");
end);

InstallMethod(AsMonoid,
"for transformation semigroup with generators",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(S)
  if MultiplicativeNeutralElement(S) = fail then
    return fail;
  fi;
  return Range(IsomorphismTransformationMonoid(S));
end);

#

InstallTrueMethod(IsFinite, IsTransformationSemigroup);

#

InstallMethod(DegreeOfTransformationSemigroup,
"for a transformation semigroup with generators",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(s)
  return DegreeOfTransformationCollection(GeneratorsOfSemigroup(s));
end);

#

InstallMethod(DegreeOfTransformationSemigroup,
"for a transformation group with generators",
[IsTransformationSemigroup and HasGeneratorsOfGroup],
function(S)
  if not IsEmpty(GeneratorsOfGroup(S)) then
    return DegreeOfTransformationCollection(GeneratorsOfGroup(S));
  else # What is an example where this can happen?
    return DegreeOfTransformationCollection(GeneratorsOfSemigroup(S));
  fi;
end);

#

InstallMethod(IsomorphismPermGroup,
"for a group H-class of a semigroup",
[IsGreensHClass],
function( h )
  local enum, permgroup, i, perm, j, elts;

  if not IsFinite(h) then
    # What is an example where this can happen?
    TryNextMethod();
  fi;

  if not IsGroupHClass(h) then
    # What is an example where this can happen?
    ErrorNoReturn("can only create isomorphisms of group H-classes");
  fi;

  elts:=[];
  enum := Enumerator( h );
  permgroup:=Group(());
  i := 1;
  while IsBound( enum[ i ] ) do
    perm := [];
    j := 1;
    while IsBound( enum[ j ] ) do
      perm[j]:=Position( enum, enum[j] * enum[ i ] );
      j := j+1;
    od;
    elts[i]:=PermList(perm);
    permgroup:=ClosureGroup(permgroup, elts[i]);
    i := i+1;
  od;

  return MappingByFunction( h, permgroup, a -> elts[Position( enum, a )],
                a -> enum[Position( elts, a )]);
end);

# TODO can this be removed? It doesn't seem to work

InstallMethod(IsomorphismTransformationSemigroup,
"for a semigroup of general mappings",
[IsSemigroup and IsGeneralMappingCollection and HasGeneratorsOfSemigroup],
function( s )
  local egens, gens, mapfun;

  egens := GeneratorsOfSemigroup(s);
  if not ForAll(egens, IsMapping) then
    return fail;
  fi;

  gens := List(egens, g->TransformationRepresentation(g)!.transformation);
  mapfun := a -> TransformationRepresentation(a)!.transformation;

  return MagmaHomomorphismByFunctionNC( s, Semigroup(gens), mapfun );
end);

#

InstallGlobalFunction(FullTransformationSemigroup,
function(d)
  local gens, s, i;

  if not IsPosInt(d) then
    ErrorNoReturn("the argument must be a positive integer");
  fi;

  if d =1 then
    gens:=[Transformation([1])];
  elif d=2 then
    gens:=[Transformation([2,1]), Transformation([1,1])];
  else
    gens:=List([1..3], x-> EmptyPlist(d));
    gens[1][d]:=1; gens[2][1]:=2; gens[2][2]:=1; gens[3][d]:=1;
    for i in [1..d-1] do
      gens[1][i]:=i+1;
      gens[3][i]:=i;
    od;
    for i in [3..d] do
      gens[2][i]:=i;
    od;
    Apply(gens, Transformation);
  fi;

  s:=Monoid(gens);

  SetSize(s,d^d);
  SetIsFullTransformationSemigroup(s,true);
  SetIsRegularSemigroup(s, true);
  return s;
end);

#

InstallMethod(IsFullTransformationSemigroup, "for a semigroup",
[IsSemigroup], ReturnFalse);

#

InstallMethod(IsFullTransformationSemigroup, "for a transformation semigroup",
[IsTransformationSemigroup],
function(s)
  local n, t;

  n := DegreeOfTransformationSemigroup(s);

  if n = 0 and HasIsTrivial(s) and IsTrivial(s) then
    return true;
  elif HasSize(s) then
    return Size(s)=n^n;
  fi;

  t:=FullTransformationSemigroup(DegreeOfTransformationSemigroup(s));
  return ForAll(GeneratorsOfSemigroup(t), x-> x in s);
end);

#

InstallMethod(\in,
"for a transformation and a full transformation semigroup",
[IsTransformation, IsFullTransformationSemigroup],
function(e,tn)
  return DegreeOfTransformation(e)<=DegreeOfTransformationSemigroup(tn);
end);

#

InstallMethod(Enumerator, "for a full transformation semigroup",
[IsFullTransformationSemigroup], 5,
#to beat the method for an acting semigroup with generators
function(S)
  local n;

  n:=DegreeOfTransformationSemigroup(S);

  return EnumeratorByFunctions(S, rec(

    ElementNumber:=function(enum, pos)
      if pos>n^n then
        return fail;
      fi;
      return TransformationNumber(pos, n);
    end,

    NumberElement:=function(enum, elt)
      if DegreeOfTransformation(elt)>n then
        return fail;
      fi;
      return NumberTransformation(elt, n);
    end,

    Length:=function(enum);
      return Size(S);
    end,

    Membership:=function(elt, enum)
      return elt in S;
    end,

    # n is either 0 or >= 2, so do not use Pluralize on "pts" in the following
    PrintObj:=function(enum)
      Print("<enumerator of full transformation semigroup on ", n," pts>");
    end));
end);

# Isomorphism from an arbitrary semigroup to a transformation semigroup, this
# is the fall back method

InstallMethod(IsomorphismTransformationSemigroup, "for a semigroup",
[IsSemigroup],
function(S)
  local en, gens, dom, act, pos, T;

  en := EnumeratorSorted(S);

  if HasGeneratorsOfSemigroup(S) then
    gens := GeneratorsOfSemigroup(S);
  else
    gens := en;
  fi;

  if HasMultiplicativeNeutralElement(S)
    and MultiplicativeNeutralElement(S) <> fail then
    dom := en;
    act := OnRight;
    pos := Position(en, MultiplicativeNeutralElement(S));
  else
    dom := [1 .. Length(en) + 1];
    act := function(i, x)
      if i <= Length(en) then
        return Position(en, en[i] * x);
      fi;
      return Position(en, x);
    end;
    pos := Length(en) + 1;
  fi;

  T := Semigroup(List(gens, x -> TransformationOp(x, dom, act)));
  UseIsomorphismRelation(S, T);

  return MagmaIsomorphismByFunctionsNC(S,
                                       T,
                                       x -> TransformationOp(x, dom, act),
                                       x -> en[pos ^ x]);
end);

# Isomorphism from an IsMonoidAsSemigroup to a transformation monoid, this
# is the fall back method

InstallMethod(IsomorphismTransformationMonoid, "for a semigroup",
[IsSemigroup],
function(S)
  local iso1, inv1, iso2, inv2;

  if MultiplicativeNeutralElement(S) = fail then
    ErrorNoReturn("the argument must be a semigroup with a ",
                  "multiplicative neutral element");
  fi;

  iso1 := IsomorphismTransformationSemigroup(S);
  inv1 := InverseGeneralMapping(iso1);
  iso2 := IsomorphismTransformationMonoid(Range(iso1));
  inv2 := InverseGeneralMapping(iso2);
  UseIsomorphismRelation(S, Range(iso2));

  return MagmaIsomorphismByFunctionsNC(S,
                                       Range(iso2),
                                       x -> (x ^ iso1) ^ iso2,
                                       x -> (x ^ inv2) ^ inv1);
end);

# Isomorphism from an IsMonoidAsSemigroup transformation semigroup to a
# transformation monoid

InstallMethod(IsomorphismTransformationMonoid,
"for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(S)
  local id, dom, T, inv;

  if IsMonoid(S) then
    return MappingByFunction(S, S, IdFunc, IdFunc);
  fi;

  if MultiplicativeNeutralElement(S) = fail then
    ErrorNoReturn("the argument must be a semigroup with a ",
                  "multiplicative neutral element");
  fi;

  id := MultiplicativeNeutralElement(S);
  dom := ImageSetOfTransformation(id, DegreeOfTransformationSemigroup(S));

  T := Monoid(List(GeneratorsOfSemigroup(S),
                   x -> TransformationOp(x, dom)));
  UseIsomorphismRelation(S, T);

  inv := function(x)
    local out, i;

    out := [1 .. DegreeOfTransformationSemigroup(S)];
    for i in [1 .. Length(dom)] do
      out[dom[i]] := dom[i ^ x];
    od;
    return id * Transformation(out);
  end;

  return MagmaIsomorphismByFunctionsNC(S,
                                       T,
                                       x -> TransformationOp(x, dom),
                                       inv);
end);

InstallMethod(IsomorphismTransformationSemigroup,
"for a transformation semigroup",
[IsTransformationSemigroup],
SUM_FLAGS,
IdentityMapping);

InstallMethod(IsomorphismTransformationSemigroup, "for partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  local n, T, inv;

  n := Maximum(DegreeOfPartialPermCollection(S),
               CodegreeOfPartialPermCollection(S)) + 1;

  T := Semigroup(List(GeneratorsOfSemigroup(S), x -> AsTransformation(x, n)));
  UseIsomorphismRelation(S, T);

  inv := function(x)
    local out, j, i;
    out := [];
    for i in [1 .. n - 1] do
      j := i ^ x;
      if j <> n then
        out[i] := j;
      else
        out[i] := 0;
      fi;
    od;
    return PartialPerm(out);
  end;

  return MagmaIsomorphismByFunctionsNC(S,
                                       T,
                                       x -> AsTransformation(x, n),
                                       inv);
end);

InstallMethod(IsomorphismTransformationMonoid, "for partial perm semigroup",
[IsPartialPermSemigroup],
function(S)
  local n, T, inv;

  if not (IsMonoid(S) or One(S) <> fail) then
    ErrorNoReturn("the argument must be a semigroup with a ",
                  "multiplicative neutral element");
    # in the case of partial perm semigroups having a One is the equivalent to
    # having a MultiplicativeNeutralElement
  fi;

  n := Maximum(DegreeOfPartialPermCollection(S),
               CodegreeOfPartialPermCollection(S)) + 1;

  T := Monoid(List(GeneratorsOfSemigroup(S), x -> AsTransformation(x, n)));
  UseIsomorphismRelation(S, T);

  inv := function(x)
    local out, j, i;
    out := [];
    for i in [1 .. n - 1] do
      j := i ^ x;
      if j <> n then
        out[i] := j;
      else
        out[i] := 0;
      fi;
    od;
    return PartialPerm(out);
  end;

  return MagmaIsomorphismByFunctionsNC(S,
                                       T,
                                       x -> AsTransformation(x, n),
                                       inv);
end);

# Isomorphisms from perm groups to transformation semigroups/monoids

InstallMethod(IsomorphismTransformationMonoid,
"for a perm group with generators",
[IsPermGroup and HasGeneratorsOfGroup],
function(G)
  local S;

  S := Monoid(List(GeneratorsOfGroup(G), AsTransformation));
  UseIsomorphismRelation(G, S);
  SetIsGroupAsSemigroup(S, true);

  return MagmaIsomorphismByFunctionsNC(G, S, AsTransformation, AsPermutation);
end);

InstallMethod(IsomorphismTransformationSemigroup,
"for a perm group with generators",
[IsPermGroup and HasGeneratorsOfGroup],
function(G)
  local S;

  # The next line has to use Semigroup instead of Monoid so that S has the
  # correct set of generators
  S := Semigroup(List(GeneratorsOfGroup(G), AsTransformation));
  UseIsomorphismRelation(G, S);
  SetIsGroupAsSemigroup(S, true);

  return MagmaIsomorphismByFunctionsNC(G, S, AsTransformation, AsPermutation);
end);

InstallMethod(AntiIsomorphismTransformationSemigroup, "for a semigroup",
[IsSemigroup],
function(S)
  local en, gens, dom, act, pos, T;

  en := EnumeratorSorted(S);

  if HasGeneratorsOfSemigroup(S) then
    gens := GeneratorsOfSemigroup(S);
  else
    gens := en;
  fi;

  if HasMultiplicativeNeutralElement(S)
    and MultiplicativeNeutralElement(S) <> fail then
    dom := en;
    act := function(pt, x)
      return x * pt;
    end;
    pos := Position(en, MultiplicativeNeutralElement(S));
  else
    dom := [1 .. Length(en) + 1];
    act := function(i, x)
      if i <= Length(en) then
        return Position(en, x * en[i]);
      fi;
      return Position(en, x);
    end;
    pos := Length(en) + 1;
  fi;

  T := Semigroup(List(gens, x -> TransformationOp(x, dom, act)));

  return MagmaIsomorphismByFunctionsNC(S,
                                       T,
                                       x -> TransformationOp(x, dom, act),
                                       x -> en[pos ^ x]);
end);
