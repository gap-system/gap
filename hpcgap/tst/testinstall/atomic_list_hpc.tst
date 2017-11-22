gap> START_TEST("atomic_list_hpc.tst");

# Tests which only make sense in HPC-GAP
# plist
gap> l:=[1,2,3];
[ 1, 2, 3 ]
gap> IsAtomicList(l);
false
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
gap> LEN_POSOBJ(l);
3
gap> IsPlistRep(l);
false
gap> IsAtomicList(l);
true
gap> l[4];
Error, Atomic List Element: <pos>=4 is an invalid index for <list>
gap> Add(l, 7);
gap> l;
[ 1, 2, 3, 7 ]
gap> Add(l, 7, 5);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Add' on 3 arguments
gap> a := FixedAtomicList(5);
[ ,,,, ]
gap> EqualLists(a, []);
true

# fixed sized list
gap> l:=FixedAtomicList([1,2,3]);
[ 1, 2, 3 ]
gap> Length(l);
3
gap> l[4];
Error, Atomic List Element: <pos>=4 is an invalid index for <list>
gap> l[1] := 42;; l;
[ 42, 2, 3 ]
gap> l[4] := 23;
Error, Atomic List Element: <pos>=4 is an invalid index for <list>
gap> a := FixedAtomicList(5);;
gap> EqualLists(a, []);
true
gap> ATOMIC_UNBIND(a, 10, 2);
Error, COMPARE_AND_SWAP: Index out of range
gap> ATOMIC_BIND(a, 10, 2);
Error, COMPARE_AND_SWAP: Index out of range
gap> a := FixedAtomicList(5);;
gap> COMPARE_AND_SWAP(a, 10, 1, 2);
Error, COMPARE_AND_SWAP: Index out of range
gap> Add(l, 7);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Add' on 2 arguments
gap> Add(l, 7, 5);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Add' on 3 arguments

#
gap> STOP_TEST("atomic_list.tst");
