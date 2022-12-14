#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Isabel Araújo.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
##  1. methods for elements of fp monoids
##

#############################################################################
##
#M  ElementOfFpMonoid( <fam>, <elm> )
##
InstallMethod( ElementOfFpMonoid,
        "for a family of f.p. monoid elements, and an assoc. word",
        true,
        [ IsElementOfFpMonoidFamily, IsAssocWordWithOne ],
        0,
        function( fam, elm )
                return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
        end );

#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . for element of fp monoid
##
InstallMethod( UnderlyingElement,
        "for an element of an fp monoid (default repres.)",
        true,
        [ IsElementOfFpMonoid and IsPackedElementDefaultRep ],
        0,
        obj -> obj![1] );

#############################################################################
##
#M  \*( <x1>, <x2> )
##
InstallMethod( \*,
        "for two elements of a fp monoid",
        IsIdenticalObj,
        [ IsElementOfFpMonoid, IsElementOfFpMonoid],
        0,
        function( x1, x2 )
                return ElementOfFpMonoid(FamilyObj(x1),
                                                UnderlyingElement(x1)*UnderlyingElement(x2));
        end );

#############################################################################
##
#M  \<( <x1>, <x2> )
##
## This method now uses the rws for monoids (30/01/2002)
##
InstallMethod( \<,
    "for two elements of a f.p. monoid",
    IsIdenticalObj,
    [ IsElementOfFpMonoid, IsElementOfFpMonoid],
    0,
    function( x1, x2 )
      local s,rws ;

      s := CollectionsFamily(FamilyObj(x1))!.wholeMonoid;
      rws := ReducedConfluentRewritingSystem(s);
      return ReducedForm(rws, UnderlyingElement(x1)) <
          ReducedForm(rws, UnderlyingElement(x2));

    end );

#############################################################################
##
#M  \=( <x1>, <x2> )
##
InstallMethod( \=,
    "for two elements of a f.p. monoid",
    IsIdenticalObj,
    [ IsElementOfFpMonoid, IsElementOfFpMonoid],
    0,
    function( x1, x2 )
                        local m,rws;

                        m := CollectionsFamily(FamilyObj(x1))!.wholeMonoid;
      rws:= ReducedConfluentRewritingSystem(m);

      return ReducedForm(rws, UnderlyingElement(x1)) =
          ReducedForm(rws, UnderlyingElement(x2));

    end );

