#############################################################################
##
#W  smlgp4.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and constrution functions for the groups
##  of size 2401, 3125 and
##  those of size p^n * q with
##  p in { 3, 5, 7 } and q a prime <> p,
##  3 <= n <= 6 for p = 3,
##  3 <= n <= 5 for p = 5,
##  3 <= n <= 4 for p = 7,
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small4","1.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 4 ]
##
SMALL_AVAILABLE_FUNCS[ 4 ] := function( size )
    local p, n, q, r;

    if size in [ 2401, 3125 ] then
        return rec( func := 8,
                    lib := 4 );
    fi;

    q := FactorsInt( size );
    n := Length( q ) - 1;
    if Length( q ) < 4 or Length( Set( q ) ) > 2 or 
       ( q[ 1 ] = q[ 2 ] and q[ n ] = q[ n + 1 ] ) then
        return fail;
    fi;
    if q[ 1 ] = q[ 2 ] then
        p := q[ n + 1 ];
    else
        p := q[ 1 ];
    fi;
    q := q[ 2 ];
    if q = 2 or q > 7 or
       ( q = 3 and n > 6 ) or ( q = 5 and n > 5 ) or ( q = 7 and n > 4 ) then
        return fail;
    fi;
    r := Minimum( n, Length( Filtered( FactorsInt( p - 1 ), x -> x = q ) ) );
    return rec( func := 17,
                lib  := 4,
                n    := n,
                p    := p,
                q    := q,
                r    := r );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 17 ]( size, i, inforec )
