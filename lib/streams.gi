#############################################################################
##
#V  InputTextStringKind
##
InputTextStringKind := NewKind(
    StreamFamily,
    IsInputTextStream and IsInputTextStringRep );


#############################################################################
##
#F  InputTextString( <str> )
##
InstallMethod( InputTextString,
    "input text stream from string",
    true,
    [ IsString ],
    0,
        
function( str )
    local   stream;

    stream := [ 0, Immutable(str) ];
    return Objectify( InputTextStringKind, stream );
end );


#############################################################################
##
#F  PrintObj( <stream> )
##
InstallMethod( PrintObj,
    "input text stream",
    true,
    [ IsInputTextStringRep ],
    0,
        
function( obj )
    Print( "stream(", obj![1], ",", Length(obj![2]), ")" );
end );


#############################################################################
##
#F  IsEndOfStream( <stream> )
##
InstallMethod( IsEndOfStream,
    "input text string",
    true,
    [ IsInputStream and IsInputTextStringRep ],
    0,
        
function( stream )
    return Length(stream![2]) <= stream![1];
end );


#############################################################################
##
#F  ReadChar( <input-text-stream> )
##
InstallMethod( ReadChar,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,
                    
function( stream )
    if Length(stream![2]) <= stream![1]  then
        return fail;
    fi;
    stream![1] := stream![1] + 1;
    return stream![2][stream![1]];
end );


#############################################################################
##
#F  ReadAll( <input-text-stream> )
##
InstallMethod( ReadAll,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,
        
function( stream )
    local   start;

    if Length(stream![2]) <= stream![1]  then
        return fail;
    fi;
    start := stream![1]+1;
    stream![1] := Length(stream![2]);
    return Immutable( stream![2]{[start..stream![1]]} );
    
end );


#############################################################################
##
#F  ReadLine( <input-text-stream> )
##
InstallMethod( ReadLine,
    "input text string",
    true,
    [ IsInputTextStream and IsInputTextStringRep ],
    0,

function( stream )
    local   str,  len,  start,  stop;

    str := stream![2];
    len := Length(str);
    if len <= stream![1]  then
        return fail;
    fi;
    start := stream![1] + 1;
    stop  := start;
    while stop <= len and str[stop] <> '\n'  do
        stop := stop + 1;
    od;
    if stop <= len  then
        stream![1] := stop;
        return Immutable( str{[start..stop-1]} );
    else
        stream![1] := stop-1;
        return Immutable( str{[start..stop]} );
    fi;

end );



