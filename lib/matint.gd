#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include A. Storjohann, R. Wainwright, A. Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for the operations of normal forms for
##  integral matrices.
##

#############################################################################
##
#V  InfoMatInt
##
##  <ManSection>
##  <InfoClass Name="InfoMatInt"/>
##
##  <Description>
##  The info class for Integer matrix operations is <C>InfoMatInt</C>.
##  </Description>
##  </ManSection>
##
DeclareInfoClass( "InfoMatInt" );

#############################################################################
##
#O  TriangulizedIntegerMat(<mat>)
##
##  <#GAPDoc Label="TriangulizedIntegerMat">
##  <ManSection>
##  <Oper Name="TriangulizedIntegerMat" Arg='mat'/>
##
##  <Description>
##  Computes an upper triangular form of a matrix with integer entries.
##  It returns a mutable matrix in upper triangular form.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("TriangulizedIntegerMat",[IsMatrix]);

#############################################################################
##
#O  TriangulizeIntegerMat(<mat>)
##
##  <#GAPDoc Label="TriangulizeIntegerMat">
##  <ManSection>
##  <Oper Name="TriangulizeIntegerMat" Arg='mat'/>
##
##  <Description>
##  Changes <A>mat</A> to be in upper triangular form.
##  (The result is the same as that of <Ref Oper="TriangulizedIntegerMat"/>,
##  but <A>mat</A> will be modified, thus using less memory.)
##  If <A>mat</A> is immutable an error will be triggered.
##  <Example><![CDATA[
##  gap> m:=[[1,15,28],[4,5,6],[7,8,9]];;
##  gap> TriangulizedIntegerMat(m);
##  [ [ 1, 15, 28 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ]
##  gap> n:=TriangulizedIntegerMatTransform(m);
##  rec( normal := [ [ 1, 15, 28 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ],
##    rank := 3, rowC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    rowQ := [ [ 1, 0, 0 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    rowtrans := [ [ 1, 0, 0 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    signdet := 1 )
##  gap> n.rowtrans*m=n.normal;
##  true
##  gap> TriangulizeIntegerMat(m); m;
##  [ [ 1, 15, 28 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("TriangulizeIntegerMat",[IsMatrix]);

#############################################################################
##
#O  TriangulizedIntegerMatTransform(<mat>)
##
##  <#GAPDoc Label="TriangulizedIntegerMatTransform">
##  <ManSection>
##  <Oper Name="TriangulizedIntegerMatTransform" Arg='mat'/>
##
##  <Description>
##  Computes an upper triangular form of a matrix with integer entries.
##  It returns a record with a component <C>normal</C> (an immutable matrix
##  in upper triangular form) and a component <C>rowtrans</C> that gives the
##  transformations done to the original matrix to bring it into upper
##  triangular form.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("TriangulizedIntegerMatTransform",[IsMatrix]);
DeclareSynonym("TriangulizedIntegerMatTransforms",
  TriangulizedIntegerMatTransform);

#############################################################################
##
#O  HermiteNormalFormIntegerMat(<mat>)
##
##  <#GAPDoc Label="HermiteNormalFormIntegerMat">
##  <ManSection>
##  <Oper Name="HermiteNormalFormIntegerMat" Arg='mat'/>
##
##  <Description>
##  This operation computes the Hermite normal form of a matrix <A>mat</A>
##  with integer entries. It returns a immutable matrix in HNF.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("HermiteNormalFormIntegerMat",[IsMatrix]);

