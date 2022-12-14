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
##  This file contains the declarations for monomial orderings and Groebner
##  bases.

#############################################################################
##
#P  IsPolynomialRingIdeal(<I>)
##
##  <ManSection>
##  <Prop Name="IsPolynomialRingIdeal" Arg='I'/>
##
##  <Description>
##  A polynomial ring ideal is a (two sided) ideal in a (commutative)
##  polynomial ring.
##  </Description>
##  </ManSection>
##
DeclareSynonym("IsPolynomialRingIdeal",
  IsRing and IsRationalFunctionCollection and HasLeftActingRingOfIdeal
  and HasRightActingRingOfIdeal);

#############################################################################
##
#V  InfoGroebner
##
##  <#GAPDoc Label="InfoGroebner">
##  <ManSection>
##  <InfoClass Name="InfoGroebner"/>
##
##  <Description>
##  This info class gives information about Groebner basis calculations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoGroebner");

#############################################################################
##
#C  IsMonomialOrdering(<obj>)
##
##  <#GAPDoc Label="IsMonomialOrdering">
##  <ManSection>
##  <Filt Name="IsMonomialOrdering" Arg='obj' Type='Category'/>
##
##  <Description>
##  A monomial ordering is an object representing a monomial ordering.
##  Its  attributes <Ref Attr="MonomialComparisonFunction"/> and
##  <Ref Attr="MonomialExtrepComparisonFun"/> are actual comparison functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsMonomialOrdering",IsObject);

#############################################################################
##
#R  IsMonomialOrderingDefaultRep
##
##  <ManSection>
##  <Filt Name="IsMonomialOrderingDefaultRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsMonomialOrderingDefaultRep",
  IsAttributeStoringRep and IsMonomialOrdering,[]);

BindGlobal("MonomialOrderingsFamily",
  NewFamily("MonomialOrderingsFamily",IsMonomialOrdering,IsMonomialOrdering));

#############################################################################
##
#A  MonomialComparisonFunction(<O>)
##
##  <#GAPDoc Label="MonomialComparisonFunction">
##  <ManSection>
##  <Attr Name="MonomialComparisonFunction" Arg='O'/>
##
##  <Description>
##  If <A>O</A> is an object representing a monomial ordering, this attribute
##  returns a <E>function</E> that can be used to compare or sort monomials (and
##  polynomials which will be compared by their monomials in decreasing
##  order) in this order.
##  <Example><![CDATA[
##  gap> MonomialComparisonFunction(lexord);
##  function( a, b ) ... end
##  gap> l:=[f,Derivative(f,x),Derivative(f,y),Derivative(f,z)];;
##  gap> Sort(l,MonomialComparisonFunction(lexord));l;
##  [ -12*z+4, 21*y^2+3, 10*x+2, 7*y^3+5*x^2-6*z^2+2*x+3*y+4*z ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("MonomialComparisonFunction",IsMonomialOrdering);


#############################################################################
##
#A  MonomialExtrepComparisonFun(<O>)
##
##  <#GAPDoc Label="MonomialExtrepComparisonFun">
##  <ManSection>
##  <Attr Name="MonomialExtrepComparisonFun" Arg='O'/>
##
##  <Description>
##  If <A>O</A> is an object representing a monomial ordering, this attribute
##  returns a <E>function</E> that can be used to compare or sort monomials <E>in
##  their external representation</E> (as lists). This comparison variant is
##  used inside algorithms that manipulate the external representation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("MonomialExtrepComparisonFun",IsObject);

#############################################################################
##
#A  OccuringVariableIndices(<O>)
#A  OccuringVariableIndices(<P>)
##
##  <ManSection>
##  <Attr Name="OccuringVariableIndices" Arg='O'/>
##  <Attr Name="OccuringVariableIndices" Arg='P'/>
##
##  <Description>
##  If <A>O</A> is an object representing a monomial ordering, this attribute
##  returns either a list of variable indices for which this ordering is
##  defined, or <K>true</K> in case it is defined for all variables.
##  <P/>
##  If <A>P</A> is a polynomial, it returns the indices of all variables occurring
##  in it.
##  </Description>
##  </ManSection>
##
DeclareAttribute("OccuringVariableIndices",IsMonomialOrdering);

