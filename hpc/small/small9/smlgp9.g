#############################################################################
##
#W  smlgp9.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##                                                 Mike Newman, Boris Girnat
##
##  This file contains the generic construction of groups of order p^4, p^5
##  and p^6 with order > 3125 (groups with order up to 3125 are contained in
##  the lower layers of the small groups library.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small9","1.0");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 9 ]
##
SMALL_AVAILABLE_FUNCS[ 9 ] := function( size )
    local p;

    if ( not IsPrimePowerInt( size ) ) or size <= 3125 then
        return fail;
    fi;

    p := FactorsInt( size );

    if Length( p ) = 4 then
        return rec( func := 19,
                    number := 15,
                    lib := 9,
                    p := p[ 1 ] );
    fi;

    if Length( p ) = 5 then
        return rec( func := 20,
                    number := 61 +
                              2 * p[ 1 ] +
                              2 * Gcd( 3, p[ 1 ] - 1 ) +
                              Gcd( 4, p[ 1 ] - 1 ),
                    lib := 9,
                    p := p[ 1 ] );
    fi;

    if Length( p ) = 6 then
        return rec( func := 21,
                    lib := 9,
                    p := p[ 1 ] );
    fi;

    return fail;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 19 ]( size, i, inforec )
##
## order p^4 , p >= 11
## 
## The groups of order p^4 (p >= 11) are given by pc presentations which are 
## produced at run-time by a function SMALL_GROUPS_FUNCS[ 19 ] provided by 
## Newman.
##
SMALL_GROUP_FUNCS[ 19 ] := function( size, i, inforec )
    local g, f, p, c, w;

    if i > 15 then
        Error( "there are just 15 groups of size ", size );
    fi;

    f := FreeGroup( 4 );
    p := inforec.p;
    c := CombinatorialCollector( f, [p,p,p,p] );
    w := IntFFE( Z ( p ) );

    if i = 1 then
        SetPower(c,1,f.2);
        SetPower(c,2,f.3);
        SetPower(c,3,f.4);
    elif i = 2 then
        SetPower(c,1,f.3);
        SetPower(c,2,f.4);
    elif i = 3 then
        SetCommutator(c,2,1,f.3);
        SetPower(c,1,f.4);
    elif i = 4 then
        SetCommutator(c,2,1,f.3);
        SetPower(c,1,f.4);
        SetPower(c,2,f.3);
    elif i = 5 then
        SetPower(c,1,f.3);
        SetPower(c,3,f.4);
    elif i = 6 then
        SetCommutator(c,2,1,f.4);
        SetPower(c,1,f.3);
        SetPower(c,3,f.4);
    elif i = 7 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
    elif i = 8 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetPower(c,1,f.4);
    elif i = 9 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetPower(c,2,f.4);
    elif i = 10 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetPower(c,2,f.4^w);
    elif i = 11 then
        SetPower(c,1,f.4);
    elif i = 12 then
        SetCommutator(c,2,1,f.4);
    elif i = 13 then
        SetCommutator(c,2,1,f.4);
        SetPower(c,1,f.4);
    elif i = 14 then
        SetCommutator(c,2,1,f.4);
        SetPower(c,3,f.4);
    elif i = 15 then
        # elementary abelian group
    fi; 

    g := GroupByRwsNC( c );
    SetIsPGroup( g, true );
    return g;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 20 ]( size, i, inforec )
