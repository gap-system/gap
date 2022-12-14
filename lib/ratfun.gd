#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the categories,  attributes, properties and operations
##  for  rational functions, Laurent polynomials   and polynomials and  their
##  families.

##  Warning:
##  If the mechanism for storing attributes is changed,
##  `LaurentPolynomialByExtRep' must be changed as well.
##  Also setter methods for coefficients and/or indeterminate number will be
##  ignored when creating Laurent polynomials.
##  (This is ugly and inconsistent, but crucial to get speed. ahulpke, May99)

#############################################################################
##
#I  InfoPoly
##
##  <#GAPDoc Label="InfoPoly">
##  <ManSection>
##  <InfoClass Name="InfoPoly"/>
##
##  <Description>
##  is the info class for univariate polynomials.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoPoly" );

#############################################################################
##
#C  IsPolynomialFunction(<obj>)
#C  IsRationalFunction(<obj>)
##
##  <#GAPDoc Label="IsPolynomialFunction">
##  <ManSection>
##  <Filt Name="IsPolynomialFunction" Arg='obj' Type='Category'/>
##  <Filt Name="IsRationalFunction" Arg='obj' Type='Category'/>
##
##  <Description>
##  A rational function is an element of the quotient field of a polynomial
##  ring over an UFD. It is represented as a quotient of two polynomials,
##  its numerator (see&nbsp;<Ref Attr="NumeratorOfRationalFunction"/>) and
##  its denominator (see&nbsp;<Ref Attr="DenominatorOfRationalFunction"/>)
##  <P/>
##  A polynomial function is an element of a polynomial ring (not
##  necessarily an UFD), or a rational function.
##  <P/>
##  &GAP; considers <Ref Filt="IsRationalFunction"/> as a subcategory of
##  <Ref Filt="IsPolynomialFunction"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPolynomialFunction", IsRingElementWithInverse and IsZDFRE);
DeclareCategory( "IsRationalFunction", IsPolynomialFunction);

DeclareCategoryCollections( "IsPolynomialFunction" );
DeclareCategoryCollections( "IsRationalFunction" );

#############################################################################
##
#C  IsPolynomialFunctionsFamilyElement(<obj>)
#C  IsRationalFunctionsFamilyElement(<obj>)
##
##  <ManSection>
##  <Filt Name="IsPolynomialFunctionsFamilyElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsRationalFunctionsFamilyElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  A polynomial is an element of a polynomial functions family. If the
##  underlying domain is an UFD, it is even a
##  <Ref Func="IsRationalFunctionsFamilyElement"/>.
##  </Description>
##  </ManSection>
##
DeclareCategory("IsPolynomialFunctionsFamilyElement",IsPolynomialFunction);
DeclareCategory("IsRationalFunctionsFamilyElement",
  IsRationalFunction and IsPolynomialFunctionsFamilyElement );

#############################################################################
##
#C  IsPolynomialFunctionsFamily(<obj>)
#C  IsRationalFunctionsFamily(<obj>)
##
##  <#GAPDoc Label="IsPolynomialFunctionsFamily">
##  <ManSection>
##  <Filt Name="IsPolynomialFunctionsFamily" Arg='obj' Type='Category'/>
##  <Filt Name="IsRationalFunctionsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsPolynomialFunctionsFamily"/> is the category of a family of
##  polynomials.
##  For families over an UFD, the category becomes
##  <Ref Filt="IsRationalFunctionsFamily"/> (as rational functions and
##  quotients are only provided for families over an UFD.)
##  <!--  1996/10/14 fceller can this be done with <C>CategoryFamily</C>?-->
##  <P/>
##  <Log><![CDATA[
##  gap> fam:=RationalFunctionsFamily(FamilyObj(1));
##  NewFamily( "RationalFunctionsFamily(...)", [ 618, 620 ],
##  [ 82, 85, 89, 93, 97, 100, 103, 107, 111, 618, 620 ] )
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPolynomialFunctionsFamily", IsFamily );
DeclareCategory( "IsRationalFunctionsFamily", IsPolynomialFunctionsFamily and IsUFDFamily );

#############################################################################
##
#C  IsRationalFunctionOverField(<obj>)
##
##  <ManSection>
##  <Filt Name="IsRationalFunctionOverField" Arg='obj' Type='Category'/>
##
##  <Description>
##  Indicates that the coefficients family for the rational function <A>obj</A>
##  is a field. In this situation it is permissible to move coefficients
##  from the denominator in the numerator, in particular the quotient of a
##  polynomial by a coefficient is again a polynomial. This last property
##  does not necessarily hold for polynomials over arbitrary rings.
##  </Description>
##  </ManSection>
##
DeclareCategory("IsRationalFunctionOverField", IsRationalFunction );

#############################################################################
##
#A  RationalFunctionsFamily( <fam> )
##
##  <#GAPDoc Label="RationalFunctionsFamily">
##  <ManSection>
##  <Attr Name="RationalFunctionsFamily" Arg='fam'/>
##
##  <Description>
##  creates a   family  containing rational functions  with   coefficients
##  in <A>fam</A>.
##  All elements of the <Ref Attr="RationalFunctionsFamily"/> are
##  rational functions (see&nbsp;<Ref Filt="IsRationalFunction"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RationalFunctionsFamily", IsFamily );

#############################################################################
##
#A  CoefficientsFamily( <rffam> )
##
##  <#GAPDoc Label="CoefficientsFamily">
##  <ManSection>
##  <Attr Name="CoefficientsFamily" Arg='rffam'/>
##
##  <Description>
##  If <A>rffam</A> has been created as
##  <C>RationalFunctionsFamily(<A>cfam</A>)</C> this attribute holds the
##  coefficients family <A>cfam</A>.
##  <P/>
##  &GAP; does <E>not</E> embed the base ring in the polynomial ring. While
##  multiplication and addition of base ring elements to rational functions
##  return the expected results, polynomials and rational functions are not
##  equal.
##  <Example><![CDATA[
##  gap> 1=Indeterminate(Rationals)^0;
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CoefficientsFamily", IsFamily );

#############################################################################
##
#A  NumeratorOfRationalFunction( <ratfun> )
##
##  <#GAPDoc Label="NumeratorOfRationalFunction">
##  <ManSection>
##  <Attr Name="NumeratorOfRationalFunction" Arg='ratfun'/>
##
##  <Description>
##  returns the numerator of the rational function <A>ratfun</A>.
##  <P/>
##  As no proper multivariate gcd has been implemented yet, numerators and
##  denominators are not guaranteed to be reduced!
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NumeratorOfRationalFunction", IsPolynomialFunction);

#############################################################################
##
#A  DenominatorOfRationalFunction( <ratfun> )
##
##  <#GAPDoc Label="DenominatorOfRationalFunction">
##  <ManSection>
##  <Attr Name="DenominatorOfRationalFunction" Arg='ratfun'/>
##
##  <Description>
##  returns the denominator of the rational function <A>ratfun</A>.
##  <P/>
##  As no proper multivariate gcd has been implemented yet, numerators and
##  denominators are not guaranteed to be reduced!
##  <Example><![CDATA[
##  gap> x:=Indeterminate(Rationals,1);;y:=Indeterminate(Rationals,2);;
##  gap> DenominatorOfRationalFunction((x*y+x^2)/y);
##  y
##  gap> NumeratorOfRationalFunction((x*y+x^2)/y);
##  x^2+x*y
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DenominatorOfRationalFunction", IsRationalFunction );

#############################################################################
##
#P  IsPolynomial( <ratfun> )
##
##  <#GAPDoc Label="IsPolynomial">
##  <ManSection>
##  <Prop Name="IsPolynomial" Arg='ratfun'/>
##
##  <Description>
##  A polynomial is a rational function whose denominator is one. (If the
##  coefficients family forms a field this is equivalent to the denominator
##  being constant.)
##  <P/>
##  If the base family is not a field, it may be impossible to represent the
##  quotient of a polynomial by a ring element as a polynomial again, but it
##  will have to be represented as a rational function.
##  <Example><![CDATA[
##  gap> IsPolynomial((x*y+x^2*y^3)/y);
##  true
##  gap> IsPolynomial((x*y+x^2)/y);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPolynomial", IsPolynomialFunction );
InstallTrueMethod( IsPolynomialFunction, IsPolynomial );


