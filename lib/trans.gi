#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include James D. Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

InstallMethod(NumberTransformation, "for a transformation",
[IsTransformation],
function(t)
  local n, a, i;
  n := DegreeOfTransformation(t);
  a := 0;
  for i in [1 .. n] do
      a := a * n + i ^ t - 1;
  od;
  return a + 1; # to be in [1 .. n ^ n]
end);

InstallMethod(NumberTransformation,
"for a transformation and zero",
[IsTransformation, IsZeroCyc],
function(t, n)
  return 1;
end);

InstallMethod(NumberTransformation,
"for a transformation and positive integer",
[IsTransformation, IsPosInt],
function(t, n)
  local a, i;
  if DegreeOfTransformation(t) > n then
    ErrorNoReturn("the second argument must be greater than or equal to the ",
                  "degree of the first argument (a transformation)");
  fi;
  a := 0;
  for i in [1 .. n] do
    a := a * n + i ^ t - 1;
  od;
  return a + 1; # to be in [1 .. n ^ n]
end);

InstallMethod(TransformationNumber,
"for a positive integer and positive integer",
[IsPosInt, IsPosInt],
function(a, n)
  local l, q, i;

  if a > n ^ n then
    ErrorNoReturn("the first argument must be at most ", n ^ n);
  fi;

  l := EmptyPlist(n);
  a := a - 1; # to be in [0 .. n ^ n - 1]
  for i in [n, n - 1 .. 1] do
      q := QuotientRemainder(Integers, a, n);
      l[i] := q[2] + 1;
      a := q[1];
  od;
  return TransformationNC(l);
end);

InstallMethod(TransformationNumber,
"for a positive integer and zero",
[IsPosInt, IsZeroCyc],
function(a, n)
  if a > 1 then
    ErrorNoReturn("the first argument must be at most 1");
  fi;
  return IdentityTransformation;
end);

InstallMethod(LT, "for a transformation and cyclotomic",
[IsTransformation, IsCyclotomic], ReturnFalse);

InstallMethod(LT, "for a cyclotomic and transformation",
[IsCyclotomic, IsTransformation], ReturnTrue);

InstallMethod(LT, "for a finite field element and transformation",
[IsFFE, IsTransformation], ReturnFalse);

InstallMethod(LT, "for a transformation and finite field element",
[IsTransformation, IsFFE], ReturnTrue);

InstallMethod(IsGeneratorsOfInverseSemigroup,
"for a transformation collection",
[IsTransformationCollection], IsGeneratorsOfMagmaWithInverses);

InstallMethod(IsGeneratorsOfInverseSemigroup,
"for a transformation collection",
[IsTransformationCollection], IsGeneratorsOfMagmaWithInverses);

InstallMethod(IsGeneratorsOfMagmaWithInverses,
 "for a transformation collection",
[IsTransformationCollection],
coll -> ForAll(coll, x -> RankOfTransformation(x) = DegreeOfTransformation(x)));

InstallMethod(TransformationList, "for a list", [IsList], Transformation);

InstallMethod(Transformation, "for a list", [IsList],
function(list)
  local len;
  len := Length(list);
  if IsDenseList(list) and ForAll(list, i -> IsPosInt(i) and i <= len) then
    return TransformationNC(list);
  fi;
  ErrorNoReturn("the argument does not describe a transformation");
end);

InstallMethod(TransformationListList, "for a list and list",
[IsList, IsList],
function(src, ran)
  if ForAll(src, IsPosInt) and ForAll(ran, IsPosInt) and IsDenseList(src)
      and IsDenseList(ran) and Length(ran) = Length(src)
      and IsDuplicateFree(src) then
    return TransformationListListNC(src, ran);
  fi;
  ErrorNoReturn("the argument does not describe a transformation");
end);

InstallMethod(Transformation, "for a list and list",
[IsList, IsList], TransformationListList);

InstallMethod(Transformation, "for a list and function",
[IsList, IsFunction],
function(list, func)
  return TransformationListList(list, List(list, func));
end);

InstallMethod(TrimTransformation, "for a transformation and pos int",
[IsTransformation, IsPosInt], TRIM_TRANS);

InstallMethod(TrimTransformation, "for a transformation",
[IsTransformation],
function(f)
  TRIM_TRANS(f, DegreeOfTransformation(f));
  return;
end);

