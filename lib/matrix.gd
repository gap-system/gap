#############################################################################
##
#W  matrix.gd                   GAP library                     Thoams Breuer
#W                                                             & Frank Celler
#W                                                         & Alexander Hulpke
#W                                                           & Heiko Theissen
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains those functions that mainly deal with matrices.
##
Revision.matrix_gd :=
    "@(#)$Id$";


#############################################################################
##

#V  InfoMatrix
##
InfoMatrix := NewInfoClass( "InfoMatrix" );


#############################################################################
##

#O  DiagonalOfMat( <mat> )
##
DiagonalOfMat := NewOperationArgs( "DiagonalOfMat" );


#############################################################################
##

#A  AbelianInvariantsOfList( <list> ) . . . . .  abelian invariants of a list
##
AbelianInvariantsOfList := NewAttribute(
    "AbelianInvariantsOfList",
    IsCyclotomicsCollection );


#############################################################################
##
#A  BaseMat( <mat> )  . . . . . . . . . .  base for the row space of a matrix
##
BaseMat := NewAttribute(
    "BaseMat",
    IsMatrix );


#############################################################################
##
#A  BaseOrthogonalSpaceMat( <mat> )
##
##  Let $V$ be the row space generated  by the rows of  <mat> (over any field
##  that contains all  entries of <mat>).  'BaseOrthogonalSpaceMat( <mat>  )'
##  computes a base of the orthogonal space of $V$.
##
##  The rows of <mat> need not be linearly independent.
##
#T Note that this means to transpose twice ...
##
BaseOrthogonalSpaceMat := NewAttribute(
    "BaseOrthogonalSpaceMat",
    IsMatrix );


#############################################################################
##
#A  DefaultFieldOfMatrix( <mat> )
##
##  is a field (not necessarily the smallest one) containing all entries
##  of the matrix <mat>.
##
DefaultFieldOfMatrix := NewAttribute(
    "DefaultFieldOfMatrix",
    IsMatrix );


#############################################################################
##
#A  DepthOfUpperTriangularMatrix( <mat> )
##
DepthOfUpperTriangularMatrix := NewAttribute(
    "DepthOfUpperTriangularMatrix",
    IsMatrix );


#############################################################################
##
#A  DeterminantMat( <mat> ) . . . . . . . . . . . . . determinant of a matrix
##
DeterminantMat := NewAttribute(
    "DeterminantMat",
    IsMatrix );


#############################################################################
##
#A  DimensionsMat( <mat> )  . . . . . . . . . . . . .  dimensions of a matrix
##
##  is a list of length 2, the first being the number of rows, the second
##  being the number of columns of the matrix <mat>.
##
DimensionsMat := NewAttribute(
    "DimensionsMat",
    IsMatrix );
SetDimensionsMat := Setter( DimensionsMat );
HasDimensionsMat := Tester( DimensionsMat );


#############################################################################
##
#A  ElementaryDivisorsMat(<mat>)  . . . . . . elementary divisors of a matrix
##
##  'ElementaryDivisors' returns a list of the elementary divisors, i.e., the
##  unique <d> with '<d>[<i>]' divides  '<d>[<i>+1]' and <mat> is  equivalent
##  to a diagonal matrix with the elements '<d>[<i>]' on the diagonal.
##
ElementaryDivisorsMat := NewAttribute(
    "ElementaryDivisorsMat",
    IsMatrix );


#############################################################################
##
#A  NullspaceMat( <mat> ) . . . . . . basis of solutions of <vec> * <mat> = 0
##
NullspaceMat := NewAttribute(
    "NullspaceMat",
    IsMatrix );


#############################################################################
##
#A  ProjectiveOrder( <mat> )
##
##  Return an integer n and a finite field element e such that <A>^n = eI.
##
ProjectiveOrder := NewAttribute(
    "ProjectiveOrder",
    IsMatrix );


#############################################################################
##
#A  RankMat( <mat> )  . . . . . . . . . . . . . . . . . . .  rank of a matrix
##
RankMat := NewAttribute(
    "RankMat",
    IsMatrix );


#############################################################################
##
#A  SemiEchelonMat( <mat> )
##
##  A matrix over a field $F$ is in semi-echelon form if the first nonzero
##  element in each row is the identity of $F$,
##  and all values exactly below these pivots are the zero of $F$.
##
##  'SemiEchelonMat' returns a record that contains information about
##  a semi-echelonized form of the matrix <mat>.
##
##  The components of this record are
##
##  'vectors': \\
##        list of row vectors, each with pivot element the identity of $F$,
##
##  'heads' : \\
##        list that contains at position <i>, if nonzero, the number of the
##        row for that the pivot element is in column <i>.
##
SemiEchelonMat := NewAttribute(
    "SemiEchelonMat",
    IsMatrix );


