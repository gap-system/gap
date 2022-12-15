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
##  polynomials over the rationals
##


#############################################################################
##
#F  APolyProd(<a>,<b>,<p>)   . . . . . . . . . . polynomial product a*b mod p
##
##  <ManSection>
##  <Func Name="APolyProd" Arg='a,b,p'/>
##
##  <Description>
##  return a</E>b mod p;
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("APolyProd");

#############################################################################
##
#F  BPolyProd(<a>,<b>,<m>,<p>) . . . . . . polynomial product a*b mod m mod p
##
##  <ManSection>
##  <Func Name="BPolyProd" Arg='a,b,m,p'/>
##
##  <Description>
##  return EuclideanRemainder(PolynomialRing(Rationals),a</E>b mod p,m) mod p;
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("BPolyProd");

#############################################################################
##
#F  PrimitivePolynomial( <f> )
##
##  <#GAPDoc Label="PrimitivePolynomial">
##  <ManSection>
##  <Oper Name="PrimitivePolynomial" Arg='f'/>
##
##  <Description>
##  takes a polynomial <A>f</A> with rational coefficients and computes a new
##  polynomial with integral coefficients, obtained by multiplying with the
##  Lcm of the denominators of the coefficients and casting out the content
##  (the Gcd of the coefficients). The operation returns a list
##  [<A>newpol</A>,<A>coeff</A>] with rational <A>coeff</A> such that
##  <C><A>coeff</A>*<A>newpol</A>=<A>f</A></C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("PrimitivePolynomial",[IsPolynomial]);

#############################################################################
##
#F  BombieriNorm(<pol>)
##
##  <#GAPDoc Label="BombieriNorm">
##  <ManSection>
##  <Func Name="BombieriNorm" Arg='pol'/>
##
##  <Description>
##  computes weighted Norm [<A>pol</A>]<M>_2</M> of <A>pol</A> which is a
##  good measure for factor coefficients (see <Cite Key="BTW93"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("BombieriNorm");

#############################################################################
##
#A  MinimizedBombieriNorm( <f> ) . . . Tschirnhaus transf'd polynomial
##
##  <#GAPDoc Label="MinimizedBombieriNorm">
##  <ManSection>
##  <Attr Name="MinimizedBombieriNorm" Arg='f'/>
##
##  <Description>
##  This function applies linear Tschirnhaus transformations
##  (<M>x \mapsto x + i</M>) to the
##  polynomial <A>f</A>, trying to get the Bombieri norm of <A>f</A> small. It returns a
##  list <C>[<A>new_polynomial</A>, <A>i_of_transformation</A>]</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("MinimizedBombieriNorm",
   IsPolynomial and IsRationalFunctionsFamilyElement);

#############################################################################
##
#F  RootBound(<f>)
##
##  <ManSection>
##  <Func Name="RootBound" Arg='f'/>
##
##  <Description>
##  returns the bound for the norm of (complex) roots of the rational
##  univariate polynomial <A>f</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RootBound");

#############################################################################
##
#F  OneFactorBound(<pol>)
##
##  <#GAPDoc Label="OneFactorBound">
##  <ManSection>
##  <Func Name="OneFactorBound" Arg='pol'/>
##
##  <Description>
##  returns the coefficient bound for a single factor of the rational
##  polynomial <A>pol</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OneFactorBound");

#############################################################################
##
#F  HenselBound(<pol>,[<minpol>,<den>]) . . . Bounds for Factor coefficients
##
##  <#GAPDoc Label="HenselBound">
##  <ManSection>
##  <Func Name="HenselBound" Arg='pol,[minpol,den]'/>
##
##  <Description>
##  returns the Hensel bound of the polynomial <A>pol</A>.
##  If the computation takes place over an algebraic extension, then
##  the minimal polynomial <A>minpol</A> and denominator <A>den</A> must be given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("HenselBound");

#############################################################################
##
#F  TrialQuotientRPF(<f>,<g>,<b>)
##
##  <ManSection>
##  <Func Name="TrialQuotientRPF" Arg='f,g,b'/>
##
##  <Description>
##  returns <M><A>f</A>/<A>g</A></M> if coefficient bounds are given by list <A>b</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TrialQuotientRPF");

#############################################################################
##
#F  TryCombinations(<f>,...)
##
##  <ManSection>
##  <Func Name="TryCombinations" Arg='f,...'/>
##
##  <Description>
##  trial divisions after Hensel factoring.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TryCombinations");

DeclareGlobalFunction("HeuGcdIntPolsExtRep"); # to permit recursive call
DeclareGlobalFunction("HeuGcdIntPolsCoeffs"); # univariate version

#############################################################################
##
#F  PolynomialModP(<pol>,<p>)
##
##  <#GAPDoc Label="PolynomialModP">
##  <ManSection>
##  <Func Name="PolynomialModP" Arg='pol,p'/>
##
##  <Description>
##  for a rational polynomial <A>pol</A> this function returns a polynomial over
##  the field with <A>p</A> elements, obtained by reducing the coefficients modulo
##  <A>p</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PolynomialModP");
