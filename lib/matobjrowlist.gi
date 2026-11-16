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
# Elementary matrix operations
#############################################################################

#############################################################################
##
#M  MultMatrixRow( <M>, <row>, <scalar> )
##
InstallMethod( MultMatrixRowLeft, "for a mutable IsRowListMatrix, a row number, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsObject ],
  function( mat, row, scalar )

    MultVectorLeft(mat[row], scalar);

  end );


#############################################################################
##
#M  MultMatrixRowRight( <M>, <row>, <scalar> )
##
InstallMethod( MultMatrixRowRight, "for a mutable IsRowListMatrix, a row number, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsObject ],
  function( mat, row, scalar )

    MultVectorRight(mat[row], scalar);

  end );


#############################################################################
##
#M  AddMatrixRows( <M>, <row1>, <row2>, <scalar> )
##
InstallMethod( AddMatrixRowsLeft, "for a mutable IsRowListMatrix, two row numbers, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, row1, row2, scalar )

    AddVector(mat[row1], mat[row2], scalar);
    # TODO: AddVector does not specify left/right... we need both variants I guess

  end );


#############################################################################
##
#M  AddMatrixRowsRight( <M>, <row1>, <row2>, <scalar> )
##
InstallMethod( AddMatrixRowsRight, "for a mutable IsRowListMatrix, two row numbers, and a scalar",
  [ IsRowListMatrix and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, row1, row2, scalar )

    AddVector(mat[row1], mat[row2], scalar);
    # TODO: AddVector does not specify left/right... we need both variants I guess

  end );

#############################################################################
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


#############################################################################
##
##  Compressed matrices are lists of rows but not in 'IsRowListMatrix'.
##  The entry-wise methods for 'IsMatrixOrMatrixObj' would be 30 to 800
##  times slower.
##
Perform( [ IsGF2MatrixRep, Is8BitMatrixRep ], function( filt )

  InstallMethod( MultMatrixRowLeft,
    "for a mutable compressed matrix, a row number, and a scalar",
    [ filt and IsMutable, IsInt, IsObject ],
    function( mat, row, scalar )
      MultVectorLeft( mat[row], scalar );
    end );

  InstallMethod( MultMatrixRowRight,
    "for a mutable compressed matrix, a row number, and a scalar",
    [ filt and IsMutable, IsInt, IsObject ],
    function( mat, row, scalar )
      MultVectorRight( mat[row], scalar );
    end );

  InstallMethod( AddMatrixRowsLeft,
    "for a mutable compressed matrix, two row numbers, and a scalar",
    [ filt and IsMutable, IsInt, IsInt, IsObject ],
    function( mat, row1, row2, scalar )
      AddVector( mat[row1], mat[row2], scalar );
    end );

  InstallMethod( AddMatrixRowsRight,
    "for a mutable compressed matrix, two row numbers, and a scalar",
    [ filt and IsMutable, IsInt, IsInt, IsObject ],
    function( mat, row1, row2, scalar )
      AddVector( mat[row1], mat[row2], scalar );
    end );

  InstallMethod( SwapMatrixRows,
    "for a mutable compressed matrix, and two row numbers",
    [ filt and IsMutable, IsInt, IsInt ],
    function( mat, row1, row2 )
      local temp;

      temp := mat[row1];
      mat[row1] := mat[row2];
      mat[row2] := temp;
    end );

  InstallMethod( PositionNonZeroInRow,
    "for a compressed matrix and a row number",
    [ filt, IsPosInt ],
    { mat, row } -> PositionNonZero( mat[row] ) );

  InstallMethod( PositionNonZeroInRow,
    "for a compressed matrix, a row number, and a start position",
    [ filt, IsPosInt, IsInt ],
    { mat, row, from } -> PositionNonZero( mat[row], from ) );

  InstallMethod( MultMatrixLeft,
    "for a mutable compressed matrix and a scalar",
    [ filt and IsMutable, IsScalar ],
    function( mat, scalar )
      local i;

      for i in [ 1 .. NrRows( mat ) ] do
        MultVectorLeft( mat[i], scalar );
      od;
    end );

  InstallMethod( MultMatrixRight,
    "for a mutable compressed matrix and a scalar",
    [ filt and IsMutable, IsScalar ],
    function( mat, scalar )
      local i;

      for i in [ 1 .. NrRows( mat ) ] do
        MultVectorRight( mat[i], scalar );
      od;
    end );

end );

# 'Is8BitMatrixRep' has its own 'AddMatrix' methods.
InstallMethod( AddMatrix, "for a mutable gf2 matrix and a gf2 matrix",
  [ IsGF2MatrixRep and IsMutable, IsGF2MatrixRep ],
  function( dstmat, srcmat )
    local i;

    if DimensionsMat( dstmat ) <> DimensionsMat( srcmat ) then
      Error( "AddMatrix: matrices must have the same dimensions" );
    fi;
    for i in [ 1 .. NrRows( dstmat ) ] do
      AddRowVector( dstmat[i], srcmat[i] );
    od;
  end );

InstallMethod( AddMatrix,
  "for a mutable gf2 matrix, a gf2 matrix, and a scalar",
  [ IsGF2MatrixRep and IsMutable, IsGF2MatrixRep, IsScalar ],
  function( dstmat, srcmat, scalar )
    local i;

    if DimensionsMat( dstmat ) <> DimensionsMat( srcmat ) then
      Error( "AddMatrix: matrices must have the same dimensions" );
    fi;
    for i in [ 1 .. NrRows( dstmat ) ] do
      AddRowVector( dstmat[i], srcmat[i], scalar );
    od;
  end );
