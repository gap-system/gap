#############################################################################
gap> START_TEST("weakptr-badargs.tst");
gap> w := WeakPointerObject([1,,3,4]);
Error, Variable: 'WeakPointerObject' must have a value
gap> w := WeakPointerObj([1,,3,4]);;
gap> SetElmWPObj(w, 0, 0);
Error, SetElmWPObj: <pos> must be a positive small integer (not a integer)
gap> SetElmWPObj(w, [1,2], 0);
Error, SetElmWPObj: <pos> must be a positive small integer (not a list (plain,\
cyc))
gap> SetElmWPObj(w, (), 0);
Error, SetElmWPObj: <pos> must be a positive small integer (not a permutation \
(small))
gap> SetElmWPObj((), 1, 1);
Error, SetElmWPObj: <wp> must be a weak pointer object (not a permutation (sma\
ll))
gap> UnbindElmWPObj(w, 0);
Error, UnbindElmWPObj: <pos> must be a positive small integer (not a integer)
gap> UnbindElmWPObj(w, []);
Error, UnbindElmWPObj: <pos> must be a positive small integer (not a list (pla\
in,empty))
gap> UnbindElmWPObj([], 2);
Error, UnbindElmWPObj: <wp> must be a weak pointer object (not a list (plain,e\
mpty))
gap> ElmWPObj(w, 0);
Error, ElmWPObj: <pos> must be a positive small integer (not a integer)
gap> ElmWPObj(w, []);
Error, ElmWPObj: <pos> must be a positive small integer (not a list (plain,emp\
ty))
gap> ElmWPObj([], 1);
Error, ElmWPObj: <wp> must be a weak pointer object (not a list (plain,empty))
gap> IsBoundWPObj(w, 0);
Error, Variable: 'IsBoundWPObj' must have a value
gap> IsBoundElmWPObj(w, 0);
Error, IsBoundElmWPObj: <pos> must be a positive small integer (not a integer)
gap> IsBoundElmWPObj(w, []);
Error, IsBoundElmWPObj: <pos> must be a positive small integer (not a list (pl\
ain,empty))
gap> IsBoundElmWPObj([], 1);
Error, IsBoundElmWPObj: <wp> must be a weak pointer object (not a list (plain,\
empty))
gap> LengthWPObj([]);
Error, LengthWPObj: <wp> must be a weak pointer object (not a list (plain,empt\
y))
gap> LengthWPObj(0);
Error, LengthWPObj: <wp> must be a weak pointer object (not a integer)
gap> STOP_TEST( "weakptr-badargs.tst", 1);
