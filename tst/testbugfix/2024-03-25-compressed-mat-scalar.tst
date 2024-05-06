# Multiplying a compressed matrix by a scalar could result
# in corrupt data. See <https://github.com/gap-system/gap/issues/5684>
#
gap> g1 := GO(1,6,64).1;
< immutable compressed matrix 6x6 over GF(64) >
gap> a := g1*Z(2^4)^5;
< immutable compressed matrix 6x6 over GF(64) >
gap> b := g1*Z(2^2);
< immutable compressed matrix 6x6 over GF(64) >
gap> a = b;
true
gap> TransposedMat(a) = TransposedMat(b);
true
gap> List(a, Q_VEC8BIT);
[ 64, 64, 64, 64, 64, 64 ]
gap> List(b, Q_VEC8BIT);
[ 64, 64, 64, 64, 64, 64 ]

# also verify printing matches
gap> Display(a);
z = Z(64)
 z^22    .    .    .    .    .
    . z^20    .    .    .    .
    .    .    . z^21    .    .
    .    . z^21    .    .    .
    .    .    .    .    . z^21
    .    .    .    . z^21    .
gap> Display(b);
z = Z(64)
 z^22    .    .    .    .    .
    . z^20    .    .    .    .
    .    .    . z^21    .    .
    .    . z^21    .    .    .
    .    .    .    .    . z^21
    .    .    .    . z^21    .
gap> Display(TransposedMat(a));
z = Z(64)
 z^22    .    .    .    .    .
    . z^20    .    .    .    .
    .    .    . z^21    .    .
    .    . z^21    .    .    .
    .    .    .    .    . z^21
    .    .    .    . z^21    .
gap> Display(TransposedMat(b));
z = Z(64)
 z^22    .    .    .    .    .
    . z^20    .    .    .    .
    .    .    . z^21    .    .
    .    . z^21    .    .    .
    .    .    .    .    . z^21
    .    .    .    . z^21    .
