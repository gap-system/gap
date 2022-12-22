#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include James D. Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later

InstallMethod(IsGeneratorsOfMagmaWithInverses,
 "for a partial perm collection",
[IsPartialPermCollection],
function(coll)
  return ForAll(coll, x -> DomainOfPartialPerm(x)
                           = DomainOfPartialPerm(coll[1])
                           and
                           ImageSetOfPartialPerm(x)
                           = DomainOfPartialPerm(coll[1]));
end);

# attributes

InstallMethod(DomainOfPartialPerm, "for a partial perm",
[IsPartialPerm], DOMAIN_PPERM);

InstallMethod(ImageListOfPartialPerm, "for a partial perm",
[IsPartialPerm], IMAGE_PPERM);

InstallMethod(ImageSetOfPartialPerm, "for a partial perm",
[IsPartialPerm], IMAGE_SET_PPERM);

InstallMethod(IndexPeriodOfPartialPerm, "for a partial perm",
[IsPartialPerm], INDEX_PERIOD_PPERM);

InstallMethod(SmallestIdempotentPower, "for a partial perm",
[IsPartialPerm], SMALLEST_IDEM_POW_PPERM);

InstallMethod(ComponentRepsOfPartialPerm, "for a partial perm",
[IsPartialPerm], COMPONENT_REPS_PPERM);

InstallMethod(NrComponentsOfPartialPerm, "for a partial perm",
[IsPartialPerm], NR_COMPONENTS_PPERM);

InstallMethod(ComponentsOfPartialPerm, "for a partial perm",
[IsPartialPerm], COMPONENTS_PPERM);

InstallMethod(IsIdempotent, "for a partial perm",
[IsPartialPerm], IS_IDEM_PPERM);

InstallMethod(IsOne, "for a partial perm",
[IsPartialPerm], IS_IDEM_PPERM);

InstallMethod(FixedPointsOfPartialPerm, "for a partial perm",
[IsPartialPerm], FIXED_PTS_PPERM);

InstallMethod(NrFixedPoints, "for a partial perm",
[IsPartialPerm], NR_FIXED_PTS_PPERM);

InstallMethod(MovedPoints, "for a partial perm",
[IsPartialPerm], MOVED_PTS_PPERM);

InstallMethod(NrMovedPoints, "for a partial perm",
[IsPartialPerm], NR_MOVED_PTS_PPERM);

InstallMethod(LargestMovedPoint, "for a partial perm",
[IsPartialPerm], LARGEST_MOVED_PT_PPERM);

InstallMethod(LargestImageOfMovedPoint, "for a partial perm",
[IsPartialPerm],
function(f)
  local max, i;

  if IsOne(f) then
    return 0;
  fi;

  max := 0;
  for i in [SmallestMovedPoint(f) .. LargestMovedPoint(f)] do
    if i ^ f > max then
      max := i ^ f;
    fi;
  od;
  return max;
end);

InstallMethod(SmallestMovedPoint, "for a partial perm",
[IsPartialPerm],
function(f)
  local m;
  m := SMALLEST_MOVED_PT_PPERM(f);
  if m = fail then
    return infinity;
  else
    return m;
  fi;
end);

InstallMethod(SmallestImageOfMovedPoint, "for a partial perm",
[IsPartialPerm],
function(f)
  local min, j, i;

  if IsOne(f) then
    return infinity;
  fi;

  min := CoDegreeOfPartialPerm(f);
  for i in [SmallestMovedPoint(f) .. LargestMovedPoint(f)] do
    j := i ^ f;
    if j > 0 and j < min then
      min := j;
    fi;
  od;
  return min;
end);

InstallMethod(LeftOne, "for a partial perm",
[IsPartialPerm], LEFT_ONE_PPERM);

InstallMethod(RightOne, "for a partial perm",
[IsPartialPerm], RIGHT_ONE_PPERM);

# operations