#############################################################################
##
#M  One( <fam> )  . . . . . . . . . . . . . for family of fp monoid elements
##
InstallOtherMethod( One,
    "for a family of fp monoid elements",
    true,
    [ IsElementOfFpMonoidFamily ],
    0,
    fam -> ElementOfFpMonoid( fam, One( fam!.freeMonoid) ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for element of fp monoid
##
InstallMethod( One, "for an fp monoid element", true, [ IsElementOfFpMonoid ],
    0, obj -> One( FamilyObj( obj ) ) );

# a^0 calls OneOp, so we have to catch this as well.
InstallMethod( OneOp, "for an fp monoid element", true, [ IsElementOfFpMonoid ],
    0, obj -> One( FamilyObj( obj ) ) );

#############################################################################
##
#M  PrintObj( <elm> )
##
InstallMethod( PrintObj, "for an fp monoid element",
  true, [ IsElementOfFpMonoid], 0,
function( elm )
  PrintObj(elm![1]);
end );

#############################################################################
##
#M  String( <elm> )
##
InstallMethod( String, "for an fp monoid element",
  true, [ IsElementOfFpMonoid], 0,
function( elm )
  return String(elm![1]);
end );

#############################################################################
##
#M  FpMonoidOfElementOfFpMonoid( <elm> )
##
InstallMethod( FpMonoidOfElementOfFpMonoid,
        "for an fp monoid element", true,
        [IsElementOfFpMonoid], 0,
        elm -> CollectionsFamily(FamilyObj(elm))!.wholeMonoid);

#############################################################################
##
#M  FpGrpMonSmgOfFpGrpMonSmgElement( <elm> )
##
##      for an fp monoid element <elm> returns the fp monoid to which
##      <elm> belongs to
##
InstallMethod(FpGrpMonSmgOfFpGrpMonSmgElement,
  "for an element of an fp monoid", true,
  [IsElementOfFpMonoid], 0,
  x -> CollectionsFamily(FamilyObj(x))!.wholeMonoid);


#############################################################################
##
##  2. methods for fp monoids
##

#############################################################################
##
#M  FactorFreeMonoidByRelations(<F>,<rels>) .. Create an FpMonoid
##
##  Note: If the monoid has fewer relations than generators,
##  then the monoid is certainly infinite.
##
InstallGlobalFunction(FactorFreeMonoidByRelations,
function( F, rels )
    local s, fam, gens, r;

    # Check that the relations are all lists of length 2
    for r in rels do
      if Length(r) <> 2 then
        Error("A relation should be a list of length 2");
      fi;
    od;

    if not (HasIsFreeMonoid(F) and IsFreeMonoid(F)) then
      Error("first argument <F> should be a free monoid");
    fi;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpMonoid", IsElementOfFpMonoid);

    # Create the default type for the elements -
    # putting IsElementOfFpMonoid ensures that lists of these things
    # have CategoryCollections(IsElementOfFpMonoid).

    fam!.freeMonoid:= F;
    fam!.relations := Immutable( rels );

    fam!.defaultType := NewType( fam, IsElementOfFpMonoid
      and IsPackedElementDefaultRep );

    # Create the monoid
    s := Objectify(
        NewType( CollectionsFamily( fam ),
        IsMonoid and IsFpMonoid and IsAttributeStoringRep),
        rec() );

    # Mark <s> to be the 'whole monoid' of its later submonoids.
    FamilyObj( s )!.wholeMonoid:= s;
    SetOne(s,ElementOfFpMonoid(fam,One(F)));
    # Create generators of the monoid.
    gens:= List( GeneratorsOfMonoid( F ),
      s -> ElementOfFpMonoid( fam, s ) );
    SetGeneratorsOfMonoid( s, gens );

    if Length(gens) > Length(rels) then
      SetIsFinite(s, false);
    fi;

    return s;
end);

#############################################################################
##
#M  ViewObj( S )
##
##  View an fp  monoid S
##
InstallMethod( ViewObj,
    "for a fp monoid with generators",
    true,
    [  IsSubmonoidFpMonoid and IsWholeFamily and IsMonoid
    and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "<fp monoid on the generators ",
          FreeGeneratorsOfFpMonoid(S),">");
    end );

#############################################################################
##
#M  FreeGeneratorsOfFpMonoid( S )
##
##  Generators of the underlying free monoid
##
InstallMethod( FreeGeneratorsOfFpMonoid,
    "for a finitely presented monoid",
    true,
    [ IsSubmonoidFpMonoid and IsWholeFamily ], 0,
    T  -> GeneratorsOfMonoid( FreeMonoidOfFpMonoid( T ) ) );

#############################################################################
##
#M  FreeMonoidOfFpMonoid( S )
##
##  Underlying free monoid of an fpmonoid
##
InstallMethod( FreeMonoidOfFpMonoid,
    "for a finitely presented monoid",
    true,
    [ IsSubmonoidFpMonoid and IsWholeFamily ], 0,
    T -> ElementsFamily( FamilyObj( T ) )!.freeMonoid);

#############################################################################
##
#M  RelationsOfFpMonoid( F )
##
InstallOtherMethod( RelationsOfFpMonoid,    "method for a free monoid",
    true,
    [ IsFreeMonoid], 0,
    F -> [] );

InstallMethod( RelationsOfFpMonoid,
    "for finitely presented monoid",
    true,
    [ IsSubmonoidFpMonoid and IsWholeFamily ], 0,
    S -> ElementsFamily( FamilyObj( S ) )!.relations );

#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> )
##
##  for a free monoid and congruence
##
InstallOtherMethod(HomomorphismFactorSemigroup,
    "for a free monoid and a congruence",
    true,
    [ IsFreeMonoid, IsMagmaCongruence ],
    0,
function(s, c)
  local
    fp;     # the monoid under construction

  if not s = Source(c) then
    TryNextMethod();
  fi;
  fp := FactorFreeMonoidByRelations(s, GeneratingPairsOfMagmaCongruence(c));
  return MagmaHomomorphismByFunctionNC(s, fp,
    x->ElementOfFpMonoid(ElementsFamily(FamilyObj(fp)),x) );
end);

#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> )
##
##  for fp monoid and congruence
##
InstallMethod(HomomorphismFactorSemigroup,
    "for an fp monoid and a congruence",
    true,
    [ IsFpMonoid, IsSemigroupCongruence ],
    0,
function(s, c)
  local
    srels,  # the relations of c
    frels,  # srels converted into pairs of words in the free monoid
    fp;     # the monoid under construction

  if not s = Source(c) then
    TryNextMethod();
  fi;

  # make the relations, relations of the free monoid
  srels := GeneratingPairsOfMagmaCongruence(c);
  frels := List(srels, x->[UnderlyingElement(x[1]),UnderlyingElement(x[2])]);

  fp := FactorFreeMonoidByRelations(FreeMonoidOfFpMonoid(s),
    Concatenation(frels, RelationsOfFpMonoid(s)));
  return MagmaHomomorphismByFunctionNC(s, fp,
    x->ElementOfFpMonoid(ElementsFamily(FamilyObj(fp)),UnderlyingElement(x)) );

end);

#############################################################################
##
#M  NaturalHomomorphismByGenerators( S )
##
BindGlobal("FreeMonoidNatHomByGeneratorsNC",
function(f, s)
 return MagmaHomomorphismByFunctionNC(f, s,
    function(w)
      local
        i,      # loop var
        prodt,  # product in the target monoid
        gens,   # generators of the target monoid
        v;      # ext rep as <gen>, <exp> pairs

      if Length(w) = 0 then
        return One(Representative(s));
      fi;

      gens := GeneratorsOfMonoid(s);
      v := ExtRepOfObj(w);
      prodt := gens[v[1]]^v[2];
      for i in [2 .. Length(v)/2] do
        prodt := prodt*gens[v[2*i-1]]^v[2*i];
      od;
      return prodt;

    end);
end);

InstallMethod( NaturalHomomorphismByGenerators,
    "for a free monoid and monoid",
    true,
    [  IsFreeMonoid, IsMonoid and HasGeneratorsOfMagmaWithOne], 0,
function(f, s)

  if Size(GeneratorsOfMagmaWithOne(f)) <> Size(GeneratorsOfMagmaWithOne(s)) then
    Error("Monoid must have the same rank.");
  fi;

  return FreeMonoidNatHomByGeneratorsNC(f, s);

end);


InstallMethod( NaturalHomomorphismByGenerators,
    "for an fp monoid and monoid",
    true,
    [  IsFpMonoid, IsMonoid and HasGeneratorsOfMonoid], 0,
function(f, s)
  local
      psi; # the homom from the free monoid

  if Size(GeneratorsOfMonoid(f)) <> Size(GeneratorsOfMonoid(s)) then
    Error("Monoids must have the same rank.");
  fi;

  psi := FreeMonoidNatHomByGeneratorsNC(FreeMonoidOfFpMonoid(f), s);

  # check that the relations hold
  if Length(
      Filtered(RelationsOfFpMonoid(f), x->x[1]^psi <> x[2]^psi))>0 then
    return fail;
  fi;

  # now create the homomorphism from the fp mon
  return MagmaHomomorphismByFunctionNC(f, s, e->UnderlyingElement(e)^psi);
end);

InstallMethod(IsomorphismFpSemigroup, "for an fp monoid", [IsFpMonoid],
function(M)
  local FMtoFS, FStoFM, FM, FS, id, rels, next, S, map, inv, x, rel;

  # Convert a word in the free monoid into a word in the free semigroup
  FMtoFS := function(id, w)
    local wlist, i;

    wlist := ExtRepOfObj(w);

    if Length(wlist) = 0 then # it is the identity
      return id;
    fi;

    # have to increment the generators by one to shift past the identity
    # generator
    wlist := ShallowCopy(wlist);
    for i in [1 .. 1 / 2 * (Length(wlist))] do
      wlist[2 * i - 1] := wlist[2 * i - 1] + 1;
    od;

    return ObjByExtRep(FamilyObj(id), wlist);
  end;

  # Convert a word in the free semigroup into a word in the free monoid.
  FStoFM := function(id, w)
    local wlist, i;

    wlist := ExtRepOfObj(w);

    if Length(wlist) = 0 or (wlist = [1, 1]) then # it is the identity
      return id;
    fi;

    # have to decrease each entry by one because of the identity generator
    wlist := ShallowCopy(wlist);
    for i in [1 .. 1 / 2 * (Length(wlist))] do
      wlist[2 * i - 1] := wlist[2 * i - 1] - 1;
    od;
    return ObjByExtRep(FamilyObj(id), wlist);
  end;

  FM := FreeMonoidOfFpMonoid(M);
  FS := FreeSemigroup(List(GeneratorsOfSemigroup(FM), String));

  id := FS.(Position(GeneratorsOfSemigroup(FM), One(FM)));

  # Add the relations that make id an identity
  rels := [[id * id, id]];
  for x in GeneratorsOfSemigroup(FS) do
    if x <> id then
      Add(rels, [id * x, x]);
      Add(rels, [x * id, x]);
    fi;
  od;

  # Rewrite the fp monoid relations as relations over FS
  for rel in RelationsOfFpMonoid(M) do
    next := [FMtoFS(id, rel[1]), FMtoFS(id, rel[2])];
    Add(rels, next);
  od;

  # finally create the fp semigroup
  S := FS / rels;

  map := x -> ElementOfFpSemigroup(FamilyObj(S.1),
                                   FMtoFS(id, UnderlyingElement(x)));

  inv := x -> Image(NaturalHomomorphismByGenerators(FM, M),
                    FStoFM(One(FM), UnderlyingElement(x)));

 return MagmaIsomorphismByFunctionsNC(M, S, map, inv);
end);