InstallMethod(OnKernelAntiAction, "for a list and transformation",
[IsHomogeneousList, IsTransformation],
function(ker, f)

  if not IsFlatKernelOfTransformation(ker) then
    ErrorNoReturn("the first argument does not describe the ",
                  "flat kernel of a transformation");
  fi;

  return ON_KERNEL_ANTI_ACTION(ker, f, 0);
end);

InstallMethod(RankOfTransformation, "for a transformation",
[IsTransformation], RANK_TRANS);

InstallMethod(RankOfTransformation, "for a transformation and pos int",
[IsTransformation, IsPosInt], RANK_TRANS_INT);

InstallMethod(RankOfTransformation, "for a transformation and zero",
[IsTransformation, IsZeroCyc], RANK_TRANS_INT);

InstallMethod(RankOfTransformation, "for a transformation and dense list",
[IsTransformation, IsDenseList], RANK_TRANS_LIST);

InstallMethod(LargestMovedPoint, "for a transformation",
[IsTransformation], LARGEST_MOVED_PT_TRANS);

InstallMethod(LargestImageOfMovedPoint, "for a transformation",
[IsTransformation], LARGEST_IMAGE_PT);

InstallMethod(SmallestMovedPoint, "for a transformation",
[IsTransformation],
function(f)
  if IsOne(f) then
    return infinity;
  fi;
  return SMALLEST_MOVED_PT_TRANS(f);
end);

InstallMethod(SmallestImageOfMovedPoint, "for a transformation",
[IsTransformation],
function(f)
  if IsOne(f) then
    return infinity;
  fi;
  return SMALLEST_IMAGE_PT(f);
end);

InstallMethod(MovedPoints, "for a transformation",
[IsTransformation], MOVED_PTS_TRANS);

InstallMethod(NrMovedPoints, "for a transformation",
[IsTransformation], NR_MOVED_PTS_TRANS);

InstallMethod(MovedPoints, "for a transformation collection",
[IsTransformationCollection], coll -> Union(List(coll, MovedPoints)));

InstallMethod(NrMovedPoints, "for a transformation collection",
[IsTransformationCollection], coll -> Length(MovedPoints(coll)));

InstallMethod(LargestMovedPoint, "for a transformation collection",
[IsTransformationCollection], coll -> Maximum(List(coll, LargestMovedPoint)));

InstallMethod(LargestImageOfMovedPoint, "for a transformation collection",
[IsTransformationCollection],
coll -> Maximum(List(coll, LargestImageOfMovedPoint)));

InstallMethod(SmallestMovedPoint, "for a transformation collection",
[IsTransformationCollection], coll -> Minimum(List(coll, SmallestMovedPoint)));

InstallMethod(SmallestImageOfMovedPoint, "for a transformation collection",
[IsTransformationCollection],
coll -> Minimum(List(coll, SmallestImageOfMovedPoint)));

InstallMethod(RightOne, "for a transformation",
[IsTransformation], RIGHT_ONE_TRANS);

InstallMethod(LeftOne, "for a transformation",
[IsTransformation], LEFT_ONE_TRANS);

InstallMethod(ComponentsOfTransformation, "for a transformation",
[IsTransformation], COMPONENTS_TRANS);

InstallMethod(NrComponentsOfTransformation, "for a transformation",
[IsTransformation], NR_COMPONENTS_TRANS);

InstallMethod(ComponentRepsOfTransformation, "for a transformation",
[IsTransformation], COMPONENT_REPS_TRANS);

InstallMethod(ComponentTransformationInt,
"for a transformation and positive integer",
[IsTransformation, IsPosInt], COMPONENT_TRANS_INT);

InstallMethod(CycleTransformationInt,
"for a transformation and positive integer",
[IsTransformation, IsPosInt], CYCLE_TRANS_INT);

InstallMethod(CyclesOfTransformation, "for a transformation",
[IsTransformation], CYCLES_TRANS);

InstallMethod(CyclesOfTransformation, "for a transformation and list",
[IsTransformation, IsList], CYCLES_TRANS_LIST);

InstallMethod(IsOne, "for a transformation",
[IsTransformation], IS_ID_TRANS);

InstallMethod(IsIdempotent, "for a transformation",
[IsTransformation], IS_IDEM_TRANS);

InstallMethod(AsPermutation, "for a transformation",
[IsTransformation], AS_PERM_TRANS);

InstallMethod(AsTransformation, "for a permutation",
[IsPerm], AS_TRANS_PERM);

InstallMethod(AsTransformation, "for a permutation and positive integer",
[IsPerm, IsInt], AS_TRANS_PERM_INT);

InstallMethod(AsTransformation, "for a transformation",
[IsTransformation], IdFunc);

