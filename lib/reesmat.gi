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
##  This file contains the implementation of Rees matrix semigroups.
##

# Notes: there are essentially 3 types of semigroups here:
# 1) the whole family Rees matrix semigroup (notice that the matrix used to
# define the semigroup may contain rows or columns consisting entirely of 0s
# so it is not guaranteed that the resulting semigroup is 0-simple)
# 2) subsemigroups U of 1), which defined by a generating set and are Rees matrix
# semigroups, i.e. U=I'xG'xJ' where the whole family if IxGxJ and I', J' subsets
# of I, J and G' a subsemigroup of G.
# 3) subsemigroups of 1) obtained by removing an index or element of the
# underlying semigroup, and hence are also Rees matrix semigroups.
# 4) subsemigroups of 1) defined by generating sets which are not
# simple/0-simple.

# So, the methods with filters IsRees(Zero)MatrixSemigroup and
# HasGeneratorsOfSemigroup only apply to subsemigroups of type 2).
# Subsemigroups of type 3 already know the values of Rows, Columns,
# UnderlyingSemigroup, and Matrix.

# a Rees matrix semigroup over a semigroup <S> is simple if and only if <S> is
# simple.

InstallImmediateMethod(IsFinite, IsReesZeroMatrixSubsemigroup, 0,
function(R)
  if IsBound(ElementsFamily(FamilyObj(R))!.IsFinite) then
    if HasIsWholeFamily(R) and IsWholeFamily(R) then
      return ElementsFamily(FamilyObj(R))!.IsFinite;
    elif ElementsFamily(FamilyObj(R))!.IsFinite then
      return true;
    fi;
  fi;
  TryNextMethod();
end);

InstallImmediateMethod(IsFinite, IsReesMatrixSubsemigroup, 0,
function(R)
  if IsBound(ElementsFamily(FamilyObj(R))!.IsFinite) then
    if HasIsWholeFamily(R) and IsWholeFamily(R) then
      return ElementsFamily(FamilyObj(R))!.IsFinite;
    elif ElementsFamily(FamilyObj(R))!.IsFinite then
      return true;
    fi;
  fi;
  TryNextMethod();
end);

InstallMethod(IsFinite, "for a Rees 0-matrix subsemigroup",
[IsReesZeroMatrixSubsemigroup],
function(R)
  if HasIsFinite(ParentAttr(R)) and IsFinite(ParentAttr(R))then
    return true;
  fi;
  TryNextMethod();
end);

InstallMethod(IsFinite, "for a Rees matrix subsemigroup",
[IsReesMatrixSubsemigroup],
function(R)
  if HasIsFinite(ParentAttr(R)) and IsFinite(ParentAttr(R)) then
    return true;
  fi;
  TryNextMethod();
end);

#

InstallMethod(IsIdempotent, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement],
function(x)
  local matrix_entry, g;

  if x![1] = 0 then
    # <x> is the 0 element of the family
    return true;
  fi;

  matrix_entry := x![4][x![3]][x![1]];

  if matrix_entry = 0 then
    return false;
  fi;

  g := UnderlyingElementOfReesZeroMatrixSemigroupElement(x);
  return g * matrix_entry * g = g;
end);

#

InstallTrueMethod(IsRegularSemigroup,
IsReesMatrixSemigroup and IsSimpleSemigroup);

#

InstallMethod(IsRegularSemigroup, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],
function(R)
  local mat;

  mat := Matrix(R);
  if HasIsGroupAsSemigroup(UnderlyingSemigroup(R))
      and IsGroupAsSemigroup(UnderlyingSemigroup(R)) then
    return ForAll(Rows(R), i -> ForAny(Columns(R), j -> mat[j,i]<>0))
      and ForAll(Columns(R), j -> ForAny(Rows(R), i -> mat[j,i]<>0));
  else
    TryNextMethod();
  fi;
end);

#

InstallMethod(IsSimpleSemigroup,
"for a subsemigroup of a Rees matrix semigroup with an underlying semigroup",
[IsReesMatrixSubsemigroup and HasUnderlyingSemigroup],
R-> IsSimpleSemigroup(UnderlyingSemigroup(R)));

# This next method for `IsSimpleSemigroup` additionally requires the filter
# `IsFinite`, but is otherwise identical.  In the Semigroups package, there are
# some more general methods installed for `IsSimpleSemigroup` which include the
# filter `IsFinite`. When the rank of `IsFinite` is sufficiently large, these
# methods can beat the above method. The above method is a more specific method
# and should always be the one chosen for Rees matrix subsemigroups with known
# underlying semigroup, whether finite or infinite.

InstallMethod(IsSimpleSemigroup,
"for finite subsemigroup of a Rees matrix semigroup with underlying semigroup",
[IsReesMatrixSubsemigroup and HasUnderlyingSemigroup and IsFinite],
R -> IsSimpleSemigroup(UnderlyingSemigroup(R)));

# check that the matrix has no rows or columns consisting entirely of 0s
# and that the underlying semigroup is simple

InstallMethod(IsZeroSimpleSemigroup, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],
function(R)
  local i, mat;

  mat := Matrix(R);
  if ForAny(Columns(R), j -> ForAll(Rows(R), i -> mat[j,i] = 0))
      or ForAny(Rows(R), i -> ForAll(Columns(R), j -> mat[j,i] = 0)) then
    return false;
  fi;
  return IsSimpleSemigroup(UnderlyingSemigroup(R));
end);

#

InstallMethod(IsReesMatrixSemigroup, "for a semigroup", [IsSemigroup], ReturnFalse);

#

InstallMethod(IsReesMatrixSemigroup,
"for a Rees matrix subsemigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  local gens, I, J;

  if IsWholeFamily(R) then
    return true;
  fi;

  # it is still possible that <R> is a Rees matrix semigroup, if, for example,
  # we have a subsemigroup specified by generators which equals a subsemigroup
  # obtained by removing a row, in the case that <R> is not simple.
  gens:=GeneratorsOfSemigroup(R);
  I:=Set(gens, x-> x![1]);
  J:=Set(gens, x-> x![3]);

  return ForAll(GeneratorsOfReesMatrixSemigroupNC(ParentAttr(R), I,
    Semigroup(List(AsSSortedList(R), x-> x![2])), J), x-> x in R);
end);

