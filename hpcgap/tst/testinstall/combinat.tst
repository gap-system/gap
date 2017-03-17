#############################################################################
##
#W  combinat.tst                GAP tests                    Martin Schönert
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests  the functions that  mainly  deal  with  combinatorics.
##
gap> START_TEST("combinat.tst");

#F  Factorial( <n> )  . . . . . . . . . . . . . . . . factorial of an integer
gap> Print(List( [0..10], Factorial ),"\n");
[ 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800 ]
gap> Factorial( 50 );
30414093201713378043612608166064768844377641568960512000000000000

#F  Binomial( <n>, <k> )  . . . . . . . . .  binomial coefficient of integers
gap> Print(List( [-8..8], k -> Binomial( 0, k ) ),"\n");
[ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> List( [-8..8], n -> Binomial( n, 0 ) );
[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]
gap> ForAll( [-8..8], n -> ForAll( [-2..8], k ->
>        Binomial(n,k) = Binomial(n-1,k) + Binomial(n-1,k-1) ) );
true
gap> Binomial( 400, 50 );
17035900270730601418919867558071677342938596450600561760371485120

#F  Bell( <n> ) . . . . . . . . . . . . . . . . .  value of the Bell sequence
gap> Print(List( [0..10], n -> Bell(n) ),"\n");
[ 1, 1, 2, 5, 15, 52, 203, 877, 4140, 21147, 115975 ]
gap> Print(List( [0..10], n -> Sum( [0..n], k -> Stirling2( n, k ) ) ),"\n");
[ 1, 1, 2, 5, 15, 52, 203, 877, 4140, 21147, 115975 ]
gap> Bell( 60 );
976939307467007552986994066961675455550246347757474482558637

#F  Stirling1( <n>, <k> ) . . . . . . . . . Stirling number of the first kind
gap> Print(List( [-8..8], k -> Stirling1( 0, k ) ),"\n");
[ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> Print(List( [-8..8], n -> Stirling1( n, 0 ) ),"\n");
[ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> ForAll( [-8..8], n -> ForAll( [-8..8], k ->
>        Stirling1(n,k) = (n-1) * Stirling1(n-1,k) + Stirling1(n-1,k-1) ) );
true
gap> Stirling1( 60, 20 );
568611292461582075463109862277030309493811818619783570055397018154658816

#F  Stirling2( <n>, <k> ) . . . . . . . .  Stirling number of the second kind
gap> Print(List( [-8..8], k -> Stirling2( 0, k ) ),"\n");
[ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> Print(List( [-8..8], n -> Stirling2( n, 0 ) ),"\n");
[ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> ForAll( [-8..8], n -> ForAll( [-8..8], k ->
>        Stirling2(n,k) = k * Stirling2(n-1,k) + Stirling2(n-1,k-1) ) );
true
gap> Stirling2( 60, 20 );
170886257768137628374668205554120607567311094075812403938286

#F  Combinations( <mset>, <k> ) . . . .  set of sorted sublists of a multiset
gap> Combinations( [] );
[ [  ] ]
gap> Print(List( [0..1], k -> Combinations( [], k ) ),"\n");
[ [ [  ] ], [  ] ]
gap> Print(Combinations( [1..4] ),"\n");
[ [  ], [ 1 ], [ 1, 2 ], [ 1, 2, 3 ], [ 1, 2, 3, 4 ], [ 1, 2, 4 ], [ 1, 3 ], 
  [ 1, 3, 4 ], [ 1, 4 ], [ 2 ], [ 2, 3 ], [ 2, 3, 4 ], [ 2, 4 ], [ 3 ], 
  [ 3, 4 ], [ 4 ] ]
gap> Print(List( [0..5], k -> Combinations( [1..4], k ) ),"\n");
[ [ [  ] ], [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ], 
  [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ], 
  [ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ] ], [ [ 1, 2, 3, 4 ] ], 
  [  ] ]
gap> Print(Combinations( [1,2,2,3] ),"\n");
[ [  ], [ 1 ], [ 1, 2 ], [ 1, 2, 2 ], [ 1, 2, 2, 3 ], [ 1, 2, 3 ], [ 1, 3 ], 
  [ 2 ], [ 2, 2 ], [ 2, 2, 3 ], [ 2, 3 ], [ 3 ] ]
gap> Print(List( [0..5], k -> Combinations( [1,2,2,3], k ) ),"\n");
[ [ [  ] ], [ [ 1 ], [ 2 ], [ 3 ] ], 
  [ [ 1, 2 ], [ 1, 3 ], [ 2, 2 ], [ 2, 3 ] ], 
  [ [ 1, 2, 2 ], [ 1, 2, 3 ], [ 2, 2, 3 ] ], [ [ 1, 2, 2, 3 ] ], [  ] ]
gap> Combinations( [1..12] )[4039];
[ 7, 8, 9, 10, 11, 12 ]
gap> Combinations( [1..16], 4 )[266];
[ 1, 5, 9, 13 ]
gap> Combinations( [1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,7] )[378];
[ 1, 2, 3, 4, 5, 6, 7 ]
gap> Combinations( [1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,8], 8 )[97];
[ 1, 2, 3, 4, 5, 6, 7, 8 ]

#F  NrCombinations( <mset>, <k> ) . . number of sorted sublists of a multiset
gap> NrCombinations( [] );
1
gap> Print(List( [0..1], k -> NrCombinations( [], k ) ),"\n");
[ 1, 0 ]
gap> NrCombinations( [1..4] );
16
gap> Print(List( [0..5], k -> NrCombinations( [1..4], k ) ),"\n");
[ 1, 4, 6, 4, 1, 0 ]
gap> NrCombinations( [1,2,2,3] );
12
gap> Print(List( [0..5], k -> NrCombinations( [1,2,2,3], k ) ),"\n");
[ 1, 3, 4, 3, 1, 0 ]
gap> NrCombinations( [1..12] );
4096
gap> NrCombinations( [1..16], 4 );
1820
gap> NrCombinations( [1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,7] );
2880
gap> NrCombinations( [1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,7,8,8,8,8], 8 );
1558

#F  Arrangements( <mset> )  . . . . set of ordered combinations of a multiset
gap> Arrangements( [] );
[ [  ] ]
gap> Print(List( [0..1], k -> Arrangements( [], k ) ),"\n");
[ [ [  ] ], [  ] ]
gap> Print(Arrangements( [1..3] ),"\n");
[ [  ], [ 1 ], [ 1, 2 ], [ 1, 2, 3 ], [ 1, 3 ], [ 1, 3, 2 ], [ 2 ], [ 2, 1 ], 
  [ 2, 1, 3 ], [ 2, 3 ], [ 2, 3, 1 ], [ 3 ], [ 3, 1 ], [ 3, 1, 2 ], [ 3, 2 ], 
  [ 3, 2, 1 ] ]
gap> Print(List( [0..4], k -> Arrangements( [1..3], k ) ),"\n");
[ [ [  ] ], [ [ 1 ], [ 2 ], [ 3 ] ], 
  [ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ] ], 
  [ [ 1, 2, 3 ], [ 1, 3, 2 ], [ 2, 1, 3 ], [ 2, 3, 1 ], [ 3, 1, 2 ], 
      [ 3, 2, 1 ] ], [  ] ]
gap> Print(Arrangements( [1,2,2,3] ),"\n");
[ [  ], [ 1 ], [ 1, 2 ], [ 1, 2, 2 ], [ 1, 2, 2, 3 ], [ 1, 2, 3 ], 
  [ 1, 2, 3, 2 ], [ 1, 3 ], [ 1, 3, 2 ], [ 1, 3, 2, 2 ], [ 2 ], [ 2, 1 ], 
  [ 2, 1, 2 ], [ 2, 1, 2, 3 ], [ 2, 1, 3 ], [ 2, 1, 3, 2 ], [ 2, 2 ], 
  [ 2, 2, 1 ], [ 2, 2, 1, 3 ], [ 2, 2, 3 ], [ 2, 2, 3, 1 ], [ 2, 3 ], 
  [ 2, 3, 1 ], [ 2, 3, 1, 2 ], [ 2, 3, 2 ], [ 2, 3, 2, 1 ], [ 3 ], [ 3, 1 ], 
  [ 3, 1, 2 ], [ 3, 1, 2, 2 ], [ 3, 2 ], [ 3, 2, 1 ], [ 3, 2, 1, 2 ], 
  [ 3, 2, 2 ], [ 3, 2, 2, 1 ] ]
gap> Print(List( [0..5], k -> Arrangements( [1,2,2,3], k ) ),"\n");
[ [ [  ] ], [ [ 1 ], [ 2 ], [ 3 ] ], 
  [ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ] ], 
  [ [ 1, 2, 2 ], [ 1, 2, 3 ], [ 1, 3, 2 ], [ 2, 1, 2 ], [ 2, 1, 3 ], 
      [ 2, 2, 1 ], [ 2, 2, 3 ], [ 2, 3, 1 ], [ 2, 3, 2 ], [ 3, 1, 2 ], 
      [ 3, 2, 1 ], [ 3, 2, 2 ] ], 
  [ [ 1, 2, 2, 3 ], [ 1, 2, 3, 2 ], [ 1, 3, 2, 2 ], [ 2, 1, 2, 3 ], 
      [ 2, 1, 3, 2 ], [ 2, 2, 1, 3 ], [ 2, 2, 3, 1 ], [ 2, 3, 1, 2 ], 
      [ 2, 3, 2, 1 ], [ 3, 1, 2, 2 ], [ 3, 2, 1, 2 ], [ 3, 2, 2, 1 ] ], [  ] ]
gap> Arrangements( [1..6] )[736];
[ 3, 2, 1, 6, 5, 4 ]
gap> Arrangements( [1..8], 4 )[443];
[ 3, 1, 7, 5 ]
gap> Arrangements( [1,2,3,3,4,4,5] )[3511];
[ 5, 4, 3, 2, 1 ]
gap> Arrangements( [1,2,3,4,4,5,5,6,6], 5 )[424];
[ 2, 3, 4, 5, 6 ]

#F  NrArrangements( <mset>, <k> ) . . number of sorted sublists of a multiset
gap> NrArrangements( [] );
1
gap> Print(List( [0..1], k -> NrArrangements( [], k ) ),"\n");
[ 1, 0 ]
gap> NrArrangements( [1..3] );
16
gap> Print(List( [0..4], k -> NrArrangements( [1..3], k ) ),"\n");
[ 1, 3, 6, 6, 0 ]
gap> NrArrangements( [1,2,2,3] );
35
gap> Print(List( [0..5], k -> NrArrangements( [1,2,2,3], k ) ),"\n");
[ 1, 3, 7, 12, 12, 0 ]
gap> NrArrangements( [1..6] );
1957
gap> NrArrangements( [1..8], 4 );
1680
gap> NrArrangements( [1,2,3,3,4,4,5] );
3592
gap> NrArrangements( [1,2,3,4,4,5,5,6,6], 5 );
2880

#F  UnorderedTuples( <set>, <k> ) . . . .  set of unordered tuples from a set
gap> Print(List( [0..1], k -> UnorderedTuples( [], k ) ),"\n");
[ [ [  ] ], [  ] ]
gap> Print(List( [0..4], k -> UnorderedTuples( [1..3], k ) ),"\n");
[ [ [  ] ], [ [ 1 ], [ 2 ], [ 3 ] ], 
  [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ] ], 
  [ [ 1, 1, 1 ], [ 1, 1, 2 ], [ 1, 1, 3 ], [ 1, 2, 2 ], [ 1, 2, 3 ], 
      [ 1, 3, 3 ], [ 2, 2, 2 ], [ 2, 2, 3 ], [ 2, 3, 3 ], [ 3, 3, 3 ] ], 
  [ [ 1, 1, 1, 1 ], [ 1, 1, 1, 2 ], [ 1, 1, 1, 3 ], [ 1, 1, 2, 2 ], 
      [ 1, 1, 2, 3 ], [ 1, 1, 3, 3 ], [ 1, 2, 2, 2 ], [ 1, 2, 2, 3 ], 
      [ 1, 2, 3, 3 ], [ 1, 3, 3, 3 ], [ 2, 2, 2, 2 ], [ 2, 2, 2, 3 ], 
      [ 2, 2, 3, 3 ], [ 2, 3, 3, 3 ], [ 3, 3, 3, 3 ] ] ]
gap> UnorderedTuples( [1..10], 6 )[1459];
[ 1, 3, 5, 7, 9, 10 ]

#F  NrUnorderedTuples( <set>, <k> ) . . number unordered of tuples from a set
gap> Print(List( [0..1], k -> NrUnorderedTuples( [], k ) ),"\n");
[ 1, 0 ]
gap> Print(List( [0..4], k -> NrUnorderedTuples( [1..3], k ) ),"\n");
[ 1, 3, 6, 10, 15 ]
gap> NrUnorderedTuples( [1..10], 6 );
5005

#F  Tuples( <set>, <k> )  . . . . . . . . .  set of ordered tuples from a set
gap> Print(List( [0..1], k -> Tuples( [], k ) ),"\n");
[ [ [  ] ], [  ] ]
gap> Print(List( [0..3], k -> Tuples( [1..3], k ) ),"\n");
[ [ [  ] ], [ [ 1 ], [ 2 ], [ 3 ] ], 
  [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], 
      [ 3, 2 ], [ 3, 3 ] ], 
  [ [ 1, 1, 1 ], [ 1, 1, 2 ], [ 1, 1, 3 ], [ 1, 2, 1 ], [ 1, 2, 2 ], 
      [ 1, 2, 3 ], [ 1, 3, 1 ], [ 1, 3, 2 ], [ 1, 3, 3 ], [ 2, 1, 1 ], 
      [ 2, 1, 2 ], [ 2, 1, 3 ], [ 2, 2, 1 ], [ 2, 2, 2 ], [ 2, 2, 3 ], 
      [ 2, 3, 1 ], [ 2, 3, 2 ], [ 2, 3, 3 ], [ 3, 1, 1 ], [ 3, 1, 2 ], 
      [ 3, 1, 3 ], [ 3, 2, 1 ], [ 3, 2, 2 ], [ 3, 2, 3 ], [ 3, 3, 1 ], 
      [ 3, 3, 2 ], [ 3, 3, 3 ] ] ]
