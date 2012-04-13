#############################################################################
##
#W  transatl.g                  GAP library                  Alexander Hulpke
##
##
#Y  Copyright (C) 2005 The GAP Group
##
##  This file contains synonym declarations for function sthat are spelled
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
Transatlantic(ClassPositionsOfSolvableResiduum);
Transatlantic(ComplementClassesRepresentativesSolvableNC);
Transatlantic(ComputedIsPSolvableCharacterTables);
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
Transatlantic(IsPSolvableCharacterTable);
Transatlantic(IsPSolvableCharacterTableOp);
Transatlantic(IsSolvableCharacterTable);
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
Transatlantic(SizesCentralizers);
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