#############################################################################
##
#F  LeadingMonomialOfPolynomial(<pol>,<ord>)
##
##  <#GAPDoc Label="LeadingMonomialOfPolynomial">
##  <ManSection>
##  <Oper Name="LeadingMonomialOfPolynomial" Arg='pol,ord'/>
##
##  <Description>
##  returns the leading monomial (with respect to the ordering <A>ord</A>)
##  of the polynomial <A>pol</A>.
##  <Example><![CDATA[
##  gap> x:=Indeterminate(Rationals,"x");;
##  gap> y:=Indeterminate(Rationals,"y");;
##  gap> z:=Indeterminate(Rationals,"z");;
##  gap> lexord:=MonomialLexOrdering();grlexord:=MonomialGrlexOrdering();
##  MonomialLexOrdering()
##  MonomialGrlexOrdering()
##  gap> f:=2*x+3*y+4*z+5*x^2-6*z^2+7*y^3;
##  7*y^3+5*x^2-6*z^2+2*x+3*y+4*z
##  gap> LeadingMonomialOfPolynomial(f,lexord);
##  x^2
##  gap> LeadingMonomialOfPolynomial(f,grlexord);
##  y^3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("LeadingMonomialOfPolynomial",
  [IsPolynomialFunction,IsMonomialOrdering]);

#############################################################################
##
#O  LeadingCoefficientOfPolynomial( <pol>,<ord> )
##
##  <#GAPDoc Label="LeadingCoefficientOfPolynomial">
##  <ManSection>
##  <Oper Name="LeadingCoefficientOfPolynomial" Arg='pol,ord'/>
##
##  <Description>
##  returns the leading coefficient (that is the coefficient of the leading
##  monomial, see&nbsp;<Ref Oper="LeadingMonomialOfPolynomial"/>) of the polynomial <A>pol</A>.
##  <Example><![CDATA[
##  gap> LeadingTermOfPolynomial(f,lexord);
##  5*x^2
##  gap> LeadingTermOfPolynomial(f,grlexord);
##  7*y^3
##  gap> LeadingCoefficientOfPolynomial(f,lexord);
##  5
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("LeadingCoefficientOfPolynomial",
  [IsPolynomialFunction,IsMonomialOrdering]);

#############################################################################
##
#F  LeadingTermOfPolynomial(<pol>,<ord>)
##
##  <#GAPDoc Label="LeadingTermOfPolynomial">
##  <ManSection>
##  <Oper Name="LeadingTermOfPolynomial" Arg='pol,ord'/>
##
##  <Description>
##  returns the leading term (with respect to the ordering <A>ord</A>)
##  of the polynomial <A>pol</A>, i.e. the product of leading coefficient and
##  leading monomial.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("LeadingTermOfPolynomial",
  [IsPolynomialFunction,IsMonomialOrdering]);


#############################################################################
##
#F  MonomialLexOrdering( [<vari>] )
##
##  <#GAPDoc Label="MonomialLexOrdering">
##  <ManSection>
##  <Func Name="MonomialLexOrdering" Arg='[vari]'/>
##
##  <Description>
##  This function creates a lexicographic ordering for monomials.
##  Monomials are compared first by the exponents of the largest variable,
##  then the exponents of the second largest variable and so on.
##  <P/>
##  The variables are ordered according to their (internal) index, i.e.,
##  <M>x_1</M> is larger than <M>x_2</M> and so on.
##  If <A>vari</A> is given, and is a list of variables or variable indices,
##  instead this arrangement of variables (in descending order; i.e. the
##  first variable is larger than the second) is
##  used as the underlying order of variables.
##  <Example><![CDATA[
##  gap> l:=List(Tuples([1..3],3),i->x^(i[1]-1)*y^(i[2]-1)*z^(i[3]-1));
##  [ 1, z, z^2, y, y*z, y*z^2, y^2, y^2*z, y^2*z^2, x, x*z, x*z^2, x*y,
##    x*y*z, x*y*z^2, x*y^2, x*y^2*z, x*y^2*z^2, x^2, x^2*z, x^2*z^2,
##    x^2*y, x^2*y*z, x^2*y*z^2, x^2*y^2, x^2*y^2*z, x^2*y^2*z^2 ]
##  gap> Sort(l,MonomialComparisonFunction(MonomialLexOrdering()));l;
##  [ 1, z, z^2, y, y*z, y*z^2, y^2, y^2*z, y^2*z^2, x, x*z, x*z^2, x*y,
##    x*y*z, x*y*z^2, x*y^2, x*y^2*z, x*y^2*z^2, x^2, x^2*z, x^2*z^2,
##    x^2*y, x^2*y*z, x^2*y*z^2, x^2*y^2, x^2*y^2*z, x^2*y^2*z^2 ]
##  gap> Sort(l,MonomialComparisonFunction(MonomialLexOrdering([y,z,x])));l;
##  [ 1, x, x^2, z, x*z, x^2*z, z^2, x*z^2, x^2*z^2, y, x*y, x^2*y, y*z,
##    x*y*z, x^2*y*z, y*z^2, x*y*z^2, x^2*y*z^2, y^2, x*y^2, x^2*y^2,
##    y^2*z, x*y^2*z, x^2*y^2*z, y^2*z^2, x*y^2*z^2, x^2*y^2*z^2 ]
##  gap> Sort(l,MonomialComparisonFunction(MonomialLexOrdering([z,x,y])));l;
##  [ 1, y, y^2, x, x*y, x*y^2, x^2, x^2*y, x^2*y^2, z, y*z, y^2*z, x*z,
##    x*y*z, x*y^2*z, x^2*z, x^2*y*z, x^2*y^2*z, z^2, y*z^2, y^2*z^2,
##    x*z^2, x*y*z^2, x*y^2*z^2, x^2*z^2, x^2*y*z^2, x^2*y^2*z^2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MonomialLexOrdering");

