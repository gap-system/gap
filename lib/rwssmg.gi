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
##  This file contains the declarations for semigroups defined by rws.

############################################################################
##
#F  ReducedConfluentSemigroupRwsNC( <kbrws>)
##
##  if we have a knuth bendix rws that we know is reduced and
##  confluent we can certainly transform it into a reduced
##  confluent rewriting system
##  This performs no checking!!!
##
BindGlobal("ReducedConfluentRwsFromKbrwsNC",
function(kbrws)
  local fam,rws;

  fam := NewFamily("Family of reduced confluent rewriting systems",
          IsReducedConfluentRewritingSystem);
  rws:= Objectify(NewType(fam,IsAttributeStoringRep and
          IsReducedConfluentRewritingSystem), rec());
  SetRules(rws,StructuralCopy(Rules(kbrws)));
  rws!.tzrules:=StructuralCopy(kbrws!.tzrules);
  rws!.tzordering:=StructuralCopy(kbrws!.tzordering);

  SetIsReduced(rws,true);
  SetIsConfluent(rws,true);
  SetFamilyForRewritingSystem(rws, FamilyForRewritingSystem(kbrws));
  SetOrderingOfRewritingSystem(rws,OrderingOfRewritingSystem(kbrws));
  if IsElementOfFpSemigroupFamily(FamilyForRewritingSystem(kbrws)) then
    SetIsBuiltFromSemigroup(rws,true);
  elif IsElementOfFpMonoidFamily(FamilyForRewritingSystem(kbrws)) then
    SetIsBuiltFromMonoid(rws,true);
  fi;

  return rws;

end);

############################################################################
##
#A  ReducedConfluentRewritingSystem( <S>)
##
##  returns a reduced confluent rewriting system of the fp semigroup
##  <S> with respect to the shortlex ordering on words.
##
InstallMethod(ReducedConfluentRewritingSystem,
"for an fp semigroup", true,
[IsFpSemigroup], 0,
function(S)
  local wordord;

  wordord := ShortLexOrdering(ElementsFamily(FamilyObj(
          FreeSemigroupOfFpSemigroup(S))));
  return ReducedConfluentRewritingSystem(S,wordord);
end);

InstallMethod(ReducedConfluentRewritingSystem,
"for an fp monoid", true,
[IsFpMonoid], 0,
function(M)
  local wordord;

  wordord := ShortLexOrdering(ElementsFamily(FamilyObj(
             FreeMonoidOfFpMonoid(M))));
  return ReducedConfluentRewritingSystem(M,wordord);
end);

############################################################################
##
#A  ReducedConfluentRewritingSystem( <S>,<ordering>)
##
##  returns a reduced confluent rewriting system of the fp semigroup/monoid
##  <S> with respect to a supplied reduction order.
##
InstallOtherMethod(ReducedConfluentRewritingSystem,
  "for an fp semigroup and an ordering on the underlying free semigroup", true,
  [IsFpSemigroup, IsOrdering], 0,
function(S,ordering)
  local kbrws,rws;

  if HasReducedConfluentRewritingSystem(S) and
    IsIdenticalObj(ordering,
      OrderingOfRewritingSystem(ReducedConfluentRewritingSystem(S))) then
    return ReducedConfluentRewritingSystem(S);
  fi;

  # we start by building a knuth bendix rws for the semigroup
  kbrws := KnuthBendixRewritingSystem(S,ordering);
  # then we make it confluent (and reduced)
  MakeConfluent(kbrws);

  # we now check whether the attribute is already set
  # (for example, there is an implementation of MakeConfluent that
  # stores it immediately)
  # if the attribute is not set we set it here
  rws := ReducedConfluentRwsFromKbrwsNC(kbrws);
  if not(HasReducedConfluentRewritingSystem(S)) then
    SetReducedConfluentRewritingSystem(S, rws);
  fi;

  return rws;
end);

