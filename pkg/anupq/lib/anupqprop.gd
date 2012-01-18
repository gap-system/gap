#############################################################################
####
##
#W  anupqprop.gd               ANUPQ package                    Werner Nickel
##
##
##  Declares properties and attributes needed for ANUPQ.
##    
#H  @(#)$Id: anupqprop.gd,v 1.2 2011/11/29 20:00:13 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

#############################################################################
##
#F  SET_PQ_PROPS_AND_ATTRS( <G>, <func> )
##
DeclareGlobalFunction( "SET_PQ_PROPS_AND_ATTRS" );

#############################################################################
##
#D  Declare properties and  attributes
##    
DeclareProperty( "IsCapable", IsGroup );

DeclareAttribute( "NuclearRank", IsGroup );

DeclareAttribute( "MultiplicatorRank", IsGroup );

DeclareAttribute( "ANUPQIdentity", IsGroup );

DeclareAttribute( "ANUPQAutomorphisms", IsGroup );

DeclareProperty( "IsPcgsAutomorphisms", IsGroup );

#E  anupqprop.gd  . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
