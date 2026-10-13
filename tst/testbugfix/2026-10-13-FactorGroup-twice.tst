# Forming the same factor group twice returned a second group which knew
# nothing the first one did, such as its size, see #6720
gap> G:= Group( (1,2,3,4,5), (1,2), (6,7,8) );;
gap> F1:= G / Group( (6,7,8) );;
gap> F2:= G / Group( (6,7,8) );;
gap> IsIdenticalObj( F1, F2 );
true

# unrelated natural homomorphisms can share their image
gap> S4:= SymmetricGroup( 4 );;  S6:= SymmetricGroup( 6 );;
gap> A:= S4 / DerivedSubgroup( S4 );;
gap> B:= S6 / DerivedSubgroup( S6 );;
gap> IsIdenticalObj( A, B );
false
gap> IsIdenticalObj( A, S4 / DerivedSubgroup( S4 ) );
true
gap> IsIdenticalObj( B, S6 / DerivedSubgroup( S6 ) );
true
gap> Source( NaturalHomomorphism( A ) ) = S4;
#I  `NaturalHomomorphism` for a `FactorGroup` is deprecated; use `NaturalHomomorphismByNormalSubgroup` instead.
true
gap> Source( NaturalHomomorphism( B ) ) = S6;
#I  `NaturalHomomorphism` for a `FactorGroup` is deprecated; use `NaturalHomomorphismByNormalSubgroup` instead.
true
