#############################################################################
##
#W  smlgp8.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and constrution functions for the groups
##  of size 1536.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small8","1.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 8 ]
##
SMALL_AVAILABLE_FUNCS[ 8 ] := function( size )

    if size <> 1536 then
        return fail;
    fi;

    return rec( func := 14,
                lib  := 8,
                number := 408641062 );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 14 ]( size, i, inforec )
##
SMALL_GROUP_FUNCS[ 14 ] := function( size, i, inforec )
    local j, k, n1, t, pos, ind, g, file, c, DATA, p, nrs, sid, rank,
          aut, op, op1, op2, S, exp, F, gens, rel, rels, id, rrf, rrs,
          zs, z2s, zf, z2f, ff, lf, llf, sf, ucs, ucf, cf, cs, ss, indf;

    if i > 408641062 then 
        Error( "there are just 408641062 groups of size 1536" );
    fi;

    if i <= 10494213 then
        return DirectProduct( SmallGroup( 512, i ), CyclicGroup( 3 ) );
    fi;

    if not IsBound( SMALL_GROUP_LIB[ 1536 ] ) then
        SMALL_GROUP_LIB[ 1536 ] := AtomicRecord( rec( 
            npnil := AtomicList( List( [ 1 .. 12 ], x -> [] ) ) ) );
    fi;

    if i <= 408526597 then
        # 2-nilpotent groups
        if not IsBound( SMALL_GROUP_LIB[ 1536 ].2nil ) then
            ReadSmallLib( "sml", 8, 1536, [ 1 ] );
        fi;

        c := [ 10494213, 11282037, 12525679, 13812281, 15148219, 17584689,
               20359710, 23262662, 26181496, 29156616, 32150672, 35244312,
               38298872, 41370584, 44397546, 47481136, 50571920, 53665776,
               56765776, 59865776, 62945872, 66044720, 69143184, 72241648,
               75339728, 78435504, 81472528, 84498416, 87582672, 90674992,
               93755792, 96835056, 99928912, 103028912, 106122768, 109204336,
               112304336, 115404336, 118501264, 121588656, 124668864, 
               127746080, 130841776, 133829728, 136814132, 139898772,
               142968052, 146068052, 149138644, 152194012, 155266792,
               158363592, 161456104, 164556104, 167645128, 170734376,
               173833736, 176933736, 180033096, 183122588, 186213996,
               189309220, 192409124, 194956602, 197415333, 200109177,
               202847921, 205866321, 208763841, 211693953, 214776385, 
               217766809, 220783545, 223860409, 226915425, 229818727,
               233475876, 238573959, 244222975, 249956607, 256108591,
               261462673, 267385977, 273239865, 278973217, 284825281,
               290684963, 296672226, 302847690, 309027893, 315231951,
               321497962, 327723139, 334018883, 340267607, 346559543,
               352828098, 359083608, 365375208, 371622251, 377875451, 
               384167667, 390439199, 396715954, 403007690, 408526597 ];
        p := PositionSorted( c, i ) - 1;
        i := i - c[ p ];
        if not IsBound( SMALL_GROUP_LIB[ 1536 ].2nil[ p ] ) then
            ReadSmallLib( "sml", 8, 1536, [ 1, p ] );
        fi;
        DATA := SMALL_GROUP_LIB[ 1536 ].2nil[ p ];

        sid := ( p - 1 ) * 100000;
        p := 0;
        op1 := 0;
        while true do
            p := p + 1;
            if IsBound( DATA.ops[ p ] ) then
                op := DATA.ops[ p ];
            else
                op := op2;
            fi;
            if IsBound( DATA.nrs[ p ] ) then
                nrs := DATA.nrs[ p ];
            else
                nrs := 1;
            fi;
            if i <= nrs * SMALL_GROUP_LIB[ 1536 ].2nil[ 107 ][ op ] then
                c := Int( 1 + (i-1) / SMALL_GROUP_LIB[1536].2nil[107][op] );
                sid := sid + c;
                i := i - (c-1) * SMALL_GROUP_LIB[ 1536 ].2nil[ 107 ][ op ];
                op := SMALL_GROUP_LIB[ 1536 ].2nil[ 106 ][ op ];

                c := [ 1, 2044, 60903, 420514, 7532392, 10493061, 10494200,
                       10494212, 10494213 ];
                rank := PositionSorted( c, sid );

                aut := 0;
                while i > 0 do
                    aut := aut + 1;
                    if op mod 2 = 1 then
                        i := i - 1;
                    fi;
                    op := QuoInt( op, 2 );
                od;

                F := FreeGroup( 10 );
                gens := GeneratorsOfGroup( F );
                rels := RelatorsCode( CodePcGroup( SmallGroup( 512, sid ) ),
                                      512, gens{[ 1 .. 9 ]} );
                Add( rels, gens[ 10 ] ^ 3 );
                aut := CoefficientsMultiadic( 2 + 0 * [ 1 .. rank ], aut );
                for i in [ 1 .. rank ] do
                     if aut[ i ] = 1 then 
                         Add( rels, gens[ 10 ] ^ gens[ i ] * gens[ 10 ] );
                     fi;
                od;
                return PcGroupFpGroup( F / rels );

            fi;
            i := i - nrs * SMALL_GROUP_LIB[ 1536 ].2nil[ 107 ][ op ];
            sid := sid + nrs;
            op2 := op1;
            op1 := op;
        od;

    elif i <= 408544625 then
        # 3-nilpotent groups
        i := i - 408526597;

        if not IsBound( SMALL_GROUP_LIB[ 1536 ].3nil ) then
            ReadSmallLib( "sml", 8, 1536, [ 2 ] );
        fi;

        j := i;
        while not IsBound( SMALL_GROUP_LIB[ 1536 ].3nil.2syl[ j ] ) do
            j := j - 1;
        od;
        S := SmallGroup( 512, SMALL_GROUP_LIB[ 1536 ].3nil.2syl[ j ] );

        j := i;
        while not IsBound( SMALL_GROUP_LIB[ 1536 ].3nil.opsn[ j ] ) do
            j := j - 1;
        od;
        aut := SMALL_GROUP_LIB[ 1536 ].3nil.opsops[
                    SMALL_GROUP_LIB[ 1536 ].3nil.opsn[ j ] ];
        
        F := FreeGroup( 10 );
        gens := GeneratorsOfGroup( F );

        rels := RelatorsCode( CodePcGroup( S ), 512, gens{[ 2 .. 10 ]} );
        Add( rels, gens[ 1 ] ^ 3 );
        aut := CoefficientsMultiadic( List( [ 1..9 ], x-> 513 ), aut ) - 1;
        for j in [ 1 .. 9 ] do
            exp := CoefficientsMultiadic( [2,2,2,2,2,2,2,2,2], aut[ j ] );
            rel := gens[ 1 ] ^ -1 * gens[ j + 1 ] ^ -1 * gens [ 1 ];
            for k in [ 1 .. 9 ] do
                if exp[ k ] = 1 then
                    rel := rel * gens[ k + 1 ];
                fi;
            od;
            Add( rels, rel );
        od;
        return PcGroupFpGroup( F / rels );
    fi;

    # remaining groups are neither 2- nor 3-nilpotent
    i := i - 408544625;
    
    ind := [ 0, 63, 2877, 24368, 24582, 87879, 89053, 95095, 96224, 96290,
             96341, 96404, 96433, 96437 ];
    pos := PositionSorted( ind, i ) - 1;
    i := i - ind[ pos ];

    if pos = 13 then
        t := [ 133828121287904829779097420032, 
               726913944952298481637619910488516722944, 
               2634249416323345597468107839036164922019464872192, 
               6368966309566407273379632747023443871927727076481509622016 ];
        return PcGroupCode( t[ i ], 1536 );
    fi;

    file := QuoInt( i + 2499, 2500 );
    i := ( ( i - 1 ) mod 2500 ) + 1;
    if not IsBound( SMALL_GROUP_LIB[ 1536 ].npnil[ pos ][ file ] ) then
        ReadSmallLib( "sml", 8, 1536, [ 3, pos, file ] );
    fi;
    cs := SMALL_GROUP_LIB[ 1536 ].npnil[ pos ][ file ][ i ];

    sf := [ 24, 48, 96, 96, 192, 192, 384, 384, 384, 768, 768, 768 ];
    sf := sf[ pos ];
    ss := 1536 / sf;
    cf := [                                   344690052,
                                           119617407496,
                                        120610198669328,
                                  158205782074846042128,
                                     245098184274223136,
                              2586624666415978127728672,
                                 1000019230708240252992,
                          84680442828248436973715619904,
                  4794912616867297042748271370442211392,
                              8176195339728967459537024,
                     5547135398087278890074879559860352,
            2512773859449297932074560631469666592227456 ];
    cf := cf[ pos ];

    F := FreeGroup( 10 );
    gens := GeneratorsOfGroup( F );
    id := gens[ 1 ] ^ 0;
    
    ff := FactorsInt( sf );
    lf := Length( ff );
    indf := CoefficientsMultiadic( List([1..lf], x -> 2), cf mod (2^lf)) + 2;
    cf := QuoInt( cf, 2 ^ lf );
    ind := Concatenation( indf, List( [ lf + 1 .. 10 ], x -> 2 ) );

    rels := [];
    rrf  := [];
    rrs  := [];

    for k in [ 1 .. 10 ] do
        rels[ k ] := gens[ k ] ^ ind[ k ];
    od;

    llf := lf * ( lf + 1 ) / 2 - 1;
    ucf := [];
    n1  := cf mod ( 2 ^ llf );
    for k in [ 1 .. llf ] do
        ucf[ k ] := n1 mod 2;
        n1 := QuoInt( n1, 2 );
    od;
    ucs := [];
    n1 := cs mod ( 2 ^ 54 );
    for k in [ 1 .. 54 ] do
        ucs[ k ] := n1 mod 2;
        n1 := QuoInt( n1, 2 );
    od;
    cf := QuoInt( cf, 2 ^ llf );
    cs := QuoInt( cs, 2 ^ 54 );

    for k in [ 1 .. Sum( ucf ) ] do
        t := CoefficientsMultiadic( indf, cf mod sf );
        g := id;
        for j in [ 1 .. lf ] do
            if t[ j ] > 0 then
                g := g * gens[ j ] ^ t[ j ];
            fi;
        od;
        Add( rrf, g );
        cf := QuoInt( cf, sf );
    od;
    for k in [ 1 .. Sum( ucs ) ] do
        t := CoefficientsMultiadic( ind, cs mod ss );
        g := id;
        for j in [ lf + 1 .. 10 ] do
            if t[ j ] > 0 then
                g := g * gens[ j ] ^ t[ j ];
            fi;
        od;
        Add( rrs, g );
        cs := QuoInt( cs, ss );
    od;

    zf := 1;
    zs := 1;
    for k in [ 1 .. 9 ] do
        if k < lf and ucf[ k ] = 1 then
            rels[ k ] := rels[ k ] / rrf[ zf ];
            zf := zf + 1;
        fi;
        if ucs[ k ] = 1 then
            rels[ k ] := rels[ k ] / rrs[ zs ];
            zs := zs + 1;
        fi;
    od;
    z2f := lf - 1;
    z2s := 9;
    for k in [ 1 .. 9 ] do
        for j in [ k + 1 .. 10 ] do
            t := id;
            if j <= lf then
                z2f := z2f + 1;
                if ucf[ z2f ] = 1 then
                    t := rrf[ zf ];
                    zf := zf + 1;
                fi;
            fi;
            z2s := z2s + 1;
            if ucs[ z2s ] = 1 then
                t := t * rrs[ zs ];
                zs := zs + 1;
            fi;
            if t <> id then
                 Add( rels, Comm( gens[ j ], gens[ k ] ) / t );
            fi;
        od;
    od;

    return PcGroupFpGroup( F / rels );
end;

#############################################################################
##                          
#F SELECT_SMALL_GROUPS_FUNCS[ 14 ]( funcs, vals, inforec, all, id, idList )
##                  
SELECT_SMALL_GROUPS_FUNCS[ 14 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];
