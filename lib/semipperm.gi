############################################################################
##
#W  semipperm.gi           GAP library                         J. D. Mitchell
##
##
#Y  Copyright (C)  2013,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation of some basics for partial perm 
##  semigroups.

#

InstallMethod(DisplayString, "for a partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup], 4, ViewString);

#

InstallMethod(ViewString, "for a partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup], 4, #beat the method for inverse semigroups
function(s)
  local str, nrgens;
  
  str:="<";

  if HasIsTrivial(s) and IsTrivial(s) then 
    Append(str, "trivial ");
  else 
    if HasIsCommutative(s) and IsCommutative(s) then 
      Append(str, "commutative ");
    fi;
  fi;

  if HasIsTrivial(s) and IsTrivial(s) then 
  elif HasIsZeroSimpleSemigroup(s) and IsZeroSimpleSemigroup(s) then 
    Append(str, "0-simple ");
  elif HasIsSimpleSemigroup(s) and IsSimpleSemigroup(s) then 
    Append(str, "simple ");
  fi;

  if HasIsInverseSemigroup(s) and IsInverseSemigroup(s) then 
    Append(str, "inverse ");
  fi;

  Append(str, "partial perm ");
 
  if HasIsMonoid(s) and IsMonoid(s) then 
    Append(str, "monoid ");
    if HasIsInverseSemigroup(s) and IsInverseSemigroup(s) then 
      nrgens:=Length(GeneratorsOfInverseMonoid(s));
    else 
      nrgens:=Length(GeneratorsOfMonoid(s));
    fi;
  else 
    Append(str, "semigroup ");
    if HasIsInverseSemigroup(s) and IsInverseSemigroup(s) then 
      nrgens:=Length(GeneratorsOfInverseSemigroup(s));
    else
      nrgens:=Length(GeneratorsOfSemigroup(s));
    fi;
  fi;
 
 if HasIsTrivial(s) and not IsTrivial(s) and HasSize(s) and Size(s)<2^64 then 
    Append(str, "\<\>of size ");
    Append(str, String(Size(s)));
    Append(str, ", ");
  fi;
 
  Append(str, "\<\>on ");
  Append(str, String(RankOfPartialPermSemigroup(s)));
  Append(str, " pts\<\> with ");

  Append(str, String(nrgens));
  Append(str, " generator");

  if nrgens>1 or nrgens=0 then 
    Append(str, "s");
  fi;
  Append(str, ">");

  return str;
end);

InstallMethod(ViewString, 
"for a simple inverse partial perm semigroup with generators",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup 
and IsSimpleSemigroup and IsInverseSemigroup], 
function(s)
  local str, nrgens;
  
  str:="<";

  if HasIsTrivial(s) and IsTrivial(s) then 
    Append(str, "trivial ");
  else 
    if HasIsCommutative(s) and IsCommutative(s) then 
      Append(str, "commutative ");
    fi;
  fi;

  Append(str, "partial perm group ");

  if HasIsMonoid(s) and IsMonoid(s) then 
    nrgens:=Length(GeneratorsOfInverseMonoid(s));
  else 
    nrgens:=Length(GeneratorsOfInverseSemigroup(s));
  fi;
 
 if HasIsTrivial(s) and not IsTrivial(s) and HasSize(s) and Size(s)<2^64 then 
    Append(str, "\<\>of size ");
    Append(str, String(Size(s)));
    Append(str, ", ");
  fi;
 
  Append(str, "\<\>on ");
  Append(str, String(RankOfPartialPermSemigroup(s)));
  Append(str, " pts\<\> with ");

  Append(str, String(nrgens));
  Append(str, " generator");

  if nrgens>1 or nrgens=0 then 
    Append(str, "s");
  fi;
  Append(str, ">");

  return str;
end);

#

InstallMethod(One, "for a partial perm semigroup with generators", 
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local x;
  
  x:=One(GeneratorsOfSemigroup(s));
  if x in s then 
    return x;
  fi;
  return fail;
end);

#

InstallMethod(One, "for a partial perm monoid with generators", 
[IsPartialPermMonoid and HasGeneratorsOfSemigroup],
function(s)
  return One(GeneratorsOfSemigroup(s));
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
"for a partial perm semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> CodegreeOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(CodegreeOfPartialPermCollection,
"for a partial perm semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> CodegreeOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(CodegreeOfPartialPermSemigroup,
"for an inverse partial perm semigroup",
[IsPartialPermSemigroup and IsInverseSemigroup and HasGeneratorsOfSemigroup],
s-> DegreeOfPartialPermSemigroup(s));

InstallMethod(RankOfPartialPermSemigroup,
"for a partial perm semigroup",
[IsPartialPermSemigroup and HasGeneratorsOfSemigroup],
s-> RankOfPartialPermCollection(GeneratorsOfSemigroup(s)));

InstallMethod(RankOfPartialPermCollection,
"for a partial perm semigroup",
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
s-> MovedPoints(GeneratorsOfSemigroup(s)));

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

InstallOtherMethod(OneMutable, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(s)
  local  one;
  one := One(GeneratorsOfSemigroup(s));
  if one in s then
    return one;
  fi;
  return fail;
end);

#

InstallOtherMethod(ZeroMutable, "for a partial perm semigroup",
[IsPartialPermSemigroup],
function(s)
  local  zero;
  zero := Zero(GeneratorsOfSemigroup(s));
  if zero in s then
    return zero;
  fi;
  return fail;
end);

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
function(s)
  local gens, one, pos, f;

  gens:=ShallowCopy(GeneratorsOfMonoid(s));
  one:=One(s);
  for f in gens do
    pos:=Position(gens, f^-1);
    if pos<>fail and (f<>f^-1 or f=one) then 
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
  local gens, pos, f;

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

