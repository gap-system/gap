#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler, Alexander Hulpke, Heiko Theißen, Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains those functions that mainly deal with matrices.
##


#############################################################################
##
#V  InfoMatrix
##
##  <#GAPDoc Label="InfoMatrix">
##  <ManSection>
##  <InfoClass Name="InfoMatrix"/>
##
##  <Description>
##  The info class for matrix operations is <Ref InfoClass="InfoMatrix"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoMatrix" );

#############################################################################
##
#F  PrintArray( <array> )
##
##  <#GAPDoc Label="PrintArray">
##  <ManSection>
##  <Func Name="PrintArray" Arg='array'/>
##
##  <Description>
##  pretty-prints the array <A>array</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PrintArray");

#############################################################################
##
#P  IsGeneralizedCartanMatrix( <A> )
##
##  <ManSection>
##  <Prop Name="IsGeneralizedCartanMatrix" Arg='A'/>
##
##  <Description>
##  The square matrix <A>A</A> is a generalized Cartan Matrix if and only if
##  1. <C>A[i,i] = 2</C> for all <M>i</M>,
##  2. <C>A[i,j]</C> are nonpositive integers for <M>i \neq j</M>,
##  3. <C>A[i,j] = 0</C> implies <C>A[j,i] = 0</C>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsGeneralizedCartanMatrix", IsMatrixOrMatrixObj );


#############################################################################
##
#P  IsDiagonalMatrix( <mat> )
#P  IsDiagonalMat( <mat> )
##
##  <#GAPDoc Label="IsDiagonalMat">
##  <ManSection>
##  <Prop Name="IsDiagonalMatrix" Arg='mat'/>
##  <Prop Name="IsDiagonalMat" Arg='mat'/>
##
##  <Description>
##  return <K>true</K> if the matrix <A>mat</A> has only zero entries
##  off the main diagonal, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> IsDiagonalMatrix( [ [ 1 ] ] );
##  true
##  gap> IsDiagonalMatrix( [ [ 1, 0, 0 ], [ 0, 1, 0 ] ] );
##  true
##  gap> IsDiagonalMatrix( [ [ 0, 1 ], [ 1, 0 ] ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsDiagonalMatrix", IsMatrixOrMatrixObj );

DeclareSynonym( "IsDiagonalMat", IsDiagonalMatrix );


#############################################################################
##
#P  IsUpperTriangularMatrix( <mat> )
#P  IsUpperTriangularMat( <mat> )
##
##  <#GAPDoc Label="IsUpperTriangularMat">
##  <ManSection>
##  <Prop Name="IsUpperTriangularMatrix" Arg='mat'/>
##  <Prop Name="IsUpperTriangularMat" Arg='mat'/>
##
##  <Description>
##  return <K>true</K> if the matrix <A>mat</A> has only zero entries below
##  the main diagonal, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> IsUpperTriangularMatrix( [ [ 1 ] ] );
##  true
##  gap> IsUpperTriangularMatrix( [ [ 1, 2, 3 ], [ 0, 5, 6 ] ] );
##  true
##  gap> IsUpperTriangularMatrix( [ [ 0, 1 ], [ 1, 0 ] ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsUpperTriangularMatrix", IsMatrixOrMatrixObj );

DeclareSynonym( "IsUpperTriangularMat", IsUpperTriangularMatrix );


#############################################################################
##
#P  IsLowerTriangularMatrix( <mat> )
#P  IsLowerTriangularMat( <mat> )
##
##  <#GAPDoc Label="IsLowerTriangularMat">
##  <ManSection>
##  <Prop Name="IsLowerTriangularMatrix" Arg='mat'/>
##  <Prop Name="IsLowerTriangularMat" Arg='mat'/>
##
##  <Description>
##  return <K>true</K> if the matrix <A>mat</A> has only zero entries above
##  the main diagonal, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> IsLowerTriangularMatrix( [ [ 1 ] ] );
##  true
##  gap> IsLowerTriangularMatrix( [ [ 1, 0, 0 ], [ 2, 3, 0 ] ] );
##  true
##  gap> IsLowerTriangularMatrix( [ [ 0, 1 ], [ 1, 0 ] ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsLowerTriangularMatrix", IsMatrixOrMatrixObj );

DeclareSynonym( "IsLowerTriangularMat", IsLowerTriangularMatrix );


#############################################################################
##
#F  DiagonalOfMatrix( <mat> )
#F  DiagonalOfMat( <mat> )
##
##  <#GAPDoc Label="DiagonalOfMat">
##  <ManSection>
##  <Func Name="DiagonalOfMatrix" Arg='mat'/>
##  <Func Name="DiagonalOfMat" Arg='mat'/>
##
##  <Description>
##  return the diagonal of the matrix <A>mat</A>. If <A>mat</A> is not a
##  square matrix, then the result has the same length as the rows of
##  <A>mat</A>, and is padded with zeros if <A>mat</A> has fewer rows than
##  columns.
##  <Example><![CDATA[
##  gap> DiagonalOfMatrix( [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] );
##  [ 1, 5, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DiagonalOfMatrix" );

DeclareSynonym( "DiagonalOfMat", DiagonalOfMatrix );


#############################################################################
##
#A  BaseMat( <mat> )  . . . . . . . . . .  base for the row space of a matrix
##
##  <#GAPDoc Label="BaseMat">
##  <ManSection>
##  <Attr Name="BaseMat" Arg='mat'/>
##
##  <Description>
##  returns a basis for the row space generated by the rows of <A>mat</A> in the
##  form of an immutable matrix.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BaseMat", IsMatrix );

#############################################################################
##
#O  BaseMatDestructive( <mat> )
##
##  <#GAPDoc Label="BaseMatDestructive">
##  <ManSection>
##  <Oper Name="BaseMatDestructive" Arg='mat'/>
##
##  <Description>
##  Does the same as <Ref Attr="BaseMat"/>, with the difference that it may destroy
##  the matrix <A>mat</A>. The matrix <A>mat</A> must be mutable.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> BaseMat(mat);
##  [ [ 1, 2, 3 ], [ 0, 1, 2 ] ]
##  gap> mm:= [[1,2,3],[4,5,6],[5,7,9]];;
##  gap> BaseMatDestructive( mm );
##  [ [ 1, 2, 3 ], [ 0, 1, 2 ] ]
##  gap> mm;
##  [ [ 1, 2, 3 ], [ 0, 1, 2 ], [ 0, 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "BaseMatDestructive", [ IsMatrix ] );

#############################################################################
##
#A  BaseOrthogonalSpaceMat( <mat> )
##
##  <#GAPDoc Label="BaseOrthogonalSpaceMat">
##  <ManSection>
##  <Attr Name="BaseOrthogonalSpaceMat" Arg='mat'/>
##
##  <Description>
##  Let <M>V</M> be the row space generated  by the rows of  <A>mat</A> (over any field
##  that contains all  entries of <A>mat</A>).  <C>BaseOrthogonalSpaceMat( <A>mat</A>  )</C>
##  computes a base of the orthogonal space of <M>V</M>.
##  <P/>
##  The rows of <A>mat</A> need not be linearly independent.
##  <P/>
##  <!-- Note that this means to transpose twice ...-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BaseOrthogonalSpaceMat", IsMatrix );


#############################################################################
##
#A  DefaultFieldOfMatrix( <mat> )
##
##  <#GAPDoc Label="DefaultFieldOfMatrix">
##  <ManSection>
##  <Attr Name="DefaultFieldOfMatrix" Arg='mat'/>
##
##  <Description>
##  For a matrix <A>mat</A>, <Ref Attr="DefaultFieldOfMatrix"/> returns either a field
##  (not necessarily the smallest one) containing all entries of <A>mat</A>,
##  or <K>fail</K>.
##  <P/>
##  If <A>mat</A> is a matrix of finite field elements or a matrix of cyclotomics,
##  <Ref Attr="DefaultFieldOfMatrix"/> returns the default field generated by the matrix
##  entries (see&nbsp;<Ref Sect="Creating Finite Fields"/> and <Ref Sect="Operations for Cyclotomics"/>).
##  <Example><![CDATA[
##  gap> DefaultFieldOfMatrix([[Z(4),Z(8)]]);
##  GF(2^6)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DefaultFieldOfMatrix", IsMatrix );


#############################################################################
##
#A  DepthOfUpperTriangularMatrix( <mat> )
##
##  <#GAPDoc Label="DepthOfUpperTriangularMatrix">
##  <ManSection>
##  <Attr Name="DepthOfUpperTriangularMatrix" Arg='mat'/>
##
##  <Description>
##  If <A>mat</A> is an upper triangular matrix this attribute returns the
##  index of the first nonzero diagonal.
##  <Example><![CDATA[
##  gap> DepthOfUpperTriangularMatrix([[0,1,2],[0,0,1],[0,0,0]]);
##  1
##  gap> DepthOfUpperTriangularMatrix([[0,0,2],[0,0,0],[0,0,0]]);
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DepthOfUpperTriangularMatrix", IsMatrix );


#############################################################################
##
#A  DeterminantMatrix( <mat> )  . . . . . . . . . . . determinant of a matrix
#A  DeterminantMat( <mat> ) . . . . . . . . . . . . . determinant of a matrix
#O  Determinant( <mat> )
##
##  <#GAPDoc Label="DeterminantMat">
##  <ManSection>
##  <Attr Name="DeterminantMatrix" Arg='mat'/>
##  <Attr Name="DeterminantMat" Arg='mat'/>
##  <Oper Name="Determinant" Arg='mat'/>
##
##  <Description>
##  returns the determinant of the square matrix <A>mat</A>.
##  <P/>
##  These methods assume implicitly that <A>mat</A> is defined over an
##  integral domain whose quotient field is implemented in &GAP;. For
##  matrices defined over an arbitrary commutative ring with one
##  see&nbsp;<Ref Oper="DeterminantMatDivFree"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DeterminantMatrix", IsMatrixOrMatrixObj );
DeclareSynonymAttr( "DeterminantMat", DeterminantMatrix );


