#############################################################################
##
#W  csetgrp.gd                      GAP library              Alexander Hulpke
##
#H  @(#)$Id:
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of operations for cosets.
##
Revision.csetgrp_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoCoset
##
InfoCoset := NewInfoClass ("InfoCoset");


#############################################################################
##
#A  CanonRepObj(<G>,<U>) . . . . . . . Canonical rerpresentative that is
##  only guaranteed to stay canonical for objects in the same representation
##  This is only to be used in algorithms, but not necessarily an end-user
##  function.
##
CanonRepObj := NewAttribute("CanonRepObj",IsDomain);

#############################################################################
##
#F  AscendingChain(<G>,<U>) . . . . . . .  chain of subgroups G=G_1>...>G_n=U
##
AscendingChain := NewOperationArgs("AscendingChain");

#############################################################################
##
#O  AscendingChainOp(<G>,<U>)  chain of subgroups
##
AscendingChainOp := NewOperation("AscendingChainOp",[IsGroup,IsGroup]);

#############################################################################
##
#A  ComputedAscendingChains     list of already computed ascending chains
##
ComputedAscendingChains := NewAttribute("ComputedAscendingChains",IsGroup,
                                        "mutable");

#############################################################################
##
#O  CanonicalRightCosetElement(U,g)    canonical representative of U*g 
##                                  (Representation dependent!)
##
CanonicalRightCosetElement:=NewOperation("CanonicalRightCosetElement",
  [IsGroup,IsObject]);

#############################################################################
##
#C  IsDoubleCoset
##
IsDoubleCoset := NewCategory("IsDoubleCoset",
    IsDomain and IsExtLSet and IsExtRSet);

#############################################################################
##
#O  DoubleCoset
##
DoubleCoset:=NewConstructor("DoubleCoset",[IsGroup,IsObject,IsGroup]);

#############################################################################
##
#O  DoubleCosets
##
DoubleCosets := NewOperationArgs("DoubleCosets");

#############################################################################
##
#O  DoubleCosetsNC
##
DoubleCosetsNC := NewOperation("DoubleCosetsNC",[IsGroup,IsGroup,IsGroup]);

#############################################################################
##
#A  RepresentativesContainedRightCosets(<D>)
##
RepresentativesContainedRightCosets := NewAttribute(
  "RepresentativesContainedRightCosets", IsDoubleCoset );

#############################################################################
##
#C  IsRightCoset
##
IsRightCoset := NewCategory("IsRightCoset",
    IsDomain and IsExtLSet);

#############################################################################
##
#O  RightCoset
##
RightCoset:=NewConstructor("RightCoset",[IsGroup,IsObject]);

#############################################################################
##
#O  RightCosets
##
RightCosets := NewOperationArgs("RightCosets");

#############################################################################
##
#O  RightCosetsNC
##
RightCosetsNC := NewOperation("RightCosetsNC",[IsGroup,IsGroup]);

#############################################################################
##
#A  RightCosetsDefaultKind
##
RightCosetsDefaultKind := NewAttribute("RightCosetsDefaultKind",IsFamily);

#############################################################################
##
#A  DoubleCosetsDefaultKind
##
DoubleCosetsDefaultKind := NewAttribute("DoubleCosetsDefaultKind",IsFamily);

#############################################################################
##
#F  IntermediateGroup(<G>,<U>)  . . . . . . . . . subgroup of G containing U
##
##  This routine tries to find a subgroup E of G, such that G>E>U. If U is
##  maximal, it returns false. This is done by finding minimal blocks for
##  the operation of G on the Right Cosets of U.
##
IntermediateGroup := NewOperationArgs("IntermediateGroup");

IsCollsElmsColls := function(a,b,c)
  return IsIdentical(a,c) and HasElementsFamily(a) and
    IsIdentical(b,ElementsFamily(a));
end;

#############################################################################
##
#E  csetgrp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
