#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the definition of the family of Lie elements of a
##  family of ring elements.


#############################################################################
##
##  <#GAPDoc Label="[1]{liefam}">
##  Let <C>x</C> be a ring element, then <C>LieObject(x)</C>
##  (see&nbsp;<Ref Attr="LieObject"/>) wraps <C>x</C> up into an
##  object that contains the same data (namely <C>x</C>). The multiplication
##  <C>*</C> for Lie objects is formed by taking the commutator. More exactly,
##  if <C>l1</C> and <C>l2</C> are the Lie objects corresponding to
##  the ring elements <C>r1</C> and <C>r2</C>, then <C>l1 * l2</C>
##  is equal to the Lie object corresponding to <C>r1 * r2 - r2 * r1</C>.
##  Two rules for Lie objects are worth noting:
##  <P/>
##  <List>
##  <Item>
##    An element is <E>not</E> equal to its Lie element.
##  </Item>
##  <Item>
##    If we take the Lie object of an ordinary (associative) matrix
##    then this is again a matrix;
##    it is therefore a collection (of its rows) and a list.
##    But it is <E>not</E> a collection of collections of its entries,
##    and its family is <E>not</E> a collections family.
##  </Item>
##  </List>
##  <P/>
##  Given a family <C>F</C> of ring elements, we can form its Lie family
##  <C>L</C>. The elements of <C>F</C> and <C>L</C> are in bijection, only
##  the multiplications via <C>*</C> differ for both families.
##  More exactly, if <C>l1</C> and <C>l2</C> are the Lie elements
##  corresponding to the elements <C>f1</C> and <C>f2</C> in <C>F</C>,
##  we have <C>l1 * l2</C> equal to the Lie element corresponding to
##  <C>f1 * f2 - f2 * f1</C>.
##  Furthermore, the product of Lie elements <C>l1</C>, <C>l2</C> and
##  <C>l3</C> is left-normed, that is <C>l1*l2*l3</C> is equal to
##  <C>(l1*l2)*l3</C>.
##  <P/>
##  The main reason to distinguish elements and Lie elements on the family
##  level is that this helps to avoid forming domains that contain
##  elements of both types.
##  For example, if we could form vector spaces of matrices then at first
##  glance it would be no problem to have both ordinary and Lie matrices
##  in it, but as soon as we find out that the space is in fact an algebra
##  (e.g., because its dimension is that of the full matrix algebra),
##  we would run into strange problems.
##  <P/>
##  Note that the family situation with Lie families may be not familiar.
##  <P/>
##  <List>
##  <Item>
##    We have to be careful when installing methods for certain types
##    of domains that may involve Lie elements.
##    For example, the zero element of a matrix space is either an ordinary
##    matrix or its Lie element, depending on the space.
##    So either the method must be aware of both cases, or the method
##    selection must distinguish the two cases.
##    In the latter situation, only one method may be applicable to each
##    case; this means that it is not sufficient to treat the Lie case
##    with the additional requirement <C>IsLieObjectCollection</C> but that
##    we must explicitly require non-Lie elements for the non-Lie case.
##  </Item>
##  <Item>
##    Being a full matrix space is a property that may hold for a space
##    of ordinary matrices or a space of Lie matrices.
##    So methods for full matrix spaces must also be aware of Lie matrices.
##  </Item>
##  </List>
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsLieObject( <obj> )
#C  IsLieObjectCollection( <obj> )
##
##  <#GAPDoc Label="IsLieObject">
##  <ManSection>
##  <Filt Name="IsLieObject" Arg='obj' Type='Category'/>
##  <Filt Name="IsLieObjectCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsRestrictedLieObject" Arg='obj' Type='Category'/>
##  <Filt Name="IsRestrictedLieObjectCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  An object lies in <Ref Filt="IsLieObject"/> if and only if
##  it lies in a family constructed by <Ref Attr="LieFamily"/>.
##  <Example><![CDATA[
##  gap> m:= [ [ 1, 0 ], [ 0, 1 ] ];;
##  gap> lo:= LieObject( m );
##  LieObject( [ [ 1, 0 ], [ 0, 1 ] ] )
##  gap> IsLieObject( m );
##  false
##  gap> IsLieObject( lo );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsLieObject",
        IsRingElement
    and IsZeroSquaredElement
    and IsJacobianElement );

DeclareCategoryCollections( "IsLieObject" );

DeclareSynonym( "IsRestrictedLieObject",
        IsLieObject and IsRestrictedJacobianElement);

DeclareCategoryCollections( "IsRestrictedLieObject" );