#############################################################################
##
#O  DeterminantMatrixDestructive( <mat> )
#O  DeterminantMatDestructive( <mat> )
##
##  <#GAPDoc Label="DeterminantMatDestructive">
##  <ManSection>
##  <Oper Name="DeterminantMatrixDestructive" Arg='mat'/>
##  <Oper Name="DeterminantMatDestructive" Arg='mat'/>
##
##  <Description>
##  Does the same as <Ref Attr="DeterminantMatrix"/>,
##  with the difference that it may
##  destroy its argument. The matrix <A>mat</A> must be mutable.
##  <Example><![CDATA[
##  gap> DeterminantMatrix([[1,2],[2,1]]);
##  -3
##  gap> mm:= [[1,2],[2,1]];;
##  gap> DeterminantMatrixDestructive( mm );
##  -3
##  gap> mm;
##  [ [ 1, 2 ], [ 0, -3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DeterminantMatrixDestructive",
    [ IsMatrixOrMatrixObj and IsMutable] );
DeclareSynonym( "DeterminantMatDestructive", DeterminantMatrixDestructive );


#############################################################################
##
#O  DeterminantMatrixDivFree( <mat> )
#O  DeterminantMatDivFree( <mat> )
##
##  <#GAPDoc Label="DeterminantMatDivFree">
##  <ManSection>
##  <Oper Name="DeterminantMatrixDivFree" Arg='mat'/>
##  <Oper Name="DeterminantMatDivFree" Arg='mat'/>
##
##  <Description>
##  return the determinant of a square matrix <A>mat</A> over an arbitrary
##  commutative ring with one using the division free method of
##  Mahajan and Vinay <Cite Key="MV97"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DeterminantMatrixDivFree", [ IsMatrixOrMatrixObj ] );
DeclareSynonym( "DeterminantMatDivFree", DeterminantMatrixDivFree );


#############################################################################
##
#A  DimensionsMat( <mat> )  . . . . . . . . . . . . .  dimensions of a matrix
##
##  <#GAPDoc Label="DimensionsMat">
##  <ManSection>
##  <Attr Name="DimensionsMat" Arg='mat'/>
##
##  <Description>
##  is a list of length 2, the first being the number of rows, the second
##  being the number of columns of the matrix <A>mat</A>. If <A>mat</A> is
##  malformed, that is, it is not a <Ref Prop="IsRectangularTable"/>,
##  returns <K>fail</K>.
##  <Example><![CDATA[
##  gap> DimensionsMat([[1,2,3],[4,5,6]]);
##  [ 2, 3 ]
##  gap> DimensionsMat([[1,2,3],[4,5]]);
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DimensionsMat", IsMatrix );


#############################################################################
##
#O  ElementaryDivisorsMat([<ring>,] <mat>)
#F  ElementaryDivisorsMatDestructive(<ring>,<mat>)
##
##  <#GAPDoc Label="ElementaryDivisorsMat">
##  <ManSection>
##  <Oper Name="ElementaryDivisorsMat" Arg='[ring,] mat'/>
##  <Func Name="ElementaryDivisorsMatDestructive" Arg='ring,mat'/>
##
##  <Description>
##  returns a list of the elementary divisors, i.e., the
##  unique <M>d</M> with <M>d[i]</M> divides  <M>d[i+1]</M> and <A>mat</A> is  equivalent
##  to a diagonal matrix with the elements <M>d[i]</M> on the diagonal.
##  The operations are performed over the euclidean
##  ring <A>ring</A>, which must contain
##  all matrix entries. For compatibility reasons it can be omitted and
##  defaults to the <Ref Func="DefaultRing" Label="for ring elements"/> of the matrix entries.
##  <P/>
##  The function <Ref Func="ElementaryDivisorsMatDestructive"/> produces the same result
##  but in the process may destroy the contents of <A>mat</A>.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> ElementaryDivisorsMat(mat);
##  [ 1, 3, 0 ]
##  gap> x:=Indeterminate(Rationals,"x");;
##  gap> mat:=mat*One(x)-x*mat^0;
##  [ [ -x+1, 2, 3 ], [ 4, -x+5, 6 ], [ 7, 8, -x+9 ] ]
##  gap> ElementaryDivisorsMat(PolynomialRing(Rationals,1),mat);
##  [ 1, 1, x^3-15*x^2-18*x ]
##  gap> mat:=KroneckerProduct(CompanionMat((x-1)^2),
##  >                          CompanionMat((x^3-1)*(x-1)));;
##  gap> mat:=mat*One(x)-x*mat^0;
##  [ [ -x, 0, 0, 0, 0, 0, 0, 1 ], [ 0, -x, 0, 0, -1, 0, 0, -1 ],
##    [ 0, 0, -x, 0, 0, -1, 0, 0 ], [ 0, 0, 0, -x, 0, 0, -1, -1 ],
##    [ 0, 0, 0, -1, -x, 0, 0, -2 ], [ 1, 0, 0, 1, 2, -x, 0, 2 ],
##    [ 0, 1, 0, 0, 0, 2, -x, 0 ], [ 0, 0, 1, 1, 0, 0, 2, -x+2 ] ]
##  gap> ElementaryDivisorsMat(PolynomialRing(Rationals,1),mat);
##  [ 1, 1, 1, 1, 1, 1, x-1, x^7-x^6-2*x^4+2*x^3+x-1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ElementaryDivisorsMat", [IsRing,IsMatrix] );
DeclareGlobalFunction( "ElementaryDivisorsMatDestructive" );

#############################################################################
##
#O  ElementaryDivisorsTransformationsMat([<ring>,] <mat>)
#F  ElementaryDivisorsTransformationsMatDestructive(<ring>,<mat>)
##
##  <#GAPDoc Label="ElementaryDivisorsTransformationsMat">
##  <ManSection>
##  <Oper Name="ElementaryDivisorsTransformationsMat" Arg='[ring,] mat'/>
##  <Func Name="ElementaryDivisorsTransformationsMatDestructive" Arg='ring,mat'/>
##
##  <Description>
##  <C>ElementaryDivisorsTransformations</C>, in addition to the tasks done
##  by <C>ElementaryDivisorsMat</C>, also calculates transforming matrices.
##  It returns a record with components <C>normal</C> (a matrix <M>S</M>),
##  <C>rowtrans</C> (a matrix <M>P</M>),
##  and <C>coltrans</C> (a matrix <M>Q</M>) such that <M>P A Q = S</M>.
##  The operations are performed over the euclidean ring
##  <A>ring</A>, which must contain
##  all matrix entries. For compatibility reasons it can be omitted and
##  defaults to the <Ref Func="DefaultRing" Label="for ring elements"/> of the matrix entries.
##  <P/>
##  The function <Ref Func="ElementaryDivisorsTransformationsMatDestructive"/>
##  produces the same result
##  but in the process destroys the contents of <A>mat</A>.
##  <Example><![CDATA[
##  gap> mat:=KroneckerProduct(CompanionMat((x-1)^2),CompanionMat((x^3-1)*(x-1)));;
##  gap> mat:=mat*One(x)-x*mat^0;
##  [ [ -x, 0, 0, 0, 0, 0, 0, 1 ], [ 0, -x, 0, 0, -1, 0, 0, -1 ],
##    [ 0, 0, -x, 0, 0, -1, 0, 0 ], [ 0, 0, 0, -x, 0, 0, -1, -1 ],
##    [ 0, 0, 0, -1, -x, 0, 0, -2 ], [ 1, 0, 0, 1, 2, -x, 0, 2 ],
##    [ 0, 1, 0, 0, 0, 2, -x, 0 ], [ 0, 0, 1, 1, 0, 0, 2, -x+2 ] ]
##  gap> t:=ElementaryDivisorsTransformationsMat(PolynomialRing(Rationals,1),mat);
##  rec( coltrans := [ [ 0, 0, 0, 0, 0, 0, 1/6*x^2-7/9*x-1/18, -3*x^3-x^2-x-1 ],
##        [ 0, 0, 0, 0, 0, 0, -1/6*x^2+x-1, 3*x^3-3*x^2 ],
##        [ 0, 0, 0, 0, 0, 1, -1/18*x^4+1/3*x^3-1/3*x^2-1/9*x, x^5-x^4+2*x^2-2*x
##           ], [ 0, 0, 0, 0, -1, 0, -1/9*x^3+1/2*x^2+1/9*x, 2*x^4+x^3+x^2+2*x ],
##        [ 0, -1, 0, 0, 0, 0, -2/9*x^2+19/18*x, 4*x^3+x^2+x ],
##        [ 0, 0, -1, 0, 0, -x, 1/18*x^5-1/3*x^4+1/3*x^3+1/9*x^2,
##            -x^6+x^5-2*x^3+2*x^2 ],
##        [ 0, 0, 0, -1, x, 0, 1/9*x^4-2/3*x^3+2/3*x^2+1/18*x,
##            -2*x^5+2*x^4-x^2+x ],
##        [ 1, 0, 0, 0, 0, 0, 1/6*x^3-7/9*x^2-1/18*x, -3*x^4-x^3-x^2-x ] ],
##    normal := [ [ 1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0 ],
##        [ 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0 ],
##        [ 0, 0, 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0, 0 ],
##        [ 0, 0, 0, 0, 0, 0, x-1, 0 ],
##        [ 0, 0, 0, 0, 0, 0, 0, x^7-x^6-2*x^4+2*x^3+x-1 ] ],
##    rowtrans := [ [ 1, 0, 0, 0, 0, 0, 0, 0 ], [ 1, 1, 0, 0, 0, 0, 0, 0 ],
##        [ 0, 0, 1, 0, 0, 0, 0, 0 ], [ 1, 0, 0, 1, 0, 0, 0, 0 ],
##        [ -x+2, -x, 0, 0, 1, 0, 0, 0 ],
##        [ 2*x^2-4*x+2, 2*x^2-x, 0, 2, -2*x+1, 0, 0, 1 ],
##        [ 3*x^3-6*x^2+3*x, 3*x^3-2*x^2, 2, 3*x, -3*x^2+2*x, 0, 1, 2*x ],
##        [ 1/6*x^8-7/6*x^7+2*x^6-4/3*x^5+7/3*x^4-4*x^3+13/6*x^2-7/6*x+2,
##            1/6*x^8-17/18*x^7+13/18*x^6-5/18*x^5+35/18*x^4-31/18*x^3+1/9*x^2-x+\
##  2, 1/9*x^5-5/9*x^4+1/9*x^3-1/9*x^2+14/9*x-1/9,
##            1/6*x^6-5/6*x^5+1/6*x^4-1/6*x^3+11/6*x^2-1/6*x,
##            -1/6*x^7+17/18*x^6-13/18*x^5+5/18*x^4-35/18*x^3+31/18*x^2-1/9*x+1,
##            1, 1/18*x^5-5/18*x^4+1/18*x^3-1/18*x^2+23/18*x-1/18,
##            1/9*x^6-5/9*x^5+1/9*x^4-1/9*x^3+14/9*x^2-1/9*x ] ] )
##  gap> t.rowtrans*mat*t.coltrans;
##  [ [ 1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0 ],
##    [ 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0 ],
##    [ 0, 0, 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0, 0 ],
##    [ 0, 0, 0, 0, 0, 0, x-1, 0 ],
##    [ 0, 0, 0, 0, 0, 0, 0, x^7-x^6-2*x^4+2*x^3+x-1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ElementaryDivisorsTransformationsMat", [IsRing,IsMatrix] );
DeclareGlobalFunction( "ElementaryDivisorsTransformationsMatDestructive" );

