#############################################################################
##
#W  grpmat.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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


#############################################################################
##

#A  DefaultFieldOfMatrixGroup( <mat-grp> )
##
##  A field containing all the matrix entries.
##
DefaultFieldOfMatrixGroup := NewAttribute(
    "DefaultFieldOfMatrixGroup",
    IsMatrixGroup );

SetDefaultFieldOfMatrixGroup := Setter(DefaultFieldOfMatrixGroup);
HasDefaultFieldOfMatrixGroup := Tester(DefaultFieldOfMatrixGroup);


#############################################################################
##
#A  DimensionOfMatrixGroup( <mat-grp> )
##
##  The dimension of the matrix group.
##
DimensionOfMatrixGroup := NewAttribute(
    "DimensionOfMatrixGroup",
    IsMatrixGroup );

SetDimensionOfMatrixGroup := Setter(DimensionOfMatrixGroup);
HasDimensionOfMatrixGroup := Tester(DimensionOfMatrixGroup);


#############################################################################
##
#A  FieldOfMatrixGroup( <mat-grp> )
##
##  The smallest  field containing all the  matrix entries.  This should only
##  be used        if  one *really*   needs     the    smallest   field,  use
##  'DefaultFieldOfMatrixGroup' to get (for example) the characteristic.
##
FieldOfMatrixGroup := NewAttribute(
    "FieldOfMatrixGroup",
    IsMatrixGroup );

SetFieldOfMatrixGroup := Setter(FieldOfMatrixGroup);
HasFieldOfMatrixGroup := Tester(FieldOfMatrixGroup);


#############################################################################
##
#P  IsGeneralLinearGroup( <matgrp> )
##
IsGeneralLinearGroup := NewProperty( "IsGeneralLinearGroup",
                                IsMatrixGroup );
SetIsGeneralLinearGroup := Setter( IsGeneralLinearGroup );
HasIsGeneralLinearGroup := Tester( IsGeneralLinearGroup );


#############################################################################
##

#E  grpmat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
