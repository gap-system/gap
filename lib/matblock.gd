#############################################################################
##
#W  matblock.gd                 GAP Library                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for block matrices.
##
Revision.matblock_gd :=
    "@(#)$Id$";

#1
##  Block matrices are a special representation of matrices which can save a
##  lot of memory if large matrices have a block structure with lots of zero
##  blocks. {\GAP} uses the representation `IsBlockMatrixRep' to store block
##  matrices.
##  \indextt{IsBlockMatrixRep}


#############################################################################
##
#F  BlockMatrix( <blocks>, <nrb>, <ncb> )
#F  BlockMatrix( <blocks>, <nrb>, <ncb>, <rpb>, <cpb>, <zero> )
##
##  `BlockMatrix' returns an immutable matrix in the sparse representation
##  `IsBlockMatrixRep'.
##  The nonzero blocks are described by the list <blocks> of triples,
##  the matrix has <nrb> row blocks and <ncb> column blocks.
##
##  If <blocks> is empty (i.e., if the matrix is a zero matrix) then
##  the dimensions of the blocks must be entered as <rpb> and <cpb>,
##  and the zero element as <zero>.
##
##  Note that all blocks must be ordinary matrices (see~"IsOrdinaryMatrix"),
##  and also the block matrix is an ordinary matrix.
##
DeclareGlobalFunction( "BlockMatrix" );


#############################################################################
##
#F  MatrixByBlockMatrix( <blockmat> ) . . . create matrix from (block) matrix
##
##  returns an ordinary matrix that is equal to the block matrix
##  <blockmat>.
##
DeclareGlobalFunction( "MatrixByBlockMatrix" );
#T ConvertToPlistRep?


#############################################################################
##
#F  AsBlockMatrix( <m>, <nrb>, <ncb> )  . . . create block matrix from matrix
##
##  returns a block matrix with <nrb> row blocks and <ncb> column blocks
##  which is equal to the ordinary matrix <m>.
##
DeclareGlobalFunction( "AsBlockMatrix" );
#T ConvertToBlockMatrixRep?


#############################################################################
##
#E

