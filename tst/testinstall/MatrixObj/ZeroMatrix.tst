gap> START_TEST("ZeroMatrix.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2MatrixRep
#
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 2, 0);
Error, Assertion failure
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 0, 3); # TODO
Error, Assertion failure

# test error handling
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), -1, 3);
Error, ListWithIdenticalEntries: <n> must be a non-negative small integer (not\
 the integer -3)
gap> TestZeroMatrix(IsGF2MatrixRep, GF(2), 2, -1);
Error, ListWithIdenticalEntries: <n> must be a non-negative small integer (not\
 the integer -2)

# test error handling
gap> TestZeroMatrix(IsGF2MatrixRep, GF(3), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments

#
# Is8BitMatrixRep
#
gap> TestZeroMatrix(Is8BitMatrixRep, GF(3), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> TestZeroMatrix(Is8BitMatrixRep, GF(3), 2, 0);
Error, Assertion failure
gap> TestZeroMatrix(Is8BitMatrixRep, GF(3), 0, 3);
Error, Assertion failure

#
gap> TestZeroMatrix(Is8BitMatrixRep, GF(251), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> TestZeroMatrix(Is8BitMatrixRep, GF(251), 2, 0);
Error, Assertion failure
gap> TestZeroMatrix(Is8BitMatrixRep, GF(251), 0, 3);
Error, Assertion failure

# test error handling
gap> TestZeroMatrix(Is8BitMatrixRep, GF(2), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> TestZeroMatrix(Is8BitMatrixRep, GF(257), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments

#
# IsPlistMatrixRep
#
gap> TestZeroMatrix(IsPlistMatrixRep, GF(2), 2, 3);
<2x3-matrix over GF(2)>
gap> TestZeroMatrix(IsPlistMatrixRep, GF(2), 2, 0);
Error, Assertion failure
gap> TestZeroMatrix(IsPlistMatrixRep, GF(2), 0, 3);
<0x3-matrix over GF(2)>

#
gap> TestZeroMatrix(IsPlistMatrixRep, Integers, 2, 3);
<2x3-matrix over Integers>
gap> TestZeroMatrix(IsPlistMatrixRep, Integers, 2, 0);
Error, Assertion failure
gap> TestZeroMatrix(IsPlistMatrixRep, Integers, 0, 3);
<0x3-matrix over Integers>

#
gap> TestZeroMatrix(IsPlistMatrixRep, Rationals, 2, 3);
<2x3-matrix over Rationals>
gap> TestZeroMatrix(IsPlistMatrixRep, Rationals, 2, 0);
Error, Assertion failure
gap> TestZeroMatrix(IsPlistMatrixRep, Rationals, 0, 3);
<0x3-matrix over Rationals>

#
gap> TestZeroMatrix(IsPlistMatrixRep, Integers mod 4, 2, 3);
<2x3-matrix over (Integers mod 4)>
gap> TestZeroMatrix(IsPlistMatrixRep, Integers mod 4, 2, 0);
Error, Assertion failure
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
<0x0-matrix over Integers>

#
gap> ZeroMatrix(Integers mod 4, 2, 3);
<2x3-matrix over (Integers mod 4)>
gap> ZeroMatrix(Integers mod 4, 0, 3);
<0x3-matrix over (Integers mod 4)>
gap> ZeroMatrix(Integers mod 4, 2, 0);
<0x0-matrix over (Integers mod 4)>

#
gap> ZeroMatrix(GF(2), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> ZeroMatrix(GF(2), 0, 3);
[  ]
gap> ZeroMatrix(GF(2), 2, 0);
[  ]

#
gap> ZeroMatrix(GF(3), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> ZeroMatrix(GF(3), 0, 3);
[  ]
gap> ZeroMatrix(GF(3), 2, 0);
[  ]

#
gap> ZeroMatrix(GF(4), 2, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Length' on 1 arguments
gap> ZeroMatrix(GF(4), 0, 3);
[  ]
gap> ZeroMatrix(GF(4), 2, 0);
[  ]

#
gap> STOP_TEST("ZeroMatrix.tst");
