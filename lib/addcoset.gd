#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
