#############################################################################
##
#W  grppcext.gd                 GAP library                      Bettina Eick
##
Revision.grppcext_gd :=
    "@(#)$Id:";

#############################################################################
##
#F  ExtensionSQ( C, G, M, c )
##
ExtensionSQ := NewOperationArgs( "ExtensionSQ" );

#############################################################################
##
#F  CompatiblePairs( G, M, [P] )
##
CompatiblePairs := NewOperationArgs( "CompatiblePairs" );

#############################################################################
##
#F  FindConjugatingElement( G, inn )
##
FindConjugatingElement := NewOperationArgs( "FindConjugatingElement" );

#############################################################################
##
#O  Extension( G, M, c )
##
Extension := NewOperation( "Extension", [ IsPcGroup, IsObject, IsVector ] );

#############################################################################
##
#O  Extensions( G, M )
##
Extensions := NewOperation( "Extensions", [ IsPcGroup, IsObject ] );

#############################################################################
##
#O  ExtensionRepresentatives( G, M, P )
##
ExtensionRepresentatives 
  := NewOperation( "ExtensionRepresentatives", 
                    [IsPcGroup, IsObject, IsObject] );

#############################################################################
##
#O  SplitExtension( G, M )
#O  SplitExtension( G, aut, N )
##
SplitExtension := NewOperation( "SplitExtension", 
                                    [IsPcGroup, IsObject] );

#############################################################################
##
#O  TopExtensionsByAutomorphism( G, aut, p )
##
TopExtensionsByAutomorphism := NewOperation( "TopExtensionsByAutomorphism",
                               [IsPcGroup, IsObject, IsInt] );

#############################################################################
##
#O  CyclicTopExtensions( G, p )
##
CyclicTopExtensions := NewOperation( "CyclicTopExtensions", 
                       [IsPcGroup, IsInt] );
