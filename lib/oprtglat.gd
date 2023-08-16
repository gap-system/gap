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
##  This file contains declarations for orbits on subgroups
##

#############################################################################
##
#O  SubgroupsOrbitsAndNormalizers(G,O,all)   orbits of G on subgroups
##  O is either a list on which G acts or a record containing a component
##  `.list' which is a list of groups. In the latter case, groups are removed
##  from the list as long as they are not needed any longer to save space.
##  if all is true, the full orbits are kept, otherwise only representatives.
##  The input list needs to be free of duplicates (e.g. using Unique),
##  otherwise the result might not be duplicate-free either.
##
DeclareOperation( "SubgroupsOrbitsAndNormalizers",[IsGroup,IsObject,IsBool]);

#############################################################################
##
#O  GroupOnSubgroupsOrbit(G,H) . . . . . . . . . . . . . . orbit of H under G
##
DeclareGlobalFunction("GroupOnSubgroupsOrbit");

#############################################################################
##
#O  MinimumGroupOnSubgroupsOrbit(G,H [,N_G(H)]) minimum of orbit of H under G
##
DeclareGlobalFunction("MinimumGroupOnSubgroupsOrbit");

#############################################################################
##
#O  PermPreConjtestGroups(G,l)
##
##  Utility function: Cluster permgroups according to orbits and cycle
##  structures, possibly conjugating. This is only worth if there are many
##  very similar subgroups and thus not part of the default
##  SubgroupsOrbitsAndNormalizers method.
DeclareGlobalFunction("PermPreConjtestGroups");

DeclareGlobalFunction("ClusterConjugacyPermgroups");
DeclareGlobalFunction("RefineClusterConjugacyPermgroups");
