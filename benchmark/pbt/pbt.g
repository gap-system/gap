#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Benchmark cases for the partition backtrack in lib/stbcbckt.gi, see
##  ../README: normalizers, conjugacy and centralizers of permutation
##  groups and elements, set stabilizers and intersections. Run them with
##  ../run.py, or all at once with test1.g.
##
##  Case names are <group>.<problem>. The problems for a group E and its
##  symmetric group S:
##    conj      RepresentativeAction(S, E, F) for a random conjugate F of E
##    norm      Normalizer(S, E)
##    nonconj   RepresentativeAction(S, E, F) for a group F of the same
##              order that is not conjugate to E
##    conj.pbt, norm.pbt
##              the same by ConjugatorPermGroup and NormalizerPermGroup,
##              which skip the methods for subgroups of symmetric groups
##  E is given by two random generators: the generators from a library
##  can let the search succeed on its first branch by luck.
##

BENCH_DIR := Concatenation( BENCH.dir, "/", BENCH.suite );

# set by the files in data/
BENCH_DATA := fail;

#############################################################################
##
##  helpers
##

BENCH_RandomGens := function( G )
    local   gens;

    repeat
        gens := [ Random( G ), Random( G ) ];
    until Size( Group( gens ) ) = Size( G );
    return gens;
end;

# <G> with random generators and a random conjugate of it
BENCH_Pair := function( G )
    local   n,  gens,  x;

    n := LargestMovedPoint( G );
    gens := BENCH_RandomGens( G );
    x := Random( SymmetricGroup( n ) );
    return rec( S := SymmetricGroup( n ), E := Group( gens ),
                F := Group( List( gens, g -> g ^ x ) ) );
end;

BENCH_Conj := function( a )
    local   r;

    r := RepresentativeAction( a.S, a.E, a.F );
    return r <> fail and a.E ^ r = a.F;
end;

BENCH_ConjPBT := function( a )
    local   r;

    r := ConjugatorPermGroup( a.S, a.E, a.F );
    return r <> fail and a.E ^ r = a.F;
end;

BENCH_NonConj := a -> RepresentativeAction( a.S, a.E, a.F ) = fail;

BENCH_Norm := a -> Size( Normalizer( a.S, a.E ) );

BENCH_NormPBT := a -> Size( NormalizerPermGroup( a.S, a.E ) );

BENCH_Case := function( name, category, needs, setup, run )
    Add( BENCH_CASES, rec( name := name, category := category,
                           needs := needs, setup := setup, run := run ) );
end;

# the four problems for the group returned by <constructor>
BENCH_Group := function( category, name, needs, constructor )
    local   setup;

    setup := function( )  return BENCH_Pair( constructor( ) );  end;
    BENCH_Case( Concatenation( name, ".conj" ), category, needs, setup,
                BENCH_Conj );
    BENCH_Case( Concatenation( name, ".conj.pbt" ), category, needs, setup,
                BENCH_ConjPBT );
    BENCH_Case( Concatenation( name, ".norm" ), category, needs, setup,
                BENCH_Norm );
    BENCH_Case( Concatenation( name, ".norm.pbt" ), category, needs, setup,
                BENCH_NormPBT );
end;

# E from <constructor>, F a random conjugate of the group from <other>
BENCH_NonConjCase := function( category, name, needs, constructor, other )
    BENCH_Case( Concatenation( name, ".nonconj" ), category, needs,
        function( )
            local   a,  H,  x;

            a := BENCH_Pair( constructor( ) );
            H := other( );
            x := Random( a.S );
            a.F := Group( List( GeneratorsOfGroup( H ), g -> g ^ x ) );
            return a;
        end, BENCH_NonConj );
end;

BENCH_ReadData := function( name )
    Read( Concatenation( BENCH_DIR, "/data/", name, ".g" ) );
    return BENCH_DATA;
end;

BENCH_Fresh := G -> Group( GeneratorsOfGroup( G ) );

BENCH_Coset := function( G, p )
    return Image( FactorCosetAction( G, SylowSubgroup( G, p ) ) );
