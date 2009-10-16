#############################################################################
##
#W    lib.gd               The GenSift package                Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: lib.gd,v 1.1.1.1 2004/12/22 13:22:49 gap Exp $
##
##  This file contains declarations for some basic things used in other files.
##

# A helper for floating point numbers:

DeclareGlobalFunction("FLOAT_RAT");

# Our info class:

DeclareInfoClass( "InfoGenSift" );

# In the following record we store all internal functions:

DeclareGlobalVariable( "GenSift" );
