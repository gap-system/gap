#############################################################################
##
#W  attr.gd                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
Revision.attr_gd :=
  "@(#)$Id$";

#1  
##  The normal behaviour of attributes (when called with just one argument)
##  is that once a method has been selected and executed, and has returned a
##  value the setter of the attribute is called, to (possibly) store the
##  computed value. In special circumstances, this behaviour can be altered
##  dynamically on an attribute-by-attribute basis, using the functions
## `DisableAttributeValueStoring' and `EnableAttributeValueStoring'.
##
##  In general, the code in the library assumes, for efficiency, but not for
##  correctness, that attribute values *will* be stored (in suitable
##  objects), so disabling storing may cause substantial computations to be
##  repeated.
##

#############################################################################
##
#V  InfoAttributes . . . info class for reporting on attribute tweaking
##
##  This info class (together with InfoWarning) is used for messages
##  about attribute storing being disabled (at level 2) or enabled
##  (level 3). It may be used in the future for other messages concerning
##  changes to attribute behaviour.
##

DeclareInfoClass("InfoAttributes");



#############################################################################
##
#F  EnableAttributeValueStoring( <attr> ) tell the attribute to resume 
##                                           storing values
##
##  'EnableAttributeValueStoring( <attr> )' enables the usual call of
##  'Setter( <attr> )' when a method for <attr> returns a value.  In
##  consequence the values may be stored.  This will usually have no
##  effect unless 'DisableAttributeValueStoring' has previously been
##  used for <attr>. <attr> must be an attribute and *not* a property.
##  
##

DeclareGlobalFunction("EnableAttributeValueStoring");

#############################################################################
##
#F  DisableAttributeValueStoring( <attr> ) tell the attribute to resume 
##                                           storing values
##
##  'DisableAttributeValueStoring( <attr> )' disables the usual call
##  of 'Setter( <attr> )' when a method for <attr> returns a value.
##  In consequence the values will never be stored. <attr> must be an 
##  attribute and *not* a property.
##

DeclareGlobalFunction("DisableAttributeValueStoring");
