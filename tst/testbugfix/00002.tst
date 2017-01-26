##  Check if ConvertToMatrixRepNC works properly. BH
##
gap> mat := [[1,0,1,1],[0,1,1,1]]*One(GF(2));
[ [ Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0 ] ]
gap> ConvertToMatrixRepNC( mat, GF(2) );
2
gap> DimensionsMat(mat);
[ 2, 4 ]
gap> mat := [[1,0,1,1],[0,1,1,1]]*One(GF(3));
[ [ Z(3)^0, 0*Z(3), Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0, Z(3)^0, Z(3)^0 ] ]
gap> ConvertToMatrixRepNC( mat, GF(3) );
3
gap> DimensionsMat(mat);
[ 2, 4 ]
