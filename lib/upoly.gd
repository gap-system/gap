#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains attributes, properties and operations for univariate
##  polynomials
##

#############################################################################
##
#A  SplittingField(<f>)
##
##  <#GAPDoc Label="SplittingField">
##  <ManSection>
##  <Attr Name="SplittingField" Arg='f'/>
##
##  <Description>
##  returns the smallest field which contains the coefficients of <A>f</A> and
##  the roots of <A>f</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("SplittingField",IsPolynomial);

#############################################################################
##
#A  IrrFacsPol( <f> ) . . . lists of irreducible factors of polynomial over
##                        diverse rings
##
##  <ManSection>
##  <Attr Name="IrrFacsPol" Arg='f'/>
##
##  <Description>
##  is used to store irreducible factorizations of the polynomial <A>f</A>.
##  The values of this attribute are lists of the form
##  <C>[ [ <A>R</A>, <A>factors</A> ], ... ]</C> where <A>factors</A> is
##  a list of the irreducible factors of <A>f</A> over the coefficients ring <A>R</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("IrrFacsPol",IsPolynomial,"mutable");

#############################################################################
##
#F  StoreFactorsPol( <pring>, <upol>, <factlist> ) . . . . store factors list
##
##  <ManSection>
##  <Func Name="StoreFactorsPol" Arg='pring, upol, factlist'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("StoreFactorsPol");


#############################################################################
##
#O  FactorsSquarefree( <pring>, <upol>, <opt> )
##
##  <#GAPDoc Label="FactorsSquarefree">
##  <ManSection>
##  <Oper Name="FactorsSquarefree" Arg='pring, upol, opt'/>
##
##  <Description>
##  returns a factorization of the squarefree, monic, univariate polynomial
##  <A>upol</A> in the polynomial ring <A>pring</A>;
##  <A>opt</A> must be a (possibly empty) record of options.
##  <A>upol</A> must not have zero as a root.
##  This function is used by the factoring algorithms.
##  <P/>
##  The current method for multivariate factorization reduces to univariate
##  factorization by use of a reduction homomorphism of the form
##  <M>f(x_1,x_2,x_3) \mapsto f(x,x^p,x^{{p^2}})</M>.
##  It can be very time intensive for larger degrees.
##  <P/>
##  <Example><![CDATA[
##  gap> Factors(x^10-y^10);
##  [ x-y, x+y, x^4-x^3*y+x^2*y^2-x*y^3+y^4, x^4+x^3*y+x^2*y^2+x*y^3+y^4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("FactorsSquarefree",[IsPolynomialRing,
                                       IsUnivariatePolynomial, IsRecord ]);

#############################################################################
##
#F  RootsOfUPol( [<field>, ]<upol>)
##
##  <#GAPDoc Label="RootsOfUPol">
##  <ManSection>
##  <Func Name="RootsOfUPol" Arg='[field, ]upol'/>
##
##  <Description>
##  This function returns a list of all roots of the univariate polynomial
##  <A>upol</A> in its default domain.
##  If the optional argument <A>field</A> is a field then the roots in this
##  field are computed.
##  If <A>field</A> is the string <C>"split"</C> then the splitting field of
##  the polynomial is taken.
##  <Example><![CDATA[
##  gap> RootsOfUPol(50-45*x-6*x^2+x^3);
##  [ 10, 1, -5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RootsOfUPol");


#############################################################################
##
#F  CyclotomicPol( <n> )  . . .  coefficients of <n>-th cyclotomic polynomial
##
##  <ManSection>
##  <Func Name="CyclotomicPol" Arg='n'/>
##
##  <Description>
##  is the coefficients list of the <A>n</A>-th cyclotomic polynomial over
##  the rationals.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CyclotomicPol" );


#############################################################################
##
#F  CyclotomicPolynomial( <F>, <n> )  . . . . . .  <n>-th cycl. pol. over <F>
##
##  <#GAPDoc Label="CyclotomicPolynomial">
##  <ManSection>
##  <Func Name="CyclotomicPolynomial" Arg='F, n'/>
##
##  <Description>
##  is the <A>n</A>-th cyclotomic polynomial over the ring <A>F</A>.
##  <Example><![CDATA[
##  gap> CyclotomicPolynomial(Rationals,5);
##  x^4+x^3+x^2+x+1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CyclotomicPolynomial" );


#############################################################################
##
#O  IsPrimitivePolynomial( <F>, <pol> )
##
##  <#GAPDoc Label="IsPrimitivePolynomial">
##  <ManSection>
##  <Oper Name="IsPrimitivePolynomial" Arg='F, pol'/>
##
##  <Description>
##  For a univariate polynomial <A>pol</A> of degree <M>d</M> in the
##  indeterminate <M>X</M>,
##  with coefficients in a finite field <A>F</A> with <M>q</M> elements,
##  <Ref Oper="IsPrimitivePolynomial"/> returns <K>true</K> if
##  <Enum>
##  <Item>
##      <A>pol</A> divides <M>X^{{q^d-1}} - 1</M>, and
##  </Item>
##  <Item>
##      for each prime divisor <M>p</M> of <M>q^d - 1</M>,
##      <A>pol</A> does not divide <M>X^{{(q^d-1)/p}} - 1</M>,
##  </Item>
##  </Enum>
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsPrimitivePolynomial", [ IsField, IsRationalFunction ] );


#############################################################################
##
#O  CompanionMatrix( <poly> )
#O  CompanionMat( <poly> )
##
##  <#GAPDoc Label="CompanionMat">
##  <ManSection>
##  <Oper Name="CompanionMatrix" Arg='poly'/>
##  <Oper Name="CompanionMat" Arg='poly'/>
##
##  <Description>
##  Return a fully mutable matrix that is the companion matrix of the
##  polynomial <A>poly</A>.
##  The negatives of the coefficients of <A>poly</A> appear
##  in the last column of the result.
##  <P/>
##  The companion matrix of <A>poly</A> has <A>poly</A> as its
##  minimal polynomial (see <Ref Oper="MinimalPolynomial"/>) and as its
##  characteristic polynomial (see <Ref Attr="CharacteristicPolynomial"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> x:= X( Rationals );;  pol:= x^3 + x^2 + 2*x + 3;;
##  gap> M:= CompanionMatrix( pol );;
##  gap> Display( M );
##  [ [   0,   0,  -3 ],
##    [   1,   0,  -2 ],
##    [   0,   1,  -1 ] ]
##  gap> MinimalPolynomial( M ) = pol;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We do not declare this as an attribute because the global function
##  'CompanionMat' from earlier GAP versions returned a mutable result.
##
DeclareOperation( "CompanionMatrix", [ IsObject ] );
DeclareSynonym( "CompanionMat", CompanionMatrix );


#############################################################################
##
#F  AllIrreducibleMonicPolynomials( <degree>, <field> )
##
##  <ManSection>
##  <Func Name="AllIrreducibleMonicPolynomials" Arg='degree, field'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AllIrreducibleMonicPolynomials" );
