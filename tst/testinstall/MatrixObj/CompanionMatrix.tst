gap> START_TEST("CompanionMatrix.tst");
gap> ReadGapRoot("tst/testinstall/MatrixObj/testmatobj.g");

#
# IsGF2MatrixRep
#
gap> F:= GF(2);;  x:= X(F);;
gap> TestCompanionMatrix(IsGF2MatrixRep, x+1, F);
<a 1x1 matrix over GF2>
gap> TestCompanionMatrix(IsGF2MatrixRep, x^2+x+1, F);
<a 2x2 matrix over GF2>

# test error handling
gap> TestCompanionMatrix(IsGF2MatrixRep, Zero(x), F);
Error, NewCompanionMatrix: degree of <pol> must be at least 1
gap> TestCompanionMatrix(IsGF2MatrixRep, One(x), F);
Error, NewCompanionMatrix: degree of <pol> must be at least 1

#
# Is8BitMatrixRep
#
gap> F:= GF(3);;  x:= X(F);;
gap> TestCompanionMatrix(Is8BitMatrixRep, x+1, F);
[ [ Z(3) ] ]
gap> TestCompanionMatrix(Is8BitMatrixRep, x^2+x+1, F);
[ [ 0*Z(3), Z(3) ], [ Z(3)^0, Z(3) ] ]

# test error handling
gap> TestCompanionMatrix(Is8BitMatrixRep, Zero(x), F);
Error, NewCompanionMatrix: degree of <pol> must be at least 1
gap> TestCompanionMatrix(Is8BitMatrixRep, One(x), F);
Error, NewCompanionMatrix: degree of <pol> must be at least 1

#
gap> F:= GF(251);;  x:= X(F);;
gap> TestCompanionMatrix(Is8BitMatrixRep, x+1, F);
[ [ Z(251)^125 ] ]
gap> TestCompanionMatrix(Is8BitMatrixRep, x^2+x+1, F);
[ [ 0*Z(251), Z(251)^125 ], [ Z(251)^0, Z(251)^125 ] ]

# test error handling
gap> TestCompanionMatrix(Is8BitMatrixRep, Zero(x), F);
Error, NewCompanionMatrix: degree of <pol> must be at least 1
gap> TestCompanionMatrix(Is8BitMatrixRep, One(x), F);
Error, NewCompanionMatrix: degree of <pol> must be at least 1

#
# IsPlistMatrixRep
#
gap> F:= GF(251);;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistMatrixRep, x+1, F);
<1x1-matrix over GF(251)>
gap> TestCompanionMatrix(IsPlistMatrixRep, x^2+x+1, F);
<2x2-matrix over GF(251)>

#
gap> F:= Integers;;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistMatrixRep, x+1, F);
<1x1-matrix over Integers>
gap> TestCompanionMatrix(IsPlistMatrixRep, x^2+x+1, F);
<2x2-matrix over Integers>

#
gap> F:= Rationals;;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistMatrixRep, x+1, F);
<1x1-matrix over Rationals>
gap> TestCompanionMatrix(IsPlistMatrixRep, x^2+x+1, F);
<2x2-matrix over Rationals>

#
# IsPlistRep
#
gap> F:= GF(251);;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistRep, x+1, F);
[ [ Z(251)^125 ] ]
gap> TestCompanionMatrix(IsPlistRep, x^2+x+1, F);
[ [ 0*Z(251), Z(251)^125 ], [ Z(251)^0, Z(251)^125 ] ]

#
gap> F:= Integers;;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistRep, x+1, F);
Error, Assertion failure
gap> TestCompanionMatrix(IsPlistRep, x^2+x+1, F);
Error, Assertion failure

#
gap> F:= Rationals;;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistRep, x+1, F);
[ [ -1 ] ]
gap> TestCompanionMatrix(IsPlistRep, x^2+x+1, F);
[ [ 0, -1 ], [ 1, -1 ] ]

#
gap> F:= Integers mod 4;;  x:= X(F);;
gap> TestCompanionMatrix(IsPlistRep, x+1, F);
[ [ ZmodnZObj( 3, 4 ) ] ]
gap> TestCompanionMatrix(IsPlistRep, x^2+x+1, F);
[ [ ZmodnZObj( 0, 4 ), ZmodnZObj( 3, 4 ) ], 
  [ ZmodnZObj( 1, 4 ), ZmodnZObj( 3, 4 ) ] ]

#
# Test CompanionMatrix variant which "guesses" a suitable representation, i.e.:
#    CompanionMatrix( <pol>, <R> )
#

#
gap> F:= GF(2);;  x:= X(F);;
gap> CompanionMatrix(x+1, F);
<a 1x1 matrix over GF2>
gap> CompanionMatrix(x^2+x+1, F);
<a 2x2 matrix over GF2>

#
gap> F:= GF(3);;  x:= X(F);;
gap> CompanionMatrix(x+1, F);
[ [ Z(3) ] ]
gap> CompanionMatrix(x^2+x+1, F);
[ [ 0*Z(3), Z(3) ], [ Z(3)^0, Z(3) ] ]

#
gap> F:= GF(4);;  x:= X(F);;
gap> CompanionMatrix(x+1, F);
[ [ Z(2)^0 ] ]
gap> CompanionMatrix(x^2+x+1, F);
[ [ 0*Z(2), Z(2)^0 ], [ Z(2)^0, Z(2)^0 ] ]

#
gap> F:= Integers;;  x:= X(F);;
gap> CompanionMatrix(x+1, F);
<1x1-matrix over Integers>
gap> CompanionMatrix(x^2+x+1, F);
<2x2-matrix over Integers>

#
gap> F:= Rationals;;  x:= X(F);;
gap> CompanionMatrix(x+1, F);
<1x1-matrix over Rationals>
gap> CompanionMatrix(x^2+x+1, F);
<2x2-matrix over Rationals>

#
gap> F:= Integers mod 4;;  x:= X(F);;
gap> CompanionMatrix(x+1, F);
<1x1-matrix over (Integers mod 4)>
gap> CompanionMatrix(x^2+x+1, F);
<2x2-matrix over (Integers mod 4)>

#
gap> STOP_TEST("CompanionMatrix.tst");