InstallMethod(PreImagePartialPerm,
"for a partial perm and positive integer",
[IsPartialPerm, IsPosInt and IsSmallIntRep], PREIMAGE_PPERM_INT);

InstallMethod(ComponentPartialPermInt,
"for a partial perm and positive integer",
[IsPartialPerm, IsPosInt and IsSmallIntRep], COMPONENT_PPERM_INT);

InstallGlobalFunction(JoinOfPartialPerms,
function(arg)
  local join, i;

  if IsPartialPermCollection(arg[1]) then
    return CallFuncList(JoinOfPartialPerms, arg[1]);
  elif not IsPartialPermCollection(arg) then
    ErrorNoReturn("usage: the argument should be a collection of partial ",
                  "perms,");
  fi;

  join := arg[1];
  i := 1;
  while i < Length(arg) and join <> fail do
    i := i + 1;
    join := JOIN_PPERMS(join, arg[i]);
   od;
  return join;
end);

InstallGlobalFunction(JoinOfIdempotentPartialPermsNC,
function(arg)
  local join, i;

  if IsPartialPermCollection(arg[1]) then
    return CallFuncList(JoinOfIdempotentPartialPermsNC, arg[1]);
  elif not IsPartialPermCollection(arg) then
    ErrorNoReturn("usage: the argument should be a collection of partial ",
                  "perms,");
  fi;

  join := arg[1];
  i := 1;
  while i < Length(arg) do
    i := i + 1;
    join := JOIN_IDEM_PPERMS(join, arg[i]);
   od;
  return join;
end);

InstallGlobalFunction(MeetOfPartialPerms,
function(arg)
  local meet, i, empty;

  if Length(arg) = 1 and IsPartialPermCollection(arg[1]) then
    return CallFuncList(MeetOfPartialPerms, AsList(arg[1]));
  elif not IsPartialPermCollection(arg) then
    ErrorNoReturn("usage: the argument should be a collection of ",
                  "partial perms,");
  fi;

  meet := arg[1];
  i := 1;
  empty := EmptyPartialPerm();

  while i < Length(arg) and meet <> empty do
    i := i + 1;
    meet := MEET_PPERMS(meet, arg[i]);
  od;

  return meet;
end);

InstallMethod(AsPartialPerm, "for a perm and a list",
[IsPerm, IsList],
function(p, list)

  if not IsSSortedList(list)
      or not ForAll(list, x -> IsSmallIntRep(x) and IsPosInt(x)) then
    ErrorNoReturn("usage: the second argument must be a set of positive ",
                  "integers,");
  fi;

  return AS_PPERM_PERM(p, list);
end);

InstallMethod(AsPartialPerm, "for a perm",
[IsPerm], p -> AS_PPERM_PERM(p, [1 .. LargestMovedPoint(p)]));

InstallMethod(AsPartialPerm, "for a perm and pos int",
[IsPerm, IsPosInt and IsSmallIntRep],
function(p, n)
  return AS_PPERM_PERM(p, [1 .. n]);
end);

InstallMethod(AsPartialPerm, "for a perm and zero",
[IsPerm, IsZeroCyc],
function(p, n)
  return PartialPerm([]);
end);

# c method? JDM

InstallMethod(AsPartialPerm, "for a transformation and list",
[IsTransformation, IsList],
function(f, list)

  if not IsSSortedList(list)
      or not ForAll(list, x -> IsSmallIntRep(x) and IsPosInt(x)) then
    ErrorNoReturn("usage: the second argument must be a set of positive ",
                  "integers,");
  elif not IsInjectiveListTrans(list, f) then
    ErrorNoReturn("usage: the first argument must be injective on the ",
                  "second,");
  fi;
  return PartialPermNC(list, OnTuples(list, f));
end);

InstallMethod(AsPartialPerm, "for a transformation and positive int",
[IsTransformation, IsPosInt and IsSmallIntRep],
function(f, n)
  return AsPartialPerm(f, [1 .. n]);
end);