gap> Tuples( [1..8], 4 )[167];
[ 1, 3, 5, 7 ]

#F  NrTuples( <set>, <k> )  . . . . . . . number of ordered tuples from a set
gap> Print(List( [0..1], k -> NrTuples( [], k ) ),"\n");
[ 1, 0 ]
gap> Print(List( [0..3], k -> NrTuples( [1..3], k ) ),"\n");
[ 1, 3, 9, 27 ]
gap> NrTuples( [1..8], 4 );
4096

#F  PermutationsList( <mset> )  . . . . . . set of permutations of a multiset
gap> PermutationsList( [] );
[ [  ] ]
gap> Print(PermutationsList( [1..4] ),"\n");
[ [ 1, 2, 3, 4 ], [ 1, 2, 4, 3 ], [ 1, 3, 2, 4 ], [ 1, 3, 4, 2 ], 
  [ 1, 4, 2, 3 ], [ 1, 4, 3, 2 ], [ 2, 1, 3, 4 ], [ 2, 1, 4, 3 ], 
  [ 2, 3, 1, 4 ], [ 2, 3, 4, 1 ], [ 2, 4, 1, 3 ], [ 2, 4, 3, 1 ], 
  [ 3, 1, 2, 4 ], [ 3, 1, 4, 2 ], [ 3, 2, 1, 4 ], [ 3, 2, 4, 1 ], 
  [ 3, 4, 1, 2 ], [ 3, 4, 2, 1 ], [ 4, 1, 2, 3 ], [ 4, 1, 3, 2 ], 
  [ 4, 2, 1, 3 ], [ 4, 2, 3, 1 ], [ 4, 3, 1, 2 ], [ 4, 3, 2, 1 ] ]
