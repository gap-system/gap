#
gap> IsDiagonalMat(NullMat(3, 3));
true
gap> IsDiagonalMat(NullMat(1, 3));
true
gap> IsDiagonalMat(NullMat(3, 1));
true
gap> IsDiagonalMat(IdentityMat(3));
true
gap> IsDiagonalMat([[1,1],[1,1]]);
false
gap> IsDiagonalMat([[1,0],[1,1]]);
false
gap> IsDiagonalMat([[1,1],[0,1]]);
false
gap> IsDiagonalMat([[1,0],[0,1],[0,1]]);
false
gap> IsDiagonalMat([[1,0],[0,1],[0,0]]);
true
gap> IsDiagonalMat([[1,0,0],[0,1,1]]);
false
gap> IsDiagonalMat([[1,0,0],[0,1,0]]);
true

#
gap> IsUpperTriangularMat(NullMat(3, 3));
true
gap> IsUpperTriangularMat(NullMat(1, 3));
true
gap> IsUpperTriangularMat(NullMat(3, 1));
true
gap> IsUpperTriangularMat(IdentityMat(3));
true
gap> IsUpperTriangularMat([[1,1],[1,1]]);
false
gap> IsUpperTriangularMat([[1,0],[1,1]]);
false
gap> IsUpperTriangularMat([[1,1],[0,1]]);
true
gap> IsUpperTriangularMat([[1,1],[0,1],[0,1]]);
false
gap> IsUpperTriangularMat([[1,1],[0,1],[0,0]]);
true
gap> IsUpperTriangularMat([[1,1,1],[0,1,1]]);
true

#
gap> IsLowerTriangularMat(NullMat(3, 3));
true
gap> IsLowerTriangularMat(NullMat(1, 3));
true
gap> IsLowerTriangularMat(NullMat(3, 1));
true
gap> IsLowerTriangularMat(IdentityMat(3));
true
gap> IsLowerTriangularMat([[1,1],[1,1]]);
false
gap> IsLowerTriangularMat([[1,0],[1,1]]);
true
gap> IsLowerTriangularMat([[1,1],[0,1]]);
false
gap> IsLowerTriangularMat([[1,0,0],[1,1,1]]);
false
gap> IsLowerTriangularMat([[1,0,0],[1,1,0]]);
true
gap> IsLowerTriangularMat([[1,0],[1,1],[1,1]]);
true

#
gap> m := Z(5)^0 * [[0, 1], [1, 0]];;
gap> m := GeneratorsWithMemory([m])[1];;
gap> BaseDomain(m) = GF(5);
true
gap> NrRows(m);
2
gap> NumberRows(m);
2
gap> NrCols(m);
2
gap> NumberColumns(m);
2
gap> DimensionsMat(m);
[ 2, 2 ]
