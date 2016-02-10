# This aims to test the various implementations of Sort. There are a few cases
# we must cover:
#
# * We can choose if we pass a comparator
# * We can do Sort or SortParallel
# * We specialise for plain lists
# Most of these checks are generate a whole bunch of random tests

gap> START_TEST("sort.tst");
gap> CheckSort := function(list, sorted)
>  local listcpy, perm;
>  listcpy := DEEP_COPY_OBJ(list); Sort(listcpy);
>  if listcpy <> sorted then Print("Fail 1 : ", listcpy, list, sorted); fi;
>  listcpy := DEEP_COPY_OBJ(list); Sort(listcpy, function (a,b) return a < b; end);
>  if listcpy <> sorted then Print("Fail 2 : ", listcpy, list, sorted); fi;
>  listcpy := DEEP_COPY_OBJ(list); Sort(listcpy, function (a,b) return a <= b; end);
>  if listcpy <> sorted then Print("Fail 3 : ", listcpy, list, sorted); fi;
>  listcpy := DEEP_COPY_OBJ(list); Sort(listcpy, function (a,b) return a > b; end);
>  if listcpy <> Reversed(sorted) then Print("Fail 4 : ", listcpy, list, sorted); fi;
>  end;;
gap> for i in [0..500] do CheckSort([1..i],[1..i]); od;
gap> for i in [0..500] do CheckSort([-i..i],[-i..i]); od;
gap> for i in [0..500] do CheckSort([i,i-1..-i],[-i..i]); od;
gap> for i in [0..500] do
>      for j in [0..10] do
>        CheckSort(Shuffle([1..i]), [1..i]);
>      od;
>    od;
gap> for i in [0..100] do
>      for j in [0..10] do
>        l := Concatenation(List([0..j], x -> List([0..i], y -> x)));
>        l2 := Shuffle(List(l));
>        CheckSort(l2, l);
>      od;
>    od;

# Need to test something which are not plists. Strings are a good choice.
gap> for i in [0..100] do
>      for j in [0..10] do
>        l := "";
>        for a in [1..j] do for b in [1..i] do
>          Add(l, CHARS_LALPHA[a]);
>        od; od;
>        l2 := Shuffle(List(l));
>        if not(IsStringRep(l)) or not(IsStringRep(l2)) then
>          Print("StringFail");
>        fi;
>        CheckSort(l2, l);
>      od;
>    od;

# Let test bool lists too!
gap> for i in [0..100] do
>      for j in [0..10] do
>        l := BlistList([1..i+j],[1..i]);
>        l2 := Shuffle(List(l));
>        if not(IsBlistRep(l)) or not(IsBlistRep(l2)) then
>          Print("BlistFail");
>        fi;
>        CheckSort(l2, l);
>      od;
>    od;

# Test SortParallel
gap> CheckSortParallel := function(sortedlist, perm, maxval)
> local list1, list2, listcpy, list1orig;
> # This slightly weird code is because I want to preserve
> # The type of the input list
> list1orig := DEEP_COPY_OBJ(sortedlist);
> for i in [1..maxval] do
>   list1orig[i] := sortedlist[i^perm];
> od;
> list1 := DEEP_COPY_OBJ(list1orig);
> list2 := List([1..maxval], x -> Random([1..100]));
> listcpy := List(list2);
> SortParallel(list1, list2);
> if ForAny([1..maxval], x -> list2[x^perm] <> listcpy[x]) then
>  Print("failed SortParallel 1", perm, maxval, list2);
> fi;
> list1 := DEEP_COPY_OBJ(list1orig);
> listcpy := List(list2);
> SortParallel(list1, list2, function (a,b) return a <= b; end);
> if ForAny([1..maxval], x -> list2[x^perm] <> listcpy[x]) then
>  Print("failed SortParallel 2", perm, maxval, list2);
> fi;
> end;;
gap> for i in [0..100] do
>      for j in [0..10] do
>        CheckSortParallel([1..i],Random(SymmetricGroup([1..i])), i);
>      od;
>    od;

# Just sanity check I really am making string reps
gap> IsStringRep(CHARS_LALPHA{[1..0]}) and IsStringRep(CHARS_LALPHA{[1..10]});
true
gap> for i in [0..26] do
>      for j in [0..10] do
>        CheckSortParallel(CHARS_LALPHA{[1..i]},Random(SymmetricGroup([1..i])), i);
>      od;
>    od;
