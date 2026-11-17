#@local a, b, c, F, G, p, q, z
gap> START_TEST("MatrixGroupMixing.tst");

# plain and compressed list matrices may be mixed
gap> a:= [ [ 0, 1 ], [ 1, 0 ] ] * Z(5)^0;;
gap> b:= [ [ 1, 1 ], [ 0, 1 ] ] * Z(5)^0;;
gap> G:= Group( a, ImmutableMatrix( GF(5), b ) );;
gap> Size( G );
240
gap> Size( Group( [ a ], ImmutableMatrix( GF(25), One( a ) ) ) );
2

# list matrices and matrix objects
gap> p:= Matrix( IsPlistMatrixRep, GF(5), b );;
gap> Group( ImmutableMatrix( GF(5), a ), p );
Error, <gens> must not mix list matrices and matrix objects
gap> Group( p, a );
Error, <gens> must not mix list matrices and matrix objects
gap> Group( [ a ], One( p ) );
Error, <gens> must not mix list matrices and matrix objects
gap> Group( [ p ], IdentityMat( 2, GF(5) ) );
Error, <gens> must not mix list matrices and matrix objects
gap> z:= ZmodnZ( 8 );;
gap> Group( [ [ 1, 1 ], [ 0, 1 ] ] * One( z ),
>           Matrix( IsZmodnZMatrixRep, z, [ [ 0, 1 ], [ 1, 0 ] ] * One( z ) ) );
Error, <gens> must not mix list matrices and matrix objects

# matrix objects in different representations
gap> q:= Matrix( IsGenericMatrixRep, GF(5), a );;
gap> Group( p, q );
Error, <gens> must not mix matrix objects with different representations
gap> Group( [ p ], One( q ) );
Error, <gens> must not mix matrix objects with different representations

# matrix objects over different base domains
gap> Group( p, Matrix( IsPlistMatrixRep, GF(25), a ) );
Error, <gens> must not mix matrix objects with different base domains
gap> Group( Matrix( IsPlistMatrixRep, Integers, [ [ 1, 1 ], [ 0, 1 ] ] ),
>           Matrix( IsPlistMatrixRep, Rationals, [ [ 0, 1 ], [ 1, 0 ] ] ) );
Error, <gens> must not mix matrix objects with different base domains

# base domains are compared by identity, as in the arithmetic of matrix
# objects
gap> F:= FieldByGenerators( [ Z(9) ] );;
gap> F = GF(9) and not IsIdenticalObj( F, GF(9) );
true
gap> Group( Matrix( IsPlistMatrixRep, GF(9), [ [ 0, 1 ], [ 1, 0 ] ] * Z(9)^0 ),
>           Matrix( IsPlistMatrixRep, F, [ [ 1, 1 ], [ 0, 1 ] ] * Z(9)^0 ) );
Error, <gens> must not mix matrix objects with different base domains

# uniform matrix objects
gap> c:= Matrix( IsPlistMatrixRep, GF(5), a );;
gap> G:= Group( c, p );;
gap> IsPlistMatrixRep( One( G ) );
true
gap> G:= Group( [ c ], One( p ) );;
gap> One( G ) = One( p );
true

#
gap> STOP_TEST("MatrixGroupMixing.tst");