gap> Print(PermutationsList( [1,2,2,3,] ),"\n");
[ [ 1, 2, 2, 3 ], [ 1, 2, 3, 2 ], [ 1, 3, 2, 2 ], [ 2, 1, 2, 3 ], 
  [ 2, 1, 3, 2 ], [ 2, 2, 1, 3 ], [ 2, 2, 3, 1 ], [ 2, 3, 1, 2 ], 
  [ 2, 3, 2, 1 ], [ 3, 1, 2, 2 ], [ 3, 2, 1, 2 ], [ 3, 2, 2, 1 ] ]
gap> Print(PermutationsList( [1..6] )[ 128 ],"\n");
[ 2, 1, 4, 3, 6, 5 ]
gap> Print(PermutationsList( [1,2,2,3,3,4,4,4] )[1359],"\n");
[ 4, 3, 2, 1, 4, 3, 2, 4 ]

#F  NrPermutationsList( <mset> )  . . .  number of permutations of a multiset
gap> NrPermutationsList( [] );
1
gap> NrPermutationsList( [1..4] );
24
gap> NrPermutationsList( [1,2,2,3] );
12
gap> NrPermutationsList( [1..6] );
720
gap> NrPermutationsList( [1,2,2,3,3,4,4,4] );
1680

#F  Derangements( <list> ) . . . . set of fixpointfree permutations of a list
gap> Derangements( [] );
[ [  ] ]
gap> Print(Derangements( [1..4] ),"\n");
[ [ 2, 1, 4, 3 ], [ 2, 3, 4, 1 ], [ 2, 4, 1, 3 ], [ 3, 1, 4, 2 ], 
  [ 3, 4, 1, 2 ], [ 3, 4, 2, 1 ], [ 4, 1, 2, 3 ], [ 4, 3, 1, 2 ], 
  [ 4, 3, 2, 1 ] ]
