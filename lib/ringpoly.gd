#############################################################################
##
#W  ringpoly.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains  the categories, attributes, properties and operations
##  for polynomial rings.
##
Revision.ringpoly_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsPolynomialRing( <pring> )
##
##  the category of *full* polynomial rings
##
IsPolynomialRing := NewCategory(
    "IsPolynomialRing",
    IsRing );


#############################################################################
##
#C  IsUnivariatePolynomialRing( <pring> )
##
IsUnivariatePolynomialRing := NewCategory(
    "IsUnivariatePolynomialRing",
    IsPolynomialRing );

#############################################################################
##
#C  IsFiniteFieldPolynomialRing( <pring> )
##
IsFiniteFieldPolynomialRing := NewCategory(
    "IsFiniteFieldPolynomialRing",
    IsPolynomialRing );


#############################################################################
##
#C  IsRationalsPolynomialRing( <pring> )
##
IsRationalsPolynomialRing := NewCategory(
    "IsRationalsPolynomialRing",
    IsPolynomialRing );


#############################################################################
##
#A  UnivariatePolynomialRing( <ring> )
##
UnivariatePolynomialRing := NewAttribute(
    "UnivariatePolynomialRing",
    IsRing );

SetUnivariatePolynomialRing := Setter( UnivariatePolynomialRing );
HasUnivariatePolynomialRing := Tester( UnivariatePolynomialRing );


#############################################################################
##

#A  CoefficientsRing( <pring> )
##
CoefficientsRing := NewAttribute(
    "CoefficientsRing",
    IsPolynomialRing );

SetCoefficientsRing := Setter(CoefficientsRing);
HasCoefficientsRing := Tester(CoefficientsRing);


#############################################################################
##
#A  Indeterminate( <R> )
##
Indeterminate := NewAttribute(
    "Indeterminate",
    IsRing );

SetIndeterminate := Setter(Indeterminate);
HasIndeterminate := Tester(Indeterminate);


#############################################################################
##
#A  IndeterminatesOfPolynomialRing( <pring> )
##
IndeterminatesOfPolynomialRing := NewAttribute(
    "IndeterminatesOfPolynomialRing",
    IsPolynomialRing );

SetIndeterminatesOfPolynomialRing := Setter(IndeterminatesOfPolynomialRing);
HasIndeterminatesOfPolynomialRing := Tester(IndeterminatesOfPolynomialRing);


#############################################################################
##
#O  PolynomialRing( <ring>, <rank> )
##
PolynomialRing := NewOperation(
    "PolynomialRing",
    [ IsRing, IsObject ] );


#############################################################################
##

#O  CharacteristicPolynomial( <ring>, <elm> )
##
##  returns the characteristic polynomial of <elm> over the <ring>
##
CharacteristicPolynomial := NewOperation(
    "CharacteristicPolynomial",
    [ IsRing,
      IsMultiplicativeElement and IsAdditiveElement ] );


#############################################################################
##
#O  MinimalPolynomial( <ring>, <elm> )
##
##  returns the minimal polynomial of <elm> over the <ring>
##
MinimalPolynomial := NewOperation(
    "MinimalPolynomial",
    [ IsRing,
      IsMultiplicativeElement and IsAdditiveElement ] );


#############################################################################
##

#E  ringpoly.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