#############################################################################
##
#O  HermiteNormalFormIntegerMatTransform(<mat>)
##
##  <#GAPDoc Label="HermiteNormalFormIntegerMatTransform">
##  <ManSection>
##  <Oper Name="HermiteNormalFormIntegerMatTransform" Arg='mat'/>
##
##  <Description>
##  This operation computes the Hermite normal form of a matrix <A>mat</A>
##  with integer entries.
##  It returns a record with components <C>normal</C> (a matrix <M>H</M>) and
##  <C>rowtrans</C> (a matrix <M>Q</M>) such that <M>Q A = H</M>.
##  <Example><![CDATA[
##  gap> m:=[[1,15,28],[4,5,6],[7,8,9]];;
##  gap> HermiteNormalFormIntegerMat(m);
##  [ [ 1, 0, 1 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ]
##  gap> n:=HermiteNormalFormIntegerMatTransform(m);
##  rec( normal := [ [ 1, 0, 1 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ], rank := 3,
##    rowC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    rowQ := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    rowtrans := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    signdet := 1 )
##  gap> n.rowtrans*m=n.normal;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("HermiteNormalFormIntegerMatTransform",[IsMatrix]);
DeclareSynonym("HermiteNormalFormIntegerMatTransforms",
  HermiteNormalFormIntegerMatTransform);


#############################################################################
##
#O  SmithNormalFormIntegerMat(<mat>)
##
##  <#GAPDoc Label="SmithNormalFormIntegerMat">
##  <ManSection>
##  <Oper Name="SmithNormalFormIntegerMat" Arg='mat'/>
##
##  <Description>
##  This operation computes the Smith normal form of a matrix <A>mat</A> with
##  integer entries. It returns a new immutable matrix in the Smith normal
##  form.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("SmithNormalFormIntegerMat",[IsMatrix]);

#############################################################################
##
#O  SmithNormalFormIntegerMatTransforms(<mat>)
##
##  <#GAPDoc Label="SmithNormalFormIntegerMatTransforms">
##  <ManSection>
##  <Oper Name="SmithNormalFormIntegerMatTransforms" Arg='mat'/>
##
##  <Description>
##  This operation computes the Smith normal form of a matrix <A>mat</A> with
##  integer entries.
##  It returns a record with components <C>normal</C> (a matrix <M>S</M>),
##  <C>rowtrans</C> (a matrix <M>P</M>),
##  and <C>coltrans</C> (a matrix <M>Q</M>) such that <M>P A Q = S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("SmithNormalFormIntegerMatTransforms",[IsMatrix]);


#############################################################################
##
#O  DiagonalizeIntMat(<mat>)
##
##  <#GAPDoc Label="DiagonalizeIntMat">
##  <ManSection>
##  <Func Name="DiagonalizeIntMat" Arg='mat'/>
##
##  <Description>
##  This function changes <A>mat</A> to its SNF.
##  (The result is the same as
##  that of <Ref Oper="SmithNormalFormIntegerMat"/>,
##  but <A>mat</A> will be modified, thus using less memory.)
##  If <A>mat</A> is immutable an error will be triggered.
##  <Example><![CDATA[
##  gap> m:=[[1,15,28],[4,5,6],[7,8,9]];;
##  gap> SmithNormalFormIntegerMat(m);
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 3 ] ]
##  gap> n:=SmithNormalFormIntegerMatTransforms(m);
##  rec( colC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    colQ := [ [ 1, 0, -1 ], [ 0, 1, -1 ], [ 0, 0, 1 ] ],
##    coltrans := [ [ 1, 0, -1 ], [ 0, 1, -1 ], [ 0, 0, 1 ] ],
##    normal := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 3 ] ], rank := 3,
##    rowC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    rowQ := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    rowtrans := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    signdet := 1 )
##  gap> n.rowtrans*m*n.coltrans=n.normal;
##  true
##  gap> DiagonalizeIntMat(m);m;
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DiagonalizeIntMat" );