#############################################################################
##
#A  AsPolynomial( <poly> )
##
##  <#GAPDoc Label="AsPolynomial">
##  <ManSection>
##  <Attr Name="AsPolynomial" Arg='poly'/>
##
##  <Description>
##  If <A>poly</A> is a rational function that is a polynomial this attribute
##  returns an equal rational function <M>p</M> such that <M>p</M> is equal
##  to its numerator and the denominator of <M>p</M> is one.
##  <Example><![CDATA[
##  gap> AsPolynomial((x*y+x^2*y^3)/y);
##  x^2*y^2+x
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsPolynomial",
  IsPolynomialFunction and IsPolynomial);

#############################################################################
##
#P  IsUnivariateRationalFunction( <ratfun> )
##
##  <#GAPDoc Label="IsUnivariateRationalFunction">
##  <ManSection>
##  <Prop Name="IsUnivariateRationalFunction" Arg='ratfun'/>
##
##  <Description>
##  A rational function is univariate if its numerator and its denominator
##  are both polynomials in the same one indeterminate. The attribute
##  <Ref Attr="IndeterminateNumberOfUnivariateRationalFunction"/> can be used to obtain
##  the number of this common indeterminate.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsUnivariateRationalFunction", IsRationalFunction );
InstallTrueMethod( IsRationalFunction, IsUnivariateRationalFunction );

#############################################################################
##
#P  IsUnivariatePolynomial( <ratfun> )
##
##  <#GAPDoc Label="IsUnivariatePolynomial">
##  <ManSection>
##  <Prop Name="IsUnivariatePolynomial" Arg='ratfun'/>
##
##  <Description>
##  A univariate polynomial is a polynomial in only one indeterminate.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr("IsUnivariatePolynomial",
  IsPolynomial and IsUnivariateRationalFunction);

#############################################################################
##
#P  IsLaurentPolynomial( <ratfun> )
##
##  <#GAPDoc Label="IsLaurentPolynomial">
##  <ManSection>
##  <Prop Name="IsLaurentPolynomial" Arg='ratfun'/>
##
##  <Description>
##  A Laurent polynomial is a univariate rational function whose denominator
##  is a monomial. Therefore every univariate polynomial is a
##  Laurent polynomial.
##  <P/>
##  The attribute <Ref Attr="CoefficientsOfLaurentPolynomial"/> gives a
##  compact representation as Laurent polynomial.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsLaurentPolynomial", IsPolynomialFunction );

InstallTrueMethod( IsUnivariateRationalFunction, IsLaurentPolynomial );
InstallTrueMethod( IsLaurentPolynomial, IsUnivariatePolynomial );

#############################################################################
##
#P  IsConstantRationalFunction( <ratfun> )
##
##  <#GAPDoc Label="IsConstantRationalFunction">
##  <ManSection>
##  <Prop Name="IsConstantRationalFunction" Arg='ratfun'/>
##
##  <Description>
##  A  constant  rational   function is  a    function  whose  numerator  and
##  denominator are polynomials of degree 0.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsConstantRationalFunction", IsPolynomialFunction );
InstallTrueMethod( IsUnivariateRationalFunction, IsConstantRationalFunction );

#############################################################################
##
#P  IsZeroRationalFunction( <ratfun> )
##
##  <ManSection>
##  <Prop Name="IsZeroRationalFunction" Arg='ratfun'/>
##
##  <Description>
##  This property indicates whether <A>ratfun</A> is the zero element of the
##  field of rational functions.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr("IsZeroRationalFunction",IsZero and IsPolynomialFunction);

InstallTrueMethod( IsConstantRationalFunction,IsZeroRationalFunction );


#############################################################################
##
#R  IsRationalFunctionDefaultRep(<obj>)
##
##  <#GAPDoc Label="IsRationalFunctionDefaultRep">
##  <ManSection>
##  <Filt Name="IsRationalFunctionDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  is the default representation of rational functions. A rational function
##  in this representation is defined by the attributes
##  <Ref Attr="ExtRepNumeratorRatFun"/> and
##  <Ref Attr="ExtRepDenominatorRatFun"/>,
##  the values of which are external representations of polynomials.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation("IsRationalFunctionDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsRationalFunction,
    ["zeroCoefficient","numerator","denominator"] );


#############################################################################
##
#R  IsPolynomialDefaultRep(<obj>)
##
##  <#GAPDoc Label="IsPolynomialDefaultRep">
##  <ManSection>
##  <Filt Name="IsPolynomialDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  is the default representation of polynomials. A polynomial
##  in this representation is defined by the components
##  and <Ref Attr="ExtRepNumeratorRatFun"/> where
##  <Ref Attr="ExtRepNumeratorRatFun"/> is the
##  external representation of the polynomial.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation("IsPolynomialDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep
    and IsPolynomialFunction and IsPolynomial,["zeroCoefficient","numerator"]);


#############################################################################
##
#R  IsLaurentPolynomialDefaultRep(<obj>)
##
##  <#GAPDoc Label="IsLaurentPolynomialDefaultRep">
##  <ManSection>
##  <Filt Name="IsLaurentPolynomialDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  This representation is used for Laurent polynomials and univariate
##  polynomials. It represents a Laurent polynomial via the attributes
##  <Ref Attr="CoefficientsOfLaurentPolynomial"/> and
##  <Ref Attr="IndeterminateNumberOfLaurentPolynomial"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation("IsLaurentPolynomialDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep
    and IsPolynomialFunction and IsLaurentPolynomial, [] );

#############################################################################
##
#R  IsUnivariateRationalFunctionDefaultRep(<obj>)
##
##  <ManSection>
##  <Filt Name="IsUnivariateRationalFunctionDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  This representation is used for univariate rational functions
##  polynomials. It represents a univariate rational function via the attributes
##  <Ref Func="CoefficientsOfUnivariateRationalFunction"/> and
##  <Ref Func="IndeterminateNumberOfUnivariateRationalFunction"/>.
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsUnivariateRationalFunctionDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep
    and IsPolynomialFunction and IsUnivariateRationalFunction, [] );


##  <#GAPDoc Label="[1]{ratfun}">
##  <Index>External representation of polynomials</Index>
##  The representation of a polynomials is a list of the form
##  <C>[<A>mon</A>,<A>coeff</A>,<A>mon</A>,<A>coeff</A>,...]</C> where <A>mon</A> is a monomial in
##  expanded form (that is given as list) and <A>coeff</A> its coefficient. The
##  monomials must be sorted according to the total degree/lexicographic
##  order (This is the same as given by the <Q>grlex</Q> monomial ordering,
##  see&nbsp;<Ref Func="MonomialGrlexOrdering"/>). We call
##  this the <E>external representation</E> of a polynomial. (The
##  reason for ordering is that addition of polynomials becomes linear in
##  the number of monomials instead of quadratic; the reason for the
##  particular ordering chose is that it is compatible with multiplication
##  and thus gives acceptable performance for quotient calculations.)
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[3]{ratfun}">
##  The operations <Ref Oper="LaurentPolynomialByCoefficients"/>,
##  <Ref Func="PolynomialByExtRep"/> and
##  <Ref Func="RationalFunctionByExtRep"/> are used to
##  construct objects in the three basic representations for rational
##  functions.
##  <#/GAPDoc>


