#############################################################################
##
#W  polyconw.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  holds. (That is, the appropriate power of a zero of $\Phi_{n,p}$ is a
##  zero of the Conway polynomial $\Phi_{d,p}$.)
##
##  With respect to the ordering defined above, $\Phi_{n,p}$ shall be
##  minimal.
##  
##  The computation of Conway polynomials can be time consuming. Therefore,
##  {\GAP} comes with a list of precomputed polynomials. If a requested
##  polynomial is not stored then {\GAP} prints a warning and computes it by
##  checking all polynomials in the order defined above for the defining
##  conditions. If $n$ is not a prime this is probably a very long computation.
##  (Some previously known polynomials with prime $n$ are not stored in
##  {\GAP} because they are quickly recomputed.) Use the function 
##  "IsCheapConwayPolynomial" to check in advance if `ConwayPolynomial' will
##  give a result after a short time.
##  
##  Note that primitivity of a polynomial can only be checked if {\GAP} can
##  factorize $p^n-1$. A sufficiently new version of the \package{FactInt}
##  package contains many precomputed factors of such numbers from various
##  factorization projects.
##  
##  See~\cite{L03} for further information on known Conway polynomials.
##  
##  If <pol> is a result returned by `ConwayPolynomial' the command
##  `Print( InfoText( <pol> ) );' will print some info on the origin of that
##  particular polynomial.
##  
##  For some purposes it may be enough to have any primitive polynomial for
##  an extension of a finite field instead of the Conway polynomial, 
##  see~"ref:RandomPrimitivePolynomial" below.
##  
DeclareGlobalFunction( "ConwayPolynomial" );

############################################################################
##
#F  IsCheapConwayPolynomial( <p>, <n> ) . . . tell if Conway polynomial is cheap to obtain
##  
##  Returns `true' if `ConwayPolynomial( <p>, <n> )' will give a result in
##  *reasonable* time. This is either the case when this polynomial is
##  pre-computed, or if <n> is a not too big prime.
##  
DeclareGlobalFunction( "IsCheapConwayPolynomial" );

############################################################################
##
#F  RandomPrimitivePolynomial( <F>, <n>[, <i> ] ) . . . . . random primitive polynomial over finite field 
##
##  For a finite field <F> and a positive integer <n> this function
##  returns a primitive polynomial of degree <n> over <F>, that is a zero of 
##  this polynomial has maximal multiplicative order $|<F>|^n-1$. 
##  If <i> is given then the polynomial is written in variable number <i>
##  over <F> (see~"ref:Indeterminate"), the default for <i> is 1.
##  
##  Alternatively, <F> can be a prime power q, then <F> = GF(q) is assumed.
##  And <i> can be a univariate polynomial over <F>, then the result is a
##  polynomial in the same variable.
##  
##  This function can work for much larger fields than those for which
##  Conway polynomials are available, of course {\GAP} must be able to
##  factorize $|<F>|^n-1$.
##  
DeclareGlobalFunction( "RandomPrimitivePolynomial" );

#############################################################################
##
#E

