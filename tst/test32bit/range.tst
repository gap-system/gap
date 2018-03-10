# 2005/08/23 (FL)
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> x := [-a..a];
Error, Range: the length of a range must be less than 2^28
gap> IsBound(x);
false

#
# test range bounds checks in interpreter
#
gap> [2^40..0];
Error, Range: <first> must be an integer less than 2^28 (not a integer (>= 2^2\
8))
gap> [0..2^40];
Error, Range: <last> must be an integer less than 2^28 (not a integer (>= 2^28\
))
gap> [2^100..0];
Error, Range: <first> must be an integer less than 2^28 (not a integer (>= 2^2\
8))
gap> [0..2^100];
Error, Range: <last> must be an integer less than 2^28 (not a integer (>= 2^28\
))
gap> [0..()];
Error, Range: <last> must be an integer less than 2^28 (not a permutation (sma\
ll))
gap> [()..0];
Error, Range: <first> must be an integer less than 2^28 (not a permutation (sm\
all))
gap> [(),1..3];
Error, Range: <first> must be an integer less than 2^28 (not a permutation (sm\
all))
gap> [1,()..3];
Error, Range: <second> must be an integer less than 2^28 (not a permutation (s\
mall))
gap> [1,2..()];
Error, Range: <last> must be an integer less than 2^28 (not a permutation (sma\
ll))
gap> [-2^28..2^28-1];
Error, Range: the length of a range must be less than 2^28

# length
gap> [-2^28..2^28-1];
Error, Range: the length of a range must be less than 2^28

#
# test range bounds checks in executor
#
gap> f:={a,b} -> [a..b];;
gap> f(2^40,0);
Error, Range: <first> must be an integer less than 2^28 (not a integer (>= 2^2\
8))
gap> f(0,2^40);
Error, Range: <last> must be an integer less than 2^28 (not a integer (>= 2^28\
))
gap> f(2^100,0);
Error, Range: <first> must be an integer less than 2^28 (not a integer (>= 2^2\
8))
gap> f(0,2^100);
Error, Range: <last> must be an integer less than 2^28 (not a integer (>= 2^28\
))
gap> f(0,());
Error, Range: <last> must be an integer less than 2^28 (not a permutation (sma\
ll))
gap> f((),0);
Error, Range: <first> must be an integer less than 2^28 (not a permutation (sm\
all))
gap> g:={a,b,c} -> [a,b..c];;
gap> g((),1,3);
Error, Range: <first> must be an integer less than 2^28 (not a permutation (sm\
all))
gap> g(1,(),3);
Error, Range: <second> must be an integer less than 2^28 (not a permutation (s\
mall))
gap> g(1,2,());
Error, Range: <last> must be an integer less than 2^28 (not a permutation (sma\
ll))

# length
gap> f(-2^28,2^28-1);
Error, Range: the length of a range must be less than 2^28
