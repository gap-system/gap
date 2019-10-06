#
# Tests for functions defined in src/blister.c
#
gap> START_TEST("kernel/blister.tst");

#
gap> a:=[true,false];; IsBlistRep(a);
true
gap> b:=[true,false];; IsBlistRep(b);
true
gap> c:=[true,true];; IsBlistRep(c);
true
gap> d:=[true,false,false,false,false,false,false];; IsBlistRep(d);
true
gap> l:=[a,b,c,d];;

# EqBlist
gap> List(l,x->List(l,y->x=y));
[ [ true, true, false, false ], [ true, true, false, false ], 
  [ false, false, true, false ], [ false, false, false, true ] ]

# LenBlist
gap> List(l,Length);
[ 2, 2, 2, 7 ]

# ElmBlist
gap> a[1];
true
gap> a[2];
false
gap> a[3];
Error, List Element: <list>[3] must have an assigned value

# ElmsBlist
gap> a{[]};
[  ]
gap> a{[1]};
[ true ]
gap> a{[2,1]};
[ false, true ]
gap> a{[1..2]};
[ true, false ]
gap> d{[1,3..7]};
[ true, false, false, false ]
gap> a{[2,1,3]};
Error, List Elements: <list>[3] must have an assigned value
gap> a{[1..3]};
Error, List Elements: <list>[3] must have an assigned value
gap> a{[3..5]};
Error, List Elements: <list>[3] must have an assigned value

# UnbBlist
gap> x := [ true, false, false, true ]; TNAM_OBJ(x);
[ true, false, false, true ]
"list (boolean)"
gap> IsSet(x); TNAM_OBJ(x);
false
"list (boolean,nsort)"

# removing unbound position has no effect at all
gap> Unbind(x[5]); x; TNAM_OBJ(x);
[ true, false, false, true ]
"list (boolean,nsort)"
gap> IsSet(x); TNAM_OBJ(x);
false
"list (boolean,nsort)"

# removing last bound position keeps it as a blist, resets filters
gap> Unbind(x[4]); x; TNAM_OBJ(x);
[ true, false, false ]
"list (boolean)"
gap> IsSet(x); TNAM_OBJ(x); # still unsorted
false
"list (boolean,nsort)"

# removing last bound position keeps it as a blist, resets filters
gap> Unbind(x[3]); x; TNAM_OBJ(x);
[ true, false ]
"list (boolean)"
gap> IsSet(x); TNAM_OBJ(x); # now it is sorted
true
"list (boolean,ssort)"

# removing any element but the last converts to a plain list
gap> Unbind(x[1]); x; TNAM_OBJ(x);
[ , false ]
"non-dense plain list"
gap> IsSet(x); TNAM_OBJ(x);
false
"non-dense plain list"

# AssBlist
gap> d[1] := false;; d; IsBlistRep(d); Length(d);
[ false, false, false, false, false, false, false ]
true
7
gap> d[1] := true;; d; IsBlistRep(d); Length(d);
[ true, false, false, false, false, false, false ]
true
7
gap> d[8] := false;; d; IsBlistRep(d); Length(d);
[ true, false, false, false, false, false, false, false ]
true
8
gap> d[8] := true;; d; IsBlistRep(d); Length(d);
[ true, false, false, false, false, false, false, true ]
true
8
gap> d2:=ShallowCopy(d);; IsBlistRep(d2);
true
gap> d2[1]:=0;; IsBlistRep(d2); d2;
false
[ 0, false, false, false, false, false, false, true ]
gap> IsBlistRep(d); d;
true
[ true, false, false, false, false, false, false, true ]

# AssBlistImm
gap> MakeImmutable(d);;
gap> d[1] := false;
Error, List Assignment: <list> must be a mutable list
gap> d[9] := false;
Error, List Assignment: <list> must be a mutable list

# PosBlist
gap> Position(d,true);
1
gap> Position(d,false);
2
gap> Position(d,fail);
fail

# IsPossBlist
gap> IsPositionsList(d);
false
gap> x:=[1,2,3];;
gap> x{a};
Error, List Elements: <poss> must be a dense list of positive integers

# IsHomogBlist
gap> List(l, IsHomogeneousList);
[ true, true, true, true ]

# IsSSortBlist
gap> List(l, IsSSortedList);
[ true, true, false, false ]

# FuncSIZE_BLIST
gap> List(l, SizeBlist);
[ 1, 1, 2, 2 ]

