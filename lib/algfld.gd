#############################################################################
##
#W  algfld.gd                   GAP Library                  Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the categories,  attributes, properties and operations
##  for algebraic extensions of fields and their elements
Revision.algfld_gd:=
  "@(#)$Id$";

#############################################################################
##
#C  IsAlgebraicElement(<obj>)
##
##  is the category for elements of an algebraic extension
DeclareCategory( "IsAlgebraicElement", IsScalar);

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
##  polynomial <f>, using {\sc Kronecker{\pif}s} construction. <L> is a
##  field whose `LeftActingDomail' is <K>. The `PrimitiveElement' (see
##  "PrimitiveElement"). of <L> is a root of <f>.
DeclareOperation( "AlgebraicExtension",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#E  algfld.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
