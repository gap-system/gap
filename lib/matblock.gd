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
##  This file contains the declarations for block matrices.
##


##  <#GAPDoc Label="[1]{matblock}">
##  Block matrices are a special representation of matrices which can save a
##  lot of memory if large matrices have a block structure with lots of zero
##  blocks. &GAP; uses the representation <C>IsBlockMatrixRep</C>
##  to store block matrices.
##  <Index Key="IsBlockMatrixRep">IsBlockMatrixRep</Index>
##  <#/GAPDoc>
##


#############################################################################
##
#F  BlockMatrix( <blocks>, <nrb>, <ncb>[, <rpb>, <cpb>, <zero>] )
##
##  <#GAPDoc Label="BlockMatrix">
##  <ManSection>
##  <Func Name="BlockMatrix" Arg='blocks, nrb, ncb[, rpb, cpb, zero]'/>
##
##  <Description>
##  <Ref Func="BlockMatrix"/> returns an immutable matrix in the sparse
##  representation <C>IsBlockMatrixRep</C>.
##  The nonzero blocks are described by the list <A>blocks</A> of triples
##  <M>[ <A>i</A>, <A>j</A>, M(i,j) ]</M> each consisting of a matrix
##  <M>M(i,j)</M> and its block coordinates in the block matrix to be
##  constructed.
##  All matrices <M>M(i,j)</M> must have the same dimensions.
##  As usual the first coordinate specifies the row and the second one
##  the column.
##  The resulting matrix has <A>nrb</A> row blocks and <A>ncb</A> column
##  blocks.
##  <P/>
##  If <A>blocks</A> is empty (i.e., if the matrix is a zero matrix) then
##  the dimensions of the blocks must be entered as <A>rpb</A> and
##  <A>cpb</A>, and the zero element as <A>zero</A>.
##  <P/>
##  Note that all blocks must be ordinary matrices
##  (see&nbsp;<Ref Filt="IsOrdinaryMatrix"/>),
##  and also the block matrix is an ordinary matrix.
##  <Example><![CDATA[
##  gap> M := BlockMatrix([[1,1,[[1, 2],[ 3, 4]]],
##  >                      [1,2,[[9,10],[11,12]]],
##  >                      [2,2,[[5, 6],[ 7, 8]]]],2,2);
##  <block matrix of dimensions (2*2)x(2*2)>
##  gap> Display(M);
##  [ [   1,   2,   9,  10 ],
##    [   3,   4,  11,  12 ],
##    [   0,   0,   5,   6 ],
##    [   0,   0,   7,   8 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BlockMatrix" );


#############################################################################
##
#A  MatrixByBlockMatrix( <blockmat> ) . . . create matrix from (block) matrix
##
##  <#GAPDoc Label="MatrixByBlockMatrix">
##  <ManSection>
##  <Attr Name="MatrixByBlockMatrix" Arg='blockmat'/>
##
##  <Description>
##  returns a plain ordinary matrix that is equal to the block matrix
##  <A>blockmat</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MatrixByBlockMatrix", IsMatrix );
#T ConvertToPlistRep?


#############################################################################
##
#F  AsBlockMatrix( <m>, <nrb>, <ncb> )  . . . create block matrix from matrix
##
##  <#GAPDoc Label="AsBlockMatrix">
##  <ManSection>
##  <Func Name="AsBlockMatrix" Arg='m, nrb, ncb'/>
##
##  <Description>
##  returns a block matrix with <A>nrb</A> row blocks and <A>ncb</A> column blocks
##  which is equal to the ordinary matrix <A>m</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AsBlockMatrix" );
#T ConvertToBlockMatrixRep?
