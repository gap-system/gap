gap> m := NewMatrix( IsPlistMatrixRep, GF(3), 2,
>                    [ [ 0*Z(3), Z(3) ], [ Z(3)^0, 0*Z(3) ] ] );;
gap> l := Unpack( m );;
gap> IsMatrix( m );
false
gap> Order( m ) = Order( l );
true
gap> ProjectiveOrder( m ) = ProjectiveOrder( l );
true
gap> MinimalPolynomial( m ) = MinimalPolynomial( l );
true
gap> MinimalPolynomialMatrixNC( DefaultFieldOfMatrix( m ), m, 1 )
>      = MinimalPolynomialMatrixNC( DefaultFieldOfMatrix( l ), l, 1 );
true
