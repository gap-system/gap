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
##  This file contains the declaration of operations for inverse semigroups.
##

InstallMethod(GeneratorsOfInverseSemigroup,
"for a group with known generators",
[IsGroup and HasGeneratorsOfGroup],
GeneratorsOfGroup);

InstallMethod(GeneratorsOfInverseMonoid,
"for a group with known generators",
[IsGroup and HasGeneratorsOfGroup],
GeneratorsOfGroup);

InstallImmediateMethod(GeneratorsOfSemigroup,
IsInverseSemigroup and HasGeneratorsOfInverseSemigroup, 0,
function(S)
  local gens, out, x;
  gens := GeneratorsOfInverseSemigroup(S);
  out := ShallowCopy(gens);
  for x in gens do
    if not IsIdempotent(x) then
      Add(out, x ^ -1);
    fi;
  od;
  MakeImmutable(out);
  return out;
end);

#

InstallMethod(IsInverseSubsemigroup, "for a semigroup and a semigroup",
[IsSemigroup, IsSemigroup],
function(s, t)
  return IsSubsemigroup(s, t) and IsInverseSemigroup(t);
end);

#

InstallMethod(AsInverseMonoid, "for an inverse monoid",
[IsInverseMonoid], 100, IdFunc );

#

InstallMethod(AsInverseMonoid,
"for an inverse semigroup with known generators",
[IsInverseSemigroup and HasGeneratorsOfInverseSemigroup],
function(S)
  local gens, pos;

  if not (IsMultiplicativeElementWithOneCollection(S)
          and One(S) <> fail and One(S) in S) then
    return fail;
  fi;

  gens := GeneratorsOfInverseSemigroup(S);

  if CanEasilyCompareElements(gens) then
    pos := Position(gens, One(S));
    if pos <> fail then
      gens := ShallowCopy(gens);
      Remove(gens, pos);
    fi;
  fi;
  return InverseMonoid(gens);
end);

#

InstallOtherMethod(IsInverseSemigroup, "for an object", [IsObject], ReturnFalse);

#

InstallMethod(\.,"for an inverse semigroup with generators and pos int",
[IsInverseSemigroup and HasGeneratorsOfInverseSemigroup, IsPosInt],
function(s, n)
  s:=GeneratorsOfInverseSemigroup(s);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(s)<n then
    Error("the second argument should be a positive integer not greater than",
     " the number of generators of the semigroup in the first argument");
  fi;
  return s[n];
end);

#

InstallMethod(\., "for an inverse monoid with generators and pos int",
[IsInverseMonoid and HasGeneratorsOfInverseMonoid, IsPosInt],
function(s, n)
  s:=GeneratorsOfInverseMonoid(s);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(s)<n then
    Error("usage: the second argument should be a pos int not greater than",
     " the number of generators of the semigroup in the first argument");
  fi;
  return s[n];
end);

#

