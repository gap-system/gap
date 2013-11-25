#############################################################################
##
#W  trans.gi           GAP library                          James D. Mitchell
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2012 The GAP Group
##

InstallMethod(NumberTransformation, "for a transformation", 
[IsTransformation], 
function(t) 
  local l, n, a, i; 
  n := DegreeOfTransformation(t); 
  a := 0; 
  for i in [1..n] do 
      a := a*n + i^t-1; 
  od; 
  return a+1;   # to be in [1..n^n] 
end); 
 
InstallMethod(NumberTransformation, 
"for a transformation and positive integer", 
[IsTransformation, IsPosInt], 
function(t, n) 
  local l, a, i; 
  a := 0; 
  for i in [1..n] do 
    a := a*n + i^t-1; 
  od; 
  return a+1;   # to be in [1..n^n] 
end); 

InstallMethod(TransformationNumber,  
"for a positive integer and positive integer", 
[IsPosInt, IsPosInt],
function(a,n) 
  local l, q, i; 
  l := EmptyPlist(n); 
  a := a - 1;   # to be in [0..n^n-1] 
  for i in [n, n-1..1] do  
      q := QuotientRemainder(Integers,a,n); 
      l[i] := q[2]+1; 
      a := q[1]; 
  od; 
  return TransformationNC(l); 
end); 

#

InstallMethod(LT, "for a transformation and cyclotomic", 
[IsTransformation, IsCyclotomic], ReturnFalse);

InstallMethod(LT, "for a cyclotomic and transformation", 
[IsCyclotomic, IsTransformation], ReturnTrue);

InstallMethod(LT, "for a finite field element and transformation", 
[IsFFE, IsTransformation], ReturnFalse);

InstallMethod(LT, "for a transformation and finite field element", 
[IsTransformation, IsFFE], ReturnTrue);

#

InstallMethod(IsGeneratorsOfInverseSemigroup, 
"for a transformation collection", 
[IsTransformationCollection], IsGeneratorsOfMagmaWithInverses);

#
#

InstallMethod(IsGeneratorsOfInverseSemigroup, 
"for a transformation collection", 
[IsTransformationCollection], IsGeneratorsOfMagmaWithInverses);

#

InstallMethod(IsGeneratorsOfMagmaWithInverses,
 "for a transformation collection",
[IsTransformationCollection],
coll-> ForAll(coll, x-> RankOfTransformation(x)=DegreeOfTransformation(x)));

#

InstallMethod(TransformationList, "for a list", [IsList], Transformation);

#

InstallMethod(Transformation, "for a list", [IsList],
function(list)
  local len;
  len:=Length(list);
  if IsDenseList(list) and ForAll(list, i-> IsPosInt(i) and i<=len) then 
    return TransformationNC(list);
  fi;
  return fail;
end);

#

InstallMethod(TransformationListList, "for a list and list",
[IsList, IsList],
function(src, ran)
  if ForAll(src, IsPosInt) and ForAll(ran, IsPosInt) and IsDenseList(src) and
    IsDenseList(ran) and Length(ran)=Length(src) then 
    return TransformationListListNC(src, ran);
  fi;
  return fail;
end);

#

InstallMethod(Transformation, "for a list and list", 
[IsList, IsList], TransformationListList);

InstallMethod(Transformation, "for a list and function",
[IsList, IsFunction], 
function(list, func)
  return TransformationListList(list, List(list, func));
end);

#

InstallMethod(TrimTransformation, "for a transformation and pos int",
[IsTransformation, IsPosInt], TRIM_TRANS);

InstallMethod(TrimTransformation, "for a transformation",
[IsTransformation], 
function(f)
  TRIM_TRANS(f, DegreeOfTransformation(f));
  return;
end);

#

InstallMethod(OnKernelAntiAction, "for a list and transformation", 
[IsDenseList and IsHomogeneousList, IsTransformation], 
function(ker, f)
  local m, i;
  
  if Length(ker)=0 or not IsPosInt(ker[1]) then 
    Error("usage: the first argument <ker> must be a non-empty dense\n", 
    "list of positive integers,");
  fi;
  
  m:=1;
  for i in ker do 
    if i>m then 
      if m+1<>i then 
        Error("usage: the first argument <ker> does not describe the\n",
        " flat kernel of a transformation,");
      fi;
      m:=m+1;
    fi;
  od;
  return ON_KERNEL_ANTI_ACTION(ker, f, 0);
end);

#

InstallMethod(RankOfTransformation, "for a transformation",
[IsTransformation], RANK_TRANS);

