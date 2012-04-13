#############################################################################
##
#W  smlgp1.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the generic construction of groups with order containg
##  maximal 3 primes. 
##

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 1 ]
##
SMALL_AVAILABLE_FUNCS[ 1 ] := function( size )
    local p;

    p := FactorsInt( size );
    if Length( p ) > 3 then
        return fail;
    fi;
    
    if Length( p ) = 1 then
        return rec( func := 1,
                    number := 1 );
    fi;

    if Length( p ) = 2 then
        if p[ 1 ] = p[ 2 ] then
            return rec( func := 2,
                        number := 2,
                        p := p[ 1 ] );
        else 
            return rec( func := 3,
                        q := p[ 2 ],
                        p := p[ 1 ] );
        fi;
    fi;

    if p[ 1 ] = p[ 3 ] then
        return rec( func := 4,
                    number := 5,
                    p := p[ 1 ] );
    elif p[ 1 ] = p[ 2 ] then
        return rec( func := 5,
                    q := p[ 3 ],
                    p := p[ 1 ] );
    elif p[ 2 ] = p[ 3 ] then 
        return rec( func := 6,
                    q := p[ 3 ],
                    p := p[ 1 ] );
    fi;
    
    return rec( func := 7,
                p := p[ 1 ],
                q := p[ 2 ],
                r := p[ 3 ] );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 1 ]( size, i, inforec )
##
## order p
##
SMALL_GROUP_FUNCS[ 1 ] := function( size, i, inforec )
    local g;

    if i > 1 then
        Error( "there is just 1 group of size ", size );
    fi;
    if size = 1 then 
        g := TrivialGroup( IsPcGroup );
        SetNameIsomorphismClass( g, Concatenation( "c", String( size ) ) );
        return g;
    fi;
    return CyclicGroup( size );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 2 ]( size, i, inforec )
##
## order p^2
##
SMALL_GROUP_FUNCS[ 2 ] := function( size, i, inforec )

    if i > 2 then
        Error( "there are just 2 groups of size ", size );
    fi;
    if i = 1 then 
        return CyclicGroup( size );
    fi;
    return ElementaryAbelianGroup( size );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 3 ]( size, i, inforec )
##
## order p * q
##
SMALL_GROUP_FUNCS[ 3 ] := function( size, i, inforec )
    local n, typ, F, gens, rels, p, q, g;

    if not IsBound( inforec.types ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 3 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    F    := FreeGroup( 2 );
    gens := GeneratorsOfGroup( F );
    p    := inforec.p;
    q    := inforec.q;
    rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q ];

    typ := inforec.types[ i ];
#    if typ = "pq" then
#        ;
    if typ = "Dpq" then
        Add( rels, gens[2] ^ gens[1] /
                   gens[2] ^ ( PrimitiveRootMod(q) ^ ( (q-1)/p ) mod q ) );
    fi;

    g := PcGroupFpGroup( F / rels );

    if typ = "pq" then 
        SetNameIsomorphismClass( g, Concatenation( "c", String( size ) ) );
    elif size = 6 then
        SetNameIsomorphismClass( g, "S3" );
    elif p = 2 then
        SetNameIsomorphismClass( g, Concatenation( "D", String( size ) ) );
    else
        SetNameIsomorphismClass( g, Concatenation(String(q),":",String(p)) );
    fi;
    return g;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 4 ]( size, i, inforec )
##
## order p^3
##
SMALL_GROUP_FUNCS[ 4 ] := function( size, i, inforec )
    local F, gens, p, rels, g, name;

    if i > 5 then
        Error( "there are just 5 groups of size ", size );
    fi;

    F    := FreeGroup( 3 );
    gens := GeneratorsOfGroup( F );
    p    := inforec.p;

    if i = 1 then 
        rels := [ gens[1]^p / gens[2], gens[2]^p / gens[3], gens[3]^p ];
        name := Concatenation( "c", String( size ) );
    elif i = 2 then 
        rels := [ gens[1]^p / gens[3], gens[2]^p, gens[3]^p ];
        name := Concatenation( String( p ), "x", String( p^2 ) );
    elif i = 3 then 
        rels := [ gens[1]^p, gens[2]^p, gens[3]^p,
                  Comm( gens[2], gens[1] ) / gens[3] ];
        if size = 8 then
            name := "D8";
        else
            name := Concatenation( String( p ), "^2:", String( p ) );
        fi;
    elif i = 4 then 
        rels := [ gens[1]^p/gens[3], gens[2]^p, gens[3]^p,
                  Comm( gens[2], gens[1] ) / gens[3] ];
        if size = 8 then
            rels[ 2 ] := gens[2]^2/gens[3];
            name := "Q8";
        else
            name := Concatenation( String( p^2 ), ":", String( p ) );
        fi;
    elif i = 5 then 
        rels := [ gens[1]^p, gens[2]^p, gens[3]^p ];
        name := Concatenation( String( p ), "^3" );
    fi;
        
    g := PcGroupFpGroup( F / rels );
    SetNameIsomorphismClass( g, name );
    return g;
