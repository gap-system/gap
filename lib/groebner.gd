#############################################################################
##
#W  groebner.gd                   GAP Library               Alexander Hulpke   
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for monomial orderings and Groebner
##  bases.
Revision.groebner_gd :=
    "@(#)$Id$";

#############################################################################
##
#P  IsPolynomialRingIdeal(<I>)
##
##  A polynomial ring ideal is a (two sided) ideal in a (commutative)
##  polynomial ring.
DeclareSynonym("IsPolynomialRingIdeal",
  IsRing and IsRationalFunctionCollection and HasLeftActingRingOfIdeal
  and HasRightActingRingOfIdeal);

#############################################################################
##
#V  InfoGroebner
##
##  This info class gives information about Groebner basis calculations.
DeclareInfoClass("InfoGroebner");

#############################################################################
##
#C  IsMonomialOrdering(<obj>)
##
##  A monomial ordering is an object representing a monomial ordering. Its 
##  attributes `MonomialComparisonFunction' and
##  `MonomialExtrepComparisonFun' are actual comparison functions.
DeclareCategory("IsMonomialOrdering",IsObject);

#############################################################################
##
#R  IsMonomialOrderingDefaultRep
##
DeclareRepresentation("IsMonomialOrderingDefaultRep",
  IsAttributeStoringRep and IsPositionalObjectRep and IsMonomialOrdering,[]);

BindGlobal("MonomialOrderingsFamily",
  NewFamily("MonomialOrderingsFamily",IsMonomialOrdering,IsMonomialOrdering));

#############################################################################
##
#A  MonomialComparisonFunction(<O>)
##
##  If <O> is an object representing a monomial ordering, this attribute
##  returns a *function* that can be used to compare or sort monomials (and
##  polynomials which will be compared by their monomials in decreasing
##  order) in this order.
DeclareAttribute("MonomialComparisonFunction",IsMonomialOrdering);


#############################################################################
##
#A  MonomialExtrepComparisonFun(<O>)
##
##  If <O> is an object representing a monomial ordering, this attribute
##  returns a *function* that can be used to compare or sort monomials *in
##  their external representation* (as lists). This comparison variant is
##  used inside algorithms that manipulate the external representation.
DeclareAttribute("MonomialExtrepComparisonFun",IsObject);

#############################################################################
##
#A  OccuringVariableIndices(<O>)
#A  OccuringVariableIndices(<P>)
##
##  If <O> is an object representing a monomial ordering, this attribute
##  returns either a list of variable indices for which this ordering is
##  defined, or `true' in case it is defined for all variables.
##
##  If <P> is a polynomial, it returns the indices of all variables occuring
##  in it.
DeclareAttribute("OccuringVariableIndices",IsMonomialOrdering);

#############################################################################
##
#F  LeadingMonomialOfPolynomial(<pol>,<ord>)
##
##  returns the leading monomial (with respect to the ordering <ord>)
##  of the polynomial <pol>.
##
DeclareOperation("LeadingMonomialOfPolynomial",
  [IsPolynomialFunction,IsMonomialOrdering]);

#############################################################################
##
#O  LeadingCoefficientOfPolynomial( <pol>,<ord> )
##
##  returns the leading coefficient (that is the coefficient of the leading
##  monomial, see~"LeadingMonomialOfPolynomial") of the polynomial <pol>.
##
DeclareOperation("LeadingCoefficientOfPolynomial",
  [IsPolynomialFunction,IsMonomialOrdering]);

#############################################################################
##
#F  LeadingTermOfPolynomial(<pol>,<ord>)
##
##  returns the leading term (with respect to the ordering <ord>)
##  of the polynomial <pol>, i.e. the product of leading coefficient and
##  leading monomial.
##
DeclareOperation("LeadingTermOfPolynomial",
  [IsPolynomialFunction,IsMonomialOrdering]);


#############################################################################
##
#F  MonomialLexOrdering()
#F  MonomialLexOrdering(<vari>)
##
##  This function creates a lexicographic ordering for monomials. Monomials
##  are compared first by the exponents of the largest variable, then the
##  exponents of the second largest variable and so on.
##
##  The variables are ordered according to their (internal) index, i.e. $x_1$
##  is larger than $x_2$ and so on.
##  If <vari> is given, and is a list of variables or variable indices,
##  instead this arrangement of variables (in descending order; i.e. the
##  first variable is larger than the second) is 
##  used as the underlying order of variables.
DeclareGlobalFunction("MonomialLexOrdering");

#############################################################################
##
#F  MonomialGrlexOrdering()
#F  MonomialGrlexOrdering(<vari>)
##
##  This function creates a degree/lexicographic ordering. In this oredring
##  monomials are compared first by their total degree, then lexicographically
##  (see `MonomialLexOrdering').
##
##  The variables are ordered according to their (internal) index, i.e. $x_1$
##  is larger than $x_2$ and so on.
##  If <vari> is given, and is a list of variables or variable indices,
##  instead this arrangement of variables (in descending order; i.e. the
##  first variable is larger than the second) is 
##  used as the underlying order of variables.
DeclareGlobalFunction("MonomialGrlexOrdering");

