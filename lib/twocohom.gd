#############################################################################
##
#W  twocohom.gd                 GAP library                      Bettina Eick
##
Revision.twocohom_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  CollectedWordSQ( C, u, v ) 
##
CollectedWordSQ := NewOperationArgs( "CollectedWordSQ" );

#############################################################################
##
#F  CollectorSQ( G, M, isSplit )
##
CollectorSQ := NewOperationArgs( "CollectorSQ" );

#############################################################################
##
#F  AddEquationsSQ( eq, t1, t2 )
##
AddEquationSQ := NewOperationArgs( "AddEquationSQ" );

#############################################################################
##
#F  SolutionSQ( C, eq )
##
SolutionSQ := NewOperationArgs( "SolutionSQ" );

#############################################################################
##
#F  TwoCocyclesSQ( C, G, M )
##
TwoCocyclesSQ := NewOperationArgs( "TwoCocyclesSQ" );

#############################################################################
##
#F  TwoCoboundariesSQ( C, G, M )
##
TwoCoboundariesSQ := NewOperationArgs( "TwoCoboundariesSQ" );

#############################################################################
##
#F  TwoCohomologySQ( C, G, M )
##
TwoCohomologySQ := NewOperationArgs( "TwoCohomologySQ" );

#############################################################################
##
#O  TwoCocycles( G, M )
##
TwoCocycles := NewOperation( "TwoCocycles", [ IsPcGroup, IsObject ] );

#############################################################################
##
#O  TwoCoboundaries( G, M )
##
TwoCoboundaries := NewOperation( "TwoCoboundaries", [ IsPcGroup, IsObject ] );

#############################################################################
##
#O  TwoCohomology( G, M )
##
TwoCohomology := NewOperation( "TwoCohomology", [ IsPcGroup, IsObject ] );

