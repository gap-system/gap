#############################################################################
##
#W  smlgp7.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and constrution functions for the groups
##  of size 512.
##
Revision.smlgp7_g :=
    "@(#)$Id$";

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small7","1.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 7 ]
##
SMALL_AVAILABLE_FUNCS[ 7 ] := function( size )

    if size = 512 then 
        return rec( func := 18, lib := 7, number := 10494213 );
    fi;

    return fail;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 18 ]( size, i, inforec )
##
SMALL_GROUP_FUNCS[ 18 ] := function( size, i, inforec )
    local p1, p2, p3, L, STR, bits, obits, tbits, j, headL, headP, pos, nr,
    n, k, l, F, rels, gens, rhs, c, body;
    
    if i > 10494213 then 
        Error( "there are just 10494213 groups of size 512" );
    fi;

    L := "%&()*+,-./0123456789:<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^abcdefghijklm\
nopqrstuvwxyz{}";

    p1 := 1 + ( ( i - 1 ) mod 1000 );
    p2 := 1 + ( QuoInt( i - 1, 1000 ) mod 100 );
    p3 := QuoInt( i + 99999, 100000 );

    if not IsBound( SMALL_GROUP_LIB[ 512 ] ) then
        ReadSmallLib( "sml", 7, 512, [ 106 ] );
    fi;
    if not IsBound( SMALL_GROUP_LIB[ 512 ][ p3 ] ) then
        ReadSmallLib( "sml", 7, 512, [ p3 ] );
    fi;
    STR := SMALL_GROUP_LIB[ 512 ][ p3 ][ p2 ];
    bits := Concatenation( List( STR{[ 1 .. 30 ]}, x ->
              CoefficientsMultiadic( [ 3,3,3,3 ], Position( L, x ) - 1 ) ) );
    obits := Filtered( [ 1 .. 120 ], x -> bits[ x ] = 2 );
    headL := Int( ( Length( obits ) + 3 ) / 4 );
    headP := fail;
    pos := 30;
    nr := 0;
    while nr < p1 do
        nr := nr + 1;
        pos := pos + 1;
        c := STR[ pos ];
        if STR[ pos ] = ' ' then
           headP := pos + 1;
           pos := pos + headL;
           nr := nr - 1;
        elif STR[ pos ] = '!' then
           headP := pos + 1;
           body := SMALL_GROUP_LIB[ 512 ][ 106 ][
                      81 * Position( L, STR[ pos + headL + 1 ] ) +
                      Position( L, STR[ pos + headL + 2 ] ) - 82 ];
           if p1 >= nr + Length( body ) then
              nr := nr + Length( body ) - 1;
              pos := pos + headL + 2;
           else
              c := body[ p1 - nr + 1 ];
              nr := 1001;
           fi;
        fi;
    od;
    tbits := Concatenation( List( STR{[ headP .. headP + headL - 1 ]}, x -> 
              CoefficientsMultiadic( [ 3,3,3,3 ], Position( L, x ) - 1 ) ) );
    for j in  [ 1 .. Length( obits ) ] do
       bits[ obits[ j ] ] := tbits[ j ];
    od;
    obits := Filtered( [ 1 .. 120 ], x -> bits[ x ] = 2 );
    tbits := CoefficientsMultiadic( [2,2,2,2,2,2], Position( L, c ) - 1 );
    for j in  [ 1 .. Length( obits ) ] do
       bits[ obits[ j ] ] := tbits[ j ];
    od;

    j := 0;
    F := FreeGroup( 9 );
    gens := GeneratorsOfGroup( F );
    rhs := [];
    for n in [ 1 .. 9 ] do
        rhs[ n ] := [];
        for k in [ 1 .. n-1 ] do
            rhs[ n ][ k ] := gens[ 1 ] ^ 0;
            for l in [ k .. n-1 ] do
                j := j + 1;
                rhs[ l ][ k ] := rhs[ l ][ k ] * gens[ n ] ^ bits[ j ];
            od;
        od;
        rhs[ n ][ n ] := gens[ 1 ] ^ 0;
    od;

    rels := [];
    for n in [ 1 .. 9 ] do
        Add( rels, gens[ n ] ^ 2 / rhs[ n ][ n ] );
        for k in [ 1 .. n-1 ] do
            Add( rels, Comm( gens[ n ], gens[ k ] ) / rhs[ n ][ k ] );
        od;
    od;

    return PcGroupFpGroup( F / rels );
end;

#############################################################################
##                          
#F SELECT_SMALL_GROUPS_FUNCS[ 18 ]( funcs, vals, inforec, all, id )
##                  
SELECT_SMALL_GROUPS_FUNCS[ 18 ] := function( arg )

   Error( "nothing implemented for selection of groups of size 512" );
end;
