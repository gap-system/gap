#############################################################################
##
#W  grpconst.tst              GAP Library                  Hans Ulrich Besche
##
##
#Y  Copyright (C)  1999,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testinstall.g: why?
##

gap> START_TEST("grpconst.tst");
gap> if LoadPackage( "grpconst", false )=fail then
> Print("\n\n",
> "*** Since you do not have the `grpconst' package installed,    ***\n",
> "*** you will get some error messages. They should be ignored.  ***\n\n\n");
> fi;
gap> ConstructAndTestAllGroups := function( size )
> local grps;
>     grps := ConstructAllGroups( size );
>    if Length( grps ) <> NumberSmallGroups( size ) then
>        Print( "wrong number of groups of size ", size, "\n" );
>    fi;
>    if Set( List( grps, IdGroup ) ) <>
>       List( [ 1 .. NumberSmallGroups( size ) ], x -> [ size, x ] ) then
>        Print( "wrong ids for the groups of size ", size, "\n" );
>    fi;
> end;
function( size ) ... end
gap> ConstructAndTestAllGroups( 96 );;
gap> ConstructAndTestAllGroups( 648 );;
gap> ConstructAndTestAllGroups( 840 );;
gap> ConstructAndTestAllGroups( 1560 );;
gap> ConstructAndTestAllGroups( 1800 );;
gap> UnloadSmallGroupsData();
gap> STOP_TEST( "grpconst.tst", 1);

#############################################################################
##
#E

