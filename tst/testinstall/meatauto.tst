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
gap> STOP_TEST("meatauto.tst");