#############################################################################
##
#A  ExtRepNumeratorRatFun( <ratfun> )
##
##  <#GAPDoc Label="ExtRepNumeratorRatFun">
##  <ManSection>
##  <Attr Name="ExtRepNumeratorRatFun" Arg='ratfun'/>
##
##  <Description>
##  returns the external representation of the numerator polynomial of the
##  rational function <A>ratfun</A>. Numerator and denominator are not guaranteed
##  to be cancelled against each other.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ExtRepNumeratorRatFun",IsPolynomialFunction);

#############################################################################
##
#A  ExtRepDenominatorRatFun( <ratfun> )
##
##  <#GAPDoc Label="ExtRepDenominatorRatFun">
##  <ManSection>
##  <Attr Name="ExtRepDenominatorRatFun" Arg='ratfun'/>
##
##  <Description>
##  returns the external representation of the denominator polynomial of the
##  rational function <A>ratfun</A>. Numerator and denominator are not guaranteed
##  to be cancelled against each other.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ExtRepDenominatorRatFun",IsRationalFunction);

#############################################################################
##
#O  ZeroCoefficientRatFun( <ratfun> )
##
##  <#GAPDoc Label="ZeroCoefficientRatFun">
##  <ManSection>
##  <Oper Name="ZeroCoefficientRatFun" Arg='ratfun'/>
##
##  <Description>
##  returns the zero of the coefficient ring. This might be needed to
##  represent the zero polynomial for which the external representation of
##  the numerator is the empty list.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ZeroCoefficientRatFun",[IsPolynomialFunction]);

#############################################################################
##
#A  ExtRepPolynomialRatFun( <polynomial> )
##
##  <#GAPDoc Label="ExtRepPolynomialRatFun">
##  <ManSection>
##  <Attr Name="ExtRepPolynomialRatFun" Arg='polynomial'/>
##
##  <Description>
##  returns the external representation of a polynomial. The difference to
##  <Ref Attr="ExtRepNumeratorRatFun"/> is that rational functions might know
##  to be a polynomial but can still have a non-vanishing denominator.
##  In this case
##  <Ref Attr="ExtRepPolynomialRatFun"/> has to call a quotient routine.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ExtRepPolynomialRatFun",IsPolynomialFunction and IsPolynomial);

#############################################################################
##
#A  CoefficientsOfLaurentPolynomial( <laurent> )
##
##  <#GAPDoc Label="CoefficientsOfLaurentPolynomial">
##  <ManSection>
##  <Attr Name="CoefficientsOfLaurentPolynomial" Arg='laurent'/>
##
##  <Description>
##  For a Laurent polynomial <A>laurent</A>, this function returns a pair
##  <C>[<A>cof</A>, <A>val</A>]</C>,
##  consisting of the coefficient list (in ascending order) <A>cof</A> and the
##  valuation <A>val</A> of <A>laurent</A>.
##  <Example><![CDATA[
##  gap> p:=LaurentPolynomialByCoefficients(FamilyObj(1),
##  > [1,2,3,4,5],-2);
##  5*x^2+4*x+3+2*x^-1+x^-2
##  gap> NumeratorOfRationalFunction(p);DenominatorOfRationalFunction(p);
##  5*x^4+4*x^3+3*x^2+2*x+1
##  x^2
##  gap> CoefficientsOfLaurentPolynomial(p*p);
##  [ [ 1, 4, 10, 20, 35, 44, 46, 40, 25 ], -4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CoefficientsOfLaurentPolynomial",
    IsLaurentPolynomial );
DeclareSynonym( "CoefficientsOfUnivariateLaurentPolynomial",
  CoefficientsOfLaurentPolynomial);

#############################################################################
##
#A  IndeterminateNumberOfUnivariateRationalFunction( <rfun> )
##
##  <#GAPDoc Label="IndeterminateNumberOfUnivariateRationalFunction">
##  <ManSection>
##  <Attr Name="IndeterminateNumberOfUnivariateRationalFunction" Arg='rfun'/>
##
##  <Description>
##  returns the number of the indeterminate in which the univariate rational
##  function <A>rfun</A> is expressed. (This also provides a way to obtain the
##  number of a given indeterminate.)
##  <P/>
##  A constant rational function might not possess an indeterminate number. In
##  this case <Ref Attr="IndeterminateNumberOfUnivariateRationalFunction"/>
##  will default to a value of 1.
##  Therefore two univariate polynomials may be considered to be in the same
##  univariate polynomial ring if their indeterminates have the same number
##  or one if of them is constant.  (see also&nbsp;<Ref Func="CIUnivPols"/>
##  and&nbsp;<Ref Filt="IsLaurentPolynomialDefaultRep"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndeterminateNumberOfUnivariateRationalFunction",
    IsUnivariateRationalFunction );


##  <#GAPDoc Label="[2]{ratfun}">
##  Algorithms should use only the attributes
##  <Ref Attr="ExtRepNumeratorRatFun"/>,
##  <Ref Attr="ExtRepDenominatorRatFun"/>,
##  <Ref Attr="ExtRepPolynomialRatFun"/>,
##  <Ref Attr="CoefficientsOfLaurentPolynomial"/> and
##  &ndash;if the univariate function is not constant&ndash;
##  <Ref Attr="IndeterminateNumberOfUnivariateRationalFunction"/> as the
##  low-level interface to work with a polynomial.
##  They should not refer to the actual representation used.
##  <#/GAPDoc>


#############################################################################
##
#O  LaurentPolynomialByCoefficients( <fam>, <cofs>, <val> [,<ind>] )
##
##  <#GAPDoc Label="LaurentPolynomialByCoefficients">
##  <ManSection>
##  <Oper Name="LaurentPolynomialByCoefficients" Arg='fam, cofs, val [,ind]'/>
##
##  <Description>
##  constructs a Laurent polynomial over the coefficients
##  family <A>fam</A> and in the indeterminate <A>ind</A> (defaulting to 1)
##  with the coefficients given by <A>cofs</A> and valuation <A>val</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LaurentPolynomialByCoefficients",
    [ IsFamily, IsList, IsInt, IsInt ] );
DeclareSynonym( "UnivariateLaurentPolynomialByCoefficients",
  LaurentPolynomialByCoefficients);

#############################################################################
##
#F  LaurentPolynomialByExtRep( <fam>, <cofs>,<val> ,<ind> )
#F  LaurentPolynomialByExtRepNC( <fam>, <cofs>,<val> ,<ind> )
##
##  <#GAPDoc Label="LaurentPolynomialByExtRep">
##  <ManSection>
##  <Func Name="LaurentPolynomialByExtRep" Arg='fam, cofs,val ,ind'/>
##  <Func Name="LaurentPolynomialByExtRepNC" Arg='fam, cofs,val ,ind'/>
##
##  <Description>
##  creates a Laurent polynomial in the family <A>fam</A> with [<A>cofs</A>,<A>val</A>] as
##  value of <Ref Attr="CoefficientsOfLaurentPolynomial"/>. No coefficient shifting is
##  performed.  This is the lowest level function to create a Laurent
##  polynomial but will rely on the coefficients being shifted properly and
##  will not perform any tests. Unless this is guaranteed for the
##  parameters,
##  <Ref Oper="LaurentPolynomialByCoefficients"/> should be used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LaurentPolynomialByExtRepNC");
DeclareSynonym("LaurentPolynomialByExtRep",LaurentPolynomialByExtRepNC);

