#############################################################################
##
#W  ratfun.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the categories,  attributes, properties and operations
##  for  rational functions, laurent polynomials   and polynomials and  their
##  families.
##
##  'RationalsFunctionsFamily( <family> )'
##
##  creates a   family  containing rational functions  with   coefficients in
##  <family>.  This family *must* be a UFD, that is to say, there are no zero
##  divisors, the family must have a one, is comutative and the factorisation
##  of an  elements into irreducible  elements of the  family is unique (upto
##  units and order).
##
##  This  still  leads  to some   strange  effects:  If   one constructs  the
##  polynomial ring over the Integers and then takes
##
##    (2*x + 1) / 2
##
##  this will be reduced to
##
##    x + 1/2
##
##  which lies in the family.  So the membership test for the polynomial ring
##  of the integers must do some work.
##
##
##  'LaurentPolynomialsFamily( <family> )'
##
##  constructs a family containing  all Laurent polynomials with coefficients
##  in <family>  for  a family which   has  a one and   is  commutative.  The
##  external representation looks like the one for 'RationalsFunctionsFamily'
##  so if  one really wants  rational  functions where  the denominator  is a
##  non-zero-divisor 'LaurentPolynomialFunctionsFamily' can easily be changed
##  to 'RestrictedRationalsFunctionsFamily'.
##
##
##  'UnivariatePolynomialsFamily( <family>, <derivation> )'
##
##  creates  a univariate  polynomials family over   a skew  field  using the
##  function <derivation> which defines
##
##    ax = xb + c
##
##  for all a in <family>.  The only implementation at the moment will be for
##  trivial derivations.  Again the external representation is the same as in
##  'RationalsFunctionsFamily'  in case one    needs a  multivariate  version
##  later.
##
##
##  To summarise the  above: 

#1
##  A monomial is a product of powers of indeterminates. {\GAP} represents
##  these as lists $[i_1,e_1,i_2,e_2,\ldots i_k,e_k]$ where $i_j$ is the
##  *number* of an indeterminate and $e_j>0$ the corresponding (positive)
##  exponent. The indeterminates must be sorted ($i_j\<i_{j+1}$),
##  i.e. `[1,2,2,1]' is correct, `[2,1,1,2]' is not!
##
##  The external representation  of  polynomials is a pair [ <zero>,
##  <polynomial>
##  ], the external representation of rational functions a triple [ <zero>,
##  <numerator-polynomial>,   <denominator-polynomial> ]. Here <zero> simply
##  is the zero of the coefficients ring. The polynomials
##  are sequences of monomials and coefficients. For example
##  $x_1^2+3x_2x_5^7$ is encoded as [[1,2],1,[2,1,3,7],3].
##
##  The monomials in an external representation also have to be sorted
##  according to a total degree/lexicographic order (see "Comparison of
##  Rational Functions").
##
##  In order to avoid confusion an element of a rational functions family has
##  category   'IsRationalFunctionsFamilyElement',   an element of  a Laurent
##  polynomials family has category 'IsLaurentPolynomialsFamilyElement',  and
##  an   element  of     a    univariate polynomials  family   has   category
##  'IsUnivariatePolynomialsFamilyElement'.   They  all   lie  in  the  super
##  category 'IsRationalFunction'.

##
##  'IsPolynomial', 'IsUnivariatePolynomials', 'IsLaurentPolynomial',     and
##  'IsUnivariateLaurentPolynomial' are properties of rational functions.
##
##  The basic operations for rational functions are:
##
##    'ExtRepOfObj'
##    'ObjByExtRep'.
##
##  The basic operations for rational functions  which are univariate laurent
##  polynomials are:
##
##    'UnivariateLaurentPolynomialByCoefficients'
##    'CoefficientsOfUnivariateLaurentPolynomial'
##    'IndeterminateNumberOfUnivariateLaurentPolynomial'
##
Revision.ratfun_gd :=
    "@(#)$Id$";


#############################################################################
##
#I  InfoPoly
##
DeclareInfoClass( "InfoPoly" );


#############################################################################
##

#C  IsRationalFunction
##
DeclareCategory( "IsRationalFunction", IsRingElementWithInverse );

