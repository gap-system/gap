#############################################################################
##
#W  addcoset.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for additive cosets.
##
Revision.addcoset_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsAdditiveCoset( <D> )
##
##  An additive coset is an external additive set whose additively acting
##  domain is an additive group.
##  The additive coset and its additively acting domain lie in the same
##  family.
##
IsAdditiveCoset := NewCategory( "IsAdditiveCoset",
    IsExtASet and IsAssociativeAOpESum and IsTrivialAOpEZero );


#############################################################################
##
#O  AdditiveCoset( <A>, <a> )
##
AdditiveCoset := NewOperation( "AdditiveCoset",
    [ IsAdditiveGroup, IsAdditiveElement ] );


#############################################################################
##
#E  addcoset.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