end;


#############################################################################
##
#F SMALL_GROUP_FUNCS[ 5 ]( size, i, inforec )
##
## order p ^ 2 * q
##
SMALL_GROUP_FUNCS[ 5 ] := function( size, i, inforec )
    local n, typ, F, gens, rels, p, q, co, root, name, g;

    if not IsBound( inforec.types ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 5 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    F    := FreeGroup( 3 );
    gens := GeneratorsOfGroup( F );
    p    := inforec.p;
    q    := inforec.q;

    typ := inforec.types[ i ];
    if typ = "ppq" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ p, gens[ 3 ] ^ q ];
        name := Concatenation( String( p ), "^2x", String( q ) );
    elif typ = "p2q" then
        rels := [ gens[ 1 ] ^ p / gens[ 3 ] , gens[ 2 ] ^ q, gens[ 3 ] ^ p ];
        name := Concatenation( "c", String( size ) );
    elif typ = "Dpqxp" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ p, gens[ 3 ] ^ q,
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( PrimitiveRootMod(q) ^ ( (q-1)/p ) mod q ) ];
        if p = 2 then
            name := Concatenation( "D", String( size ) );
        else
            name := Concatenation( String(q),":", String(p),"x", String(p) );
        fi;
    elif typ = "a4" then
        rels := [ gens[ 1 ] ^ 3, gens[ 2 ] ^ 2, gens[ 3 ] ^ 2,
                  gens[ 2 ] ^ gens[ 1 ] / gens[ 3 ],
                  gens[ 3 ] ^ gens[ 1 ] / gens[ 2 ] * gens[ 3 ] ];
        name := "A4";
    elif typ = "Gp2q" then
        rels := [ gens[ 1 ] ^ p / gens[ 2 ], gens[ 2 ] ^ p,
                  gens[ 3 ] ^ q,
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( PrimitiveRootMod(q) ^ ( (q-1)/p ) mod q ) ];
        name := Concatenation( String( p*q ), ".", String( p ) );
    else 
        # Hp2q
        root := PrimitiveRootMod(q);
        rels := [ gens[ 1 ] ^ p / gens[ 2 ], gens[ 2 ] ^ p,
                  gens[ 3 ] ^ q,
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( root ^ ( (q-1)/p^2 ) mod q ),
                  gens[3] ^ gens[2] /
                  gens[3] ^ ( root ^ ( (q-1)/p ) mod q ) ];
        name := Concatenation( String( q ), ":", String( p*p ) );
    fi;
        
    g := PcGroupFpGroup( F / rels );
    SetNameIsomorphismClass( g, name );
    return g;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 6 ]( size, i, inforec )
