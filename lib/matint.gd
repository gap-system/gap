#############################################################################
##
#W  matint.gd                GAP library                    A. Hulpke,  R. Wainwright.
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  St. Andrews
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#O  SNFNormDriven(<mat>[,<trans>])
#O  SNFChouCollins(<mat>[,<trans>])
#O  SNFLLLDriven(<mat>[,<trans>])
##
##  These operations compute the Smith normal form of a matrix with
##  integer entries, using the strategy specified in the name. If no optional 
##  argument <trans> is given <mat> must be a mutable matrix which will 
##  be changed by the algorithm.
##
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as:
##
##  1 - Row transformations.
##
##  2 - Inverse row transformations.
##
##  4 - Column transformations.
##
##  8 - Inverse column transformations.
##
##  The operation then returns a record with the component `normal' containing 
##   the  computed normal form and optional components `rowtrans', `rowinverse',
##  `coltrans', and `invcoltrans' which hold the computed transformation
##  matrices. Note if <trans> is given the operation does not change <mat>.
##
##  This functionality is still to be fully implemented for SNF with transforms.  
##   However, NormalFormIntMat performs this calculation.
##
DeclareGlobalFunction("SNFNormDriven");
DeclareGlobalFunction("SNFChouCollins");
DeclareGlobalFunction("SNFLLLDriven");


#############################################################################
##
#O  HNFNormDriven(<mat>[,<trans>[,<reduction>]])
#O  HNFChouCollins(<mat>[,<trans>[,<reduction>]])
#O  HNFLLLDriven(<mat>[,<trans>[,<reduction>]])
##
##  These operations compute the Hermite normal form of a matrix with
##  integer entries, using the strategy specified in the name. If no optional 
##  argument <trans> is given <mat> must be a  mutable matrix which will 
##  be changed by the algorithm.
##
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as
##  for the Smith normal form (see "SNFNormDriven") but note that only 
##  row operations are performed. The function then returns a  record with 
##  components as specified for the Smith normal form.
##
##  If the further optional argument <reduction> ( a rational in the range [0..1] )
##  is given, it specifies which representatives
##  are used for entries modulo $c$ when cleaning column entries to the top. 
##  Off diagonal entries are reduced to the range
##  \quad$\lfloor c(r-1)\rfloor\ldots \lfloor cr\rfloor$
##  If r is not given, a value of 1 is assumed.
##  Note if <trans> is given the operation does not change <mat>.
##
## \beginexample
##    gap> m:=[ [ 14, 20 ], [ 6, 9 ] ];;
##    gap> HNFNormDriven(m);
##    [ [ 2, 2 ], [ 0, 3 ] ]
##    gap> m;
##    [ [ 2, 2 ], [ 0, 3 ] ]
##
##   gap> m:=[[14,20],[6,9]];; 
##   gap> HNFNormDriven(m,1);
##   rec( normal := [ [ 2, 2 ], [ 0, 3 ] ], rowtrans := [ [ 1, -2 ], [ -3, 7 ] ] )
##   gap> m;
##   [ [ 14, 20 ], [ 6, 9 ] ]
##   gap> last2.rowtrans*m;
##   [ [ 2, 2 ], [ 0, 3 ] ]
##
## \endexample
##
DeclareGlobalFunction("HNFNormDriven");
DeclareGlobalFunction("HNFChouCollins");
DeclareGlobalFunction("HNFLLLDriven");


#############################################################################
##
#O  TriangulizeIntegerMat(<mat>[,<trans>])
##
##  Computes an upper triangular form of a matrix with integer entries.
##  If no optional  argument <trans> is given <mat> must be a
##  mutable matrix which will be changed by the algorithm.
##
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as
##  for the Smith normal form (see "SNFNormDriven") but note that only 
##  row operations are performed. The function then returns a record with 
##  components as specified for the Smith normal form.
##  Note if <trans> is given the operation does not change <mat>.
##
DeclareGlobalFunction("TriangulizeIntegerMat");


#############################################################################
##
#O  SmithNormalFormIntegerMat(<mat>)
#O  SmithNormalFormIntegerMatTransforms(<mat>)
#O  SmithNormalFormIntegerMatInverseTransforms(<mat>)
##
##  The Smith Normal Form,$S$, of an integer matrix $A$ is the unique 
##  equivalent diagonal form with $S_i$ dividing $S_j$ for $i \< j$. There 
##  exist unimodular integer matrices $P,Q$ such that $PAQ=S.$ 
##
##  These operations compute the Smith normal form of a matrix <mat> with
##  integer entries. The operations will try to select a suitable strategy.
##  The first operation returns a new immutable matrix in the Smith normal
##  form. The other  operations also compute matrices for the row and
##  column transformations or inverses thereof respectively.
##  They return a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans' and `coltrans', or 
##  `invrowtrans' and `invcoltrans' which hold the computed transformation
##  matrices.
##
## \beginexample
##    gap> m:=[[14,20],[6,9]];
##    [ [ 14, 20 ], [ 6, 9 ] ]
##    gap> SmithNormalFormIntegerMat(m);
##    [ [ 1, 0 ], [ 0, 6 ] ]
## \endexample
##
DeclareOperation("SmithNormalFormIntegerMat",[IsMatrix]);
DeclareOperation("SmithNormalFormIntegerMatTransforms",[IsMatrix]);
DeclareOperation("SmithNormalFormIntegerMatInverseTransforms",[IsMatrix]);