#############################################################################
##
#O  NormalFormIntMat(<mat>, <options>)
##
##  <#GAPDoc Label="NormalFormIntMat">
##  <ManSection>
##  <Func Name="NormalFormIntMat" Arg='mat, options'/>
##
##  <Description>
##  This general operation for computation of various Normal Forms
##  is probably the most efficient.
##  <P/>
##  Options bit values:
##  <List>
##  <Mark>0/1</Mark>
##  <Item>
##   Triangular Form / Smith Normal Form.
##  </Item>
##  <Mark>2</Mark>
##  <Item>
##     Reduce off diagonal entries.
##  </Item>
##  <Mark>4</Mark>
##  <Item>
##     Row Transformations.
##  </Item>
##  <Mark>8</Mark>
##  <Item>
##     Col Transformations.
##  </Item>
##  <Mark>16</Mark>
##  <Item>
##     Destructive (the original matrix may be destroyed)
##  </Item>
##  </List>
##  <P/>
##  Compute a Triangular, Hermite or Smith form of the <M>n \times m</M>
##  integer input matrix <M>A</M>.  Optionally, compute <M>n \times n</M> and
##  <M>m \times m</M> unimodular transforming matrices <M>Q, P</M>
##  which satisfy  <M>Q A = H</M> or <M>Q A P = S</M>.
##  <!-- %The routines used are based on work by Arne Storjohann -->
##  <!-- %and were implemented in &GAP;&nbsp;4 by A.&nbsp;Storjohann and R.&nbsp;Wainwright. -->
##  <P/>
##  Note option is a value ranging from 0 to 15 but not all options make sense
##  (e.g., reducing off diagonal entries with SNF option selected already).
##  If an option makes no sense it is ignored.
##  <P/>
##  Returns a record with component <C>normal</C> containing the
##  computed normal form and optional components <C>rowtrans</C>
##  and/or <C>coltrans</C> which hold the respective transformation matrix.
##  Also in the record are components holding the sign of the determinant,
##  <C>signdet</C>, and the rank of the matrix, <C>rank</C>.
##  <Example><![CDATA[
##  gap> m:=[[1,15,28],[4,5,6],[7,8,9]];;
##  gap> NormalFormIntMat(m,0);  # Triangular, no transforms
##  rec( normal := [ [ 1, 15, 28 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ],
##    rank := 3, signdet := 1 )
##  gap> NormalFormIntMat(m,6);  # Hermite Normal Form with row transforms
##  rec( normal := [ [ 1, 0, 1 ], [ 0, 1, 1 ], [ 0, 0, 3 ] ], rank := 3,
##    rowC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    rowQ := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    rowtrans := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    signdet := 1 )
##  gap> NormalFormIntMat(m,13); # Smith Normal Form with both transforms
##  rec( colC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    colQ := [ [ 1, 0, -1 ], [ 0, 1, -1 ], [ 0, 0, 1 ] ],
##    coltrans := [ [ 1, 0, -1 ], [ 0, 1, -1 ], [ 0, 0, 1 ] ],
##    normal := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 3 ] ], rank := 3,
##    rowC := [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    rowQ := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    rowtrans := [ [ -2, 62, -35 ], [ 1, -30, 17 ], [ -3, 97, -55 ] ],
##    signdet := 1 )
##  gap> last.rowtrans*m*last.coltrans;
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NormalFormIntMat");

#############################################################################
##
#A  BaseIntMat( <mat> )
##
##  <#GAPDoc Label="BaseIntMat">
##  <ManSection>
##  <Attr Name="BaseIntMat" Arg='mat'/>
##
##  <Description>
##  If <A>mat</A> is a matrix with integral entries, this function returns a
##  list of vectors that forms a basis of the integral row space of <A>mat</A>,
##  i.e. of the set of integral linear combinations of the rows of <A>mat</A>.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,7],[4,5,6],[10,11,19]];;
##  gap> BaseIntMat(mat);
##  [ [ 1, 2, 7 ], [ 0, 3, 7 ], [ 0, 0, 15 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BaseIntMat",
  IsMatrix and IsCyclotomicCollColl );

#############################################################################
##
#A  BaseIntersectionIntMats( <m>,<n> )
##
##  <#GAPDoc Label="BaseIntersectionIntMats">
##  <ManSection>
##  <Oper Name="BaseIntersectionIntMats" Arg='m,n'/>
##
##  <Description>
##  If <A>m</A> and <A>n</A> are matrices with integral entries,
##  this function returns a list of vectors that forms a basis of the
##  intersection of the integral row spaces of <A>m</A> and <A>n</A>.
##  <Example><![CDATA[
##  gap> nat:=[[5,7,2],[4,2,5],[7,1,4]];;
##  gap> BaseIntMat(nat);
##  [ [ 1, 1, 15 ], [ 0, 2, 55 ], [ 0, 0, 64 ] ]
##  gap> BaseIntersectionIntMats(mat,nat);
##  [ [ 1, 5, 509 ], [ 0, 6, 869 ], [ 0, 0, 960 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "BaseIntersectionIntMats",
  [IsMatrix and IsCyclotomicCollColl,
   IsMatrix and IsCyclotomicCollColl] );

