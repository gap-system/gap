#############################################################################
##
#A  listgen.tst               GAP 4.0 library                   Thomas Breuer
##
##
#Y  Copyright 1996,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("listgen.tst");
gap> List( [ 1 .. 10 ], x -> x^2 );
[ 1, 4, 9, 16, 25, 36, 49, 64, 81, 100 ]
gap> List( [ 2, 1, 2, 1 ], x -> x - 1 );
[ 1, 0, 1, 0 ]
gap> Flat( List( [ 1 .. 5 ], x -> [ 1 .. x ] ) );
[ 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5 ]
gap> Reversed( [ 1, 2, 1, 2 ] );
[ 2, 1, 2, 1 ]
gap> Print(Reversed( [ 1 .. 10 ] ),"\n");
[ 10, 9 .. 1 ]
gap> Filtered( [ 1 .. 10 ], x -> x < 5 );
[ 1, 2, 3, 4 ]
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
gap> perm:= Sortex( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ] );
(1,2,3,4)(6,10)(7,9,8)
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
