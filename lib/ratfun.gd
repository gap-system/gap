#############################################################################
##
#W  ratfun.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
##  To summarise the  above: the external representation  of  elements in all
##  three families is the same; it is either a tuple [ one, polynomial ] or a
##  triple [ one,  numerator-polynomial,   denominator-polynomial ].    These
##  polynomials are sequences of exponents and coefficients.
##
##  External representations are to be guarnteed to have the monomials
##  sorted, i.e. [1,2,2,1] is correct, [2,1,1,2] is not!
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

#C  IsRationalFunction
##
IsRationalFunction := NewCategory(
    "IsRationalFunction",
    IsRingElementWithInverse );

IsRationalFunctionCollection := CategoryCollections(
    "IsRationalFunctionCollection",
    IsRationalFunction );


#############################################################################
##
#C  IsRationalFunctionsFamilyElement
##
IsRationalFunctionsFamilyElement := NewCategory(
    "IsRationalFunctionsFamilyElement",
    IsRationalFunction );


#############################################################################
##
#C  IsLaurentPolynomialsFamilyElement
##
IsLaurentPolynomialsFamilyElement := NewCategory(
    "IsLaurentPolynomialsFamilyElement",
    IsRationalFunction );


#############################################################################
##
#C  IsUnivariatePolynomialsFamilyElement
##
IsUnivariatePolynomialsFamilyElement := NewCategory(
    "IsUnivariatePolynomialsFamilyElement",
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
IsRationalFunctionsFamily := NewCategory(
    "IsRationalFunctionsFamily",
    IsFamily and IsUFDFamily );


#############################################################################
##
#C  IsLaurentPolynomialsFamily
##
##  at present laurent polynomials  families only  exist if the  coefficients
##  family is commutative and has a one
##
#T  1996/10/14 fceller can this be done with 'CategoryFamily'?
##
IsLaurentPolynomialsFamily := NewCategory(
    "IsLaurentPolynomialsFamily",
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
IsUnivariatePolynomialsFamily := NewCategory(
    "IsUnivariatePolynomialsFamily",
    IsFamily );


#############################################################################
##

#P  IsConstantRationalFunction( <rat-fun> )
##
##  A  constant  rational   function is  a    function  whose  numerator  and
##  denominator are constant polynomials  (note that num/den returned by  the
##  apropiate functions are always reduced)
##
IsConstantRationalFunction := NewProperty(
    "IsConstantRationalFunction",
    IsRationalFunction );

SetIsConstantRationalFunction := Setter(IsConstantRationalFunction);
HasIsConstantRationalFunction := Tester(IsConstantRationalFunction);


#############################################################################
##
#P  IsLaurentPolynomial( <rat-fun> )
##
##  A laurent polynomial   is a rational   functions whose denominator  is  a
##  polynomial containg exactly one monomial.
##
IsLaurentPolynomial := NewProperty(
    "IsLaurentPolynomial",
    IsRationalFunction );

SetIsLaurentPolynomial := Setter(IsLaurentPolynomial);
HasIsLaurentPolynomial := Tester(IsLaurentPolynomial);


#############################################################################
##
#P  IsPolynomial( <rat-fun> )
##
##  A polynomial is  a rational functions whose  denominator is  a polynomial
##  containg exactly one monomial of degree 0.
##
IsPolynomial := NewProperty(
    "IsPolynomial",
    IsRationalFunction );

SetIsPolynomial := Setter(IsPolynomial);
HasIsPolynomial := Tester(IsPolynomial);


#############################################################################
##
#P  IsUnivariateLaurentPolynomial( <rat-fun> )
##
##  A univariate laurent polynomial is a laurent  polynomial and a univariate
##  function.
##
IsUnivariateLaurentPolynomial := NewProperty(
    "IsUnivariateLaurentPolynomial",
    IsRationalFunction );

SetIsUnivariateLaurentPolynomial := Setter(IsUnivariateLaurentPolynomial);
HasIsUnivariateLaurentPolynomial := Tester(IsUnivariateLaurentPolynomial);


#############################################################################
##
#P  IsUnivariatePolynomial( <rat-fun> )
##
##  A univariate polynomial is a polynomial and a univariate function.
##
IsUnivariatePolynomial := NewProperty(
    "IsUnivariatePolynomial",
    IsRationalFunction );

SetIsUnivariatePolynomial := Setter(IsUnivariatePolynomial);
HasIsUnivariatePolynomial := Tester(IsUnivariatePolynomial);


#############################################################################
##
#P  IsUnivariateRationalFunction( <rat-fun> )
##
IsUnivariateRationalFunction := NewProperty(
    "IsUnivariateRationalFunction",
    IsRationalFunction );


#############################################################################
##
#P  IsZeroRationalFunction( <rat-fun> )
##
IsZeroRationalFunction := NewProperty(
    "IsZeroRationalFunction",
    IsRationalFunction );

SetIsZeroRationalFunction := Setter(IsZeroRationalFunction);
HasIsZeroRationalFunction := Tester(IsZeroRationalFunction);


#############################################################################
##

#M  IsLaurentPolynomial( <poly> )
##
InstallTrueMethod( IsLaurentPolynomial,
    IsPolynomial );


#############################################################################
##
#M  IsLaurentPolynomial( <uni-laurent> )
##
InstallTrueMethod( IsLaurentPolynomial,
    IsUnivariateLaurentPolynomial );


#############################################################################
##
#M  IsPolynomial( <uni-poly> )
##
InstallTrueMethod( IsPolynomial,
    IsUnivariatePolynomial );


#############################################################################
##
#M  IsUnivariateLaurentPolynomial( <uni-poly> )
##
InstallTrueMethod( IsUnivariateLaurentPolynomial,
   IsUnivariatePolynomial );


#############################################################################
##

#A  RationalFunctionsFamily( <fam> )
##
RationalFunctionsFamily := NewAttribute(
    "RationalFunctionsFamily",
    IsUFDFamily );

SetRationalFunctionsFamily := Setter(RationalFunctionsFamily);
HasRationalFunctionsFamily := Tester(RationalFunctionsFamily);


#############################################################################
##
#A  CoefficientsFamily( <fam> )
##
CoefficientsFamily := NewAttribute(
    "CoefficientsFamily",
    IsFamily );

SetCoefficientsFamily := Setter(CoefficientsFamily);
HasCoefficientsFamily := Tester(CoefficientsFamily);


#############################################################################
##

#A  CoefficientsOfUnivariateLaurentPolynomial( <uni-laurent> )
##
##  'CoefficientsOfUnivariateLaurentPolynomial' returns   a  pair, namely the
##  coefficient list and the valuation, describing the laurent polynomial.
##
CoefficientsOfUnivariateLaurentPolynomial := NewAttribute(
    "CoefficientsOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );

SetCoefficientsOfUnivariateLaurentPolynomial :=
    Setter(CoefficientsOfUnivariateLaurentPolynomial);
HasCoefficientsOfUnivariateLaurentPolynomial :=
    Tester(CoefficientsOfUnivariateLaurentPolynomial);


#############################################################################
##
#A  CoefficientsOfUnivariatePolynomial( <uni-pol> )
##
##  'CoefficientsOfUnivariatePolynomial'  returns  the     coefficient   list
##  describing the polynomial.
##
CoefficientsOfUnivariatePolynomial := NewAttribute(
    "CoefficientsOfUnivariatePolynomial",
    IsRationalFunction and IsUnivariatePolynomial );

SetCoefficientsOfUnivariatePolynomial :=
    Setter(CoefficientsOfUnivariatePolynomial);
HasCoefficientsOfUnivariatePolynomial :=
    Tester(CoefficientsOfUnivariatePolynomial);


#############################################################################
##
#A  DegreeOfUnivariateLaurentPolynomial( <uni-laurent> )
##
DegreeOfUnivariateLaurentPolynomial := NewAttribute(
    "DegreeOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );

SetDegreeOfUnivariateLaurentPolynomial :=
    Setter(DegreeOfUnivariateLaurentPolynomial);
HasDegreeOfUnivariateLaurentPolynomial :=
    Tester(DegreeOfUnivariateLaurentPolynomial);


#############################################################################
##
#A  DenominatorOfRationalFunction( <rat-fun> )
##
##  The denominator and numerator  of rational functions are always  reduced.
##  Note that the default representation *does not*  reduce, so one has to do
##  some work in this case.
##
DenominatorOfRationalFunction := NewAttribute(
    "DenominatorOfRationalFunction",
    IsRationalFunction );


#############################################################################
##
#A  IndeterminateNumberOfUnivariateLaurentPolynomial( <uni-laurent> )
##
IndeterminateNumberOfUnivariateLaurentPolynomial := NewAttribute(
    "IndeterminateNumberOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );

SetIndeterminateNumberOfUnivariateLaurentPolynomial :=
    Setter(IndeterminateNumberOfUnivariateLaurentPolynomial);
HasIndeterminateNumberOfUnivariateLaurentPolynomial :=
    Tester(IndeterminateNumberOfUnivariateLaurentPolynomial);


#############################################################################
##
#A  IndeterminateOfUnivariateLaurentPolynomial( <uni-laurent> )
##
IndeterminateOfUnivariateLaurentPolynomial := NewAttribute(
    "IndeterminateOfUnivariateLaurentPolynomial",
    IsRationalFunction and IsUnivariateLaurentPolynomial );

SetIndeterminateOfUnivariateLaurentPolynomial :=
    Setter(IndeterminateOfUnivariateLaurentPolynomial);
HasIndeterminateOfUnivariateLaurentPolynomial :=
    Tester(IndeterminateOfUnivariateLaurentPolynomial);


#############################################################################
##
#A  NumeratorOfRationalFunction( <rat-fun> )
##
##  The denominator and numerator  of rational functions are always  reduced.
##  Note that the default representation *does not*  reduce, so one has to do
##  some work in this case.
##
NumeratorOfRationalFunction := NewAttribute(
    "NumeratorOfRationalFunction",
    IsRationalFunction );


#############################################################################
##

#O  PolynomialCoefficientsOfLaurentPolynomial( <pol>, <ind> )
##
##  'PolynomialCoefficientsOfLaurentPolynomial'     returns     a  pair,  the
##  coefficient list (which are polynomial    not containing <ind>) and   the
##  valuation, describing the laurent polynomial viewed as laurent polynomial
##  in <ind>.
##
PolynomialCoefficientsOfLaurentPolynomial := NewOperation(
    "PolynomialCoefficientsOfLaurentPolynomial",
    [ IsRationalFunction and IsLaurentPolynomial,
      IsRationalFunction and IsLaurentPolynomial ] );


#############################################################################
##
#O  PolynomialCoefficientsOfPolynomial( <pol>, <ind> )
##
##  'PolynomialCoefficientsOfPolynomial' returns the coefficient list  (which
##  are polynomial not containing  <ind>) describing the polynomial viewed as
##  polynomial in <ind>
##
PolynomialCoefficientsOfPolynomial := NewOperation(
    "PolynomialCoefficientsOfPolynomial",
    [ IsRationalFunction and IsPolynomial,
      IsRationalFunction and IsPolynomial ] );


#############################################################################
##

#O  UnivariateLaurentPolynomialByCoefficients( <fam>, <cofs>, <val>, <ind> )
##
UnivariateLaurentPolynomialByCoefficients := NewOperation(
    "UnivariateLaurentPolynomialByCoefficients",
    [ IsFamily, IsList, IsInt, IsInt ] );
#T 1997/01/16 fceller was old 'NewConstructor'



#############################################################################
##
#O  UnivariatePolynomialByCoefficients( <fam>, <cofs>, <ind> )
##
UnivariatePolynomialByCoefficients := NewOperation(
    "UnivariatePolynomialByCoefficients",
    [ IsFamily, IsList, IsInt ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  UnivariatePolynomial( <ring>, <cofs>, <ind> )
##
UnivariatePolynomial := NewOperation(
    "UnivariatePolynomial",
    [ IsRing, IsRingElementCollection, IsInt and IsPosRat ] );


#############################################################################
##

#O  ZippedSum( <z1>, <z2>, <czero>, <funcs> )
##
##  <funcs> = [ <mless>, <csum> ]
##
ZippedSum := NewOperation(
    "ZippedSum",
    [ IsList, IsList, IsObject, IsList ] );


#############################################################################
##
#O  ZippedProduct( <z1>, <z2>, <czero>, <funcs> )
##
##  <funcs> = [ <mprod>, <mless>, <csum>, <cprod> ]
##
ZippedProduct := NewOperation(
    "ZippedProduct",
    [ IsList, IsList, IsObject, IsList ] );


#############################################################################
##

#F  IsCoeffsElms( <coeff>, <elm> )
##
IsCoeffsElms := function( F1, F2 )
    return HasCoefficientsFamily(F2)
       and IsIdentical( F1, CoefficientsFamily(F2) );
end;


#############################################################################
##
#F  IsElmsCoeffs( <elm>, <coeff> )
##
IsElmsCoeffs := function( F1, F2 )
    return HasCoefficientsFamily(F1)
       and IsIdentical( CoefficientsFamily(F1), F2 );
end;


# basic polynomial reduction stuff

MonomialOrderPlex := NewOperationArgs("MonomialOrderPlex");

MonomialOrderTdeg := NewOperationArgs("MonomialOrderTdeg");

LeadingMonomialPosExtRep := NewOperationArgs("LeadingMonomialPosExtRep");

PolynomialReduction := NewOperationArgs("PolynomialReduction");


#############################################################################
##
#E  ratfun.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
