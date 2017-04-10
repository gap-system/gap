#############################################################################
##
#W  pcgsperm.gd                 GAP library                    Heiko Theißen
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##

#############################################################################
##
#R  IsPcgsPermGroupRep  . . . . . . . . . . . . . . . . .  pcgs of perm group
##
##  This is the representation for a pcgs of a perm group which computes
##  exponents via a stabilizer chain. It may not be set for subsets (tails)
##  as this could lead to wrong exponents.
##  The `RelativeOrders' are a defining attribute of a  perm group pcgs. They
##  cannot be calculated via `PcSeries' and `Size'.
##  Every Pcgs for a permutation group is automatically
##  `IsFiniteOrdersPcgs'.
##
DeclareRepresentation( "IsPcgsPermGroupRep",
    IsPcgsDefaultRep and IsFiniteOrdersPcgs, [ "group", "stabChain" ] );

#############################################################################
##
#R  IsModuloPcgsPermGroupRep  . . . . . .  pcgs of factor group of perm group
##
DeclareRepresentation( "IsModuloPcgsPermGroupRep",
    IsPcgsPermGroupRep,
    [ "group", "stabChain", "series", "denominator" ] );

DeclareGlobalFunction( "AddNormalizingElementPcgs" );
DeclareGlobalFunction( "ExtendSeriesPermGroup" );
DeclareGlobalFunction( "TryPcgsPermGroup" );
DeclareGlobalFunction( "PcgsStabChainSeries" );
DeclareGlobalFunction( "ExponentsOfPcElementPermGroup" );
DeclareGlobalFunction( "PermpcgsPcGroupPcgs" );
DeclareGlobalFunction( "SolvableNormalClosurePermGroup" );
DeclareGlobalFunction( "TailOfPcgsPermGroup" );
DeclareGlobalFunction( "PcgsMemberPcSeriesPermGroup" );

DeclareGlobalFunction( "PermgroupSuggestPcgs" );

#############################################################################
##
#E  pcgsperm.gd
##  