gap> Print(Derangements( [1..6] )[ 128 ],"\n");
[ 4, 3, 6, 1, 2, 5 ]
gap> Print(Derangements( [1,2,2,3,3,4,4,4] )[64],"\n");
[ 4, 1, 4, 2, 4, 2, 3, 3 ]

#F  NrDerangements( <list> ) .  number of fixpointfree permutations of a list
gap> NrDerangements( [] );
1
gap> NrDerangements( [1..4] );
9
gap> NrDerangements( [1..6] );
265
gap> NrDerangements( [1,2,2,3,3,4,4,4] );
126

#F  Permanent( <mat> )  . . . . . . . . . . . . . . . . permanent of a matrix
gap> Permanent( [[0,1,1,1],[1,0,1,1],[1,1,0,1],[1,1,1,0]] );
9
gap> Permanent( [[1,1,0,1,0,0,0],[0,1,1,0,1,0,0],[0,0,1,1,0,1,0],[0,0,0,1,1,0,1],
>                [1,0,0,0,1,1,0],[0,1,0,0,0,1,1],[1,0,1,0,0,0,1]] );
24

#F  PartitionsSet( <set> )  . . . . . . . . . . .  set of partitions of a set
gap> PartitionsSet( [] );
[ [  ] ]
gap> Print(List( [0..1], k -> PartitionsSet( [], k ) ),"\n");
[ [ [  ] ], [  ] ]
gap> Print(PartitionsSet( [1..4] ),"\n");
[ [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ], [ [ 1 ], [ 2 ], [ 3, 4 ] ], 
  [ [ 1 ], [ 2, 3 ], [ 4 ] ], [ [ 1 ], [ 2, 3, 4 ] ], 
  [ [ 1 ], [ 2, 4 ], [ 3 ] ], [ [ 1, 2 ], [ 3 ], [ 4 ] ], 
  [ [ 1, 2 ], [ 3, 4 ] ], [ [ 1, 2, 3 ], [ 4 ] ], [ [ 1, 2, 3, 4 ] ], 
  [ [ 1, 2, 4 ], [ 3 ] ], [ [ 1, 3 ], [ 2 ], [ 4 ] ], [ [ 1, 3 ], [ 2, 4 ] ], 
  [ [ 1, 3, 4 ], [ 2 ] ], [ [ 1, 4 ], [ 2 ], [ 3 ] ], [ [ 1, 4 ], [ 2, 3 ] ] ]
