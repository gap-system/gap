#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains  the categories, attributes, properties and operations
##  for polynomial rings and function fields.
##


#############################################################################
##
#C  IsPolynomialRing( <pring> )
##
##  <#GAPDoc Label="IsPolynomialRing">
##  <ManSection>
##  <Filt Name="IsPolynomialRing" Arg='pring' Type='Category'/>
##
##  <Description>
##  is the category of polynomial rings
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPolynomialRing", IsRing );

#############################################################################
##
#C  IsFunctionField( <ffield> )
##
##  <#GAPDoc Label="IsFunctionField">
##  <ManSection>
##  <Filt Name="IsFunctionField" Arg='ffield' Type='Category'/>
##
##  <Description>
##  is the category of function fields
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsFunctionField",IsField);

#############################################################################
##
#C  IsUnivariatePolynomialRing( <pring> )
##
##  <#GAPDoc Label="IsUnivariatePolynomialRing">
##  <ManSection>
##  <Filt Name="IsUnivariatePolynomialRing" Arg='pring' Type='Category'/>
##
##  <Description>
##  is the category of polynomial rings with one indeterminate.
##  <Example><![CDATA[
##  gap> r:=UnivariatePolynomialRing(Rationals,"p");
##  Rationals[p]
##  gap> r2:=PolynomialRing(Rationals,["q"]);
##  Rationals[q]
##  gap> IsUnivariatePolynomialRing(r);
##  true
##  gap> IsUnivariatePolynomialRing(r2);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsUnivariatePolynomialRing", IsPolynomialRing );

#############################################################################
##
#C  IsFiniteFieldPolynomialRing( <pring> )
##
##  <#GAPDoc Label="IsFiniteFieldPolynomialRing">
##  <ManSection>
##  <Filt Name="IsFiniteFieldPolynomialRing" Arg='pring' Type='Category'/>
##
##  <Description>
##  is the category of polynomial rings over a finite field
##  (see Chapter&nbsp;<Ref Chap="Finite Fields"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsFiniteFieldPolynomialRing", IsPolynomialRing );


#############################################################################
##
#C  IsAbelianNumberFieldPolynomialRing( <pring> )
##
##  <#GAPDoc Label="IsAbelianNumberFieldPolynomialRing">
##  <ManSection>
##  <Filt Name="IsAbelianNumberFieldPolynomialRing" Arg='pring' Type='Category'/>
##
##  <Description>
##  is the category of polynomial rings over a field of cyclotomics
##  (see the chapters&nbsp;<Ref Chap="Cyclotomic Numbers"/> and <Ref Chap="Abelian Number Fields"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsAbelianNumberFieldPolynomialRing", IsPolynomialRing );

#############################################################################
##
#C  IsAlgebraicExtensionPolynomialRing( <pring> )
##
##  <ManSection>
##  <Filt Name="IsAlgebraicExtensionPolynomialRing" Arg='pring' Type='Category'/>
##
##  <Description>
##  is the category of polynomial rings over a field that has been formed as
##  an <C>AlgebraicExtension</C> of a base field.
##  (see chapter&nbsp;<Ref Chap="Algebraic extensions of fields"/>).
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsAlgebraicExtensionPolynomialRing", IsPolynomialRing );


#############################################################################
##
#C  IsRationalsPolynomialRing( <pring> )
##
##  <#GAPDoc Label="IsRationalsPolynomialRing">
##  <ManSection>
##  <Filt Name="IsRationalsPolynomialRing" Arg='pring' Type='Category'/>
##
##  <Description>
##  is the category of polynomial rings over the rationals
##  (see Chapter&nbsp;<Ref Chap="Rational Numbers"/>).
##  <Example><![CDATA[
##  gap> r := PolynomialRing(Rationals, ["a", "b"] );;
##  gap> IsPolynomialRing(r);
##  true
##  gap> IsFiniteFieldPolynomialRing(r);
##  false
##  gap> IsRationalsPolynomialRing(r);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsRationalsPolynomialRing",
    IsAbelianNumberFieldPolynomialRing );


