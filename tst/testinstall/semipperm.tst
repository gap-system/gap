#############################################################################
##
#W  semipperm.tst
#Y  James D. Mitchell
##
#############################################################################
##

#
gap> START_TEST("semipperm.tst");

#
gap> PPermDisplayLimit := UserPreference("PartialPermDisplayLimit");;
gap> PPermNotation := UserPreference("NotationForPartialPerms");;
gap> SetUserPreference("PartialPermDisplayLimit", 100);
gap> SetUserPreference("NotationForPartialPerms", "component");

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

# Test  One for a partial perm semigroup without generators
gap> S := SymmetricInverseMonoid(3);;
gap> I := SemigroupIdealByGenerators(S, [S.3]);;
gap> HasGeneratorsOfSemigroup(I);
false
gap> One(I);
fail
gap> I := SemigroupIdealByGenerators(S, [S.1]);;
gap> HasGeneratorsOfSemigroup(I);
false
gap> One(I);
<identity partial perm on [ 1, 2, 3 ]>

# Test  One for a partial perm monoid with generators
gap> S := SymmetricInverseMonoid(3);;
gap> One(S);
<identity partial perm on [ 1, 2, 3 ]>
gap> S := Semigroup(S);;
gap> One(S);
<identity partial perm on [ 1, 2, 3 ]>

# Test  One for a partial perm semigroup with generators
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> One(S);
fail
gap> S := Semigroup(PartialPerm([2, 1, 3]));;
gap> One(S);
<identity partial perm on [ 1, 2, 3 ]>

# Test MultiplicativeZero for partial perm semigroups
gap> x := PartialPerm([1, 2, 4, 7, 9], [5, 3, 7, 4, 9]);;
gap> S := InverseSemigroup(x);
<inverse partial perm semigroup of rank 7 with 1 generator>
gap> Zero(S);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZeroMutable' on 1 arguments
gap> MultiplicativeZero(S);
fail

# Test MultiplicativeZero 
gap> S := SymmetricInverseMonoid(5);
<symmetric inverse monoid of degree 5>
gap> MultiplicativeZero(S);
<empty partial perm>
gap> S := Monoid(PartialPerm([1]));;
gap> MultiplicativeZero(S);
<identity partial perm on [ 1 ]>
gap> MultiplicativeZero(S);
<identity partial perm on [ 1 ]>
gap> S := Monoid(PartialPerm([2, 1]));;
gap> MultiplicativeZero(S);
fail

#
gap> SetUserPreference("PartialPermDisplayLimit", PPermDisplayLimit);;
gap> SetUserPreference("NotationForPartialPerm", PPermNotation);;

#
gap> STOP_TEST( "semipperm.tst", 42710000);
