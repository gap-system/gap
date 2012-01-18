#############################################################################
####
##
#W  anupqid.gd              ANUPQ package                       Werner Nickel
#W                                                                Greg Gamble
##
##  This file declares functions to do with evaluating identities.
##
#H  @(#)$Id: anupqid.gd,v 1.2 2011/11/29 20:00:12 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

#############################################################################
##
#F  PqEvalSingleRelation( <proc>, <r>, <instances> )
##
DeclareGlobalFunction( "PqEvalSingleRelation" );
    
#############################################################################
##
#F  PqEnumerateWords( <proc>, <data>, <r> )
##
DeclareGlobalFunction( "PqEnumerateWords" );

#############################################################################
##
#F  PqEvaluateIdentity( <proc>, <r>, <arity> )
##
DeclareGlobalFunction( "PqEvaluateIdentity" );

#############################################################################
##
#F  PqWithIdentity( <G>, <p>, <Cl>, <identity> )
##
DeclareGlobalFunction( "PqWithIdentity" );

#############################################################################
##
#F  PQ_EVALUATE_IDENTITY( <proc>, <identity> )
##
DeclareGlobalFunction( "PQ_EVALUATE_IDENTITY" );
    
#E  anupqid.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
