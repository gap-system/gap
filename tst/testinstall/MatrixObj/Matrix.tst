gap> START_TEST("Matrix.tst");

#
gap> m := Matrix( [[1,2],[3,4]] );
<2x2-matrix over Rationals>
gap> Display(m);
<2x2-matrix over Rationals:
[[ 1, 2 ]
 [ 3, 4 ]
]>

#
gap> m := Matrix( [[1,2],[3,4]] * Z(2) );
<a 2x2 matrix over GF2>
gap> Display(m);
 1 .
 1 .

#
gap> m := Matrix( IsGF2MatrixRep, GF(2), [[1,2],[3,4]] * Z(2) );
<a 2x2 matrix over GF2>
gap> Display(m);
 1 .
 1 .
gap> m = Matrix( IsGF2MatrixRep, GF(2), [1,2,3,4] * Z(2), 2 );
true

#
gap> m := Matrix( Is8BitMatrixRep, GF(4), [[1,2],[3,4]] * Z(2) );
[ [ Z(2)^0, 0*Z(2) ], [ Z(2)^0, 0*Z(2) ] ]
gap> Display(m);
 1 .
 1 .
gap> m = Matrix( Is8BitMatrixRep, GF(4), [1,2,3,4] * Z(2), 2 );
true

#
gap> m := Matrix( IsPlistMatrixRep, GF(2), [[1,2],[3,4]] * Z(2) );
<2x2-matrix over GF(2)>
gap> Display(m);
<2x2-matrix over GF(2):
[[ Z(2)^0, 0*Z(2) ]
 [ Z(2)^0, 0*Z(2) ]
]>
gap> m = Matrix( IsPlistMatrixRep, GF(2), [1,2,3,4] * Z(2), 2 );
true

#
gap> m := Matrix( IsGenericMatrixRep, GF(2), [[1,2],[3,4]] * Z(2) );
<2x2-matrix over GF(2)>
gap> Display(m);
<2x2-matrix over GF(2):
[[ Z(2)^0, 0*Z(2) ]
 [ Z(2)^0, 0*Z(2) ]
]>
gap> m = Matrix( IsGenericMatrixRep, GF(2), [1,2,3,4] * Z(2), 2 );
true

#
# vector objects as rows of compressed matrices
#
gap> Matrix( GF(9), [ NewVector( IsPlistVectorRep, GF(9), [ Z(9), 0*Z(9) ] ),
>                     NewVector( IsPlistVectorRep, GF(9), [ 0*Z(9), Z(9)^0 ] ) ] )
>    = Matrix( GF(9), [ [ Z(9), 0*Z(9) ], [ 0*Z(9), Z(9)^0 ] ] );
true
gap> Matrix( GF(2), [ NewVector( IsPlistVectorRep, GF(2), [ Z(2), 0*Z(2) ] ) ] )
>    = Matrix( GF(2), [ [ Z(2), 0*Z(2) ] ] );
true
gap> Matrix( GF(9), [ Vector( GF(9), [ Z(9), 0*Z(9) ] ),
>                     NewVector( IsPlistVectorRep, GF(9), [ 0*Z(9), Z(9)^0 ] ) ] )
>    = Matrix( GF(9), [ [ Z(9), 0*Z(9) ], [ 0*Z(9), Z(9)^0 ] ] );
true

#
gap> STOP_TEST("Matrix.tst");
