#############################################################################
##
#W  semitran.tst
#Y  James D. Mitchell
##
#############################################################################
##
gap> START_TEST("semitran.tst");

# Test that the inverse of an isomorphism from a partial perm monoid to a
# transformation monoid is really the inverse.
gap> S := InverseMonoid(PartialPerm([1, 2], [2, 1]),
>                       PartialPerm([1, 2], [3, 1]));
<inverse partial perm monoid of rank 3 with 2 generators>
gap> map := IsomorphismTransformationMonoid(S);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(S, x -> (x ^ map) ^ inv = x);
true
gap> ForAll(Range(map), x -> (x ^ inv) ^ map = x);
true

# Test that the inverse of an isomorphism from a partial perm semigroup to a
# transformation semigroup is really the inverse.
gap> S := InverseSemigroup(PartialPerm([1, 2], [2, 1]),
>                          PartialPerm([1, 2], [3, 1]));
<inverse partial perm semigroup of rank 3 with 2 generators>
gap> map := IsomorphismTransformationSemigroup(S);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(S, x -> (x ^ map) ^ inv = x);
true
gap> ForAll(Range(map), x -> (x ^ inv) ^ map = x);
true

# Test IsFullTransformationSemigroup in trivial cases
gap> IsFullTransformationSemigroup(Semigroup(Transformation([1])));
true
gap> IsFullTransformationSemigroup(Semigroup(Transformation([1, 1])));
false

# Test IsomorphismTransformationMonoid for a perm group
gap> G := Group((2,3)(5,6)(8,9)(11,12)(14,15)(17,18)(20,21)(23,24)
> (26,27)(29,30));;
gap> map := IsomorphismTransformationMonoid(G);;
gap> inv := InverseGeneralMapping(map);;
gap> ForAll(G, x -> (x ^ map) ^ inv = x);
true
gap> ForAll(Range(map), x -> (x ^ inv) ^ map = x);
true

# Test PrintObj for a transformation group (can't actually test for this)
# gap> Print(Semigroup(IdentityTransformation));
# Test SemigroupViewStringPrefix
gap> S := Semigroup(IdentityTransformation);
<trivial transformation group of degree 0 with 1 generator>

# Test < 
gap> T := Semigroup(Transformation([2, 3, 1]));
<commutative transformation semigroup of degree 3 with 1 generator>
gap> S < T;
true
gap> S = T;
false
gap> S > T;
false

# Test MovedPoints
gap> S := Semigroup(Transformation([6, 10, 1, 4, 6, 5, 1, 2, 3, 3]));;
gap> MovedPoints(S);
[ 1, 2, 3, 5, 6, 7, 8, 9, 10 ]
gap> S := Semigroup(IdentityTransformation);;
gap> MovedPoints(S);
[  ]

# Test NrMovedPoints 
gap> S := Semigroup(Transformation([7, 1, 4, 3, 2, 7, 7, 6, 6, 5]));;
gap> NrMovedPoints(S);
9
gap> NrMovedPoints(Semigroup(IdentityTransformation));
0

# Test LargestMovedPoint
gap> S := Semigroup(Transformation([6, 10, 1, 4, 6, 5, 1, 2, 3, 3]));;
gap> LargestMovedPoint(S);
10
gap> S := Semigroup(IdentityTransformation);;
gap> LargestMovedPoint(S);
0

# Test SmallestMovedPoint
gap> S := Semigroup(Transformation([6, 10, 1, 4, 6, 5, 1, 2, 3, 3]));;
gap> SmallestMovedPoint(S);
1
gap> S := Semigroup(IdentityTransformation);;
gap> SmallestMovedPoint(S);
infinity

# Test LargestImageOfMovedPoint
gap> S := Semigroup(Transformation([1, 1, 1]));;
gap> LargestImageOfMovedPoint(S);
1
gap> S := Semigroup(Transformation([3, 3, 3]));;
gap> LargestImageOfMovedPoint(S);
3
gap> S := Semigroup(IdentityTransformation);;
gap> LargestImageOfMovedPoint(S);
0

# Test SmallestImageOfMovedPoint
gap> S := Semigroup(Transformation([1, 1, 1]));;
gap> SmallestImageOfMovedPoint(S);
1
gap> S := Semigroup(Transformation([3, 3, 3]));;
gap> SmallestImageOfMovedPoint(S);
3
gap> S := Semigroup(IdentityTransformation);;
gap> SmallestImageOfMovedPoint(S);
infinity

