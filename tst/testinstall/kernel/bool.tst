#
# Tests for functions defined in src/bool.c
#
gap> START_TEST("kernel/bool.tst");

# TypeBool
gap> t:=TypeObj(true);
<Type: (BooleanFamily, [ IsBool, IsInternalRep ]), data: fail,>
gap> IsIdenticalObj(t, TypeObj(false));
true
gap> IsIdenticalObj(t, TypeObj(fail));
true

# PrintBool
gap> b := [ true, false, fail ];
[ true, false, fail ]

# EqBool
gap> SetX([1..3],[1..3],{i,j} -> (i < j) = (b[i] < b[j]));
[ true ]

# LtBool
gap> IsSet(b);
true
gap> SetX([1..3],[1..3],{i,j} -> (i < j) = (b[i] < b[j]));
[ true ]

# IsBoolHandler
gap> ForAll(b, IsBool);
true
gap> ForAny([1, 'x', "x", 0.0], IsBool);
false

# ReturnTrue
gap> List([0..7], n -> CallFuncList(ReturnTrue,[1..n]));
[ true, true, true, true, true, true, true, true ]

# ReturnFalse
gap> List([0..7], n -> CallFuncList(ReturnFalse,[1..n]));
[ false, false, false, false, false, false, false, false ]

# ReturnFail
gap> List([0..7], n -> CallFuncList(ReturnFail,[1..n]));
[ fail, fail, fail, fail, fail, fail, fail, fail ]

#
gap> STOP_TEST("kernel/bool.tst", 1);
