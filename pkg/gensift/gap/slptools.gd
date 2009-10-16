#############################################################################
##
#W    slptools.gd           The GenSift package               Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: slptools.gd,v 1.1.1.1 2004/12/22 13:22:49 gap Exp $
##
##  This file contains declarations for code to work with straight line
##  programs, escecially to produce random elements in groups together
##  with slps to describe them.
##

DeclareAttribute( "PseudoRandomSeedSLP", IsListOrCollection, "mutable" );
DeclareAttribute( "PseudoRandomSeedSLPStart", IsListOrCollection, "mutable" );
DeclareOperation( "PseudoRandomSLP", [ IsListOrCollection ] );
DeclareOperation( "ResetPseudoRandomSLP", [ IsListOrCollection ] );
DeclareOperation( "PseudoRandomAsSLP", [ IsListOrCollection ] );
# the same as PseudoRandom, but returns a pair of an element and a word

DeclareGlobalVariable( "PseudoRandomSLPDefaults" );

DeclareGlobalFunction( "Group_InitPseudoRandomSLP" );
DeclareGlobalFunction( "Group_ResetPseudoRandomSLP" );
DeclareGlobalFunction( "Group_PseudoRandomSLP" );
DeclareGlobalFunction( "Group_PseudoRandomAsSLP" );