# Test ViewString for a full transformation monoid
gap> ViewString(FullTransformationMonoid(2));
"<full transformation monoid of degree 2>"
gap> ViewString(FullTransformationMonoid(1));
"<full transformation monoid of degree 0>"

# Test AsMonoid
gap> S := Semigroup(Transformation([1, 4, 6, 2, 5, 3, 7, 8, 9, 9]),
>                   Transformation([6, 3, 2, 7, 5, 1, 8, 8, 9, 9]));;
gap> AsMonoid(S);;
gap> IsMonoid(last);
true
gap> AsMonoid(last2) = last2;
true
gap> S := Semigroup(Transformation([2, 2]), Transformation([2, 1, 2]));;
gap> AsMonoid(S);
fail

# Test DegreeOfTransformationSemigroup for a transformation semigroup with
# generators of a group
gap> S := Group(Transformation([2,1,3]));
<transformation group of degree 2 with 1 generator>
gap> DegreeOfTransformationSemigroup(S);
2
gap> S := Group(IdentityTransformation);
<transformation group of degree 0 with 1 generator>
gap> GeneratorsOfGroup(S);
[ IdentityTransformation ]
gap> S := Semigroup(IdentityTransformation);
<trivial transformation group of degree 0 with 1 generator>

# Test IsomorphismPermGroup for an H-class
gap> S := FullTransformationMonoid(4);;
gap> H := GreensHClassOfElement(S, One(S));;
gap> IsomorphismPermGroup(H);;
gap> H := GreensHClassOfElement(S, Transformation([1, 1, 2, 3]));;

# The Semigroups package produces different output so this test is supressed
#gap> IsomorphismPermGroup(H);
#Error, can only create isomorphisms of group H-classes

# Test FullTransformationMonoid 
gap> FullTransformationMonoid(2);
<full transformation monoid of degree 2>
gap> FullTransformationMonoid(0);
Error, the argument must be a positive integer

# Test IsFullTransformationMonoid 
gap> S := Semigroup(GeneratorsOfSemigroup(FullTransformationMonoid(3)));
<transformation monoid of degree 3 with 3 generators>
gap> IsFullTransformationSemigroup(S);
true
gap> S := Semigroup(IdentityTransformation);
<trivial transformation group of degree 0 with 1 generator>
gap> IsFullTransformationSemigroup(S);
true
gap> S := Semigroup(GeneratorsOfSemigroup(FullTransformationMonoid(3)));
<transformation monoid of degree 3 with 3 generators>
gap> Size(S);
27
gap> IsFullTransformationSemigroup(S);
true

# Test \in for a FullTransformationMonoid and Transformation
gap> Transformation([1, 10], [2, 5]) in FullTransformationMonoid(10);
true
gap> Transformation([1, 10], [2, 5]) in FullTransformationMonoid(2);
false

# Test Enumerator for a full transformation monod
gap> enum := Enumerator(FullTransformationMonoid(3));;
gap> ForAll(enum, x -> enum[Position(enum, x)] = x);
true
gap> ForAll([1 .. 27], i -> Position(enum, enum[i]) = i);
true
gap> Length(enum);
27
gap> ForAll(enum, x -> x in enum);
true
gap> enum[28];
fail
gap> Position(enum, Transformation([5], [1]));
fail

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

