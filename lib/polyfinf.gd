#############################################################################
##
#W  polyfinf.gd                 GAP Library                      Frank Celler
#W                                                         & Alexander Hulpke
##
##
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains functions for polynomials over finite fields
##

#############################################################################
##
#F  FactorsCommonDegreePol( <R>, <f>, <d> ) . . . . . . . . . . . . . factors
##
##  <f> must be a  square free product of  irreducible factors of  degree <d>
##  and leading coefficient 1.  <R>  must be a polynomial  ring over a finite
##  field of size p^k.
##
DeclareGlobalFunction("FactorsCommonDegreePol");

#############################################################################
##
#F  RootsRepresentativeFFPol( <R>, <f>, <n> )
##
##  returns a <n>-th root of the finite field polynomial <f>.
DeclareGlobalFunction("RootsRepresentativeFFPol");

#############################################################################
##
#F  OrderKnownDividendList( <l>, <pp> )	. . . . . . . . . . . . . . . . local
##
##  Computes  an  integer  n  such  that  OnSets( <l>, n ) contains  only one
##  element e.  <pp> must be a list of prime powers of an integer d such that
##  n divides d. The functions returns the integer n and the element e.
##
DeclareGlobalFunction("OrderKnownDividendList");

#############################################################################
##
#F  FFPOrderKnownDividend( <R>, <g>, <f>, <pp> )  . . . . . . . . . . . local
##
##  Computes an integer n such that <g>^n = const  mod <f> where <g>  and <f>
##  are polynomials in <R> and <pp> is list  of prime powers of  an integer d
##  such that n divides  d.   The  functions  returns  the integer n  and the
##  element const.
DeclareGlobalFunction("FFPOrderKnownDividend");

DeclareGlobalFunction("FFPFactors");