#
# FuncBLIST_LIST
#
gap> BlistList(fail, fail);
Error, BlistList: <list> must be a small list (not the value 'fail')
gap> BlistList([1,2,3], fail);
Error, BlistList: <sub> must be a small list (not the value 'fail')
gap> BlistList([1,2,3], [1,3]);
[ true, false, true ]

# ranges with increment 1
gap> BlistList([0..3], [-3..-1]);
[ false, false, false, false ]
gap> BlistList([0..3], [-3..1]);
[ true, true, false, false ]
gap> BlistList([0..3], [-3..6]);
[ true, true, true, true ]
gap> BlistList([0..3], [0..1]);
[ true, true, false, false ]
gap> BlistList([0..3], [0..6]);
[ true, true, true, true ]
gap> BlistList([0..3], [2..6]);
[ false, false, true, true ]
gap> BlistList([0..3], [4..6]);
[ false, false, false, false ]

#
# FuncLIST_BLIST
#
gap> ListBlist(fail, fail);
Error, ListBlist: <list> must be a small list (not the value 'fail')
gap> ListBlist([1,2,3], fail);
Error, ListBlist: <blist> must be a boolean list (not the value 'fail')
gap> ListBlist([1,2,3], [true,false]);
Error, ListBlist: <blist> must have the same length as <list> (lengths are 2 a\
nd 3)
gap> ListBlist([1,2,3], [true,false,true]);
[ 1, 3 ]

# FuncIS_SUB_BLIST
gap> IsSubsetBlist(fail, fail);
Error, IsSubsetBlist: <blist1> must be a boolean list (not the value 'fail')
gap> IsSubsetBlist([true,false], fail);
Error, IsSubsetBlist: <blist2> must be a boolean list (not the value 'fail')
gap> IsSubsetBlist([true,false,true], [true,false]);
Error, IsSubsetBlist: <blist1> must have the same length as <blist2> (lengths \
are 3 and 2)
gap> IsSubsetBlist([true,false,true], [true,false,false]);
true
gap> IsSubsetBlist([true,false,true], [true,true,false]);
false

# FuncUNITE_BLIST
gap> UniteBlist(fail, fail);
Error, UniteBlist: <blist1> must be a boolean list (not the value 'fail')
gap> UniteBlist([true,false], fail);
Error, UniteBlist: <blist2> must be a boolean list (not the value 'fail')
gap> UniteBlist([true,false,true], [true,false]);
Error, UniteBlist: <blist1> must have the same length as <blist2> (lengths are\
 3 and 2)
gap> x:= [false,true,true,false];;
gap> UniteBlist(Immutable(x), [true,true,false,false]);
Error, UniteBlist: <blist1> must be a mutable boolean list (not a list (boolea\
n,imm))
gap> x;
[ false, true, true, false ]
gap> UniteBlist(x, [true,true,false,false]);
gap> x;
[ true, true, true, false ]

# FuncUNITE_BLIST_LIST
gap> UniteBlistList(fail, fail, fail);
Error, UniteBlistList: <list> must be a small list (not the value 'fail')
gap> UniteBlistList([1,2], fail, fail);
Error, UniteBlistList: <blist> must be a boolean list (not the value 'fail')
gap> UniteBlistList([1,2], [true], fail);
Error, UniteBlistList: <blist> must have the same length as <list> (lengths ar\
e 1 and 2)
gap> UniteBlistList([1,2], [true,false], fail);
Error, UniteBlistList: <sub> must be a small list (not the value 'fail')
gap> x:= [true,true,false];;
gap> UniteBlistList([1,2,3], Immutable(x), [2,3]);
Error, UniteBlistList: <blist> must be a mutable boolean list (not a list (boo\
lean,imm))
gap> x;
[ true, true, false ]
gap> UniteBlistList([1,2,3], x, [2,3]);
gap> x;
[ true, true, true ]

# FuncINTER_BLIST
gap> IntersectBlist(fail, fail);
Error, IntersectBlist: <blist1> must be a boolean list (not the value 'fail')
gap> IntersectBlist([true,false], fail);
Error, IntersectBlist: <blist2> must be a boolean list (not the value 'fail')
gap> IntersectBlist([true,false,true], [true,false]);
Error, IntersectBlist: <blist1> must have the same length as <blist2> (lengths\
 are 3 and 2)
gap> x:= [false,true,true,false];;
gap> IntersectBlist(Immutable(x), [true,true,false,false]);
Error, IntersectBlist: <blist1> must be a mutable boolean list (not a list (bo\
olean,imm))
gap> x;
[ false, true, true, false ]
gap> IntersectBlist(x, [true,true,false,false]);
gap> x;
[ false, true, false, false ]

