#############################################################################
##
#A  matrices.gd             GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for generating matrices
##
#H  @(#)$Id: matrices.gd,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/matrices_gd") :=
    "@(#)$Id: matrices.gd,v 1.4 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  KrawtchoukMat( <n> [, <q>] )  . . . . . . .  matrix of Krawtchouk numbers
##
DeclareOperation("KrawtchoukMat", [IsInt, IsInt]); 

#############################################################################
##
#F  GrayMat( <n> [, <F>] )  . . . . . . . . .  matrix of Gray-ordered vectors
##
##  GrayMat(n [, F]) returns a matrix in which rows a(i) have the property
##  d( a(i), a(i+1) ) = 1 and a(1) = 0.
##
DeclareOperation("GrayMat", [IsInt, IsField]); 

#############################################################################
##
#F  SylvesterMat( <n> ) . . . . . . . . . . . . Sylvester matrix of order <n>
##
DeclareOperation("SylvesterMat", [IsInt]); 

#############################################################################
##
#F  HadamardMat( <n> )  . . . . . . . . . . . .  Hadamard matrix of order <n>
##
DeclareOperation("HadamardMat", [IsInt]); 

#############################################################################
##
#F  IsLatinSquare( <M> )  . . . . . . .  determines if matrix is latin square
##
##  IsLatinSquare determines if M is a latin square, that is a q*q array whose
##  entries are from a set of q distinct symbols such that each row and each
##  column of the array contains each symbol exactly once
##
DeclareOperation("IsLatinSquare", [IsMatrix]); 

#############################################################################
##
#F  AreMOLS( <matlist> )  . . . . . . . . .  determines if arguments are MOLS
##
##  AreMOLS(M1, M2, ...) determines if the arguments are mutually orthogonal
##  latin squares.
##
DeclareGlobalFunction("AreMOLS"); 

#############################################################################
##
#F  MOLS( <q> [, <n>] ) . . . . . . . . . .  list of <n> MOLS of size <q>*<q>
##
##  MOLS( q [, n]) returns a list of n Mutually Orthogonal Latin
##  Squares of size q * q. If n is omitted, MOLS will return a list
##  of two MOLS. If it is not possible to return n MOLS of size q,
##  MOLS will return a boolean false.
##
DeclareOperation("MOLS", [IsInt, IsInt]); 

#############################################################################
##
#F  VerticalConversionFieldMat( <M> ) . . . . . . .  converts matrix to GF(q)
##
##  VerticalConversionFieldMat (M) converts a matrix over GF(q^m) to a matrix
##  over GF(q) with vertical orientation of the tuples
##
DeclareOperation("VerticalConversionFieldMat", 
											[IsMatrix, IsField]); 

#############################################################################
##
#F  HorizontalConversionFieldMat( <M>, <F> )  . . .  converts matrix to GF(q)
##
##  HorizontalConversionFieldMat (M, F) converts a matrix over GF(q^m) to a
##  matrix over GF(q) with horizontal orientation of the tuples
##
DeclareOperation("HorizontalConversionFieldMat", 
												[IsMatrix, IsField]);  

#############################################################################
##
#F  IsInStandardForm( <M> [, <boolean>] ) . . . . is matrix in standard form?
##
##  IsInStandardForm(M [, identityleft]) determines if M is in standard form;
##  if identityleft = false, the identitymatrix must be at the right side
##  of M; otherwise at the left side.
##
DeclareOperation("IsInStandardForm", [IsMatrix, IsBool]);  

#############################################################################
##
#F  PutStandardForm( <M> [, <boolean>] [, <F>] )  .  put <M> in standard form
##
##  PutStandardForm(Mat [, idleft] [, F]) puts matrix Mat in standard form,
##  the size of Mat being (n x m). If idleft is true or is omitted, the
##  the identity matrix is put left, else right. The permutation is returned.
##
DeclareOperation("PutStandardForm", 
								[IsMatrix, IsBool, IsField]); 

