#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The benchmark cases for the partition backtrack, see README.md. A case
##  is added by
##
##      PBT_AddCase( <name>, <setup>, <run> )
##
##  The function setup() builds the input and is not timed. The function
##  run( input ) is timed, and the value it returns is recorded as the
##  result of the case, so it should change if the answer were wrong.
##
##  To try a case by hand, start GAP in this directory and enter
##
##      gap> Read( "cases.g" );
##      gap> case := PBT_Case( "primitive/m24.Normalizer" );;
##      gap> input := case.setup( );;
##      gap> case.run( input );  time;
##

if LoadPackage( "primgrp", false ) <> true
   or LoadPackage( "transgrp", false ) <> true then
    Error( "the cases need the packages primgrp and transgrp" );
fi;

PBT_CASES := [];

PBT_AddCase := function( name, setup, run )
    if ForAny( PBT_CASES, case -> case.name = name ) then
        Error( "there are two cases named ", name );
    fi;
    Add( PBT_CASES, rec( name := name, setup := setup, run := run ) );
end;

PBT_Case := name -> First( PBT_CASES, case -> case.name = name );

# Two random elements of <G>, and more until they generate <G>. The search
# depends on the generators, and those from a constructor or a group
# library are often special, so the inputs get random ones.
PBT_RandomGenerators := function( G )
    local gens;

    gens := [ Random( G ), Random( G ) ];
    while Size( Subgroup( G, gens ) ) < Size( G ) do
        Add( gens, Random( G ) );
    od;
    return gens;
end;

#############################################################################
##
##  Normalizers and conjugacy of subgroups of symmetric groups
##
##  PBT_SubgroupCases( <name>, <group> ) adds four cases for the permutation
##  group G returned by the function <group>. Let S be the symmetric group
##  on [ 1 .. LargestMovedPoint( G ) ], and let E be G and F be G ^ x for a
##  random x in S, both given by random generators. The cases time
##
##      <name>.Normalizer             Normalizer( S, E )
##      <name>.RepresentativeAction   RepresentativeAction( S, E, F )
##      <name>.NormalizerPermGroup    NormalizerPermGroup( S, E )
##      <name>.ConjugatorPermGroup    ConjugatorPermGroup( S, E, F )
##
##  and record the order of the normalizer, or whether the element found
##  conjugates E to F. Normalizer and RepresentativeAction are what a user
##  calls. In a symmetric group their methods in lib/gpprmsya.gi first try
##  to reduce or settle the problem by other means, and leave the rest to
##  NormalizerPermGroup and ConjugatorPermGroup, which start the backtrack
##  search; so those two are timed on the same input as well.
##
##  PBT_SubgroupPairCases( <name>, <pair> ) adds the same four cases for
##  given groups: the function <pair> returns a record with the components
##  S, E and F.
##

# whether <r> conjugates p.E to p.F, which have the same order
PBT_IsConjugator := function( p, r )
    return r <> fail
           and ForAll( GeneratorsOfGroup( p.E ), g -> g ^ r in p.F );
end;

PBT_SubgroupPairCases := function( name, pair )
    PBT_AddCase( Concatenation( name, ".Normalizer" ), pair,
        p -> Size( Normalizer( p.S, p.E ) ) );
    PBT_AddCase( Concatenation( name, ".RepresentativeAction" ), pair,
        p -> PBT_IsConjugator( p, RepresentativeAction( p.S, p.E, p.F ) ) );
    PBT_AddCase( Concatenation( name, ".NormalizerPermGroup" ), pair,
        p -> Size( NormalizerPermGroup( p.S, p.E ) ) );
    PBT_AddCase( Concatenation( name, ".ConjugatorPermGroup" ), pair,
        p -> PBT_IsConjugator( p, ConjugatorPermGroup( p.S, p.E, p.F ) ) );
end;

PBT_SubgroupCases := function( name, group )
    PBT_SubgroupPairCases( name, function( )
        local G, S, E, F;

        G := group( );
        S := SymmetricGroup( LargestMovedPoint( G ) );
        E := Group( PBT_RandomGenerators( G ) );
        F := Group( PBT_RandomGenerators( G ^ Random( S ) ) );
        return rec( S := S, E := E, F := F );
    end );
