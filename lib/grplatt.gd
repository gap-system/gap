#############################################################################
##
#W  grplatt.gd                GAP library                   Martin Sch"onert,
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

ConjugacyClassSubgroups := NewOperation("ConjugacyClassSubgroups",
                                          [IsGroup,IsGroup]);
#T 1997/01/16 fceller was old 'NewConstructor'


IsLatticeSubgroupsRep := NewRepresentation("IsLatticeSubgroupsRep",
  IsComponentObjectRep and IsAttributeStoringRep,
  ["group","conjugacyClassesSubgroups"]);

#############################################################################
##
#A  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
Zuppos := NewAttribute("Zuppos",IsGroup);
SetZuppos := Setter(Zuppos);
HasZuppos := Tester(Zuppos);

#############################################################################
##
#F  LatticeByCyclicExtension
##
LatticeByCyclicExtension := NewOperationArgs("LatticeByCyclicExtension");

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
#A  NormalSubgroups
##
NormalSubgroups := NewAttribute( "NormalSubgroups", IsGroup );
NormalSubgroupsAbove := NewOperationArgs( "NormalSubgroupsAbove" );

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