#############################################################################
##
#O  TriangulizedNullspaceMatNT(<mat>)
##
##  <ManSection>
##  <Oper Name="TriangulizedNullspaceMatNT" Arg='mat'/>
##
##  <Description>
##  This returns the triangulized nullspace of the matrix <A>mat</A>, without
##  transposing it. This is used in <C>TriangulizedNullspaceMat</C>, and
##  <C>TriangulizedNullspaceMatDestructive</C>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "TriangulizedNullspaceMatNT", [ IsMatrix ] );


#############################################################################
##
#A  NullspaceMat( <mat> ) . . . . . . basis of solutions of <vec> * <mat> = 0
#A  TriangulizedNullspaceMat(<mat>)
##
##  <#GAPDoc Label="NullspaceMat">
##  <ManSection>
##  <Attr Name="NullspaceMat" Arg='mat'/>
##  <Attr Name="TriangulizedNullspaceMat" Arg='mat'/>
##
##  <Description>
##  <Index Subkey="of a matrix">kernel</Index>
##  returns a list of row vectors that form a basis of the vector space of
##  solutions to the equation <C><A>vec</A>*<A>mat</A>=0</C>.
##  The result is an immutable matrix.
##  This basis is not guaranteed to be in any specific form.
##  <P/>
##  The variant <Ref Attr="TriangulizedNullspaceMat"/> returns a basis of the
##  nullspace in triangulized form as is often needed for algorithms.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NullspaceMat", IsMatrix );
DeclareAttribute( "TriangulizedNullspaceMat", IsMatrix );


#############################################################################
##
#O  NullspaceMatDestructive( <mat> )
#O  TriangulizedNullspaceMatDestructive(<mat>)
##
##  <#GAPDoc Label="NullspaceMatDestructive">
##  <ManSection>
##  <Oper Name="NullspaceMatDestructive" Arg='mat'/>
##  <Oper Name="TriangulizedNullspaceMatDestructive" Arg='mat'/>
##
##  <Description>
##  This function does the same as <Ref Attr="NullspaceMat"/>.
##  However, the latter function makes a copy of <A>mat</A> to avoid having
##  to change it.
##  This function does not do that; it returns the nullspace and may destroy
##  <A>mat</A>;
##  this saves a lot of memory in case <A>mat</A> is big.
##  The matrix <A>mat</A> must be mutable.
##  <P/>
##  The variant <Ref Oper="TriangulizedNullspaceMatDestructive"/> returns a
##  basis of the nullspace in triangulized form.
##  It may destroy the matrix <A>mat</A>.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> NullspaceMat(mat);
##  [ [ 1, -2, 1 ] ]
##  gap> mm:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> NullspaceMatDestructive( mm );
##  [ [ 1, -2, 1 ] ]
##  gap> mm;
##  [ [ 1, 2, 3 ], [ 0, -3, -6 ], [ 0, 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NullspaceMatDestructive", [ IsMatrix and IsMutable] );
DeclareOperation( "TriangulizedNullspaceMatDestructive", [ IsMatrix and IsMutable] );


#############################################################################
##
#O  GeneralisedEigenvalues( <F>, <A> )
#O  GeneralizedEigenvalues( <F>, <A> )
##
##  <#GAPDoc Label="GeneralisedEigenvalues">
##  <ManSection>
##  <Oper Name="GeneralisedEigenvalues" Arg='F, A'/>
##  <Oper Name="GeneralizedEigenvalues" Arg='F, A'/>
##
##  <Description>
##  The generalised eigenvalues of the matrix <A>A</A> over the field <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GeneralisedEigenvalues", [ IsRing, IsMatrixOrMatrixObj ] );
DeclareSynonym( "GeneralizedEigenvalues", GeneralisedEigenvalues );

#############################################################################
##
#O  GeneralisedEigenspaces( <F>, <A> )
#O  GeneralizedEigenspaces( <F>, <A> )
##
##  <#GAPDoc Label="GeneralisedEigenspaces">
##  <ManSection>
##  <Oper Name="GeneralisedEigenspaces" Arg='F, A'/>
##  <Oper Name="GeneralizedEigenspaces" Arg='F, A'/>
##
##  <Description>
##  The generalised eigenspaces of the matrix <A>A</A> over the field <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GeneralisedEigenspaces", [ IsRing, IsMatrixOrMatrixObj ] );
DeclareSynonym( "GeneralizedEigenspaces", GeneralisedEigenspaces );


#############################################################################
##
#O  Eigenvalues( <F>, <A> )
##
##  <#GAPDoc Label="Eigenvalues">
##  <ManSection>
##  <Oper Name="Eigenvalues" Arg='F, A'/>
##
##  <Description>
##  The eigenvalues of the matrix <A>A</A> over the field <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Eigenvalues", [ IsRing, IsMatrixOrMatrixObj ] );

#############################################################################
##
#O  Eigenspaces( <F>, <A> )
##
##  <#GAPDoc Label="Eigenspaces">
##  <ManSection>
##  <Oper Name="Eigenspaces" Arg='F, A'/>
##
##  <Description>
##  The eigenspaces of the matrix <A>A</A> over the field <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Eigenspaces", [ IsRing, IsMatrix ] );

#############################################################################
##
#O  Eigenvectors( <F>, <A> )
##
##  <#GAPDoc Label="Eigenvectors">
##  <ManSection>
##  <Oper Name="Eigenvectors" Arg='F, A'/>
##
##  <Description>
##  The eigenvectors of the matrix <A>A</A> over the field <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Eigenvectors", [ IsRing, IsMatrix ] );


#############################################################################
##
#A  ProjectiveOrder( <mat> )
##
##  <#GAPDoc Label="ProjectiveOrder">
##  <ManSection>
##  <Attr Name="ProjectiveOrder" Arg='mat'/>
##
##  <Description>
##  Returns an integer n and a finite field element e such that
##  <A>A</A>^n = eI.
##  <A>mat</A> must be a matrix defined over a finite field.
##  <Example><![CDATA[
##  gap> ProjectiveOrder([[1,4],[5,2]]*Z(11)^0);
##  [ 5, Z(11)^5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ProjectiveOrder", IsMatrix );

#############################################################################
##
#F  OrderMatTrial( <mat>,<lim> )
##
##  <ManSection>
##  <Func Name="OrderMatTrial" Arg='mat,lim'/>
##
##  <Description>
##  tries to compute the order of <A>mat</A> (of small order) by mapping the
##  basis vectors under <A>mat</A>. This is done at most <A>lim</A> times, if the
##  matrix order has not been determined at this point (or if the matrix is
##  not invertible) <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "OrderMatTrial" );


#############################################################################
##
#A  RankMatrix( <mat> ) . . . . . . . . . . . . . . . . . .  rank of a matrix
#A  RankMat( <mat> )  . . . . . . . . . . . . . . . . . . .  rank of a matrix
##
##  <#GAPDoc Label="RankMat">
##  <ManSection>
##  <Attr Name="RankMatrix" Arg='mat'/>
##  <Attr Name="RankMat" Arg='mat'/>
##
##  <Description>
##  If <A>mat</A> is a matrix object representing a matrix whose rows span a
##  free module over the ring generated by the matrix entries and their
##  inverses then <Ref Attr="RankMatrix"/> returns the dimension of this free
##  module.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  Note that <Ref Attr="RankMatrix"/> may perform a Gaussian elimination.
##  For large rational matrices this may take very long,
##  because the entries may become very large.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> RankMatrix( mat );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#T suitable definition? example for a 'fail' result?
##
DeclareAttribute( "RankMatrix", IsMatrixOrMatrixObj );
DeclareSynonymAttr( "RankMat", RankMatrix );


#############################################################################
##
#O  RankMatrixDestructive( <mat> ) . . . . . . . . . . . . . rank of a matrix
#O  RankMatDestructive( <mat> )  . . . . . . . . . . . . . . rank of a matrix
##
##  <ManSection>
##  <Oper Name="RankMatrixDestructive" Arg='mat'/>
##  <Oper Name="RankMatDestructive" Arg='mat'/>
##
##  <Description>
##  For a matrix object <A>mat</A>,
##  <Ref Oper="RankMatrixDestructive"/>
##  returns the same result as <Ref Attr="RankMatrix"/> but may
##  modify its argument in the process, if this saves time or memory.
##  </Description>
##  </ManSection>
##
DeclareOperation( "RankMatrixDestructive", [ IsMatrixOrMatrixObj and IsMutable ]);
DeclareSynonymAttr( "RankMatDestructive", RankMatrixDestructive );


#############################################################################
##
#A  SemiEchelonMat( <mat> )
##
##  <#GAPDoc Label="SemiEchelonMat">
##  <ManSection>
##  <Attr Name="SemiEchelonMat" Arg='mat'/>
##
##  <Description>
##  A matrix over a field <M>F</M> is in semi-echelon form if the first nonzero
##  element in each row is the identity of <M>F</M>,
##  and all values exactly below these pivots are the zero of <M>F</M>.
##  <P/>
##  <Ref Attr="SemiEchelonMat"/> returns a record that contains information about
##  a semi-echelonized form of the matrix <A>mat</A>.
##  <P/>
##  The components of this record are
##  <P/>
##  <List>
##  <Mark><C>vectors</C></Mark>
##  <Item>
##        list of row vectors, each with pivot element the identity of <M>F</M>,
##  </Item>
##  <Mark><C>heads</C></Mark>
##  <Item>
##        list that contains at position <A>i</A>, if nonzero, the number of the
##        row for that the pivot element is in column <A>i</A>.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SemiEchelonMat", IsMatrix );

