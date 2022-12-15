#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon and Isabel Araújo.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for finitely presented semigroups.
##

#############################################################################
##
#M  ElementOfFpSemigroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpSemigroup,
    "for a family of f.p. semigroup elements, and an assoc. word",
    true,
    [ IsElementOfFpSemigroupFamily, IsAssocWord ],
    0,
    function( fam, elm )
      return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );

#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . for element of f.p. semigroup
##
InstallMethod( UnderlyingElement,
    "for an element of an f.p. semigroup (default repres.)",
    true,
    [ IsElementOfFpSemigroup and IsPackedElementDefaultRep ],
    0,
    obj -> obj![1] );

#############################################################################
##
#M  FpSemigroupOfElementOfFpSemigroup( <elm> )
##
##  returns the fp semigroup to which <elm> belongs to
##
InstallMethod( FpSemigroupOfElementOfFpSemigroup,
    "for an element of an fp semigroup",
    true,
    [IsElementOfFpSemigroup],
    0,
    elm -> CollectionsFamily(FamilyObj(elm))!.wholeSemigroup);

#############################################################################
##
#M  \*( <x1>, <x2> )
##
InstallMethod( \*,
    "for two elements of a f.p. semigroup",
    IsIdenticalObj,
    [ IsElementOfFpSemigroup, IsElementOfFpSemigroup ],
    0,
    function( x1, x2 )
    return ElementOfFpSemigroup(FamilyObj(x1),
                        UnderlyingElement(x1)*UnderlyingElement(x2));
    end );

#############################################################################
##
#M  \<( <x1>, <x2> )
##
##
InstallMethod( \<,
    "for two elements of a f.p. semigroup",
    IsIdenticalObj,
    [ IsElementOfFpSemigroup, IsElementOfFpSemigroup ],
    0,
    function( x1, x2 )
      local S, RWS;

      S := CollectionsFamily(FamilyObj(x1))!.wholeSemigroup;
      RWS := ReducedConfluentRewritingSystem(S);
      return ReducedForm(RWS, UnderlyingElement(x1)) <
          ReducedForm(RWS, UnderlyingElement(x2));

    end );

#############################################################################
##
#M  \=( <x1>, <x2> )
##
##
InstallMethod( \=,
    "for two elements of a f.p. semigroup",
    IsIdenticalObj,
    [ IsElementOfFpSemigroup, IsElementOfFpSemigroup ],
    0,
    function( x1, x2 )
      local S, RWS;

      # This line could be improved - find out how it's done
      # for groups
      S := CollectionsFamily(FamilyObj(x1))!.wholeSemigroup;
      RWS := ReducedConfluentRewritingSystem(S);
      return ReducedForm(RWS, UnderlyingElement(x1)) =
                      ReducedForm(RWS, UnderlyingElement(x2));
    end );

#############################################################################
##
#M  PrintObj( <elm> )
##
InstallMethod( PrintObj, "for an f.p. semigroup element",
    true, [ IsElementOfFpSemigroup], 0,
function( elm )
  PrintObj(elm![1]);
end );

#############################################################################
##
#M  String( <elm> )
##
InstallMethod( String, "for an f.p. semigroup element",
    true, [ IsElementOfFpSemigroup], 0,
function( elm )
  return String(elm![1]);
end );

#############################################################################
##
#M FpGrpMonSmgOfFpGrpMonSmgElement(<elm>)
##
InstallMethod(FpGrpMonSmgOfFpGrpMonSmgElement,
  "for an element of an fp semigroup", true,
  [IsElementOfFpSemigroup], 0,
  x -> CollectionsFamily(FamilyObj(x))!.wholeSemigroup);

