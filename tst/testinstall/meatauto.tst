#@local F, e, M, v, N, G, p, hc, A
gap> START_TEST("meatauto.tst");

#
# SMTX_NewEqns, SMTX_NullspaceEqns
#
gap> e := SMTX_NewEqns(3, GF(5));;
gap> SMTX_AddEqns(e, [[1,0,0]*Z(5)^0]);
gap> SMTX_NullspaceEqns(e);
[ [ 0*Z(5), Z(5)^0, 0*Z(5) ], [ 0*Z(5), 0*Z(5), Z(5)^0 ] ]

#
# MTX.BasisModuleEndomorphisms
#
gap> G:=SmallGroup(24, 3);;
gap> p:=NextPrimeInt(100);;
gap> M:=RegularModule(G, GF(p))[2];;
gap> MTX.BasisModuleEndomorphisms(M);
[ < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) >, 
  < immutable compressed matrix 24x24 over GF(101) > ]

#
# MTX.HomogeneousComponents
#
gap> G:=SmallGroup(24, 3);;
gap> p:=NextPrimeInt(100);;
gap> M:=RegularModule(G, GF(p))[2];;
gap> hc := MTX.HomogeneousComponents(M);;
gap> SortedList(List(hc, x -> Length(x.indices)));
[ 1, 1, 2, 2, 3 ]
gap> Union(List(hc, x -> x.indices));
[ 1 .. 9 ]

#
gap> STOP_TEST("meatauto.tst");