#############################################################################
##
#A  CoefficientsRing( <pring> )
##
##  <#GAPDoc Label="CoefficientsRing">
##  <ManSection>
##  <Attr Name="CoefficientsRing" Arg='pring'/>
##
##  <Description>
##  returns the ring of coefficients of the polynomial ring <A>pring</A>,
##  that is the ring over which <A>pring</A> was defined.
##  <Example><![CDATA[
##  gap> r:=PolynomialRing(GF(7));
##  GF(7)[x_1]
##  gap> r:=PolynomialRing(GF(7),3);
##  GF(7)[x_1,x_2,x_3]
##  gap> IndeterminatesOfPolynomialRing(r);
##  [ x_1, x_2, x_3 ]
##  gap> r2:=PolynomialRing(GF(7),[5,7,12]);
##  GF(7)[x_5,x_7,x_12]
##  gap> CoefficientsRing(r);
##  GF(7)
##  gap> r:=PolynomialRing(GF(7),3);
##  GF(7)[x_1,x_2,x_3]
##  gap> r2:=PolynomialRing(GF(7),3,IndeterminatesOfPolynomialRing(r));
##  GF(7)[x_4,x_5,x_6]
##  gap> r:=PolynomialRing(GF(7),["x","y","z","z2"]);
##  GF(7)[x,y,z,z2]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CoefficientsRing", IsPolynomialRing );

##  <#GAPDoc Label="[1]{ringpoly}">
##  Internally, indeterminates are created for a <E>family</E> of objects
##  (for example all elements of finite fields in characteristic <M>3</M> are in
##  one family). Thus a variable <Q>x</Q> over the
##  rationals is also an <Q>x</Q> over the integers,
##  while an <Q>x</Q> over <C>GF(3)</C> is different.
##  <P/>
##  Within one family, every indeterminate has a number <A>nr</A> and as
##  long as  no other names have been assigned, this indeterminate will be
##  displayed as
##  <Q><C>x_<A>nr</A></C></Q>. Indeterminate numbers can be arbitrary
##  nonnegative integers.
##  <P/>
##  It is possible to assign names to indeterminates; these names are
##  strings and only provide a means for printing the indeterminates in a
##  nice way. Indeterminates that have not been assigned a name will be
##  printed as <Q><C>x_<A>nr</A></C></Q>.
##  <P/>
##  (Because of this printing convention, the name <C>x_<A>nr</A></C> is interpreted
##  specially to always denote the variable with internal number <A>nr</A>.)
##  <P/>
##  The indeterminate names have not necessarily any relations to variable
##  names: this means that an indeterminate whose name is <Q><C>x</C></Q>
##  cannot be accessed using the variable <C>x</C>, unless <C>x</C> was defined to
##  be that indeterminate.
##  <#/GAPDoc>
##
##  <#GAPDoc Label="[2]{ringpoly}">
##  When asking for indeterminates with certain
##  names, &GAP; usually will take the first (with respect to the internal
##  numbering) indeterminates that are not
##  yet named, name these accordingly and return them. Thus when asking for
##  named indeterminates, no relation between names and indeterminate
##  numbers can be guaranteed. The attribute
##  <C>IndeterminateNumberOfLaurentPolynomial(<A>indet</A>)</C> will return
##  the number of the indeterminate <A>indet</A>.
##  <P/>
##  When asked to create an indeterminate with a name that exists already for
##  the family, &GAP; will by default return this existing indeterminate. If
##  you explicitly want a <E>new</E> indeterminate, distinct from the already
##  existing one with the <E>same</E> name, you can add the <C>new</C> option
##  to the function call. (This is in most cases not a good idea.)
##  <P/>
##  <Log><![CDATA[
##  gap> R:=PolynomialRing(GF(3),["x","y","z"]);
##  GF(3)[x,y,z]
##  gap> List(IndeterminatesOfPolynomialRing(R),
##  >   IndeterminateNumberOfLaurentPolynomial);
##  [ 1, 2, 3 ]
##  gap> R:=PolynomialRing(GF(3),["z"]);
##  GF(3)[z]
##  gap> List(IndeterminatesOfPolynomialRing(R),
##  >   IndeterminateNumberOfLaurentPolynomial);
##  [ 3 ]
##  gap> R:=PolynomialRing(GF(3),["x","y","z"]:new);
##  GF(3)[x,y,z]
##  gap> List(IndeterminatesOfPolynomialRing(R),
##  >   IndeterminateNumberOfLaurentPolynomial);
##  [ 4, 5, 6 ]
##  gap> R:=PolynomialRing(GF(3),["z"]);
##  GF(3)[z]
##  gap> List(IndeterminatesOfPolynomialRing(R),
##  >   IndeterminateNumberOfLaurentPolynomial);
##  [ 3 ]
##  ]]></Log>
##  <#/GAPDoc>
##


