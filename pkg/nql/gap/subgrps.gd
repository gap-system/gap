############################################################################
##
#W  subgrps.gd			The NQL-package			René Hartung
##
#H   @(#)$Id: subgrps.gd,v 1.1 2010/03/17 13:03:40 gap Exp $
##
Revision.("nql/gap/subgrps_gd"):= 
  "@(#)$Id: subgrps.gd,v 1.1 2010/03/17 13:03:40 gap Exp $";

############################################################################
##
#O TraceCosetTableLpGroup
##
DeclareOperation( "TraceCosetTableLpGroup", [ IsList, IsObject, IsPosInt ] );

DeclareOperation( "SubgroupLpGroupByCosetTable", [ IsObject, IsList ] );

DeclareOperation( "IsCosetTableLpGroup", [ IsSubgroupLpGroup, IsList ] );

DeclareGlobalFunction( "NQL_EnforceCoincidences" );

DeclareOperation( "LowIndexSubgroupsLpGroupByFpGroup", [ IsLpGroup, IsPosInt, IsPosInt ] );
DeclareOperation( "LowIndexSubgroupsLpGroupIterator", [ IsLpGroup, IsPosInt, IsPosInt ] );

DeclareOperation( "NilpotentQuotientIterator", [ IsLpGroup ] );

DeclareOperation( "NqEpimorphismNilpotentQuotientIterator", [ IsLpGroup ] );

DeclareOperation( "LowerCentralSeriesIterator", [ IsLpGroup ] );
