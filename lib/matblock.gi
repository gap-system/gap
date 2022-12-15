#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation of methods for block matrices.
##


#############################################################################
##
#R  IsBlockMatrixRep( <mat> )
##
##  A matrix in this representation is described by the following data.
##
##  \beginitems
##  `blocks' &
##       an ordered list of triples $[ i, j, m ]$ where $m$ is a matrix
##       (possibly again a block matrix) with `rb' rows and `cb' columns
##       that is in the $i$-th row block and in the $j$-th column block
##       of the matrix <mat>,
##
##  `nrb' &
##       number of row blocks,
##
##  `ncb' &
##       number of column blocks,
##
##  `rpb' &
##       rows per block,
##
##  `cpb' &
##       columns per block,
##
##  `zero' &
##       the zero element that is stored in all places of the matrix
##       outside the blocks in `blocks'.
##  \enditems
##
DeclareRepresentation( "IsBlockMatrixRep",
    IsComponentObjectRep,
    [ "blocks", "zero", "nrb", "ncb", "rpb", "cpb" ] );


#############################################################################
##
#F  BlockMatrix( <blocks>, <nrb>, <ncb> )
#F  BlockMatrix( <blocks>, <nrb>, <ncb>, <rpb>, <cpb>, <zero> )
##
InstallGlobalFunction( BlockMatrix, function( arg )
    local blocks, nrb, ncb, rpb, cpb, zero, dims, newblocks, block, i;

    # Check and get the arguments.
    if Length( arg ) < 3 or not
       ( IsList( arg[1] ) and IsInt( arg[2] ) and IsInt( arg[3] ) ) then
      Error( "need at least <blocks>, <nrb>, <ncb>" );
    fi;

    blocks := arg[1];
    nrb    := arg[2];
    ncb    := arg[3];

    if Length( arg ) = 3 then
      if IsEmpty( blocks ) then
        Error( "need <rpb>, <cpb>, <zero> if <blocks> is empty" );
      fi;
      rpb  := Length( blocks[1][3] );
      cpb  := Length( blocks[1][3][1] );
      zero := Zero( blocks[1][3][1][1] );
    elif Length( arg ) = 6 then
      rpb  := arg[4];
      cpb  := arg[5];
      zero := arg[6];
    else
      Error("usage: BlockMatrix(<blocks>,<nrb>,<ncb>[,<rpb>,<cpb>,<zero>])");
    fi;

    if not ( IsInt(rpb) and IsInt(cpb) and IsInt(nrb) and IsInt(ncb) ) then
      Error( "block matrices must be finite" );
    fi;
    dims:= [ rpb, cpb ];

    # Remove zero blocks, and sort the list of blocks.
    newblocks:= [];
    for block in blocks do
      if IsBlockMatrixRep( block[3] ) or not IsZero( block[3] ) then
        if DimensionsMat( block[3] ) <> dims then
          Error( "all blocks must have the same dimensions" );
        fi;
        Add( newblocks, block );
      fi;
    od;
    Sort( newblocks );
    i:=1;
    while i+1<=Length(newblocks) do
      if newblocks[i][1] = newblocks[ i+1 ][1] and
         newblocks[i][2] = newblocks[ i+1 ][2] then

        #Error( "two blocks for position [", newblocks[i][1], "][",
        #       newblocks[i][2], "]" );
        newblocks:=Concatenation(newblocks{[1..i-1]},
             [[newblocks[i][1],newblocks[i][2],
               newblocks[i][3]+newblocks[i+1][3]]],
             newblocks{[i+2..Length(newblocks)]});
      else
        i:=i+1;
      fi;
    od;

    # Construct and return the block matrix.
    return Objectify( NewType( CollectionsFamily( CollectionsFamily(
                                   FamilyObj( zero ) ) ),
                                   IsOrdinaryMatrix
                               and IsMultiplicativeGeneralizedRowVector
                               and IsBlockMatrixRep
                               and IsCopyable
                               and IsFinite ),
                      rec( blocks := Immutable( newblocks ),
                           zero   := zero,
                           nrb    := nrb,
                           ncb    := ncb,
                           rpb    := rpb,
                           cpb    := cpb ) );
end );


#############################################################################
##
#M  Length( <blockmat> )  . . . . . . . . . . . . . . . .  for a block matrix
##
InstallOtherMethod( Length,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    blockmat -> blockmat!.nrb * blockmat!.rpb );


#############################################################################
##
#M  NrRows( <blockmat> )  . . . . . . . . . . . . . . . .  for a block matrix
##
InstallMethod( NrRows,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    blockmat -> blockmat!.nrb * blockmat!.rpb );