#InstallMethod(CoRankOfTransformation, "for a transformation",
#[IsTransformation], CORANK_TRANS);

InstallMethod(RankOfTransformation, "for a transformation and pos int",
[IsTransformation, IsPosInt], RANK_TRANS_INT);

#InstallMethod(CoRankOfTransformation, "for a transformation",
#[IsTransformation], CORANK_TRANS_INT);

InstallMethod(RankOfTransformation, "for a transformation and dense list",
[IsTransformation, IsDenseList], 
function(f, list)
  if IsEmpty(list) then 
    return 0;
  fi;
  return RANK_TRANS_LIST(f, list);
end);

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

InstallMethod(MovedPoints, "for a tranformation",
[IsTransformation], MOVED_PTS_TRANS);

InstallMethod(NrMovedPoints, "for a tranformation",
[IsTransformation], NR_MOVED_PTS_TRANS);

InstallMethod(MovedPoints, "for a transformation coll",
[IsTransformationCollection], coll-> Union(List(coll, MovedPoints)));

InstallMethod(NrMovedPoints, "for a transformation coll",
[IsTransformationCollection], coll-> Length(MovedPoints(coll)));

InstallMethod(LargestMovedPoint, "for a transformation collection",
[IsTransformationCollection], coll-> Maximum(List(coll, LargestMovedPoint)));

InstallMethod(LargestImageOfMovedPoint, "for a transformation collection",
[IsTransformationCollection], 
coll-> Maximum(List(coll, LargestImageOfMovedPoint)));

InstallMethod(SmallestMovedPoint, "for a transformation collection",
[IsTransformationCollection], coll-> Minimum(List(coll, SmallestMovedPoint)));

InstallMethod(SmallestImageOfMovedPoint, "for a transformation collection",
[IsTransformationCollection], coll-> Minimum(List(coll, SmallestImageOfMovedPoint)));

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

#this could be better JDM, could use ImageSetOfTransformation
InstallMethod(CyclesOfTransformation, 
"for a transformation",
[IsTransformation], f-> CYCLES_TRANS_LIST(f, [1..DegreeOfTransformation(f)]));

InstallMethod(CyclesOfTransformation, 
"for a transformation and list",
[IsTransformation, IsList], 
function(f, list)
  if IsDenseList(list) and ForAll(list, IsPosInt) then 
    return CYCLES_TRANS_LIST(f, list);
  fi;
  Error("usage: the second argument must be a dense list of positive integers");
  return;
end);

InstallMethod(IsOne, "for a transformation",
[IsTransformation], IS_ID_TRANS);

InstallMethod(IsIdempotent, "for a transformation", 
[IsTransformation], IS_IDEM_TRANS);

InstallMethod(AsPermutation, "for a transformation", 
[IsTransformation], AS_PERM_TRANS); 

InstallMethod(PermutationOfImage, "for a transformation",
[IsTransformation], PERM_IMG_TRANS);

InstallMethod(AsTransformation, "for a permutation",
[IsPerm], AS_TRANS_PERM);

InstallMethod(AsTransformation, "for a permutation and positive integer", 
[IsPerm, IsInt], 
function(f, n)
  if 0<=n then 
    return AS_TRANS_PERM_INT(f, n);
  fi;
  return fail;
end);

InstallMethod(AsTransformation, "for a transformation",
[IsTransformation], IdFunc); 

InstallMethod(AsTransformation, "for a transformation and degree", 
[IsTransformation, IsInt], 
function(f, n)
  if 0<=n then 
    return AS_TRANS_TRANS(f, n);
  fi;
  return fail;
end);

#

InstallMethod(ConstantTransformation, "for a pos int and pos int",
[IsPosInt, IsPosInt],
function(m,n)
  if m<n then 
    Error("usage: the arguments should be positive integers with the first",
    " greater\nthan or equal to the second,");
    return;
  fi;
  return Transformation(ListWithIdenticalEntries(m, n));;
end);

#

InstallMethod(DegreeOfTransformationCollection, 
"for a transformation collection",
[IsTransformationCollection], 
function(coll)
  return MaximumList(List(coll, DegreeOfTransformation));
end);

#

InstallMethod(FlatKernelOfTransformation, "for a transformation", 
[IsTransformation], x-> FLAT_KERNEL_TRANS_INT(x, DegreeOfTransformation(x)));

#

InstallMethod(FlatKernelOfTransformation, "for a transformation and pos int", 
[IsTransformation, IsPosInt], FLAT_KERNEL_TRANS_INT);

