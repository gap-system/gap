gap> START_TEST("integers.tst");

#
gap> Basis(Integers);
CanonicalBasis( Integers )
gap> CanonicalBasis(Integers);
CanonicalBasis( Integers )
gap> Coefficients(Basis(Integers), 5);
[ 5 ]
gap> Coefficients(Basis(Integers), 5/2);
fail

#
gap> BestQuoInt(5, 3);
2
gap> BestQuoInt(-5, 3);
-2
gap> BestQuoInt(-5, -3);
2
gap> BestQuoInt(5, -3);
-2

#
gap> QuoInt(5, 3);
1
gap> QuoInt(-5, 3);
-1
gap> QuoInt(-5, -3);
1
gap> QuoInt(5, -3);
-1

#
gap> PrimeDivisors(0);
Error, <n> must be non zero
gap> List([1..10], PrimeDivisors);
[ [  ], [ 2 ], [ 3 ], [ 2 ], [ 5 ], [ 2, 3 ], [ 7 ], [ 2 ], [ 3 ], [ 2, 5 ] ]
gap> last = List([1..10], n->PrimeDivisors(-n));
true

#
gap> LoadPackage("factint", false);;
gap> FactorsInt(2^155-19);
[ 167, 11824964268989, 53849995530347, 429484354827785909 ]
gap> PartialFactorization(2^155-19);
[ 167, 11824964268989, 53849995530347, 429484354827785909 ]
gap> PartialFactorization(2^155-19, 1);
[ 167, 273484587823896504154881143846609846492502347 ]

#
gap> Filtered([-4..20], IsPrimePowerInt);
[ -3, -2, 2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19 ]
gap> IsPrimePowerInt(1009^1009);
true
gap> IsPrimePowerInt(1009^1009*1013);
false

#
gap> LogInt(0, 2);
Error, <n> must be a positive integer
gap> LogInt(1, 1);
Error, <base> must be an integer greater than 1
gap> ForAll([2,8,16,10,10000, 2^64], b->
>   List([ 1, b-1, b, b+1, b^2-1, b^2, b^2+1 ], n->LogInt(n,b))
>      = [ 0,   0, 1,   1,     1,   2,     2 ]);
true

#
gap> List([-8..8], NextPrimeInt);
[ -7, -5, -5, -3, -3, -2, 2, 2, 2, 2, 3, 5, 5, 7, 7, 11, 11 ]
gap> List([-8..8], PrevPrimeInt);
[ -11, -11, -7, -7, -5, -5, -3, -2, -2, -2, -2, 2, 3, 3, 5, 5, 7 ]

#
gap> PrimePowersInt(180);
[ 2, 2, 3, 2, 5, 1 ]
gap> PrimePowersInt(1);
[  ]
gap> PrimePowersInt(2);
[ 2, 1 ]
gap> PrimePowersInt(0);
Error, <n> must be non zero

#
gap> EuclideanDegree(Integers, -5);
5
gap> EuclideanDegree(Integers, 0);
0
gap> EuclideanDegree(Integers, 5);
5

#
gap> EuclideanQuotient(5, 3);
1
gap> EuclideanQuotient(-5, 3);
-1
gap> EuclideanQuotient(-5, -3);
1
gap> EuclideanQuotient(5, -3);
-1

#
gap> EuclideanRemainder(5, 3);
2
gap> EuclideanRemainder(-5, 3);
-2
gap> EuclideanRemainder(-5, -3);
-2
gap> EuclideanRemainder(5, -3);
2

#
gap> iter := Iterator(Integers);
<iterator of Integers at 0>
gap> List([1..10], i -> NextIterator(iter));
[ 0, 1, -1, 2, -2, 3, -3, 4, -4, 5 ]
gap> it2 := ShallowCopy(iter);
<iterator of Integers at 5>
gap> NextIterator(iter);
-5
gap> it2;
<iterator of Integers at 5>
gap> iter;
<iterator of Integers at -5>

#
gap> iter := Iterator(PositiveIntegers);
<iterator>
gap> List([1..10], i -> NextIterator(iter));
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> it2 := ShallowCopy(iter);
<iterator>
gap> NextIterator(iter);
11
gap> NextIterator(it2);
11

#
gap> List([-1,0,1,5/2], i -> i in Integers);
[ true, true, true, false ]
gap> List([-1,0,1,5/2], i -> i in PositiveIntegers);
[ false, false, true, false ]
gap> List([-1,0,1,5/2], i -> i in NonnegativeIntegers);
[ false, true, true, false ]

#
gap> Iterator(5);
Error, You cannot loop over the integer 5 did you mean the range [1..5]
gap> for x in 5 do od;
Error, You cannot loop over the integer 5 did you mean the range [1..5]

#
gap> STOP_TEST("integers.tst", 1);
