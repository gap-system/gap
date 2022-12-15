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
##  This file contains the implementation for quotient semigroups.
##

#############################################################################
##
#F  HomomorphismQuotientSemigroup(<cong>)
##
##
InstallGlobalFunction(HomomorphismQuotientSemigroup,
function(cong)
  local S, Qrep, efam, filters, Q, Qgens;

  if not IsSemigroupCongruence(cong) then
    ErrorNoReturn("usage: the argument should be a semigroup congruence,");
  fi;

  S := Source(cong);
  Qrep := EquivalenceClassOfElementNC(cong, Representative(S));
  efam := FamilyObj(Qrep);

  filters := IsSemigroup and IsQuotientSemigroup and IsAttributeStoringRep;

  if IsMonoid(S) then
    filters := filters and IsMagmaWithOne;
  fi;

  if HasIsFinite(S) and IsFinite(S) then
    filters := filters and IsFinite;
  fi;

  Q:=Objectify(NewType( CollectionsFamily( efam ), filters), rec() );

  SetRepresentative(Q, Qrep);
  SetQuotientSemigroupPreimage(Q, S);
  SetQuotientSemigroupCongruence(Q, cong);
  SetQuotientSemigroupHomomorphism(Q, MagmaHomomorphismByFunctionNC(S, Q,
   x->EquivalenceClassOfElementNC(cong,x)));

  efam!.quotient := Q;

  if IsMonoid(Q) and HasOne(S) then
    SetOne(Q, One(S)^QuotientSemigroupHomomorphism(Q));
  fi;

  # Set the semigroup generators of the quotient if possible.
  #
  # It is not sufficient to check HasGeneratorsOfSemigroup
  # by itself, because groups for example only have
  # GeneratorsOfMagmaWithInverses.
  #
  # The code below is safe, because GeneratorsOfSemigroup
  # is synonymous with GeneratorsOfMagma, and there is a
  # method for GeneratorsOfMagma, if we know
  # GeneratorsOfMagmaWithInverses.
  if HasGeneratorsOfMagma(S) or
     HasGeneratorsOfMagmaWithInverses(S) or
     HasGeneratorsOfSemigroup(S) then
      Qgens := List( GeneratorsOfSemigroup(S),
                     s -> s^QuotientSemigroupHomomorphism(Q));
      SetGeneratorsOfSemigroup( Q, Qgens );
  fi;

  return QuotientSemigroupHomomorphism(Q);
end);


#############################################################################
##
#M  HomomorphismFactorSemigroup(<s>, <cong> )
##
##  for a generic semigroup and congruence
##
InstallMethod(HomomorphismFactorSemigroup,
    "for a semigroup and a congruence",
    true,
    [ IsSemigroup, IsSemigroupCongruence ],
    0,
function(s, c)

  if not s = Source(c) then
    TryNextMethod();
  fi;
  return HomomorphismQuotientSemigroup(c);
end);

#############################################################################
##
#M  ViewObj( S )
##
##  View a quotient semigroup S
##
InstallMethod( ViewObj,
    "for a quotient semigroup with generators",
    true,
    [ IsQuotientSemigroup], 0,
    function( S )
    Print( "<quotient of ",QuotientSemigroupPreimage(S)," by ",
           QuotientSemigroupCongruence(S),">");
    end );
