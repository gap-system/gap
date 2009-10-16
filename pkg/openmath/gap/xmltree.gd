#############################################################################
##
#W  xmltree.gd          OpenMath Package              Andrew Solomon
#W                                                    Marco Costantini
##
#H  @(#)$Id: xmltree.gd,v 1.2 2008/12/15 17:22:46 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  The main function in this file converts the OpenMath XML into a tree
##  (using the function ParseTreeXMLString from package GapDoc) and
##  parses it.
##

Revision.("openmath/gap/xmltree.gd") :=
    "@(#)$Id: xmltree.gd,v 1.2 2008/12/15 17:22:46 alexk Exp $";



DeclareGlobalFunction("OMParseXmlObj");
DeclareGlobalFunction("OMgetObjectXMLTree");


#############################################################################
#E