#############################################################################
##
#O  Indeterminate( <R>[, <nr>] )
#O  Indeterminate( <R>[, <name>][, <avoid>] )
#O  Indeterminate( <fam>, <nr> )
#O  X( <R>,[<nr>] )
#O  X( <R>,[<avoid>] )
#O  X( <R>,<name>[,<avoid>] )
#O  X( <fam>,<nr> )
##
##  <#GAPDoc Label="Indeterminate">
##  <ManSection>
##  <Heading>Indeterminate</Heading>
##  <Oper Name="Indeterminate" Arg='R[, nr]'
##   Label="for a ring (and a number)"/>
##  <Oper Name="Indeterminate" Arg='R[, name][, avoid]'
##   Label="for a ring (and a name, and an exclusion list)"/>
##  <Oper Name="Indeterminate" Arg='fam, nr'
##   Label="for a family and a number"/>
##  <Oper Name="X" Arg='R[, nr]'
##   Label="for a ring (and a number)"/>
##  <Oper Name="X" Arg='R[, name][, avoid]'
##   Label="for a ring (and a name, and an exclusion list)"/>
##  <Oper Name="X" Arg='fam, nr'
##   Label="for a family and a number"/>
##
##  <Description>
##  returns the indeterminate number <A>nr</A> over the ring <A>R</A>.
##  If <A>nr</A> is not given it defaults to 1.
##  If the number is not specified a list <A>avoid</A> of indeterminates
##  may be given.
##  The function will return an indeterminate that is guaranteed to be
##  different from all the indeterminates in the list <A>avoid</A>.
##  The third usage returns an indeterminate called <A>name</A>
##  (also avoiding the indeterminates in <A>avoid</A> if given).
##  <P/>
##  <Ref Oper="X" Label="for a ring (and a number)"/> is simply a synonym for
##  <Ref Oper="Indeterminate" Label="for a ring (and a number)"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> x:=Indeterminate(GF(3),"x");
##  x
##  gap> y:=X(GF(3),"y");z:=X(GF(3),"X");
##  y
##  X
##  gap> X(GF(3),2);
##  y
##  gap> X(GF(3),"x_3");
##  X
##  gap> X(GF(3),[y,z]);
##  x
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Indeterminate", [IsRing,IsPosInt] );
DeclareSynonym( "X", Indeterminate );


#############################################################################
##
##


#############################################################################
##
#O  UnivariatePolynomialRing( <R>[, <nr>] )
#O  UnivariatePolynomialRing( <R>[, <name>][, <avoid>] )
##
##  <#GAPDoc Label="UnivariatePolynomialRing">
##  <ManSection>
##  <Heading>UnivariatePolynomialRing</Heading>
##  <Oper Name="UnivariatePolynomialRing" Arg='R[, nr]'
##   Label="for a ring (and an indeterminate number)"/>
##  <Oper Name="UnivariatePolynomialRing" Arg='R[, name][, avoid]'
##   Label="for a ring (and a name and an exclusion list)"/>
##
##  <Description>
##  returns a univariate polynomial ring in the indeterminate <A>nr</A> over
##  the base ring <A>R</A>.
##  If <A>nr</A> is not given it defaults to 1.
##  <P/>
##  If the number is not specified a list <A>avoid</A> of indeterminates may
##  be given.
##  Then the function will return a ring in an indeterminate that is
##  guaranteed to be different from all the indeterminates in <A>avoid</A>.
##  <P/>
##  Also a string <A>name</A> can be prescribed as the name of the
##  indeterminate chosen
##  (also avoiding the indeterminates in the list <A>avoid</A> if given).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UnivariatePolynomialRing", [IsRing] );

#############################################################################
##
#A  IndeterminatesOfPolynomialRing( <pring> )
#A  IndeterminatesOfFunctionField( <ffield> )
##
##  <#GAPDoc Label="IndeterminatesOfPolynomialRing">
##  <ManSection>
##  <Attr Name="IndeterminatesOfPolynomialRing" Arg='pring'/>
##  <Attr Name="IndeterminatesOfFunctionField" Arg='ffield'/>
##
##  <Description>
##  returns a list of the indeterminates of the polynomial ring <A>pring</A>,
##  respectively the function field <A>ffield</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndeterminatesOfPolynomialRing", IsPolynomialRing );
DeclareSynonymAttr("IndeterminatesOfFunctionField",
                   IndeterminatesOfPolynomialRing);


