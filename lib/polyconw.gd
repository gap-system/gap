#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of functions and data around
##  Conway polynomials.
##


###############################################################################
##
#F  PowerModEvalPol( <f>, <g>, <xpownmodf> )
##
##  <ManSection>
##  <Func Name="PowerModEvalPol" Arg='f, g, xpownmodf'/>
##
##  <Description>
##  computes the coefficients list of the polynomial <M>g( x^n ) \bmod f</M>,
##  for the given coefficients lists of the two polynomials <M>f</M> and
##  <M>g</M>, and the coefficients list of <M>x^n \bmod f</M>.
##  <P/>
##  We evaluate <M>g</M> at <M>x^n \bmod f</M>, and use Horner's method and
##  reduction modulo <M>f</M> for computing the result.
##  If <M>g = \sum_{i=0}^k g_i x^i</M> then we compute
##  <M>( \cdots (((c_k x^n + c_{k-1}) x^n + c_{k-2}) x^n + c_{k-3}) x^n
##   + \cdots ) x^n + c_0</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PowerModEvalPol" );



############################################################################
##
#F  ConwayPol( <p>, <n> ) . . . . . <n>-th Conway polynomial in charact. <p>
##
##  <ManSection>
##  <Func Name="ConwayPol" Arg='p, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ConwayPol" );


############################################################################
##
#F  ConwayPolynomial( <p>, <n> ) .  <n>-th Conway polynomial in charact. <p>
##
##  <#GAPDoc Label="ConwayPolynomial">
##  <ManSection>
##  <Func Name="ConwayPolynomial" Arg='p, n'/>
##
##  <Description>
##  is the Conway polynomial of the finite field <M>GF(p^n)</M> as
##  polynomial over the prime field in characteristic <A>p</A>.
##  <P/>
##  The <E>Conway polynomial</E> <M>\Phi_{{n,p}}</M> of <M>GF(p^n)</M>
##  is defined by the following properties.
##  <P/>
##  First define an ordering of polynomials of degree <M>n</M> over
##  <M>GF(p)</M>, as follows.
##  <M>f = \sum_{{i = 0}}^n (-1)^i f_i x^i</M> is smaller than
##  <M>g = \sum_{{i = 0}}^n (-1)^i g_i x^i</M> if and only if there is an index
##  <M>m \leq n</M> such that <M>f_i = g_i</M> for all <M>i > m</M>, and
##  <M>\tilde{{f_m}} &lt; \tilde{{g_m}}</M>,
##  where <M>\tilde{{c}}</M> denotes the integer value in
##  <M>\{ 0, 1, \ldots, p-1 \}</M> that is mapped to <M>c \in GF(p)</M> under
##  the canonical epimorphism that maps the integers onto <M>GF(p)</M>.
##  <P/>
##  <M>\Phi_{{n,p}}</M> is <E>primitive</E> over <M>GF(p)</M>
##  (see&nbsp;<Ref Oper="IsPrimitivePolynomial"/>).
##  That is, <M>\Phi_{{n,p}}</M> is irreducible, monic,
##  and is the minimal polynomial of a primitive root of <M>GF(p^n)</M>.
##  <P/>
##  For all divisors <M>d</M> of <M>n</M> the compatibility condition
##  <M>\Phi_{{d,p}}( x^{{\frac{{p^n-1}}{{p^m-1}}}} ) \equiv 0
##  \pmod{{\Phi_{{n,p}}(x)}}</M>
##  holds. (That is, the appropriate power of a zero of <M>\Phi_{{n,p}}</M>
##  is a zero of the Conway polynomial <M>\Phi_{{d,p}}</M>.)
##  <P/>
##  With respect to the ordering defined above, <M>\Phi_{{n,p}}</M> shall be
##  minimal.
##  <P/>
##  The computation of Conway polynomials can be time consuming. Therefore,
##  &GAP; comes with a list of precomputed polynomials. If a requested
##  polynomial is not stored then &GAP; prints a warning and computes it by
##  checking all polynomials in the order defined above for the defining
##  conditions.
##  If <M>n</M> is not a prime this is probably a very long computation.
##  (Some previously known polynomials with prime <M>n</M> are not stored in
##  &GAP; because they are quickly recomputed.)
##  Use the function <Ref Func="IsCheapConwayPolynomial"/> to check in
##  advance if <Ref Func="ConwayPolynomial"/> will give a result after a
##  short time.
##  <P/>
##  Note that primitivity of a polynomial can only be checked if &GAP; can
##  factorize <M>p^n-1</M>.
##  A sufficiently new version of the <Package>FactInt</Package>
##  package contains many precomputed factors of such numbers from various
##  factorization projects.
##  <P/>
##  See&nbsp;<Cite Key="L03"/> for further information on known
##  Conway polynomials.
##  <P/>
##  An interactive overview of the Conway polynomials known to &GAP; is
##  provided by the function <C>BrowseConwayPolynomials</C> from the
##  &GAP; package <Package>Browse</Package>,
##  see <Ref Func="BrowseGapData" BookName="browse"/>.
##  <P/>
##  <Index Key="InfoText"
##         Subkey="(for Conway polynomials)"><C>InfoText</C></Index>
##  If <A>pol</A> is a result returned by <Ref Func="ConwayPolynomial"/> the
##  command <C>Print( InfoText( <A>pol</A> ) );</C> will print some info on
##  the origin of that particular polynomial.
##  <P/>
##  For some purposes it may be enough to have any primitive polynomial for
##  an extension of a finite field instead of the Conway polynomial,
##  see&nbsp;<Ref Func="RandomPrimitivePolynomial"/> below.
##  <Example><![CDATA[
##  gap> ConwayPolynomial( 2, 5 );  ConwayPolynomial( 3, 7 );
##  x_1^5+x_1^2+Z(2)^0
##  x_1^7-x_1^2+Z(3)^0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConwayPolynomial" );