# n is image of undefined points
InstallMethod(AsTransformation, "for a partial perm and positive integer",
[IsPartialPerm, IsPosInt and IsSmallIntRep],
function(f, n)
  local deg, out, i;

  if n < DegreeOfPartialPerm(f) and n ^ f <> 0 and n ^ f <> n then
    ErrorNoReturn("usage: the 2nd argument must not be a moved ",
                  "point of the 1st argument,");
  fi;
  deg := Maximum(n, LargestMovedPoint(f) + 1, LargestImageOfMovedPoint(f) + 1);
  out := ListWithIdenticalEntries(deg, n);
  for i in DomainOfPartialPerm(f) do
    out[i] := i ^ f;
  od;

  return Transformation(out);
end);

InstallMethod(AsTransformation, "for a partial perm",
[IsPartialPerm],
function(f)
  return AsTransformation(f,
                          Maximum(LargestImageOfMovedPoint(f),
                          LargestMovedPoint(f)) + 1);
end);

InstallMethod(RestrictedPartialPerm, "for a partial perm",
[IsPartialPerm, IsList],
function(f, list)

  if not IsSSortedList(list)
      or not ForAll(list, x -> IsSmallIntRep(x) and IsPosInt(x)) then
    ErrorNoReturn("usage: the second argument must be a set of positive ",
                  "integers,");
  fi;

  return RESTRICTED_PPERM(f, list);
end);

InstallMethod(AsPermutation, "for a partial perm",
[IsPartialPerm], AS_PERM_PPERM);

InstallMethod(PermLeftQuoPartialPermNC, "for a partial perm and partial perm",
[IsPartialPerm, IsPartialPerm], PERM_LEFT_QUO_PPERM_NC);

InstallMethod(PermLeftQuoPartialPerm, "for a partial perm and partial perm",
[IsPartialPerm, IsPartialPerm],
function(f, g)

  if ImageSetOfPartialPerm(f) <> ImageSetOfPartialPerm(g) then
    ErrorNoReturn("usage: the arguments must be partial perms with equal ",
                  "image sets,");
  fi;

  return PERM_LEFT_QUO_PPERM_NC(f, g);
end);

InstallMethod(TrimPartialPerm, "for a partial perm",
[IsPartialPerm], TRIM_PPERM);

InstallMethod(PartialPermOp, "for object, list, function",
[IsObject, IsList, IsFunction],
function(f, D, act)
  local perm, out, seen, i, j, pnt, new;

  perm := ();

  if IsPlistRep(D) and Length(D) > 2 and CanEasilySortElements(D[1]) then
    if not IsSSortedList(D) then
      D := ShallowCopy(D);
      perm := Sortex(D);
      D := Immutable(D);
    fi;
  fi;

  out := EmptyPlist(Length(D));
  seen := EmptyPlist(Length(D));
  i := 0;
  j := Length(D);

  for pnt in D do
    pnt := act(pnt, f);
    new := PositionCanonical(D, pnt);
    if not pnt in seen then
      AddSet(seen, pnt);
      if new <> fail then
        i := i + 1;
        out[i] := new;
      else
        i := i + 1;
        j := j + 1;
        out[i] := j;
      fi;
    else
      return fail;
    fi;
  od;

  out := PartialPerm([1 .. Length(D)], out);

  if not IsOne(perm) then
    out := out ^ perm;
  fi;

  return out;
end);

InstallMethod(PartialPermOp, "for an obj and list",
[IsObject, IsList],
function(obj, list)
  return PartialPermOp(obj, list, OnPoints);
end);

InstallMethod(PartialPermOp, "for an obj and domain",
[IsObject, IsDomain],
function(obj, D)
  return PartialPermOp(obj, Enumerator(D), OnPoints);
end);

