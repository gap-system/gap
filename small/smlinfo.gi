#############################################################################
##
#W  smlinfo.gi               GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the ...
##
Revision.smlinfo_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  SMALL_GROUPS_INFORMATION
##
##  ...
SMALL_GROUPS_INFORMATION := [ ];

#############################################################################
##
#F  SmallGroupsInformation( size )
##
##  ...
InstallGlobalFunction( SmallGroupsInformation, function( size )
    local smav, idav, num, lib, t;

    smav := SMALL_AVAILABLE( size );
    idav := ID_AVAILABLE( size );

    if size = 1024 then
        Print( "The groups of size 1024 are not available. \n");
        return;
    fi;

    if smav = fail then
        Print( "The groups of size ", size, " are not available. \n");
        return;
    fi; 

    lib := 1;
    if IsBound( smav.lib ) then
        lib := smav.lib;
    fi;
    
    if IsBound( smav.number ) then
        num := smav.number;
    else
        num := NUMBER_SMALL_GROUPS_FUNCS[ smav.func ]( size, smav ).number;
    fi;
    if num = 1 then 
        Print("\n  There is 1 group of order ",size,".\n");
    else
        Print("\n  There are ",num," groups of order ",size,".\n" );
    fi;
 
    SMALL_GROUPS_INFORMATION[ smav.func ]( size, smav, num );

    Print("\n  This size belongs to layer ",lib,
          " of the SmallGroups library. \n");

    if idav <> fail then 
        Print("  IdGroup is available for this size. \n \n");
    else        
        Print("  IdGroup is not available for this size. \n \n");
    fi;
end );

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 1 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 1 ] := function( size, smav, num )
    local all, i;

    all := AllSmallGroups( size );
    for i in [ 1 .. Length( all ) ] do
        if HasNameIsomorphismClass( all[ i ] ) then
            Print("    ",i," is of type ",NameIsomorphismClass(all[i]),".\n");
        else
            if HasNameIsomorphismClass( all[ i - 1 ] ) then
                Print( "    ", i, " - ", Length(all)-1, " are of types " );
                if smav.func = 6 then
                    Print( smav.q,":",smav.p,"+",smav.q,":",smav.p,".\n" );
                else
                    Print( smav.q,":",smav.p,"+",smav.r,":",smav.p,".\n" );
                fi;
            fi;
        fi;
    od;
        
    Print("\n");
    Print("  The groups whose order factorises in at most 3 primes \n");
    Print("  have been classified by O. Hoelder. This classification is \n");
    Print("  used in the SmallGroups library. \n");
end;

SMALL_GROUPS_INFORMATION[ 2 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 3 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 4 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 5 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 6 ] := SMALL_GROUPS_INFORMATION[ 1 ];
SMALL_GROUPS_INFORMATION[ 7 ] := SMALL_GROUPS_INFORMATION[ 1 ];

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 8 .. 10 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 8 ] := function( size, smav, num )
    local ffid, prop, i, l;

    ffid := IdGroup( OneSmallGroup( size, FrattinifactorSize, size ) );
    prop := PROPERTIES_SMALL_GROUPS[ size ].frattFacs;

    if not IsPrimePowerInt( size ) then
        Print("  There are sorted by their Frattini factors. \n");
        i := 1;
        if ffid[ 2 ] > 1 then
            repeat 
                if prop.pos[ i ][ 1 ] = -prop.pos[ i ][ 2 ] then
                    Print( "     ", prop.pos[ i ][ 1 ],
                       " has Frattini factor ", prop.frattFacs[ i ], ".\n"  );
                else
                    Print( "     ", prop.pos[ i ][ 1 ], " - ",
                       -prop.pos[ i ][ 2 ], " have Frattini factor ",
                       prop.frattFacs[ i ], ".\n"  );
                fi;
                i := i + 1;
            until prop.frattFacs[ i ] = ffid;
        fi;
        Print("     ", ffid[2], " - ", num, 
              " have trivial Frattini subgroup.\n");
    else
        Print("  There are sorted by their ranks. \n");
        Print("     ", 1, " is cyclic. \n");
        i := 2;
        repeat 
            l := Length( Factors( prop.frattFacs[ i ][1] ) );
            if prop.pos[ i ][ 1 ] = -prop.pos[ i ][ 2 ] then
                Print( "     ", prop.pos[ i ][ 1 ], " has rank ", l, ".\n"  );
            else
                Print( "     ", prop.pos[ i ][ 1 ], " - ",
                       -prop.pos[ i ][ 2 ], " have rank ", l, ".\n"  );
            fi;
            i := i + 1;
        until prop.frattFacs[ i ] = ffid;
        Print("     ", ffid[2], " is elementary abelian. \n");
    fi;

    Print( "\n  For the selection functions the values of the ",
           "following attributes \n  are precomputed and stored:\n ");
    if IsPrimePowerInt( size ) then
        Print( "    IsAbelian, PClassPGroup, RankPGroup,",
               " FrattinifactorSize and \n     FrattinifactorId. \n");
    else
        Print( "    IsAbelian, IsNilpotentGroup,", 
               " IsSupersolvableGroup, IsSolvableGroup, \n     LGLength,",
               " FrattinifactorSize and FrattinifactorId. \n");
    fi;
