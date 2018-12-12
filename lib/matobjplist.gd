#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

############################################################################
#
# This file is a sample implementation for new style vectors and matrices.
# It stores matrices as dense lists of lists with wrapping.
# This part declares the representations and other type related things,
# and declares some global functions.
#


DeclareRepresentation( "IsPlistVectorRep", 
   IsVectorObj and IsPositionalObjectRep, [] );
# 2 positions used:
# ![1] : BaseDomain
# ![2] : the elements as plain list

DeclareRepresentation( "IsPlistMatrixRep", 
   IsRowListMatrix and IsPositionalObjectRep, [] );
# 4 positions used:
# ![1] : BaseDomain
# ![2] : empty vector of corresponding vector representation
# ![3] : row length
# ![4] : the rows as plain list of vectors in the filter IsPlistVectorRep

# Some constants for matrix access:
BindGlobal( "BDPOS", 1 );
BindGlobal( "EMPOS", 2 );
BindGlobal( "RLPOS", 3 );
BindGlobal( "ROWSPOS", 4 );

# For vector access:
#BindGlobal( "BDPOS", 1 );   # see above
BindGlobal( "ELSPOS", 2 );

# Two filters to speed up some methods:
DeclareFilter( "IsIntVector" );
DeclareFilter( "IsFFEVector" );

############################################################################
# Constructors:
############################################################################

DeclareGlobalFunction( "MakePlistVectorType" );