#############################################################################
##
#O  SemiEchelonMatDestructive( <mat> )
##
##  <#GAPDoc Label="SemiEchelonMatDestructive">
##  <ManSection>
##  <Oper Name="SemiEchelonMatDestructive" Arg='mat'/>
##
##  <Description>
##  This does the same as <C>SemiEchelonMat( <A>mat</A> )</C>, except that it may
##  (and probably will) destroy the matrix <A>mat</A>.
##  <Example><![CDATA[
##  gap> mm:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> SemiEchelonMatDestructive( mm );
##  rec( heads := [ 1, 2, 0 ], vectors := [ [ 1, 2, 3 ], [ 0, 1, 2 ] ] )
##  gap> mm;
##  [ [ 1, 2, 3 ], [ 0, 1, 2 ], [ 0, 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SemiEchelonMatDestructive", [ IsMatrix and IsMutable] );


#############################################################################
##
#A  SemiEchelonMatTransformation( <mat> )
##
##  <#GAPDoc Label="SemiEchelonMatTransformation">
##  <ManSection>
##  <Attr Name="SemiEchelonMatTransformation" Arg='mat'/>
##
##  <Description>
##  does the same as <Ref Attr="SemiEchelonMat"/> but additionally stores the linear
##  transformation <M>T</M> performed on the matrix.
##  The additional components of the result are
##  <P/>
##  <List>
##  <Mark><C>coeffs</C></Mark>
##  <Item>
##        a list of coefficients vectors of the <C>vectors</C> component,
##        with respect to the rows of <A>mat</A>, that is, <C>coeffs * mat</C>
##        is the <C>vectors</C> component.
##  </Item>
##  <Mark><C>relations</C></Mark>
##  <Item>
##        a list of basis vectors for the (left) null space of <A>mat</A>.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> SemiEchelonMatTransformation([[1,2,3],[0,0,1]]);
##  rec( coeffs := [ [ 1, 0 ], [ 0, 1 ] ], heads := [ 1, 0, 2 ],
##    relations := [  ], vectors := [ [ 1, 2, 3 ], [ 0, 0, 1 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SemiEchelonMatTransformation", IsMatrix );

#############################################################################
##
#O  SemiEchelonMatTransformationDestructive( <mat> )
##
##  <ManSection>
##  <Oper Name="SemiEchelonMatTransformationDestructive" Arg='mat'/>
##
##  <Description>
##  This does the same as <C>SemiEchelonMatTransformation( <A>mat</A> )</C>, except that it may
##  (and probably will) destroy the matrix <A>mat</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SemiEchelonMatTransformationDestructive", [
        IsMatrix and IsMutable ] );


#############################################################################
##
#F  SemiEchelonMatsNoCo( <mats> )
##
##  <ManSection>
##  <Func Name="SemiEchelonMatsNoCo" Arg='mats'/>
##
##  <Description>
##  The function that does the work for <C>SemiEchelonMats</C> and
##  <C>SemiEchelonMatsDestructive</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SemiEchelonMatsNoCo" );

#############################################################################
##
#O  SemiEchelonMats( <mats> )
##
##  <#GAPDoc Label="SemiEchelonMats">
##  <ManSection>
##  <Oper Name="SemiEchelonMats" Arg='mats'/>
##
##  <Description>
##  A list of matrices over a field <M>F</M> is in semi-echelon form if the
##  list of row vectors obtained on concatenating the rows of each matrix
##  is a semi-echelonized matrix (see <Ref Attr="SemiEchelonMat"/>).
##  <P/>
##  <Ref Oper="SemiEchelonMats"/> returns a record that contains information about
##  a semi-echelonized form of the list <A>mats</A> of matrices.
##  <P/>
##  The components of this record are
##  <P/>
##  <List>
##  <Mark><C>vectors</C></Mark>
##  <Item>
##        list of matrices, each with pivot element the identity of <M>F</M>,
##  </Item>
##  <Mark><C>heads</C></Mark>
##  <Item>
##        matrix that contains at position [<A>i</A>,<A>j</A>], if nonzero,
##        the number of the matrix that has the pivot element in
##        this position
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SemiEchelonMats", [ IsList ] );

#############################################################################
##
#O  SemiEchelonMatsDestructive( <mats> )
##
##  <#GAPDoc Label="SemiEchelonMatsDestructive">
##  <ManSection>
##  <Oper Name="SemiEchelonMatsDestructive" Arg='mats'/>
##
##  <Description>
##  Does the same as <Ref Oper="SemiEchelonMats"/>,
##  except that it may destroy its argument.
##  Therefore the argument must be a list of matrices that are mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SemiEchelonMatsDestructive", [ IsList ] );


#############################################################################
##
#A  TransposedMatImmutable( <mat> ) . . . . . . . . .  transposed of a matrix
#A  TransposedMat( <mat> )  . . . . . . . . . . . . .  transposed of a matrix
#O  TransposedMatMutable( <mat> ) . . . . . . . . . .  transposed of a matrix
#O  TransposedMatOp( <mat> )  . . . . . . . . . . . .  transposed of a matrix
##
##  <#GAPDoc Label="TransposedMatImmutable">
##  <ManSection>
##  <Attr Name="TransposedMatImmutable" Arg='mat'/>
##  <Attr Name="TransposedMat" Arg='mat'/>
##  <Oper Name="TransposedMatMutable" Arg='mat'/>
##  <Oper Name="TransposedMatOp" Arg='mat'/>
##
##  <Description>
##  These functions all return the transposed of the matrix object
##  <A>mat</A>, i.e.,
##  a matrix object <M>trans</M> such that
##  <M>trans[i,k] = <A>mat</A>[k,i]</M> holds.
##  <P/>
##  They differ only w.r.t. the mutability of the result.
##  <P/>
##  <Ref Attr="TransposedMat"/> is an attribute and hence returns an
##  immutable result.
##  <Ref Oper="TransposedMatMutable"/> is guaranteed to return a new
##  <E>mutable</E> matrix.
##  <P/>
##  <Ref Attr="TransposedMatImmutable"/> is a synonym of
##  <Ref Attr="TransposedMat"/>,
##  and <Ref Oper="TransposedMatOp"/> is a synonym of
##  <Ref Oper="TransposedMatMutable"/>,
##  in analogy to operations such as <Ref Attr="Zero"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TransposedMatImmutable", IsMatrixOrMatrixObj );
DeclareSynonymAttr( "TransposedMat", TransposedMatImmutable );

DeclareOperation( "TransposedMatMutable", [ IsMatrixOrMatrixObj ] );
DeclareSynonym( "TransposedMatOp", TransposedMatMutable );
DeclareSynonym( "MutableTransposedMat", TransposedMatMutable ); # needed?


#############################################################################
##
#O  MutableTransposedMatDestructive( <mat> )
##
##  <ManSection>
##  <Oper Name="MutableTransposedMatDestructive" Arg='mat'/>
##
##  <Description>
##  <C>MutableTransposedMatDestructive</C> returns the transpose of the mutable
##  matrix <A>mat</A>. It may, but does not have to, destroy the contents
##  of <A>mat</A> in the process. In particular, the returned matrix may be
##  identical to <A>mat</A>, having been transposed in place.
##  </Description>
##  </ManSection>
##
DeclareOperation( "MutableTransposedMatDestructive", [IsMatrix and IsMutable] );


#############################################################################
##
#O  TransposedMatDestructive( <mat> )
##
##  <#GAPDoc Label="TransposedMatDestructive">
##  <ManSection>
##  <Oper Name="TransposedMatDestructive" Arg='mat'/>
##
##  <Description>
##  If <A>mat</A> is a mutable matrix, then the transposed
##  is computed by swapping the entries in <A>mat</A>. In this way <A>mat</A> gets
##  changed. In all other cases the transposed is computed by <Ref Attr="TransposedMat"/>.
##  <Example><![CDATA[
##  gap> TransposedMat([[1,2,3],[4,5,6],[7,8,9]]);
##  [ [ 1, 4, 7 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]
##  gap> mm:= [[1,2,3],[4,5,6],[7,8,9]];;
##  gap> TransposedMatDestructive( mm );
##  [ [ 1, 4, 7 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]
##  gap> mm;
##  [ [ 1, 4, 7 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TransposedMatDestructive", [ IsMatrix ] );



############################################################################
##
#P  IsMonomialMatrix( <mat> )
##
##  <#GAPDoc Label="IsMonomialMatrix">
##  <ManSection>
##  <Prop Name="IsMonomialMatrix" Arg='mat'/>
##
##  <Description>
##  A matrix is monomial if  and only if it  has exactly one nonzero entry in
##  every row and every column.
##  <Example><![CDATA[
##  gap> IsMonomialMatrix([[0,1],[1,0]]);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsMonomialMatrix", IsMatrix );


#############################################################################
##
#O  InverseMatMod( <mat>, <obj> )
##
##  <#GAPDoc Label="InverseMatMod">
##  <ManSection>
##  <Oper Name="InverseMatMod" Arg='mat, obj'/>
##
##  <Description>
##  For a square matrix <A>mat</A>, <Ref Oper="InverseMatMod"/> returns a matrix <A>inv</A>
##  such that <C><A>inv</A> * <A>mat</A></C> is congruent to the identity matrix modulo
##  <A>obj</A>, if such a matrix exists, and <K>fail</K> otherwise.
##  <Example><![CDATA[
##  gap> mat:= [ [ 1, 2 ], [ 3, 4 ] ];;  inv:= InverseMatMod( mat, 5 );
##  [ [ 3, 1 ], [ 4, 2 ] ]
##  gap> mat * inv;
##  [ [ 11, 5 ], [ 25, 11 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "InverseMatMod", [ IsMatrix, IsObject ] );


#############################################################################
##
#O  KroneckerProduct( <mat1>, <mat2> )
##
##  <#GAPDoc Label="KroneckerProduct">
##  <ManSection>
##  <Oper Name="KroneckerProduct" Arg='mat1, mat2'/>
##
##  <Description>
##  The Kronecker product of two matrices is the matrix obtained when
##  replacing each entry <A>a</A> of <A>mat1</A> by the product <C><A>a</A>*<A>mat2</A></C> in one
##  matrix.
##  <Example><![CDATA[
##  gap> KroneckerProduct([[1,2]],[[5,7],[9,2]]);
##  [ [ 5, 7, 10, 14 ], [ 9, 2, 18, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "KroneckerProduct", [ IsMatrixOrMatrixObj, IsMatrixOrMatrixObj ] );
#T state how mutable the result is!