#############################################################################
##
#F  PolynomialByExtRep( <rfam>, <extrep> )
#F  PolynomialByExtRepNC( <rfam>, <extrep> )
##
##  <#GAPDoc Label="PolynomialByExtRep">
##  <ManSection>
##  <Func Name="PolynomialByExtRep" Arg='rfam, extrep'/>
##  <Func Name="PolynomialByExtRepNC" Arg='rfam, extrep'/>
##
##  <Description>
##  constructs a polynomial
##  (in the representation <Ref Filt="IsPolynomialDefaultRep"/>)
##  in the rational function family <A>rfam</A>, the polynomial itself is given
##  by the external representation <A>extrep</A>.
##  <P/>
##  The variant <Ref Func="PolynomialByExtRepNC"/> does not perform any test
##  of the arguments and thus potentially can create invalid objects. It only
##  should be used if speed is required and the arguments are known to be
##  in correct form.
##  <Example><![CDATA[
##  gap> fam:=RationalFunctionsFamily(FamilyObj(1));;
##  gap> p:=PolynomialByExtRep(fam,[[1,2],1,[2,1,15,7],3]);
##  3*y*x_15^7+x^2
##  gap> q:=p/(p+1);
##  (3*y*x_15^7+x^2)/(3*y*x_15^7+x^2+1)
##  gap> ExtRepNumeratorRatFun(q);
##  [ [ 1, 2 ], 1, [ 2, 1, 15, 7 ], 3 ]
##  gap> ExtRepDenominatorRatFun(q);
##  [ [  ], 1, [ 1, 2 ], 1, [ 2, 1, 15, 7 ], 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PolynomialByExtRep" );
DeclareGlobalFunction( "PolynomialByExtRepNC" );

#############################################################################
##
#F  RationalFunctionByExtRep( <rfam>, <num>, <den> )
#F  RationalFunctionByExtRepNC( <rfam>, <num>, <den> )
##
##  <#GAPDoc Label="RationalFunctionByExtRep">
##  <ManSection>
##  <Func Name="RationalFunctionByExtRep" Arg='rfam, num, den'/>
##  <Func Name="RationalFunctionByExtRepNC" Arg='rfam, num, den'/>
##
##  <Description>
##  constructs a rational function (in the representation
##  <Ref Filt="IsRationalFunctionDefaultRep"/>) in the rational function
##  family <A>rfam</A>,
##  the rational function itself is given by the external representations
##  <A>num</A> and <A>den</A> for numerator and denominator.
##  No cancellation takes place.
##  <P/>
##  The variant <Ref Func="RationalFunctionByExtRepNC"/> does not perform any
##  test of the arguments and thus potentially can create illegal objects.
##  It only should be used if speed is required and the arguments are known
##  to be in correct form.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RationalFunctionByExtRep" );
DeclareGlobalFunction( "RationalFunctionByExtRepNC" );

#############################################################################
##
#F  UnivariateRationalFunctionByExtRep(<fam>,<ncof>,<dcof>,<val> ,<ind> )
#F  UnivariateRationalFunctionByExtRepNC(<fam>,<ncof>,<dcof>,<val> ,<ind> )
##
##  <ManSection>
##  <Func Name="UnivariateRationalFunctionByExtRep"
##   Arg='fam, ncof, dcof, val, ind'/>
##  <Func Name="UnivariateRationalFunctionByExtRepNC"
##   Arg='fam, ncof, dcof, val, ind'/>
##
##  <Description>
##  creates a univariate rational function in the family <A>fam</A> with
##  [<A>ncof</A>,<A>dcof</A>,<A>val</A>] as
##  value of <Ref Func="CoefficientsOfUnivariateRationalFunction"/>.
##  No coefficient shifting is performed.
##  This is the lowest level function to create a
##  univariate rational function but will rely on the coefficients being
##  shifted properly. Unless this is
##  guaranteed for the parameters,
##  <Ref Func="UnivariateLaurentPolynomialByCoefficients"/> should be used.
##  No cancellation is performed.
##  <P/>
##  The variant <Ref Func="UnivariateRationalFunctionByExtRepNC"/> does not
##  perform any test of
##  the arguments and thus potentially can create invalid objects. It only
##  should be used if speed is required and the arguments are known to be
##  in correct form.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "UnivariateRationalFunctionByExtRepNC");
DeclareSynonym("UnivariateRationalFunctionByExtRep",
  UnivariateRationalFunctionByExtRepNC);

#############################################################################
##
#F  RationalFunctionByExtRepWithCancellation( <rfam>, <num>, <den> )
##
##  <#GAPDoc Label="RationalFunctionByExtRepWithCancellation">
##  <ManSection>
##  <Func Name="RationalFunctionByExtRepWithCancellation" Arg='rfam, num, den'/>
##
##  <Description>
##  constructs a rational function as <Ref Func="RationalFunctionByExtRep"/>
##  does but tries to cancel out common factors of numerator and denominator,
##  calling <Ref Func="TryGcdCancelExtRepPolynomials"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RationalFunctionByExtRepWithCancellation" );

#############################################################################
##
#A  IndeterminateOfUnivariateRationalFunction( <rfun> )
##
##  <#GAPDoc Label="IndeterminateOfUnivariateRationalFunction">
##  <ManSection>
##  <Attr Name="IndeterminateOfUnivariateRationalFunction" Arg='rfun'/>
##
##  <Description>
##  returns the indeterminate in which the univariate rational
##  function <A>rfun</A> is expressed. (cf.
##  <Ref Attr="IndeterminateNumberOfUnivariateRationalFunction"/>.)
##  <Example><![CDATA[
##  gap> IndeterminateNumberOfUnivariateRationalFunction(z);
##  3
##  gap> IndeterminateOfUnivariateRationalFunction(z^5+z);
##  X
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndeterminateOfUnivariateRationalFunction",
    IsUnivariateRationalFunction );
DeclareSynonym("IndeterminateOfLaurentPolynomial",
  IndeterminateOfUnivariateRationalFunction);

#############################################################################
##
#F  IndeterminateNumberOfLaurentPolynomial(<pol>)
##
##  <#GAPDoc Label="IndeterminateNumberOfLaurentPolynomial">
##  <ManSection>
##  <Attr Name="IndeterminateNumberOfLaurentPolynomial" Arg='pol'/>
##
##  <Description>
##  Is a synonym for
##  <Ref Attr="IndeterminateNumberOfUnivariateRationalFunction"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr("IndeterminateNumberOfLaurentPolynomial",
  IndeterminateNumberOfUnivariateRationalFunction);
DeclareSynonymAttr("IndeterminateNumberOfUnivariateLaurentPolynomial",
  IndeterminateNumberOfUnivariateRationalFunction);

#############################################################################
##
#O  IndeterminateName(<fam>,<nr>)
#O  HasIndeterminateName(<fam>,<nr>)
#O  SetIndeterminateName(<fam>,<nr>,<name>)
##
##  <#GAPDoc Label="IndeterminateName">
##  <ManSection>
##  <Oper Name="IndeterminateName" Arg='fam,nr'/>
##  <Oper Name="HasIndeterminateName" Arg='fam,nr'/>
##  <Oper Name="SetIndeterminateName" Arg='fam,nr,name'/>
##
##  <Description>
##  <Ref Oper="SetIndeterminateName"/> assigns the name <A>name</A> to
##  indeterminate <A>nr</A> in the rational functions family <A>fam</A>.
##  It issues an error if the indeterminate was already named.
##  <P/>
##  <Ref Oper="IndeterminateName"/> returns the name of the <A>nr</A>-th
##  indeterminate (and returns <K>fail</K> if no name has been assigned).
##  <P/>
##  <Ref Oper="HasIndeterminateName"/> tests whether indeterminate <A>nr</A>
##  has already been assigned a name.
##  <P/>
##  <Example><![CDATA[
##  gap> IndeterminateName(FamilyObj(x),2);
##  "y"
##  gap> HasIndeterminateName(FamilyObj(x),4);
##  false
##  gap> SetIndeterminateName(FamilyObj(x),10,"bla");
##  gap> Indeterminate(GF(3),10);
##  bla
##  ]]></Example>
##  <P/>
##  As a convenience there is a special method installed for <C>SetName</C>
##  that will assign a name to an indeterminate.
##  <P/>
##  <Example><![CDATA[
##  gap> a:=Indeterminate(GF(3),5);
##  x_5
##  gap> SetName(a,"ah");
##  gap> a^5+a;
##  ah^5+ah
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IndeterminateName",
  [IsPolynomialFunctionsFamily,IsPosInt]);