#############################################################################
##
#A  SemiEchelonMatTransformation( <mat> )
##
##  does the same as 'SemiEchelonMat' but additionally stores the linear
##  transformation $T$ performed on the matrix.
##  The additional components of the result are
##
##  'coeffs' : \\
##        a list of coefficients vectors of the 'vectors' component,
##        with respect to the rows of <mat>, that is, 'coeffs \*\ mat'
##        is the 'vectors' component.
##
##  'relations' : \\
##        a list of basis vectors for the (left) null space of <mat>.
##
SemiEchelonMatTransformation := NewAttribute(
    "SemiEchelonMatTransformation",
    IsMatrix );


#############################################################################
##
#A  SemiEchelonMats( <mats> )
##
##  A list of matrices over a field $F$ is in semi-echelon form if the
##  list of row vectors obtained on concatenating the rows of each matrix
##  is a semi-echelonized matrix (see "SemiEchelonMat").
##
##  'SemiEchelonMats' returns a record that contains information about
##  a semi-echelonized form of the list <mats> of matrices.
##
##  The components of this record are
##
##  'vectors': \\
##        list of matrices, each with pivot element the identity of $F$,
##
##  'heads' : \\
##        matrix that contains at position [<i>,<j>], if nonzero,
##        the number of the matrix for that the pivot element is in
##        this position
##
SemiEchelonMats := NewOperationArgs( "SemiEchelonMats" );


#############################################################################
##
#A  TransposedMat( <mat> )  . . . . . . . . . . . . .  transposed of a matrix
##
##  'TransposedMat'  returns the transposed of the  matrix <mat>, i.e., a new
##  matrix <trans> such that '<trans>[<i>][<k>] = <mat>[<k>][<i>]'.
##
TransposedMat := NewAttribute(
    "TransposedMat",
    IsMatrix );


############################################################################
##

#P  IsMonomialMatrix( <mat> )
##
##  A matrix is monomial if  and only if it  has exactly one nonzero entry in
##  every row and every column.
##
IsMonomialMatrix := NewProperty(
    "IsMonomialMatrix",
    IsMatrix );


#############################################################################
##

#O  InverseMatMod( <mat>, <obj> )
##
InverseMatMod := NewOperation(
    "InverseMatMod",
    [ IsMatrix, IsObject ] );


#############################################################################
##
#O  KroneckerProduct( <mat1>, <mat2> )
##
KroneckerProduct := NewOperation(
    "KroneckerProduct",
    [ IsMatrix, IsMatrix ] );


#############################################################################
##
#O  SolutionMat( <mat>, <vec> ) . . . . . . . . . .  one solution of equation
##
##  One solution <x> of <x> * <mat> = <vec> or 'fail'.
##
SolutionMat := NewOperation(
    "SolutionMat",
    [ IsMatrix, IsRowVector ] );


############################################################################
##
#O  SumIntersectionMat( <M1>, <M2> )  . .  sum and intersection of two spaces
##
##  performs  Zassenhaus'  algorithm to compute  bases  for  the sum  and the
##  intersection of spaces generated by the rows of the matrices <M1>, <M2>.
##
##  returns a list  of length 2,   at first position   a base of the sum,  at
##  second  position a  base   of the   intersection.   Both  bases  are   in
##  semi-echelon form.
##
SumIntersectionMat := NewOperation(
    "SumIntersectionMat",
    [ IsMatrix, IsMatrix ] );


#############################################################################
##
#O  TriangulizeMat( <mat> ) . . . . . bring a matrix in upper triangular form
##
TriangulizeMat := NewOperation(
    "TriangulizeMat",
    [ IsMatrix and IsMutable ] );


#############################################################################
##
#O  UpperSubdiagonal( <mat>, <pos> )
##
UpperSubdiagonal := NewOperation(
    "UpperSubdiagonal",
    [ IsMatrix, IsInt and IsPosRat ] );


#############################################################################
##

#F  BaseFixedSpace( <mats> )  . . . . . . . . . . . .  calculate fixed points
##
##  'BaseFixedSpace' returns a base of the vector space $V$ such that
##  $M v = v$ for all $v$ in $V$ and all matrices $M$ in the list <mats>.
##
BaseFixedSpace := NewOperationArgs( "BaseFixedSpace" );


#############################################################################
##
#F  BaseSteinitzVectors( <bas>, <mat> )
##
##  find vectors extending mat to a basis spanning the span of <bas>.
##
BaseSteinitzVectors := NewOperationArgs( "BaseSteinitzVectors" );


