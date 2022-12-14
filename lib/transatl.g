#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains synonym declarations for functions that are spelled
##  differently on different sides of the Atlantic, such as
##  `Stabilizer/Stabiliser' and `Solvable/Soluble'.
##

#############################################################################
##
#F  Transatlantic(name)
##
##  Declare a synonym for the name according as it would be on the other
##  side of the Atlantic Ocean.
BindGlobal("Transatlantic",function(arg)
local fct,attr,name,new,p;
  fct := arg[1];
  if Length(arg) > 1 then
    attr:=arg[2];
  else
    attr:=false;
  fi;
  name:=NameFunction(fct);
  new:=ShallowCopy(name);

  p:=PositionSublist(name,"lizer");
  if p<>fail then
    new:=ShallowCopy(name);
    new[p+2]:='s';
  fi;
  p:=PositionSublist(name,"liser");
  if p<>fail then
    new:=ShallowCopy(name);
    new[p+2]:='z';
  fi;

  p:=PositionSublist(name,"olvable");
  if p<>fail then
    new:=ReplacedString(name,"olvable","oluble");
  fi;
  p:=PositionSublist(name,"oluble");
  if p<>fail then
    new:=ReplacedString(name,"oluble","olvable");
  fi;

  p:=PositionSublist(name,"enter");
  if p<>fail then
    new:=ReplacedString(name,"enter","entre");
  fi;
  p:=PositionSublist(name,"entre");
  if p<>fail then
    new:=ReplacedString(name,"entre","enter");
  fi;

  if attr then
    DeclareSynonymAttr(new,fct);
  else
    DeclareSynonym(new,fct);
  fi;
end);

# the following list is taken from gd files. It is possible that functions
# are defined in .gi files whose names do not get translated.
Transatlantic(ApproximateSuborbitsStabilizerPermGroup);
Transatlantic(Centralizer);
Transatlantic(CentralizerOp);
Transatlantic(CentralizerInParent);
Transatlantic(CentralizerInFiniteDimensionalAlgebra);
Transatlantic(CentralizerInGLnZ);
Transatlantic(CentralizerModulo);
Transatlantic(CentralizerNormalCSPG);
Transatlantic(CentralizerNormalTransCSPG);
Transatlantic(CentralizerSizeLimitConsiderFunction);
Transatlantic(CentralizerTransSymmCSPG);
Transatlantic(CentralizerWreath);
Transatlantic(ClassesSolvableGroup);
Transatlantic(ComplementClassesRepresentativesSolvableNC);
Transatlantic(CONextCentralizer);
Transatlantic(EpimorphismSolvableQuotient);
Transatlantic(ExternalOrbitsStabilizers);
Transatlantic(FullMatrixAlgebraCentralizer);
Transatlantic(GaloisStabilizer);
#Transatlantic(InfoPcNormalizer);
Transatlantic(InsertTrivialStabilizer);
Transatlantic(IsConjugacyClassSubgroupsByStabilizerRep);
Transatlantic(IsExternalOrbitByStabilizerRep);
Transatlantic(IsFixedStabilizer);
Transatlantic(IsLieSolvable);
Transatlantic(IsPSolvable);
Transatlantic(IsSolvableGroup);
Transatlantic(IsSolvableTom);
Transatlantic(LieCentralizer);
Transatlantic(LieCentralizerInParent);
Transatlantic(LieNormalizer);
Transatlantic(LieNormalizerInParent);
Transatlantic(LieSolvableRadical);
Transatlantic(Normalizer);
Transatlantic(NormalizerOp);
Transatlantic(NormalizerInParent);
Transatlantic(NormalizerInGLnZ);
Transatlantic(NormalizerInGLnZBravaisGroup);
Transatlantic(NormalizerStabCSPG);
Transatlantic(NormalizersTom);
Transatlantic(NormalizerTom);
Transatlantic(OrbitStabilizer);
Transatlantic(OrbitStabilizerAlgorithm);
Transatlantic(PartitionStabilizerPermGroup);
Transatlantic(Pcgs_OrbitStabilizer);
Transatlantic(Pcgs_OrbitStabilizer_Blist);
Transatlantic(Pcs_OrbitStabilizer);
Transatlantic(RationalClassesSolvableGroup);
Transatlantic(SolvableNormalClosurePermGroup);
Transatlantic(SolvableQuotient);
Transatlantic(Stabilizer);
Transatlantic(StabilizerFunc);
Transatlantic(StabilizerOfBlockNC);
Transatlantic(StabilizerOfExternalSet);
Transatlantic(StabilizerOp);
Transatlantic(StabilizerPcgs);
Transatlantic(SubgroupsOrbitsAndNormalizers);
Transatlantic(SubgroupsSolvableGroup);
Transatlantic(VerifyStabilizer);



