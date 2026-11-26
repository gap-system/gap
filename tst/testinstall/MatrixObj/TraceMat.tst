#@local l, m1, m2, m3, mats, M, filt
gap> START_TEST( "TraceMat.tst" );
gap> l := [[1,2],[3,4]];
[ [ 1, 2 ], [ 3, 4 ] ]
gap> m1 := Matrix(l);;
gap> m2 := Matrix(Integers,l);;
gap> m3 := Matrix(GF(7),l*One(GF(7)));;
gap> TraceMat( m1 );
5
gap> TraceMat( m2 );
5
gap> TraceMat( m3 );
Z(7)^5

# Trace agrees with TraceMat in every representation
gap> l := [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 10 ] ];;
gap> mats := [ l,
>   Matrix( IsGF2MatrixRep, GF(2), l * Z(2) ),
>   Matrix( Is8BitMatrixRep, GF(7), l * Z(7)^0 ),
>   Matrix( IsPlistMatrixRep, Integers, l ),
>   Matrix( IsGenericMatrixRep, Rationals, l ),
>   Matrix( IsZmodnZMatrixRep, Integers mod 6, l * ZmodnZObj( 1, 6 ) ),
>   ZeroMatrix( IsGenericMatrixRep, Rationals, 0, 0 ) ];;
gap> List( mats, Trace );
[ 16, 0*Z(2), Z(7)^2, 16, 16, ZmodnZObj( 4, 6 ), 0 ]
gap> ForAll( mats, M -> Trace( M ) = TraceMat( M ) );
true

# non-square input
gap> l := [ [ 1, 2, 3 ], [ 4, 5, 6 ] ];;
gap> Trace( l );
Error, matrix <M> must be square
gap> Trace( Matrix( IsPlistMatrixRep, Integers, l ) );
Error, matrix <M> must be square
gap> Trace( Matrix( IsGenericMatrixRep, Rationals, l ) );
Error, matrix <M> must be square

# a package method for its own matrix objects matches a single declaration
gap> filt := NewCategory( "IsTraceTestMatrixObj", IsMatrixObj );;
gap> InstallMethod( Trace, [ filt ], TraceMat );

#
gap> STOP_TEST("TraceMat.tst");