#

InstallMethod(IsReesZeroMatrixSemigroup, "for a semigroup", [IsSemigroup],
ReturnFalse);

#

InstallMethod(IsReesZeroMatrixSemigroup,
"for a Rees 0-matrix subsemigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  local gens, pos, elts, I, J;

  if IsWholeFamily(R) then
    return true;
  fi;

  # it is still possible that <R> is a Rees 0-matrix semigroup, if, for
  # example, we have a subsemigroup specified by generators which equals a
  # subsemigroup obtained by removing a row, in the case that <R> is not simple.

  if MultiplicativeZero(R)<>MultiplicativeZero(ParentAttr(R)) then
    return false; #Rees 0-matrix semigroups always contain the 0.
  fi;

  gens := Unique(GeneratorsOfSemigroup(R));
  pos:=Position(gens, MultiplicativeZero(R));
  if pos<>fail then
    if Size(gens) = 1 then
      return false;
    fi;
    gens:=ShallowCopy(gens);
    Remove(gens, pos);
  fi;

  elts:=ShallowCopy(AsSSortedList(R));
  RemoveSet(elts, MultiplicativeZero(R));

  I:=Set(gens, x-> x![1]);
  J:=Set(gens, x-> x![3]);

  return ForAll(GeneratorsOfReesZeroMatrixSemigroupNC(ParentAttr(R), I,
    Semigroup(List(elts, x-> x![2])), J), x-> x in R);
end);

#

InstallMethod(ReesMatrixSemigroup, "for a semigroup and a rectangular table",
[IsSemigroup, IsRectangularTable],
function(S, mat)
  local fam, R, type, x;

  for x in mat do
    if ForAny(x, s-> not s in S) then
      ErrorNoReturn("the entries of the second argument (a rectangular ",
                    "table) must belong to the first argument (a semigroup)");
    fi;
  od;

  fam := NewFamily( "ReesMatrixSemigroupElementsFamily",
          IsReesMatrixSemigroupElement);

  if HasIsFinite(S) then
    fam!.IsFinite := IsFinite(S);
  fi;

  # create the Rees matrix semigroup
  R := Objectify( NewType( CollectionsFamily( fam ), IsWholeFamily and
   IsReesMatrixSubsemigroup and IsAttributeStoringRep ), rec() );

  # store the type of the elements in the semigroup
  type:=NewType(fam, IsReesMatrixSemigroupElement and IsPositionalObjectRep);

  fam!.type:=type;
  SetTypeReesMatrixSemigroupElements(R, type);
  SetReesMatrixSemigroupOfFamily(fam, R);

  SetMatrixOfReesMatrixSemigroup(R, mat);
  SetUnderlyingSemigroup(R, S);
  SetRowsOfReesMatrixSemigroup(R, [1..Length(mat[1])]);
  SetColumnsOfReesMatrixSemigroup(R, [1..Length(mat)]);

  if HasIsSimpleSemigroup(S) and IsSimpleSemigroup(S) then
    SetIsSimpleSemigroup(R, true);
  fi;

  if HasIsFinite(S) then
    SetIsFinite(R, IsFinite(S));
  fi;

  SetIsZeroSimpleSemigroup(R, false);
  return R;
end);

#

InstallMethod(ReesZeroMatrixSemigroup, "for a semigroup and a dense list",
[IsSemigroup, IsDenseList],
function(S, mat)
  local fam, R, type, x;

  if IsEmpty(mat) or not ForAll(mat, x -> IsDenseList(x) and not IsEmpty(x)
                                          and Length(x) = Length(mat[1])) then
    ErrorNoReturn("the second argument must be a non-empty list, whose ",
                  "entries are non-empty lists of equal length");
  fi;

  for x in mat do
    if ForAny(x, s -> not (s = 0 or s in S)) then
      ErrorNoReturn("the entries of the second argument must be 0 or belong ",
                    "to the first argument (a semigroup)");
    fi;
  od;

  fam := NewFamily("ReesZeroMatrixSemigroupElementsFamily",
                   IsReesZeroMatrixSemigroupElement);

  if HasIsFinite(S) then
    fam!.IsFinite := IsFinite(S);
  fi;

  # create the Rees matrix semigroup
  R := Objectify(NewType(CollectionsFamily(fam),
                 IsWholeFamily
                 and IsReesZeroMatrixSubsemigroup
                 and IsAttributeStoringRep), rec());

  # store the type of the elements in the semigroup
  type := NewType(fam, IsReesZeroMatrixSemigroupElement and IsPositionalObjectRep);

  fam!.type := type;
  SetTypeReesMatrixSemigroupElements(R, type);
  SetReesMatrixSemigroupOfFamily(fam, R);

  SetMatrixOfReesZeroMatrixSemigroup(R, mat);
  SetUnderlyingSemigroup(R, S);
  SetRowsOfReesZeroMatrixSemigroup(R, [1 .. Length(mat[1])]);
  SetColumnsOfReesZeroMatrixSemigroup(R, [1 .. Length(mat)]);
  SetMultiplicativeZero(R,
                        Objectify(TypeReesMatrixSemigroupElements(R), [0]));

  # cannot set IsZeroSimpleSemigroup to be <true> here since the matrix may
  # contain a row or column consisting entirely of 0s!
  # WW Also S might not be a simple semigroup (which is necessary)!
  if IsGroup(S) or (HasIsFinite(S) and IsFinite(S)) then
    GeneratorsOfSemigroup(R);
  fi;
  SetIsSimpleSemigroup(R, false);
  return R;
end);

InstallMethod(ViewObj, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup], 3, #to beat the next method
function(R)
  Print("\>\><Rees matrix semigroup \>", Length(Rows(R)), "x",
      Length(Columns(R)), "\< over \<");
  View(UnderlyingSemigroup(R));
  Print(">\<");
  return;
end);

#

InstallMethod(ViewObj, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup], PrintObj);

#

