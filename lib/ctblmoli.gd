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


#############################################################################
##
#F  MolienSeries( [<tbl>, ]<psi>[, <chi>] )
##
##  <#GAPDoc Label="MolienSeries">
##  <ManSection>
##  <Func Name="MolienSeries" Arg='[tbl, ]psi[, chi]'/>
##
##  <Description>
##  The <E>Molien series</E> of the character <M>\psi</M>,
##  relative to the character <M>\chi</M>, is the rational function given by
##  the series
##  <M>M_{{\psi,\chi}}(z) = \sum_{{d = 0}}^{\infty} [\chi,\psi^{[d]}] z^d</M>,
##  where <M>\psi^{[d]}</M> denotes the symmetrization of <M>\psi</M>
##  with the trivial character of the symmetric group <M>S_d</M>
##  (see&nbsp;<Ref Func="SymmetricParts"/>).
##  <P/>
##  <Ref Func="MolienSeries"/> returns the Molien series of <A>psi</A>,
##  relative to <A>chi</A>, where <A>psi</A> and <A>chi</A> must be
##  characters of the same character table;
##  this table must be entered as <A>tbl</A> if <A>chi</A> and <A>psi</A>
##  are only lists of character values.
##  The default for <A>chi</A> is the trivial character of <A>tbl</A>.
##  <P/>
##  The return value of <Ref Func="MolienSeries"/> stores a value for the
##  attribute <Ref Attr="MolienSeriesInfo"/>.
##  This admits the computation of coefficients of the series with
##  <Ref Func="ValueMolienSeries"/>.
##  Furthermore, this attribute gives access to numerator and denominator
##  of the Molien series viewed as rational function,
##  where the denominator is a product of polynomials of the form
##  <M>(1-z^r)^k</M>; the Molien series is also displayed in this form.
##  Note that such a representation is not unique, one can use
##  <Ref Func="MolienSeriesWithGivenDenominator"/>
##  to obtain the series with a prescribed denominator.
##  <P/>
##  For more information about Molien series, see&nbsp;<Cite Key="NPP84"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> t:= CharacterTable( AlternatingGroup( 5 ) );;
##  gap> psi:= First( Irr( t ), x -> Degree( x ) = 3 );;
##  gap> mol:= MolienSeries( psi );
##  ( 1-z^2-z^3+z^6+z^7-z^9 ) / ( (1-z^5)*(1-z^3)*(1-z^2)^2 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MolienSeries" );


#############################################################################
##
#F  MolienSeriesWithGivenDenominator( <molser>, <list> )
##
##  <#GAPDoc Label="MolienSeriesWithGivenDenominator">
##  <ManSection>
##  <Func Name="MolienSeriesWithGivenDenominator" Arg='molser, list'/>
##
##  <Description>
##  is a Molien series equal to <A>molser</A> as rational function,
##  but viewed as quotient with denominator
##  <M>\prod_{{i = 1}}^n (1-z^{{r_i}})</M>,
##  where <M><A>list</A> = [ r_1, r_2, \ldots, r_n ]</M>.
##  If <A>molser</A> cannot be represented this way,
##  <K>fail</K> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> MolienSeriesWithGivenDenominator( mol, [ 2, 6, 10 ] );
##  ( 1+z^15 ) / ( (1-z^10)*(1-z^6)*(1-z^2) )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MolienSeriesWithGivenDenominator" );


