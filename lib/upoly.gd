#############################################################################
##
#W  upoly.gd                 GAP Library                     Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains attributes, properties and operations for univariate
##  polynomials
##
Revision.upoly_gd:=
  "@(#)$Id$";


#############################################################################
##
#I  InfoPoly
##
InfoPoly := NewInfoClass( "InfoPoly" );


#############################################################################
##
#O  Value( <upol>, <elm> )
#O  Value( <upol>, <elm>, <one> )
##
##  The optional third argument <one> is a multiplicative neutral element
##  that shall be taken instead of the zero-th power of <elm>.
##
Value := NewOperation("Value",[IsRationalFunction,IsRingElement]);


#############################################################################
##
#O  LeadingCoefficient( <upol> )
##
LeadingCoefficient := NewOperation("LeadingCoefficient",
                      [IsUnivariateLaurentPolynomial]);

#############################################################################
##
#A  IrrFacsPol( <f> ) . . . lists of irreducible factors of polynomial over
##                        diverse rings
##
IrrFacsPol := NewAttribute("IrrFacsPol",IsPolynomial,"mutable");
#SetIrrFacsPol := Setter(IrrFacsPol);

#############################################################################
##
#O  Derivative( <upol> )
##
Derivative := NewOperation("Derivative",[IsUnivariateLaurentPolynomial]);

#############################################################################
##
#O  FactorsSquarefree( <pring>, <upol> )
##
FactorsSquarefree := NewOperation("FactorsSquarefree",[IsPolynomialRing,
                                       IsUnivariatePolynomial]);

#############################################################################
##
#V  CYCLOTOMICPOLYNOMIALS . . . . . . . . . .  list of cyclotomic polynomials
##
##  global list encoding cyclotomic polynomials by their coefficients lists
##
CYCLOTOMICPOLYNOMIALS := [];


#############################################################################
##
#F  CyclotomicPol( <n> )  . . .  coefficients of <n>-th cyclotomic polynomial
##
##  is the coefficients list of the <n>-th cyclotomic polynomial over
##  the rationals.
##
CyclotomicPol := NewOperationArgs( "CyclotomicPol" );


#############################################################################
##
#F  CyclotomicPolynomial( <F>, <n> )  . . . . . .  <n>-th cycl. pol. over <F>
##
##  is the <n>-th cyclotomic polynomial over the ring <F>.
##
CyclotomicPolynomial := NewOperationArgs( "CyclotomicPolynomial" );


#############################################################################
##
#E  upoly.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
