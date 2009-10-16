#############################################################################
##
#W  omget.g             OpenMath Package               Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: omget.g,v 1.23 2006/08/03 18:23:38 gap Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Reads an OpenMath object from an input stream and returns
##  a GAP object.
##
##

Revision.("openmath/gap/omget.g") :=
    "@(#)$Id: omget.g,v 1.23 2006/08/03 18:23:38 gap Exp $";



#############################################################################
##
#F  OMGetObject( <stream> )
##
##  <stream> is an input stream with an OpenMath object on it.
##  Takes precisely one object off <stream> (using PipeOpenMathObject)
##  and puts it into a string.
##  From there the OpenMath object is turned into a GAP object
##  by an appropriate function.
##



InstallGlobalFunction(OMGetObject,
function( stream )
    local
        fromgap, # string
        success; # whether PipeOpenMathObject worked

    if IsClosedStream( stream )  then
        Error( "closed stream" );
    elif IsEndOfStream( stream )  then
        Error( "end of stream" );
    fi;

    fromgap := "";

    # Get one OpenMath object from 'stream' and put into 'fromgap',
    # using PipeOpenMathObject

    success := PipeOpenMathObject( stream, fromgap );

    if success <> true  then
        Error( "OpenMath object not retrieved" );
    fi;

    # convert the OpenMath string into a Gap object using an appropriate
    # function

    # this means XML encoding
    if fromgap[1] = '<' and OMgetObjectXMLTree <> ReturnFail  then
        return OMgetObjectXMLTree( fromgap );
    else
        return OMpipeObject( fromgap );
    fi;

end );


#############################################################################
#E