# optional args:
#    list of names to check (default NamesGVars()),
#    list of pairs to substitute
BindGlobal("CheckSynonyms", function(arg)
  local pairs, a, p2, allnames, md, mnd, nid, ok, d, nd, n2, doc, p, n;
  # default pairs to check
  pairs := [ [ "lizer", "liser" ],
             [ "enter", "entre" ],
             [ "Solvable", "Soluble" ],
           ];
  # default names to check
  allnames := NamesGVars();

  # can be overwritten by arguments
  for a in arg do
    if IsList(a) and ForAll(a, IsString) then
      allnames := a;
    fi;
    if IsList(a) and ForAll(a, b-> IsList(b) and ForAll(b, IsString)) then
      pairs := ShallowCopy(a);
    fi;
  od;
  # only consider bound names
  allnames := Set(Filtered(allnames, IsBoundGlobal));
  # add lowercase pairs and interchanged pairs
  for p in pairs do
    p2 := List(p, LowercaseString);
    if not p2 in pairs then
      Add(pairs, p2);
    fi;
  od;
  Append(pairs, List(pairs, p-> [p[2], p[1]]));

  md := [];
  mnd := [];
  nid := [];
  ok := [];
  d := [];
  nd := [];
  for p in pairs do
    Print("Checking pair ", p, "\n");
    for n in allnames do
      n2 := ReplacedString(n, p[1], p[2]);
      if not IsIdenticalObj(n, n2) then
        doc := List([n,n2], IsDocumentedWord);
        if not n2 in allnames then
          if doc = [false, false] then
            Add(mnd, [n,n2]);
          else
            Add(md, [n,n2]);
          fi;
        else
          if not IsIdenticalObj(ValueGlobal(n), ValueGlobal(n2)) then
            Add(nid, [n, n2]);
          else
            if doc = [true, true] then
              AddSet(ok, Set([n,n2]));
            elif doc = [false, false] then
              Add(nd, [n, n2]);
            elif IsSet([n,n2]) then
              Add(d, [n, n2]);
            fi;
          fi;
        fi;
      fi;
    od;
  od;
  if Length(nid) > 0 then
    Print("\nThese should be synonyms but have non-identical values:\n");
    for p in nid do
      Print("  ",p[1]," / ",p[2],"\n");
    od;
  fi;
  if Length(md) > 0 then
    Print("\nDocumented variables with missing synonym:\n");
    for p in md do
      Print("  ",p[1]," / ",p[2],"\n");
    od;
  fi;
  if Length(d) > 0 then
    Print("\nOne of these synonyms is not documented:\n");
    for p in d do
      Print("  ",p[1]," / ",p[2],"\n");
    od;
  fi;
  if Length(nd) > 0 then
    Print("\nSynonyms without documentation:\n");
    for p in nd do
      Print("  ",p[1]," / ",p[2],"\n");
    od;
  fi;
  if Length(mnd) > 0 then
    Print("\nUndocumented variables with missing synonym:\n");
    for p in mnd do
      Print("  ",p[1]," / ",p[2],"\n");
    od;
  fi;
  if Length(ok) > 0 then
    Print("\nOK, synonyms which are both documented:\n");
    for p in ok do
      Print("  ",p[1]," / ",p[2],"\n");
    od;
  fi;
end);


