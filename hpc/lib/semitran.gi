############################################################################
##
#W  semitran.gi           GAP library                         J. D. Mitchell
##
##
#Y  Copyright (C)  2013,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
  return Elements(S)<Elements(T);
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

#

InstallMethod(AsMonoid,
"for transformation semigroup with generators",
[IsTransformationSemigroup and HasGeneratorsOfSemigroup],
function(S)
  if One(S)<>fail then
    return Monoid(GeneratorsOfSemigroup(S));
  else
    return fail;
  fi;
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
  else 
    return DegreeOfTransformationCollection(GeneratorsOfSemigroup(S));
  fi;
end);

#

InstallMethod(IsomorphismPermGroup,
"for a group H-class of a semigroup",
[IsGreensHClass],
function( h )
  local enum, permgroup, i, perm, j, elts;

  if not(IsFinite(h)) then
    TryNextMethod();
  fi;

  if not( IsGroupHClass(h) ) then
    Error("can only create isomorphisms of group H-classes");
    return;
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

  return MappingByFunction( h, permgroup, a -> elts[Position( enum, a )]);
end);

#

InstallMethod(IsomorphismTransformationSemigroup,
"for a semigroup of general mappings",
[IsSemigroup and IsGeneralMappingCollection and HasGeneratorsOfSemigroup],
function( s )
  local egens, gens, mapfun;

  egens := GeneratorsOfSemigroup(s);
  if not ForAll(egens, g->IsMapping(g)) then
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
    Error("usage: the argument must be a positive integer,");
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

  n:=DegreeOfTransformationSemigroup(s);
  if HasSize(s) then
    return Size(s)=n^n;
  fi;

  t:=FullTransformationSemigroup(n);
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
  local n, Membership, PrintObj;
  
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

    PrintObj:=function(enum)
      Print("<enumerator of full transformation semigroup on ", n," pts>");
    end));
end);

# isomorphisms and anti-isomorphisms

InstallMethod(IsomorphismTransformationMonoid, 
"for a perm group with generators",
[IsPermGroup and HasGeneratorsOfGroup], 
function(g)
  local s, conj;
  
  s:=Monoid(List(GeneratorsOfGroup(g), 
   x-> TransformationOp(x, MovedPoints(g))));
  
  UseIsomorphismRelation(g, s);

  conj:=MappingPermListList([1..NrMovedPoints(g)], MovedPoints(g));

  return MagmaIsomorphismByFunctionsNC(g, s, 
   x-> TransformationOp(x, MovedPoints(g)), 
   x-> Permutation(x, [1..NrMovedPoints(g)])^conj);
end);

#

InstallMethod(IsomorphismTransformationSemigroup, 
"for a perm group with generators",
[IsPermGroup and HasGeneratorsOfGroup], 
function(g)
  local s, conj;
  
  s:=Semigroup(List(GeneratorsOfGroup(g), 
   x-> TransformationOp(x, MovedPoints(g))));
  UseIsomorphismRelation(g, s);
  conj:=MappingPermListList([1..NrMovedPoints(g)], MovedPoints(g));

  return MagmaIsomorphismByFunctionsNC(g, s, 
   x-> TransformationOp(x, MovedPoints(g)), 
   x-> Permutation(x, [1..NrMovedPoints(g)])^conj);
end);

#

InstallMethod(IsomorphismTransformationSemigroup, 
"for a semigroup with generators",
[IsSemigroup and HasGeneratorsOfSemigroup],
function( s )
  local en, act, gens;

  en:=EnumeratorSorted(s);
  
  act:=function(i, x)
    if i<=Length(en) then 
      return Position(en, en[i]*x);
    fi;
    return Position(en, x);
  end;
  
  gens := List(GeneratorsOfSemigroup(s), 
   x-> TransformationOp(x, [1..Length(en)+1], act));

  return MagmaIsomorphismByFunctionsNC( s, Semigroup( gens ), 
   x-> TransformationOp(x, [1..Length(en)+1], act), 
   x-> en[(Length(en)+1)^x]);
end);

#

InstallMethod(IsomorphismTransformationSemigroup,
"for a semigroup with multiplicative neutral element and generators",
[IsSemigroup and HasMultiplicativeNeutralElement and HasGeneratorsOfSemigroup],
function(s)
  local en, act, gens, pos;

  en:=EnumeratorSorted(s);
  
  act:=function(i, x)
    if i<=Length(en) then 
      return Position(en, en[i]*x);
    fi;
    return Position(en, x);
  end;
  
  gens := List(GeneratorsOfSemigroup(s), 
   x-> TransformationOp(x, [1..Length(en)], act));
  
  pos:=Position(en, MultiplicativeNeutralElement(s));

  return MagmaIsomorphismByFunctionsNC( s, Semigroup( gens ), 
   x-> TransformationOp(x, [1..Length(en)], act), 
   x-> en[pos^x]);
end);

