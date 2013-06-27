#############################################################################
##
#W  reesmat.gi           GAP library         Andrew Solomon and Isabel Araújo
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation of Rees matrix semigroups.
##

#R  IsReesMatrixSemigroupElementRep(<obj>)
##
##  A ReesMatrix element is a triple ( <i>, <s>, <lambda>)
##  <s> is an element of the underlying semigroup
##  <i>, <lambda> are indices.
##

DeclareRepresentation("IsReesMatrixSemigroupElementRep",
	IsComponentObjectRep and IsAttributeStoringRep, rec());

# returns an element of the Rees matrix semigroup <R> where:
# <s> must be in UnderlyingSemigroup(R)
# <i> must be in [1 .. RowsOfRMS(R)]
# <j> must be in [1 .. ColumnsOfRMS(R)]

InstallGlobalFunction(RMSElement,
function(R, i, s, j)

  if not (IsReesMatrixSemigroup(R) or IsReesZeroMatrixSemigroup(R)) then
    Error("usage: the first argument must be a Rees matrix semigroup", 
    " or Rees 0-matrix semigroup,");
    return;
  fi;

  if not s in UnderlyingSemigroup(R) then
     Error("usage: the second argument must be in the underlying semigroup, ");
     return;
  fi;

  if not (i in [1 .. RowsOfRMS(R)] and
    j in [1 .. ColumnsOfRMS(R)]) then
    Error("usage: the indices are out of range,");
    return;
  fi;

  return RMSElementNC(R, i, s, j);
end);

InstallGlobalFunction(RMSElementNC, 
function(R, i, s, j)
  local elt;
  if IsReesZeroMatrixSemigroup(R) and
   IsMultiplicativeZero(UnderlyingSemigroup(R), s) then 
    return MultiplicativeZero(R);
  fi;
  elt:=Objectify(R!.TypeOfElementsInRMS, rec());
  SetUnderlyingElementOfRMSElement(elt, s);
  SetColumnOfRMSElement(elt, j);
  SetRowOfRMSElement(elt, i);
  return elt;
end);

##  Install methods for subsemigroups.

InstallMethod(MatrixOfRMS,
"for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup],
R->MatrixOfRMS(ParentAttr(R)));

InstallMethod(MatrixOfRMS,
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsSubsemigroupReesZeroMatrixSemigroup],
R->MatrixOfRMS(ParentAttr(R)));

InstallMethod(RowsOfRMS,
"for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup],
R->RowsOfRMS(ParentAttr(R)));

InstallMethod(RowsOfRMS,
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsSubsemigroupReesZeroMatrixSemigroup],
R->RowsOfRMS(ParentAttr(R)));

InstallMethod(ColumnsOfRMS,
"for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup],
R->ColumnsOfRMS(ParentAttr(R)));

InstallMethod(ColumnsOfRMS,
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsSubsemigroupReesZeroMatrixSemigroup],
R->ColumnsOfRMS(ParentAttr(R)));

InstallMethod(UnderlyingSemigroup,
"for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup],
R-> UnderlyingSemigroup(ParentAttr(R)));

InstallMethod(UnderlyingSemigroup,
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsSubsemigroupReesZeroMatrixSemigroup],
R-> UnderlyingSemigroup(ParentAttr(R)));

# Returns the Rees matrix semigroup with multiplication defined by
# <mat> whose entries are in <S>.

# NC version of this JDM
InstallGlobalFunction(ReesMatrixSemigroup,
function(S, mat)
  local m, fam, R, row;

  if not (IsSemigroup(S) and IsList(mat)) then
    Error("usage: ReesMatrixSemigroup(<semigroup>, <sandwich matrix>)");
    return;
  fi;

  m:=Length(mat[1]); 
  for row in mat do
    if not IsList(row) and Length(row) = m then
      Error("Usage: ReesMatrixSemigroup(<semigroup>, <sandwich matrix>)");
      return fail;
    fi;

    if ForAny(row, x-> not x in S) then
      Error("ReesMatrixSemigroup: the matrix must be over <S>");
      return fail;
    fi;
  od;

  fam := NewFamily( "FamilyElementsReesMatrixSemigroup",
          IsReesMatrixSemigroupElement );

  # create the Rees matrix semigroup
  R := Objectify( NewType( CollectionsFamily( fam ), IsWholeFamily and
   IsReesMatrixSemigroup and IsAttributeStoringRep ), rec() );

  # store the type of the elements in the semigroup
  R!.TypeOfElementsInRMS := NewType(fam, IsReesMatrixSemigroupElement and
   IsReesMatrixSemigroupElementRep); 
  fam!.wholeSemigroup:=R;

  SetMatrixOfRMS(R, mat);
  SetRowsOfRMS(R, m);
  SetColumnsOfRMS(R, Length(mat));
  SetUnderlyingSemigroup(R, S);
  return R;
end );