#############################################################################
##
#O  SolutionMatNoCo( <mat>, <vec> )
##
##  <ManSection>
##  <Oper Name="SolutionMatNoCo" Arg='mat, vec'/>
##
##  <Description>
##  Does thework for <C>SolutionMat</C> and <C>SolutionMatDestructive</C>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SolutionMatNoCo", [ IsMatrix, IsRowVector ] );


#############################################################################
##
#O  SolutionMat( <mat>, <vec> ) . . . . . . . . . .  one solution of equation
##
##  <#GAPDoc Label="SolutionMat">
##  <ManSection>
##  <Oper Name="SolutionMat" Arg='mat, vec'/>
##
##  <Description>
##  returns a row vector <A>x</A> that is a solution of the equation <C><A>x</A> * <A>mat</A>
##  = <A>vec</A></C>. It returns <K>fail</K> if no such vector exists.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SolutionMat", [ IsMatrix, IsRowVector ] );

#############################################################################
##
#O  SolutionMatDestructive( <mat>, <vec> )
##
##  <#GAPDoc Label="SolutionMatDestructive">
##  <ManSection>
##  <Oper Name="SolutionMatDestructive" Arg='mat, vec'/>
##
##  <Description>
##  Does the same as <C>SolutionMat( <A>mat</A>, <A>vec</A> )</C> except that
##  it may destroy the matrix <A>mat</A> and the vector <A>vec</A>.
##  The matrix <A>mat</A> must be mutable.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> SolutionMat(mat,[3,5,7]);
##  [ 5/3, 1/3, 0 ]
##  gap> mm:= [[1,2,3],[4,5,6],[7,8,9]];;
##  gap> v:= [3,5,7];;
##  gap> SolutionMatDestructive( mm, v );
##  [ 5/3, 1/3, 0 ]
##  gap> mm;
##  [ [ 1, 2, 3 ], [ 0, -3, -6 ], [ 0, 0, 0 ] ]
##  gap> v;
##  [ 0, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SolutionMatDestructive",
    [ IsMatrix and IsMutable, IsRowVector ] );


############################################################################
##
#O  SumIntersectionMat( <M1>, <M2> )  . .  sum and intersection of two spaces
##
##  <#GAPDoc Label="SumIntersectionMat">
##  <ManSection>
##  <Oper Name="SumIntersectionMat" Arg='M1, M2'/>
##
##  <Description>
##  performs  Zassenhaus'  algorithm to compute  bases  for  the sum  and the
##  intersection of spaces generated by the rows of the matrices <A>M1</A>, <A>M2</A>.
##  <P/>
##  returns a list  of length 2,   at first position   a base of the sum,  at
##  second  position a  base   of the   intersection.   Both  bases  are   in
##  semi-echelon form (see&nbsp;<Ref Sect="Echelonized Matrices"/>).
##  <Example><![CDATA[
##  gap> SumIntersectionMat(mat,[[2,7,6],[5,9,4]]);
##  [ [ [ 1, 2, 3 ], [ 0, 1, 2 ], [ 0, 0, 1 ] ], [ [ 1, -3/4, -5/2 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SumIntersectionMat", [ IsMatrix, IsMatrix ] );



#############################################################################
##
#O  TriangulizedMat( <mat> ) . . .  compute upper triangular form of a matrix
##
##  <#GAPDoc Label="TriangulizedMat">
##  <ManSection>
##  <Oper Name="TriangulizedMat" Arg='mat'/>
##  <Oper Name="RREF" Arg='mat'/>
##
##  <Description>
##  Computes an upper triangular form of the matrix <A>mat</A> via
##  the Gaussian Algorithm. It returns a mutable matrix in upper triangular form.
##  This is sometimes also  called <Q>Hermite normal form</Q> or <Q>Reduced Row Echelon
##  Form</Q>.
##  <C>RREF</C> is a synonym for <C>TriangulizedMat</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TriangulizedMat", [ IsMatrix ] );
DeclareSynonym( "RREF", TriangulizedMat);

#############################################################################
##
#O  TriangulizeMat( <mat> ) . . . . . bring a matrix in upper triangular form
##
##  <#GAPDoc Label="TriangulizeMat">
##  <ManSection>
##  <Oper Name="TriangulizeMat" Arg='mat'/>
##
##  <Description>
##  Applies the Gaussian Algorithm to the mutable matrix
##  <A>mat</A> and changes <A>mat</A> such that it is in upper triangular normal
##  form (sometimes called <Q>Hermite normal form</Q> or <Q>Reduced Row Echelon
##  Form</Q>).
##  <Example><![CDATA[
##  gap> m:=TransposedMatMutable(mat);
##  [ [ 1, 4, 7 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]
##  gap> TriangulizeMat(m);m;
##  [ [ 1, 0, -1 ], [ 0, 1, 2 ], [ 0, 0, 0 ] ]
##  gap> m:=TransposedMatMutable(mat);
##  [ [ 1, 4, 7 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]
##  gap> TriangulizedMat(m);m;
##  [ [ 1, 0, -1 ], [ 0, 1, 2 ], [ 0, 0, 0 ] ]
##  [ [ 1, 4, 7 ], [ 2, 5, 8 ], [ 3, 6, 9 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TriangulizeMat", [ IsMatrix and IsMutable ] );


#############################################################################
##
#O  UpperSubdiagonal( <mat>, <pos> )
##
##  <#GAPDoc Label="UpperSubdiagonal">
##  <ManSection>
##  <Oper Name="UpperSubdiagonal" Arg='mat, pos'/>
##
##  <Description>
##  returns a mutable list containing the entries of the <A>pos</A>th upper
##  subdiagonal of the matrix <A>mat</A>.
##  <Example><![CDATA[
##  gap> UpperSubdiagonal( [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ], 1 );
##  [ 2, 6 ]
##  gap> UpperSubdiagonal( [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ], 1 );
##  [ 2 ]
##  gap> UpperSubdiagonal( [ [ 1, 2, 3, 4 ], [ 5, 6, 7, 8 ] ], 1 );
##  [ 2, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UpperSubdiagonal", [ IsMatrixOrMatrixObj, IsPosInt ] );


#############################################################################
##
#F  BaseFixedSpace( <mats> )  . . . . . . . . . . . .  calculate fixed points
##
##  <#GAPDoc Label="BaseFixedSpace">
##  <ManSection>
##  <Func Name="BaseFixedSpace" Arg='mats'/>
##
##  <Description>
##  <Ref Func="BaseFixedSpace"/> returns a list of row vectors that form a base of the
##  vector space <M>V</M> such that <M>v M = v</M> for all <M>v</M> in <M>V</M> and all matrices
##  <M>M</M> in the list <A>mats</A>.  (This is the common eigenspace of all matrices
##  in <A>mats</A> for the eigenvalue 1.)
##  <Example><![CDATA[
##  gap> BaseFixedSpace([[[1,2],[0,1]]]);
##  [ [ 0, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BaseFixedSpace" );


#############################################################################
##
#F  BaseSteinitzVectors( <bas>, <mat> )
##
##  <#GAPDoc Label="BaseSteinitzVectors">
##  <ManSection>
##  <Func Name="BaseSteinitzVectors" Arg='bas, mat'/>
##
##  <Description>
##  find vectors extending mat to a basis spanning the span of <A>bas</A>.
##  Both <A>bas</A> and <A>mat</A> must be matrices of full (row) rank. It returns a
##  record with the following components:
##  <List>
##  <Mark><C>subspace</C></Mark>
##  <Item>
##  is a basis of the space spanned by <A>mat</A> in upper triangular
##  form with leading ones at all echelon steps and zeroes above these ones.
##  </Item>
##  <Mark><C>factorspace</C></Mark>
##  <Item>
##  is a list of extending vectors in upper triangular form.
##  </Item>
##  <Mark><C>factorzero</C></Mark>
##  <Item>
##  is a zero vector.
##  </Item>
##  <Mark><C>heads</C></Mark>
##  <Item>
##  is a list of integers which can be used to decompose vectors in
##  the basis vectors. The <A>i</A>th entry indicating the vector
##  that gives an echelon step at position <A>i</A>.
##  A negative number indicates an echelon step in the subspace, a positive
##  number an echelon step in the complement, the absolute value gives the
##  position of the vector in the lists <C>subspace</C> and <C>factorspace</C>.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> BaseSteinitzVectors(IdentityMat(3,1),[[11,13,15]]);
##  rec( factorspace := [ [ 0, 1, 15/13 ], [ 0, 0, 1 ] ],
##    factorzero := [ 0, 0, 0 ], heads := [ -1, 1, 2 ],
##    subspace := [ [ 1, 13/11, 15/11 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BaseSteinitzVectors" );


#############################################################################
##
#F  BlownUpMat( <B>, <mat> )
##
##  <#GAPDoc Label="BlownUpMat">
##  <ManSection>
##  <Func Name="BlownUpMat" Arg='B, mat'/>
##
##  <Description>
##  Let <A>B</A> be a basis of a field extension <M>F / K</M>,
##  and <A>mat</A> a matrix whose entries are all in <M>F</M>.
##  (This is not checked.)
##  <Ref Func="BlownUpMat"/> returns a matrix over <M>K</M> that is obtained by replacing each
##  entry of <A>mat</A> by its regular representation w.r.t.&nbsp;<A>B</A>.
##  <P/>
##  More precisely,
##  regard <A>mat</A> as the matrix of a linear transformation on the row space
##  <M>F^n</M> w.r.t.&nbsp;the <M>F</M>-basis with vectors <M>(v_1, \ldots, v_n)</M>
##  and suppose that the basis <A>B</A> consists of the vectors
##  <M>(b_1,  \ldots, b_m)</M>;
##  then the returned matrix is the matrix of the linear transformation
##  on the row space <M>K^{mn}</M> w.r.t.&nbsp;the <M>K</M>-basis whose vectors are
##  <M>(b_1 v_1, \ldots b_m v_1, \ldots, b_m v_n)</M>.
##  <P/>
##  Note that the linear transformations act on <E>row</E> vectors, i.e.,
##  each row of the matrix is a concatenation of vectors of <A>B</A>-coefficients.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BlownUpMat" );


