#############################################################################
##
#W  morpheus.gd                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains declarations for Morpheus
##
Revision.morpheus_gd:=
  "@(#)$Id$";

InfoMorph:=NewInfoClass("InfoMorph");

#############################################################################
##
#A  AutomorphismGroup(<obj>)
##
AutomorphismGroup := NewAttribute("AutomorphismGroup",IsDomain);

#############################################################################
##
#A  InnerAutomorphismsAutomorphismGroup(<obj>)
##
InnerAutomorphismsAutomorphismGroup :=
  NewAttribute("InnerAutomorphismsAutomorphismGroup",IsGroup);
SetInnerAutomorphismsAutomorphismGroup :=
  Setter(InnerAutomorphismsAutomorphismGroup);
HasInnerAutomorphismsAutomorphismGroup :=
  Tester(InnerAutomorphismsAutomorphismGroup);

#############################################################################
##
#F  StoreNiceMonomorphismAutomGroup    for small automorphism groups
##
StoreNiceMonomorphismAutomGroup := 
  NewOperationArgs("StoreNiceMonomorphismAutomGroup");

#############################################################################
##
#F  MorFroWords(<gens>) . . . . . . create some pseudo-random words in <gens>
##                                                featuring the MeatAxe's FRO
MorFroWords := NewOperationArgs("MorFroWords");

#############################################################################
##
#F  MorRatClasses(<G>) . . . . . . . . . . . local rationalization of classes
##
MorRatClasses := NewOperationArgs("MorRatClasses");

#############################################################################
##
#F  MorMaxFusClasses(<l>) . .  maximal possible morphism fusion of classlists
##
MorMaxFusClasses := NewOperationArgs("MorMaxFusClasses");

#############################################################################
##
#F  MorClassLoop
##
MorClassLoop := NewOperationArgs("MorClassLoop");

#############################################################################
##
#F  MorFindGeneratingSystem(<G>,<cl>) . .  find generating system with an few 
##                      as possible generators from the first classes in <cl>
##
MorFindGeneratingSystem := NewOperationArgs("MorFindGeneratingSystem");

#############################################################################
##
#F  Morphium
##
Morphium := NewOperationArgs("Morphium");

#############################################################################
##
#F  AutomorphismGroupAbelianGroup
##
AutomorphismGroupAbelianGroup :=
  NewOperationArgs("AutomorphismGroupAbelianGroup");

#############################################################################
##
#F  IsomorphismAbelianGroups
##
IsomorphismAbelianGroups := NewOperationArgs("IsomorphismAbelianGroups");

#############################################################################
##
#F  IsomorphismGroups
##
IsomorphismGroups := NewOperationArgs("IsomorphismGroups");

#############################################################################
##
#F  GQuotients
##
GQuotients := NewOperation("GQuotients",[IsGroup,IsGroup]);

#############################################################################
##
#E  morpheus.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
