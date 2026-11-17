#
# Tests for functions defined in src/vector.c
#
#@local v, w
gap> START_TEST("kernel/vector.tst");

# sum and difference of a vector and a scalar have the mutability of the vector
gap> v := [ 1, 2, 3 ];;
gap> w := 1 + v;; w; IsMutable(w);
[ 2, 3, 4 ]
true
gap> w := v + 1;; w; IsMutable(w);
[ 2, 3, 4 ]
true
gap> w := v - 1;; w; IsMutable(w);
[ 0, 1, 2 ]
true
gap> MakeImmutable(v);;
gap> w := 1 + v;; w; IsMutable(w);
[ 2, 3, 4 ]
false
gap> w := v + 1;; w; IsMutable(w);
[ 2, 3, 4 ]
false
gap> w := v - 1;; w; IsMutable(w);
[ 0, 1, 2 ]
false

#
gap> STOP_TEST("kernel/vector.tst");
