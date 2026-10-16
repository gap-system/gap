#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Benchmark cases for the partition backtrack in lib/stbcbckt.gi, run by
##  ../run.py or all at once by test1.g, see ../README. Most cases ask for
##  the normalizer of a subgroup E of a symmetric group S, or for an
##  element of S conjugating E to a subgroup F; the rest are centralizers,
##  set stabilizers and intersections, which use the same search.
##
##  How a case is made, from the bottom up:
##
##  1. BENCH_AddCase( name, category, needs, setup, run ) in ../runner.g
##     records a case. setup() builds the input and is not timed; run(input)
##     computes the result and is timed.
##
##  2. A conjugacy or normalizer problem is a record with components S, E
##     and F. The functions BENCH_Conj, BENCH_ConjPBT, BENCH_Norm,
##     BENCH_NormPBT and BENCH_NonConj below are `run' functions for such a
##     record; the names of the cases end in the problem solved:
##       conj      RepresentativeAction( S, E, F ), F a conjugate of E
##       norm      Normalizer( S, E )
##       nonconj   RepresentativeAction( S, E, F ), F of the same order as E
##                 but not conjugate to it
##       conj.pbt, norm.pbt
##                 the same by ConjugatorPermGroup and NormalizerPermGroup,
##                 which skip the methods for subgroups of symmetric groups
##                 in lib/gpprmsya.gi and go straight to the backtrack
##
##  3. BENCH_PairCases( category, name, needs, problem ) adds the four cases
##     <name>.conj, .conj.pbt, .norm and .norm.pbt for a function `problem'
##     returning such a record.
##
##  4. BENCH_GroupCases( category, name, needs, group ) does the same for a
##     function returning a group: E gets random generators and F is a
##     random conjugate of E (BENCH_ConjugatePair). Random generators are
##     used because the generators from a group library can let the search
##     succeed on its first branch by luck.
##
##  To add a group, call BENCH_GroupCases with a function constructing it;
##  for a pair of groups given explicitly, BENCH_PairCases; for anything
##  else, BENCH_AddCase. Each case must have a unique name.
##

BENCH_DIR := Concatenation( BENCH.dir, "/", BENCH.suite );

#############################################################################
##
##  constructing the input of a case
##

# two random elements of <G>, and more until they generate <G>
BENCH_RandomGens := function( G )
    local   gens;

    gens := [ Random( G ), Random( G ) ];
    while Size( Subgroup( G, gens ) ) < Size( G )  do
        Add( gens, Random( G ) );
    od;
    return gens;
end;

# the problem record for <G> with random generators and a random conjugate
BENCH_ConjugatePair := function( G )
    local   S,  gens,  x;

    S := SymmetricGroup( LargestMovedPoint( G ) );
    gens := BENCH_RandomGens( G );
    x := Random( S );
    return rec( S := S, E := Group( gens ),
                F := Group( List( gens, g -> g ^ x ) ) );
end;

# a copy of <G> without its stored attributes, such as a stabilizer chain
BENCH_Fresh := G -> Group( GeneratorsOfGroup( G ) );

# the files in data/ assign the record BENCH_DATA
BENCH_DATA := fail;
BENCH_ReadData := function( name )
    Read( Concatenation( BENCH_DIR, "/data/", name, ".g" ) );
    return BENCH_DATA;
end;

# the action of <G> on the cosets of a Sylow <p>-subgroup
BENCH_CosetAction := function( G, p )
    return Image( FactorCosetAction( G, SylowSubgroup( G, p ) ) );
end;

# S_m x S_m acting on the m x m grid
BENCH_Grid := function( m )
    local   D,  pts;

    D := DirectProduct( SymmetricGroup( m ), SymmetricGroup( m ) );
    pts := Cartesian( [ 1 .. m ], [ 1 .. m ] );
    return Action( D, pts, function( pt, d )
        return [ pt[ 1 ] ^ Image( Projection( D, 1 ), d ),
                 pt[ 2 ] ^ Image( Projection( D, 2 ), d ) ];
    end );
end;

# a random subset of [ 1 .. n ] with about k elements
BENCH_RandomSubset := function( n, k )
    return Set( List( [ 1 .. k ], i -> Random( [ 1 .. n ] ) ) );
end;

#############################################################################
##
##  the problems, as `run' functions for a record with S, E and F
##

