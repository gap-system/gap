#############################################################################
##
#W  oprtglat.gd                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$ 
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations for orbits on subgroups
##
Revision.oprtglat_gd:=
  "@(#)$Id$";

#############################################################################
##
#O  SubgroupsOrbitsAndNormalizers(G,O,all)   orbits of G on subgroups
##  O is either a list on which G acts or a record containing a component
##  '.list' which is a list of groups. In the latter case, groups are removed
##  from the list as long as they are not needed any longer to save space.
##  if all is true, the full orbits are kept, otherwise only representatives.
##
SubgroupsOrbitsAndNormalizers := NewOperation(
  "SubgroupsOrbitsAndNormalizers",[IsGroup,IsObject,IsBool]);

#############################################################################
##
#O  GroupOnSubgroupsOrbit(G,H) . . . . . . . . . . . . . . orbit of H under G
##
GroupOnSubgroupsOrbit := NewOperationArgs("GroupOnSubgroupsOrbits");

#############################################################################
##
#O  MinimumGroupOnSubgroupsOrbit(G,H [,N_G(H)]) minimum of orbit of H under G
##
MinimumGroupOnSubgroupsOrbit :=
  NewOperationArgs("MinimumGroupOnSubgroupsOrbits");

#############################################################################
##
#E  oprtglat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
