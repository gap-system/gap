#############################################################################
##
#W  matint.gd                GAP library                    Alexander Hulpke
#W                                                             Rob Wainwright
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
  "@(#)$$";


#############################################################################
##
#O  SNFNormDriven(<mat>[,<trans>])
#O  SNFChouCollins(<mat>[,<trans>])
#O  SNFLLLDriven(<mat>[,<trans>])
##
##  These operations compute the Smith normal form of a matrix with
##  integer entries, using the strategy specified in the name. <mat> must be a
##  mutable matrix which will be changed by the algorithm.
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as:
##  \par\noindent
##  1\quad row transformations\par\noindent
##  2\quad inverse row transformations\par\noindent
##  4\quad column transformations\par\noindent
##  8\quad inverse column transformations\par\noindent
##  The operation returns a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans', `rowinverse',
##  `columntrans', and `columninverse' which hold the computed transformation
##  matrices.
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
##  integer entries, using the strategy specified in the name. <mat> must be a
##  mutable matrix which will be changed by the algorithm.
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as
##  for the Smith normal form (see "SNFNormDriven"). The function returns a
##  record with components as specified for the Smith normal form as well.
##  If the further optional argument <reduction> ( a rational in the range [0..1] )
##  is given, it specifies which representatives
##  are used for entries modulo $c$ when cleaning column entries to the top. 
##  Off diagonal entries are reduced to the range
##  \hphantom{-}\quad$\lfloor c(1-r)\rfloor\ldots \lfloor cr\rfloor$
##  If it is not given, a value of 1 is assumed.
DeclareGlobalFunction("HNFNormDriven");
DeclareGlobalFunction("HNFChouCollins");
DeclareGlobalFunction("HNFLLLDriven");


#############################################################################
##
#O  TriangulizeIntegerMat(<mat>[,<trans>])
##
##  computes an upper triangular form of a matrix with integer entries.
##  <mat> must be a
##  mutable matrix which will be changed by the algorithm.
##  If the optional integer argument <trans> is given, it determines which
##  transformation matrices will be computed. It is interpreted binary as
##  for the Smith normal form (see "SNFNormDriven"). The function returns a
##  record with components as specified for the Smith normal form as well.
DeclareGlobalFunction("TriangulizeIntegerMat");


#############################################################################
##
#O  SmithNormalFormIntegerMat(<mat>)
#O  SmithNormalFormIntegerMatTransforms(<mat>)
#O  SmithNormalFormIntegerMatColumnTransforms(<mat>)
#O  SmithNormalFormIntegerMatInverseColumnTransforms(<mat>)
##
##  These operations compute the Smith normal form of a matrix <mat> with
##  integer entries. The operations will try to select a suitable strategy.
##  The first operation returns a new immutable matrix in the Smith normal
##  form. The other three operations also compute matrices for the row and
##  column transformations or inverses respectively.
##  They return a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans',
##  `columntrans', and `columninverse' which hold the computed transformation
##  matrices.
DeclareOperation("SmithNormalFormIntegerMat",[IsMatrix]);
DeclareOperation("SmithNormalFormIntegerMatTransforms",[IsMatrix]);
#DeclareOperation("SmithNormalFormIntegerMatColumnTransforms",[IsMatrix]);
#DeclareOperation("SmithNormalFormIntegerMatInverseColumnTransforms",[IsMatrix]);


#############################################################################
##
#O  HermiteNormalFormIntegerMat(<mat>[,<reduction>])
#O  HermiteNormalFormIntegerMatTransforms(<mat>[,<reduction>])
#O  HermiteNormalFormIntegerMatInverseTransforms(<mat>[,<reduction>])
##
##  These operations compute the Hermite normal form of a matrix <mat> with
##  integer entries. The operations will try to select a suitable strategy.
##  The first operation returns a immutable matrix in the Hermite normal
##  form. The other two operations also compute matrices for the row 
##  transformations or inverses respectively.
##  They return a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans' or `rowinverse'
##  which hold the computed transformation matrix.
##  If the optional argument <reduction> ( a rational in the range [0..1] )
##  is given, it specifies which representatives
##  are used for entries modulo $c$ when cleaning column entries to the top. 
##  Off diagonal entries are reduced to the range
##  \hphantom{-}\quad$\lfloor c(1-r)\rfloor\ldots \lfloor cr\rfloor$
##  If it is not given, a value of 1 is assumed.
DeclareOperation("HermiteNormalFormIntegerMat",[IsMatrix]);
DeclareOperation("HermiteNormalFormIntegerMatTransforms",[IsMatrix]);
#DeclareOperation("HermiteNormalFormIntegerMatInverseTransforms",[IsMatrix]);

#############################################################################
##
#O  TriangulizedIntegerMat(<mat>[,<trans>])
#O  TriangulizedIntegerMatTransform(<mat>[,<trans>])
#O  TriangulizedIntegerMatInverseTransform(<mat>[,<trans>])
##
##  The first operation computes an upper triangular form of a matrix
##  <mat> with integer entries.
##  It returns an immutable matrix in upper triangular form.
##  The other two operations also compute matrices for the row 
##  transformations or inverses respectively.
##  They return a record with the component `normal' containing the
##  computed normal form and optional components `rowtrans' or `rowinverse'
##  which hold the computed transformation matrix.
DeclareOperation("TriangulizedIntegerMat",[IsMatrix]);
DeclareOperation("TriangulizedIntegerMatTransforms",[IsMatrix]);
#DeclareOperation("TriangulizedIntegerMatInverseTransforms",[IsMatrix]);

#############################################################################
##
#E  normalf.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
