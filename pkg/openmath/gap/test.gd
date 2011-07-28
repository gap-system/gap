#######################################################################
##
#W  test.gd          GAP OpenMath Package                Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: test.gd,v 1.4 2010/09/01 15:18:22 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  testing function
##

Revision.("openmath/gap/test.gd") :=
    "@(#)$Id: test.gd,v 1.4 2010/09/01 15:18:22 alexk Exp $";


#######################################################################
##
#F  OMTestXML( <obj> )
##
##  Converts <obj> to XML OpenMath and back. Returns true iff <obj> 
##  is unchanged (as a GAP object) by this operation. The OpenMath 
##  standard does not stipulate that converting to and from OpenMath 
##  should be the identity function so this is a useful diagnostic 
##  tool.
##
DeclareGlobalFunction("OMTestXML");
DeclareSynonym( "OMTest", OMTestXML );


#######################################################################
##
#F  OMTestBinary( <obj> )
##
##  Similar to OMTestXML, but uses binary OpenMath representation.
##
DeclareGlobalFunction("OMTestBinary");


#############################################################################
#E