#############################################################################
##
#F  MonomialGrlexOrdering( [<vari>] )
##
##  <#GAPDoc Label="MonomialGrlexOrdering">
##  <ManSection>
##  <Func Name="MonomialGrlexOrdering" Arg='[vari]'/>
##
##  <Description>
##  This function creates a degree/lexicographic ordering.
##  In this ordering monomials are compared first by their total degree,
##  then lexicographically (see <Ref Func="MonomialLexOrdering"/>).
##  <P/>
##  The variables are ordered according to their (internal) index, i.e.,
##  <M>x_1</M> is larger than <M>x_2</M> and so on.
##  If <A>vari</A> is given, and is a list of variables or variable indices,
##  instead this arrangement of variables (in descending order; i.e. the
##  first variable is larger than the second) is
##  used as the underlying order of variables.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MonomialGrlexOrdering");

#############################################################################
##
#F  MonomialGrevlexOrdering( [<vari>] )
##
##  <#GAPDoc Label="MonomialGrevlexOrdering">
##  <ManSection>
##  <Func Name="MonomialGrevlexOrdering" Arg='[vari]'/>
##
##  <Description>
##  This function creates a <Q>grevlex</Q> ordering.
##  In this ordering monomials are compared first by total degree and then
##  backwards lexicographically.
##  (This is different than <Q>grlex</Q> ordering with variables reversed.)
##  <P/>
##  The variables are ordered according to their (internal) index, i.e.,
##  <M>x_1</M> is larger than <M>x_2</M> and so on.
##  If <A>vari</A> is given, and is a list of variables or variable indices,
##  instead this arrangement of variables (in descending order; i.e. the
##  first variable is larger than the second) is
##  used as the underlying order of variables.
##  <Example><![CDATA[
##  gap> Sort(l,MonomialComparisonFunction(MonomialGrlexOrdering()));l;
##  [ 1, z, y, x, z^2, y*z, y^2, x*z, x*y, x^2, y*z^2, y^2*z, x*z^2,
##    x*y*z, x*y^2, x^2*z, x^2*y, y^2*z^2, x*y*z^2, x*y^2*z, x^2*z^2,
##    x^2*y*z, x^2*y^2, x*y^2*z^2, x^2*y*z^2, x^2*y^2*z, x^2*y^2*z^2 ]
##  gap> Sort(l,MonomialComparisonFunction(MonomialGrevlexOrdering()));l;
##  [ 1, z, y, x, z^2, y*z, x*z, y^2, x*y, x^2, y*z^2, x*z^2, y^2*z,
##    x*y*z, x^2*z, x*y^2, x^2*y, y^2*z^2, x*y*z^2, x^2*z^2, x*y^2*z,
##    x^2*y*z, x^2*y^2, x*y^2*z^2, x^2*y*z^2, x^2*y^2*z, x^2*y^2*z^2 ]
##  gap> Sort(l,MonomialComparisonFunction(MonomialGrlexOrdering([z,y,x])));l;
##  [ 1, x, y, z, x^2, x*y, y^2, x*z, y*z, z^2, x^2*y, x*y^2, x^2*z,
##    x*y*z, y^2*z, x*z^2, y*z^2, x^2*y^2, x^2*y*z, x*y^2*z, x^2*z^2,
##    x*y*z^2, y^2*z^2, x^2*y^2*z, x^2*y*z^2, x*y^2*z^2, x^2*y^2*z^2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("MonomialGrevlexOrdering");