InstallMethod(PrintObj, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  Print("\><subsemigroup of \>",
        Length(Rows(ParentAttr(R))), "x", Length(Columns(ParentAttr(R))),
        "\< Rees matrix semigroup \>with ",
        Pluralize(Length(GeneratorsOfSemigroup(R)), "generator"), "\<>\<");
  return;
end);

#

InstallMethod(ViewObj, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup], 3, #to beat the next method
function(R)
  Print("\>\><Rees 0-matrix semigroup \>", Length(Rows(R)), "x",
      Length(Columns(R)), "\< over \<");
  View(UnderlyingSemigroup(R));
  Print(">\<");
  return;
end);

#

InstallMethod(ViewObj, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup], PrintObj);

InstallMethod(PrintObj, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  Print("\><subsemigroup of \>",
        Length(Rows(ParentAttr(R))), "x", Length(Columns(ParentAttr(R))),
        "\< Rees 0-matrix semigroup \>with ",
        Pluralize(Length(GeneratorsOfSemigroup(R)), "generator"), "\<>\<");
  return;
end);

#

InstallMethod(PrintObj, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup and IsWholeFamily], 2,
function(R)
  Print("ReesMatrixSemigroup( ");
  Print(UnderlyingSemigroup(R));
  Print(", ");
  Print(Matrix(R));
  Print(" )");
end);

#

InstallMethod(PrintObj, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup and IsWholeFamily], 2,
function(R)
  Print("ReesZeroMatrixSemigroup( ");
  Print(UnderlyingSemigroup(R));
  Print(", ");
  Print(Matrix(R));
  Print(" )");
end);

#

InstallMethod(Size, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup],
function(R)
  if Size(UnderlyingSemigroup(R))=infinity then
    return infinity;
  fi;

  return Length(Rows(R))*Size(UnderlyingSemigroup(R))*Length(Columns(R));
end);

#

InstallMethod(Size, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],
function(R)
  if Size(UnderlyingSemigroup(R))=infinity then
    return infinity;
  fi;

  return Length(Rows(R))*Size(UnderlyingSemigroup(R))*Length(Columns(R))+1;
end);

#

InstallMethod(Representative,
"for a subsemigroup of Rees matrix semigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup], 2,
# to beat the other method
function(R)
  return GeneratorsOfSemigroup(R)[1];
end);

#

InstallMethod(Representative, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup],
function(R)
  return Objectify(TypeReesMatrixSemigroupElements(R),
   [Rows(R)[1], Representative(UnderlyingSemigroup(R)), Columns(R)[1],
    Matrix(R)]);
end);

#

InstallMethod(Representative,
"for a subsemigroup of Rees 0-matrix semigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup], 2,
# to beat the other method
function(R)
  return GeneratorsOfSemigroup(R)[1];
end);

#

InstallMethod(Representative, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],
function(R)
  return Objectify(TypeReesMatrixSemigroupElements(R),
   [Rows(R)[1], Representative(UnderlyingSemigroup(R)), Columns(R)[1],
    Matrix(R)]);
end);


#

InstallMethod(Enumerator, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup],
function( R )

  return EnumeratorByFunctions(R, rec(

    enum:=EnumeratorOfCartesianProduct(Rows(R),
       Enumerator(UnderlyingSemigroup(R)), Columns(R), [Matrix(R)]),

    NumberElement:=function(enum, x)
      if FamilyObj(x) <> ElementsFamily(FamilyObj(R)) then
        return fail;
      fi;
      return Position(enum!.enum, [x![1], x![2], x![3], x![4]]);
    end,

    ElementNumber:=function(enum, n)
      return Objectify(TypeReesMatrixSemigroupElements(R), enum!.enum[n]);
    end,

    Length:=enum-> Length(enum!.enum),

    PrintObj:=function(enum)
      Print("<enumerator of Rees matrix semigroup>");
      return;
    end));
end);

#

InstallMethod(Enumerator, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup and HasUnderlyingSemigroup],
function( R )

  return EnumeratorByFunctions(R, rec(

    enum:=EnumeratorOfCartesianProduct(Rows(R),
       Enumerator(UnderlyingSemigroup(R)), Columns(R), [Matrix(R)]),

    NumberElement:=function(enum, x)
      local pos;

      if FamilyObj(x) <> ElementsFamily(FamilyObj(R)) then
        return fail;
      elif IsMultiplicativeZero(R, x) then
        return 1;
      fi;

      pos:=Position(enum!.enum, [x![1], x![2], x![3], x![4]]);
      if pos=fail then
        return fail;
      fi;
      return pos+1;
    end,

    ElementNumber:=function(enum, n)
      if n=1 then
        return MultiplicativeZero(R);
      fi;
      return Objectify(TypeReesMatrixSemigroupElements(R), enum!.enum[n-1]);
    end,

    Length:=enum-> Length(enum!.enum)+1,

    PrintObj:=function(enum)
      Print("<enumerator of Rees 0-matrix semigroup>");
      return;
    end));
end);

# these methods (Matrix, Rows, Columns, UnderlyingSemigroup) should only apply
# to subsemigroups defined by a generating set, which happen to be
# simple/0-simple.

InstallMethod(MatrixOfReesMatrixSemigroup, "for a Rees matrix semigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  if not IsReesMatrixSemigroup(R) then
    return fail;
  fi;
  return MatrixOfReesMatrixSemigroup(ParentAttr(R));
end);

InstallMethod(MatrixOfReesZeroMatrixSemigroup, "for a Rees 0-matrix semigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  if not IsReesZeroMatrixSemigroup(R) then
    return fail;
  fi;
  return MatrixOfReesZeroMatrixSemigroup(ParentAttr(R));
end);

# for convenience and backwards compatibility
InstallOtherMethod(Matrix, [IsReesMatrixSubsemigroup], MatrixOfReesMatrixSemigroup);
InstallOtherMethod(Matrix, [IsReesZeroMatrixSubsemigroup], MatrixOfReesZeroMatrixSemigroup);

#

InstallMethod(RowsOfReesMatrixSemigroup, "for a Rees matrix semigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  if not IsReesMatrixSemigroup(R) then
    return fail;
  fi;
  return SetX(GeneratorsOfSemigroup(R), x-> x![1]);
end);

