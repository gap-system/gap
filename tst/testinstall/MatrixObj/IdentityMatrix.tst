gap> START_TEST("IdentityMatrix.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2MatrixRep
#
gap> TestIdentityMatrix(IsGF2MatrixRep, GF(2), 2);
<a 2x2 matrix over GF2>
gap> TestIdentityMatrix(IsGF2MatrixRep, GF(2), 0);
Error, IsGF2MatrixRep with zero rows not yet supported
gap> TestIdentityMatrix(IsGF2MatrixRep, GF(2), -1);
Error, IdentityMatrix: the dimension must be non-negative

# test error handling
gap> TestIdentityMatrix(IsGF2MatrixRep, GF(3), 2);
Error, IsGF2MatrixRep only supported over GF(2)

#
# Is8BitMatrixRep
#
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(3), 2);
[ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ]
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(3), 0);
Error, Is8BitMatrixRep with zero rows not yet supported
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(3), -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(251), 2);
[ [ Z(251)^0, 0*Z(251) ], [ 0*Z(251), Z(251)^0 ] ]
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(251), 0);
Error, Is8BitMatrixRep with zero rows not yet supported
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(251), -1);
Error, IdentityMatrix: the dimension must be non-negative

# test error handling
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(2), 2);
Error, Is8BitMatrixRep only supports base fields with 3 to 256 elements
gap> TestIdentityMatrix(Is8BitMatrixRep, GF(257), 2);
Error, Is8BitMatrixRep only supports base fields with 3 to 256 elements

#
# IsPlistMatrixRep
#
gap> TestIdentityMatrix(IsPlistMatrixRep, GF(2), 2);
<2x2-matrix over GF(2)>
gap> TestIdentityMatrix(IsPlistMatrixRep, GF(2), 0);
<0x0-matrix over GF(2)>
gap> TestIdentityMatrix(IsPlistMatrixRep, GF(2), -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> TestIdentityMatrix(IsPlistMatrixRep, Integers, 2);
<2x2-matrix over Integers>
gap> TestIdentityMatrix(IsPlistMatrixRep, Integers, 0);
<0x0-matrix over Integers>
gap> TestIdentityMatrix(IsPlistMatrixRep, Integers, -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> TestIdentityMatrix(IsPlistMatrixRep, Rationals, 2);
<2x2-matrix over Rationals>
gap> TestIdentityMatrix(IsPlistMatrixRep, Rationals, 0);
<0x0-matrix over Rationals>
gap> TestIdentityMatrix(IsPlistMatrixRep, Rationals, -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> TestIdentityMatrix(IsPlistMatrixRep, Integers mod 4, 2);
<2x2-matrix over (Integers mod 4)>
gap> TestIdentityMatrix(IsPlistMatrixRep, Integers mod 4, 0);
<0x0-matrix over (Integers mod 4)>
gap> TestIdentityMatrix(IsPlistMatrixRep, Integers mod 4, -1);
Error, IdentityMatrix: the dimension must be non-negative

#
# Test IdentityMatrix variant which "guesses" a suitable representation, i.e.:
#    IdentityMatrix( <R>, <m>, <n> )
#

#
gap> IdentityMatrix(Integers, 2);
<2x2-matrix over Integers>
gap> IdentityMatrix(Integers, 0);
<0x0-matrix over Integers>
gap> IdentityMatrix(Integers, -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> IdentityMatrix(Integers mod 4, 2);
<2x2-matrix over (Integers mod 4)>
gap> IdentityMatrix(Integers mod 4, 0);
<0x0-matrix over (Integers mod 4)>
gap> IdentityMatrix(Integers mod 4, -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> IdentityMatrix(GF(2), 2);
<a 2x2 matrix over GF2>
gap> IdentityMatrix(GF(2), 0);
Error, IsGF2MatrixRep with zero rows not yet supported
gap> IdentityMatrix(GF(2), -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> IdentityMatrix(GF(3), 2);
[ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ]
gap> IdentityMatrix(GF(3), 0);
Error, Is8BitMatrixRep with zero rows not yet supported
gap> IdentityMatrix(GF(3), -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> IdentityMatrix(GF(4), 2);
[ [ Z(2)^0, 0*Z(2) ], [ 0*Z(2), Z(2)^0 ] ]
gap> IdentityMatrix(GF(4), 0);
Error, Is8BitMatrixRep with zero rows not yet supported
gap> IdentityMatrix(GF(4), -1);
Error, IdentityMatrix: the dimension must be non-negative

#
gap> STOP_TEST("IdentityMatrix.tst");
