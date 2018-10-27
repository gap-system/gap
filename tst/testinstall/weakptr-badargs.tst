#############################################################################
gap> START_TEST("weakptr-badargs.tst");
gap> w := WeakPointerObject([1,,3,4]);
Error, Variable: 'WeakPointerObject' must have a value
gap> w := WeakPointerObj([1,,3,4]);;
gap> SetElmWPObj(w, 0, 0);
Error, SetElmWPObj: Position must be a positive small integer, not a integer
gap> SetElmWPObj(w, [1,2], 0);
Error, SetElmWPObj: Position must be a positive small integer, not a list (pla\
in,cyc)
gap> SetElmWPObj(w, (), 0);
Error, SetElmWPObj: Position must be a positive small integer, not a permutati\
on (small)
gap> SetElmWPObj((), 1, 1);
Error, SetElmWPObj: First argument must be a weak pointer object, not a permut\
ation (small)
gap> UnbindElmWPObj(w, 0);
Error, UnbindElmWPObj: Position must be a positive small integer, not a intege\
r
gap> UnbindElmWPObj(w, []);
Error, UnbindElmWPObj: Position must be a positive small integer, not a list (\
plain,empty)
gap> UnbindElmWPObj([], 2);
Error, UnbindElmWPObj: First argument must be a weak pointer object, not a lis\
t (plain,empty)
gap> ElmWPObj(w, 0);
Error, ElmWPObj: Position must be a positive small integer, not a integer
gap> ElmWPObj(w, []);
Error, ElmWPObj: Position must be a positive small integer, not a list (plain,\
empty)
gap> ElmWPObj([], 1);
Error, ElmWPObj: First argument must be a weak pointer object, not a list (pla\
in,empty)
gap> IsBoundWPObj(w, 0);
Error, Variable: 'IsBoundWPObj' must have a value
gap> IsBoundElmWPObj(w, 0);
Error, IsBoundElmWPObj: Position must be a positive small integer, not a integ\
er
gap> IsBoundElmWPObj(w, []);
Error, IsBoundElmWPObj: Position must be a positive small integer, not a list \
(plain,empty)
gap> IsBoundElmWPObj([], 1);
Error, IsBoundElmWPObj: First argument must be a weak pointer object, not a li\
st (plain,empty)
gap> LengthWPObj([]);
Error, LengthWPObj: argument must be a weak pointer object, not a list (plain,\
empty)
gap> LengthWPObj(0);
Error, LengthWPObj: argument must be a weak pointer object, not a integer
gap> STOP_TEST( "weakptr-badargs.tst", 1);
