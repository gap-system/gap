#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

# TODO: document this
DeclareRepresentation( "IsPositionalVectorRep",
        IsVectorObj and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );

# TODO: document this
DeclareRepresentation( "IsPositionalMatrixRep",
        IsMatrixObj and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


#
# Some constants for matrix resp. vector access
#
# TODO: For now the order follows the order of the predecessors:
# BDPOS = 1, RLPOS = 3, ROWSPOS = 4; the goal is to
# eventually change this. But this needs us to carefully revisit
# all Objectify calls

# Position of the base domain
BindConstant( "MAT_BD_POS", 1 );
# Position of the number of rows
BindConstant( "MAT_NROWS_POS", 5 );  # FIXME: in many cases superfluous (can be computed from NCOLS and DATA)
# Position of the number of columns
BindConstant( "MAT_NCOLS_POS", 3 );
# Position of the data
BindConstant( "MAT_DATA_POS", 4 );

# Position of the base domain
BindConstant( "VEC_BD_POS", 1 );
# Position of the data
BindConstant( "VEC_DATA_POS", 2 );
# Position of the length
#BindConstant( "VEC_LENPOS", 3 ); # FIXME: not actually needed in general????
