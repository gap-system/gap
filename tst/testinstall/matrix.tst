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
