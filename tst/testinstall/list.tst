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

#
# assignment / extraction, also with selectors
#
gap> a := [ [ [ 1 ] ] ];
[ [ [ 1 ] ] ]
gap> a[1];
[ [ 1 ] ]
gap> a[1,1];
[ 1 ]
gap> a[1,1,1];
Syntax error: '[]' only supports 1 or 2 indices in stream:1
a[1,1,1];
       ^

#
gap> a := [ [ [1, 2], [3, 4] ], [ [5, 6], [7, 8] ] ];
[ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ]
gap> a{[1]};
[ [ [ 1, 2 ], [ 3, 4 ] ] ]
gap> a{[1]}[1];
[ [ 1, 2 ] ]
gap> a{[1]}[1,2];
[ 2 ]
gap> a{[1]}{[1]};
[ [ [ 1, 2 ] ] ]
gap> a{[1]}{[1]}[1];
[ [ 1 ] ]
gap> a{[1]}{[1]}[1,1];
Error, List Element: <list> must be a list (not the integer 1)

#
gap> a{[1,,2]}:=1;
Error, List Assignments: <rhss> must be a dense list (not the integer 1)
gap> a{[1,,2]}:=[1,2];
Error, List Assignments: <poss> must be a dense list of positive integers

#
gap> a{[1]}{[1]}[1] := 42;
Error, List Assignments: <objs> must be a dense list (not the integer 42)
gap> a{[1]}{[1]}[1] := [ 42 ];
Error, List Assignments: <objs> must be a dense list (not the integer 42)
gap> a{[1]}{[1]}[1] := [ [ 42 ] ];
[ [ 42 ] ]
gap> a;
[ [ [ 42, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ]

#
gap> a{[1]}{[1]} := 19;
Error, List Assignments: <objs> must be a dense list (not the integer 19)
gap> a{[1]}{[1]} := [ 18, 19 ];
Error, List Assignments: <objs> must have the same length as <lists> (lengths \
are 2 and 1)
gap> a{[1]}{[1]} := [ [ 18, 19 ] ] ;
Error, List Assignments: <objs> must have the same length as <poss> (lengths a\
re 2 and 1)
gap> a{[1]}{[1,,3]} := [ [ [ 18, 19 ] ] ];
Error, List Assignments: <poss> must be a dense list of positive integers
gap> a{[1]}{[1]} := [ [ [ 18, 19 ] ] ];
[ [ [ 18, 19 ] ] ]
gap> a;
[ [ [ 18, 19 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ]

#
gap> a := [ [ [ 1 ] ] ];
[ [ [ 1 ] ] ]
gap> a[1] := [ [ 42 ] ];
[ [ 42 ] ]
gap> a[1,1] := [ 43 ];
[ 43 ]
gap> a[1,1,1] := 44;
Syntax error: '[]' only supports 1 or 2 indices in stream:1
a[1,1,1] := 44;
       ^
gap> IsBound(a[1,1,1]);
Syntax error: '[]' only supports 1 or 2 indices in stream:1
IsBound(a[1,1,1]);
               ^
gap> Unbind(a[1,1,1]);
Syntax error: '[]' only supports 1 or 2 indices in stream:1
Unbind(a[1,1,1]);
              ^
gap> a := [1,,3];;
gap> IsBound(a[1]);
true
gap> IsBound(a[2]);
false
gap> IsBound(a[3]);
true
gap> IsBound(a[4]);
false
gap> IsBound(a[2^100]);
false

#
# slices
#
gap> 1{1};
Error, List Elements: <poss> must be a dense list of positive integers
gap> 1{[1]};
Error, List Elements: <list> must be a list (not the integer 1)

# ... for blists
gap> list := [true,false,true];;
gap> list{1};
Error, List Elements: <poss> must be a dense list of positive integers
gap> list{[4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[1,2,3]} = list;  # with a plist as selector
true
gap> list{[1,2^100,3]};
Error, List Elements: position is too large for this type of list
gap> list{[1..3]} = list;  # with a range as selector
true
gap> list{[1..4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[4..5]};
Error, List Elements: <list>[4] must have an assigned value

# ... for plists
gap> list := [1, 2, 4];;
gap> list{1};
Error, List Elements: <poss> must be a dense list of positive integers
gap> list{[4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[1,2,3]} = list;  # with a plist as selector
true
gap> list{[1,2^100,3]};
Error, List Elements: position is too large for this type of list
gap> list{[1..3]} = list;  # with a range as selector
true
gap> list{[1..4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[4..5]};
Error, List Elements: <list>[4] must have an assigned value

# ... for ranges
gap> list := [1..3];;
gap> list{1};
Error, List Elements: <poss> must be a dense list of positive integers
gap> list{[4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[1,2,3]} = list;  # with a plist as selector
true
gap> list{[1,2^100,3]};
Error, List Elements: position is too large for this type of list
gap> list{[1..3]} = list;  # with a range as selector
true
gap> list{[1..4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[4..5]};
Error, List Elements: <list>[4] must have an assigned value

# ... for strings
gap> list := "abc";;
gap> list{1};
Error, List Elements: <poss> must be a dense list of positive integers
gap> list{[4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[1,2,3]} = list;  # with a plist as selector
true
gap> list{[1,2^100,3]};
Error, List Elements: position is too large for this type of list
gap> list{[1..3]} = list;  # with a range as selector
true
gap> list{[1..4]};
Error, List Elements: <list>[4] must have an assigned value
gap> list{[4..5]};
Error, List Elements: <list>[4] must have an assigned value

# ListWithIdenticalEntries: errors
gap> ListWithIdenticalEntries(fail, true);
Error, LIST_WITH_IDENTICAL_ENTRIES: <n> must be a non-negative small integer (\
not the value 'fail')
gap> ListWithIdenticalEntries(-1, fail);
Error, LIST_WITH_IDENTICAL_ENTRIES: <n> must be a non-negative small integer (\
not the integer -1)

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
"homogeneous plain list"
gap> l;
[ "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP", "GAP" ]
gap> TNAM_OBJ(l);
"plain list (table)"
gap> l := ListWithIdenticalEntries(10, PrimitiveRoot(GF(5)));
[ Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5), Z(5) ]
gap> TNAM_OBJ(l);
"plain list of small finite field elements"
gap> l := ListWithIdenticalEntries(10, 5 / 7);
[ 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7, 5/7 ]
gap> TNAM_OBJ(l);
"plain list of cyclotomics"
gap> l := ListWithIdenticalEntries(5, -1);
[ -1, -1, -1, -1, -1 ]
gap> TNAM_OBJ(l);
"plain list of cyclotomics"
gap> l := ListWithIdenticalEntries(5, 8);
[ 8, 8, 8, 8, 8 ]
gap> TNAM_OBJ(l);
"plain list of cyclotomics"
gap> l := ListWithIdenticalEntries(5, 0);
[ 0, 0, 0, 0, 0 ]
gap> TNAM_OBJ(l);
"plain list of cyclotomics"
gap> l := ListWithIdenticalEntries(5, infinity);
[ infinity, infinity, infinity, infinity, infinity ]
gap> TNAM_OBJ(l);
"homogeneous plain list"
gap> l := ListWithIdenticalEntries(4, []);;
gap> TNAM_OBJ(l);
"homogeneous plain list"
gap> l;
[ [  ], [  ], [  ], [  ] ]
gap> TNAM_OBJ(l);
"plain list (rectangular table)"
gap> l := ListWithIdenticalEntries(4, [5]);;
gap> TNAM_OBJ(l);
"homogeneous plain list"
gap> l;
[ [ 5 ], [ 5 ], [ 5 ], [ 5 ] ]
gap> TNAM_OBJ(l);
"plain list (rectangular table)"

# Check TNUM behaviours
gap> x := [1,,"cheese"];;
gap> x[2] := 2;;
gap> IsSSortedList(x);;
gap> TNAM_OBJ(x);
"dense plain list"
gap> x := [1,,"cheese"];;
gap> x[2] := 2;
2
gap> y := Immutable(x);;
gap> IsIdenticalObj(x,y);
false
gap> TNAM_OBJ(x);
"plain list"
gap> TNAM_OBJ(y);
"immutable plain list"
gap> IsSSortedList(y);;
gap> TNAM_OBJ(y);
"immutable dense non-homogeneous strictly-sorted plain list"

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

# First
gap> First([0,1,2,3]);
0
gap> First([0..3]);
0
gap> First(Enumerator(Integers));
0
gap> First([0,1,2,3], IsFFE);
fail
gap> First([0..3], IsFFE);
fail
gap> First([0,1,2,3], IsPosInt);
1
gap> First([0..3], IsPosInt);
1
gap> First(Enumerator(Integers), IsPosInt);
1

# Last
gap> Last([0,1,2,3]);
3
gap> Last([0..3]);
3
gap> Last(Enumerator(Integers));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `LastOp' on 1 arguments
gap> Last([0,1,2,3], IsFFE);
fail
gap> Last([0..3], IsFFE);
fail
gap> Last([0,1,2,3], IsZero);
0
gap> Last([0..3], IsZero);
0
gap> Last(Enumerator(Integers), IsZero);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `LastOp' on 2 arguments

# Positions
gap> ll := [ 1, 2, 3, 2, 1, 2 ];;
gap> Positions( ll, 1 );
[ 1, 5 ]
gap> Positions( ll, 4 );
[  ]
gap> HasIsSSortedList( Positions( ll, 2 ) );
true

# PositionSortedBy on plist
gap> ll := [ 1, 3 ];;
gap> PositionSortedBy(ll, 0, x -> x);
1
gap> PositionSortedBy(ll, 1, x -> x);
1
gap> PositionSortedBy(ll, 2, x -> x);
2
gap> PositionSortedBy(ll, 3, x -> x);
2
gap> PositionSortedBy(ll, 4, x -> x);
3
gap> PositionSortedBy([], 0, x -> x);
1
gap> for ll in [ [1], [1,2], [1,2,3], [1,2,3,4], [1,4] ] do
>   for a in [0..5] do
>     p := PositionSortedBy(ll, a, x -> x);
>     Assert(0, p = 1 or ll[p-1] < a);
>     Assert(0, p = Length(ll) + 1 or a <= ll[p]);
>   od;
> od;

# PositionSortedBy on range
gap> ll := [ 1, 3 .. 3 ];;
gap> PositionSortedBy(ll, 0, x -> x);
1
gap> PositionSortedBy(ll, 1, x -> x);
1
gap> PositionSortedBy(ll, 2, x -> x);
2
gap> PositionSortedBy(ll, 3, x -> x);
2
gap> PositionSortedBy(ll, 4, x -> x);
3
gap> for ll in [ [1..2], [1..3], [1..4], [1,4..4] ] do
>   for a in [0..5] do
>     p := PositionSortedBy(ll, a, x -> x);
>     Assert(0, p = 1 or ll[p-1] < a);
>     Assert(0, p = Length(ll) + 1 or a <= ll[p]);
>   od;
> od;

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
gap> HasIsSSortedList( PositionsProperty( ll, IsPrimeInt ) );
true

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

# PositionBound
gap> PositionBound( [] );
fail
gap> PositionBound( [ 1 .. 3 ] );
1
gap> PositionBound( [ 2, 3, 4 ] );
1
gap> PositionBound( [ ,, 1 ] );
3

# PositionsBound
gap> PositionsBound( [] );
[  ]
gap> PositionsBound( [ 1 .. 3 ] );
[ 1 .. 3 ]
gap> PositionsBound( [ 1, 2, 3 ] );
[ 1 .. 3 ]
gap> PositionsBound( [ 1,, 2 ] );
[ 1, 3 ]
gap> HasIsSSortedList( PositionsBound( [ 1,, 2 ] ) );
true

# AsSet
gap> l := ["a", "b", "c"];
[ "a", "b", "c" ]
gap> MakeImmutable(l);;
gap> IsSet(l);
true
gap> IsIdenticalObj(AsSet(l), l);
true
gap> l := [true, false];
[ true, false ]
gap> MakeImmutable(l);;
gap> IsSet(l);
true
gap> IsIdenticalObj(AsSet(l), l);
true
gap> l := [1..3];
[ 1 .. 3 ]
gap> MakeImmutable(l);;
gap> IsIdenticalObj(AsSet(l), l);
true

#
gap> STOP_TEST("list.tst");
