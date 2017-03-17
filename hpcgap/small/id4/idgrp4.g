#############################################################################
##
#W  idgrp4.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the identification routines for the groups
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
DeclareComponent("id4","1.0");

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 4 ]
##
ID_AVAILABLE_FUNCS[ 4 ] := function( size )

    if size in [ 2401, 3125 ] then
        return rec( func := 8,
                    lib := 4 );
    fi;

    return SMALL_AVAILABLE_FUNCS[ 4 ]( size );
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 17 ]( G, inforec )
##
ID_GROUP_FUNCS[ 17 ] := function( G, inforec )
    local size, sid, num, pos, cid, n, typ, c, sp, i, j, k, tmp, listInt,
          rank, id, g, gens, fgens, sgens, inv, coeff, p, root1, root2,
          pcgs, pelm, rels, C, nn, Q, coc, code, spcgs, desc, codes;

    if IsNilpotent( G ) then 
        return IdGroup( SylowSubgroup( G, inforec.q ) )[ 2 ];
    fi;

    size := Size( G );

    if ( not IsNormal( G, SylowSubgroup( G, inforec.q ) ) ) and
       ( not IsNormal( G, SylowSubgroup( G, inforec.p ) ) ) then
        # in the case of size 1053 this situation is unique
        if size = 1053 then
            return 51;
        fi;
        return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ size, 2 ] );
    fi;

    sid := IdGroup( SylowSubgroup( G, inforec.q ) )[ 2 ];
    num := NUMBER_SMALL_GROUPS_FUNCS[ 17 ]( size, inforec );

    if IsNormal( G, SylowSubgroup( G, inforec.q ) ) then
        num := num.pos[ Position( num.types, "p-autos" ) ];
        if not IsBound( SMALL_GROUP_LIB[ size ] ) then
            SMALL_GROUP_LIB[ size ] := rec();
            ReadSmallLib( "sml", inforec.lib, size, [ ] );
        fi;
        pos := Position( SMALL_GROUP_LIB[ size ].pnil.syl, sid );
        if ( not IsBound( SMALL_GROUP_LIB[ size ].pnil.syl[ pos + 1 ] ) )
           or ( SMALL_GROUP_LIB[ size ].pnil.syl[ pos + 1 ] <> sid ) then
            return num + pos;
        fi;
        return ID_GROUP_FUNCS[ 8 ]( G, inforec, [ size, 1, sid ] );
    fi;

    # p-sylow-subgroup is normal
    cid := IdGroup( Centralizer( SylowSubgroup( G, inforec.q ),
                                 SylowSubgroup( G, inforec.p ) ) );
    n   := inforec.n;
    typ := Log( inforec.q ^ n / cid[ 1 ], inforec.q );
    cid := cid[ 2 ];
    num := num.pos[ Position( num.types, typ ) ];
    nn  := inforec.q ^ 2 * Primes[ n ];

    if not IsBound( SMALL_GROUP_LIB[ nn ] ) then
        ReadSmallLib( "nor", 4, inforec.q, [ n ] );
    fi;

    if IsRecord( SMALL_GROUP_LIB[ nn ][ typ ] ) then
        tmp := [ ];
        i := 0;
        for j in [ 1 .. Length( SMALL_GROUP_LIB[ nn ][ typ ].pos ) ] do
            if SMALL_GROUP_LIB[ nn ][ typ ].pos[ j ] > 0 then
                i := i + 1;
                tmp[ SMALL_GROUP_LIB[ nn ][ typ ].pos[ j ] ] :=
                    SMALL_GROUP_LIB[ nn ][ typ ].val[ i ];
            else
                for k in [ SMALL_GROUP_LIB[ nn ][ typ ].pos[ j - 1] + 1 ..
                          -SMALL_GROUP_LIB[ nn ][ typ ].pos[ j ] ] do
                    i := i + 1;
                    tmp[ k ] := SMALL_GROUP_LIB[ nn ][ typ ].val[ i ];
                od;
            fi;
        od;
        SMALL_GROUP_LIB[ nn ][ typ ] := tmp;
    fi;

    for i in [ 1 .. sid ] do
        if IsBound( SMALL_GROUP_LIB[ nn ][ typ ][ i ] ) then
            if IsInt( SMALL_GROUP_LIB[ nn ][ typ ][ i ] ) then
                SMALL_GROUP_LIB[ nn ][ typ ][ i ] := SMALL_GROUP_LIB[ nn ]
                            [ typ ][ -SMALL_GROUP_LIB[ nn ][ typ ][ i ] ];
            fi;
            num := num + Length( SMALL_GROUP_LIB[ nn ][ typ ][ i ] );
        fi;
    od;

    # num is the last group of the correct n, typ, sid
    if Length( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) = 1 then
        return num;
    fi;

    # look if there will be a conflict
    c := [ ,, [ 1 ],
              [ 1, 1 ],
              [ 1, 1, 1 ],
              [ 12, 1, 1, 1 ] ];
    if IsBound( c[ n ][ typ ] ) then
        c := c[ n ][ typ ];
        if c > 1 then
            i := ID_GROUP_FUNCS[ 8 ]( G, inforec,
                                    [ nn, typ, sid mod c, sid, cid ], true );
        else
            i := ID_GROUP_FUNCS[ 8 ]( G, inforec,
                                    [ nn, typ, sid, cid ], true );
        fi;
        p := [ ,, [ 7, 19, 109, 163 ],, [ 11, 101, 251 ],, [29, 197 ] ];
        p := p[ inforec.q ][ typ ];
        if i <> fail then
            if p <> inforec.p then
                # construct the group of size q^n * p (<>inforec.p) with the
                # analogue operation of the q-sylowsubgroup on the p-sylowsub
                g := FreeGroup( n + 1 );
                gens := GeneratorsOfGroup( g );
                pcgs := Pcgs( SylowSubgroup( G, inforec.q ) );
                pelm := First( GeneratorsOfGroup( SylowSubgroup( G,
                                 inforec.p )), x -> Order( x ) = inforec.p );
                rels := RelatorsCode(CodePcgs(pcgs),inforec.q^n,gens{[1..n]});
                Add( rels, gens[ n + 1 ] ^ p );
                root1 := PrimitiveRootMod( p ) ^ ((p-1)/inforec.q^typ) mod p;
                root2 := PrimitiveRootMod( inforec.p ) ^
                                 ((inforec.p-1)/inforec.q^typ) mod inforec.p;
                root2 := List( [ 0..inforec.q^typ-1 ], x-> pelm^(root2^x) );
                for j in [ 1 .. n ] do
                    Add( rels, gens[ n+1 ] ^ gens[ j ] / gens[ n+1 ] ^
                         ( root1 ^ ( ( Position( root2, pelm^pcgs[j] ) - 1 )
                           mod p ) ) );
                od;
                G := PcGroupFpGroup( g / rels );
                if Size( G ) < 1000  then
                    return i.next[ Position( i.fp, IdGroup( G )[ 2 ] ) ];
                fi;
            fi;
            size := Size( G );
            G := [ G ];
            if not IsBound( i.fp ) then
                Append( G, List( i.next, x -> SmallGroup( size, x ) ) );
            fi;
            Q := List( G, x -> SylowSubgroup( x, inforec.q ) );
            coc := List( Q, CocGroup ); 
            if IsBound( i.desc ) then
                for desc in i.desc do
                    j := [ desc mod 1000 ];
                    desc := QuoInt( desc, 1000 );
                    while desc > 0 do
                        Add( j, desc mod 100 );
                        desc := QuoInt( desc, 100 );
                    od;
                    desc := Reversed( j );
                    for j in [ 1 .. Length( G ) ] do
                       coc[ j ] := DiffCoc( coc[ j ], desc[ 2 ],
                                               EvalFpCoc( coc[ j ], desc ) );
                    od;
                od;
            fi;
            coc := List( coc, x -> List( x, Concatenation ) );
            j := List( G, y -> First( GeneratorsOfGroup(
                            SylowSubgroup( y, p ) ), x -> Order( x ) = p ) );
            coc := List( coc, x -> x{ i.pos } );
            for k in [ 1 .. Length( G ) ] do
                Add( coc[ k ], List( [ 1 .. p - 1 ], x -> j[ k ] ^ x ) );
            od;
            spcgs := List( G, SpecialPcgs );
            if Length( G ) = 1 then
                repeat 
                    repeat
                        gens := List( coc[ 1 ], Random );
                    until Size( Group( gens ) ) = size;
                    code := CodeGenerators( gens, spcgs[ 1 ] ).code;
                until code in i.fp;
                return i.next[ Position( i.fp, code ) ];
            fi;
            codes := List( G, x -> [] );
            while true do
                for j in [ 1 .. Length( G ) ] do
                    repeat
                        gens := List( coc[ j ], Random );
                    until Size( Group( gens ) ) = size;
                    code := CodeGenerators( gens, spcgs[ j ] ).code;
                    if j = 1 then
                        for k in [ 2 .. Length( G ) ] do
                            if code in codes[ k ] then
                                return i.next[ k - 1 ];
                            fi;
                        od;
                        if not code in codes[ 1 ] then
                            Add( codes[ 1 ], code );
                        fi;
                    else
                        if code in codes[ 1 ] then
                            return i.next[ j - 1 ];
                        fi;
                        if not code in codes[ j ] then
                            Add( codes[ j ], code );
                        fi;
                    fi;
                od;
            od;
        fi;
    fi;

    # there is no conflict. Analyse the ids of the centralizer of the 
    # p-sylowsubgroup in the q-sylowsubgroup
    c := [ ,, [ 1, 4 ],
           [ 1, 10, 14 ],
           [ 1, 30, 60, 66 ],
           [ 1, 101, 414, 496, 503 ] ];
    c := c[ n ];
    if inforec.q = 5 and n = 5 then
        c := [ 1, 38, 70, 76 ];
    fi; 
    rank := 1;
    repeat
        rank := rank + 1;
    until c[ rank ] >= sid;

    g := SmallGroup( inforec.q ^ n, sid );
    gens := GeneratorsOfGroup( g );
    C := CyclicGroup( inforec.q ^ typ );
    c := GeneratorsOfGroup( C )[ 1 ];
    gens := gens{[ 1 .. rank ]};
    for j in [ 1 .. Length( SMALL_GROUP_LIB[ nn ][ typ ][ sid ] ) ] do
        if SMALL_GROUP_LIB[ nn ][ typ ][ sid ][ j ] > 0 then
            coeff := CoefficientsMultiadic( inforec.q ^ typ + 0 * [1..rank],
                                   SMALL_GROUP_LIB[ nn ][ typ ][ sid ][ j ] );
            if IdGroup( Kernel( GroupHomomorphismByImages( g, C, gens,
               List( coeff, x-> c^x ) ) ) ) = [ inforec.q^(n-typ), cid ] then
                return num - Length( SMALL_GROUP_LIB[nn][typ][ sid ] ) + j;
            fi;
        fi;
    od;
    Error( "fatal Error in function ID_GROUP_FUNCS[ 17 ]" );
end;