InstallMethod(PartialPermOp, "for an obj, domain, and function",
[IsObject, IsDomain, IsFunction],
function(obj, D, func)
  return PartialPermOp(obj, Enumerator(D), func);
end);

InstallMethod(PartialPermOpNC, "for object, list, function",
[IsObject, IsList, IsFunction],
function(f, D, act)
  local perm, out, i, j, pnt, new;

  perm := ();

  if IsPlistRep(D) and Length(D) > 2 and CanEasilySortElements(D[1]) then
    if not IsSSortedList(D) then
      D := ShallowCopy(D);
      perm := Sortex(D);
      D := Immutable(D);
    fi;
  fi;

  out := EmptyPlist(Length(D));
  i := 0;
  j := Length(D);

  for pnt in D do
    pnt := act(pnt, f);
    new := PositionCanonical(D, pnt);
    if new <> fail then
      i := i + 1;
      out[i] := new;
    else
      i := i + 1;
      j := j + 1;
      out[i] := j;
    fi;
  od;

  out := PartialPermNC([1 .. Length(D)], out);

  if not IsOne(perm) then
    out := out ^ perm;
  fi;

  return out;
end);

InstallMethod(PartialPermOpNC, "for an obj and list",
[IsObject, IsList],
function(obj, list)
  return PartialPermOpNC(obj, list, OnPoints);
end);

InstallMethod(PartialPermOpNC, "for an obj and domain",
[IsObject, IsDomain],
function(obj, D)
  return PartialPermOpNC(obj, Enumerator(D), OnPoints);
end);

InstallMethod(PartialPermOpNC, "for an obj, domain, and function",
[IsObject, IsDomain, IsFunction],
function(obj, D, func)
  return PartialPermOpNC(obj, Enumerator(D), func);
end);

# Creating partial perms

InstallGlobalFunction(RandomPartialPerm,
function(arg)
  local source, min, max, out, seen, j, dom, img, out1, out2, i;

  if Length(arg) = 1 then
    if IsSmallIntRep(arg[1]) and IsPosInt(arg[1]) then
      source := [1 .. arg[1]];
      min := 0;
      max := arg[1];
    elif IsCyclotomicCollection(arg[1]) and IsSSortedList(arg[1])
        and ForAll(arg[1], x -> IsSmallIntRep(x) and IsPosInt(x)) then
      source := arg[1];
      min := Minimum(source) - 1;
      max := Maximum(source);
    else
      ErrorNoReturn("usage: the argument must be a positive integer, a set, ",
      "or 2 sets, of positive integers, ");
    fi;

    out := List([1 .. max], x -> 0);
    seen := BlistList([1 .. max], []);

    for i in source do
      j := Random(source);
      if not seen[j - min] then
        seen[j - min] := true;
        out[i] := j;
      fi;
    od;
    return DensePartialPermNC(out);
  # for a domain and image
  elif Length(arg) = 2 and IsCyclotomicCollColl(arg)
      and ForAll(arg, IsSSortedList)
      and ForAll(arg[1], x -> IsSmallIntRep(x) and IsPosInt(x))
      and ForAll(arg[2], x -> IsSmallIntRep(x) and IsPosInt(x)) then

    dom := arg[1];
    img := arg[2];
    out1 := EmptyPlist(Length(dom));
    out2 := EmptyPlist(Length(dom));
    seen := BlistList([1 .. Maximum(img)], []);

    for i in dom do
      j := Random(img);
      if not seen[j] then
        seen[j] := true;
        Add(out1, i);
        Add(out2, j);
      fi;
      ShrinkAllocationPlist(out1);
      ShrinkAllocationPlist(out2);
    od;
    return SparsePartialPermNC(out1, out2);
  else
    ErrorNoReturn("usage: the argument must be a positive integer, a set, ",
                  "or 2 sets, of positive integers, ");
  fi;

end);