end;

#############################################################################
##
##  issue3718: the two examples from issue #3718, as given there
##

PBT_ReadData := name -> ReadAsFunction( Concatenation( "data/", name ) )( );

PBT_SubgroupPairCases( "issue3718/deg31", function( )
    local d;

    d := PBT_ReadData( "issue3718-deg31.g" );
    return rec( S := SymmetricGroup( 31 ), E := d.G, F := d.H );
end );

PBT_SubgroupPairCases( "issue3718/deg1125", function( )
    local d;

    d := PBT_ReadData( "issue3718-deg1125.g" );
    return rec( S := SymmetricGroup( 1125 ), E := d.g, F := d.h );
end );

# the groups of degree 1125 acting on their 375 blocks of size 3
PBT_SubgroupPairCases( "issue3718/deg375", function( )
    local d, act;

    d := PBT_ReadData( "issue3718-deg1125.g" );
    act := G -> Action( G, Blocks( G, [ 1 .. 1125 ] ), OnSets );
    return rec( S := SymmetricGroup( 375 ), E := act( d.g ), F := act( d.h ) );
end );

#############################################################################
##
##  primitive: simple groups in their natural actions
##

PBT_SubgroupCases( "primitive/psl27", {} -> PSL( 2, 7 ) );
PBT_SubgroupCases( "primitive/psl211", {} -> PSL( 2, 11 ) );
PBT_SubgroupCases( "primitive/psl33", {} -> PSL( 3, 3 ) );
PBT_SubgroupCases( "primitive/psl34", {} -> PSL( 3, 4 ) );
PBT_SubgroupCases( "primitive/psl35", {} -> PSL( 3, 5 ) );
PBT_SubgroupCases( "primitive/psl37", {} -> PSL( 3, 7 ) );
PBT_SubgroupCases( "primitive/psl38", {} -> PSL( 3, 8 ) );
PBT_SubgroupCases( "primitive/psl39", {} -> PSL( 3, 9 ) );
PBT_SubgroupCases( "primitive/psl42", {} -> PSL( 4, 2 ) );
PBT_SubgroupCases( "primitive/psl43", {} -> PSL( 4, 3 ) );
PBT_SubgroupCases( "primitive/psl52", {} -> PSL( 5, 2 ) );
PBT_SubgroupCases( "primitive/sz8", {} -> SuzukiGroup( IsPermGroup, 8 ) );
PBT_SubgroupCases( "primitive/m11", {} -> MathieuGroup( 11 ) );
PBT_SubgroupCases( "primitive/m12", {} -> MathieuGroup( 12 ) );
PBT_SubgroupCases( "primitive/m22", {} -> MathieuGroup( 22 ) );
PBT_SubgroupCases( "primitive/m23", {} -> MathieuGroup( 23 ) );
PBT_SubgroupCases( "primitive/m24", {} -> MathieuGroup( 24 ) );

#############################################################################
##
##  intransitive
##

# on the 91 points of the projective plane, with orbits of lengths 28, 63
PBT_SubgroupCases( "intransitive/psu33", {} -> PSU( 3, 3 ) );
PBT_SubgroupCases( "intransitive/psl27xpsl27",
    {} -> DirectProduct( PSL( 2, 7 ), PSL( 2, 7 ) ) );
PBT_SubgroupCases( "intransitive/m11xm12",
    {} -> DirectProduct( MathieuGroup( 11 ), MathieuGroup( 12 ) ) );
# S_7 on the 7 points and the 21 pairs of points
PBT_SubgroupCases( "intransitive/s7-points-pairs",
    {} -> Action( SymmetricGroup( 7 ),
                  Concatenation( Combinations( [ 1 .. 7 ], 1 ),
                                 Combinations( [ 1 .. 7 ], 2 ) ), OnSets ) );

#############################################################################
##
##  coset: groups acting on the cosets of a Sylow subgroup
##

PBT_CosetAction := function( G, p )
    return Image( FactorCosetAction( G, SylowSubgroup( G, p ) ) );
end;

PBT_SubgroupCases( "coset/a6syl5",
    {} -> PBT_CosetAction( AlternatingGroup( 6 ), 5 ) );
