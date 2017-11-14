# This aims to test the various implementations of Sort. There are a few cases
# we must cover:
#
# * We can choose if we pass a comparator
# * We can do Sort or SortParallel
# * We specialise for plain lists
# Most of these checks are generate a whole bunch of random tests

gap> START_TEST("sort.tst");
gap> lowAlpha := Immutable(SSortedList("abcdefghijklmnopqrstuvwxyz"));;
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
gap> # Check filters are correctly set/unset with various sortings (and merge sortings)
gap> CheckFiltersInner := function(list, isSort, isSSort, revisSort, revisSsort, sorter)
>  sorter(list);
>  if IsSortedList(list) <> isSort then
>   Print("fail isSorted : '", list, "'", isSort, "\n");
>  fi;
>  if IsSSortedList(list) <> isSSort then
>   Print("fail isSSorted : ", list, "\n");
>  fi;
>  sorter(list, function(x, y) return x < y; end);
>  if IsSortedList(list) <> isSort then
>   Print("fail isSorted 2 : '", list, "'", isSort, "\n");
>  fi;
>  if IsSSortedList(list) <> isSSort then
>   Print("fail isSSorted 2 : ", list, "\n");
>  fi;
>  sorter(list, function(x, y) return x > y; end);
>  if IsSortedList(list) <> revisSort then
>   Print("fail isSorted 3 : ", list, "\n");
>  fi;
>  if IsSSortedList(list) <> revisSsort then
>   Print("fail isSSorted 3 : ", list, "\n");
>  fi;
>  sorter(list, function(x, y) return x < y; end);
>  if IsSortedList(list) <> isSort then
>   Print("fail isSorted 4 : '", list, "'", isSort, "\n");
>  fi;
>  if IsSSortedList(list) <> isSSort then
>   Print("fail isSSorted 4 : ", list, "\n");
>  fi;
> end;;
gap> CheckFilters := function(list, isSort, isSSort, revisSort, revisSsort)
> CheckFiltersInner(list, isSort, isSSort, revisSort, revisSsort, Sort);
> CheckFiltersInner(list, isSort, isSSort, revisSort, revisSsort, StableSort);
> end;;
gap> for i in [0..500] do CheckSort([1..i],[1..i]); od;

# Want to make sure GAP doesn't know the list is sorted
gap> for i in [0..500] do CheckSort(List([1..i],x->x),[1..i]); od;
gap> for i in [0..500] do CheckSort([-i..i],[-i..i]); od;
gap> for i in [0..500] do CheckSort([i,i-1..-i],[-i..i]); od;
gap> for i in [0..50] do
>      for j in [0..10] do
>        CheckSort(Shuffle([1..i]), [1..i]);
>        CheckFilters([1..i], true, true, i <= 1, i <= 1);
>        CheckFilters(Shuffle([1..i]), true, true, i <= 1, i <= 1);
>      od;
>    od;
gap> for i in [0..100] do
>      for j in [0..10] do
>        l := Concatenation(List([0..j], x -> List([0..i], y -> x)));
>        l2 := Shuffle(List(l));
>        CheckSort(l2, l);
>        CheckFilters(l, true, i = 0, j = 0, i = 0 and j = 0);
>      od;
>    od;

# Need to test something which are not plists. Strings are a good choice.
gap> for i in [0..50] do
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
>        CheckFilters(l, true, i <= 1 or j <= 0,
>          i=0 or j<=1 or (i <= 1 and j <= 1), i=0 or j=0 or (i <= 1 and j <= 1));
>      od;
>    od;

# Let test bool lists too!
gap> for i in [0..50] do
>      for j in [0..10] do
>        l := BlistList([1..i+j],[1..i]);
>        l2 := Shuffle(List(l));
>        if not(IsBlistRep(l)) or not(IsBlistRep(l2)) then
>          Print("BlistFail");
>        fi;
>        CheckSort(l2, l);
>        CheckFilters(l, true, i<=1 and j<=1, i = 0 or j = 0, i+j <= 1);
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
gap> IsStringRep(lowAlpha{[1..0]}) and IsStringRep(lowAlpha{[1..10]});
true
gap> for i in [0..26] do
>      for j in [0..10] do
>        CheckSortParallel(lowAlpha{[1..i]},Random(SymmetricGroup([1..i])), i);
>      od;
>    od;
gap> # Pass two lists, where reverse-ordering x orders y
gap> ParallelFilterCheckInner := function(x,y, strict, sorter)
> sorter(x, y);
> if not(IsSortedList(x)      and IsSSortedList(x)=strict and
>       not(IsSortedList(y)) and not(IsSSortedList(y)) ) then
>    Print("ParFilter1 fail", x, y, strict);
> fi;
> sorter(x, y, function(x,y) return x > y; end);
> if not(IsSortedList(y)      and IsSSortedList(y)=strict and
>        not(IsSortedList(x)) and not(IsSSortedList(x)) ) then
>    Print("ParFilter2 fail", x, y, strict);
> fi;
> sorter(x, y, function(x,y) return x < y; end);
> if not(IsSortedList(x)      and IsSSortedList(x)=strict and
>       not(IsSortedList(y)) and not(IsSSortedList(y)) ) then
>    Print("ParFilter3 fail", x, y, strict);
> fi;
> sorter(x, y);
> if not(IsSortedList(x)      and IsSSortedList(x)=strict and
>       not(IsSortedList(y)) and not(IsSSortedList(y)) ) then
>    Print("ParFilter4 fail", x, y, strict);
> fi;
> end;;
gap> ParallelFilterCheck := function(x,y,strict)
> ParallelFilterCheckInner(x,y,strict, SortParallel);
> ParallelFilterCheckInner(x,y,strict, StableSortParallel);
> end;;
gap> x := [1..10];;
gap> y := [10,9..1];;
gap> ParallelFilterCheck(x, y, true);
gap> x := [1,1,1,2,2,2];;
gap> y := [2,2,2,1,1,1];;
gap> ParallelFilterCheck(x, y, false);
gap> x := "abcdef";;
gap> y := Reversed(x);;
gap> ParallelFilterCheck(x, y, true);
gap> y := [6,5..1];;
gap> ParallelFilterCheck(x, y, true);
gap> x := "aabbccddeeff";;
gap> y := Reversed(x);;
gap> ParallelFilterCheck(x, y, false);
gap> y := [6,6,5,5,4,4,3,3,2,2,1,1];;
gap> ParallelFilterCheck(x, y, false);
gap> STOP_TEST("sort.tst", 1);
