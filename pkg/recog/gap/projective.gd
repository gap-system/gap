#############################################################################
##
##  projective.gd        recog package
##                                                        Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2006 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Declaration stuff for projective recognition.
##
##  $Id: projective.gd,v 1.1 2006/10/06 20:58:48 gap Exp $
##
#############################################################################

DeclareGlobalFunction( "IsOneProjective" );
DeclareGlobalFunction( "IsEqualProjective" );

DeclareGlobalFunction( "InstallLowIndexHint" );
DeclareGlobalFunction( "DoHintedLowIndex" );
DeclareGlobalFunction( "LookupHintForSimple" );

DeclareGlobalVariable( "SUBFIELD" );  # for the subfield code