#############################################################################
##
#F  MonomialGrevlexOrdering()
#F  MonomialGrevlexOrdering(<vari>)
##
##  This function creates a ``grevlex'' ordering. In this ordering monomials
##  are compared first by total degree and then backwards lexicographically.
##  (This is different than ``grlex'' ordering with variables reversed.) 
##
##  The variables are ordered according to their (internal) index, i.e. $x_1$
##  is larger than $x_2$ and so on.
##  If <vari> is given, and is a list of variables or variable indices,
##  instead this arrangement of variables (in descending order; i.e. the
##  first variable is larger than the second) is 
##  used as the underlying order of variables.
DeclareGlobalFunction("MonomialGrevlexOrdering");

#############################################################################
##
#F  EliminationOrdering(<elim>)
#F  EliminationOrdering(<elim>,<rest>)
##
##  This function creates an elimination ordering for eliminating the
##  variables in <elim>. Two monomials are compared first by the exponent
##  vectors for the variables listed in <elim> (a lexicographic comparison
##  with respect to the ordering indicated in <elim>).
##  If these submonomial are equal, the submonomials given by the other
##  variables are compared by a graded lexicographic ordering (with respect
##  to the variable order given in <rest>, if called with two parameters).
##  
##  Both <elim> and <rest> may be a list of variables of a list of variable
##  indices.
DeclareGlobalFunction("EliminationOrdering");

#############################################################################
##
#F  PolynomialDivisionAlgorithm(<poly>,<gens>,<order>)
##
##  This function implements the division algorithm for multivariate
##  polynomials as given in theorem~3 in chapter~2 of \cite{coxlittleoshea}.
##  (It might be slower than `PolynomialReduction' but the remainders are
##  guaranteed to agree with the textbook.)
##
##  The operation returns a list of length two, the first entry is the
##  remainder after the reduction. The second entry is a list of quotients
##  corresponding to <gens>.
DeclareGlobalFunction("PolynomialDivisionAlgorithm");

#############################################################################
##
#F  PolynomialReduction(<poly>,<gens>,<order>)
##
##  reduces the polynomial <poly> by the ideal generated by the polynomials
##  in <gens>, using the order <order> of monomials.  Unless <gens> is a
##  Gr{\accent127 o}bner basis the result is not guaranteed to be unique.
##
##  The operation returns a list of length two, the first entry is the
##  remainder after the reduction. The second entry is a list of quotients
##  corresponding to <gens>.
##
##  Note that the strategy used by `PolynomialReduction' differs from the 
##  standard textbook reduction algorithm, which is provided by
##  `PolynomialDivisionAlgorithm'.
DeclareGlobalFunction("PolynomialReduction");

#############################################################################
##
#F  PolynomialReducedRemainder(<poly>,<gens>,<order>)
##
##  thios operation does the same way as `PolynomialReduction'
##  (see~"PolynomialReduction") but does not keep track of the actual quotients
##  and returns only the remainder (it is therfore slightly faster).
DeclareGlobalFunction("PolynomialReducedRemainder");


#############################################################################
##
#O  GroebnerBasis(<L>,<O>)
#O  GroebnerBasis(<I>,<O>)
#O  GroebnerBasisNC(<L>,<O>)
##
##  Let <O> be a monomial ordering and <L> be a list of polynomials that
##  generate an ideal <I>. This operation returns a Groebner basis of
##  <I> with respect to the ordering <O>.\\
##
##  `GroebnerBasisNC' works like `GroebnerBasis' with the only distinction
##  that the first argument has to be a list of polynomials and that no test is
##  performed to check whether the ordering is defined for all occuring
##  variables.
##
##  Note that {\GAP} at the moment only includes
##  a na{\"\i}ve implementation of Buchberger's algorithm (which is mainly
##  intended as a teaching tool). It might not be
##  sufficient for serious problems.
DeclareOperation("GroebnerBasis",
  [IsHomogeneousList and IsRationalFunctionCollection,IsMonomialOrdering]);
DeclareOperation("GroebnerBasis",[IsPolynomialRingIdeal,IsMonomialOrdering]);
DeclareGlobalFunction("GroebnerBasisNC");

#############################################################################
##
#O  ReducedGroebnerBasis(<L>,<O>)
#O  ReducedGroebnerBasis(<I>,<O>)
##
##  a Groebner basis <B> (see~"GroebnerBasis") is *reduced* if no monomial
##  in a polynomial in <B> is divisible by the leading monomial of another
##  polynomial in <B>. This operation computes a Groebner basis with respect
##  to <O> and then reduces it.
DeclareOperation("ReducedGroebnerBasis",
  [IsHomogeneousList and IsRationalFunctionCollection,IsMonomialOrdering]);
DeclareOperation("ReducedGroebnerBasis",
  [IsPolynomialRingIdeal,IsMonomialOrdering]);

#############################################################################
##
#A  StoredGroebnerBasis(<I>)
##
##  For an ideal <I> in a polynomial ring, this attribute holds a list
##  [<B>,<O>] where <B> is a Groebner basis for the monomial ordering <O>.
##  this can be used to test membership or canonical coset representatives.
DeclareAttribute("StoredGroebnerBasis",IsPolynomialRingIdeal);

