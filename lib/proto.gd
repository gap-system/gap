#############################################################################
##
#W  proto.gd                    GAP library                  Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  Declarations of utilities for fast prototyping of new GAP objects.
##
Revision.proto_gd :=
    "@(#)$Id$";

##########################################################################
##
#F  ArithmeticElementCreator(<spec>)
##
##  offers a simple interface to create new arithmetic elements by providing
##  functions that perform addition, multiplication and so forth, conforming to 
##  the specification <spec>. `ArithmeticElementCreator'
##  creates a new category, representation and family for the new arithmetic 
##  elements being defined, and returns a function which takes the 
##  ``defining data'' of an element and returns the corresponding new
##  arithmetic element.
##
##  <spec> is a record with one or more of the following components:
##  \beginitems
##  `ElementName'&a string used to identify the new type of object. A global
##  identifier `Is<ElementName>' will be defined to indicate a category for
##  these now objects. (Therefore it is not clever to have blanks in the
##  name). Also a collections category is defined. (You will get an error
##  message if the identifier `Is<ElementName>' is already defined.)
##
##  `Equality', `LessThan', `One', `Zero', `Multiplication', `Inverse', 
##  `Addition', `AdditiveInverse'& functions defining the arithmetic
##  operations. The functions interface on the level of ``defining data'',
##  the actual methods installed will perform the unwrapping and wrapping as
##  objects. Components are optional, but of course if no multiplication is
##  defined elements cannot be multiplied and so forth.
##
##  &There are default methods for `Equality' and `LessThan' which simply
##  calculate on the defining data. If one is defined, it must be ensured
##  that the other is compatible (so that $a \< b$ implies not($a = b$))
##
##  `Print' & a function which prints the object. By default, just
##  the defining data is printed.
##
##  `MathInfo' & filters determining the 
##  mathematical properties of the elements created. A typical value is for
##  example `IsMultiplicativeElementWithInverse' for group elements.
##
##  `RepInfo' & filters determining the representational
##   properties of the elements created. The objects created are always
##   component objects, so in most cases the only reasonable option is
##   `IsAttributeStoringRep' to permit the storing of attributes.
##  \enditems
##  All components are optional and will be filled in with default values
##  (though of course an empty record will not result in useful objects).
##
##  Note that the resulting objects are *not equal* to their defining data
##  (even though by default they print as only the defining data). The
##  operation `UnderlyingElement' can be used to obtain the defining
##  data of such an element.
##
DeclareGlobalFunction("ArithmeticElementCreator");



#############################################################################
##
#E