# Test IsomorphismTransformationSemigroup for a semigroup
gap> S := SemigroupByMultiplicationTable([[1, 1, 1], [1, 1, 1], [1, 1, 1]]);;
gap> IsomorphismTransformationSemigroup(S);
MappingByFunction( <semigroup of size 3, with 3 generators>, <transformation 
 semigroup of size 3, degree 4 with 3 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := SymmetricInverseMonoid(3);;
gap> I := SemigroupIdealByGenerators(S, [S.3]);;
gap> HasGeneratorsOfSemigroup(I);
false
gap> IsomorphismTransformationSemigroup(I);;
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := SemigroupByMultiplicationTable([[1, 2, 3], [2, 3, 3], [3, 3, 3]]);
<semigroup of size 3, with 3 generators>
gap> MultiplicativeNeutralElement(S);
m1
gap> IsomorphismTransformationSemigroup(S);
MappingByFunction( <semigroup of size 3, with 3 generators>, <transformation 
 monoid of size 3, degree 3 with 2 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

# Test IsomorphismTransformationMonoid for a semigroup
gap> S := MonoidByMultiplicationTable([[1, 2, 3], [2, 3, 3], [3, 3, 3]]);
<monoid of size 3, with 3 generators>
gap> IsomorphismTransformationMonoid(S);
MappingByFunction( <monoid of size 3, with 3 generators>, <transformation 
 monoid of size 3, degree 3 with 3 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := SemigroupByMultiplicationTable([[1, 1, 1], [1, 1, 1], [1, 1, 1]]);;
gap> IsomorphismTransformationMonoid(S);
Error, the argument must be a semigroup with a multiplicative neutral element

# Test IsomorphismTransformationMonoid for a transformation semigroup
gap> S := Semigroup(Transformation([1, 4, 6, 2, 5, 3, 7, 8, 9, 9]),
>                   Transformation([6, 3, 2, 7, 5, 1, 8, 8, 9, 9]));;
gap> IsomorphismTransformationMonoid(S);;
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := Semigroup([Transformation([2, 2]), Transformation([2, 1, 2])]);;
gap> IsomorphismTransformationMonoid(S);
Error, the argument must be a semigroup with a multiplicative neutral element

# Test IsomorphismTransformationSemigroup for a transformation semigroup
gap> S := Semigroup(Transformation([1, 4, 6, 2, 5, 3, 7, 8, 9, 9]));;
gap> IsomorphismTransformationSemigroup(S);
MappingByFunction( <commutative transformation semigroup of degree 10 with 1 
 generator>, <commutative transformation semigroup of degree 10 with 1 
 generator>, function( object ) ... end, function( object ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

# Test IsomorphismTransformationMonoid for a partial perm monoid
gap> S := SymmetricInverseMonoid(3);;
gap> IsomorphismTransformationMonoid(S);
MappingByFunction( <symmetric inverse monoid of degree 3>, <transformation 
 monoid of degree 4 with 4 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> T := SemigroupIdealByGenerators(S, [S.3]);;
gap> IsomorphismTransformationMonoid(T);
Error, the argument must be a semigroup with a multiplicative neutral element
gap> T := SemigroupIdealByGenerators(S, [S.1]);;
gap> IsomorphismTransformationMonoid(T);;
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

# Test IsomorphismTransformationSemigroup for a perm group
gap> IsomorphismTransformationSemigroup(Group((1,2,3)));
MappingByFunction( Group([ (1,2,3) ]), <transformation group of degree 3 with
  1 generator>, <Attribute "AsTransformation">, <Attribute "AsPermutation"> )
gap> BruteForceIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

#T# BruteForceAntiIsoCheck helper functions
gap> BruteForceAntiIsoCheck := function(iso)
>   local x, y;
>   if not IsInjective(iso) or not IsSurjective(iso) then
>     return false;
>   fi;
>   if Size(Range(iso)) <> Size(Source(iso)) then 
>     return false;
>   fi;
>   for x in GeneratorsOfSemigroup(Source(iso)) do
>     for y in GeneratorsOfSemigroup(Source(iso)) do
>       if x ^ iso * y ^ iso <> (y * x) ^ iso then
>         return false;
>       fi;
>     od;
>   od;
>   return true;
> end;;

# Test AntiIsomorphismTransformationSemigroup for a semigroup
gap> S := SemigroupByMultiplicationTable([[1, 1, 1], [1, 1, 1], [1, 1, 1]]);;
gap> AntiIsomorphismTransformationSemigroup(S);
MappingByFunction( <semigroup of size 3, with 3 generators>, <transformation 
 semigroup of degree 4 with 3 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceAntiIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := SymmetricInverseMonoid(3);;
gap> I := SemigroupIdealByGenerators(S, [S.3]);;
gap> HasGeneratorsOfSemigroup(I);
false
gap> AntiIsomorphismTransformationSemigroup(I);;
gap> BruteForceAntiIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true
gap> S := SemigroupByMultiplicationTable([[1, 2, 3], [2, 3, 3], [3, 3, 3]]);
<semigroup of size 3, with 3 generators>
gap> MultiplicativeNeutralElement(S);
m1
gap> AntiIsomorphismTransformationSemigroup(S);
MappingByFunction( <semigroup of size 3, with 3 generators>, <transformation 
 monoid of degree 3 with 2 generators>
 , function( x ) ... end, function( x ) ... end )
gap> BruteForceAntiIsoCheck(last);
true
gap> BruteForceInverseCheck(last2);
true

#
gap> STOP_TEST( "semitran.tst", 1);
