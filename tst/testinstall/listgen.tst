#############################################################################
##
#A  listgen.tst               GAP 4.0 library                   Thomas Breuer
##
##
#Y  Copyright 1996,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
gap> START_TEST("listgen.tst");
gap> List( [ 1 .. 10 ], x -> x^2 );
[ 1, 4, 9, 16, 25, 36, 49, 64, 81, 100 ]
gap> List( [ 2, 1, 2, 1 ], x -> x - 1 );
[ 1, 0, 1, 0 ]
gap> List();
Error, usage: List( <C>[, <func>] )
gap> List([1..10], x->x^2, "extra argument");
Error, usage: List( <C>[, <func>] )
gap> List([,1,,3,4], x->x>2);
[ , false,, true, true ]
gap> IsMutable(List([1,2,3],x->x^2));
true
gap> Flat( List( [ 1 .. 5 ], x -> [ 1 .. x ] ) );
[ 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5 ]
gap> Reversed( [ 1, 2, 1, 2 ] );
[ 2, 1, 2, 1 ]
gap> Print(Reversed( [ 1 .. 10 ] ),"\n");
[ 10, 9 .. 1 ]
gap> filt:= Filtered( [ 1 .. 10 ], x -> x < 5 );
[ 1, 2, 3, 4 ]
gap> HasIsSSortedList( filt );
true
gap> filt:= Filtered( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], x -> x < 5 );
[ 1, 2, 3, 4 ]
gap> HasIsSSortedList( filt );
false
gap> Number( [ 1 .. 10 ], x -> x < 5 );
4
gap> Number( [ 1 .. 10 ] );
10
gap> Compacted( [ 1,, 2,, 3,, 4 ] );
[ 1, 2, 3, 4 ]
gap> Collected( [ 1, 2, 3, 4, 1, 2, 3, 1, 2, 1 ] );
[ [ 1, 4 ], [ 2, 3 ], [ 3, 2 ], [ 4, 1 ] ]
gap> ForAll( [ 1 .. 10 ], IsInt );
true
gap> ForAny( [ 1 .. 10 ], x -> x > 5 );
true
gap> First( [ 1 .. 10 ], x -> x > 5 );
6
gap> PositionProperty( [ 1, 3 .. 9 ], x -> x > 4 );
3
gap> PositionBound( [ ,,,, 1 ] );
5
gap> PositionBound( [] );
fail
gap> PositionNot( [ 2, 1 ], 1 );
1
gap> PositionNot( [ 1, 2 ], 1 );
2
gap> PositionNot( [ 1, 1 ], 1 );
3
gap> PositionNot( [ 1, 1 ], 1, 3 );
4
gap> PositionNonZero( [ 1, 1 ] );
1
gap> PositionNonZero( [ 0, 1 ] );
2
gap> PositionNonZero( [ 0, 0 ] );
3
gap> PositionNonZero( [ 0, 0 ], 3 );
4
gap> l:= [ 1 .. 10 ];;
gap> SortParallel( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], l );
gap> l;
[ 4, 1, 2, 3, 5, 10, 8, 9, 7, 6 ]
gap> SortParallel( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], l,
>               function( x, y ) return y < x; end );
gap> l;
[ 10, 8, 7, 9, 6, 5, 2, 1, 4, 3 ]
gap> l :=  [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ];;
gap> SortBy(l,AINV);
gap> l;
[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
gap> l2 := [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ];;
gap> lcpy := List(l2);;
gap> permsp := SortingPerm(l2);
(1,2,3,4)(6,10)(7,9,8)
gap> l2 = lcpy;
true
gap> perm:= Sortex(l2);
(1,2,3,4)(6,10)(7,9,8)
gap> SortingPerm(l2);
()
gap> Sortex(l2);
()
gap> IsSet(l2);
true
gap> Permuted( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], perm );
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> Product( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ] );
3628800
gap> Product( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], x -> x^2 );
13168189440000
gap> Sum( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ] );
55
gap> Sum( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], x -> x^2 );
385
gap> Iterated( l, \+ );
55
gap> Iterated( l, \* );
3628800
gap> ListN( [1,2], [3,4], \+ );
[ 4, 6 ]
gap> MaximumList( l );
10
gap> MaximumList( [ 1, 2 .. 20 ] );
20
gap> MaximumList( [ 10, 8 .. 2 ] );
10
gap> MinimumList( l );
1
gap> MinimumList( [ 1, 2 .. 20 ] );
1
gap> MinimumList( [ 10, 8 .. 2 ] );
2
gap> PositionMaximum([2,4,6,4,2,6]);
3
gap> PositionMaximum([2,4,6,4,2,6], x -> -x);
1
gap> PositionMinimum([2,4,6,4,2,6]);
1
gap> PositionMinimum([2,4,6,4,2,6], x -> -x);
3
gap> PositionMaximum();
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMaximum(2);
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMaximum([1,2], 2);
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMaximum([1,2], x -> x, 2);
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMinimum();
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMinimum([1,2], 2);
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMinimum(2);
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMinimum([1,2], x -> x, 2);
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMaximum([]);
fail
gap> PositionMaximum([,,,]);
fail
gap> PositionMaximum([2,,4,,6]);
5
gap> PositionMinimum([2,,4,,6]);
1
gap> PositionMinimum([,,,]);
fail
gap> PositionMinimum([]);
fail
gap> String( l );
"[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]"
gap> String( [ 1 .. 10 ] );
"[ 1 .. 10 ]"
gap> g:=Group((1,5)(2,6)(3,7)(4,8),(1,3)(2,4)(5,7)(6,8),(1,2)(3,4)(5,6)(7,8), 
> (5,6)(7,8), (5,7)(6,8), (3,4)(7,8), (3,5)(4,6), (2,3)(6,7));;
gap> h:=Subgroup(g,[(5,6)(7,8),(5,7)(6,8),(2,4)(6,8),(2,5)(4,7),(1,2)(3,4)]);;
gap> t:=RightTransversal(g,h);;
gap> Position(t,(5,7)(6,8));
fail
gap> IsSSortedList(t);
true
gap> p2:=Position(t,(5,7)(6,8));
fail

# that's all, folks
gap> STOP_TEST( "listgen.tst", 1);

#############################################################################
##
#E
