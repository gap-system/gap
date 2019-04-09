#@local g,ranges,x,y,z,a,f
gap> START_TEST("range.tst");

#
gap> [0..0];
[ 0 ]
gap> [0..-1];
[  ]
gap> [-5..5];
[ -5 .. 5 ]
gap> [-5,-3..5];
[ -5, -3 .. 5 ]

#
gap> 0 in [0..0];
true
gap> ForAny([-2,-1,1,2], x -> x in [0..0]);
false
gap> ForAny([-2,-1,0,1,2], x -> x in [0..-1]);
false
gap> 0 in [0..1];
true
gap> 1 in [0..1];
true
gap> ForAny([-2,-1,2], x -> x in [0..1]);
false
gap> -5 in [-5,-3..5];
true
gap> -4 in [-5,-3..5];
false
gap> 1 in [-5,-3..5];
true
gap> 2 in [-5,-3..5];
false
gap> 5 in [-5,-3..5];
true
gap> 6 in [-5,-3..5];
false
gap> () in [-5,-3..5];
false

#
gap> [0..1] < [0..2];
true
gap> [0..1] < [0..0];
false
gap> [-5..5] < [1..2];
true
gap> [1..5] < [1..5];
false
gap> [0..2] < [0..1];
false
gap> [0..0] < [0..1];
true
gap> ranges := ListX([0,1,2,3,4,,5100,200], [1,2,3,-1,-2,-3], [2,3,10],
>     {start, step, size} -> [start,start+step..start+step*size]);;
gap> SetX(ranges, ranges, {a,b}-> (a < b) = ( (a+0) < (b+0)));
[ true ]

#
gap> [10..20][3];
12
gap> [10..20][-1];
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
gap> [10..20][10];
19
gap> [10..20][11];
20
gap> [10..20][12];
Error, List Element: <list>[12] must have an assigned value
gap> [-5,-3..5][1];
-5
gap> [-5,-3..5][2];
-3
gap> [-5,-3..5][6];
5
gap> [-5,-3..5][7];
Error, List Element: <list>[7] must have an assigned value
gap> [-5,-3..5]{[2..3]};
[ -3, -1 ]
gap> [-5,-3..5]{[2..4]};
[ -3, -1 .. 1 ]
gap> [-5,-3..5]{[0..7]};
Error, List Elements: <poss> must be a dense list of positive integers
gap> [-5,-3..5]{[1..7]};
Error, List Elements: <list>[7] must have an assigned value
gap> [-5,-3..5]{[1..6]};
[ -5, -3 .. 5 ]
gap> Immutable([-5,-3..5])[3] := 2;
Error, List Assignment: <list> must be a mutable list
gap> x := [-5,-3..5];
[ -5, -3 .. 5 ]
gap> x[2] := 7;
7
gap> x;
[ -5, 7, -1, 1, 3, 5 ]
gap> Immutable([-5,-3..5]){[2,4]} := [2..3];
Error, List Assignments: <list> must be a mutable list
gap> x := [-5,-3..5];
[ -5, -3 .. 5 ]
gap> x{[2,5,3]};
[ -3, 3, -1 ]
gap> x{[2,5,3]} := [7,8,9];
[ 7, 8, 9 ]
gap> x;
[ -5, 7, 9, 1, 8, 5 ]
gap> x{[2,4]} := [2..4];
Error, List Assignments: <rhss> must have the same length as <poss> (lengths a\
re 3 and 2)
gap> Immutable([-5,-3..5]){[2..3]} := [2..3];
Error, List Assignments: <list> must be a mutable list
gap> x := [-5,-3..5];
[ -5, -3 .. 5 ]
gap> x{[2..3]};
[ -3, -1 ]
gap> x{[2..3]} := [2..3];
[ 2, 3 ]
gap> x;
[ -5, 2, 3, 1, 3, 5 ]

#
gap> Position([-5, -3..5], 0);
fail
gap> Position([-5, -3..5], -1);
3
gap> Position([-5, -3..5], 5);
6
gap> Position([-5, -3..5], 4);
fail
gap> Position([-5, -3..5], ());
fail
gap> Position([-5, -3..5], 2^100);
fail
gap> Position([-5, -3..5], 5, 5);
6
gap> Position([-5, -3..5], 5, 6);
fail
gap> Position([-5, -3..5], 5, fail);
Error, Position: <start> must be a non-negative integer (not the value 'fail')

#
gap> Position([5, 3..-5], 0);
fail
gap> Position([5, 3..-5], -1);
4
gap> Position([5, 3..-5], -5);
6
gap> Position([5, 3..-5], -5, 5);
6
gap> Position([5, 3..-5], -5, 6);
fail
gap> Position([5, 3..-5], -5, fail);
Error, Position: <start> must be a non-negative integer (not the value 'fail')

#
gap> IsRange([]);
true
gap> IsRange([1]);
true
gap> IsRange([2^100]);
false
gap> IsRange([1,3,5]);
true
gap> IsRange([1,5,3]);
false
gap> IsRange([1,(),3]);
false
gap> IsRange([1,1,3]);
false
gap> IsRange([1,2,3]);
true
gap> [1,2..2];
[ 1, 2 ]
gap> [2,2..2];
Error, Range: <second> must not be equal to <first> (2)
gap> [2,4..6];
[ 2, 4 .. 6 ]
gap> [2,4..7];
Error, Range: <last>-<first> (5) must be divisible by <inc> (2)
gap> [2,4..2];
[ 2 ]
gap> [2,4..0];
[  ]
gap> [4,2..1];
Error, Range: <last>-<first> (-3) must be divisible by <inc> (-2)
gap> [4,2..0];
[ 4, 2 .. 0 ]
gap> [4,2..8];
[  ]