#############################################################################
##
#O  HermiteNormalFormIntegerMat(<mat>[,<reduction>])
#O  HermiteNormalFormIntegerMatTransforms(<mat>[,<reduction>])
#O  HermiteNormalFormIntegerMatInverseTransforms(<mat>[,<reduction>])
##
##  The Hermite Normal Form, $H$ of an integer matrix, $A$  is a row equivalent
##  upper triangular form such that all off-diagonal entries are reduced modulo
##  the diagonal entry of the column they are in.  There exists a unique 
##  unimodular matrix $Q$ such that $QA=H$. 
##
##  These operations compute the Hermite normal form of a matrix <mat> with
##  integer entries. The operations will try to select a suitable strategy.
##  The first operation returns a immutable matrix which is the Hermite normal
##  form of <mat>. 
##
##  The other two operations also compute matrices for the row 
##  transformations or inverses respectively.
##  They return a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans' or 'invrowtrans'
##  which hold the computed transformation matrix.
##
##  If the optional argument <reduction> ( a rational in the range [0..1] )
##  is given, it specifies which representatives are used for entries modulo $c$ 
##  when cleaning column entries to the top. 
##  Off diagonal entries are reduced to the range
##  \quad$\lfloor c(r-1)\rfloor\ldots \lfloor cr\rfloor$
##  If it is not given, a value of 1 is assumed.
##
## \beginexample
##    gap> m;
##    [ [ 14, 20 ], [ 6, 9 ] ]
##    gap> HermiteNormalFormIntegerMat(m);
##    [ [ 2, 2 ], [ 0, 3 ] ]
##    gap> HermiteNormalFormIntegerMatTransforms(m);
##    rec( normal := [ [ 2, 2 ], [ 0, 3 ] ], rowtrans := [ [ 1, -2 ], [ -3, 7 ] ] )
## \endexample
##
DeclareOperation("HermiteNormalFormIntegerMat",[IsMatrix]);
DeclareOperation("HermiteNormalFormIntegerMatTransforms",[IsMatrix]);
DeclareOperation("HermiteNormalFormIntegerMatInverseTransforms",[IsMatrix]);

#############################################################################
##
#O  TriangulizedIntegerMat(<mat>[,<trans>])
#O  TriangulizedIntegerMatTransform(<mat>[,<trans>])
#O  TriangulizedIntegerMatInverseTransform(<mat>[,<trans>])
##
##  The first operation computes a row equivalent upper triangular form 
##  of a matrix <mat> with integer entries.  It returns an immutable 
##  matrix in upper  triangular form.
##
##  The other two operations also compute matrices for the row 
##  transformations or inverses respectively.
##  They return a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans' or `invrowtrans'
##  which hold the computed transformation matrix.
##
DeclareOperation("TriangulizedIntegerMat",[IsMatrix]);
DeclareOperation("TriangulizedIntegerMatTransforms",[IsMatrix]);
DeclareOperation("TriangulizedIntegerMatInverseTransforms",[IsMatrix]);



#############################################################################
##
#O  SNFofREF (<mat>)
##
##   Computes the Smith Normal Form of an integer matrix in row echelon form.
##   Caveat - No testing is done to ensure that <mat> is in REF.  
##
DeclareGlobalFunction("SNFofREF");


#############################################################################
##
#O  NormalFormIntMat (<mat>, <options>)
##
##  This general operation for computation of various Normal Forms
##  is probably the most efficient.  
##
##  Options bit values:
##
##  0/1  - Triangular Form / Smith Normal Form.
##
##  2  - Reduce off diagonal entries.
##
##  4  - Row Transformations.
##
##  8  - Col Transformations.
##
##  Compute a Triangular, Hermite or Smith form of the n x m 
##  integer input matrix A.  Optionally, compute n x n / m x m
##  unimodular transforming matrices Q,P which satisfy QA = H 
##  or  QAP = S.  The routines used are based on work by Arne Storjohahn
##  and were implemented in GAP4 by A. Storjohahn and R. Wainwright.
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
## \beginexample
##    gap> m:=[[14,20],[6,9]];;
##    gap> NormalFormIntMat(m,0);  #Triangular, no transforms
##    rec( normal := [ [ 2, 2 ], [ 0, 3 ] ], rank := 2, signdet := 1 )
##
##    gap> NormalFormIntMat(m,6);  #Hermite Normal Form with row transforms
##    rec( normal := [ [ 2, 2 ], [ 0, 3 ] ], rank := 2, signdet := 1, 
##      rowtrans := [ [ 1, -2 ], [ -3, 7 ] ] )
##
##    gap> NormalFormIntMat(m,13); #Smith Normal Form with both transforming matrices
##    rec( normal := [ [ 1, 0 ], [ 0, 6 ] ], rank := 2, signdet := 1, 
##      rowtrans := [ [ -11, 25 ], [ -15, 34 ] ], 
##      coltrans := [ [ 1, -5 ], [ 1, -4 ] ] )
##    gap> last.rowtrans*m*last.coltrans;
##    [ [ 1, 0 ], [ 0, 6 ] ]
## \endexample
##
DeclareGlobalFunction("NormalFormIntMat");


#############################################################################
##
#O  DeterminantIntMat(<mat>)
##
##  Computes the determinant of an integer matrix using the  
##  same strategy as NormalFormIntMat.  This method is 
##  faster in general for matrices greater than 20x20 but 
##  quite a lot slower for smaller matrices.  It therefore passes 
##  the work to the more general DeterminantMat for these
##  smaller matrices.
##
DeclareGlobalFunction("DeterminantIntMat");




#############################################################################
##
#E  normalf.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
