#############################################################################
##
#W  omget.g             OpenMath Package               Andrew Solomon
#W                                                     Marco Costantini
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Reads an OpenMath object from an input stream and returns a GAP object.
##
##


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
InstallGlobalFunction(OMGetObject, function( stream )
    local
        fromgap, firstbyte, gap_obj, # string
        success; # whether PipeOpenMathObject worked

    if IsClosedStream( stream )  then
        Error( "closed stream" );
    elif IsEndOfStream( stream )  then
        Error( "end of stream" );
    fi;

    firstbyte := ReadByte(stream);
    
    if firstbyte = 24 then 
  	    # Binary encoding
 	    gap_obj := GetNextObject( stream, firstbyte );
     	gap_obj := OMParseXmlObj( gap_obj.content[1] );
        return gap_obj;
    else        
     	# XML encoding
        fromgap := "";
        # Get one OpenMath object from 'stream' and put into 'fromgap',
        # using PipeOpenMathObject

        success := PipeOpenMathObject( stream, fromgap, firstbyte );

        if success <> true  then
       		Error( "OpenMath object not retrieved" );
        fi;
		
        # convert the OpenMath string into a Gap object using an appropriate
        # function

        return OMgetObjectXMLTree( fromgap );
 
  	fi;    
    
end);


#############################################################################
#E
