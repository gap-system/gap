#############################################################################
##
#W  grplatt.gd                GAP library                   Martin Sch"onert,
#W                                                          J"urgen Mnich,
#AH        How much of the code dates back to Mnich ?
#W                                                          Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains declarations for subgroup latices
##
Revision.grplatt_gd:=
  "@(#)$Id$";

InfoLattice := NewInfoClass("InfoLattice");

IsConjugacyClassSubgroupsRep := NewRepresentation(
  "IsConjugacyClassSubgroupsRep",IsExternalOrbitByStabilizerRep,[]);

ConjugacyClassSubgroups := NewConstructor("ConjugacyClassSubgroups",
                                          [IsGroup,IsGroup]);

ConjugacyClassesSubgroups := NewAttribute("ConjugacyClassesSubgroups",IsGroup);

IsLatticeSubgroupsRep := NewRepresentation("IsLatticeSubgroupsRep",
  IsComponentObjectRep and IsAttributeStoringRep,
  ["group","conjugacyClassesSubgroups"]);

#############################################################################
##
#A  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
Zuppos := NewAttribute("Zuppos",IsGroup);


#############################################################################
##
#A  RepresentativesPerfectSubgroups 
##
RepresentativesPerfectSubgroups :=
  NewAttribute("RepresentativesPerfectSubgroups",IsGroup);

#############################################################################
##
#A  MaximalSubgroupsLattice
##
MaximalSubgroupsLattice :=
  NewAttribute("MaximalSubgroupsLattice",IsLatticeSubgroupsRep);

#############################################################################
##
#A  MinimalSupergroupsLattice
##
MinimalSupergroupsLattice :=
  NewAttribute("MinimalSupergroupsLattice",IsLatticeSubgroupsRep);

#############################################################################
##
#A  TableOfMarks(<G>)
##
TableOfMarks := NewAttribute("TableOfMarks",IsGroup);

#############################################################################
##
#F  CopiedGroup
##
CopiedGroup := NewOperationArgs("CopiedGroup");


#############################################################################
##
#E  grplatt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
