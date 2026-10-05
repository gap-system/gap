# Compressing lists of prime field elements in 'IsZmodpZObjSmall'
# must not silently produce wrong entries.
gap> START_TEST( "2026-09-25-ZmodpZObjSmall-compress.tst" );
gap> z0:= ZmodnZObj( FamilyObj( Z(7) ), 0 );;
gap> z3:= ZmodnZObj( FamilyObj( Z(7) ), 3 );;
gap> AsInternalFFE( z0 ); AsInternalFFE( z3 );
0*Z(7)
Z(7)
gap> NewVector( Is8BitVectorRep, GF(7), [ z0, z0 ] );
[ 0*Z(7), 0*Z(7) ]
gap> CopyToVectorRep( [ z3, z0 ], 49 );
[ Z(7), 0*Z(7) ]
gap> l:= [ z0, z3 ];;
gap> ConvertToVectorRep( l );
7
gap> l;
[ 0*Z(7), Z(7) ]
gap> Is8BitVectorRep( l );
true
gap> l:= [ z3, Z(49) ];;
gap> ConvertToVectorRep( l );
49
gap> l;
[ Z(7), Z(7^2) ]

# GF(2)
gap> o:= ZmodnZObj( FamilyObj( Z(2) ), 1 );;
gap> l:= [ o, 0*Z(2) ];;
gap> ConvertToVectorRep( l );
2
gap> l;
<a GF2 vector of length 2>
gap> l = [ Z(2), 0*Z(2) ];
true

# a ZmodnZ vector over a small prime field
gap> v:= Vector( IsZmodnZVectorRep, GF(7), [ 1, 0, 2 ] );;
gap> ImmutableVector( GF(7), v );
[ Z(7)^0, 0*Z(7), Z(7)^2 ]
gap> w:= ChangedBaseDomain( v, GF(49) );;
gap> Unpack( w );
[ Z(7)^0, 0*Z(7), Z(7)^2 ]

# large primes have no internal FFEs
gap> AsInternalFFE( One( GF( NextPrimeInt( 2^16 ) ) ) );
fail
gap> STOP_TEST( "2026-09-25-ZmodpZObjSmall-compress.tst" );