gap> Print(List( [0..4], k -> PartitionsSet( [1..3], k ) ),"\n");
[ [  ], [ [ [ 1, 2, 3 ] ] ], 
  [ [ [ 1 ], [ 2, 3 ] ], [ [ 1, 2 ], [ 3 ] ], [ [ 1, 3 ], [ 2 ] ] ], 
  [ [ [ 1 ], [ 2 ], [ 3 ] ] ], [  ] ]
gap> Print(PartitionsSet( [1..7] )[521],"\n");
[ [ 1, 3, 5, 7 ], [ 2, 4, 6 ] ]
gap> Print(PartitionsSet( [1..8], 3 )[96],"\n");
[ [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ] ]

#F  NrPartitionsSet( <set> )  . . . . . . . . . number of partitions of a set
gap> NrPartitionsSet( [] );
1
gap> List( [0..1], k -> NrPartitionsSet( [], k ) );
[ 1, 0 ]
gap> NrPartitionsSet( [1..4] );
15
gap> Print(List( [0..4], k -> NrPartitionsSet( [1,2,3], k ) ),"\n");
[ 0, 1, 3, 1, 0 ]
gap> NrPartitionsSet( [1..8] );
4140
gap> NrPartitionsSet( [1..9], 3 );
3025

#F  Partitions( <n> ) . . . . . . . . . . . . set of partitions of an integer
gap> Partitions( 0 );
[ [  ] ]
gap> List( [0..1], k -> Partitions( 0, k ) );
[ [ [  ] ], [  ] ]
gap> Print(Partitions( 6 ),"\n");
[ [ 1, 1, 1, 1, 1, 1 ], [ 2, 1, 1, 1, 1 ], [ 2, 2, 1, 1 ], [ 2, 2, 2 ], 
  [ 3, 1, 1, 1 ], [ 3, 2, 1 ], [ 3, 3 ], [ 4, 1, 1 ], [ 4, 2 ], [ 5, 1 ], 
  [ 6 ] ]
