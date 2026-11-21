gap> START_TEST("SemiEchelonMat.tst");

#
# SemiEchelonMat of a list of vector objects over a small field
#
gap> SemiEchelonMat( [ NewVector( IsPlistVectorRep, GF(9), [ Z(9), Z(9)^0 ] ),
>                      NewVector( IsPlistVectorRep, GF(9), [ Z(9)^2, Z(9) ] ),
>                      NewVector( IsPlistVectorRep, GF(9), [ Z(9)^0, Z(9) ] ) ] ).heads;
[ 1, 2 ]

#
gap> STOP_TEST("SemiEchelonMat.tst");
