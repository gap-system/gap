# This aims to test the various implementations of StableSort.
# There are a few cases we must cover:
#
# * We can choose if we pass a comparator
# * We can do Sort or SortParallel
# * We specialise for plain lists
# Most of these checks are generate a whole bunch of random tests
#
# We check StableSort implements Sort correctly
# and also have a special 'stability' check.


# We check stability in two ways, by building pairs, and also
# by using a comparator. We need this second case to ensure we
# check some non-plists. Also need to test with and without comparators.
gap> START_TEST("stablesort.tst");
gap> lowAlpha := Immutable(SSortedList("abcdefghijklmnopqrstuvwxyz"));;
gap> CheckStabilityPair := function(inputlist)
> local pairlist, listcpy1, listcpy2, intlist;
> pairlist := List([1..Length(inputlist)], x -> [inputlist[x],x]);
> listcpy1 := DEEP_COPY_OBJ(pairlist);
> listcpy2 := DEEP_COPY_OBJ(pairlist);
> Sort(listcpy1);
> StableSort(listcpy2, function(x,y) return x[1] < y[1]; end);
> if listcpy1 <> listcpy2 then
>    Print("failed Stability test 1:", inputlist, listcpy1, listcpy2);
> fi;
> listcpy2 := DEEP_COPY_OBJ(pairlist);
> intlist := [1..Length(inputlist)];
> StableSortParallel(listcpy2, intlist, function(x,y) return x[1] < y[1]; end);
> if intlist <> List(listcpy2, x -> x[2]) then
>    Print("failed Stability test 2:", listcpy2, intlist);
> fi;
> end;;

# The function checks non-plists (in particular, strings)
gap> CheckStabilityStr := function(inputlist)
> local listcpy, listcpy1, listcpy2, intlist;
> listcpy := DEEP_COPY_OBJ(inputlist);
> Sort(listcpy, function(x,y) return IntChar(x) mod 4 < IntChar(y) mod 4; end);
> listcpy1 := DEEP_COPY_OBJ(listcpy);
> listcpy2 := DEEP_COPY_OBJ(listcpy);
> Sort(listcpy1);
> StableSort(listcpy2, function(x,y) return IntChar(x)/4 < IntChar(y)/4; end);
> if listcpy1 <> listcpy2 then
>    Print("failed Stability test 1:", inputlist, listcpy1, listcpy2);
> fi;
> listcpy := DEEP_COPY_OBJ(inputlist);
> intlist := [1..Length(inputlist)];
> StableSortParallel(listcpy, intlist);
> if not IsSortedList(List([1..Length(inputlist)], i -> [listcpy[i], intlist[i]])) then
>    Print("failed Stability test 4:", listcpy, intlist);
> fi;
> listcpy := DEEP_COPY_OBJ(inputlist);
> intlist := [1..Length(inputlist)];
> StableSortParallel(listcpy, intlist, function(x,y) return x < y; end);
> if not IsSortedList(List([1..Length(inputlist)], i -> [listcpy[i], intlist[i]])) then
>    Print("failed Stability test 4:", listcpy, intlist);
> fi;
> end;;
gap> CheckSort := function(list, sorted)
>  local listcpy, perm;
>  listcpy := DEEP_COPY_OBJ(list); StableSort(listcpy);
>  if listcpy <> sorted then Print("Fail 1 : ", listcpy, list, sorted); fi;
>  listcpy := DEEP_COPY_OBJ(list); StableSort(listcpy, function (a,b) return a < b; end);
>  if listcpy <> sorted then Print("Fail 2 : ", listcpy, list, sorted); fi;
>  listcpy := DEEP_COPY_OBJ(list); StableSort(listcpy, function (a,b) return a <= b; end);
>  if listcpy <> sorted then Print("Fail 3 : ", listcpy, list, sorted); fi;
>  listcpy := DEEP_COPY_OBJ(list); Sort(listcpy, function (a,b) return a > b; end);
>  if listcpy <> Reversed(sorted) then Print("Fail 4 : ", listcpy, list, sorted); fi;
>  CheckStabilityPair(list);
>  if IsStringRep(list) then
>    CheckStabilityStr(list);
>  fi;
>  end;;
gap> for i in [0..500] do CheckSort([1..i],[1..i]); od;

# Want to make sure GAP doesn't know the list is sorted
gap> for i in [0..500] do CheckSort(List([1..i],x->x),[1..i]); od;
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
>          Add(l, lowAlpha[a]);
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
gap> IsStringRep(lowAlpha{[1..0]}) and IsStringRep(lowAlpha{[1..10]});
true
gap> for i in [0..26] do
>      for j in [0..10] do
>        CheckSortParallel(lowAlpha{[1..i]},Random(SymmetricGroup([1..i])), i);
>      od;
>    od;
gap> STOP_TEST("stablesort.tst", 1);