DeclareOperation( "HasIndeterminateName",
  [IsPolynomialFunctionsFamily,IsPosInt]);
DeclareOperation( "SetIndeterminateName",
  [IsPolynomialFunctionsFamily,IsPosInt,IsString]);



#############################################################################
##
#A  CoefficientsOfUnivariatePolynomial( <pol> )
##
##  <#GAPDoc Label="CoefficientsOfUnivariatePolynomial">
##  <ManSection>
##  <Attr Name="CoefficientsOfUnivariatePolynomial" Arg='pol'/>
##
##  <Description>
##  <Ref Attr="CoefficientsOfUnivariatePolynomial"/> returns the coefficient
##  list of the polynomial <A>pol</A>, sorted in ascending order.
##  (It returns the empty list if <A>pol</A> is 0.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("CoefficientsOfUnivariatePolynomial",IsUnivariatePolynomial);

#############################################################################
##
#A  DegreeOfLaurentPolynomial( <pol> )
##
##  <#GAPDoc Label="DegreeOfLaurentPolynomial">
##  <ManSection>
##  <Attr Name="DegreeOfLaurentPolynomial" Arg='pol'/>
##
##  <Description>
##  The degree of a univariate (Laurent) polynomial <A>pol</A> is the largest
##  exponent <M>n</M> of a monomial <M>x^n</M> of <A>pol</A>. The degree of
##  a zero polynomial is defined to be <C>-infinity</C>.
##  <Example><![CDATA[
##  gap> p:=UnivariatePolynomial(Rationals,[1,2,3,4],1);
##  4*x^3+3*x^2+2*x+1
##  gap> UnivariatePolynomialByCoefficients(FamilyObj(1),[9,2,3,4],73);
##  4*x_73^3+3*x_73^2+2*x_73+9
##  gap> CoefficientsOfUnivariatePolynomial(p);
##  [ 1, 2, 3, 4 ]
##  gap> DegreeOfLaurentPolynomial(p);
##  3
##  gap> DegreeOfLaurentPolynomial(Zero(p));
##  -infinity
##  gap> IndeterminateNumberOfLaurentPolynomial(p);
##  1
##  gap> IndeterminateOfLaurentPolynomial(p);
##  x
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DegreeOfLaurentPolynomial",
    IsLaurentPolynomial );
DeclareSynonym( "DegreeOfUnivariateLaurentPolynomial",
  DegreeOfLaurentPolynomial);
BindGlobal("DEGREE_ZERO_LAURPOL",Ninfinity);

#############################################################################
##
#O  UnivariatePolynomialByCoefficients( <fam>, <cofs>, <ind> )
##
##  <#GAPDoc Label="UnivariatePolynomialByCoefficients">
##  <ManSection>
##  <Oper Name="UnivariatePolynomialByCoefficients" Arg='fam, cofs, ind'/>
##
##  <Description>
##  constructs an univariate polynomial over the coefficients family
##  <A>fam</A> and in the indeterminate <A>ind</A> with the coefficients given by
##  <A>cofs</A>. This function should be used in algorithms to create
##  polynomials as it avoids overhead associated with
##  <Ref Oper="UnivariatePolynomial"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UnivariatePolynomialByCoefficients",
    [ IsFamily, IsList, IsInt ] );


#############################################################################
##
#O  UnivariatePolynomial( <ring>, <cofs>[, <ind>] )
##
##  <#GAPDoc Label="UnivariatePolynomial">
##  <ManSection>
##  <Oper Name="UnivariatePolynomial" Arg='ring, cofs[, ind]'/>
##
##  <Description>
##  constructs an univariate polynomial over the ring <A>ring</A> in the
##  indeterminate <A>ind</A> with the coefficients given by <A>cofs</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UnivariatePolynomial",
  [ IsRing, IsRingElementCollection, IsPosInt ] );

#############################################################################
##
#A  CoefficientsOfUnivariateRationalFunction( <rfun> )
##
##  <#GAPDoc Label="CoefficientsOfUnivariateRationalFunction">
##  <ManSection>
##  <Attr Name="CoefficientsOfUnivariateRationalFunction" Arg='rfun'/>
##
##  <Description>
##  if <A>rfun</A> is a univariate rational function, this attribute
##  returns a list <C>[ <A>ncof</A>, <A>dcof</A>, <A>val</A> ]</C>
##  where <A>ncof</A> and <A>dcof</A> are coefficient lists of univariate
##  polynomials <A>n</A> and <A>d</A> and a valuation <A>val</A> such that
##  <M><A>rfun</A> = x^{<A>val</A>} \cdot <A>n</A> / <A>d</A></M>
##  where <M>x</M> is the variable with the number given by
##  <Ref Attr="IndeterminateNumberOfUnivariateRationalFunction"/>.
##  Numerator and denominator are guaranteed to be cancelled.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CoefficientsOfUnivariateRationalFunction",
    IsUnivariateRationalFunction );

#############################################################################
##
#O  UnivariateRationalFunctionByCoefficients(<fam>,<ncof>,<dcof>,<val>[,<ind>])
##
##  <#GAPDoc Label="UnivariateRationalFunctionByCoefficients">
##  <ManSection>
##  <Oper Name="UnivariateRationalFunctionByCoefficients"
##   Arg='fam, ncof, dcof, val[, ind]'/>
##
##  <Description>
##  constructs a univariate rational function over the coefficients
##  family <A>fam</A> and in the indeterminate <A>ind</A> (defaulting to 1) with
##  numerator and denominator coefficients given by <A>ncof</A> and <A>dcof</A> and
##  valuation <A>val</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UnivariateRationalFunctionByCoefficients",
    [ IsFamily, IsList, IsList, IsInt, IsInt ] );

#############################################################################
##
#O  Value(<ratfun>,<indets>,<vals>[,<one>])
#O  Value(<upol>,<value>[,<one>])
##
##  <#GAPDoc Label="Value">
##  <ManSection>
##  <Heading>Value</Heading>
##  <Oper Name="Value" Arg='ratfun, indets, vals[, one]'
##   Label="for rat. function, a list of indeterminates, a value (and a one)"/>
##  <Oper Name="Value" Arg='upol, value[, one]'
##   Label="for a univariate rat. function, a value (and a one)"/>
##
##  <Description>
##  The first variant takes a rational function <A>ratfun</A> and specializes
##  the indeterminates given in <A>indets</A> to the values given in
##  <A>vals</A>,
##  replacing the <M>i</M>-th entry in <A>indets</A> by the <M>i</M>-th entry
##  in <A>vals</A>.
##  If this specialization results in a constant polynomial,
##  an element of the coefficient ring is returned.
##  If the specialization would specialize the denominator of <A>ratfun</A>
##  to zero, an error is raised.
##  <P/>
##  A variation is the evaluation at elements of another ring <M>R</M>,
##  for which a multiplication with elements of the coefficient ring of
##  <A>ratfun</A> are defined.
##  In this situation the identity element of <M>R</M> may be given by a
##  further argument <A>one</A> which will be used for <M>x^0</M> for any
##  specialized indeterminate <M>x</M>.
##  <P/>
##  The second version takes an univariate rational function and specializes
##  the value of its indeterminate to <A>val</A>.
##  Again, an optional argument <A>one</A> may be given.
##  <C>Value( <A>upol</A>, <A>val</A> )</C> can also be expressed as <C>upol(
##  <A>val</A> )</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> Value(x*y+y+x^7,[x,y],[5,7]);
##  78167
##  ]]></Example>
##  <P/>
##  Note that the default values for <A>one</A> can lead to different results
##  than one would expect:
##  For example for a matrix <M>M</M>, the values <M>M+M^0</M> and <M>M+1</M>
##  are <E>different</E>.
##  As <Ref Oper="Value" Label="for rat. function, a list of indeterminates, a value (and a one)"/>
##  defaults to the one of the coefficient ring,
##  when evaluating matrices in polynomials always the correct <A>one</A>
##  should be given!
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("Value",[IsPolynomialFunction,IsList,IsList]);