##
## order p * q ^ 2
##
SMALL_GROUP_FUNCS[ 6 ] := function( size, i, inforec )
    local n, typ, F, gens, rels, p, q, root, base, vec, name, g;

    if not IsBound( inforec.types ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 6 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    F    := FreeGroup( 3 );
    gens := GeneratorsOfGroup( F );
    p    := inforec.p;
    q    := inforec.q;

    typ := inforec.types[ i ];
    if typ = "pqq" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ q ];
        name := Concatenation( String( p ), "x", String( q ), "^2" );
    elif typ = "pq2" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q / gens[ 3 ], gens[ 3 ] ^ q ];
        name := Concatenation( "c", String( size ) );
    elif typ = "Dpqxq" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ q,
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( PrimitiveRootMod(q) ^ ( (q-1)/p ) mod q ) ];
        if q = 3 then
            name := "S3x3";
        elif p = 2 then
            name := Concatenation( "D", String( p*q ), "x", String( q ) );
        else
            name := Concatenation( String(q),":", String(p),"x", String(q) );
        fi;
    elif typ = "Mpq2" then
        root := PrimitiveRootMod( q ^ 2 );
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q / gens[ 3 ], gens[ 3 ] ^ q,
                  gens[2] ^ gens[1] /
                  ( gens[2] ^ ( root ^ ( (q-1)/p ) mod q ) * 
                  gens[3] ^ QuoInt( root ^ ( q*(q-1)/p ) mod ( q^2 ), q ) ),
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( root ^ ( (q-1)/p ) mod q ) ];
        name := Concatenation( String( q^2 ), ":", String( p ) );
    elif typ = "Npq2" then
        base := CanonicalBasis( GF( q ^ 2 ) );
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ q ];
        vec  := IntVecFFE( Coefficients( base, Z(q^2) ^ ( (q^2-1)/p ) ) );
        Add( rels, gens[2]^gens[1] / ( gens[2]^vec[1] * gens[3]^vec[2] ) );
        vec  := IntVecFFE( Coefficients( base, Z(q^2) ^ ( (q^2-1)/p+1 ) ) );
        Add( rels, gens[3]^gens[1] / ( gens[2]^vec[1] * gens[3]^vec[2] ) );
        name := Concatenation( String( q ), "^2:", String( p ) );
    elif IsInt( typ ) then
        # Kpq2( 1 ) or Lpq2( >1 )
        root := PrimitiveRootMod( q ) ^ ( (q-1)/p );
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ q,
                  gens[2] ^ gens[1] / gens[2] ^ ( root mod q ),
                  gens[3] ^ gens[1] / gens[3] ^ ( root ^ typ mod q ) ];
    fi;
        
    g := PcGroupFpGroup( F / rels );
    if IsBound( name ) then
        SetNameIsomorphismClass( g, name );
    fi;
    return g;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 7 ]( size, i, inforec )
##
## order p * q * r
##
SMALL_GROUP_FUNCS[ 7 ] := function( size, i, inforec )
    local n, typ, F, gens, rels, p, q, r, root, r1, r2, g, name;

    if not IsBound( inforec.types ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 7 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    F    := FreeGroup( 3 );
    gens := GeneratorsOfGroup( F );
    p := inforec.p;
    q := inforec.q;
    r := inforec.r;

    typ := inforec.types[ i ];
    if typ = "pqr" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ r ];
        name := Concatenation( "c", String( size ) );
    elif typ = "Dpqxr" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ r, gens[ 3 ] ^ q,
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( PrimitiveRootMod(q) ^ ( (q-1)/p ) mod q ) ];
        if q = 3 then
            name := Concatenation( "S3x", String( r ) );
        elif p = 2 then
            name := Concatenation( "D", String( p*q ), "x", String( r ) );
        else
            name := Concatenation( String(q),":",String(p),"x",String(r) );
        fi;
    elif typ = "Dprxq" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ r,
                  gens[3] ^ gens[1] /
                  gens[3] ^ ( PrimitiveRootMod(r) ^ ( (r-1)/p ) mod r ) ];
        if p = 2 then
            name := Concatenation( "D", String( p*r ), "x", String( q ) );
        else
            name := Concatenation( String(r),":",String(p),"x",String(q) );
        fi;
    elif typ = "Dqrxp" then
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ r,
                  gens[3] ^ gens[2] /
                  gens[3] ^ ( PrimitiveRootMod(r) ^ ( (r-1)/q ) mod r ) ];
        name := Concatenation( String(r),":",String(q),"x",String(p) );
    elif typ = "Hpqr" then
        root := PrimitiveRootMod( r );
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ r,
                  gens[3] ^ gens[1] / gens[ 3 ] ^ ( root^((r-1)/p) mod r ),
                  gens[3] ^ gens[2] / gens[ 3 ] ^ ( root^((r-1)/q) mod r ) ];
        name := Concatenation( String(r),":",String(p*q) );
    elif IsInt( typ ) then
        # Gpqr
        r1 := First( [2..r-1], t -> t^p mod r = 1 );
        r2 := First( [2..q-1], t -> t^p mod q = 1 );
        rels := [ gens[ 1 ] ^ p, gens[ 2 ] ^ q, gens[ 3 ] ^ r,
                  gens[2] ^ gens[ 1 ] / gens[2] ^ ( r2 ^ typ mod q ),
                  gens[3] ^gens[ 1 ] / gens[3] ^ r1 ];
    fi;
        
    g := PcGroupFpGroup( F / rels );
    if IsBound( name ) then
        SetNameIsomorphismClass( g, name );
    fi;
    return g;