InstallOtherMethod(ReducedConfluentRewritingSystem,
  "for an fp monoid and an ordering on the underlying free monoid", true,
  [IsFpMonoid, IsOrdering], 0,
function(M,ordering)
  local kbrws, rws;

  if HasReducedConfluentRewritingSystem(M) and
    IsIdenticalObj(ordering,
      OrderingOfRewritingSystem(ReducedConfluentRewritingSystem(M))) then
    return ReducedConfluentRewritingSystem(M);
  fi;

  # we start by building a knuth bendix rws for the monoid
  kbrws := KnuthBendixRewritingSystem(M,ordering);
  # then we make it confluent (and reduced)
  MakeConfluent(kbrws);

  # we now check whether the attribute is already set
  # (for example, there is an implementation of MakeConfluent that
  # stores it immediately)
  # if the attribute is not set we set it here
  rws := ReducedConfluentRwsFromKbrwsNC(kbrws);
  if not(HasReducedConfluentRewritingSystem(M)) then
    SetReducedConfluentRewritingSystem(M, rws);
  fi;

  return rws;
end);

############################################################################
##
#A  ReducedConfluentRewritingSystem( <S>,<lteq>)
##
##  returns a reduced confluent rewriting system of the fp semigroup
##  <S> with respect to a supplied reduction order.
##  lteq(<a>,<b>) returns true iff <a> <= <b> in the order corresponding
##  to lteq.
##
InstallOtherMethod(ReducedConfluentRewritingSystem,
"for an fp semigroup and an order on the underlying free semigroup", true,
[IsFpSemigroup, IsFunction], 0,
function(S,lteq)
  return ReducedConfluentRewritingSystem(S,
                                        OrderingByLessThanOrEqualFunctionNC(ElementsFamily(FamilyObj(
                                        FreeSemigroupOfFpSemigroup(S))),lteq,[IsReductionOrdering]));
end);

#############################################################################
##
#M  IsConfluent(<RWS>)
##
##  checks confluence of a rewriting system built from a monoid
##
InstallMethod(IsConfluent,
"for a monoid or a semigroup rewriting system", true,
[IsRewritingSystem], 0,
function(rws)
    local p,r,i,b,l,u,v,w,rules;

  # this method only works for rws which are built from
  # monoid or semigroups
 # if not (IsBuiltFromMonoid(rws) or IsBuiltFromSemigroup(rws)) then
 #  TryNextMethod();
 #fi;

  rules:=Rules(rws);
  for p in rules do
    for r in rules do

      for i in [1..Length(p[1])] do
        # b is a sufix of p[1]
        b := Subword(p[1],Length(p[1])-i+1,Length(p[1]));

        l := LengthOfLongestCommonPrefixOfTwoAssocWords(b,r[1]);

        # b and r overlap iff |b|=l or |r|=l
        # if |b|=l it means that p[1] and r[1] overlap
        # if |r|=l it means that r[1] is a subword of p[1]
        # if one of these cases occur then confluence might fail

        if Length(b)=l or Length(r[1])=l then

          # let u be the longest common prefix of b and r[1]
          u := Subword(b,1,l);

          # Now, if we have b=ud and r=ue
          # either d or e is empty
          # and if p[1]=ab then to check confluence we have to
          # check the equality of the reduced forms of
          # the words v=ar[2]d and w=p[2]e

          # so in p[1] we substitute the first occurrence of u in b by r[2]
          v := SubstitutedWord(p[1],u,Length(p[1])-i+1,r[2]);
          # and in r[1] we substitute the first occurrence of u by p[2]
          w := SubstitutedWord(r[1],u,1,p[2]);
          # the reduced form of v and w must be equal if the rws is confluent
          if ReducedForm(rws,v)<>ReducedForm(rws,w) then
            return false;
          fi;
        fi;
      od;
    od;
  od;

  # at this stage we know that the rws is confluent
  return true;
end);

