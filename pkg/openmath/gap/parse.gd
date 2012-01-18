###########################################################################
##
#W  parse.gd           OpenMath Package                      Andrew Solomon
#W                                                          d Marco Costantini
##
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  The parser reads token/values off the stream and builds GAP objects.
##  


###########################################################################
##
## Parser for the 'abstract grammar' given by:
##
## basic -> integer | float | string | bytearray | symbol | variable
## object -> basic | application | attribution | binding | error
## objects -> | object objects
## attrs ->  symbol object | symbol object attrs 
## application -> 'Application'(object objects)
## attribution -> 'Attribution'( attrs object )
## binding -> 'Binding'(object variables object)
## error -> 'Error'(symbol objects)
##
DeclareGlobalFunction("OMgetObjectByteStream");
DeclareGlobalFunction("OMparseApplication");
DeclareGlobalFunction("OMparseAttribution");
DeclareGlobalFunction("OMparseBind");
DeclareGlobalFunction("OMparseObject");


###########################################################################
#E