InstallMethod(AsTransformation, "for a transformation and degree",
[IsTransformation, IsInt], AS_TRANS_TRANS);

InstallMethod(ConstantTransformation, "for a pos int and pos int",
[IsPosInt, IsPosInt],
function(m, n)
  if m < n then
    ErrorNoReturn("the first argument (a positive integer) must be greater ",
                  "than or equal to the second (a positive integer)");
  fi;
  return Transformation(ListWithIdenticalEntries(m, n));
end);

InstallMethod(DegreeOfTransformationCollection,
"for a transformation collection",
[IsTransformationCollection],
function(coll)
  return MaximumList(List(coll, DegreeOfTransformation));
end);

InstallMethod(IsFlatKernelOfTransformation, "for a homogeneous list",
[IsHomogeneousList],
function(ker)
  local m, i;
  if Length(ker) = 0 or not IsPosInt(ker[1]) then
    return false;
  fi;
  m := 1;
  for i in ker do
    if i > m then
      if m + 1 <> i then
        return false;
      fi;
      m := m + 1;
    fi;
  od;
  return true;
end);

InstallMethod(FlatKernelOfTransformation, "for a transformation",
[IsTransformation], x -> FLAT_KERNEL_TRANS_INT(x, DegreeOfTransformation(x)));

InstallMethod(FlatKernelOfTransformation, "for a transformation and pos int",
[IsTransformation, IsInt], FLAT_KERNEL_TRANS_INT);

InstallMethod(ImageSetOfTransformation, "for a transformation",
[IsTransformation], x -> IMAGE_SET_TRANS_INT(x, DegreeOfTransformation(x)));

InstallMethod(ImageSetOfTransformation, "for a transformation and pos int",
[IsTransformation, IsInt], IMAGE_SET_TRANS_INT);

InstallMethod(ImageListOfTransformation, "for a transformation and pos int",
[IsTransformation, IsInt], IMAGE_LIST_TRANS_INT);

InstallMethod(ImageListOfTransformation, "for a transformation",
[IsTransformation], x -> IMAGE_LIST_TRANS_INT(x, DegreeOfTransformation(x)));

InstallMethod(Order, "for a transformation",
[IsTransformation], x -> Sum(IndexPeriodOfTransformation(x)) - 1);

InstallMethod(KernelOfTransformation, "for a transformation",
[IsTransformation], x -> KERNEL_TRANS(x, DegreeOfTransformation(x)));

InstallMethod(KernelOfTransformation,
"for a transformation, positive integer and boolean",
[IsTransformation, IsPosInt, IsBool],
function(f, n, bool)
  if bool then
    return KERNEL_TRANS(f, n);
  fi;
  n := Minimum(DegreeOfTransformation(f), n);
  return Filtered(KERNEL_TRANS(f, n), x -> Size(x) <> 1);
end);

InstallMethod(KernelOfTransformation, "for a transformation and pos int",
[IsTransformation, IsPosInt], KERNEL_TRANS);

InstallMethod(KernelOfTransformation, "for a transformation and pos int",
[IsTransformation, IsBool],
function(f, bool)
  return KernelOfTransformation(f, DegreeOfTransformation(f), bool);
end);

InstallOtherMethod(OneMutable, "for a transformation collection",
[IsTransformationCollection], coll -> IdentityTransformation);

InstallMethod(PermLeftQuoTransformation,
"for a transformation and transformation",
[IsTransformation, IsTransformation],
function(f, g)
  local n;
  n := Maximum(DegreeOfTransformation(f), DegreeOfTransformation(g));
  if FlatKernelOfTransformation(f, n) <> FlatKernelOfTransformation(g, n)
      or ImageSetOfTransformation(f, n) <> ImageSetOfTransformation(g, n) then
    ErrorNoReturn("the arguments (transformations) must have equal image ",
                  "set and kernel");
  fi;
  return PermLeftQuoTransformationNC(f, g);
end);

InstallMethod(PreImagesOfTransformation,
"for a transformation and positive integer",
[IsTransformation, IsPosInt], PREIMAGES_TRANS_INT);

InstallMethod(DisplayString, "for a transformation",
[IsTransformation], ViewString);

InstallMethod(String, "for a transformation",
[IsTransformation],
function(f)
  local img, str, i;

  if IsOne(f) then
    return "IdentityTransformation";
  fi;
  img := ImageListOfTransformation(f, DegreeOfTransformation(f));
  str := ShallowCopy(STRINGIFY("[ ", img[1]));
  for i in [2 .. Length(img)] do
    Append(str, ", ");
    Append(str, String(img[i]));
  od;
  Append(str, " ]");

  return STRINGIFY("Transformation( ", str, " )");
end);

