# Formatting output streams

InstallMethod(OutputTextStreamFormatter,
    "for a stream, and an int",
    [ IsOutputStream, IsInt ],
function( stream, ident )
    local i;

    if ident < 0 then
        Error("initial identation has to be >= 0");
    fi;
    return Objectify( OutputTextStreamFormatterType, [ stream, ident ] );
end);

InstallOtherMethod( OutputTextStreamFormatter,
                    "for an output stream",
                    [ IsOutputStream ],
function( stream )
    return OutputTextStreamFormatter(stream, 0);
end );

InstallMethod( ViewString,
    "for an output stream formatter",
    [ IsOutputTextStreamFormatterRep ],
function( obj )
    return "<wrapped output stream>";
end );

InstallMethod( WriteAll,
    "for an output stream formatter",
    [ IsOutputTextStream and IsOutputTextStreamFormatterRep,
      IsString ],
function( stream, string )
    local b;

    WriteAll(stream![1], ListWithIdenticalEntries(stream![2], ' '));
    for b in string do
        WriteByte(stream, INT_CHAR(b));
    od;
    return true;
end );

InstallMethod( WriteByte,
    "output text string",
    [ IsOutputTextStream and IsOutputTextStreamFormatterRep,
      IsInt ],
function( stream, byte )
    if byte < 0 or 255 < byte  then
        Error( "<byte> must an integer between 0 and 255" );
    fi;
    if byte = INT_CHAR('\<') then
        if stream![2] > 0 then
            stream![2] := stream![2] - 1;
        fi;
    elif byte = INT_CHAR('\>') then
        stream![2] := stream![2] + 1;
    else
        WriteByte(stream![1], byte);
        if byte = INT_CHAR('\n') then
            WriteAll(stream![1], ListWithIdenticalEntries(stream![2], ' '));
        fi;
        return true;
    fi;
end );

InstallMethod( GetIndentation,
    "for an output stream formatter",
    [ IsOutputTextStreamFormatterRep ],
    x -> x![2] );

InstallMethod( SetIndentation,
    "for an output stream formatter",
    [ IsOutputTextStreamFormatterRep, IsInt ],
function(stream, ident)
    if ident < 0 then
        Error("Indentation has to be >= 0");
    fi;
    stream![2] := ident;
    return stream![2];
end);

# prefix output
InstallMethod( OutputTextStreamPrefixer,
    "for a stream, and an int",
    [ IsOutputStream, IsString ],
function( stream, prefix )
    return Objectify( OutputTextStreamPrefixerType, [ stream, prefix ] );
end);

InstallMethod( ViewString,
    "for an output stream formatter",
    [ IsOutputTextStreamPrefixerRep ],
function( obj )
    return Concatenation("<wrapped output stream, prefixing ", obj![2], ">");
end );

InstallMethod( WriteAll,
    "for an output stream formatter",
    [ IsOutputTextStream and IsOutputTextStreamPrefixerRep,
      IsString ],
function( stream, string )
    local b;

    WriteAll(stream![1], stream![2]);
    for b in string do
        WriteByte(stream, INT_CHAR(b));
    od;
    return true;
end );

InstallMethod( WriteByte,
    "output text string",
    [ IsOutputTextStream and IsOutputTextStreamPrefixerRep,
      IsInt ],
function( stream, byte )
    if byte < 0 or 255 < byte  then
        Error( "<byte> must an integer between 0 and 255" );
    fi;
    WriteByte(stream![1], byte);
    if byte = INT_CHAR('\n') then
        WriteAll(stream![1], stream![2]);
    fi;
    return true;
end );

