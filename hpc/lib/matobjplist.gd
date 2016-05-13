############################################################################
# 
# matobjplist.gd
#                                                        by Max Neunhöffer
#
# Copyright (C) 2006 by Lehrstuhl D für Mathematik, RWTH Aachen
#
# This file is a sample implementation for new style vectors and matrices.
# It stores matrices as dense lists of lists with wrapping.
# This part declares the representations and other type related things,
# and declares some global functions.
#
############################################################################


DeclareRepresentation( "IsPlistVectorRep", 
   IsRowVectorObj and IsPositionalObjectRep, [] );
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

# Another pair of filters that slow down things:
DeclareFilter( "IsCheckingVector" );
DeclareFilter( "IsCheckingMatrix" );

############################################################################
# Constructors:
############################################################################

DeclareGlobalFunction( "MakePlistVectorType" );