end;

# S_m x S_m on the m x m grid
BENCH_Grid := function( m )
    local   D,  pts;

    D := DirectProduct( SymmetricGroup( m ), SymmetricGroup( m ) );
    pts := Cartesian( [ 1 .. m ], [ 1 .. m ] );
    return Action( D, pts, function( pt, d )
        return [ pt[ 1 ] ^ Image( Projection( D, 1 ), d ),
                 pt[ 2 ] ^ Image( Projection( D, 2 ), d ) ];
    end );
end;

BENCH_RandomSubset := function( n, k )
    return Set( List( [ 1 .. k ], i -> Random( [ 1 .. n ] ) ) );
end;

#############################################################################
##
##  issue #3718
##

BENCH_Issue := function( name, setup )
    BENCH_Case( Concatenation( name, ".conj" ), "issue3718", [  ], setup,
                BENCH_Conj );
    BENCH_Case( Concatenation( name, ".conj.pbt" ), "issue3718", [  ], setup,
                BENCH_ConjPBT );
    BENCH_Case( Concatenation( name, ".norm" ), "issue3718", [  ], setup,
                BENCH_Norm );
    BENCH_Case( Concatenation( name, ".norm.pbt" ), "issue3718", [  ], setup,
                BENCH_NormPBT );
end;

BENCH_Issue( "i3718-deg31", function( )
    local   d;

    d := BENCH_ReadData( "issue3718-deg31" );
    return rec( S := SymmetricGroup( 31 ), E := BENCH_Fresh( d.G ),
                F := BENCH_Fresh( d.H ) );
end );

BENCH_Issue( "i3718-deg1125", function( )
    local   d;

    d := BENCH_ReadData( "issue3718-deg1125" );
    return rec( S := SymmetricGroup( 1125 ), E := BENCH_Fresh( d.g ),
                F := BENCH_Fresh( d.h ) );
end );

# the actions on the 375 blocks of size 3
BENCH_Issue( "i3718-deg375", function( )
    local   d,  act;

    d := BENCH_ReadData( "issue3718-deg1125" );
    act := G -> Action( G, Blocks( G, [ 1 .. 1125 ] ), OnSets );
    return rec( S := SymmetricGroup( 375 ), E := act( d.g ), F := act( d.h ) );
end );

#############################################################################
##
##  primitive groups
##

BENCH_Group( "primitive", "psl27", [  ], {} -> PSL( 2, 7 ) );
BENCH_Group( "primitive", "psl211", [  ], {} -> PSL( 2, 11 ) );
BENCH_Group( "primitive", "psl33", [  ], {} -> PSL( 3, 3 ) );
BENCH_Group( "primitive", "psl34", [  ], {} -> PSL( 3, 4 ) );
BENCH_Group( "primitive", "psl35", [  ], {} -> PSL( 3, 5 ) );
BENCH_Group( "primitive", "psl37", [  ], {} -> PSL( 3, 7 ) );
BENCH_Group( "primitive", "psl38", [  ], {} -> PSL( 3, 8 ) );
BENCH_Group( "primitive", "psl39", [  ], {} -> PSL( 3, 9 ) );
BENCH_Group( "primitive", "psl42", [  ], {} -> PSL( 4, 2 ) );
BENCH_Group( "primitive", "psl43", [  ], {} -> PSL( 4, 3 ) );
BENCH_Group( "primitive", "psl52", [  ], {} -> PSL( 5, 2 ) );
BENCH_Group( "primitive", "psu33", [  ], {} -> PSU( 3, 3 ) );
BENCH_Group( "primitive", "sz8", [  ], {} -> SuzukiGroup( IsPermGroup, 8 ) );
BENCH_Group( "primitive", "m11", [  ], {} -> MathieuGroup( 11 ) );
BENCH_Group( "primitive", "m12", [  ], {} -> MathieuGroup( 12 ) );
BENCH_Group( "primitive", "m22", [  ], {} -> MathieuGroup( 22 ) );
BENCH_Group( "primitive", "m23", [  ], {} -> MathieuGroup( 23 ) );
BENCH_Group( "primitive", "m24", [  ], {} -> MathieuGroup( 24 ) );
BENCH_NonConjCase( "primitive", "prim26-2-4", [ "primgrp" ],
    {} -> PrimitiveGroup( 26, 2 ), {} -> PrimitiveGroup( 26, 4 ) );

