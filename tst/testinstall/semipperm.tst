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

# Test  Co/DegreeOfPartialPermSemigroup/Collection
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> DegreeOfPartialPermSemigroup(S);
3
gap> CodegreeOfPartialPermSemigroup(S);
11
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> DegreeOfPartialPermCollection(S);
3
gap> CodegreeOfPartialPermCollection(S);
11
gap> S := InverseSemigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                          PartialPerm([1], [3]));;
gap> CodegreeOfPartialPermSemigroup(S);
11

# Test  RankOfPartialPermSemigroup/Collection 
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> RankOfPartialPermSemigroup(S);
3
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> RankOfPartialPermCollection(S);
3
gap> S := InverseSemigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                          PartialPerm([1], [3]));;
gap> RankOfPartialPermSemigroup(S);
6
gap> S := Group(PartialPerm([]));;
gap> RankOfPartialPermSemigroup(S);
0

# Test Domain/ImageOfPartialPermCollection/Semigroup
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> DomainOfPartialPermCollection(S);
[ 1 .. 3 ]
gap> ImageOfPartialPermCollection(S);
[ 3, 4, 5, 11 ]
gap> S := Semigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                   PartialPerm([1], [3]));;
gap> DomainOfPartialPermCollection(S);
[ 1 .. 3 ]
gap> ImageOfPartialPermCollection(S);
[ 3, 4, 5, 11 ]
gap> S := InverseSemigroup(PartialPerm([1, 2, 3], [4, 5, 11]), 
>                          PartialPerm([1], [3]));;
gap> DomainOfPartialPermCollection(S);
[ 1, 2, 3, 4, 5, 11 ]
gap> ImageOfPartialPermCollection(S);
[ 1, 2, 3, 4, 5, 11 ]

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

# Test Zero 
gap> S := SymmetricInverseMonoid(5);
<symmetric inverse monoid of degree 5>
gap> ZeroMutable(S);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZeroMutable' on 1 arguments
gap> ZeroImmutable(S);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZeroMutable' on 1 arguments
gap> S := Monoid(PartialPerm([2, 1]));;
gap> ZeroImmutable(S);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZeroMutable' on 1 arguments
gap> ZeroMutable(S);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZeroMutable' on 1 arguments

# Test GeneratorsOfInverseSemigroup
gap> S := Semigroup(PartialPerm([1, 3], [3, 5]), 
>                   PartialPerm([1, 3, 4], [4, 5, 1]),
>                   PartialPerm([3, 5], [1, 3]), 
>                   PartialPerm([1, 4, 5], [4, 1, 3]));;
gap> IsInverseSemigroup(S);
true
gap> GeneratorsOfInverseSemigroup(S);
[ [1,3,5], [3,5](1,4) ]

# Test GeneratorsOfInverseMonoid
gap> S := Monoid(PartialPerm([1, 3], [3, 5]), 
>                PartialPerm([1, 3, 4], [4, 5, 1]),
>                PartialPerm([3, 5], [1, 3]), 
>                PartialPerm([1, 4, 5], [4, 1, 3]));;
gap> IsInverseMonoid(S);
true
gap> GeneratorsOfInverseMonoid(S);
[ [1,3,5], [3,5](1,4) ]

#T# BruteForceIsoCheck helper functions
gap> BruteForceIsoCheck := function(iso)
>   local x, y;
>   if not IsInjective(iso) or not IsSurjective(iso) then
>     return false;
>   fi;
>   if Size(Range(iso)) <> Size(Source(iso)) then 
>     return false;
>   fi;
>   for x in GeneratorsOfSemigroup(Source(iso)) do
>     for y in GeneratorsOfSemigroup(Source(iso)) do
>       if x ^ iso * y ^ iso <> (x * y) ^ iso then
>         return false;
>       fi;
>     od;
>   od;
>   return true;
> end;;
gap> BruteForceInverseCheck := function(map)
> local inv;
>   inv := InverseGeneralMapping(map);
>   return ForAll(Source(map), x -> x = (x ^ map) ^ inv)
>     and ForAll(Range(map), x -> x = (x ^ inv) ^ map);
> end;;