#############################################################################
##
#F  OnIndeterminates(<poly>,<perm>)
##
##  <#GAPDoc Label="OnIndeterminates">
##  <ManSection>
##  <Func Name="OnIndeterminates" Arg='poly, perm'
##   Label="as a permutation action"/>
##
##  <Description>
##  A permutation <A>perm</A> acts on the multivariate polynomial <A>poly</A>
##  by permuting the indeterminates as it permutes points.
##  <Example><![CDATA[
##  gap> x:=Indeterminate(Rationals,1);; y:=Indeterminate(Rationals,2);;
##  gap> OnIndeterminates(x^7*y+x*y^4,(1,17)(2,28));
##  x_17^7*x_28+x_17*x_28^4
##  gap> Stabilizer(Group((1,2,3,4),(1,2)),x*y,OnIndeterminates);
##  Group([ (1,2), (3,4) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OnIndeterminates");

#############################################################################
##
#F  ConstituentsPolynomial(<pol>)
##
##  <ManSection>
##  <Func Name="ConstituentsPolynomial" Arg='pol'/>
##
##  <Description>
##  Given a polynomial <A>pol</A> this function returns a record with
##  components
##  <List>
##  <Mark><C>variables</C>:</Mark>
##  <Item>
##     A list of the variables occurring in <A>pol</A>,
##  </Item>
##  <Mark><C>monomials</C>:</Mark>
##  <Item>
##     A list of the monomials in <A>pol</A>, and
##  </Item>
##  <Mark><C>coefficients</C>:</Mark>
##  <Item>
##     A (corresponding) list of coefficients.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ConstituentsPolynomial");

##  <#GAPDoc Label="[4]{ratfun}">
##  <Index>Expanded form of monomials</Index>
##  A monomial is a product of powers of indeterminates. A monomial is
##  stored as a list (we call this the <E>expanded form</E> of the monomial)
##  of the form <C>[<A>inum</A>,<A>exp</A>,<A>inum</A>,<A>exp</A>,...]</C> where each <A>inum</A>
##  is the number of an indeterminate and <A>exp</A> the corresponding exponent.
##  The list must be sorted according to the numbers of the indeterminates.
##  Thus for example, if <M>x</M>, <M>y</M> and <M>z</M> are the first three indeterminates,
##  the expanded form of the monomial <M>x^5 z^8 = z^8 x^5</M> is
##  <C>[ 1, 5, 3, 8 ]</C>.
##  <#/GAPDoc>


#############################################################################
##
#F  MonomialExtGrlexLess(<a>,<b>)
##
##  <#GAPDoc Label="MonomialExtGrlexLess">
##  <ManSection>
##  <Func Name="MonomialExtGrlexLess" Arg='a,b'/>
##
##  <Description>
##  implements comparison of monomial in their external representation by a
##  <Q>grlex</Q> order with <M>x_1>x_2</M>
##  (This is exactly the same as the ordering by
##  <Ref Func="MonomialGrlexOrdering"/>,
##  see&nbsp; <Ref Sect="Monomial Orderings"/>).
##  The function takes two
##  monomials <A>a</A> and <A>b</A> in expanded form and returns whether the first is
##  smaller than the second. (This ordering is also used by &GAP;
##  internally for representing polynomials as a linear combination of
##  monomials.)
##  <P/>
##  See section&nbsp;<Ref Sect="The Defining Attributes of Rational Functions"/> for details
##  on the expanded form of monomials.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MonomialExtGrlexLess");

#############################################################################
##
#F  LeadingMonomial(<pol>)  . . . . . . . .  leading monomial of a polynomial
##
##  <#GAPDoc Label="LeadingMonomial">
##  <ManSection>
##  <Oper Name="LeadingMonomial" Arg='pol'/>
##
##  <Description>
##  returns the leading monomial (with respect to the ordering given by
##  <Ref Func="MonomialExtGrlexLess"/>) of the polynomial <A>pol</A> as a list
##  containing indeterminate numbers and exponents.
##  <Example><![CDATA[
##  gap> LeadingCoefficient(f,1);
##  1
##  gap> LeadingCoefficient(f,2);
##  9
##  gap> LeadingMonomial(f);
##  [ 2, 7 ]
##  gap> LeadingCoefficient(f);
##  9
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeadingMonomial", [ IsPolynomialFunction ] );

#############################################################################
##
#O  LeadingCoefficient( <pol> )
##
##  <#GAPDoc Label="LeadingCoefficient">
##  <ManSection>
##  <Oper Name="LeadingCoefficient" Arg='pol'/>
##
##  <Description>
##  returns the leading coefficient (that is the coefficient of the leading
##  monomial, see&nbsp;<Ref Oper="LeadingMonomial"/>) of the polynomial <A>pol</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("LeadingCoefficient", [IsPolynomialFunction]);

#############################################################################
##
#F  LeadingMonomialPosExtRep(<fam>,<ext>,<order>)
##
##  <ManSection>
##  <Func Name="LeadingMonomialPosExtRep" Arg='fam,ext,order'/>
##
##  <Description>
##  This function takes an external representation <A>ext</A> of a polynomial in
##  family <A>fam</A> and returns the position of the leading monomial in <A>ext</A>
##  with respect to the monomial order implemented by the function <A>order</A>.
##  <P/>
##  See section&nbsp;<Ref Sect="The Defining Attributes of Rational Functions"/> for details
##  on the external representation.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("LeadingMonomialPosExtRep");


##  The following set of functions consider one indeterminate of a multivariate
##  polynomial specially


#############################################################################
##
#O  PolynomialCoefficientsOfPolynomial( <pol>, <ind> )
##
##  <#GAPDoc Label="PolynomialCoefficientsOfPolynomial">
##  <ManSection>
##  <Oper Name="PolynomialCoefficientsOfPolynomial" Arg='pol, ind'/>
##
##  <Description>
##  <Ref Oper="PolynomialCoefficientsOfPolynomial"/> returns the
##  coefficient list (whose entries are polynomials not involving the
##  indeterminate <A>ind</A>) describing the polynomial <A>pol</A> viewed as
##  a polynomial in <A>ind</A>.
##  Instead of the indeterminate,
##  <A>ind</A> can also be an indeterminate number.
##  <Example><![CDATA[
##  gap> PolynomialCoefficientsOfPolynomial(f,2);
##  [ x^5+2, 3*x+3, 0, 0, 0, 4*x, 0, 9 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PolynomialCoefficientsOfPolynomial",
  [ IsPolynomial,IsPosInt]);

#############################################################################
##
#O  DegreeIndeterminate( <pol>,<ind> )
##
##  <#GAPDoc Label="DegreeIndeterminate">
##  <ManSection>
##  <Oper Name="DegreeIndeterminate" Arg='pol, ind'/>
##
##  <Description>
##  returns the degree of the polynomial <A>pol</A> in the indeterminate
##  (or indeterminate number) <A>ind</A>.
##  <Example><![CDATA[
##  gap> f:=x^5+3*x*y+9*y^7+4*y^5*x+3*y+2;
##  9*y^7+4*x*y^5+x^5+3*x*y+3*y+2
##  gap> DegreeIndeterminate(f,1);
##  5
##  gap> DegreeIndeterminate(f,y);
##  7
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DegreeIndeterminate",[IsPolynomial,IsPosInt]);