#

InstallMethod(ImageSetOfTransformation, "for a transformation",
[IsTransformation], x-> IMAGE_SET_TRANS_INT(x, DegreeOfTransformation(x)));

#

InstallMethod(ImageSetOfTransformation, "for a transformation and pos int",
[IsTransformation, IsPosInt], IMAGE_SET_TRANS_INT);

#
InstallMethod(ImageListOfTransformation, "for a transformation and pos int", 
[IsTransformation, IsPosInt], IMAGE_TRANS);

#

InstallMethod(ImageListOfTransformation, "for a transformation", 
[IsTransformation], x-> IMAGE_TRANS(x, DegreeOfTransformation(x)));

#

InstallMethod(IndexPeriodOfTransformation, "for a transformation",
[IsTransformation], INDEX_PERIOD_TRANS);

#

InstallMethod(Order, "for a transformation",
[IsTransformation], x-> Sum(INDEX_PERIOD_TRANS(x))-1);

#

InstallMethod(IsInjectiveListTrans, "for a list and list",
[IsList, IsList], IS_INJECTIVE_LIST_TRANS);

#

InstallMethod(IsInjectiveListTrans, "for a list and trans",
[IsList, IsTransformation], IS_INJECTIVE_LIST_TRANS);

#

InstallMethod(KernelOfTransformation, "for a transformation", 
[IsTransformation], x-> KERNEL_TRANS(x, DegreeOfTransformation(x)));

#JDM could do better than this

InstallMethod(KernelOfTransformation, 
"for a transformation, positive integer and boolean", 
[IsTransformation, IsPosInt, IsBool], 
function(f, n, bool)
  if bool then 
    return KERNEL_TRANS(f, n);
  fi; 
  n:=Minimum(DegreeOfTransformation(f), n);
  return Filtered(KERNEL_TRANS(f, n), x-> Size(x)<>1);
end);

#

InstallMethod(KernelOfTransformation, "for a transformation and pos int", 
[IsTransformation, IsPosInt], KERNEL_TRANS);

#

InstallMethod(KernelOfTransformation, "for a transformation and pos int", 
[IsTransformation, IsBool],
function(f, bool)
  return KernelOfTransformation(f, DegreeOfTransformation(f), bool);
end);

#

InstallOtherMethod(OneMutable, "for a transformation coll",
[IsTransformationCollection], coll-> IdentityTransformation);

#

InstallMethod(PermLeftQuoTransformationNC, 
"for a transformation and transformation",
[IsTransformation, IsTransformation],
PERM_LEFT_QUO_TRANS_NC);

#

InstallMethod(PermLeftQuoTransformation, 
"for a transformation and transformation", [IsTransformation, IsTransformation],
function(f, g)
  local n;
  n:=Maximum(DegreeOfTransformation(f), DegreeOfTransformation(g));
  if FlatKernelOfTransformation(f, n)<>FlatKernelOfTransformation(g, n) or
    ImageSetOfTransformation(f, n)<>ImageSetOfTransformation(g, n) then 
    Error("usage: the arguments must have equal image set and kernel,");
    return;
  fi;
  return PERM_LEFT_QUO_TRANS_NC(f, g);
end);

#

InstallMethod(PreImagesOfTransformation, 
"for a transformation and positive integer",
[IsTransformation, IsPosInt], PREIMAGES_TRANS_INT);

#

InstallMethod(DisplayString, "for a transformation", 
[IsTransformation], ViewString);

#

InstallMethod(String, "for a transformation",
[IsTransformation], 
function(f) 
  local img, str, i;
 
  if IsOne(f) then 
    return "<identity transformation>";
  fi;
  img:=ImageListOfTransformation(f, DegreeOfTransformation(f));
  str:=ShallowCopy(STRINGIFY("[ ", img[1]));
  for i in [2..Length(img)] do
    Append(str, ", ");
    Append(str, String(img[i]));
  od;
  Append(str, " ]");

  return STRINGIFY("Transformation( ", str, " )");
end);

#

InstallMethod(PrintString, "for a transformation",
[IsTransformation], 
function(f) 
  local img, str, i;

  if IsOne(f) then 
    return "\>IdentityTransformation\<";
  fi;
  
  img:=ImageListOfTransformation(f, DegreeOfTransformation(f));
  str:=PRINT_STRINGIFY("[ ", img[1]);
  for i in [2..Length(img)] do 
    Append(str, ",\> ");
    Append(str, PrintString(img[i]));
    Append(str, "\<");
  od;
  Append(str, " ]");
  return Concatenation("\>Transformation( ", str, " )\<");
end);