##############################################################################
##
#A  MolienSeriesInfo( <ratfun> )
##
##  <#GAPDoc Label="MolienSeriesInfo">
##  <ManSection>
##  <Attr Name="MolienSeriesInfo" Arg='ratfun'/>
##
##  <Description>
##  If the rational function <A>ratfun</A> was constructed by
##  <Ref Func="MolienSeries"/>,
##  a representation as quotient of polynomials is known such that the
##  denominator is a product of terms of the form <M>(1-z^r)^k</M>.
##  This information is encoded as value of <Ref Attr="MolienSeriesInfo"/>.
##  Additionally, there is a special <Ref Oper="PrintObj"/> method
##  for Molien series based on this.
##  <P/>
##  <Ref Attr="MolienSeriesInfo"/> returns a record that describes the
##  rational function <A>ratfun</A> as a Molien series.
##  The components of this record are
##
##  <List>
##  <Mark><C>numer</C></Mark>
##  <Item>
##       numerator of <A>ratfun</A> (in general a multiple of the numerator
##       one gets by <Ref Attr="NumeratorOfRationalFunction"/>),
##  </Item>
##  <Mark><C>denom</C></Mark>
##  <Item>
##       denominator of <A>ratfun</A> (in general a multiple of the
##       denominator one gets by <Ref Attr="NumeratorOfRationalFunction"/>),
##  </Item>
##  <Mark><C>ratfun</C></Mark>
##  <Item>
##       the rational function <A>ratfun</A> itself,
##  </Item>
##  <Mark><C>numerstring</C></Mark>
##  <Item>
##       string corresponding to the polynomial <C>numer</C>,
##       expressed in terms of <C>z</C>,
##  </Item>
##  <Mark><C>denomstring</C></Mark>
##  <Item>
##       string corresponding to the polynomial <C>denom</C>,
##       expressed in terms of <C>z</C>,
##  </Item>
##  <Mark><C>denominfo</C></Mark>
##  <Item>
##       a list of the form <M>[ [ r_1, k_1 ], \ldots, [ r_n, k_n ] ]</M>
##       such that <C>denom</C> is
##       <M>\prod_{{i = 1}}^n (1-z^{{r_i}})^{{k_i}}</M>.
##  </Item>
##  <Mark><C>summands</C></Mark>
##  <Item>
##       a list of records, each with the components <C>numer</C>, <C>r</C>,
##       and <C>k</C>,
##       describing the summand <C>numer</C><M> / (1-z^r)^k</M>,
##  </Item>
##  <Mark><C>pol</C></Mark>
##  <Item>
##       a list of coefficients, describing a final polynomial which is added
##       to those described by <C>summands</C>,
##  </Item>
##  <Mark><C>size</C></Mark>
##  <Item>
##       the order of the underlying matrix group,
##  </Item>
##  <Mark><C>degree</C></Mark>
##  <Item>
##       the degree of the underlying matrix representation.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> HasMolienSeriesInfo( mol );
##  true
##  gap> MolienSeriesInfo( mol );
##  rec( degree := 3,
##    denom := x_1^12-2*x_1^10-x_1^9+x_1^8+x_1^7+x_1^5+x_1^4-x_1^3-2*x_1^2\
##  +1, denominfo := [ 5, 1, 3, 1, 2, 2 ],
##    denomstring := "(1-z^5)*(1-z^3)*(1-z^2)^2",
##    numer := -x_1^9+x_1^7+x_1^6-x_1^3-x_1^2+1,
##    numerstring := "1-z^2-z^3+z^6+z^7-z^9", pol := [  ],
##    ratfun := ( 1-z^2-z^3+z^6+z^7-z^9 ) / ( (1-z^5)*(1-z^3)*(1-z^2)^2 ),
##    size := 60,
##    summands := [ rec( k := 1, numer := [ -24, -12, -24 ], r := 5 ),
##        rec( k := 1, numer := [ -20 ], r := 3 ),
##        rec( k := 2, numer := [ -45/4, 75/4, -15/4, -15/4 ], r := 2 ),
##        rec( k := 3, numer := [ -1 ], r := 1 ),
##        rec( k := 1, numer := [ -15/4 ], r := 1 ) ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MolienSeriesInfo", IsRationalFunction );


#############################################################################
##
#F  CoefficientTaylorSeries( <numer>, <r>, <k>, <i> )
##
##  <ManSection>
##  <Func Name="CoefficientTaylorSeries" Arg='numer, r, k, i'/>
##
##  <Description>
##  is the coefficient of <M>z^<A>i</A></M> in the Taylor series expansion of
##  the quotient of polynomials
##  <M>p(z) / ( 1 - z^{<A>r</A>} )^{<A>k</A>}</M>,
##  where <A>numer</A> is the coefficients list of the numerator polynomial
##  <M>p(z)</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CoefficientTaylorSeries" );


#############################################################################
##
#F  SummandMolienSeries( <tbl>, <psi>, <chi>, <i> )
##
##  <ManSection>
##  <Func Name="SummandMolienSeries" Arg='tbl, psi, chi, i'/>
##
##  <Description>
##  is the summand of the Molien series of the character table <A>tbl</A>,
##  for the characters <A>psi</A> and <A>chi</A>, that corresponds to class
##  <A>i</A>.
##  That is, the returned value is the quotient
##  <Display Mode="M">
##     \chi(g) \cdot \det(D(g)) / \det(z I - D(g))
##  </Display>
##  where <M>g</M> is in class <A>i</A>, <M>D</M> is a representation with
##  character <A>psi</A>, and <M>z</M> is the indeterminate.
##  <P/>
##  The result is a record with components <C>numer</C> and <C>a</C>,
##  with the following meaning.
##  <P/>
##  Write the denominator as a product of cyclotomic polynomials,
##  encode this as a list <C>a</C> where at position <M>r</M> the
##  multiplicity of the <M>r</M>-th cyclotomic polynomial <M>\Phi_r</M>
##  is stored.
##  (For that, we possibly must change the numerator.)
##  We get
##  <Display Mode="M">
##     1 / \det(z I - D(g))
##              = P(z) / \left( \prod_{{d \mid n}} \Phi_d^{a_d}(z) \right) .
##  </Display>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SummandMolienSeries" );


#############################################################################
##
#F  ValueMolienSeries( <molser>, <i> )
##
##  <#GAPDoc Label="ValueMolienSeries">
##  <ManSection>
##  <Func Name="ValueMolienSeries" Arg='molser, i'/>
##
##  <Description>
##  is the <A>i</A>-th coefficient of the Molien series <A>series</A>
##  computed by <Ref Func="MolienSeries"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> List( [ 0 .. 20 ], i -> ValueMolienSeries( mol, i ) );
##  [ 1, 0, 1, 0, 1, 0, 2, 0, 2, 0, 3, 0, 4, 0, 4, 1, 5, 1, 6, 1, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ValueMolienSeries" );
