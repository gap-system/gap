#############################################################################
##
#W  demo.g                      GAP library                     Werner Nickel
##
#H  @(#)$Id$
##
##  This files contains functions that support running demonstrations with
##  Gap.
##
Revision.demo_g :=
    "@(#)$Id$";


#############################################################################
##
#F  Demonstration( <file> ) . . . . . . . . . . run a demonstration from file
##
BindGlobal( "Demonstration", function( file )
    local   input,  keyboard,  result;

    input := InputTextFile( file );
    while input = fail do
        Error( "Cannot open file ", file );
    od;

    Print( "\nStart of demonstration.\n\n" );

    InputLogTo( "*stdout*" );
    keyboard := InputTextUser();
    Print( "demo> \c" );
    while CHAR_INT( ReadByte( keyboard ) ) <> 'q' do
        result := READ_COMMAND( input, true );      # Executing the command.
        if result <> fail then
            View( result);
            Print("\n" );
        fi;

        if IsEndOfStream( input ) then
            break;
        fi;
        Print( "demo> \c" );
    od;
    Print( "\nEnd of demonstration.\n\n" );
    CloseStream( keyboard );
    CloseStream( input );
    InputLogTo();
end );


#############################################################################
##
#E

