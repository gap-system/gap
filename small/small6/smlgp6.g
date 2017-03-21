#############################################################################
##
#W  smlgp6.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and construction functions for the groups
##  of size 1152 and 1920.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small6","1.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 6 ]
##
SMALL_AVAILABLE_FUNCS[ 6 ] := function( size )

    if size = 1152 then
        return rec( func := 12, lib := 6, number := 157877 );
    elif size = 1920 then
        return rec( func := 12, lib := 6, number := 241004 );
    fi;

    return fail;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 12 ]( size, i, inforec )
##
SMALL_GROUP_FUNCS[ 12 ] := function( size, i, inforec )
    local pos, sid;
    
    if i > inforec.number then 
        Error( "there are just ", inforec.number, " groups of size ", size );
    fi;

    if size = 1152 then
        if i <= 2328 then
            return SMALL_GROUP_FUNCS[ 13 ]( 32769, 1152, i );
        elif i <= 4656 then
            return SMALL_GROUP_FUNCS[ 13 ]( 0, 1152, i - 2328 );
        else
             i := i - 4656;
        fi;
    elif size = 1920 then
        if i <= 2328 then
            return SMALL_GROUP_FUNCS[ 13 ]( 0, 1920, i );
        else
             i := i - 2328;
        fi;
    else
        Error( "SMALL_GROUP_FUNCS[ 12 ]: wrong call" );
    fi;

    if not IsBound( SMALL_GROUP_LIB[ size ] ) then
        SMALL_GROUP_LIB[ size ] := rec( 2nil := rec(),
                                        n2nil := [ ] );
    fi;

    if ( size = 1152 and i <= 148656 ) or
       ( size = 1920 and i <= 234016 ) then
        if not IsBound( SMALL_GROUP_LIB[ size ].2nil.codes ) then
            ReadSmallLib( "sml", 6, size, [ 1 ] );
        fi;

        if size = 1152 then
            pos := [ 0, 3368,  10292,  16477,  23956,  30069,  45539,
                       65364,  86448,  97501, 113864, 132214 ];
        else
            pos := [ 0, 4602,  14850,  23766,  34334,  42794,  67753,
                       99802, 134526, 153060, 177816, 206598 ];
        fi;
        sid := PositionSorted( pos, i );
        i := i - pos[ sid - 1 ];
        sid := ( sid - 2 ) * 200 + 1;
        while Length( SMALL_GROUP_LIB[ size ].2nil.codelist[
                        SMALL_GROUP_LIB[ size ].2nil.styps[ sid ] ] ) < i do
            i := i - Length( SMALL_GROUP_LIB[ size ].2nil.codelist[
                               SMALL_GROUP_LIB[ size ].2nil.styps[ sid ] ] );
            sid := sid + 1;
        od;

        return SMALL_GROUP_FUNCS[ 13 ]( 
                 SMALL_GROUP_LIB[ size ].2nil.codes[
                   SMALL_GROUP_LIB[ size ].2nil.codelist[                    
                     SMALL_GROUP_LIB[ size ].2nil.styps[ sid ] ][ i ] ],
                 size, sid );
    fi;

    if size = 1152 then
        i := i - 148656;
    else
        i := i - 234016;
    fi;
    pos := QuoInt( i + 2499, 2500 );
    i := i - ( pos - 1 ) * 2500;

    if not IsBound( SMALL_GROUP_LIB[ size ].n2nil[ pos ] ) then
        ReadSmallLib( "sml", 6, size, [ 2, pos ] );
    fi;

    if IsList( SMALL_GROUP_LIB[ size ].n2nil[ pos ][ i ] ) then
        return Group( SMALL_GROUP_LIB[ size ].n2nil[ pos ][ i ] );
    fi;
    return PcGroupCode( SMALL_GROUP_LIB[ size ].n2nil[ pos ][ i ], size );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 13 ]( code, size, sid )
##
## similar function to 'RelatorsCode' specialized for groups of size 1152
## and 1920 with normal (3,5)-Hall-subgroup, for which the relators of the
## 2-sylow-subgroup are not stored with the group.
##
SMALL_GROUP_FUNCS[ 13 ] := function( code, size, sid )
    local F, gens, i, j, z, z2, rels, trels, rr, g, t, n, uc, indices, ll;

    # create free group
    F := FreeGroup( 9 );
    gens := GeneratorsOfGroup( F );

    # preparations
    size := size / 128;
    indices := FactorsInt( size );
    n    := ShallowCopy( code );

    # initialize relators
    rels := [];
    rr   := [];

    for i in [1..2] do
        rels[i]:=gens[i+7]^indices[i];
    od;

    if size = 9 then
        ll := 15;
    else
        ll := 14;
    fi;
    uc := Reversed( CoefficientsMultiadic( List( [ 1 .. ll ], x -> 2 ),
                                           n mod ( 2 ^ ll ) ) );
    n := QuoInt( n,2^ll );

    for i in [1..Sum(uc)] do
        t := CoefficientsMultiadic( indices, n mod size );
        g := gens[1]^0;
        for j in [1..2] do
            if t[j] > 0 then
                g := g * gens[j+7]^t[j];
            fi;
        od;
        Add( rr, g );
        n := QuoInt( n, size );
    od;

    z := 1;
    z2 := 0;
    if size = 9 then
        if uc[1] = 1 then
            rels[1] := rels[1]/rr[1];
            z := 2;
        fi;
        z2 := 1;
    fi;
    for i in [1..7] do
        for j in [8..9] do
            z2 := z2+1;
            if uc[z2] = 1 then
                Add( rels, Comm( gens[ j ], gens[ i ] ) / rr[ z ] );
                z := z+1;
            fi;
        od;
    od;

    return PcGroupFpGroup( F / Concatenation(
        RelatorsCode( CODE_SMALL_GROUP_FUNCS[ 8 ]( 128, sid,
                      rec( func := 8, lib := 2 ) ), 128, gens{[ 1..7 ]} ),
        rels ) );
end;

#############################################################################
##                          
#F SELECT_SMALL_GROUPS_FUNCS[ 12 ]( funcs, vals, inforec, all, id )
##                  
SELECT_SMALL_GROUPS_FUNCS[ 12 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];
