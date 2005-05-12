#############################################################################
##
#W  matint.gd                GAP library                        A. Storjohann
#W                                                              R. Wainwright
#W                                                                  A. Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2003 The GAP Group
##
##  This file contains declarations for the operations of normal forms for
##  integral matrices.
##
Revision.matint_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoMatInt
##
##  The info class for Integer matrix operations is `InfoMatInt'.
##
DeclareInfoClass( "InfoMatInt" );

#############################################################################
##
#O  TriangulizedIntegerMat(<mat>)
##
##  Computes an upper triangular form of a matrix with integer entries.
##  It returns a immutable matrix in upper triangular form.
DeclareOperation("TriangulizedIntegerMat",[IsMatrix]);

#############################################################################
##
#O  TriangulizeIntegerMat(<mat>)
##
##  Changes <mat> to be in upper triangular form. (The result is the same as
##  that of `TriangulizedIntegerMat', but <mat> will be modified, thus using
##  less memory.)
##  If <mat> is immutable an error will be triggered.
DeclareOperation("TriangulizeIntegerMat",[IsMatrix]);

#############################################################################
##
#O  TriangulizedIntegerMatTransform(<mat>)
##
##  Computes an upper triangular form of a matrix with integer entries.
##  It returns a record with a component `normal' (an immutable matrix in
##  upper triangular form) and a component `rowtrans' that gives the
##  transformations done to the original matrix to bring it into upper
##  triangular form.
DeclareOperation("TriangulizedIntegerMatTransform",[IsMatrix]);
DeclareSynonym("TriangulizedIntegerMatTransforms",
  TriangulizedIntegerMatTransform);

#############################################################################
##
#O  HermiteNormalFormIntegerMat(<mat>)
##
##  This operation computes the Hermite normal form of a matrix <mat> with
##  integer entries. It returns a immutable matrix in HNF.
DeclareOperation("HermiteNormalFormIntegerMat",[IsMatrix]);

#############################################################################
##
#O  HermiteNormalFormIntegerMatTransform(<mat>)
##
##  This operation computes the Hermite normal form of a matrix <mat> with
##  integer entries. It returns a record with components `normal' (a matrix
##  $H$) and `rowtrans' (a matrix $Q$) such that $QA=H$
DeclareOperation("HermiteNormalFormIntegerMatTransform",[IsMatrix]);
DeclareSynonym("HermiteNormalFormIntegerMatTransforms",
  HermiteNormalFormIntegerMatTransform);


#############################################################################
##
#O  SmithNormalFormIntegerMat(<mat>)
##
##  This operation computes the Smith normal form of a matrix <mat> with
##  integer entries. It returns a new immutable matrix in the Smith normal
##  form.
DeclareOperation("SmithNormalFormIntegerMat",[IsMatrix]);

#############################################################################
##
#O  SmithNormalFormIntegerMatTransforms(<mat>)
##
##  This operation computes the Smith normal form of a matrix <mat> with
##  integer entries. It returns a record with components `normal' (a matrix
##  $S$), `rowtrans' (a matrix $P$), and `coltrans' (a matrix $Q$) such that
##  $PAQ=S$.
DeclareOperation("SmithNormalFormIntegerMatTransforms",[IsMatrix]);


#############################################################################
##
#O  DiagonalizeIntMat(<mat>)
##
##  This function changes <mat> to its SNF.
##  (The result is the same as
##  that of `SmithNormalFormIntegerMat', but <mat> will be modified, thus using
##  less memory.)
##  If <mat> is immutable an error will be triggered.
DeclareGlobalFunction( "DiagonalizeIntMat" );

#############################################################################
##
#O  NormalFormIntMat (<mat>, <options>)
##
##  This general operation for computation of various Normal Forms
##  is probably the most efficient.  
##
##  Options bit values:
##  \beginlist
##  \item{0/1} Triangular Form / Smith Normal Form.
##
##  \item{2}   Reduce off diagonal entries.
##
##  \item{4}   Row Transformations.
##
##  \item{8}   Col Transformations.
##
##  \item{16}   Destructive (the original matrix may be destroyed)
##  \endlist
##
##  Compute a Triangular, Hermite or Smith form of the $n \times m$ 
##  integer input matrix $A$.  Optionally, compute $n \times n$ and 
##  $m \times m$ unimodular transforming matrices $Q, P$ which satisfy 
##  $QA = H$ or $QAP = S$.
##  %The routines used are based on work by Arne Storjohann
##  %and were implemented in {\GAP}~4 by A.~Storjohann and R.~Wainwright.
##  
##  Note option is a value ranging from 0 - 15 but not all options make sense 
##  (eg reducing off diagonal entries with SNF option selected already).  
##  If an option makes no sense it is ignored.
##
##  Returns a record with component `normal' containing the
##  computed normal form and optional components `rowtrans' 
##  and/or `coltrans' which hold the respective transformation matrix.
##  Also in the record are components holding  the sign of the determinant, 
##  signdet, and the Rank of the matrix, rank.
##
DeclareGlobalFunction("NormalFormIntMat");