#############################################################################
##
#M  NrCols( <blockmat> )  . . . . . . . . . . . . . . . .  for a block matrix
##
InstallMethod( NrCols,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    blockmat -> blockmat!.ncb * blockmat!.cpb );


#############################################################################
##
#M  \[\]( <blockmat>, <n> ) . . . . . . . . . . . . . . .  for a block matrix
##
InstallOtherMethod( \[\],
    "for an ordinary block matrix and a positive integer",
    [ IsOrdinaryMatrix and IsBlockMatrixRep, IsPosInt ],
    function( blockmat, n )
    local qr, i, ii, row, block, j;

    # `n-1 = qr[1] * blockmat!.rpb + qr[2]'.
    qr:= QuotientRemainder( Integers, n-1, blockmat!.rpb );
    i:= qr[1] + 1;
    ii:= qr[2] + 1;

    row:= ListWithIdenticalEntries( blockmat!.cpb * blockmat!.ncb,
                                    blockmat!.zero );
    for block in blockmat!.blocks do
      if block[1] = i then
        j:= block[2];
        row{ [ (j-1)*blockmat!.cpb + 1 .. j*blockmat!.cpb ] }:= block[3][ii];
      elif i < block[1] then
        break;
      fi;
    od;

    return MakeImmutable(row);
    end );

#############################################################################
##
#M  \[\,\]( <blockmat>, <row>, <col> ) . . . . . . . . . . for a block matrix
##
InstallMethod( \[\,\],
    "for an ordinary block matrix and two positive integers",
    [ IsOrdinaryMatrix and IsBlockMatrixRep, IsPosInt, IsPosInt ],
    function( blockmat, row, col )
    local block_row, block_col, block;

    # `n-1 = qr[1] * blockmat!.rpb + qr[2]'.
    block_row := QuoInt(row - 1, blockmat!.rpb) + 1;
    block_col := QuoInt(col - 1, blockmat!.cpb) + 1;
    block := First(blockmat!.blocks, b -> b[1] = block_row and
                                          b[2] = block_col);
    if block = fail then
        return blockmat!.zero;
    fi;
    row := row - (block_row - 1) * blockmat!.rpb;
    col := col - (block_col - 1) * blockmat!.cpb;
    return block[3][row,col];
    end );


#############################################################################
##
#M  TransposedMat( <blockmat> ) . . . . . . . . . . . . .  for a block matrix
##
InstallOtherMethod( TransposedMat,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    m -> BlockMatrix( List( m!.blocks, i -> [ i[2], i[1],
                                              TransposedMat( i[3] ) ] ),
                      m!.ncb,
                      m!.nrb,
                      m!.cpb,
                      m!.rpb,
                      m!.zero ) );


#############################################################################
##
#M  MatrixByBlockMatrix( <blockmat> ) . . . create matrix from (block) matrix
##
InstallMethod( MatrixByBlockMatrix,
    [ IsMatrix ],
    function( blockmat )
    local mat, block, i, j;

    if not IsOrdinaryMatrix( blockmat ) then
      Error( "<blockmat> must be an ordinary matrix" );
    elif not IsBlockMatrixRep( blockmat ) then
      mat:= blockmat;
    else

      mat:= NullMat( blockmat!.nrb * blockmat!.rpb,
                     blockmat!.ncb * blockmat!.cpb,
                     blockmat!.zero );
      for block in blockmat!.blocks do
        i:= block[1];
        j:= block[2];
        mat{ [ (i-1)*blockmat!.rpb+1 .. i*blockmat!.rpb ] }{
             [ (j-1)*blockmat!.cpb+1 .. j*blockmat!.cpb ] }:=
              MatrixByBlockMatrix( block[3] );
      od;

    fi;

    return mat;
end );


#############################################################################
##
#F  AsBlockMatrix( <m>, <nrb>, <ncb> )  . . . create block matrix from matrix
##
InstallGlobalFunction( AsBlockMatrix, function( mat, nrb, ncb )
    local rpb, cpb, blocks, i, ii, j, jj, block;

    if not IsOrdinaryMatrix( mat ) or IsEmpty( mat ) then
      Error( "<mat> must be a nonempty ordinary matrix" );
    fi;

    rpb:= Length( mat ) / nrb;
    cpb:= Length( mat[1] ) / ncb;
    if not ( IsInt( rpb ) and IsInt( cpb ) ) then
      Error( "<nrb> and <ncb> must divide the dimensions of <mat>" );
    fi;

    blocks:= [];
    for i in [ 1 .. nrb ] do
      ii:= (i-1) * rpb;
      for j in [ 1 .. ncb ] do
        jj:= (j-1) * cpb;
        block:= mat{ [ ii+1 .. ii+cpb ] }{ [ jj+1 .. jj+rpb ] };
        if not IsZero( block ) then
          Add( blocks, [ i, j, block ] );
        fi;
      od;
    od;

    return BlockMatrix( blocks, nrb, ncb, rpb, cpb, Zero( mat[1][1] ) );
end );


