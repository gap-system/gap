#############################################################################
##
#W  grppcext.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grppcext_gd :=
    "@(#)$Id$";

#############################################################################
##
#I  Infos
##
DeclareInfoClass( "InfoCompPairs" );
DeclareInfoClass( "InfoExtReps");
DeclareInfoClass( "InfoFrattExt" );

#############################################################################
##
#F  ExtensionSQ( C, G, M, c )
##
DeclareGlobalFunction( "ExtensionSQ" );

#############################################################################
##
#F  FpGroupPcGroupSQ( G )
##
DeclareGlobalFunction( "FpGroupPcGroupSQ" );

#############################################################################
##
#F  CompatiblePairs( G, M, [P] )
##
DeclareGlobalFunction( "CompatiblePairs" );

#############################################################################
##
#F  FindConjugatingElement( G, inn )
##
#T DeclareGlobalFunction( "FindConjugatingElement" );
#T up to now no function is installed

#############################################################################
##
#O  Extension( G, M, c )
##
DeclareOperation( "Extension", [ CanEasilyComputePcgs, IsObject, IsVector ] );

#############################################################################
##
#O  Extensions( G, M )
##
DeclareOperation( "Extensions", [ CanEasilyComputePcgs, IsObject ] );

#############################################################################
##
#O  ExtensionRepresentatives( G, M, P )
##
DeclareOperation( "ExtensionRepresentatives", 
                    [CanEasilyComputePcgs, IsObject, IsObject] );

#############################################################################
##
#O  SplitExtension( G, M )
#O  SplitExtension( G, aut, N )
##
DeclareOperation( "SplitExtension", [CanEasilyComputePcgs, IsObject] );

#############################################################################
##
#O  TopExtensionsByAutomorphism( G, aut, p )
##
DeclareOperation( "TopExtensionsByAutomorphism",
                               [CanEasilyComputePcgs, IsObject, IsInt] );

#############################################################################
##
#O  CyclicTopExtensions( G, p )
##
DeclareOperation( "CyclicTopExtensions", 
                       [CanEasilyComputePcgs, IsInt] );

#############################################################################
##
#A SocleComplement
##
DeclareAttribute( "SocleComplement", IsGroup );

#############################################################################
##
#A SocleDimensions
##
DeclareAttribute( "SocleDimensions", IsGroup );

