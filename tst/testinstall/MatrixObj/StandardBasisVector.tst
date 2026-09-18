gap> START_TEST("StandardBasisVector.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2VectorRep
#
gap> TestStandardBasisVector(IsGF2VectorRep, GF(2), 3, 2);
<a GF2 vector of length 3>

# test error handling
gap> TestStandardBasisVector(IsGF2VectorRep, GF(2), 0, 0);
Error, length and position must be positive
gap> TestStandardBasisVector(IsGF2VectorRep, GF(2), 1, 0);
Error, length and position must be positive
gap> TestStandardBasisVector(IsGF2VectorRep, GF(2), 1, 2);
Error, <i> cannot be larger than <len>
gap> TestStandardBasisVector(IsGF2VectorRep, GF(3), 3, 1);
Error, IsGF2VectorRep only supported over GF(2)

#
# Is8BitVectorRep
#
gap> TestStandardBasisVector(Is8BitVectorRep, GF(3), 3, 2);
[ 0*Z(3), Z(3)^0, 0*Z(3) ]

#
gap> TestStandardBasisVector(Is8BitVectorRep, GF(251), 3, 2);
[ 0*Z(251), Z(251)^0, 0*Z(251) ]

# test error handling
gap> TestStandardBasisVector(Is8BitVectorRep, GF(3), 0, 0);
Error, length and position must be positive
gap> TestStandardBasisVector(Is8BitVectorRep, GF(3), 1, 0);
Error, length and position must be positive
gap> TestStandardBasisVector(Is8BitVectorRep, GF(2), 3, 2);
Error, Is8BitVectorRep only supports base fields with 3 to 256 elements
gap> TestStandardBasisVector(Is8BitVectorRep, GF(257), 3, 2);
Error, Is8BitVectorRep only supports base fields with 3 to 256 elements

#
# IsPlistVectorRep
#
gap> TestStandardBasisVector(IsPlistVectorRep, GF(2), 3, 2);
<plist vector over GF(2) of length 3>

#
gap> TestStandardBasisVector(IsPlistVectorRep, Integers, 3, 2);
<plist vector over Integers of length 3>

#
gap> TestStandardBasisVector(IsPlistVectorRep, Rationals, 3, 2);
<plist vector over Rationals of length 3>

#
gap> TestStandardBasisVector(IsPlistVectorRep, Integers mod 4, 3, 2);
<plist vector over (Integers mod 4) of length 3>

# test error handling
gap> TestStandardBasisVector(IsPlistVectorRep, Rationals, 0, 0);
Error, length and position must be positive

#
# IsPlistRep
#
gap> TestStandardBasisVector(IsPlistRep, GF(2), 3, 2);
[ 0*Z(2), Z(2)^0, 0*Z(2) ]

#
gap> TestStandardBasisVector(IsPlistRep, Integers, 3, 2);
[ 0, 1, 0 ]

#
gap> TestStandardBasisVector(IsPlistRep, Integers mod 4, 3, 2);
[ ZmodnZObj( 0, 4 ), ZmodnZObj( 1, 4 ), ZmodnZObj( 0, 4 ) ]

# test error handling
gap> TestStandardBasisVector(IsPlistRep, Rationals, 0, 0);
Error, length and position must be positive

#
# Test StandardBasisVector variant which "guesses" a suitable representation, i.e.:
#    StandardBasisVector( <R>, <m>, <k> )
#

#
gap> StandardBasisVector(Integers, 2, 1);
<plist vector over Integers of length 2>
gap> StandardBasisVector(Integers, 0, 0);
Error, length and position must be positive

#
gap> StandardBasisVector(Integers mod 4, 2, 1);
<plist vector over (Integers mod 4) of length 2>
gap> StandardBasisVector(Integers mod 4, 0, 0);
Error, length and position must be positive

#
gap> StandardBasisVector(GF(2), 2, 1);
<a GF2 vector of length 2>
gap> StandardBasisVector(GF(2), 0, 0);
Error, length and position must be positive

#
gap> StandardBasisVector(GF(3), 2, 1);
[ Z(3)^0, 0*Z(3) ]
gap> StandardBasisVector(GF(3), 0, 0);
Error, length and position must be positive

#
gap> StandardBasisVector(GF(4), 2, 1);
[ Z(2)^0, 0*Z(2) ]
gap> StandardBasisVector(GF(4), 0, 0);
Error, length and position must be positive

#
gap> STOP_TEST("StandardBasisVector.tst");
