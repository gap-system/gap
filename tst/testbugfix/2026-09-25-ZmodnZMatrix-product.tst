# Products of 'IsZmodnZMatrixRep' matrices with such matrices or vectors
# must yield vectors in 'IsZmodnZVectorRep'.
gap> START_TEST( "2026-09-25-ZmodnZMatrix-product.tst" );
gap> for R in [ Integers mod 15, GF(7), GF( NextPrimeInt( 2^16 ) ) ] do
>      m:= Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2 ], [ 3, 4 ] ] );
>      v:= m[1];
>      Assert( 0, Unpack( m * m ) = Unpack( m ) * Unpack( m ) );
>      Assert( 0, ForAll( RowsOfMatrix( m * m ), IsZmodnZVectorRep ) );
>      Assert( 0, IsZmodnZVectorRep( v * m ) );
>      Assert( 0, Unpack( v * m ) = Unpack( v ) * Unpack( m ) );
>    od;
gap> STOP_TEST( "2026-09-25-ZmodnZMatrix-product.tst" );