#############################################################################
##
##  actions on cosets of Sylow subgroups
##

BENCH_Group( "coset", "a6syl5", [  ],
    {} -> BENCH_Coset( AlternatingGroup( 6 ), 5 ) );
BENCH_Group( "coset", "s6syl3", [  ],
    {} -> BENCH_Coset( SymmetricGroup( 6 ), 3 ) );
BENCH_Group( "coset", "psl211syl2", [  ],
    {} -> BENCH_Coset( PSL( 2, 11 ), 2 ) );
BENCH_Group( "coset", "psl216syl2", [  ],
    {} -> BENCH_Coset( PSL( 2, 16 ), 2 ) );
BENCH_Group( "coset", "a7syl7", [  ],
    {} -> BENCH_Coset( AlternatingGroup( 7 ), 7 ) );
BENCH_Group( "coset", "psl33syl13", [  ],
    {} -> BENCH_Coset( PSL( 3, 3 ), 13 ) );
BENCH_Group( "coset", "m11syl11", [  ],
    {} -> BENCH_Coset( MathieuGroup( 11 ), 11 ) );
BENCH_Group( "coset", "psl34syl7", [  ], {} -> BENCH_Coset( PSL( 3, 4 ), 7 ) );

#############################################################################
##
##  wreath products
##

BENCH_Group( "wreath", "a5wrc7", [  ],
    {} -> WreathProduct( AlternatingGroup( 5 ),
                         CyclicGroup( IsPermGroup, 7 ) ) );
BENCH_Group( "wreath", "psl27wrs4", [  ],
    {} -> WreathProduct( PSL( 2, 7 ), SymmetricGroup( 4 ) ) );
BENCH_Group( "wreath", "m11wrc5", [  ],
    {} -> WreathProduct( MathieuGroup( 11 ), CyclicGroup( IsPermGroup, 5 ) ) );
BENCH_Group( "wreath", "s3wrpsl35", [  ],
    {} -> WreathProduct( SymmetricGroup( 3 ), PSL( 3, 5 ) ) );
BENCH_Group( "wreath", "c3wrs50", [  ],
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 3 ),
                         SymmetricGroup( 50 ) ) );
BENCH_Group( "wreath", "s5wrs5der", [  ],
    {} -> DerivedSubgroup( WreathProduct( SymmetricGroup( 5 ),
                                          SymmetricGroup( 5 ) ) ) );
BENCH_Group( "wreath", "d8wrpsl27", [  ],
    {} -> WreathProduct( DihedralGroup( IsPermGroup, 8 ), PSL( 2, 7 ) ) );
BENCH_Group( "wreath", "c2wragl113", [  ], function( )
    local   agl;

    agl := Group( (1,2,3,4,5,6,7,8,9,10,11,12,13),
                  (2,3,5,9,4,7,13,12,10,6,11,8) );
    return WreathProduct( CyclicGroup( IsPermGroup, 2 ), agl );
end );

#############################################################################
##
##  imprimitive groups from the library of transitive groups
##

BENCH_Transitive := function( d, i )
    BENCH_Group( "transitive",
                 Concatenation( "t", String( d ), "-", String( i ) ),
                 [ "transgrp" ], {} -> TransitiveGroup( d, i ) );
end;

BENCH_TransitiveNonConj := function( d, i, j )
    BENCH_NonConjCase( "transitive",
        Concatenation( "t", String( d ), "-", String( i ) ), [ "transgrp" ],
        {} -> TransitiveGroup( d, i ), {} -> TransitiveGroup( d, j ) );
end;

