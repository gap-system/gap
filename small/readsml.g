#############################################################################
##
#W  readsml.g                GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
Revision.readsml_g :=
    "@(#)$Id$";

#############################################################################
##
#V  READ_SMALL_FUNCS[ ]
##
READ_SMALL_FUNCS := [ ];

#############################################################################
##
#V  READ_IDLIB_FUNCS[ ]
##
READ_IDLIB_FUNCS := [ ];

#############################################################################
##
#X  first read the basic stuff of the small group library and the id-group
##  functions
##
ReadSmall( "small.gd" );
ReadSmall( "small.gi" );

#############################################################################
##
#X  read the 3-primes-order stuff, which is placed in the 'small'-directory
##
ReadSmall( "smlgp1.g" );
ReadSmall( "idgrp1.g" );

#############################################################################
##
#X  read the information function
##
ReadSmall( "smlinfo.gi" );

#############################################################################
##
#X   read the function-files of the small groups library
##
READ_SMALL_LIB := function()
    local i, s;

    s := 1;
    repeat 
        s := s + 1;
        READ_SMALL_FUNCS[ s ] := ReadAndCheckFunc(
                               Concatenation( "small/small", String( s ) ) );
        READ_SMALL_FUNCS[ s ]( Concatenation( "smlgp", String( s ), ".g" ),
                           Concatenation( "small groups #", String( s ) ) );
    until not IsBound( SMALL_AVAILABLE_FUNCS[ s ] );

    i := 1;
    repeat
        i := i + 1;
        if i = s then
            return;
        fi;
        READ_IDLIB_FUNCS[ i ] := ReadAndCheckFunc(
                               Concatenation( "small/id", String( i ) ) );
        READ_IDLIB_FUNCS[ i ]( Concatenation( "idgrp", String( i ), ".g" ),
                           Concatenation( "ids of groups #", String( i ) ) );
    until not IsBound( ID_AVAILABLE_FUNCS[ i ] );
end;

READ_SMALL_LIB();

Unbind( READ_SMALL_LIB );