# Returns the Rees 0-matrix semigroup with multiplication defined by
# <mat> whose entries are in <S>.

# NC version of this JDM

InstallGlobalFunction(ReesZeroMatrixSemigroup,
function(S, mat)
  local m, fam, R, row;

  if not (IsSemigroup(S) and IsList(mat)) then
    Error("Usage: ReesZeroMatrixSemigroup(<semigroup>, <sandwich matrix>)");
    return;
  fi;

  m:=Length(mat[1]); 
  for row in mat do
    if not IsList(row) and Length(row)=m then
      Error("Usage: ReesZeroMatrixSemigroup(<semigroup>, <sandwich matrix>)");
      return;
    fi;

    if ForAny(row, x-> not x in S) then
      Error("ReesZeroMatrixSemigroup: the matrix must be over <S>");
      return fail;
    fi;
  od;

  fam := NewFamily( "FamilyElementsReesZeroMatrixSemigroup",
   IsReesZeroMatrixSemigroupElement );

  # create the semigroup
  R:=Objectify( NewType( CollectionsFamily( fam ), IsWholeFamily and	
   IsReesZeroMatrixSemigroup and IsAttributeStoringRep), rec());

  fam!.wholeSemigroup:=R;
  R!.TypeOfElementsInRMS := NewType(fam, IsReesZeroMatrixSemigroupElement and
   IsReesMatrixSemigroupElementRep); 


  SetMatrixOfRMS(R, mat);
  SetRowsOfRMS(R, m);
  SetColumnsOfRMS(R, Length(mat));
  SetUnderlyingSemigroup(R, S);

  if HasIsZeroGroup(S) and IsZeroGroup(S) then
    SetIsZeroSimpleSemigroup(R, true);
  fi;

  return R;
end );

InstallOtherMethod(MultiplicativeZero, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup], 
R-> Objectify(R!.TypeOfElementsInRMS, rec()));

InstallOtherMethod(MultiplicativeZero, 
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsSubsemigroupReesZeroMatrixSemigroup], 
R-> MultiplicativeZero(ParentAttr(R)));

InstallOtherMethod(MultiplicativeZeroOp, 
"for a an element of a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroupElement], 
x-> MultiplicativeZero(FamilyObj(x)!.wholeSemigroup));

InstallMethod( PrintObj, "for elements of Rees matrix semigroups",
[IsReesMatrixSemigroupElement],
function(x)
  Print("(", RowOfRMSElement(x),",", UnderlyingElementOfRMSElement(x),
  ",", ColumnOfRMSElement(x), ")");
end);

InstallMethod( PrintObj, "for elements of Rees zero matrix semigroups",
[IsReesZeroMatrixSemigroupElement],
function(x)
  if IsMultiplicativeZero(FamilyObj(x)!.wholeSemigroup, x) then
    Print("0");
  else
    Print("(",RowOfRMSElement(x),",",UnderlyingElementOfRMSElement(x),
     ",",ColumnOfRMSElement(x), ")");
  fi;
  return;
end);

InstallMethod(ViewObj, "for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup],
function(R)
  if not HasIsWholeFamily(R) then
    Print("<subsemigroup of ", ParentAttr(R), ">");
  else
    Print("\><Rees matrix semigroup ", RowsOfRMS(R), "x", ColumnsOfRMS(R), 
    " over ");
    View(UnderlyingSemigroup(R));
    Print(">\<");
  fi;
  return;
end);