##
SMALL_GROUP_FUNCS[ 17 ] := function( size, i, inforec )
    local post, typ, iint, pos, file, sid, codes, sinfo, scode, rank,
          F, gens, rels, aut, exp, rel, j, k, tmp, c, n,
          S, gS, root, nn;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 17 ]( size, inforec );
    fi;

    if i > inforec.number then 
        Error( "there are just ", inforec.number, " groups of size ", size );
    fi;

    post := PositionSorted( inforec.pos, i ) - 1;
    typ  := inforec.types[ post ];
    iint := i - inforec.pos[ post ];
    n    := inforec.n;

    if typ = "none-p-nil" then
        if not IsBound( SMALL_GROUP_LIB[ size ] ) then
            SMALL_GROUP_LIB[ size ] := AtomicRecord( rec( ) );
            ReadSmallLib( "sml", inforec.lib, size, [ ] );
        fi;

        return PcGroupCode( SMALL_GROUP_LIB[ size ].npnil[ iint ], size );
    fi;

    if typ = "nil" then
        sid := iint;

    elif typ = "p-autos" then
        if not IsBound( SMALL_GROUP_LIB[ size ] ) then
            SMALL_GROUP_LIB[ size ] := AtomicRecord( rec() );
            ReadSmallLib( "sml", inforec.lib, size, [ ] );
        fi;
        sid := SMALL_GROUP_LIB[ size ].pnil.syl[ iint ];

    else
        nn := inforec.q ^ 2 * Primes[ n ];
        if not IsBound( SMALL_GROUP_LIB[ nn ] ) then
            ReadSmallLib( "nor", inforec.lib, inforec.q, [ n ] );
        fi;
        
        atomic readwrite SMALL_GROUP_LIB[nn][typ] do
        
        if IsRecord( SMALL_GROUP_LIB[ nn ][ typ ] ) then
            # lists with many empty entries are compressed
            tmp := [ ];
            i := 0;
            for j in [ 1 .. Length( SMALL_GROUP_LIB[ nn ][ typ ].pos ) ] do
                if SMALL_GROUP_LIB[ nn ][ typ ].pos[ j ] > 0 then
                    i := i + 1;
                    tmp[ SMALL_GROUP_LIB[ nn ][ typ ].pos[ j ] ] := 
                        SMALL_GROUP_LIB[ nn ][ typ ].val[ i ];
                else
                    for k in [ SMALL_GROUP_LIB[ nn ][ typ ].pos[ j - 1] + 1..
                              -SMALL_GROUP_LIB[ nn ][ typ ].pos[ j ] ] do
                        i := i + 1;
                        tmp[ k ] := SMALL_GROUP_LIB[ nn ][ typ ].val[ i ];
                    od;
                fi;
            od;
            SMALL_GROUP_LIB[ nn ][ typ ] := MigrateObj( tmp, SMALL_GROUP_LIB[nn][typ] );
        fi;

        sid := 1;
        while ( not IsBound( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) )
           or ( IsInt( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) )
           or ( Length( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) < iint ) do
            if not IsBound( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) then
                sid := sid + 1;
            elif IsInt( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) then
                # the entry is refered to one earlier
                SMALL_GROUP_LIB[ nn ][ typ ][ sid ] := SMALL_GROUP_LIB[ nn ]
                          [ typ ][ -SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ];
            else
                # simple case, just count group ids
                iint := iint - Length( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] );
                sid := sid + 1;
            fi;
        od;

        od; # atomic SMALL_GROUP_LIB[nn][typ]
    fi;

    if n = 3 then 
        scode := CodePcGroup( SmallGroup( inforec.q ^ n, sid ) );
    else
        sinfo := SMALL_AVAILABLE( inforec.q ^ n );
        scode := CODE_SMALL_GROUP_FUNCS[sinfo.func]( inforec.q^n,sid,sinfo );
    fi;

    F := FreeGroup( n + 1 );
    gens := GeneratorsOfGroup( F );

    if typ = "nil" then
        rels := RelatorsCode( scode, inforec.q^n, gens{[ 1 .. n ]} );
        Add( rels, gens[ n + 1 ] ^ inforec.p );

    elif typ = "p-autos" then
        rels := RelatorsCode( scode, inforec.q^n, gens{[ 2 .. n+1 ]} );
        Add( rels, gens[ 1 ] ^ inforec.p );
        aut := CoefficientsMultiadic( List( [ 1..n ], x-> inforec.q^n+1 ), 
               SMALL_GROUP_LIB[ size ].pnil.oper[ iint ] ) - 1;
        for j in [ 1 .. n ] do
            exp := CoefficientsMultiadic( List( [ 1..n ], x -> inforec.q ),
                                                               aut[ j ] );
            rel := gens[ 1 ] ^ -1 * gens[ j + 1 ] ^ -1 * gens [ 1 ];
            for k in [ 1 .. n ] do
                if exp[ k ] > 0 then
                    rel := rel * gens[ k + 1 ] ^ exp[ k ];
                fi;
            od;
            Add( rels, rel );
        od;

    else
        # normal p-sylowsubgroup
        rels := RelatorsCode( scode, inforec.q^n, gens{[ 1 .. n ]} );
        Add( rels, gens[ n + 1 ] ^ inforec.p );
        if inforec.q = 3 then
            c := [ ,,
                   [ 1, 4, 5 ],
                   [ 1, 10, 14, 15 ],
                   [ 1, 30, 60, 66, 67 ],
                   [ 1, 101, 414, 496, 503, 504 ] ];
        else
            c := [ ,,
                   [ 1, 4, 5 ],
                   [ 1, 10, 14, 15 ],
                   [ 1, 38, 70, 76, 77 ] ];
        fi;
        rank := PositionSorted( c[ n ], sid );
        
        root := PrimitiveRootMod( inforec.p ) ^
                        ( (inforec.p - 1 ) / inforec.q ^ typ ) mod inforec.p;

        atomic readwrite SMALL_GROUP_LIB[nn][typ] do

        if SMALL_GROUP_LIB[ nn ][ typ ][ sid ][ iint ] < 0 then
            root := root ^ ( -SMALL_GROUP_LIB[ nn ][ typ ][ sid ][ iint ] )
                                                               mod inforec.p;
            while SMALL_GROUP_LIB[ nn ][ typ ][ sid ][ iint ] < 0 do
                iint := iint - 1;
            od;
        fi;
        S := PcGroupCode( scode, inforec.q ^ n );
        gS := GeneratorsOfGroup( S );
        aut := CoefficientsMultiadic( List( [1..rank], x->inforec.q ^ typ ),
                            SMALL_GROUP_LIB[ nn ][ typ ][ sid ][ iint ] );
        
        od; # atomic SMALL_GROUP_LIB[nn][typ]
        
        for i in [ 1 .. rank ] do
            Add( rels, gens[ n + 1 ] ^ gens[ i ] /
                       gens[ n + 1 ] ^ ( root ^ aut[ i ] mod inforec.p ) );
        od;
        
       
        for i in [ rank + 1 .. n ] do
            if not gS[ i ] in DerivedSubgroup( S ) then
                j := 1;
                c := Order( gS[ i ] );
                while ( Order( gS[ j ] ) <= c ) or
                      ( gS[j] ^ ( Order(gS[j]) / c ) <> gS[i] ) do
                    j := j + 1;
                od;
                Add( rels, gens[ n + 1 ] ^ gens[ i ] / gens[ n + 1 ] ^
                    ( root ^ ( aut[j] * Order(gS[j]) / c ) mod inforec.p ) );
            fi;
        od;
    fi;

    return PcGroupFpGroup( F / rels );