BENCH_Conj := function( p )
    local   r;

    r := RepresentativeAction( p.S, p.E, p.F );
    return r <> fail and p.E ^ r = p.F;
end;

BENCH_ConjPBT := function( p )
    local   r;

    r := ConjugatorPermGroup( p.S, p.E, p.F );
    return r <> fail and p.E ^ r = p.F;
end;

BENCH_NonConj := p -> RepresentativeAction( p.S, p.E, p.F ) = fail;

BENCH_Norm := p -> Size( Normalizer( p.S, p.E ) );

BENCH_NormPBT := p -> Size( NormalizerPermGroup( p.S, p.E ) );

#############################################################################
##
##  adding the cases for a problem or a group
##

BENCH_PairCases := function( category, name, needs, problem )
    BENCH_AddCase( Concatenation( name, ".conj" ), category, needs,
                   problem, BENCH_Conj );
    BENCH_AddCase( Concatenation( name, ".conj.pbt" ), category, needs,
                   problem, BENCH_ConjPBT );
    BENCH_AddCase( Concatenation( name, ".norm" ), category, needs,
                   problem, BENCH_Norm );
    BENCH_AddCase( Concatenation( name, ".norm.pbt" ), category, needs,
                   problem, BENCH_NormPBT );
end;

BENCH_GroupCases := function( category, name, needs, group )
    BENCH_PairCases( category, name, needs,
                     {} -> BENCH_ConjugatePair( group( ) ) );
end;

# the case <name>.nonconj: E from <group>, F a random conjugate of the
# group from <other>, which must have the same order but not be conjugate
BENCH_NonConjCase := function( category, name, needs, group, other )
    BENCH_AddCase( Concatenation( name, ".nonconj" ), category, needs,
        function( )
            local   p,  x;

            p := BENCH_ConjugatePair( group( ) );
            x := Random( p.S );
            p.F := Group( List( GeneratorsOfGroup( other( ) ), g -> g ^ x ) );
            return p;
        end, BENCH_NonConj );
end;

#############################################################################
##
##  the examples from issue #3718, with the groups as given there
##

BENCH_PairCases( "issue3718", "i3718-deg31", [  ], function( )
    local   d;

    d := BENCH_ReadData( "issue3718-deg31" );
    return rec( S := SymmetricGroup( 31 ), E := BENCH_Fresh( d.G ),
                F := BENCH_Fresh( d.H ) );
end );

BENCH_PairCases( "issue3718", "i3718-deg1125", [  ], function( )
    local   d;

    d := BENCH_ReadData( "issue3718-deg1125" );
    return rec( S := SymmetricGroup( 1125 ), E := BENCH_Fresh( d.g ),
                F := BENCH_Fresh( d.h ) );
end );

# the actions of the same groups on their 375 blocks of size 3
BENCH_PairCases( "issue3718", "i3718-deg375", [  ], function( )
    local   d,  act;

    d := BENCH_ReadData( "issue3718-deg1125" );
    act := G -> Action( G, Blocks( G, [ 1 .. 1125 ] ), OnSets );
    return rec( S := SymmetricGroup( 375 ), E := act( d.g ), F := act( d.h ) );
end );

#############################################################################
##
##  primitive groups
##

BENCH_GroupCases( "primitive", "psl27", [  ], {} -> PSL( 2, 7 ) );
BENCH_GroupCases( "primitive", "psl211", [  ], {} -> PSL( 2, 11 ) );
BENCH_GroupCases( "primitive", "psl33", [  ], {} -> PSL( 3, 3 ) );
BENCH_GroupCases( "primitive", "psl34", [  ], {} -> PSL( 3, 4 ) );
BENCH_GroupCases( "primitive", "psl35", [  ], {} -> PSL( 3, 5 ) );
BENCH_GroupCases( "primitive", "psl37", [  ], {} -> PSL( 3, 7 ) );
BENCH_GroupCases( "primitive", "psl38", [  ], {} -> PSL( 3, 8 ) );
BENCH_GroupCases( "primitive", "psl39", [  ], {} -> PSL( 3, 9 ) );
BENCH_GroupCases( "primitive", "psl42", [  ], {} -> PSL( 4, 2 ) );
BENCH_GroupCases( "primitive", "psl43", [  ], {} -> PSL( 4, 3 ) );
BENCH_GroupCases( "primitive", "psl52", [  ], {} -> PSL( 5, 2 ) );
BENCH_GroupCases( "primitive", "psu33", [  ], {} -> PSU( 3, 3 ) );
BENCH_GroupCases( "primitive", "sz8", [  ],
                  {} -> SuzukiGroup( IsPermGroup, 8 ) );
