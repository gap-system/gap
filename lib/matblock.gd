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
##  Note that all blocks must be ordinary matrices,
##  and also the block matrix is an ordinary matrix.
##
DeclareGlobalFunction( "BlockMatrix" );


#############################################################################
##
#F  MatrixByBlockMatrix( <blockmat> ) . . . create matrix from (block) matrix
##
DeclareGlobalFunction( "MatrixByBlockMatrix" );


#############################################################################
##
#F  AsBlockMatrix( <m>, <nrb>, <ncb> )  . . . create block matrix from matrix
##
##  The resulting block matrix has <nrb> row blocks and <ncb> column blocks.
##
DeclareGlobalFunction( "AsBlockMatrix" );


#############################################################################
##
#E  matblock.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

