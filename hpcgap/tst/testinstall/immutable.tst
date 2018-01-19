#############################################################################
##
#W  immutable.tst                GAP Library
##
##
#Y  Copyright (C) 2017,  University of St Andrews, Scotland
##
##
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
gap> STOP_TEST( "immutable.tst", 1);
