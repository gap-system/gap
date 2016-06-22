#############################################################################
##
#W  semipperm.tst
#Y  James D. Mitchell
##
#############################################################################
##
gap> START_TEST("semipperm.tst");

# Test DisplayString
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> DisplayString(S);
"\><\>partial perm\< \>semigroup\< \>of\< \>rank \>3\<\< \>with\< \>2\< \>gene\
rators\<>\<"

# Test Fixed/moved points etc
gap> S := Semigroup(PartialPerm([1, 2, 3, 4, 6, 7, 10], [10, 8, 4, 6, 5, 3, 2]),
>              PartialPerm([1, 2, 4, 5, 6, 9, 10], [3, 5, 8, 4, 1, 9, 7]),
>              PartialPerm([1, 2, 4, 7, 9], [5, 3, 7, 4, 9]),
>              PartialPerm([1, 2, 3, 4, 6, 8], [5, 1, 10, 7, 8, 9]));
<partial perm semigroup of rank 10 with 4 generators>
gap> FixedPointsOfPartialPerm(S);
[ 9 ]
gap> MovedPoints(S);
[ 1, 2, 3, 4, 5, 6, 7, 8, 10 ]
gap> NrFixedPoints(S);
1
gap> NrMovedPoints(S);
9
gap> LargestMovedPoint(S);
10
gap> LargestImageOfMovedPoint(S);
10
gap> SmallestMovedPoint(S);
1
gap> SmallestImageOfMovedPoint(S);
1

#
gap> STOP_TEST( "semipperm.tst", 10000);
