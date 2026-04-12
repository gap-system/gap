#
gap> empty_0x2 := NewZeroMatrix(IsPlistMatrixRep, Integers, 0, 2);
<0x2-matrix over Integers>
gap> empty_2x0 := NewZeroMatrix(IsPlistMatrixRep, Integers, 2, 0);
<2x0-matrix over Integers>
gap> empty_0x0 := NewZeroMatrix(IsPlistMatrixRep, Integers, 0, 0);
<0x0-matrix over Integers>
gap> IsEmptyMatrix(empty_0x2);
true
gap> IsEmptyMatrix(empty_2x0);
true
gap> IsEmptyMatrix(empty_0x0);
true

#
gap> IsGeneralizedCartanMatrix(NullMat(3, 3));
false
gap> IsGeneralizedCartanMatrix(NullMat(1, 3));
Error, <A> must be a square matrix
gap> IsGeneralizedCartanMatrix([[1,1],[1,1]]);
false
gap> IsGeneralizedCartanMatrix([[2,1],[1,2]]);
false
gap> IsGeneralizedCartanMatrix([[2,1],[0,2]]);
false
gap> IsGeneralizedCartanMatrix([[2,0],[1,2]]);
false
gap> IsGeneralizedCartanMatrix([[2,0],[0,2]]);
true
gap> IsGeneralizedCartanMatrix([[2,-1],[-1,2]]);
true
gap> IsGeneralizedCartanMatrix([[2,-1],[-2,2]]);
true
gap> IsGeneralizedCartanMatrix([[2,-2],[-2,2]]);
true

#
gap> IsDiagonalMat(empty_0x2);
true
gap> IsDiagonalMat(empty_2x0);
true
gap> IsDiagonalMat(empty_0x0);
true
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
gap> IsUpperTriangularMat(empty_0x2);
true
gap> IsUpperTriangularMat(empty_2x0);
true
gap> IsUpperTriangularMat(empty_0x0);
true
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
gap> IsLowerTriangularMat(empty_0x2);
true
gap> IsLowerTriangularMat(empty_2x0);
true
gap> IsLowerTriangularMat(empty_0x0);
true
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
gap> IsSquareMat(empty_0x2);
false
gap> IsSquareMat(empty_2x0);
false
gap> IsSquareMat(empty_0x0);
true
gap> IsSquareMat(NullMat(3, 3));
true
gap> IsSquareMat(IdentityMat(3));
true
gap> IsSquareMat([[1]]);
true
gap> IsSquareMat([[1,2],[3,4]]);
true
gap> IsSquareMat(NullMat(2, 3));
false
gap> IsSquareMat(NullMat(3, 2));
false
gap> IsSquareMat([[1,2,3],[4,5,6]]);
false

#
gap> IsSymmetricMat(empty_0x2);
false
gap> IsSymmetricMat(empty_2x0);
false
gap> IsSymmetricMat(empty_0x0);
true
gap> IsSymmetricMat(NullMat(3, 3));
true
gap> IsSymmetricMat(IdentityMat(3));
true
gap> IsSymmetricMat([[1]]);
true
gap> IsSymmetricMat([[1,2],[2,1]]);
true
gap> IsSymmetricMat([[1,2,3],[2,4,5],[3,5,6]]);
true
gap> IsSymmetricMat([[0,1],[2,0]]);
false
gap> IsSymmetricMat([[1,1],[1,1]]);
true
gap> IsSymmetricMat(NullMat(2, 3));
false
gap> IsSymmetricMat(NullMat(3, 2));
false
gap> IsSymmetricMat([[1,2,3],[2,4,5]]);
false
gap> IsSymmetricMat([[1,2],[3,4],[5,6]]);
false

#
gap> IsAntisymmetricMat(empty_0x2);
false
gap> IsAntisymmetricMat(empty_2x0);
false
gap> IsAntisymmetricMat(empty_0x0);
true
gap> IsAntisymmetricMat(NullMat(3, 3));
true
gap> IsAntisymmetricMat([[0]]);
true
gap> IsAntisymmetricMat([[0,1],[-1,0]]);
true
gap> IsAntisymmetricMat([[0,2,3],[-2,0,5],[-3,-5,0]]);
true
gap> IsAntisymmetricMat([[0,1],[1,0]]);
false
gap> IsAntisymmetricMat([[1,0],[0,1]]);
false
gap> IsAntisymmetricMat(NullMat(2, 3));
false
gap> IsAntisymmetricMat(NullMat(3, 2));
false
gap> IsAntisymmetricMat([[1,2,3],[4,5,6]]);
false

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
