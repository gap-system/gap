#############################################################################
##
#W  randiso.gd                GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.randiso_gd :=
    "@(#)$Id$";

DeclareInfoClass( "InfoRandIso" );
DeclareAttribute( "OmegaAndLowerPCentralSeries", IsGroup );

#############################################################################
##
#F CodePcgs( <pcgs> )
##
##  returns the code corresponding to <pcgs>.
DeclareGlobalFunction( "CodePcgs" );

#############################################################################
##
#F CodePcGroup( <G> )
##
##  returns the code for a pcgs of <G>.
DeclareGlobalFunction( "CodePcGroup" );

#############################################################################
##
#F PcGroupCode( <code>, <size> )
##
## returns a pc group of size <size> corresponding to <code>.
DeclareGlobalFunction( "PcGroupCode" );

#############################################################################
##
#F PcGroupCodeRec( <rec> )
##
## Here <rec> needs to have entries .code and .order. Then PcGroupCode 
## returns a pc group of size .order corresponding to .code.
DeclareGlobalFunction( "PcGroupCodeRec" );


#############################################################################
##
#F RandomSpecialPcgsCoded( <G> )
##
## returns a code for a random special pcgs of <G>.
DeclareGlobalFunction( "RandomSpecialPcgsCoded" );

#############################################################################
##
#F RandomIsomorphismTest( <list>, <n> )
##
## Here <list> must be a list of pc groups and <n> a non-negative integer.
## Returns a sublist of <list> where isomorphic copies detected by the 
## probabilistic test have been removed.
DeclareGlobalFunction( "RandomIsomorphismTest" );

#############################################################################
##
#F ReducedByIsomorphism( <list>, <n> )
##
## returns a list of disjoint sublist of <list> such that no two isomorphic
## groups can be in the same sublist.
DeclareGlobalFunction( "ReducedByIsomorphisms" );