end;

#############################################################################
##
#F SELECT_SMALL_GROUPS_FUNCS[ 17 ]
##                                                                              
SELECT_SMALL_GROUPS_FUNCS[ 17 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 17 ]( size, inforec )
##
NUMBER_SMALL_GROUPS_FUNCS[ 17 ] := function( size, inforec )
    local p, n, c, num, r, pos, i;

    if inforec.func <> 17 then
        Error( "NUMBER_SMALL_GROUPS_FUNCS[ 17 ]: wrong call" );
    fi;

    inforec.types := [ "nil" ];
    c := [ ,, 5, 15, 67, 504 ];
    num           := c[ inforec.n ];
    if inforec.q = 5 and inforec.n = 5 then
        num := 77;
    fi;
    inforec.pos   := [ 0, num ];

    if inforec.q = 3 then
        c := [ [ ,, 8, 34, 242, 3529 ],
               [ ,, 2, 11,  52,  395 ],
               [ ,, 1,  2,  11,   61 ],
               [ ,,  ,  1,   2,   11 ],
               [ ,,  ,   ,   1,    2 ],
               [ ,,  ,   ,   ,     1 ] ];
    elif inforec.q = 5 then
        c := [ [ ,, 10, 44, 411 ],
               [ ,,  2, 15,  84 ],
               [ ,,  1,  2,  15 ],
               [ ,,   ,  1,   2 ],
               [ ,,   ,   ,   1 ] ];
    elif inforec.q = 7 then
        c := [ [ ,, 12, 54 ],
               [ ,,  2, 19 ],
               [ ,,  1,  2 ],
               [ ,,   ,  1 ] ];
    fi;
    for i in [ 1 .. Minimum( inforec.r, Length( c ) ) ] do
        Add( inforec.types, i );
        num := num + c[ i ][ inforec.n ];
        Add( inforec.pos, num );
    od;

    if inforec.q = 3 then
        c := [ 2, 5, 7, 11, 13 ];
    elif inforec.q = 5 then
        c := [ 2, 3, 11, 13, 31, 71 ];
    elif inforec.q = 7 then
        c := [ 2, 3, 5, 19 ];
    fi;
    pos := Position( c, inforec.p );
    if IsInt( pos ) then
        if inforec.q = 3 then
            c := [ [ ,, 10, 40, 194, 1294 ],
                   [ ,,   ,  1,   2,    5 ],
                   [ ,,   ,   ,    ,    1 ],
                   [ ,,   ,   ,   1,    1 ],
                   [ ,,  1,  1,   2,   10 ] ];
        elif inforec.q = 5 then
            c := [ [ ,, 10, 40, 205 ],
                   [ ,,  2,  6,  26 ],
                   [ ,,   ,   ,   1 ],
                   [ ,,   ,  1,   2 ],
                   [ ,,  1,  1,   2 ],
                   [ ,,   ,   ,   1 ] ];
        elif inforec.q = 7 then
            c := [ [ ,, 10, 40 ],
                   [ ,, 14, 54 ],
                   [ ,,   ,  1 ],
                   [ ,,  1,  1 ] ];
        fi;
        if IsBound( c[ pos ][ inforec.n ] ) then
            Add( inforec.types, "p-autos" );
            num := num + c[ pos ][ inforec.n ];
            Add( inforec.pos, num );
        fi;
    fi;

    if inforec.p = 13 and inforec.q = 3 and inforec.n >= 4 then
        c := [ ,,, 1, 2, 8 ];
        num := num + c[ inforec.n ];
        Add( inforec.pos, num );
        Add( inforec.types, "none-p-nil" );
    fi;

    inforec.number := inforec.pos[ Length( inforec.pos ) ];
    return inforec;
end;

