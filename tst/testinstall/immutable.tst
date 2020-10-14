#@local v,x
gap> START_TEST("immutable.tst");
gap> IS_IDENTICAL_OBJ(Immutable, MakeImmutable);
false
gap> IsMutable(1);
false
gap> IS_IDENTICAL_OBJ(1,Immutable(1));
true
gap> IS_IDENTICAL_OBJ(1,MakeImmutable(1));
true
gap> x := [1,2,3];
[ 1, 2, 3 ]
gap> IsMutable(x);
true
gap> IsMutable(Immutable(x));
false
gap> x = Immutable(x);
true
gap> IS_IDENTICAL_OBJ(x, Immutable(x));
false
gap> IsMutable(x);
true
gap> x;
[ 1, 2, 3 ]
gap> IS_IDENTICAL_OBJ(x, MakeImmutable(x));
true
gap> IsMutable(x);
false
gap> x;
[ 1, 2, 3 ]
gap> IsMutable(Group(()));
false
gap> IsMutable(StabChainImmutable(Group(())));
false
gap> IsMutable(StabChainMutable(Group(())));
true

#
gap> v := Immutable([Z(27), Z(3)]);;
gap> IsMutable(v);
false
gap> ConvertToVectorRep(v);
27
gap> ConvertToVectorRep(v);
27
gap> IsMutable(v);
false
gap> v := Immutable([Z(27), Z(3)]);;
gap> IsMutable(v);
false
gap> ConvertToVectorRep(v, 27);
27
gap> ConvertToVectorRep(v, 27);
27
gap> IsMutable(v);
false
gap> ConvertToVectorRep(v, fail);
fail
gap> ConvertToVectorRep(v, -1);
fail
gap> ConvertToVectorRep(v, 0);
fail
gap> ConvertToVectorRep(v, 1);
fail

#
gap> v := [Z(27), Z(3)];;
gap> IsMutable(v);
true
gap> ConvertToVectorRep(v);
27
gap> ConvertToVectorRep(v);
27
gap> IsMutable(v);
true
gap> v := [Z(27), Z(3)];;
gap> IsMutable(v);
true
gap> ConvertToVectorRep(v, 27);
27
gap> ConvertToVectorRep(v, 27);
27
gap> IsMutable(v);
true
gap> ConvertToVectorRep(v, fail);
fail
gap> ConvertToVectorRep(v, -1);
fail
gap> ConvertToVectorRep(v, 0);
fail
gap> ConvertToVectorRep(v, 1);
fail

#
gap> v := Immutable([[Z(27), Z(3)]]);;
gap> IsMutable(v);
false
gap> ConvertToMatrixRep(v);
27
gap> ConvertToMatrixRep(v);
27
gap> IsMutable(v);
false
gap> v := Immutable([[Z(27), Z(3)]]);;
gap> IsMutable(v);
false
gap> ConvertToMatrixRep(v, 27);
27
gap> ConvertToMatrixRep(v, 27);
27
gap> IsMutable(v);
false
gap> ConvertToMatrixRep(v, fail);
fail
gap> ConvertToMatrixRep(v, -1);
fail
gap> ConvertToMatrixRep(v, 0);
fail
gap> ConvertToMatrixRep(v, 1);
fail

#
gap> v := [[Z(27), Z(3)]];;
gap> IsMutable(v);
true
gap> ConvertToMatrixRep(v);
27
gap> ConvertToMatrixRep(v);
27
gap> IsMutable(v);
true
gap> v := [[Z(27), Z(3)]];;
gap> IsMutable(v);
true
gap> ConvertToMatrixRep(v, 27);
27
gap> ConvertToMatrixRep(v, 27);
27
gap> IsMutable(v);
true
gap> ConvertToMatrixRep(v, fail);
fail
gap> ConvertToMatrixRep(v, -1);
fail
gap> ConvertToMatrixRep(v, 0);
fail
gap> ConvertToMatrixRep(v, 1);
fail

#
gap> STOP_TEST( "immutable.tst", 1);