PBT_SubgroupCases( "coset/s6syl3",
    {} -> PBT_CosetAction( SymmetricGroup( 6 ), 3 ) );
PBT_SubgroupCases( "coset/psl211syl2",
    {} -> PBT_CosetAction( PSL( 2, 11 ), 2 ) );
PBT_SubgroupCases( "coset/psl216syl2",
    {} -> PBT_CosetAction( PSL( 2, 16 ), 2 ) );
PBT_SubgroupCases( "coset/a7syl7",
    {} -> PBT_CosetAction( AlternatingGroup( 7 ), 7 ) );
PBT_SubgroupCases( "coset/psl33syl13",
    {} -> PBT_CosetAction( PSL( 3, 3 ), 13 ) );
PBT_SubgroupCases( "coset/m11syl11",
    {} -> PBT_CosetAction( MathieuGroup( 11 ), 11 ) );
PBT_SubgroupCases( "coset/psl34syl7",
    {} -> PBT_CosetAction( PSL( 3, 4 ), 7 ) );

#############################################################################
##
##  wreath: wreath products in their imprimitive actions
##

PBT_SubgroupCases( "wreath/a5wrc7",
    {} -> WreathProduct( AlternatingGroup( 5 ),
                         CyclicGroup( IsPermGroup, 7 ) ) );
PBT_SubgroupCases( "wreath/psl27wrs4",
    {} -> WreathProduct( PSL( 2, 7 ), SymmetricGroup( 4 ) ) );
PBT_SubgroupCases( "wreath/m11wrc5",
    {} -> WreathProduct( MathieuGroup( 11 ), CyclicGroup( IsPermGroup, 5 ) ) );
PBT_SubgroupCases( "wreath/s3wrpsl35",
    {} -> WreathProduct( SymmetricGroup( 3 ), PSL( 3, 5 ) ) );
PBT_SubgroupCases( "wreath/c3wrs50",
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 3 ),
                         SymmetricGroup( 50 ) ) );
PBT_SubgroupCases( "wreath/s5wrs5der",
    {} -> DerivedSubgroup( WreathProduct( SymmetricGroup( 5 ),
                                          SymmetricGroup( 5 ) ) ) );
PBT_SubgroupCases( "wreath/d8wrpsl27",
    {} -> WreathProduct( DihedralGroup( IsPermGroup, 8 ), PSL( 2, 7 ) ) );
# C_2 wr AGL(1,13): the stabilizer of a point has orbits of lengths 1, 1
# and 24 only, so all structure is in the action on the blocks
PBT_SubgroupCases( "wreath/c2wragl113",
    {} -> WreathProduct( CyclicGroup( IsPermGroup, 2 ),
              Group( (1,2,3,4,5,6,7,8,9,10,11,12,13),
                     (2,3,5,9,4,7,13,12,10,6,11,8) ) ) );

#############################################################################
##
##  transitive: imprimitive groups from the library of transitive groups,
##  picked because GAP or a proposed change to it was slow on them;
##  TransitiveGroup( d, i ) is called t<d>-<i>
##

Perform( [ [ 20, 501 ], [ 20, 601 ], [ 20, 1001 ], [ 22, 37 ],
    [ 24, 2948 ], [ 24, 13353 ], [ 26, 77 ], [ 26, 79 ], [ 26, 81 ],
    [ 27, 581 ], [ 27, 835 ], [ 27, 926 ], [ 27, 1180 ], [ 28, 633 ],
    [ 28, 1481 ], [ 28, 1510 ], [ 30, 3379 ], [ 33, 106 ], [ 33, 116 ],
    [ 34, 100 ], [ 35, 82 ], [ 35, 187 ], [ 38, 60 ], [ 38, 61 ],
    [ 40, 23758 ], [ 42, 4894 ], [ 42, 6466 ], [ 44, 1048 ], [ 44, 1505 ],
    [ 44, 1524 ], [ 44, 1543 ], [ 44, 1562 ], [ 45, 4641 ], [ 45, 5459 ],
    [ 46, 37 ], [ 46, 40 ], [ 46, 47 ] ],
    function( di )
        PBT_SubgroupCases(
            StringFormatted( "transitive/t{}-{}", di[1], di[2] ),
            {} -> TransitiveGroup( di[1], di[2] ) );
    end );

