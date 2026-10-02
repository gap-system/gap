#@local R, v, l, c, a, b, m, w, pa, pv, s, G, hom
gap> START_TEST( "matobjnz.tst" );

# compare zmodnz vectors with lists, non-prime modulus
gap> R:= Integers mod 6;;
gap> v:= Vector( IsZmodnZVectorRep, R, [ 1, 2, 3 ] );;
gap> l:= One( R ) * [ 1, 2, 3 ];;
gap> v = l;
true
gap> l = v;
true
gap> v = One( R ) * [ 1, 2, 4 ];
false
gap> One( R ) * [ 1, 2 ] = v;
false

# prime modulus: list entries are FFEs
gap> v:= Vector( IsZmodnZVectorRep, GF(257), [ 1, 2, 3 ] );;
gap> l:= Z(257)^0 * [ 1, 2, 3 ];;
gap> v = l;
true
gap> l = v;
true

# a vector object with another 'ConstructingFilter'
gap> c:= Vector( IsPlistVectorRep, GF(257), l );;
gap> v = c;
false
gap> c = v;
false

# Arithmetic results stay in the ZmodnZ representations, for a prime
# modulus (base domain GF(257), entries are FFEs) and a composite one.
gap> for R in [ GF(257), Integers mod 8 ] do
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

# Products with a matrix row, including a prime above the FFE range
gap> for R in [ Integers mod 15, GF(257), GF( NextPrimeInt( 2^16 ) ) ] do
>      m:= Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2 ], [ 3, 4 ] ] );
>      v:= m[1];
>      Assert( 0, Unpack( m * m ) = Unpack( m ) * Unpack( m ) );
>      Assert( 0, ForAll( RowsOfMatrix( m * m ), IsZmodnZVectorRep ) );
>      Assert( 0, IsZmodnZVectorRep( v * m ) );
>      Assert( 0, Unpack( v * m ) = Unpack( v ) * Unpack( m ) );
>    od;

# Groups of ZmodnZ matrices
gap> R := Integers mod 8;;
gap> G := Group( Matrix( IsZmodnZMatrixRep, R, [ [ 3, 1 ], [ 0, 1 ] ] ),
>                Matrix( IsZmodnZMatrixRep, R, [ [ 1, 0 ], [ 2, 5 ] ] ) );;
gap> Size( G );
64
gap> hom := IsomorphismPermGroup( G );;
gap> Size( Image( hom ) );
64

# GF(p) with p <= 256 is left to the compressed representations
gap> Vector( IsZmodnZVectorRep, Integers mod 7, [ 1, 2 ] );
Error, IsZmodnZVectorRep: for GF(p) with p <= 256 use Is8BitVectorRep
gap> ZeroVector( IsZmodnZVectorRep, GF(2), 2 );
Error, IsZmodnZVectorRep: for GF(p) with p <= 256 use IsGF2VectorRep
gap> Matrix( IsZmodnZMatrixRep, GF(251), [ [ 1 ] ] );
Error, IsZmodnZMatrixRep: for GF(p) with p <= 256 use Is8BitMatrixRep
gap> ZeroMatrix( IsZmodnZMatrixRep, GF(2), 2, 2 );
Error, IsZmodnZMatrixRep: for GF(p) with p <= 256 use IsGF2MatrixRep
gap> IdentityMatrix( IsZmodnZMatrixRep, GF(7), 2 );
Error, IsZmodnZMatrixRep: for GF(p) with p <= 256 use Is8BitMatrixRep
gap> CompanionMatrix( IsZmodnZMatrixRep, X( GF(7) )^2 + 1, GF(7) );
Error, IsZmodnZMatrixRep: for GF(p) with p <= 256 use Is8BitMatrixRep

#
gap> STOP_TEST( "matobjnz.tst" );
