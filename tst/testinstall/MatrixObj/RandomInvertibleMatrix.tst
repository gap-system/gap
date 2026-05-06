#@local rs, M
gap> START_TEST( "RandomInvertibleMatrix.tst" );

# with base domain
gap> Is8BitMatrixRep( RandomInvertibleMatrix( GF(9), 10 ) );
true
gap> IsPlistMatrixRep( RandomInvertibleMatrix( Integers, 10 ) );
true

# with constructing filter and base domain
gap> Is8BitMatrixRep( RandomInvertibleMatrix( Is8BitMatrixRep, GF(9), 10 ) );
true
gap> IsPlistRep( RandomInvertibleMatrix( IsPlistRep, Integers, 10 ) );
true

# with random source and base domain
gap> rs:= RandomSource(IsMersenneTwister);;
gap> Is8BitMatrixRep( RandomInvertibleMatrix( Is8BitMatrixRep, GF(9), 10 ) );
true
gap> IsPlistRep( RandomInvertibleMatrix( IsPlistRep, Integers, 10 ) );
true

# with constructing filter, random source, and base domain
gap> Is8BitMatrixRep( RandomInvertibleMatrix( Is8BitMatrixRep, rs, GF(9), 10 ) );
true
gap> IsPlistRep( RandomInvertibleMatrix( IsPlistRep, rs, Integers, 10 ) );
true

# with example matrix
gap> M:= Matrix( IsPlistMatrixRep, Integers, [ 1 ], 1 );;
gap> RandomInvertibleMatrix( 2, M );
<2x2-matrix over Integers>
gap> M:= [ [ 1 ] ];;
gap> IsPlistRep( RandomInvertibleMatrix( 2, M ) );
true
gap> M:= Matrix( IsPlistMatrixRep, GF(3), [ Z(3) ], 1 );;
gap> RandomInvertibleMatrix( 2, M );
<2x2-matrix over GF(3)>

# with random source and example matrix
gap> M:= Matrix( IsPlistMatrixRep, Integers, [ 1 ], 1 );;
gap> RandomInvertibleMatrix( rs, 2, M );
<2x2-matrix over Integers>
gap> M:= [ [ 1 ] ];;
gap> IsPlistRep( RandomInvertibleMatrix( rs, 2, M ) );
true
gap> M:= Matrix( IsPlistMatrixRep, GF(3), [ Z(3) ], 1 );;
gap> RandomInvertibleMatrix( rs, 2, M );
<2x2-matrix over GF(3)>

#
gap> STOP_TEST( "RandomInvertibleMatrix.tst" );