#############################################################################
##
##  nonconjugate: subgroups of the same order that are not conjugate
##
##  PBT_NonConjugateCase( <name>, <group>, <other> ) adds one case for the
##  permutation groups G and H returned by the functions <group> and
##  <other>, which have the same degree and order. With S and E as in
##  PBT_SubgroupCases and F being H ^ x for a random x in S, given by
##  random generators, it times RepresentativeAction( S, E, F ) and records
##  whether that returns fail.
##

PBT_NonConjugateCase := function( name, group, other )
    PBT_AddCase( name,
        function( )
            local G, S, E, F;

            G := group( );
            S := SymmetricGroup( LargestMovedPoint( G ) );
            E := Group( PBT_RandomGenerators( G ) );
            F := Group( PBT_RandomGenerators( other( ) ^ Random( S ) ) );
            return rec( S := S, E := E, F := F );
        end,
        p -> RepresentativeAction( p.S, p.E, p.F ) = fail );
end;

PBT_NonConjugateCase( "nonconjugate/prim26-2-4",
    {} -> PrimitiveGroup( 26, 2 ), {} -> PrimitiveGroup( 26, 4 ) );

# TransitiveGroup( d, i ) and TransitiveGroup( d, j ) as t<d>-<i>-<j>
Perform( [ [ 24, 2948, 2949 ], [ 27, 581, 582 ], [ 27, 926, 927 ],
    [ 28, 1481, 1482 ], [ 28, 1510, 1511 ], [ 35, 187, 188 ],
    [ 42, 4894, 4895 ], [ 44, 1048, 1049 ], [ 45, 5459, 5460 ] ],
    function( dij )
        PBT_NonConjugateCase(
            StringFormatted( "nonconjugate/t{}-{}-{}", dij[1], dij[2], dij[3] ),
            {} -> TransitiveGroup( dij[1], dij[2] ),
            {} -> TransitiveGroup( dij[1], dij[3] ) );
    end );

#############################################################################
##
##  element: centralizers and conjugacy of elements
##
##  In a symmetric group these have methods that do not search, so there
##  the search is called directly: RepOpElmTuplesPermGroup( <repr>, G, <e>,
##  <f>, L, R ) searches G for an element conjugating the tuple <e> of
##  permutations to the tuple <f> if <repr> is true, and for the
##  centralizer of <e> if it is false and <e> = <f>; L and R are known
##  subgroups of the centralizers of <e> and <f>.
##

PBT_AddCase( "element/s500.centralizer",
    function( )
        local S;

        S := SymmetricGroup( 500 );
        return rec( S := S, T := TrivialSubgroup( S ), x := Random( S ) );
    end,
    p -> Size( RepOpElmTuplesPermGroup( false, p.S, [ p.x ], [ p.x ],
                                         p.T, p.T ) ) );

PBT_AddCase( "element/s500.conjugator",
    function( )
        local S, e;

        S := SymmetricGroup( 500 );
        e := [ Random( S ), Random( S ) ];
        return rec( S := S, T := TrivialSubgroup( S ), e := e,
                    f := OnTuples( e, Random( S ) ) );
    end,
    function( p )
        local r;

        r := RepOpElmTuplesPermGroup( true, p.S, p.e, p.f, p.T, p.T );
        return r <> fail and OnTuples( p.e, r ) = p.f;
    end );

PBT_AddCase( "element/s10wrs10.centralizer",
    function( )
        local G;

        G := WreathProduct( SymmetricGroup( 10 ), SymmetricGroup( 10 ) );
        return rec( G := G, x := Random( G ) );
    end,
    p -> Size( Centralizer( p.G, p.x ) ) );

PBT_AddCase( "element/s10wrs10.conjugator",
    function( )
        local G, x;

        G := WreathProduct( SymmetricGroup( 10 ), SymmetricGroup( 10 ) );
        x := Random( G );
        return rec( G := G, x := x, y := x ^ Random( G ) );
    end,
    function( p )
        local r;

        r := RepresentativeAction( p.G, p.x, p.y );
        return r <> fail and p.x ^ r = p.y;
    end );

#############################################################################
##
##  setstab: stabilizers and transporters of sets of points
##

