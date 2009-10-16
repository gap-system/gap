#############################################################################
##
#W  parse.gi           OpenMath Package         Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: parse.gi,v 1.12 2009/04/11 13:23:39 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  The parser reads token/values off the stream and builds GAP objects.
##  

Revision.("openmath/gap/parse.gi") :=
    "@(#)$Id: parse.gi,v 1.12 2009/04/11 13:23:39 alexk Exp $";



InstallGlobalFunction(OMgetObjectByteStream,
function(inputstream)
	local stream, obj;

	# assumes there is at least one byte on stream.
	stream := rec(next := ReadByte(inputstream), stream := inputstream);


	# Start -> OMtokenObject object OMtokenEndObject

	# get the OMtokenObject
	OMgetToken(stream, OMtokenObject);

	# parse the object
	obj := OMparseObject(stream);

	OMgetToken(stream, OMtokenEndObject);

	return obj;
end);


InstallGlobalFunction( OMpipeObject,
function( fromgap )

    local
        gpipe_exec, # filename of gpipe executable
        togap_stream, fromgap_stream, # streams from gpipe and to gpipe
        togap, # strings
        gap_obj;

    gpipe_exec := Filename( DirectoriesPackagePrograms( "openmath" ), "gpipe" );

    if gpipe_exec = fail  then
        Error( "package ``openmath'': the program `gpipe' is not compiled;\n",
         "see the README file or the dvi/ps/pdf manual of the package ``openmath''.\n",
         "Without this program, conversion from OpenMath to GAP cannot be performed.\n" );
    fi;

    # Remove the possible arguments of the <OMOBJ> tag. This is
    # necessary in order to support the OpenMath 2.0 objects of the form
    # <OMOBJ xmlns="http://www.openmath.org/OpenMath" version="2.0" cdbase="http://www.openmath.org/cd">

    # this means XML encoding
    if fromgap[1] = '<'  then
        fromgap := Concatenation( "<OMOBJ",
            fromgap{[ Position( fromgap, '>' ) .. Length( fromgap ) ]} );
    fi;

    # Pipe 'fromgap' to 'gpipe', getting 'togap'

    fromgap_stream := InputTextString( fromgap );
    togap := "";
    togap_stream := OutputTextString( togap, false );

    Process( DirectoryCurrent(  ), gpipe_exec,
             fromgap_stream, togap_stream, [ "-u", "-", "-" ] );

    CloseStream( fromgap_stream );
    CloseStream( togap_stream );


    # Send 'togap' to OMgetObjectByteStream, getting a Gap object

    togap_stream := InputTextString( togap );

    gap_obj := OMgetObjectByteStream( togap_stream );

    CloseStream( togap_stream );
    return gap_obj;

end);



InstallGlobalFunction(OMparseApplication, function(stream)
		local head, rest, nextob;

		# first get the OMtokenApp off the stream
		OMgetToken(stream, OMtokenApp);

		#
		# 1. Get the "head" object
		# the possibilities are:
		#
		# 2. Apply the head to the rest
		#

		# 1.1 If it's a symbol, look it up and see what it translates to in GAP
		if OMnextToken(stream) = OMtokenSymbol then
			head := OMsymLookup(OMgetSymbol(stream));
		else
			head := OMparseObject(stream);
		fi;

		# get the rest
		rest := [];
		while OMnextToken(stream) <> OMtokenEndApp do
			nextob := OMparseObject(stream);
			Append(rest, [nextob]);
		od;

		# finally get the OMtokenEndApp off the stream
		OMgetToken(stream, OMtokenEndApp);


		return head( rest );
end);

# just ignore everything but the object
InstallGlobalFunction(OMparseAttribution, function(stream)
		local nextob, ob;

		# first get the OMtokenAttr off the stream
		OMgetToken(stream, OMtokenAttr);

		# now get the OMtokenAtp off the stream
		OMgetToken(stream, OMtokenAtp);

		# just read all the objects until the end of attribution
		while OMnextToken(stream) <> OMtokenEndAtp do
			nextob := OMparseObject(stream);
		od;

		# get the OMtokenEndAtp off the stream
		OMgetToken(stream, OMtokenEndAtp);

		# finally, the only thing we don't ignore - the unattributed object
		ob :=  OMparseObject(stream);

		OMgetToken(stream, OMtokenEndAttr);

		return ob;
end);


InstallGlobalFunction(OMparseBind, function(stream)
	Error("Binding is unimplemented");
end);


InstallGlobalFunction(OMparseObject, function(stream)
##
## Object -> symbol | variable | integer | float | string | bytearray | 
##           application | binding | error | attribution

	# first the basic objects

	if OMnextToken(stream) = OMtokenSymbol then
		# this is just a nullary symbol 
		return OMsymLookup(OMgetSymbol(stream));
	elif OMnextToken(stream) = OMtokenVar then
		return OMgetVar(stream);
	elif  OMnextToken(stream) = OMtokenInteger then
		return OMgetInteger(stream);
	elif OMnextToken(stream) = OMtokenFloat then
		Error("GAP doesn't support floating point numbers.");
	elif OMnextToken(stream) = OMtokenString then
		return OMgetString(stream);
	elif OMnextToken(stream) = OMtokenByteArray then
		Error("GAP doesn't support byte arrays.");

	# now the compound objects
	elif OMnextToken(stream) = OMtokenApp then
		return OMparseApplication(stream);
	elif OMnextToken(stream) = OMtokenBind then
		return OMparseBind(stream);
	elif OMnextToken(stream) = OMtokenError then
		Error("OMtokenError encountered");
	elif OMnextToken(stream) = OMtokenAttr then
		return OMparseAttribution(stream);
		
		
	else
		Error("unrecognized token ", OMnextToken(stream));
	fi;
end);


#############################################################################
#E
