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
#I  InfoCompPairs
#I  InfoExtReps
##
DeclareInfoClass( "InfoCompPairs" );
DeclareInfoClass( "InfoExtReps");

#############################################################################
##
#F  MappedPcElement( <elm>, <pcgs>, <list> )
##
##  returns the image of <elm> when mapping the pcgs <pcgs> onto <list>
##  homomorphically.
DeclareGlobalFunction("MappedPcElement");

#############################################################################
##
#F  ExtensionSQ( <C>, <G>, <M>, <c> )
##
DeclareGlobalFunction( "ExtensionSQ" );

#############################################################################
##
#F  FpGroupPcGroupSQ( <G> )
##
DeclareGlobalFunction( "FpGroupPcGroupSQ" );

#############################################################################
##
#F  CompatiblePairs( <G>, <M> [,<D>] )
##
##  returns the group of compatible pairs of the group <G> with the 
##  <G>-module <M> as subgroup of the direct product of <Aut(G)> x <Aut(M)>.
##  Here <Aut(M)> is considered as subgroup of a general linear group. The 
##  optional argument <D> should be a subgroup of <Aut(G)> x <Aut(M)>. If it
##  is given, then only the compatible pairs in <D> are computed.
DeclareGlobalFunction( "CompatiblePairs" );

#############################################################################
##
#O  Extension( <G>, <M>, <c> )
#O  ExtensionNC( <G>, <M>, <c> )
##
##  returns the extension of <G> by the <G>-module <M> via the cocycle <c>
##  as pc groups. The `NC' version does not check the resulting group for
##  consistence.
DeclareOperation( "Extension", [ CanEasilyComputePcgs, IsObject, IsVector ] );
DeclareOperation( "ExtensionNC", [ CanEasilyComputePcgs, IsObject, IsVector ] );

#############################################################################
##
#O  Extensions( <G>, <M> )
##
##  returns all extensions of <G> by the <G>-module <M> up to equivalence
##  as pc groups.
DeclareOperation( "Extensions", [ CanEasilyComputePcgs, IsObject ] );

#############################################################################
##
#O  ExtensionRepresentatives( <G>, <M>, <P> )
##
##  returns all extensions of <G> by the <G>-module <M> up to equivalence 
##  under action of <P> where <P> has to be a subgroup of the group of 
##  compatible pairs of <G> with <M>.
DeclareOperation( "ExtensionRepresentatives", 
                    [CanEasilyComputePcgs, IsObject, IsObject] );

#############################################################################
##
#O  SplitExtension( <G>, <M> )
#O  SplitExtension( <G>, <aut>, <N> )
##
##  returns the split extension of <G> by the <G>-module <M>. In the second
##  form it returns the split extension of <G> by the arbitrary finite group
##  <N> where <aut> is a homomorphism of <G> into Aut(<N>).
DeclareOperation( "SplitExtension", [CanEasilyComputePcgs, IsObject] );

#############################################################################
##
#O  TopExtensionsByAutomorphism( <G>, <aut>, <p> )
##
DeclareOperation( "TopExtensionsByAutomorphism",
                               [CanEasilyComputePcgs, IsObject, IsInt] );

#############################################################################
##
#O  CyclicTopExtensions( <G>, <p> )
##
DeclareOperation( "CyclicTopExtensions", 
                       [CanEasilyComputePcgs, IsInt] );

#############################################################################
##
#A SocleComplement(<G>)
##
DeclareAttribute( "SocleComplement", IsGroup );

#############################################################################
##
#A SocleDimensions(<G>)
##
DeclareAttribute( "SocleDimensions", IsGroup );

#############################################################################
##
#A ModuleOfExtension( < G > );
##
DeclareAttribute( "ModuleOfExtension", IsGroup );

