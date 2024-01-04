#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for magmas with zero adjoined.
##

InstallMethod(MultiplicativeZero, "for a multiplicative element with zero",
[IsMultiplicativeElementWithZero],
function(x)
  return MultiplicativeZeroOp(x);
end);

InstallMethod( IsMultiplicativeZero,
"for magma with multiplicative zero and multiplicative element",
IsCollsElms,
[ IsMagma and HasMultiplicativeZero, IsMultiplicativeElement],
function( M, z )
  return z = MultiplicativeZero(M);
end);

#

InstallMethod( IsMultiplicativeZero,
"for a magma and multiplicative element",
IsCollsElms,
[ IsMagma, IsMultiplicativeElement],
function(M, z)
  local i, en, x;

  i := 1;
  en := Enumerator(M);
  while IsBound(en[i]) do
    x := en[i];
    if x*z <> z or z*x <> z then
      return false;
    fi;
    i := i +1;
  od;
  SetMultiplicativeZero(M,Immutable(z));
  return true;
end);

#

InstallMethod( IsMultiplicativeZero,
"for a semigroup with generators and multiplicative element",
IsCollsElms,
[IsSemigroup and HasGeneratorsOfSemigroup, IsMultiplicativeElement],
function(S, z)
  if HasMultiplicativeZero(S) then
    return z=MultiplicativeZero(S);
  elif ForAll(GeneratorsOfSemigroup(S), x->x*z=z and z*x=z) then
    SetMultiplicativeZero(S, Immutable(z));
    return true;
  fi;
  return false;
end);

#

InstallOtherMethod( MultiplicativeZero, "for a magma",
[ IsMagma ],
function( M )
  local en, i;

  en := Enumerator(M);
  i := 1;
  while (IsBound(en[i])) do
    if IsMultiplicativeZero(M, en[i]) then
      return en[i];
    fi;
    i := i +1;
  od;
  return fail;
end );

# MagmaWithZeroAdjoined

InstallMethod(MagmaWithZeroAdjoined, "for a magma with 0 adjoined element",
[IsMagmaWithZeroAdjoinedElementRep],
function( elm )
  return FamilyObj(elm)!.MagmaWithZeroAdjoined;
end);

#

InstallMethod(MagmaWithZeroAdjoined, "for a magma",
[IsMagma], m-> Range(InjectionZeroMagma(m)));

#

InstallMethod( OneMutable, "for an element of a magma with zero adjoined",
[IsMultiplicativeElementWithOne and IsMagmaWithZeroAdjoinedElementRep],
x-> One(MagmaWithZeroAdjoined(x)));

#

InstallMethod( MultiplicativeZeroOp,
"for an element of a magma with zero adjoined",
[ IsMagmaWithZeroAdjoinedElementRep],
function( elm )
  return MultiplicativeZero(MagmaWithZeroAdjoined(elm));
end );

#

InstallMethod(InjectionZeroMagma, "for a magma",
[IsMagma],
function(m)
  local filts, fam, type, inj, zero, gens, out;

  if Length(GeneratorsOfMagma(m))=0 then
    ErrorNoReturn("usage: it is only possible to adjoin a zero to a magma",
    " with generators,");
  fi;

  # filters for the elements
  filts := IsMultiplicativeElementWithZero;

  if IsMultiplicativeElementWithOne(Representative(m)) then
    filts := filts and IsMultiplicativeElementWithOne;
  fi;

  if IsAssociativeElement(Representative(m)) then
    filts := filts and IsAssociativeElement;
  fi;

  fam:=NewFamily( "FamilyOfElementOfMagmaWithZeroAdjoined", filts);
  type:=NewType(fam, filts and IsMagmaWithZeroAdjoinedElementRep);

  #the injection
  inj:=function(elt)
    local new;
    new:=Objectify(type, rec(elt:=elt));
    return new;
  end;

  # set the one
  if IsMagmaWithOne(m) then
    SetOne(fam, inj(One(m)));
  fi;

  #filters for the magma with 0 adjoined
  filts:=IsAttributeStoringRep and IsMagmaWithZeroAdjoined;

  if IsSemigroup(m) then
    filts:=filts and IsAssociative;
  fi;

  if IsMagmaWithOne(m) then
    filts:=filts and IsMagmaWithOne;
  fi;

  zero := Objectify(type, rec(elt:=fail));;
  gens:=Concatenation(List(GeneratorsOfMagma(m), inj), [zero]);
  out:=Objectify( NewType( FamilyObj( gens ), filts), rec());

  # store the magma in the family so that it can be recovered from an element
  fam!.MagmaWithZeroAdjoined:=out;

  if IsGroup(m) then
    SetIsZeroGroup(out, true);
  fi;

  SetMultiplicativeZero(out, zero);

  if IsMagmaWithOne(out) then
    SetGeneratorsOfMagmaWithOne(out, gens);
  fi;
  SetGeneratorsOfMagma(out, gens);

  inj:=MappingByFunction(m, out, inj, x-> x!.elt);
  SetUnderlyingInjectionZeroMagma(out, inj);

  return inj;
end);

