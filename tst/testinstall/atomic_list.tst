gap> START_TEST("atomic_list.tst");

# Lists we can run in GAP and HPCGAP
# plist
gap> l:=[1,2,3];
[ 1, 2, 3 ]
gap> Length(l);
3
gap> IsPlistRep(l);
true
gap> LEN_POSOBJ(l);
3
gap> l[1]; l[2]; l[3];
1
2
3
gap> l[4];
Error, List Element: <list>[4] must have an assigned value
gap> l[1] := 42;; l;
[ 42, 2, 3 ]
gap> l[4] := 23;
23
gap> EqualLists := function(l1, l2)
>  local i;
>  for i in [1..Maximum(Length(l1), Length(l2))] do
>    if IsBound(l1[i]) <> IsBound(l2[i]) then
>       Print("Bound Inconsistency: ", l1, l2);
>       return false;
>    elif IsBound(l1[i]) and l1[i] <> l2[i] then
>       Print("Unequal lists: ", l1, l2);
>       return false;
>    fi;
>  od;
>  return true;
> end;;

# variable sized list
gap> l:=AtomicList([1,2,3]);
[ 1, 2, 3 ]
gap> Length(l);
3
gap> l[1]; l[2]; l[3];
1
2
3
gap> l[1] := 42;; l;
[ 42, 2, 3 ]
gap> l[4] := 23;
23
gap> l;
[ 42, 2, 3, 23 ]
gap> a := FixedAtomicList(5);;
gap> EqualLists(a, []);
true
gap> a[2] := 7;
7
gap> IsBound(a[2]);
true
gap> IsBound(a[3]);
false
gap> IsBound(a[9]);
false
gap> GetWithDefault(a, 2, -1);
7
gap> GetWithDefault(a, 3, -1);
-1
gap> GetWithDefault(a, 10, -1);
-1
gap> s := "";;
gap> IsIdenticalObj(GetWithDefault(a, 10, s), s);
true
gap> COMPARE_AND_SWAP(a, 2, 6, 5);
false
gap> EqualLists(a, [,7]);
true
gap> COMPARE_AND_SWAP(a, 2, 7, 5);
true
gap> EqualLists(a, [,5]);
true
gap> COMPARE_AND_SWAP(a, 2, 5, [8]);
true
gap> EqualLists(a, [,[8]]);
true
gap> COMPARE_AND_SWAP(a, 2, [8], [7]);
false
gap> ATOMIC_BIND(a, 2, 5);
false
gap> EqualLists(a, [,[8]]);
true
gap> ATOMIC_BIND(a, 1, 7);
true
gap> EqualLists(a, [7,[8]]);
true
gap> ATOMIC_BIND(a, 1, 7);
false
gap> ATOMIC_UNBIND(a, 1, 6);
false
gap> EqualLists(a, [7,[8]]);
true
gap> ATOMIC_UNBIND(a, 1, 7);
true
gap> EqualLists(a, [,[8]]);
true
gap> a := AtomicList(5);;
gap> EqualLists(a, []);
true
gap> ATOMIC_BIND(a, 10, 2);
true
gap> EqualLists(a,[ ,,,,,,,,, 2 ]);
true
gap> a := AtomicList(5);;
gap> ATOMIC_UNBIND(a, 10, 2);
false
gap> EqualLists(a, []);
true
gap> a := AtomicList(5);;
gap> COMPARE_AND_SWAP(a, 10, 1, 2);
false
gap> EqualLists(a, []);
true

# fixed sized list
gap> l:=FixedAtomicList([1,2,3]);
[ 1, 2, 3 ]
gap> Length(l);
3
gap> l[1]; l[2]; l[3];
1
2
3
gap> l[1] := 42;; l;
[ 42, 2, 3 ]
gap> a := FixedAtomicList(5);;
gap> EqualLists(a, []);
true
gap> a[2] := 7;
7
gap> IsBound(a[2]);
true
gap> IsBound(a[3]);
false
gap> IsBound(a[9]);
false
gap> GetWithDefault(a, 2, -1);
7
gap> GetWithDefault(a, 3, -1);
-1
gap> GetWithDefault(a, 10, -1);
-1
gap> s := "";;
gap> IsIdenticalObj(GetWithDefault(a, 10, s), s);
true
gap> COMPARE_AND_SWAP(a, 2, 6, 5);
false
gap> EqualLists(a, [,7]);
true
gap> COMPARE_AND_SWAP(a, 2, 7, 5);
true
gap> EqualLists(a, [,5]);
true
gap> COMPARE_AND_SWAP(a, 2, 5, [8]);
true
gap> EqualLists(a, [,[8]]);
true
gap> COMPARE_AND_SWAP(a, 2, [8], [7]);
false
gap> ATOMIC_BIND(a, 2, 5);
false
gap> EqualLists(a, [,[8]]);
true
gap> ATOMIC_BIND(a, 1, 7);
true
gap> EqualLists(a, [7,[8]]);
true
gap> ATOMIC_BIND(a, 1, 7);
false
gap> ATOMIC_UNBIND(a, 1, 6);
false
gap> EqualLists(a, [7,[8]]);
true
gap> ATOMIC_UNBIND(a, 1, 7);
true
gap> EqualLists(a, [,[8]]);
true

#
gap> STOP_TEST("atomic_list.tst");