#

InstallMethod(ViewString, "for a transformation",
[IsTransformation],
function(f)
  local img, str, deg, i;

  if LargestMovedPoint(f)<UserPreference("TransformationDisplayLimit")
    then  
    if UserPreference("NotationForTransformations")="input" 
      and
      LargestImageOfMovedPoint(f)<UserPreference("TransformationDisplayLimit")
      then 
      return PrintString(f);
    elif UserPreference("NotationForTransformations")="fr" then 
      if IsOne(f) then 
        return "\><identity transformation>\<";
      fi;
      img:=ImageListOfTransformation(f, LargestMovedPoint(f));
      str:=PRINT_STRINGIFY("\>\><transformation: \<", img[1]);
      for i in [2..Length(img)] do 
        Append(str, ",\>");
        Append(str, PrintString(img[i]));
        Append(str, "\<");
      od;
      Append(str, ">\<\<");
      return str;
    fi;
  fi; 
  deg:=DegreeOfTransformation(f);
  return STRINGIFY("\><transformation on ", deg, " pts with rank ",
    RankOfTransformation(f, deg), ">\<"); 
end);

#

InstallMethod(RandomTransformation, "for a pos. int.", [IsPosInt],
function(n)
  local out, i;

  out:=EmptyPlist(n);
  n:=[1..n];

  for i in n do 
    out[i]:=Random(n);
  od;
  return TransformationNC(out);
end);

#

InstallMethod(RandomTransformation, "for pos int and pos int",
[IsPosInt, IsPosInt],
function(deg, rank)
  local dom, seen, im, set, nr, i;

  dom:=[1..deg];
  seen:=BlistList(dom, []);
  im:=EmptyPlist(deg);
  set:=EmptyPlist(rank);
  nr:=0; i:=0;
  
  while nr<rank and i<deg do 
    i:=i+1;
    im[i]:=Random(dom);
    if not seen[im[i]] then
      seen[im[i]]:=true;
      nr:=nr+1;
      AddSet(set, im[i]);
    fi;
  od;
  
  while i<deg do 
    i:=i+1;
    im[i]:=Random(set);
  od;
  return Transformation(im);
end);

#

InstallMethod(RestrictedTransformationNC, 
"for a transformation and list",
[IsTransformation, IsList], RESTRICTED_TRANS);

#

InstallMethod(RestrictedTransformation, 
"for transformation and list",
[IsTransformation, IsList],
function(f, list)

  if not (IsDenseList(list) and IsDuplicateFree(list) 
    and ForAll(list, IsPosInt)) then 
    Error("usage: the second argument should be a duplicate-free, dense ", 
    "list of positive integers,");
    return;
  fi;
  return RESTRICTED_TRANS(f, list);
end);

#

InstallMethod(SmallestIdempotentPower, "for a transformation",
[IsTransformation], SMALLEST_IDEM_POW_TRANS);

#

InstallMethod(TransformationByImageAndKernel, 
"for a list of positive integers and a list of positive integers",
[IsCyclotomicCollection and IsDenseList, 
 IsCyclotomicCollection and IsDenseList],
function(img, ker)
  
  if ForAll(ker, IsPosInt) and ForAll(img, IsPosInt) and
   Maximum(ker)=Length(img) and IsDuplicateFreeList(img) and 
   ForAll(img, x-> x<=Length(ker)) then 
    return TRANS_IMG_KER_NC(img, ker);
  fi;
  return fail;
end);

#

InstallMethod(Idempotent, "for a list of pos ints and list of pos ints",
[IsCyclotomicCollection, IsCyclotomicCollection],
function(img, ker)
  local lookup, m, i;

  if ForAll(ker, IsPosInt) and ForAll(img, IsPosInt) and 
   Maximum(ker)=Length(img) and IS_INJECTIVE_LIST_TRANS(img, ker) and
   IsSet(img) and ForAll(img, x-> x<=Length(ker)) then 
   return IDEM_IMG_KER_NC(img, ker);
  fi;
  return fail;
end);

# based on PermutationOp in oprt.gi