#############################################################################
##
#F  BlownUpMat( <B>, <mat> )
##
##  Let <B> be a basis of a field extension $F / K$, and <mat> a matrix whose
##  entries are all  in $F$.   'BlownUpMat' returns a  matrix  over $K$ where
##  each entry of  <mat> is replaced   by its regular representation w.r.  to
##  <B>.
##
##  In other words\:\
##  If we regard  <mat> as a  linear transformation  on the space  $F^n$ with
##  respect to the  $F$-basis with vectors  $(v_1, ldots, v_n)$, say, and  if
##  the basis <B>  has vectors $(b_1,  \ldots, b_m)$ then the returned matrix
##  is the linear transformation  on the space $K^{mn}$  with respect to  the
##  $K$-basis whose vectors are $(b_1 v_1, \ldots b_m v_1, \ldots, b_m v_n)$.
##
##  Note that the linear transformations act on *row* vectors, i.e., the rows
##  of the matrix contains vectors that consist of <B>-coefficients.
##
BlownUpMat := NewOperationArgs( "BlownUpMat" );


##########################################################################
##
#F  BlownUpVector( <B>, <vector> )
##
BlownUpVector := NewOperationArgs( "BlownUpVector" );


#############################################################################
##
#F  DiagonalizeIntMatNormDriven(<mat>)  . . . . diagonalize an integer matrix
##
##  'DiagonalizeIntMatNormDriven'  diagonalizes  the  integer  matrix  <mat>.
##
##  It tries to keep the entries small  through careful  selection of pivots.
##
##  First it selects a nonzero entry for which the  product of row and column
##  norm is minimal (this need not be the entry with minimal absolute value).
##  Then it brings this pivot to the upper left corner and makes it positive.
##
##  Next it subtracts multiples of the first row from the other rows, so that
##  the new entries in the first column have absolute value at most  pivot/2.
##  Likewise it subtracts multiples of the 1st column from the other columns.
##
##  If afterwards not  all new entries in the  first column and row are zero,
##  then it selects a  new pivot from those  entries (again driven by product
##  of norms) and reduces the first column and row again.
##
##  If finally all offdiagonal entries in the first column  and row are zero,
##  then it  starts all over again with the submatrix  '<mat>{[2..]}{[2..]}'.
##
##  It is  based  upon  ideas by  George Havas  and code by  Bohdan Majewski.
##  G. Havas and B. Majewski, Integer Matrix Diagonalization, JSC, to appear
##
DiagonalizeIntMatNormDriven := NewOperationArgs(
    "DiagonalizeIntMatNormDriven" );

DiagonalizeIntMat := DiagonalizeIntMatNormDriven;


#############################################################################
##
#F  DiagonalizeMat(<mat>) . . . . . . . . . . . . . . .  diagonalize a matrix
##
#T 1996/05/06 mschoene should be extended for other rings
##
DiagonalizeMat := DiagonalizeIntMat;


#############################################################################
##
#F  IdentityMat( <m> [, <F>] )  . . . . . . . identity matrix of a given size
#F  MutableIdentityMat( <m> [, <F>] ) . . . . identity matrix of a given size
##
##  `IdentityMat' returns an immutable matrix.
##
IdentityMat := NewOperationArgs( "IdentityMat" );

MutableIdentityMat := NewOperationArgs( "MutableIdentityMat" );


#############################################################################
##
#F  MutableTransposedMat( <mat> ) . . . . . . . . . .  transposed of a matrix
##
##  'MutableTransposedMat'  returns the transposed of  the  matrix <mat> as a
##  mutable matrix, i.e., a new matrix <trans> such that '<trans>[<i>][<k>] =
##  <mat>[<k>][<i>]'.
##
MutableTransposedMat := NewOperationArgs( "MutableTransposedMat" );


#############################################################################
##
#F  NullMat( <m>, <n> [, <F>] ) . . . . . . . . . null matrix of a given size
#F  MutableNullMat( <m>, <n> [, <F>] )  . . . . . null matrix of a given size
##
##  `NullMat' returns an immutable matrix.
##
NullMat := NewOperationArgs( "NullMat" );

MutableNullMat := NewOperationArgs( "MutableNullMat" );


#############################################################################
##
#F  NullspaceModQ( <E>, <q> ) . . . . . . . . . . . .nullspace of <E> mod <q>
##
##  <E> must be a matrix of integers modulo <q> and <q> a prime power.
##  Then 'NullspaceModQ' returns the set of all vectors of integers modulo
##  <q>, which solve the homogeneous equation system given by <E> modulo <q>.
##
NullspaceModQ := NewOperationArgs( "NullspaceModQ" );