for BENCH_di  in [ [ 20, 501 ], [ 20, 601 ], [ 20, 1001 ], [ 22, 37 ],
    [ 24, 2948 ], [ 24, 13353 ], [ 26, 77 ], [ 26, 79 ], [ 26, 81 ],
    [ 27, 581 ], [ 27, 835 ], [ 27, 926 ], [ 27, 1180 ], [ 28, 633 ],
    [ 28, 1481 ], [ 28, 1510 ], [ 30, 3379 ], [ 33, 106 ], [ 33, 116 ],
    [ 34, 100 ], [ 35, 82 ], [ 35, 187 ], [ 38, 60 ], [ 38, 61 ],
    [ 40, 23758 ], [ 42, 4894 ], [ 42, 6466 ], [ 44, 1048 ], [ 44, 1505 ],
    [ 44, 1524 ], [ 44, 1543 ], [ 44, 1562 ], [ 45, 4641 ], [ 45, 5459 ],
    [ 46, 37 ], [ 46, 40 ], [ 46, 47 ] ]  do
    BENCH_Transitive( BENCH_di[ 1 ], BENCH_di[ 2 ] );
od;

for BENCH_di  in [ [ 24, 2948, 2949 ], [ 27, 581, 582 ], [ 27, 926, 927 ],
    [ 28, 1481, 1482 ], [ 28, 1510, 1511 ], [ 35, 187, 188 ],
    [ 42, 4894, 4895 ], [ 44, 1048, 1049 ], [ 45, 5459, 5460 ] ]  do
    BENCH_TransitiveNonConj( BENCH_di[ 1 ], BENCH_di[ 2 ], BENCH_di[ 3 ] );
od;

#############################################################################
##
##  centralizers and conjugacy of elements
##

BENCH_Elements := function( n )
    local   name;

    name := Concatenation( "s", String( n ) );
    BENCH_Case( Concatenation( name, ".cent.pbt" ), "element", [  ],
        function( )
            local   S;

            S := SymmetricGroup( n );
            return rec( S := S, x := Random( S ), T := TrivialSubgroup( S ) );
        end,
        a -> Size( RepOpElmTuplesPermGroup( false, a.S, [ a.x ], [ a.x ],
                                             a.T, a.T ) ) );
    BENCH_Case( Concatenation( name, ".cent2.pbt" ), "element", [  ],
        function( )
            local   S;

            S := SymmetricGroup( n );
            return rec( S := S, x := Random( S ), y := Random( S ),
                        T := TrivialSubgroup( S ) );
        end,
        a -> Size( RepOpElmTuplesPermGroup( false, a.S, [ a.x, a.y ],
                                             [ a.x, a.y ], a.T, a.T ) ) );
    BENCH_Case( Concatenation( name, ".tupconj.pbt" ), "element", [  ],
        function( )
            local   S,  c;

            S := SymmetricGroup( n );
            c := Random( S );
            return rec( S := S, x := Random( S ), y := Random( S ), c := c,
                        T := TrivialSubgroup( S ) );
        end,
        function( a )
            local   r;

            r := RepOpElmTuplesPermGroup( true, a.S, [ a.x, a.y ],
                                          [ a.x ^ a.c, a.y ^ a.c ], a.T, a.T );
            return r <> fail and a.x ^ r = a.x ^ a.c and a.y ^ r = a.y ^ a.c;
        end );
end;

for BENCH_n  in [ 50, 100, 200, 500 ]  do
    BENCH_Elements( BENCH_n );
od;

BENCH_ElementsIn := function( name, constructor )
    BENCH_Case( Concatenation( name, ".elmcent" ), "element", [  ],
        function( )
            local   G;

            G := constructor( );
            return rec( G := G, x := Random( G ) );
        end,
        a -> Size( Centralizer( a.G, a.x ) ) );
    BENCH_Case( Concatenation( name, ".elmconj" ), "element", [  ],
        function( )
            local   G;

            G := constructor( );
            return rec( G := G, x := Random( G ), c := Random( G ) );
        end,
        function( a )
            local   r;

            r := RepresentativeAction( a.G, a.x, a.x ^ a.c );
            return r <> fail and a.x ^ r = a.x ^ a.c;
        end );