InstallMethod(TransformationOp, "for object, list, function",
[IsObject, IsList, IsFunction],
function(f, D, act)
  local perm, out, new, i, pnt;

  perm:=();

  if IsPlistRep(D) and Length(D)>2 and CanEasilySortElements(D[1]) then 
    if not IsSSortedList(D) then 
      D:=ShallowCopy(D);
      perm:=Sortex(D);
      D:=Immutable(D);
      SetIsSSortedList(D, true);
    fi;
  fi;

  out:=EmptyPlist(Length(D));
  i:=0;

  for pnt in D do 
    new:=PositionCanonical(D, act(pnt, f));
    if new=fail then 
      return fail;
    fi;
    i:=i+1;
    out[i]:=new;
  od;

  out:=Transformation(out);
  
  if not IsOne(perm) then 
    out:=out^(perm^-1);
  fi;

  return out;
end);

#

InstallMethod(TransformationOp, "for an obj and list",
[IsObject, IsList], 
function(obj, list) 
  return TransformationOp(obj, list, OnPoints);
end);

#

InstallMethod(TransformationOp, "for an obj and domain",
[IsObject, IsDomain], 
function(obj, D) 
  return TransformationOp(obj, Enumerator(D), OnPoints);
end);

#

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

  perm:=();

  if IsPlistRep(D) and Length(D)>2 and CanEasilySortElements(D[1]) then 
    if not IsSSortedList(D) then 
      D:=ShallowCopy(D);
      perm:=Sortex(D);
      D:=Immutable(D);
      SetIsSSortedList(D, true);
    fi;
  fi;

  out:=EmptyPlist(Length(D));
  i:=0;
  for pnt in D do 
    i:=i+1;
    out[i]:=PositionCanonical(D, act(pnt, f));
  od;

  out:=Transformation(out);

  if not IsOne(perm) then 
    out:=out^(perm^-1);
  fi;

  return out;
end);

#

InstallMethod(TransformationOpNC, "for object and list",
[IsObject, IsList],
function(f, D)
  return TransformationOpNC(f, Enumerator(D), OnPoints);
end);

#

InstallMethod(TransformationOpNC, "for object and domain",
[IsObject, IsDomain],
function(f, D)
  return TransformationOpNC(f, Enumerator(D), OnPoints);
end);

#

InstallMethod(TransformationOpNC, "for object, domain, function",
[IsObject, IsDomain, IsFunction],
function(f, D, act)
  return TransformationOpNC(f, Enumerator(D), act);
end);

# JDM expand!!

InstallGlobalFunction(TransformationActionNC, 
function(arg)
  if (IsDomain(arg[2]) or IsList(arg[2])) and IsFunction(arg[3]) then 
    if IsMonoid(arg[1]) then 
      return Monoid(GeneratorsOfMonoid(arg[1]), f-> 
       TransformationOpNC(f, arg[2], arg[3]));
    elif IsSemigroup(arg[1]) then 
      return Semigroup(GeneratorsOfSemigroup(arg[1]), f-> 
       TransformationOpNC(f, arg[2], arg[3]));
    fi;
  fi;
  return fail;
end);

#

InstallMethod(InverseOfTransformation, "for a transformation",
[IsTransformation], INV_TRANS);

#

InstallOtherMethod(InverseMutable, "for a transformation",
[IsTransformation], 
function(f)
  if RankOfTransformation(f)=DegreeOfTransformation(f) then 
    return InverseOfTransformation(f);
  fi;
  return fail;
end);

# binary relations etc...

InstallMethod(AsTransformation, "for relation over [1..n]", 
[IsGeneralMapping],
function(rel)
    local ims;

    if not IsEndoGeneralMapping(rel) then
      Error(rel, " is not a binary relation");
    fi;
    ims:= ImagesListOfBinaryRelation(rel);
    if not ForAll(ims, x->Length(x) = 1) then
      return fail;
    fi;
    return Transformation(List(ims, x->x[1]));
end);

InstallMethod(AsTransformation, "for binary relations on points", 
[IsBinaryRelation and IsBinaryRelationOnPointsRep],
function(rel)
  if not IsMapping(rel) then
    Error("usage: the argument must be a binary relation which is a mapping,"); 
    return;
  fi;
    return Transformation(Flat(Successors(rel)));
end);

InstallMethod(AsBinaryRelation, "for a transformation",
[IsTransformation], 
t->BinaryRelationByListOfImagesNC(
  List(ImageListOfTransformation(t, DegreeOfTransformation(t)), x->[x])));

InstallMethod(\*, "for a general mapping and a transformation", 
[IsGeneralMapping, IsTransformation],
function(r, t)
  return r * AsBinaryRelation(t);
end);

InstallMethod(\*, "for a transformation and a general mapping",
[IsTransformation, IsGeneralMapping],
function(t, r)
  return AsBinaryRelation(t) * r;
end);

#EOF
