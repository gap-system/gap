##############################################################################
##
#W  unknown.gd                 GAP Library                   Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for unknowns.
##
Revision.unknown_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsUnknown( <obj> )
##
DeclareCategory( "IsUnknown", IsCyclotomic );
    
    
#############################################################################
##
#V  LargestUnknown  . . . . . . . . . . . . largest used index for an unknown
##
##  'LargestUnknown' is the largest <n> that is used in any 'Unknown(<n>)'.
##  This is used in 'Unknown' which increments this value when asked to
##  make a new unknown.
##
LargestUnknown := 0;


#############################################################################
##
#O  Unknown()
#O  Unknown( <n> )
##
##  In the first form 'Unknown' returns a new unknown 'Unknown(<n>)' with a
##  <n> that was not previously used.
##
##  In the second form 'Unknown' returns the unknown 'Unknown(<n>)'.
##
DeclareOperation( "Unknown", [ IsPosInt ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#E  unknown.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



