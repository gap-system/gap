#@local M, r
gap> START_TEST( "SemiEchelonMatTransformation.tst" );

# the transformation is built in the representation of the input
gap> M := Matrix( IsPlistMatrixRep, GF(4),
>              Z(4)^0 * [ [ 1, 1 ], [ 1, 1 ], [ 0, 1 ] ] );;
gap> r := SemiEchelonMatTransformation( M );;
gap> List( r.coeffs, ConstructingFilter );
[ <Representation "IsPlistVectorRep">, <Representation "IsPlistVectorRep"> ]
gap> List( r.relations, ConstructingFilter );
[ <Representation "IsPlistVectorRep"> ]
gap> r.relations[1] * M;
<plist vector over GF(2^2) of length 2>
gap> IsZero( last );
true

#
gap> STOP_TEST( "SemiEchelonMatTransformation.tst" );