#############################################################################
##
#A  LieFamily( <Fam> )
##
##  <#GAPDoc Label="LieFamily">
##  <ManSection>
##  <Attr Name="LieFamily" Arg='Fam'/>
##
##  <Description>
##  is a family <C>F</C> in bijection with the family <A>Fam</A>,
##  but with the Lie bracket as infix multiplication.
##  That is, for <C>x</C>, <C>y</C> in <A>Fam</A>, the product of
##  the images in <C>F</C> will be the image of <C>x * y - y * x</C>.
##  <P/>
##  The standard type of objects in a Lie family <C>F</C> is
##  <C><A>F</A>!.packedType</C>.
##  <P/>
##  <Index Key="Embedding" Subkey="for Lie algebras"><C>Embedding</C></Index>
##  The bijection from <A>Fam</A> to <C>F</C> is given by
##  <C>Embedding( <A>Fam</A>, F )</C>
##  (see&nbsp;<Ref Oper="Embedding" Label="for two domains"/>);
##  this bijection respects addition and additive inverses.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieFamily", IsFamily );


#############################################################################
##
#A  UnderlyingFamily( <Fam> )
##
##  <#GAPDoc Label="UnderlyingFamily">
##  <ManSection>
##  <Attr Name="UnderlyingFamily" Arg='Fam'/>
##
##  <Description>
##  If <A>Fam</A> is a Lie family then <C>UnderlyingFamily( <A>Fam</A> )</C>
##  is a family <C>F</C> such that <C><A>Fam</A> = LieFamily( F )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingFamily", IsObject );


#############################################################################
##
#A  LieObject( <obj> )
##
##  <#GAPDoc Label="LieObject">
##  <ManSection>
##  <Attr Name="LieObject" Arg='obj'/>
##
##  <Description>
##  Let <A>obj</A> be a ring element. Then <C>LieObject( <A>obj</A> )</C> is the
##  corresponding Lie object. If <A>obj</A> lies in the family <C>F</C>,
##  then <C>LieObject( <A>obj</A> )</C> lies in the family <C>LieFamily( F )</C>
##  (see&nbsp;<Ref Attr="LieFamily"/>).
##  <Example><![CDATA[
##  gap> m:= [ [ 1, 0 ], [ 0, 1 ] ];;
##  gap> lo:= LieObject( m );
##  LieObject( [ [ 1, 0 ], [ 0, 1 ] ] )
##  gap> m*m;
##  [ [ 1, 0 ], [ 0, 1 ] ]
##  gap> lo*lo;
##  LieObject( [ [ 0, 0 ], [ 0, 0 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieObject", IsRingElement );


#############################################################################
##
#A  UnderlyingRingElement( <obj> )
##
##  <#GAPDoc Label="UnderlyingRingElement">
##  <ManSection>
##  <Attr Name="UnderlyingRingElement" Arg='obj'/>
##
##  <Description>
##  Let <A>obj</A> be a Lie object constructed from a ring element
##  <C>r</C> by calling <C>LieObject( r )</C>.
##  Then <C>UnderlyingRingElement( <A>obj</A> )</C> returns
##  the ring element <C>r</C> used to construct <A>obj</A>.
##  If <C>r</C> lies in the family <C>F</C>, then <A>obj</A>
##  lies in the family <C>LieFamily( F )</C>
##  (see&nbsp;<Ref Attr="LieFamily"/>).
##  <Example><![CDATA[
##  gap> lo:= LieObject( [ [ 1, 0 ], [ 0, 1 ] ] );
##  LieObject( [ [ 1, 0 ], [ 0, 1 ] ] )
##  gap> m:=UnderlyingRingElement(lo);
##  [ [ 1, 0 ], [ 0, 1 ] ]
##  gap> lo*lo;
##  LieObject( [ [ 0, 0 ], [ 0, 0 ] ] )
##  gap> m*m;
##  [ [ 1, 0 ], [ 0, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingRingElement", IsLieObject );


#############################################################################
##
#F  IsLieObjectsModule( <V> )
##
##  <ManSection>
##  <Func Name="IsLieObjectsModule" Arg='V'/>
##
##  <Description>
##  If a free <M>F</M>-module <A>V</A> is in the filter <C>IsLieObjectsModule</C> then
##  this expresses that <A>V</A> consists of Lie objects (see&nbsp;<Ref ???="..."/>),
##  and that <A>V</A> is handled via the mechanism of nice bases (see&nbsp;<Ref ???="..."/>)
##  in the following way.
##  Let <M>K</M> be the default field generated by the vector space generators of
##  <A>V</A>.
##  Then the <C>NiceFreeLeftModuleInfo</C> value of <A>V</A> is irrelevant,
##  and the <C>NiceVector</C> value of <M>v \in <A>V</A></M> is defined as the underlying
##  element for which <A>v</A> is obtained as <C>LieObject</C> value.
##  </Description>
##  </ManSection>
##
DeclareHandlingByNiceBasis( "IsLieObjectsModule",
    "for free left modules of Lie objects" );
