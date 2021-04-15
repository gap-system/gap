gap> START_TEST("ZeroVector.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2VectorRep
#
gap> TestZeroVector(IsGF2VectorRep, GF(2), 3);
<a GF2 vector of length 3>
gap> TestZeroVector(IsGF2VectorRep, GF(2), 0);
<a GF2 vector of length 0>

# test error handling
gap> TestZeroVector(IsGF2VectorRep, GF(2), -1);
Error, ZeroVector: length must be non-negative
gap> TestZeroVector(IsGF2VectorRep, GF(3), 3);
Error, IsGF2VectorRep only supported over GF(2)

#
# Is8BitVectorRep
#
gap> TestZeroVector(Is8BitVectorRep, GF(3), 3);
[ 0*Z(3), 0*Z(3), 0*Z(3) ]
gap> TestZeroVector(Is8BitVectorRep, GF(3), 0);
< mutable compressed vector length 0 over GF(3) >

#
gap> TestZeroVector(Is8BitVectorRep, GF(251), 3);
[ 0*Z(251), 0*Z(251), 0*Z(251) ]
gap> TestZeroVector(Is8BitVectorRep, GF(251), 0);
< mutable compressed vector length 0 over GF(251) >

# test error handling
gap> TestZeroVector(Is8BitVectorRep, GF(3), -1);
Error, ZeroVector: length must be non-negative
gap> TestZeroVector(Is8BitVectorRep, GF(2), 3);
Error, Is8BitVectorRep only supports base fields with 3 to 256 elements
gap> TestZeroVector(Is8BitVectorRep, GF(257), 3);
Error, Is8BitVectorRep only supports base fields with 3 to 256 elements

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
Error, ZeroVector: length must be non-negative

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
Error, ZeroVector: length must be non-negative

#
gap> ZeroVector(Integers mod 4, 2);
<plist vector over (Integers mod 4) of length 2>
gap> ZeroVector(Integers mod 4, 0);
<plist vector over (Integers mod 4) of length 0>
gap> ZeroVector(Integers mod 4, -1);
Error, ZeroVector: length must be non-negative

#
gap> ZeroVector(GF(2), 2);
<a GF2 vector of length 2>
gap> ZeroVector(GF(2), 0);
<a GF2 vector of length 0>
gap> ZeroVector(GF(2), -1);
Error, ZeroVector: length must be non-negative

#
gap> ZeroVector(GF(3), 2);
[ 0*Z(3), 0*Z(3) ]
gap> ZeroVector(GF(3), 0);
< mutable compressed vector length 0 over GF(3) >
gap> ZeroVector(GF(3), -1);
Error, ZeroVector: length must be non-negative

#
gap> ZeroVector(GF(4), 2);
[ 0*Z(2), 0*Z(2) ]
gap> ZeroVector(GF(4), 0);
< mutable compressed vector length 0 over GF(4) >
gap> ZeroVector(GF(4), -1);
Error, ZeroVector: length must be non-negative

#
gap> STOP_TEST("ZeroVector.tst");