InstallMethod(RowsOfReesZeroMatrixSemigroup, "for a Rees 0-matrix semigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  local out;
  if not IsReesZeroMatrixSemigroup(R) then
    return fail;
  fi;
  out:=SetX(GeneratorsOfSemigroup(R), x-> x![1]);
  if out[1]=0 then
    Remove(out, 1);
  fi;
  return out;
end);

#

InstallMethod(ColumnsOfReesMatrixSemigroup, "for a Rees matrix semigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  if not IsReesMatrixSemigroup(R) then
    return fail;
  fi;
  return SetX(GeneratorsOfSemigroup(R), x-> x![3]);
end);

InstallMethod(ColumnsOfReesZeroMatrixSemigroup, "for a Rees 0-matrix semigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  local out, x;

  if not IsReesZeroMatrixSemigroup(R) then
    return fail;
  fi;

  out:=[];
  for x in GeneratorsOfSemigroup(R) do
    if x![1]<>0 then
      AddSet(out, x![3]);
    fi;
  od;

  return out;
end);

# these methods only apply to subsemigroups which happen to be Rees matrix
# semigroups

InstallMethod(UnderlyingSemigroup,
"for a Rees matrix semigroup with generators",
[IsReesMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  local gens, i, S, U;

  if not IsReesMatrixSemigroup(R) then
    return fail;
  fi;

  gens:=List(AsSSortedList(R), x-> x![2]);

  if IsGeneratorsOfMagmaWithInverses(gens) then
    i:=1;
    S:=UnderlyingSemigroup(ParentAttr(R));
    U:=Group(gens[1]);
    while Size(U)<Size(S) and i<Length(gens) do
      i:=i+1;
      U:=ClosureGroup(U, gens[i]);
    od;
  else
    U:=Semigroup(gens);
  fi;

  SetIsSimpleSemigroup(U, true);
  return U;
end);

# these methods only apply to subsemigroups which happen to be Rees matrix
# semigroups

InstallMethod(UnderlyingSemigroup,
"for a Rees 0-matrix semigroup with generators",
[IsReesZeroMatrixSubsemigroup and HasGeneratorsOfSemigroup],
function(R)
  local gens, i, S, U;

  if not IsReesZeroMatrixSemigroup(R) then
    return fail;
  fi;

  #remove the 0
  gens:=Filtered(AsSSortedList(R), x-> x![1]<>0);
  Apply(gens, x-> x![2]);
  gens := Set(gens);

  if IsGeneratorsOfMagmaWithInverses(gens) then
    i:=1;
    S:=UnderlyingSemigroup(ParentAttr(R));
    U:=Group(gens[1]);
    while Size(U)<Size(S) and i<Length(gens) do
      i:=i+1;
      U:=ClosureGroup(U, gens[i]);
    od;
  else
    U:=Semigroup(gens);
  fi;

  return U;
end);

# again only for subsemigroups defined by generators...

InstallMethod(TypeReesMatrixSemigroupElements,
"for a subsemigroup of Rees matrix semigroup",
[IsReesMatrixSubsemigroup],
R -> TypeReesMatrixSemigroupElements(ParentAttr(R)));

InstallMethod(TypeReesMatrixSemigroupElements,
"for a subsemigroup of Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup],
R -> TypeReesMatrixSemigroupElements(ParentAttr(R)));

# Elements...

InstallGlobalFunction(RMSElement,
function(R, i, s, j)
  local out;

  if not (IsReesMatrixSubsemigroup(R)
     or IsReesZeroMatrixSubsemigroup(R)) then
    ErrorNoReturn("the first argument must be a Rees matrix semigroup",
                  " or Rees 0-matrix semigroup");
  fi;

  if (HasIsReesMatrixSemigroup(R) and IsReesMatrixSemigroup(R)) or
    (HasIsReesZeroMatrixSemigroup(R) and IsReesZeroMatrixSemigroup(R)) then
    if not i in Rows(R) then
      ErrorNoReturn("the second argument (a positive integer) does not ",
                    "belong to the rows of the first argument (a Rees ",
                    "(0-)matrix semigroup)");
    elif not j in Columns(R) then
      ErrorNoReturn("the fourth argument (a positive integer) does not ",
                    "belong to the columns of the first argument (a Rees ",
                    "(0-)matrix semigroup)");
    elif not s in UnderlyingSemigroup(R) then
      ErrorNoReturn("the second argument does not belong to the",
                    "underlying semigroup of the first argument (a Rees ",
                    "(0-)matrix semgiroup)");
    fi;
    return Objectify(TypeReesMatrixSemigroupElements(R), [i, s, j, Matrix(R)]);
  fi;

  out:=Objectify(TypeReesMatrixSemigroupElements(R),
   [i, s, j, Matrix(ParentAttr(R))]);

  if not out in R then # for the case R is defined by a generating set
    ErrorNoReturn("the arguments do not describe an element of the first ",
                  "argument (a Rees (0-)matrix semigroup)");
  fi;
  return out;
end);

#

InstallMethod(RowOfReesMatrixSemigroupElement,
"for a Rees matrix semigroup element", [IsReesMatrixSemigroupElement],
x-> x![1]);

#

InstallMethod(RowOfReesZeroMatrixSemigroupElement,
"for a Rees 0-matrix semigroup element", [IsReesZeroMatrixSemigroupElement],
function(x)
  if x![1] = 0 then
    return fail;
  fi;
  return x![1];
end);

#

InstallMethod(UnderlyingElementOfReesMatrixSemigroupElement,
"for a Rees matrix semigroup element", [IsReesMatrixSemigroupElement],
x-> x![2]);

#

InstallMethod(UnderlyingElementOfReesZeroMatrixSemigroupElement,
"for a Rees 0-matrix semigroup element", [IsReesZeroMatrixSemigroupElement],
function(x)
  if x![1] = 0 then
    return fail;
  fi;
  return x![2];
end);

#

InstallMethod(ColumnOfReesMatrixSemigroupElement,
"for a Rees matrix semigroup element", [IsReesMatrixSemigroupElement],
x-> x![3]);

#

InstallMethod(ColumnOfReesZeroMatrixSemigroupElement,
"for a Rees 0-matrix semigroup element", [IsReesZeroMatrixSemigroupElement],
function(x)
  if x![1] = 0 then
    return fail;
  fi;
  return x![3];
end);

#

InstallMethod(PrintObj, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement],
function(x)
  Print("RMSElement(",
        ReesMatrixSemigroupOfFamily(FamilyObj(x)),
        ", ", x![1], ", ", x![2], ", ", x![3], ")");
end);

