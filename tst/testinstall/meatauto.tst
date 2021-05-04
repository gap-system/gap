#@local F, e, M, v, N
gap> START_TEST("meatauto.tst");

#
# SMTX_NewEqns, SMTX_NullspaceEqns
#
gap> e := SMTX_NewEqns(3, GF(5));
rec( dim := 3, failed := false, field := GF(5), index := [  ], mat := [  ], 
  vec := [  ], weights := [  ] )
gap> SMTX_NullspaceEqns(e);
[ [ Z(5)^0, 0*Z(5), 0*Z(5) ], [ 0*Z(5), Z(5)^0, 0*Z(5) ], 
  [ 0*Z(5), 0*Z(5), Z(5)^0 ] ]

#
gap> F := GF(2);;
gap> M := IdentityMat(3, F);; M[1,3]:=M[1,1];; M[3,1]:=M[1,1];;
gap> v := ImmutableVector(F, M[2]);;
gap> e := SMTX_NewEqns(M, v);
rec( dim := 3, failed := false, field := GF(2), index := [  ], 
  mat := [ <a GF2 vector of length 3>, <a GF2 vector of length 3> ], 
  vec := [ 0*Z(2), Z(2)^0 ], weights := [ 1, 2 ] )
gap> N := SMTX_NullspaceEqns(e);
[ <a GF2 vector of length 3> ]
gap> N = [ [ Z(2)^0, 0*Z(2), Z(2)^0 ] ];
true

#
gap> F := GF(5);;
gap> M := IdentityMat(3, F);; M[1,3]:=M[1,1];; M[3,1]:=M[1,1];;
gap> v := ImmutableVector(F, M[2]);;
gap> e := SMTX_NewEqns(M, v);
rec( dim := 3, failed := false, field := GF(5), index := [  ], 
  mat := [ [ Z(5)^0, 0*Z(5), Z(5)^0 ], [ 0*Z(5), Z(5)^0, 0*Z(5) ] ], 
  vec := [ 0*Z(5), Z(5)^0 ], weights := [ 1, 2 ] )
gap> SMTX_NullspaceEqns(e);
[ [ Z(5)^2, 0*Z(5), Z(5)^0 ] ]

#
gap> STOP_TEST("meatauto.tst");
