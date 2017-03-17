#############################################################################
##
#W  idgrp3.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the identification routines for groups of order
##  2^n * p with 3 <= n <= 8 and p an odd prime
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("id3","2.1");

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 3 ]
##
ID_AVAILABLE_FUNCS[ 3 ] := function( size )
    local p;

    p := FactorsInt( size );
    if Length( p ) > 9 or p[ Length( p ) - 1 ] <> 2 or size = 512 then
        return fail;
    fi;

    return rec( func := 13,
                lib  := 3,
                n    := Length( p ) - 1,
                p    := p[ Length( p ) ] );
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 13 ]( G, inforec )
##
## standard lookup in the case 2^n * p
##
ID_GROUP_FUNCS[ 13 ] := function( G, inforec )
    local size, sid, num, pos, cid, n, typ, c, sp, i, j, k, tmp, listInt,
          rank, id, g, gens, fgens, sgens, inv, coeff, p, root1, root2,
          pcgs, pelm, rels, C;

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

    if IsNilpotent( G ) then 
        return IdGroup( SylowSubgroup( G, 2 ) )[ 2 ];
    fi;

    size := Size( G );

    if ( not IsNormal( G, SylowSubgroup( G, 2 ) ) ) and
       ( not IsNormal( G, SylowSubgroup( G, inforec.p ) ) ) then
        if size = 768 and not IsBound( ID_GROUP_TREE.next[ 768 ] ) then
            ID_GROUP_TREE.next[ 768 ] := rec( fp:= [ 1, 2 ], next:= [ ] );
        fi;
        return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ size, 2 ] );
    fi;

    sid := IdGroup( SylowSubgroup( G, 2 ) )[ 2 ];
    num := NUMBER_SMALL_GROUPS_FUNCS[ 11 ]( size, SMALL_AVAILABLE( size ) );

    if IsNormal( G, SylowSubgroup( G, 2 ) ) then
        num := num.pos[ Position( num.types, "p-autos" ) ];
        if not IsBound( SMALL_GROUP_LIB[ size ] ) then
            SMALL_GROUP_LIB[ size ] := rec();
        fi;
        if not IsBound( SMALL_GROUP_LIB[ size ].pnil ) then
            ReadSmallLib( "sml", 3, size, [ ] );
        fi;
        pos := Position( SMALL_GROUP_LIB[ size ].pnil.2syl, sid );
        if ( not IsBound( SMALL_GROUP_LIB[ size ].pnil.2syl[ pos+1 ] ) )
           or ( SMALL_GROUP_LIB[ size ].pnil.2syl[ pos + 1 ] <> sid ) then
            return num + pos;
        fi;
        if size = 768 and not IsBound( ID_GROUP_TREE.next[ 768 ] ) then
            ID_GROUP_TREE.next[ 768 ] := rec( fp:= [ 1, 2 ], next:= [ ] );
        fi;
        return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ size, 1, sid ] );
    fi;

    # p-sylow-subgroup is normal
    cid := IdGroup( Centralizer( SylowSubgroup( G, 2 ),
                                 SylowSubgroup( G, inforec.p ) ) );
    n   := inforec.n;
    typ := Log( 2 ^ n / cid[ 1 ], 2 );
    cid := cid[ 2 ];
    num := num.pos[ Position( num.types, typ ) ];

    if typ = 1 and n in [ 7, 8 ] then
        if n = 7 then
            c := [ 0, 4514, 13729 ];
        else
            c := [     0,   3465,   8461,  14319,  20208,  25076 , 30536,
                   36802,  48659,  61838,  75468,  84609,  94875, 106350,
                  115482, 124305, 135946, 146216, 158916, 171446, 185870,
                  199622, 211598, 223026, 236294, 250682, 263271, 271778,
                  286530, 307239, 328434, 351278, 379078, 402238, 431410,
                  461222, 485658, 515470, 544547, 568726, 596286, 625438,
                  656042, 686670, 716722, 746080, 771660, 799616, 830416,
                  861172, 891634, 922178, 951604, 976054, 988277, 1006917, 
                  1026007 ];
        fi;
        sp := QuoInt( sid - 1, 1000 ) * 1000 + 1;
        num := num + c[ QuoInt( sid + 999, 1000 ) ];
    else
        sp := 1;
    fi;

    if n < 8 then
        if not IsBound( SMALL_GROUP_LIB[ n ] ) then
            ReadSmallLib( "nor", 3, 2, [ n ] );
        fi;
    else  
        if not IsBound( SMALL_GROUP_LIB[ 8 ] ) then
            SMALL_GROUP_LIB[ 8 ] := [ ];
        fi;
        if not IsBound( SMALL_GROUP_LIB[ 8 ][ typ ] ) then
            c := [ 1, 2, 3, 3, 3, 3, 3, 3 ];
            ReadSmallLib( "nor", 3, 2, [ 8, c[ typ ] ] );
        fi;
    fi;

    if IsRecord( SMALL_GROUP_LIB[ n ][ typ ] ) then
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
        SMALL_GROUP_LIB[ n ][ typ ] := tmp;
    fi;

    for i in [ sp .. sid ] do
        if typ = 1 and ( not IsBound( SMALL_GROUP_LIB[n][typ][ i ] ) ) then
            SMALL_GROUP_LIB[n][typ][ i ] := SMALL_GROUP_LIB[n][typ][ i-1 ];
        fi;
        if IsBound( SMALL_GROUP_LIB[ n ][ typ ][ i ] ) then
            if IsInt( SMALL_GROUP_LIB[ n ][ typ ][ i ] ) then
                if SMALL_GROUP_LIB[ n ][ typ ][ i ] < 0 then
                    if IsInt( SMALL_GROUP_LIB[ n ][ typ ][
                                   -SMALL_GROUP_LIB[ n ][ typ ][ i ] ] ) then
                        SMALL_GROUP_LIB[ n ][ typ ][
                                     -SMALL_GROUP_LIB[ n ][ typ ][ i ] ] :=
                            listInt( SMALL_GROUP_LIB[ n ][ typ ][
                                     -SMALL_GROUP_LIB[ n ][ typ ][ i ] ]);
                    fi;
                    SMALL_GROUP_LIB[ n ][ typ ][ i ] := SMALL_GROUP_LIB[ n ]
                                [ typ ][ -SMALL_GROUP_LIB[ n ][ typ ][ i ] ];
                else
                    SMALL_GROUP_LIB[ n ][ typ ][ i ] := listInt(
                                          SMALL_GROUP_LIB[ n ][ typ ][ i ] );
                fi;
            fi;
            num := num + Length( SMALL_GROUP_LIB[ n ][ typ ][ i ] );
        fi;
    od;

    # num is the last group of the correct n, typ, sid
    if Length( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) = 1 then
        return num;
    fi;

    # look if there will be a conflict
    c := [ ,, [],
           [ 1 ],
           [ 1, 1 ],
           [ 1, 1, 1 ],
           [ 6, 1, 1, 1 ],
           [ 300, 20, 1, 1, 1 ] ];
    if IsBound( c[ n ][ typ ] ) then
        c := c[ n ][ typ ];
        if c > 1 then
            i := ID_GROUP_FUNCS[ 8 ]( G, inforec,
                                     [ n, typ, sid mod c, sid, cid ], true );
        else
            i := ID_GROUP_FUNCS[ 8 ]( G, inforec,
                                     [ n, typ, sid, cid ], true );
        fi;
        p := [ 3, 5, 17, 17, 97 ];
        p := p[ typ ];
        if i <> fail then
            if p <> inforec.p then
                # construct the group of size 2^n * p (<>inforec.p) with the
                # analogue operation of the 2-sylowsubgroup on the p-sylowsub
                g := FreeGroup( n + 1 );
                gens := GeneratorsOfGroup( g );
                pcgs := Pcgs( SylowSubgroup( G, 2 ) );
                pelm := First( GeneratorsOfGroup( SylowSubgroup( G,
                                 inforec.p )), x -> Order( x ) = inforec.p );
                rels := RelatorsCode( CodePcgs( pcgs ), 2^n, gens{[1 ..n ]});
                Add( rels, gens[ n + 1 ] ^ p );
                root1 := PrimitiveRootMod( p ) ^ ((p-1)/2^typ) mod p;
                root2 := PrimitiveRootMod( inforec.p ) ^
                                         ((inforec.p-1)/2^typ) mod inforec.p;
                root2 := List( [ 0 .. 2 ^ typ - 1 ], x-> pelm ^ (root2^x) );
                for j in [ 1 .. n ] do
                    Add( rels, gens[ n+1 ] ^ gens[ j ] / gens[ n+1 ] ^
                         ( root1 ^ ( ( Position( root2, pelm^pcgs[j] ) - 1 )
                           mod p ) ) );
                od;
                G := PcGroupFpGroup( g / rels );
                if Size( G ) < 1000 and n <> 8 then
                    return i.next[ Position( i.fp, IdGroup( G )[ 2 ] ) ];
                fi;
            fi;
            if c > 1 then
                return ID_GROUP_FUNCS[ 8 ]( G, inforec,
                                           [ n, typ, sid mod c, sid, cid ] );
            else
                return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ n, typ, sid,cid] );
            fi;
        fi;
    fi;

    # there is no conflict. Analyse the ids of the centralizer of the 
    # p-sylowsubgroup in the 2-sylowsubgroup
    c := [ ,, [ 1, 4 ],
           [ 1, 9, 13 ],
           [ 1, 20, 44, 50 ],
           [ 1, 54, 191, 259, 266 ],
           [ 1, 163, 996, 2149, 2318, 2327 ],
           [ 1, 541, 6731, 26972, 55625, 56081, 56091 ] ];
    c := c[ n ];
    rank := 1;
    repeat
        rank := rank + 1;
    until c[ rank ] >= sid;

    g := SmallGroup( 2^n, sid );
    gens := GeneratorsOfGroup( g );

    if typ = 1 then
        fgens := Reversed( gens{[ rank + 1 .. n ]} );
        for j in [ 1 .. Length( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) ] do
            coeff := CoefficientsMultiadic( 2 + 0 * [ 1 .. rank ],
                                   SMALL_GROUP_LIB[ n ][ typ ][ sid ][ j ] );
            sgens := ShallowCopy( fgens );
            Unbind( inv );
            for i in Reversed( [ 1 .. rank ] ) do
                if coeff[ i ] = 0 then
                    Add( sgens, gens[ i ] );
                else
                    if IsBound( inv ) then
                        Add( sgens, gens[ i ] * inv );
                    else
                        inv := gens[ i ];
                    fi;
                fi;
            od;
            if cid = IdGroup( GroupByGenerators( Reversed( sgens ) ) )[2] then
                return num - Length( SMALL_GROUP_LIB[n][typ][ sid ] ) + j;
            fi;
        od;
        Error( "fatal Error in function ID_GROUP_FUNCS[ 13 ]" );
    fi;

    # typ in [ 2 .. 
    C := CyclicGroup( 2 ^ typ );
    c := GeneratorsOfGroup( C )[ 1 ];
    gens := gens{[ 1 .. rank ]};
    for j in [ 1 .. Length( SMALL_GROUP_LIB[ n ][ typ ][ sid ] ) ] do
        if SMALL_GROUP_LIB[ n ][ typ ][ sid ][ j ] > 0 then
            coeff := CoefficientsMultiadic( 2 ^ typ + 0 * [ 1 .. rank ],
                                   SMALL_GROUP_LIB[ n ][ typ ][ sid ][ j ] );
            if IdGroup( Kernel( GroupHomomorphismByImages( g, C, gens,
               List( coeff, x-> c ^ x ) ) ) ) = [ 2 ^ ( n - typ ), cid ] then
                return num - Length( SMALL_GROUP_LIB[n][typ][ sid ] ) + j;
            fi;
        fi;
    od;
    Error( "fatal Error in function ID_GROUP_FUNCS[ 13 ]" );
end;
