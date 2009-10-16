#############################################################################
##
#W  grpconst.tst              GAP Library                  Hans Ulrich Besche
##
#H  @(#)$Id: grpconst.tst,v 4.7 2005/05/05 14:59:52 gap Exp $
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testall.g: why?
##

gap> START_TEST("$Id: grpconst.tst,v 4.7 2005/05/05 14:59:52 gap Exp $");
gap> if LoadPackage( "grpconst" )=fail then
#I ------ The AutPGrp package version: 1.1 ------- 
#I -- Computing automorphism groups of p-groups -- 
    ----------------------------------------------- 
    ---- Algorithms to construct finite groups ---- 
    ----- Hans Ulrich Besche and Bettina Eick ----- 
    ----------------------------------------------- 
    --------------- See ?GrpConst ----------------- 
    ----------------------------------------------- 
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

gap> STOP_TEST( "grpconst.tst", 130921000000 );

#############################################################################
##
#E

