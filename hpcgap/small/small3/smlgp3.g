#############################################################################
##
#W  smlgp3.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and construction functions for the groups
##  of size 2^n * p for 3 <= n <= 8 and p an odd prime. 2^n * p has to be
##  greater then 1000.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small3","2.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 3 ]
##
SMALL_AVAILABLE_FUNCS[ 3 ] := function( size )
    local p;

    p := FactorsInt( size );
    if Length( p ) > 9 or p[ Length( p ) - 1 ] <> 2 or size = 512 then
        return fail;
    fi;

    return rec( func := 11,
                lib  := 3 );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 11 ]( size, i, inforec )
##
SMALL_GROUP_FUNCS[ 11 ] := function( size, i, inforec )
    local post, typ, iint, pos, file, sid, codes, sinfo, scode, rank,
          F, gens, rels, n, p, aut, exp, rel, j, k, tmp, c, listInt, 
          S, gS, root;

    listInt := function( int )
        local r, i;

        i := 1;
        r := [ ];
        while int > 0 do
            if int mod 2 = 1 then
                Add( r, i );
            fi;
            i := i + 1;
            int := QuoInt( int, 2 );
        od;
        return r;
    end;
    
    if not IsBound( inforec.r ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 11 ]( size, inforec );
    fi;

    if i > inforec.number then 
        Error( "there are just ", inforec.number, " groups of size ", size );
    fi;

    post := PositionSorted( inforec.pos, i ) - 1;
    typ  := inforec.types[ post ];
    iint := i - inforec.pos[ post ];
    n := inforec.n;
    p := inforec.p;

    if typ = "none-p-nil" then
        if size = 768 then
            # the 4912 none-p-nil groups of size 768 are stored in 4 files
            if not IsBound( SMALL_GROUP_LIB[ 768 ] ) then
                SMALL_GROUP_LIB[ 768 ] := AtomicRecord( rec() );
            fi;
            if not IsBound( SMALL_GROUP_LIB[ 768 ].npnil ) then
                SMALL_GROUP_LIB[ 768 ].npnil := AtomicList([]);
            fi;
            file := QuoInt( iint + 1249, 1250 );
            pos  := iint - ( file - 1 ) * 1250;
            if not IsBound( SMALL_GROUP_LIB[ 768 ].npnil[ file ] ) then
                ReadSmallLib( "sml", 3, 768, [ file ] );
            fi;
            return PcGroupCode( SMALL_GROUP_LIB[768].npnil[file][pos], 768 );
        fi;

        if not IsBound( SMALL_GROUP_LIB[ size ] ) then
            SMALL_GROUP_LIB[ size ] := AtomicRecord( rec() );
            ReadSmallLib( "sml", inforec.lib, size, [ ] );
        fi;

        return PcGroupCode( SMALL_GROUP_LIB[ size ].npnil[ iint ], size );
    fi;

    if typ = "nil" then
        sid := i;

    elif typ = "p-autos" then
        if not IsBound( SMALL_GROUP_LIB[ size ] ) then
            SMALL_GROUP_LIB[ size ] := AtomicRecord( rec() );
        fi;
        if not IsBound( SMALL_GROUP_LIB[ size ].pnil ) then
            ReadSmallLib( "sml", 3, size, [ ] );
        fi;
        sid := SMALL_GROUP_LIB[ size ].pnil.2syl[ iint ];

    else
        if n < 8 then
            if not IsBound( SMALL_GROUP_LIB[ n ] ) then
                ReadSmallLib( "nor", 3, 2, [ n ] );
            fi;
        else 
            if not IsBound( SMALL_GROUP_LIB[ 8 ] ) then
                SMALL_GROUP_LIB[ 8 ] := AtomicList( [ ] );
            fi;
            if not IsBound( SMALL_GROUP_LIB[ 8 ][ typ ] ) then
                c := [ 1, 2, 3, 3, 3, 3, 3, 3 ];
                ReadSmallLib( "nor", 3, 2, [ 8, c[ typ ] ] );
            fi;
        fi;

        if typ = 1 then
            # relative id of the (i-1)*1000-th group
            if n = 7 then
                c := [ 0, 4514, 13729 ];
            elif n = 8 then
                c := [     0,   3465,   8461,  14319,  20208,  25076 , 30536,
                       36802,  48659,  61838,  75468,  84609,  94875, 106350,
                      115482, 124305, 135946, 146216, 158916, 171446, 185870,
                      199622, 211598, 223026, 236294, 250682, 263271, 271778,
                      286530, 307239, 328434, 351278, 379078, 402238, 431410,
                      461222, 485658, 515470, 544547, 568726, 596286, 625438,
                      656042, 686670, 716722, 746080, 771660, 799616, 830416,
                      861172, 891634, 922178, 951604 ];
            else
                c := [ 0 ];
            fi;
        else
            c := [ 0 ];
        fi;
        
        atomic readwrite SMALL_GROUP_LIB[n][typ] do

        if IsRecord( SMALL_GROUP_LIB[ n ][ typ ] ) then
            # lists with many empty entries are compressed
            tmp := [ ];
            i := 0;
            for j in [ 1 .. Length( SMALL_GROUP_LIB[ n ][ typ ].pos ) ] do
                if SMALL_GROUP_LIB[ n ][ typ ].pos[ j ] > 0 then
                    i := i + 1;
                    tmp[ SMALL_GROUP_LIB[ n ][ typ ].pos[ j ] ] := 
                        SMALL_GROUP_LIB[ n ][ typ ].val[ i ];
                else
                    for k in [ SMALL_GROUP_LIB[ n ][ typ ].pos[ j - 1] + 1 ..
                              -SMALL_GROUP_LIB[ n ][ typ ].pos[ j ] ] do
                        i := i + 1;
                        tmp[ k ] := SMALL_GROUP_LIB[ n ][ typ ].val[ i ];
                    od;
                fi;
            od;
            SMALL_GROUP_LIB[ n ][ typ ] := MigrateObj( tmp, SMALL_GROUP_LIB[n][typ] );
        fi;

        sid := PositionSorted( c, iint ) - 2;
        iint := iint - c[ sid + 1 ];
        sid := sid * 1000 + 1;
        while ( not IsBound( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) )
                 or ( IsInt( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) )
                 or ( Length( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) < iint ) do
            if not IsBound( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) then
                # for typ = 1 an empty entry shows that it is the same like
                # the precedessor
                if typ = 1 then
                    SMALL_GROUP_LIB[ n ][ typ ][ sid ] :=
                                      SMALL_GROUP_LIB[ n ][ typ ][ sid - 1 ];
                else
                    sid := sid + 1;
                fi;
            elif IsInt( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) then
                if SMALL_GROUP_LIB[ n ][ typ ][ sid ] < 0 then
                    # the entry is refered to one earlier
                    if IsInt( SMALL_GROUP_LIB[ n ][ typ ][
                                 -SMALL_GROUP_LIB[ n ][ typ ][ sid ] ] ) then
                        SMALL_GROUP_LIB[ n ][ typ ][
                                 -SMALL_GROUP_LIB[ n ][ typ ][ sid ] ] :=
                      MigrateObj( listInt( SMALL_GROUP_LIB[ n ][ typ ][
                                 -SMALL_GROUP_LIB[ n ][ typ ][ sid ] ]), 
                                  SMALL_GROUP_LIB[ n ][ typ ] );
                    fi;
                    SMALL_GROUP_LIB[ n ][ typ ][ sid ] := SMALL_GROUP_LIB[ n]
                              [ typ ][ -SMALL_GROUP_LIB[ n ][ typ ][ sid ] ];
                else
                    # special way of decompession
                    SMALL_GROUP_LIB[ n ][ typ ][ sid ] := 
                        MigrateObj( listInt( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ), 
                                             SMALL_GROUP_LIB[ n ][ typ ] );
                fi;
            else
                # simple case, just count group ids
                iint := iint - Length( SMALL_GROUP_LIB[ n ][ typ ][ sid ] );
                sid := sid + 1;
            fi;
        od;
        
        od; # atomic SMALL_GROUP_LIB[n][typ]
    fi;

    if n = 3 then 
        codes := [ 323, 33, 36, 2343, 0 ];
        scode := codes[ sid ];
    else
        sinfo := SMALL_AVAILABLE( 2 ^ n );
        scode := CODE_SMALL_GROUP_FUNCS[ sinfo.func ]( 2^n, sid, sinfo );
    fi;

    F := FreeGroup( n + 1 );
    gens := GeneratorsOfGroup( F );

    if typ = "nil" then
        rels := RelatorsCode( scode, 2^n, gens{[ 1 .. n ]} );
        Add( rels, gens[ n + 1 ]^ p );

    elif typ = "p-autos" then
        rels := RelatorsCode( scode, 2^n, gens{[ 2 .. n+1 ]} );
        Add( rels, gens[ 1 ] ^ p );
        aut := CoefficientsMultiadic( List( [ 1..n ], x-> 2^n+1 ), 
               SMALL_GROUP_LIB[ size ].pnil.oper[ iint ] ) - 1;
        for j in [ 1 .. n ] do
            exp := CoefficientsMultiadic( List( [ 1..n ], x->2 ), aut[ j ] );
            rel := gens[ 1 ] ^ -1 * gens[ j + 1 ] ^ -1 * gens [ 1 ];
            for k in [ 1 .. n ] do
                if exp[ k ] = 1 then
                    rel := rel * gens[ k + 1 ];
                fi;
            od;
            Add( rels, rel );
        od;

    else
        # normal p-sylowsubgroup
        rels := RelatorsCode( scode, 2^n, gens{[ 1 .. n ]} );
        Add( rels, gens[ n + 1 ] ^ p );
        c := [ ,,
               [ 1, 4, 5 ],
               [ 1, 9, 13, 14 ],
               [ 1, 20, 44, 50, 51 ],
               [ 1, 54, 191, 259, 266, 267 ],
               [ 1, 163, 996, 2149, 2318, 2327, 2328 ],
               [ 1, 541, 6731, 26972, 55625, 56081, 56091, 56092 ] ];
        rank := PositionSorted( c[ n ], sid );

        if typ = 1 then
            atomic readonly SMALL_GROUP_LIB[n][typ] do
                aut := CoefficientsMultiadic( List( [1..rank], x->2 ),
                                    SMALL_GROUP_LIB[ n ][ typ ][ sid ][ iint ] );
            od;                        
            for i in [ 1 .. rank ] do
                if aut[ i ] = 1 then 
                     Add( rels, gens[ n+1] ^ gens[i] * gens[ n+1] );
                fi;
            od;
        else
            root := PrimitiveRootMod( p ) ^ ((p-1)/2^typ) mod p;

            atomic readonly SMALL_GROUP_LIB[n][typ] do

            if SMALL_GROUP_LIB[ n ][ typ ][ sid ][ iint ] < 0 then
                root := root ^ ( -SMALL_GROUP_LIB[n][typ][sid][iint] ) mod p;
                while SMALL_GROUP_LIB[ n ][ typ ][ sid ][ iint ] < 0 do
                    iint := iint - 1;
                od;
            fi;
            S := PcGroupCode( scode, 2^n );
            gS := GeneratorsOfGroup( S );
            aut := CoefficientsMultiadic( List( [1..rank], x->2^typ ),
                                SMALL_GROUP_LIB[ n ][ typ ][ sid ][ iint ] );
                                
            od; # atomic readonly SMALL_GROUP_LIB[n][typ]
            
            for i in [ 1 .. rank ] do
                Add( rels, gens[ n + 1 ] ^ gens[ i ] /
                           gens[ n + 1 ] ^ ( root ^ aut[ i ] mod p ) );
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
                        ( root ^ ( aut[ j ] * Order( gS[j] ) / c ) mod p ) );
                fi;
            od;
        fi;
    fi;

    return PcGroupFpGroup( F / rels );
