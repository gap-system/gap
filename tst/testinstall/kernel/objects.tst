#
# Tests for functions defined in src/objects.c
#
#@local x, t1c, t2c, t1p, t2p
gap> START_TEST("kernel/objects.tst");

#
gap> t1c := NewType(NewFamily("MockFamily"), IsComponentObjectRep);;
gap> t2c := NewType(NewFamily("MockFamily"), IsNonAtomicComponentObjectRep);;
gap> t1p := NewType(NewFamily("MockFamily"), IsAtomicPositionalObjectRep);;
gap> t2p := NewType(NewFamily("MockFamily"), IsReadOnlyPositionalObjectRep);;
gap> IsIdenticalObj(t1c,t2c);
false
gap> IsIdenticalObj(t1p,t2p);
false

#
# SET_TYPE_OBJ
#
gap> SET_TYPE_OBJ(fail, fail);
Error, cannot change type of a boolean or fail

#
# SET_TYPE_COMOBJ
#
gap> SET_TYPE_COMOBJ(fail, fail);
Error, You can't make a component object from a boolean or fail
gap> SET_TYPE_COMOBJ([], fail);
Error, You can't make a component object from a empty plain list
gap> SET_TYPE_COMOBJ(MakeImmutable(rec()), fail);
Error, You can't make a component object from a record (plain,imm)
gap> x:=rec();;
gap> SET_TYPE_COMOBJ(x, t1c);
<object>
gap> IS_COMOBJ(x);
true
gap> IsIdenticalObj(TYPE_OBJ(x), t1c);
true
gap> SET_TYPE_COMOBJ(x, t2c);
<object>
gap> IsIdenticalObj(TYPE_OBJ(x), t2c);
true

#
# SET_TYPE_POSOBJ
#
gap> SET_TYPE_POSOBJ(fail, fail);
Error, You can't make a positional object from a boolean or fail
gap> SET_TYPE_POSOBJ(rec(), fail);
Error, You can't make a positional object from a record (plain)
gap> # TODO: the following should also fail, but for now we allow it
gap> # for compatibility with packages that use it
gap> #SET_TYPE_POSOBJ(MakeImmutable([]), fail);
gap> x:=[ 1, , 3 ];;
gap> SET_TYPE_POSOBJ(x, t1p);
<object>
gap> IS_POSOBJ(x);
true
gap> IsIdenticalObj(TYPE_OBJ(x), t1p);
true
gap> SET_TYPE_POSOBJ(x, t2p);
<object>
gap> IsIdenticalObj(TYPE_OBJ(x), t2p);
true
gap> x![1];
1
gap> x![2];
Error, PosObj Element: <PosObj>![2] must have an assigned value
gap> x![4];
Error, PosObj Element: <PosObj>![4] must have an assigned value

#
# CLONE_OBJ
#
gap> x := [];;
gap> CLONE_OBJ(x, 0);
Error, small integers cannot be cloned
gap> CLONE_OBJ(x, Z(2));
Error, finite field elements cannot be cloned
gap> CLONE_OBJ(x, true);
Error, booleans cannot be cloned
gap> CLONE_OBJ(x, x);
gap> x;
[  ]
gap> MakeImmutable(x);;
#@if IsHPCGAP
gap> CLONE_OBJ(x, x);
Error, CLONE_OBJ() cannot overwrite public objects
#@else
gap> CLONE_OBJ(x, x);
gap> # TODO: overwriting an immutable object via CLONE_OBJ should probably
gap> # not be allowed, bu InstallValue relies on it...
#@fi

#
gap> STOP_TEST("kernel/objects.tst", 1);
