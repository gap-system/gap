#############################################################################
##
#W  upoly.gd                 GAP Library                     Alexander Hulpke
##
#H  @(#)$Id: 
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains attributes, properties and operations for univariate
##  polynomials
##
Revision.upoly_gd:=
  "@(#)$Id$";

#############################################################################
##
#O  Value( <upol>, <elm> )
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
#I  InfoPoly
##
InfoPoly := NewInfoClass( "InfoPoly" );

#############################################################################
##
#E  upoly.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