# Test IsomorphismPartialPermSemigroup for a semigroup
gap> S := SemigroupByMultiplicationTable(
> [[1, 2, 2, 2, 5], 
>  [2, 2, 2, 2, 2], 
>  [2, 2, 3, 4, 2], 
>  [4, 2, 2, 2, 3],
>  [2, 2, 5, 1, 2]]);;
gap> IsInverseSemigroup(S);
true
gap> HasGeneratorsOfSemigroup(S);
true
gap> IsomorphismPartialPermSemigroup(S);
MappingByFunction( <inverse semigroup of size 5, with 5 generators>, 
<inverse partial perm semigroup of size 5, rank 5 with 5 generators>
 , function( x ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := SemigroupByMultiplicationTable(
> [[1, 1, 1, 1],
>  [1, 1, 1, 1],
>  [1, 1, 4, 2],
>  [1, 1, 2, 1]]);;
gap> IsomorphismPartialPermSemigroup(S);
Error, the argument must be an inverse semigroup

# Test IsomorphismPartialPermMonoid for a semigroup
gap> S := SemigroupByMultiplicationTable(
> [[1, 1, 1, 1],
>  [1, 1, 1, 1],
>  [1, 1, 4, 2],
>  [1, 1, 2, 1]]);;
gap> IsomorphismPartialPermMonoid(S);
Error, the argument must be a semigroup with a multiplicative neutral element
gap> S := MonoidByMultiplicationTable(
> [[1, 2, 3, 4],
>  [2, 2, 2, 2],
>  [3, 2, 2, 2],
>  [4, 2, 2, 2]]);;
gap> IsomorphismPartialPermMonoid(S);
Error, the argument must be an inverse semigroup
gap> S := MonoidByMultiplicationTable(
> [[1, 2],
>  [2, 2]]);
<monoid of size 2, with 2 generators>
gap> IsomorphismPartialPermMonoid(S);
MappingByFunction( <inverse monoid of size 2, with 2 generators>, 
<inverse partial perm monoid of size 2, rank 2 with 2 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

# Test IsomorphismPartialPermSemigroup/Monoid for a partial perm
# semigroup/monoid
gap> IsomorphismPartialPermSemigroup(SymmetricInverseMonoid(3));
MappingByFunction( <symmetric inverse monoid of degree 3>, <symmetric inverse \
monoid of degree 3>, function( object ) ... end, function( object ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> IsomorphismPartialPermMonoid(SymmetricInverseMonoid(3));
MappingByFunction( <symmetric inverse monoid of degree 3>, <symmetric inverse \
monoid of degree 3>, function( object ) ... end, function( object ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

# Test IsomorphismPartialPermMonoid for a partial perm semigroup
gap> S := Semigroup(PartialPerm([2], [2]), PartialPerm([1], [1]));;
gap> IsomorphismPartialPermMonoid(S);
Error, the argument must be a semigroup with a multiplicative neutral element
gap> S := Semigroup(PartialPerm([2, 1]));;
gap> IsomorphismPartialPermMonoid(S);;
gap> IsMonoid(Range(last));
true
gap> BruteForceIsoCheck(last2);
true
gap> BruteForceInverseCheck(last3);
true
gap> S := InverseSemigroup(PartialPerm([2, 1]));;
gap> IsomorphismPartialPermMonoid(S);;
gap> IsMonoid(Range(last));
true
gap> BruteForceIsoCheck(last2);
true
gap> BruteForceInverseCheck(last3);
true

# Test IsomorphismPartialPermSemigroup for a transformation semigroup
gap> S := Semigroup(Transformation([2, 2, 5, 1, 2, 1]),
>                   Transformation([2, 2, 2, 2, 2, 2]),
>                   Transformation([4, 2, 2, 2, 3, 3]));;
gap> IsomorphismPartialPermSemigroup(S);;
gap> IsInverseSemigroup(Range(last));
true
gap> BruteForceIsoCheck(last2);
true
gap> BruteForceInverseCheck(last3);
true
gap> S := Semigroup(Transformation([1, 1, 1, 1, 1]),
>                   Transformation([1, 3, 4, 1, 2]));;
gap> IsomorphismPartialPermSemigroup(S);
Error, the argument must be an inverse semigroup

# Test IsomorphismPartialPermSemigroup for a perm group
gap> IsomorphismPartialPermSemigroup(Group((1,2,3)));
MappingByFunction( Group([ (1,2,3) ]), <partial perm group of rank 3 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> IsomorphismPartialPermSemigroup(Group([()]));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> IsomorphismPartialPermSemigroup(Group([], ()));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> IsomorphismPartialPermMonoid(Group((1,2,3)));
MappingByFunction( Group([ (1,2,3) ]), <partial perm group of rank 3 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> IsomorphismPartialPermMonoid(Group([()]));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> IsomorphismPartialPermMonoid(Group([], ()));
MappingByFunction( Group(()), <trivial partial perm group of rank 0 with
  1 generator>, function( p ) ... end, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

# Test SymmetricInverseMonoid
gap> SymmetricInverseMonoid(-1);
Error, the argument should be a non-negative integer
gap> SymmetricInverseMonoid(0);
<symmetric inverse monoid of degree 0>
gap> SymmetricInverseMonoid(1);
<symmetric inverse monoid of degree 1>
gap> SymmetricInverseMonoid(2);
<symmetric inverse monoid of degree 2>

# Test IsSymmetricInverseSemigroup
gap> IsSymmetricInverseSemigroup(Semigroup(PartialPerm([1])));
false
gap> IsSymmetricInverseSemigroup(Semigroup(PartialPerm([])));
true

# Test NaturalPartialOrder and ReverseNaturalPartialOrder
gap> S := SymmetricInverseMonoid(3);;
gap> NaturalPartialOrder(S);
[ [  ], [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1, 2, 6 ], [ 1, 2, 7 ], 
  [ 1, 3, 5 ], [ 1, 3, 7 ], [ 1, 4, 5 ], [ 1, 4, 6 ], [ 1 ], [ 1 ], [ 1 ], 
  [ 1, 5, 15 ], [ 1, 5, 16 ], [ 1, 6, 14 ], [ 1, 6, 16 ], [ 1, 7, 14 ], 
  [ 1, 7, 15 ], [ 1, 2, 15 ], [ 1, 2, 16 ], [ 1, 2, 6, 8, 16, 20, 24 ], 
  [ 1, 2, 7, 9, 15, 22, 23 ], [ 1, 3, 14 ], [ 1, 3, 16 ], 
  [ 1, 3, 5, 10, 16, 18, 28 ], [ 1, 3, 7, 11, 14, 21, 27 ], [ 1, 4, 14 ], 
  [ 1, 4, 15 ], [ 1, 4, 5, 12, 15, 17, 32 ], [ 1, 4, 6, 13, 14, 19, 31 ] ]
gap> ReverseNaturalPartialOrder(S);
[ [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
      22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34 ], 
  [ 8, 9, 23, 24, 25, 26 ], [ 10, 11, 27, 28, 29, 30 ], 
  [ 12, 13, 31, 32, 33, 34 ], [ 10, 12, 17, 18, 29, 33 ], 
  [ 8, 13, 19, 20, 25, 34 ], [ 9, 11, 21, 22, 26, 30 ], [ 25 ], [ 26 ], 
  [ 29 ], [ 30 ], [ 33 ], [ 34 ], [ 19, 21, 27, 30, 31, 34 ], 
  [ 17, 22, 23, 26, 32, 33 ], [ 18, 20, 24, 25, 28, 29 ], [ 33 ], [ 29 ], 
  [ 34 ], [ 25 ], [ 30 ], [ 26 ], [ 26 ], [ 25 ], [  ], [  ], [ 30 ], [ 29 ], 
  [  ], [  ], [ 34 ], [ 33 ], [  ], [  ] ]

#
gap> f:=PartialPerm([1,2,3,70000],[1,2,3,100]);
[70000,100](1)(2)(3)
gap> T:=InverseSemigroup(List(GeneratorsOfInverseSemigroup(S),x->x*f));;
gap> NaturalPartialOrder(S) = NaturalPartialOrder(T);
true
gap> ReverseNaturalPartialOrder(S) = ReverseNaturalPartialOrder(T);
true

#
gap> S := InverseSemigroup([PartialPerm([2, 3, 4], [2, 5, 1]),
> PartialPerm([2], [2]), PartialPerm([1, 2, 5], [4, 2, 3])]);;
gap> NaturalPartialOrder(S);
[ [  ], [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]
gap> ReverseNaturalPartialOrder(S);
[ [ 2, 3, 4, 5 ], [  ], [  ], [  ], [  ] ]

#
gap> STOP_TEST( "semipperm.tst", 1);
