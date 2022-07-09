gap> START_TEST("ZeroMatrix.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2MatrixRep
#
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 2, 3);
<a 2x3 matrix over GF2>
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 2, 0);
<a 2x0 matrix over GF2>
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 0, 3); # TODO
Error, IsGF2MatrixRep with zero rows not yet supported

# test error handling
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), -1, 3);
Error, ZeroMatrix: the number of rows and cols must be non-negative
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 2, -1);
Error, ZeroMatrix: the number of rows and cols must be non-negative

# test error handling
gap> TestZeroMatrix(IsGF2MatrixRep, GF(3), 2, 3);
Error, IsGF2MatrixRep only supported over GF(2)

#
# Is8BitMatrixRep
#
gap> TestZeroMatrix(Is8BitMatrixRep, GF(3), 2, 3);
[ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ]
gap> TestZeroMatrix(Is8BitMatrixRep, GF(3), 2, 0);
< mutable compressed matrix 2x0 over GF(3) >
gap> TestZeroMatrix(Is8BitMatrixRep, GF(3), 0, 3);
Error, Is8BitMatrixRep with zero rows not yet supported

#
gap> TestZeroMatrix(Is8BitMatrixRep, GF(251), 2, 3);
[ [ 0*Z(251), 0*Z(251), 0*Z(251) ], [ 0*Z(251), 0*Z(251), 0*Z(251) ] ]
gap> TestZeroMatrix(Is8BitMatrixRep, GF(251), 2, 0);
< mutable compressed matrix 2x0 over GF(251) >
gap> TestZeroMatrix(Is8BitMatrixRep, GF(251), 0, 3);
Error, Is8BitMatrixRep with zero rows not yet supported

# test error handling
gap> TestZeroMatrix(Is8BitMatrixRep, GF(2), 2, 3);
Error, Is8BitMatrixRep only supports base fields with 3 to 256 elements
gap> TestZeroMatrix(Is8BitMatrixRep, GF(257), 2, 3);
Error, Is8BitMatrixRep only supports base fields with 3 to 256 elements

#
# IsPlistMatrixRep
#
gap> TestZeroMatrix(IsPlistMatrixRep, GF(2), 2, 3);
<2x3-matrix over GF(2)>
gap> TestZeroMatrix(IsPlistMatrixRep, GF(2), 2, 0);
<2x0-matrix over GF(2)>
gap> TestZeroMatrix(IsPlistMatrixRep, GF(2), 0, 3);
<0x3-matrix over GF(2)>

#
gap> TestZeroMatrix(IsPlistMatrixRep, Integers, 2, 3);
<2x3-matrix over Integers>
gap> TestZeroMatrix(IsPlistMatrixRep, Integers, 2, 0);
<2x0-matrix over Integers>
gap> TestZeroMatrix(IsPlistMatrixRep, Integers, 0, 3);
<0x3-matrix over Integers>

#
gap> TestZeroMatrix(IsPlistMatrixRep, Rationals, 2, 3);
<2x3-matrix over Rationals>
gap> TestZeroMatrix(IsPlistMatrixRep, Rationals, 2, 0);
<2x0-matrix over Rationals>
gap> TestZeroMatrix(IsPlistMatrixRep, Rationals, 0, 3);
<0x3-matrix over Rationals>

#
gap> TestZeroMatrix(IsPlistMatrixRep, Integers mod 4, 2, 3);
<2x3-matrix over (Integers mod 4)>
gap> TestZeroMatrix(IsPlistMatrixRep, Integers mod 4, 2, 0);
<2x0-matrix over (Integers mod 4)>
gap> TestZeroMatrix(IsPlistMatrixRep, Integers mod 4, 0, 3);
<0x3-matrix over (Integers mod 4)>

#
# Test ZeroMatrix variant which "guesses" a suitable representation, i.e.:
#    ZeroMatrix( <R>, <m>, <n> )
#

#
gap> ZeroMatrix(Integers, 2, 3);
<2x3-matrix over Integers>
gap> ZeroMatrix(Integers, 0, 3);
<0x3-matrix over Integers>
gap> ZeroMatrix(Integers, 2, 0);
<2x0-matrix over Integers>

#
gap> ZeroMatrix(Integers mod 4, 2, 3);
<2x3-matrix over (Integers mod 4)>
gap> ZeroMatrix(Integers mod 4, 0, 3);
<0x3-matrix over (Integers mod 4)>
gap> ZeroMatrix(Integers mod 4, 2, 0);
<2x0-matrix over (Integers mod 4)>

#
gap> ZeroMatrix(GF(2), 2, 3);
<a 2x3 matrix over GF2>
gap> ZeroMatrix(GF(2), 0, 3);
Error, IsGF2MatrixRep with zero rows not yet supported
gap> ZeroMatrix(GF(2), 2, 0);
<a 2x0 matrix over GF2>

#
gap> ZeroMatrix(GF(3), 2, 3);
[ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ]
gap> ZeroMatrix(GF(3), 0, 3);
Error, Is8BitMatrixRep with zero rows not yet supported
gap> ZeroMatrix(GF(3), 2, 0);
< mutable compressed matrix 2x0 over GF(3) >

#
gap> ZeroMatrix(GF(4), 2, 3);
[ [ 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> ZeroMatrix(GF(4), 0, 3);
Error, Is8BitMatrixRep with zero rows not yet supported
gap> ZeroMatrix(GF(4), 2, 0);
< mutable compressed matrix 2x0 over GF(4) >

#
gap> STOP_TEST("ZeroMatrix.tst");
