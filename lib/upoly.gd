#############################################################################
##
#W  upoly.gd                 GAP Library                     Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains attributes, properties and operations for univariate
##  polynomials
##
Revision.upoly_gd:=
  "@(#)$Id$";

#############################################################################
##
#A  SplittingField(<f>)
##
##  returns the smallest field which contains the coefficients of <f> and
##  the roots of <f>.
DeclareAttribute("SplittingField",IsPolynomial);

#############################################################################
##
#A  IrrFacsPol( <f> ) . . . lists of irreducible factors of polynomial over
##                        diverse rings
##
##  is used to store irreducible factorizations of the polynomial <f>.
##  The values of this attribute are lists of the form
##  `[ [ <R>, <factors> ], ... ]' where <factors> is
##  a list of the irreducible factors of <f> over the coefficients ring <R>.
##
DeclareAttribute("IrrFacsPol",IsPolynomial,"mutable");

#############################################################################
##
#F  StoreFactorsPol( <pring>, <upol>, <factlist> ) . . . . store factors list
##
DeclareGlobalFunction("StoreFactorsPol");


#############################################################################
##
#O  FactorsSquarefree( <pring>, <upol>, <opt> )
##
##  returns a factorization of the squarefree, monic, univariate polynomial
##  <upoly> in the polynomial ring <pring>;
##  <opt> must be a (possibly empty) record of options.
##  <upol> must not have zero as a root.
##  This function is used by the factoring algorithms.
##
DeclareOperation("FactorsSquarefree",[IsPolynomialRing,
                                       IsUnivariatePolynomial, IsRecord ]);

#############################################################################
##
#F  RootsOfUPol(<upol>)
#F  RootsOfUPol(<field>,<upol>)
#F  RootsOfUPol("split",<upol>)
##
##  This function returns a list of all roots of the univariate polynomial
##  <upol> in its default domain. If <field> is given the roots over <field>
##  are taken, if the first parameter is the string `"split"' the field is
##  taken to be the splitting field of the polynomial.
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
#O  IsPrimitivePolynomial( <F>, <pol> )
##
##  For a univariate polynomial <pol> of degree $d$ in the indeterminate $X$,
##  with coefficients in a finite field <F> with $q$ elements, say,
##  `IsPrimitivePolynomial' returns `true' if
##  \beginlist%ordered
##  \item{1.}
##      <pol> divides $X^{q^d-1} - 1$, and
##  \item{2.}
##      for each prime divisor $p$ of $q^d - 1$, <pol> does not divide
##      $X^{(q^d-1)/p} - 1$,
##  \endlist
##  and `false' otherwise.
##
DeclareOperation( "IsPrimitivePolynomial", [ IsField, IsRationalFunction ] );


#############################################################################
##
#F  CompanionMat( <poly> )
##
##  computes a companion matrix of the polynomial <poly>. This matrix has
##  <poly> as its minimal polynomial.
DeclareGlobalFunction( "CompanionMat" );

#############################################################################
##
#F  AllIrreducibleMonicPolynomials( <degree>, <field> )
##
DeclareGlobalFunction( "AllIrreducibleMonicPolynomials" );

#############################################################################
##
#E