InstallMethod(ViewObj, "for Rees zero matrix semigroups",
[IsSubsemigroupReesZeroMatrixSemigroup],
function(R)
  if not HasIsWholeFamily(R) then
    Print("<subsemigroup of ", ParentAttr(R), ">");
  else
    Print("\><Rees 0-matrix semigroup ", RowsOfRMS(R), "x", ColumnsOfRMS(R), 
    " over ");
    View(UnderlyingSemigroup(R));
    Print(">\<");
  fi;
  return;
end);

InstallMethod( PrintObj, "for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup], ViewObj);

InstallMethod( PrintObj, "for Rees zero matrix semigroups",
[IsSubsemigroupReesZeroMatrixSemigroup], ViewObj);

# The product of two Rees matrix semigroup elements 
# (i,a,k), (j, b, l) is (i, a*mat[k][j]*b, l)
# where mat is the sandwich matrix of R.

InstallMethod(\*, "for elements of a Rees matrix semigroup",
IsIdenticalObj, [IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  local R, i, j, k, l, mat;

  R := FamilyObj(x)!.wholeSemigroup;
  i := RowOfRMSElement(x);
  j := RowOfRMSElement(y);
  k := ColumnOfRMSElement(x);
  l := ColumnOfRMSElement(y);
  mat := MatrixOfRMS(R);

  return RMSElementNC(R, i, 
   UnderlyingElementOfRMSElement(x)*mat[k][j]*UnderlyingElementOfRMSElement(y), l);
end);

InstallMethod(\*, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj, 
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  local R, zero, i, j, k, l, mat;

  R := FamilyObj(x)!.wholeSemigroup;
  zero:=MultiplicativeZero(R);
  if x=zero or y=zero then 
    return zero;
  fi;

  i := RowOfRMSElement(x);
  j := RowOfRMSElement(y);
  k := ColumnOfRMSElement(x);
  l := ColumnOfRMSElement(y);
  mat := MatrixOfRMS(R);

  return RMSElementNC(R, i, 
   UnderlyingElementOfRMSElement(x)*mat[k][j]*UnderlyingElementOfRMSElement(y), l);
end);

InstallMethod( Size, "for a Rees matrix semigroup", [ IsReesMatrixSemigroup ],
function(r)
  local s, m, n;

  s := UnderlyingSemigroup( r );
  m := RowsOfRMS( r );
  n := ColumnsOfRMS( r );

  if Size(s) = infinity or m = infinity or n = infinity then
    return infinity;
  fi;

  return Size( s ) * m * n;
end);

InstallMethod( Size, "for a Rees 0-matrix semigroup", 
[ IsReesZeroMatrixSemigroup ],
function(r)
  local s, m, n;

  s := UnderlyingSemigroup( r );
  m := RowsOfRMS( r );
  n := ColumnsOfRMS( r );

  if Size(s) = infinity or m = infinity or n = infinity then
    return infinity;
  fi;

  return (Size( s )-1) * m * n + 1;
end);

# lexicographic

InstallMethod(\<, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(x, y)
  local a, b, i, j, k, l;

  a := UnderlyingElementOfRMSElement(x);
  b := UnderlyingElementOfRMSElement(y);
  i := RowOfRMSElement(x);
  j := RowOfRMSElement(y);
  k := ColumnOfRMSElement(x);
  l := ColumnOfRMSElement(y);

  if (a<b) or (a=b and i<j) or (a=b and i=j and k<l) then
    return true;
  fi;
  return false;
end);

InstallMethod(\<, "for elements of a Rees zero matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(x, y)
  local R, a, b, i, j, k, l;

  R:=FamilyObj(x)!.wholeSemigroup;
  if IsMultiplicativeZero(R, y) then 
    return false;
  elif IsMultiplicativeZero(R, x) then 
    return true;
  fi;

  a := UnderlyingElementOfRMSElement(x);
  b := UnderlyingElementOfRMSElement(y);
  i := RowOfRMSElement(x);
  j := RowOfRMSElement(y);
  k := ColumnOfRMSElement(x);
  l := ColumnOfRMSElement(y);

  if (a<b) or (a=b and i<j) or (a=b and i=j and k<l) then
    return true;
  fi;
  return false;
end);

InstallMethod(\=, "for elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement],
function(a, b)

  return (RowOfRMSElement(a) = RowOfRMSElement(b)) and
   (ColumnOfRMSElement(a) = ColumnOfRMSElement(b)) and
   (UnderlyingElementOfRMSElement(a) = UnderlyingElementOfRMSElement(b));
end);

InstallMethod(\=, "for elements of a Rees 0-matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement],
function(a, b)
  local R;

  R:=FamilyObj(a)!.wholeSemigroup;
  if IsIdenticalObj(MultiplicativeZero(R), a) then 
    return IsIdenticalObj(MultiplicativeZero(R), b);
  elif IsIdenticalObj(MultiplicativeZero(R), b) then 
    return false;
  fi;
  return (RowOfRMSElement(a) = RowOfRMSElement(b)) and
   (ColumnOfRMSElement(a) = ColumnOfRMSElement(b)) and
   (UnderlyingElementOfRMSElement(a) = UnderlyingElementOfRMSElement(b));
end);

InstallMethod(GeneratorsOfSemigroup, "for a Rees matrix semigroup",
[IsReesMatrixSemigroup], 
function(R)
  local s, gens, one;
  
  s:=UnderlyingSemigroup(R);
  if not IsMonoid(s) then 
    TryNextMethod();
  fi;
  gens:=List(GeneratorsOfMonoid(s), x-> 
   RMSElementNC(R, 1, x, 1));
  one:=One(s);
  Append(gens, List([1..RowsOfRMS(R)], x->
   RMSElementNC(R, x, one, 1)));
  Append(gens, List([1..ColumnsOfRMS(R)], x-> 
   RMSElementNC(R, 1, one, x)));
  return gens;
end);

#JDM this doesn't work in the case that the matrix is not normalised.
# InstallMethod(GeneratorsOfSemigroup, "for a Rees 0-matrix semigroup",
# [IsReesZeroMatrixSemigroup], 
# function(R)
#   local s, gens, one;
#   
#   s:=UnderlyingSemigroup(R);
#   if not IsMonoid(s) then 
#     TryNextMethod();
#   fi;
#   if ForAny(MatrixOfRMS(R), x-> ForAny(x, y-> IsMultiplicativeZero(s, y))) then 
#     gens:=[];
#   else
#     gens:=[MultiplicativeZero(R)];
#   fi;
#   Append(gens, List(GeneratorsOfMonoid(s), x-> 
#    RMSElementNC(R, 1, x, 1)));
#   one:=One(s);
#   Append(gens, List([1..RowsOfRMS(R)], x->
#    RMSElementNC(R, x, one, 1)));
#   Append(gens, List([1..ColumnsOfRMS(R)], x-> 
#    RMSElementNC(R, 1, one, x)));
#   return gens;
# end);
# 

InstallMethod(Enumerator, "for a Rees matrix semigroup", [IsReesMatrixSemigroup],    
function( R )
  local S, enum;
  
  # this method only works for the whole Rees matrix semigroup
  S:=UnderlyingSemigroup(R);
  
  enum:=EnumeratorOfCartesianProduct([1..RowsOfRMS(R)], 
   Enumerator(S), [1..ColumnsOfRMS(R)]);

  return EnumeratorByFunctions(R, rec(
    
    enum:=enum,
    
    NumberElement:=function(enum, elt)
      return Position(enum!.enum, 
      [RowOfRMSElement(elt),
      UnderlyingElementOfRMSElement(elt),
      ColumnOfRMSElement(elt)]);
    end,
    
    ElementNumber:=function(enum, n)
      local elt;
      elt:=enum!.enum[n];
      return RMSElementNC(R, elt[1], elt[2], elt[3]);
    end,
    
    Length:=enum-> Length(enum!.enum),

    PrintObj:=function(enum) Print("<enumerator of Rees matrix semigroup>");
    return;
    end));
end);

InstallMethod(Enumerator, "for a Rees 0-matrix semigroup",
[IsReesZeroMatrixSemigroup],    
function( R )
  local S, enum;
  
  # this method only works for the whole Rees matrix semigroup
  S:=UnderlyingSemigroup(R);
  
  enum:=EnumeratorOfCartesianProduct([1..RowsOfRMS(R)], 
   Filtered(S, x-> not IsMultiplicativeZero(S, x)), [1..ColumnsOfRMS(R)]);

  return EnumeratorByFunctions(R, rec(
    
    enum:=enum,
    
    NumberElement:=function(enum, elt)
      if not IsMultiplicativeZero(R, elt) then 
        return Position(enum!.enum, 
        [RowOfRMSElement(elt), UnderlyingElementOfRMSElement(elt),
      ColumnOfRMSElement(elt)])+1;
      fi; 
      return 1;
    end,
    
    ElementNumber:=function(enum, n)
      local elt;
      if n=1 then 
        return MultiplicativeZero(R);
      fi;
      elt:=enum!.enum[n-1];
      return RMSElementNC(R, elt[1], elt[2], elt[3]);
    end,
    
    Length:=enum-> Length(enum!.enum)+1,

    PrintObj:=function(enum) Print("<enumerator of Rees 0-matrix semigroup>");
    return;
    end));
end);

InstallMethod(IsomorphismReesMatrixSemigroup, 
"for a finite simple or 0-simple semigroup",
[IsSemigroup],
function(s)
  local iso_s_t, t, it, rep, d, h, iso_h_g, lreps, rreps, matrix, x, r, inv, iso, i, j;
  
  if not (IsSimpleSemigroup(s) or IsZeroSimpleSemigroup(s)) or not 
   IsFinite(s) then 
    Error("usage: the argument should be a finite simple or",
    " 0-simple semigroup,");
    return;
  fi;
  
  if not IsTransformationSemigroup(s) then  
    iso_s_t:=IsomorphismTransformationSemigroup(s);
    t:=Range(IsomorphismTransformationSemigroup(s));
  else
    iso_s_t:=MappingByFunction(s, s, x->x, x->x);
    t:=s;
  fi;

  # a group H-class
  it:=Iterator(t);
  rep:=NextIterator(it);
  if IsZeroSimpleSemigroup(t) and rep=MultiplicativeZero(t) then 
    rep:=NextIterator(it);
  fi;

  d:=GreensDClassOfElement(t, rep);
  h:=GroupHClassOfGreensDClass(d);
  rep:=Representative(h);

  iso_h_g:=IsomorphismPermGroup(h);

  if IsZeroSimpleSemigroup(s) then 
    iso_h_g:=CompositionMapping(InjectionZeroMagma(Range(iso_h_g)), iso_h_g);
    SetIsSingleValued(iso_h_g, true);
    SetIsTotal(iso_h_g, true);
    SetIsBijective(iso_h_g, true);
  fi;

  lreps:=List(GreensHClasses(GreensRClassOfElement(t, rep)), Representative);
  rreps:=List(GreensHClasses(GreensLClassOfElement(t, rep)), Representative);
  
  matrix := [];
  for i in [1..Length(lreps)] do
    matrix[ i ] := [];
    for j in [1..Length(rreps)] do
      x:=lreps[i]*rreps[j];
      if IsZeroSimpleSemigroup(s) and x=MultiplicativeZero(t) then 
        matrix[i][j]:=MultiplicativeZero(Range(iso_h_g));
      else
        matrix[i][j]:=Image(iso_h_g, x);
      fi;
    od;
  od;

  if IsZeroSimpleSemigroup(s) then
    r:=ReesZeroMatrixSemigroup(Range(iso_h_g), matrix);
  else
    r:=ReesMatrixSemigroup(Range(iso_h_g), matrix);
  fi;

  # from r to s
  inv:=function(x)
    local i,j,t;
    if IsReesZeroMatrixSemigroup(r) and IsMultiplicativeZero(r, x) then
      return MultiplicativeZero(s);
    fi;

    i:=RowOfRMSElement(x);
    j:=ColumnOfRMSElement(x);
    t:=UnderlyingElementOfRMSElement(x);

    return PreImage(iso_s_t, rreps[i]*PreImage(iso_h_g,t)*lreps[j]);
  end;

  iso:=MagmaHomomorphismByFunctionNC(r, s, inv);
  SetIsTotal(iso, true);
  SetIsSingleValued(iso, true);
  SetIsBijective(iso, true);
  return InverseGeneralMapping(iso);
end);

#JDM: the functions from here on down need to be redone...

InstallMethod(AssociatedReesMatrixSemigroupOfDClass, 
"for a Green's D-class of a semigroup",
[IsGreensDClass],
function( D )
  local h, phi, g, psi, gz, fun, map, r, l, rreps, lreps, n, m, mat;

  if not IsFinite(AssociatedSemigroup(D)) then
    TryNextMethod();
  fi;

    if not IsRegularDClass(D) then
        Error("usage: the argument should be a regular D-class,");
        return;
    fi;

    h:= GroupHClassOfGreensDClass(D);

    # find the isomorphic perm group.
    phi:=IsomorphismPermGroup(h);
    g:= Range(phi);
    psi:=InjectionZeroMagma(g);
    gz:= Range(psi);

    # build the function
    fun:= function(x)
      if not x in h then
        return MultiplicativeZero(gz);
      fi;
      return x^phi;
    end;

    map:= MappingByFunction(AssociatedSemigroup(D), gz, fun);

    r:= EquivalenceClassOfElement(GreensRRelation(AssociatedSemigroup(D)),
        Representative(h));
    l:= EquivalenceClassOfElement(GreensLRelation(AssociatedSemigroup(D)),
        Representative(h));

    rreps:= List(GreensHClasses(l), Representative);
    lreps:= List(GreensHClasses(r), Representative);

    n:= Length(rreps);
    m:= Length(lreps);

    mat:=List([1..m], x->List([1..n], y-> (lreps[x]*rreps[y])^map));

    if ForAll(mat, x->ForAll(x, y -> y <> MultiplicativeZero(gz))) then
      return ReesMatrixSemigroup(g, mat);
    else
      # ensure the elements of the matrix are in gz
      mat:=List(mat, x->List(x, function(y)
        if y<>MultiplicativeZero(gz) then 
          return y^psi; 
        fi;
        return y; 
        end));
      return ReesZeroMatrixSemigroup(gz, mat);
    fi;
end);

InstallMethod(ParentAttr, "for a subsemigroup of a Rees matrix semigroup",
[IsSubsemigroupReesMatrixSemigroup],
function(s)
  if not HasIsWholeFamily(s) or (HasIsWholeFamily(s) and not IsWholeFamily(s))
   then
    return FamilyObj(Representative(s))!.wholeSemigroup;
  fi;
  return s;
end);

InstallMethod(ParentAttr, 
"for a subsemigroup of a Rees 0-matrix semigroup",
[IsSubsemigroupReesZeroMatrixSemigroup],
function(s)
  if not HasIsWholeFamily(s) or (HasIsWholeFamily(s) and not IsWholeFamily(s))
    then 
    return FamilyObj(Representative(s))!.wholeSemigroup;
  fi;
  return s;
end);

InstallMethod(IsWholeFamily, "for a subsemigroup of a Rees matrix semigroup", 
[IsSubsemigroupReesMatrixSemigroup], s-> Size(s)=Size(ParentAttr(s)));

InstallMethod(Representative, "for a subsemigroup of Rees 0-matrix semigroup", 
[IsSubsemigroupReesMatrixSemigroup], 
function(s)

  if HasGeneratorsOfSemigroup(s) then # s is subsemigroup
    return GeneratorsOfSemigroup(s)[1];
  fi;
  # s must be the whole family

  return RMSElementNC(s, 1, Representative(UnderlyingSemigroup(s)), 1);
end);

InstallMethod(IsWholeFamily, "for a subsemigroup of a Rees 0-matrix semigroup", 
[IsSubsemigroupReesZeroMatrixSemigroup], s-> Size(s)=Size(ParentAttr(s)));

InstallMethod(Representative, "for a subsemigroup of Rees 0-matrix semigroup", 
[IsSubsemigroupReesZeroMatrixSemigroup], 
function(s)

  if HasGeneratorsOfSemigroup(s) then # s is subsemigroup
    return GeneratorsOfSemigroup(s)[1];
  fi;
  # s must be the whole family

  return RMSElementNC(s, 1, Representative(UnderlyingSemigroup(s)), 1);
end);