#############################################################################
##
#F  BlownUpVector( <B>, <vector> )
##
##  <#GAPDoc Label="BlownUpVector">
##  <ManSection>
##  <Func Name="BlownUpVector" Arg='B, vector'/>
##
##  <Description>
##  Let <A>B</A> be a basis of a field extension <M>F / K</M>,
##  and <A>vector</A> a row vector whose entries are all in <M>F</M>.
##  <Ref Func="BlownUpVector"/> returns a row vector over <M>K</M> that is obtained by
##  replacing each entry of <A>vector</A> by its coefficients w.r.t.&nbsp;<A>B</A>.
##  <P/>
##  So <Ref Func="BlownUpVector"/> and <Ref Func="BlownUpMat"/> are compatible
##  in the sense that for a matrix <A>mat</A> over <M>F</M>,
##  <C>BlownUpVector( <A>B</A>, <A>mat</A> * <A>vector</A> )</C>
##  is equal to
##  <C>BlownUpMat( <A>B</A>, <A>mat</A> ) * BlownUpVector( <A>B</A>, <A>vector</A> )</C>.
##  <Example><![CDATA[
##  gap> B:= Basis( CF(4), [ 1, E(4) ] );;
##  gap> mat:= [ [ 1, E(4) ], [ 0, 1 ] ];;  vec:= [ 1, E(4) ];;
##  gap> bmat:= BlownUpMat( B, mat );;  bvec:= BlownUpVector( B, vec );;
##  gap> Display( bmat );  bvec;
##  [ [   1,   0,   0,   1 ],
##    [   0,   1,  -1,   0 ],
##    [   0,   0,   1,   0 ],
##    [   0,   0,   0,   1 ] ]
##  [ 1, 0, 0, 1 ]
##  gap> bvec * bmat = BlownUpVector( B, vec * mat );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BlownUpVector" );


#############################################################################
##
#O  DiagonalizeMat(<ring>,<mat>)
##
##  <#GAPDoc Label="DiagonalizeMat">
##  <ManSection>
##  <Oper Name="DiagonalizeMat" Arg='ring,mat'/>
##
##  <Description>
##  brings the mutable matrix <A>mat</A>, considered as a matrix over <A>ring</A>,
##  into diagonal form by elementary row and column operations.
##  <Example><![CDATA[
##  gap> m:=[[1,2],[2,1]];;
##  gap> DiagonalizeMat(Integers,m);m;
##  [ [ 1, 0 ], [ 0, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DiagonalizeMat", [IsRing,IsMatrix and IsMutable] );


#############################################################################
##
#F  IdentityMat( <m> [, <R>] )  . . . . . . . identity matrix of a given size
##
##  <#GAPDoc Label="IdentityMat">
##  <ManSection>
##  <Func Name="IdentityMat" Arg='m [, R]'/>
##
##  <Description>
##  returns a (mutable) <A>m</A><M>\times</M><A>m</A> identity matrix over the ring given
##  by <A>R</A>. Here, <A>R</A> can be either a ring, or an element of a ring. By default,
##  an integer matrix is created.
##  <Example><![CDATA[
##  gap> IdentityMat(3);
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
##  gap> IdentityMat(2,Integers mod 15);
##  [ [ ZmodnZObj( 1, 15 ), ZmodnZObj( 0, 15 ) ],
##    [ ZmodnZObj( 0, 15 ), ZmodnZObj( 1, 15 ) ] ]
##  gap> IdentityMat(2,Z(3));
##  [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IdentityMat" );


#############################################################################
##
#O  MutableCopyMatrix( <mat> )  . . . . . . . . . . . . . . . copies a matrix
##
##  <ManSection>
##  <Oper Name="MutableCopyMatrix" Arg='mat'/>
##
##  <Description>
##  <Ref Oper="MutableCopyMatrix"/> returns a fully mutable copy of the
##  matrix <A>mat</A>.
##  <P/>
##  The default method does <C>List( </C><A>mat</A><C>, ShallowCopy )</C>
##  and thus may also be called for the empty list,
##  returning a new empty list.
##  <P/>
##  Note that this is different from what <Ref Func="StructuralCopy"/> does,
##  where exactly those rows of the result are mutable which are already
##  mutable in <A>mat</A>,
##  and where two rows in the result are identical if and only if they are
##  identical in <A>mat</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "MutableCopyMatrix", [ IsList ] );


#############################################################################
##
#F  NullMat( <m>, <n> [, <R>] ) . . . . . . . . . null matrix of a given size
##
##  <#GAPDoc Label="NullMat">
##  <ManSection>
##  <Func Name="NullMat" Arg='m, n [, R]'/>
##
##  <Description>
##  returns a (mutable) <A>m</A><M>\times</M><A>n</A> null matrix over the ring given by
##  by <A>R</A>. Here, <A>R</A> can be either a ring, or an element of a ring. By default,
##  an integer matrix is created.
##  <Example><![CDATA[
##  gap> NullMat(3,2);
##  [ [ 0, 0 ], [ 0, 0 ], [ 0, 0 ] ]
##  gap> NullMat(2,2,Integers mod 15);
##  [ [ ZmodnZObj( 0, 15 ), ZmodnZObj( 0, 15 ) ],
##    [ ZmodnZObj( 0, 15 ), ZmodnZObj( 0, 15 ) ] ]
##  gap> NullMat(3,2,Z(3));
##  [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NullMat" );


#############################################################################
##
#F  NullspaceModN( <M>, <n> ) . . . . . . . . . . . .nullspace of <M> mod <n>
##
##  <#GAPDoc Label="NullspaceModN">
##  <ManSection>
##  <Func Name="NullspaceModQ" Arg='M, q'/>
##  <Func Name="NullspaceModN" Arg='M, n'/>
##
##  <Description>
##  <A>M</A> must be a matrix of integers and <A>n</A> a positive integer.
##  Then <Ref Func="NullspaceModN"/> returns the set of all vectors of
##  integers modulo <A>n</A>, which solve the homogeneous equation system
##  <A>v</A> <A>M</A> = 0 modulo <A>n</A>.
##  <P/>
##  <Ref Func="NullspaceModQ"/> is a synonym for <Ref Func="NullspaceModN"/>.
##  <Example><![CDATA[
##  gap> NullspaceModN( [ [ 2 ] ], 8 );
##  [ [ 0 ], [ 4 ] ]
##  gap> NullspaceModN( [ [ 2, 1 ], [ 0, 2 ] ], 6 );
##  [ [ 0, 0 ], [ 0, 3 ] ]
##  gap> mat:= [ [ 1, 3 ], [ 1, 2 ], [ 1, 1 ] ];;
##  gap> NullspaceModN( mat, 5 );
##  [ [ 0, 0, 0 ], [ 1, 3, 1 ], [ 2, 1, 2 ], [ 3, 4, 3 ], [ 4, 2, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NullspaceModN" );
DeclareSynonym( "NullspaceModQ", NullspaceModN );


#############################################################################
##
#F  BasisNullspaceModN( <M>, <n> ) . .  basis of the nullspace of <M> mod <n>
##
##  <#GAPDoc Label="BasisNullspaceModN">
##  <ManSection>
##  <Func Name="BasisNullspaceModN" Arg='M, n'/>
##
##  <Description>
##  <A>M</A> must be a matrix of integers and <A>n</A> a positive integer.
##  Then <Ref Func="BasisNullspaceModN"/> returns a set <A>B</A> of vectors
##  such that every vector <A>v</A> of integer modulo <A>n</A> satisfying
##  <A>v</A> <A>M</A> = 0 modulo <A>n</A> can be expressed by a Z-linear
##  combination of elements of <A>B</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BasisNullspaceModN" );


#############################################################################
##
#F  PermutationMat( <perm>, <dim> [, <F> ] ) . . . . . .  permutation matrix
##
##  <#GAPDoc Label="PermutationMat">
##  <ManSection>
##  <Func Name="PermutationMat" Arg='perm, dim [, F ]'/>
##
##  <Description>
##  returns a matrix in dimension <A>dim</A> over the field given by <A>F</A> (i.e.
##  the smallest field containing the element <A>F</A> or <A>F</A> itself if it is a
##  field)  that
##  represents the permutation <A>perm</A> acting by permuting the basis vectors
##  as it permutes points.
##  <Example><![CDATA[
##  gap> PermutationMat((1,2,3),4,1);
##  [ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermutationMat" );


#############################################################################
##
#O  DiagonalMatrix( [<filt>, ]<R>, <vector> )
#O  DiagonalMatrix( <vector>[, <M>] )
##
##  <#GAPDoc Label="DiagonalMatrix">
##  <ManSection>
##  <Oper Name="DiagonalMatrix" Arg='[filt, ]R, vector'
##   Label="with base domain"/>
##  <Oper Name="DiagonalMatrix" Arg='vector[, M]'
##   Label="with example matrix"/>
##
##  <Returns>
##  a square matrix or matrix object with column number equal to the length
##  of the dense list <A>vector</A>,
##  whose diagonal entries are given by the entries of <A>vector</A>,
##  and whose off-diagonal entries are zero.
##  </Returns>
##  <Description>
##  If a semiring <A>R</A> is given then it will be the base domain
##  (see <Ref Attr="BaseDomain" Label="for a matrix object"/>)
##  of the returned matrix.
##  In this case, a filter <A>filt</A> can be specified that defines the
##  internal representation of the result
##  (see <Ref Attr="ConstructingFilter" Label="for a matrix object"/>).
##  The default value for <A>filt</A> is determined from <A>R</A>.
##  <P/>
##  If a matrix object <A>M</A> is given then the returned matrix will have
##  the same internal representation and the same base domain as <A>M</A>.
##  <P/>
##  If only <A>vector</A> is given then it is used to compute a default for
##  <A>R</A>.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a matrix object"/> value
##  of the result implies <Ref Filt="IsCopyable"/> then the result is
##  fully mutable.
##  <P/>
##  <Example><![CDATA[
##  gap> d1:= DiagonalMatrix( GF(9), [ 1, 2 ] * Z(3)^0 );
##  [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3) ] ]
##  gap> Is8BitMatrixRep( d1 );
##  true
##  gap> d2:= DiagonalMatrix( IsPlistMatrixRep, GF(9), [ 1, 2 ] * Z(3)^0 );
##  <2x2-matrix over GF(3^2)>
##  gap> IsPlistMatrixRep( d2 );
##  true
##  gap> DiagonalMatrix( [ 1, 2 ] );
##  <2x2-matrix over Rationals>
##  gap> DiagonalMatrix( [ 1, 2 ], Matrix( Integers, [ [ 1 ] ], 1 ) );
##  <2x2-matrix over Integers>
##  gap> DiagonalMatrix( [ 1, 2 ], [ [ 1 ] ] );
##  [ [ 1, 0 ], [ 0, 2 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareTagBasedOperation( "DiagonalMatrix",
    [ IsOperation, IsSemiring, IsRowVectorOrVectorObj ] );
