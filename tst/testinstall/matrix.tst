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
gap> IsSquareMat([[1,2],[4,5,6]]);
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
gap> HasNumberRows(m);
true
gap> HasNumberColumns(m);
true
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

#
# powering matrices by large exponents: POW_MAT_INT dispatches between
# repeated squaring, reduction modulo the characteristic polynomial and
# reduction modulo the minimal polynomial
#
gap> conj := function(m, F)
>      local d, t, i;
>      d := NrRows(m);
>      t := List(IdentityMat(d, F), ShallowCopy);
>      for i in [1..d-1] do t[i][i+1] := One(F); od;
>      t := ImmutableMatrix(F, t);
>      return ImmutableMatrix(F, t * m * t^-1);
>    end;;
gap> blockdiag := function(b, nb, F)
>      local e, d, m, i;
>      e := NrRows(b); d := e*nb; m := NullMat(d, d, F);
>      for i in [1..nb] do m{[(i-1)*e+1..i*e]}{[(i-1)*e+1..i*e]} := b; od;
>      return conj(ImmutableMatrix(F, m), F);
>    end;;
gap> comp := function(coeffs, F)
>      local d, m, i;
>      d := Length(coeffs) - 1; m := NullMat(d, d, F);
>      for i in [1..d-1] do m[i][i+1] := One(F); od;
>      for i in [1..d] do m[d][i] := -coeffs[i]/Last(coeffs); od;
>      return ImmutableMatrix(F, m);
>    end;;
gap> check := m -> ForAll([64, 100, 300],
>                         k -> POW_MAT_INT(m, 2^k+1) = POW_OBJ_INT(m, 2^k+1));;

# the bounded variant of the spinning used to detect a small minimal polynomial
gap> F := GF(5);; b := comp([1,1,1,1,1,1]*One(F), F);;
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(F, b, 1));
5
gap> v := ImmutableVector(F, One(F)*[1,0,0,0,0]);;
gap> Length(Matrix_OrderPolynomialInner(F, b, v, [])) - 1;
5
gap> Matrix_OrderPolynomialInner(F, b, v, [], 4);
fail
gap> Length(Matrix_OrderPolynomialInner(F, b, v, [], 5)) - 1;
5

# generic matrices: minimal polynomial equals characteristic polynomial,
# so the probe fails and the characteristic polynomial is used
gap> m := conj(comp(One(GF(2))*[1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1], GF(2)), GF(2));;
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(m)) = NrRows(m);
true
gap> check(m);
true
gap> m := conj(comp(One(GF(5))*[2,1,0,0,3,0,0,1,0,0,0,4,0,0,0,0,1], GF(5)), GF(5));;
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(m)) = NrRows(m);
true
gap> check(m);
true

# small minimal polynomial, evaluated at the matrix itself
gap> m := blockdiag(comp(One(GF(5))*[3,1,4,1], GF(5)), 20, GF(5));;
gap> [ NrRows(m), DegreeOfLaurentPolynomial(MinimalPolynomial(m)) ];
[ 60, 3 ]
gap> check(m);
true
gap> m := blockdiag(comp(One(GF(251))*[7,1,4,1,1], GF(251)), 15, GF(251));;
gap> [ NrRows(m), DegreeOfLaurentPolynomial(MinimalPolynomial(m)) ];
[ 60, 4 ]
gap> check(m);
true

# small minimal polynomial, evaluated at the block companion form
gap> m := blockdiag(comp(One(GF(5))*[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], GF(5)), 8, GF(5));;
gap> [ NrRows(m), DegreeOfLaurentPolynomial(MinimalPolynomial(m)) ];
[ 120, 15 ]
gap> check(m);
true

# a polynomial annihilates a matrix iff it is a multiple of its minimal
# polynomial; a proper divisor of the latter does not
gap> b := comp(One(GF(5))*[1,1,1,1,1,1], GF(5));;
gap> POW_MAT_INT_ANNIHILATES(One(GF(5))*[1,1,1,1,1,1], b);
true
gap> POW_MAT_INT_ANNIHILATES(One(GF(5))*[1,1,1,1,1,1,1], b);
false
gap> POW_MAT_INT_ANNIHILATES(One(GF(5))*[4,1], b);
false

# a tiny minimal polynomial next to a large dimension: here computing the
# minimal polynomial outright would cost far more than the whole method
gap> m := ImmutableMatrix(GF(2), PermutationMat((1,2,3,4), 120, GF(2)));;
gap> [ NrRows(m), DegreeOfLaurentPolynomial(MinimalPolynomial(m)) ];
[ 120, 4 ]
gap> check(m);
true

# scalar and unipotent matrices
gap> m := ImmutableMatrix(GF(9), Z(9)*IdentityMat(20, GF(9)));;
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(m));
1
gap> check(m);
true
gap> m := List(IdentityMat(40, GF(2)), ShallowCopy);;
gap> for i in [1..20] do m[i][i+20] := One(GF(2)); od;
gap> m := ImmutableMatrix(GF(2), m);;
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(m));
2
gap> check(m);
true

# entries not in a field, or in a ring of characteristic 0: repeated squaring.
# The exponents are large enough that the polynomial methods would be used if
# the base domain were a field.
gap> POW_MAT_INT([[1,1],[0,1]], 2^100+1) = [[1, 2^100+1],[0,1]];
true
gap> m := One(Integers mod 6) * [[1,1],[0,1]];;
gap> POW_MAT_INT(m, 2^4100+1) = POW_OBJ_INT(m, 2^4100+1);
true
gap> m := List([1..4], i -> List([1..4], j -> Random(Integers mod 8)));;
gap> IsField(DefaultFieldOfMatrix(m));
false
gap> POW_MAT_INT(m, 2^2050+1) = POW_OBJ_INT(m, 2^2050+1);
true

# matrix objects which do not offer access to their rows are handled as well,
# both by the characteristic and by the minimal polynomial method
gap> m := Matrix(IsGenericMatrixRep, GF(257),
>                List([1..16], i -> List([1..16], j -> Random(GF(257)))));;
gap> IsRowListMatrix(m);
false
gap> POW_MAT_INT(m, 2^514+1) = POW_OBJ_INT(m, 2^514+1);
true
gap> m := Matrix(IsGenericMatrixRep, GF(257),
>                Unpack(blockdiag(comp(One(GF(257))*[3,1,4,1], GF(257)), 8, GF(257))));;
gap> DegreeOfLaurentPolynomial(MinimalPolynomial(GF(257), m, 1));
3
gap> POW_MAT_INT(m, 2^514+1) = POW_OBJ_INT(m, 2^514+1);
true

# matrix objects
gap> m := Matrix(IsPlistMatrixRep, GF(5), Unpack(blockdiag(comp(One(GF(5))*[3,1,4,1], GF(5)), 20, GF(5))));;
gap> POW_MAT_INT(m, 2^500+1) = POW_OBJ_INT(m, 2^500+1);
true