#

InstallMethod(PrintObj, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement],
function(x)
  if x![1]=0 then
    Print("MultiplicativeZero(",
          ReesMatrixSemigroupOfFamily(FamilyObj(x)),
          ")");
    return;
  fi;
  Print("RMSElement(",
        ReesMatrixSemigroupOfFamily(FamilyObj(x)),
        ", ", x![1], ", ", x![2], ", ", x![3], ")");
end);

InstallMethod(ViewString, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement],
function(x)
  return PRINT_STRINGIFY("\>(", ViewString(x![1]), ",", ViewString(x![2]), ",",
                         ViewString(x![3]), ")\<");
end);

#

InstallMethod(ViewString, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement],
function(x)
  if x![1] = 0 then
    return "0";
  fi;
  return PRINT_STRINGIFY("\>(", ViewString(x![1]), ",", ViewString(x![2]), ",",
                         ViewString(x![3]), ")\<");
end);

#

InstallMethod(ELM_LIST, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement, IsPosInt],
function(x, i)
  if i > 3 then
    ErrorNoReturn("the second argument must be 1, 2, or 3");
  fi;
  return x![i];
end);

#

InstallMethod(ELM_LIST, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement, IsPosInt],
function(x, i)
  if x![1] = 0 then
    ErrorNoReturn("the first argument (an element of a Rees 0-matrix ",
                  "semigroup) must be non-zero");
  elif i > 3 then
    ErrorNoReturn("the second argument must be 1, 2, or 3");
  fi;
  return x![i];
end);

#

InstallMethod(ZeroOp, "for a Rees matrix semigroup element",
[IsReesMatrixSemigroupElement], ReturnFail);

#

InstallMethod(ZeroOp, "for a Rees 0-matrix semigroup element",
[IsReesZeroMatrixSemigroupElement],
function(x)
  return MultiplicativeZero(ReesMatrixSemigroupOfFamily(FamilyObj(x)));
end);

#

InstallMethod(MultiplicativeZeroOp, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup], ReturnFail);

#

InstallMethod(\*, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  return Objectify(FamilyObj(x)!.type,
   [x![1], x![2]*x![4][x![3]][y![1]]*y![2], y![3], x![4]]);
end);

#

InstallMethod(\*, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  local p;

  if x![1]=0 then
    return x;
  elif y![1]=0 then
    return y;
  fi;

  p:=x![4][x![3]][y![1]];
  if p=0 then
    return Objectify(FamilyObj(x)!.type, [0]);
  fi;
  return Objectify(FamilyObj(x)!.type, [x![1], x![2]*p*y![2], y![3], x![4]]);
end);

#

InstallMethod(\<, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  return x![1]<y![1] or (x![1]=y![1] and x![2]<y![2])
    or (x![1]=y![1] and x![2]=y![2] and x![3]<y![3]);
end);

# 0 is less than everything!

InstallMethod(\<, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  if x![1]=0 then
    return y![1]<>0;
  elif y![1]=0 then
    return false;
  fi;

  return x![1]<y![1] or (x![1]=y![1] and x![2]<y![2])
    or (x![1]=y![1] and x![2]=y![2] and x![3]<y![3]);
end);

#

InstallMethod(\=, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  return x![1]=y![1] and x![2]=y![2] and x![3]=y![3];
end);

#

InstallMethod(\=, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  if x![1]=0 then
    return y![1]=0;
  fi;
  return x![1]=y![1] and x![2]=y![2] and x![3]=y![3];
end);

#

InstallMethod(ParentAttr, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup],
function(R)
  return ReesMatrixSemigroupOfFamily(FamilyObj(Representative(R)));
end);

#

InstallMethod(ParentAttr, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup],
function(R)
  return ReesMatrixSemigroupOfFamily(FamilyObj(Representative(R)));
end);

#

InstallMethod(IsWholeFamily, "for a subsemigroup of a Rees matrix semigroup",
[IsReesMatrixSubsemigroup],
function(R)
  local S;

  if Size(R)=Size(ReesMatrixSemigroupOfFamily(ElementsFamily(FamilyObj(R))))
   then
    if not HasMatrixOfReesMatrixSemigroup(R) then # <R> is defined by generators
      S:=ParentAttr(R);
      SetMatrixOfReesMatrixSemigroup(R, Matrix(S));
      SetUnderlyingSemigroup(R, UnderlyingSemigroup(S));
      SetRowsOfReesMatrixSemigroup(R, Rows(S));
      SetColumnsOfReesMatrixSemigroup(R, Columns(S));
    fi;
    return true;
  else
    return false;
  fi;
end);

#