DeclareCategoryCollections( "IsRationalFunction" );


#############################################################################
##
#C  IsRationalFunctionsFamilyElement
##
DeclareCategory( "IsRationalFunctionsFamilyElement", IsRationalFunction );


#############################################################################
##
#C  IsLaurentPolynomialsFamilyElement
##
DeclareCategory( "IsLaurentPolynomialsFamilyElement", IsRationalFunction );


#############################################################################
##
#C  IsUnivariatePolynomialsFamilyElement
##
DeclareCategory( "IsUnivariatePolynomialsFamilyElement",
    IsRationalFunction );


#############################################################################
##
#C  IsRationalFunctionsFamily
##
##  at present  rations functions families  only   exist if the  coefficients
##  family is a UFD family
##
#T  1996/10/14 fceller can this be done with 'CategoryFamily'?
##
DeclareCategory( "IsRationalFunctionsFamily", IsFamily and IsUFDFamily );


#############################################################################
##
#C  IsLaurentPolynomialsFamily
##
##  at present laurent polynomials  families only  exist if the  coefficients
##  family is commutative and has a one
##
#T  1996/10/14 fceller can this be done with 'CategoryFamily'?
##
DeclareCategory( "IsLaurentPolynomialsFamily",
    IsFamily and HasOne and IsCommutativeFamily );


#############################################################################
##
#C  IsUnivariatePolynomialsFamily
##
##  at present univariate polynomials families only exist if the coefficients
##  family is a skew field
##
#T  1996/10/14 fceller can this be done with 'CategoryFamily'?
##
DeclareCategory( "IsUnivariatePolynomialsFamily", IsFamily );


#############################################################################
##
#P  IsConstantRationalFunction( <rat-fun> )
##
##  A  constant  rational   function is  a    function  whose  numerator  and
##  denominator are constant polynomials  (note that num/den returned by  the
##  apropiate functions are always reduced)
##
DeclareProperty( "IsConstantRationalFunction", IsRationalFunction );



#############################################################################
##
#P  IsLaurentPolynomial( <rat-fun> )
##
##  A laurent polynomial   is a rational   functions whose denominator  is  a
##  polynomial containg exactly one monomial.
##
DeclareProperty( "IsLaurentPolynomial", IsRationalFunction );



#############################################################################
##
#P  IsPolynomial( <rat-fun> )
##
##  A polynomial is  a rational functions whose  denominator is  a polynomial
##  containg exactly one monomial of degree 0.
##
DeclareProperty( "IsPolynomial", IsRationalFunction );



#############################################################################
##
#P  IsUnivariateLaurentPolynomial( <rat-fun> )
##
##  A univariate laurent polynomial is a laurent  polynomial and a univariate
##  function.
##
DeclareProperty( "IsUnivariateLaurentPolynomial", IsRationalFunction );



#############################################################################
##
#P  IsUnivariatePolynomial( <rat-fun> )
##
##  A univariate polynomial is a polynomial and a univariate function.
##
DeclareProperty( "IsUnivariatePolynomial", IsRationalFunction );



#############################################################################
##
#P  IsUnivariateRationalFunction( <rat-fun> )
##
DeclareProperty( "IsUnivariateRationalFunction", IsRationalFunction );


#############################################################################
##
#P  IsZeroRationalFunction( <rat-fun> )
##
DeclareProperty( "IsZeroRationalFunction", IsRationalFunction );



#############################################################################
##
#M  IsLaurentPolynomial( <poly> )
##
InstallTrueMethod( IsLaurentPolynomial, IsPolynomial );


#############################################################################
##
#M  IsLaurentPolynomial( <uni-laurent> )
##
InstallTrueMethod( IsLaurentPolynomial, IsUnivariateLaurentPolynomial );


#############################################################################
##
#M  IsPolynomial( <uni-poly> )
##
InstallTrueMethod( IsPolynomial, IsUnivariatePolynomial );


#############################################################################
##
#M  IsUnivariateLaurentPolynomial( <uni-poly> )
##
InstallTrueMethod( IsUnivariateLaurentPolynomial, IsUnivariatePolynomial );