############################################################################
##
#F  IsCheapConwayPolynomial( <p>, <n> ) . . . tell if Conway polynomial is cheap to obtain
##
##  <#GAPDoc Label="IsCheapConwayPolynomial">
##  <ManSection>
##  <Func Name="IsCheapConwayPolynomial" Arg='p, n'/>
##
##  <Description>
##  Returns <K>true</K> if <C>ConwayPolynomial( <A>p</A>, <A>n</A> )</C>
##  will give a result in <E>reasonable</E> time.
##  This is either the case when this polynomial is pre-computed,
##  or if <A>n</A> is a not too big prime.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsCheapConwayPolynomial" );

############################################################################
##
#F  RandomPrimitivePolynomial( <F>, <n>[, <i> ] ) . . . . . random primitive polynomial over finite field
##
##  <#GAPDoc Label="RandomPrimitivePolynomial">
##  <ManSection>
##  <Func Name="RandomPrimitivePolynomial" Arg='F, n[, i ]'/>
##
##  <Description>
##  For a finite field <A>F</A> and a positive integer <A>n</A> this function
##  returns a primitive polynomial of degree <A>n</A> over <A>F</A>,
##  that is a zero of  this polynomial has maximal multiplicative order
##  <M>|<A>F</A>|^n-1</M>.
##  If <A>i</A> is given then the polynomial is written in variable number
##  <A>i</A> over <A>F</A>
##  (see&nbsp;<Ref Oper="Indeterminate" Label="for a ring (and a number)"/>),
##  the default for <A>i</A> is 1.
##  <P/>
##  Alternatively, <A>F</A> can be a prime power q, then <A>F</A> = GF(q) is
##  assumed.
##  And <A>i</A> can be a univariate polynomial over <A>F</A>,
##  then the result is a polynomial in the same variable.
##  <P/>
##  This function can work for much larger fields than those for which
##  Conway polynomials are available, of course &GAP; must be able to
##  factorize <M>|<A>F</A>|^n-1</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomPrimitivePolynomial" );