#############################################################################
##
#A  ComplementIntMat( <full>, <sub> )
##
##  <#GAPDoc Label="ComplementIntMat">
##  <ManSection>
##  <Oper Name="ComplementIntMat" Arg='full, sub'/>
##
##  <Description>
##  Let <A>full</A> be a list of integer vectors generating an integral row
##  module <M>M</M> and <A>sub</A> a list of vectors defining a submodule
##  <M>S</M> of <M>M</M>.
##  This function computes a free basis for <M>M</M> that extends <M>S</M>.
##  I.e., if the dimension of <M>S</M> is <M>n</M> it
##  determines a basis
##  <M>B = \{ b_1, \ldots, b_m \}</M> for <M>M</M>,
##  as well as <M>n</M> integers <M>x_i</M> such that the <M>n</M> vectors
##  <M>s_i:= x_i \cdot b_i</M> form a basis for <M>S</M>.
##  <P/>
##  It returns a record with the following components:
##  <List>
##  <Mark><C>complement</C></Mark>
##  <Item>
##     the vectors <M>b_{{n+1}}</M> up to <M>b_m</M>
##     (they generate a complement to <M>S</M>).
##  </Item>
##  <Mark><C>sub</C></Mark>
##  <Item>
##     the vectors <M>s_i</M> (a basis for <M>S</M>).
##  </Item>
##  <Mark><C>moduli</C></Mark>
##  <Item>
##     the factors <M>x_i</M>.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> m:=IdentityMat(3);;
##  gap> n:=[[1,2,3],[4,5,6]];;
##  gap> ComplementIntMat(m,n);
##  rec( complement := [ [ 0, 0, 1 ] ], moduli := [ 1, 3 ],
##    sub := [ [ 1, 2, 3 ], [ 0, 3, 6 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ComplementIntMat",
  [IsMatrix and IsCyclotomicCollColl,
   IsMatrix and IsCyclotomicCollColl] );

#############################################################################
##
#A  NullspaceIntMat( <mat> )
##
##  <#GAPDoc Label="NullspaceIntMat">
##  <ManSection>
##  <Attr Name="NullspaceIntMat" Arg='mat'/>
##
##  <Description>
##  If <A>mat</A> is a matrix with integral entries, this function returns a
##  list of vectors that forms a basis of the integral nullspace of
##  <A>mat</A>, i.e., of those vectors in the nullspace of <A>mat</A> that
##  have integral entries.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,7],[4,5,6],[7,8,9],[10,11,19],[5,7,12]];;
##  gap> NullspaceMat(mat);
##  [ [ -7/4, 9/2, -15/4, 1, 0 ], [ -3/4, -3/2, 1/4, 0, 1 ] ]
##  gap> NullspaceIntMat(mat);
##  [ [ 1, 18, -9, 2, -6 ], [ 0, 24, -13, 3, -7 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NullspaceIntMat",
  IsMatrix and IsCyclotomicCollColl );

#############################################################################
##
#O  SolutionIntMat( <mat>, <vec> )
##
##  <#GAPDoc Label="SolutionIntMat">
##  <ManSection>
##  <Oper Name="SolutionIntMat" Arg='mat, vec'/>
##
##  <Description>
##  If <A>mat</A> is a matrix with integral entries and <A>vec</A> a vector
##  with integral entries, this function returns a vector <M>x</M> with
##  integer entries that is a solution of the equation
##  <M>x</M> <C>* <A>mat</A> = <A>vec</A></C>.
##  It returns <K>fail</K> if no such vector exists.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,7],[4,5,6],[7,8,9],[10,11,19],[5,7,12]];;
##  gap> SolutionMat(mat,[95,115,182]);
##  [ 47/4, -17/2, 67/4, 0, 0 ]
##  gap> SolutionIntMat(mat,[95,115,182]);
##  [ 2285, -5854, 4888, -1299, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SolutionIntMat",
  [IsMatrix and IsCyclotomicCollColl,
    IsList and IsCyclotomicCollection]);

