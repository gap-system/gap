#############################################################################
##
#W  ctblmoli.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.ctblmoli_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  MolienSeries( <psi> )
#F  MolienSeries( <psi>, <chi> )
#F  MolienSeries( <tbl>, <psi> )
#F  MolienSeries( <tbl>, <psi>, <chi> )
##
##  The *Molien series* of the character $\psi$, relative to the character
##  $\chi$, is the rational function given by the series
##  $$
##     M_{\psi,\chi}(z) = \sum_{d=0}^{\infty} [\chi,\psi^{[d]}] z^d
##  $$
##  where $\psi^{[d]}$ denotes the symmetrization of $\psi$ with the trivial
##  character of the symmetric group $S_d$ (see~"SymmetricParts").
##
##  `MolienSeries' returs the Molien series of <psi>, relative to <chi>,
##  where <psi> and <chi> must be characters of the same character table,
##  which must be entered as <tbl> if <chi> and <psi> are only lists of
##  character values.
##  The default for <chi> is the trivial character of <tbl>.
##
##  The return value of `MolienSeries' stores a value for the attribute
##  `MolienSeriesInfo' (see~"MolienSeriesInfo").
##  This admits the computation of coefficients of the series with
##  `ValueMolienSeries' (see~"ValueMolienSeries").
##  Furthermore, this attribute gives access to numerator and denominator
##  of the Molien series viewed as rational function,
##  where the denominator is a product of polynomials of the form
##  $(1-z^r)^k$; the Molien series is also displayed in this form.
##  Note that such a representation is not unique, one can use
##  `MolienSeriesWithGivenDenominator'
##  (see~"MolienSeriesWithGivenDenominator")
##  to obtain the series with a prescribed denominator.
##
##  For more information about Molien series, see~\cite{NPP84}.
##
DeclareGlobalFunction( "MolienSeries" );


#############################################################################
##
#F  MolienSeriesWithGivenDenominator( <molser>, <list> )
##
##  is a Molien series equal to <molser> as rational function,
##  but viewed as quotient with denominator
##  $\prod_{i=1}^n (1-z^{r_i})$, where $<list> = [ r_1, r_2, \ldots, r_n ]$.
##  If <molser> cannot be represented this way, `fail' is returned.
##
DeclareGlobalFunction( "MolienSeriesWithGivenDenominator" );


##############################################################################
##
#A  MolienSeriesInfo( <ratfun> )
##
##  If the rational function <ratfun> was constructed by `MolienSeries'
##  (see~"MolienSeries"),
##  a representation as quotient of polynomials is known such that the
##  denominator is a product of terms of the form $(1-z^r)^k$.
##  This information is encoded as value of `MolienSeriesInfo'.
##  Additionally, there is a special `PrintObj' method for Molien series
##  based on this.
##
##  `MolienSeriesInfo' returns a record that describes the rational function
##  <ratfun> as a Molien series.
##  The components of this record are
##  \beginitems
##  `numer' &
##       numerator of <ratfun> (in general a multiple of the numerator
##       one gets by `NumeratorOfRationalFunction'),
##
##  `denom' &
##       denominator of <ratfun> (in general a multiple of the denominator
##       one gets by `NumeratorOfRationalFunction'),
##
##  `ratfun' &
##       the rational function <ratfun> itself,
##
##  `numerstring' &
##       string corresponding to the polynomial `numer',
##       expressed in terms of `z',
##
##  `denomstring' &
##       string corresponding to the polynomial `denom',
##       expressed in terms of `z',
##
##  `denominfo' &
##       a list of the form $[ [ r_1, k_1 ], \ldots, [ r_n, k_n ] ]$
##       such that `denom' is $\prod_{i=1}^n (1-z^{r_i})^{k_i}$.
##
##  `summands' &
##       a list of records, each with the components `numer', `r', and `k',
##       describing the summand $`numer' / (1-z^r)^k$,
##  
##  `size' &
##       the order of the underlying matrix group,
##  
##  `degree' &
##       the degree of the underlying matrix representation.
##  \enditems
##
DeclareAttribute( "MolienSeriesInfo", IsRationalFunction );


#############################################################################
##
#F  CoefficientTaylorSeries( <numer>, <r>, <k>, <i> )
##
##  is the coefficient of $z^<i>$ in the Taylor series expansion of
##  the quotient of polynomials $p(z) / ( 1 - z^{<r>} )^{<k>}$,
##  where <numer> is the coefficients list of the numerator polynomial
##  $p(z)$.
##
DeclareGlobalFunction( "CoefficientTaylorSeries" );


#############################################################################
##
#F  SummandMolienSeries( <tbl>, <psi>, <chi>, <i> )
##
##  is the summand of the Molien series of the character table <tbl>,
##  for the characters <psi> and <chi>, that corresponds to class <i>.
##  That is, the returned value is the quotient
##  $$
##     \frac{\chi(g) \det(D(g))}{\det(z I - D(g))}
##  $$
##  where $g$ is in class <i>, $D$ is a representation with character <psi>,
##  and $z$ is the indeterminate.
##
##  The result is a record with components `numer' and `a', with the
##  following meaning.
##
##  Write the denominator as a product of cyclotomic polynomials,
##  encode this as a list `a' where at position $r$ the multiplicity
##  of the $r$-th cyclotomic polynomial $\Phi_r$ is stored.
##  (For that, we possibly must change the numerator.)
##  We get
##  $$
##     \frac{1}{\det(z I - D(g))}
##               = \frac{P(z)}{\prod_{d\mid n} \Phi_d^{a_d}(z)} .
##  $$
##
DeclareGlobalFunction( "SummandMolienSeries" );


#############################################################################
##
#F  ValueMolienSeries( <molser>, <i> )
##
##  is the <i>-th coefficient of the Molien series <series> computed by
##  `MolienSeries'.
##
DeclareGlobalFunction( "ValueMolienSeries" );


#############################################################################
##
#E

