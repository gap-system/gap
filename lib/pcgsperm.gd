#############################################################################
##
#W  pcgsperm.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.pcgsperm_gd :=
    "@(#)$Id$";

#############################################################################
##
#R  IsPcgsPermGroupRep  . . . . . . . . . . . . . . . . .  pcgs of perm group
##
##  The `RelativeOrders' are a defining attribute of a  perm group pcgs. They
##  cannot be calculcated via `PcSeries' and `Size'.
##
DeclareRepresentation( "IsPcgsPermGroupRep",
    IsPcgsDefaultRep, [ "group", "stabChain" ] );

#############################################################################
##
#R  IsModuloPcgsPermGroupRep  . . . . . .  pcgs of factor group of perm group
##
DeclareRepresentation( "IsModuloPcgsPermGroupRep",
    IsPcgsPermGroupRep,
    [ "group", "stabChain", "series", "denominator" ] );

DeclareGlobalFunction( "WordVector" );
DeclareGlobalFunction( "WordNumber" );
DeclareGlobalFunction( "AddNormalizingElementPcgs" );
DeclareGlobalFunction( "ExtendSeriesPermGroup" );
DeclareGlobalFunction( "TryPcgsPermGroup" );
DeclareGlobalFunction( "PcgsStabChainSeries" );
DeclareGlobalFunction( "ExponentsOfPcElementPermGroup" );
DeclareGlobalFunction( "PcGroupPcgs" );
DeclareGlobalFunction( "SolvableNormalClosurePermGroup" );
DeclareGlobalFunction( "TailOfPcgsPermGroup" );
DeclareGlobalFunction( "PcgsMemberPcSeriesPermGroup" );

#############################################################################
##
#E  pcgsperm.gd
##  