end;

BENCH_ElementsIn( "m24", {} -> MathieuGroup( 24 ) );
BENCH_ElementsIn( "psl39", {} -> PSL( 3, 9 ) );
BENCH_ElementsIn( "c3wrs50",
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 3 ),
                         SymmetricGroup( 50 ) ) );
BENCH_ElementsIn( "s10wrs10",
    {} -> WreathProduct( SymmetricGroup( 10 ), SymmetricGroup( 10 ) ) );

#############################################################################
##
##  set stabilizers and transporters
##

for BENCH_n  in [ 10, 15, 20, 30 ]  do
    BENCH_Case( Concatenation( "grid", String( BENCH_n ), ".setstab" ),
        "setstab", [  ],
        function( )
            local   n;

            n := BENCH_n;
            return rec( G := BENCH_Grid( n ),
                        A := BENCH_RandomSubset( n ^ 2, QuoInt( n ^ 2, 2 ) ) );
        end,
        a -> Size( Stabilizer( a.G, a.A, OnSets ) ) );
    BENCH_Case( Concatenation( "grid", String( BENCH_n ), ".settrans" ),
        "setstab", [  ],
        function( )
            local   G,  A;

            G := BENCH_Grid( BENCH_n );
            A := BENCH_RandomSubset( BENCH_n ^ 2, QuoInt( BENCH_n ^ 2, 2 ) );
            return rec( G := G, A := A, B := OnSets( A, Random( G ) ) );
        end,
        function( a )
            local   r;

            r := RepresentativeAction( a.G, a.A, a.B, OnSets );
            return r <> fail and OnSets( a.A, r ) = a.B;
        end );
od;

BENCH_Case( "m24.setstab", "setstab", [  ],
    function( )
        local   G;

        G := MathieuGroup( 24 );
        return rec( G := G, A := BENCH_RandomSubset( 24, 10 ) );
    end,
    a -> Size( Stabilizer( a.G, a.A, OnSets ) ) );

BENCH_Case( "s3wrs10.setstab", "setstab", [  ],
    function( )
        local   G;

        G := WreathProduct( SymmetricGroup( 3 ), SymmetricGroup( 10 ) );
        return rec( G := G, A := BENCH_RandomSubset( 30, 12 ) );
    end,
    a -> Size( Stabilizer( a.G, a.A, OnSets ) ) );

#############################################################################
##
##  intersections
##

# a primitive group with a random conjugate of S_a wr S_(n/a)
BENCH_MeetWreath := function( name, constructor, a )
    BENCH_Case( Concatenation( name, ".meetwr" ), "intersection", [  ],
        function( )
            local   G,  n,  W;

            G := constructor( );
            n := LargestMovedPoint( G );
            W := WreathProduct( SymmetricGroup( a ), SymmetricGroup( n / a ) );
            return rec( G := G, W := W ^ Random( SymmetricGroup( n ) ) );
        end,
        r -> Size( Intersection( r.G, r.W ) ) );
end;

BENCH_MeetWreath( "psl42", {} -> PSL( 4, 2 ), 3 );
BENCH_MeetWreath( "psl34", {} -> PSL( 3, 4 ), 3 );
BENCH_MeetWreath( "psl37", {} -> PSL( 3, 7 ), 19 );
BENCH_MeetWreath( "psl43", {} -> PSL( 4, 3 ), 4 );
BENCH_MeetWreath( "m12", {} -> MathieuGroup( 12 ), 3 );
BENCH_MeetWreath( "m24", {} -> MathieuGroup( 24 ), 4 );

BENCH_Case( "s3wrs10.meetconj", "intersection", [  ],
    function( )
        local   G;

        G := WreathProduct( SymmetricGroup( 3 ), SymmetricGroup( 10 ) );
        return rec( G := G, H := G ^ Random( SymmetricGroup( 30 ) ) );
    end,
    a -> Size( Intersection( a.G, a.H ) ) );

