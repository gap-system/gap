#
# Tests for functions defined in src/set.c
#
gap> START_TEST("kernel/set.tst");

#
gap> IsSet(1);
false
gap> LIST_SORTED_LIST(1);
Error, LIST_SORTED_LIST: <list> must be a small list (not the integer 1)

#
gap> IS_EQUAL_SET;
function( list1, list2 ) ... end
gap> IS_EQUAL_SET(1,1);
Error, IS_EQUAL_SET: <list1> must be a small list (not the integer 1)
gap> IS_EQUAL_SET([],1);
Error, IS_EQUAL_SET: <list2> must be a small list (not the integer 1)
gap> IS_EQUAL_SET([],[]);
true

#
gap> IS_SUBSET_SET;
function( set1, set2 ) ... end
gap> IS_SUBSET_SET(1,1);
Error, IS_SUBSET_SET: <set1> must be a small list (not the integer 1)
gap> IS_SUBSET_SET([],1);
Error, IS_SUBSET_SET: <set2> must be a small list (not the integer 1)
gap> IS_SUBSET_SET([],[]);
true
gap> IS_SUBSET_SET([1,2,3],[1,2]);
true
gap> IS_SUBSET_SET([1,2,3],[2,1]);
true
gap> IS_SUBSET_SET([1,2,3],[,1]);
true
gap> IS_SUBSET_SET([1,2,3],[1,2,4]);
false
gap> IS_SUBSET_SET([1,2,3],[2,1,4]);
false
gap> IS_SUBSET_SET([1,2,3],[,1,4]);
false
gap> IS_SUBSET_SET([1,2],[1,2,3]);
false
gap> IS_SUBSET_SET([],[1]);
false
gap> s:= List( [ 1 .. 100 ] );;
gap> List( [ [1], [100], [64], [65], [0], [101], [1,2,4,8,16,32,64,100] ],
>          x -> IS_SUBSET_SET( s, x ) );
[ true, true, true, true, false, false, true ]
gap> List( [ [1,2,4,8,16,32,64,101], [0,1], [99,100,101], [50,51,200] ],
>          x -> IS_SUBSET_SET( s, x ) );
[ false, false, false, false ]
#@if GAPInfo.BytesPerVariable = 8
gap> IS_SUBSET_SET( [-2^50..2^50], [ 0, 2^40 ] );
true
gap> IS_SUBSET_SET( [-2^50..2^50], [-2^40..2^40] );
true
gap> IS_SUBSET_SET( [-2^50,-2^50+2..2^50], [-2^40-1..2^40] );
false
gap> IS_SUBSET_SET( [2^50,2^50-2..-2^50], [-2^40,-2^40+4..2^40] );
true
gap> IS_SUBSET_SET( [1,2,3], [-2^50..2^50] );
false
#@fi
gap> IS_SUBSET_SET( [20,18..-20], [-8,-4..12] );
true
gap> IS_SUBSET_SET( [20,18..-20], [-8,-5..13] );
false
gap> IS_SUBSET_SET( [1,3..99], [1..10] );
false
gap> IS_SUBSET_SET( [1..100], [10,20..100] );
true
gap> IS_SUBSET_SET( [1,3..11], [3,7..11] );
true
gap> IS_SUBSET_SET( [1,3..11], [3,5..13] );
false
gap> IS_SUBSET_SET( [10,8..2], [,8,4,,8] );
true
gap> IS_SUBSET_SET( [10,8..2], [4,"a"] );
false
gap> IS_SUBSET_SET( [10,8..2], "" );
true
gap> IS_SUBSET_SET( "abcdef", "ace" );
true
gap> IS_SUBSET_SET( "abcdef", "eca" );
true
gap> IS_SUBSET_SET( "abcdef", "abz" );
false
gap> s:= Set( [ 1, 2/3, Z(3), (1,2), "x", [ 1 ] ] );;
gap> IS_SUBSET_SET( s, [ "x", Z(3) ] );
true
gap> IS_SUBSET_SET( s, [ "y" ] );
false
gap> rs:= RandomSource( IsMersenneTwister, 42 );;
gap> ForAll( [ 1 .. 300 ], function( i )
>      local s1, s2;
>      s1:= Set( List( [ 1 .. Random( rs, 0, 60 ) ], j -> Random( rs, 1, 100 ) ) );
>      if i mod 2 = 0 then
>        s2:= Set( List( [ 1 .. Random( rs, 0, 6 ) ], j -> Random( rs, 1, 100 ) ) );
>      else
>        s2:= Filtered( s1, x -> Random( rs, 1, 10 ) = 1 );
>      fi;
>      return IS_SUBSET_SET( s1, s2 ) = ForAll( s2, x -> x in s1 );
>    end );
true

#
gap> ADD_SET;
function( set, val ) ... end
gap> ADD_SET(1,1);
Error, ADD_SET: <set> must be a mutable proper set (not the integer 1)

#
gap> REM_SET;
function( set, val ) ... end
gap> REM_SET(1,1);
Error, REM_SET: <set> must be a mutable proper set (not the integer 1)

#
gap> UNITE_SET;
function( set1, set2 ) ... end
gap> UNITE_SET(1,1);
Error, UNITE_SET: <set1> must be a mutable proper set (not the integer 1)
gap> UNITE_SET([],1);
Error, UNITE_SET: <set2> must be a small list (not the integer 1)
gap> UNITE_SET([],[]);

#
gap> INTER_SET;
function( set1, set2 ) ... end
gap> INTER_SET(1,1);
Error, INTER_SET: <set1> must be a mutable proper set (not the integer 1)
gap> INTER_SET([],1);
Error, INTER_SET: <set2> must be a small list (not the integer 1)
gap> INTER_SET([],[]);

#
gap> SUBTR_SET;
function( set1, set2 ) ... end
gap> SUBTR_SET(1,1);
Error, SUBTR_SET: <set1> must be a mutable proper set (not the integer 1)
gap> SUBTR_SET([],1);
Error, SUBTR_SET: <set2> must be a small list (not the integer 1)
gap> SUBTR_SET([],[]);

#
gap> STOP_TEST("kernel/set.tst");
