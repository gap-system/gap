# 2005/08/23 (FL)
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