#############################################################################
##
#O  PolynomialRing( <R>, <rank>[, <avoid>] )
#O  PolynomialRing( <R>, <names>[, <avoid>] )
#O  PolynomialRing( <R>, <indets> )
#O  PolynomialRing( <R>, <indetnums> )
##
##  <#GAPDoc Label="PolynomialRing">
##  <ManSection>
##  <Heading>PolynomialRing</Heading>
##  <Oper Name="PolynomialRing" Arg='R, rank[, avoid]'
##   Label="for a ring and a rank (and an exclusion list)"/>
##  <Oper Name="PolynomialRing" Arg='R, names[, avoid]'
##   Label="for a ring and a list of names (and an exclusion list)"/>
##  <Oper Name="PolynomialRing" Arg='R, indets'
##   Label="for a ring and a list of indeterminates"/>
##  <Oper Name="PolynomialRing" Arg='R, indetnums'
##   Label="for a ring and a list of indeterminate numbers"/>
##
##  <Description>
##  creates a polynomial ring over the ring <A>R</A>.
##  If a positive integer <A>rank</A> is given,
##  this creates the polynomial ring in <A>rank</A> indeterminates.
##  These indeterminates will have the internal index numbers 1 to
##  <A>rank</A>.
##  The second usage takes a list <A>names</A> of strings and returns a
##  polynomial ring in indeterminates labelled by <A>names</A>.
##  These indeterminates have <Q>new</Q> internal index numbers as if they
##  had been created by calls to
##  <Ref Oper="Indeterminate" Label="for a ring (and a number)"/>.
##  (If the argument <A>avoid</A> is given it contains indeterminates that
##  should be avoided, in this case internal index numbers are incremented
##  to skip these variables.)
##  In the third version, a list of indeterminates <A>indets</A> is given.
##  This creates the polynomial ring in the indeterminates <A>indets</A>.
##  Finally, the fourth version specifies indeterminates by their index
##  numbers.
##  <P/>
##  To get the indeterminates of a polynomial ring use
##  <Ref Attr="IndeterminatesOfPolynomialRing"/>.
##  (Indeterminates created independently with
##  <Ref Oper="Indeterminate" Label="for a ring (and a number)"/>
##  will usually differ, though they might be given the same name and display
##  identically, see Section&nbsp;<Ref Sect="Indeterminates"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PolynomialRing",
    [ IsRing, IsObject ] );


#############################################################################
##
#O  MinimalPolynomial( <R>, <elm>[, <ind>] )
##
##  <#GAPDoc Label="MinimalPolynomial">
##  <ManSection>
##  <Oper Name="MinimalPolynomial" Arg='R, elm[, ind]'/>
##
##  <Description>
##  returns the <E>minimal polynomial</E> of <A>elm</A> over the ring <A>R</A>,
##  expressed in the indeterminate number <A>ind</A>.
##  If <A>ind</A> is not given, it defaults to 1.
##  <P/>
##  The minimal polynomial is the monic polynomial of smallest degree with
##  coefficients in <A>R</A> that has value zero at <A>elm</A>.
##  <Example><![CDATA[
##  gap> MinimalPolynomial(Rationals,[[2,0],[0,2]]);
##  x-2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MinimalPolynomial",
    [ IsRing, IsMultiplicativeElement and IsAdditiveElement, IsPosInt] );

#############################################################################
##
#O  FunctionField( <R>, <rank>[, <avoid>] )
#O  FunctionField( <R>, <names>[, <avoid>] )
#O  FunctionField( <R>, <indets> )
#O  FunctionField( <R>, <indetnums> )
##
##  <#GAPDoc Label="FunctionField">
##  <ManSection>
##  <Heading>FunctionField</Heading>
##  <Oper Name="FunctionField" Arg='R, rank[, avoid]'
##   Label="for an integral ring and a rank (and an exclusion list)"/>
##  <Oper Name="FunctionField" Arg='R, names[, avoid]'
##   Label="for an integral ring and a list of names (and an exclusion list)"/>
##  <Oper Name="FunctionField" Arg='R, indets'
##   Label="for an integral ring and a list of indeterminates"/>
##  <Oper Name="FunctionField" Arg='R, indetnums'
##   Label="for an integral ring and a list of indeterminate numbers"/>
##
##  <Description>
##  creates a function field over the integral ring <A>R</A>.
##  If a positive integer <A>rank</A> is given,
##  this creates the function field in <A>rank</A> indeterminates.
##  These indeterminates will have the internal index numbers 1 to
##  <A>rank</A>.
##  The second usage takes a list <A>names</A> of strings and returns a
##  function field in indeterminates labelled by <A>names</A>.
##  These indeterminates have <Q>new</Q> internal index numbers as if they
##  had been created by calls to
##  <Ref Oper="Indeterminate" Label="for a ring (and a number)"/>.
##  (If the argument <A>avoid</A> is given it contains indeterminates that
##  should be avoided, in this case internal index numbers are incremented
##  to skip these variables.)
##  In the third version, a list of indeterminates <A>indets</A> is given.
##  This creates the function field in the indeterminates <A>indets</A>.
##  Finally, the fourth version specifies indeterminates by their index
##  number.
##  <P/>
##  To get the indeterminates of a function field use
##  <Ref Attr="IndeterminatesOfFunctionField"/>.
##  (Indeterminates created independently with
##  <Ref Oper="Indeterminate" Label="for a ring (and a number)"/>
##  will usually differ, though they might be given the same name and display
##  identically, see Section&nbsp;<Ref Sect="Indeterminates"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("FunctionField",[IsRing,IsObject]);