#############################################################################
##
#A  BaseIntMat( <mat> )
##
##  If <mat> is a matrix with integral entries, this function returns a
##  list of vectors that forms a basis of the integral row space of <mat>, 
##  i.e. of the set of integral linear combinations of the rows of <mat>.
## 
DeclareAttribute( "BaseIntMat", 
  IsMatrix and IsCyclotomicCollColl );

#############################################################################
##
#A  BaseIntersectionIntMats( <m>,<n> )
##
##  If <m> and <n> are matrices with integral entries, this function returns a
##  list of vectors that forms a basis of the intersection of the integral
##  row spaces of <m> and <n>.
## 
DeclareOperation( "BaseIntersectionIntMats", 
  [IsMatrix and IsCyclotomicCollColl,
   IsMatrix and IsCyclotomicCollColl] );

#############################################################################
##
#A  ComplementIntMat( <full>,<sub> )
##
##  Let <full> be a list of integer vectors generating an Integral
##  module <M> and <sub> a list of vectors defining a submodule <S>. 
##  This function computes a free basis for <M> that extends <S>. 
##  I.e., if the dimension of <S> is <n> it
##  determines a basis $B=\{\underline{b}_1,\ldots,\underline{b}_m\}$ for <M>,
##  as well as <n> integers $x_i$ such that the <n> vectors
##  $\underline{s}_i:=x_i\cdot \underline{b}_i\}$ form a basis for <S>.
##
##  It returns a record with the following
##  components:
##  \beginitems
##  `complement' &
##     the vectors $\underline{b}_{n+1}$ up to $\underline{b}_m$ (they
##     generate a complement to <S>).
##
##  `sub' &
##     the vectors $s_i$ (a basis for <S>).
##
##  `moduli' &
##     the factors $x_i$.
##
##  \enditems
DeclareOperation( "ComplementIntMat", 
  [IsMatrix and IsCyclotomicCollColl,
   IsMatrix and IsCyclotomicCollColl] );

#############################################################################
##
#A  NullspaceIntMat( <mat> )
##
##  If <mat> is a matrix with integral entries, this function returns a
##  list of vectors that forms a basis of the integral nullspace of <mat>, i.e.
##  of those vectors in the nullspace of <mat> that have integral entries.
## 
DeclareAttribute( "NullspaceIntMat", 
  IsMatrix and IsCyclotomicCollColl );

#############################################################################
##
#O  SolutionIntMat( <mat>,<vec> )
##
##  If <mat> is a matrix with integral entries and <vec> a vector with
##  integral entries, this function returns a vector <x> with integer entries
##  that is a solution of the equation `<x> * <mat> = <vec>'. It returns `fail'
##  if no such vector exists.
## 
DeclareOperation( "SolutionIntMat", 
  [IsMatrix and IsCyclotomicCollColl,
    IsList and IsCyclotomicCollection]);

#############################################################################
##
#O  SolutionNullspaceIntMat( <mat>,<vec> )
##
##  This function returns a list of length two, its first entry being the
##  result of a call to `SolutionIntMat' with same arguments, the second the
##  result of `NullspaceIntMat' applied to the matrix <mat>.
##  The calculation is performed faster than if two separate calls would be
##  used.
## 
DeclareOperation( "SolutionNullspaceIntMat", 
  [IsMatrix and IsCyclotomicCollColl,
    IsList and IsCyclotomicCollection]);

#############################################################################
##
#A  AbelianInvariantsOfList( <list> ) . . . . .  abelian invariants of a list
##
##  Given a list of positive integers, this routine returns a list of prime
##  powers, such that the prime power factors of the entries in the list are
##  returned in sorted form.
DeclareAttribute( "AbelianInvariantsOfList", IsCyclotomicCollection );

#############################################################################
##
#O  DeterminantIntMat(<mat>)
##
##  Computes the determinant of an integer matrix using the  
##  same strategy as `NormalFormIntMat' (see~"NormalFormIntMat").
##  This method is 
##  faster in general for matrices greater than $20 \times 20$ but 
##  quite a lot slower for smaller matrices.  It therefore passes 
##  the work to the more general `DeterminantMat' (see~"DeterminantMat")
##  for these smaller matrices.
##
DeclareGlobalFunction("DeterminantIntMat");

# ``technical'' routines.

#############################################################################
##
#O  SNFofREF (<mat>,<destroy>)
##
##  Computes the Smith Normal Form of an integer matrix in row echelon 
##  (RE) form.
##  If <destroy> is set to `true' <mat> will be changed in-place.
##  Caveat -- No testing is done to ensure that <mat> is in RE form.  
##
DeclareGlobalFunction("SNFofREF");



# #############################################################################
# ##
# #E  matint.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
# ##