#############################################################################
##
##  many small problems, to see the overhead per call
##

BENCH_Case( "trans12-150-301.norm-batch", "overhead", [ "transgrp" ],
    function( )
        return rec( S := SymmetricGroup( 12 ),
                    L := List( [ 150 .. 301 ],
                               i -> BENCH_Fresh( TransitiveGroup( 12, i ) ) ) );
    end,
    a -> Sum( a.L, G -> Size( Normalizer( a.S, G ) ) ) );

BENCH_Case( "trans12-150-301.norm-batch.pbt", "overhead", [ "transgrp" ],
    function( )
        return rec( S := SymmetricGroup( 12 ),
                    L := List( [ 150 .. 301 ],
                               i -> BENCH_Fresh( TransitiveGroup( 12, i ) ) ) );
    end,
    a -> Sum( a.L, G -> Size( NormalizerPermGroup( a.S, G ) ) ) );

BENCH_Case( "trans12-150-301.conj-batch", "overhead", [ "transgrp" ],
    function( )
        local   S;

        S := SymmetricGroup( 12 );
        return rec( S := S, L := List( [ 150 .. 301 ], function( i )
            local   G,  x;

            G := TransitiveGroup( 12, i );
            x := Random( S );
            return [ BENCH_Fresh( G ), G ^ x ];
        end ) );
    end,
    a -> Number( a.L,
                 p -> RepresentativeAction( a.S, p[ 1 ], p[ 2 ] ) <> fail ) );

BENCH_Case( "trans8-10.norm-batch", "overhead", [ "transgrp" ],
    function( )
        return rec( L := Concatenation( List( [ 8 .. 10 ], d -> List(
            [ 1 .. NrTransitiveGroups( d ) ],
            i -> [ SymmetricGroup( d ),
                   BENCH_Fresh( TransitiveGroup( d, i ) ) ] ) ) ) );
    end,
    a -> Sum( a.L, p -> Size( Normalizer( p[ 1 ], p[ 2 ] ) ) ) );

BENCH_Case( "s12.cent-batch.pbt", "overhead", [  ],
    function( )
        local   S;

        S := SymmetricGroup( 12 );
        return rec( S := S, T := TrivialSubgroup( S ),
                    L := List( [ 1 .. 50 ], i -> Random( S ) ) );
    end,
    a -> Sum( a.L, x -> Size( RepOpElmTuplesPermGroup( false, a.S, [ x ], [ x ],
                                                        a.T, a.T ) ) ) );

#############################################################################
##
##  sweeps over group libraries; excluded by default, as they take long
##
##  The result is [ number of groups, number of pairs found conjugate,
##  sum of the indices of the groups in their normalizers, weighted sum ]
##  so that a change in any single result shows.
##

BENCH_SweepResult := function( L )
    return [ Length( L ), Number( L, p -> p[ 1 ] ), Sum( L, p -> p[ 2 ] ),
             Sum( [ 1 .. Length( L ) ], k -> k * L[ k ][ 2 ] ) ];
end;

# conjugacy and normalizer in S_d for each group in <groups>, a list of
# [ d, i ]; <lib> is PrimitiveGroup or TransitiveGroup
BENCH_Sweep := function( name, needs, lib, groups )
    BENCH_Case( name, "sweep", needs,
        function( )
            return rec( L := List( groups, function( di )
                local   G,  a;

                G := lib( di[ 1 ], di[ 2 ] );
                a := BENCH_Pair( G );
                a.S := SymmetricGroup( di[ 1 ] );
                a.order := Size( G );
                return a;
            end ) );
        end,
        r -> BENCH_SweepResult( List( r.L, a -> [ BENCH_Conj( a ),
                 Size( Normalizer( a.S, a.E ) ) / a.order ] ) ) );
end;

# all groups of the library in the given degrees, except the symmetric and
# alternating groups
BENCH_LibraryGroups := function( nr, lib, degs )
    return Concatenation( List( degs, d -> Filtered(
        List( [ 1 .. nr( d ) ], i -> [ d, i ] ),
        di -> 2 * Size( lib( d, di[ 2 ] ) ) < Factorial( d ) ) ) );
