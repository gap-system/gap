#############################################################################
##
#C  IsStream
##
IsStream := NewCategory(
    "IsStream",
    IsObject );


#############################################################################
##
#C  IsInputStream
##
IsInputStream := NewCategory(
    "IsInputStream",
    IsStream );


#############################################################################
##
#C  IsInputTextStream
##
IsInputTextStream := NewCategory(
    "IsInputTextStream",
    IsInputStream );


#############################################################################
##
#O  InputTextString( <string> )
##
InputTextString := NewOperation(
    "InputTextString",
    [ IsString ] );


#############################################################################
##
#V  StreamFamily
##
StreamFamily := NewFamily( "StreamFamily" );


#############################################################################
##
#O  IsEndOfStream( <stream> )
##
IsEndOfStream := NewOperation(
    "IsEndOfStream",
    [ IsInputStream ] );


#############################################################################
##
#O  ReadChar( <input-text-stream> )
##
ReadChar := NewOperation(
    "ReadChar",
    [ IsInputTextStream ] );
                    

#############################################################################
##
#O  ReadAll( <input-text-stream> )
##
ReadAll := NewOperation(
    "ReadAll",
    [ IsInputTextStream ] );


#############################################################################
##
#O  ReadLine( <input-text-stream> )
##
ReadLine := NewOperation(
    "ReadLine",
    [ IsInputTextStream ] );