#############################################################################
##
#F  EliminationOrdering( <elim>[, <rest>] )
##
##  <#GAPDoc Label="EliminationOrdering">
##  <ManSection>
##  <Func Name="EliminationOrdering" Arg='elim[, rest]'/>
##
##  <Description>
##  This function creates an elimination ordering for eliminating the
##  variables in <A>elim</A>.
##  Two monomials are compared first by the exponent vectors for the
##  variables listed in <A>elim</A> (a lexicographic comparison with respect
##  to the ordering indicated in <A>elim</A>).
##  If these submonomial are equal, the submonomials given by the other
##  variables are compared by a graded lexicographic ordering
##  (with respect to the variable order given in <A>rest</A>,
##  if called with two parameters).
##  <P/>
##  Both <A>elim</A> and <A>rest</A> may be a list of variables or a list of
##  variable indices.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EliminationOrdering");

#############################################################################
##
#F  PolynomialDivisionAlgorithm(<poly>,<gens>,<order>)
##
##  <#GAPDoc Label="PolynomialDivisionAlgorithm">
##  <ManSection>
##  <Func Name="PolynomialDivisionAlgorithm" Arg='poly,gens,order'/>
##
##  <Description>
##  This function implements the division algorithm for multivariate
##  polynomials as given in
##  <Cite Key="coxlittleoshea" Where="Theorem 3 in Chapter 2"/>.
##  (It might be slower than <Ref Func="PolynomialReduction"/> but the
##  remainders are guaranteed to agree with the textbook.)
##  <P/>
##  The operation returns a list of length two, the first entry is the
##  remainder after the reduction. The second entry is a list of quotients
##  corresponding to <A>gens</A>.
##  <Example><![CDATA[
##  gap> bas:=[x^3*y*z,x*y^2*z,z*y*z^3+x];;
##  gap> pol:=x^7*z*bas[1]+y^5*bas[3]+x*z;;
##  gap> PolynomialReduction(pol,bas,MonomialLexOrdering());
##  [ -y*z^5, [ x^7*z, 0, y^5+z ] ]
##  gap> PolynomialReducedRemainder(pol,bas,MonomialLexOrdering());
##  -y*z^5
##  gap> PolynomialDivisionAlgorithm(pol,bas,MonomialLexOrdering());
##  [ -y*z^5, [ x^7*z, 0, y^5+z ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PolynomialDivisionAlgorithm");

#############################################################################
##
#F  PolynomialReduction(<poly>,<gens>,<order>)
##
##  <#GAPDoc Label="PolynomialReduction">
##  <ManSection>
##  <Func Name="PolynomialReduction" Arg='poly,gens,order'/>
##
##  <Description>
##  reduces the polynomial <A>poly</A> by the ideal generated by the polynomials
##  in <A>gens</A>, using the order <A>order</A> of monomials.  Unless <A>gens</A> is a
##  Gröbner basis the result is not guaranteed to be unique.
##  <P/>
##  The operation returns a list of length two, the first entry is the
##  remainder after the reduction. The second entry is a list of quotients
##  corresponding to <A>gens</A>.
##  <P/>
##  Note that the strategy used by <Ref Func="PolynomialReduction"/> differs from the
##  standard textbook reduction algorithm, which is provided by
##  <Ref Func="PolynomialDivisionAlgorithm"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PolynomialReduction");

#############################################################################
##
#F  PolynomialReducedRemainder(<poly>,<gens>,<order>)
##
##  <#GAPDoc Label="PolynomialReducedRemainder">
##  <ManSection>
##  <Func Name="PolynomialReducedRemainder" Arg='poly,gens,order'/>
##
##  <Description>
##  this operation does the same way as
##  <Ref Func="PolynomialReduction"/> but does not keep track of the actual quotients
##  and returns only the remainder (it is therefore slightly faster).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PolynomialReducedRemainder");


