#############################################################################
##
#W  ringpoly.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareCategory( "IsPolynomialRing", IsRing );


#############################################################################
##
#C  IsUnivariatePolynomialRing( <pring> )
##
##  is a polynomial ring <pring> with one indeterminate.
DeclareCategory( "IsUnivariatePolynomialRing", IsPolynomialRing );

#############################################################################
##
#C  IsFiniteFieldPolynomialRing( <pring> )
##
##  is a polynomial ring <pring> over a finite field.
DeclareCategory( "IsFiniteFieldPolynomialRing", IsPolynomialRing );


#############################################################################
##
#C  IsRationalsPolynomialRing( <pring> )
##
##  is a polynomial ring <pring> over the rational numbers.
DeclareCategory( "IsRationalsPolynomialRing", IsPolynomialRing );

#############################################################################
##
#A  CoefficientsRing( <pring> )
##
##  returns the ring of coefficients of the polynomial ring <pring>, that is
##  the ring over which <pring> was defined.
DeclareAttribute( "CoefficientsRing", IsPolynomialRing );

#2
##  {\GAP} implements a polynomial ring with countably many indeterminates.
##  These indeterminates can be referred to by positive integers. If only a
##  number <num> of indeterminates is required they default to `[1..<num>]'.
##
##  It is posible to assign names to indeterminates. These names only
##  provide a means for printing the indeterminates in a nice way, but have
##  not necessary any relations to variable names. Indeterminates that have
##  not been assigned a name will be printed as ``{`x_<nr>'}''.
##
##  It is possible to assign
##  the *same* name to *different* indeterminates (though it is probably not
##  a good idea to do so). Asking *twice* for an indeterminate with the name
##  <nam> will produce *two different* indeterminates!
##
##  When asking for indeterminates with certain
##  names, {\GAP} usually will take the first indeterminates that are not
##  yet named, name these accordingly and return them. Thus when asking for
##  named indeterminates, no relation between names and indeterminate
##  numbers can be guaranteed. The attribute
##  `IndeterminateNumberOfUnivariateLaurentPolynomial(<indet>)' will return
##  the number of the indeterminate <indet>.


#############################################################################
##
#O  Indeterminate( <R>,[<nr>] )
#O  Indeterminate( <R>,[<avoid>] )
#O  Indeterminate( <R>,<name>[,<avoid>] )
##
##  returns indeterminate number <nr> over the ring <R>. If <nr> is not
##  given it defaults to 1. If the number is not specified a list <avoid> of
##  indeterminates may be given. The function will return an indeterminate
##  that is guaranteed to be different from all the indeterminates in
##  <avoid>. The third usage returns an indeterminate called <name> (also
##  avoiding the indeterminates in <avoid> if given).
DeclareOperation( "Indeterminate", [IsRing,IsPosInt] );


#############################################################################
##
#O  UnivariatePolynomialRing( <R> [,<nr>] )
#O  UnivariatePolynomialRing( <R> [,<avoid>] )
#O  UnivariatePolynomialRing( <R>,<name> [,<avoid>] )
##
##  returns a univariate polynomial ring in the indeterminate <nr> over the
##  base ring <R>. if <nr> is not given it defaults to 1.  If the number is
##  not specified a list <avoid> of indeterminates may be given. The
##  function will return a ring in an indeterminate that is guaranteed to be
##  different from all the indeterminates in <avoid>. The third usage
##  returns a ring in an indeterminate called <name> (also avoiding the
##  indeterminates in <avoid> if given).
DeclareOperation( "UnivariatePolynomialRing", [IsRing] );

#############################################################################
##
#A  IndeterminatesOfPolynomialRing( <pring> )
##
##  returns a list of the indeterminates of the polynomial ring <pring>
DeclareAttribute( "IndeterminatesOfPolynomialRing", IsPolynomialRing );



#############################################################################
##
#O  PolynomialRing( <ring>, <rank>, [<avoid>] )
#O  PolynomialRing( <ring>, <names>, [<avoid>] )
#O  PolynomialRing( <ring>, <indets> )
##
##  creates a polynomial ring over <ring>. If a positive integer <rank> is
##  given, this creates the polynomial ring in <rank> indeterminates
##  (differing from the indeterminates contained in <avoid> if given). The
##  second usage takes a list <names> of strings and returns a polynomial
##  ring in indeterminates labelled by <names>. In the third use, a list of
##  positive integers <indets> is given. This creates the polynomial ring in
##  the indeterminates labelled by <indets>.
DeclareOperation( "PolynomialRing",
    [ IsRing, IsObject ] );


#############################################################################
##
#O  CharacteristicPolynomial( <ring>, <elm> [,<ind>] )
##
##  returns the characteristic polynomial of <elm> over <ring>,expressed in
##  the indeterminate number <ind>. If <ind> is not given, it defaults to 1.
#T This is incompatible with the definition for field elements:
DeclareOperation( "CharacteristicPolynomial",
    [ IsRing,
      IsMultiplicativeElement and IsAdditiveElement,
      IsPosInt] );


#############################################################################
##
#O  MinimalPolynomial( <ring>, <elm> [,<ind>] )
##
##  returns the minimal polynomial of <elm> over <ring>, expressed in the
##  indeterminate number <ind>. If <ind> is not given, it defaults to 1.
##
DeclareOperation( "MinimalPolynomial",
    [ IsRing, IsMultiplicativeElement and IsAdditiveElement,
    IsPosInt] );


#############################################################################
##
#E  ringpoly.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
