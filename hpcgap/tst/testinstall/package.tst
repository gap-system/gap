#############################################################################
##
#W  package.tst               GAP Library                       Thomas Breuer
##
##
#Y  Copyright (C)  2005,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testinstall.g: why?
##
gap> START_TEST("package.tst");

# CompareVersionNumbers( <supplied>, <required>[, \"equal\"] )
gap> sml:= [ [ "", "dev" ], [ "a", "1" ], [ "a", "b1c" ], [ "1", "2" ],
>      [ "a1b", "1c1" ], [ "1a2", "b2c1d" ], [ "a1b2c3", "d1e3" ],
>      [ "1a2b3", "c1d2e4f" ] ];;
gap> equ:= [ [ "a", "" ], [ "a1b", "1" ], [ "a1b2c", "1a2" ],
>      [ "a1b2c3d", "1a2b3" ] ];;
gap> for pair in sml do
>   if   CompareVersionNumbers( pair[1], pair[2] ) then
>     Error( "wrong result for ", pair );
>   elif not CompareVersionNumbers( pair[2], pair[1] ) then
>     Error( "wrong result for ", Reversed( pair ) );
>   elif CompareVersionNumbers( pair[1], pair[2], "equal" ) then
>     Error( "wrong result for ", pair, " and \"equal\"" );
>   elif CompareVersionNumbers( pair[2], pair[1], "equal" ) then
>     Error( "wrong result for ", Reversed( pair ), " and \"equal\"" );
>   fi;
> od;
gap> for pair in equ do
>   if   not CompareVersionNumbers( pair[1], pair[2] ) then
>     Error( "wrong result for ", pair );
>   elif not CompareVersionNumbers( pair[2], pair[1] ) then
>     Error( "wrong result for ", Reversed( pair ) );
>   elif not CompareVersionNumbers( pair[1], pair[2], "equal" ) then
>     Error( "wrong result for ", pair, " and \"equal\"" );
>   elif not CompareVersionNumbers( pair[2], pair[1], "equal" ) then
>     Error( "wrong result for ", Reversed( pair ), " and \"equal\"" );
>   fi;
> od;
gap> for entry in Set( Concatenation( Concatenation( [ sml, equ ] ) ) ) do
>   if   not CompareVersionNumbers( entry, entry ) then
>     Error( "wrong result for ", [ entry, entry ] );
>   elif not CompareVersionNumbers( entry, entry, "equal" ) then
>     Error( "wrong result for ", [ entry, entry ], " and \"equal\"" );
>   fi;
> od;
gap> STOP_TEST( "package.tst", 1);

#############################################################################
##
#E