InstallMethod(IsWholeFamily, "for a subsemigroup of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSubsemigroup],
function(R)
  local S;

  if Size(R)=Size(ReesMatrixSemigroupOfFamily(ElementsFamily(FamilyObj(R))))
   then
    if not HasMatrixOfReesZeroMatrixSemigroup(R) then # <R> is defined by generators
      S:=ParentAttr(R);
      SetMatrixOfReesZeroMatrixSemigroup(R, Matrix(S));
      SetUnderlyingSemigroup(R, UnderlyingSemigroup(S));
      SetRowsOfReesZeroMatrixSemigroup(R, Rows(S));
      SetColumnsOfReesZeroMatrixSemigroup(R, Columns(S));
    fi;
    return true;
  else
    return false;
  fi;
end);

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallGlobalFunction(GeneratorsOfReesMatrixSemigroupNC,
function(R, I, U, J)
  local P, type, i, j, gens, u;

  P:=Matrix(R);   type:=TypeReesMatrixSemigroupElements(R);

  if IsGroup(U) then
    i:=I[1];   j:=J[1];
    if IsTrivial(U) then
      gens:=[Objectify(type, [i, P[j][i]^-1, j, P])];
    else
      gens:=List(GeneratorsOfGroup(U), x->
       Objectify( type, [i, x*P[j][i]^-1, j, P]));
    fi;

    if Length(I)>Length(J) then
      for i in [2..Length(J)] do
        Add(gens, Objectify(type, [I[i], One(U), J[i], P]));
      od;
      for i in [Length(J)+1..Length(I)] do
        Add(gens, Objectify(type, [I[i], One(U), J[1], P]));
      od;
    else
      for i in [2..Length(I)] do
        Add(gens, Objectify(type, [I[i], One(U), J[i], P]));
      od;
      for i in [Length(I)+1..Length(J)] do
        Add(gens, Objectify(type, [I[1], One(U), J[i], P]));
      od;
    fi;
  else
    gens:=[];
    for i in I do
      for u in U do
        for j in J do
          Add(gens, Objectify(type, [i, u, j, P]));
        od;
      od;
    od;
  fi;
  return gens;
end);

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallGlobalFunction(GeneratorsOfReesZeroMatrixSemigroupNC,
function(R, I, U, J)
  local P, type, i, j, gens, k, u;

  P:=Matrix(R);   type:=TypeReesMatrixSemigroupElements(R);
  i:=I[1];        j:=First(J, j-> P[j][i]<>0);

  if IsGroup(U) and IsRegularSemigroup(R) and not j=fail then
    if IsTrivial(U) then
      gens:=[Objectify(type, [i, P[j][i]^-1, j, P])];
    else
      gens:=List(GeneratorsOfGroup(U), x->
        Objectify(type, [i, x*P[j][i]^-1, j, P]));
    fi;

    for k in J do
      if k<>j then
        Add(gens, Objectify(type, [i, One(U), k, P]));
      fi;
    od;

    for k in I do
      if k<>i then
        Add(gens, Objectify(type, [k, One(U), j, P]));
      fi;
    od;
  else
    gens:=[];
    for i in I do
      for u in U do
        for j in J do
          Add(gens, Objectify(type, [i, u, j, P]));
        od;
      od;
    od;
  fi;
  return gens;
end);

# you can't do this operation on arbitrary subsemigroup of Rees matrix
# semigroups since they don't have to be simple and so don't have to have rows,
# columns etc.

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallMethod(GeneratorsOfReesMatrixSemigroup,
"for a Rees matrix subsemigroup, rows, semigroup, columns",
[IsReesMatrixSubsemigroup, IsList, IsSemigroup, IsList],
function(R, I, U, J)

  if not IsReesMatrixSemigroup(R) then
    ErrorNoReturn("the first argument must be a Rees matrix semigroup");
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then
    ErrorNoReturn("the second argument must be a non-empty subset of the ",
                  "rows of the first argument (a Rees matrix semigroup)");
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then
    ErrorNoReturn("the third argument must be a subsemigroup of the ",
                  "underlying semigroup of the first argument (a Rees matrix ",
                  "semigroup)");
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then
    ErrorNoReturn("the fourth argument must be a non-empty subset of the ",
                  "columns of the first argument (a Rees matrix semigroup)");
  fi;

  return GeneratorsOfReesMatrixSemigroupNC(R, I, U, J);
end);

# you can't do this operation on arbitrary subsemigroup of Rees matrix
# semigroups since they don't have to be simple and so don't have to have rows,
# columns etc.

# generators for the subsemigroup generated by <IxUxJ>, when <R> is a Rees
# matrix semigroup (and not only a subsemigroup).

InstallMethod(GeneratorsOfReesZeroMatrixSemigroup,
"for a Rees 0-matrix semigroup, rows, semigroup, columns",
[IsReesZeroMatrixSubsemigroup, IsList, IsSemigroup, IsList],
function(R, I, U, J)

  if not IsReesZeroMatrixSemigroup(R) then
    ErrorNoReturn("the first argument must be a Rees 0-matrix semigroup");
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then
    ErrorNoReturn("the second argument must be a non-empty subset of the ",
                  "rows of the first argument (a Rees 0-matrix semigroup)");
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then
    ErrorNoReturn("the third argument must be a subsemigroup of the ",
                  "underlying semigroup of the first argument (a Rees ",
                  "0-matrix semigroup)");
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then
    ErrorNoReturn("the fourth argument must be a non-empty subset of the ",
                  "columns of the first argument (a Rees 0-matrix semigroup)");
  fi;

  return GeneratorsOfReesZeroMatrixSemigroupNC(R, I, U, J);
end);

#

InstallMethod(GeneratorsOfSemigroup, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup],
function(R)
  return GeneratorsOfReesMatrixSemigroupNC(R, Rows(R), UnderlyingSemigroup(R),
   Columns(R));
end);

#

InstallMethod(GeneratorsOfSemigroup, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],
function(R)
  local gens;

  gens:=GeneratorsOfReesZeroMatrixSemigroupNC(R, Rows(R),
   UnderlyingSemigroup(R), Columns(R));
  if ForAll(Rows(R), i-> ForAll(Columns(R), j-> Matrix(R)[j][i]<>0)) then
    Add(gens, MultiplicativeZero(R));
  fi;
  return gens;
end);

# Note that it is possible that the rows and columns of the matrix only contain
# the zero element, if the resulting semigroup were taken to be in
# IsReesMatrixSemigroup then it would belong to IsReesMatrixSemigroup and
# IsReesZeroMatrixSubsemigroup, so that its elements belong to
# IsReesZeroMatrixSemigroupElement but not to IsReesMatrixSemigroupElement
# (since this makes reference to the whole family used to create the
# semigroups). On the other hand, if we simply exclude the 0, then every method
# for IsReesZeroMatrixSemigroup is messed up because we assume that they always
# contain the 0.
#
# Hence we always include the 0 element, even if all the matrix
# entries corresponding to I and J are non-zero.

