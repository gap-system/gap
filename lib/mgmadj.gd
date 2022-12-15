#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for magmas with zero adjoined.
##

# IsMultiplicativeElementWithZero is defined in arith.gd so that it can be read
# in read1.g, and used in the kernel.

##  <#GAPDoc Label="MultiplicativeZeroOp">
##  <ManSection>
##  <Oper Name="MultiplicativeZeroOp" Arg='elt'/>
##  <Returns>A multiplicative zero element.</Returns>
##  <Description>
##  for an element <A>elt</A> in the category
##  <Ref Filt="IsMultiplicativeElementWithZero"/>,
##  <C>MultiplicativeZeroOp</C>
##  returns the element <M>z</M> in the family <M>F</M> of <A>elt</A>
##  with the property that <M>z * m = z = m * z</M> holds for all
##  <M>m \in F</M>, if such an element can be determined.
##  <P/>
##
##  Families of elements in the category
##  <Ref Filt="IsMultiplicativeElementWithZero"/>
##  often arise from adjoining a new zero to an existing magma.
##  See&nbsp;<Ref Attr="InjectionZeroMagma"/> or
##  <Ref Attr="MagmaWithZeroAdjoined"/> for details.
##  <Example><![CDATA[
##  gap> G:=AlternatingGroup(5);;
##  gap> x:=Representative(MagmaWithZeroAdjoined(G));
##  <group with 0 adjoined elt: ()>
##  gap> MultiplicativeZeroOp(x);
##  <group with 0 adjoined elt: 0>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareOperation( "MultiplicativeZeroOp", [IsMultiplicativeElementWithZero] );

##  <#GAPDoc Label="MultiplicativeZero">
##  <ManSection>
##  <Attr Name="MultiplicativeZero" Arg='M'/>
##  <Oper Name="IsMultiplicativeZero" Arg='M, z'/>
##  <Description>
##  <C>MultiplicativeZero</C> returns the multiplicative zero of the magma
##  <A>M</A>  which is the element
##  <C>z</C> in <A>M</A> such that <C><A>z</A> *  <A>m</A> = <A>m</A> *
##  <A>z</A> = <A>z</A></C> for all <A>m</A> in <A>M</A>.<P/>
##
##  <C>IsMultiplicativeZero</C> returns <K>true</K> if the element <A>z</A> of
##  the magma <A>M</A> equals the multiplicative zero of <A>M</A>.
##  <Example><![CDATA[
##  gap> S:=Semigroup( Transformation( [ 1, 1, 1 ] ),
##  > Transformation( [ 2, 3, 1 ] ) );
##  <transformation semigroup of degree 3 with 2 generators>
##  gap> MultiplicativeZero(S);
##  fail
##  gap> S:=Semigroup( Transformation( [ 1, 1, 1 ] ),
##  > Transformation( [ 1, 3, 2 ] ) );
##  <transformation semigroup of degree 3 with 2 generators>
##  gap> MultiplicativeZero(S);
##  Transformation( [ 1, 1, 1 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareAttribute( "MultiplicativeZero", IsMultiplicativeElementWithZero );
DeclareOperation("IsMultiplicativeZero", [ IsMagma, IsMultiplicativeElement ] );

# the documentation for the functions below is in mgmadj.xml in doc/ref

DeclareRepresentation("IsMagmaWithZeroAdjoinedElementRep",
IsComponentObjectRep and IsMultiplicativeElementWithZero and
IsAttributeStoringRep, []);

DeclareCategory( "IsMagmaWithZeroAdjoined", IsMagma);
DeclareAttribute( "InjectionZeroMagma", IsMagma );
DeclareAttribute("MagmaWithZeroAdjoined", IsMultiplicativeElementWithZero and IsMagmaWithZeroAdjoinedElementRep);
DeclareAttribute("MagmaWithZeroAdjoined", IsMagma);
DeclareAttribute( "UnderlyingInjectionZeroMagma", IsMagmaWithZeroAdjoined);

