#@local R, a, b, v, w, pa, pv, s, G, hom
gap> START_TEST( "matobjnz.tst" );

# Arithmetic results stay in the ZmodnZ representations, for a prime
# modulus (base domain GF(7), entries are FFEs) and a composite one.
gap> for R in [ Integers mod 7, Integers mod 8 ] do
>   a := Matrix( IsZmodnZMatrixRep, R, [ [ 3, 1, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] );
>   b := Matrix( IsZmodnZMatrixRep, R, [ [ 1, 0, 0 ], [ 2, 5, 0 ], [ 0, 1, 1 ] ] );
>   v := Vector( IsZmodnZVectorRep, R, [ 1, 2, 3 ] );
>   pa := Unpack( a );
>   pv := Unpack( v );
>   s := 3 * One( R );
>   w := ShallowCopy( v );
>   AddRowVector( w, v, s );
>   Assert( 0, IsZmodnZVectorRep( w ) and Unpack( w ) = pv + pv * s );
>   w := ShallowCopy( v );
>   MultVector( w, s );
>   Assert( 0, IsZmodnZVectorRep( w ) and Unpack( w ) = pv * s );
>   for w in [ v * s, s * v, v / s ] do
>     Assert( 0, IsZmodnZVectorRep( w ) );
>   od;
>   Assert( 0, Unpack( v * s ) = pv * s and Unpack( v / s ) = pv / s );
>   for w in [ v + pv, pv + v, v - pv, pv - v ] do
>     Assert( 0, IsZmodnZVectorRep( w ) );
>   od;
>   Assert( 0, IsZero( v - pv ) and Unpack( v + pv ) = 2 * pv );
>   Assert( 0, IsZmodnZMatrixRep( a * b ) and Unpack( a * b ) = pa * Unpack( b ) );
>   Assert( 0, IsZmodnZMatrixRep( a * pa ) and Unpack( a * pa ) = pa * pa );
>   for w in [ v * a, v ^ a, pv * a, pv ^ a, v * pa, v ^ pa ] do
>     Assert( 0, IsZmodnZVectorRep( w ) and Unpack( w ) = pv * pa );
>   od;
> od;

# Groups of ZmodnZ matrices
gap> R := Integers mod 7;;
gap> G := Group( Matrix( IsZmodnZMatrixRep, R, [ [ 3, 1, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] ),
>                Matrix( IsZmodnZMatrixRep, R, [ [ 1, 0, 0 ], [ 2, 5, 0 ], [ 0, 1, 1 ] ] ) );;
gap> Size( G );
98784
gap> R := Integers mod 8;;
gap> G := Group( Matrix( IsZmodnZMatrixRep, R, [ [ 3, 1 ], [ 0, 1 ] ] ),
>                Matrix( IsZmodnZMatrixRep, R, [ [ 1, 0 ], [ 2, 5 ] ] ) );;
gap> Size( G );
64
gap> hom := IsomorphismPermGroup( G );;
gap> Size( Image( hom ) );
64

#
gap> STOP_TEST( "matobjnz.tst" );