end;

#############################################################################
##
#F SELECT_SMALL_GROUPS_FUNCS[ 1..7 ]( funcs, vals, inforec, all, id, idList )
##
SELECT_SMALL_GROUPS_FUNCS[ 1 ]:=function( size, funcs, vals, inforec, all,
                                          id, idList )
    local result, i, g, ok, j, range;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ inforec.func ]( size, inforec);
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

SELECT_SMALL_GROUPS_FUNCS[ 2 ] := SELECT_SMALL_GROUPS_FUNCS[ 1 ];
SELECT_SMALL_GROUPS_FUNCS[ 3 ] := SELECT_SMALL_GROUPS_FUNCS[ 1 ];
SELECT_SMALL_GROUPS_FUNCS[ 4 ] := SELECT_SMALL_GROUPS_FUNCS[ 1 ];
SELECT_SMALL_GROUPS_FUNCS[ 5 ] := SELECT_SMALL_GROUPS_FUNCS[ 1 ];
SELECT_SMALL_GROUPS_FUNCS[ 6 ] := SELECT_SMALL_GROUPS_FUNCS[ 1 ];
SELECT_SMALL_GROUPS_FUNCS[ 7 ] := SELECT_SMALL_GROUPS_FUNCS[ 1 ];

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 3 ]( size, inforec )
##
## order p * q
##
NUMBER_SMALL_GROUPS_FUNCS[ 3 ] := function( size, inforec )

    if inforec.q  mod inforec.p = 1 then
        inforec.number := 2;
        inforec.types := [ "Dpq", "pq" ];
    else
        inforec.number := 1;
        inforec.types := [ "pq" ];
    fi;
    return inforec;
end;

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 5 ]( size, inforec )
##
## order p ^ 2 * q
##
NUMBER_SMALL_GROUPS_FUNCS[ 5 ] := function( size, inforec )
    local p, q;

    p := inforec.p;
    q := inforec.q;
    inforec.types := [ ];
    
    if q mod p = 1 then
        Add( inforec.types, "Gp2q" );
    fi;
    
    Add( inforec.types, "p2q" );

    if q mod ( p ^ 2 ) = 1 then
        Add( inforec.types, "Hp2q" );
    fi;

    if size = 12 then
        Add( inforec.types, "a4" );
    fi;

    if q mod p = 1 then
        Add( inforec.types, "Dpqxp" );
    fi;

    Add( inforec.types, "ppq" );

    inforec.number := Length( inforec.types );
    return inforec;
end;

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 6 ]( size, inforec )
##
## order p * q ^ 2 
##
NUMBER_SMALL_GROUPS_FUNCS[ 6 ] := function( size, inforec )
    local p, q;

    p := inforec.p;
    q := inforec.q;
    inforec.types := [ ];
    
    if q mod p = 1 then
        Add( inforec.types, "Mpq2" );
    fi;

    Add( inforec.types, "pq2" );

    if q mod p = 1 then
        Add( inforec.types, "Dpqxq" );
    fi;
    
    if p <> 2 and ( q + 1 ) mod p = 0 then
        Add( inforec.types, "Npq2" );
    fi;

    if q mod p = 1 then
        Append( inforec.types, 
                       Filtered( [ 1 .. p - 1 ], x -> x <= 1/x mod p ) );
    fi;

    Add( inforec.types, "pqq" );

    inforec.number := Length( inforec.types );
    return inforec;
end;

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 7 ]( size, inforec )
##
## order p * q * r 
##
NUMBER_SMALL_GROUPS_FUNCS[ 7 ] := function( size, inforec )
    local p, q, r;

    p := inforec.p;
    q := inforec.q;
    r := inforec.r;
    inforec.types := [ ];
    
    if r mod ( p * q ) = 1 then
        Add( inforec.types, "Hpqr" );
    fi;
    
    if r mod q = 1 then
        Add( inforec.types, "Dqrxp" );
    fi;
    
    if q mod p = 1 then
        Add( inforec.types, "Dpqxr" );
    fi;
    
    if r mod p = 1 then
        Add( inforec.types, "Dprxq" );
    fi;

    if r mod p = 1 and q mod p = 1 then
        Append( inforec.types, [ 1 .. p - 1 ] );
    fi;

    Add( inforec.types, "pqr" );

    inforec.number := Length( inforec.types );
    return inforec;
end;
