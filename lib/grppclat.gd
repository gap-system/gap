#############################################################################
##
#W  grppclat.gd                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997  
##
##  This  file contains declarations for the subgroup lattice functions for
##  pc groups.
##
Revision.grppclat_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  Information function
##
InfoPcSubgroup := NewInfoClass("InfoPcSubgroup");

#############################################################################
##
#O  InvariantElementaryAbelianSeries( <G>, <morph>, [ <N> ] )
##           find <morph> invariant EAS of G (through N)
##
InvariantElementaryAbelianSeries := NewOperationArgs(
  "InvariantElementaryAbelianSeries");

#############################################################################
##
#O  InducedAutomorphism(<epi>,<aut>)
##
InducedAutomorphism := NewOperationArgs("InducedAutomorphism");

#############################################################################
##
#F  InvariantSubgroupsElementaryAbelianGroup(<G>,<homs>[,<dims])  submodules
#F    find all subgroups of el. ab. <G>, which are invariant under all <homs>
#F    which have dimension in dims
##
InvariantSubgroupsElementaryAbelianGroup := NewOperationArgs(
    "InvariantSubgroupsElementaryAbelianGroup");

#############################################################################
##
#F  InvariantSubgroupsPcGroup(<G>[,<opt>]) . classreps of subgrps of <G>,
##   				             <homs>-inv. with options.
##    Options are:  
##                  actions:  list of automorphisms: search for invariants
##                  normal:   just search for normal subgroups
##                  consider: function(A,N,B,M) indicator function, whether 
##			      complements of this type would be needed
##
InvariantSubgroupsPcGroup := NewOperationArgs("InvariantSubgroupsPcGroup");

#############################################################################
##
#F  SizeConsiderFunction(<size>)  returns auxiliary function for
##  'InvariantSubgroupsPcGroup' that allows to discard all subgroups whose
##  size is not divisible by <size>
##
SizeConsiderFunction := NewOperationArgs("SizeConsiderFunction");

#############################################################################
##
#F  ExactSizeConsiderFunction(<size>)  returns auxiliary function for
##  'InvariantSubgroupsPcGroup' that allows to discard all subgroups whose
##  size is not <size>
##
ExactSizeConsiderFunction := NewOperationArgs("ExactSizeConsiderFunction");

#############################################################################
##
#E  grppclat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
