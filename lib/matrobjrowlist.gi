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
# Elementary matrix operations
############################################################################

############################################################################
##
#M  MultMatrixRow( <M>, <row>, <scalar> )
##
InstallMethod( MultMatrixRowLeft, "for a mutable IsRowListMatrix, a row number, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsObject ],
  function( mat, row, scalar )

    MultVectorLeft(mat[row], scalar);

  end );


############################################################################
##
#M  MultMatrixRowRight( <M>, <row>, <scalar> )
##
InstallMethod( MultMatrixRowRight, "for a mutable IsRowListMatrix, a row number, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsObject ],
  function( mat, row, scalar )

    MultVectorRight(mat[row], scalar);

  end );


############################################################################
##
#M  AddMatrixRows( <M>, <row1>, <row2>, <scalar> )
##
InstallMethod( AddMatrixRowsLeft, "for a mutable IsRowListMatrix, two row numbers, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, row1, row2, scalar )

    AddVector(mat[row1], mat[row2], scalar);
    # TODO: AddVector does not specify left/right... we need both variants I guess

  end );


############################################################################
##
#M  AddMatrixRowsRight( <M>, <row1>, <row2>, <scalar> )
##
InstallMethod( AddMatrixRowsRight, "for a mutable IsRowListMatrix, two row numbers, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, row1, row2, scalar )

    AddVector(mat[row1], mat[row2], scalar);
    # TODO: AddVector does not specify left/right... we need both variants I guess

  end );

############################################################################
##
#M  SwapMatrixRows( <M>, <row1>, <row2> )
##
InstallMethod( SwapMatrixRows, "for a mutable IsRowListMatrix, and two row numbers",
  [ IsRowListMatrix and IsMutable, IsInt, IsInt ],
  function( mat, row1, row2 )
    local temp;

    temp := mat[row1];
    mat[row1] := mat[row2];
    mat[row2] := temp;

  end );
