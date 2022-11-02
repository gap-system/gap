gap> mat := [[1,2,1],[1,0,1],[0,0,1]];
[ [ 1, 2, 1 ], [ 1, 0, 1 ], [ 0, 0, 1 ] ]
gap> Eigenvalues(Rationals,mat);
[ 2, 1, -1 ]
gap> matObj1 := NewMatrix(IsPlistMatrixRep,GF(5),3,mat*Z(5)^0);
<3x3-matrix over GF(5)>
gap> Eigenvalues(GF(5),matObj1);
[ Z(5)^2, Z(5)^0, Z(5) ]
