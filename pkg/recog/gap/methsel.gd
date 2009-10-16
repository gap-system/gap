#############################################################################
##
##  methsel.gd          recog package                     Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Declaration stuff for our own method selection.
##
##  $Id: methsel.gd,v 1.3 2005/10/11 15:19:33 gap Exp $
##
#############################################################################

# Our own method selection code:

DeclareInfoClass( "InfoMethSel" );
SetInfoLevel(InfoMethSel,2);
DeclareGlobalFunction( "AddMethod" );
DeclareGlobalVariable( "NotApplicable" );
DeclareGlobalFunction( "CallMethods" );