BENCH_GroupCases( "primitive", "m11", [  ], {} -> MathieuGroup( 11 ) );
BENCH_GroupCases( "primitive", "m12", [  ], {} -> MathieuGroup( 12 ) );
BENCH_GroupCases( "primitive", "m22", [  ], {} -> MathieuGroup( 22 ) );
BENCH_GroupCases( "primitive", "m23", [  ], {} -> MathieuGroup( 23 ) );
BENCH_GroupCases( "primitive", "m24", [  ], {} -> MathieuGroup( 24 ) );
BENCH_NonConjCase( "primitive", "prim26-2-4", [ "primgrp" ],
    {} -> PrimitiveGroup( 26, 2 ), {} -> PrimitiveGroup( 26, 4 ) );

#############################################################################
##
##  actions on the cosets of Sylow subgroups
##

BENCH_GroupCases( "coset", "a6syl5", [  ],
                  {} -> BENCH_CosetAction( AlternatingGroup( 6 ), 5 ) );
BENCH_GroupCases( "coset", "s6syl3", [  ],
                  {} -> BENCH_CosetAction( SymmetricGroup( 6 ), 3 ) );
BENCH_GroupCases( "coset", "psl211syl2", [  ],
                  {} -> BENCH_CosetAction( PSL( 2, 11 ), 2 ) );
BENCH_GroupCases( "coset", "psl216syl2", [  ],
                  {} -> BENCH_CosetAction( PSL( 2, 16 ), 2 ) );
BENCH_GroupCases( "coset", "a7syl7", [  ],
                  {} -> BENCH_CosetAction( AlternatingGroup( 7 ), 7 ) );
BENCH_GroupCases( "coset", "psl33syl13", [  ],
                  {} -> BENCH_CosetAction( PSL( 3, 3 ), 13 ) );
BENCH_GroupCases( "coset", "m11syl11", [  ],
                  {} -> BENCH_CosetAction( MathieuGroup( 11 ), 11 ) );
BENCH_GroupCases( "coset", "psl34syl7", [  ],
                  {} -> BENCH_CosetAction( PSL( 3, 4 ), 7 ) );

#############################################################################
##
##  wreath products
##

BENCH_GroupCases( "wreath", "a5wrc7", [  ],
    {} -> WreathProduct( AlternatingGroup( 5 ),
                         CyclicGroup( IsPermGroup, 7 ) ) );
BENCH_GroupCases( "wreath", "psl27wrs4", [  ],
    {} -> WreathProduct( PSL( 2, 7 ), SymmetricGroup( 4 ) ) );
BENCH_GroupCases( "wreath", "m11wrc5", [  ],
    {} -> WreathProduct( MathieuGroup( 11 ), CyclicGroup( IsPermGroup, 5 ) ) );
BENCH_GroupCases( "wreath", "s3wrpsl35", [  ],
    {} -> WreathProduct( SymmetricGroup( 3 ), PSL( 3, 5 ) ) );
BENCH_GroupCases( "wreath", "c3wrs50", [  ],
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 3 ),
                         SymmetricGroup( 50 ) ) );
BENCH_GroupCases( "wreath", "s5wrs5der", [  ],
    {} -> DerivedSubgroup( WreathProduct( SymmetricGroup( 5 ),
                                          SymmetricGroup( 5 ) ) ) );
BENCH_GroupCases( "wreath", "d8wrpsl27", [  ],
    {} -> WreathProduct( DihedralGroup( IsPermGroup, 8 ), PSL( 2, 7 ) ) );
# C_2 wr AGL(1,13): the stabilizer of a point has orbits of lengths 1, 1
# and 24 only, so all structure is in the action on the blocks
BENCH_GroupCases( "wreath", "c2wragl113", [  ],
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 2 ),
              Group( (1,2,3,4,5,6,7,8,9,10,11,12,13),
                     (2,3,5,9,4,7,13,12,10,6,11,8) ) ) );

#############################################################################
##
##  imprimitive groups from the library of transitive groups on which the
##  search is known to be hard, and some pairs of the same order
##

