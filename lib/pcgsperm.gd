#############################################################################
##
#W  pcgsperm.gd                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.7  1997/01/20 16:19:59  htheisse
#H  added methods for induced and modulo perm pcgs
#H  used them in conjugacy class routines for soluble groups
#H
#H  Revision 4.6  1996/12/19 09:59:13  htheisse
#H  added revision lines
#H
#H  Revision 4.5  1996/12/10 13:39:08  htheisse
#H  changed behaviour of `TryPcgsPermGroup' in case of failure
#H  removed `RightTransversalByPcgs'
#H
#H  Revision 4.4  1996/10/21 10:30:35  htheisse
#H  changed `MembershipTestKnownBase' and added `GroupOfPcgs'
#H
#H  Revision 4.3  1996/10/15 14:43:20  htheisse
#H  added `RightTransversal' by a pcgs; cleaned up `ExtendSeries...'
#H
#H  Revision 4.2  1996/09/26 14:02:57  htheisse
#H  added natural homomorphisms from perm groups onto pc groups
#H
#H  Revision 4.1  1996/09/25 13:45:42  htheisse
#H  adapted pcgs functions for perm groups to Frank's concept of pcgs
#H
##
Revision.pcgsperm_gd :=
    "@(#)$Id$";

#############################################################################
##
#R  IsPcgsPermGroupRep  . . . . . . . . . . . . . . . . .  pcgs of perm group
##
IsPcgsPermGroupRep := NewRepresentation( "IsPcgsPermGroupRep",
    IsPcgsDefaultRep, [ "group", "stabChain" ] );

#############################################################################
##
#R  IsPcgsFactorGroupPermGroupRep . . . . pcgs for factor group of perm group
##
IsPcgsFactorGroupPermGroupRep := NewRepresentation
    ( "IsPcgsFactorGroupPermGroupRep", IsPcgsPermGroupRep,
      [ "group", "stabChain", "denominator", "nrGensSeries" ] );

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