end;

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 11 ]( size, inforec )
##
NUMBER_SMALL_GROUPS_FUNCS[ 11 ] := function( size, inforec )
    local p, n, c, num, r, pos, i;

    if inforec.func <> 11 then
        Error( "NUMBER_SMALL_GROUPS_FUNCS[ 11 ]: wrong call" );
    fi;

    p := FactorsInt( size );
    n := Length( p ) - 1;
    p := p[ Length( p ) ];
    r := Minimum( n, Length( Filtered( FactorsInt( p - 1 ), x-> x = 2 ) ) );
    inforec.p := p;
    inforec.n := n;
    inforec.r := r;
    
    inforec.types := [ "nil" ];
    c := [ ,, 5, 14, 51, 267, 2328, 56092 ];
    num           := c [ n ];
    inforec.pos   := [ 0, num ];
    c := [ [ ,, 7, 28, 144, 1120, 16996, 1027380 ], 
           [ ,, 2,  9,  40,  243,  2183,   32836 ],
           [ ,, 1,  2,   9,   42,   259,    2339 ],
           [ ,,  ,  1,   2,    9,    42,     263 ],
           [ ,,  ,   ,   1,    2,     9,      42 ],
           [ ,,  ,   ,    ,    1,     2,       9 ],
           [ ,,  ,   ,    ,     ,     1,       2 ],
           [ ,,  ,   ,    ,     ,      ,       1 ] ];
    for i in [ 1 .. Minimum( r, 8 ) ] do
        Add( inforec. types, i );
        num := num + c[ i ][ n ];
        Add( inforec.pos, num );
    od;
    c   := [ 3, 5, 7, 17, 31, 127 ];
    pos := Position( c, p );
    if IsInt( pos ) then
        c := [ [ ,, 2, 6, 19, 70, 309, 1851 ], 
               [ ,,  , 1,  2,  5,  13,   49 ],
               [ ,, 1, 1,  2,  9,  24,   77 ],
               [ ,,  ,  ,   ,   ,    ,    1 ],
               [ ,,  ,  ,  1,  1,   2,    5 ],
               [ ,,  ,  ,   ,   ,   1,    1 ] ];
        if IsBound( c[ pos ][ n ] ) then
            Add( inforec.types, "p-autos" );
            num := num + c[ pos ][ n ];
            Add( inforec.pos, num );
        fi;
        if pos <= 3 then
            c := [ [ ,, 1, 4, 17, 86, 536, 4912 ], 
                   [ ,,  ,  ,  1,  5,  21,  104 ],
                   [ ,,  ,  ,   ,   ,   1,    4 ] ];
            if IsBound( c[ pos ][ n ] ) then
                Add( inforec.types, "none-p-nil" );
                num := num + c[ pos ][ n ];
                Add( inforec.pos, num );
            fi;
        fi;
    fi;
    inforec.number := inforec.pos[ Length( inforec.pos ) ];
    return inforec;
