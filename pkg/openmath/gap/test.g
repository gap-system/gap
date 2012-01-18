#######################################################################
##
#W  test.g             GAP OpenMath Package              Andrew Solomon
#W                                                     Marco Costantini
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  testing functions
##

#######################################################################
##
#F  OMTestXML( <object> )
##
##  Converts to XML OpenMath and back. 
##  Returns true iff <object> is unchanged.
##
InstallGlobalFunction(OMTestXML, function(o)

	local
		p,	# the object retrieved
		s, t; # stream and string resp.

	# output
	t := "";
	s := OutputTextString(t, false);
	OMPutObject( OpenMathXMLWriter(s), o);
	CloseStream(s);

	#input
	s := InputTextString(t);
	p := OMGetObject(s);
	CloseStream(s);

	return o = p;
	
end);


#######################################################################
##
#F  OMTestBinary( <object> )
##
##  Converts to binary OpenMath and back. 
##  Returns true iff <object> is unchanged.
##
InstallGlobalFunction(OMTestBinary, function(o)

	local
		p,	# the object retrieved
		s, t; # stream and string resp.

	# output
	t := "";
	s := OutputTextString(t, false);
	OMPutObject( OpenMathBinaryWriter(s), o);
	CloseStream(s);

	#input
	s := InputTextString(t);
	p := OMGetObject(s);
	CloseStream(s);

	return o = p;
	
end);


#############################################################################
#E
