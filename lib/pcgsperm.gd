#############################################################################
##
#W  pcgsperm.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
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
IsPcgsPermGroupRep := NewRepresentation( "IsPcgsPermGroupRep",
    IsPcgsDefaultRep, [ "group", "stabChain", "series" ] );

#############################################################################
##
#R  IsModuloPcgsPermGroupRep  . . . . . .  pcgs of factor group of perm group
##
IsModuloPcgsPermGroupRep := NewRepresentation( "IsModuloPcgsPermGroupRep",
    IsPcgsPermGroupRep,
    [ "group", "stabChain", "series", "denominator" ] );

WordVector := NewOperationArgs( "WordVector" );
WordNumber := NewOperationArgs( "WordNumber" );
EconomicCopy := NewOperationArgs( "EconomicCopy" );
AddNormalizingElementPcgs := NewOperationArgs( "AddNormalizingElementPcgs" );
ExtendSeriesPermGroup := NewOperationArgs( "ExtendSeriesPermGroup" );
TryPcgsPermGroup := NewOperationArgs( "TryPcgsPermGroup" );
PcgsStabChainSeries := NewOperationArgs( "PcgsStabChainSeries" );
ExponentsOfPcElementPermGroup := NewOperationArgs( "ExponentsOfPcElementPermGroup" );
PcGroupPcgs := NewOperationArgs( "PcGroupPcgs" );
SolvableNormalClosurePermGroup := NewOperationArgs( "SolvableNormalClosurePermGroup" );
TailOfPcgsPermGroup := NewOperationArgs( "TailOfPcgsPermGroup" );
PcgsMemberPcSeriesPermGroup := NewOperationArgs( "PcgsMemberPcSeriesPermGroup" );

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
