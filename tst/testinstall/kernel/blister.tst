#
# Tests for functions defined in src/blister.c
#
gap> START_TEST("kernel/blister.tst");

#
gap> a:=[true,false];; IsBlist(a);
true
gap> b:=[true,false];; IsBlist(b);
true
gap> c:=[true,true];; IsBlist(c);
true
gap> d:=[true,false,false,false,false,false,false];; IsBlist(d);
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

#
gap> d[1] := false;; d; IsBlist(d); Length(d);
[ false, false, false, false, false, false, false ]
true
7
gap> d[1] := true;; d; IsBlist(d); Length(d);
[ true, false, false, false, false, false, false ]
true
7
gap> d[8] := false;; d; IsBlist(d); Length(d);
[ true, false, false, false, false, false, false, false ]
true
8
gap> d[8] := true;; d; IsBlist(d); Length(d);
[ true, false, false, false, false, false, false, true ]
true
8
gap> d2:=ShallowCopy(d);; IsBlist(d2);
true
gap> d2[1]:=0;; IsBlist(d2); d2;
false
[ 0, false, false, false, false, false, false, true ]
gap> IsBlist(d); d;
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
Error, List Elements: <positions> must be a dense list of positive integers

# IsHomogBlist
gap> List(l, IsHomogeneousList);
[ true, true, true, true ]

# IsSSortBlist
gap> List(l, IsSSortedList);
[ true, true, false, false ]

# FuncSIZE_BLIST
gap> List(l, SizeBlist);
[ 1, 1, 2, 2 ]

# FuncBLIST_LIST
gap> BlistList(fail, fail);
Error, BlistList: <list> must be a small list (not a boolean or fail)
gap> BlistList([1,2,3], fail);
Error, BlistList: <sub> must be a small list (not a boolean or fail)
gap> BlistList([1,2,3], [1,3]);
[ true, false, true ]

# FuncLIST_BLIST
gap> ListBlist(fail, fail);
Error, ListBlist: <list> must be a small list (not a boolean or fail)
gap> ListBlist([1,2,3], fail);
Error, ListBlist: <blist> must be a boolean list (not a boolean or fail)
gap> ListBlist([1,2,3], [true,false]);
Error, ListBlist: <blist> must have the same length as <list> (3)
gap> ListBlist([1,2,3], [true,false,true]);
[ 1, 3 ]

# FuncIS_SUB_BLIST
gap> IsSubsetBlist(fail, fail);
Error, IsSubsetBlist: <blist1> must be a boolean list (not a boolean or fail)
gap> IsSubsetBlist([true,false], fail);
Error, IsSubsetBlist: <blist2> must be a boolean list (not a boolean or fail)
gap> IsSubsetBlist([true,false,true], [true,false]);
Error, IsSubsetBlist: <blist2> must have the same length as <blist1> (3)
gap> IsSubsetBlist([true,false,true], [true,false,false]);
true
gap> IsSubsetBlist([true,false,true], [true,true,false]);
false

# FuncUNITE_BLIST
gap> UniteBlist(fail, fail);
Error, UniteBlist: <blist1> must be a boolean list (not a boolean or fail)
gap> UniteBlist([true,false], fail);
Error, UniteBlist: <blist2> must be a boolean list (not a boolean or fail)
gap> UniteBlist([true,false,true], [true,false]);
Error, UniteBlist: <blist2> must have the same length as <blist1> (3)
gap> x:= [false,true,true,false];;
gap> UniteBlist(x, [true,true,false,false]);
gap> x;
[ true, true, true, false ]

# FuncUNITE_BLIST_LIST
gap> UniteBlistList(fail, fail, fail);
Error, UniteBlistList: <list> must be a small list (not a boolean or fail)
gap> UniteBlistList([1,2], fail, fail);
Error, UniteBlistList: <blist> must be a boolean list (not a boolean or fail)
gap> UniteBlistList([1,2], [true], fail);
Error, UniteBlistList: <blist> must have the same length as <list> (2)
gap> UniteBlistList([1,2], [true,false], fail);
Error, UniteBlistList: <sub> must be a small list (not a boolean or fail)
gap> x:= [true,true,false];;
gap> UniteBlistList([1,2,3], x, [2,3]);
gap> x;
[ true, true, true ]

# FuncINTER_BLIST
gap> IntersectBlist(fail, fail);
Error, IntersectBlist: <blist1> must be a boolean list (not a boolean or fail)
gap> IntersectBlist([true,false], fail);
Error, IntersectBlist: <blist2> must be a boolean list (not a boolean or fail)
gap> IntersectBlist([true,false,true], [true,false]);
Error, IntersectBlist: <blist2> must have the same length as <blist1> (3)
gap> x:= [false,true,true,false];;
gap> IntersectBlist(x, [true,true,false,false]);
gap> x;
[ false, true, false, false ]

# FuncSUBTR_BLIST
gap> SubtractBlist(fail, fail);
Error, SubtractBlist: <blist1> must be a boolean list (not a boolean or fail)
gap> SubtractBlist([true,false], fail);
Error, SubtractBlist: <blist2> must be a boolean list (not a boolean or fail)
gap> SubtractBlist([true,false,true], [true,false]);
Error, SubtractBlist: <blist2> must have the same length as <blist1> (3)
gap> x:= [false,true,true,false];;
gap> SubtractBlist(x, [true,true,false,false]);
gap> x;
[ false, false, true, false ]

# FuncMEET_BLIST
gap> MEET_BLIST(fail, fail);
Error, MeetBlist: <blist1> must be a boolean list (not a boolean or fail)
gap> MEET_BLIST([true,false], fail);
Error, MeetBlist: <blist2> must be a boolean list (not a boolean or fail)
gap> MEET_BLIST([true,false,true], [true,false]);
Error, MeetBlist: <blist2> must have the same length as <blist1> (3)
gap> x:= [false,true,true,false];;
gap> MEET_BLIST(x, [true,true,false,false]);
true
gap> MEET_BLIST(x, [true,false,false,false]);
false

#
gap> STOP_TEST("kernel/blister.tst", 1);
