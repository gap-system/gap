#############################################################################
##
#W  upoly.gd                 GAP Library                     Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains attributes, properties and operations for univariate
##  polynomials
##
Revision.upoly_gd:=
  "@(#)$Id$";

#############################################################################
##
#A  IrrFacsPol( <f> ) . . . lists of irreducible factors of polynomial over
##                        diverse rings
##
##  is used to store irreducible factorizations of the polynomial <f>. This
##  attribute is a list of the form [[<ring>,<factors>],...] where <factors> is
##  a list of the irreducible factors of <f> over <ring>.
##
DeclareAttribute("IrrFacsPol",IsPolynomial,"mutable");

#############################################################################
##
#O  FactorsSquarefree( <pring>, <upol> )
##
##  returns a squarefree factorization of <upoly> over the ring <pring>.
##  this function is used by factoring algorithms.
DeclareOperation("FactorsSquarefree",[IsPolynomialRing,
                                       IsUnivariatePolynomial]);

#############################################################################
##
#F  RootsOfUPol(<upol>) . . . . . . . . . . . . . . . . roots of a polynomial
##
##  This function returns a list of all roots of the univariate polynomial
##  <upol> in its default domain.
##
DeclareGlobalFunction("RootsOfUPol");

#############################################################################
##
#V  CYCLOTOMICPOLYNOMIALS . . . . . . . . . .  list of cyclotomic polynomials
##
##  global list encoding cyclotomic polynomials by their coefficients lists
##
DeclareGlobalVariable( "CYCLOTOMICPOLYNOMIALS",
    "list, at position n the coefficient list of the n-th cycl. pol." );
InstallFlushableValue( CYCLOTOMICPOLYNOMIALS, [] );


#############################################################################
##
#F  CyclotomicPol( <n> )  . . .  coefficients of <n>-th cyclotomic polynomial
##
##  is the coefficients list of the <n>-th cyclotomic polynomial over
##  the rationals.
##
DeclareGlobalFunction( "CyclotomicPol" );


#############################################################################
##
#F  CyclotomicPolynomial( <F>, <n> )  . . . . . .  <n>-th cycl. pol. over <F>
##
##  is the <n>-th cyclotomic polynomial over the ring <F>.
##
DeclareGlobalFunction( "CyclotomicPolynomial" );


#############################################################################
##
#E  upoly.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