#############################################################################
##
#M  FactorFreeSemigroupByRelations(<F>,<rels>) .. Create an FpSemigroup
##
##  Note: If the semigroup has fewer relations than generators,
##  then the semigroup is certainly infinite.
##
InstallGlobalFunction( FactorFreeSemigroupByRelations,
function( F, rels )
  local S, fam, gens, r;

  # Check that the relations are all lists of length 2
  for r in rels do
    if Length(r) <> 2 then
      Error("A relation should be a list of length 2");
    fi;
  od;

  if not (HasIsFreeSemigroup(F) and IsFreeSemigroup(F)) then
    Error("first argument <F> should be a free semigroup");
  fi;

  # Create a new family.
  fam := NewFamily( "FamilyElementsFpSemigroup", IsElementOfFpSemigroup );

  # Create the default type for the elements -
              # putting IsElementOfFpSemigroup ensures that lists of these things
              # have CategoryCollections(IsElementOfFpSemigroup).

  fam!.freeSemigroup := F;
  fam!.relations := Immutable( rels );

  fam!.defaultType := NewType( fam, IsElementOfFpSemigroup
                      and IsPackedElementDefaultRep );

  # Create the semigroup.
  S := Objectify(
      NewType( CollectionsFamily( fam ),
      IsSemigroup and IsFpSemigroup and IsAttributeStoringRep),
      rec() );

  # Mark <S> to be the 'whole semigroup' of its later subsemigroups.
  FamilyObj( S )!.wholeSemigroup := S;

  # Create generators of the semigroup.
  gens:= List( GeneratorsOfSemigroup( F ),
               s -> ElementOfFpSemigroup( fam, s ) );
  SetGeneratorsOfSemigroup( S, gens );

  if Length(gens) > Length(rels) then
    SetIsFinite(S, false);
  fi;

  return S;
end);

#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> )
##
##  for free semigroup and congruence
##
InstallMethod(HomomorphismFactorSemigroup,
    "for a free semigroup and a congruence",
    true,
    [ IsFreeSemigroup, IsSemigroupCongruence ],
    0,
function(s, c)
  local fp;                        # the semigroup under construction

  if not s = Source(c) then
    TryNextMethod();
  fi;
  fp := FactorFreeSemigroupByRelations(s, GeneratingPairsOfMagmaCongruence(c));
  return MagmaHomomorphismByFunctionNC(s, fp,
          x->ElementOfFpSemigroup(ElementsFamily(FamilyObj(fp)),x) );

end);

#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> )
##
##  for fp semigroup and congruence
##
InstallMethod(HomomorphismFactorSemigroup,
    "for an fp semigroup and a congruence",
    true,
    [ IsFpSemigroup, IsSemigroupCongruence ],
    0,
function(s, c)
  local srels,        # the relations of c
        frels,        # srels converted into pairs of words in the free semigroup
        fp;           # the semigroup under construction

  if not s = Source(c) then
    TryNextMethod();
  fi;

  # make the relations, relations of the free semigroup
  srels := GeneratingPairsOfMagmaCongruence(c);
  frels := List(srels, x->[UnderlyingElement(x[1]),UnderlyingElement(x[2])]);

  fp := FactorFreeSemigroupByRelations(FreeSemigroupOfFpSemigroup(s),
          Concatenation(frels, RelationsOfFpSemigroup(s)));
  return MagmaHomomorphismByFunctionNC(s, fp,
          x->ElementOfFpSemigroup(ElementsFamily(FamilyObj(fp)),UnderlyingElement(x)) );
end);

#############################################################################
##
#M  FreeSemigroupOfFpSemigroup( S )
##
##  Underlying free semigroup of an fp semigroup
##
InstallMethod( FreeSemigroupOfFpSemigroup,
    "for a finitely presented semigroup",
    true,
    [ IsSubsemigroupFpSemigroup and IsWholeFamily ], 0,
    T -> ElementsFamily( FamilyObj( T ) )!.freeSemigroup );

#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . .  for a free semigroup
##
InstallMethod( Size,
    "for a free semigroup",
    true,
    [ IsFreeSemigroup ], 0,
    function( G )
    if IsTrivial( G ) then
      return 1;
    else
      return infinity;
    fi;
    end );