#############################################################################
##
##  arithmetic operations for block matrices
##

#############################################################################
##
#M  \=( <bm1>, <bm2> )  . . . . . . . . . . . . . . .  for two block matrices
##
InstallMethod( \=,
    "for two ordinary block matrices",
    IsIdenticalObj,
    [ IsOrdinaryMatrix and IsBlockMatrixRep,
      IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( bm1, bm2 )
    if     bm1!.nrb = bm2!.nrb
       and bm1!.ncb = bm2!.ncb
       and bm1!.rpb = bm2!.rpb
       and bm1!.cpb = bm2!.cpb then
      return bm1!.blocks = bm2!.blocks;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \+( <bm1>, <bm2> )  . . . . . . . . . . . . . . .  for two block matrices
##
InstallMethod( \+,
    "for two ordinary block matrices",
    IsIdenticalObj,
    [ IsOrdinaryMatrix and IsBlockMatrixRep,
      IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( bm1, bm2 )
    local blocks, pos, i;

    if     bm1!.nrb = bm2!.nrb
       and bm1!.ncb = bm2!.ncb
       and bm1!.rpb = bm2!.rpb
       and bm1!.cpb = bm2!.cpb then

      blocks:= Concatenation( bm1!.blocks, bm2!.blocks );
      Sort( blocks );
      pos:= 1;
      i:= 1;
      while i < Length( blocks ) do
        blocks[ pos ]:= blocks[i];
        if blocks[i][1] = blocks[ i+1 ][1] and
           blocks[i][2] = blocks[ i+1 ][2] then
          blocks[ pos ]:= ShallowCopy( blocks[ pos ] );
          blocks[ pos ][3]:= blocks[i][3] + blocks[ i+1 ][3];
          i:= i+1;
        fi;
        i:= i+1;
        pos:= pos+1;
      od;
      if i = Length( blocks ) then
        blocks[ pos ]:= blocks[i];
        pos:= pos+1;
      fi;
      for i in [ pos .. Length( blocks ) ] do
        Unbind( blocks[i] );
      od;
      return BlockMatrix( blocks, bm1!.nrb, bm1!.ncb, bm1!.rpb, bm1!.cpb,
                          bm1!.zero );

    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \+( <bm>, <grv> ) . . . . . . . . . . . . . . .  for block matrix and grv
#M  \+( <grv>, <bm> ) . . . . . . . . . . . . . . .  for grv and block matrix
##
InstallOtherMethod( \+,
    "for an ordinary block matrix, and a grv",
    IsIdenticalObj,
    [ IsOrdinaryMatrix and IsBlockMatrixRep, IsGeneralizedRowVector ],
    function( bm, grv )
    return MatrixByBlockMatrix( bm ) + grv;
    end );

InstallOtherMethod( \+,
    "for a grv, and an ordinary block matrix",
    IsIdenticalObj,
    [ IsGeneralizedRowVector, IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( grv, bm )
    return grv + MatrixByBlockMatrix( bm );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <blockmat> ) . . . . . . . . . . .  for a block matrix
##
##  We can't do better than the default method for AdditiveInverseOp,
##  since that has to produce a mutable result
##
InstallMethod( AdditiveInverseOp,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    bm -> BlockMatrix( List( bm!.blocks,
                             b -> [ b[1], b[2], AdditiveInverse( b[3] ) ] ),
                       bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, bm!.zero ) );


#############################################################################
##
#M  \*( <bm1>, <bm2> )  . . . . . . . . . . . . . . .  for two block matrices
#M  \*( <bm>, <vec> ) . . . . . . . . . . . . . . for block matrix and vector
#M  \*( <vec>, <bm> ) . . . . . . . . . . . . . . for vector and block matrix
#M  \*( <bm>, <c> ) . . . . . . . . . . . . for block matrix and ring element
#M  \*( <c>, <bm> ) . . . . . . . . . . . . for ring element and block matrix
##
InstallMethod( \*,
    "for two ordinary block matrices",
    IsIdenticalObj,
    [ IsOrdinaryMatrix and IsBlockMatrixRep,
      IsOrdinaryMatrix and IsBlockMatrixRep ], 6,
    # being a block matrix is better than being a small list
    function( bm1, bm2 )
    local blocks, b1, b2, pos, i;

    if     bm1!.ncb = bm2!.nrb and bm1!.cpb = bm2!.rpb then

      # Get the blocks of the product.
      blocks:= [];
      for b1 in bm1!.blocks do
        for b2 in bm2!.blocks do
          if b1[2] = b2[1] then
            Add( blocks, [ b1[1], b2[2], b1[3] * b2[3] ] );
          fi;
        od;
      od;

      # Put blocks at the same position together.
      pos:= 1;
      i:= 1;
      while i < Length( blocks ) do
        blocks[ pos ]:= blocks[i];
        if blocks[i][1] = blocks[ i+1 ][1] and
           blocks[i][2] = blocks[ i+1 ][2] then
          blocks[ pos ]:= ShallowCopy( blocks[ pos ] );
          blocks[ pos ][3]:= blocks[i][3] + blocks[ i+1 ][3];
          i:= i+1;
        fi;
        i:= i+1;
        pos:= pos+1;
      od;
      if i = Length( blocks ) then
        blocks[ pos ]:= blocks[i];
        pos:= pos+1;
      fi;
      for i in [ pos .. Length( blocks ) ] do
        Unbind( blocks[i] );
      od;

      # Return the result.
      return BlockMatrix( blocks, bm1!.nrb, bm2!.ncb, bm1!.rpb, bm2!.cpb,
                          bm1!.zero );

    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \*,
    "for ordinary block matrix and vector",
    IsCollsElms,
    [ IsOrdinaryMatrix and IsBlockMatrixRep, IsRowVector ],
    function( bm, vec )
    local cpb, rpb, ncols, nrows, vector, block, i, j;

    cpb:= bm!.cpb;
    rpb:= bm!.rpb;
    ncols:= bm!.ncb * cpb;
    nrows:= bm!.nrb * rpb;
    if Length( vec ) < ncols then
      vec:= Concatenation( vec,
              ListWithIdenticalEntries( ncols - Length( vec ), bm!.zero ) );
#T yes, this can be optimized ...
    fi;

    vector:= ListWithIdenticalEntries( nrows, bm!.zero );
    for block in bm!.blocks do
      i:= block[1];
      j:= block[2];
      vector{ [ (i-1)*rpb+1 .. i*rpb ] }:=
                        vector{ [ (i-1)*rpb+1 .. i*rpb ] } +
                        block[3] * vec{ [ (j-1)*cpb+1 .. j*cpb ] };
    od;

    return vector;
    end );

InstallMethod( \*,
    "for vector and ordinary block matrix",
    IsElmsColls,
    [ IsRowVector, IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( vec, bm )
    local cpb, rpb, ncols, nrows, vector, block, i, j;

    cpb:= bm!.cpb;
    rpb:= bm!.rpb;
    ncols:= bm!.ncb * cpb;
    nrows:= bm!.nrb * rpb;
    if Length( vec ) < nrows then
      vec:= Concatenation( vec,
              ListWithIdenticalEntries( nrows - Length( vec ), bm!.zero ) );
#T yes, this can be optimized ...
    fi;

    vector:= ListWithIdenticalEntries( ncols, bm!.zero );
    for block in bm!.blocks do
      i:= block[1];
      j:= block[2];
      vector{ [ (j-1)*cpb+1 .. j*cpb ] }:=
                        vector{ [ (j-1)*cpb+1 .. j*cpb ] } +
                        vec{ [ (i-1)*rpb+1 .. i*rpb ] } * block[3];
    od;

    return vector;
    end );

InstallMethod( \*,
    "for ordinary block matrix and ring element",
    IsCollCollsElms,
    [ IsOrdinaryMatrix and IsBlockMatrixRep, IsRingElement ],
    function( bm, c )
    return BlockMatrix( List( bm!.blocks,
                              b -> [ b[1], b[2], b[3] * c ] ),
                        bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, bm!.zero );
    end );

InstallMethod( \*,
    "for ring element and ordinary block matrix",
    IsElmsCollColls,
    [ IsRingElement, IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( c, bm )
    return BlockMatrix( List( bm!.blocks,
                              b -> [ b[1], b[2], c * b[3] ] ),
                        bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, bm!.zero );
    end );


#############################################################################
##
#M  \*( <bm>, <n> ) . . . . . . . . . . . . . .  for block matrix and integer
#M  \*( <n>, <bm> ) . . . . . . . . . . . . . .  for integer and block matrix
##
InstallMethod( \*,
    "for ordinary block matrix and integer",
    [ IsOrdinaryMatrix and IsBlockMatrixRep, IsInt ],
    function( bm, n )
    return BlockMatrix( List( bm!.blocks,
                              b -> [ b[1], b[2], b[3] * n ] ),
                        bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, bm!.zero );
    end );

InstallMethod( \*,
    "for integer and ordinary block matrix",
    [ IsInt, IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( n, bm )
    return BlockMatrix( List( bm!.blocks,
                              b -> [ b[1], b[2], n * b[3] ] ),
                        bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, bm!.zero );
    end );


#############################################################################
##
#M  \*( <bm>, <z> ) . . . . . . . . . . . .  for integer block matrix and ffe
#M  \*( <z>, <bm> ) . . . . . . . . . . . .  for ffe and integer block matrix
##
InstallMethod( \*,
    "for ordinary block matrix of integers and ffe",
    [ IsOrdinaryMatrix and IsBlockMatrixRep and IsCyclotomicCollColl,
      IsFFE ],
    function( bm, z )
    return BlockMatrix( List( bm!.blocks,
                              b -> [ b[1], b[2], b[3] * z ] ),
                        bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, Zero( z ) );
    end );

InstallMethod( \*,
    "for ffe and ordinary block matrix of integers",
    [ IsFFE,
      IsOrdinaryMatrix and IsBlockMatrixRep and IsCyclotomicCollColl ],
    function( z, bm )
    return BlockMatrix( List( bm!.blocks,
                              b -> [ b[1], b[2], z * b[3] ] ),
                        bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, Zero( z ) );
    end );


#############################################################################
##
#M  \*( <bm>, <mgrv> )  . . . . . . . . . . . . . . for block matrix and mgrv
#M  \*( <mgrv>, <bm> )  . . . . . . . . . . . . . . for mgrv and block matrix
##
InstallOtherMethod( \*,
    "for an ordinary block matrix, and a mgrv",
    IsIdenticalObj,
    [ IsOrdinaryMatrix and IsBlockMatrixRep,
      IsMultiplicativeGeneralizedRowVector ],
    function( bm, grv )
    return MatrixByBlockMatrix( bm ) * grv;
    end );

InstallOtherMethod( \*,
    "for a mgrv, and an ordinary block matrix",
    IsIdenticalObj,
    [ IsMultiplicativeGeneralizedRowVector,
      IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( grv, bm )
    return grv * MatrixByBlockMatrix( bm );
    end );


#############################################################################
##
#M  OneOp( <bm> )  . . . . . . . . . . . . . . . . . . . . for a block matrix
##
InstallOtherMethod( OneOp,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ], 3,
    # being a block matrix is better than being a small list
    function( bm )
    local mat;
    if bm!.nrb = bm!.ncb and bm!.rpb = bm!.cpb then
      if IsEmpty( bm!.blocks ) then
        mat:= Immutable( IdentityMat( bm!.rpb, bm!.zero ) );
      else
        mat:= One( bm!.blocks[1][3] );
      fi;
      return BlockMatrix( List( [ 1 .. bm!.nrb ], i -> [ i, i, mat ] ),
                          bm!.nrb, bm!.ncb, bm!.rpb, bm!.cpb, bm!.zero );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  InverseOp( <bm> )  . . . . . . . . . . . . . . . . . . for a block matrix
##
InstallOtherMethod( InverseOp,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
function( bm )
  return AsBlockMatrix(InverseOp(MatrixByBlockMatrix(bm)),bm!.nrb,bm!.ncb);
end );

#############################################################################
##
#M  \^
##
InstallMethod( \^,"for block matrix and integer",
    [ IsOrdinaryMatrix and IsBlockMatrixRep,IsInt ],POW_OBJ_INT);

#############################################################################
##
#M  ViewObj( <blockmat> ) . . . . . . . . . . . . . . . .  for a block matrix
##
InstallMethod( ViewObj,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( m )
    Print( "<block matrix of dimensions (", m!.nrb, "*", m!.rpb,
           ")x(", m!.ncb, "*", m!.cpb, ")>" );
    end );


#############################################################################
##
#M  PrintObj( <blockmat> )  . . . . . . . . . . . . . . .  for a block matrix
##
InstallMethod( PrintObj,
    "for an ordinary block matrix",
    [ IsOrdinaryMatrix and IsBlockMatrixRep ],
    function( m )
    Print( "BlockMatrix( ", m!.blocks, ",", m!.nrb, ",", m!.ncb,
           ",", m!.rpb, ",", m!.cpb, ",", m!.zero, " )" );
    end );