for BENCH_di  in [ [ 20, 501 ], [ 20, 601 ], [ 20, 1001 ], [ 22, 37 ],
    [ 24, 2948 ], [ 24, 13353 ], [ 26, 77 ], [ 26, 79 ], [ 26, 81 ],
    [ 27, 581 ], [ 27, 835 ], [ 27, 926 ], [ 27, 1180 ], [ 28, 633 ],
    [ 28, 1481 ], [ 28, 1510 ], [ 30, 3379 ], [ 33, 106 ], [ 33, 116 ],
    [ 34, 100 ], [ 35, 82 ], [ 35, 187 ], [ 38, 60 ], [ 38, 61 ],
    [ 40, 23758 ], [ 42, 4894 ], [ 42, 6466 ], [ 44, 1048 ], [ 44, 1505 ],
    [ 44, 1524 ], [ 44, 1543 ], [ 44, 1562 ], [ 45, 4641 ], [ 45, 5459 ],
    [ 46, 37 ], [ 46, 40 ], [ 46, 47 ] ]  do
    BENCH_GroupCases( "transitive",
        Concatenation( "t", String( BENCH_di[ 1 ] ), "-",
                       String( BENCH_di[ 2 ] ) ),
        [ "transgrp" ], {} -> TransitiveGroup( BENCH_di[ 1 ], BENCH_di[ 2 ] ) );
od;

for BENCH_di  in [ [ 24, 2948, 2949 ], [ 27, 581, 582 ], [ 27, 926, 927 ],
    [ 28, 1481, 1482 ], [ 28, 1510, 1511 ], [ 35, 187, 188 ],
    [ 42, 4894, 4895 ], [ 44, 1048, 1049 ], [ 45, 5459, 5460 ] ]  do
    BENCH_NonConjCase( "transitive",
        Concatenation( "t", String( BENCH_di[ 1 ] ), "-",
                       String( BENCH_di[ 2 ] ) ),
        [ "transgrp" ], {} -> TransitiveGroup( BENCH_di[ 1 ], BENCH_di[ 2 ] ),
        {} -> TransitiveGroup( BENCH_di[ 1 ], BENCH_di[ 3 ] ) );
od;

#############################################################################
##
##  centralizers and conjugacy of elements; in a symmetric group through
##  RepOpElmTuplesPermGroup, as Centralizer has a special method there
##

for BENCH_n  in [ 100, 500 ]  do
    BENCH_AddCase( Concatenation( "s", String( BENCH_n ), ".cent.pbt" ),
        "element", [  ],
        function( )
            local   S;

            S := SymmetricGroup( BENCH_n );
            return rec( S := S, T := TrivialSubgroup( S ), x := Random( S ) );
        end,
        p -> Size( RepOpElmTuplesPermGroup( false, p.S, [ p.x ], [ p.x ],
                                             p.T, p.T ) ) );
    BENCH_AddCase( Concatenation( "s", String( BENCH_n ), ".tupconj.pbt" ),
        "element", [  ],
        function( )
            local   S;

            S := SymmetricGroup( BENCH_n );
            return rec( S := S, T := TrivialSubgroup( S ), x := Random( S ),
                        y := Random( S ), c := Random( S ) );
        end,
        function( p )
            local   r;

            r := RepOpElmTuplesPermGroup( true, p.S, [ p.x, p.y ],
                     [ p.x ^ p.c, p.y ^ p.c ], p.T, p.T );
            return r <> fail and p.x ^ r = p.x ^ p.c and p.y ^ r = p.y ^ p.c;
        end );
od;

BENCH_ElementCases := function( name, group )
    BENCH_AddCase( Concatenation( name, ".elmcent" ), "element", [  ],
        function( )
            local   G;

            G := group( );
            return rec( G := G, x := Random( G ) );
        end,
        p -> Size( Centralizer( p.G, p.x ) ) );
    BENCH_AddCase( Concatenation( name, ".elmconj" ), "element", [  ],
        function( )
            local   G;

            G := group( );
            return rec( G := G, x := Random( G ), c := Random( G ) );
        end,
        function( p )
            local   r;

            r := RepresentativeAction( p.G, p.x, p.x ^ p.c );
            return r <> fail and p.x ^ r = p.x ^ p.c;
        end );
end;

BENCH_ElementCases( "m24", {} -> MathieuGroup( 24 ) );
BENCH_ElementCases( "c3wrs50",
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 3 ),
                         SymmetricGroup( 50 ) ) );

