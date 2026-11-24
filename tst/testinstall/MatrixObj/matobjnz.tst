#@local R, v, l, c, a, b, m, w, u, pa, pv, s, G, hom
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
gap> v:= Vector( IsZmodnZVectorRep, GF(7), [ 1, 2, 3 ] );;
gap> l:= Z(7)^0 * [ 1, 2, 3 ];;
gap> v = l;
true
gap> l = v;
true

# a compressed vector is a vector object with another 'ConstructingFilter'
gap> c:= ShallowCopy( l );;
gap> ConvertToVectorRep( c, 7 );;
gap> v = c;
false
gap> c = v;
false

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

# Products with a matrix row, including a prime above the FFE range
gap> for R in [ Integers mod 15, GF(7), GF( NextPrimeInt( 2^16 ) ) ] do
>      m:= Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2 ], [ 3, 4 ] ] );
>      v:= m[1];
>      Assert( 0, Unpack( m * m ) = Unpack( m ) * Unpack( m ) );
>      Assert( 0, ForAll( RowsOfMatrix( m * m ), IsZmodnZVectorRep ) );
>      Assert( 0, IsZmodnZVectorRep( v * m ) );
>      Assert( 0, Unpack( v * m ) = Unpack( v ) * Unpack( m ) );
>    od;

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

# a range as entry list
gap> R:= Integers mod 6;;
gap> v:= Vector( IsZmodnZVectorRep, R, [ 1 .. 3 ] );;
gap> w:= Vector( IsZmodnZVectorRep, R, [ 1, 1, 1 ] );;
gap> for u in [ v, Vector( [ 1 .. 3 ], w ) ] do
>      l:= ShallowCopy( w );
>      AddRowVector( l, u, 2 );
>      Assert( 0, Unpack( l ) = [ 3, 5, 1 ] * One( R ) );
>      l:= ShallowCopy( u );
>      AddRowVector( l, w, 2 );
>      Assert( 0, Unpack( l ) = [ 3, 4, 5 ] * One( R ) );
>    od;

# integer entries are reduced
gap> R:= Integers mod 6;;
gap> v:= Vector( IsZmodnZVectorRep, R, [ 2, 5 ] );;
gap> m:= Matrix( IsZmodnZMatrixRep, R, [ [ 2, 5 ] ] );;
gap> w:= ZeroVector( 2, v );; w[1]:= 8;; w[2]:= -1;;
gap> a:= ZeroMatrix( 1, 2, m );; a[1,1]:= 8;; a[1,2]:= -1;;
gap> ForAll( [ w, Vector( IsZmodnZVectorRep, R, [ 8, -1 ] ),
>              Vector( [ 8, -1 ], v ) ], u -> u = v );
true
gap> ForAll( [ a, Matrix( IsZmodnZMatrixRep, R, [ [ 8, -1 ] ] ),
>              Matrix( [ [ 8, -1 ] ], 2, m ) ], u -> u = m );
true

# sums and differences need equal dimensions
gap> R:= Integers mod 6;;
gap> a:= ZeroMatrix( IsZmodnZMatrixRep, R, 2, 2 );;
gap> a + ZeroMatrix( IsZmodnZMatrixRep, R, 3, 3 );
Error, <a> and <b> are not compatible
gap> a - ZeroMatrix( IsZmodnZMatrixRep, R, 2, 3 );
Error, <a> and <b> are not compatible
gap> ZeroMatrix( IsZmodnZMatrixRep, R, 3, 2 ) + a;
Error, <a> and <b> are not compatible
gap> a - ZeroMatrix( IsZmodnZMatrixRep, Integers mod 4, 2, 2 );
Error, <a> and <b> are not compatible
gap> v:= ZeroVector( IsZmodnZVectorRep, R, 2 );;
gap> v + ZeroVector( IsZmodnZVectorRep, R, 3 );
Error, <a> and <b> are not compatible
gap> ZeroVector( IsZmodnZVectorRep, R, 3 ) - v;
Error, <a> and <b> are not compatible

