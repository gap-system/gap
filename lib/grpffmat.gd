#############################################################################
##
#W  grpffmat.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for matrix groups over finite field.
##
Revision.grpffmat_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsFFEMatrixGroup
##
IsFFEMatrixGroup := IsFFECollCollColl and IsMatrixGroup;


#############################################################################
##

#M  IsFinite( <ffe-mat-grp> )
##
##  NOTE:    The following implication    only  holds  if  there no  infinite
##  dimensional matrices.
##
InstallTrueMethod( IsFinite,
    IsFFEMatrixGroup and IsFinitelyGeneratedGroup );


#############################################################################
##
#M  IsHandledByNiceMonomorphism( <ffe-mat-grp> )
##
InstallTrueMethod( IsHandledByNiceMonomorphism,
    IsFFEMatrixGroup and IsFinite );


#############################################################################
##

#E  grpffmat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