############################################################################
##
#A  PrintObj(<rws>)
##
##
InstallMethod(ViewObj, "for a semigroup rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(rws)
  Print("Rewriting System for ");
  Print(SemigroupOfRewritingSystem(rws));
  Print(" with rules \n");
  Print(Rules(rws));
end);

InstallMethod(ViewObj, "for a monoid rewriting system", true,
[IsRewritingSystem and IsBuiltFromMonoid], 0,
function(rws)
  Print("Rewriting System for ");
  Print(MonoidOfRewritingSystem(rws));
  Print(" with rules \n");
  Print(Rules(rws));
end);

#############################################################################
##
#F  ReduceWordUsingRewritingSystem (<RWS>,<w>)
##
##  w is a word of a free monoid or a free semigroup, RWS is a Rewriting System
##  Given a rewriting system and a word in the free structure underlying it,
##  uses the rewriting system to reduce the word and return
##  a 'minimal' one.
##
InstallGlobalFunction(ReduceLetterRepWordsRewSys,REDUCE_LETREP_WORDS_REW_SYS);

InstallGlobalFunction(ReduceWordUsingRewritingSystem,
function(rws,w)
local v;

  #check that rws is Rewriting System
  if not IsRewritingSystem(rws) then
    Error("Can only reduce word given Rewriting System");
  elif not IsAssocWord(w) then
    Error("Can only reduce word from free monoid");
  fi;

  v:=AssocWordByLetterRep(FamilyObj(w),
       ReduceLetterRepWordsRewSys(rws!.tzrules,LetterRepAssocWord(w)));

  return v;
end);

#############################################################################
##
#M  ReducedForm(<RWS>, <e>)
##
InstallMethod(ReducedForm,
"for a semigroup rewriting system and a word on the underlying free semigroup", true,
[IsRewritingSystem and IsBuiltFromSemigroup, IsAssocWord], 0,
function(rws,w)

  if not (w in FreeSemigroupOfRewritingSystem(rws)) then
      Error( Concatenation(
              "Usage: ReducedForm(<rws>, <w>)", "- <w> in FreeSemigroupRewritingSystem(<rws>)") );;
  fi;
  return ReduceWordUsingRewritingSystem(rws,w);
end);

InstallMethod(ReducedForm,
"for a monoid rewriting system and a word on the underlying free monoid",
true,
[IsRewritingSystem and IsBuiltFromMonoid, IsAssocWord], 0,
function(rws,w)

  if not (w in FreeMonoidOfRewritingSystem(rws)) then
      Error( Concatenation( "Usage: ReducedForm(<rws>, <w>)", "- <w> in FreeMonoidOfRewritingSystem(<rws>)") );;
  fi;
  return ReduceWordUsingRewritingSystem(rws,w);
end);

#############################################################################
##
#M  FreeSemigroupOfRewritingSystem(<RWS>)
##
##
InstallMethod(FreeSemigroupOfRewritingSystem,
"for a semigroup rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(rws)
  return FreeSemigroupOfFpSemigroup(
    SemigroupOfRewritingSystem(rws));
end);

#############################################################################
##
#M  FreeMonoidOfRewritingSystem(<RWS>)
##
InstallMethod(FreeMonoidOfRewritingSystem,
"for a monoid rewriting system", true,
[IsRewritingSystem and IsBuiltFromMonoid], 0,
function(rws)
  return FreeMonoidOfFpMonoid(
    MonoidOfRewritingSystem(rws));
end);

#############################################################################
##
#M  GeneratorsOfRws(<RWS>)
##

InstallOtherMethod(GeneratorsOfRws,
"for a monoid rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(rws)
return GeneratorsOfSemigroup(FreeSemigroupOfRewritingSystem(rws));
end);

#############################################################################
##
#M  GeneratorsOfRws(<RWS>)
##

InstallOtherMethod(GeneratorsOfRws,
"for a monoid rewriting system", true,
[IsRewritingSystem and IsBuiltFromMonoid], 0,
function(rws)
return GeneratorsOfMonoid(FreeMonoidOfRewritingSystem(rws));
end);
