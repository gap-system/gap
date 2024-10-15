gap> START_TEST("ring.tst");

#####################################################################
#
# Tests for IsIntegralRing
#
# Trivial ring
gap> IsIntegralRing( SmallRing(1,1) );
false

# Non-commutative ring
gap> IsIntegralRing( SmallRing(4,7) );
false

# Zero divisors on the diagonal
gap> IsIntegralRing( SmallRing(4,3) );
false

# Zero divisors not on the diagonal
gap> IsIntegralRing( Integers mod 6 );
false

# Integral rings
gap> IsIntegralRing( GF(5) );
true
gap> IsIntegralRing( Integers );
true
gap> IsIntegralRing( Rationals );
true
gap> IsIntegralRing( CF(4) );
true

#
gap> STOP_TEST( "ring.tst" );
