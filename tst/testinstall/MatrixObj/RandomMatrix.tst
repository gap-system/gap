#@local rs, M
gap> START_TEST( "RandomMatrix.tst" );

# with base domain
gap> Is8BitMatrixRep( RandomMatrix( GF(9), 10, 5 ) );
true
gap> RandomMatrix( GF(9), 0, 1 );
Error, Is8BitMatrixRep with zero rows not yet supported
gap> IsPlistMatrixRep( RandomMatrix( Integers, 10, 5 ) );
true
gap> IsPlistMatrixRep( RandomMatrix( Integers, 0, 0 ) );
true

# with constructing filter and base domain
gap> Is8BitMatrixRep( RandomMatrix( Is8BitMatrixRep, GF(9), 10, 5 ) );
true
gap> IsPlistMatrixRep( RandomMatrix( IsPlistMatrixRep, GF(9), 0, 0 ) );
true
gap> IsPlistRep( RandomMatrix( IsPlistRep, Integers, 10, 5 ) );
true

# with random source and base domain
gap> rs:= RandomSource(IsMersenneTwister);;
gap> Is8BitMatrixRep( RandomMatrix( Is8BitMatrixRep, GF(9), 10, 5 ) );
true
gap> IsPlistMatrixRep( RandomMatrix( IsPlistMatrixRep, GF(9), 0, 0 ) );
true
gap> IsPlistRep( RandomMatrix( IsPlistRep, Integers, 10, 5 ) );
true

# with constructing filter, random source, and base domain
gap> Is8BitMatrixRep( RandomMatrix( Is8BitMatrixRep, rs, GF(9), 10, 5 ) );
true
gap> IsPlistMatrixRep( RandomMatrix( IsPlistMatrixRep, rs, GF(9), 0, 0 ) );
true
gap> IsPlistRep( RandomMatrix( IsPlistRep, rs, Integers, 10, 5 ) );
true

# with example matrix
gap> M:= Matrix( IsPlistMatrixRep, Integers, [ 1 ], 1 );;
gap> RandomMatrix( 2, 2, M );
<2x2-matrix over Integers>
gap> RandomMatrix( 0, 0, M );
<0x0-matrix over Integers>
gap> M:= [ [ 1 ] ];;
gap> BaseDomain( M );
Rationals
gap> IsPlistRep( RandomMatrix( 2, 2, M ) );
true
gap> ForAll( Flat( RandomMatrix( 1, 2, M ) ), IsRat );
true
gap> M:= Matrix( IsPlistMatrixRep, GF(3), [ Z(3) ], 1 );;
gap> RandomMatrix( 2, 2, M );
<2x2-matrix over GF(3)>

# with random source and example matrix
gap> M:= Matrix( IsPlistMatrixRep, Integers, [ 1 ], 1 );;
gap> RandomMatrix( rs, 2, 2, M );
<2x2-matrix over Integers>
gap> RandomMatrix( rs, 0, 0, M );
<0x0-matrix over Integers>
gap> M:= [ [ 1 ] ];;
gap> IsPlistRep( RandomMatrix( rs, 2, 2, M ) );
true
gap> ForAll( Flat( RandomMatrix( rs, 1, 2, M ) ), IsRat );
true
gap> M:= Matrix( IsPlistMatrixRep, GF(3), [ Z(3) ], 1 );;
gap> RandomMatrix( rs, 2, 2, M );
<2x2-matrix over GF(3)>

#
gap> STOP_TEST( "RandomMatrix.tst" );
