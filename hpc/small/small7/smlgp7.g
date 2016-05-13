#############################################################################
##
#W  smlgp7.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the reading and constrution functions for the groups
##  of size 512.
##

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
    n, k, l, F, rels, gens, rhs, c, body, ibits, iibits;
    
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
    if IsBound( inforec.bits ) then
        if 1 in Set( inforec.bits + bits ) then
            return fail;
        fi;
        pos := 31;
        i := QuoInt( i - 1, 1000 ) * 1000 + 1;
        ibits := inforec.bits{ obits };
        while pos < Length( STR ) do
            headP := pos + 1;
            if STR[ pos ] = ' '  then
                pos := pos + headL;
                repeat
                    pos := pos + 1;
                until pos = Length(STR)+1 or STR[pos]=' ' or STR[pos]='!';
                body := STR{[ headP + headL .. pos - 1 ]};
            else
                pos := pos + headL + 3;
                body := SMALL_GROUP_LIB[ 512 ][ 106 ][
                     81 * Position( L, STR[ pos - 2 ] ) +
                     Position( L, STR[ pos - 1 ] ) - 82 ];
            fi;
            tbits := Concatenation( List( STR{[ headP..headP+headL-1 ]}, x-> 
                CoefficientsMultiadic( [ 3,3,3,3 ], Position( L, x ) - 1 )));
            tbits := tbits{[ 1 .. Length( obits ) ]};
            if not 1 in ibits + tbits then
                iibits := ibits{ Filtered( [ 1 .. Length( obits ) ],
                                           x -> tbits[ x ] = 2 ) };
                if iibits = [] then
                    return i;
                fi;
                iibits := Position( body, L[ ( Concatenation( iibits,
                   [ 0,0,0,0,0] ){[1..6]} * [ 32, 16, 8, 4, 2, 1 ] ) + 1 ] );
                if iibits <> fail then
                    return i + iibits - 1;
                fi;
            fi;
            i := i + Length( body );
        od;
        return fail;
    fi;

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
SELECT_SMALL_GROUPS_FUNCS[ 18 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];

#############################################################################
##
#F IdStandardPresented512Group( G )
##
InstallGlobalFunction( IdStandardPresented512Group, function( G )
    local pcgs, bits, rhs, n, k, i, str, L, t, POS, h,
          decode_head, ignore;

    decode_head := function()
        t := Position( L, str[POS] ) * 81 + Position( L, str[POS+1] ) - 82;
        POS := POS + 2;
        return CoefficientsMultiadic( [ 120, 7, 7 ], t );
    end;

    # jump the `.0'-branch
    ignore := function()
        local h, i;

        h := decode_head();
        for i in [ 2 .. 3 ] do
            if h[ i ] = 0 then
                ignore();
            elif h[ i ] <= 2 then
                POS := POS + 2;
            else
                POS := POS + 4;
            fi;
        od;
    end;

    if IsGroup( G ) then
        pcgs := Pcgs( G );
    elif IsPcgs( G ) then
        pcgs := G;
    else 
        Error( "usage: IdStandardPresented512Group( pcgs )" );
    fi;
    if not Product( RelativeOrders( pcgs ) ) = 512 then 
        Error( "need group of order 512 as input" );
    fi;

    if IsBound( pcgs ) then
        rhs := [];
        for n in [ 1 .. 9 ] do
            rhs[ n ] := [];
            for k in [ n + 1 .. 9 ] do
                rhs[n][k] := ExponentsOfPcElement( pcgs, pcgs[k] ^ pcgs[n] );
            od;
            rhs[ n ][ n ] := ExponentsOfPcElement( pcgs, pcgs[ n ] ^ 2 );
        od;
        bits := [];
        for i in [ 2 .. 9 ] do
            for n in [ 1 .. i - 1 ] do
                for k in [ n .. i - 1 ] do
                    Add( bits, rhs[ n ][ k ][ i ] );
                od;
            od;
        od;
    elif IsList( G ) then
        bits := G;
    elif IsInt( G ) then
        bits := Reversed( CoefficientsMultiadic( 2 + 0 * [ 1 .. 120 ], G ) );
    else
        Error( "usage: IdStandardPresented512Group( G ) or",
         "             IdStandardPresented512Group( Pcgs( G ) )" );
    fi;

    if not IsBound( SMALL_GROUP_LIB[ 512 ] ) then
        ReadSmallLib( "sml", 7, 512, [ 106 ] );
    fi;
    if not IsBound( SMALL_GROUP_LIB[ 512 ][ 107 ] ) then
        ReadSmallLib( "sml", 7, 512, [ 107 ] );
    fi;

    n := 1;
    for i in [ 1 .. 7 ] do
        n := 2 * n + bits[ SMALL_GROUP_LIB[ 512 ][ 107 ][ n ] ];
    od;

    L := "%&()*+,-./0123456789:<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^abcdefghijklm\
nopqrstuvwxyz{}";
    str := SMALL_GROUP_LIB[ 512 ][ 108 ][ n - 127 ];
    POS := 1;
    repeat
        h := decode_head();
        if bits[ h[ 1 ] + 1 ] = 1 then
            if h[ 2 ] = 0 then
                ignore();
            elif h[ 2 ] <= 2 then
                POS := POS + 2;
            else
                POS := POS + 4;
            fi;
        fi;
        h := h[ bits[ h[ 1 ] + 1 ] + 2 ];
    until h <> 0;
    t := 2 * (Position( L,str[POS] )*81 + Position( L,str[POS+1])) - 163;
    if h in [ 2, 5, 6 ] then
        t := t + 1;
    fi;
    if h <= 2 then
        t := t + [ 0, 1 ];
    else
        t := [ t,
     2 * (Position( L,str[POS+2] )*81 + Position( L,str[POS+3])) - 163 ];
        if h in [ 4, 6 ] then
            t[ 2 ] := t[ 2 ] + 1;
        fi;
    fi;
    for i in t do
        n := SMALL_GROUP_FUNCS[ 18 ]( fail, i * 1000 - 999,
                                      rec( bits := bits ) );
        if n <> fail then 
            return [ 512, n ];
        fi;
    od;
    Info( InfoWarning, 1, "IdStandardPresented512Group: <pcgs> does not ",
                          "correspond to an anupq-standard presentation" );
    return fail;
end );