#############################################################################
##
#A  Derivative( <ratfun>[, <ind>] )
##
##  <#GAPDoc Label="Derivative">
##  <ManSection>
##  <Attr Name="Derivative" Arg='ratfun[, ind]'/>
##
##  <Description>
##  If <A>ratfun</A> is a univariate rational function then
##  <Ref Attr="Derivative"/> returns the <E>derivative</E> of <A>ufun</A> by
##  its indeterminate.
##  For a rational function <A>ratfun</A>,
##  the derivative by the indeterminate <A>ind</A> is returned,
##  regarding <A>ratfun</A> as univariate in <A>ind</A>.
##  Instead of the desired indeterminate, also the number of this
##  indeterminate can be given as <A>ind</A>.
##  <Example><![CDATA[
##  gap> Derivative(f,2);
##  63*y^6+20*x*y^4+3*x+3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Derivative",IsUnivariateRationalFunction);
DeclareOperation("Derivative",[IsPolynomialFunction,IsPosInt]);

#############################################################################
##
#A  TaylorSeriesRationalFunction( <ratfun>, <at>, <deg> )
##
##  <#GAPDoc Label="TaylorSeriesRationalFunction">
##  <ManSection>
##  <Attr Name="TaylorSeriesRationalFunction" Arg='ratfun, at, deg]'/>
##
##  <Description>
##  Computes the taylor series up to degree <A>deg</A> of <A>ratfun</A> at
##  <A>at</A>.
##  <Example><![CDATA[
##  gap> TaylorSeriesRationalFunction((x^5+3*x+7)/(x^5+x+1),0,11);
##  -50*x^11+36*x^10-26*x^9+22*x^8-18*x^7+14*x^6-10*x^5+4*x^4-4*x^3+4*x^2-4*x+7
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TaylorSeriesRationalFunction");


#############################################################################
##
#O  Resultant( <pol1>, <pol2>, <ind> )
##
##  <#GAPDoc Label="Resultant">
##  <ManSection>
##  <Oper Name="Resultant" Arg='pol1, pol2, ind'/>
##
##  <Description>
##  computes the resultant of the polynomials <A>pol1</A> and <A>pol2</A>
##  with respect to the indeterminate <A>ind</A>,
##  or indeterminate number <A>ind</A>.
##  The resultant considers <A>pol1</A> and <A>pol2</A> as univariate in
##  <A>ind</A> and returns an element of the corresponding base ring
##  (which might be a polynomial ring).
##  <Example><![CDATA[
##  gap> Resultant(x^4+y,y^4+x,1);
##  y^16+y
##  gap> Resultant(x^4+y,y^4+x,2);
##  x^16+x
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Resultant",[ IsPolynomial, IsPolynomial, IsPosInt]);


#############################################################################
##
#O  Discriminant( <pol>[, <ind>] )
##
##  <#GAPDoc Label="Discriminant">
##  <ManSection>
##  <Oper Name="Discriminant" Arg='pol[, ind]'/>
##
##  <Description>
##  If <A>pol</A> is a univariate polynomial then
##  <Ref Oper="Discriminant"/> returns the <E>discriminant</E> of <A>pol</A>
##  by its indeterminate.
##  The two-argument form returns the discriminant of a polynomial <A>pol</A>
##  by the indeterminate number <A>ind</A>, regarding <A>pol</A> as univariate
##  in this indeterminate. Instead of the indeterminate number, the
##  indeterminate itself can also be given as <A>ind</A>.
##  <Example><![CDATA[
##  gap> Discriminant(f,1);
##  20503125*y^28+262144*y^25+27337500*y^22+19208040*y^21+1474560*y^17+136\
##  68750*y^16+18225000*y^15+6075000*y^14+1105920*y^13+3037500*y^10+648972\
##  0*y^9+4050000*y^8+900000*y^7+62208*y^5+253125*y^4+675000*y^3+675000*y^\
##  2+300000*y+50000
##  gap> Discriminant(f,1) = Discriminant(f,x);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Discriminant", IsPolynomial );
DeclareOperation( "Discriminant", [ IsPolynomial, IsPosInt ] );


##  Technical functions for rational functions


#############################################################################
##
#F  CIUnivPols( <upol1>, <upol2> )
##
##  <#GAPDoc Label="CIUnivPols">
##  <ManSection>
##  <Func Name="CIUnivPols" Arg='upol1, upol2'/>
##
##  <Description>
##  This function (whose name stands for
##  <Q>common indeterminate of univariate polynomials</Q>) takes two
##  univariate polynomials as arguments.
##  If both polynomials are given in the same indeterminate number
##  <A>indnum</A> (in this case they are <Q>compatible</Q> as
##  univariate polynomials) it returns <A>indnum</A>.
##  In all other cases it returns <K>fail</K>.
##  <Ref Func="CIUnivPols"/> also accepts if either polynomial is constant
##  but formally expressed in another indeterminate, in this situation the
##  indeterminate of the other polynomial is selected.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("CIUnivPols");

#############################################################################
##
#F  TryGcdCancelExtRepPolynomials(<fam>,<a>,<b>);
##
##  <#GAPDoc Label="TryGcdCancelExtRepPolynomials">
##  <ManSection>
##  <Func Name="TryGcdCancelExtRepPolynomials" Arg='fam,a,b'/>
##
##  <Description>
##  Let <A>a</A> and <A>b</A> be the external representations of two
##  polynomials.
##  This function tries to cancel common factors between the corresponding
##  polynomials and returns a list <M>[ a', b' ]</M> of
##  external representations of cancelled polynomials.
##  As there is no proper multivariate GCD
##  cancellation is not guaranteed to be optimal.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TryGcdCancelExtRepPolynomials");

#############################################################################
##
#O  HeuristicCancelPolynomialsExtRep(<fam>,<ext1>,<ext2>)
##
##  <#GAPDoc Label="HeuristicCancelPolynomialsExtRep">
##  <ManSection>
##  <Oper Name="HeuristicCancelPolynomialsExtRep" Arg='fam,ext1,ext2'/>
##
##  <Description>
##  is called by <Ref Func="TryGcdCancelExtRepPolynomials"/> to perform the
##  actual work.
##  It will return either <K>fail</K> or a new list of external
##  representations of cancelled polynomials.
##  The cancellation performed is not necessarily optimal.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("HeuristicCancelPolynomialsExtRep",
  [IsRationalFunctionsFamily,IsList,IsList]);

#############################################################################
##
#F  QuotientPolynomialsExtRep(<fam>,<a>,<b>)
##
##  <#GAPDoc Label="QuotientPolynomialsExtRep">
##  <ManSection>
##  <Func Name="QuotientPolynomialsExtRep" Arg='fam,a,b'/>
##
##  <Description>
##  Let <A>a</A> and <A>b</A> the external representations of two polynomials
##  in the rational functions family <A>fam</A>.
##  This function computes the external representation of the quotient of
##  both polynomials,
##  it returns <K>fail</K> if the polynomial described by <A>b</A> does not
##  divide the polynomial described by <A>a</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("QuotientPolynomialsExtRep");

#############################################################################
##
#F  QuotRemLaurpols(<left>,<right>,<mode>)
##
##  <#GAPDoc Label="QuotRemLaurpols">
##  <ManSection>
##  <Func Name="QuotRemLaurpols" Arg='left,right,mode'/>
##
##  <Description>
##  This internal function for euclidean division of polynomials
##  takes two polynomials <A>left</A> and <A>right</A>
##  and computes their quotient. No test is performed whether the arguments
##  indeed  are polynomials.
##  Depending on the integer variable <A>mode</A>, which may take values in
##  a range from 1 to 4, it returns respectively:
##  <Enum>
##  <Item>
##    the quotient (there might be some remainder),
##  </Item>
##  <Item>
##    the remainder,
##  </Item>
##  <Item>
##    a list <C>[<A>q</A>,<A>r</A>]</C> of quotient and remainder,
##  </Item>
##  <Item>
##    the quotient if there is no remainder and <K>fail</K> otherwise.
##  </Item>
##  </Enum>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("QuotRemLaurpols");

#############################################################################
##
#F  GcdCoeffs(<a>,<b>)
##
##  <ManSection>
##  <Func Name="GcdCoeffs" Arg='a,b'/>
##
##  <Description>
##  computes the univariate gcd coefficient list from coefficient lists.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("GcdCoeffs");

