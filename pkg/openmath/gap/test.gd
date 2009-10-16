#######################################################################
##
#W  test.gd          GAP OpenMath Package           Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: test.gd,v 1.3 2006/07/15 13:21:34 gap Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  testing function
##

Revision.("openmath/gap/test.gd") :=
    "@(#)$Id: test.gd,v 1.3 2006/07/15 13:21:34 gap Exp $";



#######################################################################
##
#F  OMTest( <obj> )
##
##  
##  Converts <obj> to OpenMath and back. Returns true iff <obj> is unchanged
##  (as a GAP object) by this operation. The OpenMath standard does not 
##  stipulate that converting to and from OpenMath should be the identity
##  function so this is a useful diagnostic tool.
##

DeclareGlobalFunction("OMTest");


#############################################################################
#E
