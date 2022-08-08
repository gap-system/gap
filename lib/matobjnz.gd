#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

# represent vectors/matrices over Z/nZ by nonnegative integer lists 
# in the range [0..n-1], but reduce after
# arithmetic. This way avoid always wrapping all entries separately

DeclareRepresentation( "IsZmodnZVectorRep",
        IsVectorObj and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );

DeclareRepresentation( "IsZmodnZMatrixRep",
        IsRowListMatrix and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );
