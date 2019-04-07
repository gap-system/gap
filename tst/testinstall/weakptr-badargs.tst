#############################################################################
#@local w
gap> START_TEST("weakptr-badargs.tst");
gap> w := WeakPointerObj([1,,3,4]);;
gap> SetElmWPObj(w, 0, 0);
Error, SetElmWPObj: <pos> must be a positive small integer (not the integer 0)
gap> SetElmWPObj(w, [1,2], 0);
Error, SetElmWPObj: <pos> must be a positive small integer (not a plain list o\
f cyclotomics)
gap> SetElmWPObj(w, (), 0);
Error, SetElmWPObj: <pos> must be a positive small integer (not a permutation \
(small))
gap> SetElmWPObj((), 1, 1);
Error, SetElmWPObj: <wp> must be a weak pointer object (not a permutation (sma\
ll))
gap> UnbindElmWPObj(w, 0);
Error, UnbindElmWPObj: <pos> must be a positive small integer (not the integer\
 0)
gap> UnbindElmWPObj(w, []);
Error, UnbindElmWPObj: <pos> must be a positive small integer (not a empty pla\
in list)
gap> UnbindElmWPObj([], 2);
Error, UnbindElmWPObj: <wp> must be a weak pointer object (not a empty plain l\
ist)
gap> ElmWPObj(w, 0);
Error, ElmWPObj: <pos> must be a positive small integer (not the integer 0)
gap> ElmWPObj(w, []);
Error, ElmWPObj: <pos> must be a positive small integer (not a empty plain lis\
t)
gap> ElmWPObj([], 1);
Error, ElmWPObj: <wp> must be a weak pointer object (not a empty plain list)
gap> IsBoundElmWPObj(w, 0);
Error, IsBoundElmWPObj: <pos> must be a positive small integer (not the intege\
r 0)
gap> IsBoundElmWPObj(w, []);
Error, IsBoundElmWPObj: <pos> must be a positive small integer (not a empty pl\
ain list)
gap> IsBoundElmWPObj([], 1);
Error, IsBoundElmWPObj: <wp> must be a weak pointer object (not a empty plain \
list)
gap> LengthWPObj([]);
Error, LengthWPObj: <wp> must be a weak pointer object (not a empty plain list\
)
gap> LengthWPObj(0);
Error, LengthWPObj: <wp> must be a weak pointer object (not the integer 0)
gap> STOP_TEST( "weakptr-badargs.tst", 1);