gap> Print(List( [0..7], k -> Partitions( 6, k ) ),"\n");
[ [  ], [ [ 6 ] ], [ [ 3, 3 ], [ 4, 2 ], [ 5, 1 ] ], 
  [ [ 2, 2, 2 ], [ 3, 2, 1 ], [ 4, 1, 1 ] ], 
  [ [ 2, 2, 1, 1 ], [ 3, 1, 1, 1 ] ], [ [ 2, 1, 1, 1, 1 ] ], 
  [ [ 1, 1, 1, 1, 1, 1 ] ], [  ] ]
gap> Partitions( 20 )[314];
[ 7, 4, 3, 3, 2, 1 ]
gap> Partitions( 20, 10 )[17];
[ 5, 3, 3, 2, 2, 1, 1, 1, 1, 1 ]

#F  NrPartitions( <n> ) . . . . . . . . .  number of partitions of an integer
gap> NrPartitions( 0 );
1
gap> List( [0..1], k -> NrPartitions( 0, k ) );
[ 1, 0 ]
gap> NrPartitions( 6 );
11
gap> List( [0..7], k -> NrPartitions( 6, k ) );
[ 0, 1, 3, 3, 2, 1, 1, 0 ]
gap> NrPartitions( 100 );
190569292
gap> NrPartitions( 100, 10 );
2977866

#F  OrderedPartitions( <n> ) . . . .  set of ordered partitions of an integer
gap> OrderedPartitions( 0 );
[ [  ] ]
gap> List( [0..1], k -> OrderedPartitions( 0, k ) );
[ [ [  ] ], [  ] ]
gap> Print(OrderedPartitions( 5 ),"\n");
[ [ 1, 1, 1, 1, 1 ], [ 1, 1, 1, 2 ], [ 1, 1, 2, 1 ], [ 1, 1, 3 ], 
  [ 1, 2, 1, 1 ], [ 1, 2, 2 ], [ 1, 3, 1 ], [ 1, 4 ], [ 2, 1, 1, 1 ], 
  [ 2, 1, 2 ], [ 2, 2, 1 ], [ 2, 3 ], [ 3, 1, 1 ], [ 3, 2 ], [ 4, 1 ], [ 5 ] ]
