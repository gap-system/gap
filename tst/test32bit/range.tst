# 2005/08/23 (FL)
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> x := [-a..a];
Error, Range: the length of a range must be less than 2^28
gap> IsBound(x);
false
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