#############################################################################
##
#A  RationalFunctionsFamily( <fam> )
##
##  creates a   family  containing rational functions  with   coefficients
##  in <fam>.  This family *must* be a UFD, that is to say, there are no
##  zero divisors, the family must have a one, be comutative and the
##  factorisation of an  elements into irreducible  elements of the  family
##  must be unique (up to units and order).
DeclareAttribute( "RationalFunctionsFamily", IsUFDFamily );



#############################################################################
##
#A  CoefficientsFamily( <fam> )
##
DeclareAttribute( "CoefficientsFamily", IsFamily );



#############################################################################
##
#A  CoefficientsOfUnivariateLaurentPolynomial( <uni-laurent> )
##
##  'CoefficientsOfUnivariateLaurentPolynomial' returns   a  pair, namely the
##  coefficient list and the valuation, describing the laurent polynomial.
##
DeclareAttribute( "CoefficientsOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );


#############################################################################
##
#A  CoefficientsOfUnivariatePolynomial( <pol> )
##
##  'CoefficientsOfUnivariatePolynomial'  returns  the     coefficient   list
##  of the polynomial <pol>, sorted in ascending order.
##
DeclareAttribute( "CoefficientsOfUnivariatePolynomial",
    IsRationalFunction and IsUnivariatePolynomial );


#############################################################################
##
#A  DegreeOfUnivariateLaurentPolynomial( <pol> )
##
##  The degree of a univariate (Laurent) polynomial <pol> is the largest
##  exponent $n$ of a monomial $x^n$ of <pol>.
DeclareAttribute( "DegreeOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );


#############################################################################
##
#A  DenominatorOfRationalFunction( <rat-fun> )
##
##  The denominator and numerator  of rational functions are always  reduced.
##  Note that the default representation *does not*  reduce, so one has to do
##  some work in this case.
##
DeclareAttribute( "DenominatorOfRationalFunction", IsRationalFunction );


#############################################################################
##
#A  IndeterminateNumberOfUnivariateLaurentPolynomial( <uni-laurent> )
##
##  returns the number of the indeterminate in which the laurent polynomial
##  <uni-laurent> is expressed. This also provides a way to obtain the
##  number of a given indeterminate.
DeclareAttribute( "IndeterminateNumberOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );


#############################################################################
##
#A  IndeterminateOfUnivariateLaurentPolynomial( <uni-laurent> )
##
##  returns the indeterminate in which the laurent polynomial
##  <uni-laurent> is expressed.
DeclareAttribute( "IndeterminateOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );


#############################################################################
##
#O  IndeterminateName(<fam>,<nr>)
#O  HasIndeterminateName(<fam>,<nr>)
#O  SetIndeterminateName(<fam>,<nr>,<name>)
##
##  `SetIndeterminateName' assigns the name <name> to indeterminate <nr>
##  in the rational functions family <fam>. It issues an error if the
##  indeterminate was already named.
##
##  `IndeterminateName' returns the name of the <nr>-th indeterminate (and
##  returns `fail' if no name has been assigned).
## 
##  `HasIndeterminateName' tests whether indeterminate <nr> has already been
##  assigned a name 
DeclareOperation( "IndeterminateName",
  [IsRationalFunctionsFamily,IsPosInt]);
DeclareOperation( "HasIndeterminateName",
  [IsRationalFunctionsFamily,IsPosInt]);
DeclareOperation( "SetIndeterminateName",
  [IsRationalFunctionsFamily,IsPosInt,IsString]);

#############################################################################
##
#A  NumeratorOfRationalFunction( <rat-fun> )
##
##  The denominator and numerator  of rational functions are always  reduced.
##  Note that the default representation *does not*  reduce, so one has to do
##  some work in this case.
##
DeclareAttribute( "NumeratorOfRationalFunction", IsRationalFunction );


#############################################################################
##
#O  Resultant( <pol1>,<pol2>,<inum> )
#O  Resultant( <pol1>,<pol2>,<ind> )
##
##  computes the resultant of the polynomials <pol1> and <pol2> with respect
##  to the indeterminate <ind> or indeterminate number <inum>.
DeclareOperation( "Resultant",[ IsRationalFunction and IsLaurentPolynomial,
      IsRationalFunction and IsLaurentPolynomial, IsPosInt]);

#############################################################################
##
#O  PolynomialCoefficientsOfLaurentPolynomial( <pol>, <inum> )
#O  PolynomialCoefficientsOfLaurentPolynomial( <pol>, <ind> )
##
##  `PolynomialCoefficientsOfLaurentPolynomial'  returns     a  pair,
##  the coefficient list (which are polynomials   not containing
##  indeterminate <ind>) and   the valuation, describing the laurent
##  polynomial viewed as laurent polynomial in <ind>.
##  Instead of <ind> also the indeterminate number <inum> can be given.
##
DeclareOperation( "PolynomialCoefficientsOfLaurentPolynomial",
    [ IsRationalFunction and IsLaurentPolynomial, IsPosInt]);


#############################################################################
##
#O  PolynomialCoefficientsOfPolynomial( <pol>, <inum> )
#O  PolynomialCoefficientsOfPolynomial( <pol>, <ind> )
##
##  `PolynomialCoefficientsOfPolynomial' returns the coefficient list
##  (which are polynomials not containing indeterminate <ind>)
##  describing the polynomial viewed as polynomial in <ind>. 
##  Instead of <ind> also the indeterminate number <inum> can be given.
##
DeclareOperation( "PolynomialCoefficientsOfPolynomial",
    [ IsRationalFunction and IsPolynomial,IsPosInt]);


#############################################################################
##
#O  UnivariateLaurentPolynomialByCoefficients( <fam>, <cofs>, <val> [,<ind>] )
##
##  constructs an univariate laurent polynomial over the coefficients
##  family <fam> and in the indeterminate <ind> (defaulting to 1) with
##  the coefficients given by <coefs> and valuation <val>.
DeclareOperation( "UnivariateLaurentPolynomialByCoefficients",
    [ IsFamily, IsList, IsInt, IsInt ] );

#############################################################################
##
#O  UnivariatePolynomialByCoefficients( <fam>, <cofs>, <ind> )
##
##  constructs an univariate polynomial over the coeffcients family
##  <fam> and in the indeterminate <ind> with the coefficients given by
##  <coefs>. This function should be used in algorithms to create
##  polynomials as it avoids overhead associated with
##  `UnivariatePolynomial'.
DeclareOperation( "UnivariatePolynomialByCoefficients",
    [ IsFamily, IsList, IsInt ] );


#############################################################################
##
#O  UnivariatePolynomial( <ring>, <cofs>, <ind> )
##
##  constructs an univariate polynomial over the ring <ring> in the
##  indeterminate <ind> with the coefficients given by <coefs>.
DeclareOperation( "UnivariatePolynomial",
  [ IsRing, IsRingElementCollection, IsPosInt ] );


#############################################################################
##
#O  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
##
##  <funcs> = [ <monomial less>, <coefficient sum> ]
##
DeclareOperation( "ZippedSum", [ IsList, IsList, IsObject, IsList ] );

#############################################################################
##
#O  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
##
##  <funcs> = [ <monomial prod>, <monomial less>,
##              <coefficient sum>, <coefficient prod> ]
##
DeclareOperation( "ZippedProduct", [ IsList, IsList, IsObject, IsList ] );


#############################################################################
##
#O  DegreeIndeterminate( <pol>,<ind> )
##
##  returns the degree of the polynomial pol in the indeterminate <ind>
##  (respectively indeterminate number <ind>).
##
DeclareOperation("DegreeIndeterminate",[IsRationalFunction,IsPosInt]);


#############################################################################
##
#O  Derivative( <upol> )
#O  Derivative( <pol>,<ind> )
##
##  returns the derivative $<upoly>'$ of the univariate polynomial <upoly>
##  by its indeterminant. The second version returns the derivative of <pol>
##  by the indeterminate <ind> (respectively indeterminate number <ind>).
##
DeclareOperation("Derivative",[IsUnivariateLaurentPolynomial]);


#############################################################################
##
#O  Discriminant( <upol> )
#O  Discriminant( <pol>,<ind> )
##
##  returns the discriminant $<upoly>'$ of the univariate polynomial <upoly>
##  by its indeterminant. The second version returns the discriminant of <pol>
##  by the indeterminate <ind> (respectively indeterminate number <ind>).
##
DeclareOperation("Discriminant",[IsUnivariateLaurentPolynomial]);


#############################################################################
##
#O  LeadingCoefficient( <pol> )
##
##  returns the leading coefficient (that is the coefficient of the monomial
##  with the highest exponent) of the polynomial <pol>.
##
DeclareOperation("LeadingCoefficient", [IsRationalFunction]);

#############################################################################
##
#F  LeadingMonomial(<pol>)  . . . . . . . .  leading monomial of a polynomial
##
##  returns the leading monomial of the polynomial <pol> as a list
##  containing indeterminate numbers and exponents.
##
DeclareOperation( "LeadingMonomial", [ IsRationalFunction ] );

#############################################################################
##
#F  MonomialRevLexico_Less(<a>,<b>)
##
##  implements comparison of monomials by the position/lexicographic
##  order.
DeclareGlobalFunction("MonomialRevLexico_Less");

#############################################################################
##
#F  MonomialTotalDegree_Less( <a>, <b> )
##
##  implements comparison of polynomials by the total degree order. This is
##  the order {\GAP} naturally puts on monomials.
DeclareGlobalFunction("MonomialTotalDegree_Less");

# basic polynomial reduction stuff

#############################################################################
##
#F  PolynomialReduction(<poly>,<gens>,<order>)
##
##  reduces the polynomial <poly> by the ideal generated by the polynomials
##  in <gens>, using the order <order> of monomials.
##  Unless <gens> is a Gr{\accent127 o}bner basis the result is not necessarily unique.
DeclareGlobalFunction("PolynomialReduction");

#############################################################################
##
#F  LeadingMonomialPosExtRep(<ext>,<order>)
##
DeclareGlobalFunction("LeadingMonomialPosExtRep");

#############################################################################
##
#F  ValueMultivariate(<poly>,<vals>[,<one>]) 
#O  Value(<poly>,<vals>[,<one>]) 
#O  Value( <upol>, <elm> )
#O  Value( <upol>, <elm>, <one> )
##
##  Evaluates the multivariate polynomial <poly> at the point given by
##  specializing the <i>-th indeterminate to <vals>[<i>]. 
##  The optional third argument <one> is a multiplicative neutral element
##  that will be taken instead of the zero-th power of <elm>.
##                               
##  The third and fourth version
##  evaluate the univariate polynomial <upoly> at <elm>.
##
DeclareOperation("Value",[IsRationalFunction,IsRingElement]);
DeclareGlobalFunction("ValueMultivariate");


#############################################################################
##
#F  OnIndeterminates(poly,perm) 
##                               
##  A permutation <perm> acts on the multivariate polynomial <poly> by
##  permuting the indeterminates as it permutes points.
DeclareGlobalFunction("OnIndeterminates");

#############################################################################
##
#F  BRCIUnivPols( <upol>, <upol> )
##
##  This function (whose name stands for
##  ``BaseRingAndCommonIndeterminateOfUnivariatePolynomials'') takes two
##  univariate polynomials as arguments. If both polynomials are given in
##  the same indeterminate number <indnum> and have the same
##  `CoefficientsFamily' <coefam> (in this case they are ``compatible'' as
##  univariate polynomials) it returns the list [<coefam>,<indnum>]. In all
##  other cases it returns `fail'.
DeclareGlobalFunction("BRCIUnivPols");

#############################################################################
##
#O  TryGcdCancelExtRepPol(<fam>,<a>,<b>,<zero>);
##
##  Let `f:=ObjByExtRep(<fam>,[<zero>,<a>])'
##  and `g:=ObjByExtRep(<fam>,[<zero>,<a>])'. This routine tries to compute
##  a gcd of <f> and <g>. It returns `fail' if no gcd could be computed and
##  two coefficient parts of the extenal representation <ar> and <br> of the
##  reduced polynomials.
DeclareOperation("TryGcdCancelExtRepPol",
  [IsRationalFunctionsFamily,IsList,IsList,IsScalar]);

#############################################################################
##
#E  ratfun.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
