gap> START_TEST("ZeroVector.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2VectorRep
#
gap> TestZeroVector(IsGF2VectorRep, GF(2), 3);
Error, Assertion failure
gap> TestZeroVector(IsGF2VectorRep, GF(2), 0);
Error, Assertion failure

# test error handling
gap> TestZeroVector(IsGF2VectorRep, GF(2), -1);
Error, ZERO_GF2VEC_2: <len> must be a non-negative small integer (not the inte\
ger -1)
gap> TestZeroVector(IsGF2VectorRep, GF(3), 3);
Error, Assertion failure

#
# Is8BitVectorRep
#
gap> TestZeroVector(Is8BitVectorRep, GF(3), 3);
Error, Assertion failure
gap> TestZeroVector(Is8BitVectorRep, GF(3), 0);
Error, Assertion failure

#
gap> TestZeroVector(Is8BitVectorRep, GF(251), 3);
Error, Assertion failure
gap> TestZeroVector(Is8BitVectorRep, GF(251), 0);
Error, Assertion failure

# test error handling
gap> TestZeroVector(Is8BitVectorRep, GF(3), -1);
Error, ListWithIdenticalEntries: <n> must be a non-negative small integer (not\
 the integer -1)
gap> TestZeroVector(Is8BitVectorRep, GF(2), 3);
Error, Assertion failure
gap> TestZeroVector(Is8BitVectorRep, GF(257), 3);
Error, Assertion failure

#
# IsPlistVectorRep
#
gap> TestZeroVector(IsPlistVectorRep, GF(2), 3);
<plist vector over GF(2) of length 3>
gap> TestZeroVector(IsPlistVectorRep, GF(2), 0);
<plist vector over GF(2) of length 0>

#
gap> TestZeroVector(IsPlistVectorRep, Integers, 3);
<plist vector over Integers of length 3>
gap> TestZeroVector(IsPlistVectorRep, Integers, 0);
<plist vector over Integers of length 0>

#
gap> TestZeroVector(IsPlistVectorRep, Rationals, 3);
<plist vector over Rationals of length 3>
gap> TestZeroVector(IsPlistVectorRep, Rationals, 0);
<plist vector over Rationals of length 0>

#
gap> TestZeroVector(IsPlistVectorRep, Integers mod 4, 3);
<plist vector over (Integers mod 4) of length 3>
gap> TestZeroVector(IsPlistVectorRep, Integers mod 4, 0);
<plist vector over (Integers mod 4) of length 0>

# test error handling
gap> TestZeroVector(IsPlistVectorRep, Rationals, -1);
Error, Assertion failure

#
# Test ZeroVector variant which "guesses" a suitable representation, i.e.:
#    ZeroVector( <R>, <m> )
#

#
gap> ZeroVector(Integers, 2);
<plist vector over Integers of length 2>
gap> ZeroVector(Integers, 0);
<plist vector over Integers of length 0>
gap> ZeroVector(Integers, -1);
<plist vector over Integers of length 0>

#
gap> ZeroVector(Integers mod 4, 2);
<plist vector over (Integers mod 4) of length 2>
gap> ZeroVector(Integers mod 4, 0);
<plist vector over (Integers mod 4) of length 0>
gap> ZeroVector(Integers mod 4, -1);
<plist vector over (Integers mod 4) of length 0>

#
gap> ZeroVector(GF(2), 2);
<a GF2 vector of length 2>
gap> ZeroVector(GF(2), 0);
<a GF2 vector of length 0>
gap> ZeroVector(GF(2), -1);
Error, ZERO_GF2VEC_2: <len> must be a non-negative small integer (not the inte\
ger -1)

#
gap> ZeroVector(GF(3), 2);
[ 0*Z(3), 0*Z(3) ]
gap> ZeroVector(GF(3), 0);
[  ]
gap> ZeroVector(GF(3), -1);
Error, ListWithIdenticalEntries: <n> must be a non-negative small integer (not\
 the integer -1)

#
gap> ZeroVector(GF(4), 2);
[ 0*Z(2), 0*Z(2) ]
gap> ZeroVector(GF(4), 0);
[  ]
gap> ZeroVector(GF(4), -1);
Error, ListWithIdenticalEntries: <n> must be a non-negative small integer (not\
 the integer -1)

#
gap> STOP_TEST("ZeroVector.tst");