DeclareOperation( "DiagonalMatrix", [ IsSemiring, IsRowVectorOrVectorObj ] );
DeclareOperation( "DiagonalMatrix",
    [ IsRowVectorOrVectorObj, IsMatrixOrMatrixObj ] );
DeclareOperation( "DiagonalMatrix", [ IsRowVectorOrVectorObj ] );


#############################################################################
##
#F  DiagonalMat( <vector> ) . . . . . . . . . . . . . . . . . diagonal matrix
##
##  <#GAPDoc Label="DiagonalMat">
##  <ManSection>
##  <Func Name="DiagonalMat" Arg='vector'/>
##
##  <Description>
##  returns a diagonal matrix <A>mat</A> with the diagonal entries given by
##  <A>vector</A>.
##  <Example><![CDATA[
##  gap> DiagonalMat([1,2,3]);
##  [ [ 1, 0, 0 ], [ 0, 2, 0 ], [ 0, 0, 3 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DiagonalMat" );


#############################################################################
##
#F  ReflectionMat( <coeffs>[, <conj>][, <root>] )
##
##  <#GAPDoc Label="ReflectionMat">
##  <ManSection>
##  <Func Name="ReflectionMat" Arg='coeffs[, conj][, root]'/>
##
##  <Description>
##  Let <A>coeffs</A> be a row vector.
##  <Ref Func="ReflectionMat"/> returns the matrix of the reflection in this
##  vector.
##  <P/>
##  More precisely, if <A>coeffs</A> is the coefficients list of a vector
##  <M>v</M> w.r.t. a basis <M>B</M> (see&nbsp;<Ref Attr="Basis"/>)
##  then the returned matrix describes the
##  reflection in <M>v</M> w.r.t. <M>B</M> as a map on a row space,
##  with action from the right.
##  <P/>
##  The optional argument <A>root</A> is a root of unity that determines the
##  order of the reflection.
##  The default is a reflection of order 2.
##  For triflections one should choose a third root of unity etc.
##  (see&nbsp;<Ref Oper="E"/>).
##  <P/>
##  <A>conj</A> is a function of one argument that conjugates a ring element.
##  The default is <Ref Attr="ComplexConjugate"/>.
##  <P/>
##  The matrix of the reflection in <M>v</M> is defined as
##  <Display Mode="M">
##  M = I_n + <A>conj</A>(v^{tr}) \cdot (<A>root</A>-1) /
##  (v \cdot <A>conj</A>(v^{tr})) \cdot v
##  </Display>
##  where <M>n</M> is the length of the coefficient list.
##  <P/>
##  So <M>v</M> is mapped to <A>root</A><M> \cdot v</M>,
##  with default <M>-v</M>, and any vector <M>x</M> with the property
##  <M>x \cdot </M><A>conj</A><M>(v^{tr}) = 0</M> is fixed by the reflection.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ReflectionMat" );


#############################################################################
##
#F  RandomInvertibleMat( [rs ,] <m> [, <R>] ) . . .  random invertible matrix
##
##  <#GAPDoc Label="RandomInvertibleMat">
##  <ManSection>
##  <Func Name="RandomInvertibleMat" Arg='[rs ,] m [, R]'/>
##
##  <Description>
##  <Ref Func="RandomInvertibleMat"/> returns a new mutable invertible random
##  matrix with <A>m</A> rows and columns with elements taken from the ring
##  <A>R</A>, which defaults to <Ref Var="Integers"/>.
##  Optionally, a random source <A>rs</A> can be supplied.
##  <Example><![CDATA[
##  gap> m := RandomInvertibleMat(4);
##  [ [ -4, 1, 0, -1 ], [ -1, -1, 1, -1 ], [ 1, -2, -1, -2 ],
##    [ 0, -1, 2, -2 ] ]
##  gap> m^-1;
##  [ [ -1/8, -11/24, 1/24, 1/4 ], [ 1/4, -13/12, -1/12, 1/2 ],
##    [ -1/8, 5/24, -7/24, 1/4 ], [ -1/4, 3/4, -1/4, -1/2 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomInvertibleMat" );


#############################################################################
##
#F  RandomMat( [rs ,] <m>, <n> [, <R>] ) . . . . . . . . make a random matrix
##
##  <#GAPDoc Label="RandomMat">
##  <ManSection>
##  <Func Name="RandomMat" Arg='[rs ,] m, n [, R]'/>
##
##  <Description>
##  <Ref Func="RandomMat"/> returns a new mutable random matrix with <A>m</A> rows and
##  <A>n</A> columns with elements taken from the ring <A>R</A>, which defaults
##  to <Ref Var="Integers"/>.
##  Optionally, a random source <A>rs</A> can be supplied.
##  <Example><![CDATA[
##  gap> RandomMat(2,3,GF(3));
##  [ [ Z(3), Z(3), 0*Z(3) ], [ Z(3), Z(3)^0, Z(3) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomMat" );


#############################################################################
##
#F  RandomUnimodularMat( [rs ,] <m> ) . . . . . . . . random unimodular matrix
##
##  <#GAPDoc Label="RandomUnimodularMat">
##  <ManSection>
##  <Func Name="RandomUnimodularMat" Arg='[rs ,] m'/>
##
##  <Description>
##  returns a new random mutable <A>m</A><M>\times</M><A>m</A> matrix with integer
##  entries that is invertible over the integers.
##  Optionally, a random source <A>rs</A> can be supplied.
##  If the option <A>domain</A> is given, random selection is made from <A>domain</A>, otherwise
##  from <A>Integers</A>
##  <Example><![CDATA[
##  gap> m := RandomUnimodularMat(3);
##  [ [ -5, 1, 0 ], [ 12, -2, -1 ], [ -14, 3, 0 ] ]
##  gap> m^-1;
##  [ [ -3, 0, 1 ], [ -14, 0, 5 ], [ -8, -1, 2 ] ]
##  gap> RandomUnimodularMat(3:domain:=[-1000..1000]);
##  [ [ 312330173, 15560030349, -125721926670 ],
##  [ -307290, -15309014, 123693281 ],
##  [ -684293792, -34090949551, 275448039848 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomUnimodularMat" );


#############################################################################
##
#F  SimultaneousEigenvalues( <matlist>, <expo> ) . . . . . . . . .eigenvalues
##
##  <#GAPDoc Label="SimultaneousEigenvalues">
##  <ManSection>
##  <Func Name="SimultaneousEigenvalues" Arg='matlist, expo'/>
##
##  <Description>
##  The matrices in <A>matlist</A> must be matrices over GF(<A>q</A>)
##  for some prime <A>q</A>.
##  Together, they must generate an abelian p-group of exponent <A>expo</A>.
##  Then the eigenvalues of <A>mat</A> in the splitting field
##  <C>GF(<A>q</A>^<A>r</A>)</C> for some <A>r</A> are powers of an element
##  <M>\xi</M> in the splitting field, which is of order <A>expo</A>.
##  <Ref Func="SimultaneousEigenvalues"/> returns a matrix of
##  integers mod <A>expo</A> <M>(a_{{i,j}})</M>, such that the power
##  <M>\xi^{{a_{{i,j}}}}</M> is an eigenvalue of the <A>i</A>-th matrix in
##  <A>matlist</A> and the eigenspaces of the different matrices to the
##  eigenvalues <M>\xi^{{a_{{i,j}}}}</M> for fixed <A>j</A> are equal.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SimultaneousEigenvalues" );


#############################################################################
##
#A  TraceMatrix( <mat> )  . . . . . . . . . . . . . . . . . trace of a matrix
#A  TraceMat( <mat> ) . . . . . . . . . . . . . . . . . . . trace of a matrix
#A  Trace( <mat> )
##
##  <#GAPDoc Label="TraceMat">
##  <ManSection>
##  <Attr Name="TraceMatrix" Arg='mat'/>
##  <Attr Name="TraceMat" Arg='mat'/>
##  <Attr Name="Trace" Arg='mat' Label="of a matrix"/>
##
##  <Description>
##  The trace of a square matrix is the sum of its diagonal entries.
##  <Example><![CDATA[
##  gap> TraceMatrix([[1,2,3],[4,5,6],[7,8,9]]);
##  15
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TraceMatrix", IsMatrixOrMatrixObj );
DeclareSynonymAttr( "TraceMat", TraceMatrix );


#############################################################################
##
#A  JordanDecomposition( <mat> )
##
##  <#GAPDoc Label="JordanDecomposition">
##  <ManSection>
##  <Attr Name="JordanDecomposition" Arg='mat'/>
##
##  <Description>
##  <C>JordanDecomposition( <A>mat </A> )</C> returns a list <C>[S,N]</C> such that
##  <C>S</C> is a semisimple matrix and <C>N</C> is nilpotent. Furthermore, <C>S</C>
##  and <C>N</C> commute and <C><A>mat</A>=S+N</C>.
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];;
##  gap> JordanDecomposition(mat);
##  [ [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ],
##    [ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "JordanDecomposition", IsMatrix );


#############################################################################
##
#F  FlatBlockMat( <blockmat> ) . . . . . . . . convert block matrix to matrix
##
##  <ManSection>
##  <Func Name="FlatBlockMat" Arg='blockmat'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "FlatBlockMat" );

#############################################################################
##
#F  DirectSumMat( <matlist> ) . . . . . . . . . . . create block diagonal mat
##
##  <ManSection>
##  <Func Name="DirectSumMat" Arg='matlist'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "DirectSumMat" );

#############################################################################
##
#F  EmptyMatrix( <char> )
##
##  <#GAPDoc Label="EmptyMatrix">
##  <ManSection>
##  <Func Name="EmptyMatrix" Arg='char'/>
##
##  <Description>
##  is an empty (ordinary) matrix in characteristic <A>char</A> that can be added
##  to or multiplied with empty lists (representing zero-dimensional row
##  vectors). It also acts (via the operation <Ref Oper="\^"/>) on empty lists.
##  <P/>
##  <!-- store in the family as an attribute?-->
##  <Example><![CDATA[
##  gap> EmptyMatrix(5);
##  EmptyMatrix( 5 )
##  gap> AsList(last);
##  [  ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EmptyMatrix" );


