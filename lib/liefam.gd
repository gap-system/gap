#############################################################################
##
#W  liefam.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id: liefam.gd,v 4.28 2008/09/22 16:22:29 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the definition of the family of Lie elements of a
##  family of ring elements.


#############################################################################
##
##  <#GAPDoc Label="[1]{liefam}">
##  Let <M>x</M> be a ring element, then <C>LieObject(x)</C> wraps <M>x</M> up into an
##  object that contains the same data (namely <M>x</M>). The multiplication
##  <C>*</C> for Lie objects is formed by taking the commutator. More exactly,
##  if <M>l_1</M> and <M>l_2</M> are the Lie objects corresponding to
##  the ring elements <M>r_1</M> and <M>r_2</M>, then <M>l_1 * l_2</M> is equal to the
##  Lie object corresponding to <M>r_1 * r_2 - r_2 * r_1</M>. Two rules
##  for Lie objects are worth noting:
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
##  Given a family <M>F</M> of ring elements, we can form its Lie family <M>L</M>.
##  The elements of <M>F</M> and <M>L</M> are in bijection, only the multiplications
##  via <C>*</C> differ for both families.
##  More exactly, if <M>l_1</M> and <M>l_2</M> are the Lie elements corresponding to
##  the elements <M>f_1</M> and <M>f_2</M> in <M>F</M>, we have <M>l_1 * l_2</M> equal to the
##  Lie element corresponding to <M>f_1 * f_2 - f_2 * f_2</M>.
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
Revision.liefam_gd :=
    "@(#)$Id: liefam.gd,v 4.28 2008/09/22 16:22:29 gap Exp $";


#############################################################################
##
#C  IsLieObject( <obj> )
#C  IsLieObjectCollection( <obj> )
##
##  <#GAPDoc Label="IsLieObject">
##  <ManSection>
##  <Filt Name="IsLieObject" Arg='obj' Type='Category'/>
##  <Filt Name="IsLieObjectCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  An object lies in <C>IsLieObject</C> if and only if it lies in a family
##  constructed by <C>LieFamily</C>.
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


#############################################################################
##
#A  LieFamily( <Fam> )
##
##  <#GAPDoc Label="LieFamily">
##  <ManSection>
##  <Attr Name="LieFamily" Arg='Fam'/>
##
##  <Description>
##  is a family <M>F</M> in bijection with the family <A>Fam</A>,
##  but with the Lie bracket as infix multiplication.
##  That is, for <M>x</M>, <M>y</M> in <A>Fam</A>, the product of the images in <M>F</M> will be
##  the image of <M>x * y - y * x</M>.
##  <P/>
##  The standard type of objects in a Lie family <A>F</A> is <C><A>F</A>!.packedType</C>.
##  <P/>
##  <Index Key="Embedding" Subkey="for Lie algebras"><C>Embedding</C></Index>
##  The bijection from <A>Fam</A> to <M>F</M> is given by <C>Embedding( <A>Fam</A>, </C><M>F</M><C> )</C>;
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
##  is a family <M>F</M> such that <C><A>Fam</A> = LieFamily( </C><M>F</M><C> )</C>.
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
##  corresponding Lie object. If <A>obj</A> lies in the family <A>F</A>,
##  then <C>LieObject( <A>obj</A> )</C> lies in the family LieFamily( <A>F</A> )
##  (see&nbsp;<Ref Func="LieFamily"/>).
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


#############################################################################
##
#E