##
## order p^5 , p >= 7
##
## The groups of order p^5 (p >= 7) are given by pc presentations which are 
## produced at run-time by a function SMALL_GROUPS_FUNCS[ 20 ] provided by 
## Girnat (2004) [10].
##
SMALL_GROUP_FUNCS[ 20 ] := function( size, i, inforec )
    local g, typ, k, f, c, w, p, a, b;

    if i > inforec.number then
        Error( "there are just ", inforec.number, " groups of size ", size );
    fi;

    f := FreeGroup( 5 );
    p := inforec.p;
    c := CombinatorialCollector( f, [p,p,p,p,p] );
    w := IntFFE( Z ( p ) );
    a := Gcd( p-1, 3 );
    b := Gcd( p-1, 4 );

    if i <= 10 then
        typ := i;
    elif i <= 11+(p-1)/2-1 then
        typ := 11;
        k := i - 10;
    elif i <= 11+p-2 then
        typ := 12;
        k := i - (11+(p-1)/2-1);
    elif i <= 25+p then
        typ := i - p + 3;
    elif i <= 25+p+a then
        typ := 29;
        k := i - (25+p);
    elif i <= 27+p+a then
        typ := i - p - a + 4;
    elif i <= 27+p+2*a then
        typ := 32;
        k := i - (27+p+a);
    elif i <= 27+p+2*a+b then
        typ := 33;
        k := i - (27+p+2*a);
    elif i <= 41+p+2*a+b then
        typ := i - p - 2*a - b + 6;
    elif i <= 41+p+2*a+b+(p-1)/2 then
        typ := 48;
        k := i - (41+p+2*a+b);
    elif i = 42+p+2*a+b+(p-1)/2 then
        typ := 49;
    elif i <= 42+p+2*a+b+p-1 then
        typ := 50;
        k := i - (42+p+2*a+b+(p-1)/2);
    else
        typ := i - 2*p - 2*a - b + 9;
    fi;

    if typ = 1 then
        SetPower(c,1,f.2);
        SetPower(c,2,f.3);
        SetPower(c,3,f.4);
        SetPower(c,4,f.5);
    elif typ = 2 then
        SetCommutator(c,2,1,f.3);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 3 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
    elif typ = 4 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,2,f.5);
    elif typ = 5 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,2,f.4);
    elif typ = 6 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,2,f.4^w);
    elif typ = 7 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 8 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4*f.5);
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 9 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4*f.5^w);
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 10 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5^w);
        SetCommutator(c,3,2,f.4);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 11 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5^(w^k mod p));
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 12 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4*f.5^(w^k mod p));
        SetCommutator(c,3,2,f.4^(w^(k-1) mod p)*f.5);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 13 then
        SetPower(c,1,f.3);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 14 then
        SetCommutator(c,2,1,f.5);
        SetPower(c,1,f.3);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 15 then
        SetCommutator(c,2,1,f.3);
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 16 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetPower(c,1,f.4);
    elif typ = 17 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 18 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5^w);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 19 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 20 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
    elif typ = 21 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
        SetPower(c,2,f.5);
    elif typ = 22 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 23 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5^w);
        SetCommutator(c,3,2,f.5^w);
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 24 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.5);
        SetCommutator(c,4,2,f.5^(p-1));
        SetPower(c,1,f.4);
        SetPower(c,2,f.3);
        SetPower(c,3,f.5); 
    elif typ = 25 then
        SetCommutator(c,2,1,f.3);
        SetPower(c,1,f.4);
        SetPower(c,2,f.3);
        SetPower(c,4,f.5);
    elif typ = 26 then
        SetPower(c,1,f.3);
        SetPower(c,3,f.4);
        SetPower(c,4,f.5);
    elif typ = 27 then
        SetCommutator(c,2,1,f.5);
        SetPower(c,1,f.3);
        SetPower(c,3,f.4);
        SetPower(c,4,f.5);
    elif typ = 28 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,4,1,f.5);
    elif typ = 29 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,4,1,f.5^(w^k mod p));
        SetPower(c,2,f.5);
    elif typ = 30 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,4,1,f.5);
        SetPower(c,1,f.5);
    elif typ = 31 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,4,1,f.5);
        SetCommutator(c,3,2,f.5);
    elif typ = 32 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,4,1,f.5^(w^k mod p));
        SetCommutator(c,3,2,f.5^(w^k mod p));
        SetPower(c,2,f.5);
    elif typ = 33 then
        SetCommutator(c,2,1,f.3);
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,4,1,f.5^(w^k mod p));
        SetCommutator(c,3,2,f.5^(w^k mod p));
        SetPower(c,1,f.5);
    elif typ = 34 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,3,1,f.5);
    elif typ = 35 then
        SetCommutator(c,2,1,f.4);
        SetPower(c,3,f.5);
    elif typ = 36 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,3,f.5);
    elif typ = 37 then
        SetCommutator(c,3,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 38 then
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,3,f.5);
    elif typ = 39 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,3,f.4);
    elif typ = 40 then
        SetCommutator(c,3,2,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 41 then
        SetCommutator(c,3,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 42 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,3,2,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 43 then
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 44 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,3,1,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 45 then
        SetCommutator(c,2,1,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 46 then
        SetCommutator(c,2,1,f.4*f.5);
        SetCommutator(c,3,1,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 47 then
        SetCommutator(c,3,1,f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 48 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,3,1,f.5^(w^k mod p));
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 49 then
        SetCommutator(c,2,1,f.5^w);
        SetCommutator(c,3,1,f.4);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 50 then
        SetCommutator(c,2,1,f.4*f.5^(w^k mod p));
        SetCommutator(c,3,1,f.4^(w^(k-1) mod p)*f.5);
        SetPower(c,2,f.4);
        SetPower(c,3,f.5);
    elif typ = 51 then
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 52 then
        SetCommutator(c,3,2,f.5);
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 53 then
        SetCommutator(c,3,1,f.5);
        SetPower(c,1,f.4);
        SetPower(c,4,f.5);
    elif typ = 54 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
    elif typ = 55 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetPower(c,3,f.5);
    elif typ = 56 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetPower(c,2,f.5);
    elif typ = 57 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetPower(c,1,f.5);
    elif typ = 58 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5^w);
        SetPower(c,1,f.5); 
    elif typ = 59 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetCommutator(c,3,1,f.5);
    elif typ = 60 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetCommutator(c,3,1,f.5);
        SetPower(c,3,f.5);
    elif typ = 61 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetCommutator(c,3,1,f.5);
        SetPower(c,2,f.5);
    elif typ = 62 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5);
        SetCommutator(c,3,1,f.5);
        SetPower(c,1,f.5);
    elif typ = 63 then
        SetCommutator(c,2,1,f.4);
        SetCommutator(c,4,2,f.5^w);
        SetCommutator(c,3,1,f.5^w);
        SetPower(c,1,f.5);
    elif typ = 64 then
        SetCommutator(c,2,1,f.5);
    elif typ = 65 then
        SetCommutator(c,2,1,f.5);
        SetCommutator(c,4,3,f.5);
    elif typ = 66 then
        SetPower(c,1,f.5);
    elif typ = 67 then
        SetCommutator(c,2,1,f.5);
        SetPower(c,1,f.5);
    elif typ = 68 then
        SetCommutator(c,2,1,f.5);
        SetPower(c,3,f.5);
    elif typ = 69 then
        SetCommutator(c,2,1,f.5);
        SetCommutator(c,4,3,f.5);
        SetPower(c,4,f.5);
    elif typ = 70 then
        # elementary abelian group
    fi; 

    g := GroupByRwsNC( c );
    SetIsPGroup( g, true );
    return g;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 21 ]( size, i, inforec )
##
## order p^6 , p >= 5
##
## The groups of order p^6 (p >= 5) are given by pc presentations which are 
## produced at run-time by a function SMALL_GROUPS_FUNCS[ 21 ] provided by 
## Newman, O'Brien and Vaughan-Lee (2003) [13].
##
## The groups of order p^6 are given as a list of partially repetitive structures.
## These are compressed into the file 'sml1.z'. At run-time, this compressed 
## structure will be expanded, but restricted to those parts of the structure 
## relevant for the given p when needed. It is cached into SMALL_GROUP_LIB[1]. 
## As parts of this structure contain long ( O(p^2) ) lists of groups which are 
## classified by additional parameters and these lists are not dense, it might 
## be neccessary to set up the complete list of indices to find the presentation 
## of a single group.
## 
SMALL_GROUP_FUNCS[ 21 ] := function( size, i, inforec )
    local n, p, phi, part,
          j, ind, ri, g, j1, j2, k, l, m, c1, c2,
          r, mem, rel,
          F, famRels, grpRels;
    
    if not IsBound( inforec.F ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 21 ]( size, inforec );
    fi;

    atomic inforec do

    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    if i <= 11 then
        part := [ [ 6 ],
                  [ 5, 1 ],
                  [ 4, 2 ], [ 4, 1, 1 ],
                  [ 3, 3 ], [ 3, 2, 1 ], [ 3, 1, 1, 1 ],
                  [ 2, 2, 2 ], [ 2, 2, 1, 1 ], [ 2, 1, 1, 1, 1 ],
                  [ 1, 1, 1, 1, 1, 1 ] ];

        return AbelianGroup( IsPcGroup, List( part[i], x -> inforec.p^x ) );
    fi;

    F := inforec.F;
    p := inforec.p;

    phi := 0;
    repeat
        phi := phi + 1;
        i := i - inforec.num[ phi ];
    until i <= 0;
    i := i + inforec.num[ phi ];

    od; # atomic inforec
    
    if not IsBound( SMALL_GROUP_LIB[ 1 ] ) then
        ReadSmallLib( "sml", 9, 1, [ ] );
        atomic readwrite SMALL_GROUP_LIB[ 1 ] do
            SMALL_GROUP_LIB[ 1 ][ 1 ] := MigrateObj( inforec, SMALL_GROUP_LIB[ 1 ] );
            # now inforec is in the same region with SMALL_GROUP_LIB[ 1 ] and
            # we will hold the lock on this region until the group is returned
        od;    
    fi;

    atomic readwrite SMALL_GROUP_LIB[ 1 ] do
    
    if not IsBound( inforec.groups[ phi ] ) then
        inforec.groups[ phi ] := [];
        for j in [ 1 .. Length( SMALL_GROUP_LIB[ 1 ][ phi ] ) ] do

            n := SMALL_GROUP_LIB[ 1 ][ phi ][ j ][ 1 ];
            r := rec( classBound := n mod 7,
                      famMems := [ ] );
            n := QuoInt( n, 7 );

            famRels := ShallowCopy( inforec.genRels );
            while n > 0 do
                Unbind( famRels[ n mod 22 ] );
                n := QuoInt( n, 22 );
            od;

            n := SMALL_GROUP_LIB[ 1 ][ phi ][ j ][ 2 ];
            while n > 0 do
                ind := n mod 22;
                n := QuoInt( n, 22 );
                ri := One( F );
                l := n mod 3;
                n := QuoInt( n, 3 );
                for m in [ 1 .. l ] do
                    g := F.(n mod 7);
                    n := QuoInt( n, 7 );
                    j2 := n mod 50;
                    n := QuoInt( n, 50 );
                    ri := ri * g^SMALL_GROUP_FUNCS[23]( j2, inforec, fail );
                od;
                famRels[ ind ] := famRels[ ind ] / ri;
            od;
            r.famRels := famRels;

            for n in SMALL_GROUP_LIB[ 1 ][ phi ][ j ][ 3 ] do
                c1 := n mod 9;
                n := QuoInt( n, 9 );
                c2 := n mod 22;
                n := QuoInt( n, 22 );
                mem := rec( num := SMALL_GROUP_FUNCS[ 22 ]( c1, c2, p ),
                            rels := [] );
                if mem.num > 0 then
                    while n > 0 do
                        rel := rec( ind := n mod 22,
                                    exli := [ ] );
                        n := QuoInt( n, 22 );
                        l := n mod 3;
                        n := QuoInt( n, 3 );
                        for m in [ 1 .. l ] do
                            j1 := n mod 7;
                            n := QuoInt( n, 7 );
                            j2 := n mod 50;
                            n := QuoInt( n, 50 );
                            Add( rel.exli, [ j1, j2 ] );
                        od;
                        Add( mem.rels, rel );
                    od;
                    Add( r.famMems, mem );
                fi;
            od;
            Add( inforec.groups[ phi ], r );
        od;
    fi;

    j := 1;
    k := 1;
    while i > inforec.groups[ phi ][ j ].famMems[ k ].num do
        i := i - inforec.groups[ phi ][ j ].famMems[ k ].num;
        k := k + 1;
        if k > Length( inforec.groups[ phi ][ j ].famMems ) then
            j := j + 1;
            k := 1;
        fi;
    od;

    grpRels := ShallowCopy( inforec.groups[ phi ][ j ].famRels );
    for rel in inforec.groups[ phi ][ j ].famMems[ k ].rels do
        ri := One( F );
        for m in rel.exli do
            ri := ri * F.(m[1])^SMALL_GROUP_FUNCS[23]( m[2], inforec, i );
        od;
        grpRels[ rel.ind ] := grpRels[ rel.ind ] / ri;
    od;

##    return Image( EpimorphismQuotientSystem( PQuotient( F/Set( grpRels ),
##                  p, inforec.groups[ phi ][ j ].classBound ) ) );
    j:= EpimorphismQuotientSystem( PQuotient( F/Set( grpRels ),
                  p, inforec.groups[ phi ][ j ].classBound ) );
    i := Image( j );
    i!.eqs := j;
    return i;

    od; # atomic readwrite SMALL_GROUP_LIB[ 1 ]
        
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 22 ]( c1, c2, p )
##
## 
SMALL_GROUP_FUNCS[ 22 ] := function( c1, c2, p )

    if c1 = 0 or
       c1 = 1 and p mod 3 = 1 or
       c1 = 2 and p mod 4 = 1 or
       c1 = 3 and p mod 4 = 3 or
       c1 = 4 and p mod 5 = 1 or
       c1 = 5 and p = 5 or
       c1 = 6 and p <> 5 or
       c1 = 7 and p <> 5 and p mod 4 = 1 or
       c1 = 8 and p <> 5 and p mod 3 = 2 then
        if c2 <= 5 then
            return c2;
        elif c2 = 6 then
            return p;
        elif c2 = 7 then
            return p-1;
        elif c2 = 8 then
            return p-2;
        elif c2 = 9 then
            return p-3;
        elif c2 = 10 then
            return p - 3 + Gcd( p-1, 4 ) / 2;
        elif c2 = 11 then
            return (p-1)/2;
        elif c2 = 12 then
            return (p-3)/2;
        elif c2 = 13 then
            return 2*p-2;
        elif c2 = 14 then
            return 2*p-4;
        elif c2 = 15 then
            return p*(p-1)/2;
        elif c2 = 16 then
            return (p-1)*(p-1)/2;
        elif c2 = 17 then
            return p*(p-1)/2 - 11/4*p + (1/4*p-1)*Gcd(p-1,4) + 23/4;
        elif c2 = 18 then
            return p*(p-1)/2 + 3/4*p + (-1/4*p+1/2)*Gcd(p-1,4) - 7/4;
        elif c2 = 19 then
            return (p-2)*(p-1)/2;
        elif c2 = 20 then
            return (p-2)*(p-1)/2-1;
        elif c2 = 21 then
            return (p-2)*(p-1)/2+1;
        fi;
    else
       return 0;
    fi;
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 23 ]( j2, inforec )
##
## 
SMALL_GROUP_FUNCS[ 23 ] := function( j2, inforec, ii )
    local p, pr, nqr, nqrm, squares,
          cart, f, gg, k, r, s, t, x, y, z;

    p := inforec.p;
    pr := inforec.pr;
    nqr := inforec.nqr;
    nqrm := inforec.nqrm;
    squares := inforec.squares;

    if j2 in [ 20, 21, 45, 46 ] and not IsBound( inforec.epx ) then
        x := 1;
        y := 0;
        repeat
            y := y + 1;
            if y = p then
                x := x + 1;
                y := 1;
            fi;
        until ( x*x - nqrm*y*y ) mod p = nqrm;
        inforec.epx := x;
        inforec.epy := y;
    fi;

    if j2 = 0 then
        return -1;
    elif j2 <= 2 then
        return j2;
    elif j2 <= 7 then
        return j2 + ii - 5;
    elif j2 = 8 then
        return -ii + 1;
    elif j2 = 9 then
        if ii = 1 then
            return 0;
        fi;
        return -ii;
    elif j2 <= 21 then
        if inforec.activeCache <> j2 then
            inforec.activeCache := j2;
            if j2 = 10 then
                inforec.listCache :=
                    Filtered( Cartesian( [ 1, nqr ], [ 1 .. p-1 ] ),
                        x -> ( 1 + 4*x[1]*x[2] ) mod p <> 0 and
                             ( 1 + 4*x[1]*x[2] ) mod p in squares );
            elif j2 = 11 then
                inforec.subCache := Cartesian( [ 1, nqr ], [ 1 .. p-1 ] );
                inforec.subCacheLength := [ ];
                for r in [ 1, nqr ] do
                    for s in [ 1 .. p-1 ] do
                        x := 0;
                        for k in List( [ 0 .. (p-1)/2 ], x -> pr^x mod p ) do
                            if k <> r*s mod p and
                               ((1-k)^2+4*r*s) mod p <> 0 and
                               ((1-k)^2+4*r*s) mod p in squares and
                               not ( r=nqr and
                                     k in [1,p-1] and
                                     ( -s mod p in squares ) ) then
                                x := x + 1;
                            fi;
                        od;
                        Add( inforec.subCacheLength, x );
                    od;
                od;
            elif j2 = 12 then
                inforec.listCache := 
                    Filtered( Cartesian( [ 1, nqr ], [ 1 .. p-1 ] ),
                        x -> not( 
                            ( 1 + 4*x[1]*x[2] ) mod p in squares ) );
            elif j2 = 13 then
                inforec.subCache := Cartesian( [ 1, nqr ], [ 1 .. p-1 ] );
                inforec.subCacheLength := [ ];
                for r in [ 1, nqr ] do
                    for s in [ 1 .. p-1 ] do
                        x := 0;
                        for k in List( [ 0 .. (p-1)/2 ], x -> pr^x mod p ) do
                            if k <> r*s mod p and
                               not ( ( (1-k)^2+4*r*s ) mod p ) in squares and
                               not ( r=nqr and
                                     k in [1,p-1] and
                                     ( -s mod p in squares ) ) then
                                x := x + 1;
                            fi;
                        od;
                        Add( inforec.subCacheLength, x );
                    od;
                od;
            elif j2 = 14 then
                inforec.listCache := 
                    Filtered( Cartesian( [ 1, nqr ], [ 0 .. p-1 ] ),
                        x -> ( 1 + 4*x[1]*x[2] ) mod p = 0 );
            elif j2 = 15 then
                inforec.listCache := [];
                for r in [ 1, nqr ] do
                    for k in List( [ 1 .. (p-3)/2 ], x -> pr^x mod p ) do
                        for t in [ 0 .. p-1 ] do
                            if ( 4*r*t + (1-k)^2) mod p = 0 then
                                Add( inforec.listCache, [ r, t, k ] );
                            fi;
                        od;
                    od;
                od;
            elif j2 = 16 then
                x := Int( p / 4 );
                inforec.subCache := [ 1 .. p-1 ];
                inforec.subCacheLength :=
                    Concatenation( [ 1 .. x ] * 0 + (p-3)/2,
                                   [ 1 .. p - 1 - 2*x ] * 0 + (p-1)/2,
                                   [ 1 .. x ] * 0 + (p+1)/2 );
            elif j2 = 17 then
                inforec.listCache := [];
                for r in [ 1, nqr ] do
                    for gg in List( [ 0 .. (p-3)/2 ], x -> pr^x mod p ) do
                        if not ( p mod 4 = 3 and 
                                 r = nqr and
                                 gg = 1 ) then
                            Add( inforec.listCache, [r,gg/r mod p,gg] );
                        fi;
                    od;
                od;
            elif j2 = 18 then
                inforec.listCache := List(
                     Filtered( [ 1 .. p-1 ], x-> x^2 mod p <> p-nqr ),
                     x -> [ nqrm * x mod p, x ] );
            elif j2 = 19 then
                if p mod 4 = 1 then
                    inforec.subCache := [ 1 .. p-1 ];
                    inforec.subCacheLength := [ 1 .. p-1 ] * 0 + ((p-1)/2);
                    for x in Filtered( [ 2 .. p-2 ],
                                      z -> (z^2-1)/nqrm mod p in squares ) do
                        inforec.subCacheLength[ x ] := (p-3)/2;
                    od;
                else
                    inforec.subCache := [ 1 .. (p-1)/2 ];
                    inforec.subCacheLength := [ 1 .. (p-1)/2 ] * 0 + (p-1);
                    for x in Filtered( [ 2 .. (p-1)/2 ],
                                      z -> (z^2-1)/nqrm mod p in squares ) do
                        inforec.subCacheLength[ x ] := p - 3;
                    od;
                fi;
            elif j2 = 20 then
                if p mod 4 = 1 then
                    cart := Filtered( [ 1..p-1 ], l -> l^2 mod p <> p-1 );
                else
                    cart := [ 1 .. (p-1)/2 ];
                fi;
                inforec.listCache := List( cart,
                    c -> [ nqrm * ( c - inforec.epy ) mod p , -inforec.epx,
                           inforec.epx, ( c + inforec.epy ) mod p] );
            elif j2 = 21 then
                if p mod 4 = 1 then
                    inforec.subCache := [ 1 .. (p-1)/2 ];
                    inforec.subCacheLength := [ 1 .. (p-1)/2 ] * 0 + (p-1);
                    for x in Filtered( [ 1 .. (p-1)/2 ],
                                       z -> (z^2*nqr-1) mod p in squares ) do
                        inforec.subCacheLength[ x ] := p - 3;
                    od;
                else
                    inforec.subCache := [ 1 .. p-1 ];
                    inforec.subCacheLength := [ 1 .. p-1 ] * 0 + ((p-1)/2);
                    for x in Filtered( [ 1 .. p-1 ],
                                       z -> (z^2*nqr-1) mod p in squares ) do
                        inforec.subCacheLength[ x ] := (p-3)/2;
                    od;
                fi;
            fi;
            inforec.activeSubCache := fail;
        fi;
        if j2 in [ 11, 13, 16, 19, 21 ] then
            x := 1;
            while ii > inforec.subCacheLength[ x ] do
                ii := ii - inforec.subCacheLength[ x ];
                x := x + 1;
            od;
            if x <> inforec.activeSubCache then
                inforec.activeSubCache := x;
                x := inforec.subCache[ x ];
                inforec.listCache := [];
                if j2 = 11 then
                    r := x[ 1 ];
                    s := x[ 2 ];
                    for k in List( [ 0 .. (p-1)/2 ], x -> pr^x mod p ) do
                        if k <> r*s mod p and
                           ((1-k)^2+4*r*s) mod p <> 0 and
                           ((1-k)^2+4*r*s) mod p in squares and
                           not ( r=nqr and
                                 k in [1,p-1] and
                                 ( -s mod p in squares ) ) then
                            Add( inforec.listCache, [ r, s, k ] );
                        fi;
                    od;
                elif j2 = 13 then
                    r := x[ 1 ];
                    s := x[ 2 ];
                    for k in List( [ 0 .. (p-1)/2 ], x -> pr^x mod p ) do
                        if k <> r*s mod p and
                           not ( ( (1-k)^2+4*r*s ) mod p ) in squares and
                           not ( r=nqr and
                                 k in [1,p-1] and
                                 ( -s mod p in squares ) ) then
                            Add( inforec.listCache, [ r, s, k ] );
                        fi;
                    od;
                elif j2 = 16 then
                    for z in Filtered( [ 0 .. (p-1)/2 ],
                                       y -> x <> y and 2*x mod p <> y ) do
                        Add( inforec.listCache, [ x, z - x ] );
                    od;
                elif j2 = 19 then
                    if p mod 4 = 1 then
                        k := (p-1) / 2;
                    else
                        k := p - 1;
                    fi;
                    for z in Filtered( [ 1 .. k ],
                                      c -> ( x^2 - nqrm*c^2 ) mod p <> 1 ) do
                        Add( inforec.listCache, [ nqrm * z mod p, x - 1,
                                                  x + 1,          z     ] );
                    od;
                elif j2 = 21 then
                    if p mod 4 = 1 then
                        k := p - 1;
                    else
                        k := (p-1) / 2;
                    fi;
                    for z in Filtered( [ 1 .. k ],
                                   c -> ( x^2 - nqrm*c^2 ) mod p <> nqrm ) do
                        Add( inforec.listCache,
                                     [ nqrm * ( z - inforec.epy ) mod p,
                                       x - inforec.epx,
                                       ( x + inforec.epx ) mod p,
                                       ( z + inforec.epy ) mod p ] );
                    od;
                fi;
            fi;
        fi;
        inforec.ExpCache := inforec.listCache[ ii ];
        return inforec.ExpCache[ 1 ];
    elif j2 <= 24 then
        return inforec.ExpCache[ j2 - 20 ];
    elif j2 = 25 then
        return nqr;
    elif j2 = 26 then
        return nqrm;
    elif j2 = 27 then
        return -nqr;
    elif j2 = 28 then
        return -nqrm;
    elif j2 = 29 then
        return 2*nqr;
    elif j2 = 30 then
        if ii mod 2 = 1 then
            return 1;
        else
            return nqr;
        fi;
    elif j2 = 31 then
        if ii <= 2 then
            return 1;
        else
            return nqr;
        fi;
    elif j2 = 32 then
        if ii = 1 then
            return -1;
        else
            return -nqrm;
        fi;
    elif j2 = 33 then
        return nqr * ii;
    elif j2 = 34 then
        return nqrm * ii;
    elif j2 = 35 then
        return pr^ii mod p;
    elif j2 = 36 then
        return 2*pr^ii mod p;
    elif j2 = 37 then
        return -pr^ii mod p;
    elif j2 = 38 then
        return ( -1 + pr^(ii*2-1) ) mod p;
    elif j2 = 39 then
        x := 1;
        y := 0;
        repeat
            y := y + 1;
            if y = p then
                x := x + 1;
                y := 1;
            fi;
        until ( x*x - nqrm*y*y ) mod p = ii+1;
        inforec.ExpCache := [ , -nqrm*y, y, 1+x ];
        return 1-x;
    elif j2 = 40 then
        if ii < p then
            if ii = 1 then
                inforec.ExpCache := [ , 0 ];
            else
                inforec.ExpCache := [ , ii ];
            fi;
            return 1;
        else
            if ii < p + nqrm then
                inforec.ExpCache := [ , ii - p ];
            else
                inforec.ExpCache := [ , ii - p + 1 ];
            fi;
            return nqr;
        fi;
    elif j2 = 41 then
        if ii < p then
            inforec.ExpCache := [ , ii ];
            return 1;
        else
            inforec.ExpCache := [ , ii - ( p-1 ) ];
            return nqr;
        fi;
    elif j2 = 42 then
        if ii <= p-2 then
            inforec.ExpCache := [ , ii + 1 ];
            return 1;
        else
            inforec.ExpCache := [ , ii - p + 3 ];
            return nqr;
        fi;
    elif j2 = 43 then
        if ii <= (p-1)/2 then
            inforec.ExpCache := [ , ii ];
            return 1;
        else
            inforec.ExpCache := [ , ii - ( p-1 ) / 2 ];
            return nqr;
        fi;
    elif j2 = 44 then
        x := Int( (ii-1) / ((p-1)/2) );
        inforec.ExpCache := [ , ii - x * (p-1)/2 ];
        return x;
    elif j2 = 45 then
        inforec.ExpCache := [            , -inforec.epx, 
                              inforec.epx, inforec.epy   ];
        return -nqrm * inforec.epy mod p;
    elif j2 = 46 then
        inforec.ExpCache := [                           , ii - inforec.epx, 
                              ( ii + inforec.epx ) mod p, inforec.epy      ];
        return -nqrm * inforec.epy mod p;
    elif j2 = 47 then
        return -( (ii-2) / 3 mod 5 );
    elif j2 <= 49 then
        if j2 = 48 then
            f := 1;
        else
            f := nqrm;
        fi;
        x := 0;
        y := 0;
        repeat
            y := y + 1;
            if y = p then
                x := x + 1;
                y := 0;
            fi;
        until ( x*x - f*y*y ) mod p = ii;
        inforec.ExpCache := [ , -y+1 ];
        return -x-1;
    fi;
