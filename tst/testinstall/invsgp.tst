#############################################################################
##
#W  invsgp.tst                 GAP library                  James D. Mitchell
##
##
#Y  Copyright (C) 2016
##

gap> START_TEST("invsgp.tst");

# Test String method for inverse semigroup with generators as a semigroup
gap> S := Semigroup(Transformation([1, 2, 3, 4, 5, 6, 7, 7, 7]), 
>                   Transformation([4, 6, 3, 6, 6, 6, 7, 7, 7]),
>                   Transformation([4, 5, 6, 1, 6, 6, 7, 7, 7]), 
>                   Transformation([6, 6, 3, 1, 6, 6, 7, 7, 7]), 
>                   Transformation([4, 6, 6, 1, 2, 6, 7, 7, 7]));;
gap> IsInverseSemigroup(S);
true
gap> String(S);
"Semigroup( [ Transformation( [ 1, 2, 3, 4, 5, 6, 7, 7, 7 ] ), Transformation(\
 [ 4, 6, 3, 6, 6, 6, 7, 7, 7 ] ), Transformation( [ 4, 5, 6, 1, 6, 6, 7, 7, 7 \
] ), Transformation( [ 6, 6, 3, 1, 6, 6, 7, 7, 7 ] ), Transformation( [ 4, 6, \
6, 1, 2, 6, 7, 7, 7 ] ) ] )"
gap> S = EvalString(String(S));
true

# Test String method for inverse monoid with generators as a monoid
gap> S := Monoid(Transformation([1, 2, 3, 4, 5, 6, 7, 7, 7]), 
>                Transformation([4, 6, 3, 6, 6, 6, 7, 7, 7]),
>                Transformation([4, 5, 6, 1, 6, 6, 7, 7, 7]), 
>                Transformation([6, 6, 3, 1, 6, 6, 7, 7, 7]), 
>                Transformation([4, 6, 6, 1, 2, 6, 7, 7, 7]));;
gap> IsInverseMonoid(S);
true
gap> String(S);
"Monoid( [ Transformation( [ 1, 2, 3, 4, 5, 6, 7, 7, 7 ] ), Transformation( [ \
4, 6, 3, 6, 6, 6, 7, 7, 7 ] ), Transformation( [ 4, 5, 6, 1, 6, 6, 7, 7, 7 ] )\
, Transformation( [ 6, 6, 3, 1, 6, 6, 7, 7, 7 ] ), Transformation( [ 4, 6, 6, \
1, 2, 6, 7, 7, 7 ] ) ] )"
gap> S = EvalString(String(S));
true

# Test string method for inverse monoid with inverse monoid generators
gap> S := InverseMonoid(PartialPerm([1, 2, 3]), PartialPerm([1], [2]));;
gap> String(S);
"InverseMonoid( [ PartialPermNC( [ 1, 2, 3 ], [ 1, 2, 3 ] ), PartialPermNC( [ \
1 ], [ 2 ] ) ] )"
gap> S = EvalString(String(S));
true

# Test string method for inverse semigroup with inverse semigroup generators
gap> S := InverseSemigroup(PartialPerm([1, 2, 3]), PartialPerm([1], [2]));;
gap> String(S);
"InverseMonoid( [ PartialPermNC( [ 1, 2, 3 ], [ 1, 2, 3 ] ), PartialPermNC( [ \
1 ], [ 2 ] ) ] )"
gap> S = EvalString(String(S));
true

#
gap> STOP_TEST( "invsgp.tst", 1);