#############################################################################
##
#O  SolutionNullspaceIntMat( <mat>,<vec> )
##
##  <#GAPDoc Label="SolutionNullspaceIntMat">
##  <ManSection>
##  <Oper Name="SolutionNullspaceIntMat" Arg='mat,vec'/>
##
##  <Description>
##  This function returns a list of length two, its first entry being the
##  result of a call to <Ref Oper="SolutionIntMat"/> with same arguments,
##  the second the result of <Ref Attr="NullspaceIntMat"/> applied to the
##  matrix <A>mat</A>.
##  The calculation is performed faster than if two separate calls would be
##  used.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,7],[4,5,6],[7,8,9],[10,11,19],[5,7,12]];;
##  gap> SolutionNullspaceIntMat(mat,[95,115,182]);
##  [ [ 2285, -5854, 4888, -1299, 0 ],
##    [ [ 1, 18, -9, 2, -6 ], [ 0, 24, -13, 3, -7 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SolutionNullspaceIntMat",
  [IsMatrix and IsCyclotomicCollColl,
    IsList and IsCyclotomicCollection]);

#############################################################################
##
#A  AbelianInvariantsOfList( <list> ) . . . . .  abelian invariants of a list
##
##  <#GAPDoc Label="AbelianInvariantsOfList">
##  <ManSection>
##  <Attr Name="AbelianInvariantsOfList" Arg='list'/>
##
##  <Description>
##  Given a list of nonnegative integers, this routine returns a sorted
##  list containing the prime power factors of the positive entries in the
##  original list, as well as all zeroes of the original list.
##  <Example><![CDATA[
##  gap> AbelianInvariantsOfList([4,6,2,0,12]);
##  [ 0, 2, 2, 3, 3, 4, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AbelianInvariantsOfList", IsCyclotomicCollection );

#############################################################################
##
#O  DeterminantIntMat(<mat>)
##
##  <#GAPDoc Label="DeterminantIntMat">
##  <ManSection>
##  <Func Name="DeterminantIntMat" Arg='mat'/>
##
##  <Description>
##  <Index Subkey="integer matrix">determinant</Index>
##  Computes the determinant of an integer matrix using the
##  same strategy as <Ref Func="NormalFormIntMat"/>.
##  This method is
##  faster in general for matrices greater than <M>20 \times 20</M> but
##  quite a lot slower for smaller matrices.  It therefore passes
##  the work to the more general <Ref Attr="DeterminantMat"/>
##  for these smaller matrices.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DeterminantIntMat");

# ``technical'' routines.

#############################################################################
##
#O  SNFofREF(<mat>,<destroy>)
##
##  <ManSection>
##  <Oper Name="SNFofREF" Arg='mat,destroy'/>
##
##  <Description>
##  Computes the Smith Normal Form of an integer matrix in row echelon
##  (RE) form.
##  If <A>destroy</A> is set to <K>true</K> <A>mat</A> will be changed in-place.
##  Caveat
##  &ndash;No testing is done to ensure that <A>mat</A> is in RE form.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SNFofREF");

#############################################################################
##
#O  ReducedRelationMat(<mat>)
##
##  <#GAPDoc Label="ReducedRelationMat">
##  <ManSection>
##  <Func Name="ReducedRelationMat" Arg='mat'/>
##
##  <Description>
##  Let <A>mat</A> be a matrix that has been obtained as abelianized
##  relations. Such matrices tend to have a particular form with some short
##  vectors. This function runs a (quick) heuristic row reduction,
##  resulting in a matrix with the same Z-row space but fewer/shorter vectors,
##  thus speeding up a subsequent SNF. It does not do a full HNF but should be
##  much quicker.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ReducedRelationMat");