InstallMethod(PrintString, "for a transformation",
[IsTransformation],
function(f)
  local img, str, i;

  if IsOne(f) then
    return "\>IdentityTransformation\<";
  fi;

  img := ImageListOfTransformation(f, DegreeOfTransformation(f));
  str := PRINT_STRINGIFY("[ ", img[1]);
  for i in [2..Length(img)] do
    Append(str, ",\> ");
    Append(str, PrintString(img[i]));
    Append(str, "\<");
  od;
  Append(str, " ]");
  return Concatenation("\>Transformation( ", str, " )\<");
end);

InstallMethod(ViewString, "for a transformation",
[IsTransformation],
function(f)
  local img, str, deg, i;

  if LargestMovedPoint(f) < UserPreference("TransformationDisplayLimit")
      then
    if UserPreference("NotationForTransformations")="input"
        and LargestImageOfMovedPoint(f) <
        UserPreference("TransformationDisplayLimit") then
      return PrintString(f);
    elif UserPreference("NotationForTransformations") = "fr" then
      if IsOne(f) then
        return "\><identity transformation>\<";
      fi;
      img := ImageListOfTransformation(f, LargestMovedPoint(f));
      str := PRINT_STRINGIFY("\>\><transformation: \<", img[1]);
      for i in [2 .. Length(img)] do
        Append(str, ",\>");
        Append(str, PrintString(img[i]));
        Append(str, "\<");
      od;
      Append(str, ">\<\<");
      return str;
    fi;
  fi;
  deg := DegreeOfTransformation(f);
  # deg is either 0 or >= 2, so do not use Pluralize on "pts" in the following
  return STRINGIFY("\><transformation on ", deg, " pts with rank ",
                   RankOfTransformation(f, deg), ">\<");
end);

InstallMethod(RandomTransformation, "for a pos. int.", [IsPosInt],
function(n)
  local out, i;

  out := EmptyPlist(n);
  n := [1 .. n];

  for i in n do
    out[i] := Random(n);
  od;
  return TransformationNC(out);
end);

InstallMethod(RandomTransformation, "for pos int and pos int",
[IsPosInt, IsPosInt],
function(deg, rank)
  local dom, seen, im, set, nr, i;

  dom := [1 .. deg];
  seen := BlistList(dom, []);
  im := EmptyPlist(deg);
  set := EmptyPlist(rank);
  nr := 0;
  i := 0;

  while nr < rank and i < deg do
    i := i + 1;
    im[i] := Random(dom);
    if not seen[im[i]] then
      seen[im[i]] := true;
      nr := nr + 1;
      AddSet(set, im[i]);
    fi;
  od;

  while i < deg do
    i := i + 1;
    im[i] := Random(set);
  od;
  return Transformation(im);
end);

InstallMethod(SmallestIdempotentPower, "for a transformation",
[IsTransformation], SMALLEST_IDEM_POW_TRANS);

InstallMethod(TransformationByImageAndKernel,
"for a list of positive integers and a list of positive integers",
[IsCyclotomicCollection and IsDenseList,
 IsCyclotomicCollection and IsDenseList],
function(img, ker)

  if IsFlatKernelOfTransformation(ker) and ForAll(img, IsPosInt) and
      Maximum(ker) = Length(img) and IsDuplicateFreeList(img) and
      ForAll(img, x -> x <= Length(ker)) then
    return TRANS_IMG_KER_NC(img, ker);
  fi;
  return fail;
end);

InstallMethod(Idempotent, "for a list of pos ints and list of pos ints",
[IsCyclotomicCollection, IsCyclotomicCollection],
function(img, ker)

  if IsFlatKernelOfTransformation(ker) and ForAll(img, IsPosInt)
      and Maximum(ker) = Length(img) and IsInjectiveListTrans(img, ker)
      and IsSet(img) and ForAll(img, x -> x <= Length(ker)) then
    return IDEM_IMG_KER_NC(img, ker);
  fi;

  return fail;
end);

# based on PermutationOp in oprt.gi