InstallMethod(ReesZeroMatrixSubsemigroup,
"for a Rees 0-matrix semigroup, rows, semigroup, columns",
[IsReesZeroMatrixSubsemigroup, IsList, IsSemigroup, IsList],
function(R, I, U, J)

  if not IsReesZeroMatrixSemigroup(R) then
    ErrorNoReturn("the first argument must be a Rees 0-matrix semigroup");
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then
    ErrorNoReturn("the second argument must be a non-empty subset of the ",
                  "rows of the first argument (a Rees 0-matrix semigroup)");
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then
    ErrorNoReturn("the third argument must be a subsemigroup of the ",
                  "underlying semigroup of the first argument (a Rees ",
                  "0-matrix semigroup)");
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then
    ErrorNoReturn("the fourth argument must be a non-empty subset of the ",
                  "columns of the first argument (a Rees 0-matrix semigroup)");
  fi;

  return ReesZeroMatrixSubsemigroupNC(R, I, U, J);
end);

InstallGlobalFunction(ReesZeroMatrixSubsemigroupNC,
function(R, I, U, J)
  local S;

  if U=UnderlyingSemigroup(R) and ForAny(Matrix(R){J}{I}, x-> 0 in x) then
    S:=Objectify( NewType( FamilyObj(R),
     IsReesZeroMatrixSubsemigroup and IsAttributeStoringRep ), rec() );
    SetTypeReesMatrixSemigroupElements(S, TypeReesMatrixSemigroupElements(R));

    SetMatrixOfReesZeroMatrixSemigroup(S, Matrix(R));
    SetUnderlyingSemigroup(S, UnderlyingSemigroup(R));
    SetRowsOfReesZeroMatrixSemigroup(S, I);
    SetColumnsOfReesZeroMatrixSemigroup(S, J);
    SetParentAttr(S, R);

    #it might be that all the matrix entries corresponding to I and J are zero
    #and so we can't set IsZeroSimpleSemigroup here.
    SetMultiplicativeZero(S, MultiplicativeZero(R));
    SetIsSimpleSemigroup(S, false);
    SetIsReesZeroMatrixSemigroup(S, true);
    return S;
  fi;

  return Semigroup(GeneratorsOfReesZeroMatrixSemigroupNC(R, I, U, J));
end);

#

InstallMethod(ReesMatrixSubsemigroup,
"for a Rees matrix semigroup, rows, semigroup, columns",
[IsReesMatrixSubsemigroup, IsList, IsSemigroup, IsList],
function(R, I, U, J)

  if not IsReesMatrixSemigroup(R) then
    ErrorNoReturn("the first argument must be a Rees matrix semigroup");
  elif not IsSubset(Rows(R), I) or IsEmpty(I) then
    ErrorNoReturn("the second argument must be a non-empty subset of the ",
                  "rows of the first argument (a Rees matrix semigroup)");
  elif not IsSubsemigroup(UnderlyingSemigroup(R), U) then
    ErrorNoReturn("the third argument must be a subsemigroup of the ",
                  "underlying semigroup of the first argument (a Rees ",
                  "matrix semigroup)");
  elif not IsSubset(Columns(R), J) or IsEmpty(J) then
    ErrorNoReturn("the fourth argument must be a non-empty subset of the ",
                  "columns of the first argument (a Rees matrix semigroup)");
  fi;

  return ReesMatrixSubsemigroupNC(R, I, U, J);
end);

#

InstallGlobalFunction(ReesMatrixSubsemigroupNC,
function(R, I, U, J)
  local S;

  if U=UnderlyingSemigroup(R) then
    S:=Objectify( NewType( FamilyObj(R),
      IsReesMatrixSubsemigroup and IsAttributeStoringRep ), rec() );
    SetTypeReesMatrixSemigroupElements(S, TypeReesMatrixSemigroupElements(R));

    SetMatrixOfReesMatrixSemigroup(S, Matrix(R));
    SetUnderlyingSemigroup(S, UnderlyingSemigroup(R));
    SetRowsOfReesMatrixSemigroup(S, I);
    SetColumnsOfReesMatrixSemigroup(S, J);
    SetParentAttr(S, R);

    if HasIsSimpleSemigroup(R) and IsSimpleSemigroup(R) then
      SetIsSimpleSemigroup(S, true);
    fi;
    SetIsReesMatrixSemigroup(S, true);
    SetIsZeroSimpleSemigroup(S, false);
    return S;
  fi;
  return Semigroup(GeneratorsOfReesMatrixSemigroupNC(R, I, U, J));
end);

#

BindGlobal("_InjectionPrincipalFactor",
function(D, constructor)
  local map, inv, G, mat, rep, R, L, x, RR, LL, rms, iso, hom, i, j;

  map := IsomorphismPermGroup(GroupHClassOfGreensDClass(D));
  inv := InverseGeneralMapping(map);

  G := Range(map);
  mat := [];

  rep := Representative(GroupHClassOfGreensDClass(D));
  L := List(GreensHClasses(GreensRClassOfElement(Parent(D), rep)),
            Representative);
  R := List(GreensHClasses(GreensLClassOfElement(Parent(D), rep)),
            Representative);

  for i in [1 .. Length(L)] do
    mat[i] := [];
    for j in [1 .. Length(R)] do
      x := L[i] * R[j];
      if x in D then
        mat[i,j] := x ^ map;
      else
        mat[i,j] := 0;
      fi;
    od;
  od;

  RR := EmptyPlist(Length(R));
  LL := EmptyPlist(Length(L));

  for j in [1 .. Length(R)] do
    for i in [1 .. Length(L)] do
      if mat[i,j] <> 0 then
        RR[j] := ((mat[i,j] ^ -1) ^ inv) * L[i];
        break;
      fi;
    od;
  od;

  for i in [1 .. Length(L)] do
    for j in [1 .. Length(R)] do
      if mat[i,j] <> 0 then
        LL[i] := R[j] * (mat[i,j] ^ -1) ^ inv;
        break;
      fi;
    od;
  od;

  rms := constructor(G, mat);

  iso := function(x)
    i := PositionProperty(R, y -> y in GreensRClassOfElement(Parent(D), x));
    j := PositionProperty(L, y -> y in GreensLClassOfElement(Parent(D), x));

    if i = fail or j = fail then
      return fail;
    fi;
    return Objectify(TypeReesMatrixSemigroupElements(rms),
                     [i, (rep * RR[i] * x * LL[j]) ^ map, j, mat]);
  end;

  hom := MappingByFunction(D, rms, iso,
                           function(x)
                             if x![1] = 0 then
                               return fail;
                             fi;
                             return R[x![1]] * (x![2] ^ inv) * L[x![3]];
                           end);
  SetIsInjective(hom, true);
  SetIsTotal(hom, true);
  return hom;
end);