InstallGlobalFunction(InverseMonoid,
function(arg)
  local out, i;

  if Length(arg) = 0 or (Length(arg) = 1 and HasIsEmpty(arg[1])
      and IsEmpty(arg[1])) then
    ErrorNoReturn("Usage: cannot create an inverse monoid with no ",
                  "generators,");
  fi;

  out := [];
  for i in [1 .. Length(arg)] do
    if i = Length(arg) and IsRecord(arg[i]) then
      if not IsGeneratorsOfInverseSemigroup(out) then
        ErrorNoReturn("Usage: InverseMonoid(<gen>,...), ",
                      "InverseMonoid(<gens>), InverseMonoid(<D>),");
      fi;
      return InverseMonoidByGenerators(out, arg[i]);
    elif IsMultiplicativeElementWithOne(arg[i]) or IsMatrix(arg[i]) then
      Add(out, arg[i]);
    elif IsListOrCollection(arg[i]) then
      if IsGeneratorsOfInverseSemigroup(arg[i]) then
        if HasGeneratorsOfInverseSemigroup(arg[i]) then
          Append(out, GeneratorsOfInverseSemigroup(arg[i]));
        elif HasGeneratorsOfSemigroup(arg[i]) or IsMagmaIdeal(arg[i]) then
          Append(out, GeneratorsOfSemigroup(arg[i]));
        elif IsList(arg[i]) then
          Append(out, arg[i]);
        else
          Append(out, AsList(arg[i]));
        fi;
      elif not IsEmpty(arg[i]) then
          ErrorNoReturn("Usage: InverseMonoid(<gen>,...), ",
                        "InverseMonoid(<gens>), InverseMonoid(<D>),");
      fi;
    else
        ErrorNoReturn("Usage: InverseMonoid(<gen>,...), ",
                      "InverseMonoid(<gens>), InverseMonoid(<D>),");
    fi;
  od;
  if not IsGeneratorsOfInverseSemigroup(out) then
    ErrorNoReturn("Usage: InverseMonoid(<gen>,...), ",
                  "InverseMonoid(<gens>), InverseMonoid(<D>),");
  fi;
  return InverseMonoidByGenerators(out);
end);

#

InstallGlobalFunction(InverseSemigroup,
function(arg)
  local out, i;

  if Length(arg) = 0 or (Length(arg) = 1 and HasIsEmpty(arg[1])
      and IsEmpty(arg[1])) then
    ErrorNoReturn("Usage: cannot create an inverse semigroup with no ",
                  "generators,");
  fi;

  out := [];
  for i in [1 .. Length(arg)] do
    if i = Length(arg) and IsRecord(arg[i]) then
      if not IsGeneratorsOfInverseSemigroup(out) then
        ErrorNoReturn("Usage: InverseSemigroup(<gen>, ...), ",
                      "InverseSemigroup(<gens>), InverseSemigroup(<D>),");
      fi;
      return InverseSemigroupByGenerators(out, arg[i]);
    elif IsMultiplicativeElement(arg[i]) or IsMatrix(arg[i]) then
      Add(out, arg[i]);
    elif IsListOrCollection(arg[i]) then
      if IsGeneratorsOfInverseSemigroup(arg[i]) then
        if HasGeneratorsOfInverseSemigroup(arg[i]) then
          Append(out, GeneratorsOfInverseSemigroup(arg[i]));
        elif HasGeneratorsOfSemigroup(arg[i]) or IsMagmaIdeal(arg[i]) then
          Append(out, GeneratorsOfSemigroup(arg[i]));
        elif IsList(arg[i]) then
          Append(out, arg[i]);
        else
          Append(out, AsList(arg[i]));
        fi;
      elif not IsEmpty(arg[i]) then
          ErrorNoReturn("Usage: InverseSemigroup(<gen>, ...), ",
                        "InverseSemigroup(<gens>), InverseSemigroup(<D>),");
      fi;
    else
      ErrorNoReturn("Usage: InverseSemigroup(<gen>, ...), ",
                    "InverseSemigroup(<gens>), InverseSemigroup(<D>),");
    fi;
  od;
  if not IsGeneratorsOfInverseSemigroup(out) then
    ErrorNoReturn("Usage: InverseSemigroup(<gen >, ...), ",
                  "InverseSemigroup(<gens>), InverseSemigroup(<D>),");
  fi;
  return InverseSemigroupByGenerators(out);
end);

#

