gap> START_TEST("atomic_list.tst");

#
gap> l:=[1,2,3];
[ 1, 2, 3 ]
gap> Length(l);
3
gap> IsPlistRep(l);
true
gap> IsAtomicList(l);
false
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

#
gap> l:=AtomicList([1,2,3]);
[ 1, 2, 3 ]
gap> Length(l);
3
gap> IsPlistRep(l);
false
gap> IsAtomicList(l);
true
gap> LEN_POSOBJ(l);
3
gap> l[1]; l[2]; l[3];
1
2
3
gap> l[4];
Error, Atomic List Element: <pos>=4 is an invalid index for <list>
gap> l[1] := 42;; l;
[ 42, 2, 3 ]
gap> l[4] := 23;
23

#
gap> l:=FixedAtomicList([1,2,3]);
[ 1, 2, 3 ]
gap> Length(l);
3
gap> IsPlistRep(l);
false
gap> IsAtomicList(l);
true
gap> LEN_POSOBJ(l);
3
gap> l[1]; l[2]; l[3];
1
2
3
gap> l[4];
Error, Atomic List Element: <pos>=4 is an invalid index for <list>
gap> l[1] := 42;; l;
[ 42, 2, 3 ]
gap> l[4] := 23;
Error, Atomic List Element: <pos>=4 is an invalid index for <list>

#
gap> STOP_TEST("atomic_list.tst");