#############################################################################
##
##  set stabilizers and transporters
##

for BENCH_n  in [ 15, 30 ]  do
    BENCH_AddCase( Concatenation( "grid", String( BENCH_n ), ".setstab" ),
        "setstab", [  ],
        function( )
            local   n;

            n := BENCH_n;
            return rec( G := BENCH_Grid( n ),
                        A := BENCH_RandomSubset( n ^ 2, QuoInt( n ^ 2, 2 ) ) );
        end,
        p -> Size( Stabilizer( p.G, p.A, OnSets ) ) );
    BENCH_AddCase( Concatenation( "grid", String( BENCH_n ), ".settrans" ),
        "setstab", [  ],
        function( )
            local   n,  G,  A;

            n := BENCH_n;
            G := BENCH_Grid( n );
            A := BENCH_RandomSubset( n ^ 2, QuoInt( n ^ 2, 2 ) );
            return rec( G := G, A := A, B := OnSets( A, Random( G ) ) );
        end,
        function( p )
            local   r;

            r := RepresentativeAction( p.G, p.A, p.B, OnSets );
            return r <> fail and OnSets( p.A, r ) = p.B;
        end );
od;

BENCH_AddCase( "m24.setstab", "setstab", [  ],
    function( )
        return rec( G := MathieuGroup( 24 ),
                    A := BENCH_RandomSubset( 24, 10 ) );
    end,
    p -> Size( Stabilizer( p.G, p.A, OnSets ) ) );

#############################################################################
##
##  intersections
##

# a primitive group with a random conjugate of S_a wr S_(n/a)
BENCH_MeetWreathCase := function( name, group, a )
    BENCH_AddCase( Concatenation( name, ".meetwr" ), "intersection", [  ],
        function( )
            local   G,  n,  W;

            G := group( );
            n := LargestMovedPoint( G );
            W := WreathProduct( SymmetricGroup( a ), SymmetricGroup( n / a ) );
            return rec( G := G, W := W ^ Random( SymmetricGroup( n ) ) );
        end,
        p -> Size( Intersection( p.G, p.W ) ) );
end;

BENCH_MeetWreathCase( "psl42", {} -> PSL( 4, 2 ), 3 );
BENCH_MeetWreathCase( "psl37", {} -> PSL( 3, 7 ), 19 );
BENCH_MeetWreathCase( "m24", {} -> MathieuGroup( 24 ), 4 );

BENCH_AddCase( "s3wrs10.meetconj", "intersection", [  ],
    function( )
        local   G;

        G := WreathProduct( SymmetricGroup( 3 ), SymmetricGroup( 10 ) );
        return rec( G := G, H := G ^ Random( SymmetricGroup( 30 ) ) );
    end,
    p -> Size( Intersection( p.G, p.H ) ) );

#############################################################################
##
##  many small problems at once, to see the overhead per call
##

BENCH_AddCase( "trans12-150-301.norm-batch", "overhead", [ "transgrp" ],
    function( )
        return rec( S := SymmetricGroup( 12 ),
                    L := List( [ 150 .. 301 ],
                               i -> BENCH_Fresh( TransitiveGroup( 12, i ) ) ) );
    end,
    p -> Sum( p.L, G -> Size( Normalizer( p.S, G ) ) ) );

BENCH_AddCase( "trans12-150-301.conj-batch", "overhead", [ "transgrp" ],
    function( )
        local   S;

        S := SymmetricGroup( 12 );
        return rec( S := S, L := List( [ 150 .. 301 ], function( i )
            local   G;

            G := TransitiveGroup( 12, i );
            return [ BENCH_Fresh( G ), G ^ Random( S ) ];
        end ) );
    end,
    p -> Number( p.L,
                 q -> RepresentativeAction( p.S, q[ 1 ], q[ 2 ] ) <> fail ) );

BENCH_AddCase( "s12.cent-batch.pbt", "overhead", [  ],
    function( )
        local   S;

        S := SymmetricGroup( 12 );
        return rec( S := S, T := TrivialSubgroup( S ),
                    L := List( [ 1 .. 50 ], i -> Random( S ) ) );
    end,
    p -> Sum( p.L, x -> Size( RepOpElmTuplesPermGroup( false, p.S, [ x ], [ x ],
                                                        p.T, p.T ) ) ) );
