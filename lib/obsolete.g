#############################################################################
##
#W  obsolete.g                  GAP library                     Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains a number of functions, or extensions of
##  functions to certain numbers or combinations of arguments, which
##  are now considered "deprecated" or "obsolescent", buit which are presently
##  included in the system to maintain backwards compatibility.
##
##  Procedures for dealing with this functionality are not yet completely
##  agreed, but it will probably be removed from the system over
##  several releases. 
##
##  These functions should NOT be used in the library

Revision.obsolete_g :=
    "@(#)$Id$";
##
## Some relics of the old primitive groups library.
##

DeclareGlobalFunction( "AffinePermGroupByMatrixGroup");

InstallGlobalFunction( AffinePermGroupByMatrixGroup, 
        function(arg)
    return AffineActionByMatrixGroup(arg[1]);
end);

DeclareSynonym( "PrimitiveAffinePermGroupByMatrixGroup", AffineActionByMatrixGroup);

#############################################################################
##
#E

