#############################################################################
##
#W  algfld.gd                   GAP Library                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St  Andrews, Scotland
##
##  This file contains the categories,  attributes, properties and operations
##  for algebraic extensions of fields and their elements
Revision.algfld_gd:=
  "@(#)$Id$";

#############################################################################
##
#C  IsAlgebraicElement(<obj>)
##
##  is the category for elements of an algebraic extension.
DeclareCategory( "IsAlgebraicElement", IsScalar);
DeclareCategoryCollections( "IsAlgebraicElement");

#############################################################################
##
#C  IsAlgebraicElementFamily     Category for Families of Algebraic Elements
##
DeclareCategoryFamily( "IsAlgebraicElement" );

#############################################################################
##
#C  IsAlgebraicExtension(<obj>)
##
##  is the category of algebraic extensions of fields.
DeclareCategory( "IsAlgebraicExtension", IsField );


#############################################################################
##
#A  AlgebraicElementsFamilies    List of AlgElm. families to one poly over
##                               different fields
##
DeclareAttribute( "AlgebraicElementsFamilies",
  IsUnivariatePolynomial, "mutable" );

#############################################################################
##
#O  AlgebraicElementsFamily   Create Family of alg elms
##
DeclareOperation( "AlgebraicElementsFamily",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#O  AlgebraicExtension(<K>,<f>)
##
##  constructs an extension <L> of the field <K> by one root of the irreducible
##  polynomial <f>, using Kronecker{\pif}s construction. <L> is a
##  field whose `LeftActingDomain' is <K>. The  polynomial <p> is the
##  `DefiningPolynomial' of <L> and the attribute `RootOfDefiningPolynomial'
##  of <L> holds a root of <f> in <L> (see~"RootOfDefiningPolynomial").
DeclareOperation( "AlgebraicExtension",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#F  MaxNumeratorCoeffAlgElm(<a>)
##
##  maximal (absolute value, in numerator) 
##  coefficient in the representation of algebraic elm. <a>
##
DeclareOperation("MaxNumeratorCoeffAlgElm",[IsScalar]);

#############################################################################
##
#E  algfld.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