end;
SMALL_GROUPS_INFORMATION[ 9 ] := SMALL_GROUPS_INFORMATION[ 8 ];
SMALL_GROUPS_INFORMATION[ 10 ] := SMALL_GROUPS_INFORMATION[ 8 ];

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 11, 17 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 11 ] := function( size, smav, num )
    local i, q;

    q := 2;
    if IsBound( smav.q ) then q := smav.q; fi;

    Print("  There are sorted by normal Sylow subgroups. \n");
    Print( "     1 - ", smav.pos[ 2 ], " are the nilpotent groups.\n" );
    for i in [ 2 .. Length( smav.types ) ] do
        Print( "     ", smav.pos[i] + 1, " - ", smav.pos[i+1] );
        if smav.types[ i ] = "p-autos" then 
            Print( " have a normal Sylow ", q,"-subgroup. \n");
        elif smav.types[ i ] = "none-p-nil" then 
            Print( " have no normal Sylow subgroup. \n");
        elif IsInt( smav.types[ i ] ) then
            Print( " have a normal Sylow ", smav.p, "-subgroup \n");
            Print( "                     with centralizer of index ");
            Print( q^smav.types[i],".\n");
        fi;
    od;
end;
SMALL_GROUPS_INFORMATION[ 17 ] := SMALL_GROUPS_INFORMATION[ 11 ];

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 12 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 12 ] := function( size, smav, num )

    if size = 1152 then
        Print("  There are sorted using Sylow subgroups. \n");
        Print("     1 - 2328 are nilpotent with Sylow 3-subgroup c9.\n" );
        Print("     2329 - 4656 are nilpotent with Sylow 3-subgroup 3^2.\n");
        Print("     4657 - 153312 are non-nilpotent with normal ");
        Print("Sylow 3-subgroup.\n");
        Print("     153313 - 157877 have no normal Sylow 3-subgroup.\n");
        return;
    fi;

    Print("  There are sorted using Hall subgroups. \n");
    Print( "     1 - 2328 are the nilpotent groups.\n" );
    Print( "     2329 - 236344 have a normal Hall (3,5)-subgroup.\n");
    Print( "     236345 - 240416 are solvable without normal Hall",
           " (3,5)-subgroup.\n");
    Print( "     240417 - 241004 are not solvable.\n" );
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 14 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 14 ] := function( size, smav, num )

    Print( "     1 - 10494213 are the nilpotent groups.\n" );
    Print( "     10494214 - 408526597 have a normal Sylow 3-subgroup.\n" );
    Print( "     408526598 - 408544625 have a normal Sylow 2-subgroup.\n" );
    Print( "     408544626 - 408641062 have no normal Sylow subgroup.\n" );
end;

#############################################################################
##
#F SMALL_GROUPS_INFORMATION[ 18 ]( size, smav, num )
##
SMALL_GROUPS_INFORMATION[ 18 ] := function( size, smav, num )

    Print( "     1 is cyclic. \n");
    Print( "     2 - 10 have rank 2 and p-class 3.\n" );
    Print( "     11 - 386 have rank 2 and p-class 4.\n" );
    Print( "     387 - 1698 have rank 2 and p-class 5.\n" );
    Print( "     1699 - 2008 have rank 2 and p-class 6.\n" );
    Print( "     2009 - 2039 have rank 2 and p-class 7.\n" );
    Print( "     2040 - 2044 have rank 2 and p-class 8.\n" );
    Print( "     2045 has rank 3 and p-class 2.\n" );
    Print( "     2046 - 29398 have rank 3 and p-class 3.\n" );
    Print( "     29399 - 56685 have rank 3 and p-class 4.\n" );
    Print( "     56686 - 60615 have rank 3 and p-class 5.\n" );
    Print( "     60616 - 60894 have rank 3 and p-class 6.\n" );
    Print( "     60895 - 60903 have rank 3 and p-class 7.\n" );
    Print( "     60904 - 67612 have rank 4 and ", "p-class 2.\n" );
    Print( "     67613 - 387088 have rank 4 and ", "p-class 3.\n" );
    Print( "     387089 - 419734 have rank 4 and ", "p-class 4.\n" );
    Print( "     419735 - 420500 have rank 4 and ", "p-class 5.\n" );
    Print( "     420501 - 420514 have rank 4 and ", "p-class 6.\n" );
    Print( "     420515 - 6249623 have rank 5 and ", "p-class 2.\n" );
    Print( "     6249624 - 7529606 have rank 5 and ", "p-class 3.\n" );
    Print( "     7529607 - 7532374 have rank 5 and ", "p-class 4.\n" );
    Print( "     7532375 - 7532392 have rank 5 and ", "p-class 5.\n" );
    Print( "     7532393 - 10481221 have rank 6 and ", "p-class 2.\n" );
    Print( "     10481222 - 10493038 have rank 6 and ", "p-class 3.\n" );
    Print( "     10493039 - 10493061 have rank 6 and ", "p-class 4.\n" );
    Print( "     10493062 - 10494173 have rank 7 ", "and p-class 2.\n" );
    Print( "     10494174 - 10494200 have rank 7 ", "and p-class 3.\n" );
    Print( "     10494201 - 10494212 have rank 8 ", "and p-class 2.\n" );
    Print( "     10494213 is elementary abelian.\n");
end;
