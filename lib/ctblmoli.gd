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
##  \[ \frac{\chi(g) \det(D(g))}{\det(z I - D(g))} \]
##  where $g$ is in class <i>, $D$ is a representation with character <psi>,
##  and $z$ is the indeterminate.
##
##  The result is a record with components 'numer' and 'a', with the
##  following meaning.
##
##  Write the denominator as a product of cyclotomic polynomials,
##  encode this as a list 'a' where at position $r$ the multiplicity
##  of the $r$-th cyclotomic polynomial $\Phi_r$ is stored.
##  (For that, we possibly must change the numerator.)
##  We get
##  \[ \frac{1}{\det(z I - D(g))}
##               = \frac{P(z)}{\prod_{d\mid n} \Phi_d^{a_d}(z)} \ . \]
##
DeclareGlobalFunction( "SummandMolienSeries" );


##############################################################################
##
#A  MolienSeriesInfo( <ratfun> )
##
##  If the rational function <ratfun> was constructed by 'MolienSeries',
##  a representation as quotient of polynomials is known such that the
##  denominator is a product of terms of the form $(1-z^r)^k$.
##  Since this is of particular interest in invariant theory, this
##  information is encoded as value of 'MolienSeriesInfo'.
##  Additionally, there is a special 'PrintObj' method for Molien series
##  based on this.
##
##  'MolienSeriesInfo' returns a record that describes the rational function
##  <ratfun> as a Molien series.
##  The components of this record are
##  
##  'summands'
##       a list of records with components 'numer', 'r', and 'k',
##       describing the summand $'numer' / (1-z^r)^k$,
##  
##  'size'
##       the order of the underlying group,
##  
##  'degree'
##       the degree of the character <psi>,
##
##  'pol'
##       polynomial summand of the series
#T       (always zero?)
##
DeclareAttribute( "MolienSeriesInfo", IsRationalFunction );


#############################################################################
##
#F  MolienSeries( <psi> )
#F  MolienSeries( <psi>, <chi> )
#F  MolienSeries( <tbl>, <psi> )
#F  MolienSeries( <tbl>, <psi>, <chi> )
##
##  is the rational function given by the series
##  \[ M_{\psi,\chi}(z) = \sum_{d=0}^{\infty} (\chi,\psi^{[d]}) z^d \]
##  where $\psi^{[d]}$ denotes the symmetrization of $\psi$ with the trivial
##  character of the symmetric group $S_d$ (see "SymmetricParts").
##
##  <psi> and <chi> must be characters of the character table <tbl>,
##  the default for <chi> is the trivial character.
##
DeclareGlobalFunction( "MolienSeries" );


#############################################################################
##
#F  ValueMolienSeries( <series>, <i> )
##
##  is the <i>-th coefficient of the Molien series <series> computed by
##  'MolienSeries'.
##
DeclareGlobalFunction( "ValueMolienSeries" );


#############################################################################
##
#E  ctblmoli.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