end;

#############################################################################
##                          
#F SELECT_SMALL_GROUPS_FUNCS[ 11 ]( funcs, vals, inforec, all, id, idList )
##                  
SELECT_SMALL_GROUPS_FUNCS[ 11 ] := function( size, funcs, vals, inforec, all,
                                             id, idList)
    local result, i, g, ok, j, range;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ inforec.func ]( size, inforec);
    fi;

    if idList = fail then
        Info( InfoWarning, 2, "`SelectSmallGroups' checks ", inforec.number,
                            " grps of size ", size, " with trivial methods");
    fi;

    result := [ ];
    range := [ 1 .. inforec.number ];
    if idList <> fail then
        range := idList;
    fi;
    for i in range do                         
        g := SMALL_GROUP_FUNCS[ inforec.func ]( size, i, inforec );
        SetIdGroup( g, [ size, i ] );
        ok := true;
        for j in [ 1 .. Length( funcs ) ] do
            ok := ok and funcs[ j ]( g ) in vals[ j ];
        od;
        if all and id and ok then
            Add( result, [ size, i ] );
        elif all and ok then
            Add( result, g );
        elif ok then          
            return g;                                           
        fi;
    od;                                                                     

    if all then                                                            
        return result;
    else                                                                  
        return fail;                                          
    fi;                                                       
end;      