InstallMethod(InverseMonoidByGenerators,
[IsCollection],
function(gens)
  local S, one, pos;

  S := Objectify(NewType(FamilyObj(gens), IsMagmaWithOne
                                          and IsInverseSemigroup
                                          and IsAttributeStoringRep), rec());

  gens := AsList(gens);

  if CanEasilyCompareElements(gens) and IsFinite(gens)
      and IsMultiplicativeElementWithOneCollection(gens) then
    one := One(gens);
    SetOne(S, one);
    pos := Position(gens, one);
    if pos <> fail  then
      SetGeneratorsOfInverseSemigroup(S, gens);
      if Length(gens) = 1 then # Length(gens) <> 0 since One(gens) in gens
        SetIsTrivial(S, true);
      elif not IsPartialPermCollection(gens) or One(gens) =
        One(gens{Concatenation([1 .. pos - 1], [pos + 1 .. Length(gens)])}) then
        # if gens = [PartialPerm([1,2]), PartialPerm([1])], then removing the One
        # = gens[1] from this, it is not possible to recreate the semigroup using
        # Monoid(PartialPerm([1])) (since the One in this case is
        # PartialPerm([1]) not PartialPerm([1,2]) as it should be.
        gens := ShallowCopy(gens);
        Remove(gens, pos);
      fi;
      SetGeneratorsOfInverseMonoid(S, gens);
    else
      SetGeneratorsOfInverseMonoid(S, gens);
      gens := ShallowCopy(gens);
      Add(gens, one);
      SetGeneratorsOfInverseSemigroup(S, gens);
    fi;
  else
    SetGeneratorsOfInverseMonoid(S, gens);
  fi;

  return S;
end);

#

InstallMethod(InverseSemigroupByGenerators, "for a collection",
[IsCollection],
function(gens)
  local S, pos;

  S := Objectify(NewType (FamilyObj(gens), IsMagma
                                           and IsInverseSemigroup
                                           and IsAttributeStoringRep), rec());
  gens := AsList(gens);
  SetGeneratorsOfInverseSemigroup(S, gens);

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
        # if gens = [PartialPerm([1,2]), PartialPerm([1])], then removing the One
        # = gens[1] from this, it is not possible to recreate the semigroup using
        # Monoid(PartialPerm([1])) (since the One in this case is
        # PartialPerm([1]) not PartialPerm([1,2]) as it should be.
        gens := ShallowCopy(gens);
        Remove(gens, pos);
      fi;
      SetGeneratorsOfInverseMonoid(S, gens);
    fi;
  fi;
  return S;
end);

#

InstallMethod(InverseSubsemigroupNC,
"for an inverse semigroup and collection",
[IsInverseSemigroup, IsCollection],
function(s, gens)
  local t;
  t:=InverseSemigroup(gens);
  SetParent(t, s);
  return t;
end);

#

InstallMethod(InverseSubsemigroup,
"for an inverse semigroup and collection",
[IsInverseSemigroup, IsCollection],
function(s, gens)
  if ForAll(gens, x-> x in s) then
    return InverseSubsemigroupNC(s, gens);
  fi;
  ErrorNoReturn("the specified elements do not belong to the first argument,");
end);

#

InstallMethod(InverseSubmonoidNC,
"for an inverse monoid and collection",
[IsInverseMonoid, IsCollection],
function(s, gens)
  local t;

  t:=InverseMonoid(gens);
  SetParent(t, s);
  return t;
end);

#

InstallMethod(InverseSubmonoid,
"for an inverse monoid and collection",
[IsInverseMonoid, IsCollection],
function(s, gens)
  if ForAll(gens, x-> x in s) then
    if One(s)<>One(gens) then
      Append(gens, One(s));
    fi;
    return InverseSubmonoidNC(s, gens);
  fi;
  ErrorNoReturn("the specified elements do not belong to the first argument,");
end);

#

InstallMethod(IsSubsemigroup,
"for an inverse semigroup and inverse semigroup with generators",
[IsInverseSemigroup, IsInverseSemigroup and HasGeneratorsOfInverseSemigroup],
function(s, t)
  return ForAll(GeneratorsOfInverseSemigroup(t), x-> x in s);
end);

#

InstallMethod(\=, "for an inverse semigroups with generators",
[IsInverseSemigroup and HasGeneratorsOfInverseSemigroup,
IsInverseSemigroup and HasGeneratorsOfInverseSemigroup],
function(s, t)
return ForAll(GeneratorsOfInverseSemigroup(s), x-> x in t)
 and ForAll(GeneratorsOfInverseSemigroup(t), x-> x in s);
end);