# S_m x S_m acting on the m x m grid
PBT_Grid := function( m )
    return Action( DirectProduct( SymmetricGroup( m ), SymmetricGroup( m ) ),
                   Cartesian( [ 1 .. m ], [ m + 1 .. 2 * m ] ), OnTuples );
end;

# a random subset of [ 1 .. n ] with k elements
PBT_RandomSubset := function( n, k )
    return Set( Shuffle( [ 1 .. n ] ){ [ 1 .. k ] } );
end;

PBT_AddCase( "setstab/grid30.stabilizer",
    {} -> rec( G := PBT_Grid( 30 ), A := PBT_RandomSubset( 900, 450 ) ),
    p -> Size( Stabilizer( p.G, p.A, OnSets ) ) );

PBT_AddCase( "setstab/grid30.transporter",
    function( )
        local G, A;

        G := PBT_Grid( 30 );
        A := PBT_RandomSubset( 900, 450 );
        return rec( G := G, A := A, B := OnSets( A, Random( G ) ) );
    end,
    function( p )
        local r;

        r := RepresentativeAction( p.G, p.A, p.B, OnSets );
        return r <> fail and OnSets( p.A, r ) = p.B;
    end );

PBT_AddCase( "setstab/m24.stabilizer",
    {} -> rec( G := MathieuGroup( 24 ), A := PBT_RandomSubset( 24, 10 ) ),
    p -> Size( Stabilizer( p.G, p.A, OnSets ) ) );

#############################################################################
##
##  intersection: a group with a random conjugate of another, named
##  <group>-<other>
##

PBT_AddCase( "intersection/psl37-s19wrs3",
    function( )
        local H;

        H := WreathProduct( SymmetricGroup( 19 ), SymmetricGroup( 3 ) );
        return rec( G := PSL( 3, 7 ), H := H ^ Random( SymmetricGroup( 57 ) ) );
    end,
    p -> Size( Intersection( p.G, p.H ) ) );

PBT_AddCase( "intersection/m24-s4wrs6",
    function( )
        local H;

        H := WreathProduct( SymmetricGroup( 4 ), SymmetricGroup( 6 ) );
        return rec( G := MathieuGroup( 24 ),
                    H := H ^ Random( SymmetricGroup( 24 ) ) );
    end,
    p -> Size( Intersection( p.G, p.H ) ) );

PBT_AddCase( "intersection/s3wrs10-s3wrs10",
    function( )
        local G;

        G := WreathProduct( SymmetricGroup( 3 ), SymmetricGroup( 10 ) );
        return rec( G := G, H := G ^ Random( SymmetricGroup( 30 ) ) );
    end,
    p -> Size( Intersection( p.G, p.H ) ) );

#############################################################################
##
##  batch: many small problems in one case, to see the overhead per call
##

# <G> as a new group that knows nothing but its generators
PBT_Plain := G -> Group( GeneratorsOfGroup( G ) );

# the last 152 of the 301 transitive groups of degree 12
PBT_AddCase( "batch/trans12.Normalizer",
    {} -> rec( S := SymmetricGroup( 12 ),
               L := List( [ 150 .. 301 ],
                          i -> PBT_Plain( TransitiveGroup( 12, i ) ) ) ),
    p -> Sum( p.L, E -> Size( Normalizer( p.S, E ) ) ) );

PBT_AddCase( "batch/trans12.RepresentativeAction",
    function( )
        local S;

        S := SymmetricGroup( 12 );
        return rec( S := S, L := List( [ 150 .. 301 ], function( i )
            local G;

            G := TransitiveGroup( 12, i );
            return [ PBT_Plain( G ), PBT_Plain( G ^ Random( S ) ) ];
        end ) );
    end,
    p -> Number( p.L,
                 EF -> RepresentativeAction( p.S, EF[1], EF[2] ) <> fail ) );

PBT_AddCase( "batch/s12.centralizer",
    function( )
        local S;

        S := SymmetricGroup( 12 );
        return rec( S := S, T := TrivialSubgroup( S ),
                    L := List( [ 1 .. 500 ], i -> Random( S ) ) );
    end,
    p -> Sum( p.L, x -> Size( RepOpElmTuplesPermGroup( false, p.S, [ x ],
                                                        [ x ], p.T, p.T ) ) ) );
