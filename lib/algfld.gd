#############################################################################
##
#W  algfld.gd                   GAP Library                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the categories,  attributes, properties and operations
##  for algebraic extensions of fields and their elements
Revision.algfld_gd:=
  "@(#)$Id$";

#############################################################################
##
#C  IsAlgebraicElement   Category for Elements of algebraic extension
##
IsAlgebraicElement := NewCategory( "IsAlgebraicElement", IsScalar);

#############################################################################
##
#C  IsAlgebraicElementsFamily    Category for Families of Algebraic Elements
##
IsAlgebraicElementsFamily := CategoryFamily( "IsAlgebraicElementsFamily",
				IsAlgebraicElement );

#############################################################################
##
#C  IsAlgebraicExtension    Category for Algebraic Extensions
##
IsAlgebraicExtension := NewCategory( "IsAlgebraicExtension", IsField );


#############################################################################
##
#A  AlgebraicElementsFamilies    List of AlgElm. families to one poly over
##                               different fields
##
AlgebraicElementsFamilies := NewAttribute( "AlgebraicElementsFamilies",
  IsUnivariatePolynomial, "mutable" );

#############################################################################
##
#O  AlgebraicElementsFamily   Create Family of alg elms
##
AlgebraicElementsFamily := NewOperation( "AlgebraicElementsFamily",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#O  AlgebraicExtension         of field by polynomial
##
AlgebraicExtension := NewOperation( "AlgebraicExtension",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#E  algfld.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