InstallMethod(IsomorphismReesMatrixSemigroup, "for a D-class",
[IsGreensDClass],
function(D)
  if Number(D, IsIdempotent) <> Length(GreensHClasses(D)) then
    ErrorNoReturn("the argument (a Green's D-class) is not a subsemigroup");
  fi;
  return _InjectionPrincipalFactor(D, ReesMatrixSemigroup);
end);

InstallMethod(IsomorphismReesMatrixSemigroup,
"for a finite simple", [IsSemigroup],
function(S)
  local rep, inj;

  if not (IsSimpleSemigroup(S) and IsFinite(S)) then
    ErrorNoReturn("the argument must be a finite simple semigroup");
  fi;

  rep := Representative(S);
  inj := _InjectionPrincipalFactor(GreensDClassOfElement(S, rep),
                                   ReesMatrixSemigroup);

  return MagmaIsomorphismByFunctionsNC(S, Range(inj),
                                       x -> x ^ inj,
                                       x -> x ^ InverseGeneralMapping(inj));
end);

InstallMethod(IsomorphismReesZeroMatrixSemigroup,
"for a finite 0-simple", [IsSemigroup],
function(S)
  local D, map, inj, inv;

  if not (IsZeroSimpleSemigroup(S) and IsFinite(S)) then
    ErrorNoReturn("the argument must be a finite 0-simple semigroup");
  fi;

  D := First(GreensDClasses(S),
             x -> not IsMultiplicativeZero(S, Representative(x)));

  map := _InjectionPrincipalFactor(D, ReesZeroMatrixSemigroup);

  # the below is necessary since map is not defined on the zero of S
  inj := function(x)
    if x = MultiplicativeZero(S) then
      return MultiplicativeZero(Range(map));
    fi;
    return x ^ map;
  end;

  inv := function(x)
    if x = MultiplicativeZero(Range(map)) then
      return MultiplicativeZero(S);
    fi;
    return x ^ InverseGeneralMapping(map);
  end;

  return MagmaIsomorphismByFunctionsNC(S,
                                       Range(map),
                                       inj,
                                       inv);
end);

#

InstallMethod(AssociatedReesMatrixSemigroupOfDClass,
"for a Green's D-class of a semigroup",
[IsGreensDClass],
function(D)

  if not IsFinite(Parent(D)) then
    TryNextMethod();
  fi;

  if not IsRegularDClass(D) then
    ErrorNoReturn("the argument should be a regular D-class");
  fi;

  if Length(GreensHClasses(D)) = Number(D, IsIdempotent) then
    return Range(IsomorphismReesMatrixSemigroup(D));
  fi;
  return Range(_InjectionPrincipalFactor(D, ReesZeroMatrixSemigroup));
end);

# so that we can find Green's relations etc

InstallMethod(MonoidByAdjoiningIdentity, [IsReesMatrixSubsemigroup],
function(R)
  local M;
  M:=Monoid(List(GeneratorsOfSemigroup(R), MonoidByAdjoiningIdentityElt));
  SetUnderlyingSemigroupOfMonoidByAdjoiningIdentity(M, R);
  return M;
end);

# so that we can find Green's relations etc

InstallMethod(MonoidByAdjoiningIdentity, [IsReesZeroMatrixSubsemigroup],
function(R)
  local M;
  M:=Monoid(List(GeneratorsOfSemigroup(R), MonoidByAdjoiningIdentityElt));
  SetUnderlyingSemigroupOfMonoidByAdjoiningIdentity(M, R);
  return M;
end);

# the next two methods by Michael Torpey and Thomas Bourne.

InstallMethod(IsomorphismReesZeroMatrixSemigroup,
"for a Rees 0-matrix subsemigroup", [IsReesZeroMatrixSubsemigroup],
function(U)
  local V, iso, inv;

  if not IsReesZeroMatrixSemigroup(U) then
    TryNextMethod();
  elif IsWholeFamily(U) then
    return MagmaIsomorphismByFunctionsNC(U, U, IdFunc, IdFunc);
  fi;

  V:=ReesZeroMatrixSemigroup(UnderlyingSemigroup(U),
                             Matrix(U){Columns(U)}{Rows(U)});

  iso := function(u)
    if u = MultiplicativeZero(U) then
      return MultiplicativeZero(V);
    fi;
    return RMSElement(V,
                      Position(Rows(U),u![1]),
                      u![2],
                      Position(Columns(U),u![3]));
  end;

  inv := function(v)
    if v = MultiplicativeZero(V) then
      return MultiplicativeZero(U);
    fi;
    return RMSElement(U, Rows(U)[v![1]], v![2], Columns(U)[v![3]]);
  end;

  return MagmaIsomorphismByFunctionsNC(U, V, iso, inv);
end);

InstallMethod(IsomorphismReesMatrixSemigroup, "for a Rees matrix subsemigroup",
[IsReesMatrixSubsemigroup],
function(U)
  local V, iso, inv;

    if not IsReesMatrixSemigroup(U) then
      TryNextMethod();
    elif IsWholeFamily(U) then
      return MagmaIsomorphismByFunctionsNC(U, U, IdFunc, IdFunc);
    fi;

    V:=ReesMatrixSemigroup(UnderlyingSemigroup(U),
     List(Matrix(U){Columns(U)}, x-> x{Rows(U)}));
   #JDM doing Matrix(U){Columns(U)}{Rows(U)} the resulting object does not know
   #IsRectangularTable, and doesn't store this after it is calculated.

    iso := function(u)
      return RMSElement(V, Position(Rows(U),u![1]), u![2],
       Position(Columns(U),u![3]));
    end;

    inv := function(v)
      return RMSElement(U, Rows(U)[v![1]], v![2], Columns(U)[v![3]]);
    end;

    return MagmaIsomorphismByFunctionsNC(U, V, iso, inv);
end);

#EOF