InstallGlobalFunction(PartialPermNC,
function(arg)

  if Length(arg) = 1 then
    return DensePartialPermNC(arg[1]);
  elif Length(arg) = 2 then
    return SparsePartialPermNC(arg[1], arg[2]);
  fi;

  ErrorNoReturn("usage: there should be one or two arguments,");
end);

InstallGlobalFunction(PartialPerm,
function(arg)

  if Length(arg) = 1 then
    if ForAll(arg[1], i -> IsSmallIntRep(i) and i >= 0)
        and IsDuplicateFreeList(Filtered(arg[1], x -> x <> 0)) then
      return DensePartialPermNC(arg[1]);
    else
      ErrorNoReturn("usage: the argument must be a list of non-negative ",
                    "integers and the non-zero elements must be ",
                    "duplicate-free,");
    fi;
  elif Length(arg) = 2 then
    if IsSSortedList(arg[1]) and ForAll(arg[1], IsPosInt and IsSmallIntRep)
        and IsDuplicateFreeList(arg[2]) and ForAll(arg[2], IsPosInt and IsSmallIntRep)
        and Length(arg[1]) = Length(arg[2]) then
      return SparsePartialPermNC(arg[1], arg[2]);
    else
      ErrorNoReturn("usage: the 1st argument must be a set of positive ",
                    "integers and the 2nd argument must be a duplicate-free ",
                    "list of positive integers of equal length to the first");
    fi;
  fi;

  ErrorNoReturn("usage: there should be one or two arguments, ");
end);

# printing, viewing, displaying...

InstallMethod(String, "for a partial perm",
[IsPartialPerm],
function(f)
  return STRINGIFY("PartialPerm( ", DomainOfPartialPerm(f), ", ",
   ImageListOfPartialPerm(f), " )");
end);

InstallMethod(PrintString, "for a partial perm",
[IsPartialPerm],
function(f)
  return PRINT_STRINGIFY("PartialPerm( ",
    Concatenation(PrintString(DomainOfPartialPerm(f)), ", "),
     ImageListOfPartialPerm(f), " )");
end);

InstallMethod(PrintObj, "for a partial perm",
[IsPartialPerm],
function(f)
  Print("PartialPerm(\>\> ", DomainOfPartialPerm(f), "\<, \>",
     ImageListOfPartialPerm(f), "\<\< )");
end);

InstallMethod(ViewString, "for a partial perm",
[IsPartialPerm],
function(f)

  if DegreeOfPartialPerm(f) = 0 then
    return "<empty partial perm>";
  fi;

  if RankOfPartialPerm(f) < UserPreference("PartialPermDisplayLimit") then
    if UserPreference("NotationForPartialPerms") = "component" then
      if DomainOfPartialPerm(f) <> ImageListOfPartialPerm(f) then
        return ComponentStringOfPartialPerm(f);
      else
        return PRINT_STRINGIFY("<identity partial perm on ",
                               DomainOfPartialPerm(f),
                               ">");
      fi;
    elif UserPreference("NotationForPartialPerms") = "domainimage" then
      if DomainOfPartialPerm(f) <> ImageListOfPartialPerm(f) then
        return PRINT_STRINGIFY(DomainOfPartialPerm(f),
                               " -> ",
                               ImageListOfPartialPerm(f));
      else
        return PRINT_STRINGIFY("<identity partial perm on ",
                               DomainOfPartialPerm(f),
                               ">");
      fi;
    elif UserPreference("NotationForPartialPerms") = "input" then
      return PrintString(f);
    fi;
  fi;

  return STRINGIFY("<partial perm on ",
                   Pluralize(RankOfPartialPerm(f), "pt"),
                   " with degree ",
                   DegreeOfPartialPerm(f),
                   ", codegree ",
                   CoDegreeOfPartialPerm(f),
                   ">");
end);