end;

#############################################################################
##
#F SELECT_SMALL_GROUPS_FUNCS[ 19, 20, 21 ]( funcs, vals, inforec, all, id )
##
SELECT_SMALL_GROUPS_FUNCS[ 19 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];
SELECT_SMALL_GROUPS_FUNCS[ 20 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];
SELECT_SMALL_GROUPS_FUNCS[ 21 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 21 ]( size, inforec )
##
## order p^6 , p >= 6
##
NUMBER_SMALL_GROUPS_FUNCS[ 21 ] := function( size, inforec )
    local p, p2, pp2, a, b, c, i, j;

    if IsBound( SMALL_GROUP_LIB[ 1 ] ) then
        atomic readonly SMALL_GROUP_LIB[ 1 ] do
            if IsBound( SMALL_GROUP_LIB[ 1 ][ 1 ] ) and
                        SMALL_GROUP_LIB[ 1 ][ 1 ].p = inforec.p then
                return SMALL_GROUP_LIB[ 1 ][ 1 ];
            fi;
        od;
    fi;    
    
    p := inforec.p;
    p2 := (p-1) / 2;
    pp2 := p*p2;
    a := Gcd( 3, p-1 );
    b := Gcd( 4, p-1 );
    c := Gcd( 5, p-1 );

    inforec.num := [ 11, 31, 32, 3*p+32, 7, 2*p+21, 21, p+5, 3*a+7,
        3*a+3*b+4, 2*p+10, p+13, p+10, 3, p+3, p+a+12, 4*p+a+30, 3*p+a+b+9,
        3*pp2+6*p+p2+11, 5*p+a+b+13, 3*pp2+4*p-p2+2, 7, p+4*a+b+5, a+3, p2+2,
        p2+2, a+b+3, p, p, 2*a+4, 7, 5, 6, 3, b+2, 2*a+b+1, b+4, p+b+c,
        p+2*a+c, a+2, a+1, p+1, p];

    inforec.number := Sum( inforec.num ); 

    inforec.F := FreeGroup( IsSyllableWordsFamily, 6, "q" );
    inforec.genRels := [];
    for i in [ 1 .. 6 ] do
        Add( inforec.genRels, inforec.F.(i)^p );
    od;
    for j in [ 2 .. 6 ] do
        for i in [ 1 .. j-1 ] do
            Add( inforec.genRels, Comm( inforec.F.(i), inforec.F.(j) ) );
        od;
    od;

    inforec.groups := [];
    inforec.activeCache := fail;

    inforec.pr := Int( PrimitiveRoot( GF( p ) ) );
    inforec.squares := Set( List( [ 0 .. p - 1 ], x -> x ^ 2 mod p ) );
    inforec.nqr := 1;
    repeat
        inforec.nqr := inforec.nqr + 1;
    until not inforec.nqr in inforec.squares;
    inforec.nqrm :=  1 / inforec.nqr mod p;

    if IsBound( SMALL_GROUP_LIB[ 1 ] ) then
        atomic readwrite SMALL_GROUP_LIB[ 1 ] do
           SMALL_GROUP_LIB[ 1 ][ 1 ] := MigrateObj( inforec, SMALL_GROUP_LIB[ 1 ] );
        od;
    fi;
    return inforec;
    
end;
