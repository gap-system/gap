gap> START_TEST("list.tst");

# EQ: for two small lists, 1
gap> [1] = [2];
false
gap> [1] = [1];
true
gap> [2, 1] = [2];
false
gap> [4] = [4, 5];
false

# EQ: for two lists, the first or second being empty
gap> l := [0];;
gap> HasIsEmpty(l);
false
gap> l = [];
false
gap> [] = l;
false

# ListWithIdenticalEntries: errors
gap> ListWithIdenticalEntries(fail, true);
Error, <n> must be a non-negative integer (not a boolean or fail)
gap> ListWithIdenticalEntries(-1, fail);
Error, <n> must be a non-negative integer (not a integer)

# ListWithIdenticalEntries: 0 length
gap> l := ListWithIdenticalEntries(0, 'w');
""
gap> IsStringRep(l);
true
gap> l := ListWithIdenticalEntries(0, true);
[  ]
gap> IsBlistRep(l);
true
gap> l := ListWithIdenticalEntries(0, fail);
[  ]
gap> IsPlistRep(l);
true

# ListWithIdenticalEntries: strings
gap> l := ListWithIdenticalEntries(1, 'y');
"y"
gap> IsStringRep(l);
true
gap> l := ListWithIdenticalEntries(2, 'z');
"zz"
gap> IsStringRep(l);
true
gap> l := ListWithIdenticalEntries(76, '#');
"############################################################################"
gap> IsStringRep(l);
true

# ListWithIdenticalEntries: blists
gap> l := ListWithIdenticalEntries(1, true);
[ true ]
gap> IsBlistRep(l);
true
gap> l := ListWithIdenticalEntries(2, true);
[ true, true ]
gap> IsBlistRep(l);
true
gap> l := ListWithIdenticalEntries(3, true);
[ true, true, true ]
gap> IsBlistRep(l);
true
gap> ForAll([1 .. 100],
>           i -> ForAll(ListWithIdenticalEntries(i, true), x -> x));
true
gap> l := ListWithIdenticalEntries(1, false);
[ false ]
gap> IsBlistRep(l);
true
gap> l := ListWithIdenticalEntries(2, false);
[ false, false ]
gap> IsBlistRep(l);
true
gap> l := ListWithIdenticalEntries(3, false);
[ false, false, false ]
gap> IsBlistRep(l);
true
gap> ForAny([1 .. 100],
>           i -> ForAny(ListWithIdenticalEntries(i, false), x -> x));
false

# ListWithIdenticalEntries: other
gap> l := ListWithIdenticalEntries(2, Group(()));
[ Group(()), Group(()) ]
gap> IsPlistRep(l);
true
gap> IsIdenticalObj(l[1], l[2]);
true
gap> l := ListWithIdenticalEntries(10, "GAP");;
gap> TNAM_OBJ(l);
"list (plain,hom)"
gap> l;
[ "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP" ]
gap> TNAM_OBJ(l);
"list (plain,table)"
gap> l := ListWithIdenticalEntries(10, PrimitiveRoot(GF(5)));
[ Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5) ]
gap> TNAM_OBJ(l);
"list (sml fin fld elms)"
gap> l := ListWithIdenticalEntries(10, 5 / 7);
[ 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7 ]
gap> TNAM_OBJ(l);
"list (plain,cyc)"
gap> l := ListWithIdenticalEntries(5, -1);
[ -1, -1, -1, -1, -1 ]
gap> TNAM_OBJ(l);
"list (plain,cyc)"
gap> l := ListWithIdenticalEntries(5, 8);
[ 8, 8, 8, 8, 8 ]
gap> TNAM_OBJ(l);
"list (plain,cyc)"
gap> l := ListWithIdenticalEntries(5, 0);
[ 0, 0, 0, 0, 0 ]
gap> TNAM_OBJ(l);
"list (plain,cyc)"
gap> l := ListWithIdenticalEntries(5, infinity);
[ infinity, infinity, infinity, infinity, infinity ]
gap> TNAM_OBJ(l);
"list (plain,hom)"
gap> l := ListWithIdenticalEntries(4, []);;
gap> TNAM_OBJ(l);
"list (plain,hom)"
gap> l;
[ [  ], [  ], [  ], [  ] ]
gap> TNAM_OBJ(l);
"list (plain,rect table)"
gap> l := ListWithIdenticalEntries(4, [5]);;
gap> TNAM_OBJ(l);
"list (plain,hom)"
gap> l;
[ [ 5 ], [ 5 ], [ 5 ], [ 5 ] ]
gap> TNAM_OBJ(l);
"list (plain,rect table)"

# String, for a range
gap> l := [5 .. 10];
[ 5 .. 10 ]
gap> String(l);
"[ 5 .. 10 ]"
gap> l := [21, 23, 25];
[ 21, 23, 25 ]
gap> IsRange(l);
true
gap> String(l);
"[ 21, 23 .. 25 ]"
gap> l := [10, 20];
[ 10, 20 ]
gap> IsRange(l);
true
gap> String(l);
"[ 10, 20 .. 20 ]"
gap> l := [2, 10, 18, 26, 34, 42];
[ 2, 10, 18, 26, 34, 42 ]
gap> IsRange(l);
true
gap> String(l);
"[ 2, 10 .. 42 ]"
gap> l := [50, 40, 30, 20, 10, 0, -10];
[ 50, 40, 30, 20, 10, 0, -10 ]
gap> IsRange(l);
true
gap> String(l);
"[ 50, 40 .. -10 ]"
gap> EvalString(String(l)) = l;
true

# Representative, for two lists
gap> l := Filtered([1 .. 20], IsPrimeInt);;
gap> Representative(l);
2
gap> Representative([]);
Error, <list> must be nonempty to have a representative
gap> Representative(EmptyPlist(0));
Error, <list> must be nonempty to have a representative
gap> l := EmptyPlist(4);;
gap> l[3] := 5;;
gap> Representative(l);
5

# RepresentativeSmallest, for an empty list
gap> RepresentativeSmallest(EmptyPlist(0));
Error, <C> must be nonempty to have a representative

# RepresentativeSmallest, for a strictly sorted list
gap> l := [12 .. 40];;
gap> RepresentativeSmallest(l);
12

# RepresentativeSmallest, for a list
gap> l := [40, 39 .. 10];;
gap> RepresentativeSmallest(l);
10

# PositionsProperty
gap> ll := [ 1, , "s" ];;
gap> PositionsProperty( ll, ReturnTrue );
[ 1, 3 ]
gap> PositionsProperty( ll, IsInt );
[ 1 ]
gap> ll := [ 1, 2, 3 ];;
gap> PositionsProperty( ll, ReturnTrue );
[ 1, 2, 3 ]
gap> PositionsProperty( ll, IsInt );
[ 1, 2, 3 ]

# PositionProperty
gap> ll := [ 1, , "s" ];;
gap> PositionProperty( ll, ReturnTrue, 0);
1
gap> PositionProperty( ll, ReturnTrue, 1);
3
gap> PositionProperty( ll, IsInt, 0);
1
gap> PositionProperty( ll, IsInt, 1);
fail
gap> ll := [ 1, 2, 3 ];;
gap> PositionProperty( ll, ReturnTrue, 0);
1
gap> PositionProperty( ll, ReturnTrue, 1);
2
gap> PositionProperty( ll, ReturnTrue, 2);
3
gap> PositionProperty( ll, ReturnTrue, 3);
fail

#
gap> STOP_TEST("list.tst");