end;

# every k-th group, for a sample of about <cnt> imprimitive groups per degree
BENCH_SampledImprimitive := function( degs, cnt )
    return Concatenation( List( degs, function( d )
        local   nr;

        nr := NrTransitiveGroups( d );
        return Filtered(
            List( Set( List( [ 1 .. cnt ], k -> 1 + RemInt( k * 7919, nr ) ) ),
                  i -> [ d, i ] ),
            function( di )
                local   G;

                G := TransitiveGroup( d, di[ 2 ] );
                return not IsPrimitive( G ) and 2 * Size( G ) < Factorial( d );
            end );
    end ) );
end;

BENCH_Case( "prim.sweep.5-24", "sweep", [ "primgrp" ],
    function( )
        return rec( groups := BENCH_LibraryGroups(
                        NrPrimitiveGroups, PrimitiveGroup, [ 5 .. 24 ] ) );
    end,
    r -> BENCH_SweepResult( List( r.groups, function( di )
        local   a;

        a := BENCH_Pair( PrimitiveGroup( di[ 1 ], di[ 2 ] ) );
        a.S := SymmetricGroup( di[ 1 ] );
        return [ BENCH_Conj( a ),
                 Size( Normalizer( a.S, a.E ) ) / Size( a.E ) ];
    end ) ) );

BENCH_Case( "prim.sweep.25-36", "sweep", [ "primgrp" ],
    function( )
        return rec( groups := BENCH_LibraryGroups(
                        NrPrimitiveGroups, PrimitiveGroup, [ 25 .. 36 ] ) );
    end,
    r -> BENCH_SweepResult( List( r.groups, function( di )
        local   a;

        a := BENCH_Pair( PrimitiveGroup( di[ 1 ], di[ 2 ] ) );
        a.S := SymmetricGroup( di[ 1 ] );
        return [ BENCH_Conj( a ),
                 Size( Normalizer( a.S, a.E ) ) / Size( a.E ) ];
    end ) ) );

BENCH_Case( "trans.sweep.4-12", "sweep", [ "transgrp" ],
    function( )
        return rec( groups := BENCH_LibraryGroups(
                        NrTransitiveGroups, TransitiveGroup, [ 4 .. 12 ] ) );
    end,
    r -> BENCH_SweepResult( List( r.groups, function( di )
        local   a;

        a := BENCH_Pair( TransitiveGroup( di[ 1 ], di[ 2 ] ) );
        a.S := SymmetricGroup( di[ 1 ] );
        return [ BENCH_Conj( a ),
                 Size( Normalizer( a.S, a.E ) ) / Size( a.E ) ];
    end ) ) );

for BENCH_degs  in [ [ [ 12, 14, 15, 16 ], 40 ], [ [ 18, 20 ], 40 ],
    [ [ 21, 22, 24 ], 40 ], [ [ 25, 26, 27 ], 40 ], [ [ 28, 30 ], 40 ],
    [ [ 33, 34, 35, 36 ], 20 ], [ [ 38, 39, 40 ], 20 ],
    [ [ 42, 44, 45, 46 ], 20 ] ]  do
    BENCH_Case( Concatenation( "imprim.sweep.", String( BENCH_degs[ 1 ][ 1 ] ),
                               "-", String( Last( BENCH_degs[ 1 ] ) ) ),
        "sweep", [ "transgrp" ],
        function( )
            return rec( groups := BENCH_SampledImprimitive( BENCH_degs[ 1 ],
                                                            BENCH_degs[ 2 ] ) );
        end,
        r -> BENCH_SweepResult( List( r.groups, function( di )
            local   a;

            a := BENCH_Pair( TransitiveGroup( di[ 1 ], di[ 2 ] ) );
            a.S := SymmetricGroup( di[ 1 ] );
            return [ BENCH_Conj( a ),
                     Size( Normalizer( a.S, a.E ) ) / Size( a.E ) ];
        end ) ) );
od;
