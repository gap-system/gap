gap> START_TEST("stabchain.tst");
gap> TestGens := function(g)
> local m;
> m := SortedList(List(g));
> if Size(m) <> Size(g) or Size(Set(m)) <> Size(m) or
>    Group(m) <> g then Print("0"); fi;
> ChangeStabChain(StabChainMutable(g), [1..10], false);
> if m <> SortedList(List(g)) then Print("1"); fi;
> if m <> SortedList(List(g, x -> x)) then Print("2"); fi;
> ChangeStabChain(StabChainMutable(g), [10,9..1], false);
> if m <> SortedList(List(g)) then Print("3"); fi;
> if m <> SortedList(List(g, x -> x)) then Print("3"); fi;
> ChangeStabChain(StabChainMutable(g), [1,10,11,12,13,14,15,2,3,4,5,6,7,8], false);
> if m <> SortedList(List(g)) then Print("5"); fi;
> if m <> SortedList(List(g, x -> x)) then Print("4"); fi;
> return true;
> end;;
gap> TestGens(Group(()));;
gap> List([2..7],
>       x -> List([1..NrTransitiveGroups(x)],
>         y -> TestGens(TransitiveGroup(x,y))));;
gap> STOP_TEST("stabchain.tst", 1);
