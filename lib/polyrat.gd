#############################################################################
##
#W  polyrat.gd                 GAP Library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains attributes, properties and operations for univariate
##  polynomials over the rationals
##
Revision.polyrat_gd:=
  "@(#)$Id$";
#############################################################################
##
#F  APolyProd(<a>,<b>,<p>)   . . . . . . . . . . polynomial product a*b mod p
##
##  return a*b mod p;
DeclareGlobalFunction("APolyProd");

#############################################################################
##
#F  BPolyProd(<a>,<b>,<m>,<p>) . . . . . . polynomial product a*b mod m mod p
##
##  return EuclideanRemainder(PolynomialRing(Rationals),a*b mod p,m) mod p;
DeclareGlobalFunction("BPolyProd");

#############################################################################
##
#F  PrimitivePolynomial( <f> )
##
##  takes a polynomial <f> with rational coefficients and computes a new
##  polynomial with integral coefficients, obtained by multiplying with the
##  Lcm of the denominators of the coefficients and casting out the content
##  (the Gcd of the coefficients). The operation returns a list
##  [<newpol>,<coeff>] with rational <coeff> such that
##  `<coeff>\*<newpol>=<f>'.
##
DeclareOperation("PrimitivePolynomial",[IsPolynomial]);

#############################################################################
##
#F  BombieriNorm(<pol>)
##
## computes weighted Norm [pol]_2 of <pol> which is a good measure for
## factor coeffietients (see \cite{BTW93}).
##
DeclareGlobalFunction("BombieriNorm");

#############################################################################
##
#A  MinimizedBombieriNorm( <f> ) . . . Tschirnhaus transf'd polynomial
##
##  This function applies linear Tschirnhaus transformations 
##  ($x \mapsto x + i$) to the
##  polynomial <f>, trying to get the Bombieri norm of <f> small. It returns a
##  list `[<new_polynomial>, <i_of_transformation>]'.
##
DeclareAttribute("MinimizedBombieriNorm",
   IsPolynomial and IsRationalFunctionsFamilyElement);

#############################################################################
##
#F  RootBound(<f>)
##
##  returns the bound for the norm of (complex) roots of the rational 
##  univariate polynomial <f>.
##
DeclareGlobalFunction("RootBound");

#############################################################################
##
#F  OneFactorBound(<pol>)
##
##  returns the coefficient bound for a single factor of the rational 
##  polynomial <pol>.
##
DeclareGlobalFunction("OneFactorBound");

#############################################################################
##
#F  HenselBound(<pol>,[<minpol>,<den>]) . . . Bounds for Factor coefficients
##
##  returns the Hensel bound of the polynomial <pol>.
##  If the computation takes place over an algebraic extension, then
##  the minimal polynomial <minpol> and denominator <den> must be given.
##
DeclareGlobalFunction("HenselBound");

#############################################################################
##
#F  TrialQuotientRPF(<f>,<g>,<b>)
##
##  returns $<f>/<g>$ if coefficient bounds are given by list <b>.
##
DeclareGlobalFunction("TrialQuotientRPF");

#############################################################################
##
#F  TryCombinations(<f>,...)
##
##  trial divisions after Hensel factoring.
DeclareGlobalFunction("TryCombinations");

DeclareGlobalFunction("HeuGcdIntPolsExtRep"); # to permit recursive call
DeclareGlobalFunction("HeuGcdIntPolsCoeffs"); # univariate version

#############################################################################
##
#E  polyrat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