# isomorphisms

#

InstallMethod(IsomorphismPartialPermSemigroup, 
"for a semigroup with generators",
[IsSemigroup and HasGeneratorsOfSemigroup],
function(S)
  local elts, iso, gens;

  if not IsInverseSemigroup(S) then 
    return fail;
  fi;
  
  elts:=Elements(S);

  iso:=function(x)
    local dom, y;
    y:=InversesOfSemigroupElement(S, x)[1];
    dom:=Set(elts*y);
    return PartialPermNC(List(dom, y-> Position(elts, y)),
     List(List(dom, y-> y*x), y-> Position(elts, y)));
  end;

  gens:=ShallowCopy(GeneratorsOfSemigroup(S));
  Apply(gens, iso);
  return MagmaHomomorphismByFunctionNC(S, InverseSemigroup(gens), iso);
end);

#

InstallMethod(IsomorphismPartialPermMonoid, 
"for a monoid with generators",
[IsMonoid and HasGeneratorsOfMonoid],
function(S)
  local elts, iso, gens;

  if not IsInverseSemigroup(S) then 
    return fail;
  fi;
  
  elts:=Elements(S);

  iso:=function(x)
    local dom, y;
    y:=InversesOfSemigroupElement(S, x)[1];
    dom:=Set(elts*y);
    return PartialPermNC(List(dom, y-> Position(elts, y)),
     List(List(dom, y-> y*x), y-> Position(elts, y)));
  end;

  gens:=ShallowCopy(GeneratorsOfMonoid(S));
  Apply(gens, iso);
  return MagmaHomomorphismByFunctionNC(S, InverseMonoid(gens), iso);
end);

#JDM improve this

InstallMethod(IsomorphismPartialPermMonoid,
"for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local iso;

  if not IsInverseMonoid(s) and MultiplicativeNeutralElement(s)=fail then
    Error("usage: the argument should be an inverse semigroup with ",  
     "a mult. neutral element,");
    return;
  fi;

  iso:=function(f)
  local dom, img;
    dom:=ImageSetOfTransformation(InversesOfSemigroupElement(s, f)[1], 
      DegreeOfTransformationSemigroup(s));
    img:=List(dom, i-> i^f);
    return PartialPermNC(dom, img);
  end;

  return MagmaHomomorphismByFunctionNC(s,
   InverseMonoid(List(GeneratorsOfSemigroup(s), iso)), iso);
end);

#JDM improve this

InstallMethod(IsomorphismPartialPermSemigroup,
"for a transformation semigroup",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local iso;

  if not IsInverseSemigroup(s) then
    Error("usage: the argument should be an inverse semigroup,");
    return;
  fi;

  iso:=function(f)
    local dom, img;
    dom:=ImageSetOfTransformation(InversesOfSemigroupElement(s, f)[1], 
      DegreeOfTransformationSemigroup(s));
    img:=List(dom, i-> i^f);
    return PartialPermNC(dom, img);
  end;

  return MagmaHomomorphismByFunctionNC(s,
   InverseSemigroup(List(GeneratorsOfSemigroup(s), iso)), iso);
end);

#

InstallMethod(IsomorphismPartialPermMonoid, "for a perm group",
[IsPermGroup],
function(g)
  local dom;
  dom:=MovedPoints(g);
  return MagmaIsomorphismByFunctionsNC(g,
   InverseMonoid(List(GeneratorsOfGroup(g), p-> AsPartialPerm(p, dom))), 
   p-> AsPartialPerm(p, dom), f-> AsPermutation(f));
end);

#

InstallMethod(IsomorphismPartialPermSemigroup, "for a perm group",
[IsPermGroup],
function(g)
  local dom;
  dom:=MovedPoints(g);
  return MagmaIsomorphismByFunctionsNC(g,
   InverseSemigroup(List(GeneratorsOfGroup(g), p-> AsPartialPerm(p, dom))), 
   p-> AsPartialPerm(p, dom), f-> AsPermutation(f));
end);

#

InstallMethod(IsomorphismPartialPermMonoid, "for a partial perm monoid", 
[IsPartialPermMonoid], 
function(s)
  return MagmaIsomorphismByFunctionsNC(s, s, IdFunc, IdFunc);
end);

#

InstallMethod(IsomorphismPartialPermMonoid, 
"for a partial perm semigroup",
[IsPartialPermSemigroup],
function(s)
  local t;

  if IsInverseSemigroup(s) then 
    t:=AsInverseMonoid(s);
  else 
    t:=AsMonoid(s);
  fi;
  if t=fail then 
    return fail;
  fi;
  return MagmaIsomorphismByFunctionsNC(s, t, IdFunc, IdFunc); 
end);

#

InstallMethod(SymmetricInverseSemigroup, "for a integer",
[IsInt],
function(n)
  local s;

  if n<0 then
    Error("usage: the argument should be a non-negative integer,");
    return;
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

InstallMethod(ViewString, "for a symmetric inverse semigroup",
[IsSymmetricInverseSemigroup], 10,
function(s)
  return STRINGIFY("<symmetric inverse semigroup on ",
   DegreeOfPartialPermSemigroup(s), " pts>");
end);

InstallMethod(IsSymmetricInverseSemigroup, 
"for a semigroup", [IsSemigroup], ReturnFalse);

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

  elts:=ShallowCopy(Elements(s));  
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

  elts:=ShallowCopy(Elements(s));  
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