InstallMethod( String,
    "for a inverse semigroup",
    [ IsInverseSemigroup ],
    function( S )
    return "InverseSemigroup( ... )";
    end );

InstallMethod( PrintObj,
    "for a inverse semigroup with known generators",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    Print( "InverseSemigroup( ", GeneratorsOfInverseSemigroup( S ), " )" );
    end );

InstallMethod( String,
    "for a inverse semigroup with known generators as an inverse semigroup",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    return STRINGIFY( "InverseSemigroup( ",
     GeneratorsOfInverseSemigroup( S ), " )" );
    end );

InstallMethod( String,
    "for a inverse semigroup with known generators as a semigroup",
    [ IsInverseSemigroup and HasGeneratorsOfSemigroup ],
    function( S )
    return STRINGIFY( "Semigroup( ",
     GeneratorsOfSemigroup( S ), " )" );
    end );

InstallMethod( PrintString,
    "for a inverse semigroup with known generators",
    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
    function( S )
    return PRINT_STRINGIFY( "InverseSemigroup( ",
     GeneratorsOfInverseSemigroup( S ), " )" );
    end );

InstallMethod( ViewString,
    "for a inverse semigroup",
    [ IsInverseSemigroup ],
    function( S )
    return "<inverse semigroup>" ;
    end );

#InstallMethod( ViewString,
#    "for a inverse semigroup with generators",
#    [ IsInverseSemigroup and HasGeneratorsOfInverseSemigroup ],
#    function( S )
#    return STRINGIFY( "<inverse semigroup with ",
#      Pluralize( Length( GeneratorsOfInverseSemigroup( S ) ), "generator" ),
#      ">" );
#    end );

#

InstallMethod( String,
    "for a inverse monoid",
    [ IsInverseMonoid ],
    function( S )
    return "InverseMonoid( ... )";
    end );

InstallMethod( PrintObj,
    "for a inverse monoid with known generators",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    Print( "InverseMonoid( ", GeneratorsOfInverseMonoid( S ), " )" );
    end );

InstallMethod( String,
    "for a inverse monoid with known generators as a monoid",
    [ IsInverseMonoid and HasGeneratorsOfMonoid ],
    function( S )
    return STRINGIFY( "Monoid( ",
     GeneratorsOfMonoid( S ), " )" );
    end );

InstallMethod( String,
    "for a inverse monoid with known generators as an inverse monoid",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    return STRINGIFY( "InverseMonoid( ",
     GeneratorsOfInverseMonoid( S ), " )" );
    end );


InstallMethod( PrintString,
    "for a inverse monoid with known generators",
    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
    function( S )
    return PRINT_STRINGIFY( "InverseMonoid( ",
     GeneratorsOfInverseMonoid( S ), " )" );
    end );

InstallMethod( ViewString,
    "for a inverse monoid",
    [ IsInverseMonoid ],
    function( S )
    return "<inverse monoid>" ;
    end );

#InstallMethod( ViewString,
#    "for a inverse monoid with generators",
#    [ IsInverseMonoid and HasGeneratorsOfInverseMonoid ],
#    function( S )
#    return STRINGIFY( "<inverse monoid with ",
#     Pluralize( Length( GeneratorsOfInverseMonoid( S ) ), "generator" ), ">" );
#    end );

#

InstallMethod( AsInverseSemigroup,
    "for an inverse semigroup",
    [ IsInverseSemigroup ], 100,
    IdFunc );

InstallMethod( AsInverseMonoid,
    "for an inverse monoid",
    [ IsInverseMonoid ], 100,
    IdFunc );


#

InstallMethod( IsRegularSemigroupElement,
"for an inverse semigroup", IsCollsElms,
[IsInverseSemigroup, IsAssociativeElement],
function(s, x)
return x in s;
end);
