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
##  This file contains the categories,  attributes, properties and operations
##  for algebraic extensions of fields and their elements

#############################################################################
##
#C  IsAlgebraicElement(<obj>)
##
##  <#GAPDoc Label="IsAlgebraicElement">
##  <ManSection>
##  <Filt Name="IsAlgebraicElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  is the category for elements of an algebraic extension.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsAlgebraicElement", IsScalar and IsZDFRE and
                    IsAssociativeElement and IsAdditivelyCommutativeElement
                    and IsCommutativeElement);
DeclareCategoryCollections( "IsAlgebraicElement");
DeclareCategoryCollections( "IsAlgebraicElementCollection");
DeclareCategoryCollections( "IsAlgebraicElementCollColl");

#############################################################################
##
#C  IsAlgebraicElementFamily     Category for Families of Algebraic Elements
##
##  <ManSection>
##  <Filt Name="IsAlgebraicElementFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryFamily( "IsAlgebraicElement" );

#############################################################################
##
#C  IsAlgebraicExtension(<obj>)
##
##  <#GAPDoc Label="IsAlgebraicExtension">
##  <ManSection>
##  <Filt Name="IsAlgebraicExtension" Arg='obj' Type='Category'/>
##
##  <Description>
##  is the category of algebraic extensions of fields.
##  <Example><![CDATA[
##  gap> IsAlgebraicExtension(e);
##  true
##  gap> IsAlgebraicExtension(Rationals);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsAlgebraicExtension", IsField );


#############################################################################
##
#A  AlgebraicElementsFamilies    List of AlgElm. families to one poly over
##
##  <ManSection>
##  <Attr Name="AlgebraicElementsFamilies" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AlgebraicElementsFamilies",
  IsUnivariatePolynomial, "mutable" );

#############################################################################
##
#O  AlgebraicElementsFamily   Create Family of alg elms
##
##  <ManSection>
##  <Oper Name="AlgebraicElementsFamily" Arg='obj'/>
##
##  <Description>
##  Arguments: base field, polynomial, check
##  If check is true, then the irreducibility of the polynomial in
##  polynomial ring over base field is checked.
##  </Description>
##  </ManSection>
##
DeclareOperation( "AlgebraicElementsFamily",
  [IsField,IsUnivariatePolynomial,IsBool]);

#############################################################################
##
#O  AlgebraicExtension(<K>,<f>)
##
##  <#GAPDoc Label="AlgebraicExtension">
##  <ManSection>
##  <Oper Name="AlgebraicExtension" Arg='K,f[,nam]'/>
##  <Oper Name="AlgebraicExtensionNC" Arg='K,f[,nam]'/>
##
##  <Description>
##  constructs an extension <A>L</A> of the field <A>K</A> by one root of the
##  irreducible polynomial <A>f</A>, using Kronecker's construction.
##  <A>L</A> is a field whose <Ref Attr="LeftActingDomain"/> value is
##  <A>K</A>.
##  The  polynomial <A>f</A> is the <Ref Attr="DefiningPolynomial"/> value
##  of <A>L</A> and the attribute
##  <Ref Attr="RootOfDefiningPolynomial"/>
##  of <A>L</A> holds a root of <A>f</A> in <A>L</A>.
##  By default this root is printed as <C>a</C>, this string can be
##  overwritten with the optional argument <A>nam</A>. <P/>
##
##  The first version of the command checks that the polynomial <A>f</A>
##  is an irreducible polynomial over <A>K</A>. This check is skipped with
##  the <C>NC</C> variant.
##  <Example><![CDATA[
##  gap> x:=Indeterminate(Rationals,"x");;
##  gap> p:=x^4+3*x^2+1;;
##  gap> e:=AlgebraicExtension(Rationals,p);
##  <algebraic extension over the Rationals of degree 4>
##  gap> IsField(e);
##  true
##  gap> a:=RootOfDefiningPolynomial(e);
##  a
##  gap> l := AlgebraicExtensionNC(Rationals, x^24+3*x^2+1, "alpha");;
##  gap> RootOfDefiningPolynomial(l)^50;
##  9*alpha^6+6*alpha^4+alpha^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraicExtension",
  [IsField,IsUnivariatePolynomial]);
DeclareOperation( "AlgebraicExtensionNC",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#F  MaxNumeratorCoeffAlgElm(<a>)
##
##  <ManSection>
##  <Func Name="MaxNumeratorCoeffAlgElm" Arg='a'/>
##
##  <Description>
##  maximal (absolute value, in numerator)
##  coefficient in the representation of algebraic elm. <A>a</A>
##  </Description>
##  </ManSection>
##
DeclareOperation("MaxNumeratorCoeffAlgElm",[IsScalar]);

#############################################################################
##
#F  AlgExtEmbeddedPol(<ext>,<pol>)
##
##  <ManSection>
##  <Func Name="AlgExtEmbeddedPol" Arg='ext,pol'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("AlgExtEmbeddedPol");

DeclareGlobalFunction("AlgExtSquareHensel");

#############################################################################
##
#F  IdealDecompositionsOfPolynomial( <f> [:"onlyone"] )  finds ideal decompositions of rational f
##
##  <#GAPDoc Label="IdealDecompositionsOfPolynomial">
##  <ManSection>
##  <Func Name="IdealDecompositionsOfPolynomial" Arg='pol'/>
##
##  <Description>
##  Let <M>f</M> be a univariate, rational, irreducible, polynomial. A
##  pair <M>g</M>,<M>h</M> of polynomials of degree strictly
##  smaller than that of <M>f</M>, such that <M>f(x)|g(h(x))</M> is
##  called an ideal decomposition. In the context of field
##  extensions, if <M>\alpha</M> is a root of <M>f</M> in a suitable extension
##  and <M>Q</M> the field of rational numbers. Such decompositions correspond
##  to (proper) subfields <M>Q &lt; Q(\beta) &lt; Q(\alpha)</M>,
##  where <M>g</M> is the minimal polynomial of <M>\beta</M>.
##  This function determines such decompositions up to equality of the subfields
##  <M>Q(\beta)</M>, thus determining subfields of a given algebraic extension.
##  It returns a list of pairs <M>[g,h]</M> (and an empty list if no such
##  decomposition exists). If the option <A>onlyone</A> is given it returns at
##  most one such decomposition (and performs faster).
##  <Example><![CDATA[
##  gap> x:=X(Rationals,"x");;pol:=x^8-24*x^6+144*x^4-288*x^2+144;;
##  gap> l:=IdealDecompositionsOfPolynomial(pol);
##  [ [ x^2+72*x+144, x^6-20*x^4+60*x^2-36 ],
##    [ x^2-48*x+144, x^6-21*x^4+84*x^2-48 ],
##    [ x^2+288*x+17280, x^6-24*x^4+132*x^2-288 ],
##    [ x^4-24*x^3+144*x^2-288*x+144, x^2 ] ]
##  gap> List(l,x->Value(x[1],x[2])/pol);
##  [ x^4-16*x^2-8, x^4-18*x^2+33, x^4-24*x^2+120, 1 ]
##  gap> IdealDecompositionsOfPolynomial(pol:onlyone);
##  [ [ x^2+72*x+144, x^6-20*x^4+60*x^2-36 ] ]
##  ]]></Example>
##  In this example the given polynomial is regular with Galois group
##  <M>Q_8</M>, as expected we get four proper subfields.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IdealDecompositionsOfPolynomial");
DeclareSynonym("DecomPoly",IdealDecompositionsOfPolynomial);