#############################################################################
##
#M  FreeGeneratorsOfFpSemigroup( S )
##
##  Generators of the underlying free semigroup
##
InstallMethod( FreeGeneratorsOfFpSemigroup,
    "for a finitely presented semigroup",
    true,
    [ IsSubsemigroupFpSemigroup and IsWholeFamily ], 0,
    T  -> GeneratorsOfSemigroup( FreeSemigroupOfFpSemigroup( T ) ) );

#############################################################################
##
#M  ViewObj( S )
##
##  View a semigroup S
##
InstallMethod( ViewObj,
    "for a free semigroup with generators",
    true,
    [ IsSemigroup and IsFreeSemigroup and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "<free semigroup on the generators ",GeneratorsOfSemigroup(S),">");
    end );

InstallMethod( ViewObj,
    "for a fp semigroup with generators",
    true,
    [  IsSubsemigroupFpSemigroup and IsWholeFamily and IsSemigroup
    and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "<fp semigroup on the generators ",
          FreeGeneratorsOfFpSemigroup(S),">");
    end );

#############################################################################
##
#M  RelationsOfFpSemigroup( F )
##
InstallOtherMethod( RelationsOfFpSemigroup,
    "method for a free semigroup",
    true,
    [ IsFreeSemigroup ], 0,
    F -> [] );

InstallMethod( RelationsOfFpSemigroup,
    "for finitely presented semigroup",
    true,
    [ IsSubsemigroupFpSemigroup and IsWholeFamily ], 0,
    S -> ElementsFamily( FamilyObj( S ) )!.relations );

############################################################################
##
#O  NaturalHomomorphismByGenerators( <f>, <s> )
##
##  returns a mapping from the free semigroup <f> with <n> generators to the
##  semigroup <s> with <n> generators, which maps the ith generator to the
##  ith generator.
##
BindGlobal("FreeSemigroupNatHomByGeneratorsNC",
function(f, s)
 return MagmaHomomorphismByFunctionNC(f, s,
    function(w)
      local
        i,      # loop var
        prodt,  # product in the target semigroup
        gens,   # generators of the target semigroup
        v;      # ext rep as <gen>, <exp> pairs

      if Length(w) = 0 then
        return One(Representative(s));
      fi;

      gens := GeneratorsOfSemigroup(s);
      v := ExtRepOfObj(w);
      prodt := gens[v[1]]^v[2];
      for i in [2 .. Length(v)/2] do
        prodt := prodt*gens[v[2*i-1]]^v[2*i];
      od;
      return prodt;
    end);
end);

InstallMethod( NaturalHomomorphismByGenerators,
    "for a free semigroup and semigroup",
    true,
    [  IsFreeSemigroup, IsSemigroup and HasGeneratorsOfMagma], 0,
function(f, s)

  if Size(GeneratorsOfMagma(f)) <> Size(GeneratorsOfMagma(s)) then
    Error("Semigroups must have the same rank.");
  fi;

  return FreeSemigroupNatHomByGeneratorsNC(f, s);

end);

InstallMethod( NaturalHomomorphismByGenerators,
    "for an fp semigroup and semigroup",
    true,
    [  IsFpSemigroup, IsSemigroup and HasGeneratorsOfSemigroup], 0,
function(f, s)
  local psi; # the homom from the free semi

  if Size(GeneratorsOfSemigroup(f)) <> Size(GeneratorsOfSemigroup(s)) then
    Error("Semigroups must have the same rank.");
  fi;

  psi := FreeSemigroupNatHomByGeneratorsNC(FreeSemigroupOfFpSemigroup(f), s);

  # check that the relations hold
  if Length(Filtered(RelationsOfFpSemigroup(f), x->x[1]^psi <> x[2]^psi))>0 then
    return fail;
  fi;

  # now create the homomorphism from the fp semi
  return MagmaHomomorphismByFunctionNC(f, s, e->UnderlyingElement(e)^psi);
end);