InstallMethod(TransformationOp, "for object, list, function",
[IsObject, IsList, IsFunction],
function(f, D, act)
  local perm, out, new, i, pnt;

  perm := ();

  if IsPlistRep(D) and Length(D) > 2 and CanEasilySortElements(D[1]) then
    if not IsSSortedList(D) then
      D := ShallowCopy(D);
      perm := Sortex(D);
      D := Immutable(D);
      SetIsSSortedList(D, true);
    fi;
  fi;

  out := EmptyPlist(Length(D));
  i := 0;

  for pnt in D do
    new := PositionCanonical(D, act(pnt, f));
    if new = fail then
      return fail;
    fi;
    i := i + 1;
    out[i] := new;
  od;

  out := Transformation(out);

  if not IsOne(perm) then
    out := out ^ (perm ^ -1);
  fi;

  return out;
end);

InstallMethod(TransformationOp, "for an obj and list",
[IsObject, IsList],
function(obj, list)
  return TransformationOp(obj, list, OnPoints);
end);

InstallMethod(TransformationOp, "for an obj and domain",
[IsObject, IsDomain],
function(obj, D)
  return TransformationOp(obj, Enumerator(D), OnPoints);
end);

InstallMethod(TransformationOp, "for an obj, domain, and function",
[IsObject, IsDomain, IsFunction],
function(obj, D, func)
  return TransformationOp(obj, Enumerator(D), func);
end);

# based on PermutationOp in oprt.gi

# same as the above except no check that PositionCanonical is not fail

InstallMethod(TransformationOpNC, "for object, list, function",
[IsObject, IsList, IsFunction],
function(f, D, act)
  local perm, out, i, pnt;

  perm := ();

  if IsPlistRep(D) and Length(D) > 2 and CanEasilySortElements(D[1]) then
    if not IsSSortedList(D) then
      D := ShallowCopy(D);
      perm := Sortex(D);
      D := Immutable(D);
      SetIsSSortedList(D, true);
    fi;
  fi;

  out := EmptyPlist(Length(D));
  i := 0;
  for pnt in D do
    i := i + 1;
    out[i] := PositionCanonical(D, act(pnt, f));
  od;

  out := Transformation(out);

  if not IsOne(perm) then
    out := out ^ (perm ^ -1);
  fi;

  return out;
end);

InstallMethod(TransformationOpNC, "for object and list",
[IsObject, IsList],
function(f, D)
  return TransformationOpNC(f, Enumerator(D), OnPoints);
end);

InstallMethod(TransformationOpNC, "for object and domain",
[IsObject, IsDomain],
function(f, D)
  return TransformationOpNC(f, Enumerator(D), OnPoints);
end);

InstallMethod(TransformationOpNC, "for object, domain, function",
[IsObject, IsDomain, IsFunction],
function(f, D, act)
  return TransformationOpNC(f, Enumerator(D), act);
end);

InstallOtherMethod(InverseMutable, "for a transformation",
[IsTransformation],
function(f)
  if RankOfTransformation(f) = DegreeOfTransformation(f) then
    return InverseOfTransformation(f);
  fi;
  return fail;
end);

# binary relations etc...

#InstallMethod(AsTransformation, "for relation over [1..n]",
#[IsGeneralMapping],
#function(rel)
#    local ims;
#
#    if not IsEndoGeneralMapping(rel) then
#      ErrorNoReturn("AsTransformation: ", rel, " is not a binary relation");
#    fi;
#    ims := ImagesListOfBinaryRelation(rel);
#    if not ForAll(ims, x -> Length(x) = 1) then
#      return fail;
#    fi;
#    return Transformation(List(ims, x -> x[1]));
#end);

InstallMethod(AsTransformation, "for binary relations on points",
[IsBinaryRelation and IsBinaryRelationOnPointsRep],
function(rel)
  if not IsMapping(rel) then
    ErrorNoReturn("the argument must be a binary relation which is a mapping");
  fi;
  return Transformation(Flat(Successors(rel)));
end);

InstallMethod(AsBinaryRelation, "for a transformation",
[IsTransformation],
function(t)
  local img;
  img := ImageListOfTransformation(t, DegreeOfTransformation(t));
  return BinaryRelationByListOfImagesNC(List(img, x -> [x]));
end);

#InstallMethod(\*, "for a general mapping and a transformation",
#[IsGeneralMapping, IsTransformation],
#function(r, t)
#  return r * AsBinaryRelation(t, DegreeOfBinaryRelation(r));
#end);
#
#InstallMethod(\*, "for a transformation and a general mapping",
#[IsTransformation, IsGeneralMapping],
#function(t, r)
#  return AsBinaryRelation(t, DegreeOfBinaryRelation(r)) * r;
#end);