InstallGlobalFunction(ComponentStringOfPartialPerm,
function(f)
  local n, seen, str, i, j;

  n := Maximum(DegreeOfPartialPerm(f), CoDegreeOfPartialPerm(f));
  seen := List([1 .. n], x -> 0);

  #find the image
  for i in ImageSetOfPartialPerm(f) do
    seen[i] := 1;
  od;

  str := "";

  #find chains
  for i in DomainOfPartialPerm(f) do
    if seen[i] = 0 then
      Append(str, "\>[\>");
      Append(str, String(i));
      Append(str, "\<");
      seen[i] := 2;
      i := i ^ f;
      while i <> 0 do
        Append(str, ",\>");
        Append(str, String(i));
        Append(str, "\<");
        seen[i] := 2;
        i := i ^ f;
      od;
      Append(str, "\<]");
    fi;
  od;

  #find cycles
  for i in DomainOfPartialPerm(f) do
    if seen[i] = 1 then
      Append(str, "\>(\>");
      Append(str, String(i));
      Append(str, "\<");
      j := i ^ f;
      while j <> i do
        Append(str, ",\>");
        Append(str, String(j));
        Append(str, "\<");
        seen[j] := 2;
        j := j ^ f;
      od;
      Append(str, "\<)");
    fi;
  od;
  return str;
end);

#collections

InstallMethod(DegreeOfPartialPermCollection,
"for a partial perm collection",
[IsPartialPermCollection], coll -> Maximum(List(coll, DegreeOfPartialPerm)));

InstallMethod(CodegreeOfPartialPermCollection,
"for a partial perm collection",
[IsPartialPermCollection], coll -> Maximum(List(coll, CodegreeOfPartialPerm)));

InstallMethod(RankOfPartialPermCollection,
"for a partial perm collection",
[IsPartialPermCollection], coll -> Length(DomainOfPartialPermCollection(coll)));

InstallMethod(DomainOfPartialPermCollection, "for a partial perm coll",
[IsPartialPermCollection], coll -> Union(List(coll, DomainOfPartialPerm)));

InstallMethod(ImageOfPartialPermCollection, "for a partial perm coll",
[IsPartialPermCollection], coll -> Union(List(coll, ImageSetOfPartialPerm)));

InstallMethod(FixedPointsOfPartialPerm, "for a partial perm coll",
[IsPartialPermCollection], coll -> Union(List(coll, FixedPointsOfPartialPerm)));

InstallMethod(MovedPoints, "for a partial perm coll",
[IsPartialPermCollection], coll -> Union(List(coll, MovedPoints)));

InstallMethod(NrFixedPoints, "for a partial perm coll",
[IsPartialPermCollection], coll -> Length(FixedPointsOfPartialPerm(coll)));

InstallMethod(NrMovedPoints, "for a partial perm coll",
[IsPartialPermCollection], coll -> Length(MovedPoints(coll)));

InstallMethod(LargestMovedPoint, "for a partial perm collection",
[IsPartialPermCollection], coll -> Maximum(List(coll, LargestMovedPoint)));

InstallMethod(LargestImageOfMovedPoint, "for a partial perm collection",
[IsPartialPermCollection],
coll -> Maximum(List(coll, LargestImageOfMovedPoint)));

InstallMethod(SmallestMovedPoint, "for a partial perm collection",
[IsPartialPermCollection], coll -> Minimum(List(coll, SmallestMovedPoint)));

InstallMethod(SmallestImageOfMovedPoint, "for a partial perm collection",
[IsPartialPermCollection],
coll -> Minimum(List(coll, SmallestImageOfMovedPoint)));

InstallMethod(OneImmutable, "for a partial perm coll",
[IsPartialPermCollection],
function(x)
  return JoinOfIdempotentPartialPermsNC(List(x, OneImmutable));
end);

InstallMethod(OneMutable, "for a partial perm coll",
[IsPartialPermCollection], OneImmutable);

InstallMethod(MultiplicativeZeroOp, "for a partial perm",
[IsPartialPerm], x -> PartialPerm([]));
