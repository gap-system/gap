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
##  Declarations of utilities for fast prototyping of new GAP objects.
##


##########################################################################
##
#F  ArithmeticElementCreator(<spec>)
##
##  <#GAPDoc Label="ArithmeticElementCreator">
##  <ManSection>
##  <Func Name="ArithmeticElementCreator" Arg="spec"/>
##
##  <Description>
##  offers a simple interface to create new arithmetic elements by providing
##  functions that perform addition, multiplication and so forth, conforming
##  to the specification <A>spec</A>. <C>ArithmeticElementCreator</C>
##  creates a new category, representation and family for the new arithmetic
##  elements being defined, and returns a function which takes the
##  <Q>defining data</Q> of an element and returns the corresponding new
##  arithmetic element.
##  <P/>
##  <A>spec</A> is a record with one or more of the following components:
##  <List>
##  <Mark><C>ElementName</C></Mark>
##  <Item>
##     string used to identify the new type of object. A global
##     identifier <C>Is<A>ElementName</A></C> will be defined to indicate
##     a category for these now objects. (Therefore it is not clever to have
##     blanks in the name). Also a collections category is defined.
##     (You will get an error message if the identifier
##     <C>Is<A>ElementName</A></C> is already defined.)
##  </Item>
##  <Mark><C>Equality</C>, <C>LessThan</C>, <C>One</C>, <C>Zero</C>,
##   <C>Multiplication</C>, <C>Inverse</C>, <C>Addition</C>,
##   <C>AdditiveInverse</C></Mark>
##  <Item>
##     functions defining the arithmetic
##     operations. The functions interface on the level of
##     <Q>defining data</Q>, the actual methods installed will perform the
##     unwrapping and wrapping as objects.
##     Components are optional, but of course if no multiplication is
##     defined elements cannot be multiplied and so forth.
##     <P/>
##     There are default methods for <C>Equality</C> and <C>LessThan</C>
##     which simply calculate on the defining data.
##     If one is defined, it must be ensured that the other is compatible
##     (so that <M>a &lt; b</M> implies not <M>(a = b)</M>)
##  </Item>
##  <Mark><C>Print</C></Mark>
##  <Item>
##     a function which prints the object.
##     By default, just the defining data is printed.
##  </Item>
##  <Mark><C>MathInfo</C></Mark>
##  <Item>
##     filters determining the mathematical properties of the elements
##     created. A typical value is for example
##     <C>IsMultiplicativeElementWithInverse</C> for group elements.
##  </Item>
##  <Mark><C>RepInfo</C></Mark>
##  <Item>
##     filters determining the representational properties of the elements
##     created. The objects created are always component objects,
##     so in most cases the only reasonable option is
##     <C>IsAttributeStoringRep</C> to permit the storing of attributes.
##  </Item>
##  </List>
##  <P/>
##  All components are optional and will be filled in with default values
##  (though of course an empty record will not result in useful objects).
##  <P/>
##  Note that the resulting objects are <E>not equal</E> to their defining
##  data (even though by default they print as only the defining data). The
##  operation <C>UnderlyingElement</C> can be used to obtain the defining
##  data of such an element.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ArithmeticElementCreator");