gap> Print(List( [0..6], k -> OrderedPartitions( 5, k ) ),"\n");
[ [  ], [ [ 5 ] ], [ [ 1, 4 ], [ 2, 3 ], [ 3, 2 ], [ 4, 1 ] ], 
  [ [ 1, 1, 3 ], [ 1, 2, 2 ], [ 1, 3, 1 ], [ 2, 1, 2 ], [ 2, 2, 1 ], 
      [ 3, 1, 1 ] ], 
  [ [ 1, 1, 1, 2 ], [ 1, 1, 2, 1 ], [ 1, 2, 1, 1 ], [ 2, 1, 1, 1 ] ], 
  [ [ 1, 1, 1, 1, 1 ] ], [  ] ]
gap> OrderedPartitions( 13 )[2048];
[ 1, 12 ]
gap> OrderedPartitions( 16, 6 )[1001];
[ 1, 11, 1, 1, 1, 1 ]

#F  NrOrderedPartitions( <n> ) . . number of ordered partitions of an integer
gap> NrOrderedPartitions( 0 );
1
gap> List( [0..1], k -> NrOrderedPartitions( 0, k ) );
[ 1, 0 ]
gap> NrOrderedPartitions( 5 );
16
gap> List( [0..6], k -> NrOrderedPartitions( 5, k ) );
[ 0, 1, 4, 6, 4, 1, 0 ]
gap> NrOrderedPartitions( 13 );
4096
gap> NrOrderedPartitions( 16, 6 );
3003

#F  RestrictedPartitions( <n>, <set> )  . restricted partitions of an integer
gap> RestrictedPartitions( 0, [1..10] );
[ [  ] ]
gap> List( [0..1], k -> RestrictedPartitions( 0, [1..10], k ) );
[ [ [  ] ], [  ] ]
gap> Print(RestrictedPartitions( 10, [1,2,5,10] ),"\n");
[ [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ], [ 2, 1, 1, 1, 1, 1, 1, 1, 1 ], 
  [ 2, 2, 1, 1, 1, 1, 1, 1 ], [ 2, 2, 2, 1, 1, 1, 1 ], [ 2, 2, 2, 2, 1, 1 ], 
  [ 2, 2, 2, 2, 2 ], [ 5, 1, 1, 1, 1, 1 ], [ 5, 2, 1, 1, 1 ], [ 5, 2, 2, 1 ], 
  [ 5, 5 ], [ 10 ] ]