# rows must fit the matrix
gap> R:= Integers mod 6;;
gap> m:= ZeroMatrix( IsZmodnZMatrixRep, R, 2, 2 );;
gap> v:= Vector( IsZmodnZVectorRep, Integers mod 4, [ 1, 3 ] );;
gap> w:= ZeroVector( IsZmodnZVectorRep, R, 3 );;
gap> Matrix( IsZmodnZMatrixRep, R, [ v ] );
Error, the entries of <list> must have the given base domain
gap> Matrix( [ v ], 2, m );
Error, the entries of <list> must have the given base domain
gap> Matrix( [ w ], 2, m );
Error, the entries of <list> must have length <ncols>
gap> Matrix( [ [ 1, 2, 3 ] ], 2, m );
Error, the entries of <list> must have length <ncols>
gap> m[1]:= v;
Error, <M> and <v> are not compatible
gap> m[1]:= w;
Error, <M> and <v> are not compatible
gap> Add( m, w );
Error, <M> and <v> are not compatible
gap> Add( m, v, 1 );
Error, <M> and <v> are not compatible
gap> Append( m, ZeroMatrix( IsZmodnZMatrixRep, Integers mod 4, 1, 2 ) );
Error, <M> and <N> are not compatible
gap> List( RowsOfMatrix( m ), Unpack ) = NullMat( 2, 2, R );
true

# element assignment stays inside the object
gap> R:= Integers mod 6;;
gap> m:= ZeroMatrix( IsZmodnZMatrixRep, R, 2, 2 );;
gap> m[1,3]:= 1;
Error, <col> must be at most <M>![RLPOS]
gap> v:= ZeroVector( IsZmodnZVectorRep, R, 2 );;
gap> v[3]:= 1;
Error, <p> is out of bounds
gap> List( RowsOfMatrix( m ), Length ) = [ 2, 2 ] and Length( v ) = 2;
true

# entries and scalars must lie in the base domain
gap> R:= Integers mod 6;;
gap> v:= Vector( IsZmodnZVectorRep, R, [ 1, 2 ] );;
gap> w:= ShallowCopy( v );;
gap> w[1]:= ZmodnZObj( 5, 4 );
Error, <ob> must be an integer or in the base domain of <v>
gap> w[1]:= Z(257)^5;
Error, <ob> must be an integer or in the base domain of <v>
gap> w[1]:= 1/5;
Error, <ob> must be an integer or in the base domain of <v>
gap> AddRowVector( w, v, 1/5 );
Error, <s> must be an integer or in the base domain of <v>
gap> AddRowVector( w, v, ZmodnZObj( 1, 4 ), 1, 2 );
Error, <s> must be an integer or in the base domain of <v>
gap> AddRowVector( w, Unpack( v ), 1/5 );
Error, <s> must be an integer or in the base domain of <v>
gap> MultVectorLeft( w, 1/5 );
Error, <s> must be an integer or in the base domain of <v>
gap> v * (1/5);
Error, <s> must be an integer or in the base domain of <v>
gap> (1/5) * v;
Error, <s> must be an integer or in the base domain of <v>
gap> v / 2;
Error, PowerModInt: negative <exp> but <base> is not invertible modulo <mod>
gap> w = v and v / 5 = 5 * v and v / ZmodnZObj( 5, 6 ) = 5 * v;
true

# AddRowVector needs equal base domains
gap> v:= Vector( IsZmodnZVectorRep, Integers mod 6, [ 5, 5 ] );;
gap> w:= Vector( IsZmodnZVectorRep, Integers mod 4, [ 1, 1 ] );;
gap> AddRowVector( v, w );
Error, <a> and <b> are not compatible
gap> AddRowVector( v, w, 1 );
Error, <a> and <b> are not compatible
gap> AddRowVector( v, w, 1, 1, 2 );
Error, <a> and <b> are not compatible
gap> AddRowVector( v, Unpack( w ), 1 );
Error, <a> and <b> are not compatible
gap> Unpack( v ) = [ 5, 5 ] * One( Integers mod 6 );
true

#
gap> STOP_TEST( "matobjnz.tst" );