# FuncSUBTR_BLIST
gap> SubtractBlist(fail, fail);
Error, SubtractBlist: <blist1> must be a boolean list (not the value 'fail')
gap> SubtractBlist([true,false], fail);
Error, SubtractBlist: <blist2> must be a boolean list (not the value 'fail')
gap> SubtractBlist([true,false,true], [true,false]);
Error, SubtractBlist: <blist1> must have the same length as <blist2> (lengths \
are 3 and 2)
gap> x:= [false,true,true,false];;
gap> SubtractBlist(Immutable(x), [true,true,false,false]);
Error, SubtractBlist: <blist1> must be a mutable boolean list (not a list (boo\
lean,imm))
gap> x;
[ false, true, true, false ]
gap> SubtractBlist(x, [true,true,false,false]);
gap> x;
[ false, false, true, false ]

# FuncMEET_BLIST
gap> MEET_BLIST(fail, fail);
Error, MeetBlist: <blist1> must be a boolean list (not the value 'fail')
gap> MEET_BLIST([true,false], fail);
Error, MeetBlist: <blist2> must be a boolean list (not the value 'fail')
gap> MEET_BLIST([true,false,true], [true,false]);
Error, MeetBlist: <blist1> must have the same length as <blist2> (lengths are \
3 and 2)
gap> x:= [false,true,true,false];;
gap> MEET_BLIST(x, [true,true,false,false]);
true
gap> MEET_BLIST(x, [true,false,false,false]);
false

# FuncFLIP_BLIST
gap> FLIP_BLIST(fail);
Error, FlipBlist: <blist> must be a boolean list (not the value 'fail')
gap> x:= [false,true,true,false];;
gap> FlipBlist(Immutable(x));
Error, FlipBlist: <blist> must be a mutable boolean list (not a list (boolean,\
imm))
gap> x;
[ false, true, true, false ]
gap> FLIP_BLIST(x);
gap> x;
[ true, false, false, true ]
gap> FLIP_BLIST(x);
gap> x;
[ false, true, true, false ]
gap> for i in [0..200] do
> f1 := List([1..i], x -> false);
> f2 := List([1..i], x -> false);
> t1 := List([1..i], x -> true);
> t2 := List([1..i], x -> true);
> FLIP_BLIST(f1); FLIP_BLIST(t1);
> if f1 <> t2 or t1 <> f2 then Print("Broken FLIP_BLIST", i, "\n"); fi;
> od;

# FuncSET_ALL_BLIST
gap> SET_ALL_BLIST(fail);
Error, SetAllBitsBlist: <blist> must be a boolean list (not the value 'fail')
gap> x:= [false,true,true,false];;
gap> SET_ALL_BLIST(Immutable(x));
Error, SetAllBitsBlist: <blist> must be a mutable boolean list (not a list (bo\
olean,imm))
gap> x;
[ false, true, true, false ]
gap> SET_ALL_BLIST(x);
gap> x;
[ true, true, true, true ]
gap> SET_ALL_BLIST(x);
gap> x;
[ true, true, true, true ]
gap> for i in [0..200] do
> f1 := List([1..i], x -> false);
> t1 := List([1..i], x -> true);
> SET_ALL_BLIST(f1);
> if f1 <> t1 then Print("Broken SET_ALL_BLIST\n"); fi;
> od;

# FuncCLEAR_ALL_BLIST
gap> CLEAR_ALL_BLIST(fail);
Error, ClearAllBitsBlist: <blist> must be a boolean list (not the value 'fail'\
)
gap> x:= [false,true,true,false];;
gap> CLEAR_ALL_BLIST(Immutable(x));
Error, ClearAllBitsBlist: <blist> must be a mutable boolean list (not a list (\
boolean,imm))
gap> x;
[ false, true, true, false ]
gap> CLEAR_ALL_BLIST(x);
gap> x;
[ false, false, false, false ]
gap> CLEAR_ALL_BLIST(x);
gap> x;
[ false, false, false, false ]
gap> for i in [0..200] do
> f1 := List([1..i], x -> false);
> t1 := List([1..i], x -> true);
> CLEAR_ALL_BLIST(t1);
> if f1 <> t1 then Print("Broken CLEAR_ALL_BLIST\n"); fi;
> od;

#
gap> STOP_TEST("kernel/blister.tst", 1);