gap> Print(List( [1..10],k->RestrictedPartitions( 10, [1,2,5,10], k )),"\n");
[ [ [ 10 ] ], [ [ 5, 5 ] ], [  ], [ [ 5, 2, 2, 1 ] ], 
  [ [ 2, 2, 2, 2, 2 ], [ 5, 2, 1, 1, 1 ] ], 
  [ [ 2, 2, 2, 2, 1, 1 ], [ 5, 1, 1, 1, 1, 1 ] ], [ [ 2, 2, 2, 1, 1, 1, 1 ] ],
  [ [ 2, 2, 1, 1, 1, 1, 1, 1 ] ], [ [ 2, 1, 1, 1, 1, 1, 1, 1, 1 ] ], 
  [ [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ] ]
gap> Print(RestrictedPartitions( 20, [2,5,10] ),"\n");
[ [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ], [ 5, 5, 2, 2, 2, 2, 2 ], [ 5, 5, 5, 5 ], 
  [ 10, 2, 2, 2, 2, 2 ], [ 10, 5, 5 ], [ 10, 10 ] ]
gap> Print(List( [1..20], k -> RestrictedPartitions( 20, [2,5,10],k)),"\n");
[ [  ], [ [ 10, 10 ] ], [ [ 10, 5, 5 ] ], [ [ 5, 5, 5, 5 ] ], [  ], 
  [ [ 10, 2, 2, 2, 2, 2 ] ], [ [ 5, 5, 2, 2, 2, 2, 2 ] ], [  ], [  ], 
  [ [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ] ], [  ], [  ], [  ], [  ], [  ], [  ], 
  [  ], [  ], [  ], [  ] ]
gap> Print(RestrictedPartitions( 60, [2,3,5,7,11,13,17] )[600],"\n");
[ 13, 7, 5, 5, 5, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]
gap> Print(RestrictedPartitions( 100, [2,3,5,7,11,13,17], 10 )[75],"\n");
[ 17, 17, 13, 13, 13, 7, 5, 5, 5, 5 ]

#F  NrRestrictedPartitions(<n>,<set>) . . . . number of restricted partitions
gap> NrRestrictedPartitions( 0, [1..10] );
1
gap> List( [0..1], k -> NrRestrictedPartitions( 0, [1..10], k ) );
[ 1, 0 ]
gap> NrRestrictedPartitions( 50, [1,2,5,10] );
341
gap> Print(List( [1..50], k->NrRestrictedPartitions( 50, [1,2,5,10], k)),"\n");
[ 0, 0, 0, 0, 1, 1, 1, 2, 4, 6, 6, 8, 10, 11, 11, 12, 13, 14, 14, 14, 15, 15, 
  14, 14, 14, 13, 12, 12, 11, 10, 9, 9, 8, 7, 6, 6, 6, 5, 4, 4, 4, 3, 2, 2, 
  2, 2, 1, 1, 1, 1 ]
gap> NrRestrictedPartitions( 50, [2,5,10] );
21
gap> Print(List( [1..50],k -> NrRestrictedPartitions( 50, [2,5,10],k)),"\n");
[ 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> NrRestrictedPartitions( 60, [2,3,5,7,11,13,17] );
1213
gap> NrRestrictedPartitions( 100, [2,3,5,7,11,13,17], 10 );
125

#F  IteratorOfPartitions( <n> )
gap> for n in [ 1 .. 15 ] do
>      pn:= Partitions( n );
>      iter:= IteratorOfPartitions( n );
>      list:= [];
>      for i in [ 1 .. Length( pn ) ] do
>        Add( list, NextIterator( iter ) );
>      od;
>      if not IsDoneIterator( iter ) then
>        Error( "wrong number of elements" );
>      elif pn <> list then
>        Error( "different elements" );
>      fi;
>    od;

#F  Lucas(<P>,<Q>,<k>)  . . . . . . . . . . . . . . value of a lucas sequence
gap> Print(List( [0..10], i->Lucas(1,-2,i)[1] ),"\n");
[ 0, 1, 1, 3, 5, 11, 21, 43, 85, 171, 341 ]
gap> Print(List( [0..10], i->Lucas(1,-2,i)[2] ),"\n");
[ 2, 1, 5, 7, 17, 31, 65, 127, 257, 511, 1025 ]
gap> Print(List( [0..10], i->Lucas(1,-1,i)[1] ),"\n");
[ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ]
gap> Print(List( [0..10], i->Lucas(2,1,i)[1] ),"\n");
[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> Lucas( 0, -4, 100 ) = [ 0, 2^101, 4^100 ];
true

#F  Fibonacci( <n> )  . . . . . . . . . . . . value of the Fibonacci sequence
gap> Print(List( [0..17], Fibonacci ),"\n");
[ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597 ]
gap> Fibonacci( 333 );
1751455877444438095408940282208383549115781784912085789506677971125378

#F  Bernoulli( <n> )  . . . . . . . . . . . . value of the Bernoulli sequence
gap> Print(List( [0..14], Bernoulli ),"\n");
[ 1, -1/2, 1/6, 0, -1/30, 0, 1/42, 0, -1/30, 0, 5/66, 0, -691/2730, 0, 7/6 ]
gap> Bernoulli( 80 );
-4603784299479457646935574969019046849794257872751288919656867/230010

# thats it for the combinatorical package  ##################################
gap> STOP_TEST( "combinat.tst", 1);

#############################################################################
##
#E
