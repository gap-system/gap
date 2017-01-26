# 2012/06/15 (AH)
gap> gens:=[[[1,1],[0,1]], [[1,0],[1,1]]] * ZmodnZObj(1,7);
[ [ [ Z(7)^0, Z(7)^0 ], [ 0*Z(7), Z(7)^0 ] ], 
  [ [ Z(7)^0, 0*Z(7) ], [ Z(7)^0, Z(7)^0 ] ] ]
gap> gens:=List(Immutable(gens),i->ImmutableMatrix(GF(7),i));;