#

InstallMethod(PrintObj, "for a magma with zero adjoined",
[IsMagmaWithZeroAdjoined and IsMagma and HasGeneratorsOfMagma], 10 ,
function(m)
  Print("<");
  PrintObj(Source(UnderlyingInjectionZeroMagma(m)));
  Print(" with 0 adjoined>");
end);

#

InstallMethod(ViewObj, "for a zero group",
[IsMagmaWithZeroAdjoined and IsMagma and HasGeneratorsOfMagma], 10,
function(m)
  Print("<");
  ViewObj(Source(UnderlyingInjectionZeroMagma(m)));
  Print(" with 0 adjoined>");
end);

#

InstallMethod( Size, "for a magma with a zero adjoined",
[IsMagmaWithZeroAdjoined],
function(m)
  return Size(Source(UnderlyingInjectionZeroMagma(m)))+1;
end);

#

InstallMethod( \*, "for two elements of a magma with zero adjoined",
IsIdenticalObj,
[ IsMagmaWithZeroAdjoinedElementRep, IsMagmaWithZeroAdjoinedElementRep ],
function(x, y)

  if x!.elt=fail then
    return x;
  elif y!.elt=fail then
    return y;
  fi;
  return (x!.elt*y!.elt)^UnderlyingInjectionZeroMagma(
   MagmaWithZeroAdjoined(x));
end );

#

InstallMethod( \=, "for two elements of a magma with zero adjoined",
IsIdenticalObj,
[IsMagmaWithZeroAdjoinedElementRep, IsMagmaWithZeroAdjoinedElementRep ],
function(x, y)
  return x!.elt=y!.elt;
end);

#  ordering of the underlying magma with zero less than everything else

InstallMethod(\<, "for two elements of magmas with zero adjoined",
IsIdenticalObj,
[ IsMagmaWithZeroAdjoinedElementRep, IsMagmaWithZeroAdjoinedElementRep ],
function(x, y)
  local xx, yy;

  xx:=x!.elt; yy:=y!.elt;

  if xx=fail then
    return not yy=fail;
  elif yy=fail then
    return false;
  fi;
  return xx<yy;
end);

#

InstallMethod(PrintObj, "for an element of a magma with zero adjoined",
[IsMagmaWithZeroAdjoinedElementRep],
function(x)
  local m;

  m:=FamilyObj(x)!.MagmaWithZeroAdjoined;
  Print("<");
  if IsGroup(Source(UnderlyingInjectionZeroMagma(m))) then
    Print("group ");
  elif IsMonoid(Source(UnderlyingInjectionZeroMagma(m))) then
    Print("monoid ");
  elif IsSemigroup(Source(UnderlyingInjectionZeroMagma(m))) then
    Print("semigroup ");
  else
    Print("magma ");
  fi;

  Print("with 0 adjoined elt: ");
  if x!.elt=fail then
    Print("0");
  else
    PrintObj(x!.elt);
  fi;
  Print(">");
end);

