#############################################################################
##
#W  polyconw.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of functions and data around
##  Conway polynomials.
##
Revision.polyconw_gd :=
    "@(#)$Id$";


###############################################################################
##
#F  PowerModEvalPol( <f>, <g>, <xpownmodf> )
##
##  computes the coefficients list of the polynomial $g( x^n ) \bmod f$, for
##  the given coefficients lists of the two polynomials $f$ and $g$, and the
##  coefficients list of $x^n \bmod f$.
##
##  We evaluate $g$ at $x^n \bmod f$, and use Horner\'s method and reduction
##  modulo $f$ for computing the result.
##  If $g = \sum_{i=0}^k g_i x^i$ then we compute
##  $( \cdots (((c_k x^n + c_{k-1}) x^n + c_{k-2}) x^n + c_{k-3}) x^n
##   + \cdots c_0$.
##
##  (this function is used in `ConwayPol'.)
##
DeclareGlobalFunction( "PowerModEvalPol" );


############################################################################
##
#V  CONWAYPOLYNOMIALS
##
##  is a list that stores at position $p$, if bound,
##  a list $l$ describing Conway polynomials in characteristic $p$.
##  The $n$-th entry of $l$, if bound, is a list $[ i_0, i_1, \ldots, i_k ]$
##  of integers such that the Conway polynomial for the field with $p^n$
##  elements is $i_0 + i_1 X + \cdots + i_k X^k + X^n$.
##
DeclareGlobalVariable( "CONWAYPOLYNOMIALS" );


############################################################################
##
#F  ConwayPol( <p>, <n> ) . . . . . <n>-th Conway polynomial in charact. <p>
##
DeclareGlobalFunction( "ConwayPol" );


############################################################################
##
#F  ConwayPolynomial( <p>, <n> ) .  <n>-th Conway polynomial in charact. <p>
##
##  is the Conway polynomial of the finite field $GF(p^n)$ as
##  polynomial over the prime field in characteristic <p>.
##
##  The *Conway polynomial* $\Phi_{n,p}$ of $GF(p^n)$ is defined by the
##  following properties.
##
##  First define an ordering of polynomials of degree $n$ over $GF(p)$ as
##  follows.  $f = \sum_{i=0}^n (-1)^i f_i x^i$ is smaller than
##  $g = \sum_{i=0}^n (-1)^i g_i x^i$ if and only if there is an index
##  $m \leq n$ such that $f_i = g_i$ for all $i > m$, and
##  $\tilde{f_m} \< \tilde{g_m}$, where $\tilde{c}$ denotes the integer
##  value in $\{ 0, 1, \ldots, p-1 \}$ that is mapped to $c\in GF(p)$ under
##  the canonical epimorphism that maps the integers onto $GF(p)$.
##
##  $\Phi_{n,p}$ is *primitive* over $GF(p)$ (see~"IsPrimitivePolynomial").
##  That is, $\Phi_{n,p}$ is irreducible, monic,
##  and is the minimal polynomial of a primitive root of $GF(p^n)$.
##
##  For all divisors $d$ of $n$ the compatibility condition
##  $\Phi_{d,p}( x^{\frac{p^n-1}{p^m-1}} ) \equiv 0 \pmod{\Phi_{n,p}(x)}$
##  holds.
##
##  With respect to the ordering defined above, $\Phi_{n,p}$ shall be
##  minimal.
##
DeclareGlobalFunction( "ConwayPolynomial" );


#############################################################################
##
#E