#

InstallMethod(IsomorphismTransformationMonoid, 
"for a semigroup with multiplicative neutral element and generators",
[IsSemigroup and HasMultiplicativeNeutralElement and HasGeneratorsOfSemigroup],
IsomorphismTransformationSemigroup);

#

InstallMethod(IsomorphismTransformationSemigroup, "for a semigroup",
[IsSemigroup],
function( s )
  local en, act, gens;

  en:=EnumeratorSorted(s);
  
  act:=function(i, x)
    if i<=Length(en) then 
      return Position(en, en[i]*x);
    fi;
    return Position(en, x);
  end;
  
  gens := List(en, x-> TransformationOp(x, [1..Length(en)+1], act));

  return MagmaIsomorphismByFunctionsNC( s, Semigroup( gens ), 
   x-> TransformationOp(x, [1..Length(en)+1], act), 
   x-> en[(Length(en)+1)^x]);
end);

#

InstallMethod(IsomorphismTransformationSemigroup, "for a transformation semigroup", 
[IsTransformationSemigroup], 
function(S)
  return MagmaIsomorphismByFunctionsNC(S, S, IdFunc, IdFunc);
end);

#

InstallMethod(IsomorphismTransformationSemigroup,
"for a semigroup with multiplicative neutral element",
[IsSemigroup and HasMultiplicativeNeutralElement],
function(s)
  local en, act, gens, pos;

  en:=EnumeratorSorted(s);
  
  act:=function(i, x)
    if i<=Length(en) then 
      return Position(en, en[i]*x);
    fi;
    return Position(en, x);
  end;
  
  gens := List(en, x-> TransformationOp(x, [1..Length(en)], act));
  pos:=Position(en, MultiplicativeNeutralElement(s));

  return MagmaIsomorphismByFunctionsNC( s, Semigroup( gens ), 
   x-> TransformationOp(x, [1..Length(en)], act), 
   x-> en[pos^x]);
end);

#

InstallMethod(AntiIsomorphismTransformationSemigroup,
"for a semigroup with generators",
[IsSemigroup and HasGeneratorsOfSemigroup],
function(s)
  local en, act, gens;

  en:=EnumeratorSorted(s);
  
  act:=function(i, x)
    if i<=Length(en) then 
      return Position(en, x*en[i]);
    fi;
    return Position(en, x);
  end;
  
  gens := List( GeneratorsOfSemigroup( s ), x-> 
   TransformationOp(x, [1..Length(en)+1], act));

  return MagmaIsomorphismByFunctionsNC( s, Semigroup( gens ), 
   x-> TransformationOp(x, [1..Length(en)+1], act), 
   x-> en[(Length(en)+1)^x]);
end);

#

InstallMethod(IsomorphismTransformationSemigroup, 
"for partial perm semigroup",
[IsPartialPermSemigroup],
function(s)
  local n, gens1, m, gens2, iso, u, i;
 
  if DomainOfPartialPermCollection(s)=[] then 
    # semigroup consisting of the empty set
    return MagmaIsomorphismByFunctionsNC(s, Semigroup(Transformation([1])), 
    x-> Transformation([1]), x-> PartialPermNC([]));
  fi;

  n:=Maximum(DegreeOfPartialPermCollection(s),
   CodegreeOfPartialPermCollection(s))+1;
  gens1:=GeneratorsOfSemigroup(s); 
  m:=Length(gens1);
  gens2:=EmptyPlist(m);

  for i in [1..m] do 
    gens2[i]:=AsTransformation(gens1[i], n);
  od;

  return MagmaIsomorphismByFunctionsNC(s, Semigroup(gens2), 
   x-> AsTransformation(x, n), AsPartialPerm);
end);

#

InstallMethod(IsomorphismTransformationMonoid, 
"for partial perm semigroup",
[IsPartialPermSemigroup],
function(s)
  local n, gens1, m, gens2, iso, u, i;
  
  if not (IsMonoid(s) or One(s)<>fail) then 
    Error("usage: the argument should define a monoid,");
    return;
  fi;

  n:=Maximum(DegreeOfPartialPermCollection(s),
   CodegreeOfPartialPermCollection(s))+1;
  gens1:=GeneratorsOfSemigroup(s); 
  m:=Length(gens1);
  gens2:=EmptyPlist(m);

  for i in [1..m] do 
    gens2[i]:=AsTransformation(gens1[i], n);
  od;

  return MagmaIsomorphismByFunctionsNC(s, Monoid(gens2), x->
   AsTransformation(x, n), AsPartialPerm);
end);

#EOF