#############################################################################
##
#F  OnSubspacesByCanonicalBasis(<bas>,<mat>)
##
##  <#GAPDoc Label="OnSubspacesByCanonicalBasis">
##  <ManSection>
##  <Func Name="OnSubspacesByCanonicalBasis" Arg='bas,mat'/>
##  <Func Name="OnSubspacesByCanonicalBasisConcatenations" Arg='basvec,mat'/>
##
##  <Description>
##  implements the operation of a matrix group on subspaces of a vector
##  space. <A>bas</A> must be a list of (linearly independent) vectors which
##  forms a basis of the subspace in Hermite normal form. <A>mat</A> is an
##  element of the acting matrix group. The function returns a mutable
##  matrix which gives the basis of the image of the subspace in Hermite
##  normal form. (In other words: it triangulizes the product of <A>bas</A> with
##  <A>mat</A>.)
##  <P/>
##  <A>bas</A> must be given in Hermite normal form,
##  otherwise an error is triggered (see&nbsp;<Ref Sect="Action on canonical representatives"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OnSubspacesByCanonicalBasis");
DeclareGlobalFunction("OnSubspacesByCanonicalBasisConcatenations");


#############################################################################
##
#F  OnSubspacesByCanonicalBasisGF2(<bas>,<mat>)
##
##  <ManSection>
##  <Func Name="OnSubspacesByCanonicalBasisGF2" Arg='bas,mat'/>
##
##  <Description>
##  is a special version of <C>OnSubspacesByCanonicalBasis</C> for matrices over
##  GF2.
##  </Description>
##  </ManSection>
##
DeclareSynonym("OnSubspacesByCanonicalBasisGF2",OnSubspacesByCanonicalBasis);


#############################################################################
##
#A  CharacteristicPolynomial( [[<F>, <E>, ]<mat>[, <ind>] )
##
##  <#GAPDoc Label="CharacteristicPolynomial">
##  <ManSection>
##  <Attr Name="CharacteristicPolynomial" Arg='[F, E, ]mat[, ind]'/>
##
##  <Description>
##  For a square matrix <A>mat</A>, <Ref Attr="CharacteristicPolynomial"/>
##  returns the <E>characteristic polynomial</E> of <A>mat</A>, that is, the
##  <Ref Oper="StandardAssociate"/> of the determinant of the matrix
##  <M><A>mat</A> - X \cdot I</M>, where <M>X</M> is an indeterminate and
##  <M>I</M> is the appropriate identity matrix.
##  <P/>
##  If fields <A>F</A> and <A>E</A> are given, then <A>F</A> must be a
##  subfield of <A>E</A>, and <A>mat</A> must have entries in <A>E</A>.
##  Then <Ref Attr="CharacteristicPolynomial"/> returns the characteristic
##  polynomial of the <A>F</A>-linear mapping induced by <A>mat</A>
##  on the underlying <A>E</A>-vector space of <A>mat</A>. In this case,
##  the characteristic polynomial is computed using <Ref Func="BlownUpMat"/>
##  for the field extension of <M>E/F</M> generated by the default field.
##  Thus, if <M>F = E</M>, the result is the same as for the one argument
##  version.
##  <P/>
##  The returned polynomials are expressed in the indeterminate number
##  <A>ind</A>.  If <A>ind</A> is not given, it defaults to <M>1</M>.
##  <P/>
##  <C>CharacteristicPolynomial(<A>F</A>, <A>E</A>, <A>mat</A>)</C> is a
##  multiple of the  minimal polynomial
##  <C>MinimalPolynomial(<A>F</A>, <A>mat</A>)</C>
##  (see&nbsp;<Ref Oper="MinimalPolynomial"/>).
##  <P/>
##  Note that, up to &GAP; version 4.4.6,
##  <Ref Attr="CharacteristicPolynomial"/> only  allowed to specify one field
##  (corresponding to <A>F</A>) as an argument.
##  That usage has been disabled because its definition turned out to be
##  ambiguous and may have lead to unexpected results. (To ensure
##  backward compatibility, it is still possible to use the old form
##  if <A>F</A> contains the default field of the matrix,
##  see&nbsp;<Ref Attr="DefaultFieldOfMatrix"/>,
##  but this feature will disappear in future versions of &GAP;.)
##  <Example><![CDATA[
##  gap> CharacteristicPolynomial( [ [ 1, 1 ], [ 0, 1 ] ] );
##  x^2-2*x+1
##  gap> mat := [[0,1],[E(4)-1,E(4)]];;
##  gap> CharacteristicPolynomial( mat );
##  x^2+(-E(4))*x+(1-E(4))
##  gap> CharacteristicPolynomial( Rationals, CF(4), mat );
##  x^4+3*x^2+2*x+2
##  gap> mat:= [ [ E(4), 1 ], [ 0, -E(4) ] ];;
##  gap> CharacteristicPolynomial( mat );
##  x^2+1
##  gap> CharacteristicPolynomial( Rationals, CF(4), mat );
##  x^4+2*x^2+1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CharacteristicPolynomial", IsMatrix );
DeclareOperation( "CharacteristicPolynomial", [ IsMatrix, IsPosInt ] );
DeclareOperation( "CharacteristicPolynomial",
    [ IsRing, IsRing, IsMatrix, IsPosInt ] );
DeclareOperation( "CharacteristicPolynomial",
    [ IsRing, IsRing, IsMatrix ] );


#############################################################################
##
#O  CharacteristicPolynomialMatrixNC( <field>,<mat>,<indnum> )
##
##  <ManSection>
##  <Oper Name="CharacteristicPolynomialMatrixNC" Arg='field,mat,indnum'/>
##
##  <Description>
##  returns the characteristic polynomial for matrix <A>mat</A> which <E>must</E> be
##  defined over <A>field</A>. No tests are performed.
##  </Description>
##  </ManSection>
##
DeclareOperation("CharacteristicPolynomialMatrixNC",
  #IsField is not yet known
  [IsRing,IsOrdinaryMatrix,IsPosInt]);


#############################################################################
##
#O  MinimalPolynomialMatrixNC( <field>,<mat>,<indnum> )
##
##  <ManSection>
##  <Oper Name="MinimalPolynomialMatrixNC" Arg='field,mat,indnum'/>
##
##  <Description>
##  returns the minimal polynomial for matrix <A>mat</A> which <E>must</E> be
##  defined over field>. No tests are performed.
##  </Description>
##  </ManSection>
##
DeclareOperation("MinimalPolynomialMatrixNC",
  #IsField is not yet known
  [IsRing,IsOrdinaryMatrix,IsPosInt]);

#############################################################################
##
#O  FieldOfMatrixList( <matlist> )
##
##  <ManSection>
##  <Oper Name="FieldOfMatrixList" Arg='matlist'/>
##
##  <Description>
##  The smallest  field containing all the entries of all matrices in
##  <A>matlist</A>. As the algorithm must run through all matrix entries, this
##  can be hard.
##  </Description>
##  </ManSection>
##
DeclareOperation("FieldOfMatrixList",[IsListOrCollection]);

#############################################################################
##
#O  DefaultRingOfMatrixList( <matlist> )
##
##  <ManSection>
##  <Oper Name="DefaultScalarDomainOfMatrixList" Arg='matlist'/>
##
##  <Description>
##  For a list of matrices <A>matlist</A> this operation returns a ring
##  <M>R</M> such that all entries of the matrices lie in <M>R</M>. If
##  <M>R</M> has a quotient field that can be represented, this quotient
##  field is returned instead.
##  In general <M>R</R> is not chosen to be as small as possible, but to
##  be determined quickly without being unnecessarily large
##  (see <Ref Attr="DefaultFieldOfMatrix"/>).
##  </Description>
##  </ManSection>
##
DeclareOperation("DefaultScalarDomainOfMatrixList",[IsListOrCollection]);


#############################################################################
##
#O  BaseField( <matrixorvector> )
##
##  <ManSection>
##  <Oper Name="BaseField" Arg='matrixorvector'/>
##
##  <Description>
##  returns the base field of a matrix or a vector. This is only defined
##  for wrapped matrices and vectors, not for plain lists. That is, for
##  a plain list the operation returns fail. It is guaranteed
##  that a call to this operation is only a very fast lookup.
##  </Description>
##  </ManSection>
##
DeclareOperation("BaseField",[IsObject]);


#############################################################################
##
#O  SimplexMethod( <A>, <b>, <c> )
##
##  <#GAPDoc Label="SimplexMethod">
##  <ManSection>
##  <Func Name="SimplexMethod" Arg='A,b,c'/>
##
##  <Description>
##  Find a rational vector <A>x</A> that maximizes <M><A>x</A>\cdot<A>c</A></M>, subject
##  to the constraint <M><A>A</A>\cdot<A>x</A>\le<A>b</A></M>.
##  <Example><![CDATA[
##  gap> A:=[[3,1,1,4],[1,-3,2,3],[2,1,3,-1]];;
##  gap> b:=[12,7,10];;c:=[2,4,3,1];;
##  gap> SimplexMethod(A,b,c);
##  [ [ 0, 52/5, 0, 2/5 ], 42 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SimplexMethod" );

#############################################################################
##
#O  RationalCanonicalFormTransform( <mat> )
##
##  <#GAPDoc Label="RationalCanonicalFormTransform">
##  <ManSection>
##  <Func Name="RationalCanonicalFormTransform" Arg='mat'/>
##
##  <Description>
##  <Index>Frobenius Normal Form</Index>
##  For a matrix <C>A</C>, return a matrix <C>P</C> such that
##  <M>A^{P}</M> is in rational canonical form (also called
##  Frobenius normal form). The algorithm used is the basic textbook
##  version and thus not of optimal complexity.
##  <Example><![CDATA[
##  gap> aa:=[[0,-8,12,40,-36,4,0,59,15,-9],[-2,-2,-2,6,-11,1,-1,10,1,0],
##  > [1,5,0,-6,12,-2,0,-12,-4,2],[0,0,0,2,0,0,0,7,0,0],
##  > [0,2,-3,-7,8,-1,0,-7,-3,2],[-5,-4,-6,18,-30,2,-2,35,5,-1],
##  > [-1,-6,6,20,-28,3,0,24,10,-6],[0,0,0,-1,0,0,0,-3,0,0],
##  > [0,0,-1,-2,-2,0,-1,-7,0,0],[0,-8,9,21,-36,4,-2,12,12,-8]];;
##  gap> t:=RationalCanonicalFormTransform(aa);;
##  gap> aa^t;
##  [ [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ], [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
##    [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ],
##    [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ],
##    [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 1 ], [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ],
##    [ 0, 0, 0, 0, 0, 0, 0, 1, 0, -1 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 1, -1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RationalCanonicalFormTransform" );