#############################################################################
##
#F  UnivariatenessTestRationalFunction(<f>)
##
##  <#GAPDoc Label="UnivariatenessTestRationalFunction">
##  <ManSection>
##  <Func Name="UnivariatenessTestRationalFunction" Arg='f'/>
##
##  <Description>
##  takes a rational function <A>f</A> and tests whether it is univariate
##  rational function (or even a Laurent polynomial). It returns a list
##  <C>[isunivariate, indet, islaurent, cofs]</C>.
##  <P/>
##  If <A>f</A> is a univariate rational function then <C>isunivariate</C>
##  is <K>true</K> and <C>indet</C> is the number of the appropriate
##  indeterminate.
##  <P/>
##  Furthermore, if <A>f</A> is a Laurent polynomial, then <C>islaurent</C>
##  is also <K>true</K>. In this case the fourth entry, <C>cofs</C>, is
##  the value of the attribute <Ref Attr="CoefficientsOfLaurentPolynomial"/>
##  for <A>f</A>.
##  <P/>
##  If <C>isunivariate</C> is <K>true</K> but <C>islaurent</C> is
##  <K>false</K>, then <C>cofs</C> is the value of the attribute
##  <Ref Attr="CoefficientsOfUnivariateRationalFunction"/> for <A>f</A>.
##  <P/>
##  Otherwise, each entry of the returned list is equal to <K>fail</K>.
##  As there is no proper multivariate gcd, this may also happen for the
##  rational function which may be reduced to univariate (see example).
##  <Example><![CDATA[
##  gap> UnivariatenessTestRationalFunction( 50-45*x-6*x^2+x^3 );
##  [ true, 1, true, [ [ 50, -45, -6, 1 ], 0 ] ]
##  gap> UnivariatenessTestRationalFunction( (-6*y^2+y^3) / (y+1) );
##  [ true, 2, false, [ [ -6, 1 ], [ 1, 1 ], 2 ] ]
##  gap> UnivariatenessTestRationalFunction( (-6*y^2+y^3) / (x+1));
##  [ false, fail, false, fail ]
##  gap> UnivariatenessTestRationalFunction( ((y+2)*(x+1)) / ((y-1)*(x+1)) );
##  [ fail, fail, fail, fail ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("UnivariatenessTestRationalFunction");

#############################################################################
##
#F  SpecializedExtRepPol(<fam>,<ext>,<ind>,<val>)
##
##  <ManSection>
##  <Func Name="SpecializedExtRepPol" Arg='fam,ext,ind,val'/>
##
##  <Description>
##  specializes the indeterminate <A>ind</A> in the polynomial ext rep to <A>val</A>
##  and returns the resulting polynomial ext rep.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SpecializedExtRepPol");

#############################################################################
##
#F  RandomPol(<ring>,<deg>[,<indnum>])
##
##  <ManSection>
##  <Func Name="RandomPol" Arg='ring,deg[,indnum]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RandomPol");

#############################################################################
##
#O  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
##
##  <#GAPDoc Label="ZippedSum">
##  <ManSection>
##  <Oper Name="ZippedSum" Arg='z1, z2, czero, funcs'/>
##
##  <Description>
##  computes the sum of two external representations of polynomials
##  <A>z1</A> and <A>z2</A>.
##  <A>czero</A> is the appropriate coefficient zero and <A>funcs</A> a list
##  [ <A>monomial_less</A>, <A>coefficient_sum</A> ] containing a monomial
##  comparison and a coefficient addition function.
##  This list can be found in the component <A>fam</A><C>!.zippedSum</C>
##  of the rational functions family.
##  <P/>
##  Note that <A>coefficient_sum</A> must be a proper <Q>summation</Q>
##  function, not a function computing differences.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZippedSum", [ IsList, IsList, IsObject, IsList ] );

#############################################################################
##
#O  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
##
##  <#GAPDoc Label="ZippedProduct">
##  <ManSection>
##  <Oper Name="ZippedProduct" Arg='z1, z2, czero, funcs'/>
##
##  <Description>
##  computes the product of two external representations of polynomials
##  <A>z1</A> and <A>z2</A>.
##  <A>czero</A> is the appropriate coefficient zero and <A>funcs</A> a list
##  [ <A>monomial_prod</A>, <A>monomial_less</A>, <A>coefficient_sum</A>,
##  <A>coefficient_prod</A>] containing functions to multiply and compare
##  monomials, to add and to multiply coefficients.
##  This list can be found in the component <C><A>fam</A>!.zippedProduct</C>
##  of the rational functions family.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZippedProduct", [ IsList, IsList, IsObject, IsList ] );

DeclareGlobalFunction( "ProdCoefRatfun" );
DeclareGlobalFunction( "SumCoefRatfun" );
DeclareGlobalFunction( "SumCoefPolynomial" );

##  The following functions are intended to permit the calculations with
##  (Laurent) Polynomials over Rings which are not an UFD. In this case it
##  is not possible to create the field of rational functions (and thus no
##  rational functions family exists.


#############################################################################
##
#C  IsLaurentPolynomialsFamilyElement
##
##  <ManSection>
##  <Filt Name="IsLaurentPolynomialsFamilyElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  constructs a family containing  all Laurent polynomials with coefficients
##  in <A>family</A>  for  a family which   has  a one and   is  commutative.  The
##  external representation looks like the one for <C>RationalsFunctionsFamily</C>
##  so if  one really wants  rational  functions where  the denominator  is a
##  non-zero-divisor <C>LaurentPolynomialFunctionsFamily</C> can easily be changed
##  to <C>RestrictedRationalsFunctionsFamily</C>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsLaurentPolynomialsFamilyElement", IsRationalFunction );


#############################################################################
##
#C  IsUnivariatePolynomialsFamilyElement
##
##  <ManSection>
##  <Filt Name="IsUnivariatePolynomialsFamilyElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsUnivariatePolynomialsFamilyElement",
    IsRationalFunction );

#############################################################################
##
#C  IsLaurentPolynomialsFamily(<obj>)
##
##  <ManSection>
##  <Filt Name="IsLaurentPolynomialsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  At present Laurent polynomials  families only  exist if the  coefficients
##  family is commutative and has a one.
##  <P/>
##  <!--  1996/10/14 fceller can this be done with <C>CategoryFamily</C>?-->
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsLaurentPolynomialsFamily",
    IsFamily and HasOne and IsCommutativeFamily );


#############################################################################
##
#C  IsUnivariatePolynomialsFamily
##
##  <ManSection>
##  <Filt Name="IsUnivariatePolynomialsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  At present univariate polynomials families only exist if the coefficients
##  family is a skew field.
##  <P/>
##  <!--  1996/10/14 fceller can this be done with <C>CategoryFamily</C>?-->
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsUnivariatePolynomialsFamily", IsFamily );



##  `IsRationalFunctionsFamilyElement',   an element of  a Laurent
##  polynomials family has category `IsLaurentPolynomialsFamilyElement',  and
##  an   element  of     a    univariate polynomials  family   has   category
##  `IsUnivariatePolynomialsFamilyElement'.   They  all   lie  in  the  super
##  category `IsRationalFunction'.

##
##  `IsPolynomial', `IsUnivariatePolynomials', `IsLaurentPolynomial',     and
##  `IsUnivariateLaurentPolynomial' are properties of rational functions.
##
##  The basic operations for rational functions are:
##
##    `ExtRepOfObj'
##    `ObjByExtRep'.
##
##  The basic operations for rational functions  which are univariate Laurent
##  polynomials are:
##
##    `UnivariateLaurentPolynomialByCoefficients'
##    `CoefficientsOfUnivariateLaurentPolynomial'
##    `IndeterminateNumberOfUnivariateLaurentPolynomial'
##


#needed as ``forward''-declaration.
DeclareGlobalFunction("MultivariateFactorsPolynomial");
