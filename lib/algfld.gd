#############################################################################
##
#W  algfld.gd                   GAP Library                  Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  </Description>
##  </ManSection>
##
DeclareOperation( "AlgebraicElementsFamily",
  [IsField,IsUnivariatePolynomial]);

#############################################################################
##
#O  AlgebraicExtension(<K>,<f>)
##
##  <#GAPDoc Label="AlgebraicExtension">
##  <ManSection>
##  <Oper Name="AlgebraicExtension" Arg='K,f'/>
##
##  <Description>
##  constructs an extension <A>L</A> of the field <A>K</A> by one root of the
##  irreducible polynomial <A>f</A>, using Kronecker's construction.
##  <A>L</A> is a field whose <Ref Attr="LeftActingDomain"/> value is
##  <A>K</A>.
##  The  polynomial <A>f</A> is the <Ref Attr="DefiningPolynomial"/> value
##  of <A>L</A> and the attribute
##  <Ref Func="RootOfDefiningPolynomial"/>
##  of <A>L</A> holds a root of <A>f</A> in <A>L</A>.
##  <Example><![CDATA[
##  gap> x:=Indeterminate(Rationals,"x");;
##  gap> p:=x^4+3*x^2+1;;
##  gap> e:=AlgebraicExtension(Rationals,p);
##  <algebraic extension over the Rationals of degree 4>
##  gap> IsField(e);
##  true
##  gap> a:=RootOfDefiningPolynomial(e);
##  a
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraicExtension",
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
#F  DefectApproximation( <K> ) . . . . . . . approximation for defect K, i.e.
#F                                      denominators of integer elements in K
##
##  <ManSection>
##  <Func Name="DefectApproximation" Arg='K'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute("DefectApproximation",IsAlgebraicExtension);

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