#############################################################################
##
#O  GroebnerBasis(<L>,<O>)
#O  GroebnerBasis(<I>,<O>)
#O  GroebnerBasisNC(<L>,<O>)
##
##  <#GAPDoc Label="GroebnerBasis">
##  <ManSection>
##  <Heading>GroebnerBasis</Heading>
##  <Oper Name="GroebnerBasis" Arg='L, O'
##   Label="for a list and a monomial ordering"/>
##  <Oper Name="GroebnerBasis" Arg='I, O'
##   Label="for an ideal and a monomial ordering"/>
##  <Func Name="GroebnerBasisNC" Arg='L, O'/>
##
##  <Description>
##  Let <A>O</A> be a monomial ordering and <A>L</A> be a list of polynomials
##  that generate an ideal <A>I</A>.
##  This operation returns a Groebner basis of <A>I</A> with respect to the
##  ordering <A>O</A>.
##  <P/>
##  <Ref Func="GroebnerBasisNC"/> works like
##  <Ref Oper="GroebnerBasis" Label="for a list and a monomial ordering"/>
##  with the only distinction that the first argument has to be a list of
##  polynomials and that no test is performed to check whether the ordering
##  is defined for all occurring variables.
##  <P/>
##  Note that &GAP; at the moment only includes
##  a naïve implementation of Buchberger's algorithm (which is mainly
##  intended as a teaching tool).
##  It might not be sufficient for serious problems.
##  <Example><![CDATA[
##  gap> l:=[x^2+y^2+z^2-1,x^2+z^2-y,x-y];;
##  gap> GroebnerBasis(l,MonomialLexOrdering());
##  [ x^2+y^2+z^2-1, x^2+z^2-y, x-y, -y^2-y+1, -z^2+2*y-1,
##    1/2*z^4+2*z^2-1/2 ]
##  gap> GroebnerBasis(l,MonomialLexOrdering([z,x,y]));
##  [ x^2+y^2+z^2-1, x^2+z^2-y, x-y, -y^2-y+1 ]
##  gap> GroebnerBasis(l,MonomialGrlexOrdering());
##  [ x^2+y^2+z^2-1, x^2+z^2-y, x-y, -y^2-y+1, -z^2+2*y-1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("GroebnerBasis",
  [IsHomogeneousList and IsRationalFunctionCollection,IsMonomialOrdering]);
DeclareOperation("GroebnerBasis",[IsPolynomialRingIdeal,IsMonomialOrdering]);
DeclareGlobalFunction("GroebnerBasisNC");

DeclareSynonym("GrobnerBasis",GroebnerBasis);

#############################################################################
##
#O  ReducedGroebnerBasis( <L>, <O> )
#O  ReducedGroebnerBasis( <I>, <O> )
##
##  <#GAPDoc Label="ReducedGroebnerBasis">
##  <ManSection>
##  <Heading>ReducedGroebnerBasis</Heading>
##  <Oper Name="ReducedGroebnerBasis" Arg='L, O'
##   Label="for a list and a monomial ordering"/>
##  <Oper Name="ReducedGroebnerBasis" Arg='I, O'
##   Label="for an ideal and a monomial ordering"/>
##
##  <Description>
##  a Groebner basis <M>B</M>
##  (see&nbsp;<Ref Oper="GroebnerBasis" Label="for a list and a monomial ordering"/>)
##  is <E>reduced</E> if no monomial in a polynomial in <A>B</A> is divisible
##  by the leading monomial of another polynomial in <M>B</M>.
##  This operation computes a Groebner basis with respect
##  to the monomial ordering <A>O</A> and then reduces it.
##  <P/>
##  <Example><![CDATA[
##  gap> ReducedGroebnerBasis(l,MonomialGrlexOrdering());
##  [ x-y, z^2-2*y+1, y^2+y-1 ]
##  gap> ReducedGroebnerBasis(l,MonomialLexOrdering());
##  [ z^4+4*z^2-1, -1/2*z^2+y-1/2, -1/2*z^2+x-1/2 ]
##  gap> ReducedGroebnerBasis(l,MonomialLexOrdering([y,z,x]));
##  [ x^2+x-1, z^2-2*x+1, -x+y ]
##  ]]></Example>
##  <P/>
##  For performance reasons it can be advantageous to define
##  monomial orderings once and then to reuse them:
##  <P/>
##  <Example><![CDATA[
##  gap> ord:=MonomialGrlexOrdering();;
##  gap> GroebnerBasis(l,ord);
##  [ x^2+y^2+z^2-1, x^2+z^2-y, x-y, -y^2-y+1, -z^2+2*y-1 ]
##  gap> ReducedGroebnerBasis(l,ord);
##  [ x-y, z^2-2*y+1, y^2+y-1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ReducedGroebnerBasis",
  [IsHomogeneousList and IsRationalFunctionCollection,IsMonomialOrdering]);
DeclareOperation("ReducedGroebnerBasis",
  [IsPolynomialRingIdeal,IsMonomialOrdering]);
DeclareSynonym("ReducedGrobnerBasis",ReducedGroebnerBasis);

#############################################################################
##
#A  StoredGroebnerBasis(<I>)
##
##  <#GAPDoc Label="StoredGroebnerBasis">
##  <ManSection>
##  <Attr Name="StoredGroebnerBasis" Arg='I'/>
##
##  <Description>
##  For an ideal <A>I</A> in a polynomial ring, this attribute holds a list
##  <M>[ B, O ]</M> where <M>B</M> is a Groebner basis for the monomial
##  ordering <M>O</M>.
##  this can be used to test membership or canonical coset representatives.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("StoredGroebnerBasis",IsPolynomialRingIdeal);
