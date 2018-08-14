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

#
gap> m := Matrix( Is8BitMatrixRep, GF(4), [[1,2],[3,4]] * Z(2) );
[ [ Z(2)^0, 0*Z(2) ], [ Z(2)^0, 0*Z(2) ] ]
gap> Display(m);
 1 .
 1 .

#
gap> m := Matrix( IsPlistMatrixRep, GF(2), [[1,2],[3,4]] * Z(2) );
<2x2-matrix over GF(2)>
gap> Display(m);
<2x2-matrix over GF(2):
[[ Z(2)^0, 0*Z(2) ]
 [ Z(2)^0, 0*Z(2) ]
]>

#
gap> STOP_TEST("Matrix.tst");
