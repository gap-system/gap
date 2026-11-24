#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

#############################################################################
#
# Packed matrix and vector objects: all entries in one bag, for base
# domains GF(p) and Integers mod n with n < 2^64. The kernel module
# src/packmat.c implements them on the core in src/packmat/.
#

#############################################################################
##
#R  IsPackedMatrixRep( <obj> )
#R  IsPackedVectorRep( <obj> )
##
##  A matrix object in IsPackedMatrixRep stores its dimensions and its
##  entries in one data object, row by row; it has no row objects, so
##  <M>[i] is not supported. A vector object in IsPackedVectorRep stores its
##  length and entries likewise. Two such objects are equal only if their
##  base domains are identical.
##
DeclareRepresentation( "IsPackedMatrixRep",
        IsMatrixObj and IsDataObjectRep
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain );

DeclareRepresentation( "IsPackedVectorRep",
        IsVectorObj and IsDataObjectRep
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain );


#############################################################################
##
#A  PackedRepContext( <R> )
##
##  The types of packed matrices and vectors over the base domain <R>, as a
##  record with the components matrix, immutableMatrix, vector and
##  immutableVector. Their data hold the kernel's field context, so every
##  base domain object gets its own. An error for unsupported <R>.
##
DeclareAttribute( "PackedRepContext", IsSemiring );