#
gap> x := [1..3];; y:=[x,x];
[ [ 1 .. 3 ], [ 1 .. 3 ] ]
gap> z := StructuralCopy(y);
[ [ 1 .. 3 ], [ 1 .. 3 ] ]
gap> IsIdenticalObj(z[1],x[1]);
false
gap> IsIdenticalObj(z[1],z[2]);
true

#
gap> SetX(ranges, ranges,
>   function(a,b)
>     local c;
>     c:=ShallowCopy(a);
>     IntersectSet(c,b);
>     return c = Intersection(AsPlist(a),AsPlist(b));
>   end);
[ true ]

#@if 8*GAPInfo.BytesPerVariable = 32
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> x := [-a..a];
Error, Range: the length of a range must be a small integer
gap> IsBound(x);
false

#
# test range bounds checks in interpreter
#
gap> [2^40..0];
Error, Range: <first> must be a small integer (not a large positive integer)
gap> [0..2^40];
Error, Range: <last> must be a small integer (not a large positive integer)
gap> [2^100..0];
Error, Range: <first> must be a small integer (not a large positive integer)
gap> [0..2^100];
Error, Range: <last> must be a small integer (not a large positive integer)
gap> [0..()];
Error, Range: <last> must be a small integer (not a permutation (small))
gap> [()..0];
Error, Range: <first> must be a small integer (not a permutation (small))
gap> [(),1..3];
Error, Range: <first> must be a small integer (not a permutation (small))
gap> [1,()..3];
Error, Range: <second> must be a small integer (not a permutation (small))
gap> [1,2..()];
Error, Range: <last> must be a small integer (not a permutation (small))
gap> [-2^28..2^28-1];
Error, Range: the length of a range must be a small integer

# length
gap> [-2^28..2^28-1];
Error, Range: the length of a range must be a small integer

#
# test range bounds checks in executor
#
gap> f:={a,b} -> [a..b];;
gap> f(2^40,0);
Error, Range: <first> must be a small integer (not a large positive integer)
gap> f(0,2^40);
Error, Range: <last> must be a small integer (not a large positive integer)
gap> f(2^100,0);
Error, Range: <first> must be a small integer (not a large positive integer)
gap> f(0,2^100);
Error, Range: <last> must be a small integer (not a large positive integer)
gap> f(0,());
Error, Range: <last> must be a small integer (not a permutation (small))
gap> f((),0);
Error, Range: <first> must be a small integer (not a permutation (small))
gap> g:={a,b,c} -> [a,b..c];;
gap> g((),1,3);
Error, Range: <first> must be a small integer (not a permutation (small))
gap> g(1,(),3);
Error, Range: <second> must be a small integer (not a permutation (small))
gap> g(1,2,());
Error, Range: <last> must be a small integer (not a permutation (small))

# length
gap> f(-2^28,2^28-1);
Error, Range: the length of a range must be a small integer
#@else
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> x := [-a..a];
Error, Range: the length of a range must be a small integer
gap> IsBound(x);
false

#
# test range bounds checks in interpreter
#
gap> [2^40..0];
[  ]
gap> [0..2^40];
[ 0 .. 1099511627776 ]
gap> [2^100..0];
Error, Range: <first> must be a small integer (not a large positive integer)
gap> [0..2^100];
Error, Range: <last> must be a small integer (not a large positive integer)
gap> [0..()];
Error, Range: <last> must be a small integer (not a permutation (small))
gap> [()..0];
Error, Range: <first> must be a small integer (not a permutation (small))
gap> [(),1..3];
Error, Range: <first> must be a small integer (not a permutation (small))
gap> [1,()..3];
Error, Range: <second> must be a small integer (not a permutation (small))
gap> [1,2..()];
Error, Range: <last> must be a small integer (not a permutation (small))

# length
gap> [-2^60..2^60-1];
Error, Range: the length of a range must be a small integer

#
# test range bounds checks in executor
#
gap> f:={a,b} -> [a..b];;
gap> f(2^40,0);
[  ]
gap> f(0,2^40);
[ 0 .. 1099511627776 ]
gap> f(2^100,0);
Error, Range: <first> must be a small integer (not a large positive integer)
gap> f(0,2^100);
Error, Range: <last> must be a small integer (not a large positive integer)
gap> f(0,());
Error, Range: <last> must be a small integer (not a permutation (small))
gap> f((),0);
Error, Range: <first> must be a small integer (not a permutation (small))
gap> g:={a,b,c} -> [a,b..c];;
gap> g((),1,3);
Error, Range: <first> must be a small integer (not a permutation (small))
gap> g(1,(),3);
Error, Range: <second> must be a small integer (not a permutation (small))
gap> g(1,2,());
Error, Range: <last> must be a small integer (not a permutation (small))

# length
gap> f(-2^60,2^60-1);
Error, Range: the length of a range must be a small integer
#@fi
gap> STOP_TEST( "range.tst", 1);
