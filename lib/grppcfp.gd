#############################################################################
##
#W  grppcfp.gd                  GAP library                      Bettina Eick
##
Revision.grppcfp_gd :=
    "@(#)$Id$"; 

#############################################################################
##
#F  PcGroupFpGroup( F )
##  should this become a method?
##
PcGroupFpGroup := NewOperationArgs( "PcGroupFpGroup" );

#############################################################################
##
#F  SmithNormalFormSQ( mat ) 
##
SmithNormalFormSQ := NewOperationArgs( "SmithNormalFormSQ" );

#############################################################################
##
#F  InitEpimorphismSQ( F )
##
InitEpimorphismSQ := NewOperationArgs( "InitEpimorphismSQ" );

#############################################################################
##
#F  LiftEpimorphismSQ( epi, M, c )
##
LiftEpimorphismSQ := NewOperationArgs( "LiftEpimorphismSQ" );

#############################################################################
##
#F  BlowUpCocycleSQ( v, K, F )
##
BlowUpCocycleSQ := NewOperationArgs( "BlowUpCocycleSQ" );

#############################################################################
##
#F  TryModuleSQ( epi, M )
##
TryModuleSQ := NewOperationArgs( "TryModuleSQ" );

#############################################################################
##
#F  TryLayerSQ( epi, layer )
##
TryLayerSQ := NewOperationArgs( "TryLayerSQ" );

#############################################################################
##
#F  SQ( <F>, <...> ) / SolvableQuotient( <F>, <...> )
##  should this become a method?
##
SolvableQuotient := NewOperationArgs( "SolvableQuotient" );
SQ := NewOperationArgs( "SQ" );
