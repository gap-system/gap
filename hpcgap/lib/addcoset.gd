#############################################################################
##
#W  addcoset.gd                 GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for additive cosets.
##


#############################################################################
##
#C  IsAdditiveCoset( <D> )
##
##  An additive coset is an external additive set whose additively acting
##  domain is an additive group.
##  The additive coset and its additively acting domain lie in the same
##  family.
##
##  Note that additive cosets for non-commutative addition are not supported.
##
DeclareCategory( "IsAdditiveCoset",
    IsExtASet and IsAssociativeAOpESum and IsTrivialAOpEZero );


#############################################################################
##
#O  AdditiveCoset( <A>, <a> )
##
DeclareOperation( "AdditiveCoset", [ IsAdditiveGroup, IsAdditiveElement ] );


#############################################################################
##
#E