#############################################################################
##
#F  PermutationMat( <perm>, <dim> [, <F> ] ) . . . . . .  permutation matrix
##
PermutationMat := NewOperationArgs( "PermutationMat" );


#############################################################################
##
#F  DiagonalMat( <vector> ) . . . . . . . . . . . . . . . . . diagonal matrix
##
DiagonalMat := NewOperationArgs( "DiagonalMat" );


#############################################################################
##
#F  ReflectionMat( <coeffs> )
#F  ReflectionMat( <coeffs>, <root> )
#F  ReflectionMat( <coeffs>, <conj> )
#F  ReflectionMat( <coeffs>, <conj>, <root> )
##
##  Let <coeffs> be a row vector.
##  'ReflectionMat' returns the matrix of the reflection in this vector.
##
##  More precisely, if <coeffs> is the coefficients of a vector $v$ w.r.t. a
##  basis $B$, say, then the returned matrix describes the reflection in $v$
##  w.r.t. $B$ as a map on a row space, with action from the right.
##
##  The optional argument <root> is a root of unity that determines the order
##  of the reflection.  The default is a reflection of order 2.
##  For triflections one should choose a third root of unity etc.
##
##  <conj> is a function of one argument that conjugates a ring element.
##  The default is 'ComplexConjugate'.
##
##  The matrix of the reflection in $v$ is defined as
##  \[ M = I_n + \overline{v^{tr}} \cdot \frac{w-1}{v \overline{v^{tr}}}
##                                 \cdot v \]
##  where '$w$ = root',
##  $n$ is the length of our coefficients list,
##  and $\overline{\ }$ denotes the conjugation.
##
ReflectionMat := NewOperationArgs( "ReflectionMat" );


#############################################################################
##
#F  RandomInvertibleMat( <m> [, <R>] )  . . . make a random invertible matrix
##
##  'RandomInvertibleMat'  returns a invertible  random  matrix with <m> rows
##  and  columns with  elements  taken from the ring  <R>,  which defaults to
##  'Integers'.
##
RandomInvertibleMat := NewOperationArgs( "RandomInvertibleMat" );


#############################################################################
##
#F  RandomMat( <m>, <n> [, <R>] ) . . . . . . . . . . .  make a random matrix
##
##  'RandomMat' returns a  random matrix with  <m> rows and  <n> columns with
##  elements taken from the ring <R>, which defaults to 'Integers'.
##
RandomMat := NewOperationArgs( "RandomMat" );


#############################################################################
##
#F  RandomUnimodularMat( <m> )  . . . . . . . . . .  random unimodular matrix
##
RandomUnimodularMat := NewOperationArgs( "RandomUnimodularMat" );


#############################################################################
##
#F  SimultaneousEigenvalues( <matlist>, <expo> ) . . . . . . . . .eigenvalues
##
##  The  matgroup  generated  by <matlist>  must  be  an  abelian p-group  of
##  exponent <expo>.  The matrices in  matlist must  be matrices over GF(<q>)
##  for some prime <q>. Then the eigenvalues of <mat>  in the splitting field
##  GF(<q>^r) for some r are powers of an element ksi in the splitting field,
##  which is of order  <expo>.  'SimultaneousEigenspaces' returns a matrix of
##  intergers  mod <expo>, say (a_{i,j}),  such that the power ksi^a_{i,j} is
##  an eigenvalue of the i-th matrix in  <matlist> and the eigenspaces of the
##  different matrices to the eigenvalues ksi^a_{i,j} for fixed j are equal.
##
SimultaneousEigenvalues := NewOperationArgs( "SimultaneousEigenvalues" );


#############################################################################
##
#F  TraceMat( <mat> ) . . . . . . . . . . . . . . . . . . . trace of a matrix
##
##  belongs to the attribute 'Trace'
##
TraceMat := NewOperationArgs( "TraceMat" );


#############################################################################
##
#F  FlatBlockMat( <blockmat> ) . . . . . . . . convert block matrix to matrix
##
FlatBlockMat := NewOperationArgs( "FlatBlockMat" );


#############################################################################
##
#F  BlownUpMat( <mat>, <K> )  . . . . . . . extend matrix by field extension
##
BlownUpMat := NewOperationArgs( "BlownUpMat" );


#############################################################################
##

#F  EmptyMatrix( <fam>, <m>, <n> )
##
EmptyMatrix := NewOperationArgs( "EmptyMatrix" );
EmptyMatrixConstructor := NewOperationArgs( "EmptyMatrixConstructor" );


#############################################################################
##

#E  matrix.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
