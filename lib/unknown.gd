#############################################################################
##
#W  unknown.gd                 GAP Library                   Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for unknowns.
##
Revision.unknown_gd :=
    "@(#)$Id$";


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
Unknown := NewConstructor( "Unknown", [ IsPosRat and IsInt ] );


#############################################################################
##
#E  unknown.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



