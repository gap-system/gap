#############################################################################
##
#W  grpmat.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for matrix groups.
##
Revision.grpmat_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsMatrixGroup
##
IsMatrixGroup := IsRingElementCollCollColl and IsGroup;

InstallTrueMethod( IsHandledByNiceMonomorphism, IsMatrixGroup and IsFinite );

#############################################################################
##

#A  DefaultFieldOfMatrixGroup( <mat-grp> )
##
##  A field containing all the matrix entries.
##
DeclareAttribute(
    "DefaultFieldOfMatrixGroup",
    IsMatrixGroup );


InstallSubsetMaintainedMethod( DefaultFieldOfMatrixGroup,
        IsMatrixGroup and HasDefaultFieldOfMatrixGroup, IsMatrixGroup );


#############################################################################
##
#A  DimensionOfMatrixGroup( <mat-grp> )
##
##  The dimension of the matrix group.
##
DeclareAttribute(
    "DimensionOfMatrixGroup",
    IsMatrixGroup );


InstallSubsetMaintainedMethod( DimensionOfMatrixGroup,
        IsMatrixGroup and HasDimensionOfMatrixGroup, IsMatrixGroup );


#############################################################################
##
#A  FieldOfMatrixGroup( <mat-grp> )
##
##  The smallest  field containing all the  matrix entries.  This should only
##  be used        if  one *really*   needs     the    smallest   field,  use
##  'DefaultFieldOfMatrixGroup' to get (for example) the characteristic.
##
DeclareAttribute(
    "FieldOfMatrixGroup",
    IsMatrixGroup );



#############################################################################
##
#P  IsGeneralLinearGroup( <matgrp> )
##
DeclareProperty( "IsGeneralLinearGroup",
                                IsMatrixGroup );


#############################################################################
##

#E  grpmat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
